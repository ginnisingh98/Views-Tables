--------------------------------------------------------
--  DDL for Package PO_REQAPPROVAL_INIT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQAPPROVAL_INIT1" AUTHID CURRENT_USER AS
/* $Header: POXWPA1S.pls 120.13.12010000.13 2014/12/18 11:36:12 linlilin ship $ */

 /*=======================================================================+
 | FILENAME
 |   POXWPA1S.pls
 |
 | DESCRIPTION
 |   PL/SQL spec for package:  PO_REQAPPROVAL_INIT1
 |
 | NOTES
 | MODIFIED    	Ben Chihaoui (06/10/97)
 | MODIFIED    	davidng (05/24/02)
 |       	Changed parameter PrintFlag to default to 'N' instead of NULL
 *=====================================================================*/


-- Start_WF_Process
--  Generates the itemkey, sets up the Item Attributes,
--  then starts the workflow process.
--
/* RETROACTIVE FPI Change.
 * Added 2 new parameters MassUpdateReleases and RetroactivePriceChange.
 * MassUpdateReleases is Y when approval is initiated from the Form and
 * the user wants to update all the releases against the blanket with
 * the retroactive price change. RetroactivePriceChange is Y when the
 * releases are updated with the retroactive price change.
*/
PROCEDURE Start_WF_Process ( ItemType          VARCHAR2,
                             ItemKey                VARCHAR2,
                             WorkflowProcess        VARCHAR2,
                             ActionOriginatedFrom   VARCHAR2,
                             DocumentID             NUMBER,
                             DocumentNumber         VARCHAR2,
                             PreparerID             NUMBER,
                             DocumentTypeCode       VARCHAR2,
                             DocumentSubtype        VARCHAR2,
                             SubmitterAction        VARCHAR2,
                             forwardToID            NUMBER,
                             forwardFromID          NUMBER,
                             DefaultApprovalPathID  NUMBER,
                             Note                   VARCHAR2,
                             PrintFlag              VARCHAR2 default 'N',
							 FaxFlag		    VARCHAR2 default 'N',
							 FAXNumber		    VARCHAR2 default NULL,
							 EmailFlag              VARCHAR2 default 'N',
                             EmailAddress           VARCHAR2 default NULL,
                             CreateSourcingRule     VARCHAR2 default NULL,
                             ReleaseGenMethod       VARCHAR2 default NULL,
                             UpdateSourcingRule     VARCHAR2 default NULL,
                             MassUpdateReleases     VARCHAR2 default 'N', -- Retroactive FPI
                             RetroactivePriceChange VARCHAR2 default 'N', -- Retroactive FPI
                             OrgAssignChange        VARCHAR2 default 'N', -- GA FPI
                             CommunicatePriceChange VARCHAR2 default NULL, -- <FPJ Retroactive> -- bug4176111
                             p_Background_Flag      VARCHAR2 default 'N', -- <DropShip FPJ>
                             p_Initiator            VARCHAR2 default NULL,
                             p_xml_flag             VARCHAR2 default NULL, -- Bug 5218538,
							/* Bug6708182 FPDS-NG ER. */
							/* Bug 6708182 Start */
							 FpdsngFlag			VARCHAR2 default 'N',
                             p_source_type_code VARCHAR2 DEFAULT null,
							/* Bug 6708182 End */
		             p_bypass_checks_flag VARCHAR2 DEFAULT 'N', /*AME Project*/
                             p_sourcing_level VARCHAR2 DEFAULT NULL,/*BUG19701485*/
                             p_sourcing_inv_org_id NUMBER DEFAULT NULL /*BUG19701485*/
                           );


-- set_multiorg_context
--   Get the org_id and set the context for Mult-org
--
PROCEDURE get_multiorg_context(document_type varchar2, document_id number,
                               x_orgid IN OUT NOCOPY number);


-- Record variable ReqHdr_rec
--   Public record variable used to hold the Requisition_header columns
-- Bug#3147435
-- Added contractor_requisition_flag and contractor_status to ReqHdrRecord
   TYPE ReqHdrRecord IS RECORD(
                               REQUISITION_HEADER_ID NUMBER,
                               DESCRIPTION           VARCHAR2(240),
                               AUTHORIZATION_STATUS  VARCHAR2(25),
                               TYPE_LOOKUP_CODE      VARCHAR2(25),
                               PREPARER_ID           NUMBER,
                               SEGMENT1              VARCHAR2(20),
                               CLOSED_CODE           VARCHAR2(25),
                               EMERGENCY_PO_NUM      VARCHAR2(25),
                               CONTRACTOR_REQUISITION_FLAG VARCHAR2(1),
                               CONTRACTOR_STATUS     VARCHAR2(25),
                               NOTE_TO_AUTHORIZER    VARCHAR2(4000));

   ReqHdr_rec ReqHdrRecord;

-- Record variable ReqLine_rec
--   Public record variable used to hold the Requisition_line columns.

   TYPE ReqLineRecord IS RECORD(
                               LINE_NUM               NUMBER,
                               ITEM_DESCRIPTION       VARCHAR2(240),
                               UNIT_MEAS_LOOKUP_CODE  VARCHAR2(25),
                               UNIT_PRICE             NUMBER,
                               QUANTITY               NUMBER,
                               NEED_BY_DATE           DATE,
                               TO_PERSON_ID           NUMBER,
                               DELIVER_TO_LOCATION_ID NUMBER,

   /** PO UTF8 Column Expansion Project 9/23/2002 tpoon **/
   /** Expanded deliver_to_location from 20 to 60 **/
--                               DELIVER_TO_LOCATION    VARCHAR2(20),
                               DELIVER_TO_LOCATION    VARCHAR2(60),

                               REQUESTOR_FULL_NAME    VARCHAR2(240));

   ReqLine_rec ReqLineRecord;

-- Cursor GetRecHdr_csr
--   Public cursor used to get the Requisition_header columns.

   CURSOR GetRecHdr_csr(p_requisition_header_id NUMBER) RETURN ReqHdrRecord;

--
PROCEDURE get_user_name( p_employee_id IN number, x_username OUT NOCOPY varchar2,
                         x_user_display_name OUT NOCOPY varchar2);

--
PROCEDURE get_employee_id( p_username IN varchar2, x_employee_id OUT NOCOPY number);

--

-- SetStartupValues
--
--
-- IN
--   itemtype --   itemkey --   actid  --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Set_Startup_Values(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
--
-- Get_ReqAttributes
--   Get the requisition attributes. We get the header info and up to 5
--   requisition lines.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Get_Req_Attributes(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
--
-- Set_req_stat_preapproved
-- Added for WR4
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Set_doc_stat_preapproved(     itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

--
-- Set_req_stat_inprocess
-- Set the requisition status to IN-PROCESS. That way, the users can not bring
-- the Requisition up in the entry form and make modifications while it's in
-- in the workflow process.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Set_doc_stat_inprocess(     itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

-- set_doc_to_originalstat
--  Sets the doc back to it's original status if No Approver was found
--  or doc failed STATE VERIFICATION or COMPLETENESS check before APPROVE,
--  REJECT or FORWARD.

--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure set_doc_to_originalstat(     itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

-- Register_doc_submitted
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Register_doc_submitted(     itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

--
-- Can_Owner_Approve
--   Can the owner of a requisition approve it
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout
--     Y - Owner can approve requisition
--     N - Owner can NOT approve requisition
--
procedure Can_Owner_Approve(   itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );

--Bug 10013322
--  Is_Submitter_Same_As_Preparer
--  Is the submitter same as preparer
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout
--     Y - Submitter same as preparer
--     N - Submitter and preparer are different
--
procedure Is_Submitter_Same_As_Preparer(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );


--
-- Is_doc_preapproved
--   Is the document status pre-approved
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout
--     Y -
--     N -
--
procedure Is_doc_preapproved(   itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );
--

--
-- Ins_actionhist_submit
--   When submitting the document into the workflow, we need to insert
--   action SUBMIT into PO_ACTION_HISTORY
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout
--     ACTIVITY_PERFORMED
--
procedure Ins_actionhist_submit(   itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );
--

--
-- Set_End_VerifyDoc_Failed
--  Sets the value of the transition to FAILED_VERIFICATION to match the
--  transition value for the VERIFY_REQUISITION Process
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Set_End_VerifyDoc_Failed(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

--
-- Set_End_VerifyDoc_Passed
--  Sets the value of the transition to PASSED_VERIFICATION to match the
--  transition value for the VERIFY_REQUISITION Process
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    -
--
procedure Set_End_VerifyDoc_Passed(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

--
-- Set_End_Valid_Action
--  Sets the value of the transition to VALID_ACTION to match the
--  transition value for the APPROVE_REQUISITION, APPROVE_PO,
--  APPROVE_AND_FORWARD_REQUISITION and APPROVE_AND_FORWARD_PO Processes.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - VALID_ACTION
--
procedure Set_End_Valid_Action(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

--
-- Set_End_Invalid_Action
--  Sets the value of the transition to VALID_ACTION to match the
--  transition value for the APPROVE_REQUISITION, APPROVE_PO,
--  APPROVE_AND_FORWARD_REQUISITION and APPROVE_AND_FORWARD_PO Processes.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - VALID_ACTION
--
procedure Set_End_Invalid_Action(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

--
--
-- Encumb_on_doc_unreserved
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Y/N
--   If Encumbrance is ON and Document is NOT reserved, then return Y.

procedure Encumb_on_doc_unreserved(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );


--
--
-- RESERVE_AT_COMPLETION_CHECK
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Y/N
--   If the reserve at completion flag is checked, then return Y.

procedure RESERVE_AT_COMPLETION_CHECK(   itemtype        in varchar2,
                                         itemkey         in varchar2,
                                         actid           in number,
                                         funcmode        in varchar2,
                                         resultout       out NOCOPY varchar2    );
--

--
--
-- Is_Interface_ReqImport
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Y/N
--   If requisition being generated from the requisiton import program

procedure Is_Interface_ReqImport(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    ) ;

--
-- Remove_reminder_notif
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Remove the reminder notifications since this doc is now approved.

procedure Remove_reminder_notif(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    ) ;

-- Print_Doc_Yes_No
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Does user want to print the document?

procedure Print_Doc_Yes_No(   itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    ) ;


-- Fax_Doc_Yes_No
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Does user want to fax the document?

procedure Fax_Doc_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    ) ;



-- Send_WS_Notif_Yes_No
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Does user want to send the notification ?

procedure Send_WS_Notif_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    ) ;


-- Send_WS_Fyi_Notif_Yes_No
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Does user want to send the FYI notification ?

procedure Send_WS_Fyi_Notif_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    ) ;


-- Send_WS_Ack_Notif_Yes_No
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Does user want to send the acknowledgement notification ?

procedure Send_WS_Ack_Notif_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    ) ;


-- locate_notifier
-- IN
-- document_number, document_type
-- OUT
-- fnd_user (resultout)
-- What is the web supplier defined for this particular user (if any)?

procedure locate_notifier		(document_id	in	varchar2,
					document_type  	in 	varchar2,
				 resultout	in out NOCOPY  varchar2);


/*******************************************************************
  < Added this procedure as part of Bug #: 2810150 >

  PROCEDURE NAME: get_user_list_with_resp

  DESCRIPTION   :
  For the given document_id ( ie. po_header_id ), this procedure
  tries to find out the correct users that need to be sent the
  notifications.

  Referenced by : Workflow procedures
  parameters    :
   Input:
    document_id - the document id
    document_type - Document type
    p_notify_only_flag -
        The values can be 'Y' or 'N'
        'Y' means: The procedure will return all the users that are supplier users related to the document.
        Returns the role containing all the users in the "x_resultout" variable

        'N' means: we want users that need to be sent FYI and also the users with resp.
            x_resultout: will have the role for the users that need to be sent the FYI
            x_role_with_resp: will have the role for users having the fucntion "POS_ACK_ORDER" assigned to
            them.

   Output:
    x_resultout - Role for the users that need to be sent FYI
    x_role_with_resp - Role for the users who have the ability to acknowledge.

  CHANGE History: Created      27-Feb-2003    jpasala
*******************************************************************/

procedure locate_notifier       (p_document_id    in      varchar2,
                                 p_document_type   in     varchar2,
                                 p_notify_only_flag   in     varchar2,
                                 x_resultout      in out NOCOPY  varchar2,
                                 x_role_with_resp in out NOCOPY VARCHAR2) ;
-- Email_Doc_Yes_No
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Does user want to email the document?

procedure Email_Doc_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    ) ;


-- Print_Document
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Print Document.

procedure Print_Document(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) ;



-- Fax_Document
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Fax Document.

procedure Fax_Document(     itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) ;



-- Is_document_Approved
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Is the document already approved. This may be the case if the document
--   was PRE-APPROVED before it goes through the reserve action. The RESERVE
--   would then approve the doc after it reserved the funds.

procedure Is_document_Approved(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) ;

-- Get_Workflow_Approval_Mode
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--      On-line
--      Background

procedure Get_Workflow_Approval_Mode(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) ;

-- Get_Create_PO_Mode
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--      Activity Performed

procedure Get_Create_PO_Mode(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) ;

-- Dummy
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--      Activity Performed
-- Dummy procedure that does nothing (NOOP). Used to set the
-- cost above the backgound engine threshold. This causes the
-- workflow to execute in the background.
procedure Dummy(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) ;

-- Is product source code POR ?
-- Determines if the requisition is created
-- through web requisition
procedure is_apps_source_POR(itemtype in varchar2,
                         itemkey         in varchar2,
                         actid           in number,
                         funcmode        in varchar2,
                         resultout       out NOCOPY varchar2);

-- Bug#3147435
-- Is contractor status PENDING?
-- Determines if the requisition has contractor_status PENDING at header level
procedure is_contractor_status_pending(itemtype in varchar2,
                                       itemkey         in varchar2,
                                       actid           in number,
                                       funcmode        in varchar2,
                                       resultout       out NOCOPY varchar2);

-- Is_Submitter_Last_Approver
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
-- Bug 823167 kbenjami
--
-- Is the Submitter the last Approver?
-- Checks to see if submitter is also the current
-- approver of the doc.
-- Prevents two notifications from being sent to the
-- same person.
--
procedure Is_Submitter_Last_Approver(itemtype 	in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) ;

-- This function finds out the document type, subtype and number and
-- concatenates them together for PLSQL_ERROR_DOC.  This is need because
-- the document info attribute may be rolled back when error occurs.

function get_error_doc(itemtype in varchar2,
                       itemkey  in varchar2) return varchar2;

-- This function finds out preparer user name.  This is need because
-- the document info attribute may be rolled back when error occurs.

function get_preparer_user_name(itemtype in varchar2,
                                itemkey  in varchar2) return varchar2;

-- This procedure send the 'PLSQL_ERROR_OCCURS' notification to the
-- preparer when PL/SQL error occurs during approval workflow

procedure send_error_notif(itemtype    in varchar2,
                           itemkey     in varchar2,
                           username    in varchar2,
                           doc         in varchar2,
                           msg         in varchar2,
                           loc         in varchar2,
			   document_id in number default NULL); /* Bug 6827401 Added document_id with default value as NULL*/

/* Bug# 1739194: kagarwal
** Desc: Added new procedure to check the document manager error.
*/
procedure Is_Document_Manager_Error_1_2(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

/* bug 1759631 - procedure to check if there is any second email address
   in the profile */

procedure PROFILE_VALUE_CHECK(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2 ) ;

procedure Check_Error_Count(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);
procedure Initialise_Error(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
			   resultout       out NOCOPY varchar2);

procedure  acceptance_required   ( itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    );
--

procedure  Register_acceptance   ( itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    );
--

procedure  Register_rejection   (  itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    );

procedure Create_SR_ASL_Yes_No( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );

/* Bug#2353153: kagarwal
** Added new PROCEDURE set_doc_mgr_context as a global procedure as this
** is being used by wf apis present in different packages.
*/

PROCEDURE Set_doc_mgr_context (itemtype VARCHAR2,
                               itemkey VARCHAR2);

/* FPI RETROACTIVE PRICING CHANGE START */
/*******************************************************************
  PROCEDURE NAME: MassUpdate_Releases_Yes_No

  DESCRIPTION   : This is the API which determines whether the approval;
		  process should also update the releases against the
		  blanket that is getting approved has to be updated
		  with the new price change. Get the value of
		  the parameter massupdatereleases from start_Wf_process.
		  If this value is Y and if it is a blanket agreeement
		  then we need to mass update the releases with the new
		  price.
  Referenced by :
  parameters    : Usual workflow attributes.

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/

procedure MassUpdate_Releases_Yes_No( itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
                                     resultout       out NOCOPY varchar2    );

/*******************************************************************
  PROCEDURE NAME: MassUpdate_Releases_Workflow

  DESCRIPTION   : This is the API that is called from PO Approval
		  Workflow if the massupdate checkbox in the
		  Approval  Window is set to Yes.
  Referenced by :
  parameters    : Usual workflow attributes.

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/
procedure MassUpdate_Releases_Workflow( itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
				     resultout       out NOCOPY varchar2 ) ;


/*******************************************************************
  PROCEDURE NAME: Send_Supplier_Comm_Yes_No

  DESCRIPTION   : This is the API which determines whether supplier
		  Communication has to be sent when the document is
		  is approved. There is a new Change Order Workflow
		  attribute which can be set to Y if we need to
		  send supplier when the release is updated with
		  the new price after the Mass update release program is
		  run. If it is yes, then this procedure will return
		  Yes.
  Referenced by :
  parameters    : Usual workflow attributes.

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/
procedure Send_Supplier_Comm_Yes_No( itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
                                     resultout       out NOCOPY varchar2    );

/* RETROACTIVE FPI END */


-- <FPJ Retroactive START>
/**
* Public Procedure: Retro_Invoice_Release_WF
* Requires:
*   IN PARAMETERS:
*     Usual workflow attributes.
* Modifies: PO_DISTRIBUTIONS_ALL.invoice_adjustment_flag
* Effects:  This procedure updates invoice adjustment flag, and calls Costing
*           and Inventory APIs.
*/
procedure Retro_Invoice_Release_WF( itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    resultout       out NOCOPY varchar2    );

procedure should_notify_cat_admin(p_item_type        in varchar2,
	                          p_item_key         in varchar2,
	                          p_act_id           in number,
	                          p_func_mode        in varchar2,
	                          x_result_out       out NOCOPY varchar2    );

-- <FPJ Retroactive END>

-- <Bug 5059002 Begin>

/**
* Public Procedure: set_is_supplier_context_y
* Requires:
*   IN PARAMETERS:
*     Usual workflow attributes.
* Modifies: Sets the workflow attribute IS_SUPPLIER_CONTEXT to Y
*/

-- Commenting this procedure. May not be required after context Setting Fix.
/* procedure set_is_supplier_context_y(p_item_type        in varchar2,
	                          p_item_key         in varchar2,
	                          p_act_id           in number,
	                          p_func_mode        in varchar2,
	                          x_result_out       out NOCOPY varchar2); */

/**
* Public Procedure: set_is_supplier_context_n
* Requires:
*   IN PARAMETERS:
*     Usual workflow attributes.
* Modifies: Sets the workflow attribute IS_SUPPLIER_CONTEXT to N
*/
/* procedure set_is_supplier_context_n(p_item_type        in varchar2,
	                          p_item_key         in varchar2,
	                          p_act_id           in number,
	                          p_func_mode        in varchar2,
	                          x_result_out       out NOCOPY varchar2); */
-- <Bug 5059002 End>

-- HTML Orders R12
-- function to construct the PO view/update Page URL's
Function get_po_url (p_po_header_id IN NUMBER,
	             p_doc_subtype  IN VARCHAR2,
                     p_mode         IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_wf_role_for_users(p_list_of_users in varchar2, p_num_users in number) return varchar2;

-- <Bug 5228261 Begin>
procedure GetReqAttributes(p_requisition_header_id in NUMBER,
                             itemtype        in varchar2,
                             itemkey         in varchar2);
-- <Bug 5228261 End>

-- <Bug 4950854 Begin>
procedure update_print_count( p_doc_id in NUMBER,
                              p_doc_type IN VARCHAR2 );
-- <Bug 4950854 End>

--<Bug 16516373 Start>
-- Non-Autonomous procedure to update print count
procedure update_print_count_na( p_doc_id in number,
                              p_doc_type IN VARCHAR2 );

--<Bug 16516373 End>

-- <BUG 5691965 START>
/**
** Public Procedure: Update_Action_History_TimeOut
** Requires:
**   IN PARAMETERS:
**     Usual workflow attributes.
** Modifies: Action History
** Effects:  Actoin History is updated with No Action if the approval
**           notification is TimedOut.
*/

PROCEDURE Update_Action_History_TimeOut (itemtype     IN    VARCHAR2,
                                         itemkey      IN    VARCHAR2,
                                         actid        IN    NUMBER,
                                         funcmode     IN    VARCHAR2,
                                         resultout   OUT   NOCOPY VARCHAR2);

-- <BUG 5691965 END>

-- <Bug 6144768 Begin>
-- When Supplier responds from iSP then the responder should show
-- as supplier and also supplier acknowledgement notifications
-- should be available in the To-Do Notification full list.

/**
* Public Procedure: set_is_supplier_context_y
* Requires:
*   IN PARAMETERS:
*     Usual workflow attributes.
* Modifies: Sets the workflow attribute IS_SUPPLIER_CONTEXT to Y
*/
procedure set_is_supplier_context_y(p_item_type        in varchar2,
	                            p_item_key         in varchar2,
	                            p_act_id           in number,
	                            p_func_mode        in varchar2,
                                    x_result_out       out NOCOPY varchar2);

/**
* Public Procedure: set_is_supplier_context_n
* Requires:
*   IN PARAMETERS:
*     Usual workflow attributes.
* Modifies: Sets the workflow attribute IS_SUPPLIER_CONTEXT to N
*/
procedure set_is_supplier_context_n(p_item_type        in varchar2,
	                            p_item_key         in varchar2,
	                            p_act_id           in number,
	                            p_func_mode        in varchar2,
	                            x_result_out       out NOCOPY varchar2);
-- <Bug 6144768 End>

-- added for bug 8291565 - to avoid sending repeated FYI notifications to iSupplier Users for Purchase orders having same revision number

-- updates the po_headers_all table with the revision number of the Purchase Order for which supplier users are communicated.
PROCEDURE update_supplier_com_rev_num(itemtype IN VARCHAR2,
                                      itemkey IN VARCHAR2,
                                      actid   IN VARCHAR2,
                                      funcmode IN VARCHAR2,
                                      resultout OUT NOCOPY VARCHAR2);

-- compares the current revision number of the purchase order with the value stored as last revision number communicated to supplier users.
PROCEDURE check_rev_num_supplier_notif(itemtype IN VARCHAR2,
                                       itemkey IN VARCHAR2,
                                       actid   IN VARCHAR2,
                                       funcmode IN VARCHAR2,
                                       resultout OUT NOCOPY VARCHAR2);

-- added for bug 8291565 - to avoid sending repeated FYI notifications to iSupplier Users for Purchase orders having same revision number

-- Bug#18416955
procedure Is_Doc_Release(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2);

-- Bug#18301844
procedure cancel_comm_process(ItemType               VARCHAR2,
                              ItemKey                VARCHAR2,
                              WorkflowProcess        VARCHAR2,
                              ActionOriginatedFrom   VARCHAR2,
                              DocumentID             NUMBER,
                              DocumentTypeCode       VARCHAR2,
                              DocumentSubtype        VARCHAR2,
                              SubmitterAction        VARCHAR2,
                              p_Background_Flag      VARCHAR2 default 'N',
                              p_communication_method_value VARCHAR2,   --bug#19214300
                              p_communication_method_option VARCHAR2); --bug#19214300

end  PO_REQAPPROVAL_INIT1;

/
