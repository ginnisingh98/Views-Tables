--------------------------------------------------------
--  DDL for Package PO_WF_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_WF_DEBUG_PKG" AUTHID CURRENT_USER as
/* $Header: POXWDBGS.pls 120.1.12000000.1 2007/03/27 22:05:20 dedelgad noship $*/

/***************************************************************************************
*
* THis package is used to track the progress of all the functions in the workflow as
* they are invoked by the workflow process. It captures the following:
* - the Process Name
* - the unique ID of the Item going through the process
* - the Package.procedure name being executed
* - the progress within that Package.procedure
*
***************************************************************************************/


  procedure insert_debug (itemtype varchar2,
                          itemkey  varchar2,
                          x_progress  varchar2);

  -- <PO OTM Integration FPJ>: Added BPEL debug procedures, since FND
  -- logging does not currently support logging without an APPS context,
  -- which is how calls from BPEL processes are executed.
 PROCEDURE debug_stmt(
     p_log_head                       IN             VARCHAR2
  ,  p_token                          IN             VARCHAR2
  ,  p_message                        IN             VARCHAR2
  );

  PROCEDURE debug_begin(
     p_log_head                       IN             VARCHAR2
  );

  PROCEDURE debug_end(
     p_log_head                       IN             VARCHAR2
  );

  PROCEDURE debug_var(
     p_log_head                       IN             VARCHAR2
  ,  p_progress                       IN             VARCHAR2
  ,  p_name                           IN             VARCHAR2
  ,  p_value                          IN             VARCHAR2
  );

  PROCEDURE debug_var(
     p_log_head                       IN             VARCHAR2
  ,  p_progress                       IN             VARCHAR2
  ,  p_name                           IN             VARCHAR2
  ,  p_value                          IN             NUMBER
  );

  PROCEDURE debug_var(
     p_log_head                       IN             VARCHAR2
  ,  p_progress                       IN             VARCHAR2
  ,  p_name                           IN             VARCHAR2
  ,  p_value                          IN             DATE
  );

  PROCEDURE debug_var(
     p_log_head                       IN             VARCHAR2
  ,  p_progress                       IN             VARCHAR2
  ,  p_name                           IN             VARCHAR2
  ,  p_value                          IN             BOOLEAN
  );

  PROCEDURE debug_unexp(
     p_log_head                       IN             VARCHAR2
  ,  p_progress                       IN             VARCHAR2
  ,  p_message                        IN             VARCHAR2
        DEFAULT NULL
  );

END PO_WF_DEBUG_PKG;


 

/
