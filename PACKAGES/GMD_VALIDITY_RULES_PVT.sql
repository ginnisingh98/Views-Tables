--------------------------------------------------------
--  DDL for Package GMD_VALIDITY_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_VALIDITY_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVRVRS.pls 120.0.12010000.1 2008/07/24 10:02:25 appldev ship $ */

  m_api_version   CONSTANT NUMBER         := 1;
  m_pkg_name      CONSTANT VARCHAR2 (30)  := 'GMD_VALIDITY_RULES_PVT';

  /* define record and table type to specify the column that needs to
     updated */
  TYPE update_table_rec_type IS RECORD
  (
   p_col_to_update	VARCHAR2(240)
  ,p_value		VARCHAR2(240)
  );

  TYPE update_tbl_type IS TABLE OF update_table_rec_type INDEX BY BINARY_INTEGER;

  PROCEDURE update_validity_rules
  ( p_validity_rule_id	IN	gmd_recipe_validity_rules.recipe_validity_rule_id%TYPE
  , p_update_table	    IN	GMD_VALIDITY_RULES_PVT.update_tbl_type
  , x_message_count 	  OUT NOCOPY 	NUMBER
  , x_message_list 	    OUT NOCOPY 	VARCHAR2
  , x_return_status	    OUT NOCOPY 	VARCHAR2
  );

  -- Commented the section below to make these procedures / functions Private */
  -- Some of these validation call might be moved to a public later.
  /*
  PROCEDURE validate_start_date (P_disp_start_date  DATE,
                                 P_routing_start_date DATE,
                                 x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE validate_end_date (P_end_date  DATE,
                               P_routing_end_date DATE,
                               x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE effective_dates ( P_start_date DATE,
                              P_end_date DATE,
                              x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE std_qty(P_std_qty NUMBER,
                    P_min_qty NUMBER,
                    P_max_qty NUMBER,
                    x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE max_qty(P_min_qty NUMBER,
                    P_max_qty NUMBER,
                    x_return_status OUT NOCOPY VARCHAR2);

  -- this procedure calls gmi stored procedures and copies
  -- min and max in inv uom into block fields
  PROCEDURE calc_inv_qtys (P_inv_item_um VARCHAR2,
                           P_item_um VARCHAR2,
                           P_item_id NUMBER,
                           P_min_qty NUMBER,
                           P_max_qty NUMBER,
                           X_inv_min_qty OUT NOCOPY NUMBER,
                           X_inv_max_qty OUT NOCOPY NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2) ;

  PROCEDURE calculate_process_loss( V_assign 	IN	NUMBER DEFAULT 1
                                   ,P_vr_id   IN  NUMBER
                                   ,X_TPL      OUT NOCOPY NUMBER
                                   ,X_PPL      OUT NOCOPY NUMBER
                                   ,x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE check_for_duplicate(pRecipe_id NUMBER
                               ,pitem_id NUMBER
                               ,pOrgn_code VARCHAR2 DEFAULT NULL
                               ,pRecipe_Use NUMBER
                               ,pPreference NUMBER
                               ,pstd_qty NUMBER
                               ,pmin_qty NUMBER
                               ,pmax_qty NUMBER
                               ,pinv_max_qty NUMBER
                               ,pinv_min_qty NUMBER
                               ,pitem_um VARCHAR2
                               ,pstart_date DATE
                               ,pend_date DATE DEFAULT NULL
                               ,pPlanned_process_loss NUMBER DEFAULT NULL
                               ,x_return_status OUT NOCOPY VARCHAR2
                               );
  */

END GMD_VALIDITY_RULES_PVT;

/
