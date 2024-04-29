--------------------------------------------------------
--  DDL for Package GMD_SPREAD_FETCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SPREAD_FETCH_PKG" AUTHID CURRENT_USER as
/* $Header: GMDSPDFS.pls 120.6.12010000.1 2008/07/24 09:59:56 appldev ship $ */


  PROCEDURE load_details (V_entity_id IN NUMBER,V_sprd_id IN NUMBER,
  		          V_batch_id  IN NUMBER,V_formula_id IN NUMBER, V_spec_id IN NUMBER  DEFAULT NULL,
  		          V_orgn_id   IN NUMBER,V_update_inv_ind IN VARCHAR2,
  		          V_plant_id  IN NUMBER);

  PROCEDURE load_spread_details  (V_entity_id IN NUMBER,V_sprd_id IN  NUMBER,V_orgn_id IN NUMBER);

  PROCEDURE load_batch_details   (V_entity_id IN NUMBER,V_batch_id IN NUMBER,V_orgn_id IN NUMBER,
                                  V_update_inv_ind IN VARCHAR2,V_plant_id IN NUMBER);

  PROCEDURE load_formula_details (V_entity_id IN NUMBER,V_formula_id IN NUMBER,V_orgn_id IN NUMBER,
  			          V_plant_id IN NUMBER);

  -- NPD Conv. Changed parameter V_orgn_code to V_orgn_id.
  PROCEDURE load_tech_params (V_entity_id IN NUMBER,V_sprd_id IN NUMBER,V_batch_id IN NUMBER,
                              V_orgn_id IN NUMBER,V_folder_name IN VARCHAR2,
                              V_inv_item_id IN NUMBER DEFAULT NULL,V_formula_id IN NUMBER DEFAULT NULL);

  PROCEDURE add_new_line  (V_entity_id  IN NUMBER, V_inv_item_id IN NUMBER, V_line_type IN NUMBER,
  			   V_line_no    IN NUMBER, V_source_ind  IN NUMBER,
  			   V_formula_id IN NUMBER, V_move_order_header_id IN NUMBER,
  			   V_orgn_id    IN NUMBER,X_line_id  OUT NOCOPY NUMBER,
  			   X_parent_line_id  OUT NOCOPY NUMBER,
  			   X_move_order_line_id  OUT NOCOPY NUMBER,V_plant_id IN NUMBER);

  PROCEDURE load_spread_values (V_entity_id IN NUMBER,V_sprd_id IN NUMBER,V_orgn_id IN NUMBER,
  				V_parent_line_id IN NUMBER);

  PROCEDURE load_batch_values (V_entity_id IN NUMBER,V_batch_id IN NUMBER,V_orgn_id IN NUMBER,
  			       V_matl_detl_id IN NUMBER,V_line_id IN NUMBER DEFAULT NULL,
  			       V_plant_id IN NUMBER);

  PROCEDURE load_formula_values (V_entity_id IN NUMBER,V_formula_id IN NUMBER,V_orgn_id IN NUMBER,
  			         V_formulaline_id IN NUMBER,V_line_id IN NUMBER DEFAULT NULL,
  			         V_plant_id IN NUMBER);

  PROCEDURE save_spreadsheet (V_entity_id IN NUMBER,V_sprd_id IN NUMBER,
  			      V_formula_id IN NUMBER,V_batch_id IN NUMBER,
  			      V_orgn_id IN NUMBER,V_spread_name IN VARCHAR2,V_maintain_type NUMBER DEFAULT NULL,
  			      V_text_code IN NUMBER,V_last_update_date IN DATE,V_move_order_header_id IN NUMBER);

  FUNCTION get_density_value (V_line_id IN NUMBER,V_density_parameter IN VARCHAR2) RETURN NUMBER;

  PROCEDURE update_line_mass_vol_qty (V_orgn_id IN NUMBER,V_line_id IN NUMBER,V_density_parameter IN VARCHAR2,
                                      V_mass_uom IN VARCHAR2,V_vol_uom IN VARCHAR2,X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE update_mass_vol_qty (V_orgn_id IN NUMBER, V_entity_id IN NUMBER,V_density_parameter IN VARCHAR2,
                                 V_mass_uom IN VARCHAR2,V_vol_uom IN VARCHAR2,X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE load_quality_data (V_line_id IN NUMBER, V_orgn_id IN NUMBER,V_plant_id IN NUMBER);

  -- Sriram.S CAF Enhancement Bug# 3891067
  PROCEDURE get_lot_density (P_orgn_id IN NUMBER, P_parent_detl_id NUMBER, P_entity_id NUMBER);

  PROCEDURE load_lcf_details  (V_entity_id IN NUMBER, V_orgn_id IN NUMBER,V_plant_id IN NUMBER);

  PROCEDURE load_lcf_values (V_entity_id IN NUMBER,V_orgn_id IN NUMBER,
                             V_formulaline_id IN NUMBER,V_plant_id IN NUMBER,
                             V_line_id IN NUMBER DEFAULT NULL);

  PROCEDURE load_derived_cost (V_entity_id IN NUMBER,V_orgn_id IN NUMBER,V_line_id IN NUMBER);

end GMD_SPREAD_FETCH_PKG;

/
