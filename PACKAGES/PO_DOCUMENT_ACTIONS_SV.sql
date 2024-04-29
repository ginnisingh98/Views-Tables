--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_ACTIONS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_ACTIONS_SV" AUTHID CURRENT_USER AS
/* $Header: POXDORAS.pls 120.0 2005/06/01 14:12:21 appldev noship $*/

-- <HTMLAC BEGIN>
-- Start of comments
--	API name : po_request_action_bulk
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: Calls po_request_action for each line that needs
--			      to have an action requsted.
--	Parameters	:
--	IN		:	p_api_version           	   IN NUMBER	Required
--          p_reason                      IN varchar2 Required
--            The reason needed to return this document if any
--          p_employee_id                 IN NUMBER Required
--            The employee_id to whom we will send a notification.
--          p_grouping_method             IN varchar2 Required
--            The req grouping selected from the UI
--          p_req_header_id_tbl           IN PO_TBL_NUMBER Required
--            The table containing the req_header_id column.
-- OUT   :  x_result                     OUT NUMBER
--          x_error_message              OUT VARCHAR2
--          x_online_report_id_tbl       OUT PO_TBL_NUMBER
--            The online report ids that have been generated.
--          x_req_header_id_succ_tbl     OUT PO_TBL_NUMBER
--            Contains all the header_ids of the successful reqs.
--	Version	: Current version	1.0
--			     Previous version 	1.0
--			     Initial version 	1.0
-- End of comments
PROCEDURE po_request_action_bulk (
   p_api_version             IN NUMBER,
   x_result                 OUT NOCOPY NUMBER,
   x_error_message          OUT NOCOPY VARCHAR2,
   p_reason                  IN VARCHAR2 := NULL,
   p_employee_id             IN NUMBER,
   p_req_header_id_tbl       IN PO_TBL_NUMBER,
   x_online_report_id_tbl   OUT NOCOPY PO_TBL_NUMBER,
   x_req_header_id_succ_tbl OUT NOCOPY PO_TBL_NUMBER
);
-- <HTMLAC END>

/*===========================================================================
  FUNCTION NAME:	PO_REQUEST_ACTION

  DESCRIPTION:

  Main document action interface for interacting with the Document
  Action Manager.  The Document Action Manager is a server side Transaction
  Manager that sits on the server and awaits requests for processing from the
  client.   The execution of the program will happen  on  the
  server  transparent  to the client and with minimal time de-
  lay.  At the end of program execution, the  client  will  be
  notified  of  the  outcome  and a completion message will be
  given along with a set of return values.  We pass information back
  and forth across the pipe.  When we make a request we send information
  about the action we wish to take and the document we wish to take action
  upon and we get back the results of that request.  To get the various
  return parameters from the request we use
  fnd_transaction.get_values ().  We then parse the arguments that returned
  through this mechanism and return them to the user through arguments to
  this function.


  PARAMETERS:

     Action              VARCHAR2(25)    IN    (Required)
      - Action would you like to take APPROVE, APPROVE AND RESERVE,
        SUBMISSION_CHECK, etc.

     Document_Type       VARCHAR2(25)    IN    (Required)
      - Type of document are you trying to take the action on PO, REQ

     Document_Subtype    VARCHAR2(25)    IN    (Required)
      - Subtype of the doument you are trying to take the action
        on STANDARD, PLANNED, BLANKET

     Document_Id         NUMBER          IN    (Required)
      - Primary key for the document header

     Line_Id             NUMBER          IN    (Optional)
      - Primary key for the document line

     Shipment_Id         NUMBER          IN    (Optional)
      - Primary key for the document shipment

     Distribution_Id     NUMBER          IN    (Optional)
      - Primary key for the document distribtion

     Employee_Id         NUMBER          IN    (Required for Approvals)
      - Primary key for the employee that is performing the action

     New_Document_Status VARCHAR2(30)    IN    (Required for Approvals)
      - New status for the documnt forward_document action
        (IN-PROCESS, PRE-APPROVED)

     Offline_Code        VARCHAR2(1)     IN    (Required for Approvals)
      - Is the Approver and Offline approver

     Note                VARCHAR2(480)   IN    (Optional)
      - Note to send to person document is being submitted to
        < UTF8 FPI - changed from Note VARCHAR2(240) >

     Approval_Path_Id    NUMBER          IN    (Optional)
      - Primary key for the Approval path for this document

     Forward_To_Id       NUMBER          IN    (Optional)
      - Id for the person you are forwarding the document to

     Action_Date         DATE		 IN    (Optional)
     - The date that you would like to apply for encumbrance transactions

     Override_Funds      VARCHAR2(1)	IN     (Optional)
     - If there are no more funds available do you wish to override the
       funds checker return code

     Info_Request        VARCHAR2(25)    OUT
      - Information about your request

     Document_Status     VARCHAR2(240)   OUT
      - The status of the document that you've taken the action on
        APPROVED, INCOMPLETE, RESERVED

     Online_Report_Id    NUMBER          OUT
      - The primary key for the report lines if the document failed the request

     Return_Code         VARCHAR2(25)    OUT
      - The return code from the request that you've submitted

     Error_Msg         VARCHAR2(2000)    OUT
      - The error msg that you should put in a dialog and if the
       return value = 1,2,3

     --<CANCEL API FPI START>

     p_extra_arg1          IN VARCHAR2 DEFAULT NULL  (Optional)
     p_extra_arg2          IN VARCHAR2 DEFAULT NULL  (Optional)
     p_extra_arg3          IN VARCHAR2 DEFAULT NULL  (Optional)
      - Any extra arguments needed to pass to the Document Manager. These must
        be in the format expected by the Document Manager: 'NAME=VALUE'.

     --<CANCEL API FPI END>

     -- <ENCUMBRANCE FPJ START>
     p_extra_args4         IN VARCHAR2 DEFAULT NULL   (Optional)
      - Any extra arguments needed to pass to the Document Manager. These must
        be in the format expected by the Document Manager: 'NAME=VALUE'.
     -- <ENCUMBRANCE FPJ END>

  RETURN VALUES

     E_SUCCESS constant number    := 0;           -- success
     E_TIMEOUT constant number    := 1;           -- timeout
     E_NOMGR   constant number    := 2;           -- no manager
     E_OTHER   constant number    := 3;           -- other

  DESIGN REFERENCES:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

===========================================================================*/
FUNCTION PO_REQUEST_ACTION  (
    Action              IN  VARCHAR2,
    Document_Type       IN  VARCHAR2,
    Document_Subtype    IN  VARCHAR2,
    Document_Id         IN  NUMBER,
    Line_Id             IN  NUMBER,
    Shipment_Id         IN  NUMBER,
    Distribution_Id     IN  NUMBER,
    Employee_id         IN  NUMBER,
    New_Document_Status IN  VARCHAR2,
    Offline_Code        IN  VARCHAR2,
    Note                IN  VARCHAR2,
    Approval_Path_Id    IN  NUMBER,
    Forward_To_Id       IN  NUMBER,
    Action_Date         IN  DATE,
    Override_Funds      IN  VARCHAR2,
    Info_Request        OUT NOCOPY VARCHAR2,
    Document_Status     OUT NOCOPY VARCHAR2,
    Online_Report_Id    OUT NOCOPY NUMBER,
    Return_Code         OUT NOCOPY VARCHAR2,
    Error_Msg           OUT NOCOPY VARCHAR2,
    --<CANCEL API FPI START>
    p_extra_arg1        IN  VARCHAR2 DEFAULT NULL,
    p_extra_arg2        IN  VARCHAR2 DEFAULT NULL,
    p_extra_arg3        IN  VARCHAR2 DEFAULT NULL,
    --<CANCEL API FPI END>
    p_extra_arg4        IN  VARCHAR2 DEFAULT NULL  -- <ENCUMBRANCE FPJ>
   )
  RETURN NUMBER;

/*===========================================================================
  FUNCTION NAME:	PO_HOLD_DOCUMENT

  DESCRIPTION:



  PARAMETERS:

     PO_Header_Id         NUMBER          IN    (Required)
      - Primary key for the Purchase Order Header

     PO_Release_Id         NUMBER          IN    (Optional)
      - Primary key for the individual Purchase Order Release

     Error_Msg         VARCHAR2(2000)    OUT
      - The error msg that you should put in a dialog and if the
       return value = 1,2,3

  RETURN VALUES

     E_SUCCESS constant number    := 0;           -- success
     E_TIMEOUT constant number    := 1;           -- timeout
     E_NOMGR   constant number    := 2;           -- no manager
     E_OTHER   constant number    := 3;           -- other

  DESIGN REFERENCES:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

===========================================================================*/
FUNCTION PO_HOLD_DOCUMENT (
Po_Header_Id          IN              NUMBER  ,
Po_Release_Id         IN              NUMBER ,
Error_Msg             OUT NOCOPY             VARCHAR2) RETURN NUMBER;

END PO_DOCUMENT_ACTIONS_SV;

 

/
