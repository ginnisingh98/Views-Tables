--------------------------------------------------------
--  DDL for Package ZPB_AW_WRITE_BACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_AW_WRITE_BACK" AUTHID CURRENT_USER AS
/* $Header: zpbwriteback.pls 120.7 2007/12/04 16:24:33 mbhat ship $ */

   PENDING CONSTANT VARCHAR2(7) := 'PENDING';
   FAILED CONSTANT VARCHAR2(6) := 'FAILED';
   COMPLETED CONSTANT VARCHAR2(9) := 'COMPLETED';
   RESET CONSTANT VARCHAR2(5) := 'RESET';
   UMAINT CONSTANT VARCHAR2(2) := 'UM';

   PROCEDURE submit_writeback_request ( P_BUSINESS_AREA_ID IN NUMBER,
                                        P_USER_ID IN NUMBER,
                                        P_RESP_ID IN NUMBER,
                                        P_SESSION_ID IN NUMBER,
                                        P_TASK_TYPE IN VARCHAR2,
                                        P_SPL IN VARCHAR2,
                                        P_START_TIME IN DATE,
                                        P_OUTVAL OUT NOCOPY Number);

   PROCEDURE process_cleanup ( ERRBUF OUT NOCOPY VARCHAR2,
                               RETCODE OUT NOCOPY VARCHAR2,
                               P_TASK_SEQ IN NUMBER,
                               P_BUSINESS_AREA_ID IN NUMBER);

   PROCEDURE process_dvac_writeback ( ERRBUF OUT NOCOPY VARCHAR2,
                                      RETCODE OUT NOCOPY VARCHAR2,
                                      P_TASK_SEQ IN NUMBER,
                                      P_BUSINESS_AREA_ID IN NUMBER);

   -- Added P_CONC_REQUEST_ID for Bug: 5475982
   PROCEDURE process_scoping_admin_tasks ( ERRBUF OUT NOCOPY VARCHAR2,
                                           RETCODE OUT NOCOPY VARCHAR2,
                                           P_TASK_SEQ IN NUMBER,
                                           P_CONC_REQUEST_ID IN NUMBER DEFAULT NULL,
                                           P_BUSINESS_AREA_ID IN NUMBER);

   PROCEDURE reapply_all_scopes ( ERRBUF OUT NOCOPY VARCHAR2,
                                  RETCODE OUT NOCOPY VARCHAR2,
                                  P_BUSINESS_AREA IN NUMBER);

   PROCEDURE process_spl ( ERRBUF     OUT NOCOPY VARCHAR2,
                           RETCODE    OUT NOCOPY VARCHAR2,
                           P_TASK_SEQ IN NUMBER,
                           P_BUSINESS_AREA_ID IN NUMBER);

   PROCEDURE process_create_pers_aw_daemon (errbuf         OUT NOCOPY VARCHAR2,
                                            retcode        OUT NOCOPY VARCHAR2,
                                            p_task_seq     IN NUMBER);

   PROCEDURE process_create_personal_aw ( ERRBUF     OUT NOCOPY VARCHAR2,
                                          RETCODE    OUT NOCOPY VARCHAR2,
                                          P_USER_ID  IN NUMBER,
                                          P_BUSINESS_AREA_ID IN NUMBER);

   -- Added for Bug:5475982
   PROCEDURE bulk_writeback(p_business_area_id IN NUMBER,
                            p_root_request_id  IN NUMBER,
                            p_child_request_id OUT NOCOPY NUMBER);

END ZPB_AW_WRITE_BACK;


/
