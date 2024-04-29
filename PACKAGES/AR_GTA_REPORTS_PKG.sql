--------------------------------------------------------
--  DDL for Package AR_GTA_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_GTA_REPORTS_PKG" AUTHID CURRENT_USER AS
--$Header: ARGRREPS.pls 120.0.12010000.3 2010/01/19 08:38:42 choli noship $
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|      ARRREPS.pls                                                     |
--|                                                                       |
--| DESCRIPTION                                                           |
--|      This package is used to generate Golden Tax Adaptor reports      |
--|                                                                       |
--| HISTORY                                                               |
--|     05/08/05          Qiang Li         Created                        |
--|     05/17/05          Donghai Wang     Add procedures:                |
--|                                            Compare_Header             |
--|                                            Compare_Lines              |
--|                                            Get_Unmatched_Lines        |
--|                                            Generate_Discrepancy_Xml   |
--|                                            Generate_Discrepancy_Rep   |
--|    09/27/05           Qiang Li         Add function:                  |
--|                                            Get_Gt_Tax_Reg_Count       |
--|    05/12/05           Qiang Li        Update Generate_Mapping_Rep     |
--|                                       Update Get_Gt_Trx               |
--|                                       Update Get_Ar_Trx               |
--|                                       Rename Get_Gt_Tax_Reg_Count to  |
--|                                       Get_Gt_Count                    |
--|    07/02/06           Qiang Li        Update FUNCTION Get_Ar_Trx     |
--|    06/18/07           Donghai Wang    Update G_MODULE_PREFIX to follow|
--|                                       FND log Standards               |
--|    25-Jul-2009        Allen Yang      Add functions and procedure:    |
--|                                            Get_Consolidation_Trx      |
--|                                            Get_Consolidated_Trxs      |
--|                                            Generate_Consol_Mapping_Rep|
--|                                       for bug 8605196: ENHANCEMENT FOR|
--|                                       GOLDEN TAX ADAPTER R12.1.2      |
--+======================================================================*/

--Declare global variable for package name
G_MODULE_PREFIX VARCHAR2(50) :='ar.plsql.AR_GTA_REPORTS_PKG';
--==========================================================================
--  FUNCTION NAME:
--
--    Get_Gt_Count                        Public
--
--  DESCRIPTION:
--
--    This function get GT trxs count in a given
--    AR transaction
--  PARAMETERS:
--      In:  p_ar_trx_header_id        AR transaction header id
--           p_fp_tax_reg_num          first party tax registration number
--           P_Gt_Inv_Date_From        Golden Tax Invoice Date from
--           P_Gt_Inv_Date_To          Golden Tax Invoice Date to
--           P_Gt_Inv_Num_From         Golden Tax Invoice Number from
--           P_Gt_Inv_Num_To	         Golden Tax Invoice Number to
--     Out:
--
--  Return: VARCHAR2
--
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           27-Sep-05   	Qiang Li        Created.
--           05-Dec-05    Qiang Li        Rename to get_gt_count
--                                        Add four new parameters
--
--===========================================================================
FUNCTION Get_Gt_Count
( p_ar_trx_header_id IN NUMBER
, p_fp_tax_reg_num   IN VARCHAR2
, P_Gt_Inv_Date_From IN DATE
, P_Gt_Inv_Date_To   IN DATE
, P_Gt_Inv_Num_From  IN VARCHAR2
, P_Gt_Inv_Num_To	   IN VARCHAR2
)
RETURN VARCHAR2;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Ar_Trx                        Public
--
--  DESCRIPTION:
--
--    This function get xml data of AR transaction.
--
--  PARAMETERS:
--      In:  p_org_id                  Operating unit id
--           p_ar_trx_header_id        AR transaction header id
--           p_fp_tax_reg_num          first party tax registration number
--           P_Gt_Inv_Date_From        Golden Tax Invoice Date from
--           P_Gt_Inv_Date_To          Golden Tax Invoice Date to
--           P_Gt_Inv_Num_From         Golden Tax Invoice Number from
--           P_Gt_Inv_Num_To	         Golden Tax Invoice Number to
--     Out:
--
--  Return: XMLTYPE
--
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           05/08/05   	Qiang Li        Created.
--           09/27/05     Qiang Li        Add new parameter p_fp_tax_reg_num
--           05-Dec-2005  Qiang Li        add four new parameters
--           07-Feb-2006  Qiang Li        Change data type of p_fp_tax_reg_num
--                                        to Varchar2
--===========================================================================
FUNCTION Get_Ar_Trx
( p_ar_trx_header_id IN NUMBER
, p_org_id           IN NUMBER
, p_fp_tax_reg_num   IN VARCHAR2
, P_Gt_Inv_Date_From IN DATE
, P_Gt_Inv_Date_To   IN DATE
, P_Gt_Inv_Num_From  IN VARCHAR2
, P_Gt_Inv_Num_To	   IN VARCHAR2
)
RETURN XMLTYPE;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Gt_Trxs                        Public
--
--  DESCRIPTION:
--
--    This function get XML data of Golden Tax transactions
--
--  PARAMETERS:
--      In:  p_org_id                  Operating unit id
--           p_ar_trx_header_id        AR transaction header id
--           p_Tax_Registration_Number First party tax registration number
--           P_Gt_Inv_Date_From        Golden Tax Invoice Date from
--           P_Gt_Inv_Date_To          Golden Tax Invoice Date to
--           P_Gt_Inv_Num_From         Golden Tax Invoice Number from
--           P_Gt_Inv_Num_To	         Golden Tax Invoice Number to
--
--     Out:
--
--  Return: XMLTYPE
--
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           05/08/05   	Qiang Li        Created.
--           05/12/05     Qiang Li        add five new parameters
--
--===========================================================================
  FUNCTION Get_Gt_Trxs
  ( P_Ar_Trx_Header_Id        IN NUMBER
  , P_Org_Id                  IN NUMBER
  , p_Tax_Registration_Number IN VARCHAR2
  , P_Gt_Inv_Date_From        IN DATE
  , P_Gt_Inv_Date_To          IN DATE
  , P_Gt_Inv_Num_From         IN VARCHAR2
  , P_Gt_Inv_Num_To	          IN VARCHAR2
  )
  RETURN Xmltype;


--==========================================================================
--  PROCEDURE NAME:
--
--    Generate_Mapping_Rep                Public
--
--  DESCRIPTION:
--
--    This procedure generate mapping report data
--
--  PARAMETERS:
--      In:   p_fp_tax_reg_num         First Party Tax Registration Number
--            p_org_id                 Operating unit id
--            p_trx_source             Transaction source,GT or AR
--            p_customer_id            Customer id
--            p_gt_inv_num_from        GT invoice number low range
--            p_gt_inv_num_to          GT invoice number high range
--            p_gt_inv_date_from       GT invoice date low range
--            p_gt_inv_date_to         GT invoice date high range
--            p_ar_inv_num_from        AR invoice number low range
--            p_ar_inv_num_to          AR invoice number high range
--            p_ar_inv_date_from       AR invoice date low range
--            p_ar_inv_date_to         AR invoice date high range
--     Out:
--
--
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           05/08/05   	Qiang Li        Created.
--           27-Sep-2005:Qiang Li   Add a new parameter fp_tax_reg_number.
--
--===========================================================================
Procedure Generate_Mapping_Rep
( p_org_id	          IN	NUMBER
, p_fp_tax_reg_num        IN  VARCHAR2
, p_trx_source            IN	NUMBER
, p_customer_id           IN	NUMBER
, p_gt_inv_num_from       IN	VARCHAR2
, p_gt_inv_num_to         IN	VARCHAR2
, p_gt_inv_date_from      IN	DATE
, p_gt_inv_date_to        IN	DATE
, p_ar_inv_num_from       IN	VARCHAR2
, p_ar_inv_num_to         IN	VARCHAR2
, p_ar_inv_date_from      IN	DATE
, p_ar_inv_date_to        IN	DATE
);

--==========================================================================
--  PROCEDURE NAME:
--
--      Compare_Header                Public
--
--  DESCRIPTION:
--
--   This Procedure Compare Ar, Gta, Gt Headers AND Input Difference Record
--   Compared Columns Include: "Amount", "Tax Amount", "Customer Name",
--  "Bank Name Account" and "Tax Payer Id"
--
--  PARAMETERS:
--      In:   p_org_id                 Operating unit id
--            p_ar_header_id           AR Transaction id
--
--     Out:   x_has_difference
--
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           05/17/05   	Donghai  Wang        Created.
--
--===========================================================================
PROCEDURE Compare_Header
( p_org_id               IN         NUMBER
, p_ar_header_id	 IN	    NUMBER
, x_has_difference	 OUT NOCOPY BOOLEAN
);

--==========================================================================
--  PROCEDURE NAME:
--
--      Compare_Lines                Public
--
--  DESCRIPTION:
--
--      This Procedure Compare Ar, Gta, Gt Lines And Input Difference Record
--      Compared Columns Include: "Goods Description", "Line Amount",
--      "Vat Line Tax", "Vat Tax Rate", "Quantity", "Unit Price" And "Uom"
--
--  PARAMETERS:
--      In:   p_org_id                 Operating unit id
--            p_ar_header_id           AR Transaction id
--
--     Out:   x_has_difference
--
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           05/17/05   	Donghai  Wang        Created.
--
--===========================================================================
PROCEDURE Compare_Lines
( p_org_id	         IN          NUMBER
, p_ar_header_id	 IN          NUMBER
, x_validated_lines      OUT  NOCOPY NUMBER
, x_ar_matching_lines    OUT  NOCOPY NUMBER
, x_ar_partially_import  OUT  NOCOPY NUMBER
, x_has_difference	 OUT  NOCOPY BOOLEAN
);

--==========================================================================
--  PROCEDURE NAME:
--
--      Get_Unmatched_Lines                Public
--
--  DESCRIPTION:
--
--      This Procedure Get Gta, Gt Unmatched Lines And Input Difference Record
--
--
--  PARAMETERS:
--      In:   p_org_id                 Operating unit id
--            p_ar_header_id           AR Transaction id
--
--     Out:   x_has_difference
--
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           05/17/05   	Donghai  Wang        Created.
--
--==========================================================================
PROCEDURE Get_Unmatched_Lines
( p_org_id	        IN	   NUMBER
, p_ar_header_id	IN	   NUMBER
, x_has_difference	OUT NOCOPY BOOLEAN
);


--==========================================================================
--  PROCEDURE NAME:
--
--      Generate_Discrepancy_Xml               Public
--
--  DESCRIPTION:
--
--       This Procedure is used to generate XML element content
--       for disrcepancy report output
--
--
--  PARAMETERS:
--     In:  p_org_id                     Operating unit id
--          p_gta_batch_num_from         GTA batch number low range
--          p_gta_batch_num_to           GTA batch number high range
--          p_ar_transaction_type        AR transaction type
--          p_cust_num_from              Customer Number low range
--          p_cust_num_to                Customer Number high range
--          p_cust_name_from             Customer Name low range
--          p_cust_name_to               Customer Name high range
--          p_gl_period                  GL period name
--          p_gl_date_from               GL period date low range
--          p_gl_date_to                 GL period date high range
--          p_ar_trx_batch_from          AR Transaction name low range
--          p_ar_trx_batch_to            AR Transaction name high range
--          p_ar_trx_num_from            AR Transaction number low range
--          p_ar_trx_num_to              AR Transaction number high range
--          p_ar_trx_date_from           AR Transaction date low range
--          p_ar_trx_date_to             AR Transaction date high range
--          p_ar_doc_num_from            AR transaction document
--                                       sequence low range
--          p_ar_doc_num_to              AR transaction document sequence high range
--          p_original_curr_code         Currency code on AR transaction
--          p_primary_sales              Primary salesperson
--          p_validated_lines_total      the number of ar lines that have been
--                                       validated by the report
--          p_ar_matching_lines_total    the number of ar lines that exactly
--                                       match with GTA invoice
--                                       and GT invoice
--          p_ar_partially_import_total  ar lines are not fully imported to GT
--
--    Out:  x_output
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           05/17/05   	Donghai  Wang        Created.
--
--==========================================================================
PROCEDURE Generate_Discrepancy_Xml
( p_org_id	                  IN	NUMBER
, p_gta_batch_num_from	          IN	VARCHAR2
, p_gta_batch_num_to              IN	VARCHAR2
, p_ar_transaction_type	          IN	NUMBER
, p_cust_num_from	          IN	VARCHAR2
, p_cust_num_to	                  IN	VARCHAR2
, p_cust_name_id	          IN	NUMBER
, p_gl_period	                  IN	VARCHAR2
, p_gl_date_from	          IN	DATE
, p_gl_date_to	                  IN	DATE
, p_ar_trx_batch_from	          IN	VARCHAR2
, p_ar_trx_batch_to	          IN	VARCHAR2
, P_ar_trx_num_from	          IN	VARCHAR2
, p_ar_trx_num_to	          IN	VARCHAR2
, p_ar_trx_date_from	          IN	DATE
, p_ar_trx_date_to	          IN	DATE
, p_ar_doc_num_from	          IN	VARCHAR2
, p_ar_doc_num_to	          IN	VARCHAR2
, p_original_curr_code	          IN	VARCHAR2
, p_primary_sales	          IN	NUMBER
, p_validated_lines_total         IN    NUMBER
, p_ar_matching_lines_total       IN    NUMBER
, p_ar_partially_import_total     IN    NUMBER
, x_output                        OUT   NOCOPY XMLTYPE
);


--==========================================================================
--  PROCEDURE NAME:
--
--      Generate_Discrepancy_Rep               Public
--
--  DESCRIPTION:
--
--       This Procedure Generate Discrepancy Report Data
--
--
--  PARAMETERS:
--      In:  p_org_id                 Operating unit id
--           p_gta_batch_num_from     GTA batch number low range
--           p_gta_batch_num_to       GTA batch number high range
--           p_ar_transaction_type    AR transaction type
--           p_cust_num_from          Customer Number low range
--           p_cust_num_to            Customer Number high range
--           p_cust_name_from         Customer Name low range
--           p_cust_name_to           Customer Name high range
--           p_gl_period              GL period name
--           p_gl_date_from           GL period date low range
--           p_gl_date_to             GL period date high range
--           p_ar_trx_batch_from      AR Transaction name low range
--           p_ar_trx_batch_to        AR Transaction name high range
--           p_ar_trx_num_from        AR Transaction number low range
--           p_ar_trx_num_to          AR Transaction number high range
--           p_ar_trx_date_from       AR Transaction date low range
--           p_ar_trx_date_to         AR Transaction date high range
--           p_ar_doc_num_from        AR transaction document sequence low range
--           p_ar_doc_num_to          AR transaction document sequence high range
--           p_original_curr_code     Currency code on AR transaction
--           p_primary_sales          Primary salesperson
--
--    Out:
--
--  DESIGN REFERENCES:
--      GTA_REPORTS_TD.doc
--
--  CHANGE HISTORY:
--
--           05/17/05   	Donghai  Wang        Created.
--
--==========================================================================
PROCEDURE Generate_Discrepancy_Rep
( p_org_id	                  IN	NUMBER
, p_gta_batch_num_from	          IN	VARCHAR2
, p_gta_batch_num_to              IN	VARCHAR2
, p_ar_transaction_type	          IN	NUMBER
, p_cust_num_from	          IN	VARCHAR2
, p_cust_num_to	                  IN	VARCHAR2
, p_cust_name_id	          IN	NUMBER
, p_gl_period	                  IN	VARCHAR2
, p_gl_date_from	          IN	VARCHAR2
, p_gl_date_to	                  IN	VARCHAR2
, p_ar_trx_batch_from	          IN	VARCHAR2
, p_ar_trx_batch_to	          IN	VARCHAR2
, P_ar_trx_num_from	          IN	VARCHAR2
, p_ar_trx_num_to	          IN	VARCHAR2
, p_ar_trx_date_from	          IN	VARCHAR2
, p_ar_trx_date_to	          IN	VARCHAR2
, p_ar_doc_num_from	          IN	VARCHAR2
, p_ar_doc_num_to	          IN	VARCHAR2
, p_original_curr_code	          IN	VARCHAR2
, p_primary_sales	          IN	NUMBER
);

--==========================================================================
--  PROCEDURE NAME:
--
--      Generate_Consol_Mapping_Rep               Public
--
--  DESCRIPTION:
--
--       This procedure generates Invoice Consolidation Mapping Report data.
--
--
--  PARAMETERS:
--      In:  p_org_id                 Operating unit id
--           p_gl_period              GL period
--           p_customer_num_from      Customer number low range
--           p_customer_num_to        Customer number high range
--           p_customer_name_from     Customer name low range
--           p_customer_name_to       Customer name high range
--           p_consol_trx_num_from    Consolidated invoice number low range
--           p_consol_trx_num_to      Consolidated invoice number high range
--           p_invoice_type           Invoice type
--
--    Out:
--
--  DESIGN REFERENCES:
--      GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--      25-Jul-2009  	Allen Yang        Created.
--
--==========================================================================
Procedure Generate_Consol_Mapping_Rep
( p_org_Id	            IN   NUMBER
, p_gl_period           IN   VARCHAR2
, p_customer_num_from   IN   VARCHAR2
, p_customer_num_to     IN   VARCHAR2
, p_customer_name_from  IN   VARCHAR2
, p_customer_name_to    IN   VARCHAR2
, p_consol_trx_num_from IN   VARCHAR2
, p_consol_trx_num_to   IN   VARCHAR2
, p_invoice_type        IN   VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--      Get_Consolidation_Trx               Public
--
--  DESCRIPTION:
--
--       This procedure returns XML data for a given consolidated invoice.
--
--
--  PARAMETERS:
--      In:  p_trx_header_id          invoice header identifier
--
--
--      Out:
--
--  DESIGN REFERENCES:
--      GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--      25-Jul-2009  	Allen Yang        Created.
--
--==========================================================================
FUNCTION Get_Consolidation_Trx(p_trx_header_id	  IN  NUMBER)
RETURN XMLTYPE;

--==========================================================================
--  PROCEDURE NAME:
--
--      Get_Consolidated_Trxs               Public
--
--  DESCRIPTION:
--
--      For a given consolidated invoice, get xml data of its
--      consolidation invoices.
--
--
--  PARAMETERS:
--      In:  p_trx_header_id          invoice header identifier
--
--
--      Out:
--
--  DESIGN REFERENCES:
--      GTA_12.1.2_Technical_Design.doc
--
--  CHANGE HISTORY:
--
--      25-Jul-2009  	Allen Yang        Created.
--
--==========================================================================
FUNCTION Get_Consolidated_Trxs(p_trx_header_id	  IN  NUMBER)
RETURN XMLTYPE;
--==========================================================================
--  PROCEDURE NAME:
--
--      Compare_Consolidated_Inv                Public
--
--  DESCRIPTION:
--
--   This Procedure Compare completed consolidated_invs with gt invoice
--
--  PARAMETERS:
--      In:   p_org_id                 Operating unit id
--            p_gta_header_id          GTA invoice header id
--
--     Out:   x_has_difference
--
--
--  DESIGN REFERENCES:
--
--
--  CHANGE HISTORY:
--
--           09-Aug-2009  Yao Zhang   Created.
--===========================================================================
PROCEDURE Compare_Consolidated_Inv
(p_org_id         NUMBER
,p_gta_header_id  NUMBER
,x_has_difference OUT NOCOPY	BOOLEAN
) ;
END AR_GTA_REPORTS_PKG;

/
