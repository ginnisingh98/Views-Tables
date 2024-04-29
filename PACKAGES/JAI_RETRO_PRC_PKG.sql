--------------------------------------------------------
--  DDL for Package JAI_RETRO_PRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RETRO_PRC_PKG" AUTHID CURRENT_USER AS
--$Header: jai_retro_prc.pls 120.0 2008/01/21 10:58:36 rchandan noship $
--==========================================================================
--  PROCEDURE NAME:
--
--    Process_Retroactive_Update                     Public
--
--  DESCRIPTION:
--
--    This procedure is used to do the Costing for DELIEVR transaction and also
--    when user choses to UNCLAIM.
--
--
--  PARAMETERS:
--      In:  pn_vendor_id             identifier of vendor
--           pn_vendor_site_id        identifier of vendor site
--           pn_po_header_id          identifier of po header
--           pd_from_eff_date         effective date
--           pv_cenvat_action         'CLAIM' OR 'UNCLAIM'
--           pv_supp_exc_inv_no       excise invoice number
--           pv_supp_exc_inv_date     excise invoice date
--           pv_vat_action            'CLAIM' OR 'UNCLAIM'
--           pv_supp_vat_inv_no       vat invoice number
--           pv_supp_vat_inv_date     vat invoice date
--           pv_process_downward      price downward processing flag
--      Out :
--           errbuf     concurrent return message
--           retcode    concurrent return code
--
--
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Eric Ma  created
--==========================================================================
GV_MODULE_PREFIX       VARCHAR2(50) := 'jai.plsql.JAI_RETRO_PRC_PKG';

lc_rec  PO_LINE_LOCATIONS_ALL%ROWTYPE;

PROCEDURE Process_Retroactive_Update
( errbuf                OUT  NOCOPY       VARCHAR2
, retcode               OUT  NOCOPY       VARCHAR2
, pn_vendor_id          IN NUMBER
, pn_vendor_site_id     IN NUMBER   DEFAULT NULL
, pn_po_header_id       IN NUMBER   DEFAULT NULL
, pv_from_eff_date      IN VARCHAR2 DEFAULT NULL
, pv_cenvat_action      IN VARCHAR2 DEFAULT NULL
, pv_supp_exc_inv_no    IN VARCHAR2 DEFAULT NULL
, pv_supp_exc_inv_date  IN VARCHAR2 DEFAULT NULL
, pv_vat_action         IN VARCHAR2 DEFAULT NULL
, pv_supp_vat_inv_no    IN VARCHAR2 DEFAULT NULL
, pv_supp_vat_inv_date  IN VARCHAR2 DEFAULT NULL
, pv_process_downward   IN VARCHAR2 DEFAULT NULL
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Insert_Price_Changes                     Public
--
--  DESCRIPTION:
--
--    This procedure is used to insert location line history changes
--    when doing retroactive price update.
--
--  PARAMETERS:
--      In: pr_old                lc_rec%TYPE  old line record
--          pr_new                lc_rec%TYPE  new line record
--     Out: pv_process_flag       VARCHAR2     return flag
--          pv_process_message    VARCHAR2     return message
--
--
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Kevin Cheng  Created
--==========================================================================
PROCEDURE Insert_Price_Changes
( pr_old               IN lc_rec%TYPE
, pr_new               IN lc_rec%TYPE
, pv_process_flag      OUT NOCOPY VARCHAR2
, pv_process_message   OUT NOCOPY VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Update_Price_Changes                     Public
--
--  DESCRIPTION:
--
--    This procedure is used to update tax amount in tax line changes table
--    when doing retroactive price update.
--
--  PARAMETERS:
--      In: pn_tax_amt            NUMBER       updated tax amount
--          pn_line_no            NUMBER       tax line number
--          pn_line_loc_id        NUMBER       line location id
--     Out: pv_process_flag       VARCHAR2     return flag
--          pv_process_message    VARCHAR2     return message
--
--
--  DESIGN REFERENCES:
--    JAI_Retroprice_TDD.doc
--
--  CHANGE HISTORY:
--
--           14-JAN-2008   Kevin Cheng  Created
--==========================================================================
PROCEDURE Update_Price_Changes
( pn_tax_amt           IN NUMBER
, pn_line_no           IN NUMBER
, pn_line_loc_id       IN NUMBER
, pv_process_flag      OUT NOCOPY VARCHAR2
, pv_process_message   OUT NOCOPY VARCHAR2
);

END JAI_RETRO_PRC_PKG ;

/
