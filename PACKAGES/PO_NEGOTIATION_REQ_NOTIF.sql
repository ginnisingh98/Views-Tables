--------------------------------------------------------
--  DDL for Package PO_NEGOTIATION_REQ_NOTIF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_NEGOTIATION_REQ_NOTIF" AUTHID CURRENT_USER AS
/* $Header: POXNEG2S.pls 115.5 2004/02/26 18:00:07 zxzhang ship $*/

/*============================================================================
     Name: Req_Change_workflow_startup
     DESC: notifications to sourcing professional when req details are changed
           or cancelled
==============================================================================*/

PROCEDURE req_change_workflow_startup(x_calling_program      IN VARCHAR2,
                                   x_negotiation_id       IN NUMBER  ,
                                   x_negotiation_num      IN VARCHAR2  ,
                                   x_requisition_doc_id   IN NUMBER,
                                   x_process_id           IN NUMBER DEFAULT NULL);


/*============================================================================
     Name: Start_wf_process
     DESC: notifications to sourcing professional when req details are changed
           or cancelled   procedure to start the wf
==============================================================================*/

PROCEDURE Start_WF_Process ( ItemType   IN VARCHAR2,
                     ItemKey            IN VARCHAR2,
                     WorkflowProcess    IN VARCHAR2,
                     Source             IN VARCHAR2,
                     DocumentId         IN NUMBER,
                     NegotiationNum IN  VARCHAR2,
                     OwnerName          IN VARCHAR2,
                     ProcessId         IN NUMBER);

/*============================================================================
   Procedure to build the message body
  input parameters :
    - document id
    - display type taken from workflow preferences
  output
    - the plsql document containing the message body
    - the type of the message attribute
==============================================================================*/
PROCEDURE get_req_line_details(document_id	in	varchar2,
				 display_type	in 	Varchar2,
                                 document	in out	NOCOPY clob,
				 document_type	in out NOCOPY  varchar2);

-- Bug 3346038, Should use PLSQLCLOB
/*============================================================================
   Procedure to build the message body when called from MRP reschedule
  input parameters :
    - document id
    - display type taken from workflow preferences
  output
    - the plsql document containing the message body
    - the type of the message attribute
==============================================================================*/
PROCEDURE get_req_line_details_mrp_wd(document_id	in	varchar2,
				 display_type	in 	Varchar2,
                                 document	in out	NOCOPY clob,
				 document_type	in out NOCOPY  varchar2);

/*============================================================================
   Procedure to build the message body when called from MRP reschedule
    input : wf item type,item key and the document id
==============================================================================*/
PROCEDURE set_req_line_details_mrp_wd(itemtype	in	varchar2,
			       itemkey in 	varchar2,
                               x_document	in out	NOCOPY varchar2) ;


/*============================================================================
  Wrapper to group the requisition lines by negotiation and call the WF
  input parameters : control level - the place this wf is called from
                     document id :  id corresponding to the level
                                    (line/header/process id)
==============================================================================*/
PROCEDURE call_negotiation_wf(x_control_level  IN VARCHAR2,
                              x_document_id    IN NUMBER);

/*============================================================================
   Procedure tocheck where the wf is being called from so as to decide
   the correct notification to be sent
    input : wf item type,item key
    output : source
==============================================================================*/
procedure Check_Source(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) ;


END po_negotiation_req_notif;


 

/
