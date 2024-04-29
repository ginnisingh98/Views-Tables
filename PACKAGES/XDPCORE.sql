--------------------------------------------------------
--  DDL for Package XDPCORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDPCORE" AUTHID CURRENT_USER AS
/* $Header: XDPCORES.pls 120.1 2005/06/15 22:37:27 appldev  $ */



 e_NullValueException		EXCEPTION;




 x_ErrMsg			VARCHAR2(2000);
 x_DebugMsg			VARCHAR2(2000);

 x_ErrorID number;
 x_Code number;
 x_Str varchar2(800);
 x_MessageList XDP_TYPES.MESSAGE_TOKEN_LIST;

business_error   VARCHAR2(1) := 'N';
object_type   VARCHAR2(2000);
object_key     VARCHAR2(32000);
error_name      VARCHAR2(30);
error_number    NUMBER;
error_message   VARCHAR2(2000);
error_stack     VARCHAR2(32000);

-- StartWfProcess
-- Generates the itemkey, sets up the Item Attributes,
-- then starts the workflow process.
--
Procedure StartWfProcess ( ItemType in VARCHAR2,
                           ItemKey in VARCHAR2,
                           OrderID in number,
                           WorkflowProcess in VARCHAR2,
                           Caller in VARCHAR2);


-- StartOA Process
-- Creates and Starts the OA process

Procedure StartOAProcess ( OrderID in number);


-- StartInitOrderProcess
-- Creates and Starts the InitialOrderProcess

Procedure StartInitOrderProcess ( OrderID in number);

-- StartORUProcess
-- Creates and Starts the Order Resubmission Process

Procedure StartORUProcess ( ResubmissionJOBID in number,
                            itemtype OUT NOCOPY varchar2,
                            itemkey OUT NOCOPY varchar2);



-- CreateOrderProcess
-- then creates the Main Order Process which the Order processor Dequer starts off
--
Procedure CreateOrderProcess (OrderID in number,
                              ItemType OUT NOCOPY VARCHAR2,
                              ItemKey OUT NOCOPY VARCHAR2 );


--  ENQUEUE_PENDING_QUEUE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

/****

Procedure ENQUEUE_PENDING_QUEUE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);

*****/


--  RESUME_SDP
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here: Put the Order requiring Order Analyzer into the
--			  Order Analyzer Queue for processing.

Procedure RESUME_SDP (itemtype        in varchar2,
                      itemkey         in varchar2,
                      actid           in number,
                      funcmode        in varchar2,
                      resultout       OUT NOCOPY varchar2);


--  LAUNCH_ORDER_ANALYZER
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure LAUNCH_ORDER_ANALYZER (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 );


--  IS_OA_NEEDED
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure IS_OA_NEEDED (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);



--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure ORDER_TYPE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);



--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure WHAT_SOURCE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);


Procedure OP_START (itemtype        in varchar2,
                 itemkey         in varchar2,
                 actid           in number,
                 funcmode        in varchar2,
                 resultout       OUT NOCOPY varchar2);

Procedure OP_END (itemtype        in varchar2,
               itemkey         in varchar2,
               actid           in number,
               funcmode        in varchar2,
               resultout       OUT NOCOPY varchar2);

Procedure CheckNAddItemAttrText(itemtype in varchar2,
                                itemkey in varchar2,
                                AttrName in varchar2,
                                AttrValue in varchar2,
                                ErrCode OUT NOCOPY number,
                                ErrStr OUT NOCOPY varchar2);

Procedure CheckNAddItemAttrNumber(itemtype in varchar2,
                                  itemkey in varchar2,
                                  AttrName in varchar2,
                                  AttrValue in number,
                                  ErrCode OUT NOCOPY number,
                                  ErrStr OUT NOCOPY varchar2);

Procedure CheckNAddItemAttrDate(itemtype in varchar2,
                                  itemkey in varchar2,
                                  AttrName in varchar2,
                                  AttrValue in date,
                                  ErrCode OUT NOCOPY number,
                                  ErrStr OUT NOCOPY varchar2);

--This procedure creates the child process and sets the parent child
--relationship along with the label of wait flow activity in parent
-- bug fix for bug #2269403
Procedure CreateNAddAttrNParentLabel(itemtype in varchar2,
			      itemkey in varchar2,
			      processname in varchar2,
			      parentitemtype in varchar2,
			      parentitemkey in varchar2,
			      waitflowLabel in varchar2,
			      OrderID in number,
			      LineitemID in number,
			      WIInstanceID in number,
			      FAInstanceID in number);

Procedure CreateAndAddAttrNum(itemtype in varchar2,
			      itemkey in varchar2,
			      processname in varchar2,
			      parentitemtype in varchar2,
			      parentitemkey in varchar2,
			      OrderID in number,
			      LineitemID in number,
			      WIInstanceID in number,
			      FAInstanceID in number);


Procedure SEND_NOTIFICATION (role in varchar2,
                             msg_type in varchar2,
                             msg_name in varchar2,
                             due_date in varchar2,
                             itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             priority in number default 100,
                             OrderID in number default null,
                             WIInstanceID in number default null,
                             FAInstanceID in number default null,
                             notifID OUT NOCOPY number);

Procedure START_FA_RESUBMIT_PROCESS( p_fe_id                IN NUMBER,
                                     p_start_date           IN DATE ,
                                     p_end_date             IN DATE,
                                     p_resubmission_job_id  IN NUMBER,
                                     x_error_code          OUT NOCOPY NUMBER,
                                     x_error_message       OUT NOCOPY VARCHAR2);


Procedure START_RESUBMISSION_CHANNELS( p_fe_id              IN NUMBER,
                                       p_channels_reqd      IN NUMBER,
                                       p_usage_code         IN VARCHAR2,
                                       x_channels_started  OUT NOCOPY NUMBER,
                                       x_error_code        OUT NOCOPY NUMBER,
                                       x_error_message     OUT NOCOPY VARCHAR2) ;
--
-- Clear
--   Clear the error buffers.
-- EXCEPTIONS
--   none
--
procedure Clear;
pragma restrict_references(CLEAR, WNDS, RNDS, RNPS);


--
-- Get_Error
--   Return current error info and clear error stack.
--   Returns null if no current error.
-- OUT
--   error_name - error name - varchar2(30)
--   error_message - substituted error message - varchar2(2000)
--   error_stack - error call stack, truncated if needed  - varchar2(2000)
-- EXCEPTIONS
--   none
--
procedure Get_Error(object_type OUT NOCOPY varchar2,
		    object_key OUT NOCOPY varchar2,
		    err_name OUT NOCOPY varchar2,
		    err_message OUT NOCOPY varchar2,
                    err_stack OUT NOCOPY varchar2);
pragma restrict_references(GET_ERROR, WNDS, RNDS);


--
-- Context
--   set procedure context (for stack trace)
-- IN
--   pkg_name   - package name
--   proc_name  - procedure/function name
--   arg1       - first IN argument
--   argn       - n'th IN argument
-- EXCEPTIONS
--   none
--

procedure Context(pkg_name  in varchar2,
                  proc_name in varchar2,
                  arg1      in varchar2 default '*none*',
                  arg2      in varchar2 default '*none*',
                  arg3      in varchar2 default '*none*',
                  arg4      in varchar2 default '*none*',
                  arg5      in varchar2 default '*none*',
                  arg6      in varchar2 default '*none*',
                  arg7      in varchar2 default '*none*',
                  arg8      in varchar2 default '*none*',
                  arg9      in varchar2 default '*none*',
                  arg10      in varchar2 default '*none*');
pragma restrict_references(CONTEXT, WNDS);

--
-- Error_Context
--   set procedure Error context (for logging errors)
-- IN
-- EXCEPTIONS
--   none

Procedure error_context (object_type in varchar2,
		        object_key in varchar2,
			error_name in varchar2,
			error_message in varchar2);
pragma restrict_references(error_CONTEXT, WNDS);

function is_business_error return varchar2;
pragma restrict_references(is_business_error, WNDS);

--
-- Raise
--   Raise an exception to the caller
-- IN
--   none
-- EXCEPTIONS
--   Raises an a user-defined (20002) exception with the error message.
--
procedure Raise(err_number in number default -20001,
		err_message in varchar2 default null);

End XDPCORE;

 

/
