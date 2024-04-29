--------------------------------------------------------
--  DDL for Package ASO_PRICING_CORE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_PRICING_CORE_PVT" AUTHID CURRENT_USER as
/* $Header: asovpcos.pls 120.2.12010000.3 2014/03/10 04:52:40 rassharm ship $ */
-- Start of Comments
-- Package name     : ASO_PRICING_CORE_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

 G_LINE_INDEX_tbl                      QP_PREQ_GRP.pls_integer_type;
 G_LINE_TYPE_CODE_TBL                  QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICING_EFFECTIVE_DATE_TBL          QP_PREQ_GRP.DATE_TYPE;
 G_ACTIVE_DATE_FIRST_TBL               QP_PREQ_GRP.DATE_TYPE;
 G_ACTIVE_DATE_FIRST_TYPE_TBL          QP_PREQ_GRP.VARCHAR_TYPE;
 G_ACTIVE_DATE_SECOND_TBL              QP_PREQ_GRP.DATE_TYPE   ;
 G_ACTIVE_DATE_SECOND_TYPE_TBL         QP_PREQ_GRP.VARCHAR_TYPE ;
 G_LINE_QUANTITY_TBL                   QP_PREQ_GRP.NUMBER_TYPE ;
 G_LINE_UOM_CODE_TBL                   QP_PREQ_GRP.VARCHAR_TYPE;
 G_REQUEST_TYPE_CODE_TBL               QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICED_QUANTITY_TBL                 QP_PREQ_GRP.NUMBER_TYPE;
 G_UOM_QUANTITY_TBL                    QP_PREQ_GRP.NUMBER_TYPE;
 G_PRICED_UOM_CODE_TBL                 QP_PREQ_GRP.VARCHAR_TYPE;
 G_CURRENCY_CODE_TBL                   QP_PREQ_GRP.VARCHAR_TYPE;
 G_UNIT_PRICE_TBL                      QP_PREQ_GRP.NUMBER_TYPE;
 G_PERCENT_PRICE_TBL                   QP_PREQ_GRP.NUMBER_TYPE;
 G_ADJUSTED_UNIT_PRICE_TBL             QP_PREQ_GRP.NUMBER_TYPE;
 G_UPD_ADJUSTED_UNIT_PRICE_TBL         QP_PREQ_GRP.NUMBER_TYPE;
 G_PROCESSED_FLAG_TBL                  QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICE_FLAG_TBL                      QP_PREQ_GRP.VARCHAR_TYPE;
 G_LINE_ID_TBL                         QP_PREQ_GRP.NUMBER_TYPE;
 G_PROCESSING_ORDER_TBL                QP_PREQ_GRP.PLS_INTEGER_TYPE;
 G_ROUNDING_FACTOR_TBL                 QP_PREQ_GRP.PLS_INTEGER_TYPE;
 G_ROUNDING_FLAG_TBL                   QP_PREQ_GRP.FLAG_TYPE;
 G_QUALIFIERS_EXIST_FLAG_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICING_ATTRS_EXIST_FLAG_TBL        QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICE_LIST_ID_TBL                   QP_PREQ_GRP.NUMBER_TYPE;
 G_PL_VALIDATED_FLAG_TBL               QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICE_REQUEST_CODE_TBL              QP_PREQ_GRP.VARCHAR_TYPE;
 G_USAGE_PRICING_TYPE_TBL              QP_PREQ_GRP.VARCHAR_TYPE;
 G_LINE_CATEGORY_TBL                   QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICING_STATUS_CODE_tbl             QP_PREQ_GRP.VARCHAR_TYPE;
 G_PRICING_STATUS_TEXT_tbl             QP_PREQ_GRP.VARCHAR_TYPE;
 G_CHRG_PERIODICITY_CODE_TBL           QP_PREQ_GRP.VARCHAR_3_TYPE;
 /* Changes Made for OKS uptake bug 4900084 	*/
 G_CONTRACT_START_DATE_TBL                 QP_PREQ_GRP.DATE_TYPE;
 G_CONTRACT_END_DATE_TBL                   QP_PREQ_GRP.DATE_TYPE;

 G_ATTR_LINE_INDEX_tbl                 QP_PREQ_GRP.pls_integer_type;
 G_ATTR_LINE_DETAIL_INDEX_tbl          QP_PREQ_GRP.pls_integer_type;
 G_ATTR_VALIDATED_FLAG_tbl             QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_PRICING_CONTEXT_tbl            QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_PRICING_ATTRIBUTE_tbl          QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_ATTRIBUTE_LEVEL_tbl            QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_ATTRIBUTE_TYPE_tbl             QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_APPLIED_FLAG_tbl               QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_PRICING_STATUS_CODE_tbl        QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_PRICING_ATTR_FLAG_tbl          QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_LIST_HEADER_ID_tbl             QP_PREQ_GRP.NUMBER_TYPE;
 G_ATTR_LIST_LINE_ID_tbl               QP_PREQ_GRP.NUMBER_TYPE;
 G_ATTR_VALUE_FROM_tbl                 QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_SETUP_VALUE_FROM_tbl           QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_VALUE_TO_tbl                   QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_SETUP_VALUE_TO_tbl             QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_GROUPING_NUMBER_tbl            QP_PREQ_GRP.PLS_INTEGER_TYPE;
 G_ATTR_NO_QUAL_IN_GRP_tbl             QP_PREQ_GRP.PLS_INTEGER_TYPE;
 G_ATTR_COMP_OPERATOR_TYPE_tbl         QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_PRICING_STATUS_TEXT_tbl        QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_QUAL_PRECEDENCE_tbl            QP_PREQ_GRP.PLS_INTEGER_TYPE;
 G_ATTR_DATATYPE_tbl                   QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_QUALIFIER_TYPE_tbl             QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_PRODUCT_UOM_CODE_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_EXCLUDER_FLAG_TBL              QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_PRICING_PHASE_ID_TBL           QP_PREQ_GRP.PLS_INTEGER_TYPE;
 G_ATTR_INCOM_GRP_CODE_TBL             QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_LDET_TYPE_CODE_TBL             QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_MODIFIER_LEVEL_CODE_TBL        QP_PREQ_GRP.VARCHAR_TYPE;
 G_ATTR_PRIMARY_UOM_FLAG_TBL           QP_PREQ_GRP.VARCHAR_TYPE;

G_LDET_LINE_DTL_INDEX_TBL              QP_PREQ_GRP.pls_integer_type;
G_LDET_PRICE_ADJ_ID_TBL                QP_PREQ_GRP.NUMBER_TYPE;
G_LDET_LINE_DTL_TYPE_TBL               QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_PRICE_BREAK_TYPE_TBL            QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_LIST_PRICE_TBL                  QP_PREQ_GRP.NUMBER_TYPE;
G_LDET_LINE_INDEX_TBL                  QP_PREQ_GRP.pls_integer_type;
G_LDET_LIST_HEADER_ID_TBL              QP_PREQ_GRP.NUMBER_TYPE;
G_LDET_LIST_LINE_ID_TBL                QP_PREQ_GRP.NUMBER_TYPE;
G_LDET_LIST_LINE_TYPE_TBL              QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_LIST_TYPE_CODE_TBL              QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_CREATED_FROM_SQL_TBL            QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_PRICING_GRP_SEQ_TBL             QP_PREQ_GRP.PLS_INTEGER_TYPE;
G_LDET_PRICING_PHASE_ID_TBL            QP_PREQ_GRP.PLS_INTEGER_TYPE;
G_LDET_OPERAND_CALC_CODE_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_OPERAND_VALUE_TBL               QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_SUBSTN_TYPE_TBL                 QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_SUBSTN_VALUE_FROM_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_SUBSTN_VALUE_TO_TBL             QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_ASK_FOR_FLAG_TBL                QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_PRICE_FORMULA_ID_TBL            QP_PREQ_GRP.NUMBER_TYPE;
G_LDET_PRICING_STATUS_CODE_TBL         QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_PRICING_STATUS_TXT_TBL          QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_PRODUCT_PRECEDENCE_TBL          QP_PREQ_GRP.PLS_INTEGER_TYPE;
G_LDET_INCOMPAT_GRP_CODE_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_PROCESSED_FLAG_TBL              QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_APPLIED_FLAG_TBL                QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_AUTOMATIC_FLAG_TBL              QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_OVERRIDE_FLAG_TBL               QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_PRIMARY_UOM_FLAG_TBL            QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_PRINT_ON_INV_FLAG_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_MODIFIER_LEVEL_TBL              QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_BENEFIT_QTY_TBL                 QP_PREQ_GRP.NUMBER_TYPE;
G_LDET_BENEFIT_UOM_CODE_TBL            QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_LIST_LINE_NO_TBL                QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_ACCRUAL_FLAG_TBL                QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_ACCR_CONV_RATE_TBL              QP_PREQ_GRP.NUMBER_TYPE;
G_LDET_ESTIM_ACCR_RATE_TBL             QP_PREQ_GRP.NUMBER_TYPE;
G_LDET_RECURRING_FLAG_TBL              QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_SELECTED_VOL_ATTR_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_ROUNDING_FACTOR_TBL             QP_PREQ_GRP.PLS_INTEGER_TYPE;
G_LDET_HDR_LIMIT_EXISTS_TBL            QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_LINE_LIMIT_EXISTS_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_CHARGE_TYPE_TBL                 QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_CHARGE_SUBTYPE_TBL              QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_CURRENCY_DTL_ID_TBL             QP_PREQ_GRP.NUMBER_TYPE;
G_LDET_CURRENCY_HDR_ID_TBL             QP_PREQ_GRP.NUMBER_TYPE;
G_LDET_SELLING_ROUND_TBL               QP_PREQ_GRP.NUMBER_TYPE;
G_LDET_ORDER_CURRENCY_TBL              QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_PRICING_EFF_DATE_TBL            QP_PREQ_GRP.DATE_TYPE;
G_LDET_BASE_CURRENCY_TBL               QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_LINE_QUANTITY_TBL               QP_PREQ_GRP.NUMBER_TYPE;
G_LDET_UPDATED_FLAG_TBL                QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_CALC_CODE_TBL                   QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_CHG_REASON_CODE_TBL             QP_PREQ_GRP.VARCHAR_TYPE;
G_LDET_CHG_REASON_TEXT_TBL             QP_PREQ_GRP.VARCHAR_TYPE;

G_RLTD_LINE_INDEX_TBL                  QP_PREQ_GRP.NUMBER_TYPE;
G_RLTD_LINE_DTL_INDEX_TBL              QP_PREQ_GRP.NUMBER_TYPE;
G_RLTD_RELATION_TYPE_CODE_TBL          QP_PREQ_GRP.VARCHAR_TYPE;
G_RLTD_RELATED_LINE_IND_TBL            QP_PREQ_GRP.NUMBER_TYPE;
G_RLTD_RLTD_LINE_DTL_IND_TBL           QP_PREQ_GRP.NUMBER_TYPE;
G_RLTD_LST_LN_ID_DEF_TBL               QP_PREQ_GRP.NUMBER_TYPE;
G_RLTD_RLTD_LST_LN_ID_DEF_TBL          QP_PREQ_GRP.NUMBER_TYPE;

G_LINE_UNIT_PRICE_TBL                  QP_PREQ_GRP.NUMBER_TYPE; -- bug 17517305

--Define Some Constants used in pricing integration
G_TERMS_SUBSTITUTION      CONSTANT VARCHAR2(30) := 'TSN';
G_ORDER_LEVEL             CONSTANT VARCHAR2(30) :='ORDER';
G_LINE_LEVEL              CONSTANT VARCHAR2(30) :='LINE';
G_QUAL_ATTRIBUTE1         CONSTANT VARCHAR2(30) := 'QUALIFIER_ATTRIBUTE1';
G_QUAL_ATTRIBUTE10        CONSTANT VARCHAR2(30) := 'QUALIFIER_ATTRIBUTE10';
G_QUAL_ATTRIBUTE11        CONSTANT VARCHAR2(30) := 'QUALIFIER_ATTRIBUTE11';
G_FREIGHT_TERM_LK_TYPE    CONSTANT VARCHAR2(30) := 'FREIGHT_TERMS';
G_YES_FLAG                CONSTANT VARCHAR2(1)  := 'Y';
G_NO_FLAG                 CONSTANT VARCHAR2(1)  := 'N';
G_FREE_LINE_FLAG          CONSTANT VARCHAR2(1)  := 'F';
G_BINARY_LIMIT            CONSTANT NUMBER:=2147483648;  -- bug 14311089


TYPE Index_Link_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
G_MISS_Link_Tbl      Index_Link_Tbl_Type;

PROCEDURE Initialize_Global_Tables;

FUNCTION Set_Global_Rec (
    p_qte_header_rec      ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    p_shipment_rec        ASO_QUOTE_PUB.Shipment_Rec_Type)
RETURN ASO_PRICING_INT.PRICING_HEADER_REC_TYPE;

FUNCTION Set_Global_Rec (
    p_qte_line_rec        ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    p_qte_line_dtl_rec    ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type,
    p_shipment_rec        ASO_QUOTE_PUB.Shipment_Rec_Type)
RETURN ASO_PRICING_INT.PRICING_LINE_REC_TYPE;


PROCEDURE Print_G_Header_Rec;

PROCEDURE Print_G_Line_Rec;

/*New Append_ask_for to use direct insert*/
PROCEDURE  Append_Asked_For(
        p_pricing_event                        varchar2
	  ,p_price_line_index                     NUMBER
       ,p_header_id                            number := null
       ,p_Line_id                              number := null
       ,px_index_counter       IN OUT NOCOPY /* file.sql.39 change */ number);

/*New copy_Header_to_request to use direct insert*/
PROCEDURE Copy_Header_To_Request(
    p_Request_Type                      VARCHAR2,
    p_price_line_index                  NUMBER,
    px_index_counter                    NUMBER);

/*New copy_Line_to_request to use direct insert*/
PROCEDURE Copy_Line_To_Request(
    p_Request_Type                      VARCHAR2,
    p_price_line_index                  NUMBER,
    px_index_counter                    NUMBER);

--PROCEDURE Query_Price_Adj_Header_All (p_quote_header_id    IN NUMBER);

PROCEDURE Query_Price_Adj_All
(p_quote_header_id    IN  NUMBER,
 x_adj_id_tbl         OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE);


PROCEDURE Query_Price_Adj_Header (p_quote_header_id    IN NUMBER);

PROCEDURE Query_Price_Adjustments
(p_quote_header_id    IN  NUMBER,
 p_qte_line_id_tbl    IN  JTF_NUMBER_TABLE,
 x_adj_id_tbl         OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE);

Procedure Query_Relationships(p_qte_adj_id_tbl IN JTF_NUMBER_TABLE,
                              p_service_qte_line_id_tbl IN JTF_NUMBER_TABLE);

PROCEDURE Print_Global_Data_Lines;

PROCEDURE Print_Global_Data_Adjustments;

PROCEDURE Print_Global_Data_Rltships;

PROCEDURE Populate_QP_Temp_Tables;

PROCEDURE Delete_Promotion (
                           P_Api_Version_Number IN   NUMBER,
                           P_Init_Msg_List      IN   VARCHAR2  := FND_API.G_FALSE,
                           P_Commit             IN   VARCHAR2  := FND_API.G_FALSE,
                           p_price_attr_tbl     IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
                           x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                           x_msg_count          OUT NOCOPY /* file.sql.39 change */ NUMBER,
                           x_msg_data           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                          );

PROCEDURE Copy_Price_To_Quote(
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     P_control_rec              IN   ASO_PRICING_INT.Pricing_Control_Rec_Type,
     p_qte_header_rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
	P_Insert_Type              IN   VARCHAR2 := 'HDR',
     x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */ NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

FUNCTION Modify_Global_PlsIndex_Table (
               p_global_tbl     IN QP_PREQ_GRP.pls_integer_type,
               p_search_tbl     IN Index_Link_Tbl_Type)
RETURN QP_PREQ_GRP.pls_integer_type;

FUNCTION Modify_Global_NumIndex_Table (
               p_global_tbl            IN QP_PREQ_GRP.NUMBER_TYPE,
               p_search_tbl            IN Index_Link_Tbl_Type)
RETURN QP_PREQ_GRP.NUMBER_TYPE;

PROCEDURE Process_Charges(
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     P_control_rec              IN   ASO_PRICING_INT.Pricing_Control_Rec_Type,
     p_qte_header_rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */ NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


PROCEDURE Process_PRG(
     P_Api_Version_Number       IN   NUMBER,
     P_Init_Msg_List            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit                   IN   VARCHAR2 := FND_API.G_FALSE,
     P_control_rec              IN   ASO_PRICING_INT.Pricing_Control_Rec_Type,
     p_qte_header_rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
	x_qte_line_tbl             OUT NOCOPY /* file.sql.39 change */ ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
     x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
     x_msg_count                OUT NOCOPY /* file.sql.39 change */ NUMBER,
     x_msg_data                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


End ASO_PRICING_CORE_PVT;

/
