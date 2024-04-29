--------------------------------------------------------
--  DDL for Package GMP_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_UTILITY" AUTHID CURRENT_USER as
/* $Header: GMPUTILS.pls 120.0.12010000.2 2009/02/23 17:24:03 rpatangy ship $ */

PROCEDURE generate_opm_acct
(
 V_DESTINATION_TYPE    IN      VARCHAR2 ,
 V_INV_ITEM_TYPE       IN      VARCHAR2 ,
 V_SUBINV_TYPE         IN      VARCHAR2,
 V_DEST_ORG_ID         IN      NUMBER ,
 V_APPS_ITEM_ID        IN      NUMBER,
 V_VENDOR_SITE_ID      IN      NUMBER,
 V_CC_ID               IN OUT NOCOPY NUMBER
) ;

-- BUG: 8230710 VPEDARLA
FUNCTION populate_eff
( org_string           IN      VARCHAR2
) RETURN BOOLEAN  ;

end gmp_utility;

/
