--------------------------------------------------------
--  DDL for Package AP_PO_AMT_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PO_AMT_MATCH_PKG" AUTHID CURRENT_USER AS
/*$Header: apamtpos.pls 120.3 2005/06/25 00:44:29 schitlap noship $*/

PROCEDURE ap_amt_match
	  	  (X_match_mode  	 IN 	VARCHAR2,
                   X_invoice_id          IN	NUMBER,
                   X_invoice_line_number IN     NUMBER,
		   X_dist_tab            IN OUT NOCOPY AP_MATCHING_PKG.DIST_TAB_TYPE,
		   X_po_line_location_id IN	NUMBER,
		   X_amount              IN	NUMBER,
		   X_quantity	         IN	NUMBER,
		   X_unit_price	    	 IN 	NUMBER,
                   X_uom_lookup_code     IN     VARCHAR2,
		   X_final	   	 IN  	VARCHAR2,
		   X_overbill	         IN	VARCHAR2,
		   X_freight_cost_factor_id IN  NUMBER DEFAULT NULL,
		   X_freight_amount      IN	NUMBER,
		   X_freight_description IN	VARCHAR2,
		   x_misc_cost_factor_id IN     NUMBER DEFAULT NULL,
		   X_misc_amount         IN	NUMBER,
		   X_misc_description    IN	VARCHAR2,
		   X_retained_amount	 IN	NUMBER DEFAULT NULL,
		   X_calling_sequence    IN	VARCHAR2);


PROCEDURE Amount_Correct_Inv_PO(
                X_Invoice_Id            IN      NUMBER,
                X_Invoice_Line_Number   IN      NUMBER,
                X_Corrected_Invoice_Id  IN      NUMBER,
                X_Corrected_Line_Number IN      NUMBER,
                X_Match_Mode            IN      VARCHAR2,
                X_Correction_Amount     IN      NUMBER,
                X_Po_Line_Location_Id   IN      NUMBER,
                X_Corr_Dist_Tab         IN OUT NOCOPY AP_MATCHING_PKG.CORR_DIST_TAB_TYPE,
                X_Final_Match_Flag      IN      VARCHAR2,
                X_Uom_Lookup_Code       IN      VARCHAR2,
		X_Retained_Amount	IN	NUMBER DEFAULT NULL,
                X_Calling_Sequence      IN      VARCHAR2);


END AP_PO_AMT_MATCH_PKG;

 

/
