--------------------------------------------------------
--  DDL for Package Body HRI_BPL_DIM_LVL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_DIM_LVL" AS
/* $Header: hribdlv.pkb 120.0 2005/05/29 06:52:40 appldev noship $ */

/******************************************************************************/
/* Returns the label for a dimension level value                              */
/*                                                                            */
/* Inputs:                                                                    */
/*    p_dim_lvl_name:  DIMENSION+LEVEL                                        */
/*    p_dim_lvl_pk:    ID from lookup view                                    */
/*    p_name_type:     e.g. SHORT or LONG                                     */
/*                                                                            */
/* The lookup view corresponding to the dimension level is chosen. For the    */
/* ID given the dimension level value row is queried and the appropriate      */
/* column returned.                                                           */
/******************************************************************************/
FUNCTION get_value_label(p_dim_lvl_name  VARCHAR2,
                         p_dim_lvl_pk    VARCHAR2,
                         p_name_type     VARCHAR2)
       RETURN VARCHAR2 IS

/* Cursor is dynamic as the lookup view changes with */
/* the dimension level passed in */
  TYPE c_dim_lvl_value_csrtype IS REF CURSOR;

  c_dim_lvl_value_csr  c_dim_lvl_value_csrtype;
  l_dim_lvl_value      VARCHAR2(240);
  l_dim_lvl_view       VARCHAR2(30);

BEGIN

/* Look up the LOV view for the given dimension */
  l_dim_lvl_view := hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                       (p_dim_lvl_name).viewby_table;

/* Return the dimension level value from the LOV view */
  OPEN c_dim_lvl_value_csr FOR
  'SELECT value
   FROM ' || l_dim_lvl_view || '
   WHERE id = :id'
  USING p_dim_lvl_pk;
  FETCH c_dim_lvl_value_csr INTO l_dim_lvl_value;
  CLOSE c_dim_lvl_value_csr;

/* Return the value */
  RETURN l_dim_lvl_value;

END get_value_label;

END hri_bpl_dim_lvl;

/
