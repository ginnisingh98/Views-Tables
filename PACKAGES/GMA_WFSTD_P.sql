--------------------------------------------------------
--  DDL for Package GMA_WFSTD_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_WFSTD_P" AUTHID CURRENT_USER AS
/* $Header: GMAWFSTS.pls 115.5 2002/11/01 21:19:03 appldev ship $ */
/* Procedure to get the role. Input parameters are
 Wokflow type, Process type and Activity_type */
   PROCEDURE get_role (

      p_wf_item_type     IN varchar2,
      p_process_name     IN varchar2,
      p_activity_name    IN varchar2,
      p_datastring       IN VARCHAR2,
      P_role             OUT NOCOPY VARCHAR2
                );
   FUNCTION check_process_approval_req(p_wf_item_type  VARCHAR2,
                                       p_Process_name  VARCHAR2,
                                       p_datastring    VARCHAR2) RETURN VARCHAR2;
   FUNCTION check_activity_approval_req(p_wf_item_type  VARCHAR2,
                                        p_Process_name  VARCHAR2,
                                        p_activity_name    IN varchar2,
                                        p_datastring    VARCHAR2) RETURN VARCHAR2;
   FUNCTION check_process_enabled(p_wf_item_type  VARCHAR2,
                                  p_Process_name  VARCHAR2) RETURN BOOLEAN;
  PROCEDURE WF_GET_CONTORL_PARAMS(P_WF_ITEM_TYPE  IN VARCHAR2,
                                  P_PROCESS_NAME  IN VARCHAR2,
                                  P_ACTIVITY_NAME IN VARCHAR2,
                                  P_TABLE_NAME    IN VARCHAR2,
                                  P_WHERE_CLAUSE  IN VARCHAR2,
                                  P_DATASTRING   OUT NOCOPY VARCHAR2,
                                  P_WFSTRING     OUT NOCOPY VARCHAR2) ;

END gma_wfstd_p;

 

/
