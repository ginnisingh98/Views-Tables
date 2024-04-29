--------------------------------------------------------
--  DDL for Package ZX_MIGRATE_AR_TAX_DEF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_MIGRATE_AR_TAX_DEF" AUTHID CURRENT_USER as
/* $Header: zxartaxdefmigs.pls 120.3 2005/10/30 01:52:41 appldev ship $ */
/*===========================================================================+
 | PROCEDURE
 |    migrate_ar_tax_code_setup
 | IN
 |    p_tax_id : ar_vat_tax_all_b.vat_tax_id is passed when it is called from
 |               AR Tax Codes form for synchronization.
 |
 | OUT
 |
 |
 | DESCRIPTION
 |     This routine is a wrapper for migration of O2C TAX SETUP.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 08/31/2004   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/

PROCEDURE migrate_ar_tax_code_setup (p_tax_id   NUMBER);



/*===========================================================================+
 | PROCEDURE
 |    get_r2r_for_ar_taxcode
 | IN
 |    p_tax_code: varchar2: AR Tax Code (ar_vat_tax_all_b.tax_code)
 |    p_org_id  : number  : Org ID for AR Tax Code (ar_vat_tax_all_b.org_id)
 | OUT
 |    p_tax_regime_code : varchar2: Tax Regime Code derived for AR Tax Code
 |    p_tax             : varchar2: Tax derived for AR Tax Code
 |    p_tax_status_code : varchar2: Tax Status Code derived for AR Tax Code
 |    p_tax_rate_code   : varchar2" Tax Rate Code derived for AR Tax Code
 |
 | DESCRIPTION
 |     This routine returns Tax Regime Code, Tax, Tax Status Code, Tax Rate
 |     Code derived for AR Tax Code during eBTax tax definition migration.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |
 | NOTES
 |    Although this procedure is opened to public it should only be called from
 |    eBTax migration related pl/sql packages after AR Tax Definition migration
 |    has been completed successfully.
 |
 | MODIFICATION HISTORY
 | 12/21/2004   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/

PROCEDURE get_r2r_for_ar_taxcode
(p_tax_code        IN VARCHAR2,
 p_org_id          IN NUMBER,
 p_tax_class       IN VARCHAR2,
 p_tax_regime_code OUT NOCOPY VARCHAR2,
 p_tax             OUT NOCOPY VARCHAR2,
 p_tax_status_code OUT NOCOPY VARCHAR2,
 p_tax_rate_code   OUT NOCOPY VARCHAR2);

/*===========================================================================+
 | PROCEDURE
 |   migrate_vnd_tax_code
 |
 | IN
 |   p_tax_id    NUMBER                 : NULL for initial load.
 |                                        NOT NULL for synch.
 |   p_tax_type  VARCHAR2 DEFAULT NULL  : NULL for initial load.
 |                                        NOT NULL for synch.
 |
 | OUT
 |   NA
 |
 | DESCRIPTION
 |   This procedure populates Regime to Rate entity for Tax Codes used to
 |   implement tax vendors (VERTEX, TAXWARE).
 |
 |   Naming Convention
 |   ------------------
 |   Regime Code : 'US-SALES-TAX-VERTEX/TAXWARE'
 |   Tax         : STATE, COUNTY, CITY, DISTRICT
 |   Status Code : STD_AR_OUTPUT
 |   Rates       : NA
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_ar_tax_code_setup
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | 01/19/2005   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE migrate_vnd_tax_code (p_tax_id    NUMBER,
                                p_tax_type  VARCHAR2  DEFAULT  NULL);

/*===========================================================================+
 | PROCEDURE
 |    migrate_loc_tax_code
 |
 | IN
 |    p_tax_id  NUMBER                : NULL for initial load.
 |                                      NOT NULL when it is called for SYNCH.
 |    p_tax_type VARCHAR2 DEFAULT NULL: NULL for initial load.
 |                                      NOT NULL when it is called for SYNCH.
 |
 | OUT
 |
 | DESCRIPTION
 |     This routine creates records in zx_taxes_b/tl for tax code with tax
 |     type = 'LOCATION' and tax code used by tax vendors.
 |     It creates regime, tax, status.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |        zx_migrate_ar_tax_def.migrate_ar_tax_code_setup
 |        zx_upgrade_control_pkg
 |
 | NOTES
 | 8/31/2004 : The logic could be distributed to create_zx_regime, create_zx_tax,
 |             create_zx_status, migrate_ar_vat_tax after the approach is finalized.
 | 9/28/2004 : May need a synch logic.
 |
 | MODIFICATION HISTORY
 | 08/31/2004   Yoshimichi Konishi   Created.
 | 09/28/2004   Yoshimichi Konishi   Modified ZX_TAX population logic.
 | 10/29/2004   Yoshimichi Konishi   Bug 3961322. Modified ZX_TAX population logic.
 | 11/05/2004   Yoshimichi Konishi   Bug 3961322. Added logic to derive parent_
 |                                   geography_id.
 | 01/10/2005   Yoshimichi Konishi   Reimplemented logic:
 |                                   -Populates regimes per location structure.
 |                                   -Populates taxes using segment qualifier.
 |
 +==========================================================================*/

PROCEDURE migrate_loc_tax_code (p_tax_id    NUMBER,
                                p_tax_type  VARCHAR2  DEFAULT  NULL);
END;

 

/
