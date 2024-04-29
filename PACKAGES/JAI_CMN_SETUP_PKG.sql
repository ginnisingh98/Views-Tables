--------------------------------------------------------
--  DDL for Package JAI_CMN_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_SETUP_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_setup.pls 120.1 2005/07/20 12:57:41 avallabh ship $ */

PROCEDURE generate_excise_invoice_no
(
P_ORGANIZATION_ID Number,
P_LOCATION_ID     Number,
P_CALLED_FROM     VARCHAR2,
P_ORDER_INVOICE_TYPE_ID NUMBER,
P_FIN_YEAR        Number,
P_EXCISE_INV_NO OUT NOCOPY Varchar2,
P_Errbuf OUT NOCOPY Varchar2
);

/*PROCEDURE gen_opm_excise_invoice_no
(P_Ordid IN NUMBER ,
P_ORGN_CODE IN VARCHAR2 ,
V_ITEM_CLASS IN VARCHAR2 ,
P_BOL_ID IN NUMBER ,
P_BOLLINE_NO IN NUMBER,
P_EXCISE_INV_NUM IN OUT NOCOPY VARCHAR2
);
*/

FUNCTION get_po_assessable_value(
  p_vendor_id IN NUMBER,
  p_vendor_site_id IN NUMBER,
  p_inv_item_id IN NUMBER,
  p_line_uom IN VARCHAR2
)RETURN NUMBER;

END jai_cmn_setup_pkg;
 

/
