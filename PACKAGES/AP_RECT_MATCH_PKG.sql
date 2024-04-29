--------------------------------------------------------
--  DDL for Package AP_RECT_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_RECT_MATCH_PKG" AUTHID CURRENT_USER AS
/*$Header: aprcvmts.pls 120.7 2005/07/29 11:43:05 schitlap noship $*/

PROCEDURE Base_Credit_RCV_Match(
			    X_match_mode          IN    VARCHAR2,
                            X_invoice_id          IN    NUMBER,
                            X_invoice_line_number IN    NUMBER,
                            X_Po_Line_Location_id IN    NUMBER,
			    X_Rcv_Transaction_id  IN	NUMBER,
                            X_Dist_Tab            IN OUT NOCOPY AP_MATCHING_PKG.DIST_TAB_TYPE,
                            X_amount              IN    NUMBER,
                            X_quantity            IN    NUMBER,
                            X_unit_price          IN    NUMBER,
                            X_uom_lookup_code     IN    VARCHAR2,
			    X_freight_cost_factor_id IN NUMBER DEFAULT NULL,
                            X_freight_amount      IN    NUMBER,
                            X_freight_description IN    VARCHAR2,
			    X_misc_cost_factor_id IN    NUMBER DEFAULT NULL,
                            X_misc_amount         IN    NUMBER,
                            X_misc_description    IN    VARCHAR2,
			    X_retained_amount	  IN	NUMBER DEFAULT NULL,
                            X_calling_sequence    IN    VARCHAR2) ;

PROCEDURE Price_Quantity_Correct_Inv_RCV(
		X_Invoice_Id		IN	NUMBER,
		X_Invoice_Line_Number   IN 	NUMBER,
		X_Corrected_Invoice_Id  IN	NUMBER,
		X_Corrected_Line_Number IN	NUMBER,
		X_Correction_Type	IN	VARCHAR2,
		X_Correction_Quantity	IN	NUMBER,
		X_Correction_Amount	IN	NUMBER,
		X_Correction_Price	IN	NUMBER,
		X_Match_Mode		IN      VARCHAR2,
		X_Po_Line_Location_Id   IN	NUMBER,
		X_Rcv_Transaction_Id	IN	NUMBER,
		X_Corr_Dist_Tab 	IN OUT  NOCOPY
				 	 AP_MATCHING_PKG.CORR_DIST_TAB_TYPE,
		X_Uom_Lookup_Code	IN	VARCHAR2,
		X_Retained_Amount	IN	NUMBER DEFAULT NULL,
		X_Calling_Sequence	IN 	VARCHAR2);

END AP_RECT_MATCH_PKG;

 

/
