--------------------------------------------------------
--  DDL for Package OKC_PRICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_PRICE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPPRES.pls 120.0 2005/05/25 18:00:03 appldev noship $ */


---Added smhanda---------------------------------------------------------------
----------------------------------------------------------------------------
----PRICE_CONTROL_REC_TYPE holds the control rec to be sent to price_request as well other parameters.
----------------------------------------------------------------------------
TYPE PRICE_CONTROL_REC_TYPE is Record
(
  p_Request_Type_Code		VARCHAR2(3),
  p_negotiated_changed      varchar2(1) DEFAULT 'N', --possible values 'Y','N'
  p_level                   VARCHAR2(2) DEFAULT 'L',--possible values 'L' lines only,'QA' From QA, 'H' Header and lines
  p_calc_flag               varchar2(1) DEFAULT 'B', --possible values
                           --'B' (search and calculate -Apply the existing manual adj. and get new automatics and calculate price),
                           --'C' (calculate only- Recalculate the price based upon already selected adjustments)
                           -- 'S' (Search only- Do not recalculate the price. Just get the new adjustments available)
  p_config_yn               varchar2(1) DEFAULT 'N', --possible values
                            -- 'Y' Configurator call. donot save the price adjustments data
                            -- 'N' not configurator call
                            -- 'S' configurator call. save the price adjustments data
  p_top_model_id            number
);

SUBTYPE GLOBAL_LSE_REC_TYPE IS OKC_PRICE_PVT.GLOBAL_LSE_REC_TYPE;
SUBTYPE GLOBAL_RPRLE_REC_TYPE IS OKC_PRICE_PVT.GLOBAL_RPRLE_REC_TYPE;
SUBTYPE CLE_PRICE_REC_TYPE IS OKC_PRICE_PVT.CLE_PRICE_REC_TYPE;
SUBTYPE Manual_Adj_REC_Type IS OKC_PRICE_PVT.Manual_Adj_REC_Type;
SUBTYPE OKC_CONTROL_REC_TYPE IS OKC_PRICE_PVT.OKC_CONTROL_REC_TYPE;
SUBTYPE LINE_REC_TYPE IS OKC_PRICE_PVT.LINE_REC_TYPE;


SUBTYPE GLOBAL_LSE_TBL_TYPE IS OKC_PRICE_PVT.GLOBAL_LSE_TBL_TYPE;
SUBTYPE GLOBAL_RPRLE_TBL_TYPE IS OKC_PRICE_PVT.GLOBAL_RPRLE_TBL_TYPE;
SUBTYPE NUM_TBL_TYPE IS OKC_PRICE_PVT.NUM_TBL_TYPE;
SUBTYPE CLE_PRICE_TBL_TYPE IS OKC_PRICE_PVT.CLE_PRICE_TBL_TYPE;
SUBTYPE MANUAL_Adj_Tbl_Type IS OKC_PRICE_PVT.MANUAL_Adj_Tbl_Type;
SUBType LINE_Tbl_Type Is OKC_PRICE_PVT.LINE_Tbl_Type;

G_LSE_TBL            GLOBAL_LSE_TBL_TYPE;
G_RUL_TBL            GLOBAL_RPRLE_TBL_TYPE;
G_PRLE_TBL           GLOBAL_RPRLE_TBL_TYPE;

/********** Following is added by JOMY  ****************/

TYPE Customer_Info_Rec_Type IS RECORD
(       customer_id         NUMBER
,       customer_class_code VARCHAR2(240)
,       sales_channel_code  VARCHAR2(240)
,       gsa_indicator       VARCHAR2(1)
,       account_types       QP_Attr_Mapping_PUB.t_MultiRecord
,       customer_relationships       QP_Attr_Mapping_PUB.t_MultiRecord
);

TYPE Order_Info_Rec_Type IS RECORD
(       header_id         NUMBER
,       order_amount      VARCHAR2(240)
,       order_quantity    VARCHAR2(240)
);

TYPE Contract_Info_Rec_Type IS RECORD
(       TOP_MODEL_LINE_ID         NUMBER
,       INVENTORY_ITEM_ID         NUMBER
,       INV_ORG_ID                NUMBER
,       SOLD_TO_ORG_ID            NUMBER
,       PRICING_DATE              DATE
,       GOVERNING_CONTRACT_ID     NUMBER
);


TYPE Site_Use_Rec_Type IS RECORD
(       contact_id        VARCHAR2(240)
,       site_use_id       VARCHAR2(240)
);

TYPE Agreement_Info_Rec_Type IS RECORD
(       agreement_id            VARCHAR2(240)
,       agreement_type_code   VARCHAR2(240)
);

TYPE Item_Segments_Rec_Type IS RECORD
(       inventory_item_id       NUMBER
,       segment1                VARCHAR2(240)
,       segment2                VARCHAR2(240)
,       segment3                VARCHAR2(240)
,       segment4                VARCHAR2(240)
,       segment5                VARCHAR2(240)
,       segment6                VARCHAR2(240)
,       segment7                VARCHAR2(240)
,       segment8                VARCHAR2(240)
,       segment9                VARCHAR2(240)
,       segment10               VARCHAR2(240)
,       segment11               VARCHAR2(240)
,       segment12               VARCHAR2(240)
,       segment13               VARCHAR2(240)
,       segment14               VARCHAR2(240)
,       segment15               VARCHAR2(240)
,       segment16               VARCHAR2(240)
,       segment17               VARCHAR2(240)
,       segment18               VARCHAR2(240)
,       segment19               VARCHAR2(240)
,       segment20               VARCHAR2(240)
);

--G_TOP_MODEL_LINE_ID NUMBER;
--G_MODEL_ID NUMBER;
G_Customer_Info    Customer_Info_Rec_Type;
--G_Order_Info       Order_Info_Rec_Type;
--G_Site_Use         Site_Use_Rec_Type;
--G_Agreement_Info   Agreement_Info_Rec_Type;
G_Item_Segments    Item_Segments_Rec_Type;
G_CONTRACT_INFO    CONTRACT_INFO_REC_TYPE;
/******* The aboveis added by JOMY *******/

--------------------------------------------------------------------
--FUNCTION - GET_LSE_SOURCE_VALUE
-- This function is used in mapping of attributes between QP and OKC
-- The calls to this function will be made by QP Engine to get values for
--various Qualifiers and Pricing Attributes
-- p_lse_tbl - Global Table holding various OKX_SOURCES and their values for lse
-- p_registered_source - The source for which value should be returned
-- Returns the value for the p_registered_source
----------------------------------------------------------------------------
FUNCTION Get_LSE_SOURCE_VALUE (
            p_lse_tbl         IN      global_lse_tbl_type,
            p_registered_source  IN      VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------
--FUNCTION - GET_RUL_SOURCE_VALUE
-- This function is used in mapping of attributes between QP and OKC
-- The calls to this function will be made by QP Engine to get values for
--various Qualifiers and Pricing Attributes
-- p_rul_tbl - Global Table holding various OKX_SOURCES and their values for rules
-- p_registered_code - The rule code for which value should be returned
-- p_registered_source - The source for which value should be returned
-- Returns the value for the p_registered_source+p_registered_code
----------------------------------------------------------------------------
FUNCTION Get_RUL_SOURCE_VALUE (
            p_rul_tbl            IN      global_rprle_tbl_type,
            p_registered_code    IN      varchar2,
            p_registered_source  IN      VARCHAR2)
RETURN VARCHAR2;

------------------------------------------------------------------------------
--FUNCTION - GET_PRLE_SOURCE_VALUE
-- This function is used in mapping of attributes between QP and OKC
-- The calls to this function will be made by QP Engine to get values for
--various Qualifiers and Pricing Attributes
-- p_prle_tbl - Global Table holding various OKX_SOURCES and their values for rules
-- p_registered_role - The role code for which value should be returned
-- p_registered_source - The source for which value should be returned
-- Returns the value for the p_registered_source+p_registered_role
----------------------------------------------------------------------------
FUNCTION Get_PRLE_SOURCE_VALUE (
            p_prle_tbl          IN      global_rprle_tbl_type,
            p_registered_code   IN      varchar2,
            p_registered_source IN      VARCHAR2)
RETURN VARCHAR2;

   ----------------------------------------------------------------------------
-- CALCULATE_PRICE
-- This procedure will calculate the price for the sent in line/header
-- px_cle_price_tbl returns the priced line ids and thier prices
-- p_level tells whether line level or header level
-- possible value 'L','H','QA' DEFAULT 'L'
--p_calc_flag   'B'(Both -calculate and search),'C'(Calculate Only), 'S' (Search only)
----------------------------------------------------------------------------
PROCEDURE CALCULATE_price(
          p_api_version                 IN          NUMBER DEFAULT 1,
          p_init_msg_list               IN          VARCHAR2 DEFAULT OKC_API.G_FALSE,
          p_CHR_ID                      IN          NUMBER,
          p_Control_Rec			        IN          OKC_CONTROL_REC_TYPE,
          px_req_line_tbl               IN  OUT NOCOPY   QP_PREQ_GRP.LINE_TBL_TYPE,
          px_Req_qual_tbl               IN  OUT NOCOPY   QP_PREQ_GRP.QUAL_TBL_TYPE,
          px_Req_line_attr_tbl          IN  OUT NOCOPY   QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
          px_Req_LINE_DETAIL_tbl        IN  OUT NOCOPY   QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
          px_Req_LINE_DETAIL_qual_tbl   IN  OUT NOCOPY   QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
          px_Req_LINE_DETAIL_attr_tbl   IN  OUT NOCOPY   QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
          px_Req_RELATED_LINE_TBL       IN  OUT NOCOPY   QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
          px_CLE_PRICE_TBL		        IN  OUT NOCOPY   CLE_PRICE_TBL_TYPE,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count             OUT  NOCOPY NUMBER,
          x_msg_data              OUT  NOCOPY VARCHAR2);

--------------------------------------------------------------------------
-- Update_Contract_price
-- This procedure will calculate the price for all the Priced lines in a contract
-- while calculating whether header level adjustments are to be considrerd
-- or not will be taken care of by px_control_rec.p_level (possible values 'L','H','QA')
-- p_chr_id - id of the header
-- x_chr_net_price - estimated amount on header

----------------------------------------------------------------------------
PROCEDURE Update_CONTRACT_price(
          p_api_version                 IN          NUMBER,
          p_init_msg_list               IN          VARCHAR2 DEFAULT OKC_API.G_FALSE,
          p_commit                      IN          VARCHAR2 DEFAULT OKC_API.G_TRUE,
          p_CHR_ID                      IN          NUMBER,
          px_Control_Rec			    IN  OUT NOCOPY     PRICE_CONTROL_REC_TYPE,
          x_CLE_PRICE_TBL		        OUT  NOCOPY CLE_PRICE_TBL_TYPE,
          x_chr_net_price               OUT  NOCOPY NUMBER,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count                   OUT  NOCOPY NUMBER,
          x_msg_data                    OUT  NOCOPY VARCHAR2);

----------------------------------------------------------------------------
-- Update_Line_price
-- This procedure will calculate the price for all the Priced lines below sent in line
-- Called when a line is updated in the form
-- p_cle_id - id of the line updated
-- p_chr_id - id of the header
-- p_lowest_level Possible values 0(p_cle_id not null and this line is subline),
--                                 1(p_cle_id not null and this line is upper line),
--                                 -1(update all lines)
--                                 -2(update all lines and header)
--                                 DEFAULT -2
--
--px_chr_list_price  IN OUT -holds the total line list price, for right value pass in the existing value,
--px_chr_net_price   IN OUT -holds the total line net price, for right value pass in the existing value
-- px_cle_amt gets back the net price for the line that was updated. In case of
-- p_negotiated_changed, it brings in the old net price of the line updated

----------------------------------------------------------------------------
PROCEDURE Update_LINE_price(
          p_api_version                 IN          NUMBER,
          p_init_msg_list               IN          VARCHAR2 DEFAULT OKC_API.G_FALSE,
          p_commit                      IN          VARCHAR2 DEFAULT OKC_API.G_TRUE,
          p_CHR_ID                      IN          NUMBER,
          p_cle_id			            IN	        NUMBER DEFAULT null,
          p_lowest_level                IN          NUMBER DEFAULT -2,
          px_Control_Rec			    IN   OUT NOCOPY    PRICE_CONTROL_REC_TYPE,
          px_chr_list_price             IN   OUT NOCOPY    NUMBER,
          px_chr_net_price              IN   OUT NOCOPY    NUMBER,
          x_CLE_PRICE_TBL		        OUT  NOCOPY CLE_PRICE_TBL_TYPE,
          px_cle_amt    		        IN   OUT NOCOPY    NUMBER,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count                   OUT  NOCOPY NUMBER,
          x_msg_data                    OUT  NOCOPY VARCHAR2);

----------------------------------------------------------------------------
-- GET_MANUAL_ADJUSTMENTS
-- This procedure will return all the manual adjustments that qualify for the
-- sent in lines and header
-- To get adjustments for a line pass p_cle_id and p_control_rec.p_level='L'
-- To get adjustments for a Header pass p_cle_id as null and p_control_rec.p_level='H'
----------------------------------------------------------------------------
PROCEDURE get_manual_adjustments(
          p_api_version                 IN          NUMBER,
          p_init_msg_list               IN          VARCHAR2 DEFAULT OKC_API.G_FALSE,
          p_CHR_ID                      IN          NUMBER,
          p_cle_id                      IN          number                     Default Null,
          p_Control_Rec			        IN          PRICE_CONTROL_REC_TYPE,
          x_ADJ_tbl                     OUT  NOCOPY MANUAL_Adj_Tbl_Type,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count                   OUT  NOCOPY NUMBER,
          x_msg_data                    OUT  NOCOPY VARCHAR2);
--end added smhanda------------------------------------------------------------

G_REQUIRED_VALUE            CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
G_INVALID_VALUE             CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
G_COL_NAME_TOKEN            CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
G_PARENT_TABLE_TOKEN        CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
G_CHILD_TABLE_TOKEN         CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'SQLERRM';
G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'SQLCODE';

------------------------------------------------------------------------------------

  -- GLOBAL EXCEPTION

---------------------------------------------------------------------------

G_EXCEPTION_HALT_VALIDATION EXCEPTION;
G_BUILD_RECORD_FAILED       EXCEPTION;
G_REQUIRED_ATTR_FAILED      EXCEPTION;
G_CALL_QP_FAILED            EXCEPTION;

--  Global constant holding the package name

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'OKC_PRICE_PUB';
G_APP_NAME              CONSTANT VARCHAR2(3) := 'OKC';


G_LIST_CONTEXT          CONSTANT VARCHAR2(30) := 'MODLIST';
G_LIST_PRICE_ATTR       CONSTANT VARCHAR2(30) := 'QUALIFIER_ATTRIBUTE4';
G_LIST_MODIFIER_ATTR    CONSTANT VARCHAR2(30) := 'QUALIFIER_ATTRIBUTE6';

G_ITEM_CONTEXT          CONSTANT VARCHAR2(30) := 'ITEM';
G_ITEM_ATTR             CONSTANT VARCHAR2(30) := 'PRICING_ATTRIBUTE1';

G_VOLUME_CONTEXT        CONSTANT VARCHAR2(30) := 'VOLUME';
G_VOLUME_ATTR           CONSTANT VARCHAR2(30) := 'PRICING_ATTRIBUTE1';

G_REQUEST_TYPE_CODE     CONSTANT VARCHAR2(30) := 'ASO';
G_PRICING_EVENT         CONSTANT VARCHAR2(30) := 'PRICE';
G_LINE_TYPE             CONSTANT VARCHAR2(30) := 'SERVICE CONTRACT LINE';
G_CONTROL_REC		QP_PREQ_GRP.CONTROL_RECORD_TYPE;


G_JTF_Party        CONSTANT  VARCHAR2(30)  := 'OKX_PARTY';
G_JTF_Covlvl       CONSTANT  VARCHAR2(30)  := 'OKX_COVSYST';
G_JTF_Custacct     CONSTANT  VARCHAR2(30)  := 'OKX_CUSTACCT';
G_JTF_CusProd      CONSTANT  VARCHAR2(40)  := 'OKX_CUSTPROD';

--G_JTF_Sysitem    CONSTANT  VARCHAR2(30)  := 'X_
G_JTF_Billto       CONSTANT  VARCHAR2(30)  := 'OKX_BILLTO';
G_JTF_Shipto       CONSTANT  VARCHAR2(30)  := 'OKX_SHIPTO';
G_JTF_Warr         CONSTANT  VARCHAR2(30)  := 'OKX_WARRANTY';
G_JTF_Extwar       CONSTANT  VARCHAR2(30)  := 'OKX_SERVICE';


G_JTF_usage        CONSTANT  VARCHAR2(30)  := 'OKX_USAGE';
G_JTF_service      CONSTANT  VARCHAR2(30)  := 'OKX_SERVICE';

G_JTF_Invrule      CONSTANT  VARCHAR2(30)  := 'OKX_INVRULE';
G_JTF_Acctrule     CONSTANT  VARCHAR2(30)  := 'OKX_ACCTRULE';
G_JTF_Payterm      CONSTANT  VARCHAR2(30)  := 'OKX_PPAYTERM';
G_JTF_Price        CONSTANT  VARCHAR2(30)  := 'OKX_PRICE';
G_JTF_Nolov        CONSTANT  VARCHAR2(30)  := 'OKX_NOLOV';
G_PRE_RULE         CONSTANT  VARCHAR2(90)  := 'PRE';

--- ******************************** P A R T I  *******************************************************
--	1. To build the global contract line structure so that it can be used in QP dimension sourcing
--- ***************************************************************************************************

TYPE G_LINE_REC_TYPE IS RECORD(
        HDR_ID   	      	NUMBER,
        START_DATE   		DATE,
        END_DATE   		DATE,
        STATUS_CODE   		VARCHAR2(30),
        LINE_ID   		NUMBER,
        CLASS   		 VARCHAR2(80),
        SUB_CLASS   		VARCHAR2(80),
        PARTY_ID   		NUMBER,
        AGREEMENT_ID  		NUMBER,
        PRICE_LIST_ID  		NUMBER,
        MODIFIER_LIST_ID	NUMBER,
        CURRENCY_CODE  		VARCHAR2(15),
        ACCOUNTING_RULE_ID 	VARCHAR2(30),
        INVOICE_RULE_ID  	VARCHAR2(30),
        PAYMENT_TERMS_ID  	VARCHAR2(30),
        CUSTOMER_PO_NUMBER 	nUMBER,
        BILL_INTERVAL  		VARCHAR2(40),
        INVENTORY_ITEM_ID  	NUMBER,
        ITEM_QTY   		NUMBER,
        ITEM_UOM_CODE  		VARCHAR2(30),
        BILL_TO_ID   		VARCHAR2(30),
        SHIP_TO_ID   		VARCHAR2(30),
        CUSTOMER_ACCT_ID  	NUMBER,
	USAGE_ITEM_FLAG		VARCHAR2(1),
	RECORD_BUILT_FLAG	VARCHAR2(1)
);

TYPE G_SLINE_REC_TYPE IS RECORD(
 	SUB_LINE_INDEX 		NUMBER,
 	SUB_LINE_ID  		Number,
	LINE_ID			NUMBER,
        INVENTORY_ITEM_ID	NUMBER,
        ITEM_QTY   		NUMBER,
        ITEM_UOM_CODE   	VARCHAR2(30),
	CP_UNIT_PRICE		NUMBER,
	UNIT_PRICE 	        NUMBER,
	UNIT_PERCENT	        NUMBER,
	PRICED_QUANTITY         NUMBER,
 	PRICED_UOM_CODE         VARCHAR2(30),
 	CURRENCY_CODE           VARCHAR2(30),
 	ADJUSTED_UNIT_PRICE     NUMBER,
	EXTENDED_AMOUNT		NUMBER
);

TYPE G_SLINE_TBL_TYPE is TABLE OF G_SLINE_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE G_PRICE_BREAK_REC_TYPE IS RECORD(
 	quantity_from  		Number,
	quantity_to		NUMBER,
        list_price		NUMBER,
	break_method		VARCHAR2(10)
);

TYPE G_PRICE_BREAK_TBL_TYPE is TABLE OF G_PRICE_BREAK_REC_TYPE INDEX BY BINARY_INTEGER;


--  This procedure will load the contract line(service item) for a given contract line ID
--  and returns the loaded record
--
PROCEDURE BUILD_OKC_KLINE_REC
(
	p_contract_line_id		IN NUMBER,
	x_contract_line_rec	 OUT NOCOPY OKC_PRICE_PUB.G_LINE_REC_TYPE,
	x_return_status		 OUT NOCOPY VARCHAR2
);

--- ******************************** P A R T II  *******************************************************
--  2. To assemble data in accordance to pricing engine request
--- 	This procedure is to be used by contracts authoring screen to get price of a
--- 	service item on serviceable items. The price will be returned in x_contract_cp_tbl
--- 	which the screen can display on the UI. It basically calls the overloaded calculate_price procedure
--- ****************************************************************************************************


Procedure Calculate_Price(p_clev_tbl          OKC_CONTRACT_PUB.clev_tbl_type,
                          p_cimv_tbl          OKC_CONTRACT_ITEM_PUB.cimv_tbl_type,
                          px_unit_price       OUT NOCOPY Number,
                          px_extended_amount  OUT NOCOPY Number,
                          px_message          OUT NOCOPY Varchar2,
                          x_return_status     OUT NOCOPY VARCHAR2,
                          x_msg_count         OUT NOCOPY NUMBER,
                          x_msg_data          OUT NOCOPY VARCHAR2);

/* Procedure Calculate_Price(p_cle_id            Number,
                          px_contract_cp_tbl  IN OUT NOCOPY OKC_PRICE_PUB.G_SLINE_TBL_TYPE,
                          x_return_status     OUT NOCOPY VARCHAR2,
                          x_msg_count         OUT NOCOPY NUMBER,
                          x_msg_data          OUT NOCOPY VARCHAR2);
PROCEDURE CALCULATE_PRICE
(
	p_contract_line_rec		IN OKC_PRICE_PUB.G_LINE_REC_TYPE,
	px_contract_cp_tbl 		IN OUT NOCOPY OKC_PRICE_PUB.G_SLINE_TBL_TYPE,
	x_return_status		 OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2
); */


PROCEDURE GET_PRICE_BREAK
(
	p_contract_line_rec		IN OKC_PRICE_PUB.G_LINE_REC_TYPE,
	x_price_break_tbl 	 OUT NOCOPY OKC_PRICE_PUB.G_PRICE_BREAK_TBL_TYPE,
	x_return_status		 OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2
);

/*Following is added by JOMY */
PROCEDURE Get_Customer_Info (p_cust_id NUMBER);
FUNCTION Get_Item_Category
(
        P_inventory_item_id IN NUMBER,
        P_org_id            IN NUMBER
) RETURN QP_Attr_Mapping_PUB.t_MultiRecord;

FUNCTION Get_Customer_Class(p_cust_id IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_Account_Type (p_cust_id IN NUMBER) RETURN QP_Attr_Mapping_PUB.t_MultiRecord;

FUNCTION Get_Sales_Channel (p_cust_id IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_GSA (p_cust_id NUMBER) RETURN VARCHAR2;

FUNCTION Get_Item_Segment
(
    p_inventory_item_id IN NUMBER,
               p_org_id IN NUMBER,
    p_seg_num NUMBER
)   RETURN VARCHAR2;
---> Add New parameter(P_org_id IN NUMBER)
--added by smhanda
--pass global rule tbl here
FUNCTION Get_Site_Use (p_rul_tbl IN GLOBAL_RPRLE_TBL_TYPE) RETURN QP_Attr_Mapping_PUB.t_MultiRecord;
--not used anymore take get_invoice--  out later
FUNCTION GET_INVOICE_TO_ORG_ID (p_rul_tbl IN GLOBAL_RPRLE_TBL_TYPE,p_rle_tbl IN GLOBAL_RPRLE_TBL_TYPE) RETURN NUMBER;

FUNCTION GET_PARTY_ID (p_sold_to_org_id IN NUMBER) RETURN NUMBER ;
FUNCTION GET_SHIP_TO_PARTY_SITE_ID(p_rul_tbl IN GLOBAL_RPRLE_TBL_TYPE) RETURN NUMBER;
FUNCTION GET_INVOICE_TO_PARTY_SITE_ID(p_rul_tbl IN GLOBAL_RPRLE_TBL_TYPE) RETURN NUMBER;

-- ifilimon: added to support unit price retrieving by main item attributes
FUNCTION Get_Unit_Price(
  p_price_list_id                 Number,
  p_inventory_item_id             Number,
  p_uom_code                      Varchar2,
  p_cur_code                      Varchar2,
  p_qty                           NUMBER := 1
) RETURN NUMBER ;

-- ifilimon: added to round unit price according to currency rules
FUNCTION ROUND_PRICE(p_price NUMBER, p_cur_code VARCHAR2) RETURN NUMBER;

END OKC_PRICE_PUB;

 

/
