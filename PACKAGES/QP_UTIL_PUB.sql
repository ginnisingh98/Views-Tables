--------------------------------------------------------
--  DDL for Package QP_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: QPXRTCNS.pls 120.1.12000000.2 2008/11/25 23:35:38 rbadadar ship $ */

--GLOBAL Constant holding the package name

G_PKG_NAME               CONSTANT  VARCHAR2(30) := 'QP_LIMITS_UTIL_PUB';
G_MULTI_CURRENCY         VARCHAR2(30);
G_MULTI_CURRENCY_USAGE   VARCHAR2(30);
G_ROUNDING_OPTIONS       VARCHAR2(30);
G_OE_UNIT_PRICE_ROUNDING VARCHAR2(30);
G_PRICE_LIST_ID          NUMBER := 0;
G_CURRENCY_CODE          VARCHAR2(15) := 'x';
G_PRICING_EFF_DATE       DATE := trunc(sysdate);
G_ROUNDING_FACTOR        NUMBER := '';

/***********************************************************************
   Procedure to Reverse the Limit Balances and Transactions for a return
   or cancellation.
***********************************************************************/

TYPE qp_preq_lines_tbl_type IS TABLE OF qp_npreq_lines_tmp%ROWTYPE;
TYPE qp_preq_ldets_tbl_type IS TABLE OF qp_npreq_ldets_tmp%ROWTYPE;

Procedure Reverse_Limits (p_action_code             IN  VARCHAR2,
                          p_cons_price_request_code IN  VARCHAR2,
                          p_orig_ordered_qty        IN  NUMBER   DEFAULT NULL,
                          p_amended_qty             IN  NUMBER   DEFAULT NULL,
                          p_ret_price_request_code  IN  VARCHAR2 DEFAULT NULL,
                          p_returned_qty            IN  NUMBER   DEFAULT NULL,
                          x_return_status           OUT NOCOPY VARCHAR2,
                          x_return_message          OUT NOCOPY VARCHAR2);

TYPE ORDER_LINES_STATUS_REC_TYPE IS RECORD
(ALL_LINES_FLAG     VARCHAR2(30),
 SUMMARY_LINE_FLAG  VARCHAR2(30),
 CHANGED_LINES_FLAG VARCHAR2(1));

-- added third parameter for bug 3006670
-- [julin/4261562] added p_request_type_code for PTE/SS filter
Procedure Get_Order_Lines_Status(p_event_code IN VARCHAR2,
                                 x_order_status_rec OUT NOCOPY ORDER_LINES_STATUS_REC_TYPE,
                                 p_freight_call_flag IN VARCHAR2 := 'N',
                                 p_request_type_code IN VARCHAR2 DEFAULT NULL);

-- Bug 7241731/7596981
PROCEDURE Get_Manual_All_Lines_Status(p_event_code IN VARCHAR2,
                                      x_manual_all_lines_status OUT NOCOPY VARCHAR2);

TYPE currency_rec IS RECORD
(
    currency_code		VARCHAR2(15)
   ,currency_name		VARCHAR2(80)
   ,currency_precision          NUMBER
);

TYPE currency_code_tbl IS TABLE OF currency_rec INDEX BY BINARY_INTEGER;

TYPE price_list_rec IS RECORD
(
     price_list_id              NUMBER
    ,name                       VARCHAR2(240)
    ,description                VARCHAR2(2000)
    ,start_date_active          DATE
    ,end_date_active            DATE
);

TYPE price_list_tbl IS TABLE OF price_list_rec INDEX BY BINARY_INTEGER;

TYPE price_lists_rec IS RECORD
(
     price_list_id              NUMBER
    ,name                       VARCHAR2(240)
    ,description                VARCHAR2(2000)
    ,rounding_factor            NUMBER
    ,start_date_active          DATE
    ,end_date_active            DATE
);

TYPE price_lists_tbl IS TABLE OF price_lists_rec INDEX BY BINARY_INTEGER;

TYPE agreement_rec IS RECORD
(
     agreement_name             VARCHAR2(300)
    ,agreement_id               NUMBER
    ,agreement_type             VARCHAR2(30)
    ,price_list_name            VARCHAR2(240)
    ,customer_name              VARCHAR2(360)
    ,payment_term_name          VARCHAR2(15)
    ,start_date_active          DATE
    ,end_date_active            DATE
);

TYPE agreement_tbl IS TABLE OF agreement_rec INDEX BY BINARY_INTEGER;

PROCEDURE Validate_Price_list_Curr_code
(
    l_price_list_id	        IN NUMBER
   ,l_currency_code             IN VARCHAR2
   ,l_pricing_effective_date    IN DATE
   ,l_validate_result          OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Price_List
(
    l_currency_code 		IN VARCHAR2
   ,l_pricing_effective_date    IN DATE
   ,l_agreement_id              IN NUMBER
   ,l_blanket_reference_id      IN VARCHAR2 DEFAULT NULL --Blanket Pricing
   ,l_price_list_tbl           OUT NOCOPY price_list_tbl
   ,l_sold_to_org_id            IN NUMBER DEFAULT NULL
);

PROCEDURE Get_Price_Lists
(
    p_currency_code             IN VARCHAR2 DEFAULT NULL
   ,p_price_lists_tbl           OUT NOCOPY price_lists_tbl
);

PROCEDURE Get_Agreement
(
    p_sold_to_org_id            IN NUMBER DEFAULT NULL
   ,p_transaction_type_id       IN NUMBER DEFAULT NULL
   ,p_pricing_effective_date    IN DATE
   ,p_agreement_tbl            OUT NOCOPY agreement_tbl
);

PROCEDURE Get_Currency
(
    l_price_list_id		IN NUMBER
   ,l_pricing_effective_date    IN DATE
   ,l_currency_code_tbl        OUT NOCOPY CURRENCY_CODE_TBL
);

  -- round_price.p_operand_type could be 'A' for adjustment amount or 'S' for item price
PROCEDURE round_price
(
     p_operand                  IN NUMBER
    ,p_rounding_factor          IN NUMBER
    ,p_use_multi_currency       IN VARCHAR2
    ,p_price_list_id            IN NUMBER
    ,p_currency_code            IN VARCHAR2
    ,p_pricing_effective_date   IN DATE
    ,x_rounded_operand         IN OUT NOCOPY NUMBER
    ,x_status_code             IN OUT NOCOPY VARCHAR2
    ,p_operand_type             IN VARCHAR2 default 'S'
);

  -- called by pricing engine
FUNCTION get_rounding_factor
(
    p_use_multi_currency       IN VARCHAR2
    ,p_price_list_id            IN NUMBER
    ,p_currency_code            IN VARCHAR2
    ,p_pricing_effective_date   IN DATE
) return NUMBER;

FUNCTION Basic_Pricing_Setup RETURN VARCHAR2;

PROCEDURE Reprice_Debug_Engine_Request
(
      p_request_id IN NUMBER,
      x_request_id OUT NOCOPY NUMBER,
      x_return_status OUT NOCOPY VARCHAR2,
      x_return_status_text OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Price_List_Currency
(
    p_price_list_id             IN NUMBER
   ,x_sql_string                OUT NOCOPY VARCHAR2
);

--moved to QPXJUTLS.pls QP_JAVA_ENGINE_UTIL_PUB package
/*--'Y', JavaEngine is installed, 'N' is not installed.
FUNCTION Java_Engine_Installed RETURN VARCHAR2;
*/
FUNCTION HVOP_Pricing_Setup RETURN VARCHAR2;

FUNCTION HVOP_Pricing_On RETURN VARCHAR2;

PROCEDURE RESET_HVOP_PRICING_ON;

TYPE attribute_rec IS RECORD
(
 Attribute_Type           VARCHAR2(30),
 Context_Code             VARCHAR2(30),
 Attribute_Code           VARCHAR2(30),
 Operator                 VARCHAR2(30),
 Attribute_Value_From     VARCHAR2(240),
 Attribute_Value_To       VARCHAR2(240),
 Context_Text             VARCHAR2(240),
 Attribute_Text           VARCHAR2(80),
 Attribute_Value_From_Text VARCHAR2(240)
);

TYPE attribute_tbl IS TABLE OF attribute_rec INDEX BY BINARY_INTEGER;

-- New procedure for bug 3118385
procedure Get_Attribute_Text(p_attributes_tbl  IN OUT NOCOPY attribute_tbl);

 -- This procedure fetchs price lists and modifier lists specific to a blanket.
 -- i.e. pricing data with list_source_code of Blanket and orig_system_header_ref of this blanket header
procedure Get_Blanket_Pricelist_Modifier(
 p_blanket_header_id		IN	NUMBER
,x_price_list_tbl		OUT 	NOCOPY QP_Price_List_PUB.Price_List_Tbl_Type
,x_modifier_list_tbl		OUT 	NOCOPY QP_Modifiers_PUB.Modifier_List_Tbl_Type
,x_return_status		OUT 	NOCOPY VARCHAR2
,x_msg_count			OUT 	NOCOPY NUMBER
,x_msg_data			OUT 	NOCOPY VARCHAR2
);

PROCEDURE Check_Pricing_Attributes (
         P_Api_Version_Number           IN   NUMBER         := 1,
         P_Init_Msg_List                IN   VARCHAR2       := FND_API.G_FALSE,
         P_Commit                       IN   VARCHAR2       := FND_API.G_FALSE,
         P_Inventory_Id                 IN   NUMBER         := FND_API.G_MISS_NUM,
         P_Price_List_Id                IN   NUMBER         := FND_API.G_MISS_NUM,
         X_Check_Return_Status_qp       OUT  NOCOPY VARCHAR2,
         x_return_status                OUT  NOCOPY VARCHAR2,
         x_msg_count                    OUT  NOCOPY  NUMBER,
         x_msg_data                     OUT  NOCOPY  VARCHAR2);

PROCEDURE Check_Pricing_Attributes (
      P_Api_Version_Number              IN   NUMBER         := 1,
      P_Init_Msg_List                   IN   VARCHAR2       := FND_API.G_FALSE,
      P_Commit                          IN   VARCHAR2       := FND_API.G_FALSE,
      P_Inventory_Id                    IN   NUMBER         := FND_API.G_MISS_NUM,
      P_Price_List_Id                   IN   NUMBER         := FND_API.G_MISS_NUM,
      X_Check_Return_Status_qp          OUT  NOCOPY VARCHAR2,
      x_msg_count                       OUT  NOCOPY NUMBER,
      x_msg_data                        OUT  NOCOPY VARCHAR2);

/*--bug 3228829
OM needs API to update the lines_tmp table
this API will take care of updating i/f tables java engine is installed
and update temp tables when plsql engine is installed*/
PROCEDURE Update_Lines(p_update_type IN VARCHAR2, p_line_id IN NUMBER,
                       p_line_index IN NUMBER, p_priced_quantity IN NUMBER);

PROCEDURE Flex_Enabled_Status (p_flexfields_name IN VARCHAR2, x_status OUT NOCOPY VARCHAR2);


END QP_UTIL_PUB;

 

/
