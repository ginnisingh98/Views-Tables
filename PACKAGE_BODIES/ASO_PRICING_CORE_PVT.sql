--------------------------------------------------------
--  DDL for Package Body ASO_PRICING_CORE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_PRICING_CORE_PVT" as
/* $Header: asovpcob.pls 120.15.12010000.22 2017/03/13 08:54:52 rassharm ship $ */
-- Start of Comments
-- Package name     : ASO_PRICING_CORE_PVT
-- Purpose          :
-- History          :
--             120.13.12000000.2	02/07/2007     gkeshava - Fix for perf bug 5614878
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'ASO_PRICING_CORE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asovpcob.pls';
--G_ADJ_NUM   CONSTANT NUMBER := 999;

PROCEDURE Initialize_Global_Tables
IS
BEGIN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('ASO_PRICING_CORE_PVT: Begin Initializing All the Globals',1,'Y');
END IF;

G_LINE_INDEX_tbl.delete;
G_LINE_TYPE_CODE_TBL.delete;
G_PRICING_EFFECTIVE_DATE_TBL.delete;
G_ACTIVE_DATE_FIRST_TBL.delete;
G_ACTIVE_DATE_FIRST_TYPE_TBL.delete;
G_ACTIVE_DATE_SECOND_TBL.delete;
G_ACTIVE_DATE_SECOND_TYPE_TBL.delete;
G_LINE_QUANTITY_TBL.delete;
G_LINE_UOM_CODE_TBL.delete;
G_REQUEST_TYPE_CODE_TBL.delete;
G_PRICED_QUANTITY_TBL.delete;
G_UOM_QUANTITY_TBL.delete;
G_PRICED_UOM_CODE_TBL.delete;
G_CURRENCY_CODE_TBL.delete;
G_UNIT_PRICE_TBL.delete;
G_LINE_UNIT_PRICE_TBL.delete; -- bug 20700246 , commented for Bug 19243138
G_PERCENT_PRICE_TBL.delete;
G_ADJUSTED_UNIT_PRICE_TBL.delete;
G_UPD_ADJUSTED_UNIT_PRICE_TBL.delete;
G_PROCESSED_FLAG_TBL.delete;
G_PRICE_FLAG_TBL.delete;
G_LINE_ID_TBL.delete;
G_PROCESSING_ORDER_TBL.delete;
G_ROUNDING_FACTOR_TBL.delete;
G_ROUNDING_FLAG_TBL.delete;
G_QUALIFIERS_EXIST_FLAG_TBL.delete;
G_PRICING_ATTRS_EXIST_FLAG_TBL.delete;
G_PRICE_LIST_ID_TBL.delete;
G_PL_VALIDATED_FLAG_TBL.delete;
G_PRICE_REQUEST_CODE_TBL.delete;
G_USAGE_PRICING_TYPE_TBL.delete;
G_LINE_CATEGORY_TBL.delete;
G_PRICING_STATUS_CODE_tbl.delete;
G_PRICING_STATUS_TEXT_tbl.delete;
G_CHRG_PERIODICITY_CODE_TBL.delete;
/* Changes Made for OKS uptake bug 4900084  */
G_CONTRACT_START_DATE_TBL.delete;
G_CONTRACT_END_DATE_TBL.delete;

G_ATTR_LINE_INDEX_tbl.delete;
G_ATTR_LINE_DETAIL_INDEX_tbl.delete;
G_ATTR_VALIDATED_FLAG_tbl.delete;
G_ATTR_PRICING_CONTEXT_tbl.delete;
G_ATTR_PRICING_ATTRIBUTE_tbl.delete;
G_ATTR_ATTRIBUTE_LEVEL_tbl.delete;
G_ATTR_ATTRIBUTE_TYPE_tbl.delete;
G_ATTR_APPLIED_FLAG_tbl.delete;
G_ATTR_PRICING_STATUS_CODE_tbl.delete;
G_ATTR_PRICING_ATTR_FLAG_tbl.delete;
G_ATTR_LIST_HEADER_ID_tbl.delete;
G_ATTR_LIST_LINE_ID_tbl.delete;
G_ATTR_VALUE_FROM_tbl.delete;
G_ATTR_SETUP_VALUE_FROM_tbl.delete;
G_ATTR_VALUE_TO_tbl.delete;
G_ATTR_SETUP_VALUE_TO_tbl.delete;
G_ATTR_GROUPING_NUMBER_tbl.delete;
G_ATTR_NO_QUAL_IN_GRP_tbl.delete;
G_ATTR_COMP_OPERATOR_TYPE_tbl.delete;
G_ATTR_PRICING_STATUS_TEXT_tbl.delete;
G_ATTR_QUAL_PRECEDENCE_tbl.delete;
G_ATTR_DATATYPE_tbl.delete;
G_ATTR_QUALIFIER_TYPE_tbl.delete;
G_ATTR_PRODUCT_UOM_CODE_TBL.delete;
G_ATTR_EXCLUDER_FLAG_TBL.delete;
G_ATTR_PRICING_PHASE_ID_TBL.delete;
G_ATTR_INCOM_GRP_CODE_TBL.delete;
G_ATTR_LDET_TYPE_CODE_TBL.delete;
G_ATTR_MODIFIER_LEVEL_CODE_TBL.delete;
G_ATTR_PRIMARY_UOM_FLAG_TBL.delete;

G_LDET_LINE_DTL_INDEX_TBL.delete;
G_LDET_PRICE_ADJ_ID_TBL.delete;
G_LDET_LINE_DTL_TYPE_TBL.delete;
G_LDET_PRICE_BREAK_TYPE_TBL.delete;
G_LDET_LIST_PRICE_TBL.delete;
G_LDET_LINE_INDEX_TBL.delete;
G_LDET_LIST_HEADER_ID_TBL.delete;
G_LDET_LIST_LINE_ID_TBL.delete;
G_LDET_LIST_LINE_TYPE_TBL.delete;
G_LDET_LIST_TYPE_CODE_TBL.delete;
G_LDET_CREATED_FROM_SQL_TBL.delete;
G_LDET_PRICING_GRP_SEQ_TBL.delete;
G_LDET_PRICING_PHASE_ID_TBL.delete;
G_LDET_OPERAND_CALC_CODE_TBL.delete;
G_LDET_OPERAND_VALUE_TBL.delete;
G_LDET_SUBSTN_TYPE_TBL.delete;
G_LDET_SUBSTN_VALUE_FROM_TBL.delete;
G_LDET_SUBSTN_VALUE_TO_TBL.delete;
G_LDET_ASK_FOR_FLAG_TBL.delete;
G_LDET_PRICE_FORMULA_ID_TBL.delete;
G_LDET_PRICING_STATUS_CODE_TBL.delete;
G_LDET_PRICING_STATUS_TXT_TBL.delete;
G_LDET_PRODUCT_PRECEDENCE_TBL.delete;
G_LDET_INCOMPAT_GRP_CODE_TBL.delete;
G_LDET_PROCESSED_FLAG_TBL.delete;
G_LDET_APPLIED_FLAG_TBL.delete;
G_LDET_AUTOMATIC_FLAG_TBL.delete;
G_LDET_OVERRIDE_FLAG_TBL.delete;
G_LDET_PRIMARY_UOM_FLAG_TBL.delete;
G_LDET_PRINT_ON_INV_FLAG_TBL.delete;
G_LDET_MODIFIER_LEVEL_TBL.delete;
G_LDET_BENEFIT_QTY_TBL.delete;
G_LDET_BENEFIT_UOM_CODE_TBL.delete;
G_LDET_LIST_LINE_NO_TBL.delete;
G_LDET_ACCRUAL_FLAG_TBL.delete;
G_LDET_ACCR_CONV_RATE_TBL.delete;
G_LDET_ESTIM_ACCR_RATE_TBL.delete;
G_LDET_RECURRING_FLAG_TBL.delete;
G_LDET_SELECTED_VOL_ATTR_TBL.delete;
G_LDET_ROUNDING_FACTOR_TBL.delete;
G_LDET_HDR_LIMIT_EXISTS_TBL.delete;
G_LDET_LINE_LIMIT_EXISTS_TBL.delete;
G_LDET_CHARGE_TYPE_TBL.delete;
G_LDET_CHARGE_SUBTYPE_TBL.delete;
G_LDET_CURRENCY_DTL_ID_TBL.delete;
G_LDET_CURRENCY_HDR_ID_TBL.delete;
G_LDET_SELLING_ROUND_TBL.delete;
G_LDET_ORDER_CURRENCY_TBL.delete;
G_LDET_PRICING_EFF_DATE_TBL.delete;
G_LDET_BASE_CURRENCY_TBL.delete;
G_LDET_LINE_QUANTITY_TBL.delete;
G_LDET_UPDATED_FLAG_TBL.delete;
G_LDET_CALC_CODE_TBL.delete;
G_LDET_CHG_REASON_CODE_TBL.delete;
G_LDET_CHG_REASON_TEXT_TBL.delete;

G_RLTD_LINE_INDEX_TBL.delete;
G_RLTD_LINE_DTL_INDEX_TBL.delete;
G_RLTD_RELATION_TYPE_CODE_TBL.delete;
G_RLTD_RELATED_LINE_IND_TBL.delete;
G_RLTD_RLTD_LINE_DTL_IND_TBL.delete;
G_RLTD_LST_LN_ID_DEF_TBL.delete;
G_RLTD_RLTD_LST_LN_ID_DEF_TBL.delete;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('ASO_PRICING_CORE_PVT: End Initializing All the Globals',1,'Y');
END IF;

END Initialize_Global_Tables;

FUNCTION Set_Global_Rec (
    p_qte_header_rec      ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    p_shipment_rec        ASO_QUOTE_PUB.Shipment_Rec_Type)
RETURN ASO_PRICING_INT.PRICING_HEADER_REC_TYPE
IS
    l_header_rec    ASO_PRICING_INT.PRICING_HEADER_REC_TYPE;
BEGIN
    l_header_rec.QUOTE_HEADER_ID := p_qte_header_rec.QUOTE_HEADER_ID;
    l_header_rec.CREATION_DATE := p_qte_header_rec.CREATION_DATE;
    l_header_rec.CREATED_BY := p_qte_header_rec.CREATED_BY;
    l_header_rec.LAST_UPDATE_DATE := p_qte_header_rec.LAST_UPDATE_DATE;
    l_header_rec.LAST_UPDATED_BY := p_qte_header_rec.LAST_UPDATED_BY;
    l_header_rec.LAST_UPDATE_LOGIN := p_qte_header_rec.LAST_UPDATE_LOGIN;
    l_header_rec.REQUEST_ID := p_qte_header_rec.REQUEST_ID;
    l_header_rec.PROGRAM_APPLICATION_ID := p_qte_header_rec.PROGRAM_APPLICATION_ID;
    l_header_rec.PROGRAM_ID := p_qte_header_rec.PROGRAM_ID;
    l_header_rec.PROGRAM_UPDATE_DATE := p_qte_header_rec.PROGRAM_UPDATE_DATE;
    l_header_rec.ORG_ID := p_qte_header_rec.ORG_ID;
    l_header_rec.QUOTE_NAME := p_qte_header_rec.QUOTE_NAME;
    l_header_rec.QUOTE_NUMBER := p_qte_header_rec.QUOTE_NUMBER;
    l_header_rec.QUOTE_VERSION := p_qte_header_rec.QUOTE_VERSION;
    l_header_rec.QUOTE_STATUS_ID := p_qte_header_rec.QUOTE_STATUS_ID;
    l_header_rec.QUOTE_SOURCE_CODE := p_qte_header_rec.QUOTE_SOURCE_CODE;
    l_header_rec.QUOTE_EXPIRATION_DATE := p_qte_header_rec.QUOTE_EXPIRATION_DATE;
    l_header_rec.PRICE_FROZEN_DATE := p_qte_header_rec.PRICE_FROZEN_DATE;
    l_header_rec.QUOTE_PASSWORD := p_qte_header_rec.QUOTE_PASSWORD;
    l_header_rec.ORIGINAL_SYSTEM_REFERENCE := p_qte_header_rec.ORIGINAL_SYSTEM_REFERENCE;
    l_header_rec.CUST_PARTY_ID:= p_qte_header_rec.CUST_PARTY_ID;
    l_header_rec.PARTY_ID := p_qte_header_rec.PARTY_ID;
    l_header_rec.CUST_ACCOUNT_ID := p_qte_header_rec.CUST_ACCOUNT_ID;
    l_header_rec.ORG_CONTACT_ID := p_qte_header_rec.ORG_CONTACT_ID;
    l_header_rec.PHONE_ID := p_qte_header_rec.PHONE_ID;
    l_header_rec.INVOICE_TO_PARTY_SITE_ID := p_qte_header_rec.INVOICE_TO_PARTY_SITE_ID;
    l_header_rec.INVOICE_TO_PARTY_ID := p_qte_header_rec.INVOICE_TO_PARTY_ID;
    l_header_rec.ORIG_MKTG_SOURCE_CODE_ID := p_qte_header_rec.ORIG_MKTG_SOURCE_CODE_ID;
    l_header_rec.MARKETING_SOURCE_CODE_ID := p_qte_header_rec.MARKETING_SOURCE_CODE_ID;
    l_header_rec.ORDER_TYPE_ID := p_qte_header_rec.ORDER_TYPE_ID;
    l_header_rec.QUOTE_CATEGORY_CODE := p_qte_header_rec.QUOTE_CATEGORY_CODE;
    l_header_rec.ORDERED_DATE := p_qte_header_rec.ORDERED_DATE;
    l_header_rec.ACCOUNTING_RULE_ID := p_qte_header_rec.ACCOUNTING_RULE_ID;
    l_header_rec.INVOICING_RULE_ID := p_qte_header_rec.INVOICING_RULE_ID;
    l_header_rec.EMPLOYEE_PERSON_ID := p_qte_header_rec.EMPLOYEE_PERSON_ID;
    l_header_rec.PRICE_LIST_ID := p_qte_header_rec.PRICE_LIST_ID;
    l_header_rec.CURRENCY_CODE := p_qte_header_rec.CURRENCY_CODE;
    l_header_rec.TOTAL_LIST_PRICE := p_qte_header_rec.TOTAL_LIST_PRICE;
    l_header_rec.TOTAL_ADJUSTED_AMOUNT := p_qte_header_rec.TOTAL_ADJUSTED_AMOUNT;
    l_header_rec.TOTAL_ADJUSTED_PERCENT := p_qte_header_rec.TOTAL_ADJUSTED_PERCENT;
    l_header_rec.TOTAL_TAX := p_qte_header_rec.TOTAL_TAX;
    l_header_rec.TOTAL_SHIPPING_CHARGE := p_qte_header_rec.TOTAL_SHIPPING_CHARGE;
    l_header_rec.SURCHARGE := p_qte_header_rec.SURCHARGE;
    l_header_rec.TOTAL_QUOTE_PRICE := p_qte_header_rec.TOTAL_QUOTE_PRICE;
    l_header_rec.PAYMENT_AMOUNT := p_qte_header_rec.PAYMENT_AMOUNT;
    l_header_rec.CONTRACT_ID := p_qte_header_rec.CONTRACT_ID;
    l_header_rec.SALES_CHANNEL_CODE := p_qte_header_rec.SALES_CHANNEL_CODE;
    l_header_rec.ORDER_ID := p_qte_header_rec.ORDER_ID;
    l_header_rec.RECALCULATE_FLAG := p_qte_header_rec.RECALCULATE_FLAG;
    l_header_rec.ATTRIBUTE_CATEGORY := p_qte_header_rec.ATTRIBUTE_CATEGORY;
    l_header_rec.ATTRIBUTE1 := p_qte_header_rec.ATTRIBUTE1;
    l_header_rec.ATTRIBUTE2 := p_qte_header_rec.ATTRIBUTE2;
    l_header_rec.ATTRIBUTE3 := p_qte_header_rec.ATTRIBUTE3;
    l_header_rec.ATTRIBUTE4 := p_qte_header_rec.ATTRIBUTE4;
    l_header_rec.ATTRIBUTE5 := p_qte_header_rec.ATTRIBUTE5;
    l_header_rec.ATTRIBUTE6 := p_qte_header_rec.ATTRIBUTE6;
    l_header_rec.ATTRIBUTE7 := p_qte_header_rec.ATTRIBUTE7;
    l_header_rec.ATTRIBUTE8 := p_qte_header_rec.ATTRIBUTE8;
    l_header_rec.ATTRIBUTE9 := p_qte_header_rec.ATTRIBUTE9;
    l_header_rec.ATTRIBUTE10 := p_qte_header_rec.ATTRIBUTE10;
    l_header_rec.ATTRIBUTE11 := p_qte_header_rec.ATTRIBUTE11;
    l_header_rec.ATTRIBUTE12 := p_qte_header_rec.ATTRIBUTE12;
    l_header_rec.ATTRIBUTE13 := p_qte_header_rec.ATTRIBUTE13;
    l_header_rec.ATTRIBUTE14 := p_qte_header_rec.ATTRIBUTE14;
    l_header_rec.ATTRIBUTE15 := p_qte_header_rec.ATTRIBUTE15;
     -- Added for bug 12696699
    l_header_rec.ATTRIBUTE16 := p_qte_header_rec.ATTRIBUTE16;
    l_header_rec.ATTRIBUTE17 := p_qte_header_rec.ATTRIBUTE17;
    l_header_rec.ATTRIBUTE18 := p_qte_header_rec.ATTRIBUTE18;
    l_header_rec.ATTRIBUTE19 := p_qte_header_rec.ATTRIBUTE19;
    l_header_rec.ATTRIBUTE20 := p_qte_header_rec.ATTRIBUTE20;
    --end bug 12696699
    l_header_rec.PROMISE_DATE := p_shipment_rec.PROMISE_DATE;
    l_header_rec.REQUEST_DATE := p_shipment_rec.REQUEST_DATE;
    l_header_rec.SCHEDULE_SHIP_DATE := p_shipment_rec.SCHEDULE_SHIP_DATE;
    l_header_rec.SHIP_TO_PARTY_SITE_ID := p_shipment_rec.SHIP_TO_PARTY_SITE_ID;
    l_header_rec.SHIP_TO_PARTY_ID := p_shipment_rec.SHIP_TO_PARTY_ID;
    l_header_rec.SHIP_PARTIAL_FLAG := p_shipment_rec.SHIP_PARTIAL_FLAG;
    l_header_rec.SHIP_SET_ID := p_shipment_rec.SHIP_SET_ID;
    l_header_rec.SHIP_METHOD_CODE := p_shipment_rec.SHIP_METHOD_CODE;
    l_header_rec.FREIGHT_TERMS_CODE := p_shipment_rec.FREIGHT_TERMS_CODE;
    l_header_rec.FREIGHT_CARRIER_CODE := p_shipment_rec.FREIGHT_CARRIER_CODE;
    l_header_rec.FOB_CODE := p_shipment_rec.FOB_CODE;
    l_header_rec.SHIPPING_INSTRUCTIONS := p_shipment_rec.SHIPPING_INSTRUCTIONS;
    l_header_rec.PACKING_INSTRUCTIONS := p_shipment_rec.PACKING_INSTRUCTIONS;
    l_header_rec.EXCHANGE_TYPE_CODE := p_qte_header_rec.EXCHANGE_TYPE_CODE;
    l_header_rec.EXCHANGE_RATE_DATE := p_qte_header_rec.EXCHANGE_RATE_DATE;
    l_header_rec.EXCHANGE_RATE := p_qte_header_rec.EXCHANGE_RATE;
    l_header_rec.MINISITE_ID := p_qte_header_rec.MINISITE_ID;
      --Bug 21661093
    l_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID := p_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID;
    return l_header_rec;
END Set_Global_Rec;

FUNCTION Set_Global_Rec (
    p_qte_line_rec        ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    p_qte_line_dtl_rec    ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type,
    p_shipment_rec        ASO_QUOTE_PUB.Shipment_Rec_Type)
RETURN ASO_PRICING_INT.PRICING_LINE_REC_TYPE
IS
    l_line_rec    ASO_PRICING_INT.PRICING_LINE_REC_TYPE;
    l_inventory_item_id NUMBER;

    /*Cursor to obtain the top model inventory item id*/
    CURSOR C_top_model_item_id(p_config_hdr_id NUMBER, p_rev_num NUMBER) IS
        SELECT qte.inventory_item_id
        FROM aso_quote_line_details line_dtl
             ,aso_quote_lines_all qte
        WHERE qte.quote_line_id = line_dtl.quote_line_id
        AND line_dtl.config_header_id = p_config_hdr_id
        AND line_dtl.config_revision_num = p_rev_num
        AND line_dtl.ref_type_code = 'CONFIG'
        AND line_dtl.ref_line_id is null;
BEGIN
    l_line_rec.quote_line_id := p_qte_line_rec.quote_line_id;
    l_line_rec.CREATION_DATE := p_qte_line_rec.CREATION_DATE;
    l_line_rec.CREATED_BY := p_qte_line_rec.CREATED_BY;
    l_line_rec.LAST_UPDATE_DATE := p_qte_line_rec.LAST_UPDATE_DATE;
    l_line_rec.LAST_UPDATED_BY := p_qte_line_rec.LAST_UPDATED_BY;
    l_line_rec.LAST_UPDATE_LOGIN := p_qte_line_rec.LAST_UPDATE_LOGIN;
    l_line_rec.REQUEST_ID := p_qte_line_rec.REQUEST_ID;
    l_line_rec.PROGRAM_APPLICATION_ID := p_qte_line_rec.PROGRAM_APPLICATION_ID;
    l_line_rec.PROGRAM_ID := p_qte_line_rec.PROGRAM_ID;
    l_line_rec.PROGRAM_UPDATE_DATE := p_qte_line_rec.PROGRAM_UPDATE_DATE;
    l_line_rec.quote_header_id := p_qte_line_rec.quote_header_id;
    l_line_rec.ORG_ID := p_qte_line_rec.ORG_ID;
    l_line_rec.LINE_CATEGORY_CODE := p_qte_line_rec.LINE_CATEGORY_CODE;
    l_line_rec.ITEM_TYPE_CODE := p_qte_line_rec.ITEM_TYPE_CODE;
    l_line_rec.LINE_NUMBER := p_qte_line_rec.LINE_NUMBER;
    l_line_rec.START_DATE_ACTIVE := p_qte_line_rec.START_DATE_ACTIVE;
    l_line_rec.END_DATE_ACTIVE := p_qte_line_rec.END_DATE_ACTIVE;
    l_line_rec.ORDER_LINE_TYPE_ID := p_qte_line_rec.ORDER_LINE_TYPE_ID;
    l_line_rec.INVOICE_TO_PARTY_SITE_ID := p_qte_line_rec.INVOICE_TO_PARTY_SITE_ID;
    -- added for sourcing rule match on 06/06/01
    If l_line_rec.INVOICE_TO_PARTY_SITE_ID is NULL
       OR l_line_rec.INVOICE_TO_PARTY_SITE_ID = fnd_api.g_miss_num then
          l_line_rec.INVOICE_TO_PARTY_SITE_ID := ASO_PRICING_INT.G_HEADER_REC.INVOICE_TO_PARTY_SITE_ID;
    End if;
    l_line_rec.INVOICE_TO_PARTY_ID := p_qte_line_rec.INVOICE_TO_PARTY_ID;
    l_line_rec.ORGANIZATION_ID := p_qte_line_rec.ORGANIZATION_ID;
    l_line_rec.INVENTORY_ITEM_ID := p_qte_line_rec.INVENTORY_ITEM_ID;
    l_line_rec.QUANTITY := p_qte_line_rec.QUANTITY;
    l_line_rec.UOM_CODE := p_qte_line_rec.UOM_CODE;
    l_line_rec.MARKETING_SOURCE_CODE_ID := p_qte_line_rec.MARKETING_SOURCE_CODE_ID;
    l_line_rec.PRICE_LIST_ID := p_qte_line_rec.PRICE_LIST_ID;
    -- added for sourcing rule match on 06/06/01
    If (l_line_rec.PRICE_LIST_ID is NULL OR l_line_rec.PRICE_LIST_ID = fnd_api.g_miss_num) then
       l_line_rec.PRICE_LIST_ID := ASO_PRICING_INT.G_HEADER_REC.PRICE_LIST_ID;
    End If;

    If (NVL(p_qte_line_rec.PRICING_LINE_TYPE_INDICATOR,'X')  = 'F') then
        l_line_rec.PRICE_LIST_ID := p_qte_line_rec.priced_price_list_id;
    End If;
    l_line_rec.PRICE_LIST_LINE_ID := p_qte_line_rec.PRICE_LIST_LINE_ID;
    l_line_rec.CURRENCY_CODE := p_qte_line_rec.CURRENCY_CODE;
    l_line_rec.LINE_LIST_PRICE := p_qte_line_rec.LINE_LIST_PRICE;
    l_line_rec.LINE_ADJUSTED_AMOUNT := p_qte_line_rec.LINE_ADJUSTED_AMOUNT;
    l_line_rec.LINE_ADJUSTED_PERCENT := p_qte_line_rec.LINE_ADJUSTED_PERCENT;
    l_line_rec.LINE_QUOTE_PRICE := p_qte_line_rec.LINE_QUOTE_PRICE;
    l_line_rec.RELATED_ITEM_ID := p_qte_line_rec.RELATED_ITEM_ID;
    l_line_rec.ITEM_RELATIONSHIP_TYPE := p_qte_line_rec.ITEM_RELATIONSHIP_TYPE;
    l_line_rec.ACCOUNTING_RULE_ID := p_qte_line_rec.ACCOUNTING_RULE_ID;
    l_line_rec.INVOICING_RULE_ID := p_qte_line_rec.INVOICING_RULE_ID;
    l_line_rec.SPLIT_SHIPMENT_FLAG := p_qte_line_rec.SPLIT_SHIPMENT_FLAG;
    l_line_rec.BACKORDER_FLAG := p_qte_line_rec.BACKORDER_FLAG;
    l_line_rec.INVOICE_TO_CUST_PARTY_ID := p_qte_line_rec.INVOICE_TO_CUST_PARTY_ID;
    l_line_rec.RECALCULATE_FLAG := p_qte_line_rec.RECALCULATE_FLAG;
    l_line_rec.SELLING_PRICE_CHANGE := p_qte_line_rec.SELLING_PRICE_CHANGE;
    l_line_rec.PRICING_LINE_TYPE_INDICATOR := p_qte_line_rec.PRICING_LINE_TYPE_INDICATOR;
    l_line_rec.MINISITE_ID := p_qte_line_rec.MINISITE_ID;
    l_line_rec.AGREEMENT_ID := p_qte_line_rec.AGREEMENT_ID;
    If (l_line_rec.AGREEMENT_ID is NULL OR l_line_rec.AGREEMENT_ID = fnd_api.g_miss_num) then
	  l_line_rec.AGREEMENT_ID := ASO_PRICING_INT.G_HEADER_REC.CONTRACT_ID;
    End If;
    l_line_rec.ATTRIBUTE_CATEGORY := p_qte_line_rec.ATTRIBUTE_CATEGORY;
    l_line_rec.ATTRIBUTE1 := p_qte_line_rec.ATTRIBUTE1;
    l_line_rec.ATTRIBUTE2 := p_qte_line_rec.ATTRIBUTE2;
    l_line_rec.ATTRIBUTE3 := p_qte_line_rec.ATTRIBUTE3;
    l_line_rec.ATTRIBUTE4 := p_qte_line_rec.ATTRIBUTE4;
    l_line_rec.ATTRIBUTE5 := p_qte_line_rec.ATTRIBUTE5;
    l_line_rec.ATTRIBUTE6 := p_qte_line_rec.ATTRIBUTE6;
    l_line_rec.ATTRIBUTE7 := p_qte_line_rec.ATTRIBUTE7;
    l_line_rec.ATTRIBUTE8 := p_qte_line_rec.ATTRIBUTE8;
    l_line_rec.ATTRIBUTE9 := p_qte_line_rec.ATTRIBUTE9;
    l_line_rec.ATTRIBUTE10 := p_qte_line_rec.ATTRIBUTE10;
    l_line_rec.ATTRIBUTE11 := p_qte_line_rec.ATTRIBUTE11;
    l_line_rec.ATTRIBUTE12 := p_qte_line_rec.ATTRIBUTE12;
    l_line_rec.ATTRIBUTE13 := p_qte_line_rec.ATTRIBUTE13;
    l_line_rec.ATTRIBUTE14 := p_qte_line_rec.ATTRIBUTE14;
    l_line_rec.ATTRIBUTE15 := p_qte_line_rec.ATTRIBUTE15;
    l_line_rec.CHARGE_PERIODICITY_CODE := p_qte_line_rec.CHARGE_PERIODICITY_CODE;
    l_line_rec.PRICING_QUANTITY_UOM := p_qte_line_rec.PRICING_QUANTITY_UOM;
    l_line_rec.PRICING_QUANTITY := p_qte_line_rec.PRICING_QUANTITY;

    l_line_rec.CONFIG_HEADER_ID := p_qte_line_dtl_rec.CONFIG_HEADER_ID;
    l_line_rec.COMPLETE_CONFIGURATION_FLAG := p_qte_line_dtl_rec.COMPLETE_CONFIGURATION_FLAG;
    l_line_rec.CONFIG_REVISION_NUM := p_qte_line_dtl_rec.CONFIG_REVISION_NUM;
    l_line_rec.VALID_CONFIGURATION_FLAG := p_qte_line_dtl_rec.VALID_CONFIGURATION_FLAG;
    l_line_rec.COMPONENT_CODE := p_qte_line_dtl_rec.COMPONENT_CODE;
    l_line_rec.SERVICE_COTERMINATE_FLAG := p_qte_line_dtl_rec.SERVICE_COTERMINATE_FLAG;
    l_line_rec.SERVICE_DURATION := p_qte_line_dtl_rec.SERVICE_DURATION;
    l_line_rec.SERVICE_UNIT_SELLING_PERCENT := p_qte_line_dtl_rec.SERVICE_UNIT_SELLING_PERCENT;
    l_line_rec.SERVICE_UNIT_LIST_PERCENT := p_qte_line_dtl_rec.SERVICE_UNIT_LIST_PERCENT;
    l_line_rec.SERVICE_NUMBER := p_qte_line_dtl_rec.SERVICE_NUMBER;
    l_line_rec.UNIT_PERCENT_BASE_PRICE := p_qte_line_dtl_rec.UNIT_PERCENT_BASE_PRICE;
    l_line_rec.SERVICE_PERIOD := p_qte_line_dtl_rec.SERVICE_PERIOD;

    l_line_rec.PROMISE_DATE := p_shipment_rec.PROMISE_DATE;
    l_line_rec.REQUEST_DATE := p_shipment_rec.REQUEST_DATE;
    If l_line_rec.REQUEST_DATE is NULL
	  OR l_line_rec.REQUEST_DATE  = fnd_api.g_miss_date then
	     l_line_rec.REQUEST_DATE :=  ASO_PRICING_INT.G_HEADER_REC.REQUEST_DATE;
    End If;
    l_line_rec.SCHEDULE_SHIP_DATE := p_shipment_rec.SCHEDULE_SHIP_DATE;
    l_line_rec.SHIP_TO_PARTY_SITE_ID := p_shipment_rec.SHIP_TO_PARTY_SITE_ID;
    -- added for sourcing rule match on 06/06/01
    if l_line_rec.SHIP_TO_PARTY_SITE_ID is NULL
       OR l_line_rec.SHIP_TO_PARTY_SITE_ID =  fnd_api.g_miss_num then
          l_line_rec.SHIP_TO_PARTY_SITE_ID := ASO_PRICING_INT.G_HEADER_REC.SHIP_TO_PARTY_SITE_ID;
    End if;
    l_line_rec.SHIP_TO_PARTY_ID := p_shipment_rec.SHIP_TO_PARTY_ID;
    l_line_rec.SHIP_PARTIAL_FLAG := p_shipment_rec.SHIP_PARTIAL_FLAG;
    l_line_rec.SHIP_SET_ID := p_shipment_rec.SHIP_SET_ID;
    l_line_rec.SHIP_METHOD_CODE := p_shipment_rec.SHIP_METHOD_CODE;
    -- added for sourcing rule match on 06/06/01
    If l_line_rec.SHIP_METHOD_CODE is NULL
       OR l_line_rec.SHIP_METHOD_CODE = fnd_api.g_miss_char then
          l_line_rec.SHIP_METHOD_CODE := ASO_PRICING_INT.G_HEADER_REC.SHIP_METHOD_CODE;
    End If;
    l_line_rec.FREIGHT_TERMS_CODE := p_shipment_rec.FREIGHT_TERMS_CODE;
    -- added for sourcing rule match on 06/06/01
    If l_line_rec.FREIGHT_TERMS_CODE is NULL
       OR l_line_rec.FREIGHT_TERMS_CODE = fnd_api.g_miss_char then
          l_line_rec.FREIGHT_TERMS_CODE := ASO_PRICING_INT.G_HEADER_REC.FREIGHT_TERMS_CODE;
    End If;
    l_line_rec.FREIGHT_CARRIER_CODE := p_shipment_rec.FREIGHT_CARRIER_CODE;
    If l_line_rec.FREIGHT_CARRIER_CODE  is NULL
	   OR l_line_rec.FREIGHT_CARRIER_CODE  = fnd_api.g_miss_char then
	      l_line_rec.FREIGHT_CARRIER_CODE :=  ASO_PRICING_INT.G_HEADER_REC.FREIGHT_CARRIER_CODE;
    End If;
    l_line_rec.FOB_CODE := p_shipment_rec.FOB_CODE;
    If l_line_rec.FOB_CODE is NULL
	  OR l_line_rec.FOB_CODE  = fnd_api.g_miss_char then
		l_line_rec.FOB_CODE := ASO_PRICING_INT.G_HEADER_REC.FOB_CODE;
    End If;
    l_line_rec.SHIPPING_INSTRUCTIONS := p_shipment_rec.SHIPPING_INSTRUCTIONS;
    l_line_rec.PACKING_INSTRUCTIONS := p_shipment_rec.PACKING_INSTRUCTIONS;
    l_line_rec.SHIPPING_QUANTITY := p_shipment_rec.QUANTITY;
    l_line_rec.RESERVED_QUANTITY := p_shipment_rec.RESERVED_QUANTITY;
    l_line_rec.RESERVATION_ID := p_shipment_rec.RESERVATION_ID;
    l_line_rec.ORDER_LINE_ID := p_shipment_rec.ORDER_LINE_ID;
    l_line_rec.SHIPMENT_PRIORITY_CODE := p_shipment_rec.SHIPMENT_PRIORITY_CODE;
    --education change: added to check model id
    --Changed again to fix the bundle item bug fix: changed to obtain the model via cursor
    --rather than using the get_top_model_item_id() function.
    If l_line_rec.MODEL_ID is NULL OR l_line_rec.MODEL_ID =  fnd_api.g_miss_num then
         OPEN C_top_model_item_id( p_qte_line_dtl_rec.CONFIG_HEADER_ID,
                                         p_qte_line_dtl_rec.CONFIG_REVISION_NUM);
         FETCH C_top_model_item_id INTO l_inventory_item_id;
         CLOSE C_top_model_item_id;
         l_line_rec.MODEL_ID := l_inventory_item_id;
    End if;

     -- bug 12696699
    l_line_rec.ATTRIBUTE16 := p_qte_line_rec.ATTRIBUTE16;
    l_line_rec.ATTRIBUTE17 := p_qte_line_rec.ATTRIBUTE17;
    l_line_rec.ATTRIBUTE18 := p_qte_line_rec.ATTRIBUTE18;
    l_line_rec.ATTRIBUTE19 := p_qte_line_rec.ATTRIBUTE19;
    l_line_rec.ATTRIBUTE20 := p_qte_line_rec.ATTRIBUTE20;
    -- end bug 12696699

    -- l_line_rec.UNIT_PRICE := p_qte_line_rec.UNIT_PRICE;  -- bug 17517305 , commented for Bug 19243138

    --Bug 21661093
    l_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID := p_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID;

    return l_line_rec;
END Set_Global_Rec;

-- TSN processing...

PROCEDURE PROCESS_HDR_TSN(p_quote_header_id NUMBER) IS

CURSOR c_hdr_pyt_exists IS
SELECT payment_id
FROM   ASO_PAYMENTS
WHERE quote_header_id = p_quote_header_id;

CURSOR c_hdr_smc_exists IS
SELECT shipment_id
FROM   ASO_SHIPMENTS
WHERE  quote_header_id = p_quote_header_id;

CURSOR c_hdr_ftc_exists IS
SELECT shipment_id
FROM   ASO_SHIPMENTS
WHERE  quote_header_id = p_quote_header_id;

CURSOR c_hdr_tsn_count  IS
 SELECT /*+ LEADING (lines) INDEX (lines, QP_PREQ_LINES_TMP_N1) USE_NL (lines A B ) */
        B.SUBSTITUTION_VALUE,
        b.substitution_attribute, lines.line_id,
       lines.line_index, A.CREATED_FROM_LIST_LINE_TYPE,a.applied_flag,
       a.modifier_level_code,a.process_code
 FROM QP_PREQ_LINES_TMP_T lines,
      QP_PREQ_LDETS_TMP_T A,
      QP_LIST_LINES B
 WHERE lines.line_id = p_quote_header_id
 AND lines.REQUEST_ID = nvl(sys_context('QP_CONTEXT','REQUEST_ID'),1)
 AND (p_quote_header_id IS NOT NULL
 AND p_quote_header_id <> FND_API.G_MISS_NUM)
 AND lines.line_index = a.line_index
 AND A.CREATED_FROM_LIST_LINE_TYPE = QP_PREQ_GRP.G_TERMS_SUBSTITUTION
 AND a.applied_flag = G_YES_FLAG
 AND a.modifier_level_code = G_ORDER_LEVEL
 AND a.process_code IN (QP_PREQ_GRP.G_STATUS_NEW, QP_PREQ_GRP.G_STATUS_UPDATED)
 and a.CREATED_FROM_LIST_LINE_ID = b.LIST_LINE_ID
 AND a.PRICING_STATUS_CODE = 'N'
 and a.REQUEST_ID = nvl(SYS_CONTEXT('QP_CONTEXT','REQUEST_ID'),1);


CURSOR c_hdr_pyt_tsn  IS
 SELECT /*+ LEADING (lines) INDEX (lines, QP_PREQ_LINES_TMP_N1) USE_NL (lines A B ) */
        B.SUBSTITUTION_VALUE
 FROM QP_PREQ_LINES_TMP_T lines,
      QP_PREQ_LDETS_TMP_T A,
      QP_LIST_LINES B,
      RA_TERMS_B ratv
 WHERE lines.line_id = p_quote_header_id
 AND lines.REQUEST_ID = nvl(sys_context('QP_CONTEXT','REQUEST_ID'),1)
 AND (p_quote_header_id IS NOT NULL
 AND p_quote_header_id <> FND_API.G_MISS_NUM)
 AND lines.line_index = a.line_index
 AND b.substitution_attribute = G_QUAL_ATTRIBUTE1
 AND A.CREATED_FROM_LIST_LINE_TYPE = QP_PREQ_GRP.G_TERMS_SUBSTITUTION
 AND a.applied_flag = G_YES_FLAG
 AND a.modifier_level_code = G_ORDER_LEVEL
 AND a.process_code IN (QP_PREQ_GRP.G_STATUS_NEW, QP_PREQ_GRP.G_STATUS_UPDATED)
 and a.CREATED_FROM_LIST_LINE_ID = b.LIST_LINE_ID
 AND a.PRICING_STATUS_CODE = 'N'
 and a.REQUEST_ID = nvl(SYS_CONTEXT('QP_CONTEXT','REQUEST_ID'),1)
 AND   ratv.term_id = B.SUBSTITUTION_VALUE
 AND  (TRUNC(sysdate)  BETWEEN NVL(TRUNC(ratv.start_date_active),TRUNC(sysdate))
                              AND NVL(TRUNC(ratv.end_date_active ), TRUNC(sysdate)));

CURSOR c_hdr_smc_tsn  IS
 SELECT /*+ LEADING (lines) INDEX (lines, QP_PREQ_LINES_TMP_N1) USE_NL (lines A B ) */
        B.SUBSTITUTION_VALUE
 FROM QP_PREQ_LINES_TMP_T lines,
      QP_PREQ_LDETS_TMP_T A,
      QP_LIST_LINES B
 WHERE lines.line_id = p_quote_header_id
 AND lines.REQUEST_ID = nvl(sys_context('QP_CONTEXT','REQUEST_ID'),1)
 AND (p_quote_header_id IS NOT NULL
 AND p_quote_header_id <> FND_API.G_MISS_NUM)
 AND lines.line_index = a.line_index
 AND b.substitution_attribute = G_QUAL_ATTRIBUTE11
 AND A.CREATED_FROM_LIST_LINE_TYPE = QP_PREQ_GRP.G_TERMS_SUBSTITUTION
 AND a.applied_flag = G_YES_FLAG
 AND a.modifier_level_code = G_ORDER_LEVEL
 AND a.process_code IN (QP_PREQ_GRP.G_STATUS_NEW, QP_PREQ_GRP.G_STATUS_UPDATED)
 and a.CREATED_FROM_LIST_LINE_ID = b.LIST_LINE_ID
 AND a.PRICING_STATUS_CODE = 'N'
 and a.REQUEST_ID = nvl(SYS_CONTEXT('QP_CONTEXT','REQUEST_ID'),1);


CURSOR c_hdr_ftc_tsn IS
 SELECT /*+ LEADING (lines) INDEX (lines, QP_PREQ_LINES_TMP_N1) USE_NL (lines A B olk) */
        B.SUBSTITUTION_VALUE
 FROM QP_PREQ_LINES_TMP_T lines,
      QP_PREQ_LDETS_TMP_T A,
      QP_LIST_LINES B,
      fnd_lookup_values olk
 WHERE lines.line_id = p_quote_header_id
 AND lines.REQUEST_ID = nvl(sys_context('QP_CONTEXT','REQUEST_ID'),1)
 AND (p_quote_header_id IS NOT NULL
 AND p_quote_header_id <> FND_API.G_MISS_NUM)
 AND lines.line_index = a.line_index
 AND b.substitution_attribute = G_QUAL_ATTRIBUTE10
 AND A.CREATED_FROM_LIST_LINE_TYPE = G_TERMS_SUBSTITUTION
 AND a.applied_flag = G_YES_FLAG
 AND a.modifier_level_code = G_ORDER_LEVEL
 AND a.process_code IN (QP_PREQ_GRP.G_STATUS_NEW, QP_PREQ_GRP.G_STATUS_UPDATED)
 AND olk.lookup_type = G_FREIGHT_TERM_LK_TYPE
 AND olk.enabled_flag = G_YES_FLAG
 AND olk.lookup_code = B.SUBSTITUTION_VALUE
 AND (TRUNC(sysdate) BETWEEN NVL(TRUNC(olk.start_date_active),TRUNC( sysdate))
 AND NVL(TRUNC(olk.end_date_active), TRUNC(sysdate)))
 and a.CREATED_FROM_LIST_LINE_ID = b.LIST_LINE_ID
 AND a.PRICING_STATUS_CODE = 'N'
 and a.REQUEST_ID = nvl(SYS_CONTEXT('QP_CONTEXT','REQUEST_ID'),1)
 and olk.LANGUAGE = USERENV('LANG')
 and olk.VIEW_APPLICATION_ID = 660
 and olk.SECURITY_GROUP_ID =0;


l_req_payment_term_id     ASO_PAYMENTS.payment_term_id%TYPE;
l_req_ship_method_code    ASO_SHIPMENTS.ship_method_code%TYPE;
l_req_freight_terms_code  ASO_SHIPMENTS.freight_terms_code%TYPE;

l_payment_id         	  ASO_PAYMENTS.payment_id%TYPE;
l_shipment_id             ASO_SHIPMENTS.shipment_id%TYPE;
l_freight_shipment_id     ASO_SHIPMENTS.shipment_id%TYPE;


l_payment_rec             ASO_QUOTE_PUB.payment_rec_type;
lx_payment_id             ASO_PAYMENTS.payment_id%TYPE;

l_shipment_rec            ASO_QUOTE_PUB.shipment_rec_type;
lx_shipment_id            ASO_SHIPMENTS.shipment_id%TYPE;


l_freight_rec             ASO_QUOTE_PUB.shipment_rec_type;
lx_freight_shipment_id    ASO_SHIPMENTS.shipment_id%TYPE;

G_USER_ID   		  NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID       	  NUMBER := FND_GLOBAL.CONC_LOGIN_ID;


BEGIN

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_CORE_PVT: Hdr TSN Count Starts Here...',1,'Y');
     	FOR hdr_rec IN c_hdr_tsn_count LOOP
            --aso_debug_pub.add('ASO_PRICING_CORE_PVT: hdr_rec.substitution_value_to :'||NVL(hdr_rec.substitution_value_to,'null'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: hdr_rec.substitution_value :'||NVL(hdr_rec.substitution_value,'null'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: hdr_rec.substitution_attribute :'||NVL(hdr_rec.substitution_attribute ,'null'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: hdr_rec.line_id :'||NVL(hdr_rec.line_id,0),1,'Y');
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: hdr_rec.line_index :'||NVL(hdr_rec.line_index,0),1,'Y');
            --aso_debug_pub.add('ASO_PRICING_CORE_PVT: hdr_rec.list_line_type_code :'||NVL(hdr_rec.list_line_type_code,'null'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: hdr_rec.created_from_list_line_type :'||NVL(hdr_rec.created_from_list_line_type,'null'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: hdr_rec.applied_flag :'||NVL(hdr_rec.applied_flag,'null'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: hdr_rec.modifier_level_code :'||NVL(hdr_rec.modifier_level_code,'null'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: hdr_rec.process_code :'||NVL(hdr_rec.process_code,'null'),1,'Y');
     	END LOOP;
        aso_debug_pub.add('ASO_PRICING_CORE_PVT: PROCESS_HDR_TSN Starts Here...',1,'Y');
     END IF;

     OPEN c_hdr_pyt_exists;
     FETCH c_hdr_pyt_exists INTO l_payment_id;
     CLOSE c_hdr_pyt_exists;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_payment_id :'||NVL(l_payment_id,0),1,'Y');
     END IF;

     OPEN c_hdr_pyt_tsn;
     FETCH c_hdr_pyt_tsn INTO l_req_payment_term_id;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_req_payment_term_id: '||NVL(l_req_payment_term_id,0),1,'Y');
     END IF;

     IF l_req_payment_term_id IS NULL THEN
        	CLOSE c_hdr_pyt_tsn;
     		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No Header Level Payment TSN exists hence update with from value...',1,'Y');
     		END IF;
		IF l_payment_id IS NOT NULL THEN
        		UPDATE ASO_PAYMENTS
		           SET payment_term_id = payment_term_id_from
			WHERE  quote_header_id = p_quote_header_id
			AND    (p_quote_header_id IS NOT NULL AND p_quote_header_id <> FND_API.G_MISS_NUM)
			AND    quote_line_id IS NULL;
		END IF;
        	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        	  aso_debug_pub.add('ASO_PRICING_CORE_PVT: No of Payment Rows Updated : '||sql%ROWCOUNT,1,'Y');
        	END IF;

    ELSE

        CLOSE c_hdr_pyt_tsn;

     	IF l_payment_id IS NULL THEN
     		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No Payment Record Exists...Before Payment Insert Row',1,'Y');
        	END IF;
		lx_PAYMENT_ID  := NULL;
		ASO_PAYMENTS_PKG.Insert_Row(
	    		px_PAYMENT_ID                  => lx_PAYMENT_ID,
	    		p_CREATION_DATE                => SYSDATE,
	    		p_CREATED_BY                   => G_USER_ID,
	    		p_LAST_UPDATE_DATE	       => sysdate,
	    		p_LAST_UPDATED_BY              => G_USER_ID,
	    		p_LAST_UPDATE_LOGIN            => G_LOGIN_ID,
	    		p_REQUEST_ID                   => l_payment_rec.REQUEST_ID,
	    		p_PROGRAM_APPLICATION_ID       => l_payment_rec.PROGRAM_APPLICATION_ID,
	    		p_PROGRAM_ID                   => l_payment_rec.PROGRAM_ID,
	    		p_PROGRAM_UPDATE_DATE          => l_payment_rec.PROGRAM_UPDATE_DATE,
	    		p_QUOTE_HEADER_ID              => p_quote_header_id,
	    		p_QUOTE_LINE_ID  	       => NULL,
	    		p_PAYMENT_TYPE_CODE            => l_payment_rec.PAYMENT_TYPE_CODE,
	    		p_PAYMENT_REF_NUMBER           => l_payment_rec.PAYMENT_REF_NUMBER,
	    		p_PAYMENT_OPTION               => l_payment_rec.PAYMENT_OPTION,
	    		p_PAYMENT_TERM_ID              => l_payment_rec.PAYMENT_TERM_ID,
	    		p_CREDIT_CARD_CODE	       => l_payment_rec.CREDIT_CARD_CODE,
	    		p_CREDIT_CARD_HOLDER_NAME      => l_payment_rec.CREDIT_CARD_HOLDER_NAME,
	    		p_CREDIT_CARD_EXPIRATION_DATE  => l_payment_rec.CREDIT_CARD_EXPIRATION_DATE,
	    		p_CREDIT_CARD_APPROVAL_CODE    => l_payment_rec.CREDIT_CARD_APPROVAL_CODE,
	    		p_CREDIT_CARD_APPROVAL_DATE    => l_payment_rec.CREDIT_CARD_APPROVAL_DATE,
	    		p_PAYMENT_AMOUNT               => l_payment_rec.PAYMENT_AMOUNT,
	    		p_ATTRIBUTE_CATEGORY           => l_payment_rec.ATTRIBUTE_CATEGORY,
	    		p_ATTRIBUTE1                   => l_payment_rec.ATTRIBUTE1,
	    		p_ATTRIBUTE2                   => l_payment_rec.ATTRIBUTE2,
	    		p_ATTRIBUTE3                   => l_payment_rec.ATTRIBUTE3,
	    		p_ATTRIBUTE4                   => l_payment_rec.ATTRIBUTE4,
	    		p_ATTRIBUTE5                   => l_payment_rec.ATTRIBUTE5,
	    		p_ATTRIBUTE6                   => l_payment_rec.ATTRIBUTE6,
	    		p_ATTRIBUTE7                   => l_payment_rec.ATTRIBUTE7,
	    		p_ATTRIBUTE8                   => l_payment_rec.ATTRIBUTE8,
	    		p_ATTRIBUTE9                   => l_payment_rec.ATTRIBUTE9,
	    		p_ATTRIBUTE10                  => l_payment_rec.ATTRIBUTE10,
	    		p_ATTRIBUTE11                  => l_payment_rec.ATTRIBUTE11,
	    		p_ATTRIBUTE12                  => l_payment_rec.ATTRIBUTE12,
	    		p_ATTRIBUTE13                  => l_payment_rec.ATTRIBUTE13,
	    		p_ATTRIBUTE14                  => l_payment_rec.ATTRIBUTE14,
	    		p_ATTRIBUTE15                  => l_payment_rec.ATTRIBUTE15,
               p_ATTRIBUTE16                  => l_payment_rec.ATTRIBUTE16,
		     p_ATTRIBUTE17                  => l_payment_rec.ATTRIBUTE17,
			p_ATTRIBUTE18                  => l_payment_rec.ATTRIBUTE18,
			p_ATTRIBUTE19                  => l_payment_rec.ATTRIBUTE19,
			p_ATTRIBUTE20                  => l_payment_rec.ATTRIBUTE20,
				p_QUOTE_SHIPMENT_ID            => l_payment_rec.QUOTE_SHIPMENT_ID,
	    		p_CUST_PO_NUMBER               => l_payment_rec.CUST_PO_NUMBER,
            		p_PAYMENT_TERM_ID_FROM         => l_payment_rec.PAYMENT_TERM_ID_FROM,
				p_OBJECT_VERSION_NUMBER   => l_payment_rec.OBJECT_VERSION_NUMBER,
                        p_CUST_PO_LINE_NUMBER   => l_payment_rec.CUST_PO_LINE_NUMBER, -- Line Payments Change
				    p_TRXN_EXTENSION_ID    => l_payment_rec.TRXN_EXTENSION_ID
	    		);
		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		   aso_debug_pub.add('ASO_PRICING_CORE_PVT: After Payment Insert Row...Payment_ID :'||NVL(lx_payment_id,0),1,'Y');
		END IF;
	END IF; -- l_payment_id is null; Header Payment exists or not check.


     	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           aso_debug_pub.add('ASO_PRICING_CORE_PVT: Header Level Payment TSN exists...',1,'Y');
     	END IF;
	IF l_payment_id IS NOT NULL or lx_payment_id IS NOT NULL
        THEN
      		UPDATE ASO_PAYMENTS
		   SET payment_term_id = l_req_payment_term_id
		WHERE  quote_header_id = p_quote_header_id
		AND    (p_quote_header_id IS NOT NULL AND p_quote_header_id <> FND_API.G_MISS_NUM)
		AND    quote_line_id IS NULL;
        END IF;
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No of Payment Rows Updated : '||sql%ROWCOUNT,1,'Y');
	END IF;
    END IF; -- l_req_payment_term_id IS NULL or not check.


    OPEN c_hdr_smc_exists;
    FETCH c_hdr_smc_exists INTO l_shipment_id;
    CLOSE c_hdr_smc_exists;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_shipment_id: '||NVL(l_shipment_id,0),1,'Y');
    END IF;

    OPEN c_hdr_smc_tsn;
    FETCH c_hdr_smc_tsn INTO l_req_ship_method_code;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_req_ship_method_code: '||NVL(l_req_ship_method_code,0),1,'Y');
    END IF;

    IF l_req_ship_method_code IS NULL THEN
		CLOSE c_hdr_smc_tsn;
     		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No Header Level Ship Method Code TSN exists hence update with From value...',1,'Y');
        	END IF;
                IF l_shipment_id IS NOT NULL
		THEN
			UPDATE ASO_SHIPMENTS aso
			   SET aso.ship_method_code = ship_method_code_from
			WHERE  quote_header_id = p_quote_header_id
			AND    (p_quote_header_id IS NOT NULL AND p_quote_header_id <> FND_API.G_MISS_NUM)
			AND    quote_line_id IS NULL;
		END IF;
     		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No of Ship Method Code Rows Updated : '||sql%ROWCOUNT,1,'Y');
     		END IF;
     ELSE
	 CLOSE c_hdr_smc_tsn;
	 IF l_shipment_id IS NULL THEN
	 	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	 	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No Shipment Record exists...Before Shipment Insert Rows ',1,'Y');
		END IF;

		lx_shipment_id := NULL;
		ASO_SHIPMENTS_PKG.Insert_Row(
			px_SHIPMENT_ID  		=> lx_shipment_id,
			p_CREATION_DATE  		=> SYSDATE,
			p_CREATED_BY  			=> G_USER_ID,
			p_LAST_UPDATE_DATE		=> SYSDATE,
			p_LAST_UPDATED_BY  		=> G_USER_ID,
			p_LAST_UPDATE_LOGIN  		=> G_LOGIN_ID,
			p_REQUEST_ID  			=> l_shipment_rec.REQUEST_ID,
			p_PROGRAM_APPLICATION_ID  	=> l_shipment_rec.PROGRAM_APPLICATION_ID,
			p_PROGRAM_ID  			=> l_shipment_rec.PROGRAM_ID,
			p_PROGRAM_UPDATE_DATE  		=> l_shipment_rec.PROGRAM_UPDATE_DATE,
			p_QUOTE_HEADER_ID  		=> p_quote_header_id,
			p_QUOTE_LINE_ID  		=> NULL,
			p_PROMISE_DATE  		=> l_shipment_rec.PROMISE_DATE,
			p_REQUEST_DATE  		=> l_shipment_rec.REQUEST_DATE,
			p_SCHEDULE_SHIP_DATE  		=> l_shipment_rec.SCHEDULE_SHIP_DATE,
			p_SHIP_TO_PARTY_SITE_ID  	=> l_shipment_rec.SHIP_TO_PARTY_SITE_ID,
			p_SHIP_TO_PARTY_ID		=> l_shipment_rec.SHIP_TO_PARTY_ID,
			p_SHIP_TO_CUST_ACCOUNT_ID  	=> l_shipment_rec.SHIP_TO_CUST_ACCOUNT_ID,
			p_SHIP_PARTIAL_FLAG  		=> l_shipment_rec.SHIP_PARTIAL_FLAG,
			p_SHIP_SET_ID  			=> l_shipment_rec.SHIP_SET_ID,
			p_SHIP_METHOD_CODE		=> l_shipment_rec.SHIP_METHOD_CODE,
			p_FREIGHT_TERMS_CODE  		=> l_shipment_rec.FREIGHT_TERMS_CODE,
			p_FREIGHT_CARRIER_CODE  	=> l_shipment_rec.FREIGHT_CARRIER_CODE,
			p_FOB_CODE			=> l_shipment_rec.FOB_CODE,
			p_SHIPPING_INSTRUCTIONS  	=> l_shipment_rec.SHIPPING_INSTRUCTIONS,
			p_PACKING_INSTRUCTIONS  	=> l_shipment_rec.PACKING_INSTRUCTIONS,
			p_QUANTITY			=> l_shipment_rec.QUANTITY,
			p_RESERVED_QUANTITY  		=> l_shipment_rec.RESERVED_QUANTITY,
			p_RESERVATION_ID  		=> l_shipment_rec.RESERVATION_ID,
			p_ORDER_LINE_ID  		=> l_shipment_rec.ORDER_LINE_ID,
			p_ATTRIBUTE_CATEGORY  		=> l_shipment_rec.ATTRIBUTE_CATEGORY,
			p_ATTRIBUTE1  			=> l_shipment_rec.ATTRIBUTE1,
			p_ATTRIBUTE2  			=> l_shipment_rec.ATTRIBUTE2,
			p_ATTRIBUTE3  			=> l_shipment_rec.ATTRIBUTE3,
			p_ATTRIBUTE4  			=> l_shipment_rec.ATTRIBUTE4,
			p_ATTRIBUTE5  			=> l_shipment_rec.ATTRIBUTE5,
			p_ATTRIBUTE6  			=> l_shipment_rec.ATTRIBUTE6,
			p_ATTRIBUTE7  			=> l_shipment_rec.ATTRIBUTE7,
			p_ATTRIBUTE8  			=> l_shipment_rec.ATTRIBUTE8,
			p_ATTRIBUTE9  			=> l_shipment_rec.ATTRIBUTE9,
			p_ATTRIBUTE10 			=> l_shipment_rec.ATTRIBUTE10,
			p_ATTRIBUTE11  			=> l_shipment_rec.ATTRIBUTE11,
			p_ATTRIBUTE12  			=> l_shipment_rec.ATTRIBUTE12,
			p_ATTRIBUTE13  			=> l_shipment_rec.ATTRIBUTE13,
			p_ATTRIBUTE14  			=> l_shipment_rec.ATTRIBUTE14,
			p_ATTRIBUTE15  			=> l_shipment_rec.ATTRIBUTE15,
		     p_ATTRIBUTE16                  =>  l_shipment_rec.ATTRIBUTE16,
               p_ATTRIBUTE17                  =>  l_shipment_rec.ATTRIBUTE17,
               p_ATTRIBUTE18                  =>  l_shipment_rec.ATTRIBUTE18,
               p_ATTRIBUTE19                  =>  l_shipment_rec.ATTRIBUTE19,
               p_ATTRIBUTE20                  =>  l_shipment_rec.ATTRIBUTE20,
			p_SHIPMENT_PRIORITY_CODE 	=> l_shipment_rec.SHIPMENT_PRIORITY_CODE,
			p_SHIP_QUOTE_PRICE 		=> l_shipment_rec.SHIP_QUOTE_PRICE,
			p_SHIP_FROM_ORG_ID 		=> l_shipment_rec.SHIP_FROM_ORG_ID,
			p_SHIP_TO_CUST_PARTY_ID 	=> l_shipment_rec.SHIP_TO_CUST_PARTY_ID,
			p_SHIP_METHOD_CODE_FROM     	=> l_shipment_rec.SHIP_METHOD_CODE_FROM,
			p_FREIGHT_TERMS_CODE_FROM  	=> l_shipment_rec.FREIGHT_TERMS_CODE_FROM,
			p_OBJECT_VERSION_NUMBER       => l_shipment_rec.OBJECT_VERSION_NUMBER,
		     p_request_date_type              => l_shipment_rec.request_date_type,
               p_demand_class_code              => l_shipment_rec.demand_class_code
			);
	 	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	 	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: After Shipment Insert Row...Shipment_ID '||NVL(lx_shipment_id,0),1,'Y');
		END IF;
	 END IF; --l_shipment_id is NULL or not check.

     	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: Header Level Shipment TSN exists...',1,'Y');
        END IF;
     	IF l_shipment_id IS NOT NULL or lx_shipment_id IS NOT NULL
        THEN
		UPDATE ASO_SHIPMENTS aso
		   SET aso.ship_method_code = l_req_ship_method_code
		WHERE  quote_header_id = p_quote_header_id
		AND    (p_quote_header_id IS NOT NULL AND p_quote_header_id <> FND_API.G_MISS_NUM)
		AND    quote_line_id IS NULL
        	AND   ('S' = (ASO_VALIDATE_PVT.Validate_ShipMethods('T', l_req_ship_method_code,
		       aso.ship_from_org_id, p_quote_header_id, NULL)));
        END IF;
     	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           aso_debug_pub.add('ASO_PRICING_CORE_PVT: No of Ship Method Code Rows Updated : '||sql%ROWCOUNT,1,'Y');
     	END IF;
     END IF; --l_req_ship_method_code IS NULL or not check.

     OPEN c_hdr_ftc_exists;
     FETCH c_hdr_ftc_exists INTO l_freight_shipment_id;
     CLOSE c_hdr_ftc_exists;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_freight_shipment_id '||NVL(l_freight_shipment_id,0),1,'Y');
     END IF;

     OPEN c_hdr_ftc_tsn;
     FETCH c_hdr_ftc_tsn INTO l_req_freight_terms_code;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_req_freight_terms_code: '||NVL(l_req_freight_terms_code,0),1,'Y');
     END IF;

     IF l_req_freight_terms_code IS NULL THEN
 		CLOSE c_hdr_ftc_tsn;
     		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No Header Level Freight Terms Code TSN exists hence update with From value...',1,'Y');
     		END IF;
		IF l_freight_shipment_id IS NOT NULL THEN
			UPDATE ASO_SHIPMENTS aso
			   SET aso.freight_terms_code = freight_terms_code_from
			WHERE  quote_header_id = p_quote_header_id
			AND    (p_quote_header_id IS NOT NULL AND p_quote_header_id <> FND_API.G_MISS_NUM)
			AND    quote_line_id IS NULL;
		END IF;
    		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       		   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No of Freight Terms Code Rows Updated : '||sql%ROWCOUNT,1,'Y');
		END IF;
     ELSE
 	 CLOSE c_hdr_ftc_tsn;

	 IF l_freight_shipment_id IS NULL THEN
	 	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	 	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No Shipment(Freight) Record exists...Before Shipment(Freight) Insert Rows ',1,'Y');
		END IF;
		lx_freight_shipment_id  := NULL;
		ASO_SHIPMENTS_PKG.Insert_Row(
			px_SHIPMENT_ID  		=> lx_freight_shipment_id,
			p_CREATION_DATE  		=> SYSDATE,
			p_CREATED_BY  			=> G_USER_ID,
			p_LAST_UPDATE_DATE		=> SYSDATE,
			p_LAST_UPDATED_BY  		=> G_USER_ID,
			p_LAST_UPDATE_LOGIN  		=> G_LOGIN_ID,
			p_REQUEST_ID  			=> l_freight_rec.REQUEST_ID,
			p_PROGRAM_APPLICATION_ID  	=> l_freight_rec.PROGRAM_APPLICATION_ID,
			p_PROGRAM_ID  			=> l_freight_rec.PROGRAM_ID,
			p_PROGRAM_UPDATE_DATE  		=> l_freight_rec.PROGRAM_UPDATE_DATE,
			p_QUOTE_HEADER_ID  		=> p_quote_header_id,
			p_QUOTE_LINE_ID  		=> NULL,
			p_PROMISE_DATE  		=> l_freight_rec.PROMISE_DATE,
			p_REQUEST_DATE  		=> l_freight_rec.REQUEST_DATE,
			p_SCHEDULE_SHIP_DATE  		=> l_freight_rec.SCHEDULE_SHIP_DATE,
			p_SHIP_TO_PARTY_SITE_ID  	=> l_freight_rec.SHIP_TO_PARTY_SITE_ID,
			p_SHIP_TO_PARTY_ID		=> l_freight_rec.SHIP_TO_PARTY_ID,
			p_SHIP_TO_CUST_ACCOUNT_ID  	=> l_freight_rec.SHIP_TO_CUST_ACCOUNT_ID,
			p_SHIP_PARTIAL_FLAG  		=> l_freight_rec.SHIP_PARTIAL_FLAG,
			p_SHIP_SET_ID  			=> l_freight_rec.SHIP_SET_ID,
			p_SHIP_METHOD_CODE		=> l_freight_rec.SHIP_METHOD_CODE,
			p_FREIGHT_TERMS_CODE  		=> l_freight_rec.FREIGHT_TERMS_CODE,
			p_FREIGHT_CARRIER_CODE  	=> l_freight_rec.FREIGHT_CARRIER_CODE,
			p_FOB_CODE			=> l_freight_rec.FOB_CODE,
			p_SHIPPING_INSTRUCTIONS  	=> l_freight_rec.SHIPPING_INSTRUCTIONS,
			p_PACKING_INSTRUCTIONS  	=> l_freight_rec.PACKING_INSTRUCTIONS,
			p_QUANTITY			=> l_freight_rec.QUANTITY,
			p_RESERVED_QUANTITY  		=> l_freight_rec.RESERVED_QUANTITY,
			p_RESERVATION_ID  		=> l_freight_rec.RESERVATION_ID,
			p_ORDER_LINE_ID  		=> l_freight_rec.ORDER_LINE_ID,
			p_ATTRIBUTE_CATEGORY  		=> l_freight_rec.ATTRIBUTE_CATEGORY,
			p_ATTRIBUTE1  			=> l_freight_rec.ATTRIBUTE1,
			p_ATTRIBUTE2  			=> l_freight_rec.ATTRIBUTE2,
			p_ATTRIBUTE3  			=> l_freight_rec.ATTRIBUTE3,
			p_ATTRIBUTE4  			=> l_freight_rec.ATTRIBUTE4,
			p_ATTRIBUTE5  			=> l_freight_rec.ATTRIBUTE5,
			p_ATTRIBUTE6  			=> l_freight_rec.ATTRIBUTE6,
			p_ATTRIBUTE7  			=> l_freight_rec.ATTRIBUTE7,
			p_ATTRIBUTE8  			=> l_freight_rec.ATTRIBUTE8,
			p_ATTRIBUTE9  			=> l_freight_rec.ATTRIBUTE9,
			p_ATTRIBUTE10 			=> l_freight_rec.ATTRIBUTE10,
			p_ATTRIBUTE11  			=> l_freight_rec.ATTRIBUTE11,
			p_ATTRIBUTE12  			=> l_freight_rec.ATTRIBUTE12,
			p_ATTRIBUTE13  			=> l_freight_rec.ATTRIBUTE13,
			p_ATTRIBUTE14  			=> l_freight_rec.ATTRIBUTE14,
			p_ATTRIBUTE15  			=> l_freight_rec.ATTRIBUTE15,
		     p_ATTRIBUTE16                  =>  l_freight_rec.ATTRIBUTE16,
               p_ATTRIBUTE17                  =>  l_freight_rec.ATTRIBUTE17,
               p_ATTRIBUTE18                  =>  l_freight_rec.ATTRIBUTE18,
               p_ATTRIBUTE19                  =>  l_freight_rec.ATTRIBUTE19,
               p_ATTRIBUTE20                  =>  l_freight_rec.ATTRIBUTE20,
               p_SHIPMENT_PRIORITY_CODE 	=> l_freight_rec.SHIPMENT_PRIORITY_CODE,
			p_SHIP_QUOTE_PRICE 		=> l_freight_rec.SHIP_QUOTE_PRICE,
			p_SHIP_FROM_ORG_ID 		=> l_freight_rec.SHIP_FROM_ORG_ID,
			p_SHIP_TO_CUST_PARTY_ID 	=> l_freight_rec.SHIP_TO_CUST_PARTY_ID,
			p_SHIP_METHOD_CODE_FROM     	=> l_freight_rec.SHIP_METHOD_CODE_FROM,
			p_FREIGHT_TERMS_CODE_FROM  	=> l_freight_rec.FREIGHT_TERMS_CODE_FROM,
			p_OBJECT_VERSION_NUMBER       => l_freight_rec.OBJECT_VERSION_NUMBER,
		     p_request_date_type              => l_freight_rec.request_date_type,
               p_demand_class_code              => l_freight_rec.demand_class_code
               );
	 	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	 	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: After Shipment(Freight) Insert Row...Freight_Shipment_ID '||NVL(lx_freight_shipment_id,0),1,'Y');
		END IF;
	END IF; --l_freight_shipment_id is NULL or not check.

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: Header Level Freight TSN exists...',1,'Y');
	END IF;
	IF l_freight_shipment_id IS NOT NULL or lx_freight_shipment_id IS NOT NULL THEN
		UPDATE ASO_SHIPMENTS aso
		   SET aso.freight_terms_code = l_req_freight_terms_code
		WHERE  quote_header_id = p_quote_header_id
		AND    (p_quote_header_id IS NOT NULL AND p_quote_header_id <> FND_API.G_MISS_NUM)
		AND    quote_line_id IS NULL;
     	END IF;
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       	aso_debug_pub.add('ASO_PRICING_CORE_PVT: No of Freight Terms Code Rows Updated : '||sql%ROWCOUNT,1,'Y');
	END IF;
    END IF; --l_req_freight_terms_code IS NULL or NOT check.

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('ASO_PRICING_CORE_PVT: PROCESS_HDR_TSN Ends Here...',1,'Y');
    END IF;
END PROCESS_HDR_TSN;

PROCEDURE PROCESS_LN_TSN(p_quote_header_id NUMBER, p_insert_type VARCHAR2) IS

CURSOR c_qte_lines IS
SELECT quote_line_id
FROM  ASO_QUOTE_LINES_ALL
WHERE quote_header_id = p_quote_header_id;

CURSOR c_get_free_lines IS
SELECT quote_line_id
FROM ASO_QUOTE_LINES_ALL
WHERE quote_header_id = p_quote_header_id
AND   nvl(pricing_line_type_indicator,'X') = G_FREE_LINE_FLAG;

CURSOR c_ln_tsn_count(p_quote_line_id NUMBER)  IS
 SELECT /*+ LEADING (lines) INDEX (lines, QP_PREQ_LINES_TMP_N1) USE_NL (lines A B ) */
        B.SUBSTITUTION_VALUE,
        b.substitution_attribute, lines.line_id,
       lines.line_index, A.CREATED_FROM_LIST_LINE_TYPE,a.applied_flag,
       a.modifier_level_code,a.process_code
 FROM QP_PREQ_LINES_TMP_T lines,
      QP_PREQ_LDETS_TMP_T A,
      QP_LIST_LINES B
 WHERE lines.line_id = p_quote_line_id
 AND lines.REQUEST_ID = nvl(sys_context('QP_CONTEXT','REQUEST_ID'),1)
 AND (lines.line_id  IS NOT NULL
 AND lines.line_id  <> FND_API.G_MISS_NUM)
 AND lines.line_index = a.line_index
 AND A.CREATED_FROM_LIST_LINE_TYPE = QP_PREQ_GRP.G_TERMS_SUBSTITUTION
 AND a.applied_flag = G_YES_FLAG
 AND a.modifier_level_code = G_LINE_LEVEL
 AND a.process_code IN (QP_PREQ_GRP.G_STATUS_NEW, QP_PREQ_GRP.G_STATUS_UPDATED)
 and a.CREATED_FROM_LIST_LINE_ID = b.LIST_LINE_ID
 AND a.PRICING_STATUS_CODE = 'N'
 and a.REQUEST_ID = nvl(SYS_CONTEXT('QP_CONTEXT','REQUEST_ID'),1);

-- Added QP_PREQ_LDETS_TMP_N3 index hint for bug 20215472
CURSOR c_ln_smc_tsn (p_quote_line_id NUMBER)  IS
 SELECT /*+ LEADING (lines) INDEX (lines, QP_PREQ_LINES_TMP_N1) index(A QP_PREQ_LDETS_TMP_N3) USE_NL (lines A B ) */
        B.SUBSTITUTION_VALUE
 FROM QP_PREQ_LINES_TMP_T lines,
      QP_PREQ_LDETS_TMP_T A,
      QP_LIST_LINES B
 WHERE lines.line_id = p_quote_line_id
 AND lines.REQUEST_ID = nvl(sys_context('QP_CONTEXT','REQUEST_ID'),1)
 AND (lines.line_id IS NOT NULL
 AND lines.line_id <> FND_API.G_MISS_NUM)
 AND lines.line_index = a.line_index
 AND b.substitution_attribute = G_QUAL_ATTRIBUTE11
 AND A.CREATED_FROM_LIST_LINE_TYPE = QP_PREQ_GRP.G_TERMS_SUBSTITUTION
 AND a.applied_flag = G_YES_FLAG
 AND a.modifier_level_code = G_LINE_LEVEL
 AND a.process_code IN (QP_PREQ_GRP.G_STATUS_NEW, QP_PREQ_GRP.G_STATUS_UPDATED)
 and a.CREATED_FROM_LIST_LINE_ID = b.LIST_LINE_ID
 AND a.PRICING_STATUS_CODE = 'N'
 and a.REQUEST_ID = nvl(SYS_CONTEXT('QP_CONTEXT','REQUEST_ID'),1);

-- Added QP_PREQ_LDETS_TMP_N3 index hint for bug 20215472
CURSOR c_ln_ftc_tsn (p_quote_line_id NUMBER) IS
 SELECT /*+ LEADING (lines) INDEX (lines, QP_PREQ_LINES_TMP_N1) index(A QP_PREQ_LDETS_TMP_N3) USE_NL (lines A B olk) */
        B.SUBSTITUTION_VALUE
 FROM QP_PREQ_LINES_TMP_T lines,
      QP_PREQ_LDETS_TMP_T A,
      QP_LIST_LINES B,
      fnd_lookup_values olk
 WHERE lines.line_id = p_quote_line_id
 AND lines.REQUEST_ID = nvl(sys_context('QP_CONTEXT','REQUEST_ID'),1)
 AND (lines.line_id IS NOT NULL
 AND lines.line_id <> FND_API.G_MISS_NUM)
 AND lines.line_index = a.line_index
 AND b.substitution_attribute = G_QUAL_ATTRIBUTE10
 AND A.CREATED_FROM_LIST_LINE_TYPE = G_TERMS_SUBSTITUTION
 AND a.applied_flag = G_YES_FLAG
 AND a.modifier_level_code = G_LINE_LEVEL
 AND a.process_code IN (QP_PREQ_GRP.G_STATUS_NEW, QP_PREQ_GRP.G_STATUS_UPDATED)
 AND olk.lookup_type = G_FREIGHT_TERM_LK_TYPE
 AND olk.enabled_flag = G_YES_FLAG
 AND olk.lookup_code = B.SUBSTITUTION_VALUE
 AND (TRUNC(sysdate) BETWEEN NVL(TRUNC(olk.start_date_active),TRUNC( sysdate))
 AND NVL(TRUNC(olk.end_date_active), TRUNC(sysdate)))
 and a.CREATED_FROM_LIST_LINE_ID = b.LIST_LINE_ID
 AND a.PRICING_STATUS_CODE = 'N'
 and a.REQUEST_ID = nvl(SYS_CONTEXT('QP_CONTEXT','REQUEST_ID'),1)
 and olk.LANGUAGE = USERENV('LANG')
 and olk.VIEW_APPLICATION_ID = 660
 and olk.SECURITY_GROUP_ID =0;

l_req_ship_method_code    ASO_SHIPMENTS.ship_method_code%TYPE;
l_req_freight_terms_code  ASO_SHIPMENTS.freight_terms_code%TYPE;



-- Added for Line Level Payment TSN
l_payment_rec             ASO_QUOTE_PUB.payment_rec_type;
lx_payment_id             ASO_PAYMENTS.payment_id%TYPE;
l_payment_id  NUMBER;
l_req_payment_term_id NUMBER;
G_USER_ID   		  NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID       	  NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

CURSOR c_line_pyt_exists (p_quote_line_id NUMBER) IS
SELECT payment_id
FROM   ASO_PAYMENTS
WHERE quote_header_id = p_quote_header_id
and quote_line_id = p_quote_line_id;

-- Added QP_PREQ_LDETS_TMP_N3 index hint for bug 20215472
CURSOR c_line_pyt_tsn(p_quote_line_id NUMBER)  IS
 SELECT /*+ LEADING (lines) INDEX (lines, QP_PREQ_LINES_TMP_N1) index(A QP_PREQ_LDETS_TMP_N3) USE_NL (lines A B ) */
        B.SUBSTITUTION_VALUE
 FROM QP_PREQ_LINES_TMP_T lines,
      QP_PREQ_LDETS_TMP_T A,
      QP_LIST_LINES B,
      RA_TERMS_B ratv
 WHERE lines.line_id = p_quote_line_id
 AND lines.REQUEST_ID = nvl(sys_context('QP_CONTEXT','REQUEST_ID'),1)
 AND (lines.line_id IS NOT NULL
 AND lines.line_id <> FND_API.G_MISS_NUM)
 AND lines.line_index = a.line_index
 AND b.substitution_attribute = G_QUAL_ATTRIBUTE1
 AND A.CREATED_FROM_LIST_LINE_TYPE = QP_PREQ_GRP.G_TERMS_SUBSTITUTION
 AND a.applied_flag = G_YES_FLAG
 AND a.modifier_level_code = G_LINE_LEVEL
 AND a.process_code IN (QP_PREQ_GRP.G_STATUS_NEW, QP_PREQ_GRP.G_STATUS_UPDATED)
 and a.CREATED_FROM_LIST_LINE_ID = b.LIST_LINE_ID
 AND a.PRICING_STATUS_CODE = 'N'
 and a.REQUEST_ID = nvl(SYS_CONTEXT('QP_CONTEXT','REQUEST_ID'),1)
 AND   ratv.term_id = B.SUBSTITUTION_VALUE
 AND  (TRUNC(sysdate)  BETWEEN NVL(TRUNC(ratv.start_date_active),TRUNC(sysdate))
                              AND NVL(TRUNC(ratv.end_date_active ), TRUNC(sysdate)));


l_substitution_value_to  NUMBER;


BEGIN

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_PRICING_CORE_PVT:Start of line tsn p_insert_type: '||p_insert_type,1,'Y');
	END If;
     If p_insert_type = 'HDR' Then

        FOR l_qte_ln_rec IN c_qte_lines LOOP
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_qte_ln_rec.quote_line_id: '||NVL(l_qte_ln_rec.quote_line_id,0),1,'Y');
             aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln TSN Count Starts Here...',1,'Y');
     	     FOR ln_rec IN c_ln_tsn_count(l_qte_ln_rec.quote_line_id) LOOP
               --aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.substitution_value_to :'||NVL(ln_rec.substitution_value_to,'null'),1,'Y');
               aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.substitution_value :'||NVL(ln_rec.substitution_value,'null'),1,'Y');
               aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.substitution_attribute :'||NVL(ln_rec.substitution_attribute ,'null'),1,'Y');
               aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.line_id :'||NVL(ln_rec.line_id,0),1,'Y');
               aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.line_index :'||NVL(ln_rec.line_index,0),1,'Y');
               --aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.list_line_type_code :'||NVL(ln_rec.list_line_type_code,'null'),1,'Y');
               aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.created_from_list_line_type :'||NVL(ln_rec.created_from_list_line_type,'null'),1,'Y');
               aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.applied_flag :'||NVL(ln_rec.applied_flag,'null'),1,'Y');
               aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.modifier_level_code :'||NVL(ln_rec.modifier_level_code,'null'),1,'Y');
               aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.process_code :'||NVL(ln_rec.process_code,'null'),1,'Y');
     	     END LOOP;
             aso_debug_pub.add('ASO_PRICING_CORE_PVT: PROCESS_LN_TSN Starts Here...',1,'Y');
           END IF;
 --Line Level Payment TSN Starts Here
            l_payment_id := NUll; -- Code change done for Bug 18618623
            OPEN c_line_pyt_exists(l_qte_ln_rec.quote_line_id);
            FETCH c_line_pyt_exists INTO l_payment_id;
            CLOSE c_line_pyt_exists;
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                    aso_debug_pub.add('ASO_PRICING_CORE_PVT:Line l_payment_id :'||NVL(l_payment_id,0),1,'Y');
                END IF;
          	     OPen c_line_pyt_tsn(l_qte_ln_rec.quote_line_id);
				fetch c_line_pyt_tsn into l_substitution_value_to;
				close c_line_pyt_tsn;


                    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                        aso_debug_pub.add('ASO_PRICING_CORE_PVT:Line l_substitution_value_to: '||NVL(l_substitution_value_to,0),1,'Y');
                     END IF;


                    IF l_substitution_value_to IS NULL AND l_payment_id IS NOT NULL THEN

     		             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               	         aso_debug_pub.add('ASO_PRICING_CORE_PVT: No Line Level Payment TSN exists hence update with from value...',1,'Y');
                        END IF;

        	               UPDATE ASO_PAYMENTS
		                      SET payment_term_id = payment_term_id_from
			                 WHERE  quote_header_id = p_quote_header_id
			                 AND    quote_line_id = l_qte_ln_rec.quote_line_id;

        	               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        	                   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No of Payment Rows Updated : '||sql%ROWCOUNT,1,'Y');
        	               END IF;

                    ELSIF l_substitution_value_to IS NOT NULL AND l_payment_id IS NOT NULL THEN
                                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        	                       aso_debug_pub.add('ASO_PRICING_CORE_PVT: Inside ELSIF l_substitution_value_to IS NOT NULLAND l_payment_id IS NOT NULL:',1,'Y');
        	                   END IF;
                            UPDATE ASO_PAYMENTS
		                      SET payment_term_id = l_substitution_value_to
		                      WHERE  quote_header_id = p_quote_header_id
                            and quote_line_id = l_qte_ln_rec.quote_line_id;

     	             ELSIF l_payment_id IS NULL AND l_substitution_value_to IS NOT NULL THEN
     		             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           	                aso_debug_pub.add('ASO_PRICING_CORE_PVT: No Line Level Payment Record Exists...Before Payment Insert Row',1,'Y');
                            aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_substitution_value_to'||l_substitution_value_to,1,'Y');
        	               END IF;
						   lx_PAYMENT_ID := null;
		                  ASO_PAYMENTS_PKG.Insert_Row(
	    		             px_PAYMENT_ID                  => lx_PAYMENT_ID,
	    		             p_CREATION_DATE                => SYSDATE,
	    		             p_CREATED_BY                   => G_USER_ID,
	    		             p_LAST_UPDATE_DATE	       => sysdate,
	    		             p_LAST_UPDATED_BY              => G_USER_ID,
	    		             p_LAST_UPDATE_LOGIN            => G_LOGIN_ID,
	    		             p_REQUEST_ID                   => l_payment_rec.REQUEST_ID,
	    		             p_PROGRAM_APPLICATION_ID       => l_payment_rec.PROGRAM_APPLICATION_ID,
	    		             p_PROGRAM_ID                   => l_payment_rec.PROGRAM_ID,
	    	              	p_PROGRAM_UPDATE_DATE          => l_payment_rec.PROGRAM_UPDATE_DATE,
	    		             p_QUOTE_HEADER_ID              => p_quote_header_id,
	    		             p_QUOTE_LINE_ID  	       => l_qte_ln_rec.quote_line_id,
	    		             p_PAYMENT_TYPE_CODE            => l_payment_rec.PAYMENT_TYPE_CODE,
	    		             p_PAYMENT_REF_NUMBER           => l_payment_rec.PAYMENT_REF_NUMBER,
	    		             p_PAYMENT_OPTION               => l_payment_rec.PAYMENT_OPTION,
	    		             p_PAYMENT_TERM_ID              => l_substitution_value_to,
	    		             p_CREDIT_CARD_CODE	       => l_payment_rec.CREDIT_CARD_CODE,
	    		                 p_CREDIT_CARD_HOLDER_NAME      => l_payment_rec.CREDIT_CARD_HOLDER_NAME,
	    		             p_CREDIT_CARD_EXPIRATION_DATE  => l_payment_rec.CREDIT_CARD_EXPIRATION_DATE,
	    		             p_CREDIT_CARD_APPROVAL_CODE    => l_payment_rec.CREDIT_CARD_APPROVAL_CODE,
	    		             p_CREDIT_CARD_APPROVAL_DATE    => l_payment_rec.CREDIT_CARD_APPROVAL_DATE,
	    		             p_PAYMENT_AMOUNT               => l_payment_rec.PAYMENT_AMOUNT,
	    		             p_ATTRIBUTE_CATEGORY           => l_payment_rec.ATTRIBUTE_CATEGORY,
	    		             p_ATTRIBUTE1                   => l_payment_rec.ATTRIBUTE1,
	    		             p_ATTRIBUTE2                   => l_payment_rec.ATTRIBUTE2,
	    		             p_ATTRIBUTE3                   => l_payment_rec.ATTRIBUTE3,
                	    		p_ATTRIBUTE4                   => l_payment_rec.ATTRIBUTE4,
                	    		p_ATTRIBUTE5                   => l_payment_rec.ATTRIBUTE5,
                	    		p_ATTRIBUTE6                   => l_payment_rec.ATTRIBUTE6,
                	    		p_ATTRIBUTE7                   => l_payment_rec.ATTRIBUTE7,
                	    		p_ATTRIBUTE8                   => l_payment_rec.ATTRIBUTE8,
                	    		p_ATTRIBUTE9                   => l_payment_rec.ATTRIBUTE9,
                	    		p_ATTRIBUTE10                  => l_payment_rec.ATTRIBUTE10,
                	    		p_ATTRIBUTE11                  => l_payment_rec.ATTRIBUTE11,
                	    		p_ATTRIBUTE12                  => l_payment_rec.ATTRIBUTE12,
                	    		p_ATTRIBUTE13                  => l_payment_rec.ATTRIBUTE13,
                	    		p_ATTRIBUTE14                  => l_payment_rec.ATTRIBUTE14,
                	    		p_ATTRIBUTE15                  => l_payment_rec.ATTRIBUTE15,
                                 p_ATTRIBUTE16                  => l_payment_rec.ATTRIBUTE16,
                  		     p_ATTRIBUTE17                  => l_payment_rec.ATTRIBUTE17,
                  			p_ATTRIBUTE18                  => l_payment_rec.ATTRIBUTE18,
                  			p_ATTRIBUTE19                  => l_payment_rec.ATTRIBUTE19,
                  			p_ATTRIBUTE20                  => l_payment_rec.ATTRIBUTE20,
                  			p_QUOTE_SHIPMENT_ID            => l_payment_rec.QUOTE_SHIPMENT_ID,
                        		p_CUST_PO_NUMBER               => l_payment_rec.CUST_PO_NUMBER,
                        		p_PAYMENT_TERM_ID_FROM         => l_payment_rec.PAYMENT_TERM_ID_FROM,
                  			p_OBJECT_VERSION_NUMBER   => l_payment_rec.OBJECT_VERSION_NUMBER,
                              p_CUST_PO_LINE_NUMBER   => l_payment_rec.CUST_PO_LINE_NUMBER, -- Line Payments Change
                  		    p_TRXN_EXTENSION_ID    => l_payment_rec.TRXN_EXTENSION_ID
                  	    		);
		                              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		                                                  aso_debug_pub.add('ASO_PRICING_CORE_PVT: After Payment Insert Row...Payment_ID :'||NVL(lx_payment_id,0),1,'Y');
		                               END IF;
              END IF;

	      l_req_ship_method_code := NULL;
           l_req_freight_terms_code := NULL;

	   OPEN c_ln_smc_tsn(l_qte_ln_rec.quote_line_id);
           FETCH c_ln_smc_tsn INTO l_req_ship_method_code;
        	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_req_ship_method_code: '||NVL(l_req_ship_method_code,0),1,'Y');
     	   END IF;

           IF l_req_ship_method_code IS NULL THEN
		   CLOSE c_ln_smc_tsn;
        	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        	      aso_debug_pub.add('ASO_PRICING_CORE_PVT: No Line Level Ship Method Code TSN exists hence update with From value...',1,'Y');
        	   END IF;
		   UPDATE ASO_SHIPMENTS aso
	   	      SET aso.ship_method_code = ship_method_code_from
		   WHERE  aso.quote_header_id = p_quote_header_id
		   AND    (p_quote_header_id IS NOT NULL AND p_quote_header_id <> FND_API.G_MISS_NUM)
		   AND    aso.quote_line_id = l_qte_ln_rec.quote_line_id
		   AND    (l_qte_ln_rec.quote_line_id IS NOT NULL AND l_qte_ln_rec.quote_line_id <> FND_API.G_MISS_NUM)
		   AND    aso.quote_line_id IS NOT NULL;
        	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No of Ship Method Code Rows Updated : '||sql%ROWCOUNT,1,'Y');
		   END IF;
	   ELSE
	   	   CLOSE c_ln_smc_tsn;
     		   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           	      aso_debug_pub.add('ASO_PRICING_CORE_PVT: Line Level Shipment TSN exists...',1,'Y');
     		   END IF;
		   UPDATE ASO_SHIPMENTS aso
	   	      SET aso.ship_method_code = l_req_ship_method_code
		   WHERE  aso.quote_header_id = p_quote_header_id
		   AND    (p_quote_header_id IS NOT NULL AND p_quote_header_id <> FND_API.G_MISS_NUM)
		   AND    aso.quote_line_id = l_qte_ln_rec.quote_line_id
		   AND    (l_qte_ln_rec.quote_line_id IS NOT NULL AND l_qte_ln_rec.quote_line_id <> FND_API.G_MISS_NUM)
		   AND    aso.quote_line_id IS NOT NULL
	        AND   ('S' = (ASO_VALIDATE_PVT.Validate_ShipMethods('T', l_req_ship_method_code,
      		       aso.ship_from_org_id, p_quote_header_id, l_qte_ln_rec.quote_line_id)));
        	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No of Ship Method Code Rows Updated : '||sql%ROWCOUNT,1,'Y');
		   END IF;
	   END IF; -- l_req_ship_method_code IS NULL or NOT check.


	   OPEN c_ln_ftc_tsn(l_qte_ln_rec.quote_line_id);
           FETCH c_ln_ftc_tsn INTO l_req_freight_terms_code;
     	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_req_freight_terms_code: '||NVL(l_req_freight_terms_code,0),1,'Y');
     	   END IF;

           IF l_req_freight_terms_code IS NULL THEN
		   CLOSE c_ln_ftc_tsn;
        	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No Line Level Freight Terms Code TSN exists hence update with From value...',1,'Y');
        	   END IF;
		   UPDATE ASO_SHIPMENTS aso
	   	      SET aso.freight_terms_code = freight_terms_code_from
		   WHERE  aso.quote_header_id = p_quote_header_id
		   AND    (p_quote_header_id IS NOT NULL AND p_quote_header_id <> FND_API.G_MISS_NUM)
		   AND    aso.quote_line_id = l_qte_ln_rec.quote_line_id
		   AND    (l_qte_ln_rec.quote_line_id IS NOT NULL AND l_qte_ln_rec.quote_line_id <> FND_API.G_MISS_NUM)
		   AND    aso.quote_line_id IS NOT NULL;
        	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No of Freight Terms Code Rows Updated : '||sql%ROWCOUNT,1,'Y');
        	   END IF;
	   ELSE
		   CLOSE c_ln_ftc_tsn;
     		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: Line Level Freight TSN exists...',1,'Y');
     		END IF;
		   UPDATE ASO_SHIPMENTS aso
	   	      SET aso.freight_terms_code = l_req_freight_terms_code
		   WHERE  aso.quote_header_id = p_quote_header_id
		   AND    (p_quote_header_id IS NOT NULL AND p_quote_header_id <> FND_API.G_MISS_NUM)
		   AND    aso.quote_line_id = l_qte_ln_rec.quote_line_id
		   AND    (l_qte_ln_rec.quote_line_id IS NOT NULL AND l_qte_ln_rec.quote_line_id <> FND_API.G_MISS_NUM)
		   AND    aso.quote_line_id IS NOT NULL;
        	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No of Freight Terms Code Rows Updated : '||sql%ROWCOUNT,1,'Y');
        	   END IF;
	   END IF; -- l_req_freight_terms_code IS NULL or not check.

        END LOOP; -- for c_qte_lines.

   Else
	 /*Partial order, repricing the free lines only*/
	 /*We will only change the TSN for the free lines only*/

        FOR l_qte_ln_rec IN c_get_free_lines LOOP
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_qte_ln_rec.quote_line_id: '||NVL(l_qte_ln_rec.quote_line_id,0),1,'Y');
             aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln TSN Count Starts Here...',1,'Y');
     	     FOR ln_rec IN c_ln_tsn_count(l_qte_ln_rec.quote_line_id) LOOP
               --aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.substitution_value_to :'||NVL(ln_rec.substitution_value_to,'null'),1,'Y');
               aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.substitution_value :'||NVL(ln_rec.substitution_value,'null'),1,'Y');
               aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.substitution_attribute :'||NVL(ln_rec.substitution_attribute ,'null'),1,'Y');
               aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.line_id :'||NVL(ln_rec.line_id,0),1,'Y');
               aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.line_index :'||NVL(ln_rec.line_index,0),1,'Y');
               --aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.list_line_type_code :'||NVL(ln_rec.list_line_type_code,'null'),1,'Y');
               aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.created_from_list_line_type :'||NVL(ln_rec.created_from_list_line_type,'null'),1,'Y');
			aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.applied_flag :'||NVL(ln_rec.applied_flag,'null'),1,'Y');
               aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.modifier_level_code :'||NVL(ln_rec.modifier_level_code,'null'),1,'Y');
               aso_debug_pub.add('ASO_PRICING_CORE_PVT: ln_rec.process_code :'||NVL(ln_rec.process_code,'null'),1,'Y');
     	     END LOOP;
             aso_debug_pub.add('ASO_PRICING_CORE_PVT: PROCESS_LN_TSN Starts Here...',1,'Y');
           END IF;
           --Line level Payment TSN starts here for free good line

            OPEN c_line_pyt_exists(l_qte_ln_rec.quote_line_id);
            FETCH c_line_pyt_exists INTO l_payment_id;
            CLOSE c_line_pyt_exists;
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                    aso_debug_pub.add('ASO_PRICING_CORE_PVT:Line l_payment_id :'||NVL(l_payment_id,0),1,'Y');
                END IF;
          	     OPen c_line_pyt_tsn(l_qte_ln_rec.quote_line_id);
				fetch c_line_pyt_tsn into l_substitution_value_to;
				close c_line_pyt_tsn;


                    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                        aso_debug_pub.add('ASO_PRICING_CORE_PVT:Line l_substitution_value_to: '||NVL(l_substitution_value_to,0),1,'Y');
                     END IF;


                    IF l_substitution_value_to IS NULL AND l_payment_id IS NOT NULL THEN

     		             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               	         aso_debug_pub.add('ASO_PRICING_CORE_PVT: No Line Level Payment TSN exists hence update with from value...',1,'Y');
                        END IF;

        	               UPDATE ASO_PAYMENTS
		                      SET payment_term_id = payment_term_id_from
			                 WHERE  quote_header_id = p_quote_header_id
			                 AND    quote_line_id = l_qte_ln_rec.quote_line_id;

        	               IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        	                   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No of Payment Rows Updated : '||sql%ROWCOUNT,1,'Y');
        	               END IF;

                    ELSIF l_substitution_value_to IS NOT NULL AND l_payment_id IS NOT NULL THEN
                                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        	                       aso_debug_pub.add('ASO_PRICING_CORE_PVT: Inside ELSIF l_substitution_value_to IS NOT NULLAND l_payment_id IS NOT NULL:',1,'Y');
        	                   END IF;
                            UPDATE ASO_PAYMENTS
		                      SET payment_term_id = l_substitution_value_to
		                      WHERE  quote_header_id = p_quote_header_id
                            and quote_line_id = l_qte_ln_rec.quote_line_id;

     	             ELSIF l_payment_id IS NULL AND l_substitution_value_to IS NOT NULL THEN
     		             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           	                aso_debug_pub.add('ASO_PRICING_CORE_PVT: No Line Level Payment Record Exists...Before Payment Insert Row',1,'Y');
                            aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_substitution_value_to'||l_substitution_value_to,1,'Y');
        	               END IF;
						   lx_PAYMENT_ID := null;
		                  ASO_PAYMENTS_PKG.Insert_Row(
	    		             px_PAYMENT_ID                  => lx_PAYMENT_ID,
	    		             p_CREATION_DATE                => SYSDATE,
	    		             p_CREATED_BY                   => G_USER_ID,
	    		             p_LAST_UPDATE_DATE	       => sysdate,
	    		             p_LAST_UPDATED_BY              => G_USER_ID,
	    		             p_LAST_UPDATE_LOGIN            => G_LOGIN_ID,
	    		             p_REQUEST_ID                   => l_payment_rec.REQUEST_ID,
	    		             p_PROGRAM_APPLICATION_ID       => l_payment_rec.PROGRAM_APPLICATION_ID,
	    		             p_PROGRAM_ID                   => l_payment_rec.PROGRAM_ID,
	    	              	p_PROGRAM_UPDATE_DATE          => l_payment_rec.PROGRAM_UPDATE_DATE,
	    		             p_QUOTE_HEADER_ID              => p_quote_header_id,
	    		             p_QUOTE_LINE_ID  	       => l_qte_ln_rec.quote_line_id,
	    		             p_PAYMENT_TYPE_CODE            => l_payment_rec.PAYMENT_TYPE_CODE,
	    		             p_PAYMENT_REF_NUMBER           => l_payment_rec.PAYMENT_REF_NUMBER,
	    		             p_PAYMENT_OPTION               => l_payment_rec.PAYMENT_OPTION,
	    		             p_PAYMENT_TERM_ID              => l_substitution_value_to,
	    		             p_CREDIT_CARD_CODE	       => l_payment_rec.CREDIT_CARD_CODE,
	    		                 p_CREDIT_CARD_HOLDER_NAME      => l_payment_rec.CREDIT_CARD_HOLDER_NAME,
	    		             p_CREDIT_CARD_EXPIRATION_DATE  => l_payment_rec.CREDIT_CARD_EXPIRATION_DATE,
	    		             p_CREDIT_CARD_APPROVAL_CODE    => l_payment_rec.CREDIT_CARD_APPROVAL_CODE,
	    		             p_CREDIT_CARD_APPROVAL_DATE    => l_payment_rec.CREDIT_CARD_APPROVAL_DATE,
	    		             p_PAYMENT_AMOUNT               => l_payment_rec.PAYMENT_AMOUNT,
	    		             p_ATTRIBUTE_CATEGORY           => l_payment_rec.ATTRIBUTE_CATEGORY,
	    		             p_ATTRIBUTE1                   => l_payment_rec.ATTRIBUTE1,
	    		             p_ATTRIBUTE2                   => l_payment_rec.ATTRIBUTE2,
	    		             p_ATTRIBUTE3                   => l_payment_rec.ATTRIBUTE3,
                	    		p_ATTRIBUTE4                   => l_payment_rec.ATTRIBUTE4,
                	    		p_ATTRIBUTE5                   => l_payment_rec.ATTRIBUTE5,
                	    		p_ATTRIBUTE6                   => l_payment_rec.ATTRIBUTE6,
                	    		p_ATTRIBUTE7                   => l_payment_rec.ATTRIBUTE7,
                	    		p_ATTRIBUTE8                   => l_payment_rec.ATTRIBUTE8,
                	    		p_ATTRIBUTE9                   => l_payment_rec.ATTRIBUTE9,
                	    		p_ATTRIBUTE10                  => l_payment_rec.ATTRIBUTE10,
                	    		p_ATTRIBUTE11                  => l_payment_rec.ATTRIBUTE11,
                	    		p_ATTRIBUTE12                  => l_payment_rec.ATTRIBUTE12,
                	    		p_ATTRIBUTE13                  => l_payment_rec.ATTRIBUTE13,
                	    		p_ATTRIBUTE14                  => l_payment_rec.ATTRIBUTE14,
                	    		p_ATTRIBUTE15                  => l_payment_rec.ATTRIBUTE15,
                                 p_ATTRIBUTE16                  => l_payment_rec.ATTRIBUTE16,
                  		     p_ATTRIBUTE17                  => l_payment_rec.ATTRIBUTE17,
                  			p_ATTRIBUTE18                  => l_payment_rec.ATTRIBUTE18,
                  			p_ATTRIBUTE19                  => l_payment_rec.ATTRIBUTE19,
                  			p_ATTRIBUTE20                  => l_payment_rec.ATTRIBUTE20,
                  			p_QUOTE_SHIPMENT_ID            => l_payment_rec.QUOTE_SHIPMENT_ID,
                        		p_CUST_PO_NUMBER               => l_payment_rec.CUST_PO_NUMBER,
                        		p_PAYMENT_TERM_ID_FROM         => l_payment_rec.PAYMENT_TERM_ID_FROM,
                  			p_OBJECT_VERSION_NUMBER   => l_payment_rec.OBJECT_VERSION_NUMBER,
                              p_CUST_PO_LINE_NUMBER   => l_payment_rec.CUST_PO_LINE_NUMBER, -- Line Payments Change
                  		    p_TRXN_EXTENSION_ID    => l_payment_rec.TRXN_EXTENSION_ID
                  	    		);
		                              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		                                                  aso_debug_pub.add('ASO_PRICING_CORE_PVT: After Payment Insert Row...Payment_ID :'||NVL(lx_payment_id,0),1,'Y');
		                               END IF;
              END IF;

	      l_req_ship_method_code := NULL;
           l_req_freight_terms_code := NULL;

	   OPEN c_ln_smc_tsn(l_qte_ln_rec.quote_line_id);
           FETCH c_ln_smc_tsn INTO l_req_ship_method_code;
        	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_req_ship_method_code: '||NVL(l_req_ship_method_code,0),1,'Y');
     	   END IF;

           IF l_req_ship_method_code IS NULL THEN
		   CLOSE c_ln_smc_tsn;
        	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        	      aso_debug_pub.add('ASO_PRICING_CORE_PVT: No Line Level Ship Method Code TSN exists hence update with From value...',1,'Y');
        	   END IF;
		   UPDATE ASO_SHIPMENTS aso
	   	      SET aso.ship_method_code = ship_method_code_from
		   WHERE  aso.quote_header_id = p_quote_header_id
		   AND    (p_quote_header_id IS NOT NULL AND p_quote_header_id <> FND_API.G_MISS_NUM)
		   AND    aso.quote_line_id = l_qte_ln_rec.quote_line_id
		   AND    (l_qte_ln_rec.quote_line_id IS NOT NULL AND l_qte_ln_rec.quote_line_id <> FND_API.G_MISS_NUM)
		   AND    aso.quote_line_id IS NOT NULL;
        	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No of Ship Method Code Rows Updated : '||sql%ROWCOUNT,1,'Y');
		   END IF;
	   ELSE
	   	   CLOSE c_ln_smc_tsn;
     		   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           	      aso_debug_pub.add('ASO_PRICING_CORE_PVT: Line Level Shipment TSN exists...',1,'Y');
     		   END IF;
		   UPDATE ASO_SHIPMENTS aso
	   	      SET aso.ship_method_code = l_req_ship_method_code
		   WHERE  aso.quote_header_id = p_quote_header_id
		   AND    (p_quote_header_id IS NOT NULL AND p_quote_header_id <> FND_API.G_MISS_NUM)
		   AND    aso.quote_line_id = l_qte_ln_rec.quote_line_id
		   AND    (l_qte_ln_rec.quote_line_id IS NOT NULL AND l_qte_ln_rec.quote_line_id <> FND_API.G_MISS_NUM)
		   AND    aso.quote_line_id IS NOT NULL
	        AND   ('S' = (ASO_VALIDATE_PVT.Validate_ShipMethods('T', l_req_ship_method_code,
      		       aso.ship_from_org_id, p_quote_header_id, l_qte_ln_rec.quote_line_id)));
        	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No of Ship Method Code Rows Updated : '||sql%ROWCOUNT,1,'Y');
		   END IF;
	   END IF; -- l_req_ship_method_code IS NULL or NOT check.


	   OPEN c_ln_ftc_tsn(l_qte_ln_rec.quote_line_id);
           FETCH c_ln_ftc_tsn INTO l_req_freight_terms_code;
     	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_req_freight_terms_code: '||NVL(l_req_freight_terms_code,0),1,'Y');
     	   END IF;

           IF l_req_freight_terms_code IS NULL THEN
		   CLOSE c_ln_ftc_tsn;
        	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No Line Level Freight Terms Code TSN exists hence update with From value...',1,'Y');
        	   END IF;
		   UPDATE ASO_SHIPMENTS aso
	   	      SET aso.freight_terms_code = freight_terms_code_from
		   WHERE  aso.quote_header_id = p_quote_header_id
		   AND    (p_quote_header_id IS NOT NULL AND p_quote_header_id <> FND_API.G_MISS_NUM)
		   AND    aso.quote_line_id = l_qte_ln_rec.quote_line_id
		   AND    (l_qte_ln_rec.quote_line_id IS NOT NULL AND l_qte_ln_rec.quote_line_id <> FND_API.G_MISS_NUM)
		   AND    aso.quote_line_id IS NOT NULL;
        	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No of Freight Terms Code Rows Updated : '||sql%ROWCOUNT,1,'Y');
        	   END IF;
	   ELSE
		   CLOSE c_ln_ftc_tsn;
     		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: Line Level Freight TSN exists...',1,'Y');
     		END IF;
		   UPDATE ASO_SHIPMENTS aso
	   	      SET aso.freight_terms_code = l_req_freight_terms_code
		   WHERE  aso.quote_header_id = p_quote_header_id
		   AND    (p_quote_header_id IS NOT NULL AND p_quote_header_id <> FND_API.G_MISS_NUM)
		   AND    aso.quote_line_id = l_qte_ln_rec.quote_line_id
		   AND    (l_qte_ln_rec.quote_line_id IS NOT NULL AND l_qte_ln_rec.quote_line_id <> FND_API.G_MISS_NUM)
		   AND    aso.quote_line_id IS NOT NULL;
        	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              	   aso_debug_pub.add('ASO_PRICING_CORE_PVT: No of Freight Terms Code Rows Updated : '||sql%ROWCOUNT,1,'Y');
        	   END IF;
	   END IF; -- l_req_freight_terms_code IS NULL or not check.

	   END LOOP; -- for c_get_free_lines


   End If;--If p_insert_type = 'HDR'

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           aso_debug_pub.add('ASO_PRICING_CORE_PVT: PROCESS_LN_TSN Ends Here...',1,'Y');
        END IF;
END PROCESS_LN_TSN;

-- The above two procedures are for TSN processing...

PROCEDURE Print_G_Header_Rec
AS
BEGIN
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('**********Start Header Level Information available to Price Request***********',1,'Y');
         aso_debug_pub.add('QUOTE_HEADER_ID:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.QUOTE_HEADER_ID),'NULL'),1,'Y');
         aso_debug_pub.add('QUOTE_NAME:'||nvl(ASO_PRICING_INT.G_HEADER_REC.QUOTE_NAME,'NULL'),1,'Y');
         aso_debug_pub.add('QUOTE_NUMBER:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.QUOTE_NUMBER),'NULL'),1,'Y');
         aso_debug_pub.add('QUOTE_VERSION:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.QUOTE_VERSION),'NULL'),1,'Y');
         aso_debug_pub.add('QUOTE_STATUS_ID:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.QUOTE_STATUS_ID),'NULL'),1,'Y');
         aso_debug_pub.add('QUOTE_SOURCE_CODE:'||nvl(ASO_PRICING_INT.G_HEADER_REC.QUOTE_SOURCE_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('QUOTE_EXPIRATION_DATE:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.QUOTE_EXPIRATION_DATE),'NULL'),1,'Y');
         aso_debug_pub.add('PRICE_FROZEN_DATE:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.PRICE_FROZEN_DATE),'NULL'),1,'Y');
         aso_debug_pub.add('CUST_PARTY_ID:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.CUST_PARTY_ID),'NULL'),1,'Y');
         aso_debug_pub.add('PARTY_ID:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.PARTY_ID),'NULL'),1,'Y');
         aso_debug_pub.add('CUST_ACCOUNT_ID:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.CUST_ACCOUNT_ID),'NULL'),1,'Y');
         aso_debug_pub.add('ORG_CONTACT_ID:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.ORG_CONTACT_ID),'NULL'),1,'Y');
         aso_debug_pub.add('INVOICE_TO_PARTY_SITE_ID:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.INVOICE_TO_PARTY_SITE_ID),'NULL'),1,'Y');
         aso_debug_pub.add('INVOICE_TO_PARTY_ID:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.INVOICE_TO_PARTY_ID),'NUll'),1,'Y');
         aso_debug_pub.add('ORDER_TYPE_ID:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.ORDER_TYPE_ID),'NULL'),1,'Y');
         aso_debug_pub.add('QUOTE_CATEGORY_CODE:'||nvl(ASO_PRICING_INT.G_HEADER_REC.QUOTE_CATEGORY_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('ORDERED_DATE:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.ORDERED_DATE),'NULL'),1,'Y');
         aso_debug_pub.add('PRICE_LIST_ID:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.PRICE_LIST_ID),'NULL'),1,'Y');
         aso_debug_pub.add('CURRENCY_CODE:'||nvl(ASO_PRICING_INT.G_HEADER_REC.CURRENCY_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('TOTAL_LIST_PRICE:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.TOTAL_LIST_PRICE),'NULL'),1,'Y');
         aso_debug_pub.add('TOTAL_QUOTE_PRICE:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.TOTAL_QUOTE_PRICE),'NULL'),1,'Y');
         aso_debug_pub.add('CONTRACT_ID:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.CONTRACT_ID),'NULL'),1,'Y');
         aso_debug_pub.add('SALES_CHANNEL_CODE:'||nvl(ASO_PRICING_INT.G_HEADER_REC.SALES_CHANNEL_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('SHIP_TO_PARTY_SITE_ID:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.SHIP_TO_PARTY_SITE_ID),'NULL'),1,'Y');
         aso_debug_pub.add('SHIP_TO_PARTY_ID:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.SHIP_TO_PARTY_ID),'NULL'),1,'Y');
         aso_debug_pub.add('SHIP_METHOD_CODE:'||nvl(ASO_PRICING_INT.G_HEADER_REC.SHIP_METHOD_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('FREIGHT_TERMS_CODE:'||nvl(ASO_PRICING_INT.G_HEADER_REC.FREIGHT_TERMS_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('FREIGHT_CARRIER_CODE:'||nvl(ASO_PRICING_INT.G_HEADER_REC.FREIGHT_CARRIER_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('FOB_CODE:'||nvl(ASO_PRICING_INT.G_HEADER_REC.FOB_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('REQUEST_DATE:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.REQUEST_DATE),'NULL'),1,'Y');
         aso_debug_pub.add('RECALCULATE_FLAG:'||nvl(ASO_PRICING_INT.G_HEADER_REC.RECALCULATE_FLAG,'NULL'),1,'Y');
         aso_debug_pub.add('MINISITE_ID:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.MINISITE_ID),'NULL'),1,'Y');
	 aso_debug_pub.add('END_CUSTOMER_CUST_ACCOUNT_ID:'||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.END_CUSTOMER_CUST_ACCOUNT_ID),'NULL'),1,'Y'); -- bug 21661093
         aso_debug_pub.add('**********End Header Level Information available to Price Request***********',1,'Y');
       END IF;

END Print_G_Header_Rec;

PROCEDURE Print_G_Line_Rec
AS
BEGIN
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('**********Start Line Level Information available to Price Request***********',1,'Y');
         aso_debug_pub.add('QUOTE_HEADER_ID:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.QUOTE_HEADER_ID),'NULL'),1,'Y');
         aso_debug_pub.add('QUOTE_LINE_ID:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.QUOTE_LINE_ID),'NULL'),1,'Y');
         aso_debug_pub.add('LINE_CATEGORY_CODE:'||nvl(ASO_PRICING_INT.G_LINE_REC.LINE_CATEGORY_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('ITEM_TYPE_CODE:'||nvl(ASO_PRICING_INT.G_LINE_REC.ITEM_TYPE_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('ORDER_LINE_TYPE_ID:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.ORDER_LINE_TYPE_ID),'NULL'),1,'Y');
         aso_debug_pub.add('INVOICE_TO_PARTY_SITE_ID:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.INVOICE_TO_PARTY_SITE_ID),'NULL'),1,'Y');
         aso_debug_pub.add('INVOICE_TO_PARTY_ID:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.INVOICE_TO_PARTY_ID),'NULL'),1,'Y');
         aso_debug_pub.add('INVENTORY_ITEM_ID:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.INVENTORY_ITEM_ID),'NULL'),1,'Y');
         aso_debug_pub.add('QUANTITY:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.QUANTITY),'NULL'),1,'Y');
         aso_debug_pub.add('ORDER_LINE_TYPE_ID:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.ORDER_LINE_TYPE_ID),'NULL'),1,'Y');
         aso_debug_pub.add('UOM_CODE:'||nvl(ASO_PRICING_INT.G_LINE_REC.UOM_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('PRICE_LIST_ID:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.PRICE_LIST_ID),'NULL'),1,'Y');
         aso_debug_pub.add('PRICE_LIST_LINE_ID:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.PRICE_LIST_LINE_ID),'NULL'),1,'Y');
         aso_debug_pub.add('CURRENCY_CODE:'||nvl(ASO_PRICING_INT.G_LINE_REC.CURRENCY_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('LINE_LIST_PRICE:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.LINE_LIST_PRICE),'NULL'),1,'Y');
         aso_debug_pub.add('LINE_ADJUSTED_AMOUNT:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.LINE_ADJUSTED_AMOUNT),'NULL'),1,'Y');
         aso_debug_pub.add('LINE_ADJUSTED_PERCENT:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.LINE_ADJUSTED_PERCENT),'NULL'),1,'Y');
         aso_debug_pub.add('LINE_QUOTE_PRICE:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.LINE_QUOTE_PRICE),'NULL'),1,'Y');
         aso_debug_pub.add('RELATED_ITEM_ID:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.RELATED_ITEM_ID),'NULL'),1,'Y');
         aso_debug_pub.add('ITEM_RELATIONSHIP_TYPE:'||nvl(ASO_PRICING_INT.G_LINE_REC.ITEM_RELATIONSHIP_TYPE,'NULL'),1,'Y');
         aso_debug_pub.add('MODEL_ID:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.MODEL_ID),'NULL'),1,'Y');
         aso_debug_pub.add('SERVICE_REF_LINE_ID:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.SERVICE_REF_LINE_ID),'NULL'),1,'Y');
         aso_debug_pub.add('SHIP_TO_PARTY_SITE_ID:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.SHIP_TO_PARTY_SITE_ID),'NULL'),1,'Y');
         aso_debug_pub.add('SHIP_TO_PARTY_ID:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.SHIP_TO_PARTY_ID),'NULL'),1,'Y');
         aso_debug_pub.add('SHIP_METHOD_CODE:'||nvl(ASO_PRICING_INT.G_LINE_REC.SHIP_METHOD_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('FREIGHT_TERMS_CODE:'||nvl(ASO_PRICING_INT.G_LINE_REC.FREIGHT_TERMS_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('FREIGHT_CARRIER_CODE:'||nvl(ASO_PRICING_INT.G_LINE_REC.FREIGHT_CARRIER_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('FOB_CODE:'||nvl(ASO_PRICING_INT.G_LINE_REC.FOB_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('REQUEST_DATE:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.REQUEST_DATE),'NULL'),1,'Y');
         aso_debug_pub.add('AGREEMENT_ID:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.AGREEMENT_ID),'NULL'),1,'Y');
         aso_debug_pub.add('SELLING_PRICE_CHANGE:'||nvl(ASO_PRICING_INT.G_LINE_REC.SELLING_PRICE_CHANGE,'NULL'),1,'Y');
         aso_debug_pub.add('RECALCULATE_FLAG:'||nvl(ASO_PRICING_INT.G_LINE_REC.RECALCULATE_FLAG,'NULL'),1,'Y');
         aso_debug_pub.add('PRICING_LINE_TYPE_INDICATOR:'||nvl(ASO_PRICING_INT.G_LINE_REC.PRICING_LINE_TYPE_INDICATOR,'NULL'),1,'Y');
         aso_debug_pub.add('MINISITE_ID:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.MINISITE_ID),'NULL'),1,'Y');
         aso_debug_pub.add('CHARGE_PERIODICITY_CODE:'||nvl(ASO_PRICING_INT.G_LINE_REC.CHARGE_PERIODICITY_CODE,'NULL'),1,'Y');
         aso_debug_pub.add('PRICING_QUANTITY_UOM:'||nvl(ASO_PRICING_INT.G_LINE_REC.PRICING_QUANTITY_UOM,'NULL'),1,'Y');
         aso_debug_pub.add('PRICING_QUANTITY:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.PRICING_QUANTITY),'NULL'),1,'Y');
	-- aso_debug_pub.add('UNIT_PRICE:'||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.UNIT_PRICE),'NULL'),1,'Y'); commented for Bug 19243138
         aso_debug_pub.add('**********End Line Level Information available to Price Request***********',1,'Y');
       END IF;

END Print_G_Line_Rec;


/*New Append_ask_for to use direct insert*/
PROCEDURE  Append_Asked_For(
        p_pricing_event                        varchar2
	  ,p_price_line_index                     NUMBER
       ,p_header_id                            number := null
       ,p_Line_id                              number := null
       ,px_index_counter         IN OUT NOCOPY /* file.sql.39 change */ number)
IS

cursor asked_for_cur is
    select flex_title, pricing_context, pricing_attribute1,
    pricing_attribute2 , pricing_attribute3 , pricing_attribute4 , pricing_attribute5 ,
    pricing_attribute6 , pricing_attribute7 , pricing_attribute8 , pricing_attribute9 ,
    pricing_attribute10 , pricing_attribute11 , pricing_attribute12 , pricing_attribute13 ,
    pricing_attribute14 , pricing_attribute15 , pricing_attribute16 , pricing_attribute17 ,
    pricing_attribute18 , pricing_attribute19 , pricing_attribute20 , pricing_attribute21 ,
    pricing_attribute22 , pricing_attribute23 , pricing_attribute24 , pricing_attribute25 ,
    pricing_attribute26 , pricing_attribute27 , pricing_attribute28 , pricing_attribute29 ,
    pricing_attribute30 , pricing_attribute31 , pricing_attribute32 , pricing_attribute33 ,
    pricing_attribute34 , pricing_attribute35 , pricing_attribute36 , pricing_attribute37 ,
    pricing_attribute38 , pricing_attribute39 , pricing_attribute40 , pricing_attribute41 ,
    pricing_attribute42 , pricing_attribute43 , pricing_attribute44 , pricing_attribute45 ,
    pricing_attribute46 , pricing_attribute47 , pricing_attribute48 , pricing_attribute49 ,
    pricing_attribute50 , pricing_attribute51 , pricing_attribute52 , pricing_attribute53 ,
    pricing_attribute54 , pricing_attribute55 , pricing_attribute56 , pricing_attribute57 ,
    pricing_attribute58 , pricing_attribute59 , pricing_attribute60 , pricing_attribute61 ,
    pricing_attribute62 , pricing_attribute63 , pricing_attribute64 , pricing_attribute65 ,
    pricing_attribute66 , pricing_attribute67 , pricing_attribute68 , pricing_attribute69 ,
    pricing_attribute70 , pricing_attribute71 , pricing_attribute72 , pricing_attribute73 ,
    pricing_attribute74 , pricing_attribute75 , pricing_attribute76 , pricing_attribute77 ,
    pricing_attribute78 , pricing_attribute79 , pricing_attribute80 , pricing_attribute81 ,
    pricing_attribute82 , pricing_attribute83 , pricing_attribute84 , pricing_attribute85 ,
    pricing_attribute86 , pricing_attribute87 , pricing_attribute88 , pricing_attribute89 ,
    pricing_attribute90 , pricing_attribute91 , pricing_attribute92 , pricing_attribute93 ,
    pricing_attribute94 , pricing_attribute95 , pricing_attribute96 , pricing_attribute97 ,
    pricing_attribute98 , pricing_attribute99 , pricing_attribute100
    ,Override_Flag
    from aso_price_attributes a
    where  a.QUOTE_HEADER_ID = p_header_id
    and p_header_id is not null
    and a.quote_line_id is null
    /*
     * New Code - Union is changed to union all
     */
  UNION ALL
    select flex_title, pricing_context, pricing_attribute1,
    pricing_attribute2 , pricing_attribute3 , pricing_attribute4 , pricing_attribute5 ,
    pricing_attribute6 , pricing_attribute7 , pricing_attribute8 , pricing_attribute9 ,
    pricing_attribute10 , pricing_attribute11 , pricing_attribute12 , pricing_attribute13 ,
    pricing_attribute14 , pricing_attribute15 , pricing_attribute16 , pricing_attribute17 ,
    pricing_attribute18 , pricing_attribute19 , pricing_attribute20 , pricing_attribute21 ,
    pricing_attribute22 , pricing_attribute23 , pricing_attribute24 , pricing_attribute25 ,
    pricing_attribute26 , pricing_attribute27 , pricing_attribute28 , pricing_attribute29 ,
    pricing_attribute30 , pricing_attribute31 , pricing_attribute32 , pricing_attribute33 ,
    pricing_attribute34 , pricing_attribute35 , pricing_attribute36 , pricing_attribute37 ,
    pricing_attribute38 , pricing_attribute39 , pricing_attribute40 , pricing_attribute41 ,
    pricing_attribute42 , pricing_attribute43 , pricing_attribute44 , pricing_attribute45 ,
    pricing_attribute46 , pricing_attribute47 , pricing_attribute48 , pricing_attribute49 ,
    pricing_attribute50 , pricing_attribute51 , pricing_attribute52 , pricing_attribute53 ,
    pricing_attribute54 , pricing_attribute55 , pricing_attribute56 , pricing_attribute57 ,
    pricing_attribute58 , pricing_attribute59 , pricing_attribute60 , pricing_attribute61 ,
    pricing_attribute62 , pricing_attribute63 , pricing_attribute64 , pricing_attribute65 ,
    pricing_attribute66 , pricing_attribute67 , pricing_attribute68 , pricing_attribute69 ,
    pricing_attribute70 , pricing_attribute71 , pricing_attribute72 , pricing_attribute73 ,
    pricing_attribute74 , pricing_attribute75 , pricing_attribute76 , pricing_attribute77 ,
    pricing_attribute78 , pricing_attribute79 , pricing_attribute80 , pricing_attribute81 ,
    pricing_attribute82 , pricing_attribute83 , pricing_attribute84 , pricing_attribute85 ,
    pricing_attribute86 , pricing_attribute87 , pricing_attribute88 , pricing_attribute89 ,
    pricing_attribute90 , pricing_attribute91 , pricing_attribute92 , pricing_attribute93 ,
    pricing_attribute94 , pricing_attribute95 , pricing_attribute96 , pricing_attribute97 ,
    pricing_attribute98 , pricing_attribute99 , pricing_attribute100
    ,Override_Flag
    FROM ASO_PRICE_ATTRIBUTES a
    WHERE a.quote_header_id = p_header_id
    AND a.QUOTE_line_id = p_line_id
    AND p_line_id IS NOT NULL;

    l_counter NUMBER := 0;
    l_line_index   NUMBER;

begin
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT: In Direct Insert Append_Asked_for',1,'Y');
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Direct Insert Append_Ask_for - Global_Header_Rec.quote_status_id:'
                         ||ASO_PRICING_INT.G_HEADER_REC.quote_status_id,1,'Y');
    END IF;

    l_line_index := p_price_line_index;

    l_counter := px_index_counter;
    for asked_for_rec in asked_for_cur loop
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_CONTEXT:'
                             ||asked_for_rec.PRICING_CONTEXT,1,'Y');
          aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.flex_title:'
                             ||asked_for_rec.flex_title,1,'Y');
        END IF;

        If asked_for_rec.flex_title = 'QP_ATTR_DEFNS_PRICING' then
           if asked_for_rec.PRICING_ATTRIBUTE1 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE1:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE1,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE1';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE1;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

           end if;
        if asked_for_rec.PRICING_ATTRIBUTE2 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE2:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE2,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE2';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE2;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE3 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE3:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE3,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE3';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE3;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE4 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE4:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE4,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE4';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE4;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE5 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE5:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE5,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE5';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE5;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE6 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE6:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE6,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE6';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE6;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE7 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE7:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE7,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE7';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE7;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE8 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE8:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE8,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE8';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE8;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE9 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE9:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE9,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE9';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE9;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE10 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE10:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE10,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE10';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE10;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE11 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE11:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE11,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE11';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE11;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE12 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE12:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE12,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE12';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE12;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE13 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE13:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE13,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE13';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE13;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE14 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE14:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE14,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE14';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE14;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE15 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE15:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE15,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE15';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE15;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE16 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE16:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE16,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE16';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE16;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE17 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE17:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE17,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE17';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE17;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE18 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE18:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE18,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE18';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE18;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE19 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE19:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE19,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE19';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE19;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE20 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE20:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE20,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE20';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE20;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE21 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE21:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE20,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE21';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE21;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE22 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE22:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE22,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE22';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE22;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE23 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE23:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE23,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE23';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE23;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE24 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE24:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE24,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE24';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE24;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE25 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE25:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE25,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE25';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE25;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE26 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE26:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE26,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE26';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE26;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE27 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE27:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE27,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE27';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE27;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE28 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE28:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE28,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE28';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE28;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE29 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE29:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE29,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE29';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE29;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE30 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE30:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE30,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE30';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE30;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE31 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE31:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE31,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE31';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE31;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE32 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE32:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE32,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE32';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE32;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE33 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE33:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE33,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE33';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE33;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE34 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE34:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE34,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE34';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE34;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE35 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE35:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE35,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE35';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE35;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
              l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE36 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE36:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE36,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE36';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE36;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE37 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE37:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE37,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE37';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE37;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE38 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE38:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE38,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE38';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE38;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE39 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE39:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE39,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE39';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE39;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE40 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE40:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE40,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE40';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE40;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE41 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE41:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE41,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE41';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE41;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE42 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE42:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE42,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE42';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE42;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE43 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE43:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE43,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE43';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE43;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE44 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE44:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE44,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE44';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE44;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE45 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE45:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE45,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE45';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE45;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE46 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE46:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE46,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE46';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE46;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE47 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE47:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE47,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE47';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE47;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE48 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE48:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE48,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE48';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE48;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE49 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE49:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE49,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE49';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE49;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE50 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE50:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE50,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE50';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE50;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE51 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE51:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE51,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE51';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE51;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE52 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE52:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE52,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE52';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE52;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE53 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE53:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE53,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE53';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE53;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE54 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE54:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE54,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE54';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE54;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE55 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE55:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE55,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE55';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE55;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE56 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE56:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE56,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE56';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE56;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE57 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE57:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE57,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE57';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE57;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE58 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE58:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE58,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE58';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE58;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE59 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE59:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE59,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index ;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE59';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE59;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;

        if asked_for_rec.PRICING_ATTRIBUTE60 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE60:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE60,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE60';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE60;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE61 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE61:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE61,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE61';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE61;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE62 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE62:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE62,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE62';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE62;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE63 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE63:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE63,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE63';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE63;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE64 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE64:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE64,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE64';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE64;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE65 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE65:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE65,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE65';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE65;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE66 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE66:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE66,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE66';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE66;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE67 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE67:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE67,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE67';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE67;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE68 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE68:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE68,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE68';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE68;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE69 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE69:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE69,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE69';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE69;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE70 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE70:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE70,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE70';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE70;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE71 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE71:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE71,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE71';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE71;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE72 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE72:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE72,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE72';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE72;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE73 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE73:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE73,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE73';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE73;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE74 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE74:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE74,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE74';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE74;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE75 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE75:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE75,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE75';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE75;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE76 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE76:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE76,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE76';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE76;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE77 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE77:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE77,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE77';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE77;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE78 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE78:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE78,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE78';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE78;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE79 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE79:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE79,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE79';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE79;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE80 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE80:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE80,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE80';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE80;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE81 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE81:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE81,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE81';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE81;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE82 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE82:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE82,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE82';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE82;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE83 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE83:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE83,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE83';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE83;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE84 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE84:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE84,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE84';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE84;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE85 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE85:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE85,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE85';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE85;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE86 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE86:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE86,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE86';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE86;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE87 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE87:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE87,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE87';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE87;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE88 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE88:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE88,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE88';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE88;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE89 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE89:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE89,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE89';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE89;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE90 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE90:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE90,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE90';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE90;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE91 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE91:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE91,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE91';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE91;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE92 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE92:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE92,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE92';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE92;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE93 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE93:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE93,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE93';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE93;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE94 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE94:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE94,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE94';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE94;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE95 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE95:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE95,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE95';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE95;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE96 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE96:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE96,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE96';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE96;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE97 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE97:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE97,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE97';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE97;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE98 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE98:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE98,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE98';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE98;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE99 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE99:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE99,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE99';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE99;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE100 is not null then
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE100:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE100,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'PRICING_ATTRIBUTE100';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE100;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;

      else -- Copy the Qualifiers
	 if p_pricing_event = 'BATCH' then
	   --added the and condition to accomodate the change made in the forms UI to pass pricing_attribute1 only when pricing_attribute2 is null
        if asked_for_rec.PRICING_ATTRIBUTE1 is not null and asked_for_rec.PRICING_ATTRIBUTE2 is null then -- Promotion
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE1:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE1,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              IF NVL(ASO_PRICING_INT.G_HEADER_REC.quote_status_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
                 G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              ELSE
                 G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_VALIDATED;
              END IF;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'QUALIFIER_ATTRIBUTE1';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE1;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE2 is not null then --Deal Component
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE2:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE2,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              IF NVL(ASO_PRICING_INT.G_HEADER_REC.quote_status_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
                 G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              ELSE
                 G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_VALIDATED;
              END IF;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'QUALIFIER_ATTRIBUTE2';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE2;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
		    l_counter := l_counter + 1;

        end if;
        if asked_for_rec.PRICING_ATTRIBUTE3 is not null then -- Coupons
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: asked_for_rec.PRICING_ATTRIBUTE3:'
                                   ||asked_for_rec.PRICING_ATTRIBUTE3,1,'Y');
              END IF;

              G_ATTR_LINE_INDEX_tbl(l_counter)          := l_line_index;
              G_ATTR_LINE_DETAIL_INDEX_tbl(l_counter)   := NULL;
              G_ATTR_ATTRIBUTE_LEVEL_tbl(l_counter)     := QP_PREQ_GRP.G_LINE_LEVEL;
              IF NVL(ASO_PRICING_INT.G_HEADER_REC.quote_status_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
                 G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_NOT_VALIDATED;
              ELSE
                 G_ATTR_VALIDATED_FLAG_tbl(l_counter)      := QP_PREQ_GRP.G_VALIDATED;
              END IF;
              IF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_ITEM_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRODUCT_TYPE;
              ELSIF (asked_for_rec.pricing_context = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT) THEN
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_QUALIFIER_TYPE;
              ELSE
                  G_ATTR_ATTRIBUTE_TYPE_tbl(l_counter) := QP_PREQ_GRP.G_PRICING_TYPE;
              END IF;
              G_ATTR_PRICING_CONTEXT_tbl(l_counter)     := asked_for_rec.pricing_context;
              G_ATTR_PRICING_ATTRIBUTE_tbl(l_counter)   := 'QUALIFIER_ATTRIBUTE3';
              G_ATTR_APPLIED_FLAG_tbl(l_counter)        := QP_PREQ_GRP.G_LIST_NOT_APPLIED;
              G_ATTR_PRICING_STATUS_CODE_tbl(l_counter) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
              G_ATTR_PRICING_ATTR_FLAG_tbl (l_counter)  := QP_PREQ_GRP.G_YES;
              G_ATTR_LIST_HEADER_ID_tbl(l_counter)      := NULL;
              G_ATTR_LIST_LINE_ID_tbl(l_counter)        := NULL;
              G_ATTR_VALUE_FROM_tbl(l_counter)          := asked_for_rec.PRICING_ATTRIBUTE3;
              G_ATTR_SETUP_VALUE_FROM_tbl(l_counter)    := NULL;
              G_ATTR_VALUE_TO_tbl(l_counter)            := NULL;
              G_ATTR_SETUP_VALUE_TO_tbl(l_counter)      := NULL;
              G_ATTR_GROUPING_NUMBER_tbl(l_counter)     := NULL;
              G_ATTR_NO_QUAL_IN_GRP_tbl(l_counter)      := NULL;
              G_ATTR_COMP_OPERATOR_TYPE_tbl(l_counter)  := NULL;
              G_ATTR_PRICING_STATUS_TEXT_tbl(l_counter) := NULL;
              G_ATTR_QUAL_PRECEDENCE_tbl(l_counter)     := NULL;
              G_ATTR_DATATYPE_tbl(l_counter)            := NULL;
              G_ATTR_QUALIFIER_TYPE_tbl(l_counter)      := NULL;
              G_ATTR_PRODUCT_UOM_CODE_TBL(l_counter)    := NULL;
              G_ATTR_EXCLUDER_FLAG_TBL(l_counter)       := NULL;
              G_ATTR_PRICING_PHASE_ID_TBL(l_counter)    := NULL;
              G_ATTR_INCOM_GRP_CODE_TBL(l_counter)      := NULL;
              G_ATTR_LDET_TYPE_CODE_TBL(l_counter)      := NULL;
              G_ATTR_MODIFIER_LEVEL_CODE_TBL(l_counter) := NULL;
              G_ATTR_PRIMARY_UOM_FLAG_TBL(l_counter)    := NULL;
	      l_counter := l_counter + 1;

        end if;
	end if;-- p_pricing_event = 'BATCH'
  end if;--asked_for_rec.flex_title = 'QP_ATTR_DEFNS_PRICING'
end loop;
    px_index_counter := l_counter;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_counter:'||l_counter,1,'Y');
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:End of Direct Insert Append_asked_for',1,'Y');
    END IF;

end Append_asked_for;

/*New copy_Header_to_request to use direct insert*/
PROCEDURE Copy_Header_To_Request(
    p_Request_Type                   VARCHAR2,
    p_price_line_index               NUMBER,
    px_index_counter                 NUMBER)
IS
BEGIN
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of the direct insert Copy_Header_To_Request',1,'Y');
     aso_debug_pub.add('ASO_PRICING_CORE_PVT: px_index_counter:'||px_index_counter,1,'Y');
     aso_debug_pub.add('ASO_PRICING_CORE_PVT: ASO_PRICING_INT.G_HEADER_REC.quote_header_id:'||ASO_PRICING_INT.G_HEADER_REC.quote_header_id,1,'Y');
   END IF;
   G_LINE_INDEX_TBL(px_index_counter)              := p_price_line_index;
   G_LINE_TYPE_CODE_TBL(px_index_counter)          := 'ORDER';
   /*FastTrak: Price effective date is assigned to the price frozen unless the price frozen date is null*/
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:Copy_Header_To_Req: ASO_PRICING_INT.G_HEADER_REC.PRICE_FROZEN_DATE:'
                               ||ASO_PRICING_INT.G_HEADER_REC.PRICE_FROZEN_DATE,1,'Y');
   END IF;
   if NVL(ASO_PRICING_INT.G_HEADER_REC.PRICE_FROZEN_DATE,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE THEN
          G_PRICING_EFFECTIVE_DATE_TBL(px_index_counter) := trunc(sysdate);
   else
          G_PRICING_EFFECTIVE_DATE_TBL(px_index_counter) := trunc(ASO_PRICING_INT.G_HEADER_REC.PRICE_FROZEN_DATE);
   end if;
   G_ACTIVE_DATE_FIRST_TBL(px_index_counter)       := TRUNC(sysdate);
   G_ACTIVE_DATE_FIRST_TYPE_TBL(px_index_counter)  := 'NO TYPE';
   G_ACTIVE_DATE_SECOND_TBL(px_index_counter)      := TRUNC(sysdate);
   G_ACTIVE_DATE_SECOND_TYPE_TBL(px_index_counter) := 'NO TYPE';
   G_LINE_QUANTITY_TBL(px_index_counter)           := null;
   G_LINE_UOM_CODE_TBL(px_index_counter)           := null;
   G_REQUEST_TYPE_CODE_TBL(px_index_counter)       := p_request_type;
   G_PRICED_QUANTITY_TBL(px_index_counter)         := null;
   G_UOM_QUANTITY_TBL(px_index_counter)            := null;
   G_PRICED_UOM_CODE_TBL(px_index_counter)         := null;
   G_CURRENCY_CODE_TBL(px_index_counter)           := ASO_PRICING_INT.G_HEADER_REC.currency_code;
   G_UNIT_PRICE_TBL(px_index_counter)              := null;
   G_LINE_UNIT_PRICE_TBL(px_index_counter)         := null; -- bug 20700246 , commented for Bug 19243138
   G_PERCENT_PRICE_TBL(px_index_counter)           := null;
   G_ADJUSTED_UNIT_PRICE_TBL(px_index_counter)     := null;
   G_PROCESSED_FLAG_TBL(px_index_counter)          := null;
   G_PRICE_FLAG_TBL(px_index_counter)              := 'Y';
   G_LINE_ID_TBL(px_index_counter)                 := ASO_PRICING_INT.G_HEADER_REC.quote_header_id;
   G_ROUNDING_FLAG_TBL(px_index_counter)           := null;
   G_ROUNDING_FACTOR_TBL(px_index_counter)         := null;
   G_PROCESSING_ORDER_TBL(px_index_counter)        := NULL;
   G_PRICING_STATUS_CODE_tbl(px_index_counter)     := QP_PREQ_GRP.G_STATUS_UNCHANGED;
   G_PRICING_STATUS_TEXT_tbl(px_index_counter)     := NULL;
   G_QUALIFIERS_EXIST_FLAG_TBL(px_index_counter)   := 'N';
   G_PRICING_ATTRS_EXIST_FLAG_TBL(px_index_counter):= 'N';
   G_PRICE_LIST_ID_TBL(px_index_counter)           := NULL;
   G_PL_VALIDATED_FLAG_TBL(px_index_counter)       := 'N';
   G_PRICE_REQUEST_CODE_TBL(px_index_counter)      := NULL;
   G_USAGE_PRICING_TYPE_TBL(px_index_counter)      := 'REGULAR';
   G_UPD_ADJUSTED_UNIT_PRICE_TBL(px_index_counter) := NULL;
   G_LINE_CATEGORY_TBL(px_index_counter):= NULL;
   G_CHRG_PERIODICITY_CODE_TBL(px_index_counter)    := NULL;
   /* Changes Made for OKS uptake bug 4900084  */
   G_CONTRACT_START_DATE_TBL(px_index_counter)      := NULL;
   G_CONTRACT_END_DATE_TBL(px_index_counter)        := NULL;

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT: End of the direct insert Copy_Header_To_Request',1,'Y');
   END IF;

end copy_Header_to_request;

/*New copy_Line_to_request to use direct insert*/
PROCEDURE Copy_Line_To_Request(
    p_Request_Type                      VARCHAR2,
    p_price_line_index                  NUMBER,
    px_index_counter                    NUMBER)
is
    l_uom_rate        NUMBER;
begin
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:Start of Direct Insert of Copy_Line_To_Request',1,'Y');
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:px_index_counter:'||px_index_counter,1,'Y');
   END IF;
   G_LINE_INDEX_TBL(px_index_counter)               := p_price_line_index;
   G_LINE_TYPE_CODE_TBL(px_index_counter)           :=  'LINE';

   /*FastTrak: Price effective date is assigned to the price frozen unless the price frozen date is null*/
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:Copy_Line_To_Request: G_HEADER_REC.PRICE_FROZEN_DATE:'
                               ||ASO_PRICING_INT.G_HEADER_REC.PRICE_FROZEN_DATE,1,'Y');
   END IF;
   if NVL(ASO_PRICING_INT.G_HEADER_REC.PRICE_FROZEN_DATE,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE THEN
      G_PRICING_EFFECTIVE_DATE_TBL(px_index_counter) := trunc(sysdate);
   else
      G_PRICING_EFFECTIVE_DATE_TBL(px_index_counter) := trunc(ASO_PRICING_INT.G_HEADER_REC.PRICE_FROZEN_DATE);
   end if;
   G_ACTIVE_DATE_FIRST_TBL(px_index_counter)        := TRUNC(sysdate);
   G_ACTIVE_DATE_FIRST_TYPE_TBL(px_index_counter)   := 'NO TYPE';
   G_ACTIVE_DATE_SECOND_TBL(px_index_counter)       := TRUNC(sysdate);
   G_ACTIVE_DATE_SECOND_TYPE_TBL(px_index_counter)  := 'NO TYPE';
   G_LINE_QUANTITY_TBL(px_index_counter)            := ASO_PRICING_INT.G_LINE_REC.quantity;
   G_LINE_UOM_CODE_TBL(px_index_counter)            := ASO_PRICING_INT.G_LINE_REC.uom_code;
   G_REQUEST_TYPE_CODE_TBL(px_index_counter)        := p_Request_Type;
   -- Added for Service Item after pathcset E
   If ASO_PRICING_INT.G_LINE_REC.service_period is not null
      AND ASO_PRICING_INT.G_LINE_REC.service_period <> fnd_api.g_miss_char then
      If (ASO_PRICING_INT.G_LINE_REC.service_period = ASO_PRICING_INT.G_LINE_REC.uom_code) Then
          G_UOM_QUANTITY_TBL(px_index_counter) := ASO_PRICING_INT.G_LINE_REC.service_duration;
          G_CONTRACT_START_DATE_TBL(px_index_counter) := ASO_PRICING_INT.G_LINE_REC.start_date_active;
          G_CONTRACT_END_DATE_TBL(px_index_counter) := ASO_PRICING_INT.G_LINE_REC.end_date_active;

       Else
          /* Changes Made for OKS uptake bug 4900084

          INV_CONVERT.INV_UM_CONVERSION(
                   From_Unit  => ASO_PRICING_INT.G_LINE_REC.service_period
                   ,To_Unit   => ASO_PRICING_INT.G_LINE_REC.uom_code
                   ,Item_ID   => ASO_PRICING_INT.G_LINE_REC.Inventory_item_id
                   ,Uom_Rate  => l_Uom_rate);
          G_UOM_QUANTITY_TBL(px_index_counter) := ASO_PRICING_INT.G_LINE_REC.service_duration * l_uom_rate; */

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_PRICING_CORE_PVT: before call to OKS_OMINT_PUB.GET_TARGET_DURATION',1,'Y');
          END IF;


          G_UOM_QUANTITY_TBL(px_index_counter) :=		OKS_OMINT_PUB.GET_TARGET_DURATION
	                                         ( p_start_date => ASO_PRICING_INT.G_LINE_REC.start_date_active,
	                                           p_end_date   => ASO_PRICING_INT.G_LINE_REC.end_date_active,
									   p_source_uom => ASO_PRICING_INT.G_LINE_REC.service_period,
									   p_source_duration => ASO_PRICING_INT.G_LINE_REC.service_duration,
									   p_target_uom => ASO_PRICING_INT.G_LINE_REC.uom_code,
									   p_org_id     => ASO_PRICING_INT.G_LINE_REC.org_id);

           G_CONTRACT_START_DATE_TBL(px_index_counter) := ASO_PRICING_INT.G_LINE_REC.start_date_active;
		 G_CONTRACT_END_DATE_TBL(px_index_counter) := ASO_PRICING_INT.G_LINE_REC.end_date_active;

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		              aso_debug_pub.add('ASO_PRICING_CORE_PVT: after  call to OKS_OMINT_PUB.GET_TARGET_DURATION',1,'Y');
		END IF;

      End If;
   Else
	 G_UOM_QUANTITY_TBL(px_index_counter) := null;
	 G_CONTRACT_START_DATE_TBL(px_index_counter) := null;
	 G_CONTRACT_END_DATE_TBL(px_index_counter) := null;
   End If;
   G_PRICED_QUANTITY_TBL(px_index_counter)          := ASO_PRICING_INT.G_LINE_REC.pricing_quantity;
   G_PRICED_UOM_CODE_TBL(px_index_counter)          := ASO_PRICING_INT.G_LINE_REC.pricing_quantity_uom;
   G_CURRENCY_CODE_TBL(px_index_counter)            := ASO_PRICING_INT.G_LINE_REC.currency_code;

  /* commented for Bug 19243138
   -- bug 17517305
   If ASO_PRICING_INT.G_LINE_REC.line_list_price <> FND_API.G_MISS_NUM Then
      G_LINE_UNIT_PRICE_TBL(px_index_counter) := ASO_PRICING_INT.G_LINE_REC.line_list_price;
   Else
      G_LINE_UNIT_PRICE_TBL(px_index_counter) := NULL;
   End If;

   If ASO_PRICING_INT.G_LINE_REC.unit_price <> FND_API.G_MISS_NUM Then
      G_UNIT_PRICE_TBL(px_index_counter) := ASO_PRICING_INT.G_LINE_REC.unit_price;
   Else
      G_UNIT_PRICE_TBL(px_index_counter) := NULL;
   End If;

   -- end bug 17517305
   */

   -- Start : code change added for Bug 19243138

   If ASO_PRICING_INT.G_LINE_REC.line_list_price <> FND_API.G_MISS_NUM Then
      G_UNIT_PRICE_TBL(px_index_counter) := ASO_PRICING_INT.G_LINE_REC.line_list_price;
      G_LINE_UNIT_PRICE_TBL(px_index_counter) := ASO_PRICING_INT.G_LINE_REC.line_list_price;  -- bug 20700246
   Else
      G_UNIT_PRICE_TBL(px_index_counter) := NULL;
      G_LINE_UNIT_PRICE_TBL(px_index_counter) := NULL; -- bug 20700246
   End If;

   -- End : code change added for Bug 19243138

   G_PERCENT_PRICE_TBL(px_index_counter)            := null;
   If NVL(ASO_PRICING_INT.G_LINE_REC.line_list_price,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
      G_ADJUSTED_UNIT_PRICE_TBL(px_index_counter)      := ASO_PRICING_INT.G_LINE_REC.line_list_price;
   else
	 G_ADJUSTED_UNIT_PRICE_TBL(px_index_counter)      := null;
   end if;
   G_PROCESSED_FLAG_TBL(px_index_counter)           := QP_PREQ_GRP.G_NOT_PROCESSED;

   -- Bug 2430534.Should set this flag only for child service line, normal line to 'Y'
   -- If the line is from order or customer product set it to 'N'.
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:In Copy line to req p_Line_rec.LINE_CATEGORY_CODE  :'
                         ||ASO_PRICING_INT.G_LINE_REC.LINE_CATEGORY_CODE,1,'Y');
   END IF;
   /*For PRG Line need to setup the free lines with price_flag to 'P'*/
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:In Copy line to req p_Line_rec.PRICING_LINE_TYPE_INDICATOR  :'
                         ||ASO_PRICING_INT.G_LINE_REC.PRICING_LINE_TYPE_INDICATOR,1,'Y');
   END IF;

   IF ASO_PRICING_INT.G_LINE_REC.PRICING_LINE_TYPE_INDICATOR = 'F' THEN
    	     G_PRICE_FLAG_TBL(px_index_counter) := 'P';
   ELSE
     IF ASO_PRICING_INT.G_LINE_REC.LINE_CATEGORY_CODE
      IN ('SERVICE_REF_ORDER_LINE','SERVICE_REF_CUSTOMER_LINE') THEN
    	        G_PRICE_FLAG_TBL(px_index_counter) := 'N';
     ELSE
   	      G_PRICE_FLAG_TBL(px_index_counter) := 'Y';
     END IF;
   END IF;

    -- for rel 12.0 Deal Integeration
   IF ASO_PRICING_INT.G_LINE_REC.PRICING_LINE_TYPE_INDICATOR = 'D' THEN
    	     G_PRICE_FLAG_TBL(px_index_counter) := 'P';
   end if;

   G_LINE_ID_TBL(px_index_counter)                  := ASO_PRICING_INT.G_LINE_REC.quote_line_id;
   G_ROUNDING_FLAG_TBL(px_index_counter)            := null;
   G_ROUNDING_FACTOR_TBL(px_index_counter)          := null;
   G_PROCESSING_ORDER_TBL(px_index_counter)         := NULL;
   G_PRICING_STATUS_CODE_tbl(px_index_counter)      := QP_PREQ_GRP.G_STATUS_UNCHANGED;
   G_PRICING_STATUS_TEXT_tbl(px_index_counter)      := NULL;
   G_QUALIFIERS_EXIST_FLAG_TBL(px_index_counter)    :='N';
   G_PRICING_ATTRS_EXIST_FLAG_TBL(px_index_counter) :='N';
   G_PRICE_LIST_ID_TBL(px_index_counter)            := -9999;
   G_PL_VALIDATED_FLAG_TBL(px_index_counter)        := 'N';
   G_PRICE_REQUEST_CODE_TBL(px_index_counter)       := NULL;
   G_USAGE_PRICING_TYPE_TBL(px_index_counter)       :='REGULAR';
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:In Copy line to req SELLING_PRICE_CHANGE: '
                        ||ASO_PRICING_INT.G_LINE_REC.SELLING_PRICE_CHANGE,1,'Y');
   END IF;
   If ASO_PRICING_INT.G_LINE_REC.SELLING_PRICE_CHANGE = 'Y' then
      G_UPD_ADJUSTED_UNIT_PRICE_TBL(px_index_counter) := ASO_PRICING_INT.G_LINE_REC.line_quote_price;
   else
	 G_UPD_ADJUSTED_UNIT_PRICE_TBL(px_index_counter) := NULL;
   End If;

   G_LINE_CATEGORY_TBL(px_index_counter)            := ASO_PRICING_INT.G_LINE_REC.line_category_code;
   G_CHRG_PERIODICITY_CODE_TBL(px_index_counter)    := ASO_PRICING_INT.G_LINE_REC.charge_periodicity_code;

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:End of Direct Insert of Copy_Line_To_Request',1,'Y');
   END IF;

end Copy_Line_To_Request;

/*Query both automatic and manual(applied) header and line adjs*/
PROCEDURE Query_Price_Adj_All
(p_quote_header_id    IN  NUMBER,
 x_adj_id_tbl         OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE)
IS
 l_adj_counter   NUMBER;
 l_rel_counter   NUMBER;
 l_adj_id_tbl    JTF_NUMBER_TABLE;

BEGIN
 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('ASO_PRICING_CORE_PVT: Inside of the Query_Price_Adj_All',1,'Y');
 END IF;

 UPDATE ASO_PRICE_ADJUSTMENTS apa
 SET OPERAND_PER_PQTY = (SELECT decode(arithmetic_operator,'%',operand,
                                  'LUMPSUM',operand,
                                  'AMT',(operand*l.quantity)/l.PRICING_QUANTITY,
                                  'NEWPRICE',(operand*l.quantity)/l.PRICING_QUANTITY)
                          FROM  ASO_QUOTE_LINES_ALL l
                          WHERE l.quote_header_id = apa.quote_header_id
					 AND l.quote_line_id = apa.quote_line_id
                          )
 WHERE apa.quote_header_id = p_quote_header_id
 AND apa.quote_line_id is not null
 AND   (apa.applied_flag = 'Y' or apa.updated_flag = 'Y');
 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:Operand per pqty updated rows - Line level: '||sql%ROWCOUNT,1,'Y');
 END IF;

 --Only support % at the header level
 UPDATE ASO_PRICE_ADJUSTMENTS
 SET OPERAND_PER_PQTY = operand
 WHERE quote_header_id = p_quote_header_id
 AND quote_line_id is null
 AND (applied_flag = 'Y' OR updated_flag = 'Y');

 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:Operand per pqty updated rows - Header Level: '||sql%ROWCOUNT,1,'Y');
 END IF;

       SELECT
		 PRICE_ADJUSTMENT_ID,
           PRICE_ADJUSTMENT_ID,
		 PRICE_ADJUSTMENT_ID,
           'NULL', --line_detail_type_code
           PRICE_BREAK_TYPE_CODE,
           NULL,
		 decode(quote_line_id,NULL,1,quote_line_id),
           MODIFIER_HEADER_ID,
           MODIFIER_LINE_ID,
           MODIFIER_LINE_TYPE_CODE,
           NULL,--List type code that we do not store currently
           NULL,--Created from SQL
           PRICING_GROUP_SEQUENCE,
           PRICING_PHASE_ID,
           ARITHMETIC_OPERATOR,
           nvl(OPERAND_PER_PQTY,OPERAND),
           NULL,--substitution_attribute
           MODIFIED_FROM,
           MODIFIED_TO,
           NULL,--ask_for_flag that we do not store currently
           NULL,--formula_id
           'X',--pricing_status_code
           NULL,--pricing_status_text
           NULL,--product_precedence
           NULL,--incompatibility_group
           'N',--processed_flag
           APPLIED_FLAG,
           AUTOMATIC_FLAG,
           UPDATE_ALLOWABLE_FLAG,
           NULL,--primary_uom_flag
           ON_INVOICE_FLAG,
           MODIFIER_LEVEL_CODE,
           BENEFIT_QTY,
           BENEFIT_UOM_CODE,
           LIST_LINE_NO,
           ACCRUAL_FLAG,
           ACCRUAL_CONVERSION_RATE,
           NULL,--estim_accrual_rate
           'N',--recurring_flag
           NULL,--selected_vol_attr
           NULL,--rounding_factor
           NULL,--hdr_limit_exist
           NULL,--Line_limit_exist
           CHARGE_TYPE_CODE,
           CHARGE_SUBTYPE_CODE,
           NULL,--currency_detail_id
           NULL,--currency_hdr_id
           NULL,--selling_round
           NULL,--order_currency
           NULL,--pricing_effect_date
           NULL,--base_currency
           RANGE_BREAK_QUANTITY,
           UPDATED_FLAG,
           MODIFIER_MECHANISM_TYPE_CODE,
           CHANGE_REASON_CODE,
           CHANGE_REASON_TEXT
	 BULK COLLECT INTO
		   l_adj_id_tbl,
             G_LDET_LINE_DTL_INDEX_TBL,
		   G_LDET_PRICE_ADJ_ID_TBL,
             G_LDET_LINE_DTL_TYPE_TBL,
             G_LDET_PRICE_BREAK_TYPE_TBL,
             G_LDET_LIST_PRICE_TBL,
             G_LDET_LINE_INDEX_TBL,
             G_LDET_LIST_HEADER_ID_TBL,
             G_LDET_LIST_LINE_ID_TBL,
             G_LDET_LIST_LINE_TYPE_TBL,
             G_LDET_LIST_TYPE_CODE_TBL,
             G_LDET_CREATED_FROM_SQL_TBL,
             G_LDET_PRICING_GRP_SEQ_TBL,
             G_LDET_PRICING_PHASE_ID_TBL,
             G_LDET_OPERAND_CALC_CODE_TBL,
             G_LDET_OPERAND_VALUE_TBL,
             G_LDET_SUBSTN_TYPE_TBL,
             G_LDET_SUBSTN_VALUE_FROM_TBL,
             G_LDET_SUBSTN_VALUE_TO_TBL,
             G_LDET_ASK_FOR_FLAG_TBL,
             G_LDET_PRICE_FORMULA_ID_TBL,
             G_LDET_PRICING_STATUS_CODE_TBL,
             G_LDET_PRICING_STATUS_TXT_TBL,
             G_LDET_PRODUCT_PRECEDENCE_TBL,
             G_LDET_INCOMPAT_GRP_CODE_TBL,
             G_LDET_PROCESSED_FLAG_TBL,
             G_LDET_APPLIED_FLAG_TBL,
             G_LDET_AUTOMATIC_FLAG_TBL,
             G_LDET_OVERRIDE_FLAG_TBL,
             G_LDET_PRIMARY_UOM_FLAG_TBL,
             G_LDET_PRINT_ON_INV_FLAG_TBL,
             G_LDET_MODIFIER_LEVEL_TBL,
             G_LDET_BENEFIT_QTY_TBL,
             G_LDET_BENEFIT_UOM_CODE_TBL,
             G_LDET_LIST_LINE_NO_TBL,
             G_LDET_ACCRUAL_FLAG_TBL,
             G_LDET_ACCR_CONV_RATE_TBL,
             G_LDET_ESTIM_ACCR_RATE_TBL,
             G_LDET_RECURRING_FLAG_TBL,
             G_LDET_SELECTED_VOL_ATTR_TBL,
             G_LDET_ROUNDING_FACTOR_TBL,
             G_LDET_HDR_LIMIT_EXISTS_TBL,
             G_LDET_LINE_LIMIT_EXISTS_TBL,
             G_LDET_CHARGE_TYPE_TBL,
             G_LDET_CHARGE_SUBTYPE_TBL,
             G_LDET_CURRENCY_DTL_ID_TBL,
             G_LDET_CURRENCY_HDR_ID_TBL,
             G_LDET_SELLING_ROUND_TBL,
             G_LDET_ORDER_CURRENCY_TBL,
             G_LDET_PRICING_EFF_DATE_TBL,
             G_LDET_BASE_CURRENCY_TBL,
             G_LDET_LINE_QUANTITY_TBL,
             G_LDET_UPDATED_FLAG_TBL,
             G_LDET_CALC_CODE_TBL,
             G_LDET_CHG_REASON_CODE_TBL,
             G_LDET_CHG_REASON_TEXT_TBL
      FROM ASO_PRICE_ADJUSTMENTS adj
      WHERE adj.QUOTE_HEADER_ID   = p_quote_header_id
	 AND   (NVL(adj.updated_flag,'N') = 'Y' OR  nvl(adj.automatic_flag,'N') = 'Y');

   x_adj_id_tbl := l_adj_id_tbl;

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT: x_adj_id_tbl.count:'||nvl(x_adj_id_tbl.count,0),1,'Y');
   END IF;

END Query_price_Adj_All;

/*Query only Header Adjs*/
PROCEDURE Query_Price_Adj_Header
(p_quote_header_id    IN NUMBER)
IS
BEGIN

 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of Query_Price_Adj_Header',1,'Y');
 END IF;

 --Only support % at the header level
 UPDATE ASO_PRICE_ADJUSTMENTS
 SET OPERAND_PER_PQTY = operand
 WHERE quote_header_id = p_quote_header_id
 AND quote_line_id is null
 AND (applied_flag = 'Y' OR updated_flag = 'Y');

 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:Operand per pqty updated rows - Header Level: '||sql%ROWCOUNT,1,'Y');
 END IF;

       SELECT
           mod(PRICE_ADJUSTMENT_ID, G_BINARY_LIMIT),--PRICE_ADJUSTMENT_ID, bug 14311089
		 PRICE_ADJUSTMENT_ID,
           'NULL', --line_detail_type_code
           PRICE_BREAK_TYPE_CODE,
           NULL,
           1,
           MODIFIER_HEADER_ID,
           MODIFIER_LINE_ID,
           MODIFIER_LINE_TYPE_CODE,
           NULL,--List type code that we do not store currently
           NULL,--Created from SQL
           PRICING_GROUP_SEQUENCE,
           PRICING_PHASE_ID,
           ARITHMETIC_OPERATOR,
           nvl(OPERAND_PER_PQTY,OPERAND),
           NULL,--substitution_attribute
           MODIFIED_FROM,
           MODIFIED_TO,
           NULL,--ask_for_flag that we do not store currently
           NULL,--formula_id
           'X',--pricing_status_code
           NULL,--pricing_status_text
           NULL,--product_precedence
           NULL,--incompatibility_group
           'N',--processed_flag
           APPLIED_FLAG,
           AUTOMATIC_FLAG,
           UPDATE_ALLOWABLE_FLAG,
           NULL,--primary_uom_flag
           ON_INVOICE_FLAG,
           MODIFIER_LEVEL_CODE,
           BENEFIT_QTY,
           BENEFIT_UOM_CODE,
           LIST_LINE_NO,
           ACCRUAL_FLAG,
           ACCRUAL_CONVERSION_RATE,
           NULL,--estim_accrual_rate
           'N',--recurring_flag
           NULL,--selected_vol_attr
           NULL,--rounding_factor
           NULL,--hdr_limit_exist
           NULL,--Line_limit_exist
           CHARGE_TYPE_CODE,
           CHARGE_SUBTYPE_CODE,
           NULL,--currency_detail_id
           NULL,--currency_hdr_id
           NULL,--selling_round
           NULL,--order_currency
           NULL,--pricing_effect_date
           NULL,--base_currency
           RANGE_BREAK_QUANTITY,
           UPDATED_FLAG,
           MODIFIER_MECHANISM_TYPE_CODE,
           CHANGE_REASON_CODE,
           CHANGE_REASON_TEXT
	 BULK COLLECT INTO
             G_LDET_LINE_DTL_INDEX_TBL,
		   G_LDET_PRICE_ADJ_ID_TBL,
             G_LDET_LINE_DTL_TYPE_TBL,
             G_LDET_PRICE_BREAK_TYPE_TBL,
             G_LDET_LIST_PRICE_TBL,
             G_LDET_LINE_INDEX_TBL,
             G_LDET_LIST_HEADER_ID_TBL,
             G_LDET_LIST_LINE_ID_TBL,
             G_LDET_LIST_LINE_TYPE_TBL,
             G_LDET_LIST_TYPE_CODE_TBL,
             G_LDET_CREATED_FROM_SQL_TBL,
             G_LDET_PRICING_GRP_SEQ_TBL,
             G_LDET_PRICING_PHASE_ID_TBL,
             G_LDET_OPERAND_CALC_CODE_TBL,
             G_LDET_OPERAND_VALUE_TBL,
             G_LDET_SUBSTN_TYPE_TBL,
             G_LDET_SUBSTN_VALUE_FROM_TBL,
             G_LDET_SUBSTN_VALUE_TO_TBL,
             G_LDET_ASK_FOR_FLAG_TBL,
             G_LDET_PRICE_FORMULA_ID_TBL,
             G_LDET_PRICING_STATUS_CODE_TBL,
             G_LDET_PRICING_STATUS_TXT_TBL,
             G_LDET_PRODUCT_PRECEDENCE_TBL,
             G_LDET_INCOMPAT_GRP_CODE_TBL,
             G_LDET_PROCESSED_FLAG_TBL,
             G_LDET_APPLIED_FLAG_TBL,
             G_LDET_AUTOMATIC_FLAG_TBL,
             G_LDET_OVERRIDE_FLAG_TBL,
             G_LDET_PRIMARY_UOM_FLAG_TBL,
             G_LDET_PRINT_ON_INV_FLAG_TBL,
             G_LDET_MODIFIER_LEVEL_TBL,
             G_LDET_BENEFIT_QTY_TBL,
             G_LDET_BENEFIT_UOM_CODE_TBL,
             G_LDET_LIST_LINE_NO_TBL,
             G_LDET_ACCRUAL_FLAG_TBL,
             G_LDET_ACCR_CONV_RATE_TBL,
             G_LDET_ESTIM_ACCR_RATE_TBL,
             G_LDET_RECURRING_FLAG_TBL,
             G_LDET_SELECTED_VOL_ATTR_TBL,
             G_LDET_ROUNDING_FACTOR_TBL,
             G_LDET_HDR_LIMIT_EXISTS_TBL,
             G_LDET_LINE_LIMIT_EXISTS_TBL,
             G_LDET_CHARGE_TYPE_TBL,
             G_LDET_CHARGE_SUBTYPE_TBL,
             G_LDET_CURRENCY_DTL_ID_TBL,
             G_LDET_CURRENCY_HDR_ID_TBL,
             G_LDET_SELLING_ROUND_TBL,
             G_LDET_ORDER_CURRENCY_TBL,
             G_LDET_PRICING_EFF_DATE_TBL,
             G_LDET_BASE_CURRENCY_TBL,
             G_LDET_LINE_QUANTITY_TBL,
             G_LDET_UPDATED_FLAG_TBL,
             G_LDET_CALC_CODE_TBL,
             G_LDET_CHG_REASON_CODE_TBL,
             G_LDET_CHG_REASON_TEXT_TBL
      FROM ASO_PRICE_ADJUSTMENTS adj
      WHERE adj.QUOTE_HEADER_ID   = p_quote_header_id
      AND   adj.QUOTE_LINE_ID IS NULL
	 AND   NVL(ASO_PRICING_INT.G_HEADER_REC.RECALCULATE_FLAG,'N') = 'N'
      AND   NVL(updated_flag,'N') = 'Y';

END Query_price_Adj_header;

/*Query line adjs only*/
/*only for the free lines before the second implicit call*/
PROCEDURE Query_Price_Adj_Line
(p_quote_header_id    IN  NUMBER,
 p_qte_line_id_tbl    IN  JTF_NUMBER_TABLE,
 x_adj_id_tbl         OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE)
IS
 l_adj_counter   NUMBER;
 l_rel_counter   NUMBER;
 l_adj_id_tbl    JTF_NUMBER_TABLE;

BEGIN
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of the Query_Price_Adj_line',1,'Y');
   END IF;

 UPDATE ASO_PRICE_ADJUSTMENTS apa
 SET OPERAND_PER_PQTY = (SELECT decode(arithmetic_operator,'%',operand,
                                  'LUMPSUM',operand,
                                  'AMT',(operand*l.quantity)/l.PRICING_QUANTITY,
                                  'NEWPRICE',(operand*l.quantity)/l.PRICING_QUANTITY)
                          FROM  ASO_QUOTE_LINES_ALL l
                          WHERE l.quote_header_id = apa.quote_header_id
					 AND l.quote_line_id = apa.quote_line_id
                          )
 WHERE apa.quote_header_id = p_quote_header_id
 AND apa.quote_line_id is not null
 AND   (apa.applied_flag = 'Y' or apa.updated_flag = 'Y');
 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:Operand per pqty updated rows - Line level: '||sql%ROWCOUNT,1,'Y');
 END IF;

 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	If p_qte_line_id_tbl.count is not null then
	   For i in 1..p_qte_line_id_tbl.count loop
	    aso_debug_pub.add('ASO_PRICING_CORE_PVT:Querying for the following quote line ids:',1,'Y');
	    aso_debug_pub.add('ASO_PRICING_CORE_PVT:p_qte_line_id_tbl(i):'||p_qte_line_id_tbl(i),1,'Y');
	   End Loop;
	End If;
   END IF;

       SELECT
		 PRICE_ADJUSTMENT_ID,
                mod(PRICE_ADJUSTMENT_ID, G_BINARY_LIMIT), --PRICE_ADJUSTMENT_ID, Bug 14311089
		 PRICE_ADJUSTMENT_ID,
           'NULL', --line_detail_type_code
           PRICE_BREAK_TYPE_CODE,
           NULL,
           quote_line_id,
           MODIFIER_HEADER_ID,
           MODIFIER_LINE_ID,
           MODIFIER_LINE_TYPE_CODE,
           NULL,--List type code that we do not store currently
           NULL,--Created from SQL
           PRICING_GROUP_SEQUENCE,
           PRICING_PHASE_ID,
           ARITHMETIC_OPERATOR,
           nvl(OPERAND_PER_PQTY,OPERAND),
           NULL,--substitution_attribute
           MODIFIED_FROM,
           MODIFIED_TO,
           NULL,--ask_for_flag that we do not store currently
           NULL,--formula_id
           'X',--pricing_status_code
           NULL,--pricing_status_text
           NULL,--product_precedence
           NULL,--incompatibility_group
           'N',--processed_flag
           APPLIED_FLAG,
           AUTOMATIC_FLAG,
           UPDATE_ALLOWABLE_FLAG,
           NULL,--primary_uom_flag
           ON_INVOICE_FLAG,
           MODIFIER_LEVEL_CODE,
           BENEFIT_QTY,
           BENEFIT_UOM_CODE,
           LIST_LINE_NO,
           ACCRUAL_FLAG,
           ACCRUAL_CONVERSION_RATE,
           NULL,--estim_accrual_rate
           'N',--recurring_flag
           NULL,--selected_vol_attr
           NULL,--rounding_factor
           NULL,--hdr_limit_exist
           NULL,--Line_limit_exist
           CHARGE_TYPE_CODE,
           CHARGE_SUBTYPE_CODE,
           NULL,--currency_detail_id
           NULL,--currency_hdr_id
           NULL,--selling_round
           NULL,--order_currency
           NULL,--pricing_effect_date
           NULL,--base_currency
           RANGE_BREAK_QUANTITY,
           UPDATED_FLAG,
           MODIFIER_MECHANISM_TYPE_CODE,
           CHANGE_REASON_CODE,
           CHANGE_REASON_TEXT
	 BULK COLLECT INTO
		   l_adj_id_tbl,
             G_LDET_LINE_DTL_INDEX_TBL,
		   G_LDET_PRICE_ADJ_ID_TBL,
             G_LDET_LINE_DTL_TYPE_TBL,
             G_LDET_PRICE_BREAK_TYPE_TBL,
             G_LDET_LIST_PRICE_TBL,
             G_LDET_LINE_INDEX_TBL,
             G_LDET_LIST_HEADER_ID_TBL,
             G_LDET_LIST_LINE_ID_TBL,
             G_LDET_LIST_LINE_TYPE_TBL,
             G_LDET_LIST_TYPE_CODE_TBL,
             G_LDET_CREATED_FROM_SQL_TBL,
             G_LDET_PRICING_GRP_SEQ_TBL,
             G_LDET_PRICING_PHASE_ID_TBL,
             G_LDET_OPERAND_CALC_CODE_TBL,
             G_LDET_OPERAND_VALUE_TBL,
             G_LDET_SUBSTN_TYPE_TBL,
             G_LDET_SUBSTN_VALUE_FROM_TBL,
             G_LDET_SUBSTN_VALUE_TO_TBL,
             G_LDET_ASK_FOR_FLAG_TBL,
             G_LDET_PRICE_FORMULA_ID_TBL,
             G_LDET_PRICING_STATUS_CODE_TBL,
             G_LDET_PRICING_STATUS_TXT_TBL,
             G_LDET_PRODUCT_PRECEDENCE_TBL,
             G_LDET_INCOMPAT_GRP_CODE_TBL,
             G_LDET_PROCESSED_FLAG_TBL,
             G_LDET_APPLIED_FLAG_TBL,
             G_LDET_AUTOMATIC_FLAG_TBL,
             G_LDET_OVERRIDE_FLAG_TBL,
             G_LDET_PRIMARY_UOM_FLAG_TBL,
             G_LDET_PRINT_ON_INV_FLAG_TBL,
             G_LDET_MODIFIER_LEVEL_TBL,
             G_LDET_BENEFIT_QTY_TBL,
             G_LDET_BENEFIT_UOM_CODE_TBL,
             G_LDET_LIST_LINE_NO_TBL,
             G_LDET_ACCRUAL_FLAG_TBL,
             G_LDET_ACCR_CONV_RATE_TBL,
             G_LDET_ESTIM_ACCR_RATE_TBL,
             G_LDET_RECURRING_FLAG_TBL,
             G_LDET_SELECTED_VOL_ATTR_TBL,
             G_LDET_ROUNDING_FACTOR_TBL,
             G_LDET_HDR_LIMIT_EXISTS_TBL,
             G_LDET_LINE_LIMIT_EXISTS_TBL,
             G_LDET_CHARGE_TYPE_TBL,
             G_LDET_CHARGE_SUBTYPE_TBL,
             G_LDET_CURRENCY_DTL_ID_TBL,
             G_LDET_CURRENCY_HDR_ID_TBL,
             G_LDET_SELLING_ROUND_TBL,
             G_LDET_ORDER_CURRENCY_TBL,
             G_LDET_PRICING_EFF_DATE_TBL,
             G_LDET_BASE_CURRENCY_TBL,
             G_LDET_LINE_QUANTITY_TBL,
             G_LDET_UPDATED_FLAG_TBL,
             G_LDET_CALC_CODE_TBL,
             G_LDET_CHG_REASON_CODE_TBL,
             G_LDET_CHG_REASON_TEXT_TBL
      FROM ASO_PRICE_ADJUSTMENTS adj,
           TABLE (CAST(P_Qte_Line_id_tbl AS JTF_NUMBER_TABLE)) Lines
      WHERE adj.QUOTE_HEADER_ID   = p_quote_header_id
      AND   adj.QUOTE_LINE_ID = Lines.column_value
	 AND   adj.QUOTE_LINE_ID IS NOT NULL
	 AND   adj.modifier_line_type_code = 'DIS';

	--We won't need this since in the second implicit call the only Adj record for free line
	--is the PRG related DIS record.
	 /*AND EXISTS ( SELECT null
			      FROM ASO_PRICE_ADJUSTMENTS adj2,
                          ASO_PRICE_ADJ_RELATIONSHIPS rlt
                     WHERE rlt.rltd_price_adj_id = adj.price_adjustment_id
                     AND   adj2.modifier_line_type_code = 'PRG'
                     AND   adj2.quote_header_id = adj.quote_header_id
                     AND   adj2.price_adjustment_id = rlt.price_adjustment_id));*/

   x_adj_id_tbl := l_adj_id_tbl;
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT: x_adj_id_tbl.count:'||nvl(x_adj_id_tbl.count,0),1,'Y');
   END IF;

END Query_price_Adj_line;

/*Query both header and line adjs*/
PROCEDURE Query_Price_Adjustments
(p_quote_header_id    IN  NUMBER,
 p_qte_line_id_tbl    IN  JTF_NUMBER_TABLE,
 x_adj_id_tbl         OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE)
IS
 l_adj_counter   NUMBER;
 l_rel_counter   NUMBER;
 l_adj_id_tbl    JTF_NUMBER_TABLE;

BEGIN
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of the Query_Price_Adjustments',1,'Y');
   END IF;
--bug8599987 changed to operand from 'AMT',(operand*l.quantity)/l.PRICING_QUANTITY
--bug8599987 changed to operand from 'NEWPRICE',(operand*l.quantity)/l.PRICING_QUANTITY)
 UPDATE ASO_PRICE_ADJUSTMENTS apa
 SET OPERAND_PER_PQTY = (SELECT decode(arithmetic_operator,'%',operand,
                                  'LUMPSUM',operand,
				   --'AMT',(operand*l.quantity)/l.PRICING_QUANTITY, -- bug 17517305
                                   --'NEWPRICE',(operand*l.quantity)/l.PRICING_QUANTITY)  -- bug 17517305
                                  -- 'AMT',operand, -- P1 bug 22170040
                                  -- 'NEWPRICE',operand)  -- P1 bug 22170040
								  'AMT',Decode(l.QUANTITY_UOM_CHANGE,'Y',operand,'N',(operand*l.quantity)/l.PRICING_QUANTITY),   -- added for Bug 22582573
                                  'NEWPRICE',Decode(l.QUANTITY_UOM_CHANGE,'Y',operand,'N',(operand*l.quantity)/l.PRICING_QUANTITY))  -- added for Bug 22582573
                          FROM  ASO_QUOTE_LINES_ALL l
                          WHERE l.quote_header_id = apa.quote_header_id
					 AND l.quote_line_id = apa.quote_line_id
                          )
 WHERE apa.quote_header_id = p_quote_header_id
 AND apa.quote_line_id is not null
 AND   (apa.applied_flag = 'Y' or apa.updated_flag = 'Y');
 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:Operand per pqty updated rows - Line level: '||sql%ROWCOUNT,1,'Y');
 END IF;

 --Only support % at the header level
 UPDATE ASO_PRICE_ADJUSTMENTS
 SET OPERAND_PER_PQTY = operand
 WHERE quote_header_id = p_quote_header_id
 AND quote_line_id is null
 AND (applied_flag = 'Y' OR updated_flag = 'Y');

 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:Operand per pqty updated rows - Header Level: '||sql%ROWCOUNT,1,'Y');
	If p_qte_line_id_tbl.count is not null then
	   For i in 1..p_qte_line_id_tbl.count loop
	    aso_debug_pub.add('ASO_PRICING_CORE_PVT:Querying for the following quote line ids:',1,'Y');
	    aso_debug_pub.add('ASO_PRICING_CORE_PVT:p_qte_line_id_tbl(i):'||p_qte_line_id_tbl(i),1,'Y');
	   End Loop;
	End If;
   END IF;

       SELECT
		 PRICE_ADJUSTMENT_ID,
                 mod(PRICE_ADJUSTMENT_ID, G_BINARY_LIMIT), --PRICE_ADJUSTMENT_ID, Bug  14311089
		 PRICE_ADJUSTMENT_ID,
           'NULL', --line_detail_type_code
           PRICE_BREAK_TYPE_CODE,
           NULL,
		 1,
           MODIFIER_HEADER_ID,
           MODIFIER_LINE_ID,
           MODIFIER_LINE_TYPE_CODE,
           NULL,--List type code that we do not store currently
           NULL,--Created from SQL
           PRICING_GROUP_SEQUENCE,
           PRICING_PHASE_ID,
           ARITHMETIC_OPERATOR,
		 nvl(OPERAND_PER_PQTY,OPERAND),
           NULL,--substitution_attribute
           MODIFIED_FROM,
           MODIFIED_TO,
           NULL,--ask_for_flag that we do not store currently
           NULL,--formula_id
           'X',--pricing_status_code
           NULL,--pricing_status_text
           NULL,--product_precedence
           NULL,--incompatibility_group
           'N',--processed_flag
           APPLIED_FLAG,
           AUTOMATIC_FLAG,
           UPDATE_ALLOWABLE_FLAG,
           NULL,--primary_uom_flag
           ON_INVOICE_FLAG,
           MODIFIER_LEVEL_CODE,
           BENEFIT_QTY,
           BENEFIT_UOM_CODE,
           LIST_LINE_NO,
           ACCRUAL_FLAG,
           ACCRUAL_CONVERSION_RATE,
           NULL,--estim_accrual_rate
           'N',--recurring_flag
           NULL,--selected_vol_attr
           NULL,--rounding_factor
           NULL,--hdr_limit_exist
           NULL,--Line_limit_exist
           CHARGE_TYPE_CODE,
           CHARGE_SUBTYPE_CODE,
           NULL,--currency_detail_id
           NULL,--currency_hdr_id
           NULL,--selling_round
           NULL,--order_currency
           NULL,--pricing_effect_date
           NULL,--base_currency
           RANGE_BREAK_QUANTITY,
           UPDATED_FLAG,
           MODIFIER_MECHANISM_TYPE_CODE,
           CHANGE_REASON_CODE,
           CHANGE_REASON_TEXT
	 BULK COLLECT INTO
		   l_adj_id_tbl,
             G_LDET_LINE_DTL_INDEX_TBL,
		   G_LDET_PRICE_ADJ_ID_TBL,
             G_LDET_LINE_DTL_TYPE_TBL,
             G_LDET_PRICE_BREAK_TYPE_TBL,
             G_LDET_LIST_PRICE_TBL,
             G_LDET_LINE_INDEX_TBL,
             G_LDET_LIST_HEADER_ID_TBL,
             G_LDET_LIST_LINE_ID_TBL,
             G_LDET_LIST_LINE_TYPE_TBL,
             G_LDET_LIST_TYPE_CODE_TBL,
             G_LDET_CREATED_FROM_SQL_TBL,
             G_LDET_PRICING_GRP_SEQ_TBL,
             G_LDET_PRICING_PHASE_ID_TBL,
             G_LDET_OPERAND_CALC_CODE_TBL,
             G_LDET_OPERAND_VALUE_TBL,
             G_LDET_SUBSTN_TYPE_TBL,
             G_LDET_SUBSTN_VALUE_FROM_TBL,
             G_LDET_SUBSTN_VALUE_TO_TBL,
             G_LDET_ASK_FOR_FLAG_TBL,
             G_LDET_PRICE_FORMULA_ID_TBL,
             G_LDET_PRICING_STATUS_CODE_TBL,
             G_LDET_PRICING_STATUS_TXT_TBL,
             G_LDET_PRODUCT_PRECEDENCE_TBL,
             G_LDET_INCOMPAT_GRP_CODE_TBL,
             G_LDET_PROCESSED_FLAG_TBL,
             G_LDET_APPLIED_FLAG_TBL,
             G_LDET_AUTOMATIC_FLAG_TBL,
             G_LDET_OVERRIDE_FLAG_TBL,
             G_LDET_PRIMARY_UOM_FLAG_TBL,
             G_LDET_PRINT_ON_INV_FLAG_TBL,
             G_LDET_MODIFIER_LEVEL_TBL,
             G_LDET_BENEFIT_QTY_TBL,
             G_LDET_BENEFIT_UOM_CODE_TBL,
             G_LDET_LIST_LINE_NO_TBL,
             G_LDET_ACCRUAL_FLAG_TBL,
             G_LDET_ACCR_CONV_RATE_TBL,
             G_LDET_ESTIM_ACCR_RATE_TBL,
             G_LDET_RECURRING_FLAG_TBL,
             G_LDET_SELECTED_VOL_ATTR_TBL,
             G_LDET_ROUNDING_FACTOR_TBL,
             G_LDET_HDR_LIMIT_EXISTS_TBL,
             G_LDET_LINE_LIMIT_EXISTS_TBL,
             G_LDET_CHARGE_TYPE_TBL,
             G_LDET_CHARGE_SUBTYPE_TBL,
             G_LDET_CURRENCY_DTL_ID_TBL,
             G_LDET_CURRENCY_HDR_ID_TBL,
             G_LDET_SELLING_ROUND_TBL,
             G_LDET_ORDER_CURRENCY_TBL,
             G_LDET_PRICING_EFF_DATE_TBL,
             G_LDET_BASE_CURRENCY_TBL,
             G_LDET_LINE_QUANTITY_TBL,
             G_LDET_UPDATED_FLAG_TBL,
             G_LDET_CALC_CODE_TBL,
             G_LDET_CHG_REASON_CODE_TBL,
             G_LDET_CHG_REASON_TEXT_TBL
      FROM ASO_PRICE_ADJUSTMENTS adj
      WHERE adj.QUOTE_HEADER_ID   = p_quote_header_id
      AND   NVL(adj.updated_flag,'N') = 'Y'
      AND   adj.QUOTE_LINE_ID IS NULL
	 AND   NVL(ASO_PRICING_INT.G_HEADER_REC.RECALCULATE_FLAG,'N') = 'N'
   UNION ALL
      SELECT
		 PRICE_ADJUSTMENT_ID,
                 mod(PRICE_ADJUSTMENT_ID, G_BINARY_LIMIT), -- PRICE_ADJUSTMENT_ID, bug 14311089
		 PRICE_ADJUSTMENT_ID,
           'NULL', --line_detail_type_code
           PRICE_BREAK_TYPE_CODE,
           NULL,
           quote_line_id,
           MODIFIER_HEADER_ID,
           MODIFIER_LINE_ID,
           MODIFIER_LINE_TYPE_CODE,
           NULL,--List type code that we do not store currently
           NULL,--Created from SQL
           PRICING_GROUP_SEQUENCE,
           PRICING_PHASE_ID,
           ARITHMETIC_OPERATOR,
		 nvl(OPERAND_PER_PQTY,OPERAND),
           NULL,--substitution_attribute
           MODIFIED_FROM,
           MODIFIED_TO,
           NULL,--ask_for_flag that we do not store currently
           NULL,--formula_id
           'X',--pricing_status_code
           NULL,--pricing_status_text
           NULL,--product_precedence
           NULL,--incompatibility_group
           'N',--processed_flag
           APPLIED_FLAG,
           AUTOMATIC_FLAG,
           UPDATE_ALLOWABLE_FLAG,
           NULL,--primary_uom_flag
           ON_INVOICE_FLAG,
           MODIFIER_LEVEL_CODE,
           BENEFIT_QTY,
           BENEFIT_UOM_CODE,
           LIST_LINE_NO,
           ACCRUAL_FLAG,
           ACCRUAL_CONVERSION_RATE,
           NULL,--estim_accrual_rate
           'N',--recurring_flag
           NULL,--selected_vol_attr
           NULL,--rounding_factor
           NULL,--hdr_limit_exist
           NULL,--Line_limit_exist
           CHARGE_TYPE_CODE,
           CHARGE_SUBTYPE_CODE,
           NULL,--currency_detail_id
           NULL,--currency_hdr_id
           NULL,--selling_round
           NULL,--order_currency
           NULL,--pricing_effect_date
           NULL,--base_currency
           RANGE_BREAK_QUANTITY,
           UPDATED_FLAG,
           MODIFIER_MECHANISM_TYPE_CODE,
           CHANGE_REASON_CODE,
           CHANGE_REASON_TEXT
      FROM ASO_PRICE_ADJUSTMENTS adj,
           TABLE (CAST(P_Qte_Line_id_tbl AS JTF_NUMBER_TABLE)) Lines
      WHERE adj.QUOTE_HEADER_ID   = p_quote_header_id
      AND   adj.QUOTE_LINE_ID = Lines.column_value
	 AND   adj.QUOTE_LINE_ID IS NOT NULL
      AND   (( NVL(adj.updated_flag,'N') = 'Y'
              AND   EXISTS ( SELECT null from ASO_QUOTE_LINES_ALL lines2
                   WHERE  lines2.quote_line_id = adj.quote_line_id
                   AND    nvl(lines2.RECALCULATE_FLAG,'N') = 'N' )
              AND   NVL(ASO_PRICING_INT.G_HEADER_REC.RECALCULATE_FLAG,'N') = 'N')
		    OR ( adj.modifier_line_type_code = 'PRG'
                 OR
                 ( adj.modifier_line_type_code = 'DIS' and exists ( select null from aso_price_adjustments adj2,
                                                                                   aso_price_adj_relationships rlt
                                                            where rlt.rltd_price_adj_id = adj.price_adjustment_id
                                                            and   adj2.modifier_line_type_code = 'PRG'
                                                            and   adj2.quote_header_id = adj.quote_header_id
                                                            and   adj2.price_adjustment_id = rlt.price_adjustment_id))));

   x_adj_id_tbl := l_adj_id_tbl;
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT: x_adj_id_tbl.count:'||nvl(x_adj_id_tbl.count,0),1,'Y');
   END IF;

END Query_price_Adjustments;

PROCEDURE Query_Relationships(p_qte_adj_id_tbl IN JTF_NUMBER_TABLE,
                              p_service_qte_line_id_tbl IN JTF_NUMBER_TABLE)
IS
BEGIN


IF  p_service_qte_line_id_tbl.exists(1) AND p_qte_adj_id_tbl.exists(1) THEN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CORE_PVT: Get both price adj rltship and service rltship',1,'Y');
END IF;
SELECT
     adj_rel.quote_line_id,
     mod(adj_rel.PRICE_ADJUSTMENT_ID, G_BINARY_LIMIT), --adj_rel.price_adjustment_id, bug 14311089
     decode(dbadj.modifier_line_type_code,QP_PREQ_GRP.G_PRICE_BREAK_TYPE,QP_PREQ_GRP.G_PBH_LINE,QP_PREQ_GRP.G_GENERATED_LINE),
     mod(adj_rel.rltd_price_adj_id, G_BINARY_LIMIT),-- adj_rel.rltd_price_adj_id,  bug 14311089
     dbadjrel.quote_line_id,
	dbadj.modifier_line_id,
	dbadjrel.modifier_line_id
BULK COLLECT INTO
     G_RLTD_LINE_INDEX_TBL,
     G_RLTD_LINE_DTL_INDEX_TBL,
     G_RLTD_RELATION_TYPE_CODE_TBL,
     G_RLTD_RLTD_LINE_DTL_IND_TBL,
     G_RLTD_RELATED_LINE_IND_TBL,
	G_RLTD_LST_LN_ID_DEF_TBL,
	G_RLTD_RLTD_LST_LN_ID_DEF_TBL
FROM  ASO_PRICE_ADJ_RELATIONSHIPS adj_rel,
      ASO_PRICE_ADJUSTMENTS dbadj,
	 ASO_PRICE_ADJUSTMENTS dbadjrel,
      TABLE (CAST(p_qte_adj_id_tbl AS JTF_NUMBER_TABLE)) adj
WHERE  dbadj.quote_header_id = ASO_PRICING_INT.G_HEADER_REC.quote_header_id
AND    dbadjrel.quote_header_id = ASO_PRICING_INT.G_HEADER_REC.quote_header_id
AND    adj_rel.price_adjustment_id = adj.column_value
AND    dbadj.price_adjustment_id = adj_rel.price_adjustment_id
AND    dbadjrel.price_adjustment_id = adj_rel.rltd_price_adj_id
AND    dbadj.modifier_line_type_code IN (QP_PREQ_GRP.G_PRICE_BREAK_TYPE,QP_PREQ_GRP.G_PROMO_GOODS_DISCOUNT)
UNION ALL
SELECT
     ldets.service_ref_line_id quote_line_id,
     0,
     QP_PREQ_GRP.G_SERVICE_LINE,
     0,
     ldets.quote_line_id related_quote_line_id,
	to_number(NULL),
     to_number(NULL)
FROM ASO_QUOTE_LINE_DETAILS ldets,
     TABLE (CAST(P_service_Qte_Line_id_tbl AS JTF_NUMBER_TABLE)) serviceLines,
     ASO_QUOTE_LINES_ALL lines
WHERE ldets.quote_line_id = serviceLines.column_value
AND   lines.quote_header_id = ASO_PRICING_INT.G_HEADER_REC.quote_header_id
AND   lines.quote_line_id = ldets.quote_line_id
AND   ldets.service_ref_line_id IS NOT NULL;

ELSIF  p_service_qte_line_id_tbl is not null and  p_service_qte_line_id_tbl.exists(1) then
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT: Get only service rltship',1,'Y');
  END IF;

  SELECT
     ldets.service_ref_line_id quote_line_id,
     0,
     QP_PREQ_GRP.G_SERVICE_LINE,
     0,
     ldets.quote_line_id related_quote_line_id,
     to_number(NULL),
     to_number(NULL)
  BULK COLLECT INTO
     G_RLTD_LINE_INDEX_TBL,
     G_RLTD_LINE_DTL_INDEX_TBL,
     G_RLTD_RELATION_TYPE_CODE_TBL,
     G_RLTD_RLTD_LINE_DTL_IND_TBL,
     G_RLTD_RELATED_LINE_IND_TBL,
     G_RLTD_LST_LN_ID_DEF_TBL,
     G_RLTD_RLTD_LST_LN_ID_DEF_TBL
  FROM ASO_QUOTE_LINE_DETAILS ldets,
     TABLE (CAST(P_service_Qte_Line_id_tbl AS JTF_NUMBER_TABLE)) serviceLines,
     ASO_QUOTE_LINES_ALL lines
  WHERE ldets.quote_line_id = serviceLines.column_value
  AND   lines.quote_header_id = ASO_PRICING_INT.G_HEADER_REC.quote_header_id
  AND   lines.quote_line_id = ldets.quote_line_id
  AND   ldets.service_ref_line_id IS NOT NULL;

ELSIF  p_qte_adj_id_tbl is not null and p_qte_adj_id_tbl.exists(1) THEN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CORE_PVT: Get only price adj rltship',1,'Y');
END IF;
SELECT
     adj_rel.quote_line_id,
      mod(adj_rel.PRICE_ADJUSTMENT_ID, G_BINARY_LIMIT), --adj_rel.price_adjustment_id, bug 14311089
     decode(dbadj.modifier_line_type_code,QP_PREQ_GRP.G_PRICE_BREAK_TYPE,QP_PREQ_GRP.G_PBH_LINE,QP_PREQ_GRP.G_GENERATED_LINE),
     mod(adj_rel.rltd_price_adj_id, G_BINARY_LIMIT), --adj_rel.rltd_price_adj_id, bug 14311089
     dbadjrel.quote_line_id,
	dbadj.modifier_line_id,
	dbadjrel.modifier_line_id
BULK COLLECT INTO
     G_RLTD_LINE_INDEX_TBL,
     G_RLTD_LINE_DTL_INDEX_TBL,
     G_RLTD_RELATION_TYPE_CODE_TBL,
     G_RLTD_RLTD_LINE_DTL_IND_TBL,
     G_RLTD_RELATED_LINE_IND_TBL,
	G_RLTD_LST_LN_ID_DEF_TBL,
	G_RLTD_RLTD_LST_LN_ID_DEF_TBL
FROM  ASO_PRICE_ADJ_RELATIONSHIPS adj_rel,
      ASO_PRICE_ADJUSTMENTS dbadj,
	 ASO_PRICE_ADJUSTMENTS dbadjrel,
      TABLE (CAST(p_qte_adj_id_tbl AS JTF_NUMBER_TABLE)) adj
WHERE  dbadj.quote_header_id = ASO_PRICING_INT.G_HEADER_REC.quote_header_id
AND    dbadjrel.quote_header_id = ASO_PRICING_INT.G_HEADER_REC.quote_header_id
AND    adj_rel.price_adjustment_id = adj.column_value
AND    dbadj.price_adjustment_id = adj_rel.price_adjustment_id
AND    dbadjrel.price_adjustment_id = adj_rel.rltd_price_adj_id
AND    dbadj.modifier_line_type_code IN (QP_PREQ_GRP.G_PRICE_BREAK_TYPE,QP_PREQ_GRP.G_PROMO_GOODS_DISCOUNT);

END IF;

END Query_relationships;

PROCEDURE Print_Global_Data_Lines
IS

BEGIN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('===================GLOBAL LINES==============================================',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LINE_INDEX_TBL.count:'
                     ||nvl(G_LINE_INDEX_TBL.count,0),1,'Y');
END IF;
If nvl(G_LINE_INDEX_TBL.count,0) > 0 then
For i in 1..G_LINE_INDEX_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LINE_INDEX_TBL('||i||'):'||G_LINE_INDEX_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LINE_TYPE_CODE_TBL.count:'
                     ||nvl(G_LINE_TYPE_CODE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LINE_INDEX_TBL.count,0) > 0 then
For i in 1..G_LINE_TYPE_CODE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LINE_TYPE_CODE_TBL('||i||'):'||G_LINE_TYPE_CODE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_PRICING_EFFECTIVE_DATE_TBL.count:'
                     ||nvl(G_PRICING_EFFECTIVE_DATE_TBL.count,0),1,'Y');
END IF;

If nvl(G_PRICING_EFFECTIVE_DATE_TBL.count,0) > 0 then
For i in 1..G_PRICING_EFFECTIVE_DATE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_PRICING_EFFECTIVE_DATE_TBL('||i||'):'||G_PRICING_EFFECTIVE_DATE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_ACTIVE_DATE_FIRST_TBL.count:'
                     ||nvl(G_ACTIVE_DATE_FIRST_TBL.count,0),1,'Y');
END IF;

If nvl(G_ACTIVE_DATE_FIRST_TBL.count,0) > 0 then
For i in 1..G_ACTIVE_DATE_FIRST_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_ACTIVE_DATE_FIRST_TBL('||i||'):'||G_ACTIVE_DATE_FIRST_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_ACTIVE_DATE_FIRST_TYPE_TBL.count:'
                     ||nvl(G_ACTIVE_DATE_FIRST_TYPE_TBL.count,0),1,'Y');
END IF;

If nvl(G_ACTIVE_DATE_FIRST_TYPE_TBL.count,0) > 0 then
For i in 1..G_ACTIVE_DATE_FIRST_TYPE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_ACTIVE_DATE_FIRST_TYPE_TBL('||i||'):'||G_ACTIVE_DATE_FIRST_TYPE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_ACTIVE_DATE_SECOND_TBL.count:'
                     ||nvl(G_ACTIVE_DATE_SECOND_TBL.count,0),1,'Y');
END IF;

If nvl(G_ACTIVE_DATE_SECOND_TBL.count,0) > 0 then
For i in 1..G_ACTIVE_DATE_SECOND_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_ACTIVE_DATE_SECOND_TBL('||i||'):'||G_ACTIVE_DATE_SECOND_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_ACTIVE_DATE_SECOND_TYPE_TBL.count:'
                     ||nvl(G_ACTIVE_DATE_SECOND_TYPE_TBL.count,0),1,'Y');
END IF;

If nvl(G_ACTIVE_DATE_SECOND_TYPE_TBL.count,0) > 0 then
For i in 1..G_ACTIVE_DATE_SECOND_TYPE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_ACTIVE_DATE_SECOND_TYPE_TBL('||i||'):'||G_ACTIVE_DATE_SECOND_TYPE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LINE_QUANTITY_TBL.count:'
                     ||nvl(G_LINE_QUANTITY_TBL.count,0),1,'Y');
END IF;

If nvl(G_LINE_QUANTITY_TBL.count,0) > 0 then
For i in 1..G_LINE_QUANTITY_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LINE_QUANTITY_TBL('||i||'):'||G_LINE_QUANTITY_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LINE_UOM_CODE_TBL.count:'
                     ||nvl(G_LINE_UOM_CODE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LINE_UOM_CODE_TBL.count,0) > 0 then
For i in 1..G_LINE_UOM_CODE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LINE_UOM_CODE_TBL('||i||'):'||G_LINE_UOM_CODE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_REQUEST_TYPE_CODE_TBL.count:'
                     ||nvl(G_REQUEST_TYPE_CODE_TBL.count,0),1,'Y');
END IF;

If nvl(G_REQUEST_TYPE_CODE_TBL.count,0) > 0 then
For i in 1..G_REQUEST_TYPE_CODE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_REQUEST_TYPE_CODE_TBL('||i||'):'||G_REQUEST_TYPE_CODE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_PRICED_QUANTITY_TBL.count:'
                     ||nvl(G_PRICED_QUANTITY_TBL.count,0),1,'Y');
END IF;

If nvl(G_PRICED_QUANTITY_TBL.count,0) > 0 then
For i in 1..G_PRICED_QUANTITY_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_PRICED_QUANTITY_TBL('||i||'):'||G_PRICED_QUANTITY_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_PRICED_UOM_CODE_TBL.count:'
                     ||nvl(G_PRICED_UOM_CODE_TBL.count,0),1,'Y');
END IF;

If nvl(G_PRICED_UOM_CODE_TBL.count,0) > 0 then
For i in 1..G_PRICED_UOM_CODE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_PRICED_UOM_CODE_TBL('||i||'):'||G_PRICED_UOM_CODE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_CURRENCY_CODE_TBL.count:'
                     ||nvl(G_CURRENCY_CODE_TBL.count,0),1,'Y');
END IF;

If nvl(G_CURRENCY_CODE_TBL.count,0) > 0 then
For i in 1..G_CURRENCY_CODE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_CURRENCY_CODE_TBL('||i||'):'||G_CURRENCY_CODE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_UNIT_PRICE_TBL.count:'
                     ||nvl(G_UNIT_PRICE_TBL.count,0),1,'Y');
END IF;

If nvl(G_UNIT_PRICE_TBL.count,0) > 0 then
For i in 1..G_UNIT_PRICE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_UNIT_PRICE_TBL('||i||'):'||G_UNIT_PRICE_TBL(i),1,'Y');
END IF;
end loop;
end if;

-- bug 20700246
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LINE_UNIT_PRICE_TBL.count:'
                     ||nvl(G_LINE_UNIT_PRICE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LINE_UNIT_PRICE_TBL.count,0) > 0 then
For i in 1..G_LINE_UNIT_PRICE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LINE_UNIT_PRICE_TBL('||i||'):'||G_LINE_UNIT_PRICE_TBL(i),1,'Y');
END IF;
end loop;
end if;
-- end bug 20700246

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_PERCENT_PRICE_TBL.count:'
                     ||nvl(G_PERCENT_PRICE_TBL.count,0),1,'Y');
END IF;

If nvl(G_PERCENT_PRICE_TBL.count,0) > 0 then
For i in 1..G_PERCENT_PRICE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_PERCENT_PRICE_TBL('||i||'):'||G_PERCENT_PRICE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_UOM_QUANTITY_TBL.count:'
                     ||nvl(G_UOM_QUANTITY_TBL.count,0),1,'Y');
END IF;

If nvl(G_UOM_QUANTITY_TBL.count,0) > 0 then
For i in 1..G_UOM_QUANTITY_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_UOM_QUANTITY_TBL('||i||'):'||G_UOM_QUANTITY_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_ADJUSTED_UNIT_PRICE_TBL.count:'
                     ||nvl(G_ADJUSTED_UNIT_PRICE_TBL.count,0),1,'Y');
END IF;

If nvl(G_ADJUSTED_UNIT_PRICE_TBL.count,0) > 0 then
For i in 1..G_ADJUSTED_UNIT_PRICE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_ADJUSTED_UNIT_PRICE_TBL('||i||'):'||G_ADJUSTED_UNIT_PRICE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_UPD_ADJUSTED_UNIT_PRICE_TBL.count:'
                     ||nvl(G_UPD_ADJUSTED_UNIT_PRICE_TBL.count,0),1,'Y');
END IF;

If nvl(G_UPD_ADJUSTED_UNIT_PRICE_TBL.count,0) > 0 then
For i in 1..G_UPD_ADJUSTED_UNIT_PRICE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_UPD_ADJUSTED_UNIT_PRICE_TBL('||i||'):'||G_UPD_ADJUSTED_UNIT_PRICE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_PROCESSED_FLAG_TBL.count:'
                     ||nvl(G_PROCESSED_FLAG_TBL.count,0),1,'Y');
END IF;

If nvl(G_PROCESSED_FLAG_TBL.count,0) > 0 then
For i in 1..G_PROCESSED_FLAG_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_PROCESSED_FLAG_TBL('||i||'):'||G_PROCESSED_FLAG_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_PRICE_FLAG_TBL.count:'
                     ||nvl(G_PRICE_FLAG_TBL.count,0),1,'Y');
END IF;

If nvl(G_PRICE_FLAG_TBL.count,0) > 0 then
For i in 1..G_PRICE_FLAG_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_PRICE_FLAG_TBL('||i||'):'||G_PRICE_FLAG_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LINE_ID_TBL.count:'
                     ||nvl(G_LINE_ID_TBL.count,0),1,'Y');
END IF;

If nvl(G_LINE_ID_TBL.count,0) > 0 then
For i in 1..G_LINE_ID_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LINE_ID_TBL('||i||'):'||G_LINE_ID_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_PROCESSING_ORDER_TBL.count:'
                     ||nvl(G_PROCESSING_ORDER_TBL.count,0),1,'Y');
END IF;

If nvl(G_PROCESSING_ORDER_TBL.count,0) > 0 then
For i in 1..G_PROCESSING_ORDER_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_PROCESSING_ORDER_TBL('||i||'):'||G_PROCESSING_ORDER_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_PRICING_STATUS_CODE_tbl.count:'
                     ||nvl(G_PRICING_STATUS_CODE_tbl.count,0),1,'Y');
END IF;

If nvl(G_PRICING_STATUS_CODE_tbl.count,0) > 0 then
For i in 1..G_PRICING_STATUS_CODE_tbl.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_PRICING_STATUS_CODE_tbl('||i||'):'||G_PRICING_STATUS_CODE_tbl(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_PRICING_STATUS_TEXT_tbl.count:'
                     ||nvl(G_PRICING_STATUS_TEXT_tbl.count,0),1,'Y');
END IF;

If nvl(G_PRICING_STATUS_TEXT_tbl.count,0) > 0 then
For i in 1..G_PRICING_STATUS_TEXT_tbl.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_PRICING_STATUS_TEXT_tbl('||i||'):'||G_PRICING_STATUS_TEXT_tbl(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_ROUNDING_FLAG_TBL.count:'
                     ||nvl(G_ROUNDING_FLAG_TBL.count,0),1,'Y');
END IF;

If nvl(G_ROUNDING_FLAG_TBL.count,0) > 0 then
For i in 1..G_ROUNDING_FLAG_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_ROUNDING_FLAG_TBL('||i||'):'||G_ROUNDING_FLAG_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_ROUNDING_FACTOR_TBL.count:'
                     ||nvl(G_ROUNDING_FACTOR_TBL.count,0),1,'Y');
END IF;

If nvl(G_ROUNDING_FACTOR_TBL.count,0) > 0 then
For i in 1..G_ROUNDING_FACTOR_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_ROUNDING_FACTOR_TBL('||i||'):'||G_ROUNDING_FACTOR_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_QUALIFIERS_EXIST_FLAG_TBL.count:'
                     ||nvl(G_QUALIFIERS_EXIST_FLAG_TBL.count,0),1,'Y');
END IF;

If nvl(G_QUALIFIERS_EXIST_FLAG_TBL.count,0) > 0 then
For i in 1..G_QUALIFIERS_EXIST_FLAG_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_QUALIFIERS_EXIST_FLAG_TBL('||i||'):'||G_QUALIFIERS_EXIST_FLAG_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_PRICING_ATTRS_EXIST_FLAG_TBL.count:'
                     ||nvl(G_PRICING_ATTRS_EXIST_FLAG_TBL.count,0),1,'Y');
END IF;

If nvl(G_PRICING_ATTRS_EXIST_FLAG_TBL.count,0) > 0 then
For i in 1..G_PRICING_ATTRS_EXIST_FLAG_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_PRICING_ATTRS_EXIST_FLAG_TBL('||i||'):'||G_PRICING_ATTRS_EXIST_FLAG_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_PRICE_LIST_ID_TBL.count:'
                     ||nvl(G_PRICE_LIST_ID_TBL.count,0),1,'Y');
END IF;

If nvl(G_PRICE_LIST_ID_TBL.count,0) > 0 then
For i in 1..G_PRICE_LIST_ID_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_PRICE_LIST_ID_TBL('||i||'):'||G_PRICE_LIST_ID_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_PL_VALIDATED_FLAG_TBL.count:'
                     ||nvl(G_PL_VALIDATED_FLAG_TBL.count,0),1,'Y');
END IF;

If nvl(G_PL_VALIDATED_FLAG_TBL.count,0) > 0 then
For i in 1..G_PL_VALIDATED_FLAG_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_PL_VALIDATED_FLAG_TBL('||i||'):'||G_PL_VALIDATED_FLAG_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_PRICE_REQUEST_CODE_TBL.count:'
                     ||nvl(G_PRICE_REQUEST_CODE_TBL.count,0),1,'Y');
END IF;

If nvl(G_PRICE_REQUEST_CODE_TBL.count,0) > 0 then
For i in 1..G_PRICE_REQUEST_CODE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_PRICE_REQUEST_CODE_TBL('||i||'):'||G_PRICE_REQUEST_CODE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_USAGE_PRICING_TYPE_tbl.count:'
                     ||nvl(G_USAGE_PRICING_TYPE_tbl.count,0),1,'Y');
END IF;

If nvl(G_USAGE_PRICING_TYPE_tbl.count,0) > 0 then
For i in 1..G_USAGE_PRICING_TYPE_tbl.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_USAGE_PRICING_TYPE_tbl('||i||'):'||G_USAGE_PRICING_TYPE_tbl(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LINE_CATEGORY_tbl.count:'
                     ||nvl(G_LINE_CATEGORY_tbl.count,0),1,'Y');
END IF;

If nvl(G_LINE_CATEGORY_tbl.count,0) > 0 then
For i in 1..G_LINE_CATEGORY_tbl.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LINE_CATEGORY_tbl('||i||'):'||G_LINE_CATEGORY_tbl(i),1,'Y');
END IF;
end loop;
end if;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_CHRG_PERIODICITY_CODE_TBL.count:'
                     ||nvl(G_CHRG_PERIODICITY_CODE_TBL.count,0),1,'Y');
END IF;

If nvl(G_CHRG_PERIODICITY_CODE_TBL.count,0) > 0 then
For i in 1..G_CHRG_PERIODICITY_CODE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_CHRG_PERIODICITY_CODE_TBL('||i||'):'||G_CHRG_PERIODICITY_CODE_TBL(i),1,'Y');
END IF;
end loop;
end if;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_CONTRACT_START_DATE_TBL.count:'
                     ||nvl(G_CONTRACT_START_DATE_TBL.count,0),1,'Y');
END IF;

If nvl(G_CONTRACT_START_DATE_TBL.count,0) > 0 then
For i in 1..G_CONTRACT_START_DATE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_CONTRACT_START_DATE_TBL('||i||'):'||G_CONTRACT_START_DATE_TBL(i),1,'Y');
END IF;
end loop;
end if;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_CONTRACT_END_DATE_TBL.count:'
                     ||nvl(G_CONTRACT_END_DATE_TBL.count,0),1,'Y');
END IF;

If nvl(G_CONTRACT_END_DATE_TBL.count,0) > 0 then
For i in 1..G_CONTRACT_END_DATE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_CONTRACT_END_DATE_TBL('||i||'):'||G_CONTRACT_END_DATE_TBL(i),1,'Y');
END IF;
end loop;
end if;


IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
END IF;

END Print_Global_Data_Lines;

PROCEDURE Print_Global_Data_Adjustments
IS
BEGIN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('-------------------GLOBAL ADJUSTMENTS---------------------------------------------',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_LINE_DTL_INDEX_TBL.count:'
                     ||nvl(G_LDET_LINE_DTL_INDEX_TBL.count,0),1,'Y');
END IF;
If nvl(G_LDET_LINE_DTL_INDEX_TBL.count,0) > 0 then
For i in 1..G_LDET_LINE_DTL_INDEX_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_LINE_DTL_INDEX_TBL('||i||'):'||G_LDET_LINE_DTL_INDEX_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_PRICE_ADJ_ID_TBL.count:'
                     ||nvl(G_LDET_PRICE_ADJ_ID_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_PRICE_ADJ_ID_TBL.count,0) > 0 then
For i in 1..G_LDET_PRICE_ADJ_ID_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_PRICE_ADJ_ID_TBL('||i||'):'||G_LDET_PRICE_ADJ_ID_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_LINE_DTL_TYPE_TBL.count:'
                     ||nvl(G_LDET_LINE_DTL_TYPE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_LINE_DTL_TYPE_TBL.count,0) > 0 then
For i in 1..G_LDET_LINE_DTL_TYPE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_LINE_DTL_TYPE_TBL('||i||'):'||G_LDET_LINE_DTL_TYPE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_PRICE_BREAK_TYPE_TBL.count:'
                     ||nvl(G_LDET_PRICE_BREAK_TYPE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_PRICE_BREAK_TYPE_TBL.count,0) > 0 then
For i in 1..G_LDET_PRICE_BREAK_TYPE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_PRICE_BREAK_TYPE_TBL('||i||'):'||G_LDET_PRICE_BREAK_TYPE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_LIST_PRICE_TBL.count:'
                     ||nvl(G_LDET_LIST_PRICE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_LIST_PRICE_TBL.count,0) > 0 then
For i in 1..G_LDET_LIST_PRICE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_LIST_PRICE_TBL('||i||'):'||G_LDET_LIST_PRICE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_LINE_INDEX_TBL.count:'
                     ||nvl(G_LDET_LINE_INDEX_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_LINE_INDEX_TBL.count,0) > 0 then
For i in 1..G_LDET_LINE_INDEX_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_LINE_INDEX_TBL('||i||'):'||G_LDET_LINE_INDEX_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_LIST_HEADER_ID_TBL.count:'
                     ||nvl(G_LDET_LIST_HEADER_ID_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_LIST_HEADER_ID_TBL.count,0) > 0 then
For i in 1..G_LDET_LIST_HEADER_ID_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_LIST_HEADER_ID_TBL('||i||'):'||G_LDET_LIST_HEADER_ID_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_LIST_LINE_ID_TBL.count:'
                     ||nvl(G_LDET_LIST_LINE_ID_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_LIST_LINE_ID_TBL.count,0) > 0 then
For i in 1..G_LDET_LIST_LINE_ID_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_LIST_LINE_ID_TBL('||i||'):'||G_LDET_LIST_LINE_ID_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_LIST_LINE_TYPE_TBL.count:'
                     ||nvl(G_LDET_LIST_LINE_TYPE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_LIST_LINE_TYPE_TBL.count,0) > 0 then
For i in 1..G_LDET_LIST_LINE_TYPE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_LIST_LINE_TYPE_TBL('||i||'):'||G_LDET_LIST_LINE_TYPE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_LIST_TYPE_CODE_TBL.count:'
                     ||nvl(G_LDET_LIST_TYPE_CODE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_LIST_TYPE_CODE_TBL.count,0) > 0 then
For i in 1..G_LDET_LIST_TYPE_CODE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_LIST_TYPE_CODE_TBL('||i||'):'||G_LDET_LIST_TYPE_CODE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_CREATED_FROM_SQL_TBL.count:'
                     ||nvl(G_LDET_CREATED_FROM_SQL_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_CREATED_FROM_SQL_TBL.count,0) > 0 then
For i in 1..G_LDET_CREATED_FROM_SQL_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_CREATED_FROM_SQL_TBL('||i||'):'||G_LDET_CREATED_FROM_SQL_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_PRICING_GRP_SEQ_TBL.count:'
                     ||nvl(G_LDET_PRICING_GRP_SEQ_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_PRICING_GRP_SEQ_TBL.count,0) > 0 then
For i in 1..G_LDET_PRICING_GRP_SEQ_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_PRICING_GRP_SEQ_TBL('||i||'):'||G_LDET_PRICING_GRP_SEQ_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_PRICING_PHASE_ID_TBL.count:'
                     ||nvl(G_LDET_PRICING_PHASE_ID_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_PRICING_PHASE_ID_TBL.count,0) > 0 then
For i in 1..G_LDET_PRICING_PHASE_ID_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_PRICING_PHASE_ID_TBL('||i||'):'||G_LDET_PRICING_PHASE_ID_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_OPERAND_CALC_CODE_TBL.count:'
                     ||nvl(G_LDET_OPERAND_CALC_CODE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_OPERAND_CALC_CODE_TBL.count,0) > 0 then
For i in 1..G_LDET_OPERAND_CALC_CODE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_OPERAND_CALC_CODE_TBL('||i||'):'||G_LDET_OPERAND_CALC_CODE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_OPERAND_VALUE_TBL.count:'
                     ||nvl(G_LDET_OPERAND_VALUE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_OPERAND_VALUE_TBL.count,0) > 0 then
For i in 1..G_LDET_OPERAND_VALUE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_OPERAND_VALUE_TBL('||i||'):'||G_LDET_OPERAND_VALUE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_SUBSTN_TYPE_TBL.count:'
                     ||nvl(G_LDET_SUBSTN_TYPE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_SUBSTN_TYPE_TBL.count,0) > 0 then
For i in 1..G_LDET_SUBSTN_TYPE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_SUBSTN_TYPE_TBL('||i||'):'||G_LDET_SUBSTN_TYPE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_SUBSTN_VALUE_FROM_TBL.count:'
                     ||nvl(G_LDET_SUBSTN_VALUE_FROM_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_SUBSTN_VALUE_FROM_TBL.count,0) > 0 then
For i in 1..G_LDET_SUBSTN_VALUE_FROM_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_SUBSTN_VALUE_FROM_TBL('||i||'):'||G_LDET_SUBSTN_VALUE_FROM_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_SUBSTN_VALUE_TO_TBL.count:'
                     ||nvl(G_LDET_SUBSTN_VALUE_TO_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_SUBSTN_VALUE_TO_TBL.count,0) > 0 then
For i in 1..G_LDET_SUBSTN_VALUE_TO_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_SUBSTN_VALUE_TO_TBL('||i||'):'||G_LDET_SUBSTN_VALUE_TO_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_ASK_FOR_FLAG_TBL.count:'
                     ||nvl(G_LDET_ASK_FOR_FLAG_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_ASK_FOR_FLAG_TBL.count,0) > 0 then
For i in 1..G_LDET_ASK_FOR_FLAG_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_ASK_FOR_FLAG_TBL('||i||'):'||G_LDET_ASK_FOR_FLAG_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_PRICE_FORMULA_ID_TBL.count:'
                     ||nvl(G_LDET_PRICE_FORMULA_ID_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_PRICE_FORMULA_ID_TBL.count,0) > 0 then
For i in 1..G_LDET_PRICE_FORMULA_ID_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_PRICE_FORMULA_ID_TBL('||i||'):'||G_LDET_PRICE_FORMULA_ID_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_PRICING_STATUS_CODE_TBL.count:'
                     ||nvl(G_LDET_PRICING_STATUS_CODE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_PRICING_STATUS_CODE_TBL.count,0) > 0 then
For i in 1..G_LDET_PRICING_STATUS_CODE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_PRICING_STATUS_CODE_TBL('||i||'):'||G_LDET_PRICING_STATUS_CODE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_PRICING_STATUS_TXT_TBL.count:'
                     ||nvl(G_LDET_PRICING_STATUS_TXT_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_PRICING_STATUS_TXT_TBL.count,0) > 0 then
For i in 1..G_LDET_PRICING_STATUS_TXT_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_PRICING_STATUS_TXT_TBL('||i||'):'||G_LDET_PRICING_STATUS_TXT_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_PRODUCT_PRECEDENCE_TBL.count:'
                     ||nvl(G_LDET_PRODUCT_PRECEDENCE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_PRODUCT_PRECEDENCE_TBL.count,0) > 0 then
For i in 1..G_LDET_PRODUCT_PRECEDENCE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_PRODUCT_PRECEDENCE_TBL('||i||'):'||G_LDET_PRODUCT_PRECEDENCE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_INCOMPAT_GRP_CODE_TBL.count:'
                     ||nvl(G_LDET_INCOMPAT_GRP_CODE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_INCOMPAT_GRP_CODE_TBL.count,0) > 0 then
For i in 1..G_LDET_INCOMPAT_GRP_CODE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_INCOMPAT_GRP_CODE_TBL('||i||'):'||G_LDET_INCOMPAT_GRP_CODE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_PROCESSED_FLAG_TBL.count:'
                     ||nvl(G_LDET_PROCESSED_FLAG_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_PROCESSED_FLAG_TBL.count,0) > 0 then
For i in 1..G_LDET_PROCESSED_FLAG_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_PROCESSED_FLAG_TBL('||i||'):'||G_LDET_PROCESSED_FLAG_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_APPLIED_FLAG_TBL.count:'
                     ||nvl(G_LDET_APPLIED_FLAG_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_APPLIED_FLAG_TBL.count,0) > 0 then
For i in 1..G_LDET_APPLIED_FLAG_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_APPLIED_FLAG_TBL('||i||'):'||G_LDET_APPLIED_FLAG_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_AUTOMATIC_FLAG_TBL.count:'
                     ||nvl(G_LDET_AUTOMATIC_FLAG_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_AUTOMATIC_FLAG_TBL.count,0) > 0 then
For i in 1..G_LDET_AUTOMATIC_FLAG_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_AUTOMATIC_FLAG_TBL('||i||'):'||G_LDET_AUTOMATIC_FLAG_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_OVERRIDE_FLAG_TBL.count:'
                     ||nvl(G_LDET_OVERRIDE_FLAG_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_OVERRIDE_FLAG_TBL.count,0) > 0 then
For i in 1..G_LDET_OVERRIDE_FLAG_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_OVERRIDE_FLAG_TBL('||i||'):'||G_LDET_OVERRIDE_FLAG_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_PRIMARY_UOM_FLAG_TBL.count:'
                     ||nvl(G_LDET_PRIMARY_UOM_FLAG_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_PRIMARY_UOM_FLAG_TBL.count,0) > 0 then
For i in 1..G_LDET_PRIMARY_UOM_FLAG_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_PRIMARY_UOM_FLAG_TBL('||i||'):'||G_LDET_PRIMARY_UOM_FLAG_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_PRINT_ON_INV_FLAG_TBL.count:'
                     ||nvl(G_LDET_PRINT_ON_INV_FLAG_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_PRINT_ON_INV_FLAG_TBL.count,0) > 0 then
For i in 1..G_LDET_PRINT_ON_INV_FLAG_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_PRINT_ON_INV_FLAG_TBL('||i||'):'||G_LDET_PRINT_ON_INV_FLAG_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_MODIFIER_LEVEL_TBL.count:'
                     ||nvl(G_LDET_MODIFIER_LEVEL_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_MODIFIER_LEVEL_TBL.count,0) > 0 then
For i in 1..G_LDET_MODIFIER_LEVEL_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_MODIFIER_LEVEL_TBL('||i||'):'||G_LDET_MODIFIER_LEVEL_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_BENEFIT_QTY_TBL.count:'
                     ||nvl(G_LDET_BENEFIT_QTY_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_BENEFIT_QTY_TBL.count,0) > 0 then
For i in 1..G_LDET_BENEFIT_QTY_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_BENEFIT_QTY_TBL('||i||'):'||G_LDET_BENEFIT_QTY_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_BENEFIT_UOM_CODE_TBL.count:'
                     ||nvl(G_LDET_BENEFIT_UOM_CODE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_BENEFIT_UOM_CODE_TBL.count,0) > 0 then
For i in 1..G_LDET_BENEFIT_UOM_CODE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_BENEFIT_UOM_CODE_TBL('||i||'):'||G_LDET_BENEFIT_UOM_CODE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_LIST_LINE_NO_TBL.count:'
                     ||nvl(G_LDET_LIST_LINE_NO_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_LIST_LINE_NO_TBL.count,0) > 0 then
For i in 1..G_LDET_LIST_LINE_NO_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_LIST_LINE_NO_TBL('||i||'):'||G_LDET_LIST_LINE_NO_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_ACCRUAL_FLAG_TBL.count:'
                     ||nvl(G_LDET_ACCRUAL_FLAG_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_ACCRUAL_FLAG_TBL.count,0) > 0 then
For i in 1..G_LDET_ACCRUAL_FLAG_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_ACCRUAL_FLAG_TBL('||i||'):'||G_LDET_ACCRUAL_FLAG_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_ACCR_CONV_RATE_TBL.count:'
                     ||nvl(G_LDET_ACCR_CONV_RATE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_ACCR_CONV_RATE_TBL.count,0) > 0 then
For i in 1..G_LDET_ACCR_CONV_RATE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_ACCR_CONV_RATE_TBL('||i||'):'||G_LDET_ACCR_CONV_RATE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_ESTIM_ACCR_RATE_TBL.count:'
                     ||nvl(G_LDET_ESTIM_ACCR_RATE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_ESTIM_ACCR_RATE_TBL.count,0) > 0 then
For i in 1..G_LDET_ESTIM_ACCR_RATE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_ESTIM_ACCR_RATE_TBL('||i||'):'||G_LDET_ESTIM_ACCR_RATE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_RECURRING_FLAG_TBL.count:'
                     ||nvl(G_LDET_RECURRING_FLAG_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_RECURRING_FLAG_TBL.count,0) > 0 then
For i in 1..G_LDET_RECURRING_FLAG_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_RECURRING_FLAG_TBL('||i||'):'||G_LDET_RECURRING_FLAG_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_SELECTED_VOL_ATTR_TBL.count:'
                     ||nvl(G_LDET_SELECTED_VOL_ATTR_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_SELECTED_VOL_ATTR_TBL.count,0) > 0 then
For i in 1..G_LDET_SELECTED_VOL_ATTR_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_SELECTED_VOL_ATTR_TBL('||i||'):'||G_LDET_SELECTED_VOL_ATTR_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_ROUNDING_FACTOR_TBL.count:'
                     ||nvl(G_LDET_ROUNDING_FACTOR_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_ROUNDING_FACTOR_TBL.count,0) > 0 then
For i in 1..G_LDET_ROUNDING_FACTOR_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_ROUNDING_FACTOR_TBL('||i||'):'||G_LDET_ROUNDING_FACTOR_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_HDR_LIMIT_EXISTS_TBL.count:'
                     ||nvl(G_LDET_HDR_LIMIT_EXISTS_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_HDR_LIMIT_EXISTS_TBL.count,0) > 0 then
For i in 1..G_LDET_HDR_LIMIT_EXISTS_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_HDR_LIMIT_EXISTS_TBL('||i||'):'||G_LDET_HDR_LIMIT_EXISTS_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_LINE_LIMIT_EXISTS_TBL.count:'
                     ||nvl(G_LDET_LINE_LIMIT_EXISTS_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_LINE_LIMIT_EXISTS_TBL.count,0) > 0 then
For i in 1..G_LDET_LINE_LIMIT_EXISTS_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_LINE_LIMIT_EXISTS_TBL('||i||'):'||G_LDET_LINE_LIMIT_EXISTS_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_CHARGE_TYPE_TBL.count:'
                     ||nvl(G_LDET_CHARGE_TYPE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_CHARGE_TYPE_TBL.count,0) > 0 then
For i in 1..G_LDET_CHARGE_TYPE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_CHARGE_TYPE_TBL('||i||'):'||G_LDET_CHARGE_TYPE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_CHARGE_SUBTYPE_TBL.count:'
                     ||nvl(G_LDET_CHARGE_SUBTYPE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_CHARGE_SUBTYPE_TBL.count,0) > 0 then
For i in 1..G_LDET_CHARGE_SUBTYPE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_CHARGE_SUBTYPE_TBL('||i||'):'||G_LDET_CHARGE_SUBTYPE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_CURRENCY_DTL_ID_TBL.count:'
                     ||nvl(G_LDET_CURRENCY_DTL_ID_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_CURRENCY_DTL_ID_TBL.count,0) > 0 then
For i in 1..G_LDET_CURRENCY_DTL_ID_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_CURRENCY_DTL_ID_TBL('||i||'):'||G_LDET_CURRENCY_DTL_ID_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_CURRENCY_HDR_ID_TBL.count:'
                     ||nvl(G_LDET_CURRENCY_HDR_ID_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_CURRENCY_HDR_ID_TBL.count,0) > 0 then
For i in 1..G_LDET_CURRENCY_HDR_ID_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_CURRENCY_HDR_ID_TBL('||i||'):'||G_LDET_CURRENCY_HDR_ID_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_SELLING_ROUND_TBL.count:'
                     ||nvl(G_LDET_SELLING_ROUND_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_SELLING_ROUND_TBL.count,0) > 0 then
For i in 1..G_LDET_SELLING_ROUND_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_SELLING_ROUND_TBL('||i||'):'||G_LDET_SELLING_ROUND_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_ORDER_CURRENCY_TBL.count:'
                     ||nvl(G_LDET_ORDER_CURRENCY_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_ORDER_CURRENCY_TBL.count,0) > 0 then
For i in 1..G_LDET_ORDER_CURRENCY_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_ORDER_CURRENCY_TBL('||i||'):'||G_LDET_ORDER_CURRENCY_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_PRICING_EFF_DATE_TBL.count:'
                     ||nvl(G_LDET_PRICING_EFF_DATE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_PRICING_EFF_DATE_TBL.count,0) > 0 then
For i in 1..G_LDET_PRICING_EFF_DATE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_PRICING_EFF_DATE_TBL('||i||'):'||G_LDET_PRICING_EFF_DATE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_BASE_CURRENCY_TBL.count:'
                     ||nvl(G_LDET_BASE_CURRENCY_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_BASE_CURRENCY_TBL.count,0) > 0 then
For i in 1..G_LDET_BASE_CURRENCY_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_BASE_CURRENCY_TBL('||i||'):'||G_LDET_BASE_CURRENCY_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_LINE_QUANTITY_TBL.count:'
                     ||nvl(G_LDET_LINE_QUANTITY_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_LINE_QUANTITY_TBL.count,0) > 0 then
For i in 1..G_LDET_LINE_QUANTITY_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_LINE_QUANTITY_TBL('||i||'):'||G_LDET_LINE_QUANTITY_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_UPDATED_FLAG_TBL.count:'
                     ||nvl(G_LDET_UPDATED_FLAG_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_UPDATED_FLAG_TBL.count,0) > 0 then
For i in 1..G_LDET_UPDATED_FLAG_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_UPDATED_FLAG_TBL('||i||'):'||G_LDET_UPDATED_FLAG_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_CALC_CODE_TBL.count:'
                     ||nvl(G_LDET_CALC_CODE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_CALC_CODE_TBL.count,0) > 0 then
For i in 1..G_LDET_CALC_CODE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_CALC_CODE_TBL('||i||'):'||G_LDET_CALC_CODE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_CHG_REASON_CODE_TBL.count:'
                     ||nvl(G_LDET_CHG_REASON_CODE_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_CHG_REASON_CODE_TBL.count,0) > 0 then
For i in 1..G_LDET_CHG_REASON_CODE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_CHG_REASON_CODE_TBL('||i||'):'||G_LDET_CHG_REASON_CODE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_LDET_CHG_REASON_TEXT_TBL.count:'
                     ||nvl(G_LDET_CHG_REASON_TEXT_TBL.count,0),1,'Y');
END IF;

If nvl(G_LDET_CHG_REASON_TEXT_TBL.count,0) > 0 then
For i in 1..G_LDET_CHG_REASON_TEXT_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_LDET_CHG_REASON_TEXT_TBL('||i||'):'||G_LDET_CHG_REASON_TEXT_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
END IF;

END Print_Global_Data_Adjustments;

Procedure Print_Global_Data_Rltships
IS
BEGIN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('**********Global Relationships*****************************************',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_RLTD_LINE_INDEX_TBL.count:'
                     ||nvl(G_RLTD_LINE_INDEX_TBL.count,0),1,'Y');
END IF;
If nvl(G_RLTD_LINE_INDEX_TBL.count,0) > 0 then
For i in 1..G_RLTD_LINE_INDEX_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_RLTD_LINE_INDEX_TBL('||i||'):'||G_RLTD_LINE_INDEX_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_RLTD_LINE_DTL_INDEX_TBL.count:'
                     ||nvl(G_RLTD_LINE_DTL_INDEX_TBL.count,0),1,'Y');
END IF;

If nvl(G_RLTD_LINE_DTL_INDEX_TBL.count,0) > 0 then
For i in 1..G_RLTD_LINE_DTL_INDEX_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_RLTD_LINE_DTL_INDEX_TBL('||i||'):'||G_RLTD_LINE_DTL_INDEX_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_RLTD_RELATION_TYPE_CODE_TBL.count:'
                     ||nvl(G_RLTD_RELATION_TYPE_CODE_TBL.count,0),1,'Y');
END IF;


If nvl(G_RLTD_RELATION_TYPE_CODE_TBL.count,0) > 0 then
For i in 1..G_RLTD_RELATION_TYPE_CODE_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_RLTD_RELATION_TYPE_CODE_TBL('||i||'):'||G_RLTD_RELATION_TYPE_CODE_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_RLTD_RELATED_LINE_IND_TBL.count:'
                     ||nvl(G_RLTD_RELATED_LINE_IND_TBL.count,0),1,'Y');
END IF;

If nvl(G_RLTD_RELATED_LINE_IND_TBL.count,0) > 0 then
For i in 1..G_RLTD_RELATED_LINE_IND_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_RLTD_RELATED_LINE_IND_TBL('||i||'):'||G_RLTD_RELATED_LINE_IND_TBL(i),1,'Y');
END IF;
end loop;
end if;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_RLTD_RLTD_LINE_DTL_IND_TBL.count:'
                     ||nvl(G_RLTD_RLTD_LINE_DTL_IND_TBL.count,0),1,'Y');
END IF;

If nvl(G_RLTD_RLTD_LINE_DTL_IND_TBL.count,0) > 0 then
For i in 1..G_RLTD_RLTD_LINE_DTL_IND_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_RLTD_RLTD_LINE_DTL_IND_TBL('||i||'):'||G_RLTD_RLTD_LINE_DTL_IND_TBL(i),1,'Y');
END IF;
end loop;
end if;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_RLTD_LST_LN_ID_DEF_TBL.count:'
                     ||nvl(G_RLTD_LST_LN_ID_DEF_TBL.count,0),1,'Y');
END IF;

If nvl(G_RLTD_LST_LN_ID_DEF_TBL.count,0) > 0 then
For i in 1..G_RLTD_LST_LN_ID_DEF_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_RLTD_LST_LN_ID_DEF_TBL('||i||'):'||G_RLTD_LST_LN_ID_DEF_TBL(i),1,'Y');
END IF;
end loop;
end if;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:b4 insert temp table:G_RLTD_RLTD_LST_LN_ID_DEF_TBL.count:'
                     ||nvl(G_RLTD_RLTD_LST_LN_ID_DEF_TBL.count,0),1,'Y');
END IF;

If nvl(G_RLTD_RLTD_LST_LN_ID_DEF_TBL.count,0) > 0 then
For i in 1..G_RLTD_RLTD_LST_LN_ID_DEF_TBL.count loop
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('G_RLTD_RLTD_LST_LN_ID_DEF_TBL('||i||'):'||G_RLTD_RLTD_LST_LN_ID_DEF_TBL(i),1,'Y');
END IF;
end loop;
end if;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('  ',1,'Y');
END IF;
END Print_Global_Data_Rltships;

PROCEDURE Populate_QP_Temp_Tables
IS
l_return_status          varchar2(1) := FND_API.G_RET_STS_SUCCESS;
l_return_status_text     varchar2(240) ;
i NUMBER;

BEGIN

Print_Global_Data_Lines;

QP_PREQ_GRP.INSERT_LINES2
                (p_LINE_INDEX               =>G_LINE_INDEX_TBL,
                 p_LINE_TYPE_CODE           =>G_LINE_TYPE_CODE_TBL,
                 p_PRICING_EFFECTIVE_DATE   =>G_PRICING_EFFECTIVE_DATE_TBL,
                 p_ACTIVE_DATE_FIRST        =>G_ACTIVE_DATE_FIRST_TBL,
                 p_ACTIVE_DATE_FIRST_TYPE   =>G_ACTIVE_DATE_FIRST_TYPE_TBL,
                 p_ACTIVE_DATE_SECOND       =>G_ACTIVE_DATE_SECOND_TBL,
                 p_ACTIVE_DATE_SECOND_TYPE  =>G_ACTIVE_DATE_SECOND_TYPE_TBL,
                 p_LINE_QUANTITY            =>G_LINE_QUANTITY_TBL,
                 p_LINE_UOM_CODE            =>G_LINE_UOM_CODE_TBL,
                 p_REQUEST_TYPE_CODE        =>G_REQUEST_TYPE_CODE_TBL,
                 p_PRICED_QUANTITY          =>G_PRICED_QUANTITY_TBL,
                 p_PRICED_UOM_CODE          =>G_PRICED_UOM_CODE_TBL,
                 p_CURRENCY_CODE            =>G_CURRENCY_CODE_TBL,
                 p_UNIT_PRICE               =>G_UNIT_PRICE_TBL,
		 p_LINE_UNIT_PRICE          =>G_LINE_UNIT_PRICE_TBL,  -- bug 20700246 , commented for Bug 19243138
                 p_PERCENT_PRICE            =>G_PERCENT_PRICE_TBL,
                 p_UOM_QUANTITY             =>G_UOM_QUANTITY_TBL,
                 p_ADJUSTED_UNIT_PRICE      =>G_ADJUSTED_UNIT_PRICE_TBL,
                 p_UPD_ADJUSTED_UNIT_PRICE  =>G_UPD_ADJUSTED_UNIT_PRICE_TBL,
                 p_PROCESSED_FLAG           =>G_PROCESSED_FLAG_TBL,
                 p_PRICE_FLAG               =>G_PRICE_FLAG_TBL,
                 p_LINE_ID                  =>G_LINE_ID_TBL,
                 p_PROCESSING_ORDER         =>G_PROCESSING_ORDER_TBL,
                 p_PRICING_STATUS_CODE      =>G_PRICING_STATUS_CODE_tbl,
                 p_PRICING_STATUS_TEXT      =>G_PRICING_STATUS_TEXT_tbl,
                 p_ROUNDING_FLAG            =>G_ROUNDING_FLAG_TBL,
                 p_ROUNDING_FACTOR          =>G_ROUNDING_FACTOR_TBL,
                 p_QUALIFIERS_EXIST_FLAG    =>G_QUALIFIERS_EXIST_FLAG_TBL,
                 p_PRICING_ATTRS_EXIST_FLAG =>G_PRICING_ATTRS_EXIST_FLAG_TBL,
                 p_PRICE_LIST_ID            =>G_PRICE_LIST_ID_TBL,
                 p_VALIDATED_FLAG           =>G_PL_VALIDATED_FLAG_TBL,
                 p_PRICE_REQUEST_CODE       =>G_PRICE_REQUEST_CODE_TBL,
                 p_USAGE_PRICING_TYPE       =>G_USAGE_PRICING_TYPE_tbl,
                 p_line_category            =>G_LINE_CATEGORY_tbl,
			  p_charge_periodicity_code  =>G_CHRG_PERIODICITY_CODE_TBL,
                 /* Changes Made for OKS uptake bug 4900084  */
			  p_CONTRACT_START_DATE      =>G_CONTRACT_START_DATE_TBL,
			  p_CONTRACT_END_DATE        =>G_CONTRACT_END_DATE_TBL,
                 x_status_code              =>l_return_status,
                 x_status_text              =>l_return_status_text);

IF l_return_status = FND_API.G_RET_STS_ERROR THEN
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:Error in insert_lines2',1,'Y');
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_return_status_text:'||l_return_status_text,1,'Y');
   END IF;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF G_ATTR_LINE_INDEX_tbl.count > 0 THEN
QP_PREQ_GRP.INSERT_LINE_ATTRS2
   (    p_LINE_INDEX_tbl                => G_ATTR_LINE_INDEX_tbl,
        p_LINE_DETAIL_INDEX_tbl         => G_ATTR_LINE_DETAIL_INDEX_tbl,
        p_ATTRIBUTE_LEVEL_tbl           => G_ATTR_ATTRIBUTE_LEVEL_tbl,
        p_ATTRIBUTE_TYPE_tbl            => G_ATTR_ATTRIBUTE_TYPE_tbl,
        p_LIST_HEADER_ID_tbl            => G_ATTR_LIST_HEADER_ID_tbl,
        p_LIST_LINE_ID_tbl              => G_ATTR_LIST_LINE_ID_tbl,
        p_CONTEXT_tbl                   => G_ATTR_PRICING_CONTEXT_tbl,
        p_ATTRIBUTE_tbl                 => G_ATTR_PRICING_ATTRIBUTE_tbl,
        p_VALUE_FROM_tbl                => G_ATTR_VALUE_FROM_tbl,
        p_SETUP_VALUE_FROM_tbl          => G_ATTR_SETUP_VALUE_FROM_tbl,
        p_VALUE_TO_tbl                  => G_ATTR_VALUE_TO_tbl,
        p_SETUP_VALUE_TO_tbl            => G_ATTR_SETUP_VALUE_TO_tbl,
        p_GROUPING_NUMBER_tbl           => G_ATTR_GROUPING_NUMBER_tbl,
        p_NO_QUALIFIERS_IN_GRP_tbl      => G_ATTR_NO_QUAL_IN_GRP_tbl,
        p_COMPARISON_OPERATOR_TYPE_tbl  => G_ATTR_COMP_OPERATOR_TYPE_tbl,
        p_VALIDATED_FLAG_tbl            => G_ATTR_VALIDATED_FLAG_tbl,
        p_APPLIED_FLAG_tbl              => G_ATTR_APPLIED_FLAG_tbl,
        p_PRICING_STATUS_CODE_tbl       => G_ATTR_PRICING_STATUS_CODE_tbl,
        p_PRICING_STATUS_TEXT_tbl       => G_ATTR_PRICING_STATUS_TEXT_tbl,
        p_QUALIFIER_PRECEDENCE_tbl      => G_ATTR_QUAL_PRECEDENCE_tbl,
        p_DATATYPE_tbl                  => G_ATTR_DATATYPE_tbl,
        p_PRICING_ATTR_FLAG_tbl         => G_ATTR_PRICING_ATTR_FLAG_tbl,
        p_QUALIFIER_TYPE_tbl            => G_ATTR_QUALIFIER_TYPE_tbl,
        p_PRODUCT_UOM_CODE_TBL          => G_ATTR_PRODUCT_UOM_CODE_TBL,
        p_EXCLUDER_FLAG_TBL             => G_ATTR_EXCLUDER_FLAG_TBL,
        p_PRICING_PHASE_ID_TBL          => G_ATTR_PRICING_PHASE_ID_TBL,
        p_INCOMPATABILITY_GRP_CODE_TBL  => G_ATTR_INCOM_GRP_CODE_TBL,
        p_LINE_DETAIL_TYPE_CODE_TBL     => G_ATTR_LDET_TYPE_CODE_TBL,
        p_MODIFIER_LEVEL_CODE_TBL       => G_ATTR_MODIFIER_LEVEL_CODE_TBL,
        p_PRIMARY_UOM_FLAG_TBL          => G_ATTR_PRIMARY_UOM_FLAG_TBL,
        x_status_code                   => l_return_status,
        x_status_text                   => l_return_status_text );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('ASO_PRICING_CORE_PVT:Error inserting into line attrs'||sqlerrm,1,'Y');
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

END IF;

Print_Global_Data_Adjustments;

IF (G_LDET_LINE_DTL_INDEX_TBL.COUNT > 0) THEN
QP_PREQ_GRP.INSERT_LDETS2
  (p_LINE_DETAIL_INDEX             => G_LDET_LINE_DTL_INDEX_TBL,
   p_LINE_DETAIL_TYPE_CODE         => G_LDET_LINE_DTL_TYPE_TBL,
   p_PRICE_BREAK_TYPE_CODE         => G_LDET_PRICE_BREAK_TYPE_TBL,
   p_LIST_PRICE                    => G_LDET_LIST_PRICE_TBL,
   p_LINE_INDEX                    => G_LDET_LINE_INDEX_TBL,
   p_CREATED_FROM_LIST_HEADER_ID   => G_LDET_LIST_HEADER_ID_TBL,
   p_CREATED_FROM_LIST_LINE_ID     => G_LDET_LIST_LINE_ID_TBL,
   p_CREATED_FROM_LIST_LINE_TYPE   => G_LDET_LIST_LINE_TYPE_TBL,
   p_CREATED_FROM_LIST_TYPE_CODE   => G_LDET_LIST_TYPE_CODE_TBL,
   p_CREATED_FROM_SQL              => G_LDET_CREATED_FROM_SQL_TBL,
   p_PRICING_GROUP_SEQUENCE        => G_LDET_PRICING_GRP_SEQ_TBL,
   p_PRICING_PHASE_ID              => G_LDET_PRICING_PHASE_ID_TBL,
   p_OPERAND_CALCULATION_CODE      => G_LDET_OPERAND_CALC_CODE_TBL,
   p_OPERAND_VALUE                 => G_LDET_OPERAND_VALUE_TBL,
   p_SUBSTITUTION_TYPE_CODE        => G_LDET_SUBSTN_TYPE_TBL,
   p_SUBSTITUTION_VALUE_FROM       => G_LDET_SUBSTN_VALUE_FROM_TBL,
   p_SUBSTITUTION_VALUE_TO         => G_LDET_SUBSTN_VALUE_TO_TBL,
   p_ASK_FOR_FLAG                  => G_LDET_ASK_FOR_FLAG_TBL,
   p_PRICE_FORMULA_ID              => G_LDET_PRICE_FORMULA_ID_TBL,
   p_PRICING_STATUS_CODE           => G_LDET_PRICING_STATUS_CODE_TBL,
   p_PRICING_STATUS_TEXT           => G_LDET_PRICING_STATUS_TXT_TBL,
   p_PRODUCT_PRECEDENCE            => G_LDET_PRODUCT_PRECEDENCE_TBL,
   p_INCOMPATABLILITY_GRP_CODE     => G_LDET_INCOMPAT_GRP_CODE_TBL,
   p_PROCESSED_FLAG                => G_LDET_PROCESSED_FLAG_TBL,
   p_APPLIED_FLAG                  => G_LDET_APPLIED_FLAG_TBL,
   p_AUTOMATIC_FLAG                => G_LDET_AUTOMATIC_FLAG_TBL,
   p_OVERRIDE_FLAG                 => G_LDET_OVERRIDE_FLAG_TBL,
   p_PRIMARY_UOM_FLAG              => G_LDET_PRIMARY_UOM_FLAG_TBL,
   p_PRINT_ON_INVOICE_FLAG         => G_LDET_PRINT_ON_INV_FLAG_TBL,
   p_MODIFIER_LEVEL_CODE           => G_LDET_MODIFIER_LEVEL_TBL,
   p_BENEFIT_QTY                   => G_LDET_BENEFIT_QTY_TBL,
   p_BENEFIT_UOM_CODE              => G_LDET_BENEFIT_UOM_CODE_TBL,
   p_LIST_LINE_NO                  => G_LDET_LIST_LINE_NO_TBL,
   p_ACCRUAL_FLAG                  => G_LDET_ACCRUAL_FLAG_TBL,
   p_ACCRUAL_CONVERSION_RATE       => G_LDET_ACCR_CONV_RATE_TBL,
   p_ESTIM_ACCRUAL_RATE            => G_LDET_ESTIM_ACCR_RATE_TBL,
   p_RECURRING_FLAG                => G_LDET_RECURRING_FLAG_TBL,
   p_SELECTED_VOLUME_ATTR          => G_LDET_SELECTED_VOL_ATTR_TBL,
   p_ROUNDING_FACTOR               => G_LDET_ROUNDING_FACTOR_TBL,
   p_HEADER_LIMIT_EXISTS           => G_LDET_HDR_LIMIT_EXISTS_TBL,
   p_LINE_LIMIT_EXISTS             => G_LDET_LINE_LIMIT_EXISTS_TBL,
   p_CHARGE_TYPE_CODE              => G_LDET_CHARGE_TYPE_TBL,
   p_CHARGE_SUBTYPE_CODE           => G_LDET_CHARGE_SUBTYPE_TBL,
   p_CURRENCY_DETAIL_ID            => G_LDET_CURRENCY_DTL_ID_TBL,
   p_CURRENCY_HEADER_ID            => G_LDET_CURRENCY_HDR_ID_TBL,
   p_SELLING_ROUNDING_FACTOR       => G_LDET_SELLING_ROUND_TBL,
   p_ORDER_CURRENCY                => G_LDET_ORDER_CURRENCY_TBL,
   p_PRICING_EFFECTIVE_DATE        => G_LDET_PRICING_EFF_DATE_TBL,
   p_BASE_CURRENCY_CODE            => G_LDET_BASE_CURRENCY_TBL,
   p_LINE_QUANTITY                 => G_LDET_LINE_QUANTITY_TBL,
   p_UPDATED_FLAG                  => G_LDET_UPDATED_FLAG_TBL,
   p_CALCULATION_CODE              => G_LDET_CALC_CODE_TBL,
   p_CHANGE_REASON_CODE            => G_LDET_CHG_REASON_CODE_TBL,
   p_CHANGE_REASON_TEXT            => G_LDET_CHG_REASON_TEXT_TBL,
   p_PRICE_ADJUSTMENT_ID           => G_LDET_PRICE_ADJ_ID_TBL,
   x_status_code                   => l_return_status,
   x_status_text                   => l_return_status_text);

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_CORE_PVT:Error inserting into adj ldets'||sqlerrm,1,'Y');
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

END IF;--G_LDET_LINE_DTL_INDEX_TBL

Print_Global_Data_Rltships;

IF (G_RLTD_LINE_INDEX_TBL.COUNT > 0)
THEN
  QP_PREQ_GRP.INSERT_RLTD_LINES2 (
    p_LINE_INDEX                => G_RLTD_LINE_INDEX_TBL,
    p_LINE_DETAIL_INDEX         => G_RLTD_LINE_DTL_INDEX_TBL,
    p_RELATIONSHIP_TYPE_CODE    => G_RLTD_RELATION_TYPE_CODE_TBL,
    p_RELATED_LINE_INDEX        => G_RLTD_RELATED_LINE_IND_TBL,
    p_RELATED_LINE_DETAIL_INDEX => G_RLTD_RLTD_LINE_DTL_IND_TBL,
    p_LIST_LINE_ID              => G_RLTD_LST_LN_ID_DEF_TBL,
    p_RELATED_LIST_LINE_ID      => G_RLTD_RLTD_LST_LN_ID_DEF_TBL,
    x_status_code               => l_return_status,
    x_status_text               => l_return_status_text);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CORE_PVT:Error inserting into adj relationship'||sqlerrm,1,'Y');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

END IF;--G_RLTD_LINE_INDEX_TBL

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT: After direct insert into temp table: bulk insert',1,'Y');
    END IF;

EXCEPTION
WHEN OTHERS THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Populate_QP_Temp_Tables;


PROCEDURE Delete_Promotion (
                           P_Api_Version_Number IN   NUMBER,
                           P_Init_Msg_List      IN   VARCHAR2  := FND_API.G_FALSE,
                           P_Commit             IN   VARCHAR2  := FND_API.G_FALSE,
                           p_price_attr_tbl     IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
                           x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                           x_msg_count          OUT NOCOPY /* file.sql.39 change */ NUMBER,
                           x_msg_data           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
			   )
IS


   CURSOR C_get_adj_id_HdrH(l_quote_header_id NUMBER,l_price_attribute1 VARCHAR2) IS
   SELECT price_adjustment_id
   FROM aso_price_adjustments
   WHERE quote_header_id = l_quote_header_id
   AND quote_line_id is null
   AND modifier_header_id = to_number(l_price_attribute1);

   CURSOR C_get_adj_id_HdrL(l_quote_header_id NUMBER,l_price_attribute2 VARCHAR2) IS
   SELECT price_adjustment_id
   FROM aso_price_adjustments
   WHERE Quote_header_id = l_quote_header_id
   AND quote_line_id is null
   AND modifier_line_id = to_number(l_price_attribute2);

   CURSOR C_get_adj_id_LnH(l_quote_header_id NUMBER,l_quote_line_id NUMBER,l_price_attribute1 VARCHAR2) IS
   SELECT price_adjustment_id
   FROM aso_price_adjustments
   WHERE Quote_header_id = l_quote_header_id
   AND   Quote_line_id = l_quote_line_id
   AND modifier_header_id = to_number(l_price_attribute1);

   CURSOR C_get_adj_id_LnL(l_quote_header_id NUMBER,l_quote_line_id NUMBER,l_price_attribute2 VARCHAR2)IS
   SELECT price_adjustment_id
   FROM aso_price_adjustments
   WHERE Quote_header_id = l_quote_header_id
   AND   Quote_line_id = l_quote_line_id
   AND modifier_line_id = to_number(l_price_attribute2);



    l_api_name                      CONSTANT VARCHAR2(30) := 'Delete_Promotion';
    l_api_version_number            CONSTANT NUMBER   := 1.0;
    l_price_adjustment_id                    NUMBER;
    i                                        NUMBER;

BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Inside Delete_Promotion', 1, 'Y');
    END IF;


    -- Standard Start of API savepoint
    SAVEPOINT Delete_Promotion_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
          FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:p_price_attr_tbl.count:'||nvl(p_price_attr_tbl.count,0),1,'Y');
   END IF;

   For i in 1..p_price_attr_tbl.count loop
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CORE_PVT:In Delete Promotion - p_price_attr_tbl(i).operation_code:'
                            ||p_price_attr_tbl(i).operation_code,1,'Y');
       END IF;
       If p_price_attr_tbl(i).operation_code = 'DELETE' Then
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CORE_PVT:Parameters passed to Delete_Promotion: loop '||i,1,'Y');
            aso_debug_pub.add('ASO_PRICING_CORE_PVT:Quote_header_id:'||p_price_attr_tbl(i).quote_header_id,1,'Y');
            aso_debug_pub.add('ASO_PRICING_CORE_PVT:Price_attribute_id:'||p_price_attr_tbl(i).price_attribute_id,1,'Y');
            aso_debug_pub.add('ASO_PRICING_CORE_PVT:Quote_line_id:'||p_price_attr_tbl(i).quote_line_id,1,'Y');
            aso_debug_pub.add('ASO_PRICING_CORE_PVT:Pricing_Attribute1:'||p_price_attr_tbl(i).pricing_attribute1,1,'Y');
            aso_debug_pub.add('ASO_PRICING_CORE_PVT:Pricing_Attribute2:'||p_price_attr_tbl(i).pricing_attribute2,1,'Y');
            aso_debug_pub.add('ASO_PRICING_CORE_PVT:Flex_title:'||p_price_attr_tbl(i).flex_title,1,'Y');
          END IF;

       If p_price_attr_tbl(i).price_attribute_id is not null then
		If ((p_price_attr_tbl(i).pricing_attribute1 IS NULL
		    OR p_price_attr_tbl(i).pricing_attribute1 = FND_API.G_MISS_CHAR)
		    AND
             (p_price_attr_tbl(i).pricing_attribute2 IS NULL
		   OR p_price_attr_tbl(i).pricing_attribute2 = FND_API.G_MISS_CHAR))
		   OR (p_price_attr_tbl(i).flex_title = 'QP_ATTR_DEFNS_PRICING'
			  OR (p_price_attr_tbl(i).flex_title = FND_API.G_MISS_CHAR
				 OR  p_price_attr_tbl(i).flex_title IS NULL)) then
		           /*Deleting the attributes or promotions from Istore*/
                    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                       aso_debug_pub.add('ASO_PRICING_CORE_PVT:Deleting Price attributes or promocodes from Istorewith Price_attribute_id:'||p_price_attr_tbl(i).Price_attribute_id,1,'Y');
                    END IF;
                    ASO_PRICE_ATTRIBUTES_PKG.Delete_Row
                                      (p_PRICE_ATTRIBUTE_ID  => p_price_attr_tbl(i).price_attribute_id);
          else
	         --We will require at least quote_header_id AND (price_attr1 OR price_attr2 value)
              --Check if there is a header id
              If (p_price_attr_tbl(i).quote_header_id IS NULL)
	            OR (p_price_attr_tbl(i).quote_header_id = FND_API.G_MISS_NUM) THEN
                      x_return_status := FND_API.G_RET_STS_ERROR;
		            RAISE FND_API.G_EXC_ERROR;
              END If;

              If (p_price_attr_tbl(i).pricing_attribute1 = FND_API.G_MISS_CHAR
	             OR p_price_attr_tbl(i).pricing_attribute1 is null)
                  AND (p_price_attr_tbl(i).pricing_attribute2 = FND_API.G_MISS_CHAR
		           OR p_price_attr_tbl(i).pricing_attribute2 is null ) THEN
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        RAISE FND_API.G_EXC_ERROR;
              End If;

              If (p_price_attr_tbl(i).quote_line_id IS NULL
                 OR p_price_attr_tbl(i).quote_line_id = FND_API.G_MISS_NUM) then
                 /*Delete all the header level adjustments*/

                 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                    aso_debug_pub.add('ASO_PRICING_CORE_PVT:Deleting header level adjustments',1,'Y');
                 END IF;
	            If (p_price_attr_tbl(i).pricing_attribute2 is null
		          OR p_price_attr_tbl(i).pricing_attribute2 = FND_API.G_MISS_CHAR) then

                    /*Delete all the adjustment record with the modifier_header_id*/
                    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                       aso_debug_pub.add('ASO_PRICING_CORE_PVT:Deleting header level adjustments with the modifier_header_id',1,'Y');
                    END IF;

                    OPEN C_get_adj_id_HdrH(p_price_attr_tbl(i).quote_header_id,
                                           p_price_attr_tbl(i).pricing_attribute1);
                    FETCH C_get_adj_id_HdrH INTO l_price_adjustment_id;

			     While C_get_adj_id_HdrH%found LOOP
                          ASO_PRICE_ADJUSTMENTS_PKG.Delete_Row(p_PRICE_ADJ_ID  => l_price_adjustment_id);
                          FETCH C_get_adj_id_HdrH INTO l_price_adjustment_id;
			     End Loop;
                    CLOSE C_get_adj_id_HdrH;

	            Elsif (p_price_attr_tbl(i).pricing_attribute1 is null
			         OR p_price_attr_tbl(i).pricing_attribute1 = FND_API.G_MISS_CHAR) then

	                   /*Delete all the adjustment record with the modifier_line_id*/
                        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                           aso_debug_pub.add('ASO_PRICING_CORE_PVT:Deleting header level adjustments with the modifier_line_id',1,'Y');
                        END IF;

                        OPEN C_get_adj_id_HdrL(p_price_attr_tbl(i).quote_header_id,
                                               p_price_attr_tbl(i).pricing_attribute2);
                        FETCH C_get_adj_id_HdrL INTO l_price_adjustment_id;
                        IF (C_get_adj_id_HdrL%NOTFOUND) THEN
			            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			               aso_debug_pub.add('ASO_PRICING_CORE_PVT:No record in C_get_adj_id_HdrL:i - '||i,1,'Y');
			            END IF;
                           /*Do not error OUT do nothing*/
                        ELSE
                           ASO_PRICE_ADJUSTMENTS_PKG.Delete_Row(p_PRICE_ADJ_ID  => l_price_adjustment_id);
                        END IF;
                        CLOSE C_get_adj_id_HdrL;
	            End If;-- IF (p_price_attr_tbl(i).pricing_attribute2 is null

              Else/*Delete all the line level adjustments*/

                  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                     aso_debug_pub.add('ASO_PRICING_CORE_PVT:Deleting line level adjustments',1,'Y');
                  END IF;

                  If (p_price_attr_tbl(i).pricing_attribute2 is null
		            OR p_price_attr_tbl(i).pricing_attribute2 = FND_API.G_MISS_CHAR) then

	                /*Delete all the adjustment record with the modifier_header_id*/
                     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                        aso_debug_pub.add('ASO_PRICING_CORE_PVT:Deleting line level adjustments with the modifier_header_id',1,'Y');
                     END IF;

                     OPEN C_get_adj_id_LnH(p_price_attr_tbl(i).quote_header_id,
                                   p_price_attr_tbl(i).quote_line_id,
                                   p_price_attr_tbl(i).pricing_attribute1
                                   );
                     FETCH C_get_adj_id_LnH INTO l_price_adjustment_id;

		           While C_get_adj_id_LnH%found LOOP
		              ASO_PRICE_ADJUSTMENTS_PKG.Delete_Row(p_PRICE_ADJ_ID  => l_price_adjustment_id);
		              FETCH C_get_adj_id_LnH INTO l_price_adjustment_id;
                     End Loop;

                     CLOSE C_get_adj_id_LnH;

	             Elsif (p_price_attr_tbl(i).pricing_attribute1 is null
		              OR p_price_attr_tbl(i).pricing_attribute1 = FND_API.G_MISS_CHAR) then

	                   /*Delete all the adjustment record with the modifier_line_id*/
                       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                          aso_debug_pub.add('ASO_PRICING_CORE_PVT:Deleting line level adjustments with the modifier_line_id',1,'Y');
                       END IF;

                       OPEN C_get_adj_id_LnL(p_price_attr_tbl(i).quote_header_id,
                                     p_price_attr_tbl(i).quote_line_id,
                                     p_price_attr_tbl(i).pricing_attribute2
                                     );
                       FETCH C_get_adj_id_LnL INTO l_price_adjustment_id;
                       IF (C_get_adj_id_LnL%NOTFOUND) THEN
			           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			              aso_debug_pub.add('ASO_PRICING_CORE_PVT:No record in C_get_adj_id_LnL:i'||i,1,'Y');
			           END IF;
                          /*Do not error OUT - do nothing*/
                       ELSE
                          ASO_PRICE_ADJUSTMENTS_PKG.Delete_Row(p_PRICE_ADJ_ID  => l_price_adjustment_id);
                       END IF;
                       CLOSE C_get_adj_id_LnL;

                 End If;

         End If;--If (p_price_attr_tbl(i).quote_line_id IS NULL

        /*Delete the Price Attribute Record*/

         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CORE_PVT:After Deleting Adj Deleting the attribute rec',1,'Y');
         END IF;
         ASO_PRICE_ATTRIBUTES_PKG.Delete_Row
                (p_PRICE_ATTRIBUTE_ID  => p_price_attr_tbl(i).price_attribute_id);

       End If;--If ((p_price_attr_tbl(i).pricing_attribute1 IS NULL This is the end if of else of Istore and attr

      End If;-- If p_price_attr_tbl(i).price_attribute_id is not null

   End If;-- p_price_attr_tbl(i).operation_code = 'DELETE'

  End Loop;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
     aso_debug_pub.add('ASO_PRICING_CORE_PVT:Delete_Promotion Ends', 1, 'Y');
  END IF;

  -- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
 EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
          ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

END Delete_Promotion;


PROCEDURE Copy_Price_To_Quote(
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     P_control_rec              IN   ASO_PRICING_INT.Pricing_Control_Rec_Type,
     p_qte_header_rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
	P_Insert_Type              IN   VARCHAR2 := 'HDR',
     x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */ NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS

l_api_name                    CONSTANT VARCHAR2(30) := 'Copy_Price_To_Quote';
l_api_version_number          CONSTANT NUMBER   := 1.0;
l_line_shipping_charge        number := 0;
l_hdr_shipping_charge         number := 0;
l_message_text                VARCHAR2(2000);
l_msg_text                          VARCHAR2(1000);
msg_length                         number:=0;
G_USER_ID                     NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID                    NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
l_last_update_date			Date	:= SYSDATE;
l                             BINARY_INTEGER;
l_total_list_price            NUMBER;
l_ln_total_discount           NUMBER;
ls_qte_line_tbl               ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
l_profile_value               VARCHAR2(20);
l_db_line_counter             NUMBER;

CURSOR C_status_code IS
SELECT line_id,
	  pricing_status_code,
       pricing_status_text
FROM qp_preq_lines_tmp lines
WHERE lines.line_type_code='LINE'
AND  lines.pricing_status_code in(
            QP_PREQ_GRP.g_status_invalid_price_list,
            QP_PREQ_GRP.g_sts_lhs_not_found,
            QP_PREQ_GRP.g_status_formula_error,
            QP_PREQ_GRP.g_status_other_errors,
            fnd_api.g_ret_sts_unexp_error,
            fnd_api.g_ret_sts_error,
            QP_PREQ_GRP.g_status_calc_error,
            QP_PREQ_GRP.g_status_uom_failure,
            QP_PREQ_GRP.g_status_invalid_uom,
            QP_PREQ_GRP.g_status_dup_price_list,
            QP_PREQ_GRP.g_status_invalid_uom_conv,
            QP_PREQ_GRP.g_status_invalid_incomp,
            QP_PREQ_GRP.g_status_best_price_eval_error,
	       QP_PREQ_PUB.g_back_calculation_sts);

CURSOR C_status_code_GSA IS
SELECT pricing_status_code,
       pricing_status_text
FROM  qp_preq_lines_tmp lines
WHERE lines.line_type_code='LINE'
AND   lines.pricing_status_code = QP_PREQ_GRP.G_STATUS_GSA_VIOLATION;

/*This cursor is just for debugging purpose*/
CURSOR C_QP_PREQ_RLTD_LINES_TMP IS
SELECT
rltd.REQUEST_TYPE_CODE,
rltd.LINE_INDEX,
rltd.LINE_DETAIL_INDEX,
rltd.RELATIONSHIP_TYPE_CODE,
rltd.RELATED_LINE_INDEX,
rltd.RELATED_LINE_DETAIL_INDEX,
rltd.PRICING_STATUS_CODE,
rltd.PRICING_STATUS_TEXT,
rltd.LIST_LINE_ID,
rltd.RELATED_LIST_LINE_ID,
rltd.RELATED_LIST_LINE_TYPE,
rltd.OPERAND_CALCULATION_CODE,
rltd.OPERAND,
rltd.PRICING_GROUP_SEQUENCE,
rltd.RELATIONSHIP_TYPE_DETAIL,
rltd.SETUP_VALUE_FROM,
rltd.SETUP_VALUE_TO,
rltd.QUALIFIER_VALUE,
rltd.ADJUSTMENT_AMOUNT,
rltd.SATISFIED_RANGE_VALUE,
rltd.REQUEST_ID,
lines.line_id,
lines.process_status
FROM QP_PREQ_RLTD_LINES_TMP rltd,
     QP_PREQ_LINES_TMP lines
WHERE RLTD.PRICING_STATUS_CODE = QP_PREQ_PUB.G_STATUS_NEW
AND RLTD.Relationship_Type_Code in (QP_PREQ_GRP.G_PBH_LINE ,QP_PREQ_GRP.G_GENERATED_LINE )
AND lines.process_status IN (QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_UNCHANGED)
AND lines.line_type_code = 'LINE'
AND lines.line_index = rltd.line_index;


BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
          FND_MSG_PUB.initialize;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Start Copy_Price_To_Quote ',1,'Y');
	 aso_debug_pub.add('ASO_PRICING_CORE_PVT:P_control_rec.price_mode:'||P_control_rec.price_mode,1,'Y');
	 aso_debug_pub.add('ASO_PRICING_CORE_PVT:p_insert_type:'||p_insert_type,1,'Y');
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Post_Price_Request for p_qte_header_rec.quote_header_id'
                         ||p_qte_header_rec.quote_header_id,1,'Y');
    END IF;

    SELECT count(rowid)
    INTO l_db_line_counter
    FROM ASO_QUOTE_LINES_ALL
    WHERE quote_header_id = p_qte_header_rec.quote_header_id;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_db_line_counter:'||l_db_line_counter,1,'Y');
    END IF;


    If l_db_line_counter <> 0 Then

       FOR C_status_code_rec in C_status_code LOOP
           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('ASO_PRICING_CORE_PVT:Inside c_status_code cursor line_id:'
					       ||C_status_code_rec.line_id,1,'Y');
             aso_debug_pub.add('ASO_PRICING_CORE_PVT:Inside c_status_code cursor pricing_status_code:'
					       ||C_status_code_rec.pricing_status_code,1,'Y');
             aso_debug_pub.add('ASO_PRICING_CORE_PVT:Inside c_status_code cursor pricing_status_text:'
					       ||C_status_code_rec.pricing_status_text,1,'Y');
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
	    -- bug 13902362
	   if l_message_text is null then
                 l_message_text := C_status_code_rec.pricing_status_code || ': '||C_status_code_rec.pricing_status_text;
           else
	        l_msg_text:= C_status_code_rec.pricing_status_text;
		msg_length:=length(l_message_text)+length(l_msg_text)+1;
		--aso_debug_pub.add('ASO_PRICING_CORE_PVT:l:'||msg_length,1,'Y');
		if  msg_length<=2000 then
 	            l_message_text:=l_message_text||'  '||l_msg_text;
                 end if;
              end if;

          /* IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR');
              FND_MESSAGE.Set_Token('MSG_TXT', substr(l_message_text, 1,255), FALSE);
              FND_MSG_PUB.ADD;
           END IF;
             RAISE FND_API.G_EXC_ERROR;*/
      END LOOP;
      if l_message_text is not null then
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR');
              FND_MESSAGE.Set_Token('MSG_TXT', substr(l_message_text, 1,255), FALSE);
              FND_MSG_PUB.ADD;
           END IF;
             RAISE FND_API.G_EXC_ERROR;
     END if;
      --end  bug 13902362
      l_profile_value := FND_PROFILE.value('ASO_GSA_PRICING');
	 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	   aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_profile_value - ASO_GSA_PRICING:'||l_profile_value,1,'Y');
	 END IF;
      IF ( l_profile_value = 'ERROR' ) THEN
       FOR C_status_code_GSA_rec in C_status_code_GSA LOOP
            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.add('ASO_PRICING_CORE_PVT:Inside GSA error',1,'Y');
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('ASO', 'ASO_GSA_VIOLATION');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
            END LOOP;
      ELSE
       FOR C_status_code_GSA_rec in C_status_code_GSA LOOP
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CORE_PVT:inside GSA Warning',1,'Y');
          END IF;
          FND_MESSAGE.Set_Name('ASO', 'ASO_GSA_VIOLATION');
          FND_MSG_PUB.ADD;
       END LOOP;
      END IF;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_CORE_PVT:After Error Handling',1,'Y');
        aso_debug_pub.add('ASO_PRICING_CORE_PVT:quote header id = '||p_qte_header_rec.quote_header_id,1,'Y');
      END IF;

/*
 * Updating Quote Lines
 */


IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_CORE_PVT:Before updating lines P_control_rec.pricing_event:'
					  ||P_control_rec.pricing_event,1,'Y');
        aso_debug_pub.add('ASO_PRICING_CORE_PVT:Before updating lines P_control_rec.price_mode : '
					  ||P_control_rec.price_mode,1,'Y');
END IF;

If (P_control_rec.pricing_event = 'PRICE') then

UPDATE ASO_QUOTE_LINES_all l
SET (line_quote_price
    ,line_list_price
   -- ,unit_price -- bug 17517305 , commented for Bug 19243138
    ,line_adjusted_amount
    ,line_adjusted_percent
    ,quantity
    ,uom_code
    ,priced_price_list_id
    ,pricing_quantity
    ,pricing_quantity_uom
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,QUANTITY_UOM_CHANGE
  )
   =
 (SELECT to_number(substr(decode(l.selling_price_change,'Y',l.line_quote_price,NVL(Lines.order_uom_selling_price,lines.line_unit_price)),1,40)) -- bug 14680110
                   --decode(l.selling_price_change,'Y',l.line_quote_price,NVL(Lines.order_uom_selling_price,lines.line_unit_price))
        ,to_number(substr(lines.line_unit_price,1,40)) -- bug 14680110
	--,to_number(substr(lines.unit_price,1,40)) -- bug 17517305 , commented for Bug 19243138
        ,to_number(substr((NVL(lines.order_uom_selling_price, lines.line_unit_price)-lines.line_unit_price),1,40)) -- bug 14680110
        ,to_number(substr(decode(lines.line_unit_price,0,lines.line_unit_price,
    ((NVL(lines.order_uom_selling_price, lines.line_unit_price)-lines.line_unit_price)/lines.line_unit_price)*100),1,40)) -- bug 14680110
        ,lines.line_quantity
        ,lines.line_uom_code
        ,lines.price_list_header_id
	   ,lines.priced_quantity
	   ,lines.priced_uom_code
        ,sysdate
        ,G_USER_ID
        ,G_LOGIN_ID
	,'N'
  FROM  qp_preq_lines_tmp lines
  WHERE lines.line_id=l.quote_line_id
  AND   lines.line_type_code='LINE'
  )
WHERE l.quote_header_id=p_qte_header_rec.quote_header_id
AND   l.quote_line_id IN
         (SELECT line_id
          FROM   qp_preq_lines_tmp lines
          WHERE  lines.pricing_status_code
                 IN (QP_PREQ_GRP.G_STATUS_UPDATED, QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
          AND    lines.line_type_code='LINE');

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:With Price Event Lines Updated '||sql%ROWCOUNT,1,'Y');
END IF;

else
 -- manual price change is possible

UPDATE ASO_QUOTE_LINES_all l
SET (line_quote_price
    ,line_list_price
   -- ,unit_price -- bug 17517305 , commented for Bug 19243138
    ,line_adjusted_amount
    ,line_adjusted_percent
    ,quantity
    ,uom_code
    ,priced_price_list_id
    ,pricing_quantity
    ,pricing_quantity_uom
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,recalculate_flag
    ,selling_price_change
    ,QUANTITY_UOM_CHANGE
  )
   =
 (SELECT to_number(substr(NVL(Lines.order_uom_selling_price,lines.line_unit_price),1,40)) -- bug 14680110
        ,to_number(substr(lines.line_unit_price,1,40))  -- bug 14680110
     --	,to_number(substr(lines.unit_price,1,40)) -- bug 17517305 , commented for Bug 19243138
        ,to_number(substr((NVL(lines.order_uom_selling_price, lines.line_unit_price)-lines.line_unit_price),1,40))  -- bug 14680110
        ,to_number(substr(decode(lines.line_unit_price,0,lines.line_unit_price,
    ((NVL(lines.order_uom_selling_price, lines.line_unit_price)-lines.line_unit_price)/lines.line_unit_price)*100),1,40))  -- bug 14680110
        ,lines.line_quantity
        ,lines.line_uom_code
        ,lines.price_list_header_id
	   ,lines.priced_quantity
	   ,lines.priced_uom_code
        ,sysdate
        ,G_USER_ID
        ,G_LOGIN_ID
        ,'N'--recalculate_flag - reset back to the default value
        ,'N'--selling_price_change - reset back to the default value
	,'N' -- resetting the flag

  FROM  qp_preq_lines_tmp lines
  WHERE lines.line_id=l.quote_line_id
  AND   lines.line_type_code='LINE'
  AND   lines.process_status IN (QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_UNCHANGED)
  AND   lines.pricing_status_code IN (QP_PREQ_GRP.G_STATUS_UPDATED, QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
  )
WHERE l.quote_header_id=p_qte_header_rec.quote_header_id
AND   l.quote_line_id IN
         (SELECT line_id
          FROM   qp_preq_lines_tmp lines
          WHERE  lines.pricing_status_code IN (QP_PREQ_GRP.G_STATUS_UPDATED, QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
          AND   lines.process_status IN (QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_UNCHANGED)
          AND    lines.line_type_code='LINE');


IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:Lines Updated '||sql%ROWCOUNT,1,'Y');
END IF;

end If;--If P_control_rec.pricing_event = 'PRICE'

--Bulk Insert of Price Adjustment from QP temp table for a quote Header
If (p_control_rec.pricing_event = 'BATCH') OR (p_control_rec.pricing_event = 'ORDER') then
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:p_insert_type: '||p_insert_type,1,'Y');
END IF;

If p_insert_type = 'HDR' then

INSERT INTO ASO_PRICE_ADJUSTMENTS
      (price_adjustment_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      quote_header_id,
      quote_line_id,
      MODIFIER_HEADER_ID,
      MODIFIER_LINE_ID,
      MODIFIER_LINE_TYPE_CODE,
      MODIFIED_FROM,
      MODIFIED_TO,
      OPERAND,
      ARITHMETIC_OPERATOR,
      AUTOMATIC_FLAG,
      UPDATE_ALLOWABLE_FLAG,
      UPDATED_FLAG,
      APPLIED_FLAG,
      ON_INVOICE_FLAG,
      CHARGE_TYPE_CODE,
      PRICING_PHASE_ID,
      PRICING_GROUP_SEQUENCE,
      PRICE_BREAK_TYPE_CODE,
      ADJUSTED_AMOUNT,
      MODIFIER_LEVEL_CODE,
      ACCRUAL_FLAG,
      LIST_LINE_NO,
      ACCRUAL_CONVERSION_RATE,
      EXPIRATION_DATE,
      CHARGE_SUBTYPE_CODE,
      INCLUDE_ON_RETURNS_FLAG,
      BENEFIT_QTY,
      BENEFIT_UOM_CODE,
      PRORATION_TYPE_CODE,
      REBATE_TRANSACTION_TYPE_CODE,
      range_break_quantity,
      MODIFIER_MECHANISM_TYPE_CODE,
      SUBSTITUTION_ATTRIBUTE,
      change_reason_code,
      change_reason_text,
      update_allowed,
	 operand_per_pqty,
	 adjusted_amount_per_pqty
      )(
     SELECT
                nvl(ldets_v.PRICE_ADJUSTMENT_ID,ASO_PRICE_ADJUSTMENTS_S.nextval),
                sysdate
               ,fnd_global.user_id
               ,sysdate
               ,fnd_global.user_id
               ,fnd_global.login_id
               ,p_qte_header_rec.quote_header_id,
               decode(ldets_v.modifier_level_code,'ORDER',NULL,lines.line_id),
               ldets_v.list_header_id,
               ldets_v.list_line_id,
               ldets_v.list_line_type_code,
               NULL,
               NULL,
               ldets_v.ORDER_QTY_OPERAND,
               ldets_v.Operand_Calculation_Code,
               ldets_v.Automatic_flag,
               ldets_v.Override_flag,
               ldets_v.UPDATED_FLAG,
               ldets_v.Applied_Flag,
               ldets_v.Print_On_Invoice_Flag,
               ldets_v.CHARGE_TYPE_CODE,
               ldets_v.Pricing_phase_id,
               ldets_v.PRICING_GROUP_SEQUENCE,
               ldets_v.PRICE_BREAK_TYPE_CODE,
               ldets_v.ORDER_QTY_ADJ_AMT,
               ldets_v.MODIFIER_LEVEL_CODE,
               ldets_v.ACCRUAL_FLAG,
               ldets_v.LIST_LINE_NO,
               ldets_v.ACCRUAL_CONVERSION_RATE,
               ldets_v.EXPIRATION_DATE,
               ldets_v.CHARGE_SUBTYPE_CODE,
               ldets_v.INCLUDE_ON_RETURNS_FLAG,
               ldets_v.BENEFIT_QTY,
               ldets_v.BENEFIT_UOM_CODE,
               ldets_v.PRORATION_TYPE_CODE,
               ldets_v.REBATE_TRANSACTION_TYPE_CODE,
               decode(ldets_v.modifier_level_code,'ORDER',NULL,ldets_v.Line_quantity),
               decode(ldets_v.modifier_level_code,'ORDER',NULL,ldets_v.Calculation_code),
               ldets_v.SUBSTITUTION_ATTRIBUTE,
               ldets_v.change_reason_code,
               ldets_v.change_reason_text,
               ldets_v.OVERRIDE_FLAG,
			ldets_v.operand_value,
			ldets_v.adjustment_amount
       FROM    QP_PREQ_LINES_TMP lines,
               QP_LDETS_V ldets_v
       WHERE lines.line_index = ldets_v.line_index
	  AND   lines.process_status IN (QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_UNCHANGED)
       AND   ldets_v.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
       AND   ldets_v.process_code = QP_PREQ_GRP.G_STATUS_NEW
       AND   nvl(ldets_v.created_from_list_type_code,'X') not in ('PRL','AGR'));

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:Insert into Adjustment '||sql%ROWCOUNT,1,'Y');
END IF;


IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('',1,'Y');
aso_debug_pub.add('',1,'Y');
aso_debug_pub.add('*****************QP_PREQ_RLTD_LINES_TMP*****************************************',1,'Y');
For C_QP_PREQ_RLTD_LINES_TMP_REC in C_QP_PREQ_RLTD_LINES_TMP loop
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.REQUEST_TYPE_CODE:'||C_QP_PREQ_RLTD_LINES_TMP_REC.REQUEST_TYPE_CODE,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.LINE_INDEX:'||C_QP_PREQ_RLTD_LINES_TMP_REC.LINE_INDEX,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.LINE_DETAIL_INDEX:'||C_QP_PREQ_RLTD_LINES_TMP_REC.LINE_DETAIL_INDEX,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.RELATIONSHIP_TYPE_CODE:'||C_QP_PREQ_RLTD_LINES_TMP_REC.RELATIONSHIP_TYPE_CODE,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.RELATED_LINE_INDEX:'||C_QP_PREQ_RLTD_LINES_TMP_REC.RELATED_LINE_INDEX,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.RELATED_LINE_DETAIL_INDEX:'||C_QP_PREQ_RLTD_LINES_TMP_REC.RELATED_LINE_DETAIL_INDEX,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.PRICING_STATUS_CODE:'||C_QP_PREQ_RLTD_LINES_TMP_REC.PRICING_STATUS_CODE,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.PRICING_STATUS_TEXT:'||C_QP_PREQ_RLTD_LINES_TMP_REC.PRICING_STATUS_TEXT,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.LIST_LINE_ID:'||C_QP_PREQ_RLTD_LINES_TMP_REC.LIST_LINE_ID,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.RELATED_LIST_LINE_ID:'||C_QP_PREQ_RLTD_LINES_TMP_REC.RELATED_LIST_LINE_ID,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.RELATED_LIST_LINE_TYPE:'||C_QP_PREQ_RLTD_LINES_TMP_REC.RELATED_LIST_LINE_TYPE,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.OPERAND_CALCULATION_CODE:'||C_QP_PREQ_RLTD_LINES_TMP_REC.OPERAND_CALCULATION_CODE,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.OPERAND:'||C_QP_PREQ_RLTD_LINES_TMP_REC.OPERAND,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.PRICING_GROUP_SEQUENCE:'||C_QP_PREQ_RLTD_LINES_TMP_REC.PRICING_GROUP_SEQUENCE,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.RELATIONSHIP_TYPE_DETAIL:'||C_QP_PREQ_RLTD_LINES_TMP_REC.RELATIONSHIP_TYPE_DETAIL,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.SETUP_VALUE_FROM:'||C_QP_PREQ_RLTD_LINES_TMP_REC.SETUP_VALUE_FROM,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.SETUP_VALUE_TO:'||C_QP_PREQ_RLTD_LINES_TMP_REC.SETUP_VALUE_TO,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.QUALIFIER_VALUE:'||C_QP_PREQ_RLTD_LINES_TMP_REC.QUALIFIER_VALUE,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.ADJUSTMENT_AMOUNT:'||C_QP_PREQ_RLTD_LINES_TMP_REC.ADJUSTMENT_AMOUNT,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.SATISFIED_RANGE_VALUE:'||C_QP_PREQ_RLTD_LINES_TMP_REC.SATISFIED_RANGE_VALUE,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.REQUEST_ID:'||C_QP_PREQ_RLTD_LINES_TMP_REC.REQUEST_ID,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.process_status:'||C_QP_PREQ_RLTD_LINES_TMP_REC.process_status,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.line_id:'||C_QP_PREQ_RLTD_LINES_TMP_REC.line_id,1,'Y');
aso_debug_pub.add('*****************NEXT ADJUSTMENT RELATIONSHIP*****************************************',1,'Y');

End Loop;

END IF;
/*
 * Insert to Price Adj Relationships
 *
 */

        INSERT INTO ASO_PRICE_ADJ_RELATIONSHIPS
        (adj_relationship_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        quote_line_id,
        price_adjustment_id,
        rltd_price_adj_id
        )
        (SELECT  ASO_PRICE_RELATIONSHIPS_S.nextval
                ,sysdate
                ,fnd_global.user_id
                ,sysdate
                ,fnd_global.user_id
                ,fnd_global.login_id
                ,adj.QUOTE_LINE_ID
                ,ADJ.PRICE_ADJUSTMENT_ID
                ,RADJ.PRICE_ADJUSTMENT_ID
         FROM
               QP_PREQ_RLTD_LINES_TMP RLTD,
               QP_PREQ_LINES_TMP LINE,
			QP_PREQ_LINES_TMP RLTD_LINE,
               ASO_PRICE_ADJUSTMENTS ADJ,
               ASO_PRICE_ADJUSTMENTS RADJ
        WHERE RLTD.PRICING_STATUS_CODE = QP_PREQ_PUB.G_STATUS_NEW
        AND RLTD_LINE.line_index = RLTD.related_line_index
        AND RLTD.Relationship_Type_Code in
            (QP_PREQ_GRP.G_PBH_LINE ,QP_PREQ_GRP.G_GENERATED_LINE )
        AND line.line_index = rltd.line_index
        AND adj.quote_header_id = p_qte_header_rec.quote_header_id
        AND adj.quote_line_id = line.line_id
        AND line.line_type_code = 'LINE'
        AND line.process_status IN (QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_UNCHANGED)
	   AND rltd_line.process_status IN (QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_UNCHANGED)
        AND adj.modifier_line_id = rltd.list_line_id
        AND radj.quote_header_id = p_qte_header_rec.quote_header_id
        AND radj.quote_line_id = rltd_line.line_id
        AND radj.modifier_line_id = rltd.related_list_line_id);

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:Insert into Adjustment Relationships '||sql%ROWCOUNT,1,'Y');
END IF;


/*
 * Insert into Price Adj Attributes - Line Attributes
 */


 -- Added hint to fix perf bug 5614878.

 INSERT INTO ASO_PRICE_ADJ_ATTRIBS
              (  price_adj_attrib_id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                price_adjustment_id,
                pricing_context,
                pricing_attribute,
                pricing_attr_value_from,
                pricing_attr_value_to,
                comparison_operator,
                flex_title)
                (SELECT /*+ ORDERED USE_NL(LINES LDETS QPLAT ADJ) INDEX(LINES) INDEX(LDETS) INDEX(QPLAT  QP_PREQ_LINE_ATTRS_TMP_N3) */
			  ASO_PRICE_ADJ_ATTRIBS_S.nextval,
                 sysdate
                ,fnd_global.user_id
                ,sysdate
                ,fnd_global.user_id
                ,fnd_global.login_id
                ,ADJ.PRICE_ADJUSTMENT_ID
                ,QPLAT.CONTEXT
                ,QPLAT.ATTRIBUTE
                ,nvl(QPLAT.SETUP_VALUE_FROM,QPLAT.VALUE_FROM)
                ,QPLAT.SETUP_VALUE_TO
                ,QPLAT.COMPARISON_OPERATOR_TYPE_CODE
                ,decode(QPLAT.ATTRIBUTE_TYPE,
                        'QUALIFIER','QP_ATTR_DEFNS_QUALIFIER',
                        'QP_ATTR_DEFNS_PRICING')
               FROM
                  ASO_PRICE_ADJUSTMENTS ADJ,
                  QP_PREQ_LINES_TMP LINES ,
                  QP_PREQ_LDETS_TMP LDETS,
                  QP_PREQ_LINE_ATTRS_TMP QPLAT
              WHERE ADJ.QUOTE_HEADER_ID = p_qte_header_rec.quote_header_id
              AND LINES.LINE_ID = ADJ.QUOTE_LINE_ID
              AND lines.process_status IN (QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_UNCHANGED)
              AND LDETS.LINE_INDEX = LINES.LINE_INDEX
              AND LDETS.PRICING_PHASE_ID = ADJ.PRICING_PHASE_ID
              AND LDETS.PRICING_STATUS_CODE = QP_PREQ_PUB.G_STATUS_NEW
              AND LDETS.CREATED_FROM_LIST_LINE_ID = ADJ.MODIFIER_LINE_ID
              AND LDETS.CREATED_FROM_LIST_HEADER_ID = ADJ.MODIFIER_HEADER_ID
              AND QPLAT.LINE_DETAIL_INDEX = LDETS.LINE_DETAIL_INDEX
              AND QPLAT.PRICING_STATUS_CODE = QP_PREQ_PUB.G_STATUS_NEW);

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:Insert into Adjustment Attributes - Line Level Attributes'||sql%ROWCOUNT,1,'Y');
END IF;

 -- Added hint to fix perf bug 5614878.

              INSERT INTO ASO_PRICE_ADJ_ATTRIBS
              (  price_adj_attrib_id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                price_adjustment_id,
                pricing_context,
                pricing_attribute,
                pricing_attr_value_from,
                pricing_attr_value_to,
                comparison_operator,
                flex_title)
                (SELECT /*+ ORDERED USE_NL(LINES LDETS QPLAT ADJ) INDEX(LINES) INDEX(LDETS) INDEX(QPLAT  QP_PREQ_LINE_ATTRS_TMP_N3) */ ASO_PRICE_ADJ_ATTRIBS_S.nextval,
                 sysdate
                ,fnd_global.user_id
                ,sysdate
                ,fnd_global.user_id
                ,fnd_global.login_id
                ,ADJ.PRICE_ADJUSTMENT_ID
                ,QPLAT.CONTEXT
                ,QPLAT.ATTRIBUTE
                ,nvl(QPLAT.SETUP_VALUE_FROM,QPLAT.VALUE_FROM)
                ,QPLAT.SETUP_VALUE_TO
                ,QPLAT.COMPARISON_OPERATOR_TYPE_CODE
                ,decode(QPLAT.ATTRIBUTE_TYPE,
                        'QUALIFIER','QP_ATTR_DEFNS_QUALIFIER',
                        'QP_ATTR_DEFNS_PRICING')
               FROM
                  ASO_PRICE_ADJUSTMENTS ADJ,
                  QP_PREQ_LINES_TMP LINES ,
                  QP_PREQ_LDETS_TMP LDETS,
                  QP_PREQ_LINE_ATTRS_TMP QPLAT
              WHERE ADJ.QUOTE_HEADER_ID = p_qte_header_rec.quote_header_id
              AND LINES.LINE_ID = ADJ.QUOTE_HEADER_ID
              AND LDETS.LINE_INDEX = LINES.LINE_INDEX
              AND lines.process_status IN (QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_UNCHANGED)
              AND LDETS.PRICING_PHASE_ID = ADJ.PRICING_PHASE_ID
              AND LDETS.PRICING_STATUS_CODE = QP_PREQ_PUB.G_STATUS_NEW
              AND LDETS.CREATED_FROM_LIST_LINE_ID = ADJ.MODIFIER_LINE_ID
              AND LDETS.CREATED_FROM_LIST_HEADER_ID = ADJ.MODIFIER_HEADER_ID
              AND QPLAT.LINE_DETAIL_INDEX = LDETS.LINE_DETAIL_INDEX
              AND QPLAT.PRICING_STATUS_CODE = QP_PREQ_PUB.G_STATUS_NEW);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Insert into Adjustment Attributes - Header Level Attributes'||sql%ROWCOUNT,1,'Y');
    END IF;


    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('ASO_PRICING_CORE_PVT:************ TERM SUBSTITUTION Starts Here ******************', 1, 'Y');
       aso_debug_pub.add('ASO_PRICING_CORE_PVT: p_qte_header_rec.quote_header_id :'||NVL(p_qte_header_rec.quote_header_id,0), 1, 'Y');
       aso_debug_pub.add('ASO_PRICING_CORE_PVT: p_insert_type :'||p_insert_type, 1, 'Y');
    END IF;

    PROCESS_HDR_TSN(p_qte_header_rec.quote_header_id);

    PROCESS_LN_TSN(p_qte_header_rec.quote_header_id, p_insert_type);


    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('ASO_PRICING_CORE_PVT:************ TERM SUBSTITUTION Ends Here ******************', 1, 'Y');
    END IF;

Elsif p_insert_type = 'NO_HDR' then
   /*p_insert_type <> 'HDR'*/
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Only insert line level adjustments and relationships and attribs',1,'Y');
   END IF;

INSERT INTO ASO_PRICE_ADJUSTMENTS
      (price_adjustment_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      quote_header_id,
      quote_line_id,
      MODIFIER_HEADER_ID,
      MODIFIER_LINE_ID,
      MODIFIER_LINE_TYPE_CODE,
      MODIFIED_FROM,
      MODIFIED_TO,
      OPERAND,
      ARITHMETIC_OPERATOR,
      AUTOMATIC_FLAG,
      UPDATE_ALLOWABLE_FLAG,
      UPDATED_FLAG,
      APPLIED_FLAG,
      ON_INVOICE_FLAG,
      CHARGE_TYPE_CODE,
      PRICING_PHASE_ID,
      PRICING_GROUP_SEQUENCE,
      PRICE_BREAK_TYPE_CODE,
      ADJUSTED_AMOUNT,
      MODIFIER_LEVEL_CODE,
      ACCRUAL_FLAG,
      LIST_LINE_NO,
      ACCRUAL_CONVERSION_RATE,
      EXPIRATION_DATE,
      CHARGE_SUBTYPE_CODE,
      INCLUDE_ON_RETURNS_FLAG,
      BENEFIT_QTY,
      BENEFIT_UOM_CODE,
      PRORATION_TYPE_CODE,
      REBATE_TRANSACTION_TYPE_CODE,
      range_break_quantity,
      MODIFIER_MECHANISM_TYPE_CODE,
      SUBSTITUTION_ATTRIBUTE,
      change_reason_code,
      change_reason_text,
      update_allowed,
	 operand_per_pqty,
	 adjusted_amount_per_pqty
      )(
     SELECT
                nvl(ldets_v.PRICE_ADJUSTMENT_ID,ASO_PRICE_ADJUSTMENTS_S.nextval),
                sysdate
               ,fnd_global.user_id
               ,sysdate
               ,fnd_global.user_id
               ,fnd_global.login_id
               ,p_qte_header_rec.quote_header_id,
               lines.line_id,
               ldets_v.list_header_id,
               ldets_v.list_line_id,
               ldets_v.list_line_type_code,
               NULL,
               NULL,
               ldets_v.ORDER_QTY_OPERAND,
               ldets_v.Operand_Calculation_Code,
               ldets_v.Automatic_flag,
               ldets_v.Override_flag,
               ldets_v.UPDATED_FLAG,
               ldets_v.Applied_Flag,
               ldets_v.Print_On_Invoice_Flag,
               ldets_v.CHARGE_TYPE_CODE,
               ldets_v.Pricing_phase_id,
               ldets_v.PRICING_GROUP_SEQUENCE,
               ldets_v.PRICE_BREAK_TYPE_CODE,
               ldets_v.ORDER_QTY_ADJ_AMT,
               ldets_v.MODIFIER_LEVEL_CODE,
               ldets_v.ACCRUAL_FLAG,
               ldets_v.LIST_LINE_NO,
               ldets_v.ACCRUAL_CONVERSION_RATE,
               ldets_v.EXPIRATION_DATE,
               ldets_v.CHARGE_SUBTYPE_CODE,
               ldets_v.INCLUDE_ON_RETURNS_FLAG,
               ldets_v.BENEFIT_QTY,
               ldets_v.BENEFIT_UOM_CODE,
               ldets_v.PRORATION_TYPE_CODE,
               ldets_v.REBATE_TRANSACTION_TYPE_CODE,
               ldets_v.Line_quantity,
               ldets_v.Calculation_code,
               ldets_v.SUBSTITUTION_ATTRIBUTE,
               ldets_v.change_reason_code,
               ldets_v.change_reason_text,
               ldets_v.OVERRIDE_FLAG,
			ldets_v.operand_value,
			ldets_v.adjustment_amount
       FROM    QP_PREQ_LINES_TMP lines,
               QP_LDETS_V ldets_v
       WHERE lines.line_index = ldets_v.line_index
	  AND   ldets_v.modifier_level_code = 'LINE'
	  AND   lines.process_status IN (QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_UNCHANGED)
	  AND   nvl(ldets_v.Calculation_code,'X') <> QP_PREQ_PUB.G_FREEGOOD
       AND   ldets_v.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
       AND   ldets_v.process_code = QP_PREQ_GRP.G_STATUS_NEW
       AND   nvl(ldets_v.created_from_list_type_code,'X') not in ('PRL','AGR'));

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:Insert into Adjustment '||sql%ROWCOUNT,1,'Y');
END IF;


IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('',1,'Y');
aso_debug_pub.add('',1,'Y');
aso_debug_pub.add('*****************QP_PREQ_RLTD_LINES_TMP*****************************************',1,'Y');
For C_QP_PREQ_RLTD_LINES_TMP_REC in C_QP_PREQ_RLTD_LINES_TMP loop
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.REQUEST_TYPE_CODE:'||C_QP_PREQ_RLTD_LINES_TMP_REC.REQUEST_TYPE_CODE,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.LINE_INDEX:'||C_QP_PREQ_RLTD_LINES_TMP_REC.LINE_INDEX,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.LINE_DETAIL_INDEX:'||C_QP_PREQ_RLTD_LINES_TMP_REC.LINE_DETAIL_INDEX,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.RELATIONSHIP_TYPE_CODE:'||C_QP_PREQ_RLTD_LINES_TMP_REC.RELATIONSHIP_TYPE_CODE,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.RELATED_LINE_INDEX:'||C_QP_PREQ_RLTD_LINES_TMP_REC.RELATED_LINE_INDEX,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.RELATED_LINE_DETAIL_INDEX:'||C_QP_PREQ_RLTD_LINES_TMP_REC.RELATED_LINE_DETAIL_INDEX,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.PRICING_STATUS_CODE:'||C_QP_PREQ_RLTD_LINES_TMP_REC.PRICING_STATUS_CODE,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.PRICING_STATUS_TEXT:'||C_QP_PREQ_RLTD_LINES_TMP_REC.PRICING_STATUS_TEXT,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.LIST_LINE_ID:'||C_QP_PREQ_RLTD_LINES_TMP_REC.LIST_LINE_ID,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.RELATED_LIST_LINE_ID:'||C_QP_PREQ_RLTD_LINES_TMP_REC.RELATED_LIST_LINE_ID,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.RELATED_LIST_LINE_TYPE:'||C_QP_PREQ_RLTD_LINES_TMP_REC.RELATED_LIST_LINE_TYPE,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.OPERAND_CALCULATION_CODE:'||C_QP_PREQ_RLTD_LINES_TMP_REC.OPERAND_CALCULATION_CODE,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.OPERAND:'||C_QP_PREQ_RLTD_LINES_TMP_REC.OPERAND,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.PRICING_GROUP_SEQUENCE:'||C_QP_PREQ_RLTD_LINES_TMP_REC.PRICING_GROUP_SEQUENCE,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.RELATIONSHIP_TYPE_DETAIL:'||C_QP_PREQ_RLTD_LINES_TMP_REC.RELATIONSHIP_TYPE_DETAIL,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.SETUP_VALUE_FROM:'||C_QP_PREQ_RLTD_LINES_TMP_REC.SETUP_VALUE_FROM,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.SETUP_VALUE_TO:'||C_QP_PREQ_RLTD_LINES_TMP_REC.SETUP_VALUE_TO,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.QUALIFIER_VALUE:'||C_QP_PREQ_RLTD_LINES_TMP_REC.QUALIFIER_VALUE,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.ADJUSTMENT_AMOUNT:'||C_QP_PREQ_RLTD_LINES_TMP_REC.ADJUSTMENT_AMOUNT,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.SATISFIED_RANGE_VALUE:'||C_QP_PREQ_RLTD_LINES_TMP_REC.SATISFIED_RANGE_VALUE,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.REQUEST_ID:'||C_QP_PREQ_RLTD_LINES_TMP_REC.REQUEST_ID,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.process_status:'||C_QP_PREQ_RLTD_LINES_TMP_REC.process_status,1,'Y');
aso_debug_pub.add('C_QP_PREQ_RLTD_LINES_TMP_REC.line_id:'||C_QP_PREQ_RLTD_LINES_TMP_REC.line_id,1,'Y');
aso_debug_pub.add('*****************NEXT ADJUSTMENT RELATIONSHIP*****************************************',1,'Y');

End Loop;

END IF;
/*
 * Insert to Price Adj Relationships
 *
 */

        INSERT INTO ASO_PRICE_ADJ_RELATIONSHIPS
        (adj_relationship_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        quote_line_id,
        price_adjustment_id,
        rltd_price_adj_id
        )
        (SELECT  ASO_PRICE_RELATIONSHIPS_S.nextval
                ,sysdate
                ,fnd_global.user_id
                ,sysdate
                ,fnd_global.user_id
                ,fnd_global.login_id
                ,adj.QUOTE_LINE_ID
                ,ADJ.PRICE_ADJUSTMENT_ID
                ,RADJ.PRICE_ADJUSTMENT_ID
         FROM
               QP_PREQ_RLTD_LINES_TMP RLTD,
               QP_PREQ_LINES_TMP LINE,
			QP_PREQ_LINES_TMP RLTD_LINE,
               ASO_PRICE_ADJUSTMENTS ADJ,
               ASO_PRICE_ADJUSTMENTS RADJ
        WHERE RLTD.PRICING_STATUS_CODE = QP_PREQ_PUB.G_STATUS_NEW
        AND RLTD_LINE.line_index = RLTD.related_line_index
        AND RLTD.Relationship_Type_Code in
            (QP_PREQ_GRP.G_PBH_LINE ,QP_PREQ_GRP.G_GENERATED_LINE )
        AND line.line_index = rltd.line_index
        AND adj.quote_header_id = p_qte_header_rec.quote_header_id
        AND adj.quote_line_id = line.line_id
        AND line.line_type_code = 'LINE'
        AND line.process_status IN (QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_UNCHANGED)
        AND adj.modifier_line_id = rltd.list_line_id
        AND radj.quote_header_id = p_qte_header_rec.quote_header_id
        AND radj.quote_line_id = rltd_line.line_id
        AND radj.modifier_line_id = rltd.related_list_line_id);

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:Insert into Adjustment Relationships '||sql%ROWCOUNT,1,'Y');
END IF;


/*
 * Insert into Price Adj Attributes - Line Attributes
 */


 -- Added hint to fix perf bug 5614878.

 INSERT INTO ASO_PRICE_ADJ_ATTRIBS
              (  price_adj_attrib_id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                price_adjustment_id,
                pricing_context,
                pricing_attribute,
                pricing_attr_value_from,
                pricing_attr_value_to,
                comparison_operator,
                flex_title)
                (SELECT /*+ ORDERED USE_NL(LINES LDETS QPLAT ADJ) INDEX(LINES) INDEX(LDETS) INDEX(QPLAT  QP_PREQ_LINE_ATTRS_TMP_N3) */ ASO_PRICE_ADJ_ATTRIBS_S.nextval,
                 sysdate
                ,fnd_global.user_id
                ,sysdate
                ,fnd_global.user_id
                ,fnd_global.login_id
                ,ADJ.PRICE_ADJUSTMENT_ID
                ,QPLAT.CONTEXT
                ,QPLAT.ATTRIBUTE
                ,nvl(QPLAT.SETUP_VALUE_FROM,QPLAT.VALUE_FROM)
                ,QPLAT.SETUP_VALUE_TO
                ,QPLAT.COMPARISON_OPERATOR_TYPE_CODE
                ,decode(QPLAT.ATTRIBUTE_TYPE,
                        'QUALIFIER','QP_ATTR_DEFNS_QUALIFIER',
                        'QP_ATTR_DEFNS_PRICING')
               FROM
                  ASO_PRICE_ADJUSTMENTS ADJ,
                  QP_PREQ_LINES_TMP LINES ,
                  QP_PREQ_LDETS_TMP LDETS,
                  QP_PREQ_LINE_ATTRS_TMP QPLAT
              WHERE ADJ.QUOTE_HEADER_ID = p_qte_header_rec.quote_header_id
              AND LINES.LINE_ID = ADJ.QUOTE_LINE_ID
              AND lines.process_status IN (QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_UNCHANGED)
              AND LDETS.LINE_INDEX = LINES.LINE_INDEX
              AND LDETS.PRICING_PHASE_ID = ADJ.PRICING_PHASE_ID
              AND LDETS.PRICING_STATUS_CODE = QP_PREQ_PUB.G_STATUS_NEW
              AND LDETS.CREATED_FROM_LIST_LINE_ID = ADJ.MODIFIER_LINE_ID
              AND LDETS.CREATED_FROM_LIST_HEADER_ID = ADJ.MODIFIER_HEADER_ID
              AND QPLAT.LINE_DETAIL_INDEX = LDETS.LINE_DETAIL_INDEX
              AND QPLAT.PRICING_STATUS_CODE = QP_PREQ_PUB.G_STATUS_NEW);

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:Insert into Adjustment Attributes - Line Level Attributes'||sql%ROWCOUNT,1,'Y');
END IF;

 PROCESS_LN_TSN(p_qte_header_rec.quote_header_id, p_insert_type);

ELSE
/* p_insert_type = 'HDR_ONLY' */

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:p_insert_type: '||p_insert_type,1,'Y');
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:Inserting only header level adjustments',1,'Y');
END IF;

INSERT INTO ASO_PRICE_ADJUSTMENTS
      (price_adjustment_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      quote_header_id,
      quote_line_id,
      MODIFIER_HEADER_ID,
      MODIFIER_LINE_ID,
      MODIFIER_LINE_TYPE_CODE,
      MODIFIED_FROM,
      MODIFIED_TO,
      OPERAND,
      ARITHMETIC_OPERATOR,
      AUTOMATIC_FLAG,
      UPDATE_ALLOWABLE_FLAG,
      UPDATED_FLAG,
      APPLIED_FLAG,
      ON_INVOICE_FLAG,
      CHARGE_TYPE_CODE,
      PRICING_PHASE_ID,
      PRICING_GROUP_SEQUENCE,
      PRICE_BREAK_TYPE_CODE,
      ADJUSTED_AMOUNT,
      MODIFIER_LEVEL_CODE,
      ACCRUAL_FLAG,
      LIST_LINE_NO,
      ACCRUAL_CONVERSION_RATE,
      EXPIRATION_DATE,
      CHARGE_SUBTYPE_CODE,
      INCLUDE_ON_RETURNS_FLAG,
      BENEFIT_QTY,
      BENEFIT_UOM_CODE,
      PRORATION_TYPE_CODE,
      REBATE_TRANSACTION_TYPE_CODE,
      range_break_quantity,
      MODIFIER_MECHANISM_TYPE_CODE,
      SUBSTITUTION_ATTRIBUTE,
      change_reason_code,
      change_reason_text,
      update_allowed,
	 operand_per_pqty,
	 adjusted_amount_per_pqty
      )(
     SELECT
                nvl(ldets_v.PRICE_ADJUSTMENT_ID,ASO_PRICE_ADJUSTMENTS_S.nextval),
                sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               fnd_global.login_id,
               p_qte_header_rec.quote_header_id,
               decode(ldets_v.modifier_level_code,'ORDER',NULL,lines.line_id),
               ldets_v.list_header_id,
               ldets_v.list_line_id,
               ldets_v.list_line_type_code,
               NULL,
               NULL,
               ldets_v.ORDER_QTY_OPERAND,
               ldets_v.Operand_Calculation_Code,
               ldets_v.Automatic_flag,
               ldets_v.Override_flag,
               ldets_v.UPDATED_FLAG,
               ldets_v.Applied_Flag,
               ldets_v.Print_On_Invoice_Flag,
               ldets_v.CHARGE_TYPE_CODE,
               ldets_v.Pricing_phase_id,
               ldets_v.PRICING_GROUP_SEQUENCE,
               ldets_v.PRICE_BREAK_TYPE_CODE,
               ldets_v.ORDER_QTY_ADJ_AMT,
               ldets_v.MODIFIER_LEVEL_CODE,
               ldets_v.ACCRUAL_FLAG,
               ldets_v.LIST_LINE_NO,
               ldets_v.ACCRUAL_CONVERSION_RATE,
               ldets_v.EXPIRATION_DATE,
               ldets_v.CHARGE_SUBTYPE_CODE,
               ldets_v.INCLUDE_ON_RETURNS_FLAG,
               ldets_v.BENEFIT_QTY,
               ldets_v.BENEFIT_UOM_CODE,
               ldets_v.PRORATION_TYPE_CODE,
               ldets_v.REBATE_TRANSACTION_TYPE_CODE,
               decode(ldets_v.modifier_level_code,'ORDER',NULL,ldets_v.Line_quantity),
               decode(ldets_v.modifier_level_code,'ORDER',NULL,ldets_v.Calculation_code),
               ldets_v.SUBSTITUTION_ATTRIBUTE,
               ldets_v.change_reason_code,
               ldets_v.change_reason_text,
               ldets_v.OVERRIDE_FLAG,
			ldets_v.operand_value,
			ldets_v.adjustment_amount
       FROM    QP_PREQ_LINES_TMP lines,
               QP_LDETS_V ldets_v
       WHERE lines.line_index = ldets_v.line_index
	  AND   lines.process_status IN (QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_UNCHANGED)
       AND   ldets_v.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
       AND   ldets_v.process_code = QP_PREQ_GRP.G_STATUS_NEW
       AND   nvl(ldets_v.created_from_list_type_code,'X') not in ('PRL','AGR')
	  AND   ldets_v.modifier_level_code = 'ORDER');

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('ASO_PRICING_CORE_PVT:Insert into Adjustment '||sql%ROWCOUNT,1,'Y');
END IF;


 -- Added hint to fix perf bug 5614878.

              INSERT INTO ASO_PRICE_ADJ_ATTRIBS
              (  price_adj_attrib_id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                price_adjustment_id,
                pricing_context,
                pricing_attribute,
                pricing_attr_value_from,
                pricing_attr_value_to,
                comparison_operator,
                flex_title)
                (SELECT /*+ ORDERED USE_NL(LINES LDETS QPLAT ADJ) INDEX(LINES) INDEX(LDETS) INDEX(QPLAT  QP_PREQ_LINE_ATTRS_TMP_N3) */ ASO_PRICE_ADJ_ATTRIBS_S.nextval,
                 sysdate
                ,fnd_global.user_id
                ,sysdate
                ,fnd_global.user_id
                ,fnd_global.login_id
                ,ADJ.PRICE_ADJUSTMENT_ID
                ,QPLAT.CONTEXT
                ,QPLAT.ATTRIBUTE
                ,nvl(QPLAT.SETUP_VALUE_FROM,QPLAT.VALUE_FROM)
                ,QPLAT.SETUP_VALUE_TO
                ,QPLAT.COMPARISON_OPERATOR_TYPE_CODE
                ,decode(QPLAT.ATTRIBUTE_TYPE,
                        'QUALIFIER','QP_ATTR_DEFNS_QUALIFIER',
                        'QP_ATTR_DEFNS_PRICING')
               FROM
                  ASO_PRICE_ADJUSTMENTS ADJ,
                  QP_PREQ_LINES_TMP LINES ,
                  QP_PREQ_LDETS_TMP LDETS,
                  QP_PREQ_LINE_ATTRS_TMP QPLAT
              WHERE ADJ.QUOTE_HEADER_ID = p_qte_header_rec.quote_header_id
              AND LINES.LINE_ID = ADJ.QUOTE_HEADER_ID
              AND LDETS.LINE_INDEX = LINES.LINE_INDEX
              AND lines.process_status IN (QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_UNCHANGED)
              AND LDETS.PRICING_PHASE_ID = ADJ.PRICING_PHASE_ID
              AND LDETS.PRICING_STATUS_CODE = QP_PREQ_PUB.G_STATUS_NEW
              AND LDETS.CREATED_FROM_LIST_LINE_ID = ADJ.MODIFIER_LINE_ID
              AND LDETS.CREATED_FROM_LIST_HEADER_ID = ADJ.MODIFIER_HEADER_ID
              AND QPLAT.LINE_DETAIL_INDEX = LDETS.LINE_DETAIL_INDEX
              AND QPLAT.PRICING_STATUS_CODE = QP_PREQ_PUB.G_STATUS_NEW);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Insert Adjustment Attributes - Header Level Attributes'||sql%ROWCOUNT,1,'Y');
    END IF;

    PROCESS_HDR_TSN(p_qte_header_rec.quote_header_id);


End If;--If p_insert_type = 'HDR'

End if;--If p_control_rec.price_mode = 'BATCH'
Else
   --l_db_line_counter is zero.
   --Just Insert ASO_PRICE_ADJUSTMENTS only.

INSERT INTO ASO_PRICE_ADJUSTMENTS
      (price_adjustment_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      quote_header_id,
      quote_line_id,
      MODIFIER_HEADER_ID,
      MODIFIER_LINE_ID,
      MODIFIER_LINE_TYPE_CODE,
      MODIFIED_FROM,
      MODIFIED_TO,
      OPERAND,
      ARITHMETIC_OPERATOR,
      AUTOMATIC_FLAG,
      UPDATE_ALLOWABLE_FLAG,
      UPDATED_FLAG,
      APPLIED_FLAG,
      ON_INVOICE_FLAG,
      CHARGE_TYPE_CODE,
      PRICING_PHASE_ID,
      PRICING_GROUP_SEQUENCE,
      PRICE_BREAK_TYPE_CODE,
      ADJUSTED_AMOUNT,
      MODIFIER_LEVEL_CODE,
      ACCRUAL_FLAG,
      LIST_LINE_NO,
      ACCRUAL_CONVERSION_RATE,
      EXPIRATION_DATE,
      CHARGE_SUBTYPE_CODE,
      INCLUDE_ON_RETURNS_FLAG,
      BENEFIT_QTY,
      BENEFIT_UOM_CODE,
      PRORATION_TYPE_CODE,
      REBATE_TRANSACTION_TYPE_CODE,
      range_break_quantity,
      MODIFIER_MECHANISM_TYPE_CODE,
      SUBSTITUTION_ATTRIBUTE,
      change_reason_code,
      change_reason_text,
      update_allowed,
	 operand_per_pqty,
	 adjusted_amount_per_pqty
      )(
     SELECT
                nvl(ldets_v.PRICE_ADJUSTMENT_ID,ASO_PRICE_ADJUSTMENTS_S.nextval),
                sysdate
               ,fnd_global.user_id
               ,sysdate
               ,fnd_global.user_id
               ,fnd_global.login_id
               ,p_qte_header_rec.quote_header_id,
               decode(ldets_v.modifier_level_code,'ORDER',NULL,lines.line_id),
               ldets_v.list_header_id,
               ldets_v.list_line_id,
               ldets_v.list_line_type_code,
               NULL,
               NULL,
			ldets_v.ORDER_QTY_OPERAND,
               ldets_v.Operand_Calculation_Code,
               ldets_v.Automatic_flag,
               ldets_v.Override_flag,
               ldets_v.UPDATED_FLAG,
               ldets_v.Applied_Flag,
               ldets_v.Print_On_Invoice_Flag,
               ldets_v.CHARGE_TYPE_CODE,
               ldets_v.Pricing_phase_id,
               ldets_v.PRICING_GROUP_SEQUENCE,
               ldets_v.PRICE_BREAK_TYPE_CODE,
			ldets_v.ORDER_QTY_ADJ_AMT,
               ldets_v.MODIFIER_LEVEL_CODE,
               ldets_v.ACCRUAL_FLAG,
               ldets_v.LIST_LINE_NO,
               ldets_v.ACCRUAL_CONVERSION_RATE,
               ldets_v.EXPIRATION_DATE,
               ldets_v.CHARGE_SUBTYPE_CODE,
               ldets_v.INCLUDE_ON_RETURNS_FLAG,
               ldets_v.BENEFIT_QTY,
               ldets_v.BENEFIT_UOM_CODE,
               ldets_v.PRORATION_TYPE_CODE,
               ldets_v.REBATE_TRANSACTION_TYPE_CODE,
               decode(ldets_v.modifier_level_code,'ORDER',NULL,ldets_v.Line_quantity),
               decode(ldets_v.modifier_level_code,'ORDER',NULL,ldets_v.Calculation_code),
               ldets_v.SUBSTITUTION_ATTRIBUTE,
               ldets_v.change_reason_code,
               ldets_v.change_reason_text,
               ldets_v.OVERRIDE_FLAG,
			ldets_v.operand_value,
			ldets_v.adjustment_amount
       FROM    QP_PREQ_LINES_TMP lines,
               QP_LDETS_V ldets_v
       WHERE lines.line_index = ldets_v.line_index
       AND   ldets_v.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
       AND   ldets_v.process_code = QP_PREQ_GRP.G_STATUS_NEW
       AND   nvl(ldets_v.created_from_list_type_code,'X') not in ('PRL','AGR')
	  AND   nvl(ldets_v.list_line_type_code,'X') <> 'FREIGHT_CHARGE');


end if;--l_db_line_counter<>0
/***********************************************************
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   aso_debug_pub.add('ASO_PRICING_CORE_PVT:************ TERM SUBSTITUTION Starts Here ******************', 1, 'Y');
   aso_debug_pub.add('ASO_PRICING_CORE_PVT: p_qte_header_rec.quote_header_id :'||NVL(p_qte_header_rec.quote_header_id,0), 1, 'Y');
   aso_debug_pub.add('ASO_PRICING_CORE_PVT: p_insert_type :'||p_insert_type, 1, 'Y');
END IF;

If p_insert_type = 'HDR' then

   PROCESS_HDR_TSN(p_qte_header_rec.quote_header_id);

   PROCESS_LN_TSN(p_qte_header_rec.quote_header_id);


   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:************ TERM SUBSTITUTION Ends Here ******************', 1, 'Y');
   END IF;
end if;
*******************************************/

 -- Standard check for p_commit
IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
END IF;

 FND_MSG_PUB.Count_And_Get
      ( p_encoded    => 'F',
        p_count      =>   x_msg_count,
        p_data       =>   x_msg_data
      );

 for l in 1 ..x_msg_count loop
    x_msg_data := fnd_msg_pub.get( p_msg_index => l, p_encoded => 'F');
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Messge count and get '||x_msg_data, 1, 'Y');
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Messge count and get '||x_msg_count, 1, 'Y');
    END IF;
 end loop;

END Copy_Price_To_Quote;

FUNCTION Modify_Global_PlsIndex_Table (
               p_global_tbl            IN QP_PREQ_GRP.pls_integer_type,
               p_search_tbl            IN Index_Link_Tbl_Type)
RETURN QP_PREQ_GRP.pls_integer_type IS
  i NUMBER;
  l_global_tbl QP_PREQ_GRP.pls_integer_type;
BEGIN
  l_global_tbl.delete;
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Start Modify_Global_PlsIndex_Table ',1,'Y');
  END IF;

  For i in 1..p_global_tbl.count LOOP
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:i:'||i,1,'Y');
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:p_global_tbl(i):'||p_global_tbl(i),1,'Y');
       END IF;

	  If p_global_tbl(i) = 1 then
		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				aso_debug_pub.add('This is a header record value assigned 1',1,'Y');
          END IF;
		l_global_tbl(i) := 1;
	  Else
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:p_search_tbl(p_global_tbl(i)):'||p_search_tbl(p_global_tbl(i)),1,'Y');
          l_global_tbl(i) := p_search_tbl(p_global_tbl(i));
	  End If;
  END LOOP;--End for loop
  RETURN l_global_tbl;

END Modify_Global_PlsIndex_Table;

FUNCTION Modify_Global_NumIndex_Table (
               p_global_tbl            IN QP_PREQ_GRP.NUMBER_TYPE,
               p_search_tbl            IN Index_Link_Tbl_Type)
RETURN QP_PREQ_GRP.NUMBER_TYPE IS
  i NUMBER;
  l_global_tbl QP_PREQ_GRP.NUMBER_TYPE;
BEGIN
  l_global_tbl.delete;
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Start Modify_Global_NumIndex_Table ',1,'Y');
  END IF;

  For i in 1..p_global_tbl.count LOOP
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:i:'||i,1,'Y');
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:p_global_tbl(i):'||p_global_tbl(i),1,'Y');
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:p_search_tbl(p_global_tbl(i)):'||p_search_tbl(p_global_tbl(i)),1,'Y');
       END IF;
      l_global_tbl(i) := p_search_tbl(p_global_tbl(i));
  END LOOP;--End for loop
  RETURN l_global_tbl;

END Modify_Global_NumIndex_Table;


PROCEDURE Process_Charges(
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     P_control_rec              IN   ASO_PRICING_INT.Pricing_Control_Rec_Type,
     p_qte_header_rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */ NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS

CURSOR c_qte_sum IS
SELECT sum(NVL(LINE_LIST_PRICE*quantity, 0)) total_list_price,
sum(NVL(line_adjusted_amount*quantity,NVL(LINE_ADJUSTED_PERCENT*LINE_LIST_PRICE*quantity,0))) ln_total_discount
FROM ASO_QUOTE_LINES_ALL
WHERE QUOTE_HEADER_ID = p_qte_header_rec.quote_header_id;

l_api_name                    CONSTANT VARCHAR2(30) := 'Process_Charges';
l_api_version_number          CONSTANT NUMBER   := 1.0;
G_USER_ID                     NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID                    NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
l_last_update_date            Date := SYSDATE;
l_line_shipping_charge        NUMBER := 0;
l_hdr_shipping_charge         NUMBER := 0;
l_total_list_price            NUMBER;
l_ln_total_discount           NUMBER;
ls_qte_line_tbl               ASO_QUOTE_PUB.Qte_Line_Tbl_Type;

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
          FND_MSG_PUB.initialize;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Start Process_Charges ',1,'Y');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Start Process_Charges:p_control_rec.pricing_event: '
                         ||p_control_rec.pricing_event,1,'Y');
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Start Process_Charges:p_control_rec.calculate_flag: '
                         ||p_control_rec.calculate_flag,1,'Y');
    END IF;

If (p_control_rec.pricing_event = 'BATCH') OR (p_control_rec.pricing_event = 'ORDER') then

l_hdr_shipping_charge := ASO_SHIPPING_INT.Get_Header_Freight_Charges(p_qte_header_rec.quote_header_id);
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Before Update ASO_SHIPMENTS:l_hdr_shipping_charge: '
                         ||l_hdr_shipping_charge,1,'Y');
END IF;
         UPDATE ASO_SHIPMENTS
               SET SHIP_QUOTE_PRICE = l_hdr_shipping_charge,
               last_update_date = l_last_update_date,
               last_updated_by = G_USER_ID,
               last_update_login = G_LOGIN_ID
               WHERE  QUOTE_HEADER_ID = p_qte_header_rec.quote_header_id
               AND  QUOTE_LINE_ID is NULL;

--Should not update the line levelfeight charges as in Calculate only call we only get updated order level modifiers

If p_control_rec.calculate_flag <> QP_PREQ_GRP.G_CALCULATE_ONLY then
 /*Query the line table to pass it to ASO_SHIPPING_INT*/
  ls_qte_line_tbl := ASO_UTILITY_PVT.Query_Qte_Line_Rows(p_qte_header_rec.quote_header_id);
  FOR i IN 1..ls_qte_line_tbl.count LOOP
   l_line_shipping_charge := ASO_SHIPPING_INT.get_line_freight_charges
                              (p_qte_header_rec.quote_header_id,ls_qte_line_tbl(i).quote_line_id);
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Before Update ASO_SHIPMENTS:quote_line_id: '||ls_qte_line_tbl(i).quote_line_id
                         ||' line charge for the quote line:'||l_line_shipping_charge,1,'Y');
   END IF;

        UPDATE ASO_SHIPMENTS
             SET SHIP_QUOTE_PRICE = l_line_shipping_charge,
               QUANTITY = ls_qte_line_tbl(i).quantity,
               last_update_date = l_last_update_date,
               last_updated_by = G_USER_ID,
               last_update_login = G_LOGIN_ID
             WHERE  QUOTE_HEADER_ID = p_qte_header_rec.quote_header_id
             AND  QUOTE_LINE_ID   =  ls_qte_line_tbl(i).quote_line_id;
  END LOOP;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_CORE_PVT:Update Shipment info and before calling get_line_freight_charges Ends', 1, 'Y');
    aso_debug_pub.add('ASO_PRICING_CORE_PVT:Cursor c_qte_sum opens and update of total for ASO_QUOTE_HEADERS_ALL Starts',1,'Y');
  END IF;

  OPEN c_qte_sum;
  FETCH c_qte_sum INTO l_total_list_price, l_ln_total_discount;
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PRICING_CORE_PVT:Before Update ASO_QUOTE_HEADERS_ALL l_total_list_price:'||l_total_list_price, 1, 'Y');
    aso_debug_pub.add('ASO_PRICING_CORE_PVT:Before Update ASO_QUOTE_HEADERS_ALL l_ln_total_discount:'||l_ln_total_discount,1,'Y');
  END IF;
  CLOSE c_qte_sum;
     UPDATE ASO_QUOTE_HEADERS_ALL
            SET total_list_price = l_total_list_price,
         TOTAL_ADJUSTED_AMOUNT = l_ln_total_discount,
         total_adjusted_percent = decode(total_list_price, 0, NULL,
                    (l_ln_total_discount/total_list_price)*100),
         total_quote_price = l_total_list_price+l_ln_total_discount+
                    NVL(total_tax, 0)+
                    NVL(total_shipping_charge, 0),
               last_update_date = l_last_update_date,
               last_updated_by = G_USER_ID,
               last_update_login = G_LOGIN_ID
     WHERE quote_header_id = p_qte_header_rec.quote_header_id;
END IF; -- p_control_rec.calculate_flag <> QP_PREQ_GRP.G_CALCULATE_ONLY

END If;--If (p_control_rec.pricing_event = 'BATCH') OR (p_control_rec.pricing_event = 'ORDER')

-- Standard check for p_commit
IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
END IF;

 FND_MSG_PUB.Count_And_Get
      ( p_encoded    => 'F',
        p_count      =>   x_msg_count,
        p_data       =>   x_msg_data
      );

FND_MSG_PUB.Count_And_Get
      ( p_encoded    => 'F',
        p_count      =>   x_msg_count,
        p_data       =>   x_msg_data
      );

 for l in 1 ..x_msg_count loop
    x_msg_data := fnd_msg_pub.get( p_msg_index => l, p_encoded => 'F');
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Messge count and get '||x_msg_data, 1, 'Y');
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Messge count and get '||x_msg_count, 1, 'Y');
    END IF;
 end loop;

END Process_Charges;


PROCEDURE Process_PRG(
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     P_control_rec              IN   ASO_PRICING_INT.Pricing_Control_Rec_Type,
     p_qte_header_rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
	x_qte_line_tbl             OUT NOCOPY /* file.sql.39 change */ ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */ NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS

l_api_name                    CONSTANT VARCHAR2(30) := 'Process_PRG';
l_api_version_number          CONSTANT NUMBER   := 1.0;
l_db_line_counter             NUMBER;
l_line_counter                NUMBER;
l_adj_counter                 NUMBER;
l_rltn_counter                NUMBER;
l_adj_attr_counter            NUMBER;
l_track_var                   VARCHAR2(3):= 'N';
l_adj_exists                  VARCHAR2(3):= 'N';
lx_index_counter              Number;
l_index_counter               Number;
l_qte_line_dtl_rec            ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type:= ASO_QUOTE_PUB.G_Miss_qte_line_dtl_rec;
l_shipment_rec                ASO_QUOTE_PUB.Shipment_Rec_Type;
l_qte_line_rec                ASO_QUOTE_PUB.Qte_Line_Rec_Type;
l_shipment_tbl                ASO_QUOTE_PUB.Shipment_Tbl_Type;
l_req_control_rec             QP_PREQ_GRP.CONTROL_RECORD_TYPE;
l_return_status               VARCHAR2(1);
l_return_status_text          VARCHAR2(2000);
l_message_text                VARCHAR2(2000);
x_pass_line                   VARCHAR2(10);
l_adj_search_tbl              Index_Link_Tbl_Type;
l_qte_line_id_tbl             JTF_NUMBER_TABLE;
l_qte_adj_id_tbl              JTF_NUMBER_TABLE;
l_price_index                 Number;
px_line_index_search_tbl      ASO_PRICING_CORE_PVT.Index_Link_Tbl_Type;
l_global_pls_tbl              QP_PREQ_GRP.pls_integer_type;
l_global_num_tbl              QP_PREQ_GRP.NUMBER_TYPE;
l_parent_line_id              NUMBER;
l_def_profile_value           VARCHAR2(3);



-- Variables to hold values to be passed to ASO_QUOTE_PUB.Update_Quote()
    l_last_update_date           Date := SYSDATE;
    l_pub_control_rec            ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_Miss_Control_Rec;
    l_qte_header_rec             ASO_QUOTE_PUB.Qte_Header_Rec_type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;
    l_qte_line_tbl               ASO_QUOTE_PUB.Qte_Line_Tbl_Type := ASO_QUOTE_PUB.G_Miss_Qte_Line_Tbl;
    l_qte_line_dtl_tbl           ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type := ASO_QUOTE_PUB.G_Miss_qte_line_dtl_tbl;
    l_Price_Adjustment_Tbl       ASO_QUOTE_PUB.Price_Adj_Tbl_Type  := ASO_QUOTE_PUB.G_Miss_Price_Adj_Tbl;
    l_Price_Adj_Rltship_Tbl      ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type := ASO_QUOTE_PUB.G_Miss_Price_Adj_Rltship_Tbl;
    l_ln_price_attributes_tbl    ASO_QUOTE_PUB.Price_Attributes_Tbl_Type  := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl;
    l_ln_shipment_tbl            ASO_QUOTE_PUB.Shipment_Tbl_Type          := ASO_QUOTE_PUB.G_Miss_Shipment_Tbl;
    l_ln_sales_credit_tbl        ASO_QUOTE_PUB.Sales_Credit_Tbl_type      := ASO_QUOTE_PUB.G_Miss_Sales_Credit_Tbl;
    l_Price_Adj_Attr_Tbl         ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type    := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl;
    lx_out_Qte_Header_Rec        ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    lx_Qte_Line_Tbl              ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    lx_Qte_Line_Dtl_Tbl          ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    lx_Hd_Price_Attributes_Tbl   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    lx_Hd_Payment_Tbl            ASO_QUOTE_PUB.Payment_Tbl_Type;
    lx_Hd_Shipment_Tbl           ASO_QUOTE_PUB.Shipment_Tbl_Type;
    lx_Hd_Freight_Charge_Tbl     ASO_QUOTE_PUB.Freight_Charge_Tbl_Type ;
    lx_Hd_Tax_Detail_Tbl         ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
    lx_Hd_Attr_Ext_tbl           ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
    lx_Hd_Sales_Credit_Tbl       ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
    lx_Hd_Quote_Party_tbl        ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
    lx_Line_Attr_Ext_Tbl         ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
    lx_Line_Rltship_tbl          ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
    lx_Price_Adjustment_Tbl      ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    lx_Price_Adj_Attr_Tbl        ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
    lx_Price_Adj_Rltship_Tbl     ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
    lx_Ln_Price_Attributes_Tbl   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    lx_Ln_Payment_Tbl            ASO_QUOTE_PUB.Payment_Tbl_Type;
    lx_Ln_Shipment_Tbl           ASO_QUOTE_PUB.Shipment_Tbl_Type;
    lx_Ln_Freight_Charge_Tbl     ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
    lx_Ln_Sales_Credit_Tbl       ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
    lx_Ln_Quote_Party_tbl        ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
    lx_Ln_Tax_Detail_Tbl         ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
    X_Qte_Header_Rec             ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    X_Qte_Line_Dtl_Tbl           ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    X_Hd_Price_Attributes_Tbl    ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    X_Hd_Payment_Tbl             ASO_QUOTE_PUB.Payment_Tbl_Type;
    X_Hd_Shipment_Tbl            ASO_QUOTE_PUB.Shipment_Tbl_Type;
    X_Hd_Freight_Charge_Tbl      ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
    X_Hd_Tax_Detail_Tbl          ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
    X_Line_Attr_Ext_Tbl          ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
    X_line_rltship_tbl           ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
    X_Price_Adjustment_Tbl       ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    X_Price_Adj_Attr_Tbl         ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
    X_Price_Adj_Rltship_Tbl      ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
    X_Ln_Price_Attributes_Tbl    ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    X_Ln_Payment_Tbl             ASO_QUOTE_PUB.Payment_Tbl_Type;
    X_Ln_Shipment_Tbl            ASO_QUOTE_PUB.Shipment_Tbl_Type;
    X_Ln_Freight_Charge_Tbl      ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
    X_Ln_Tax_Detail_Tbl          ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;

/*Necessary Cursors*/

CURSOR C_PRG_LINES_TMP IS
SELECT
   lines.REQUEST_TYPE_CODE REQUEST_TYPE_CODE,
   lines.LINE_ID LINE_ID,
   lines.LINE_INDEX LINE_INDEX,
   lines.LINE_TYPE_CODE LINE_TYPE_CODE,
   lines.PRICING_EFFECTIVE_DATE PRICING_EFFECTIVE_DATE,
   lines.LINE_QUANTITY LINE_QUANTITY,
   lines.LINE_UOM_CODE LINE_UOM_CODE,
   lines.PRICED_QUANTITY PRICED_QUANTITY,
   lines.PRICED_UOM_CODE PRICED_UOM_CODE,
   lines.UOM_QUANTITY UOM_QUANTITY,
   lines.CURRENCY_CODE CURRENCY_CODE,
   lines.UNIT_PRICE UNIT_PRICE,
   lines.PERCENT_PRICE PERCENT_PRICE,
   lines.ADJUSTED_UNIT_PRICE ADJUSTED_UNIT_PRICE,
   lines.PARENT_PRICE PARENT_PRICE,
   lines.PARENT_QUANTITY PARENT_QUANTITY,
   lines.PARENT_UOM_CODE PARENT_UOM_CODE,
   lines.PROCESSING_ORDER PROCESSING_ORDER,
   lines.PROCESSED_FLAG PROCESSED_FLAG,
   lines.PROCESSED_CODE PROCESSED_CODE,
   lines.PRICE_FLAG PRICE_FLAG,
   lines.PRICING_STATUS_CODE PRICING_STATUS_CODE,
   lines.PRICING_STATUS_TEXT PRICING_STATUS_TEXT,
   lines.START_DATE_ACTIVE_FIRST START_DATE_ACTIVE_FIRST,
   lines.ACTIVE_DATE_FIRST_TYPE ACTIVE_DATE_FIRST_TYPE,
   lines.START_DATE_ACTIVE_SECOND START_DATE_ACTIVE_SECOND,
   lines.ACTIVE_DATE_SECOND_TYPE ACTIVE_DATE_SECOND_TYPE,
   lines.GROUP_QUANTITY GROUP_QUANTITY,
   lines.GROUP_AMOUNT GROUP_AMOUNT,
   lines.LINE_AMOUNT LINE_AMOUNT,
   lines.ROUNDING_FLAG ROUNDING_FLAG,
   lines.ROUNDING_FACTOR ROUNDING_FACTOR,
   lines.UPDATED_ADJUSTED_UNIT_PRICE UPDATED_ADJUSTED_UNIT_PRICE,
   lines.PRICE_REQUEST_CODE PRICE_REQUEST_CODE,
   lines.HOLD_CODE HOLD_CODE,
   lines.HOLD_TEXT HOLD_TEXT,
   lines.PRICE_LIST_HEADER_ID PRICE_LIST_HEADER_ID,
   lines.VALIDATED_FLAG VALIDATED_FLAG,
   lines.QUALIFIERS_EXIST_FLAG QUALIFIERS_EXIST_FLAG,
   lines.PRICING_ATTRS_EXIST_FLAG PRICING_ATTRS_EXIST_FLAG,
   lines.PRIMARY_QUALIFIERS_MATCH_FLAG PRIMARY_QUALIFIERS_MATCH_FLAG,
   lines.USAGE_PRICING_TYPE USAGE_PRICING_TYPE,
   lines.LINE_CATEGORY LINE_CATEGORY,
   lines.CONTRACT_START_DATE CONTRACT_START_DATE,
   lines.CONTRACT_END_DATE CONTRACT_END_DATE,
   lines.LINE_UNIT_PRICE LINE_UNIT_PRICE,
   lines.REQUEST_ID REQUEST_ID,
   lines.PROCESS_STATUS PROCESS_STATUS,
   lines.EXTENDED_PRICE EXTENDED_PRICE,
   lines.ORDER_UOM_SELLING_PRICE ORDER_UOM_SELLING_PRICE,
   lines.CATCHWEIGHT_QTY CATCHWEIGHT_QTY,
   lines.ACTUAL_ORDER_QUANTITY ACTUAL_ORDER_QUANTITY,
   attrs.ATTRIBUTE ATTRIBUTE,
   attrs.CONTEXT CONTEXT,
   attrs.VALUE_FROM VALUE_FROM
FROM QP_PREQ_LINES_TMP lines,
     QP_PREQ_LINE_ATTRS_TMP attrs
--WHERE lines.PROCESSED_CODE = QP_PREQ_PUB.G_BY_ENGINE
WHERE   lines.process_status in (QP_PREQ_GRP.G_STATUS_NEW, QP_PREQ_GRP.G_STATUS_DELETED)
AND   lines.line_index = attrs.line_index
AND   attrs.CONTEXT = 'ITEM'
AND   attrs.ATTRIBUTE = 'PRICING_ATTRIBUTE1';

CURSOR C_PRG_RLTD_INFO(l_rltd_line_index NUMBER) IS
SELECT
   LINE_INDEX,
   LINE_DETAIL_INDEX,
   RELATIONSHIP_TYPE_CODE,
   RELATED_LINE_INDEX,
   RELATED_LINE_DETAIL_INDEX,
   LIST_LINE_ID,
   RELATED_LIST_LINE_ID
FROM QP_PREQ_RLTD_LINES_TMP
WHERE RELATED_LINE_INDEX = l_rltd_line_index
AND RELATIONSHIP_TYPE_CODE = QP_PREQ_GRP.G_GENERATED_LINE;

CURSOR C_PRG_DISCOUNT_DTL(l_line_index NUMBER, l_line_detail_index NUMBER) IS
SELECT
   LINE_DETAIL_INDEX,
   LINE_DETAIL_TYPE_CODE,
   LINE_INDEX,
   LIST_HEADER_ID,
   LIST_LINE_ID,
   LIST_LINE_TYPE_CODE,
   PRICE_BREAK_TYPE_CODE,
   LINE_QUANTITY,
   ADJUSTMENT_AMOUNT,
   AUTOMATIC_FLAG,
   PRICING_PHASE_ID,
   OPERAND_CALCULATION_CODE,
   OPERAND_VALUE,
   PRICING_GROUP_SEQUENCE,
   CREATED_FROM_LIST_TYPE_CODE,
   APPLIED_FLAG,
   PRICING_STATUS_CODE,
   PRICING_STATUS_TEXT,
   LIMIT_CODE,
   LIMIT_TEXT,
   LIST_LINE_NO,
   GROUP_QUANTITY,
   UPDATED_FLAG,
   PROCESS_CODE,
   SUBSTITUTION_VALUE_TO,
   SUBSTITUTION_ATTRIBUTE,
   ACCRUAL_FLAG,
   MODIFIER_LEVEL_CODE,
   ESTIM_GL_VALUE,
   ACCRUAL_CONVERSION_RATE,
   OVERRIDE_FLAG,
   PRINT_ON_INVOICE_FLAG,
   INVENTORY_ITEM_ID,
   ORGANIZATION_ID,
   RELATED_ITEM_ID,
   RELATIONSHIP_TYPE_ID,
   ESTIM_ACCRUAL_RATE,
   EXPIRATION_DATE,
   BENEFIT_PRICE_LIST_LINE_ID,
   RECURRING_FLAG,
   BENEFIT_LIMIT,
   CHARGE_TYPE_CODE,
   CHARGE_SUBTYPE_CODE,
   BENEFIT_QTY,
   BENEFIT_UOM_CODE,
   PRORATION_TYPE_CODE,
   INCLUDE_ON_RETURNS_FLAG,
   REBATE_TRANSACTION_TYPE_CODE,
   NUMBER_EXPIRATION_PERIODS,
   EXPIRATION_PERIOD_UOM,
   COMMENTS,
   CALCULATION_CODE,
   CHANGE_REASON_CODE,
   CHANGE_REASON_TEXT,
   PRICE_ADJUSTMENT_ID,
   NET_AMOUNT_FLAG,
   ORDER_QTY_OPERAND,
   ORDER_QTY_ADJ_AMT
FROM QP_LDETS_V
WHERE line_index = l_line_index
AND line_detail_index = l_line_detail_index;

CURSOR C_ADJ_ATTR_DTL(l_line_index NUMBER, l_line_detail_index NUMBER) IS
SELECT
QPLAT.CONTEXT CONTEXT,
QPLAT.ATTRIBUTE ATTRIBUTE,
nvl(QPLAT.SETUP_VALUE_FROM,QPLAT.VALUE_FROM) VALUE_FROM,
QPLAT.SETUP_VALUE_TO VALUE_TO,
QPLAT.COMPARISON_OPERATOR_TYPE_CODE COMPARISON_OPERATOR,
decode(QPLAT.ATTRIBUTE_TYPE,
       'QUALIFIER','QP_ATTR_DEFNS_QUALIFIER',
       'QP_ATTR_DEFNS_PRICING')  FLEX_TITLE
FROM QP_PREQ_LINE_ATTRS_TMP QPLAT
WHERE QPLAT.LINE_INDEX = l_line_index
AND   QPLAT.LINE_DETAIL_INDEX = l_line_detail_index;

CURSOR C_Get_Parent_Adj_id(l_qte_line_id NUMBER, l_modifier_line_id NUMBER) IS
SELECT PRICE_ADJUSTMENT_ID
FROM ASO_PRICE_ADJUSTMENTS
WHERE quote_line_id = l_qte_line_id
AND   modifier_line_id = l_modifier_line_id;


--ER 25708040

    Cursor limit_violated_details IS
      SELECT ldets.line_index, ldets.limit_text, lines.line_id
      FROM QP_LDETS_V ldets, qp_preq_lines_tmp lines
      WHERE ldets.LIMIT_CODE IN (QP_PREQ_GRP.G_STATUS_LIMIT_EXCEEDED,  QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED )
      AND ldets.line_index = lines.line_index;

      l_line_id                   NUMBER;
      l_err_txt                   varchar2(1000);
      l_line_number               number;
      l_item                      varchar2(40);
-- End ER 25708040


BEGIN

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
          FND_MSG_PUB.initialize;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Start Process_PRG ',1,'Y');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


       /* Start ER 25708040   */
     For I in limit_violated_details LOOP
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('In Process_PRG Limits line_index'||I.line_index,1,'Y');
       aso_debug_pub.add('In Process_PRG Limits limit_text'||I.limit_text,1,'Y');
        aso_debug_pub.add('In Process_PRG Limits line_id'||I.line_id,1,'Y');

      END IF;
      l_err_txt:='N';
      IF (i.line_id = p_qte_header_rec.quote_header_id) THEN
           l_err_txt:=  '';
           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('Limit exceeded at header',1,'Y');
           END IF;
      ELSE
            l_line_id :=  i.line_id;
            IF l_line_id IS NOT NULL AND l_line_id <> 0 AND l_line_id <> FND_API.G_MISS_NUM THEN

		BEGIN
                 /*SELECT
		  ASO_LINE_NUM_INT.Get_UI_Line_Number(l_line_id) ui_line_number  , INVENTORY_ITEM
		  into l_line_number,l_item
		  FROM ASO_PVT_QUOTE_LINES_BALI_V
		  WHERE QUOTE_LINE_ID=l_line_id;  */

                  SELECT
		  ITEMS.CONCATENATED_SEGMENTS INVENTORY_ITEM
			INTO  l_item
		  FROM ASO_QUOTE_LINES_ALL QUOTE_LINES,
		  MTL_SYSTEM_ITEMS_VL ITEMS
		  WHERE QUOTE_LINE_ID               = l_line_id
		  AND QUOTE_LINES.INVENTORY_ITEM_ID = ITEMS.INVENTORY_ITEM_ID
                  AND QUOTE_LINES.ORGANIZATION_ID   = ITEMS.ORGANIZATION_ID  ;

		  l_err_txt:='Product: '||l_item||';';





                EXCEPTION
		 WHEN NO_DATA_FOUND then
                   l_err_txt:='N';
		   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                    aso_debug_pub.add('No reference data for limits',1,'Y');
                   END IF;
		  WHEN OTHERS THEN
		    l_err_txt:='N';
		    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                    aso_debug_pub.add('When others exception for limits data reference',1,'Y');
                    END IF;
		END;

	    end if; -- line id not null
       END IF; -- line id  equal to header id

       FND_MESSAGE.Set_Name('ASO', 'ASO_PROMO_LIMIT_EXCEEDED');
       FND_MESSAGE.Set_Token('INF', l_err_txt, FALSE);
       FND_MESSAGE.Set_Token('MSG_TXT', substr(I.limit_text, 1,255), FALSE);
       FND_MSG_PUB.ADD;
    end LOOP;
 /* End ER 25708040   */

   l_line_counter := 1;
   l_adj_counter  := 1;
   l_rltn_counter := 1;
   l_adj_attr_counter := 1;

   /*Prepraring for Update_Quote Call*/
   FOR C_PRG_LINES_TMP_REC in C_PRG_LINES_TMP Loop
       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:C_PRG_LINES_TMP_REC.PROCESS_STATUS: '
                            ||C_PRG_LINES_TMP_REC.PROCESS_STATUS,1,'Y');
       END IF;

       /*Setting up the line record*/
       If C_PRG_LINES_TMP_REC.PROCESS_STATUS = QP_PREQ_GRP.G_STATUS_NEW Then
	     l_track_var := 'Y'; --If there are any new prg lines then set this to 'Y'
          l_qte_line_tbl(l_line_counter).OPERATION_CODE := 'CREATE';
       end if;
       If C_PRG_LINES_TMP_REC.PROCESS_STATUS = QP_PREQ_GRP.G_STATUS_DELETED Then
          l_qte_line_tbl(l_line_counter).OPERATION_CODE := 'DELETE';
          l_qte_line_tbl(l_line_counter).quote_line_id  := C_PRG_LINES_TMP_REC.line_id;
       end if;

       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:C_PRG_LINES_TMP_REC.LINE_INDEX: '||C_PRG_LINES_TMP_REC.LINE_INDEX,1,'Y');
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:C_PRG_LINES_TMP_REC.VALUE_FROM(inventory_item_id): '
					    ||C_PRG_LINES_TMP_REC.VALUE_FROM,1,'Y');
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:C_PRG_LINES_TMP_REC.LINE_QUANTITY: '
                             ||C_PRG_LINES_TMP_REC.LINE_QUANTITY,1,'Y');
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:C_PRG_LINES_TMP_REC.LINE_UOM_CODE: '
                             ||C_PRG_LINES_TMP_REC.LINE_UOM_CODE,1,'Y');
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:C_PRG_LINES_TMP_REC.PRICE_LIST_HEADER_ID: '
                             ||C_PRG_LINES_TMP_REC.PRICE_LIST_HEADER_ID,1,'Y');
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:C_PRG_LINES_TMP_REC.CURRENCY_CODE: '
                             ||C_PRG_LINES_TMP_REC.CURRENCY_CODE,1,'Y');
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:C_PRG_LINES_TMP_REC.ORDER_UOM_SELLING_PRICE: '
                             ||C_PRG_LINES_TMP_REC.ORDER_UOM_SELLING_PRICE,1,'Y');
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:C_PRG_LINES_TMP_REC.LINE_UNIT_PRICE: '
                             ||C_PRG_LINES_TMP_REC.LINE_UNIT_PRICE,1,'Y');
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:C_PRG_LINES_TMP_REC.priced_uom_code: '
                             ||C_PRG_LINES_TMP_REC.priced_uom_code,1,'Y');
          aso_debug_pub.add('ASO_PRICING_CORE_PVT:C_PRG_LINES_TMP_REC.priced_quantity: '
                             ||C_PRG_LINES_TMP_REC.priced_quantity,1,'Y');
       END IF;

       l_qte_line_tbl(l_line_counter).Pricing_Line_Type_Indicator:= 'F';
       l_qte_line_tbl(l_line_counter).QUOTE_HEADER_ID := p_qte_header_rec.quote_header_id;
       l_qte_line_tbl(l_line_counter).INVENTORY_ITEM_ID := C_PRG_LINES_TMP_REC.VALUE_FROM;
       l_qte_line_tbl(l_line_counter).QUANTITY := C_PRG_LINES_TMP_REC.LINE_QUANTITY;
       l_qte_line_tbl(l_line_counter).UOM_CODE := C_PRG_LINES_TMP_REC.LINE_UOM_CODE;
       l_qte_line_tbl(l_line_counter).PRICED_PRICE_LIST_ID := C_PRG_LINES_TMP_REC.PRICE_LIST_HEADER_ID;
       l_qte_line_tbl(l_line_counter).RECALCULATE_FLAG := 'N';
       l_qte_line_tbl(l_line_counter).SELLING_PRICE_CHANGE := 'N';
       l_qte_line_tbl(l_line_counter).CURRENCY_CODE := C_PRG_LINES_TMP_REC.CURRENCY_CODE;
       l_qte_line_tbl(l_line_counter).LINE_QUOTE_PRICE := NVL(C_PRG_LINES_TMP_REC.ORDER_UOM_SELLING_PRICE,
                                                              C_PRG_LINES_TMP_REC.LINE_UNIT_PRICE);
       l_qte_line_tbl(l_line_counter).LINE_LIST_PRICE := C_PRG_LINES_TMP_REC.LINE_UNIT_PRICE;
       l_qte_line_tbl(l_line_counter).LINE_ADJUSTED_AMOUNT := NVL(C_PRG_LINES_TMP_REC.ORDER_UOM_SELLING_PRICE, C_PRG_LINES_TMP_REC.LINE_UNIT_PRICE)-C_PRG_LINES_TMP_REC.LINE_UNIT_PRICE;

      If C_PRG_LINES_TMP_REC.line_unit_price = 0 then
         l_qte_line_tbl(l_line_counter).LINE_ADJUSTED_PERCENT := C_PRG_LINES_TMP_REC.line_unit_price;
      else
         l_qte_line_tbl(l_line_counter).LINE_ADJUSTED_PERCENT := ((NVL(C_PRG_LINES_TMP_REC.order_uom_selling_price, C_PRG_LINES_TMP_REC.line_unit_price)-C_PRG_LINES_TMP_REC.line_unit_price)/C_PRG_LINES_TMP_REC.line_unit_price)* 100;
      end if;
	 -- priced information change
	 l_qte_line_tbl(l_line_counter).pricing_quantity_uom := C_PRG_LINES_TMP_REC.priced_uom_code;
	 l_qte_line_tbl(l_line_counter).pricing_quantity := C_PRG_LINES_TMP_REC.priced_quantity;

      /*Create detail and relationship adj records*/
      For C_PRG_RLTD_INFO_REC in C_PRG_RLTD_INFO(C_PRG_LINES_TMP_REC.line_index) LOOP

       If l_qte_line_tbl(l_line_counter).operation_code <> 'DELETE' then
         /*Create Adjustment table*/
         --l_Price_Adjustment_Tbl
         For C_PRG_DISCOUNT_DTL_REC in C_PRG_DISCOUNT_DTL(C_PRG_LINES_TMP_REC.line_index,
											   C_PRG_RLTD_INFO_REC.related_line_detail_index) loop
             IF l_adj_search_tbl.exists(C_PRG_RLTD_INFO_REC.related_line_detail_index) then
                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		       aso_debug_pub.add('ASO_PRICING_CORE_PVT: C_PRG_RLTD_INFO_REC.related_line_detail_index:'
			     			 ||C_PRG_RLTD_INFO_REC.related_line_detail_index||' already inserted',1,'Y');
                END IF;
			 l_adj_exists := 'Y';
	         ELSE
              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		       aso_debug_pub.add('ASO_PRICING_CORE_PVT: C_PRG_RLTD_INFO_REC.related_line_detail_index:'
			     			 ||C_PRG_RLTD_INFO_REC.related_line_detail_index,1,'Y');
              END IF;
              l_adj_search_tbl(C_PRG_RLTD_INFO_REC.related_line_detail_index) := l_adj_counter;
              l_Price_Adjustment_Tbl(l_adj_counter).operation_code := l_qte_line_tbl(l_line_counter).operation_code;
              l_Price_Adjustment_Tbl(l_adj_counter).qte_line_index := l_line_counter;

              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:ADJUSTMENT RECORD:',1,'Y');
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).operation_code: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).operation_code,1,'Y');
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).qte_line_index: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).qte_line_index,1,'Y');
              END IF;
              l_Price_Adjustment_Tbl(l_adj_counter).quote_header_id := p_qte_header_rec.quote_header_id;
              l_Price_Adjustment_Tbl(l_adj_counter).modifier_header_id := C_PRG_DISCOUNT_DTL_REC.list_header_id;
              l_Price_Adjustment_Tbl(l_adj_counter).modifier_line_id := C_PRG_DISCOUNT_DTL_REC.list_line_id;
              l_Price_Adjustment_Tbl(l_adj_counter).modifier_line_type_code := C_PRG_DISCOUNT_DTL_REC.list_line_type_code;
              l_Price_Adjustment_Tbl(l_adj_counter).modified_from := NULL;
              l_Price_Adjustment_Tbl(l_adj_counter).modified_to := NULL;
              l_Price_Adjustment_Tbl(l_adj_counter).operand := C_PRG_DISCOUNT_DTL_REC.order_qty_operand;
              l_Price_Adjustment_Tbl(l_adj_counter).arithmetic_operator := C_PRG_DISCOUNT_DTL_REC.Operand_Calculation_Code;
              l_Price_Adjustment_Tbl(l_adj_counter).automatic_flag := C_PRG_DISCOUNT_DTL_REC.Automatic_flag;
              l_Price_Adjustment_Tbl(l_adj_counter).update_allowable_flag := C_PRG_DISCOUNT_DTL_REC.Override_flag;
              l_Price_Adjustment_Tbl(l_adj_counter).updated_flag := C_PRG_DISCOUNT_DTL_REC.updated_flag;
              l_Price_Adjustment_Tbl(l_adj_counter).applied_flag := C_PRG_DISCOUNT_DTL_REC.Applied_Flag;
              l_Price_Adjustment_Tbl(l_adj_counter).on_invoice_flag := C_PRG_DISCOUNT_DTL_REC.Print_On_Invoice_Flag;
              l_Price_Adjustment_Tbl(l_adj_counter).charge_type_code := C_PRG_DISCOUNT_DTL_REC.charge_type_code;
              l_Price_Adjustment_Tbl(l_adj_counter).pricing_phase_id := C_PRG_DISCOUNT_DTL_REC.pricing_phase_id;
              l_Price_Adjustment_Tbl(l_adj_counter).pricing_group_sequence := C_PRG_DISCOUNT_DTL_REC.pricing_group_sequence;
              l_Price_Adjustment_Tbl(l_adj_counter).price_break_type_code := C_PRG_DISCOUNT_DTL_REC.price_break_type_code;
              l_Price_Adjustment_Tbl(l_adj_counter).adjusted_amount := C_PRG_DISCOUNT_DTL_REC.order_qty_adj_amt;
              l_Price_Adjustment_Tbl(l_adj_counter).modifier_level_code := C_PRG_DISCOUNT_DTL_REC.modifier_level_code;
              l_Price_Adjustment_Tbl(l_adj_counter).accrual_flag := C_PRG_DISCOUNT_DTL_REC.accrual_flag;
              l_Price_Adjustment_Tbl(l_adj_counter).list_line_no := C_PRG_DISCOUNT_DTL_REC.list_line_no;
              l_Price_Adjustment_Tbl(l_adj_counter).accrual_conversion_rate := C_PRG_DISCOUNT_DTL_REC.accrual_conversion_rate;
              l_Price_Adjustment_Tbl(l_adj_counter).expiration_date := C_PRG_DISCOUNT_DTL_REC.expiration_date;
              l_Price_Adjustment_Tbl(l_adj_counter).charge_subtype_code := C_PRG_DISCOUNT_DTL_REC.charge_subtype_code;
              l_Price_Adjustment_Tbl(l_adj_counter).include_on_returns_flag := C_PRG_DISCOUNT_DTL_REC.include_on_returns_flag;
              l_Price_Adjustment_Tbl(l_adj_counter).benefit_qty := C_PRG_DISCOUNT_DTL_REC.benefit_qty;
              l_Price_Adjustment_Tbl(l_adj_counter).benefit_uom_code := C_PRG_DISCOUNT_DTL_REC.benefit_uom_code;
              l_Price_Adjustment_Tbl(l_adj_counter).proration_type_code := C_PRG_DISCOUNT_DTL_REC.proration_type_code;
              l_Price_Adjustment_Tbl(l_adj_counter).rebate_transaction_type_code := C_PRG_DISCOUNT_DTL_REC.rebate_transaction_type_code;
              l_Price_Adjustment_Tbl(l_adj_counter).range_break_quantity := C_PRG_DISCOUNT_DTL_REC.Line_quantity;
              l_Price_Adjustment_Tbl(l_adj_counter).modifier_mechanism_type_code := C_PRG_DISCOUNT_DTL_REC.Calculation_code;
              l_Price_Adjustment_Tbl(l_adj_counter).change_reason_code := C_PRG_DISCOUNT_DTL_REC.change_reason_code;
              l_Price_Adjustment_Tbl(l_adj_counter).change_reason_text := C_PRG_DISCOUNT_DTL_REC.change_reason_text;
              l_Price_Adjustment_Tbl(l_adj_counter).update_allowed := C_PRG_DISCOUNT_DTL_REC.override_flag;
		    --priced information change
              l_Price_Adjustment_Tbl(l_adj_counter).operand_per_pqty := C_PRG_DISCOUNT_DTL_REC.operand_value;
              l_Price_Adjustment_Tbl(l_adj_counter).adjusted_amount_per_pqty := C_PRG_DISCOUNT_DTL_REC.adjustment_amount;

              IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).quote_header_id: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).quote_header_id,1,'Y');
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).modifier_header_id: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).modifier_header_id,1,'Y');
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).modifier_line_id: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).modifier_line_id,1,'Y');
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).modifier_line_type_code: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).modifier_line_type_code,1,'Y');
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).operand: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).operand,1,'Y');
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).arithmetic_operator: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).arithmetic_operator,1,'Y');
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).automatic_flag: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).automatic_flag,1,'Y');
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).update_allowable_flag: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).update_allowable_flag,1,'Y');
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).updated_flag: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).updated_flag,1,'Y');
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).applied_flag: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).applied_flag,1,'Y');
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).adjusted_amount: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).adjusted_amount,1,'Y');
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).modifier_level_code: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).modifier_level_code,1,'Y');
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).update_allowed: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).update_allowed,1,'Y');
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).operand_per_pqty: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).operand_per_pqty,1,'Y');
                 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl(l_adj_counter).adjusted_amount_per_pqty: '
                                    ||l_Price_Adjustment_Tbl(l_adj_counter).adjusted_amount_per_pqty,1,'Y');
              END IF;
              -- l_Price_Adj_Attr_Tbl
              For C_ADJ_ATTR_DTL_REC in C_ADJ_ATTR_DTL(C_PRG_LINES_TMP_REC.line_index,
                                                        C_PRG_RLTD_INFO_REC.related_line_detail_index) LOOP
                  l_Price_Adj_Attr_Tbl(l_adj_attr_counter).PRICE_ADJ_INDEX := l_adj_counter;
                  l_Price_Adj_Attr_Tbl(l_adj_attr_counter).OPERATION_CODE  := l_qte_line_tbl(l_line_counter).operation_code;
                  l_Price_Adj_Attr_Tbl(l_adj_attr_counter).PRICING_CONTEXT := C_ADJ_ATTR_DTL_REC.CONTEXT;
                  l_Price_Adj_Attr_Tbl(l_adj_attr_counter).PRICING_ATTRIBUTE := C_ADJ_ATTR_DTL_REC.ATTRIBUTE;
                  l_Price_Adj_Attr_Tbl(l_adj_attr_counter).PRICING_ATTR_VALUE_FROM := C_ADJ_ATTR_DTL_REC.VALUE_FROM;
                  l_Price_Adj_Attr_Tbl(l_adj_attr_counter).PRICING_ATTR_VALUE_TO := C_ADJ_ATTR_DTL_REC.VALUE_TO;
                  l_Price_Adj_Attr_Tbl(l_adj_attr_counter).COMPARISON_OPERATOR := C_ADJ_ATTR_DTL_REC.COMPARISON_OPERATOR;
                  l_Price_Adj_Attr_Tbl(l_adj_attr_counter).FLEX_TITLE := C_ADJ_ATTR_DTL_REC.FLEX_TITLE;
                  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                     aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_Price_Adj_Attr_Tbl(l_adj_attr_counter).PRICE_ADJ_INDEX:'
                                        ||l_Price_Adj_Attr_Tbl(l_adj_attr_counter).PRICE_ADJ_INDEX,1,'Y');
                     aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_Price_Adj_Attr_Tbl(l_adj_attr_counter).OPERATION_CODE:'
                                        ||l_Price_Adj_Attr_Tbl(l_adj_attr_counter).OPERATION_CODE,1,'Y');
                     aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_Price_Adj_Attr_Tbl(l_adj_attr_counter).PRICING_CONTEXT:'
                                        ||l_Price_Adj_Attr_Tbl(l_adj_attr_counter).PRICING_CONTEXT,1,'Y');
                     aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_Price_Adj_Attr_Tbl(l_adj_attr_counter).PRICING_ATTRIBUTE:'
                                        ||l_Price_Adj_Attr_Tbl(l_adj_attr_counter).PRICING_ATTRIBUTE,1,'Y');
                     aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_Price_Adj_Attr_Tbl(l_adj_attr_counter).PRICING_ATTR_VALUE_FROM:'
                                        ||l_Price_Adj_Attr_Tbl(l_adj_attr_counter).PRICING_ATTR_VALUE_FROM,1,'Y');
                     aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_Price_Adj_Attr_Tbl(l_adj_attr_counter).PRICING_ATTR_VALUE_TO:'
                                        ||l_Price_Adj_Attr_Tbl(l_adj_attr_counter).PRICING_ATTR_VALUE_TO,1,'Y');
                     aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_Price_Adj_Attr_Tbl(l_adj_attr_counter).COMPARISON_OPERATOR:'
                                        ||l_Price_Adj_Attr_Tbl(l_adj_attr_counter).COMPARISON_OPERATOR,1,'Y');
                     aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_Price_Adj_Attr_Tbl(l_adj_attr_counter).FLEX_TITLE:'
                                        ||l_Price_Adj_Attr_Tbl(l_adj_attr_counter).FLEX_TITLE,1,'Y');

                  END IF;
                  l_adj_attr_counter := l_adj_attr_counter + 1;
              END LOOP; -- C_ADJ_ATTR_DTL_REC

	    END IF;--If l_adj_search_tbl.exists(C_PRG_RLTD_INFO_REC.related_line_detail_index)

         /*Create Adjustment relationship table*/
         --l_Price_Adj_Rltship_Tbl
         l_Price_Adj_Rltship_Tbl(l_rltn_counter).operation_code := l_qte_line_tbl(l_line_counter).operation_code;

	    --First get the quote line id of the parent record.
         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: Parent Line index C_PRG_RLTD_INFO_REC.line_index:'
                               ||C_PRG_RLTD_INFO_REC.line_index,1,'Y');
         END IF;
	    SELECT LINE_ID
	    INTO l_parent_line_id
	    FROM QP_PREQ_LINES_TMP
	    WHERE LINE_INDEX = C_PRG_RLTD_INFO_REC.line_index;
	    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_parent_line_id:'||l_parent_line_id,1,'Y');
         END IF;
         l_Price_Adj_Rltship_Tbl(l_rltn_counter).QUOTE_LINE_ID := l_parent_line_id;

         /*Need to get price adjustment id of the parent record*/
         For C_Get_Parent_Adj_id_Rec in C_Get_Parent_Adj_id(l_parent_line_id,
												C_PRG_RLTD_INFO_REC.list_line_id) loop
             l_Price_Adj_Rltship_Tbl(l_rltn_counter).price_adjustment_id := C_Get_Parent_Adj_id_Rec.price_adjustment_id;
         end loop;--C_Get_Parent_Adj_id_Rec
         l_Price_Adj_Rltship_Tbl(l_rltn_counter).rltd_price_adj_index := l_adj_search_tbl(C_PRG_RLTD_INFO_REC.related_line_detail_index);
         --l_Price_Adj_Rltship_Tbl(l_rltn_counter).rltd_price_adj_index := l_adj_counter;

         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           aso_debug_pub.add('ASO_PRICING_CORE_PVT:ADJUSTMENT RELATIONSHIP RECORD:',1,'Y');
           aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adj_Rltship_Tbl(l_rltn_counter).operation_code:'
                              ||l_Price_Adj_Rltship_Tbl(l_rltn_counter).operation_code,1,'Y');
           aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adj_Rltship_Tbl(l_rltn_counter).QUOTE_LINE_ID:'
                              ||l_Price_Adj_Rltship_Tbl(l_rltn_counter).QUOTE_LINE_ID,1,'Y');
           aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adj_Rltship_Tbl(l_rltn_counter).price_adjustment_id:'
                              ||l_Price_Adj_Rltship_Tbl(l_rltn_counter).price_adjustment_id,1,'Y');
           aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adj_Rltship_Tbl(l_rltn_counter).rltd_price_adj_index:'
                              ||l_Price_Adj_Rltship_Tbl(l_rltn_counter).rltd_price_adj_index,1,'Y');
         END IF;

         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_line_counter:'||l_line_counter,1,'Y');
           aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_adj_counter:'||l_adj_counter,1,'Y');
           aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_rltn_counter:'||l_rltn_counter,1,'Y');
         END IF;
         If l_adj_exists = 'N' then
             l_adj_counter := l_adj_counter + 1;
	    End If;
	    l_adj_exists := 'N';

     End Loop;--C_PRG_DISCOUNT_DTL_REC

     l_rltn_counter := l_rltn_counter + 1;

	END If;--l_qte_line_tbl(l_line_counter).operation_code <> 'DELETE'

     END LOOP;--C_PRG_RLTD_INFO_REC

     l_line_counter:= l_line_counter + 1;

   End Loop;--C_PRG_LINES_TMP_REC

   /*Call update quote if l_qte_line_tbl.count is >0*/
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_qte_line_tbl.count:'||nvl(l_qte_line_tbl.count,0),1,'Y');
	 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adjustment_Tbl.count:'||nvl(l_Price_Adjustment_Tbl.count,0),1,'Y');
	 aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_Price_Adj_Rltship_Tbl.count:'||nvl(l_Price_Adj_Rltship_Tbl.count,0),1,'Y');
   END IF;

   If l_qte_line_tbl.count > 0 then

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Calling Update Quote for PRG lines',1,'Y');
   END IF;


   /*Setting up Header Rec*/
   l_qte_header_rec.quote_header_id := p_qte_header_rec.quote_header_id;

   Begin
       SELECT last_update_date into l_last_update_date
       FROM ASO_QUOTE_HEADERS_ALL
       WHERE quote_header_id = p_qte_header_rec.quote_header_id;

       l_qte_header_rec.last_update_date  := l_last_update_date;

   exception when no_data_found then
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	               FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
	               FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
	               FND_MSG_PUB.ADD;
            END IF;
	       raise FND_API.G_EXC_ERROR;
   end;

   -- Setting up the Control record for Update quote
   l_def_profile_value := FND_PROFILE.value('ASO_ENABLE_DEFAULTING_RULE');
   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_def_profile_value - ASO_ENABLE_DEFAULTING_RULE:'||l_def_profile_value,1,'Y');
   END IF;
   If l_def_profile_value = 'Y' then
      l_pub_control_rec.DEFAULTING_FWK_FLAG := 'Y';
	 l_pub_control_rec.DEFAULTING_FLAG := FND_API.G_TRUE;
	 l_pub_control_rec.APPLICATION_TYPE_CODE := 'QUOTING HTML';/* Need to be changed if iStore uptakes defaulting. It should be input parameter */
   Else
      l_pub_control_rec.DEFAULTING_FWK_FLAG := 'N';
	 l_pub_control_rec.DEFAULTING_FLAG := FND_API.G_FALSE;
   End If;

   ASO_QUOTE_PUB.Update_Quote(
          p_api_version_number     => 1.0,
          p_init_msg_list          => fnd_api.g_false,
          p_commit                 => fnd_api.g_false,
		P_Validation_Level       => FND_API.G_VALID_LEVEL_NONE,
		P_Control_Rec            => l_pub_control_rec,
          p_qte_header_rec         => l_qte_header_rec,
          p_qte_line_tbl            => l_qte_line_tbl,
		p_price_adjustment_Tbl   => l_price_adjustment_Tbl,
          P_Price_Adj_Attr_Tbl     => l_Price_Adj_Attr_Tbl,
		p_price_adj_rltship_Tbl  => l_price_adj_rltship_Tbl,
          X_Qte_Header_Rec         => lx_out_qte_header_rec,
          X_Qte_Line_Tbl           => lx_Qte_Line_Tbl,
          X_Qte_Line_Dtl_Tbl       => lx_Qte_Line_Dtl_Tbl,
          X_hd_Price_Attributes_Tbl => lx_hd_Price_Attributes_Tbl,
          X_hd_Payment_Tbl         => lx_hd_Payment_Tbl,
          X_hd_Shipment_Tbl        => lx_hd_Shipment_Tbl,
          X_hd_Freight_Charge_Tbl  => lx_hd_Freight_Charge_Tbl,
          X_hd_Tax_Detail_Tbl      => lx_hd_Tax_Detail_Tbl,
          X_hd_Attr_Ext_Tbl        => lX_hd_Attr_Ext_Tbl,
          X_hd_Sales_Credit_Tbl    => lx_hd_Sales_Credit_Tbl,
          X_hd_Quote_Party_Tbl     => lx_hd_Quote_Party_Tbl,
          X_Line_Attr_Ext_Tbl      => lx_Line_Attr_Ext_Tbl,
          X_line_rltship_tbl       => lx_line_rltship_tbl,
          X_Price_Adjustment_Tbl   => lx_Price_Adjustment_Tbl,
          X_Price_Adj_Attr_Tbl     => lx_Price_Adj_Attr_Tbl,
          X_Price_Adj_Rltship_Tbl  => lx_Price_Adj_Rltship_Tbl,
          X_ln_Price_Attributes_Tbl=> lx_ln_Price_Attributes_Tbl,
          X_ln_Payment_Tbl         => lx_ln_Payment_Tbl,
          X_ln_Shipment_Tbl        => lx_ln_Shipment_Tbl,
          X_ln_Freight_Charge_Tbl  => lx_ln_Freight_Charge_Tbl,
          X_ln_Tax_Detail_Tbl      => lx_ln_Tax_Detail_Tbl,
          X_Ln_Sales_Credit_Tbl    => lX_Ln_Sales_Credit_Tbl,
          X_Ln_Quote_Party_Tbl     => lX_Ln_Quote_Party_Tbl,
          X_Return_Status          => x_Return_Status,
          X_Msg_Count              => x_Msg_Count,
          X_Msg_Data               => x_Msg_Data);

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	      aso_debug_pub.add('ASO_PRICING_CORE_PVT:After Update Quote X_Return_Status:'||X_Return_Status,1,'Y');
           aso_debug_pub.add('ASO_PRICING_CORE_PVT:After Update Quote X_Msg_Count:'||X_Msg_Count,1,'Y');
	   END IF;

        IF x_return_status = FND_API.G_RET_STS_ERROR then
           raise FND_API.G_EXC_ERROR;
        elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
		 For i in 1..lx_Qte_Line_Tbl.count loop
	      aso_debug_pub.add('ASO_PRICING_CORE_PVT:After Update Quote:lx_Qte_Line_Tbl(i).quote_line_id:'
					    ||lx_Qte_Line_Tbl(i).quote_line_id,1,'Y');
           End loop;
        END IF;
	   x_Qte_Line_Tbl := lx_Qte_Line_Tbl;
	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	      aso_debug_pub.add('ASO_PRICING_CORE_PVT:After Update Quote:Count of x_Qte_Line_Tbl.count:'
					     ||x_Qte_Line_Tbl.count,1,'Y');
        END IF;
   end If;--l_qte_line_tbl.count > 1

   If l_track_var = 'Y' then
	 If p_control_rec.prg_reprice_mode = 'F' then

      ASO_PRICING_CORE_PVT.Initialize_Global_Tables;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CORE_PVT:Second call to pricing where just free lines are passed',1,'Y');
         aso_debug_pub.add('ASO_PRICING_CORE_PVT:p_control_rec.request_type:'||p_control_rec.request_type,1,'Y');
         aso_debug_pub.add('ASO_PRICING_CORE_PVT:p_control_rec.pricing_event:'||p_control_rec.pricing_event,1,'Y');
         aso_debug_pub.add('ASO_PRICING_CORE_PVT:p_qte_header_rec.quote_header_id:'||p_qte_header_rec.quote_header_id,1,'Y');
      END IF;
      l_price_index := 1;

	 ASO_PRICING_CORE_PVT.Print_G_Header_Rec;

	 QP_Price_Request_Context.Set_Request_Id;

      QP_ATTR_MAPPING_PUB.Build_Contexts (
      P_REQUEST_TYPE_CODE          => p_control_rec.request_type,
      P_PRICING_TYPE_CODE          => 'H',
      P_line_index                 => l_price_index,
      P_pricing_event              => p_control_rec.pricing_event,
      p_check_line_flag            => 'N',
      x_pass_line                  => x_pass_line);

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CORE_PVT: x_pass_line: '||nvl(x_pass_line,'null'),1,'Y');
         aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of Copy_Header_To_Request...',1,'Y');
      END IF;

      ASO_PRICING_CORE_PVT.Copy_Header_To_Request(
       p_Request_Type                   => p_control_rec.request_type,
       p_price_line_index               => l_price_index,
       px_index_counter                 => 1);

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of Append_asked_for...',1,'Y');
      END IF;

      lx_index_counter:= 1;
      ASO_PRICING_CORE_PVT.Append_asked_for(
        p_pricing_event                   => p_control_rec.pricing_event,
        p_price_line_index                => l_price_index,
        p_header_id                       => p_qte_header_rec.quote_header_id,
        px_index_counter                  => lx_index_counter);

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CORE_PVT:After Append Ask for lx_index_counter:'
                        ||lx_index_counter,1,'Y');
      END IF;
      --increment the line index
      l_price_index:= l_price_index+1;

      -- Header ends here

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('************************ HEADER LEVEL ENDS *******************************',1,'Y');
         aso_debug_pub.add('  ',1,'Y');
         aso_debug_pub.add('************************ LINE LEVEL BEGINS *******************************',1,'Y');
         aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of ASO UTL PVT Query_Pricing_Line_Rows...',1,'Y');
      END IF;

      For i in 1..lx_Qte_Line_Tbl.count loop
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('ASO_PRICING_CORE_PVT:Before Query_Qte_Line_Row utility lx_Qte_Line_Tbl(i).quote_line_id:'
						  ||lx_Qte_Line_Tbl(i).quote_line_id,1,'Y');
          END IF;
          l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row(lx_Qte_Line_Tbl(i).quote_line_id);

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of Query_Shipment_Rows..',1,'Y');
          END IF;
          l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows
                                            (p_qte_header_rec.quote_header_id, lx_Qte_Line_Tbl(i).quote_line_id);
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_shipment_tbl.count :'
                               ||NVL(l_shipment_tbl.count,0),1,'Y');
          END IF;
          IF l_shipment_tbl.count = 1 THEN
               l_shipment_rec := l_shipment_tbl(1);
          else
               l_shipment_rec := ASO_QUOTE_PUB.G_Miss_Shipment_rec;
          END IF;

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of Set_Global_Rec - Line Level...', 1, 'Y');
          END IF;
          ASO_PRICING_INT.G_LINE_REC := ASO_PRICING_CORE_PVT.Set_Global_Rec (
                    p_qte_line_rec               => l_qte_line_rec,
                    p_qte_line_dtl_rec           => l_qte_line_dtl_rec,
                    p_shipment_rec               => l_shipment_rec);

          ASO_PRICING_CORE_PVT.Print_G_Line_Rec;

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of QP Build_Contexts - Line Level...',1,'Y');
          END IF;

          QP_ATTR_MAPPING_PUB.Build_Contexts (
                    p_request_type_code          => p_control_rec.request_type,
                    p_line_index                 => l_price_index,
                    p_check_line_flag            => 'N',
                    p_pricing_event              => p_control_rec.pricing_event,
                    p_pricing_type_code          => 'L',
                    p_price_list_validated_flag  => 'N',
                    x_pass_line                  => x_pass_line);

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: x_pass_line: '||nvl(x_pass_line,'null'),1,'Y');
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of Copy_Line_To_Request...',1,'Y');
          END IF;

          ASO_PRICING_CORE_PVT.Copy_Line_To_Request(
               p_Request_Type         => p_control_rec.request_type,
               p_price_line_index    => l_price_index,
               px_index_counter       => i+1);


          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of Append_asked_for...',1,'Y');
            aso_debug_pub.add('ASO_PRICING_CORE_PVT:Before Append Ask for lx_index_counter:'
                               ||lx_index_counter,1,'Y');
          END IF;
          l_index_counter := lx_index_counter;
          ASO_PRICING_CORE_PVT.Append_asked_for(
                               p_pricing_event   => p_control_rec.pricing_event,
                               p_price_line_index => l_price_index,
                               p_header_id       => p_qte_header_rec.quote_header_id,
                               p_line_id         => l_qte_line_rec.quote_line_id,
                               px_index_counter  => lx_index_counter);
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_PRICING_CORE_PVT:After Append Ask for lx_index_counter:'
                               ||lx_index_counter,1,'Y');
          END IF;
          If lx_index_counter = 0 then
             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT:Assigning the value of l_index_counter back to lx_index_counter:'
                                   || l_index_counter,1,'Y');
             END IF;
             lx_index_counter := l_index_counter;
          end if;

          /*Store all the quote_line_id processed*/
          IF l_Qte_Line_id_tbl.EXISTS(1) THEN
             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of l_qte_line_id_tbl.extend...',1,'Y');
             END IF;
             l_Qte_Line_id_tbl.extend;
             l_Qte_Line_id_tbl(l_Qte_Line_id_tbl.count) := lx_Qte_Line_Tbl(i).quote_line_id;
           ELSE
             IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                aso_debug_pub.add('ASO_PRICING_CORE_PVT: First quote_line_id in l_qte_line_id_tbl',1,'Y');
             END IF;
             l_Qte_Line_id_tbl := JTF_NUMBER_TABLE(lx_Qte_Line_Tbl(i).quote_line_id);
          END IF;

          --increment the line index
          px_line_index_search_tbl(l_qte_line_rec.quote_line_id) := l_price_index;
          l_price_index:= l_price_index+1;

      end loop;--line loop for lx_Qte_Line_Tbl

      /*Need to find OUT  what adjustments and relationships need to be passed*/
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of Query_Price_Adjustments...',1,'Y');
        aso_debug_pub.add('ASO_PRICING_CORE_PVT: l_qte_line_id_tbl.count :'
                           ||NVL(l_qte_line_id_tbl.count,0),1,'Y');
        If NVL(l_qte_line_id_tbl.count,0) > 0 then
           For i in 1..l_qte_line_id_tbl.count loop
	          aso_debug_pub.add('ASO_PRICING_CORE_PVT:l_qte_line_id_tbl(i):'||l_qte_line_id_tbl(i),1,'Y');
	      end loop;
	   End If;
      END IF;
      ASO_PRICING_CORE_PVT.Query_Price_Adj_Line
          (p_quote_header_id       => p_qte_header_rec.quote_header_id,
           p_qte_line_id_tbl       => l_qte_line_id_tbl,
           x_adj_id_tbl            => l_qte_adj_id_tbl);

      /*In the second call we are not going to delete any adjustments and relationships and attributes*/


      --Need to modify the global index table of pls integer types
      l_global_pls_tbl := ASO_PRICING_CORE_PVT.G_LDET_LINE_INDEX_TBL;
      ASO_PRICING_CORE_PVT.G_LDET_LINE_INDEX_TBL:= ASO_PRICING_CORE_PVT.Modify_Global_PlsIndex_Table(
                                                    p_global_tbl => l_global_pls_tbl,
                                                    p_search_tbl => px_line_index_search_tbl);
      l_global_num_tbl := ASO_PRICING_CORE_PVT.G_RLTD_LINE_INDEX_TBL;
      ASO_PRICING_CORE_PVT.G_RLTD_LINE_INDEX_TBL:= ASO_PRICING_CORE_PVT.Modify_Global_NumIndex_Table(
                                                    p_global_tbl => l_global_num_tbl,
                                                    p_search_tbl => px_line_index_search_tbl);
      l_global_num_tbl := ASO_PRICING_CORE_PVT.G_RLTD_RELATED_LINE_IND_TBL;
      ASO_PRICING_CORE_PVT.G_RLTD_RELATED_LINE_IND_TBL:= ASO_PRICING_CORE_PVT.Modify_Global_NumIndex_Table(
                                                    p_global_tbl => l_global_num_tbl,
                                                    p_search_tbl => px_line_index_search_tbl);


      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of Populate_QP_Temp_tables...',1,'Y');
      END IF;
      ASO_PRICING_CORE_PVT.populate_qp_temp_tables;


      -- Set the control rec for QP

      l_req_control_rec.pricing_event := p_control_rec.pricing_event;
      l_req_control_rec.calculate_flag := p_control_rec.calculate_flag;
      l_req_control_rec.simulation_flag := p_control_rec.simulation_flag;
      l_req_control_rec.TEMP_TABLE_INSERT_FLAG := 'N';  ---- Modified
      l_req_control_rec.source_order_amount_flag := 'Y';
      l_req_control_rec.GSA_CHECK_FLAG := 'Y';
      l_req_control_rec.GSA_DUP_CHECK_FLAG := 'Y';
      l_req_control_rec.REQUEST_TYPE_CODE := p_control_rec.request_type;
      l_req_control_rec.rounding_flag := 'Q';

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of QP_PREQ_PUB.PRICE_REQUEST second implicit call', 1, 'Y');
      END IF;

      /*   Change for populating QP_PREQ_GRP.CONTROL_RECORD_TYPE.ORG_ID Yogeshwar  (MOAC) */

	            l_req_control_rec.ORG_ID :=  p_qte_header_rec.org_id;

     /*				End of Change                                     (MOAC) */


      QP_PREQ_PUB.PRICE_REQUEST
               (p_control_rec           =>l_req_control_rec
               ,x_return_status         =>l_return_status
               ,x_return_status_Text    =>l_return_status_Text
               );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR');
         FND_MESSAGE.Set_Token('MSG_TXT', substr(l_return_status_text, 1,255), FALSE);
         FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('ASO_PRICING_CORE_PVT: End of QP_PREQ_PUB.PRICE_REQUEST', 1, 'Y');
       aso_debug_pub.add('ASO_PRICING_CORE_PVT: After PRICE_REQUEST l_return_status:'
                          ||l_return_status, 1, 'Y');
       aso_debug_pub.add('ASO_PRICING_CORE_PVT: After PRICE_REQUEST l_return_status_text '
                          ||l_return_status_text,1,'Y');
       aso_debug_pub.add('ASO_PRICING_CORE_PVT: Start of Copy_Price_To_Quote...',1,'Y');
      END IF;

      ASO_PRICING_CORE_PVT.Copy_Price_To_Quote(
          P_Api_Version_Number       => 1.0,
          P_Init_Msg_List            => FND_API.G_FALSE,
          P_Commit                   => FND_API.G_FALSE,
          p_control_rec              => p_control_rec,
          p_qte_header_rec           => p_qte_header_rec,
          p_insert_type              => 'NO_HDR',
          x_return_status            => x_return_status,
          x_msg_count                => x_msg_count,
          x_msg_data                 => x_msg_data);
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('ASO_PRICING_FLOWS_PVT: Copy_Price_To_Quote : x_return_status: '
                          ||NVL(x_return_status,'X'),1,'Y');
     END IF;

   else  --p_control_rec.prg_reprice_mode = 'A'
      /* we need to make the second call with all the lines*/

      ASO_PRICING_CORE_PVT.Initialize_Global_Tables;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('ASO_PRICING_CORE_PVT:Second call to pricing where all lines are passed',1,'Y');
	    aso_debug_pub.add('ASO_PRICING_CORE_PVT:p_control_rec.price_mode:'||p_control_rec.price_mode,1,'Y');
      END IF;
	 If (p_control_rec.price_mode = 'ENTIRE_QUOTE') then
         ASO_PRICING_FLOWS_PVT.Price_Entire_Quote(
             P_Api_Version_Number       => P_Api_Version_Number,
             P_Init_Msg_List            => FND_API.G_FALSE,
             P_Commit                   => FND_API.G_FALSE,
             p_control_rec              => p_control_rec,
             p_qte_header_rec           => p_qte_header_rec,
             p_qte_line_tbl             => ASO_QUOTE_PUB.G_Miss_Qte_Line_Tbl,
             p_internal_call_flag       => 'Y',
		   x_Qte_Line_Tbl             => lx_Qte_Line_Tbl,
             x_return_status            => x_return_status,
             x_msg_count                => x_msg_count,
             x_msg_data                 => x_msg_data);
      Else
	    /**CHANGE_LINE****/
	   ASO_PRICING_FLOWS_PVT.Price_Quote_With_Change_Lines(
            P_Api_Version_Number      => P_Api_Version_Number,
            P_Init_Msg_List           => FND_API.G_FALSE,
            P_Commit                  => FND_API.G_FALSE,
            p_control_rec             => p_control_rec,
            p_qte_header_rec          => p_qte_header_rec,
            p_qte_line_tbl            => ASO_QUOTE_PUB.G_Miss_Qte_Line_Tbl,
            p_internal_call_flag      => 'Y',
            x_qte_line_tbl            => lx_Qte_Line_Tbl,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data);
      End If;--(p_control_rec.price_mode = 'ENTIRE_QUOTE')

      end if;--p_control_rec.prg_reprice_mode = 'F'

   end if;--l_track_var = 'Y'

-- Standard check for p_commit
IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
END IF;

 FND_MSG_PUB.Count_And_Get
      ( p_encoded    => 'F',
        p_count      =>   x_msg_count,
        p_data       =>   x_msg_data
      );

FND_MSG_PUB.Count_And_Get
      ( p_encoded    => 'F',
        p_count      =>   x_msg_count,
        p_data       =>   x_msg_data
      );

 for l in 1 ..x_msg_count loop
    x_msg_data := fnd_msg_pub.get( p_msg_index => l, p_encoded => 'F');
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Messge count and get '||x_msg_data, 1, 'Y');
      aso_debug_pub.add('ASO_PRICING_CORE_PVT:Messge count and get '||x_msg_count, 1, 'Y');
    END IF;
 end loop;

END Process_PRG;




End ASO_PRICING_CORE_PVT;

/
