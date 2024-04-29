--------------------------------------------------------
--  DDL for Package JAI_PO_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_PO_TAX_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_po_tax.pls 120.13 2008/01/25 14:32:06 rchandan ship $ */
  PROCEDURE calculate_tax(
    p_type IN VARCHAR2,
    p_header_id NUMBER,
    P_line_id NUMBER,
    p_line_loc_id IN NUMBER,
    p_line_quantity IN NUMBER,
    p_price IN NUMBER,
    p_line_uom_code IN VARCHAR2,
    p_tax_amount IN OUT NOCOPY NUMBER,
    p_assessable_value IN NUMBER DEFAULT NULL,
    p_vat_assess_value IN NUMBER,  -- Ravi for VAT
    p_item_id IN NUMBER DEFAULT NULL,
    p_conv_rate IN NUMBER DEFAULT NULL
    ,pv_retroprice_changed IN VARCHAR2 DEFAULT 'N' --Added by Kevin Cheng for Retroactive Price 2008/01/10
    ,pv_called_from         IN VARCHAR2 DEFAULT NULL--Added by Eric Ma for Retroactive Price 2008/01/11
  );

  PROCEDURE batch_quot_taxes_copy
	(
		p_errbuf OUT NOCOPY VARCHAR2,
		p_retcode OUT NOCOPY VARCHAR2
	) ;

  PROCEDURE copy_reqn_taxes
  (
    p_Vendor_Id number,
    p_Vendor_Site_Id number,
    p_Po_Header_Id number,
    p_Po_Line_Id number, --added by Sriram on 22-Nov-2001
    p_line_location_id number, --added by Sriram on 22-Nov-2001
    p_Type_Lookup_Code varchar2,
    p_Quotation_Class_Code varchar2,
    p_Ship_To_Location_Id number,
    p_Org_Id number,
  --p_Rate number, --commented by Sriram on 22-Nov-2001
  --p_Rate_type number, --commented by Sriram on 22-Nov-2001
  --p_Rate_date date, --commented by Sriram on 22-Nov-2001
  --p_Currency_Code varchar2, --commented by Sriram on 22-Nov-2001
    p_Creation_Date date,
    p_Created_By number,
    p_Last_Update_Date date,
    p_Last_Updated_By number,
    p_Last_Update_Login number
    /* Brathod, For Bug# 4242351 */
    ,p_rate		      PO_HEADERS_ALL.RATE%TYPE      DEFAULT NULL
    ,p_rate_type	    PO_HEADERS_ALL.RATE_TYPE%TYPE DEFAULT NULL
    ,p_rate_date     PO_HEADERS_ALL.RATE_DATE%TYPE DEFAULT NULL
    ,p_currency_code PO_HEADERS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
    /* End of Bug# 4242351 */
    );

  PROCEDURE calc_tax(
  -- Do not use this function to pass line_location_id in place of header_id, use relevant fields to pass
  -- the parameters
    p_type      IN  VARCHAR2,   -- Contains the type of document
    p_header_id   IN  NUMBER,     -- Contains the header_id of the document
    P_line_id   IN  NUMBER,     -- Contains the line_id of the document
    p_line_location_id  IN  NUMBER,   -- Shipment line_id of the PO Document
    p_line_focus_id IN  NUMBER,     -- unique key of JAI_PO_LINE_LOCATIONS table
    p_line_quantity IN  NUMBER,     -- quantity given in the line
    p_base_value  IN  NUMBER,     -- base value of the line i.e quantity * base price of item
    p_line_uom_code IN  VARCHAR2,   -- uom_code of the line item
    p_tax_amount  IN OUT NOCOPY  NUMBER,    -- total tax amount that should be returned to the calling procedure
    p_assessable_value  IN NUMBER DEFAULT NULL, -- assessable value of line on which excise duty is calculated i.e quantity * assessable_price
    p_vat_assess_value  IN NUMBER, -- vat assessable value /* rallamse bug#4250072 VAT */
    p_item_id     IN NUMBER DEFAULT NULL, -- inventory item given in the line
    p_conv_rate     IN NUMBER DEFAULT NULL, -- Convertion rate from Functional to PO currency
    p_po_curr   IN VARCHAR2 DEFAULT NULL, -- PO Header or Requisition line currency
    p_func_curr   IN VARCHAR2 DEFAULT NULL,  -- Functional currency of the organization or operating unit
    p_requisition_line_id   IN NUMBER   DEFAULT NULL    --Bgowrava for Bug#5877782
    ,pv_retroprice_changed IN VARCHAR2 DEFAULT 'N' --Added by Kevin Cheng for Retroactive Price 2008/01/10
  );

  PROCEDURE copy_source_taxes
  (
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_type				VARCHAR2,
    p_po_hdr_id			NUMBER,
    p_po_line_id		NUMBER,
    p_po_line_loc_id	NUMBER,
    p_line_num			NUMBER,
    p_ship_num			NUMBER,
    p_item_id			NUMBER,
    p_from_hdr_id		NUMBER,
    p_from_type_lookup_code	VARCHAR2,
    p_cre_dt			DATE,
    p_cre_by			NUMBER,
    p_last_upd_dt		DATE,
    p_last_upd_by		NUMBER,
    p_last_upd_login	NUMBER
  );

  PROCEDURE copy_quot_taxes
  (
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_line_loc_id IN NUMBER,
    p_po_hdr_id IN NUMBER,
    p_po_line_id IN NUMBER,
    p_qty IN NUMBER,
    p_frm_hdr_id IN NUMBER,
    p_frm_line_id IN NUMBER,
    p_price IN NUMBER,
    p_unit_code IN VARCHAR2,
    p_assessable_value IN NUMBER,
    p_cre_dt IN DATE,
    p_cre_by IN NUMBER,
    p_last_upd_dt IN DATE,
    p_last_upd_by IN NUMBER,
    p_last_upd_login IN NUMBER
  );

  PROCEDURE copy_agreement_taxes
  (
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_seq_val     IN  NUMBER,
    p_qty         IN  NUMBER,
    p_hdr_id      IN  NUMBER,
    p_line_id     IN  NUMBER,
    p_line_loc_id IN  NUMBER,
    p_ship_type   IN  VARCHAR2,
    p_cum_flag    IN  VARCHAR2,
    p_cre_dt      IN  DATE,
    p_cre_by      IN  NUMBER,
    p_last_cre_dt IN  DATE,
    p_last_cre_by IN  NUMBER,
    p_last_login  IN  NUMBER
    ,pv_retroprice_changed IN VARCHAR2 DEFAULT 'N' --Added by Kevin Cheng for Retroactive Price 2008/01/10
  );

  PROCEDURE Ja_In_Po_Case1(
    v_type_lookup_code IN VARCHAR2,
    v_quot_class_code  IN VARCHAR2,
    vendor_id IN NUMBER,
    v_vendor_site_id IN NUMBER,
    currency IN VARCHAR2,
    v_org_id IN NUMBER,
    v_item_id IN NUMBER,
    v_uom_measure IN VARCHAR2,
    v_line_loc_id IN NUMBER,
    v_po_hdr_id IN NUMBER,
    v_po_line_id IN NUMBER,
    v_frm_po_line_id IN NUMBER,
    v_frm_line_loc_id IN NUMBER,
    v_price  IN NUMBER,
    v_qty IN NUMBER,
    v_cre_dt IN DATE,
    v_cre_by IN NUMBER,
    v_last_upd_dt IN DATE,
    v_last_upd_by IN NUMBER,
    v_last_upd_login IN NUMBER,
    flag IN VARCHAR2,
    success IN OUT NOCOPY NUMBER,
    p_quantity   IN PO_LINE_LOCATIONS_ALL.quantity%TYPE  DEFAULT NULL  --added by csahoo for bug#6144740
  );

  PROCEDURE Ja_In_Po_Case2(
    v_type_lookup_code IN VARCHAR2,
    v_quot_class_code  IN VARCHAR2,
    vendor_id IN NUMBER,
    v_vendor_site_id IN NUMBER,
    currency IN VARCHAR2,
    v_org_id IN NUMBER,
    v_item_id IN NUMBER,
    v_line_loc_id IN NUMBER,
    v_po_hdr_id IN NUMBER,
    v_po_line_id IN NUMBER,
    v_price  IN NUMBER,
    v_qty IN NUMBER,
    v_cre_dt IN DATE,
    v_cre_by IN NUMBER,
    v_last_upd_dt IN DATE,
    v_last_upd_by IN NUMBER,
    v_last_upd_login IN NUMBER,
    v_uom_measure IN VARCHAR2,
    flag IN VARCHAR2,
    v_assessable_val IN NUMBER DEFAULT NULL,
    p_vat_assess_value IN NUMBER ,  -- added, Harshita for bug #4245062
    v_conv_rate IN NUMBER DEFAULT NULL,
    /* Bug 5096787. Added by Lakshmi Gopalsami  */
    v_rate IN NUMBER DEFAULT NULL,
    v_rate_date IN DATE DEFAULT NULL,
    v_rate_type IN VARCHAR2 DEFAULT NULL,
p_tax_category_id IN NUMBER DEFAULT NULL
,pv_retroprice_changed IN VARCHAR2 DEFAULT 'N' --Added by Kevin Cheng for Retroactive Price 2008/01/13
);

  PROCEDURE Ja_In_Po_Insert(
    v_type_lookup_code IN VARCHAR2,
    v_quot_class_code IN VARCHAR2,
    v_seq_val IN NUMBER,
    v_line_loc_id IN NUMBER,
    v_tax_line_no IN NUMBER,
    v_po_line_id IN NUMBER,
    v_po_hdr_id IN NUMBER,
    v_prec1 IN NUMBER,
    v_prec2 IN NUMBER,
    v_prec3 IN NUMBER,
    v_prec4 IN NUMBER,
    v_prec5 IN NUMBER,
    v_prec6 IN NUMBER, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    v_prec7 IN NUMBER,
    v_prec8 IN NUMBER,
    v_prec9 IN NUMBER,
    v_prec10 IN NUMBER,
    v_taxid IN NUMBER,
    v_price IN NUMBER,
    v_qty IN NUMBER,
    v_curr IN VARCHAR2,
    v_tax_rate IN NUMBER,
    v_qty_rate IN NUMBER,
    v_uom IN VARCHAR2,
    v_tax_amt IN NUMBER ,
    v_tax_type VARCHAR2,
    v_mod_flag IN VARCHAR2,
    v_vendor_id IN NUMBER,
    v_tax_target_amt IN NUMBER,
    v_cre_dt IN DATE,
    v_cre_by IN NUMBER,
    v_last_upd_dt IN DATE,
    v_last_upd_by  IN NUMBER,
    v_last_upd_login IN NUMBER,
    v_tax_category_id IN NUMBER   -- cbabu for EnhancementBug# 2427465
  ) ;

END jai_po_tax_pkg;

/
