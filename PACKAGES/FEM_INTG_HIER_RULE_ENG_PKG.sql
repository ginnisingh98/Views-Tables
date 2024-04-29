--------------------------------------------------------
--  DDL for Package FEM_INTG_HIER_RULE_ENG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_INTG_HIER_RULE_ENG_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_intg_hir_eng.pls 120.1 2005/09/01 11:10:37 appldev noship $ */

/***********************************************************************
 *              PACKAGE VARIABLES                                      *
 ***********************************************************************/

  pv_hier_rule_obj_id      NUMBER;
  pv_hier_rule_obj_def_id  NUMBER;
  pv_coa_id                NUMBER;
  pv_dim_id                NUMBER;
  pv_dim_vs_id             NUMBER;
  pv_aol_vs_id             NUMBER;
  pv_dim_memb_vl_obj       VARCHAR2(30);
  pv_dim_memb_tl_tab       VARCHAR2(30);
  pv_dim_memb_b_tab        VARCHAR2(30);
  pv_dim_memb_col          VARCHAR2(30);
  pv_dim_memb_disp_col     VARCHAR2(30);
  pv_dim_memb_name_col     VARCHAR2(30);
  pv_dim_memb_desc_col     VARCHAR2(30);
  pv_dim_hier_tab          VARCHAR2(30);
  pv_dim_attr_tab          VARCHAR2(30);

  pv_dim_rule_obj_def_id   NUMBER;
  pv_dim_rule_obj_id       NUMBER;

  pv_segment_count         NUMBER;
  pv_top_parent_disp_code  VARCHAR2(30);
  pv_top_parent_id         NUMBER;
  pv_new_obj_def_needed    BOOLEAN;
  pv_gvsc_id               NUMBER;
  -- AGB =============================================================
/***********************************************************************
 *              PL/SQL TABLE                                           *
 ***********************************************************************/
  TYPE r_hier_traversal IS RECORD (
         display_order           number,
         top_parent_value        VARCHAR2 (150),
         top_parent_id           number,
         aol_vs_id               number,
         concat_segment          number);

  TYPE tr_hier_traversal IS TABLE OF r_hier_traversal;

  pv_traversal_rarray   tr_hier_traversal := tr_hier_traversal();
  pv_hier_obj_def_id           NUMBER;

  -- AGB END =============================================================


/*****************************************************************
 *              PUBLIC PROCEDURES                                *
 *****************************************************************/

-- ======================================================================
-- Procedure
--     Main
-- Purpose
--     This routine is the Main of the FEM_INTG_HIER_RULE_ENG_PKG
--  History
--     10-28-04  Jee Kim  Created
-- Arguments
--     x_errbuf                   Standard Concurrent Program parameter
--     x_retcode                  Standard Concurrent Program parameter
--     p_hier_rule_obj_def_id     Hierarchy rule version ID
--     p_new_version_flag         Indicates if a new version of the hierarchy
--                                structure should be created
-- ======================================================================

  PROCEDURE Main (x_errbuf OUT NOCOPY  VARCHAR2,
                x_retcode OUT NOCOPY VARCHAR2,
                p_hier_rule_obj_def_id IN NUMBER);

END FEM_INTG_HIER_RULE_ENG_PKG;

 

/
