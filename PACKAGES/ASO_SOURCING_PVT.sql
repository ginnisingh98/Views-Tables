--------------------------------------------------------
--  DDL for Package ASO_SOURCING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SOURCING_PVT" AUTHID CURRENT_USER as
/* $Header: asovsrcs.pls 115.8 2003/05/09 22:10:26 smadapus ship $ */
-- Start of Comments
-- Package name     : ASO_SOURCING_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

FUNCTION Get_Customer_Class
(p_cust_account_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION Get_Account_Type
(p_cust_account_id IN NUMBER)
RETURN QP_Attr_Mapping_PUB.t_MultiRecord;

FUNCTION Get_Sales_Channel
(p_cust_account_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION Get_GSA
(p_cust_account_id NUMBER)
RETURN VARCHAR2;

FUNCTION Get_quote_Qty
(p_qte_header_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION Get_quote_Amount(p_qte_header_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION Get_shippable_flag(p_qte_line_id NUMBER)
RETURN VARCHAR2;

FUNCTION Get_Cust_Acct (p_quote_header_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Ship_to_Site_Use (p_quote_header_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Line_Ship_to_Site_Use (p_quote_line_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Invoice_to_Site_Use (p_quote_header_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Line_Invoice_Site_Use (p_quote_line_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Ship_to_Party_Site (p_quote_header_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Line_Ship_Party_Site (p_quote_line_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Invoice_to_Party_Site (p_quote_header_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Line_Invoice_Party_Site (p_quote_line_id NUMBER)
RETURN NUMBER;

--FUNCTION Get_Party_Id (p_quote_header_id NUMBER)
--RETURN NUMBER;



FUNCTION Get_Cust_Po(
p_qte_header_id 	number
) RETURN  VARCHAR2;

FUNCTION Get_line_Cust_Po(
p_qte_line_id       number
) RETURN  VARCHAR2;

FUNCTION Get_Request_date(
p_qte_header_id 	number
) RETURN  DATE;

FUNCTION Get_line_Request_date(
p_qte_line_id 	number
) RETURN  DATE;

FUNCTION Get_Freight_term(
p_qte_header_id 	number
	) RETURN  DATE;

FUNCTION Get_line_Freight_term(
p_qte_line_id    number
) RETURN  VARCHAR2;

FUNCTION Get_Payment_term(
p_qte_header_id 	number
) RETURN  NUMBER;

FUNCTION Get_line_Payment_term(
p_qte_line_id    number,p_qte_header_id number
) RETURN  NUMBER;


FUNCTION Get_top_model_item_id(
p_qte_line_id    number
) RETURN  NUMBER;


FUNCTION Get_freight_terms_code(
p_qte_line_id    number
) RETURN  VARCHAR2;


FUNCTION Get_shipping_method_code(
p_qte_line_id    number
) RETURN  VARCHAR2;

FUNCTION Get_header_ship_flag(p_qte_header_id NUMBER)
RETURN VARCHAR2;

FUNCTION Get_Parent_List_price (p_quote_line_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Minisite_Id RETURN NUMBER;

End ASO_SOURCING_PVT;

 

/
