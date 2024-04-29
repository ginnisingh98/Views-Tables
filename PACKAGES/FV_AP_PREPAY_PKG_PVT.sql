--------------------------------------------------------
--  DDL for Package FV_AP_PREPAY_PKG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_AP_PREPAY_PKG_PVT" AUTHID CURRENT_USER AS
-- $Header: FVAPPFRS.pls 120.0 2003/09/15 21:37:01 snama noship $

---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- Public Procedure Specification
---------------------------------------------------------------------------
---------------------------------------------------------------------------

PROCEDURE Funds_Check(p_invoice_id		IN NUMBER,
		      p_dist_line_num		IN NUMBER,
		      p_return_message_name 	IN OUT NOCOPY VARCHAR2,
                      p_calling_sequence 	IN VARCHAR2);

PROCEDURE Funds_Reserve(p_invoice_id		IN NUMBER,
		        p_unique_packet_id_per	IN VARCHAR2,
  			p_set_of_books_id	IN NUMBER,
		   	p_base_currency_code	IN VARCHAR2,
		   	p_inv_enc_type_id	IN NUMBER,
		   	p_purch_enc_type_id	IN NUMBER,
			p_conc_flag	  	IN VARCHAR2,
			p_system_user		IN NUMBER,
			p_ussgl_option		IN VARCHAR2,
			p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			p_hold_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			p_release_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
                        p_calling_sequence 	IN VARCHAR2);


PROCEDURE SetUp_Flexbuild_Params(p_chart_of_accounts_id IN NUMBER,
				 p_flex_method IN VARCHAR2,
                                 p_flex_xrate_flag IN BOOLEAN,
				 p_xrate_gain_ccid IN NUMBER,
				 p_xrate_loss_ccid IN NUMBER,
				 p_flex_qualifier_name IN OUT NOCOPY VARCHAR2,
				 p_flex_segment_delimiter IN OUT NOCOPY VARCHAR2,
				 p_flex_segment_number IN OUT NOCOPY NUMBER,
                                 p_num_of_segments IN OUT NOCOPY NUMBER,
				 p_xrate_gain_segments IN OUT NOCOPY FND_FLEX_EXT.SEGMENTARRAY,
				 p_xrate_loss_segments IN OUT NOCOPY FND_FLEX_EXT.SEGMENTARRAY,
				 p_xrate_cant_flexbuild_flag IN OUT NOCOPY BOOLEAN,
                                 p_cant_flexbuild_reason IN OUT NOCOPY VARCHAR2,
				 p_calling_sequence IN VARCHAR2);

PROCEDURE Calc_IPV_ERV(p_auto_offsets_flag	IN VARCHAR2,
		       p_xrate_cant_flexbuild_flag IN BOOLEAN,
		       p_chart_of_accounts_id	IN NUMBER,
		       p_xrate_gain_segments    IN FND_FLEX_EXT.SEGMENTARRAY,
		       p_xrate_loss_segments    IN FND_FLEX_EXT.SEGMENTARRAY,
		       p_sys_xrate_gain_ccid    IN NUMBER,
		       p_sys_xrate_loss_ccid    IN NUMBER,
		       p_dist_ccid 		IN NUMBER,
		       p_expense_ccid		IN NUMBER,
		       p_variance_ccid    	IN NUMBER,
		       p_segment_number		IN NUMBER,
		       p_flex_method		IN VARCHAR2,
		       p_flex_qualifier_name	IN VARCHAR2,
		       p_flex_segment_delimiter IN VARCHAR2,
		       p_po_rate		IN NUMBER,
		       p_po_price		IN NUMBER,
		       p_inv_rate		IN NUMBER,
		       p_rtxn_rate		IN NUMBER,
		       p_rtxn_uom		IN VARCHAR2,
		       p_rtxn_item_id		IN NUMBER,
		       p_po_uom			IN VARCHAR2,
		       p_match_option		IN VARCHAR2,
		       p_inv_price		IN NUMBER,
		       p_inv_qty		IN NUMBER,
		       p_dist_amount		IN NUMBER,
		       p_base_dist_amount	IN NUMBER,
		       p_inv_currency_code	IN VARCHAR2,
		       p_base_currency_code	IN VARCHAR2,
		       p_destination_type	IN VARCHAR2,
		       p_ipv   			IN OUT NOCOPY NUMBER,
		       p_bipv  			IN OUT NOCOPY NUMBER,
		       p_price_var_ccid		IN OUT NOCOPY NUMBER,
		       p_erv   			IN OUT NOCOPY NUMBER,
		       p_erv_ccid 		IN OUT NOCOPY NUMBER,
		       p_calling_sequence	IN VARCHAR2);

Procedure Calc_Tax_IPV_ERV(p_auto_offsets_flag	IN VARCHAR2,
		       p_xrate_cant_flexbuild_flag IN BOOLEAN,
		       p_chart_of_accounts_id	IN NUMBER,
		       p_xrate_gain_segments    IN FND_FLEX_EXT.SEGMENTARRAY,
		       p_xrate_loss_segments    IN FND_FLEX_EXT.SEGMENTARRAY,
		       p_sys_xrate_gain_ccid    IN NUMBER,
		       p_sys_xrate_loss_ccid    IN NUMBER,
                       p_flex_segment_number    IN NUMBER,
                       p_flex_method            IN VARCHAR2,
                       p_flex_qualifier_name    IN VARCHAR2,
                       p_flex_segment_delimiter IN VARCHAR2,
		       p_tax_dist_id 		IN NUMBER,
		       p_po_dist_id 		IN NUMBER,
		       p_dist_ccid 		IN NUMBER,
		       p_sum_qty_invoiced 	IN NUMBER,
		       p_sum_allocated_amount 	IN NUMBER,
                       p_po_expense_ccid        IN NUMBER,
                       p_price_variance_ccid    IN NUMBER,
                       p_po_price               IN NUMBER,
                       p_rtxn_rate              IN NUMBER,
                       p_rtxn_uom               IN VARCHAR2,
                       p_rtxn_item_id           IN NUMBER,
                       p_po_uom                 IN VARCHAR2,
                       p_match_option           IN VARCHAR2,
                       p_po_rate                IN NUMBER,
                       p_inv_rate               IN NUMBER,
                       p_destination_type       IN VARCHAR2,
                       p_po_tax_rate            IN NUMBER,
                       p_po_recov_rate          IN NUMBER,
                       p_invoice_currency_code  IN VARCHAR2,
                       p_base_currency_code     IN VARCHAR2,
                       p_tax_ipv_ccid           IN OUT NOCOPY NUMBER,
                       p_tax_erv_ccid           IN OUT NOCOPY NUMBER,
                       p_tax_ipv                IN OUT NOCOPY NUMBER,
                       p_tax_bipv               IN OUT NOCOPY NUMBER,
                       p_tax_erv                IN OUT NOCOPY NUMBER,
                       p_calling_sequence       IN VARCHAR2,
		       p_tax_id 	  	IN NUMBER,
		       p_codeorgroup		IN NUMBER,
		       p_vendor_id		IN NUMBER,
		       p_vendor_site_id		IN NUMBER);

PROCEDURE Calc_QV(p_invoice_id		IN NUMBER,
		  p_po_dist_id		IN NUMBER,
		  p_inv_currency_code	IN VARCHAR2,
		  p_base_currency_code	IN VARCHAR2,
		  p_po_price		IN NUMBER,
		  p_po_qty		IN NUMBER,
		  p_match_option	IN VARCHAR2,
	          p_rtxn_uom		IN VARCHAR2,
		  p_po_uom		IN VARCHAR2,
		  p_item_id		IN NUMBER,
		  p_qv			IN OUT NOCOPY NUMBER,
		  p_bqv			IN OUT NOCOPY NUMBER,
		  p_update_line_num	IN OUT NOCOPY NUMBER,
		  p_calling_sequence    IN VARCHAR2);

END FV_AP_PREPAY_PKG_PVT;

 

/
