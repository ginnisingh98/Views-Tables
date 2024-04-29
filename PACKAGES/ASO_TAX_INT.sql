--------------------------------------------------------
--  DDL for Package ASO_TAX_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_TAX_INT" AUTHID CURRENT_USER as
/* $Header: asoitaxs.pls 120.7.12010000.3 2012/05/24 07:12:05 rassharm ship $ */
-- Start of Comments
-- Package name     : ASO_TAX_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

--   Record Type:
--	Charge_Control_Rec_Type

TYPE Tax_Control_Rec_Type IS RECORD
(
    Tax_Level		VARCHAR2(50) := 'SHIPMENT',
    Update_DB		VARCHAR2(1)
);

G_Miss_Tax_Control_Rec  Tax_Control_Rec_Type;

-- rassharm gsi
TYPE Tax_Class_Rec_Type IS RECORD
(
quote_line_id number,
tax_classification_code     varchar2(50)
);

G_Miss_Tax_Class_Rec  Tax_Class_Rec_Type;
TYPE   Tax_Class_Rec_Tbl_Type      IS TABLE OF Tax_Class_Rec_Type INDEX BY BINARY_INTEGER;
G_MISS_Tax_Class_TBL          Tax_Class_Rec_Tbl_Type;

/*
 *
 *
PROCEDURE Calculate_Tax(
    P_Api_Version_Number	 IN   NUMBER,
    P_Tax_Control_Rec		 IN   Tax_Control_Rec_Type
					:= G_Miss_Tax_Control_Rec,
    P_Qte_Header_Rec		 IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type
					:= ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_Qte_Line_Rec		 IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type
					:= ASO_QUOTE_PUB.G_Miss_Qte_Line_Rec,
    P_Shipment_Rec		 IN   ASO_QUOTE_PUB.Shipment_Rec_Type
					:= ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC,
    p_tax_detail_rec		 IN   ASO_QUOTE_PUB.Tax_Detail_Rec_Type
					:= ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_REC,
    x_tax_amount		 OUT NOCOPY    NUMBER,
    x_tax_detail_tbl		 OUT NOCOPY    ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_Return_Status              OUT NOCOPY    VARCHAR2,
    X_Msg_Count                  OUT NOCOPY    NUMBER,
    X_Msg_Data                   OUT NOCOPY    VARCHAR2);

TYPE tax_rec_tbl_type is TABLE of RA_CUSTOMER_TRX_LINES%ROWTYPE index by
  binary_integer;

PROCEDURE Calculate_Tax(
                P_Api_Version_Number	IN   NUMBER,
		p_quote_header_id 	IN   NUMBER,
                p_qte_line_id    IN NUMBER :=NULL,
                P_Tax_Control_Rec       IN   Tax_Control_Rec_Type
					:= G_Miss_Tax_Control_Rec,
                x_tax_amount	 OUT NOCOPY    NUMBER,
    		x_tax_detail_tbl        OUT NOCOPY    ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    		X_Return_Status         OUT NOCOPY    VARCHAR2,
    		X_Msg_Count             OUT NOCOPY    NUMBER,
    		X_Msg_Data              OUT NOCOPY    VARCHAR2);

PROCEDURE Calculate_Tax(
		p_trx_id 		IN 	NUMBER,
                p_trx_line_id		IN      NUMBER,
                p_charge_line_id	IN      NUMBER,
		p_viewname 		IN 	VARCHAR2,
                x_tax_amount OUT NOCOPY   	NUMBER,
                x_tax_rec_tbl OUT NOCOPY       ARP_TAX.tax_rec_tbl_type);

Procedure aso_tax_line
(P_Api_Version_Number   IN   NUMBER,
 p_qte_header_id        IN   NUMBER,
 P_Tax_Control_Rec        IN   Tax_Control_Rec_Type
                    := G_Miss_Tax_Control_Rec,
 p_qte_line_id          IN   NUMBER := NULL,
 x_tax_value            OUT NOCOPY    NUMBER,
 x_tax_detail_tbl        OUT NOCOPY    ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
 x_return_status        OUT NOCOPY    VARCHAR2
);
*
*
*/

--Calculate Tax with GTT added as a part of etax By Anoop Rajan om 9 August 2005
--Modified on 11 August with NOCOPY Hint added
procedure CALCULATE_TAX_WITH_GTT
(
	p_API_VERSION_NUMBER IN NUMBER,
	p_qte_header_id IN NUMBER,
	p_qte_line_id IN NUMBER:=NULL,
	x_return_status OUT NOCOPY VARCHAR2,
	X_Msg_Count OUT	NOCOPY NUMBER,
	X_Msg_Data OUT NOCOPY VARCHAR2
);

-- Commenting the following routine as part of release 12. Bug 5044986
/*
 *
 *
PROCEDURE  print_tax_info_rec( p_debug_level in number := 5 );
*
*
*/

FUNCTION Get_Tax_Detail_Id (
		p_qte_header_id		NUMBER,
		p_qte_line_id		NUMBER,
		p_shipment_id		NUMBER) RETURN NUMBER;

FUNCTION Get_Tax_Code (
		p_qte_header_id		NUMBER,
		p_qte_line_id		NUMBER,
		p_shipment_id		NUMBER) RETURN VARCHAR2;

FUNCTION Get_Tax_exempt_flag (
		p_qte_header_id		NUMBER,
		p_qte_line_id		NUMBER,
		p_shipment_id		NUMBER) RETURN VARCHAR2;

FUNCTION Get_Tax_exempt_number (
		p_qte_header_id		NUMBER,
		p_qte_line_id		NUMBER,
		p_shipment_id		NUMBER) RETURN VARCHAR2;

FUNCTION Get_Tax_exempt_reason_code (
		p_qte_header_id		NUMBER,
		p_qte_line_id		NUMBER,
		p_shipment_id		NUMBER) RETURN VARCHAR2;

FUNCTION Get_Tax_Invoice_To (
		p_ln_invoice_id		NUMBER,
		p_hd_invoice_id		NUMBER) RETURN NUMBER;

FUNCTION GET_ra_trx_type_ID (p_order_type_id NUMBER,p_qte_line_rec ASO_QUOTE_PUB.Qte_Line_rec_Type) RETURN NUMBER;

--Procedure added by Anoop on 14 Sep 2005 to print TAX GTT details
Procedure print_tax_info(rec in number,qte_header_id in number) ;
End ASO_TAX_INT;

/
