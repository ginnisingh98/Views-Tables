--------------------------------------------------------
--  DDL for Package AP_INVOICE_CORRECTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_INVOICE_CORRECTIONS_PKG" AUTHID CURRENT_USER AS
/*$Header: apinvcos.pls 120.2 2006/10/20 22:07:33 bghose noship $*/


TYPE r_corr_dist_info IS RECORD
   (corrected_inv_dist_id AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_DISTRIBUTION_ID%TYPE,--INDEX column
    invoice_distribution_id AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_DISTRIBUTION_ID%TYPE,
    amount                AP_INVOICE_DISTRIBUTIONS_ALL.AMOUNT%TYPE,
    base_amount           AP_INVOICE_DISTRIBUTIONS_ALL.BASE_AMOUNT%TYPE,
    rounding_amt          AP_INVOICE_DISTRIBUTIONS_ALL.ROUNDING_AMT%TYPE
    );

TYPE dist_tab_type IS TABLE OF r_corr_dist_info INDEX BY BINARY_INTEGER;

-- Bug 5597409, Added included_tax_amount
TYPE r_corr_line_info IS RECORD
   (corrected_line_number AP_INVOICE_LINES_ALL.LINE_NUMBER%TYPE,	--INDEX column
    line_amount		  AP_INVOICE_LINES_ALL.AMOUNT%TYPE,
    base_amount		  AP_INVOICE_LINES_ALL.BASE_AMOUNT%TYPE,
    rounding_amt          AP_INVOICE_LINES_ALL.ROUNDING_AMT%TYPE,
    line_number           AP_INVOICE_LINES_ALL.LINE_NUMBER%TYPE,
    included_tax_amount   AP_INVOICE_LINES_ALL.INCLUDED_TAX_AMOUNT%TYPE);

TYPE line_tab_type IS TABLE OF r_corr_line_info INDEX BY BINARY_INTEGER;

Procedure Invoice_Correction(
		X_Invoice_Id		IN	NUMBER,
		X_Invoice_Line_Number   IN 	NUMBER,
		X_Corrected_Invoice_Id  IN	NUMBER,
		X_Corrected_Line_Number IN	NUMBER,
		X_Prorate_Lines_Flag    IN      VARCHAR2,
		X_Prorate_Dists_Flag    IN      VARCHAR2,
		X_Correction_Quantity   IN      NUMBER,
		X_Correction_Amount   	IN	NUMBER,
		X_Correction_Price	IN	NUMBER,
		X_Line_Tab              IN OUT NOCOPY LINE_TAB_TYPE,
		X_Dist_Tab		IN OUT NOCOPY DIST_TAB_TYPE,
		X_Calling_Sequence	IN 	VARCHAR2);


END AP_INVOICE_CORRECTIONS_PKG;

 

/
