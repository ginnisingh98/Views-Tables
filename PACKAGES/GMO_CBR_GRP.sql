--------------------------------------------------------
--  DDL for Package GMO_CBR_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_CBR_GRP" AUTHID CURRENT_USER AS
/* $Header: GMOGCBRS.pls 120.2 2006/06/13 22:10:34 srpuri noship $ */

  /**********************************************************************************
   **  This Procedure is to concurrent request to enable control batch recording.
   **
   ** OUT Parameter
   **      Concurrent Program default parameters
   **      RETCODE
   **      ERRBUF
   **
   ***********************************************************************************/

    PROCEDURE ENABLE_CBR (ERRBUF OUT NOCOPY VARCHAR2,RETCODE OUT NOCOPY VARCHAR2);

  /**********************************************************************************
   **  This Procedure is to update batch progression row with event date and new status
   **
   ** IN Parameters:
   **     P_ERECORD_ID               number   -- E-record ID
   **     P_BATCH_PROGRESSION_ID     number   -- Batch Progression ID
   **     P_EVENT_DATE               DATE     -- Event Date
   **     P_STATUS                   VARCHAR2 -- Event Status
   **
   ***********************************************************************************/

    PROCEDURE UPDATE_EVENT (P_ERECORD_ID NUMBER, P_BATCH_PROGRESSION_ID NUMBER,P_EVENT_DATE DATE, P_STATUS VARCHAR2 );

  /**********************************************************************************
   **  This Procedure is to process event in CBR Subscriptions
   **
   ** IN Parameters:
   **     P_SUBSCRIPTION_GUID        Subscription GUID
   **     P_EVENT                    Workflow Event Object
   ***********************************************************************************/

    FUNCTION  PROCESS_EVENT (P_SUBSCRIPTION_GUID IN RAW, P_EVENT IN OUT NOCOPY WF_EVENT_T) RETURN VARCHAR2;

  /**********************************************************************************
   **  This Procedure is to insert new batch progression row
   **
   ** IN Parameters:
   **     P_BATCH_PROG_REC         GMO_BATCH_PROGRESSION Row Type
   **     P_BATCH_PROGRESSION_ID   NUMBER
   ***********************************************************************************/

    PROCEDURE INSERT_EVENT(P_BATCH_PROG_REC GMO_BATCH_PROGRESSION%ROWTYPE, P_BATCH_PROGRESSION_ID OUT NOCOPY NUMBER);

  /**********************************************************************************
   **  This Procedure is to process batch progression rows before CBR XML generation.
   **
   ** IN Parameters:
   **     p_BATCH_ID          number   -- Batch ID
   ***********************************************************************************/

    PROCEDURE CBR_PREPROCESS (P_BATCH_ID IN NUMBER);

  /**********************************************************************************
   **  This Procedure is to insert default batch progression rows when batch is
   **  created.
   ** IN Parameters:
   **     p_BATCH_ID          number   -- Batch ID
   ***********************************************************************************/

    PROCEDURE INSERT_BATH_EVENTS(P_BATCH_ID IN NUMBER);
 /**********************************************************************************
   **  This Procedure is to process Instruction Set event in CBR Subscriptions
   ** IN Parameters:
   **     P_SUBSCRIPTION_GUID        Subscription GUID
   **     P_EVENT                    Workflow Event Object
   ***********************************************************************************/

 FUNCTION PROCESS_INSTANCE_INSTR_SET(P_SUBSCRIPTION_GUID IN RAW, P_EVENT IN OUT NOCOPY WF_EVENT_T) RETURN VARCHAR2;

  /**********************************************************************************
   **  This Procedure is to delete batch progression row
   ** Usage:
   **    1. Send BATCH_PROGRESSION_ID alone deletes progression row with the given
   **                                 Batch Progression Row Identifier
   **    2. You send ERECORD_ID alone deletes progression row with the given ERecord_ID
   **    3. Send Evnet and Evnet Key. Deletes all batch progression rows for the
   **                                 given event and event Key.
   **
   ** NOTE: If Batch Progression id is passed then other parameters will be ignored
   **       If Batch Progression id is null and if ERecordID passed then
   **          Event information will be ignored
   **       If Both Batch Progression id  and E-Record ID are null then Event information
   **       is used for deletion.
   **
   ** IN Parameters:
   **     P_ERECORD_ID               number   -- E-record ID
   **     P_BATCH_PROGRESSION_ID     number   -- Batch Progression ID
   **     P_EVENT                    VARCHAR2 -- Event
   **     P_EVENT_KEY                VARCHAR2 -- Event Key
   ** OUT Parameters:
   **     X_RETURN_STATUS            VARCHAR2 -- Deletion Status
   **     x_msg_count                number
   **     x_msg_data                 varchar2
   ***********************************************************************************/

    PROCEDURE DELETE_PROGRESSION_ROW (P_BATCH_PROGRESSION_ID   NUMBER DEFAULT Null,
                                      P_ERECORD_ID             NUMBER DEFAULT Null,
                                      P_EVENT                  VARCHAR2 DEFAULT Null,
                                      P_EVENT_KEY              VARCHAR2 DEFAULT Null,
                                      X_RETURN_STATUS        OUT NOCOPY VARCHAR2,
                                      X_MSG_COUNT            OUT NOCOPY NUMBER,
                                      X_MSG_DATA             OUT NOCOPY VARCHAR2);





END GMO_CBR_GRP;

 

/
