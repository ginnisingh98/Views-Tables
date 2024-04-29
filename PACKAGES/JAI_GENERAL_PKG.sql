--------------------------------------------------------
--  DDL for Package JAI_GENERAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_GENERAL_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_general.pls 120.2 2006/02/06 10:41:50 avallabh ship $ */

  YES       CONSTANT VARCHAR2(1) := 'Y';
  NO        CONSTANT VARCHAR2(1) := 'N';

  gd_ass_value_date CONSTANT DATE DEFAULT SYSDATE ; -- --rpokkula for File.Sql.35

  INDIAN_CURRENCY  CONSTANT VARCHAR2(3) := 'INR';

  FUNCTION get_fin_year( p_organization_id IN NUMBER) RETURN NUMBER;

  PROCEDURE get_range_division(  p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER,
    p_range_no OUT NOCOPY VARCHAR2, p_division_no OUT NOCOPY VARCHAR2);

  PROCEDURE update_rg_balances(  p_organization_id IN NUMBER, p_location_id IN NUMBER,
    p_register IN VARCHAR2, p_amount IN NUMBER, p_transaction_source IN VARCHAR2, p_called_from IN VARCHAR2);

  FUNCTION get_currency_precision(p_organization_id IN NUMBER) RETURN NUMBER;

  FUNCTION get_gl_concatenated_segments(p_code_combination_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION get_organization_code( p_organization_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION get_rg_register_type(p_item_class IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION get_primary_uom_code(p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION get_uom_code(p_uom IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION get_orgn_master_flag(p_organization_id IN NUMBER, p_location_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION trxn_to_primary_conv_rate(
    p_transaction_uom_code  IN  MTL_UNITS_OF_MEASURE.uom_code%TYPE,
    p_primary_uom_code      IN  MTL_UNITS_OF_MEASURE.uom_code%TYPE,
    p_inventory_item_id     IN  MTL_SYSTEM_ITEMS.inventory_item_id%TYPE
  ) RETURN NUMBER;

  FUNCTION get_matched_boe_no(p_transaction_id IN  NUMBER ) RETURN VARCHAR2;

  FUNCTION get_last_record_of_rg(
    p_register_name     IN VARCHAR2,
    p_organization_id   IN NUMBER,
    p_location_id       IN NUMBER,
    p_inventory_item_id IN NUMBER,
    p_fin_year          IN NUMBER   DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION plot_codepath (
    p_statement_id                            in      varchar2,
    p_codepath                                in      varchar2,
    p_calling_procedure                       in      varchar2 default null,
    p_special_call                            in      varchar2  default null
  ) RETURN VARCHAR2;

  /* added by Vijay Shankar for Bug#4068823 */
  FUNCTION is_item_an_expense(
    p_organization_id   IN  NUMBER,
    p_item_id           IN  NUMBER
  ) RETURN VARCHAR2;

  -- added, Harshita for bug #4245062
 FUNCTION JA_IN_VAT_ASSESSABLE_VALUE(
    p_party_id IN NUMBER,
    p_party_site_id IN NUMBER,
    p_inventory_item_id IN NUMBER,
    p_uom_code IN VARCHAR2,
    p_default_price IN NUMBER,
    p_ass_value_date IN DATE,    -- DEFAULT SYSDATE, -- Added global variable gd_ass_value_date in package spec. by rpokkula for File.Sql.35
    p_party_type IN VARCHAR2
) RETURN NUMBER ;

END jai_general_pkg;
 

/
