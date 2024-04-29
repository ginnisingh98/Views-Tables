--------------------------------------------------------
--  DDL for Package PO_DOC_MANAGER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOC_MANAGER_PUB" AUTHID CURRENT_USER as
/* $Header: POXWAPIS.pls 115.4 2002/11/23 01:20:22 sbull ship $ */

/*===========================================================================
  PACKAGE NAME:		PO_DOC_MANAGER_PUB

  DESCRIPTION:          Contains the record type to be used for calls
                        between the workflow engine and the doc manager.
                        Defines the procedure that will call the doc manager


  CLIENT/SERVER:	Server

  LIBRARY NAME          NONE

  OWNER:                Raj Bhakta

  PROCEDURES/FUNCTIONS:	CALL_DOC_MANAGER

============================================================================*/

 -- Defining the record type to be used
 -- The definitions of what each component of the record
 -- does is in POXDORAS.pls

 TYPE DM_CALL_REC_TYPE IS RECORD
 (
    Action                         VARCHAR2(60),
    Document_Type                  VARCHAR2(25),
    Document_Subtype               VARCHAR2(25),
    Document_Id                    NUMBER,
    Line_Id                        NUMBER,
    Shipment_Id                    NUMBER,
    Distribution_Id                NUMBER,
    Employee_id                    NUMBER  ,
    New_Document_Status            VARCHAR2(25),
    Offline_Code                   VARCHAR2(1),
--<UTF-8 FPI START>
    --Note                           VARCHAR2(480),
Note  				   PO_ACTION_HISTORY.NOTE%TYPE,
--<UTF-8 FPI END>
    Approval_Path_Id               NUMBER,
    Forward_To_Id                  NUMBER,
    Action_date                    Date,
    Override_funds                 VARCHAR2(1),
    Info_Request                   VARCHAR2(25),
    Document_Status                VARCHAR2(240),
    Online_Report_Id               NUMBER,
    Return_Code                    VARCHAR2(25),
    Error_Msg                      VARCHAR2(2000),
    Return_Value                   NUMBER);

/*===========================================================================
  PROCEDURE NAME:	CALL_DOC_MANAGER()

  DESCRIPTION:          Accepts a record as input and calls
                        po_document_actions_sv.po_request_action which in turn
                        calls the Document Manager using dbms_pipe

  PARAMETERS:           X_DM_CALL_REC IN OUT PO_DOC_MANAGER_PUB.DM_CALL_REC_TYPE

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Raj Bhakta   06/18/97     Created
===========================================================================*/

 PROCEDURE CALL_DOC_MANAGER(X_DM_CALL_REC IN OUT NOCOPY PO_DOC_MANAGER_PUB.DM_CALL_REC_TYPE);

 END PO_DOC_MANAGER_PUB;


 

/
