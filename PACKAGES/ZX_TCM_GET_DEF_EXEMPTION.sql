--------------------------------------------------------
--  DDL for Package ZX_TCM_GET_DEF_EXEMPTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TCM_GET_DEF_EXEMPTION" AUTHID CURRENT_USER AS
/* $Header: zxcgetdefexempts.pls 120.1 2005/11/09 00:43:22 usrikuma ship $ */

TYPE exemption_rec_type IS RECORD
  ( TAX_EXEMPTION_ID 			NUMBER(15),
    EXEMPTION_TYPE_CODE 		VARCHAR2(30),
    EXEMPTION_STATUS_CODE		VARCHAR2(30),
    EXEMPT_CERTIFICATE_NUMBER 		VARCHAR2(80),
    EXEMPT_REASON_CODE			VARCHAR2(30),
    TAX_REGIME_CODE			VARCHAR2(30),
    TAX_STATUS_CODE			VARCHAR2(30),
    TAX					VARCHAR2(30),
    TAX_RATE_CODE			VARCHAR2(50),
    EFFECTIVE_FROM			DATE,
    EFFECTIVE_TO			DATE,
    CONTENT_OWNER_ID			NUMBER(15),
    PRODUCT_ID				NUMBER,
    INVENTORY_ORG_ID			NUMBER,
    RATE_MODIFIER			NUMBER,
    TAX_JURISDICTION_ID 		NUMBER(15),
    PARTY_TAX_PROFILE_ID		NUMBER(15));

TYPE exemption_rec_tbl_type IS TABLE of exemption_rec_type INDEX BY BINARY_INTEGER;


PROCEDURE get_default_exemptions
                            (p_bill_to_cust_acct_id          IN NUMBER,
                             p_ship_to_cust_acct_id          IN NUMBER,
                             p_ship_to_site_use_id           IN NUMBER,
                             p_bill_to_site_use_id           IN NUMBER,
                             p_bill_to_party_id              IN NUMBER,
                             p_bill_to_party_site_id         IN NUMBER,
                             p_ship_to_party_site_id         IN NUMBER,
 			     p_legal_entity_id               IN NUMBER,
   			     p_org_id 			     IN NUMBER,
			     p_trx_date			     IN DATE,
                             p_exempt_certificate_number     IN VARCHAR2,
                             p_reason_code                   IN VARCHAR2,
                             p_exempt_control_flag           IN VARCHAR2,
			     p_inventory_org_id		     IN NUMBER,
			     p_inventory_item_id	     IN NUMBER,
                             x_return_status                 OUT NOCOPY VARCHAR2,
                             x_exemption_rec_tbl             OUT NOCOPY exemption_rec_tbl_type);

END;

 

/
