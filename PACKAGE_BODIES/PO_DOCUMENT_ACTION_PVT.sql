--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_ACTION_PVT" AS
-- $Header: POXVDACB.pls 120.10.12010000.5 2012/06/28 09:08:01 vlalwani ship $

-- Private package constants

g_pkg_name CONSTANT varchar2(30) := 'PO_DOCUMENT_ACTION_PVT';
g_log_head CONSTANT VARCHAR2(50) := 'po.plsql.'|| g_pkg_name || '.';

-- Private package variables

-- variable that stores the value that will be put into
-- error_msg variable of the record upon action completion
-- re-initialized at beginning of do_action
g_err_message VARCHAR2(2000);

------------------------------------------------------------------------------
--Start of Comments
--Name: do_action
--Pre-reqs:
--  None
--Modifies:
--  None, directly.
--Locks:
--  None, directly.Calls PO_DOCUMENT_LOCK_GRP to lock document
--  if action ctl record's lock_document = TRUE
--Function:
--  This procedure is the switchboard for all document actions in
--  package PO_DOCUMENT_ACTION_PVT.  Performs all the common logic
--  for these actions.
--  This includes:
--    setting the org context to that of the document
--    initializing g_err_message, the shared error string
--    locking the document, if necessary
--    calling the appropriate action handler
--    inbound logistics, if necessary (PO_DELREC_PVT call)
--    rolling back when action returns 'U'
--    resetting the org context back to the original org context
--Replaces:
--  This method covers some of the logic in poxdmaction in poxdm.lpc.
--Parameters:
--IN:
--  p_action_ctl_rec
--    Record containing all necessary parameters for action.
--    Should be populated by the individual do_XXXX methods.
--OUT:
--  p_action_ctl_rec
--    Record contains variables that record output values depending
--    on the action.  All actions will populate at least a return_status.
--    See individual actions and package spec for more info on outputs.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_action(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
)
IS

l_doc_org_id   PO_HEADERS_ALL.org_id%TYPE;
l_old_org_id   PO_HEADERS_ALL.org_id%TYPE;
l_lock_status  VARCHAR2(1);

l_ret_sts      VARCHAR2(1);
l_msg_count    NUMBER;
l_msg_data     VARCHAR2(2000) := NULL;

d_progress     NUMBER;
d_module       VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_PVT.do_action';
d_log_msg      VARCHAR2(200);

-- variables required for locking
-- resource_busy_exc definition copied from PO_DOCUMENT_LOCK_GRP
resource_busy_exc   EXCEPTION;
PRAGMA EXCEPTION_INIT(resource_busy_exc, -00054);
l_locked_doc        BOOLEAN := FALSE;
l_doc_id_tbl        po_tbl_number;

-- <HTML Agreement Release 12>
l_update_allowed    VARCHAR2(1);
l_locking_applicable VARCHAR2(1);
l_unlock_required   VARCHAR2(1);
l_error_message     VARCHAR2(30);
l_error_message_text FND_NEW_MESSAGES.message_text%type;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.action', p_action_ctl_rec.action);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_type', p_action_ctl_rec.document_type); --Bug#4962625
  END IF;

  SAVEPOINT DA_DO_ACTION_SP;

  -- initialize shared concatenated string to be used as error stack
  g_err_message := NULL;

  BEGIN

    d_progress := 10;

    -- Set the org context to that of the document
    -- Keep track of old org context so that we can reset it.

    l_old_org_id := NULL;
    l_doc_org_id := NULL;

    IF (p_action_ctl_rec.document_type in ('PO', 'PA'))
    THEN

      d_progress := 11.1;

      SELECT org_id
      INTO l_doc_org_id
      FROM po_headers_all poh
      WHERE poh.po_header_id = p_action_ctl_rec.document_id;

    ELSIF (p_action_ctl_rec.document_type = 'RELEASE')
    THEN

      d_progress := 11.2;

      SELECT org_id
      INTO l_doc_org_id
      FROM po_releases_all por
      WHERE por.po_release_id = p_action_ctl_rec.document_id;

    ELSIF (p_action_ctl_rec.document_type = 'REQUISITION')
    THEN

      d_progress := 11.3;

      SELECT org_id
      INTO l_doc_org_id
      FROM po_requisition_headers_all porh
      WHERE porh.requisition_header_id = p_action_ctl_rec.document_id;

    ELSE

      d_progress := 11.4;
      d_log_msg := 'invalid document type';
      l_ret_sts := 'U';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;  -- p_aciton_ctl_rec.document_type = ...

    d_progress := 12;

    --the current org id is now derived using the get_current_org_id
    --function because org context is not set in java
    l_old_org_id := PO_MOAC_UTILS_PVT.get_current_org_id;

    d_progress := 13;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_old_org_id', l_old_org_id);
      PO_LOG.stmt(d_module, d_progress, 'l_doc_org_id', l_doc_org_id);
      PO_LOG.stmt(d_module, d_progress, 'Setting org context.');
    END IF;

    po_moac_utils_pvt.set_org_context(l_doc_org_id); --<R12 MOAC>


    -- if necessary, lock the document

    IF (p_action_ctl_rec.lock_document)
    THEN

      d_progress := 15;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Locking the document.');
      END IF;

      l_doc_id_tbl := po_tbl_number(p_action_ctl_rec.document_id);

      -- Ported over functionality from document manager
      -- It would try to lock the document 1000 times.
      FOR i IN 1..1000
      LOOP

        BEGIN

          d_progress := 16;

	  /*Bug8512125 We pass the calling mode from here which will execute a different set of cursors if the mode is RCV*/

	  PO_LOCKS.lock_headers(
             p_doc_type          => p_action_ctl_rec.document_type
          ,  p_doc_level         => PO_CORE_S.g_doc_level_HEADER
          ,  p_doc_level_id_tbl  => l_doc_id_tbl
	  ,  p_calling_mode      => p_action_ctl_rec.calling_mode
          );

          l_locked_doc := TRUE;

          EXIT;

        EXCEPTION
          WHEN resource_busy_exc THEN
            NULL;
        END;

      END LOOP;  -- for i in 1..1000

      IF (NOT l_locked_doc)
      THEN

        d_log_msg := 'failed to lock document after 1000 tries';
        l_ret_sts := 'U';
        RAISE PO_CORE_S.g_early_return_exc;

      END IF;


      -- <HTML Agreement R12 START>
      -- Obtain functional lock of the document
      -- <Bug#4651122>
      -- Added l_error_message_text as an argument to match the singature
      IF (p_action_ctl_rec.document_type = 'PA') THEN

        PO_DRAFTS_PVT.update_permission_check
        ( p_calling_module      => PO_DRAFTS_PVT.g_call_mod_API,
          p_po_header_id        => p_action_ctl_rec.document_id,
          p_role                => PO_GLOBAL.g_role_BUYER,
          p_skip_cat_upload_chk => FND_API.G_TRUE,
          x_update_allowed      => l_update_allowed,
          x_locking_applicable  => l_locking_applicable,
          x_unlock_required     => l_unlock_required,
          x_message             => l_error_message,
	  x_message_text        => l_error_message_text     --Bug#4651122
        );

        IF (l_update_allowed = FND_API.G_FALSE) THEN
          d_log_msg := 'unable to perform control action to doc: ' ||
                       l_error_message_text;
          l_ret_sts := 'E';
          RAISE PO_CORE_S.g_early_return_exc;
        END IF;

      END IF;

      -- <HTML Agreement R12 END>

    ELSE

      d_progress := 20;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Not locking the document.');
      END IF;

    END IF;  -- IF p_action_ctl_rec.lock_document


    -- Switchboard: run appropriate handler routine based on action

    IF (p_action_ctl_rec.action = PO_DOCUMENT_ACTION_PVT.g_doc_action_APPROVE)
    THEN

      d_progress := 30.1;
      PO_DOCUMENT_ACTION_AUTH.approve(p_action_ctl_rec => p_action_ctl_rec);

    ELSIF (p_action_ctl_rec.action = PO_DOCUMENT_ACTION_PVT.g_doc_action_REJECT)
    THEN

      d_progress := 30.2;
      PO_DOCUMENT_ACTION_AUTH.reject(p_action_ctl_rec => p_action_ctl_rec);

    ELSIF (p_action_ctl_rec.action = PO_DOCUMENT_ACTION_PVT.g_doc_action_FORWARD)
    THEN

      d_progress := 30.3;
      PO_DOCUMENT_ACTION_AUTH.forward(p_action_ctl_rec => p_action_ctl_rec);

    ELSIF (p_action_ctl_rec.action = PO_DOCUMENT_ACTION_PVT.g_doc_action_RETURN)
    THEN

      d_progress := 30.4;
      PO_DOCUMENT_ACTION_AUTH.return_action(p_action_ctl_rec => p_action_ctl_rec);

    ELSIF (p_action_ctl_rec.action = PO_DOCUMENT_ACTION_PVT.g_doc_action_CHECK_APPROVE)
    THEN

      d_progress := 40.1;
      PO_DOCUMENT_ACTION_CHECK.approve_status_check(p_action_ctl_rec => p_action_ctl_rec);

    ELSIF (p_action_ctl_rec.action = PO_DOCUMENT_ACTION_PVT.g_doc_action_CHECK_REJECT)
    THEN

      d_progress := 40.2;
      PO_DOCUMENT_ACTION_CHECK.reject_status_check(p_action_ctl_rec => p_action_ctl_rec);

    ELSIF (p_action_ctl_rec.action = PO_DOCUMENT_ACTION_PVT.g_doc_action_CHECK_AUTHORITY)
    THEN

      d_progress := 40.3;
      PO_DOCUMENT_ACTION_CHECK.authority_check(p_action_ctl_rec => p_action_ctl_rec);

    ELSIF (p_action_ctl_rec.action IN (PO_DOCUMENT_ACTION_PVT.g_doc_action_FREEZE,
                                       PO_DOCUMENT_ACTION_PVT.g_doc_action_UNFREEZE))
    THEN

      d_progress := 50.1;
      PO_DOCUMENT_ACTION_HOLD.freeze_unfreeze(p_action_ctl_rec => p_action_ctl_rec);

    ELSIF (p_action_ctl_rec.action IN (PO_DOCUMENT_ACTION_PVT.g_doc_action_HOLD,
                                       PO_DOCUMENT_ACTION_PVT.g_doc_action_RELEASE_HOLD))
    THEN

      d_progress := 50.2;
      PO_DOCUMENT_ACTION_HOLD.hold_unhold(p_action_ctl_rec => p_action_ctl_rec);

    ELSIF (p_action_ctl_rec.action IN (PO_DOCUMENT_ACTION_PVT.g_doc_action_CLOSE,
                                       PO_DOCUMENT_ACTION_PVT.g_doc_action_CLOSE_RCV,
                                       PO_DOCUMENT_ACTION_PVT.g_doc_action_CLOSE_INV,
                                       PO_DOCUMENT_ACTION_PVT.g_doc_action_FINALLY_CLOSE,
                                       PO_DOCUMENT_ACTION_PVT.g_doc_action_OPEN,
                                       PO_DOCUMENT_ACTION_PVT.g_doc_action_OPEN_RCV,
                                       PO_DOCUMENT_ACTION_PVT.g_doc_action_OPEN_INV))
    THEN

      d_progress := 60.1;
      PO_DOCUMENT_ACTION_CLOSE.manual_close_po(p_action_ctl_rec => p_action_ctl_rec);

    ELSIF (p_action_ctl_rec.action = PO_DOCUMENT_ACTION_PVT.g_doc_action_UPDATE_CLOSE_AUTO)
    THEN

      d_progress := 60.2;
      PO_DOCUMENT_ACTION_CLOSE.auto_close_po(p_action_ctl_rec => p_action_ctl_rec);

    ELSE

      d_progress := 100;
      d_log_msg := 'unsupported action type';
      l_ret_sts := 'U';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;  -- IF (p_action_ctl_rec.action = ...)

    IF (p_action_ctl_rec.return_status = 'U')
    THEN

      d_progress := 110;
      d_log_msg := 'unexpected error in action call';
      l_ret_sts := 'U';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    IF (p_action_ctl_rec.return_status = 'E')
    THEN

      d_progress := 115;
      d_log_msg := 'functional error in action call';
      l_ret_sts := 'E';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 120;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'action call complete');
    END IF;


    -- Handle inbound logistics for SPOs and Blanket Releases

    IF (((p_action_ctl_rec.document_type = 'PO') AND (p_action_ctl_rec.document_subtype = 'STANDARD'))
      OR ((p_action_ctl_rec.document_type = 'RELEASE') AND (p_action_ctl_rec.document_subtype = 'BLANKET')))
    THEN

      --<Bug# 5766607> PO-OTM: HOLD/UNHOLD ACTIONS RAISED FROM HTML DO NOT COMMUNICATED TO OTM.
      --Remove the filter on the action types. All actions will be handled properly
      --in the create_update_delrec procedure.
      d_progress := 130;

      PO_DELREC_PVT.create_update_delrec(
         p_api_version    => 1.0
      ,  x_return_status => l_ret_sts
      ,  x_msg_count     => l_msg_count
      ,  x_msg_data      => l_msg_data
      ,  p_action        => p_action_ctl_rec.action
      ,  p_doc_type      => p_action_ctl_rec.document_type
      ,  p_doc_subtype   => p_action_ctl_rec.document_subtype
      ,  p_doc_id        => p_action_ctl_rec.document_id
      ,  p_line_id       => p_action_ctl_rec.line_id
      ,  p_line_location_id => p_action_ctl_rec.shipment_id
      );

      IF (l_ret_sts <> 'S')
      THEN

        d_progress := 140;
        d_log_msg := 'create_update_delrec not successful';
        FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
        error_msg_append(d_module, d_progress, l_msg_data);
        l_ret_sts := 'U';
        RAISE PO_CORE_S.g_early_return_exc;

      END IF;

    END IF;  -- p_action_ctl_rec.document_type = 'PO' AND ...

    d_progress := 150;
    p_action_ctl_rec.error_msg := NULL;
    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      IF (l_ret_sts = 'U') THEN
        IF (l_msg_data IS NOT NULL) THEN
          error_msg_append(d_module, d_progress, l_msg_data);
        END IF;
        error_msg_append(d_module, d_progress, d_log_msg);
        get_error_message(p_action_ctl_rec.error_msg);
        IF (PO_LOG.d_exc) THEN
          PO_LOG.exc(d_module, d_progress, d_log_msg);
        END IF;
        ROLLBACK TO DA_DO_ACTION_SP;
      ELSIF (l_ret_sts = 'E') THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, d_log_msg);
        END IF;
      END IF;
  END;

  d_progress := 160;
--<R12 MOAC IMPACT>
--  Reset org context to what it was before we set
--  the org context to document's org context

--  We do not need to check for org context being
--  set to null as this is a valid scenario from HTML
--  A null org id implies multiple org context

    po_moac_utils_pvt.set_org_context(l_old_org_id); --<R12 MOAC>

--<R12 MOAC IMPACT>

  p_action_ctl_rec.return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_code', p_action_ctl_rec.return_code);
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.functional_error', p_action_ctl_rec.functional_error);
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.error_msg', p_action_ctl_rec.error_msg);
    PO_LOG.proc_end(d_module);
  END IF;


  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    p_action_ctl_rec.return_status := 'U';

    error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);
    get_error_message(p_action_ctl_rec.error_msg);
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
      PO_LOG.proc_end(d_module, 'p_action_ctl_rec.functional_error', p_action_ctl_rec.functional_error);
      PO_LOG.proc_end(d_module, 'p_action_ctl_rec.error_msg', p_action_ctl_rec.error_msg);
      PO_LOG.proc_end(d_module);
    END IF;

    ROLLBACK TO DA_DO_ACTION_SP;

    -- Reset org context to what it was before we set
    -- the org context to document's org context
--<R12 MOAC IMPACT>
    --IF (l_old_org_id IS NOT NULL)
    --THEN
      po_moac_utils_pvt.set_org_context(l_old_org_id); --<R12 MOAC>
--    END IF;
--<R12 MOAC IMPACT>
    RETURN;

END do_action;


------------------------------------------------------------------------------
--Start of Comments
--Name: do_approve
--Pre-reqs:
--  None
--Modifies:
--  None, directly.
--Locks:
--  None, directly.  Through do_action, locks the document header.
--Function:
--  Approves a document as current user.
--  Does not do any kind of status or state checking.
--  Uses do_action switchboard
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO', 'PA', or 'REQUISITION'
--  p_document_subtype
--    REQUISITION: 'INTERNAL', 'PURCHASE'
--    PO: 'STANDARD', 'PLANNED'
--    PA: 'CONTRACT', 'BLANKET'
--    RELEASE: 'SCHEDULED', 'BLANKET'
--  p_note
--    To be stored in action history table.
--  p_approval_path_id
--    To be stored in action history table.
--OUT:
--  x_return_status
--    'S': Approve action was successful
--    'U': Approve action failed
--  x_exception_message
--    If x_return_status = 'U', this parameter will
--    contain an error stack in concatenated string form.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_approve(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_note               IN           VARCHAR2
,  p_approval_path_id   IN           NUMBER
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
)
IS

l_da_call_rec   DOC_ACTION_CALL_REC_TYPE;

BEGIN

  l_da_call_rec.action := g_doc_action_APPROVE;
  l_da_call_rec.lock_document := TRUE;
  l_da_call_rec.document_id := p_document_id;
  l_da_call_rec.document_type := p_document_type;
  l_da_call_rec.document_subtype := p_document_subtype;
  l_da_call_rec.new_document_status := g_doc_status_APPROVED;
  l_da_call_rec.forward_to_id := NULL;
  l_da_call_rec.note := p_note;
  l_da_call_rec.approval_path_id := p_approval_path_id;
  l_da_call_rec.line_id := NULL;
  l_da_call_rec.shipment_id := NULL;
  l_da_call_rec.offline_code := NULL;

  do_action(p_action_ctl_rec => l_da_call_rec);

  x_exception_msg := l_da_call_rec.error_msg;
  x_return_status := l_da_call_rec.return_status;

END do_approve;


------------------------------------------------------------------------------
--Start of Comments
--Name: do_reject
--Pre-reqs:
--  None
--Modifies:
--  None, directly.
--Locks:
--  None, directly.  Through do_action, locks the document header.
--Function:
--  Rejects a document as current user.
--  Does a document state check before attempting to reject.
--  Uses do_action switchboard
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO', 'PA'
--  p_document_subtype
--    PO: 'STANDARD', 'PLANNED'
--    PA: 'CONTRACT', 'BLANKET'
--    RELEASE: 'SCHEDULED', 'BLANKET'
--  p_note
--    To be stored in action history table.
--  p_approval_path_id
--    To be stored in action history table.
--OUT:
--  x_return_status
--    'S': Reject action had no unexpected errors
--         In this case, check return_code for success/failure.
--    'U': Reject action failed with unexpected errors
--  x_return_code
--    'STATE_FAILED': Document state check failed
--    'P', 'F', 'T': Encumbrance call not fully successful.
--    NULL: reject action was successful
--  x_exception_message
--    If x_return_status = 'U', this parameter will
--    contain an error stack in concatenated string form.
--  x_online_report_id
--    ID to online report containing more detailed encumbrance results
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_reject(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_note               IN           VARCHAR2
,  p_approval_path_id   IN           NUMBER
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
,  x_online_report_id   OUT  NOCOPY  NUMBER
)
IS

l_da_call_rec   DOC_ACTION_CALL_REC_TYPE;

BEGIN

  l_da_call_rec.action := g_doc_action_REJECT;
  l_da_call_rec.lock_document := TRUE;
  l_da_call_rec.document_id := p_document_id;
  l_da_call_rec.document_type := p_document_type;
  l_da_call_rec.document_subtype := p_document_subtype;
  l_da_call_rec.forward_to_id := NULL;
  l_da_call_rec.new_document_status := g_doc_status_REJECTED;
  l_da_call_rec.note := p_note;
  l_da_call_rec.approval_path_id := p_approval_path_id;
  l_da_call_rec.offline_code := NULL;
  l_da_call_rec.online_report_id := NULL;

  do_action(p_action_ctl_rec => l_da_call_rec);

  x_exception_msg    := l_da_call_rec.error_msg;
  x_return_code      := l_da_call_rec.return_code;
  x_online_report_id := l_da_call_rec.online_report_id;
  x_return_status    := l_da_call_rec.return_status;


END do_reject;

------------------------------------------------------------------------------
--Start of Comments
--Name: do_return
--Pre-reqs:
--  None
--Modifies:
--  None, directly.
--Locks:
--  None, directly.  Through do_action, locks the document header.
--Function:
--  Returns a requisition as current user, removing it from
--  the requisition pool.
--  Does a document state check before attempting to return.
--  Uses do_action switchboard
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'REQUISITION'
--  p_document_subtype
--    REQUISITION: 'INTERNAL', 'PURCHASE'
--  p_note
--    To be stored in action history table.
--  p_approval_path_id
--    To be stored in action history table.
--OUT:
--  x_return_status
--    'S': Return action had no unexpected errors
--         In this case, check return_code for success/failure.
--    'U': Return action failed with unexpected errors
--  x_return_code
--    'STATE_FAILED': Document state check failed
--    'P', 'F', 'T': Encumbrance call not fully successful.
--    NULL: return action was successful
--  x_exception_message
--    If x_return_status = 'U', this parameter will
--    contain an error stack in concatenated string form.
--  x_online_report_id
--    ID to online report containing more detailed encumbrance results
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_return(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_note               IN           VARCHAR2
,  p_approval_path_id   IN           NUMBER
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
,  x_online_report_id   OUT  NOCOPY  NUMBER
)
IS

l_da_call_rec   DOC_ACTION_CALL_REC_TYPE;

BEGIN

  l_da_call_rec.action := g_doc_action_RETURN;
  l_da_call_rec.lock_document := TRUE;
  l_da_call_rec.document_id := p_document_id;
  l_da_call_rec.document_type := p_document_type;
  l_da_call_rec.document_subtype := p_document_subtype;
  l_da_call_rec.forward_to_id := NULL;
  l_da_call_rec.new_document_status := NULL;
  l_da_call_rec.note := p_note;
  l_da_call_rec.approval_path_id := p_approval_path_id;
  l_da_call_rec.offline_code := NULL;
  l_da_call_rec.online_report_id := NULL;

  do_action(p_action_ctl_rec => l_da_call_rec);

  x_exception_msg    := l_da_call_rec.error_msg;
  x_return_code      := l_da_call_rec.return_code;
  x_online_report_id := l_da_call_rec.online_report_id;
  x_return_status    := l_da_call_rec.return_status;


END do_return;

------------------------------------------------------------------------------
--Start of Comments
--Name: do_forward
--Pre-reqs:
--  None
--Modifies:
--  None, directly.
--Locks:
--  None, directly.  Through do_action, locks the document header.
--Function:
--  Forwards a document from the current user.
--  Does not do any kind of status or state checking.
--  Uses do_action switchboard
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO', 'PA', or 'REQUISITION'
--  p_document_subtype
--    REQUISITION: 'INTERNAL', 'PURCHASE'
--    PO: 'STANDARD', 'PLANNED'
--    PA: 'CONTRACT', 'BLANKET'
--    RELEASE: 'SCHEDULED', 'BLANKET'
--  p_new_doc_status
--    status the document should be in after forward action completes.
--    Should be g_doc_action_PREAPPROVED or g_doc_action_INPROCESS
--  p_note
--    To be stored in action history table.
--  p_approval_path_id
--    To be stored in action history table.
--  p_forward_to_id
--    ID of employee to forward document to
--OUT:
--  x_return_status
--    'S': Forward action was successful
--    'U': Forward action failed
--  x_exception_message
--    If x_return_status = 'U', this parameter will
--    contain an error stack in concatenated string form.
--End of Comments
------------------------------------------------------------------------------
PROCEDURE do_forward(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_new_doc_status     IN           VARCHAR2
,  p_note               IN           VARCHAR2
,  p_approval_path_id   IN           NUMBER
,  p_forward_to_id      IN           NUMBER
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
)
IS

l_da_call_rec   DOC_ACTION_CALL_REC_TYPE;

BEGIN

  l_da_call_rec.action := g_doc_action_FORWARD;
  l_da_call_rec.lock_document := TRUE;
  l_da_call_rec.document_id := p_document_id;
  l_da_call_rec.document_type := p_document_type;
  l_da_call_rec.document_subtype := p_document_subtype;
  l_da_call_rec.new_document_status := p_new_doc_status;
  l_da_call_rec.note := p_note;
  l_da_call_rec.approval_path_id := p_approval_path_id;
  l_da_call_rec.forward_to_id := p_forward_to_id;
  l_da_call_rec.offline_code := NULL;

  do_action(p_action_ctl_rec => l_da_call_rec);

  x_exception_msg := l_da_call_rec.error_msg;
  x_return_status := l_da_call_rec.return_status;

END do_forward;



------------------------------------------------------------------------------
--Start of Comments
--Name: verify_authority.
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Verify the authority of an employee to approve a document.
--  Verifies against the various po control rules.
--  Uses do_action switchboard
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO', 'PA', or 'REQUISITION'
--  p_document_subtype
--    REQUISITION: 'INTERNAL', 'PURCHASE'
--    PO: 'STANDARD', 'PLANNED'
--    PA: 'CONTRACT', 'BLANKET'
--    RELEASE: 'SCHEDULED', 'BLANKET'
--  p_employee_id
--    The id of the employee to verify approval authority for.
--OUT:
--  x_return_status
--    'S': Verification encountered no unexpected errors.
--         In this case, check return_code for success/failure.
--    'U': Verification encountered unexpected errors.
--  x_return_code
--    'AUTHORIZATION_FAILED': user does not have sufficient authority
--    NULL: user has sufficient authority to approve the document
--  x_exception_message
--    If x_return_status = 'U', this parameter will
--    contain an error stack in concatenated string form.
--  x_auth_failed_msg
--    If return_code is AUTHORIZATION_FAILED, then this will contain
--    a user friendly message indicating the check that failed.
--    e.g.: the value of FND_MESSAGE.get_string(PO, PO_AUT_DOC_TOTAL_FAIL);
--End of Comments
------------------------------------------------------------------------------
PROCEDURE verify_authority(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_employee_id        IN           VARCHAR2
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
,  x_auth_failed_msg    OUT  NOCOPY  VARCHAR2
)
IS

l_da_call_rec   DOC_ACTION_CALL_REC_TYPE;

BEGIN

  l_da_call_rec.action := g_doc_action_CHECK_AUTHORITY;
  l_da_call_rec.lock_document := FALSE;
  l_da_call_rec.document_id := p_document_id;
  l_da_call_rec.document_type := p_document_type;
  l_da_call_rec.document_subtype := p_document_subtype;
  l_da_call_rec.employee_id := p_employee_id;

  do_action(p_action_ctl_rec => l_da_call_rec);

  x_exception_msg := l_da_call_rec.error_msg;
  x_return_code   := l_da_call_rec.return_code;
  x_auth_failed_msg := l_da_call_rec.functional_error;
  x_return_status := l_da_call_rec.return_status;

END verify_authority;


------------------------------------------------------------------------------
--Start of Comments
--Name: check_doc_status_approve
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Verify that a document is in appropriate state for the approve action.
--  Verifies authorization status, closed status, frozen flag, etc.
--  Uses do_action switchboard
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO', 'PA', or 'REQUISITION'
--  p_document_subtype
--    REQUISITION: 'INTERNAL', 'PURCHASE'
--    PO: 'STANDARD', 'PLANNED'
--    PA: 'CONTRACT', 'BLANKET'
--    RELEASE: 'SCHEDULED', 'BLANKET'
--OUT:
--  x_return_status
--    'S': Verification encountered no unexpected errors.
--         In this case, check return_code for success/failure.
--    'U': State verification encountered unexpected errors.
--  x_return_code
--    'STATE_FAILED': document is not in valid state for approve action
--    NULL: document is in valid state for approve action
--  x_exception_message
--    If x_return_status = 'U', this parameter will
--    contain an error stack in concatenated string form.
--End of Comments
------------------------------------------------------------------------------
PROCEDURE check_doc_status_approve(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
)
IS

l_da_call_rec   DOC_ACTION_CALL_REC_TYPE;

BEGIN

  l_da_call_rec.action := g_doc_action_CHECK_APPROVE;
  l_da_call_rec.lock_document := FALSE;
  l_da_call_rec.document_id := p_document_id;
  l_da_call_rec.document_type := p_document_type;
  l_da_call_rec.document_subtype := p_document_subtype;

  do_action(p_action_ctl_rec => l_da_call_rec);

  x_exception_msg := l_da_call_rec.error_msg;
  x_return_code   := l_da_call_rec.return_code;
  x_return_status := l_da_call_rec.return_status;

END check_doc_status_approve;

------------------------------------------------------------------------------
--Start of Comments
--Name: check_doc_status_reject
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Verify that a document is in appropriate state for the reject action.
--  Verifies authorization status, closed status, frozen flag, etc.
--  Uses do_action switchboard
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO', 'PA', or 'REQUISITION'
--  p_document_subtype
--    REQUISITION: 'INTERNAL', 'PURCHASE'
--    PO: 'STANDARD', 'PLANNED'
--    PA: 'CONTRACT', 'BLANKET'
--    RELEASE: 'SCHEDULED', 'BLANKET'
--OUT:
--  x_return_status
--    'S': Verification encountered no unexpected errors.
--         In this case, check return_code for success/failure.
--    'U': State verification encountered unexpected errors.
--  x_return_code
--    'STATE_FAILED': document is not in valid state for reject action
--    NULL: document is in valid state for reject action
--  x_exception_message
--    If x_return_status = 'U', this parameter will
--    contain an error stack in concatenated string form.
--End of Comments
------------------------------------------------------------------------------
PROCEDURE check_doc_status_reject(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
)
IS

l_da_call_rec   DOC_ACTION_CALL_REC_TYPE;

BEGIN

  l_da_call_rec.action := g_doc_action_CHECK_REJECT;
  l_da_call_rec.lock_document := FALSE;
  l_da_call_rec.document_id := p_document_id;
  l_da_call_rec.document_type := p_document_type;
  l_da_call_rec.document_subtype := p_document_subtype;

  do_action(p_action_ctl_rec => l_da_call_rec);

  x_exception_msg := l_da_call_rec.error_msg;
  x_return_code   := l_da_call_rec.return_code;
  x_return_status := l_da_call_rec.return_status;

END check_doc_status_reject;


------------------------------------------------------------------------------
--Start of Comments
--Name: do_freeze
--Pre-reqs:
--  None
--Modifies:
--  None, directly.
--Locks:
--  None, directly.  Through do_action, locks the document header.
--Function:
--  Freezes a document as current user.
--  Does a document state check before attempting to freeze.
--  Uses do_action switchboard
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO', 'PA'
--  p_document_subtype
--    PO: 'STANDARD', 'PLANNED'
--    PA: 'CONTRACT', 'BLANKET'
--    RELEASE: 'SCHEDULED', 'BLANKET'
--  p_reason
--    To be stored in action history table.
--OUT:
--  x_return_status
--    'S': Freeze action had no unexpected errors
--         In this case, check return_code for success/failure.
--    'U': Freeze action failed with unexpected errors
--  x_return_code
--    'STATE_FAILED': Document state check failed
--    NULL: freeze action was successful
--  x_exception_message
--    If x_return_status = 'U', this parameter will
--    contain an error stack in concatenated string form.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_freeze(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_reason             IN           VARCHAR2
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
)
IS

l_da_call_rec   DOC_ACTION_CALL_REC_TYPE;

BEGIN

  l_da_call_rec.action := g_doc_action_FREEZE;
  l_da_call_rec.lock_document := TRUE;
  l_da_call_rec.document_id := p_document_id;
  l_da_call_rec.document_type := p_document_type;
  l_da_call_rec.document_subtype := p_document_subtype;
  l_da_call_rec.note := p_reason;

  do_action(p_action_ctl_rec => l_da_call_rec);

  x_exception_msg := l_da_call_rec.error_msg;
  x_return_code   := l_da_call_rec.return_code;
  x_return_status := l_da_call_rec.return_status;

END do_freeze;


------------------------------------------------------------------------------
--Start of Comments
--Name: do_unfreeze
--Pre-reqs:
--  None
--Modifies:
--  None, directly.
--Locks:
--  None, directly.  Through do_action, locks the document header.
--Function:
--  Unfreezes a document as current user.
--  Does a document state check before attempting to unfreeze.
--  Uses do_action switchboard
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO', 'PA'
--  p_document_subtype
--    PO: 'STANDARD', 'PLANNED'
--    PA: 'CONTRACT', 'BLANKET'
--    RELEASE: 'SCHEDULED', 'BLANKET'
--  p_reason
--    To be stored in action history table.
--OUT:
--  x_return_status
--    'S': Unfreeze action had no unexpected errors
--         In this case, check return_code for success/failure.
--    'U': Unfreeze action failed with unexpected errors
--  x_return_code
--    'STATE_FAILED': Document state check failed
--    NULL: Unfreeze action was successful
--  x_exception_message
--    If x_return_status = 'U', this parameter will
--    contain an error stack in concatenated string form.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_unfreeze(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_reason             IN           VARCHAR2
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
)
IS

l_da_call_rec   DOC_ACTION_CALL_REC_TYPE;

BEGIN

  l_da_call_rec.action := g_doc_action_UNFREEZE;
  l_da_call_rec.lock_document := TRUE;
  l_da_call_rec.document_id := p_document_id;
  l_da_call_rec.document_type := p_document_type;
  l_da_call_rec.document_subtype := p_document_subtype;
  l_da_call_rec.note := p_reason;

  do_action(p_action_ctl_rec => l_da_call_rec);

  x_exception_msg := l_da_call_rec.error_msg;
  x_return_code   := l_da_call_rec.return_code;
  x_return_status := l_da_call_rec.return_status;

END do_unfreeze;


------------------------------------------------------------------------------
--Start of Comments
--Name: do_hold
--Pre-reqs:
--  None
--Modifies:
--  None, directly.
--Locks:
--  None, directly.  Through do_action, locks the document header.
--Function:
--  Puts a hold on a document as current user.
--  Does a document state check before attempting to hold.
--  Uses do_action switchboard
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO', 'PA'
--  p_document_subtype
--    PO: 'STANDARD', 'PLANNED'
--    PA: 'CONTRACT', 'BLANKET'
--    RELEASE: 'SCHEDULED', 'BLANKET'
--  p_reason
--    To be stored in action history table.
--OUT:
--  x_return_status
--    'S': Hold action had no unexpected errors
--         In this case, check return_code for success/failure.
--    'U': Hold action failed with unexpected errors
--  x_return_code
--    'STATE_FAILED': Document state check failed
--    NULL: hold action was successful
--  x_exception_message
--    If x_return_status = 'U', this parameter will
--    contain an error stack in concatenated string form.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_hold(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_reason             IN           VARCHAR2
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
)
IS

l_da_call_rec   DOC_ACTION_CALL_REC_TYPE;

BEGIN

  l_da_call_rec.action := g_doc_action_HOLD;
  l_da_call_rec.lock_document := TRUE;
  l_da_call_rec.document_id := p_document_id;
  l_da_call_rec.document_type := p_document_type;
  l_da_call_rec.document_subtype := p_document_subtype;
  l_da_call_rec.note := p_reason;

  do_action(p_action_ctl_rec => l_da_call_rec);

  x_exception_msg := l_da_call_rec.error_msg;
  x_return_code   := l_da_call_rec.return_code;
  x_return_status := l_da_call_rec.return_status;

END do_hold;

------------------------------------------------------------------------------
--Start of Comments
--Name: do_release_hold
--Pre-reqs:
--  None
--Modifies:
--  None, directly.
--Locks:
--  None, directly.  Through do_action, locks the document header.
--Function:
--  Releases a hold on a document as current user.
--  Does a document state check before attempting to release hold.
--  Uses do_action switchboard
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO', 'PA'
--  p_document_subtype
--    PO: 'STANDARD', 'PLANNED'
--    PA: 'CONTRACT', 'BLANKET'
--    RELEASE: 'SCHEDULED', 'BLANKET'
--  p_reason
--    To be stored in action history table.
--OUT:
--  x_return_status
--    'S': Release hold action had no unexpected errors
--         In this case, check return_code for success/failure.
--    'U': Release hold action failed with unexpected errors
--  x_return_code
--    'STATE_FAILED': Document state check failed
--    NULL: release hold action was successful
--  x_exception_message
--    If x_return_status = 'U', this parameter will
--    contain an error stack in concatenated string form.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_release_hold(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_reason             IN           VARCHAR2
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
)
IS

l_da_call_rec   DOC_ACTION_CALL_REC_TYPE;

BEGIN

  l_da_call_rec.action := g_doc_action_RELEASE_HOLD;
  l_da_call_rec.lock_document := TRUE;
  l_da_call_rec.document_id := p_document_id;
  l_da_call_rec.document_type := p_document_type;
  l_da_call_rec.document_subtype := p_document_subtype;
  l_da_call_rec.note := p_reason;

  do_action(p_action_ctl_rec => l_da_call_rec);

  x_exception_msg := l_da_call_rec.error_msg;
  x_return_code   := l_da_call_rec.return_code;
  x_return_status := l_da_call_rec.return_status;

END do_release_hold;

------------------------------------------------------------------------------
--Start of Comments
--Name: find_forward_to_id
--Pre-reqs:
--  Org Context must be set.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Find the next employee in the approval chain that
--  has the authority to approve the document.
--  Unlike other actions in this package, find_forward_to_id does
--  not directly call the do_action switchboard;
--  instead its logic calls verify_authority many times.
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO', 'PA', or 'REQUISITION'
--  p_document_subtype
--    REQUISITION: 'INTERNAL', 'PURCHASE'
--    PO: 'STANDARD', 'PLANNED'
--    PA: 'CONTRACT', 'BLANKET'
--    RELEASE: 'SCHEDULED', 'BLANKET'
--  p_employee_id
--    The id of the employee to forward from.
--  p_approval_path_id
--    The position structure id to use in po_employee_hierarchies
--OUT:
--  x_return_status
--    'S': Method encountered no unexpected errors.
--    'U': Method encountered unexpected errors.
--  x_forward_to_od
--    Contains forward_to_id of supervisor that can approve document.
--    Can return null if no one with authority is found.
--    Only valid if x_return_status = 'S'
--End of Comments
------------------------------------------------------------------------------
PROCEDURE find_forward_to_id(
   p_document_id        IN     NUMBER
,  p_document_type      IN     VARCHAR2
,  p_document_subtype   IN     VARCHAR2
,  p_employee_id        IN     NUMBER
,  p_approval_path_id   IN     NUMBER
,  x_return_status      OUT NOCOPY  VARCHAR2
,  x_forward_to_id      OUT NOCOPY  NUMBER
)
IS

d_progress        NUMBER;
d_module          VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_PVT.find_forward_to_id';
d_msg             VARCHAR2(200);

l_ret_sts         VARCHAR2(1) := 'S';  -- Bug 4448215
l_ret_code        VARCHAR2(25);
l_fwd_to_id       NUMBER;
l_exc_msg         VARCHAR2(2000);
l_fail_msg        VARCHAR2(2000);

l_forwarding_mode   PO_DOCUMENT_TYPES.forwarding_mode_code%TYPE;
l_using_positions   FINANCIALS_SYSTEM_PARAMETERS.use_positions_flag%TYPE;
l_bus_group_id      FINANCIALS_SYSTEM_PARAMETERS.business_group_id%TYPE;
l_hr_xbg_profile    VARCHAR2(1);

-- Bug 5386007: Replaced hr_employees_current_v with base tables to
-- improve performance
-- Bug12360617 Contingent worker should be defaulted on the forward_to
-- field.
CURSOR direct_pos(p_emp_id NUMBER, p_path_id NUMBER) IS
SELECT  /*+ ordered  use_nl (poeh a p  past b) */ poeh.superior_id
 FROM  po_employee_hierarchies_all poeh,
       per_all_people_f p,
       per_all_assignments_f a,
       per_assignment_status_types past
 WHERE a.person_id = p.person_id
 AND   poeh.business_group_id in (select fsp.business_group_id
                                 from financials_system_parameters fsp)
 AND a.primary_flag = 'Y'
 AND Trunc(SYSDATE) BETWEEN p.effective_start_date AND p.effective_end_date
 AND Trunc(SYSDATE) BETWEEN a.effective_start_date AND a.effective_end_date
 AND (NVL(CURRENT_EMPLOYEE_FLAG,'N') = 'Y'
          OR NVL(CURRENT_NPW_FLAG,'N') = 'Y')
 AND a.assignment_type in ('E',decode(
          nvl(fnd_profile.value('HR_TREAT_CWK_AS_EMP'),'N'),'Y','C','E'))
 AND a.assignment_status_type_id = past.assignment_status_type_id
 AND past.per_system_status IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN','ACTIVE_CWK')
 AND poeh.position_structure_id = p_path_id
 AND poeh.employee_id = p_emp_id
 AND p.person_id = poeh.superior_id
 AND poeh.superior_level > 0
 AND 'TRUE' = Decode(hr_security.view_all, 'Y', 'TRUE',
            hr_security.Show_person(p.person_id,
                                      p.current_applicant_flag,
                                      p.current_employee_flag,
                                      p.current_npw_flag,
                                      p.employee_number,
                                      p.applicant_number,
                                      p.npw_number))
 AND 'TRUE' =   Decode(hr_security.view_all, 'Y', 'TRUE',
              hr_security.Show_record('PER_ALL_ASSIGNMENTS_F',
                                      a.assignment_id,
                                      a.person_id,
                                      a.assignment_type))
 ORDER BY poeh.superior_level, p.full_name;

CURSOR direct_assign(p_emp_id NUMBER, p_bus_group_id NUMBER) IS
  SELECT pera.supervisor_id
  FROM per_assignments_f pera
  WHERE pera.business_group_id = p_bus_group_id
    AND trunc(SYSDATE) BETWEEN pera.effective_start_date
           AND pera.effective_end_date
  START WITH pera.person_id = p_emp_id
         AND pera.business_group_id = p_bus_group_id
         AND trunc(SYSDATE) BETWEEN pera.effective_start_date
                AND pera.effective_end_date
  CONNECT BY pera.person_id = PRIOR pera.supervisor_id
         AND pera.business_group_id = p_bus_group_id
         AND trunc(SYSDATE) BETWEEN pera.effective_start_date
                AND pera.effective_end_date;

CURSOR direct_assign_xbg(p_emp_id NUMBER) IS
  SELECT pera.supervisor_id
  FROM per_assignments_f pera
  WHERE trunc(SYSDATE) BETWEEN pera.effective_start_date
           AND pera.effective_end_date
  START WITH pera.person_id = p_emp_id
         AND trunc(SYSDATE) BETWEEN pera.effective_start_date
                AND pera.effective_end_date
  CONNECT BY pera.person_id = PRIOR pera.supervisor_id
         AND trunc(SYSDATE) BETWEEN pera.effective_start_date
                AND pera.effective_end_date;

-- Bug12360617 Contingent worker should be defaulted on the forward_to
-- field.
CURSOR hier_pos(p_emp_id NUMBER, p_path_id NUMBER) IS
SELECT  /*+ ordered  use_nl (poeh a p  past b) */ poeh.superior_id
 FROM  po_employee_hierarchies_all poeh,
       per_all_people_f p,
       per_all_assignments_f a,
       per_assignment_status_types past
 WHERE a.person_id = p.person_id
 AND   poeh.business_group_id in (select fsp.business_group_id
                                 from financials_system_parameters fsp)
 AND a.primary_flag = 'Y'
 AND Trunc(SYSDATE) BETWEEN p.effective_start_date AND p.effective_end_date
 AND Trunc(SYSDATE) BETWEEN a.effective_start_date AND a.effective_end_date
 AND (NVL(CURRENT_EMPLOYEE_FLAG,'N') = 'Y'
          OR NVL(CURRENT_NPW_FLAG,'N') = 'Y')
 AND a.assignment_type in ('E',decode(
          nvl(fnd_profile.value('HR_TREAT_CWK_AS_EMP'),'N'),'Y','C','E'))
 AND a.assignment_status_type_id = past.assignment_status_type_id
 AND past.per_system_status IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN','ACTIVE_CWK')
 AND poeh.position_structure_id = p_path_id
 AND poeh.employee_id = p_emp_id
 AND p.person_id = poeh.superior_id
 AND poeh.superior_level = 1
 AND 'TRUE' = Decode(hr_security.view_all, 'Y', 'TRUE',
            hr_security.Show_person(p.person_id,
                                      p.current_applicant_flag,
                                      p.current_employee_flag,
                                      p.current_npw_flag,
                                      p.employee_number,
                                      p.applicant_number,
                                      p.npw_number))
 AND 'TRUE' =   Decode(hr_security.view_all, 'Y', 'TRUE',
              hr_security.Show_record('PER_ALL_ASSIGNMENTS_F',
                                      a.assignment_id,
                                      a.person_id,
                                      a.assignment_type))
 ORDER BY p.full_name;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_employee_id', p_employee_id);
    PO_LOG.proc_begin(d_module, 'p_approval_path_id', p_approval_path_id);
  END IF;

  d_progress := 10;

  l_exc_msg := NULL;
  l_fwd_to_id := NULL;

  SELECT podt.forwarding_mode_code
  INTO l_forwarding_mode
  FROM po_document_types podt
  WHERE podt.document_type_code = p_document_type
    AND podt.document_subtype = p_document_subtype;

  d_progress := 15;

  SELECT NVL(fsp.use_positions_flag, 'N'), fsp.business_group_id
  INTO l_using_positions, l_bus_group_id
  FROM financials_system_parameters fsp;

  d_progress := 16;
  l_hr_xbg_profile := NVL(hr_general.get_xbg_profile, 'N');

  d_progress := 20;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'l_forwarding_mode', l_forwarding_mode);
    PO_LOG.stmt(d_module, d_progress, 'l_using_positions', l_using_positions);
    PO_LOG.stmt(d_module, d_progress, 'l_bus_group_id', l_bus_group_id);
    PO_LOG.stmt(d_module, d_progress, 'l_hr_xbg_profile', l_hr_xbg_profile);
  END IF;

  BEGIN

    IF (l_forwarding_mode = 'DIRECT')
    THEN

      d_progress := 30;

      IF (l_using_positions = 'Y')
      THEN

        d_progress := 40;

        OPEN direct_pos(p_employee_id, p_approval_path_id);
        LOOP
          d_progress := 50;
          FETCH direct_pos INTO l_fwd_to_id;
          EXIT WHEN (direct_pos%NOTFOUND IS NULL) OR (direct_pos%NOTFOUND);

          d_progress := 60;
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_progress, 'l_fwd_to_id', l_fwd_to_id);
          END IF;

          verify_authority(
             p_document_id      => p_document_id
          ,  p_document_type    => p_document_type
          ,  p_document_subtype => p_document_subtype
          ,  p_employee_id      => l_fwd_to_id
          ,  x_return_status    => l_ret_sts
          ,  x_return_code      => l_ret_code
          ,  x_exception_msg    => l_exc_msg
          ,  x_auth_failed_msg  => l_fail_msg
          );

          IF (l_ret_sts <> 'S')
          THEN
            d_progress := 70;
            d_msg := 'verify_authority threw unexpected error';
            l_ret_sts := 'U';
            RAISE PO_CORE_S.g_early_return_exc;
          END IF;

          IF (l_ret_code IS NULL)
          THEN
            -- this supervisor can approve the document;
            d_progress := 80;
            EXIT;
          END IF;

        END LOOP;

      ELSIF (l_hr_xbg_profile <> 'Y') THEN

        d_progress := 90;

        OPEN direct_assign(p_employee_id, p_approval_path_id);
        LOOP
          d_progress := 100;
          FETCH direct_assign INTO l_fwd_to_id;
          EXIT WHEN (direct_assign%NOTFOUND IS NULL) OR (direct_assign%NOTFOUND);

          d_progress := 110;
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_progress, 'l_fwd_to_id', l_fwd_to_id);
          END IF;

          verify_authority(
             p_document_id      => p_document_id
          ,  p_document_type    => p_document_type
          ,  p_document_subtype => p_document_subtype
          ,  p_employee_id      => l_fwd_to_id
          ,  x_return_status    => l_ret_sts
          ,  x_return_code      => l_ret_code
          ,  x_exception_msg    => l_exc_msg
          ,  x_auth_failed_msg  => l_fail_msg
          );

          IF (l_ret_sts <> 'S')
          THEN
            d_progress := 120;
            d_msg := 'verify_authority threw unexpected error';
            l_ret_sts := 'U';
            RAISE PO_CORE_S.g_early_return_exc;
          END IF;

          IF (l_ret_code IS NULL)
          THEN
            -- this supervisor can approve the document;
            d_progress := 130;
            EXIT;
          END IF;

        END LOOP;

      ELSE

        d_progress := 140;

        OPEN direct_assign_xbg(p_employee_id);
        LOOP
          d_progress := 150;
          FETCH direct_assign_xbg INTO l_fwd_to_id;
          EXIT WHEN (direct_assign_xbg%NOTFOUND IS NULL) OR (direct_assign_xbg%NOTFOUND);

          d_progress := 160;
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_progress, 'l_fwd_to_id', l_fwd_to_id);
          END IF;

          verify_authority(
             p_document_id      => p_document_id
          ,  p_document_type    => p_document_type
          ,  p_document_subtype => p_document_subtype
          ,  p_employee_id      => l_fwd_to_id
          ,  x_return_status    => l_ret_sts
          ,  x_return_code      => l_ret_code
          ,  x_exception_msg    => l_exc_msg
          ,  x_auth_failed_msg  => l_fail_msg
          );

          IF (l_ret_sts <> 'S')
          THEN
            d_progress := 170;
            d_msg := 'verify_authority threw unexpected error';
            l_ret_sts := 'U';
            RAISE PO_CORE_S.g_early_return_exc;
          END IF;

          IF (l_ret_code IS NULL)
          THEN
            -- this supervisor can approve the document;
            d_progress := 180;
            EXIT;
          END IF;

        END LOOP;

      END IF; -- l_using_positions = 'Y'

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'l_fwd_to_id', l_fwd_to_id);
      END IF;

    ELSIF (l_forwarding_mode = 'HIERARCHY')
    THEN

      IF (l_using_positions = 'Y')
      THEN

        d_progress := 200;
        OPEN hier_pos(p_employee_id, p_approval_path_id);
        FETCH hier_pos INTO l_fwd_to_id;
        IF ((hier_pos%NOTFOUND IS NULL) or (hier_pos%NOTFOUND))
        THEN
          l_fwd_to_id := NULL;
        END IF;

        d_progress := 210;

      ELSE

        d_progress := 220;

        BEGIN

          SELECT hre.supervisor_id
          INTO l_fwd_to_id
          FROM per_workforce_current_x hre       --R12 CWK Enhancement
          WHERE hre.person_id = p_employee_id;

        EXCEPTION
          WHEN no_data_found THEN
            l_fwd_to_id := NULL;
        END;

        d_progress := 230;

      END IF;  -- l_using_positions = 'Y'

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'l_fwd_to_id', l_fwd_to_id);
      END IF;

    ELSE

      l_ret_sts := 'U';
      d_msg := 'Invalid forwarding mode from po_document_types';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;  -- l_forwarding_mode = ...

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, d_msg);
        PO_LOG.stmt(d_module, d_progress, 'l_exc_msg', l_exc_msg);
      END IF;
  END;

  IF direct_pos%ISOPEN THEN
    CLOSE direct_pos;
  END IF;

  IF direct_assign%ISOPEN THEN
    CLOSE direct_assign;
  END IF;

  IF direct_assign_xbg%ISOPEN THEN
    CLOSE direct_assign_xbg;
  END IF;

  IF hier_pos%ISOPEN THEN
    CLOSE hier_pos;
  END IF;

  x_return_status := l_ret_sts;
  x_forward_to_id := l_fwd_to_id;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_forward_to_id', x_forward_to_id);
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF direct_pos%ISOPEN THEN
      CLOSE direct_pos;
    END IF;

    IF direct_assign%ISOPEN THEN
      CLOSE direct_assign;
    END IF;

    IF direct_assign_xbg%ISOPEN THEN
      CLOSE direct_assign_xbg;
    END IF;

    IF hier_pos%ISOPEN THEN
      CLOSE hier_pos;
    END IF;

    x_return_status := 'U';

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;
END find_forward_to_id;



------------------------------------------------------------------------------
--Start of Comments
--Name: auto_update_close_state
--Pre-reqs:
--  None
--Modifies:
--  None, directly.
--Locks:
--  None, directly.  Through do_action, locks the document header.
--Function:
--  Automatically updates the closed status of a document entity,
--  based on the quantities received and/or billed. For example, if
--  all of a shipment has been received, then the shipment is closed for
--  receiving.
--  Rolls up the close state as necessary.
--  Uses do_action switchboard
--  Replaces the UPDATE_CLOSE_STATE action in the Pro*C document manager
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO', 'PA'
--    This method does nothing for 'PA' except return successfully
--  p_document_subtype
--    PO: 'STANDARD', 'PLANNED'
--    PA: 'CONTRACT', 'BLANKET'
--    RELEASE: 'SCHEDULED', 'BLANKET'
--  p_line_id
--    If acting on a header, pass NULL
--    If acting on a line, pass in the po_line_id of the line.
--    If acting on a shipment, pass in the po_line_id of the shipment's line.
--  p_shipment_id
--    If acting on a header, pass NULL
--    If acting on a line, pass NULL
--    If acting on a shipment, pass in the line_location_id of the shipment
--  p_action_date
--    Used for encumbrance purposes for final close and invoice open actions
--    Defaults to SYSDATE
--  p_calling_mode
--    'PO', 'RCV', or 'AP'
--    Defaults to 'PO'
--  p_called_from_conc
--    Pass TRUE if this procedure is being called from within a concurrent program.
--    Pass FALSE otherwise
--    Defaults to FALSE
--    Used for getting the correct login_id.
--OUT:
--  x_return_status
--    'S': auto update close state action had no unexpected errors
--         In this case, check return_code for success/failure.
--    'U': auto update close state action failed with unexpected errors
--  x_return_code
--    'STATE_FAILED': Document state check failed
--    NULL: auto update close action action was successful
--  x_exception_message
--    If x_return_status = 'U', this parameter will
--    contain an error stack in concatenated string form.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE auto_update_close_state(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_document_subtype  IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  p_calling_mode      IN      VARCHAR2  DEFAULT  'PO'
,  p_called_from_conc  IN      BOOLEAN   DEFAULT  FALSE
,  x_return_status     OUT NOCOPY  VARCHAR2
,  x_exception_msg     OUT NOCOPY  VARCHAR2
,  x_return_code       OUT NOCOPY  VARCHAR2
)
IS

l_da_call_rec   DOC_ACTION_CALL_REC_TYPE;

BEGIN

  l_da_call_rec.action := g_doc_action_UPDATE_CLOSE_AUTO;
  l_da_call_rec.lock_document := TRUE;

  l_da_call_rec.document_id := p_document_id;
  l_da_call_rec.document_type := p_document_type;
  l_da_call_rec.document_subtype := p_document_subtype;
  l_da_call_rec.line_id := p_line_id;
  l_da_call_rec.shipment_id := p_shipment_id;
  l_da_call_rec.calling_mode := p_calling_mode;
  l_da_call_rec.called_from_conc := p_called_from_conc;

  do_action(p_action_ctl_rec => l_da_call_rec);

  x_exception_msg := l_da_call_rec.error_msg;
  x_return_code   := l_da_call_rec.return_code;
  x_return_status := l_da_call_rec.return_status;

END auto_update_close_state;


------------------------------------------------------------------------------
--Start of Comments
--Name: do_manual_close
--Pre-reqs:
--  None
--Modifies:
--  None, directly.
--Locks:
--  None, directly.  Through do_action, locks the document header.
--Function:
--  Sets the closed status of a document entity, depending on
--  the close or open action passed in via p_action.
--  Rolls up the closed status as necessary when closing a line or shipment.
--  Uses do_action switchboard
--Parameters:
--IN:
--  p_action
--    Use one of PO_DOCUMENT_ACTION_PVT.g_doc_action<>
--    Where <> could be:
--      OPEN, CLOSE, CLOSE_RCV, OPEN_RCV, CLOSE_INV, OPEN_INV, or FINALLY_CLOSE
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO', 'PA'
--  p_document_subtype
--    PO: 'STANDARD', 'PLANNED'
--    PA: 'CONTRACT', 'BLANKET'
--    RELEASE: 'SCHEDULED', 'BLANKET'
--  p_line_id
--    If acting on a header, pass NULL
--    If acting on a line, pass in the po_line_id of the line.
--    If acting on a shipment, pass in the po_line_id of the shipment's line.
--  p_shipment_id
--    If acting on a header, pass NULL
--    If acting on a line, pass NULL
--    If acting on a shipment, pass in the line_location_id of the shipment
--  p_reason
--    To be stored as the closed_reason on the line or shipment,
--    or as the note in the action history table.
--  p_action_date
--    Used for encumbrance purposes for final close and invoice open actions
--    Defaults to SYSDATE
--  p_calling_mode
--    'PO', 'RCV', or 'AP'
--    Defaults to 'PO'
--  p_origin_doc_id
--    For final close and invoice open actions, the id of the invoice
--    NULL otherwise
--    Defaults to NULL
--  p_called_from_conc
--    Pass TRUE if this procedure is being called from within a concurrent program.
--    Pass FALSE otherwise
--    Defaults to FALSE
--    Used for getting the correct login_id.
--  p_use_gl_date
--    'Y' or 'N'
--    Defaults to 'N'
--    Needed for encumbrance purposes, for final_close and invoice_open actions
--OUT:
--  x_return_status
--    'S': manual close action had no unexpected errors
--         In this case, check return_code for success/failure.
--    'U': manual close action failed with unexpected errors
--  x_return_code
--    'STATE_FAILED': Document state check failed
--    'SUBMISSION_FAILED': Submission check failed for final close action
--    'P', 'F', 'T': Encumbrance call not fully successful.
--    NULL: manual close action was successful
--  x_exception_message
--    If x_return_status = 'U', this parameter will
--    contain an error stack in concatenated string form.
--  x_online_report_id
--    ID to online report containing more detailed submission check
--    or encumbrance results
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_manual_close(
   p_action            IN      VARCHAR2
,  p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_document_subtype  IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  p_reason            IN      VARCHAR2
,  p_action_date       IN      DATE      DEFAULT  SYSDATE
,  p_calling_mode      IN      VARCHAR2  DEFAULT  'PO'
,  p_origin_doc_id     IN      NUMBER    DEFAULT  NULL
,  p_called_from_conc  IN      BOOLEAN   DEFAULT  FALSE
,  p_use_gl_date       IN      VARCHAR2  DEFAULT  'N'
,  x_return_status     OUT NOCOPY  VARCHAR2
,  x_exception_msg     OUT NOCOPY  VARCHAR2
,  x_return_code       OUT NOCOPY  VARCHAR2
,  x_online_report_id  OUT NOCOPY  NUMBER
)
IS

l_da_call_rec   DOC_ACTION_CALL_REC_TYPE;

BEGIN

  l_da_call_rec.action := p_action;
  l_da_call_rec.lock_document := TRUE;

  l_da_call_rec.document_id := p_document_id;
  l_da_call_rec.document_type := p_document_type;
  l_da_call_rec.document_subtype := p_document_subtype;
  l_da_call_rec.line_id := p_line_id;
  l_da_call_rec.shipment_id := p_shipment_id;
  l_da_call_rec.note := p_reason;
  l_da_call_rec.action_date := p_action_date;
  l_da_call_rec.calling_mode := p_calling_mode;
  l_da_call_rec.origin_doc_id := p_origin_doc_id;
  l_da_call_rec.called_from_conc := p_called_from_conc;
  l_da_call_rec.use_gl_date := p_use_gl_date;

  do_action(p_action_ctl_rec => l_da_call_rec);

  x_online_report_id := l_da_call_rec.online_report_id;
  x_exception_msg := l_da_call_rec.error_msg;
  x_return_code   := l_da_call_rec.return_code;
  x_return_status := l_da_call_rec.return_status;

END do_manual_close;


-- Methods intended to be used only within PO_DOCUMENT_ACTION_XXXX packages

-- get the current error stack
PROCEDURE get_error_message(
  x_error_message        OUT NOCOPY     VARCHAR2
)
IS
BEGIN

  x_error_message := g_err_message;

END get_error_message;

-- append to the error stack
PROCEDURE error_msg_append(
   p_subprogram_name     IN           VARCHAR2
,  p_position            IN           NUMBER
,  p_message_text        IN           VARCHAR2
)
IS
BEGIN

  IF (g_err_message IS NULL)
  THEN

    g_err_message := substr(p_subprogram_name || ':' || p_position || ':' || p_message_text, 1, 2000);

  ELSE

    g_err_message := substr(g_err_message || ' -  ' || p_subprogram_name || ':' || p_position || ':' || p_message_text, 1, 2000);

  END IF;  -- g_err_message IS NULL

END error_msg_append;

-- append to the error stack
PROCEDURE error_msg_append(
   p_subprogram_name     IN           VARCHAR2
,  p_position            IN           NUMBER
,  p_sqlcode             IN           NUMBER
,  p_sqlerrm             IN           VARCHAR2
)
IS
BEGIN

  error_msg_append(p_subprogram_name, p_position, p_sqlcode || p_sqlerrm);

END error_msg_append;

-- <R12 BEGIN INVCONV>
PROCEDURE update_secondary_qty_cancelled (
   p_join_column         IN           VARCHAR2
,  p_entity_id           IN           NUMBER
)
IS
   CURSOR cur_ship_lines
   IS
      SELECT pol.item_id, poll.ship_to_organization_id, poll.po_header_id, poll.po_line_id,
             poll.line_location_id, poll.po_release_id, poll.quantity_cancelled,
             pol.unit_meas_lookup_code, poll.secondary_unit_of_measure
        FROM po_line_locations poll, po_lines pol;

   TYPE rc IS REF CURSOR;

   l_cursor              rc;
   l_ship_rec            cur_ship_lines%ROWTYPE;
   l_ship_column_list    VARCHAR2 (2000);
   l_ship_table_list     VARCHAR2 (2000);
   l_ship_where_clause   VARCHAR2 (2000);
   l_converted_qty       NUMBER;
BEGIN
   -- assign column list
   l_ship_column_list :=
         'pol.item_id, poll.ship_to_organization_id, poll.po_header_id, poll.po_line_id, '
      || 'poll.line_location_id, poll.po_release_id, poll.quantity_cancelled, '
      || 'pol.unit_meas_lookup_code, poll.secondary_unit_of_measure ';

   -- assign table list
   l_ship_table_list := 'po_line_locations poll, po_lines pol ';

   -- build where clause
   l_ship_where_clause := 'poll.' || p_join_column || ' = ' || p_entity_id;
   l_ship_where_clause := l_ship_where_clause  || ' AND poll.po_line_id = pol.po_line_id ';
   l_ship_where_clause := l_ship_where_clause
             || ' AND   nvl(poll.cancel_flag, ' || '''N''' || ') = ' || '''I''';
   l_ship_where_clause := l_ship_where_clause
             || ' AND   nvl(poll.closed_code, ' || '''OPEN''' || ') != ' || '''FINALLY CLOSED''';
   l_ship_where_clause := l_ship_where_clause || ' AND poll.secondary_unit_of_measure is not null ';

   OPEN l_cursor
    FOR    'select '
        || l_ship_column_list
        || ' from '
        || l_ship_table_list
        || ' where '
        || l_ship_where_clause;

   LOOP
      FETCH l_cursor
       INTO l_ship_rec;

      EXIT WHEN l_cursor%NOTFOUND;
      l_converted_qty :=
         inv_convert.inv_um_convert (organization_id      => l_ship_rec.ship_to_organization_id,
                                     item_id              => l_ship_rec.item_id,
                                     lot_number           => NULL,
                                     precision            => 5,
                                     from_quantity        => l_ship_rec.quantity_cancelled,
                                     from_unit            => NULL,
                                     to_unit              => NULL,
                                     from_name            => l_ship_rec.unit_meas_lookup_code,
                                     to_name              => l_ship_rec.secondary_unit_of_measure
                                    );

      IF (l_converted_qty <> -99999)
      THEN
         UPDATE po_line_locations
            SET secondary_quantity_cancelled = l_converted_qty
          WHERE line_location_id = l_ship_rec.line_location_id;
      END IF;
   END LOOP;

   CLOSE l_cursor;
END update_secondary_qty_cancelled;
-- <R12 END INVCONV>

------------------------------------------------------------------------------
--Start of Comments
--Name: do_cancel
--Pre-reqs:
--  None
--Modifies:
--   All cancel columns and who columns for this document at the entity
--   level of cancellation. API message list.

--Locks:
--  None, directly.  Through do_action, locks the document header.
--Function:
--   Cancels the document at the header, line, or shipment level
--   depending upon the document ID parameters after performing validations.
--   Validations include state checks and cancel submission checks. If
--   p_cbc_enabled is 'Y', then the CBC accounting date is updated to be
--   p_action_date. If p_cancel_reqs_flag is 'Y', then backing requisitions will
--   also be cancelled if allowable. Otherwise, they will be recreated.
--   Encumbrance is recalculated for cancelled entities if enabled. If the
--   cancel action is successful, the document's cancel and who columns will be
--   updated at the specified entity level. Otherwise, the document will remain
--   unchanged. All changes will be committed upon success if p_commit is
--   FND_API.G_TRUE.

--Parameters:
--IN:
--  p_entity_dtl_rec
--  p_reason
--  p_action
--  p_action_date
--  p_use_gl_date
--  p_cancel_reqs_flag
--  p_note_to_vendor
--  p_launch_approvals_flag
--  p_communication_method_option
--  p_communication_method_value
--  p_caller
--  p_commit
--  p_revert_pending_chg_flag


--OUT:
--  x_online_report_id
--    ID to online report containing more detailed submission check
--    or encumbrance results
--  x_return_status
--    'S': manual close action had no unexpected errors
--         In this case, check return_code for success/failure.
--    'U': manual close action failed with unexpected errors
--  x_exception_msg
--    If x_return_status = 'U', this parameter will
--    contain an error stack in concatenated string form.
--  x_return_code
--    'STATE_FAILED': Document state check failed
--    'SUBMISSION_FAILED': Submission check failed for final close action
--    'P', 'F', 'T': Encumbrance call not fully successful.
--    NULL: manual close action was successful



-- Reference :
--   <Bug 14207546 :Cancel Refactoring Project>

--End of Comments
-------------------------------------------------------------------------------


PROCEDURE do_cancel(

   p_entity_dtl_rec               IN   entity_dtl_rec_type_tbl
,  p_reason                       IN   VARCHAR2
,  p_action                       IN   VARCHAR2
,  p_action_date                  IN   DATE      DEFAULT  SYSDATE
,  p_use_gl_date                  IN   VARCHAR2  DEFAULT  'N'
,  p_cancel_reqs_flag             IN   VARCHAR2
,  p_note_to_vendor               IN   VARCHAR2  DEFAULT NULL
,  p_launch_approvals_flag        IN   VARCHAR2  DEFAULT  'N'
,  p_communication_method_option  IN   VARCHAR2
,  p_communication_method_value   IN   VARCHAR2
,  p_caller                       IN   VARCHAR2
,  p_commit                       IN   VARCHAR2
,  p_revert_pending_chg_flag      IN   VARCHAR2
,  x_online_report_id             OUT  NOCOPY NUMBER
,  x_return_status                OUT  NOCOPY  VARCHAR2
,  x_exception_msg                OUT  NOCOPY  VARCHAR2
,  x_return_code                  OUT  NOCOPY  VARCHAR2
)

IS
l_da_call_rec   DOC_ACTION_CALL_TBL_REC_TYPE;
BEGIN

    l_da_call_rec.action                      := p_action;
    l_da_call_rec.entity_dtl_record_tbl       := p_entity_dtl_rec;
    l_da_call_rec.reason                      := p_reason;
    l_da_call_rec.action_date                 := p_action_date;
    l_da_call_rec.use_gl_date                 := p_use_gl_date;
    l_da_call_rec.cancel_reqs_flag            := p_cancel_reqs_flag;
    l_da_call_rec.note_to_vendor              := p_note_to_vendor;
    l_da_call_rec.launch_approval_flag        := p_launch_approvals_flag;
    l_da_call_rec.communication_method_option := p_communication_method_option;
    l_da_call_rec.communication_method_value  := p_communication_method_value;
    l_da_call_rec.caller                      := p_caller;
    l_da_call_rec.revert_pending_chg_flag     := p_revert_pending_chg_flag;

    l_da_call_rec.commit_flag                 := p_commit;

    PO_Document_Cancel_PVT.cancel_document(
          p_da_call_rec => l_da_call_rec,
          p_api_version =>1.0,
          p_init_msg_list => FND_API.G_FALSE,
          x_return_status =>x_return_status,
          x_msg_data => x_exception_msg,
          x_return_code=>x_return_code);

    x_online_report_id :=  l_da_call_rec.online_report_id;


END do_cancel;



END PO_DOCUMENT_ACTION_PVT;

/
