--------------------------------------------------------
--  DDL for Package CZ_MODEL_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_MODEL_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: czvmdlus.pls 120.1 2005/09/12 09:30:57 misheehy ship $  */

  PATH_PREFERENCE_DISABLED	   constant NUMBER := 0;
  PATH_PREFERENCE_ROOT_ONLY	   constant NUMBER := 1;
  PATH_PREFERENCE_ROOT_KIDS	   constant NUMBER := 2;

  FUNCTION find_nodes_by_path(p_model_to_search IN NUMBER
                             ,p_namepath IN system.cz_varchar2_2000_tbl_type
                             )
      RETURN system.cz_model_node_tbl_type;
  PRAGMA RESTRICT_REFERENCES(find_nodes_by_path, WNDS, WNPS);

  FUNCTION find_unique_node_by_path (p_model_to_search IN NUMBER
                             ,p_namepath IN system.cz_varchar2_2000_tbl_type
							 ,p_path_preference IN NUMBER
                             )
      RETURN system.cz_model_node_tbl_type;
  PRAGMA RESTRICT_REFERENCES(find_unique_node_by_path, WNDS, WNPS);

  -- Returns array of distinct ordered referenced model ids under the top-level
  -- model specified by p_model_id
  FUNCTION get_referenced_models(p_model_id IN NUMBER) RETURN system.cz_model_order_tbl_type;
  PRAGMA RESTRICT_REFERENCES(get_referenced_models, WNDS);

  -- Returns array of all referenced UIs with explosion IDs in context of root UI's model
  FUNCTION get_ui_refs_under_model (
		  p_root_ui_def_id IN NUMBER,
		  p_maxdepth IN NUMBER
	  ) return "SYSTEM".CZ_UIREFS_INMODEL_TBL_TYPE;
  PRAGMA RESTRICT_REFERENCES (get_ui_refs_under_model, WNDS);

  -- GET_PARALLEL_EXPLS takes an enclosing explosion ID in a root model, and a descendant explosion ID in a child model
  -- the descendant explosion ID must be in the CHILD_MODEL_EXPL_ID chain from the enclosing explosion ID
  -- it walks down the corresponding ref-explosion subtrees, matching the explosion nodes accordingly
  -- it returns each pair of corresponding explosion IDs in a table
  -- Note the explosion IDs do not cross models; only explosions from the models owning the argument explosion IDs are
  -- used.
  FUNCTION get_parallel_expls (p_encl_expl_id in number, p_desc_expl_id in number, p_max_expl_depth in number)
  return "SYSTEM".CZ_EXPL_pair_tbl;
  pragma restrict_references (get_parallel_expls, WNDS);

END cz_model_util_pvt;

 

/
