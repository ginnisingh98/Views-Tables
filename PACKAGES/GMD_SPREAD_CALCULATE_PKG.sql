--------------------------------------------------------
--  DDL for Package GMD_SPREAD_CALCULATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SPREAD_CALCULATE_PKG" AUTHID CURRENT_USER as
/* $Header: GMDSPDCS.pls 120.2.12010000.1 2008/07/24 09:59:54 appldev ship $ */

  PROCEDURE calculate (V_entity_id IN NUMBER,V_orgn_id IN NUMBER,X_return_status OUT NOCOPY VARCHAR2) ;

  PROCEDURE rollup_wt_pct (V_entity_id IN NUMBER,V_line_id IN NUMBER,V_parm_name IN VARCHAR2,
                           V_parm_id IN NUMBER,V_sort_seq IN NUMBER,X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE evaluate_expression (V_entity_id IN NUMBER,V_line_id IN NUMBER,V_parm_name IN VARCHAR2,V_parm_id IN NUMBER,
                                 V_sort_seq IN NUMBER,X_expression OUT NOCOPY VARCHAR2,X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE rollup_vol_pct (V_entity_id IN NUMBER,V_orgn_id IN NUMBER, V_line_id IN NUMBER,V_parm_name IN VARCHAR2,V_parm_id IN NUMBER,
                            V_sort_seq IN NUMBER,X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE rollup_cost_update(V_entity_id IN NUMBER,V_line_id IN NUMBER,V_parm_name IN VARCHAR2,V_parm_id IN NUMBER,
                               V_primary_qty IN	VARCHAR2,V_sort_seq IN NUMBER,X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE rollup_update(V_entity_id IN NUMBER,V_line_id IN NUMBER,V_parm_name IN VARCHAR2,V_parm_id IN NUMBER,
                          V_sort_seq IN NUMBER,X_return_status	OUT NOCOPY VARCHAR2);

  FUNCTION rollup_cost_units  (V_entity_id IN NUMBER,V_line_id IN NUMBER,V_parm_name IN VARCHAR2,V_parm_id IN NUMBER,
                               X_return_status OUT NOCOPY VARCHAR2) RETURN NUMBER;

  PROCEDURE rollup_equiv_wt (V_entity_id IN NUMBER,V_line_id IN NUMBER,V_parm_name IN VARCHAR2,V_parm_id IN NUMBER,
                             V_unit_code IN VARCHAR2,V_orgn_id IN NUMBER,V_sort_seq IN NUMBER,
                             X_return_status OUT NOCOPY	VARCHAR2);

   procedure temp_dump (V_entity_id		IN		NUMBER);
    procedure temp_param (V_entity_id IN NUMBER,V_line_id IN NUMBER default null);

   procedure auto_calc_product(V_entity_id		IN		NUMBER,
                                x_return_status    OUT NOCOPY VARCHAR2,
                                 x_msg_count        OUT NOCOPY      NUMBER,
                                 x_msg_data         OUT NOCOPY      VARCHAR2 );

end GMD_SPREAD_CALCULATE_PKG;

/
