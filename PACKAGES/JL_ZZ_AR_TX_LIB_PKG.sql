--------------------------------------------------------
--  DDL for Package JL_ZZ_AR_TX_LIB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AR_TX_LIB_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzxlis.pls 120.6.12010000.3 2009/01/27 19:29:46 sachandr ship $ */

mo_org_id number;

FUNCTION get_tax_category_id(p_vat_tax_id IN NUMBER) RETURN NUMBER;

FUNCTION get_tax_inclusive_flag(p_tax_category_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE get_item_fsc_txn_nat_code(p_inv_item_id   IN NUMBER,
                                    p_item_org      IN OUT NOCOPY VARCHAR2,
                                    p_item_fsc_type IN OUT NOCOPY VARCHAR2,
                                    p_fed_trib      IN OUT NOCOPY VARCHAR2,
                                    p_state_trib    IN OUT NOCOPY VARCHAR2);

PROCEDURE get_memo_fsc_txn_nat_code(p_memo_line_id  IN NUMBER,
                                    p_item_org      IN OUT NOCOPY VARCHAR2,
                                    p_item_fsc_type IN OUT NOCOPY VARCHAR2,
                                    p_fed_trib      IN OUT NOCOPY VARCHAR2,
                                    p_state_trib    IN OUT NOCOPY VARCHAR2);

PROCEDURE get_tax_base_rate_amount
     (p_cust_trx_line_id IN NUMBER,
      p_tax_base_rate    IN OUT NOCOPY NUMBER,
      p_tax_base_amount  IN OUT NOCOPY NUMBER,
      p_org_id           IN     NUMBER);   --Bugfix 2367111

FUNCTION get_tax_method
     (p_org_id           IN NUMBER )RETURN VARCHAR2;   --Bugfix 2367111

FUNCTION contributor_class_exists(p_address_id             IN NUMBER,
                                  p_contributor_class_code IN VARCHAR2)
RETURN BOOLEAN;

FUNCTION contributor_class_check(p_address_id             IN NUMBER,
                                 p_contributor_class_code IN VARCHAR2)
RETURN BOOLEAN;

PROCEDURE populate_cus_cls_details(p_address_id             IN NUMBER,
                                   p_contributor_class_code IN VARCHAR2);

FUNCTION get_lookup_meaning(p_lookup_code   IN VARCHAR2,
                            p_lookup_type   IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE set_mo_org_id(p_org_id number) ;
function get_mo_org_id return number;
FUNCTION validate_loc_classification(p_geo_type IN VARCHAR2,
                                     p_country_code IN VARCHAR2
                                     )
RETURN VARCHAR2;
END JL_ZZ_AR_TX_LIB_PKG;

/
