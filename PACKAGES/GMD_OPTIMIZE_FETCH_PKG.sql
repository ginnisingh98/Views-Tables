--------------------------------------------------------
--  DDL for Package GMD_OPTIMIZE_FETCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_OPTIMIZE_FETCH_PKG" AUTHID CURRENT_USER as
/* $Header: GMDOPTMS.pls 120.1 2005/07/13 07:27:51 rajreddy noship $ */

  PROCEDURE load_optimizer_details (V_entity_id IN NUMBER,V_maintain_type IN NUMBER,
                                    X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE calculate (V_entity_id IN NUMBER,V_orgn_id IN NUMBER,X_return_status OUT NOCOPY VARCHAR2) ;

  PROCEDURE rollup_wt_pct (V_entity_id IN NUMBER,V_parm_name IN VARCHAR2,
                           V_parm_id IN NUMBER,X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE rollup_vol_pct (V_entity_id IN NUMBER,V_parm_name IN VARCHAR2,
                            V_parm_id IN NUMBER,X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE rollup_update (V_entity_id IN NUMBER,V_parm_name IN VARCHAR2,V_parm_id IN NUMBER,
                           X_return_status OUT NOCOPY VARCHAR2);

  FUNCTION rollup_cost_units (V_entity_id IN NUMBER,V_parm_name IN VARCHAR2,
                              V_parm_id IN NUMBER,X_return_status OUT NOCOPY VARCHAR2) RETURN NUMBER;

  PROCEDURE rollup_equiv_wt (V_entity_id IN NUMBER,V_parm_name IN VARCHAR2,
                             V_parm_id IN NUMBER,V_unit_code IN VARCHAR2,V_orgn_id IN NUMBER,
                             X_return_status OUT NOCOPY	VARCHAR2);

  FUNCTION is_lot_selected(V_parentline_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION consider_line(V_line_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION get_density_value (V_line_id IN NUMBER,V_density_parameter IN VARCHAR2) RETURN NUMBER;

  PROCEDURE update_line_mass_vol_qty (V_orgn_id IN NUMBER,V_line_id IN NUMBER,
                                      V_density_parameter IN VARCHAR2,V_mass_uom IN VARCHAR2,
                                      V_vol_uom IN VARCHAR2,X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE update_mass_vol_qty (V_orgn_id IN NUMBER,V_entity_id IN NUMBER,
                                 V_density_parameter IN VARCHAR2,V_mass_uom IN VARCHAR2,
                                 V_vol_uom IN VARCHAR2,X_return_status OUT NOCOPY VARCHAR2);

END GMD_OPTIMIZE_FETCH_PKG;

 

/
