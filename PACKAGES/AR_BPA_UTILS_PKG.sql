--------------------------------------------------------
--  DDL for Package AR_BPA_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BPA_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: ARBPAUTS.pls 120.3 2005/08/03 00:21:19 lishao noship $*/
pg_debug varchar2(1);

FUNCTION fn_get_header_level_so ( p_customer_trx_id IN number ) return varchar2 ;

FUNCTION fn_get_header_level_co ( p_customer_trx_id IN number ) return varchar2 ;

FUNCTION fn_get_billing_line_level ( p_customer_trx_id IN number ) return varchar2;

FUNCTION fn_get_profile_class_name ( p_customer_trx_id IN number ) return varchar2;

FUNCTION fn_get_tax_printing_option (  p_bill_to_site_use_id IN number, p_bill_to_customer_id in number) return varchar2;

FUNCTION fn_trx_has_groups ( p_customer_trx_id IN number ) return varchar2;

FUNCTION fn_get_line_taxrate ( p_customer_trx_line_id IN number) return varchar2;

FUNCTION fn_get_line_taxname ( p_customer_trx_line_id IN number) return varchar2;

FUNCTION fn_get_line_taxcode ( p_customer_trx_line_id IN number) return varchar2;

FUNCTION fn_get_group_taxrate (p_customer_trx_id IN number, id in number, bcl_id in number) return varchar2;

FUNCTION fn_get_group_taxname (p_customer_trx_id IN number, id in number, bcl_id in number) return varchar2;

FUNCTION fn_get_group_taxcode (p_customer_trx_id IN number, id in number, bcl_id in number) return varchar2;

FUNCTION fn_get_group_taxyn (p_customer_trx_id IN number, id in number, bcl_id in number) return varchar2;

FUNCTION fn_get_line_description ( p_customer_trx_line_id IN number) return varchar2;

/* Return contact name */
FUNCTION fn_get_contact_name (p_contact_id IN NUMBER) return varchar2 ;

/* Return contact phone */
FUNCTION fn_get_phone (p_contact_id IN NUMBER) return varchar2 ;

/* Return contact fax */
FUNCTION fn_get_fax (p_contact_id IN NUMBER) return varchar2 ;

function get_tax_description(
    tax_rate in number,
    vat_tax_id in number,
    tax_exemption_id in number,
    location_rate_id in number,
    tax_precedence in number,
    D_euro_taxable_amount in varchar2  ) return varchar2 ;

procedure create_dup_areas(
  p_orig_template_id IN NUMBER,
  p_dup_template_id IN NUMBER
);

procedure DELETE_FLEXFIELD_ITEMS (
  P_DATASRC_APP_ID in NUMBER
);

procedure UPDATE_VIEW_ITEM (
  P_ITEM_ID in NUMBER default null,
  P_ITEM_CODE in VARCHAR2,
  P_DISPLAY_LEVEL in VARCHAR2,
  P_DATA_SOURCE_ID in NUMBER,
  P_DISPLAY_ENABLED_FLAG in VARCHAR2,
  P_SEEDED_APPLICATION_ID in NUMBER,
  P_DATA_TYPE in VARCHAR2,
  P_COLUMN_NAME in VARCHAR2,
  P_ITEM_NAME in VARCHAR2,
  P_DISPLAY_PROMPT in VARCHAR2,
  P_ITEM_DESCRIPTION in VARCHAR2,
  P_FLEXFIELD_ITEM_FLAG in VARCHAR2,
  P_AMOUNT_ITEM_FLAG IN VARCHAR2,
  P_ASSIGNMENT_ENABLED_FLAG IN VARCHAR2,
  P_DISPLAYED_MULTI_LEVEL_FLAG  IN VARCHAR2,
  P_TAX_ITEM_FLAG in VARCHAR2,
  P_TOTALS_ENABLED_FLAG in VARCHAR2,
  P_LINK_ENABLED_FLAG in VARCHAR2,
  P_ITEM_TYPE in VARCHAR2
);

procedure DELETE_VIEW_ITEM (
  P_ITEM_ID in NUMBER
);

PROCEDURE debug (
    p_message                   IN      VARCHAR2,
    p_log_level                 IN      NUMBER default FND_LOG.LEVEL_STATEMENT,
    p_module_name               IN      VARCHAR2 default 'ar.plsql.ar_bpa_utils_pkg');

end AR_BPA_UTILS_PKG;

 

/
