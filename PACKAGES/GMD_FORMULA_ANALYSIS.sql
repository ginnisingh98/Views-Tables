--------------------------------------------------------
--  DDL for Package GMD_FORMULA_ANALYSIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_FORMULA_ANALYSIS" AUTHID CURRENT_USER AS
/* $Header: GMDFANLS.pls 120.0 2005/05/26 00:54:54 appldev noship $ */

TYPE form_anlys_tab IS TABLE OF gmd_formula_analysis_dtl%ROWTYPE INDEX BY BINARY_INTEGER;
P_dtl_tab    form_anlys_tab;

TYPE ing_rec IS RECORD (item_id             NUMBER,
                        line_no             NUMBER,
                        item_no             VARCHAR2(32),
                        qty                 NUMBER,
                        item_um             VARCHAR2(4),
                        iaformula_id        NUMBER,
                        tpformula_id        NUMBER,
                        formula_id          NUMBER,
                        exp_ind             NUMBER,
                        mass_qty            NUMBER,
                        vol_qty             NUMBER,
                        technical_class     VARCHAR2(240),
                        technical_sub_class VARCHAR2(240));

TYPE ing_tab IS TABLE OF ing_rec INDEX BY BINARY_INTEGER;
TYPE formula_rec IS RECORD (formula_id NUMBER);
TYPE formula_tab IS TABLE OF formula_rec INDEX BY BINARY_INTEGER;
P_ingred_tab   ing_tab;
P_form_tab     formula_tab;
P_density      VARCHAR2(40);
P_vol_um       mtl_units_of_measure.unit_of_measure%TYPE;
P_vol_um_type  mtl_units_of_measure.unit_of_measure%TYPE;
P_mass_um      mtl_units_of_measure.unit_of_measure%TYPE;
P_mass_um_type mtl_units_of_measure.unit_of_measure%TYPE;
P_space        VARCHAR2(100);
P_error        VARCHAR2(100);
P_warning      VARCHAR2(100);
P_vrules_tab   gmd_fetch_validity_rules.recipe_validity_tbl;

PROCEDURE analyze_formula(err_buf           OUT NOCOPY VARCHAR2,
                          ret_code          OUT NOCOPY VARCHAR2,
                          p_organization_id IN  NUMBER,
                          p_laboratory_id   IN  NUMBER,
                          p_formula_no      IN  VARCHAR2,
                          p_formula_vers    IN  NUMBER,
                          p_formula_id      IN  NUMBER,
                          p_analysis_qty    IN  NUMBER,
                          p_rep_um          IN  VARCHAR2,
                          p_explosion_rule  IN  NUMBER,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2);
PROCEDURE calc_percent(p_orgn_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE check_explosion(p_formula_id NUMBER, p_organization_id NUMBER, p_laboratory_id NUMBER, p_rec IN OUT NOCOPY ing_rec,
                          p_explosion_rule NUMBER, x_return_status OUT NOCOPY VARCHAR2);
PROCEDURE get_valid_formula(p_recipe_use NUMBER, p_vr_status VARCHAR2, p_status VARCHAR2, x_formula_id OUT NOCOPY NUMBER,
                            x_formula_no OUT NOCOPY VARCHAR2, x_formula_vers OUT NOCOPY NUMBER, x_found OUT NOCOPY NUMBER);
PROCEDURE scale_table(p_formula_id NUMBER, p_orgn_id NUMBER, p_scale_factor NUMBER, p_table IN OUT NOCOPY ing_tab);
PROCEDURE try_validity_rules(p_item_id NUMBER, p_organization_id NUMBER,
                             p_qty NUMBER, p_uom VARCHAR2,
                             X_vr_tbl OUT NOCOPY gmd_fetch_validity_rules.recipe_validity_tbl);
PROCEDURE load_ingreds(p_formula_id NUMBER, x_ing_tab OUT NOCOPY ing_tab,
                       x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE calc_mass_vol_qty(p_rec IN OUT NOCOPY ing_rec, p_organization_id NUMBER, p_laboratory_id NUMBER, x_return_status OUT NOCOPY VARCHAR2);
PROCEDURE get_formula(p_recipe_id IN NUMBER, x_form_mst_rec OUT NOCOPY fm_form_mst%ROWTYPE);
PROCEDURE get_recipe(p_recipe_id IN NUMBER, x_recipe_rec OUT NOCOPY gmd_recipes%ROWTYPE);

PROCEDURE get_density(p_ing_rec ing_rec, p_organization_id NUMBER, p_laboratory_id NUMBER, p_tech_parm_name VARCHAR2,
                      x_value OUT NOCOPY NUMBER, x_return_status OUT NOCOPY VARCHAR2);

END gmd_formula_analysis;

 

/
