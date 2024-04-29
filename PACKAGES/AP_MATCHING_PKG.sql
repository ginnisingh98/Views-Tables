--------------------------------------------------------
--  DDL for Package AP_MATCHING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_MATCHING_PKG" AUTHID CURRENT_USER AS
/*$Header: apmatchs.pls 120.13.12010000.2 2009/02/12 11:56:56 mayyalas ship $*/

TYPE r_dist_info IS RECORD
  (po_distribution_id      	PO_DISTRIBUTIONS.po_distribution_id%TYPE,   --Index Column
   invoice_distribution_id 	AP_INVOICE_DISTRIBUTIONS.invoice_distribution_id%TYPE,
   quantity_invoiced       	AP_INVOICE_DISTRIBUTIONS.quantity_invoiced%TYPE,
   amount                  	AP_INVOICE_DISTRIBUTIONS.amount%TYPE,
   base_amount		   	AP_INVOICE_DISTRIBUTIONS.base_amount%TYPE,
   rounding_amt		   	AP_INVOICE_DISTRIBUTIONS.rounding_amt%TYPE,
   unit_price              	AP_INVOICE_DISTRIBUTIONS.unit_price%TYPE,
   dist_ccid		   	AP_INVOICE_DISTRIBUTIONS.dist_code_combination_id%TYPE,
   po_ccid		   	PO_DISTRIBUTIONS.code_combination_id%TYPE,
   accrue_on_receipt_flag  	PO_DISTRIBUTIONS.accrue_on_receipt_flag%TYPE,
   project_id		   	PO_DISTRIBUTIONS.project_id%TYPE,
   task_id		   	PO_DISTRIBUTIONS.task_id%TYPE,
   award_id			PO_DISTRIBUTIONS.award_id%TYPE DEFAULT NULL,
   expenditure_type	   	PO_DISTRIBUTIONS.expenditure_type%TYPE,
   expenditure_item_date   	PO_DISTRIBUTIONS.expenditure_item_date%TYPE,
   expenditure_organization_id 	PO_DISTRIBUTIONS.expenditure_organization_id%TYPE,
   pa_quantity         		AP_INVOICE_DISTRIBUTIONS.pa_quantity%TYPE,
   awt_group_id		   	AP_INVOICE_DISTRIBUTIONS.awt_group_id%TYPE,
   pay_awt_group_id     AP_INVOICE_DISTRIBUTIONS.pay_awt_group_id%TYPE); --bug8222382

TYPE dist_tab_type IS TABLE OF r_dist_info INDEX BY BINARY_INTEGER;


TYPE r_corr_dist_info IS RECORD
   (po_distribution_id      PO_DISTRIBUTIONS.po_distribution_id%TYPE,   --Index Column
    invoice_distribution_id AP_INVOICE_DISTRIBUTIONS.invoice_distribution_id%TYPE,
    corrected_inv_dist_id   AP_INVOICE_DISTRIBUTIONS.invoice_distribution_id%TYPE,
    corrected_quantity      AP_INVOICE_DISTRIBUTIONS.corrected_quantity%TYPE,
    amount                  AP_INVOICE_DISTRIBUTIONS.amount%TYPE,
    base_amount             AP_INVOICE_DISTRIBUTIONS.base_amount%TYPE,
    rounding_amt	    AP_INVOICE_DISTRIBUTIONS.rounding_amt%TYPE,
    unit_price              AP_INVOICE_DISTRIBUTIONS.unit_price%TYPE,
    pa_quantity             AP_INVOICE_DISTRIBUTIONS.pa_quantity%TYPE,
    dist_ccid		    AP_INVOICE_DISTRIBUTIONS.dist_code_combination_id%TYPE);


TYPE corr_dist_tab_type IS TABLE OF r_corr_dist_info INDEX BY BINARY_INTEGER;


TYPE r_shipment_info_rec IS RECORD
  (po_header_id		  PO_HEADERS.po_header_id%TYPE,
   po_line_id		  PO_LINES.po_line_id%TYPE,
   po_release_id	  PO_RELEASES.po_release_id%TYPE,
   po_line_location_id    PO_LINE_LOCATIONS.line_location_id%TYPE,  --Index Column
   rcv_transaction_id     RCV_TRANSACTIONS.transaction_id%TYPE,
   uom			  AP_INVOICE_LINES.unit_meas_lookup_code%TYPE,
   unit_price		  AP_INVOICE_LINES.unit_price%TYPE,
   line_number		  AP_INVOICE_LINES.line_number%TYPE,
   quantity_invoiced	  AP_INVOICE_LINES.quantity_invoiced%TYPE,
   amount		  AP_INVOICE_LINES.amount%TYPE,
   base_amount		  AP_INVOICE_LINES.base_amount%TYPE,
   rounding_amt		  AP_INVOICE_LINES.rounding_amt%TYPE,
   inventory_item_id	  AP_INVOICE_LINES.inventory_item_id%TYPE,
   item_description	  AP_INVOICE_LINES.item_description%TYPE,
   asset_category_id	  AP_INVOICE_LINES.asset_category_id%TYPE,
-- Removed for bug 4277744
-- ussgl_transaction_code AP_INVOICE_LINES.ussgl_transaction_code%TYPE,
   type_1099		  AP_INVOICE_LINES.type_1099%TYPE,
   attribute_category	  AP_INVOICE_LINES.attribute_category%TYPE,
   attribute1		  AP_INVOICE_LINES.attribute1%TYPE,
   attribute2             AP_INVOICE_LINES.attribute2%TYPE,
   attribute3             AP_INVOICE_LINES.attribute3%TYPE,
   attribute4             AP_INVOICE_LINES.attribute4%TYPE,
   attribute5             AP_INVOICE_LINES.attribute5%TYPE,
   attribute6             AP_INVOICE_LINES.attribute6%TYPE,
   attribute7             AP_INVOICE_LINES.attribute7%TYPE,
   attribute8             AP_INVOICE_LINES.attribute8%TYPE,
   attribute9             AP_INVOICE_LINES.attribute9%TYPE,
   attribute10            AP_INVOICE_LINES.attribute10%TYPE,
   attribute11            AP_INVOICE_LINES.attribute11%TYPE,
   attribute12            AP_INVOICE_LINES.attribute12%TYPE,
   attribute13            AP_INVOICE_LINES.attribute13%TYPE,
   attribute14            AP_INVOICE_LINES.attribute14%TYPE,
   attribute15            AP_INVOICE_LINES.attribute15%TYPE,
   --ETAX: Invwkb
   ship_to_location_id    AP_INVOICE_LINES.ship_to_location_id%TYPE,
   primary_intended_use   AP_INVOICE_LINES.primary_intended_use%TYPE,
   product_fisc_classification AP_INVOICE_LINES.product_fisc_classification%TYPE,
   product_type		  AP_INVOICE_LINES.product_type%TYPE,
   product_category       AP_INVOICE_LINES.product_category%TYPE,
   user_defined_fisc_class AP_INVOICE_LINES.user_defined_fisc_class%TYPE,
   matching_basis          PO_LINE_LOCATIONS.matching_basis%TYPE,
   retained_amount	   AP_INVOICE_LINES.retained_amount%TYPE,
   assessable_value       AP_INVOICE_LINES.assessable_value%TYPE,
   tax_classification_code AP_INVOICE_LINES.tax_classification_code%TYPE
   );

-- Bug 5125441
-- Added matching basis and retained amount to r_shipment_info_rec

TYPE t_shipment_table IS TABLE of r_shipment_info_rec index by BINARY_INTEGER;

PROCEDURE Base_Credit_PO_Match(
		X_match_mode          IN    VARCHAR2,
                X_invoice_id          IN    NUMBER,
                X_invoice_line_number IN    NUMBER,
                X_Po_Line_Location_id IN    NUMBER,
                X_Dist_Tab            IN OUT NOCOPY DIST_TAB_TYPE,
                X_amount              IN    NUMBER,
                X_quantity            IN    NUMBER,
                X_unit_price          IN    NUMBER,
                X_uom_lookup_code     IN    VARCHAR2,
                X_final_match_flag    IN    VARCHAR2,
                X_overbill_flag       IN    VARCHAR2,
		X_freight_cost_factor_id IN NUMBER DEFAULT NULL,
                X_freight_amount      IN    NUMBER,
                X_freight_description IN    VARCHAR2,
		X_misc_cost_factor_id IN    NUMBER DEFAULT NULL,
                X_misc_amount         IN    NUMBER,
                X_misc_description    IN    VARCHAR2,
	    	X_retained_amount     IN    NUMBER DEFAULT NULL,
                X_calling_sequence    IN    VARCHAR2) ;

PROCEDURE Price_Quantity_Correct_Inv_PO(
		X_Invoice_Id		IN	NUMBER,
		X_Invoice_Line_Number   IN 	NUMBER,
		X_Corrected_Invoice_Id  IN	NUMBER,
		X_Corrected_Line_Number IN	NUMBER,
		X_Correction_Type	IN	VARCHAR2,
		X_Match_Mode		IN	VARCHAR2,
		X_Correction_Quantity	IN	NUMBER,
		X_Correction_Amount	IN	NUMBER,
		X_Correction_Price	IN	NUMBER,
		X_Po_Line_Location_Id   IN	NUMBER,
		X_Corr_Dist_Tab		IN OUT NOCOPY CORR_DIST_TAB_TYPE,
		X_Final_Match_Flag	IN	VARCHAR2,
		X_Uom_Lookup_Code	IN	VARCHAR2,
		X_Retained_Amount	IN	NUMBER DEFAULT NULL,
		X_Calling_Sequence	IN 	VARCHAR2);

PROCEDURE Quick_Match_Line_Generation(
                x_invoice_id       IN   NUMBER,
		x_po_header_id     IN   NUMBER,
	        x_match_option     IN   VARCHAR2,
	        x_invoice_amount   IN   NUMBER,
	        x_calling_sequence IN   VARCHAR2);

-- Bug 5465722. Building Prepay Proper Account as per Federal Functionality.
-- Only Natural Account will be overlayed
PROCEDURE  Build_Prepay_Account(P_base_ccid             IN     NUMBER
                              ,P_overlay_ccid          IN     NUMBER
                              ,P_accounting_date       IN     DATE
                              ,P_result_ccid           OUT NOCOPY    NUMBER
                              ,P_Reason_Unbuilt_Flex   OUT NOCOPY    VARCHAR2
                              ,P_calling_sequence      IN     VARCHAR2);


END AP_MATCHING_PKG;

/
