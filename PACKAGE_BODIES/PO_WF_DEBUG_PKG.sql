--------------------------------------------------------
--  DDL for Package Body PO_WF_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WF_DEBUG_PKG" as
/* $Header: POXWDBGB.pls 120.1.12010000.3 2012/07/12 05:29:15 kuichen ship $*/

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
                        x_progress  varchar2) is

/* Bug# 1632741: kagarwal
** Desc: Making procedure insert_debug an autonomous transaction as
** there should never be a commit in any code that is called by the
** workflow engine that will be executed in the same transaction.
*/

  pragma AUTONOMOUS_TRANSACTION;

  l_document_id        number := NULL;
  l_document_number    varchar2(25) := NULL;
  l_preparer_id        number := NULL;
  l_approver_empid     number := NULL;
  l_Forward_to_id      number := NULL;
  l_Forward_to_username varchar2(100) := NULL;
  l_Forward_from_id    number := NULL;
  l_Forward_from_username varchar2(100) := NULL;
  l_Authorization_status  varchar2(25) := NULL;

  x_option_value       varchar2(10);

BEGIN


/* If it's Req or PO approval then get some of the info that we want to log.
** If the profile option is set , then log debug messages.
*/
/* Bug 2834040 fixed. replaced the wf_engine call with po_wf_util_pkg
   wrapper call so that debug messages will get logged inspite of
   the workflow attributes not being set.
*/
fnd_profile.get('PO_SET_DEBUG_WORKFLOW_ON',x_option_value);

IF x_option_value = 'Y' THEN

  IF itemtype IN ('REQAPPRV','POAPPRV')  THEN

   l_document_number:= PO_WF_UTIL_PKG.GetItemAttrText (     itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'DOCUMENT_NUMBER');
        --
   l_document_id:=     PO_WF_UTIL_PKG.GetItemAttrNumber (   itemtype   => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'DOCUMENT_ID');

   l_preparer_id:=     PO_WF_UTIL_PKG.GetItemAttrNumber (   itemtype        => itemType,
                                        itemkey         => itemkey,
                                        aname           => 'PREPARER_ID');
        --
   l_Forward_to_id:=   PO_WF_UTIL_PKG.GetItemAttrNumber (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'FORWARD_TO_ID');
        --
   l_Forward_from_id:=  PO_WF_UTIL_PKG.GetItemAttrNumber (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'FORWARD_FROM_ID');
        --
   l_Forward_to_username:= PO_WF_UTIL_PKG.GetItemAttrText ( itemtype   => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'FORWARD_TO_USERNAME');

   l_Forward_from_username:= PO_WF_UTIL_PKG.GetItemAttrText ( itemtype   => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'FORWARD_FROM_USER_NAME');

   l_approver_empid:=     PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'APPROVER_EMPID');

   l_authorization_status :=  PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'AUTHORIZATION_STATUS');
  END IF;

  BEGIN

      insert into PO_WF_DEBUG
                        (EXECUTION_SEQUENCE,
                         EXECUTION_DATE,
                         ITEMTYPE,
                         ITEMKEY,
                         DOCUMENT_ID,
                         DOCUMENT_NUMBER,
                         PREPARER_ID,
                         APPROVER_EMPID,
                         FORWARD_TO_ID,
                         FORWARD_TO_USERNAME,
                         FORWARD_FROM_ID,
                         FORWARD_FROM_USERNAME,
                         AUTHORIZATION_STATUS,
                         DEBUG_MESSAGE)
                        values(po_wf_debug_s.nextval,
                                sysdate,
                                itemtype,
                                itemkey,
                                l_document_id,
                                l_document_number,
                                l_preparer_id,
                                l_approver_empid,
                                l_Forward_to_id,
                                l_Forward_to_username,
                                l_Forward_from_id,
                                l_Forward_from_username,
                                l_Authorization_status,
                                x_progress);

  EXCEPTION

    WHEN OTHERS THEN
      NULL;  -- Don't raise any exceptions. Just don't log to the table.
  END;

  --Bug 14044581, log the wf debug messages into FND log table
  --Profile PO: Set Debug Workflow ON still need to be set
  --as existing calling procedures only call this code when the
  --wf debug profile is set
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt('po.plsql.WF LOG TO FND LOG', NULL, 'itemtype: '||itemtype||' itemkey: '
                ||itemkey||' Message Text: '||x_progress);
  END IF;

COMMIT;

END IF;


EXCEPTION
     WHEN OTHERS THEN
      NULL;  -- Don't raise any exceptions. Just don't log to the table.
END insert_debug;

-- <R12 PO OTM Integration START>
PROCEDURE debug_stmt(
   p_log_head                       IN             VARCHAR2
,  p_token                          IN             VARCHAR2
,  p_message                        IN             VARCHAR2
)
IS

PRAGMA AUTONOMOUS_TRANSACTION;

l_option_value VARCHAR2(10);

BEGIN

FND_PROFILE.get('PO_SET_DEBUG_WORKFLOW_ON', l_option_value);

IF (l_option_value = 'Y') THEN
  BEGIN
    INSERT INTO po_wf_debug (  execution_sequence
                             , execution_date
                             , debug_message
                            )
    VALUES                  (  po_wf_debug_s.NEXTVAL
                             , SYSDATE
                             , SUBSTRB(p_log_head || '.' || p_token || ':' || p_message, 1, 1000));
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  --Bug 14044581, log the wf debug messages into FND log table
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt('po.plsql.WF LOG TO FND LOG', NULL, 'p_log_head: '||p_log_head||' p_token: '
                ||p_token||' Message Text: '||p_message);
  END IF;

  COMMIT;
END IF;

END debug_stmt;

PROCEDURE debug_begin(
   p_log_head                       IN             VARCHAR2
)
IS
BEGIN
  debug_stmt(p_log_head,'BEGIN','Entry into procedure '||p_log_head||'.');
END debug_begin;

PROCEDURE debug_end(
   p_log_head                       IN             VARCHAR2
)
IS
BEGIN
  debug_stmt(p_log_head,'END','Exiting procedure '||p_log_head||' normally.');
END debug_end;

PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             VARCHAR2
)
IS
BEGIN
  IF (p_value IS NULL) THEN
    debug_stmt(p_log_head,p_progress,p_name||' IS NULL');
  ELSE
    debug_stmt(p_log_head,p_progress,p_name||' = '||p_value);
  END IF;
END debug_var;

PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             NUMBER
)
IS
BEGIN
  IF (p_value IS NULL) THEN
    debug_stmt(p_log_head,p_progress,p_name||' IS NULL');
  ELSE
    debug_stmt(p_log_head,p_progress,p_name||' = '||TO_CHAR(p_value));
  END IF;
END debug_var;



PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             DATE
)
IS
BEGIN
  IF (p_value IS NULL) THEN
    debug_stmt(p_log_head,p_progress,p_name||' IS NULL');
  ELSE
    debug_stmt(p_log_head,p_progress,p_name||' = '||TO_CHAR(p_value));
  END IF;
END debug_var;


PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             BOOLEAN
)
IS
BEGIN
  IF (p_value IS NULL) THEN
    debug_stmt(p_log_head,p_progress,p_name||' IS NULL');
  ELSIF (p_value) THEN
    debug_var(p_log_head,p_progress,p_name,'TRUE');
  ELSE
    debug_var(p_log_head,p_progress,p_name,'FALSE');
  END IF;
END debug_var;

PROCEDURE debug_unexp(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_message                        IN             VARCHAR2
      DEFAULT NULL
)
IS
BEGIN
  debug_stmt(p_log_head,p_progress,'EXCEPTION: '||p_message||'; SQLCODE = '||
  TO_CHAR(SQLCODE) || '; SQLERRM = ' || SQLERRM);
END debug_unexp;
-- <R12 PO OTM Integration END>


END PO_WF_DEBUG_PKG;

/
