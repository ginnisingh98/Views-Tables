--------------------------------------------------------
--  DDL for Package QP_PREQ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PREQ_PUB" AUTHID CURRENT_USER AS
/* $Header: QPXPPRES.pls 120.3.12010000.3 2008/08/22 11:19:09 smuhamme ship $ */
/*#
 * This package contains procedures to be called to pass the request information
 * to the pricing engine.
 *
 * @rep:scope public
 * @rep:product QP
 * @rep:displayname Price Request
 * @rep:category BUSINESS_ENTITY QP_PRICE_LIST
 * @rep:category BUSINESS_ENTITY QP_PRICE_MODIFIER
 * @rep:category BUSINESS_ENTITY QP_PRICE_QUALIFIER
 * @rep:category BUSINESS_ENTITY QP_PRICE_FORMULA
 */

--For Perforamnce fix bug 7309551 smbalara
G_DYNAMIC_SAMPLING_LEVEL CONSTANT VARCHAR2(30)  := 'QP_DYNAMIC_SAMPLING_LEVEL';
G_ODS NUMBER;

--replacement constant for FND_API.G_MISS_NUM
G_MISS_NUM CONSTANT NUMBER := 9.99E125;

--FOR DIRECT TEMP TABLE INSERTION
G_PRICE_PHASE_FLAG            BOOLEAN;
G_MIN_PRICING_DATE               DATE;
G_MAX_PRICING_DATE               DATE;
G_PRICE_FLAG_INDEX              VARCHAR2(1) := 'N';
G_CURRENCY_CODE              VARCHAR2(30);
G_PRICE_LIST_PHASE_ID         PLS_INTEGER :=1;
G_PRICE_LIST_SEQUENCE         PLS_INTEGER :=0;
G_GSA_INDICATOR		     VARCHAR2(1);
G_LICENSED_FOR_PRODUCT       VARCHAR2(30);


--Processing status
G_STATUS_NEW                      CONSTANT VARCHAR2(30):='N';
G_STATUS_DELETED                  CONSTANT VARCHAR2(30):='D';
G_STATUS_UNCHANGED                CONSTANT VARCHAR2(30):='X';
G_STATUS_TRANSIENT                CONSTANT VARCHAR2(30):='T';
G_STATUS_GROUPING                 CONSTANT VARCHAR2(30):='G';
G_STATUS_UPDATED                  CONSTANT VARCHAR2(30):='UPDATED';
G_STATUS_INVALID_PRICE_LIST       CONSTANT VARCHAR2(30):='IPL';
G_STATUS_GSA_VIOLATION            CONSTANT VARCHAR2(30):='GSA';
G_STS_LHS_NOT_FOUND               CONSTANT VARCHAR2(30):='NMS';
G_STATUS_FORMULA_ERROR            CONSTANT VARCHAR2(30):='FER';
G_STATUS_OTHER_ERRORS             CONSTANT VARCHAR2(30):='OER';
G_STATUS_SYSTEM_GENERATED         CONSTANT VARCHAR2(30):='S';
G_STATUS_BEST_PRICE_EVAL          CONSTANT VARCHAR2(30):= 'B';
G_STATUS_INCOMP_LOGIC             CONSTANT VARCHAR2(30):= 'I';
G_STATUS_CALC_ERROR        CONSTANT VARCHAR2(30):='CALC';
G_STATUS_UOM_FAILURE              CONSTANT VARCHAR2(30):='UOM';
G_STATUS_PRIMARY_UOM_FLAG       CONSTANT VARCHAR2(30):='P_UOM_FLAG';
G_STATUS_OTHER_ITEM_BENEFITS      CONSTANT VARCHAR2(30):='OTHER_ITEM_BENEFITS';
G_STATUS_INVALID_UOM              CONSTANT VARCHAR2(30) := 'INVALID_UOM';
G_STATUS_DUP_PRICE_LIST           CONSTANT VARCHAR2(30) := 'DUPLICATE_PRICE_LIST
';
G_STATUS_INVALID_UOM_CONV         CONSTANT VARCHAR2(30) := 'INVALID_UOM_CONV';
G_STATUS_INVALID_INCOMP           CONSTANT VARCHAR2(30) := 'INVALID_INCOMP';
G_STATUS_BEST_PRICE_EVAL_ERROR    CONSTANT VARCHAR2(30) := 'INVALID_BEST_PRICE';

--Processed code
G_NO_LIST_PASSED                  CONSTANT   VARCHAR2(30):='NLP';
G_STATUS_NOT_IN_MINI_SEARCH       CONSTANT   VARCHAR2(30) := 'NMS';
G_STATUS_MINI_SEARCH_NOT_EXEC     CONSTANT  VARCHAR2(30) := 'NMSE';
G_BY_ENGINE                       CONSTANT  VARCHAR2(30) :='ENGINE';

--DELETED BY STATUS CODE
G_DELETED_PBH                    CONSTANT VARCHAR2(30):='D_PBH';
G_DELETED_GRP                    CONSTANT VARCHAR2(30):='D_GRP';
G_DELETED_EXCLUDER               CONSTANT VARCHAR2(30):='D_EXCL';
G_DELETED_NULL_PRICE             CONSTANT VARCHAR2(30):='D_NULL_PRICE';
G_DELETED_CAL_ERROR              CONSTANT VARCHAR2(30):='D_CAL_ERROR';
G_DELETED_BETWEEN                CONSTANT VARCHAR2(30):='D_BETWEEN';
G_DELETED_PARENT_FAILS           CONSTANT VARCHAR2(30):='D_PBH_PARENT_FAILS';

--PROCESSED FLAG for internal used only
G_NOT_PROCESSED                 CONSTANT VARCHAR2(30):='N';
G_PROCESSED                     CONSTANT VARCHAR2(30):='Y';
G_BY_PBH                        CONSTANT VARCHAR2(30):='PBH';

--VALIDATED_CODE
G_NOT_VALIDATED                CONSTANT VARCHAR2(30):='N';
G_VALIDATED                    CONSTANT VARCHAR2(30):='Y';

--APPLIED_FLAG
G_LIST_APPLIED                 CONSTANT VARCHAR2(30):='Y';
G_LIST_NOT_APPLIED             CONSTANT VARCHAR2(30):='N';

--Line Type Code
G_PRICE_BREAK_TYPE     CONSTANT VARCHAR2(30):= 'PBH';
G_RECURRING_BREAK      CONSTANT VARCHAR2(30):= 'RECURRING';
G_OTHER_ITEM_DISCOUNT  CONSTANT VARCHAR2(30):= 'OID';
G_ITEM_UPGRADE         CONSTANT VARCHAR2(30) :='IUE';
G_TERMS_SUBSTITUTION   CONSTANT VARCHAR2(30) := 'TSN';
G_COUPON_ISSUE         CONSTANT VARCHAR2(30) := 'CIE';
G_COUPON               CONSTANT VARCHAR2(30) := 'COUPON';
G_DISCOUNT             CONSTANT VARCHAR2(30) := 'DIS';
G_SURCHARGE            CONSTANT VARCHAR2(30) := 'SUR';
G_PROMO_GOODS_DISCOUNT CONSTANT VARCHAR2(30) := 'PRG';
G_FREIGHT_CHARGE       CONSTANT VARCHAR2(30) := 'FREIGHT_CHARGE';

-- Operand Calculation Codes
G_PERCENT_DISCOUNT     CONSTANT VARCHAR2(30) := '%';
G_AMOUNT_DISCOUNT      CONSTANT VARCHAR2(30) := 'AMT';
G_NEWPRICE_DISCOUNT    CONSTANT VARCHAR2(30) := 'NEWPRICE';
G_LUMPSUM_DISCOUNT     CONSTANT VARCHAR2(30) := 'LUMPSUM';

-- Price List Types
G_UNIT_PRICE           CONSTANT  VARCHAR2(30) := 'UNIT_PRICE';
G_PERCENT_PRICE        CONSTANT  VARCHAR2(30) := 'PERCENT_PRICE';
G_BLOCK_PRICE          CONSTANT  VARCHAR2(30) := 'BLOCK_PRICE';

--Attribute type
G_QUALIFIER_TYPE       CONSTANT VARCHAR2(30):='QUALIFIER';
G_PRICING_TYPE         CONSTANT VARCHAR2(30):='PRICING';
G_PRODUCT_TYPE         CONSTANT VARCHAR2(30):='PRODUCT';
G_BENEFIT_TYPE         CONSTANT VARCHAR2(30):='BENEFIT';
G_QUANTITY             CONSTANT VARCHAR2(1):='Q';
G_AMOUNT               CONSTANT VARCHAR2(1):='A';
G_ORDER_LINE_TYPE      CONSTANT VARCHAR2(30):='ORDER_LINE';
G_ADJUSTMENT_LINE_TYPE CONSTANT VARCHAR2(30):='ADJUSTMENT_LINE';
G_CHILD_DETAIL_TYPE    CONSTANT VARCHAR2(30):='CHILD_DETAIL_LINE';
G_PRICE_LIST_TYPE      CONSTANT VARCHAR2(30):='PLL';

--Line level
G_LINE_LEVEL              CONSTANT VARCHAR2(30):='LINE';
G_DETAIL_LEVEL            CONSTANT VARCHAR2(30):='DETAIL';
G_ORDER_LEVEL             CONSTANT VARCHAR2(30):='ORDER';

G_LINE_GROUP              CONSTANT VARCHAR2(30):='LINEGROUP';

--PROCESSED_CODE
G_LINE_GROUP_PROCESSED    CONSTANT VARCHAR2(30):='LGP';
G_DISCOUNT_MODE           CONSTANT VARCHAR2(3):='DIS';
G_PRICELIST_MODE          CONSTANT VARCHAR2(3):='PLL';

--COMPARISON OPERATOR TYPE CODE
G_OPERATOR_BETWEEN CONSTANT VARCHAR2(30):='BETWEEN';

--Context for list header and list line as qualifiers
G_LIST_HEADER_CONTEXT              CONSTANT VARCHAR2(30):= 'MODLIST';
G_OLD_LIST_HEADER_CONTEXT          CONSTANT VARCHAR2(30):='ORDER';
G_LIST_LINE_CONTEXT                CONSTANT VARCHAR2(30):= 'LISTLINE';
G_PRIC_VOLUME_CONTEXT            CONSTANT VARCHAR2(30):= 'VOLUME';
G_PRIC_ITEM_CONTEXT                CONSTANT VARCHAR2(30):= 'ITEM';
G_CUSTOMER_CONTEXT                 CONSTANT VARCHAR2(30) := 'CUSTOMER';

-- Attributes
G_QUAL_ATTRIBUTE1    CONSTANT VARCHAR2(30) := 'QUALIFIER_ATTRIBUTE1'; -- Promotion
G_QUAL_ATTRIBUTE2    CONSTANT VARCHAR2(30) := 'QUALIFIER_ATTRIBUTE2'; -- List Line Id
G_QUAL_ATTRIBUTE6    CONSTANT VARCHAR2(30) := 'QUALIFIER_ATTRIBUTE6';  -- Discount Id
G_PRIC_ATTRIBUTE1    CONSTANT VARCHAR2(30)  := 'PRICING_ATTRIBUTE1';
G_PRIC_ATTRIBUTE10   CONSTANT VARCHAR2(30) := 'PRICING_ATTRIBUTE10';
G_PRIC_ATTRIBUTE12   CONSTANT VARCHAR2(30) := 'PRICING_ATTRIBUTE12';
G_GSA_ATTRIBUTE      CONSTANT VARCHAR2(30) :='QUALIFIER_ATTRIBUTE15';
G_DISCOUNT_ATTRIBUTE CONSTANT VARCHAR2(30) :='QUALIFIER_ATTRIBUTE6';
G_PROMOTION_ATTRIBUTE CONSTANT VARCHAR2(30):='QUALIFIER_ATTRIBUTE1';
G_PRICELIST_ATTRIBUTE CONSTANT VARCHAR2(30):='QUALIFIER_ATTRIBUTE4';
G_QUANTITY_ATTRIBUTE CONSTANT VARCHAR2(30):='PRICING_ATTRIBUTE10';
G_LINE_AMT_ATTRIBUTE CONSTANT VARCHAR2(30):='PRICING_ATTRIBUTE12';
G_ORDER_AMOUNT_ATTRIBUTE CONSTANT VARCHAR2(30):='QUALIFIER_ATTRIBUTE10';

--Need to change! these both may not be same
G_LINEGRP_QUANTITY_ATTRIBUTE CONSTANT VARCHAR2(30):='PRICING_ATTRIBUTE12';
G_LINEGRP_AMOUNT_ATTRIBUTE CONSTANT VARCHAR2(30):='PRICING_ATTRIBUTE12';

-- Yes/No/Phase/Debug Flags
G_YES CONSTANT VARCHAR2(20) := 'Y';
G_NO CONSTANT VARCHAR2(20) := 'N';
G_PHASE CONSTANT VARCHAR2(20):='P';
G_DONT_WRITE_TO_DEBUG CONSTANT VARCHAR2(20) := 'V';
G_ENGINE_TIME_TRACE_ON CONSTANT VARCHAR2(20) := 'T';    --3085171
-- Best Price Evaluation Constants
G_DISCOUNT_PROCESSING   CONSTANT VARCHAR2(30) := 'DISCOUNT';
G_PRICELIST_PROCESSING  CONSTANT VARCHAR2(30) := 'PRICE_LIST';

-- Incompatibility Processing
G_INCOMP_EXCLUSIVE CONSTANT VARCHAR2(30) := 'EXCL';

--Incompatibility Resolve Codes
G_INCOMP_PRECEDENCE CONSTANT VARCHAR2(30) := 'PRECEDENCE';
G_INCOMP_BEST_PRICE CONSTANT VARCHAR2(30) := 'BEST_PRICE';

-- Header/Line Qualifiers
G_HEADER_QUALIFIER CONSTANT VARCHAR2(30) := 'HQ';
G_LINE_QUALIFIER CONSTANT VARCHAR2(30) := 'LQ';

-- Search Flags
G_NO_SEARCH CONSTANT VARCHAR2(30):='N';
G_YES_SEARCH  CONSTANT VARCHAR2(30):='Y';

--Context for Product ITEN
G_ITEM_CONTEXT CONSTANT VARCHAR2(30):='ITEM';

--INDICATE IF there is a pricing attribute passed in
G_PRICING_YES CONSTANT VARCHAR2(30):='Y';
G_PRICING_NO  CONSTANT VARCHAR2(30):='N';

--EVENT CONSTANT
G_PRICE_LINE_EVENT CONSTANT VARCHAR2(30):='PRICE_LINE';
G_PRICE_ORDER_EVENT CONSTANT VARCHAR2(30):='PRICE_ORDER';

--PRICE BREAK TYPE
G_RANGE_BREAK  CONSTANT VARCHAR2(30):='RANGE';
G_POINT_BREAK  CONSTANT VARCHAR2(30):='POINT';

--G_RELATIONSHIP TYPE CODE
G_LINE_TO_LINE       CONSTANT VARCHAR2(30):='LINE_TO_LINE';
G_LINE_TO_DETAIL     CONSTANT VARCHAR2(30):='LINE_TO_DETAIL';
G_DETAIL_TO_DETAIL   CONSTANT VARCHAR2(30):='DETAIL_TO_DETAIL';
G_ORDER_TO_LINE      CONSTANT VARCHAR2(30):='ORDER_TO_LINE';
G_RELATED_ITEM_PRICE CONSTANT VARCHAR2(30):='RELATED_ITEM_PRICE';
G_PBH_LINE           CONSTANT VARCHAR2(30):='PBH_LINE';
G_SERVICE_LINE       CONSTANT VARCHAR2(30):='SERVICE_LINE';
G_GENERATED_LINE     CONSTANT VARCHAR2(30):='GENERATED_LINE';

--List Header Type Code
G_DISCOUNT_LIST_HEADER  CONSTANT VARCHAR2(30):='DLT';
G_PRICE_LIST_HEADER     CONSTANT VARCHAR2(30):='PRL';
G_AGR_LIST_HEADER       CONSTANT VARCHAR2(30):='AGR';
G_CHARGES_HEADER        CONSTANT VARCHAR2(30):='CHARGES';

--Profile Option Constants
--GSA
G_GSA_Max_Discount_Enabled CONSTANT VARCHAR2(30) := 'QP_VERIFY_GSA';
G_BYPASS_PRICING CONSTANT VARCHAR2(30) := 'QP_BYPASS_PRICING';
G_RETURN_MANUAL_DISCOUNTS CONSTANT VARCHAR2(30) := 'QP_RETURN_MANUAL_DISCOUNTS';
G_BLIND_DISCOUNT CONSTANT VARCHAR2(30) := 'QP_BLIND_DISCOUNT';

--DATA_TYPE
G_NUMERIC CONSTANT VARCHAR2(1):= 'N';
G_VARCHAR CONSTANT VARCHAR2(1):= 'C';
G_DATE    CONSTANT VARCHAR2(1):= 'D';
G_DATE_X  CONSTANT VARCHAR2(1):= 'X';
G_DATE_Y  CONSTANT VARCHAR2(1):= 'Y';

--CONTROL RECORD constants
G_CALCULATE_ONLY      CONSTANT VARCHAR2(30):='C';
G_SEARCH_ONLY         CONSTANT VARCHAR2(30):='N';
G_SEARCH_N_CALCULATE  CONSTANT VARCHAR2(30):='Y';
G_MANUAL_DISCOUNT_FLAG     VARCHAR2(1);
G_GSA_CHECK_FLAG           VARCHAR2(1);
G_GSA_DUP_CHECK_FLAG       VARCHAR2(1);
G_TEMP_TABLE_INSERT_FLAG   VARCHAR2(1);
G_PUBLIC_API_CALL_FLAG     VARCHAR2(1);


G_YES_PROD_HDR_QUAL_IND           CONSTANT NUMBER :=6; -- Has Header Qualifiers, Products
G_YES_PROD_PRIC_HDR_QUAL_IND      CONSTANT NUMBER :=22;-- Has Header Qualifiers, Products and Pricing Attrs
G_YES_PROD_LINE_QUAL_IND          CONSTANT NUMBER :=12;-- Has Line Qualifiers,Products
G_YES_PROD_PRIC_LINE_QUAL_IND     CONSTANT NUMBER :=28;-- Has Line Qualifiers,Products and Pricing Attrs
G_YES_PROD_HDR_LINE_QUAL_IND      CONSTANT NUMBER :=14;-- Has Header, Line Qualifiers,Products
G_YES_PRIC_HDR_LINE_QUAL_IND      CONSTANT NUMBER :=30;-- Has Header, Line Qualifiers,Products,Pricing Attrs
G_YES_PROD_IND                    CONSTANT NUMBER :=4; -- Has Products
G_YES_PROD_PRIC_IND               CONSTANT NUMBER :=20;-- Has Products and Pricing Attrs
G_YES_HDR_QUAL_IND                CONSTANT NUMBER :=2; -- Has (Header Level) Qualifiers
G_YES_LINE_QUAL_IND               CONSTANT NUMBER :=8; -- Has (Line Level) Qualifiers
G_YES_HDR_LINE_QUAL_IND           CONSTANT NUMBER :=10;-- Has (Header+Line Level) Qualifiers
G_BLIND_DISCOUNT_IND              CONSTANT NUMBER :=0; -- Blind Discount

G_NO_QUAL_IND         CONSTANT NUMBER := 2;
G_NO_PRIC_IND         CONSTANT NUMBER := 4;
G_NO_QUAL_PRIC_IND    CONSTANT NUMBER := 6;

G_LINE_DETAIL_INDEX         PLS_INTEGER :=1;
G_DEBUG_ENGINE                VARCHAR2(3);






G_BACK_CALCULATION_STS VARCHAR2(30) := 'BACK_CALCULATION_ERROR';
G_BACK_CALCULATION_STS_NONE VARCHAR2(30) := 'NONE';
G_BACK_CALCULATE VARCHAR2(30) := 'BACK_CALCULATE';
--is_ldet_rec used in calculation_cur in VCLNB.pls
G_LDET_ORDER_TYPE CONSTANT VARCHAR2(30) := 'Y_ORDER';
G_ADJ_ORDER_TYPE CONSTANT VARCHAR2(30) := 'N_ORDER';
G_ASO_ORDER_TYPE CONSTANT VARCHAR2(30) := 'X_ORDER';
G_LDET_LINE_TYPE CONSTANT VARCHAR2(30) := 'Y_LINE';
G_ADJ_LINE_TYPE CONSTANT VARCHAR2(30) := 'N_LINE';
G_ASO_LINE_TYPE CONSTANT VARCHAR2(30) := 'X_LINE';
--debug profile
G_QP_DEBUG VARCHAR2(1);

-- price book
G_CALL_FROM_PRICE_BOOK VARCHAR2(1) := 'N';

TYPE FRT_CHARGE_REC IS RECORD
( LINE_INDEX NUMBER
 ,LINE_DETAIL_INDEX NUMBER
 ,CREATED_FROM_LIST_LINE_ID NUMBER
 ,ADJUSTMENT_AMOUNT NUMBER
 ,LEVEL VARCHAR2(30)
 ,CHARGE_TYPE_CODE VARCHAR2(30)
 ,CHARGE_SUBTYPE_CODE VARCHAR2(30)
 ,UPDATED_FLAG VARCHAR2(1)
 ,DELETED_FLAG VARCHAR2(1));

TYPE FRT_CHARGE_TBL IS TABLE OF FRT_CHARGE_REC INDEX BY BINARY_INTEGER;



TYPE adj_rec_type IS RECORD
(
created_from_list_line_id number,
line_ind number,
curr_line_index number,
line_id number,
line_detail_index number,
created_from_list_line_type varchar2(30),
created_from_list_header_id number,
modifier_level_code varchar(30),
applied_flag varchar2(1),
amount_changed number,
adjusted_unit_price number,
priced_quantity number,
line_priced_quantity number,
updated_adjusted_unit_price number,
automatic_flag varchar2(1),
override_flag varchar2(1),
pricing_group_sequence number,
operand_calculation_code varchar2(30),
operand_value number,
adjustment_amount number,
unit_price number,
accrual_flag varchar2(1),
updated_flag varchar2(1),
process_code varchar2(30),
pricing_status_code varchar2(30),
pricing_status_text varchar2(240),
price_break_type_code varchar2(30),
charge_type_code varchar2(30),
charge_subtype_code varchar2(30),
rounding_factor number,
pricing_phase_id number,
created_from_list_type_code varchar2(30),
limit_code varchar2(30),
limit_text varchar2(2000),
list_line_no varchar2(240),
group_quantity number,
group_amount number,
line_pricing_status_code varchar2(30),
is_ldet_rec varchar2(30),
line_type_code varchar2(30),
price_adjustment_id number,
net_amount_flag varchar2(1),
calculation_code varchar2(30),
ordered_qty number,
catchweight_qty  number,
actual_order_qty number,
line_unit_price number,
line_category varchar2(30),
price_flag varchar2(1)
);

TYPE adj_tbl_type IS TABLE OF adj_rec_type index by BINARY_INTEGER;

--4900095 service item lumpsum discount
--procedure to evaluate the quantity to prorate lumpsum
--to include the parent quantity

PROCEDURE Determine_svc_item_quantity;

PROCEDURE UPDATE_UNIT_PRICE(x_return_status  OUT NOCOPY  VARCHAR2,
				 x_return_status_text OUT NOCOPY VARCHAR2);

/*#
 * This API allows you to get a base price and to apply price adjustments, other
 * benefits, and charges to a transaction.
 *
 * @param p_line_tbl the input table which contains the elements in the calling
 *        application that require a base and adjusted price
 * @param p_qual_tbl the input table that contains qualifier information that
 *        helps the pricing engine to determine the pricelist lines
 *        and modifier list lines for which a pricing request is
 *        eligible
 * @param p_line_attr_tbl the input table that contains pricing attribute
 *        information that helps the pricing engine to determine
 *        the price list lines and modifier list lines for which
 *        a pricing request is eligible
 * @param p_line_detail_tbl the input table that contains the details of the
 *        derivation of the base and adjusted prices
 * @param p_line_detail_qual_tbl the input table that contains the details of the
 *        derivation of the qualifier information
 * @param p_line_detail_attr_tbl the input table that contains the details of the
 *        derivation of the pricing attribute information
 * @param p_related_lines_tbl the input table that contains relationships between
 *        request lines and request line details
 * @param p_control_rec the input record that contains parameters which control
 *        the behavior of the pricing engine
 * @param x_line_tbl the output table which contains the elements in the calling
 *        application that require a base and adjusted price
 * @param x_line_qual the output table that contains qualifier information
 * @param x_line_attr_tbl the output table that contains pricing attribute
 *        information
 * @param x_line_detail_tbl the output table that contains the details of the
 *        derivation of the base and adjusted prices
 * @param x_line_detail_qual_tbl the output table that contains the details of
 *        the derivation of the qualifier information
 * @param x_line_detail_attr_tbl the output table that contains the details of
 *        the derivation of the pricing attribute
 *        information
 * @param x_related_lines_tbl the output table that contains relationships
 *        between request lines and request line details
 * @param x_return_status the return status of the request
 * @param x_return_status_text the return status text of the request
 *
 * @rep:displayname Price Request
 */
PROCEDURE PRICE_REQUEST
(p_line_tbl               IN   QP_PREQ_GRP.LINE_TBL_TYPE,
 p_qual_tbl               IN   QP_PREQ_GRP.QUAL_TBL_TYPE,
 p_line_attr_tbl          IN   QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
 p_line_detail_tbl        IN   QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
 p_line_detail_qual_tbl   IN   QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
 p_line_detail_attr_tbl   IN   QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
 p_related_lines_tbl      IN   QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
 p_control_rec            IN   QP_PREQ_GRP.CONTROL_RECORD_TYPE,
 x_line_tbl               OUT  NOCOPY QP_PREQ_GRP.LINE_TBL_TYPE,
 x_line_qual              OUT  NOCOPY QP_PREQ_GRP.QUAL_TBL_TYPE,
 x_line_attr_tbl          OUT  NOCOPY QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
 x_line_detail_tbl        OUT  NOCOPY QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
 x_line_detail_qual_tbl   OUT  NOCOPY QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
 x_line_detail_attr_tbl   OUT  NOCOPY QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
 x_related_lines_tbl      OUT  NOCOPY  QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
 x_return_status          OUT  NOCOPY VARCHAR2,
 x_return_status_text     OUT  NOCOPY VARCHAR2
);

FUNCTION Raise_GSA_Error
(   p_request_type_code             IN  VARCHAR2
,   p_inventory_item_id             IN  NUMBER
,   p_pricing_date                  IN  DATE
,   p_unit_price                    IN  NUMBER
,   p_cust_account_id		    IN  NUMBER
)
RETURN BOOLEAN;

--overloaded for applications who insert into temp tables directly
PROCEDURE PRICE_REQUEST
(p_control_rec            IN   QP_PREQ_GRP.CONTROL_RECORD_TYPE,
 x_return_status          OUT  NOCOPY VARCHAR2,
 x_return_status_text     OUT  NOCOPY VARCHAR2
);

PROCEDURE CHECK_GSA_VIOLATION( x_return_status OUT NOCOPY VARCHAR2,
                               x_return_status_text OUT NOCOPY VARCHAR2);

PROCEDURE Update_Child_Break_Lines(x_return_status OUT NOCOPY VARCHAR2,
                   x_return_status_text OUT NOCOPY VARCHAR2);

--Procedure to update the line status to 'UPDATED' if there are
--any lines with adjustments with process_code 'UPDATED'/'N'

PROCEDURE Update_Line_Status(x_return_status OUT NOCOPY VARCHAR2,
                                x_return_status_text OUT NOCOPY VARCHAR2);

PROCEDURE CALCULATE_PRICE
(
			p_request_type_code IN VARCHAR2,
			p_rounding_flag IN VARCHAR2,
                        p_view_name IN VARCHAR2,
                        p_event_code IN VARCHAR2,
			p_adj_tbl IN QP_PREQ_PUB.adj_tbl_type,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_return_status_text OUT NOCOPY VARCHAR2
);

-- 3493716: parameter change from p_list_line_id to p_ldet_index
-- 3721860 - reverted the fix done for bug 3493716 and added a new parameter p_line_index
FUNCTION Get_Buy_Line_Price_flag(p_list_line_id IN NUMBER, p_line_index IN NUMBER) RETURN VARCHAR2;

PROCEDURE Update_passed_in_pbh(x_return_status OUT NOCOPY VARCHAR2,
                                x_return_status_text OUT NOCOPY VARCHAR2);

--for catchwt pricing
PROCEDURE GET_ORDERQTY_VALUES(p_ordered_qty IN NUMBER,
                              p_priced_qty IN NUMBER,
                              p_catchweight_qty IN NUMBER,
                              p_actual_order_qty IN NUMBER,
                              p_unit_price IN NUMBER DEFAULT NULL,
                              p_adjusted_unit_price IN NUMBER DEFAULT NULL,
                              p_line_unit_price IN NUMBER DEFAULT NULL,
                              p_operand IN NUMBER DEFAULT NULL,
                              p_adjustment_amt IN NUMBER DEFAULT NULL,
                              p_operand_calculation_code IN VARCHAR2 DEFAULT NULL,
                              p_input_type IN VARCHAR2,
                              x_ordqty_output1 OUT NOCOPY NUMBER,
                              x_ordqty_output2 OUT NOCOPY NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_return_status_text OUT NOCOPY VARCHAR2);

--prg constants
G_FREEGOOD CONSTANT VARCHAR2(30) := 'FREEGOOD';
G_FREEGOOD_LINE CONSTANT VARCHAR2(30) := 'F';
G_BUYLINE	CONSTANT VARCHAR2(30) := 'BUYLINE';
G_NOT_VALID CONSTANT VARCHAR2(30) := 'NOT_VALID';
G_REQUEST_TYPE_CODE VARCHAR2(30);
G_CHECK_CUST_VIEW_FLAG VARCHAR2(30);

G_BUYLINE_PRICE_FLAG QP_PREQ_GRP.FLAG_TYPE;
G_GET_FREIGHT_FLAG VARCHAR2(1);

--2388011
G_PBHVOLATTR_ATTRIBUTE QP_PREQ_GRP.VARCHAR_TYPE;

--procedure to return price and status code and text -- needed by PO team
PROCEDURE get_price_for_line(p_line_index                   IN NUMBER,
                             p_line_id                      IN NUMBER,
                             x_line_unit_price              OUT NOCOPY number,
                             x_adjusted_unit_price          OUT NOCOPY number,
                             x_return_status                OUT NOCOPY varchar2,
                             x_pricing_status_code          OUT NOCOPY varchar2,
                             x_pricing_status_text          OUT NOCOPY varchar2
                            );

type varchar2000_tbl_type is table of varchar2(2000) index by binary_integer; -- bug 3618464
G_LINE_INDEXES_FOR_LINE_ID varchar2000_tbl_type; -- bug 3618464
G_BUYLINE_INDEXES_FOR_LINE_ID varchar2000_tbl_type; -- bug 3721860

--4900095
G_PBH_MOD_LEVEL_CODE QP_PREQ_GRP.varchar_type;
G_Service_pbh_lg_amt_qty QP_PREQ_GRP.number_type;

END QP_PREQ_PUB;

/
