--------------------------------------------------------
--  DDL for Package GMD_LCF_FETCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_LCF_FETCH_PKG" AUTHID CURRENT_USER as
/* $Header: GMDLCFMS.pls 120.5 2005/11/22 11:42 rajreddy noship $ */
G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMD_LCF_FETCH_PKG';

  PROCEDURE calculate (V_formulation_spec_id IN NUMBER, V_line_id IN NUMBER, X_return_status OUT NOCOPY VARCHAR2) ;

  PROCEDURE rollup_wt_pct (V_parm_name IN VARCHAR2,V_line_id IN NUMBER,
                           V_parm_id IN NUMBER,X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE rollup_vol_pct (V_parm_name IN VARCHAR2,V_line_id IN NUMBER,
                            V_parm_id IN NUMBER,X_return_status OUT NOCOPY VARCHAR2);

  FUNCTION get_density_value (V_line_id IN NUMBER,V_density_parameter IN VARCHAR2) RETURN NUMBER;

  PROCEDURE update_line_mass_vol_qty (V_orgn_id IN NUMBER,V_line_id IN NUMBER,
                                      V_density_parameter IN VARCHAR2,V_mass_uom IN VARCHAR2,
                                      V_vol_uom IN VARCHAR2,X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE update_mass_vol_qty (V_orgn_id IN NUMBER,V_entity_id IN NUMBER,
                                 V_density_parameter IN VARCHAR2,V_mass_uom IN VARCHAR2,
                                 V_vol_uom IN VARCHAR2,X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE load_cost_values (V_orgn_id IN NUMBER, V_inv_item_id IN NUMBER, V_cost_type IN VARCHAR2,
                              V_date IN DATE, V_cost_orgn IN VARCHAR2, V_source IN NUMBER, X_value OUT NOCOPY NUMBER);

  PROCEDURE load_tech_values (V_orgn_id IN NUMBER, V_formulation_spec_id IN NUMBER, V_date IN DATE);

  PROCEDURE load_items (V_formulation_spec_id IN NUMBER, V_organization_id IN NUMBER,V_ingred_pick_base IN VARCHAR2,
  			V_formula_no IN VARCHAR2, V_batch_no IN VARCHAR2, V_date IN DATE);

  PROCEDURE load_categories (V_formulation_spec_id IN NUMBER);

  PROCEDURE get_category_value (V_inventory_item_id IN NUMBER, V_organization_id IN NUMBER,
  				V_line_id IN NUMBER);

  PROCEDURE load_quality_data (V_line_id IN NUMBER, V_orgn_id IN NUMBER,
                               V_qcassy_typ_id IN NUMBER, V_tech_parm_id IN NUMBER);

  PROCEDURE generate_lcf_data (V_formulation_spec_id IN NUMBER, V_organization_id IN NUMBER,
  			       V_formula_no IN VARCHAR2, V_batch_no IN VARCHAR2, V_date IN DATE,
                               X_return_code OUT NOCOPY NUMBER);

  --debug procedures.
  PROCEDURE temp_dump;
  PROCEDURE temp_param;
  PROCEDURE temp_category;


END GMD_LCF_FETCH_PKG;

 

/
