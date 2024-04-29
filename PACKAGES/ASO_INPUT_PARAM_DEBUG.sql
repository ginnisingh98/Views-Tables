--------------------------------------------------------
--  DDL for Package ASO_INPUT_PARAM_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_INPUT_PARAM_DEBUG" AUTHID CURRENT_USER as
/* $Header: asovinps.pls 120.1 2005/07/07 10:54:25 appldev noship $ */

PROCEDURE Print_quote_input
(P_Quote_Header_Rec IN ASO_QUOTE_PUB.Qte_Header_Rec_Type,
P_hd_Price_Attributes_Tbl IN ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
P_hd_Payment_Tbl IN ASO_QUOTE_PUB.Payment_Tbl_Type,
P_hd_Shipment_tbl IN  ASO_QUOTE_PUB.Shipment_tbl_Type,
P_hd_Tax_Detail_Tbl IN ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
P_hd_Sales_Credit_Tbl IN ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
P_Qte_Line_Tbl IN ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
P_Qte_Line_Dtl_Tbl IN  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
P_Price_Adjustment_Tbl IN  ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
P_Ln_Price_Attributes_Tbl IN  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
P_Ln_Payment_Tbl IN  ASO_QUOTE_PUB.Payment_Tbl_Type,
P_Ln_Shipment_Tbl IN  ASO_QUOTE_PUB.Shipment_Tbl_Type,
P_Ln_Tax_Detail_Tbl IN  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
P_ln_Sales_Credit_Tbl IN  ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
P_Qte_Access_Tbl           IN   ASO_QUOTE_PUB.Qte_Access_Tbl_Type := ASO_QUOTE_PUB.G_MISS_QTE_ACCESS_TBL
);

END ASO_INPUT_PARAM_DEBUG;


 

/
