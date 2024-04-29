--------------------------------------------------------
--  DDL for Package GMD_TECH_PARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_TECH_PARAMS" AUTHID CURRENT_USER AS
/* $Header: GMDTECHS.pls 115.5 2002/10/25 20:22:05 santunes noship $ */

/* BEGIN BUG#2360352 T Prasuna */
/* Changed the length of the 'value' field from 30 to 80 characters */
TYPE tech_param_rec IS RECORD
    (tech_parm_name  VARCHAR2(30),
     value           VARCHAR2(80),
     uom             VARCHAR2(4),
     data_type       NUMBER,
     expression      VARCHAR2(100));
/* END BUG#2360352 */
TYPE tech_param_tab IS TABLE OF tech_param_rec INDEX BY BINARY_INTEGER;

TYPE item_master_rec IS RECORD
    (item_no          VARCHAR2(32),
     item_id          NUMBER,
     item_primary_uom VARCHAR2(4),
     line_type        NUMBER,
     quantity         NUMBER,
     uom              VARCHAR2(4),
     line_no          NUMBER,
     line_id          NUMBER,
     formula_id       NUMBER,
     lot_no           VARCHAR2(32),
     sublot_no        VARCHAR2(32),
     lot_id           NUMBER,
     primary_uom_qty  NUMBER,
     mass_uom_qty     NUMBER,
     vol_uom_qty      NUMBER);
TYPE item_tbl IS TABLE OF item_master_rec INDEX BY BINARY_INTEGER;
item_master_tbl item_tbl;

TYPE tp_master_rec IS RECORD
    (tech_parm_name VARCHAR2(32),
     expression     VARCHAR2(240),
     data_type      NUMBER,
     tp_uom         VARCHAR2(4),
     qc_orgn_code   VARCHAR2(4),
     qc_assay_name  VARCHAR2(32));
TYPE tp_tbl IS TABLE OF tp_master_rec INDEX BY BINARY_INTEGER;
tp_master_tbl tp_tbl;

TYPE attrib_master_rec IS RECORD
    (item_id        NUMBER,
     line_type      NUMBER,
     line_no        NUMBER,
     tech_parm_name VARCHAR2(32),
     num_value      NUMBER,
     char_value     VARCHAR2(240),
     boolean_value  VARCHAR2(30));
TYPE attrib_tbl IS TABLE OF attrib_master_rec INDEX BY BINARY_INTEGER;
attrib_master_tbl attrib_tbl;

PROCEDURE load_ingred_tp(p_lab_type          IN  VARCHAR2,
                         p_formula_id        IN  NUMBER,
                         p_item_id           IN  NUMBER,
                         p_line_no           IN  NUMBER,
                         x_tech_table        OUT NOCOPY tech_param_tab,
                         x_return_status     OUT NOCOPY VARCHAR2,
                         x_msg_count         OUT NOCOPY NUMBER,
                         x_msg_data          OUT NOCOPY VARCHAR2);
PROCEDURE load_prod_tp(p_lab_type          IN  VARCHAR2,
                       p_formula_id        IN  NUMBER,
                       p_item_id           IN  NUMBER,
                       p_line_no           IN  NUMBER,
                       x_tech_table        OUT NOCOPY tech_param_tab,
                       x_return_status     OUT NOCOPY VARCHAR2,
                       x_msg_count         OUT NOCOPY NUMBER,
                       x_msg_data          OUT NOCOPY VARCHAR2);
PROCEDURE load_lab_arrays(p_formula_id NUMBER, p_lab_type VARCHAR2, p_prod_tech_parm NUMBER);
PROCEDURE calculate_expr(p_tech_table IN tech_param_tab, calc_table OUT NOCOPY tech_param_tab);
PROCEDURE convert_uoms(p_lab_type      IN  VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2);
PROCEDURE get_qc_results;
PROCEDURE rollup_wt_pct(p_tech_parm_name VARCHAR2, p_result OUT NOCOPY NUMBER);
PROCEDURE rollup_vol_pct_and_spec_gr(p_tech_parm_name VARCHAR2, p_data_type NUMBER, p_result OUT NOCOPY NUMBER);
PROCEDURE rollup_cost_and_units(p_tech_parm_name VARCHAR2, p_prod_uom VARCHAR2,
                                p_lab_type VARCHAR2, p_result OUT NOCOPY NUMBER, x_return_status OUT NOCOPY VARCHAR2);
PROCEDURE rollup_equiv_wt(p_tech_parm_name VARCHAR2, p_prod_uom VARCHAR2,
                          p_lab_type VARCHAR2, p_result OUT NOCOPY NUMBER, x_return_status OUT NOCOPY VARCHAR2);

FUNCTION check_for_tech_data(plab_type VARCHAR2, pitem_id NUMBER, pformula_id NUMBER) RETURN NUMBER;

END gmd_tech_params;

 

/
