--------------------------------------------------------
--  DDL for Package JAI_PO_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_PO_HOOK_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_po_hook_pkg.pls 120.5.12010000.2 2009/04/03 09:14:33 srjayara ship $ */

-- Declare global variable for package name
GV_MODULE_PREFIX       VARCHAR2(50) :='jai.plsql.JAI_PO_HOOK_PKG';

 PROCEDURE calc_taxes
  (
    p_document_type IN VARCHAR2,
    p_header_id     IN NUMBER,
    p_line_id       IN NUMBER,
    Errbuf          OUT NOCOPY VARCHAR2,
    RetCode         OUT NOCOPY VARCHAR2
  );

  PROCEDURE PROCESS_RECEIPT
  (
    p_shipment_header_id IN NUMBER,
    p_transaction_id     IN NUMBER DEFAULT NULL,
    p_process_Action     IN VARCHAR2 DEFAULT NULL,
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY VARCHAR2
  );

  PROCEDURE UPDATE_RCV_TXN
  (
    P_transaction_id IN NUMBER,
    p_invoice_num    IN VARCHAR2,
    P_invoice_date   IN VARCHAR2,
    errbuf           OUT NOCOPY VARCHAR2,
    retcode          OUT NOCOPY VARCHAR2
  );

  FUNCTION gettax
  (
    p_document_type IN VARCHAR2,
    p_header_id     IN NUMBER,
    p_line_id       IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_taxes_inr
  (
    p_document_id  IN VARCHAR2,
    p_header_id    IN NUMBER,
    p_line_id      IN NUMBER
  ) RETURN NUMBER;

  FUNCTION gettax
  (
    p_document_type     IN VARCHAR2,
    p_header_id         IN NUMBER,
    p_line_id           IN NUMBER,
    p_shipment_line_num IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_profile_value(cp_profile_name VARCHAR2) RETURN VARCHAR2;

  PROCEDURE populate_cmn_taxes
  (
    p_po_header_id     IN NUMBER,
    p_line_location_id IN NUMBER,
    p_hdr_intf_id      IN NUMBER,
    p_cmn_line_id      IN NUMBER,
    p_quantity         IN NUMBER,
    p_tot_quantity     IN NUMBER
  );

  PROCEDURE Populate_cmn_lines
  (
    p_hdr_intf_id  IN NUMBER,
    p_invoice_num  IN VARCHAR2,
    p_invoice_date IN DATE,
    errbuf         OUT NOCOPY VARCHAR2,
    retcode        OUT NOCOPY VARCHAR2
  );

  PROCEDURE update_cmn_lines
  (
    p_shipment_num IN VARCHAR2,
    p_ex_inv_num   IN VARCHAR2,
    p_ex_inv_date  IN DATE,
    p_header_interface_id IN NUMBER DEFAULT NULL,  /*bug 8400813*/
    errbuf         OUT NOCOPY VARCHAR2,
    retcode        OUT NOCOPY VARCHAR2
  );

  PROCEDURE UPDATE_ASBN_MODE
  (
    p_shipment_num IN VARCHAR2,
    p_mode         IN VARCHAR2,
    p_header_interface_id IN NUMBER DEFAULT NULL,  /*bug 8400813*/
    errbuf         OUT NOCOPY VARCHAR2,
    retcode        OUT NOCOPY VARCHAR2
  );

  PROCEDURE Populate_cmn_lines_on_upload
 (
    p_hdr_intf_id  IN NUMBER,
   errbuf         OUT NOCOPY VARCHAR2,
   retcode        OUT NOCOPY VARCHAR2
 );

  FUNCTION gettaxisp
  (
    p_document_type IN VARCHAR2,
    p_header_id     IN NUMBER,
    p_line_id       IN NUMBER,
    p_release_id    IN NUMBER
  ) RETURN NUMBER;

--==========================================================================
--  PROCEDURE NAME:
--
--    Get_InAndEx_Tax_Total                        Public
--
--  DESCRIPTION:
--
--    to calculate the inclusive and exclusive tax amount
--
--  PARAMETERS:
--      In:  pv_document_type      document type
--           pn_header_id          header id
--           pn_line_id            line id
--           pv_inclusive_tax_flag inclusive tax flag
--
--  DESIGN REFERENCES:
--    Inclusive Tax Technical Design.doc
--
--  CHANGE HISTORY:
--
--           20-NOV-2007   Jason Liu  created
FUNCTION Get_InAndEx_Tax_Total
( pv_document_type      IN VARCHAR2
, pn_header_id          IN NUMBER
, pn_line_id            IN NUMBER
, pv_inclusive_tax_flag IN VARCHAR2
)
RETURN NUMBER;

--==========================================================================
--  PROCEDURE NAME:
--
--    Get_Isp_InAndEx_Tax_Total                        Public
--
--  DESCRIPTION:
--
--    to calculate the inclusive and exclusive tax amount
--
--  PARAMETERS:
--      In:  pv_document_type      document type
--           pn_header_id          header id
--           pn_line_id            line id
--           pn_release_id         release id
--           pv_inclusive_tax_flag inclusive tax flag
--
--  DESIGN REFERENCES:
--    Inclusive Tax Technical Design.doc
--
--  CHANGE HISTORY:
--
--           20-NOV-2007   Jason Liu  created
FUNCTION Get_Isp_InAndEx_Tax_Total
( pv_document_type       IN VARCHAR2
, pn_header_id           IN NUMBER
, pn_line_id             IN NUMBER
, pn_release_id          IN NUMBER
, pv_inclusive_tax_flag IN VARCHAR2
)
RETURN NUMBER;

END JAI_PO_HOOK_PKG;

/
