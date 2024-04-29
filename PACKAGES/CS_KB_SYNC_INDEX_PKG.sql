--------------------------------------------------------
--  DDL for Package CS_KB_SYNC_INDEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_SYNC_INDEX_PKG" AUTHID CURRENT_USER AS
/* $Header: csksyncs.pls 120.1.12010000.2 2009/07/20 13:38:18 gasankar ship $ */

  /*
   * Populate_Soln_Content_Cache
   *  Populate a solution's content cache, for a given
   *  language, with the cacheable synthesized text content
   */
  PROCEDURE Populate_Soln_Content_Cache
  ( p_solution_id in number, p_lang in varchar2 );

  /*
   * Populate_Soln_Content_Cache
   *  Populate a solution's content cache, for all installed
   *  languages, with the cacheable synthesized text content
   */
  PROCEDURE Populate_Soln_Content_Cache( p_solution_id in number );

--Start 12.1.3
  /*
   * Populate_Soln_Attach_Content_Cache
   *  Populate a solution's attachment content cache, for a given
   *  language, with the cacheable synthesized text content
   */
  PROCEDURE Pop_Soln_Attach_Content_Cache
  ( p_solution_id in number, p_lang in varchar2 );

  /*
   * Populate_Soln_Attach_Content_Cache
   *  Populate a solution's attachment content cache, for all installed
   *  languages, with the cacheable synthesized text content
   */
  PROCEDURE Pop_Soln_Attach_Content_Cache( p_solution_id in number );
--End 12.1.3


  /*
   * Request_Sync_Index
   *  This procedure submits a concurrent request
   *  to sync KM indexes.
   */
  PROCEDURE Request_Sync_KM_Indexes
  ( x_request_id    OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2 );

  /*
   * Request_Mark_Idx_on_Sec_Change
   *  This procedure submits a concurrent request
   *  to mark the solution and statement text indexes when
   *  KM security setup changes.
   *
   *  Parameters:
   *  1) SECURITY_CHANGE_ACTION_TYPE
   *     Valid values:
   *      ADD_VIS              - Add Visibility Level
   *      REM_VIS              - Remove Visibility Level
   *      CHANGE_CAT_VIS       - Change Category Visibility
   *      ADD_CAT_TO_CAT_GRP   - Add Category to Category Group
   *      REM_CAT_FROM_CAT_GRP - Remove Category from Category Group
   *  2) For each action type, the parameter values required are as follows:
   *      ADD_VIS
   *        PARAMETER1 - visibility position of the added visibility
   *      REM_VIS
   *        PARAMETER1 - visibility position of the removed visibility
   *      CHANGE_CAT_VIS
   *        PARAMETER1 - category id for which the visibility changed
   *        PARAMETER2 - the original visibility id for the category
   *      ADD_CAT_TO_CAT_GRP
   *        PARAMETER1 - category group id to which the category was added.
   *        PARAMETER2 - category id which was added to the category group.
   *      REM_CAT_FROM_CAT_GRP
   *        PARAMETER1 - category group id from which the category was removed.
   *        PARAMETER2 - category id which was removed from the category group.
   */
  PROCEDURE Request_Mark_Idx_on_Sec_Change
  ( p_security_change_action_type IN VARCHAR2,
    p_parameter1                  IN NUMBER default null,
    p_parameter2                  IN NUMBER default null,
    x_request_id                  OUT NOCOPY NUMBER,
    x_return_status               OUT NOCOPY VARCHAR2 );

  /*
   * Mark_Idxs_on_Pub_Soln
   *  Mark all appropriate text indexes after a solution is
   *  published.
   */
  PROCEDURE Mark_Idxs_on_Pub_Soln( p_solution_number varchar2 );

  /*
   * Mark_Idxs_on_Obs_Soln
   *  Mark all appropriate text indexes after a solution is
   *  obsoleted.
   */
  PROCEDURE Mark_Idxs_on_Obs_Soln( p_solution_number varchar2 );

  /*
   * Mark_Idxs_on_Global_Stmt_Upd
   *  Mark all appropriate text indexes after a global statement
   *  update is performed.
   */
  PROCEDURE Mark_Idxs_on_Global_Stmt_Upd( p_statement_id number );

  -- Add Visibility Level - ADD_VIS
  /*
   * Mark_Idx_on_Add_Vis
   *  Mark Solution and Statement text indexes when a new visibility
   *  level is added.
   */
  PROCEDURE Mark_Idx_on_Add_Vis( p_added_vis_pos number );

  /*
   * Mark_Idx_on_Rem_Vis
   *  Mark Solution and Statement text indexes when a visibility is
   *  removed.
   */
  PROCEDURE Mark_Idx_on_Rem_Vis( p_removed_vis_pos number );

  /*
   * Mark_Idx_on_Change_Cat_Vis
   *  Mark Solution and Statement text indexes when a Solution Category's
   *  visibility level changes.
   */
  PROCEDURE Mark_Idx_on_Change_Cat_Vis( p_cat_id number, p_orig_vis_id number );

  /*
   * Mark_Idx_on_Add_Cat_To_Cat_Grp
   *  Mark Solution and Statement text indexes when a Category is
   *  added to a Category Group.
   */
  PROCEDURE Mark_Idx_on_Add_Cat_To_Cat_Grp( p_cat_grp_id number, p_cat_id number );

  /*
   * Mark_Idx_on_Rem_Cat_fr_Cat_Grp
   *  Mark Solution and Statement text indexes when a Category is
   *  removed from a Category Group.
   */
  PROCEDURE Mark_Idx_on_Rem_Cat_fr_Cat_Grp( p_cat_grp_id number, p_cat_id number );

  /*
   * Mark_Idx_on_Change_Parent_Cat
   *  Mark Solution and Statement text indexes when a Solution Category's
   *  visibility level changes.
   */
  PROCEDURE Mark_Idx_on_Change_Parent_Cat( p_cat_id number, p_orig_parent_cat_id number );

  /*
   * Mark_Idxs_For_Multi_Soln
   *  Mark Solution and Statement text indexes for multiple solutions.
   */
  PROCEDURE Mark_Idxs_For_Multi_Soln( p_set_ids JTF_NUMBER_TABLE );


  /*
   * Request_Sync_Set_Index
   *  This procedure submits a concurrent request
   *  to sync KM set index.
   */
  PROCEDURE Request_Sync_Set_Index
  ( x_request_id    OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2 );

  /*
   * Request_Sync_Element_Index
   *  This procedure submits a concurrent request
   *  to sync KM element index.
   */
  PROCEDURE Request_Sync_Element_Index
  ( x_request_id    OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2 );

end CS_KB_SYNC_INDEX_PKG;

/
