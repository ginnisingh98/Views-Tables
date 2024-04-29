--------------------------------------------------------
--  DDL for Package CS_KB_CONC_PROG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_CONC_PROG_PKG" AUTHID CURRENT_USER AS
/* $Header: csksynis.pls 120.0.12010000.2 2009/07/20 13:38:41 gasankar ship $ */

  SUCCESS NUMBER := 0;
  WARNING NUMBER := 1;
  ERROR   NUMBER := 2;

  PROCEDURE Sync_All_Index (ERRBUF OUT NOCOPY VARCHAR2,
                            RETCODE OUT NOCOPY NUMBER,
                            BMODE IN VARCHAR2 default null);

  PROCEDURE Sync_Element_Index  (ERRBUF OUT NOCOPY VARCHAR2,
                                 RETCODE OUT NOCOPY NUMBER,
                                 BMODE IN VARCHAR2,
                                 pworker  IN NUMBER DEFAULT 0);
  PROCEDURE Sync_Set_Index  (ERRBUF OUT NOCOPY VARCHAR2,
                             RETCODE OUT NOCOPY NUMBER,
                             BMODE IN VARCHAR2,
                             pworker  IN NUMBER DEFAULT 0,
			     attachment IN VARCHAR2);

  PROCEDURE Sync_Forum_Index  (ERRBUF OUT NOCOPY VARCHAR2,
                               RETCODE OUT NOCOPY NUMBER,
                               BMODE IN VARCHAR2,
                               pworker  IN NUMBER DEFAULT 0);

  PROCEDURE Sync_Soln_Cat_Index  (ERRBUF OUT NOCOPY VARCHAR2,
                                  RETCODE OUT NOCOPY NUMBER,
                                  BMODE IN VARCHAR2,
                                  pworker  IN NUMBER DEFAULT 0);

 PROCEDURE Sync_index(  index1   IN VARCHAR2,
                        bmode    IN VARCHAR2,
                        pworker  IN NUMBER DEFAULT 0);

  procedure del_sync_prog;

  procedure update_set_count_sum (ERRBUF OUT NOCOPY VARCHAR2,
                                  RETCODE OUT NOCOPY NUMBER);

  -- klou, (SRCHEFF), since 11.5.10
  PROCEDURE Update_Magic_Word;

  PROCEDURE Update_Usage_Score (ERRBUF OUT NOCOPY VARCHAR2,
                                 RETCODE OUT NOCOPY NUMBER);
  -- End (SRCHEFF)

  /*
   * Rebuild_Soln_Content_Cache
   *  Repopulate the solution content cache column for all published
   *  solutions. Content cache entries will be commited in batches.
   */
  PROCEDURE Rebuild_Soln_Content_Cache
  ( errbuf out nocopy varchar2,
    retcode out nocopy number );


  /*
   * Mark_Idx_on_Sec_Change
   *  Mark text index columns (solutions and statements) when KM
   *  security setup changes. Marking the text columns is done off-line
   *  in a concurrent program to give better UI response time.
   *  The way the program works is by passing in a security change
   *  action type code. For each action type, there is a list of
   *  parameters that get passed through parameter1-2.
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
  PROCEDURE Mark_Idx_on_Sec_Change
  ( ERRBUF                       OUT NOCOPY VARCHAR2,
    RETCODE                      OUT NOCOPY NUMBER,
    SECURITY_CHANGE_ACTION_TYPE  IN         VARCHAR2   default null,
    PARAMETER1                   IN         NUMBER     default null,
    PARAMETER2                   IN         NUMBER     default null );


  /*
   *  get_max_parallel_worker: get THE job_queue_processes value.
   */
  FUNCTION get_max_parallel_worker RETURN NUMBER;

  /*
   *  is_validate_mode: VALIDATE a synchronization MODE.
   *  RETURN 'Y' IF THE MODE IS valid. Otherwise RETURN 'N'.
   */
  FUNCTION is_validate_mode(bmode IN VARCHAR2) RETURN VARCHAR;

  /*
   * Create_Set_Index
   *   This PROCEDURE creates THE solution INDEX AND also populates THE INDEX
   *   content.
   */
  PROCEDURE Create_Set_Index
  (  pworker IN NUMBER DEFAULT  0,
     x_msg_error     OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
  );


  /*
   * Create_Element_Index
   *   This PROCEDURE creates the statement INDEX AND also populates THE INDEX
   *   content.
   */
  PROCEDURE Create_Element_Index
  (  pworker IN NUMBER DEFAULT  0,
     x_msg_error     OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
  );

  /*
   * Create_Soln_Cat_Index
   *   This PROCEDURE creates the category INDEX AND also populates THE INDEX
   *   content.
   */
  PROCEDURE Create_Soln_Cat_Index
  (  pworker IN NUMBER DEFAULT  0,
     x_msg_error     OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
  );


  /*
   * Create_Forum_Index
   *   This PROCEDURE creates the forum INDEX AND also populates THE INDEX
   *   content.
   */
  PROCEDURE Create_Forum_Index
  (  pworker IN NUMBER DEFAULT  0,
     x_msg_error     OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
  );

  PROCEDURE Drop_Index
  ( p_index_name IN VARCHAR,
    x_msg_error     OUT NOCOPY VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2
  );

end CS_KB_CONC_PROG_PKG;

/
