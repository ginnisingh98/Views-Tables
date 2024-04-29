--------------------------------------------------------
--  DDL for Package CLN_PO_CHANGE_RESPONSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_PO_CHANGE_RESPONSE_PKG" AUTHID CURRENT_USER AS
/* $Header: CLNPOCHS.pls 115.3 2004/04/08 16:25:03 kkram noship $ */

--  Package
--      CLN_RESPONSE_POCHANGE_PKG
--
--  Purpose
--      Specs of package CLN_RESPONSE_POCHANGE_PKG.
--
--  History
--      June-17-2003  Rahul Krishan         Created

--  Global variable holding the current change_request_group_id

    g_change_request_group_id   NUMBER := 0;


   -- Name
   --   SETATTRIBUTES
   -- Purpose
   --   The main purpose ofthis API is to set different attributes based
   --   on the change request group id passed to it through workflow.
   -- Arguments
   --
   -- Notes
   --   No specific notes.

   PROCEDURE SET_ATTRIBUTES_OF_WORKFLOW(
        p_itemtype                        IN VARCHAR2,
        p_itemkey                         IN VARCHAR2,
        p_actid                           IN NUMBER,
        p_funcmode                        IN VARCHAR2,
        x_resultout                       IN OUT NOCOPY VARCHAR2 );


 -- Function
 --   GET_CHANGE_REQUEST_ID
 -- Description
 --   Returns the value of Change Request Group ID which can be used in view at runtime.
 -- Return Value
 --   Returns the value of Change Request Group ID.


 FUNCTION GET_CHANGE_REQUEST_GROUP_ID RETURN NUMBER;


  -- Name
  --   SET_REQUEST_GRP_ID_AND_COLL_ID
  -- Description
  --   Sets the value of Change Request Group ID which can be used in view at runtime.
  -- Return Value
  --

  PROCEDURE SET_REQUEST_GRP_ID_AND_COLL_ID(
        p_itemtype                      IN VARCHAR2,
        p_itemkey                       IN VARCHAR2,
        p_actid                         IN NUMBER,
        p_funcmode                      IN VARCHAR2,
        x_resultout                     IN OUT NOCOPY VARCHAR2 );


  -- Name
  --   SET_ACKCODE_CONDITIONALLY
  -- Description
  --   return. x_ackcode based on the two reasons passed
  -- Return Value
  --
  PROCEDURE CALC_ACKCODE_CONDITIONALLY(
        p_reason                        IN VARCHAR2,
        p_cons_reason                   IN VARCHAR2,
        x_ackcode                       IN OUT NOCOPY VARCHAR2 );


  -- Name
  --   GET_ADDITIONAL_DATA
  -- Description
  --   This procedure should be used to obtain data
  --   that is otherwise not possible to get from element mapping
  --   in a XML Gateway message map
  -- Return
  --   x_data1: Supplier Document Reference
  --   x_data2: For future use
  --   x_data3: For future use
  --   x_data4: For future use
  --   x_data5: For future use

  PROCEDURE GET_ADDITIONAL_DATA(
        P_CHANGE_REQUEST_GROUP_ID       IN VARCHAR2,
        X_DATA1                         IN OUT NOCOPY VARCHAR2,
        X_DATA2                         IN OUT NOCOPY VARCHAR2,
        X_DATA3                         IN OUT NOCOPY VARCHAR2,
        X_DATA4                         IN OUT NOCOPY VARCHAR2,
        X_DATA5                         IN OUT NOCOPY VARCHAR2);


END CLN_PO_CHANGE_RESPONSE_PKG;

 

/
