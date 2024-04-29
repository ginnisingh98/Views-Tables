--------------------------------------------------------
--  DDL for Package EAM_WORKBENCH_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WORKBENCH_TREE" AUTHID CURRENT_USER AS
/* $Header: EAMWBTRS.pls 120.2 2006/03/27 05:18:37 kmurthy noship $ */

  /**
   * Given the search criteria, this function finds out all the asset numbers
   * and insert those into the temp table under a group id which is returned.
   */
  function find_all_asset_numbers(p_org_id number,
                                  p_instance_id number,
                                  p_location_id number,
                                  p_category_id number,
                                  p_owning_dept_id number,
                                  p_asset_group_id number,
                                  p_asset_number varchar2,
				  p_transferred_asset varchar2,
				  p_set_name_id  number
				  ) return number;


  /**
   * Given the search criteria, this function finds out all the applicable
   * asset numbers and builds the hierarchy trees. And after that, it dumps
   * all the searched asset numbers into the temp table under a group id which
   * is returned to the user.
   */
  function construct_hierarchy_forest(p_org_id number,
                                      p_instance_id number,
                                      p_location_id number,
                                      p_category_id number,
                                      p_owning_dept_id number,
                                      p_asset_group_id number,
                                      p_asset_number varchar2,
	  			      p_set_name_id  number
				      ) return number;


  /**
   * Procedure construct_hierarchy_forest must be called before this function can
   * be called. Otherwise, it will cause unexpected behavior.
   * Given the asset number and asset group id, this function will copy the
   * subtree of the given asset number to the temp table. It returns the group_id
   * back so the user can reference it. It returns -1 if the given asset number
   * is not found.
   */
  function copy_subtree_to_temp_table(p_asset_group_id number,
                                      p_asset_number varchar2) return number;

  /**
   * This procedure releases the resource taken explicity.
   */
  procedure clear_forest;

  /** added by sraval to include rebuildables in activity workbench
    */
    function find_all_asset_numbers(p_org_id number,
                                    p_instance_id number,
                                    p_location_id number,
                                    p_category_id number,
                                    p_owning_dept_id number,
                                    p_asset_group_id number,
                                    p_asset_number varchar2,
                                    p_include_rebuildable varchar2,
				    p_transferred_asset varchar2,
     				    p_set_name_id  number ) return number;

    /** added by sraval to include rebuildables in activity workbench
    */
    function construct_hierarchy_forest(p_org_id number,
                                        p_instance_id number,
                                        p_location_id number,
                                        p_category_id number,
                                        p_owning_dept_id number,
                                        p_asset_group_id number,
                                        p_asset_number varchar2,
                                        p_include_rebuildable varchar2,
					p_set_name_id  number ) return number;

   /* This procedure is used to delete the session data from eam_asset_explosion_temp
      table. This is added for the bug #2688078
   */
  procedure clear_eam_asset(p_group_id IN NUMBER);

 /* Code Added for bug 3982343 Start */
     TYPE global_group_ids IS
     TABLE OF NUMBER
     INDEX BY BINARY_INTEGER;
     /* This procedure is used to delete session data from
      * eam_asset_explosion_temp table, accepting a plsql collection of group_ids to
      * be deleted.
      */
     procedure clear_eam_asset(p_global_group_ids IN global_group_ids);
     /* Code Added for bug 3982343 End */


END eam_workbench_tree;

 

/
