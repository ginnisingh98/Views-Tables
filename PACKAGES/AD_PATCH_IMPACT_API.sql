--------------------------------------------------------
--  DDL for Package AD_PATCH_IMPACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_PATCH_IMPACT_API" AUTHID CURRENT_USER AS
/* $Header: adpaias.pls 120.3 2006/04/05 03:29:02 msailoz noship $ */

    TYPE t_rec_patch is TABLE of NUMBER(30)
    INDEX BY BINARY_INTEGER;
    TYPE t_prereq_patch is TABLE of NUMBER(30)
    INDEX BY BINARY_INTEGER;

    TYPE t_recomm_patch_rec IS RECORD (
      bug_number      NUMBER,
      baseline        VARCHAR2(150),
      patch_id        NUMBER
    );

    TYPE t_recomm_patch_tab IS TABLE OF t_recomm_patch_rec;

/**
  The Function returns the list of patches recommended in the current request set.
  i.e., this AD API would query the FND Concurrent Request table to get the request
  ID of the currently running Request Set and use this request ID to query the
  AD_PA_ANALYSIS_RUN_BUGS table to get the list of bug numbers recommended.
**/
 PROCEDURE get_recommend_patch_list
 (
     a_rec_patch OUT NOCOPY  t_rec_patch
 )
  ;

/**
  The Function returns the list of patches recommended in the current request set.
  i.e., this AD API would query the FND Concurrent Request table to get the request
  ID of the currently running Request Set and use this request ID to query the
  AD_PA_ANALYSIS_RUN_BUGS table to get the list of bug numbers recommended.
**/
 PROCEDURE get_recommend_patch_list
 (
     p_recomm_patch_tab OUT NOCOPY  t_recomm_patch_tab
 )
  ;


/**
  This API will return to PIA the Global Snapshot ID.
 **/
 PROCEDURE get_global_snapshot_id
 (
    snap_id OUT NOCOPY Number
 )
  ;

/**
 PIA CPs would call this PL/SQL API that returns the list of
  pre-req'ed patches that have not been applied for each recommended patch.
  API input: recommended patch bug number (obtained from the 1st API)
  API output: list of pre-req's of this recommended patch that have not been
  applied to the system.
**/
  PROCEDURE get_prereq_list
  (
    bug_number_val IN Number,
    a_prereq_patch OUT  NOCOPY t_prereq_patch
   )
    ;

/**
  PIA CPs would call this PL/SQL API that returns the list of
  pre-req'ed patches that have not been applied for each recommended patch
  for a particular request set.
  API input: request set id
  API input: recommended patch bug number (obtained from the 1st API)
  API output: list of pre-req's of this recommended patch that have not been
  applied to the system.
  The Function returns 1 in case of error
 **/
  PROCEDURE get_prereq_list
  (
    pRequestId  IN Number,
    pBugNumber     IN Number,
    pPrereqPatches OUT  NOCOPY t_prereq_patch
   )
   ;


END AD_PATCH_IMPACT_API;

 

/
