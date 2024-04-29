--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_ACTION_AUTH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_ACTION_AUTH" AS
-- $Header: POXDAAPB.pls 120.2.12010000.8 2014/05/19 20:58:47 pla ship $

-- Private package constants

g_pkg_name CONSTANT varchar2(30) := 'PO_DOCUMENT_ACTION_AUTH';
g_log_head CONSTANT VARCHAR2(50) := 'po.plsql.'|| g_pkg_name || '.';


-- Forward Declare Private Methods
--As part of bug fix 13507482, this method has been changed from private to public
/*
PROCEDURE get_supply_action_name(
   p_action            IN          VARCHAR2
,  p_document_type     IN          VARCHAR2
,  p_document_subtype  IN          VARCHAR2
,  x_supply_action     OUT NOCOPY  VARCHAR2
,  x_return_status     OUT NOCOPY  VARCHAR2
);
*/

-- Public Methods (to be used only by other DOCUMENT_ACTION packages)

------------------------------------------------------------------------------
--Start of Comments
--Name: approve
--Pre-reqs:
--  Document is locked.
--  Org context is set to that of document.
--Modifies:
--  None, directly.
--Locks:
--  None.
--Function:
--  This procedure handles logic to approves a document.
--  The logic is:
--    1. update action history
--    2. update document authorization status and approved flags
--    3. if not a PA, call appropriate supply action
--    4. if not a requisition, archive the document.
--Replaces:
--  This method covers some of the logic in poxdmaction in poxdm.lpc.
--Parameters:
--IN:
--  p_action_ctl_rec
--    Record containing all necessary parameters for action.
--OUT:
--  p_action_ctl_rec
--    Record contains variables that record output values depending
--    on the action.  All actions will populate at least a return_status.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE approve(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
)
IS

l_ret_sts         VARCHAR2(1);
l_err_msg         VARCHAR2(200);
l_bool_ret_sts    BOOLEAN;

l_msg_data        VARCHAR2(2000);
l_msg_count       NUMBER;

d_progress        NUMBER;
d_module          VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_AUTH.approve';

l_supply_action   VARCHAR2(40);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_id', p_action_ctl_rec.document_id);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_type', p_action_ctl_rec.document_type);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_subtype', p_action_ctl_rec.document_subtype);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.action', p_action_ctl_rec.action);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.new_document_status', p_action_ctl_rec.new_document_status);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.employee_id', p_action_ctl_rec.employee_id);
  END IF;

  d_progress := 10;

  BEGIN

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'Calling change_doc_auth_state');
    END IF;

    PO_DOCUMENT_ACTION_UTIL.change_doc_auth_state(
       p_document_id         => p_action_ctl_rec.document_id
    ,  p_document_type       => p_action_ctl_rec.document_type
    ,  p_document_subtype    => p_action_ctl_rec.document_subtype
    ,  p_action              => 'APPROVE'
    ,  p_fwd_to_id           => p_action_ctl_rec.forward_to_id
    ,  p_offline_code        => p_action_ctl_rec.offline_code
    ,  p_approval_path_id    => p_action_ctl_rec.approval_path_id
    ,  p_note                => p_action_ctl_rec.note
    ,  p_new_status          => PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED
    ,  p_notify_action       => 'APPROVAL'
    ,  p_notify_employee     => p_action_ctl_rec.forward_to_id
    ,  x_return_status       => l_ret_sts
    );

    IF (l_ret_sts <> 'S')
    THEN

       d_progress := 20;
       p_action_ctl_rec.return_status := 'U';
       l_err_msg := 'change_doc_auth_state not successful';
       RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 30;

    IF (p_action_ctl_rec.document_type <> 'PA')
    THEN

      get_supply_action_name(
         p_action           => p_action_ctl_rec.action
      ,  p_document_type    => p_action_ctl_rec.document_type
      ,  p_document_subtype => p_action_ctl_rec.document_subtype
      ,  x_return_status    => l_ret_sts
      ,  x_supply_action    => l_supply_action
      );

      IF (l_ret_sts <> 'S')
      THEN
        d_progress := 40;
        p_action_ctl_rec.return_status := 'U';
        l_err_msg := 'get_supply_action_name not successful';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      d_progress := 50;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'l_supply_action', l_supply_action);
      END IF;

      l_bool_ret_sts :=
        PO_SUPPLY.po_req_supply(
           p_docid          => p_action_ctl_rec.document_id
        ,  p_lineid         => NULL
        ,  p_shipid         => NULL
        ,  p_action         => l_supply_action
        ,  p_recreate_flag  => FALSE
        ,  p_qty            => NULL
        ,  p_receipt_date   => NULL
        );

      IF (NOT l_bool_ret_sts)
      THEN
        d_progress := 60;
        l_err_msg := 'po_req_supply returned false';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

    END IF;  -- p_action_ctl_rec.document_type <> 'PA'

    d_progress := 70;
    -- <Unified Catalog R12 Start>
    IF ((p_action_ctl_rec.document_type = 'PA') AND
        (p_action_ctl_rec.document_subtype = 'BLANKET'))
    THEN
      -- Rebuild catalog search index.
      -- Call this procedure BEFORE calling archive_po because this one
      -- compares against the archive tables to check if any of the
      -- searchable fields have been modified or not.
      PO_CATALOG_INDEX_PVT.rebuild_index
      (
        p_type => PO_CATALOG_INDEX_PVT.TYPE_BLANKET
      , p_po_header_id => P_ACTION_CTL_REC.document_id
      );

    END IF; -- if Blanket Agreement
    -- <Unified Catalog R12 End>

    d_progress := 80;
    IF (p_action_ctl_rec.document_type <> 'REQUISITION')
    THEN

      PO_DOCUMENT_ARCHIVE_GRP.archive_po(
         p_api_version      => 1.0
      ,  p_document_id      => p_action_ctl_rec.document_id
      ,  p_document_type    => p_action_ctl_rec.document_type
      ,  p_document_subtype => p_action_ctl_rec.document_subtype
      ,  p_process          => 'APPROVE'
      ,  x_return_status    => l_ret_sts
      ,  x_msg_count        => l_msg_count
      ,  x_msg_data         => l_msg_data
      );

      IF (l_ret_sts <> 'S')
      THEN
        d_progress := 90;
        l_err_msg := 'archive_po not successful';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

    END IF;  -- if p_action_ctl_rec.document_type <> 'REQUISITION'

    -- TODO: ANALYZE return_code value (as opposed to return_status).
    p_action_ctl_rec.return_status := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      p_action_ctl_rec.return_status := 'U';
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, l_err_msg);
      END IF;
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, l_err_msg);

  END;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    p_action_ctl_rec.return_status := 'U';

    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END approve;


------------------------------------------------------------------------------
--Start of Comments
--Name: reject
--Pre-reqs:
--  Document is locked.
--  Org context is set to that of document.
--Modifies:
--  None, directly.
--Locks:
--  None.
--Function:
--  This procedure handles logic to reject a document that is
--  either pre-approved or in process.
--  The logic is:
--    1. check that document is in right status
--    2. handle encumbrance
--    3. update action history
--    4. update document authorization status
--    5. if not a PA, call appropriate supply action
--Replaces:
--  This method covers the logic in podareject in podar.lpc.
--Parameters:
--IN:
--  p_action_ctl_rec
--    Record containing all necessary parameters for action.
--OUT:
--  p_action_ctl_rec
--    Record contains variables that record output values depending
--    on the action.  All actions will populate at least a return_status.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE reject(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
)
IS

l_doc_state_ok    BOOLEAN;
l_preparer_id     PO_HEADERS_ALL.agent_id%TYPE;

l_ret_sts         VARCHAR2(1);
l_err_msg         VARCHAR2(200);
l_bool_ret_sts    BOOLEAN;

l_enc_flag        VARCHAR2(1);
l_enc_ret_code    VARCHAR2(10);
l_enc_report_id   NUMBER;

l_supply_action   VARCHAR2(40);

d_progress        NUMBER;
d_module          VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_AUTH.reject';

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_id', p_action_ctl_rec.document_id);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_type', p_action_ctl_rec.document_type);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_subtype', p_action_ctl_rec.document_subtype);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.action', p_action_ctl_rec.action);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.forward_to_id', p_action_ctl_rec.forward_to_id);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.approval_path_id', p_action_ctl_rec.approval_path_id);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.note', p_action_ctl_rec.note);
  END IF;

  d_progress := 10;

  BEGIN

    PO_DOCUMENT_ACTION_CHECK.reject_status_check(p_action_ctl_rec);

    d_progress := 20;

    IF (p_action_ctl_rec.return_status <> 'S')
    THEN

      d_progress := 30;
      p_action_ctl_rec.return_status := 'U';
      l_err_msg := 'reject_status_check not successful';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    IF (p_action_ctl_rec.return_code IS NOT NULL)
    THEN

      d_progress := 40;
      p_action_ctl_rec.return_status := 'S';
      p_action_ctl_rec.return_code := 'STATE_FAILED';
      l_err_msg := 'State check failed';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    -- reset return status and return code after reject_status_check call
    p_action_ctl_rec.return_status := NULL;
    p_action_ctl_rec.return_code := NULL;

    d_progress := 50;

    PO_DOCUMENT_ACTION_UTIL.get_doc_preparer_id(
       p_document_id => p_action_ctl_rec.document_id
    ,  p_document_type => p_action_ctl_rec.document_type
    ,  x_return_status => l_ret_sts
    ,  x_preparer_id => l_preparer_id
    );

    IF (l_ret_sts <> 'S')
    THEN

      d_progress := 60;
      p_action_ctl_rec.return_status := 'U';
      l_err_msg := 'get_doc_preparer_id not successful';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 70;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_preparer_id', l_preparer_id);
    END IF;


    IF ( PO_CORE_S.is_encumbrance_on(
            p_doc_type => p_action_ctl_rec.document_type
         ,  p_org_id => NULL
         )
        )
    THEN
      l_enc_flag := 'Y';
    ELSE
      l_enc_flag := 'N';
    END IF;

    d_progress := 80;

    IF ((l_enc_flag = 'Y') AND (p_action_ctl_rec.document_type = 'PA')
       AND (p_action_ctl_rec.document_subtype = 'BLANKET'))
    THEN

      d_progress := 90;

      SELECT nvl(poh.encumbrance_required_flag, 'N')
      INTO l_enc_flag
      FROM po_headers_all poh
      WHERE po_header_id = p_action_ctl_rec.document_id;

    END IF;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_enc_flag', l_enc_flag);
    END IF;

 -- Bug16927756 Bypass the call to PO_DOCUMENT_FUNDS_PVT.do_reject
 -- since no encumbrance action happens during reject after
 -- Encumbrance ER

 -- Bug#18672709 : remove the comment introduced by Bug16927756
 -- we should only bypass the call to PO_DOCUMENT_FUNDS_PVT.do_reject
 -- for the PO case only
 --
    IF ((l_enc_flag = 'Y') AND ((p_action_ctl_rec.document_subtype <> 'CONTRACT') OR
                                (p_action_ctl_rec.document_subtype <> 'STANDARD')) )  -- bug 8498264
    THEN

      d_progress := 100;

      PO_DOCUMENT_FUNDS_PVT.do_reject(
        x_return_status     => l_ret_sts
      , p_doc_type          => p_action_ctl_rec.document_type
      , p_doc_subtype       => p_action_ctl_rec.document_subtype
      , p_doc_level         => PO_DOCUMENT_FUNDS_PVT.g_doc_level_HEADER
      , p_doc_level_id      => p_action_ctl_rec.document_id
      , p_use_enc_gt_flag   => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO
      , p_override_funds    => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO
      , p_use_gl_date       => PO_DOCUMENT_FUNDS_PVT.g_parameter_USE_PROFILE
      , p_override_date     => SYSDATE
      , x_po_return_code    => l_enc_ret_code
      , x_online_report_id  => l_enc_report_id
      );


      IF (l_ret_sts <> FND_API.g_ret_sts_success)
      THEN

        d_progress := 110;
        p_action_ctl_rec.return_status := 'U';
        l_err_msg := 'do_reject not successful';
        RAISE PO_CORE_S.g_early_return_exc;

      END IF;

      d_progress := 120;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'l_enc_ret_code', l_enc_ret_code);
        PO_LOG.stmt(d_module, d_progress, 'l_enc_report_id', l_enc_report_id);
      END IF;

      p_action_ctl_rec.online_report_id := l_enc_report_id;

      IF ((l_enc_ret_code = PO_DOCUMENT_FUNDS_PVT.g_return_SUCCESS)
           OR (l_enc_ret_code = PO_DOCUMENT_FUNDS_PVT.g_return_WARNING))
      THEN

        d_progress := 125;
        -- Just continue with reject action.

      ELSIF (l_enc_ret_code = PO_DOCUMENT_FUNDS_PVT.g_return_PARTIAL)
      THEN

        d_progress := 130;
        p_action_ctl_rec.return_status := 'S';
        p_action_ctl_rec.return_code := 'P';
        l_err_msg := 'funds do_reject partial';
        RAISE PO_CORE_S.g_early_return_exc;

      ELSIF (l_enc_ret_code = PO_DOCUMENT_FUNDS_PVT.g_return_FAILURE)
      THEN

        d_progress := 140;
        p_action_ctl_rec.return_status := 'S';
        p_action_ctl_rec.return_code := 'F';
        l_err_msg := 'funds do_reject failure';
        RAISE PO_CORE_S.g_early_return_exc;

      ELSIF (l_enc_ret_code = PO_DOCUMENT_FUNDS_PVT.g_return_FATAL)
      THEN

        d_progress := 150;
        p_action_ctl_rec.return_status := 'S';
        p_action_ctl_rec.return_code := 'T';
        l_err_msg := 'funds do_reject fatal';
        RAISE PO_CORE_S.g_early_return_exc;

      ELSE

       d_progress := 160;
       p_action_ctl_rec.return_status := 'U';
       l_err_msg := 'Bad return code from funds do_reject';
       RAISE PO_CORE_S.g_early_return_exc;

      END IF;  -- if l_enc_ret_code IN (...)

    END IF;  -- if l_enc_flag = 'Y' ...
    -- End of Bug#18672709

    d_progress := 170;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'Calling change_doc_auth_state');
    END IF;

    PO_DOCUMENT_ACTION_UTIL.change_doc_auth_state(
       p_document_id         => p_action_ctl_rec.document_id
    ,  p_document_type       => p_action_ctl_rec.document_type
    ,  p_document_subtype    => p_action_ctl_rec.document_subtype
    ,  p_action              => 'REJECT'
    ,  p_fwd_to_id           => p_action_ctl_rec.forward_to_id
    ,  p_offline_code        => p_action_ctl_rec.offline_code
    ,  p_approval_path_id    => p_action_ctl_rec.approval_path_id
    ,  p_note                => p_action_ctl_rec.note
    ,  p_new_status          => PO_DOCUMENT_ACTION_PVT.g_doc_status_REJECTED
    ,  p_notify_action       => 'REJECTED_BY_APPROVER'
    ,  p_notify_employee     => l_preparer_id
    ,  x_return_status       => l_ret_sts
    );

    IF (l_ret_sts <> 'S')
    THEN

       d_progress := 180;
       p_action_ctl_rec.return_status := 'U';
       l_err_msg := 'change_doc_auth_state not successful';
       RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 190;
--    Bug 9488727 supply/reservations need not be altered for reject action
--    IF (p_action_ctl_rec.document_type <> 'PA')
--    THEN
--
--      get_supply_action_name(
--         p_action           => p_action_ctl_rec.action
--      ,  p_document_type    => p_action_ctl_rec.document_type
--      ,  p_document_subtype => p_action_ctl_rec.document_subtype
--      ,  x_return_status    => l_ret_sts
--      ,  x_supply_action    => l_supply_action
--      );
--
--      IF (l_ret_sts <> 'S')
--      THEN
--        d_progress := 195;
--        p_action_ctl_rec.return_status := 'U';
--        l_err_msg := 'get_supply_action_name not successful';
--        RAISE PO_CORE_S.g_early_return_exc;
--      END IF;
--
--      d_progress := 200;
--      IF (PO_LOG.d_stmt) THEN
--        PO_LOG.stmt(d_module, d_progress, 'l_supply_action', l_supply_action);
--      END IF;
--
--      l_bool_ret_sts :=
--        PO_SUPPLY.po_req_supply(
--           p_docid          => p_action_ctl_rec.document_id
--        ,  p_lineid         => NULL
--        ,  p_shipid         => NULL
--        ,  p_action         => l_supply_action
--        ,  p_recreate_flag  => FALSE
--        ,  p_qty            => NULL
--        ,  p_receipt_date   => NULL
--        );
--
--      IF (NOT l_bool_ret_sts)
--      THEN
--        d_progress := 210;
--        p_action_ctl_rec.return_status := 'U';
--        l_err_msg := 'po_req_supply returned false';
--        RAISE PO_CORE_S.g_early_return_exc;
--      END IF;
--
--    END IF;  -- document_type <> 'PA'

    p_action_ctl_rec.return_status := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      IF (p_action_ctl_rec.return_status = 'U')
      THEN
        IF (PO_LOG.d_exc) THEN
          PO_LOG.exc(d_module, d_progress, l_err_msg);
        END IF;
      END IF;

      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, l_err_msg);

  END;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_code', p_action_ctl_rec.return_code);
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.online_report_id', p_action_ctl_rec.online_report_id);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    p_action_ctl_rec.return_status := 'U';

    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END reject;


------------------------------------------------------------------------------
--Start of Comments
--Name: forward
--Pre-reqs:
--  Document is locked.
--  Org context is set to that of document.
--Modifies:
--  None, directly.
--Locks:
--  None.
--Function:
--  This procedure handles the forwarding of a document from one employee
--  to another.  It is just a wrapper around PO_DOCUMENT_ACTION_UTIL.change_doc_auth_state().
--  The logic is:
--    1. update action history
--    2. update document authorization status, if necessary
--Replaces:
--  This method covers some of the logic in poxdmaction in poxdm.lpc.
--Parameters:
--IN:
--  p_action_ctl_rec
--    Record containing all necessary parameters for action.
--OUT:
--  p_action_ctl_rec
--    Record contains variables that record output values depending
--    on the action.  All actions will populate at least a return_status.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE forward(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
)
IS

l_ret_sts        VARCHAR2(1);
l_err_msg        VARCHAR2(200);

d_progress       NUMBER;
d_module         VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_AUTH.forward';

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_id', p_action_ctl_rec.document_id);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_type', p_action_ctl_rec.document_type);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_subtype', p_action_ctl_rec.document_subtype);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.action', p_action_ctl_rec.action);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.forward_to_id', p_action_ctl_rec.forward_to_id);
  END IF;

  d_progress := 10;

  BEGIN

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'Calling change_doc_auth_state');
    END IF;

    PO_DOCUMENT_ACTION_UTIL.change_doc_auth_state(
       p_document_id         => p_action_ctl_rec.document_id
    ,  p_document_type       => p_action_ctl_rec.document_type
    ,  p_document_subtype    => p_action_ctl_rec.document_subtype
    ,  p_action              => 'FORWARD'
    ,  p_fwd_to_id           => p_action_ctl_rec.forward_to_id
    ,  p_offline_code        => p_action_ctl_rec.offline_code
    ,  p_approval_path_id    => p_action_ctl_rec.approval_path_id
    ,  p_note                => p_action_ctl_rec.note
    ,  p_new_status          => p_action_ctl_rec.new_document_status
    ,  p_notify_action       => 'APPROVAL'
    ,  p_notify_employee     => p_action_ctl_rec.forward_to_id
    ,  x_return_status       => l_ret_sts
    );

    IF (l_ret_sts <> 'S')
    THEN
      d_progress := 20;
      l_ret_sts := 'U';
      l_err_msg := 'change doc state not successful';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 30;
    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, l_err_msg);
      END IF;
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, l_err_msg);

  END;

  p_action_ctl_rec.return_status := l_ret_sts;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    p_action_ctl_rec.return_status := 'U';

    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END forward;

------------------------------------------------------------------------------
--Start of Comments
--Name: return_action
--Pre-reqs:
--  Document is locked.
--  Org context is set to that of document.
--Modifies:
--  None, directly.
--Locks:
--  None.
--Function:
--  This procedure handles logic to return a requistion during autocreate.
--  The logic is:
--    1. verify document is requisition
--    2. verify requisition state - e.g. that it is approved.
--    3. handle encumbrance
--    4. update action history
--    5. update authorization_status and appropriate flags
--    6. call appropriate methods to handle supply
--Replaces:
--  This method covers some of the logic in podatreturn in podat.lpc.
--Parameters:
--IN:
--  p_action_ctl_rec
--    Record containing all necessary parameters for action.
--OUT:
--  p_action_ctl_rec
--    Record contains variables that record output values depending
--    on the action.  All actions will populate at least a return_status.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE return_action(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
)
IS

l_ret_sts        VARCHAR2(1);
l_bool_ret_sts   BOOLEAN;
l_err_msg        VARCHAR2(200);

l_allowed_states    PO_DOCUMENT_ACTION_UTIL.doc_state_rec_type;
l_doc_state_ok      BOOLEAN;

l_req_enc_on        BOOLEAN;
l_enc_ret_code      VARCHAR2(10);
l_enc_report_id     NUMBER;

l_preparer_id     PO_REQUISITION_HEADERS.preparer_id%TYPE;
l_supply_action   VARCHAR2(40);

d_progress       NUMBER;
d_module         VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_AUTH.return_action';

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_id', p_action_ctl_rec.document_id);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_type', p_action_ctl_rec.document_type);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_subtype', p_action_ctl_rec.document_subtype);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.action', p_action_ctl_rec.action);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.note', p_action_ctl_rec.note);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.approval_path_id', p_action_ctl_rec.approval_path_id);
  END IF;

  d_progress := 10;

  BEGIN

    IF (p_action_ctl_rec.document_type <> 'REQUISITION')
    THEN

      d_progress := 20;
      l_err_msg := 'Invalid document type';
      l_ret_sts := 'U';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 30;

    l_allowed_states.auth_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED;
    l_allowed_states.hold_flag := 'N';
    l_allowed_states.frozen_flag := 'N';
    l_allowed_states.closed_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED;
    l_allowed_states.closed_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_OPEN;

    l_doc_state_ok := PO_DOCUMENT_ACTION_UTIL.check_doc_state(
                                p_document_id => p_action_ctl_rec.document_id
                             ,  p_document_type => p_action_ctl_rec.document_type
                             ,  p_allowed_states => l_allowed_states
                             ,  x_return_status  => l_ret_sts
                             );

    IF (l_ret_sts <> 'S')
    THEN

      d_progress := 40;
      l_err_msg := 'check_doc_state not successful';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    IF (NOT l_doc_state_ok)
    THEN

      d_progress := 45;
      l_ret_sts := 'S';
      p_action_ctl_rec.return_code := 'STATE_FAILED';
      l_err_msg := 'State check failed.';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 50;

    l_req_enc_on := PO_CORE_S.is_encumbrance_on(
                           p_doc_type => PO_CORE_S.g_doc_type_REQUISITION
                        ,  p_org_id   => NULL
                        );

    d_progress := 60;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_req_enc_on', l_req_enc_on);
    END IF;

    IF (l_req_enc_on)
    THEN

      d_progress := 70;

      PO_DOCUMENT_FUNDS_PVT.do_return(
        x_return_status     => l_ret_sts
      , p_doc_type          => p_action_ctl_rec.document_type
      , p_doc_subtype       => p_action_ctl_rec.document_subtype
      , p_doc_level         => PO_DOCUMENT_FUNDS_PVT.g_doc_level_HEADER
      , p_doc_level_id      => p_action_ctl_rec.document_id
      , p_use_enc_gt_flag   => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO
      , p_use_gl_date       => PO_DOCUMENT_FUNDS_PVT.g_parameter_USE_PROFILE
      , p_override_date     => SYSDATE
      , x_po_return_code    => l_enc_ret_code
      , x_online_report_id  => l_enc_report_id
      );


      IF (l_ret_sts <> FND_API.g_ret_sts_success)
      THEN

        d_progress := 80;
        l_ret_sts := 'U';
        l_err_msg := 'do_return not successful';
        RAISE PO_CORE_S.g_early_return_exc;

      END IF;

      d_progress := 90;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'l_enc_ret_code', l_enc_ret_code);
        PO_LOG.stmt(d_module, d_progress, 'l_enc_report_id', l_enc_report_id);
      END IF;

      p_action_ctl_rec.online_report_id := l_enc_report_id;

      IF ((l_enc_ret_code = PO_DOCUMENT_FUNDS_PVT.g_return_SUCCESS)
           OR (l_enc_ret_code = PO_DOCUMENT_FUNDS_PVT.g_return_WARNING))
      THEN

        d_progress := 100;
        -- Just continue with return action.

      ELSIF (l_enc_ret_code = PO_DOCUMENT_FUNDS_PVT.g_return_PARTIAL)
      THEN

        d_progress := 110;
        l_ret_sts := 'S';
        p_action_ctl_rec.return_code := 'P';
        l_err_msg := 'funds do_return partial';
        RAISE PO_CORE_S.g_early_return_exc;

      ELSIF (l_enc_ret_code = PO_DOCUMENT_FUNDS_PVT.g_return_FAILURE)
      THEN

        d_progress := 120;
        l_ret_sts := 'S';
        p_action_ctl_rec.return_code := 'F';
        l_err_msg := 'funds do_return failure';
        RAISE PO_CORE_S.g_early_return_exc;

      ELSIF (l_enc_ret_code = PO_DOCUMENT_FUNDS_PVT.g_return_FATAL)
      THEN

        d_progress := 130;
        l_ret_sts := 'S';
        p_action_ctl_rec.return_code := 'T';
        l_err_msg := 'funds do_return fatal';
        RAISE PO_CORE_S.g_early_return_exc;

      ELSE

       d_progress := 140;
       l_ret_sts := 'U';
       l_err_msg := 'Bad return code from funds do_return';
       RAISE PO_CORE_S.g_early_return_exc;

      END IF;  -- if l_enc_ret_code IN (...)

    END IF;  -- IF l_req_enc_on

    d_progress := 150;

    PO_DOCUMENT_ACTION_UTIL.get_doc_preparer_id(
       p_document_id => p_action_ctl_rec.document_id
    ,  p_document_type => p_action_ctl_rec.document_type
    ,  x_return_status => l_ret_sts
    ,  x_preparer_id => l_preparer_id
    );

    IF (l_ret_sts <> 'S')
    THEN

      d_progress := 160;
      l_ret_sts := 'U';
      l_err_msg := 'get_doc_preparer_id not successful';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 170;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'Calling change_doc_auth_state');
    END IF;

    PO_DOCUMENT_ACTION_UTIL.change_doc_auth_state(
       p_document_id         => p_action_ctl_rec.document_id
    ,  p_document_type       => p_action_ctl_rec.document_type
    ,  p_document_subtype    => p_action_ctl_rec.document_subtype
    ,  p_action              => 'RETURN'
    ,  p_fwd_to_id           => NULL
    ,  p_offline_code        => NULL
    ,  p_approval_path_id    => p_action_ctl_rec.approval_path_id
    ,  p_note                => p_action_ctl_rec.note
    ,  p_new_status          => PO_DOCUMENT_ACTION_PVT.g_doc_status_RETURNED
    ,  p_notify_action       => 'APPROVAL'
    ,  p_notify_employee     => l_preparer_id
    ,  x_return_status       => l_ret_sts
    );

    IF (l_ret_sts <> 'S')
    THEN

       d_progress := 180;
       l_ret_sts := 'U';
       l_err_msg := 'change_doc_auth_state not successful';
       RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 190;

    get_supply_action_name(
       p_action           => p_action_ctl_rec.action
    ,  p_document_type    => p_action_ctl_rec.document_type
    ,  p_document_subtype => p_action_ctl_rec.document_subtype
    ,  x_return_status    => l_ret_sts
    ,  x_supply_action    => l_supply_action
    );

    IF (l_ret_sts <> 'S')
    THEN
      d_progress := 195;
      l_ret_sts := 'U';
      l_err_msg := 'get_supply_action_name not successful';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 200;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_supply_action', l_supply_action);
    END IF;

    l_bool_ret_sts :=
      PO_SUPPLY.po_req_supply(
         p_docid          => p_action_ctl_rec.document_id
      ,  p_lineid         => NULL
      ,  p_shipid         => NULL
      ,  p_action         => l_supply_action
      ,  p_recreate_flag  => FALSE
      ,  p_qty            => NULL
      ,  p_receipt_date   => NULL
      );

    IF (NOT l_bool_ret_sts)
    THEN
      d_progress := 210;
      l_ret_sts := 'U';
      l_err_msg := 'po_req_supply returned false';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 220;
    p_action_ctl_rec.return_code := NULL;
    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      IF (l_ret_sts = 'U') THEN
        IF (PO_LOG.d_exc) THEN
          PO_LOG.exc(d_module, d_progress, l_err_msg);
        END IF;
      END IF;

      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, l_err_msg);
  END;

  p_action_ctl_rec.return_status := l_ret_sts;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_code', p_action_ctl_rec.return_code);
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.online_report_id', p_action_ctl_rec.online_report_id);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    p_action_ctl_rec.return_status := 'U';

    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END return_action;

-- Private package methods

------------------------------------------------------------------------------
--Start of Comments
--Name: get_supply_action_name
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- Given an action and document type, returns the appropriate supply action
-- to call via PO_SUPPLY.po_req_supply().
--Parameters:
--IN:
--  p_action
--    REJECT, APPROVE, RETURN
--  p_document_type
--    APPROVE/REJECT: PO, PA, RELEASE, REQUISITION
--    RETURN: REQUISITION
--  p_document_subtype
--    RELEASE: BLANKET, SCHEDULED
--    PO: PLANNED, STANDARD
--    PA: CONTRACT, BLANKET
--OUT:
--  x_return_status
--    'S' if successful
--    'U' if unexpected error
--  x_supply_action
--    Name of supply action to pass to PO_SUPPLY.po_req_supply()
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_supply_action_name(
   p_action            IN          VARCHAR2
,  p_document_type     IN          VARCHAR2
,  p_document_subtype  IN          VARCHAR2
,  x_supply_action     OUT NOCOPY  VARCHAR2
,  x_return_status     OUT NOCOPY  VARCHAR2
)
IS

d_progress  NUMBER;
d_module    VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_AUTH.get_supply_action_name';

l_supply_action  VARCHAR2(40);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_subtype);
  END IF;

  IF (p_action IN (PO_DOCUMENT_ACTION_PVT.g_doc_action_APPROVE,
                   PO_DOCUMENT_ACTION_PVT.g_doc_action_REJECT))
  THEN

    IF (p_document_type = 'PO')
    THEN

      d_progress := 10;
      l_supply_action := 'Approve_PO_Supply';

    ELSIF (p_document_type = 'RELEASE')
    THEN
      d_progress := 20;
      IF (p_document_subtype = 'BLANKET')
      THEN
        d_progress := 30;
        l_supply_action := 'Approve_Blanket_Release_Supply';
      ELSE
        d_progress := 40;
        l_supply_action := 'Approve_Planned_Release_Supply';
      END IF;

    ELSIF (p_document_type = 'REQUISITION')
    THEN

      d_progress := 50;
      l_supply_action := 'Approve_Req_Supply';

    END IF;  -- document_type = 'PO'

  ELSIF ((p_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_RETURN)
       AND (p_document_type = 'REQUISITION'))
  THEN

    d_progress := 60;
    l_supply_action := 'Remove_Return_Req_Supply';

  ELSE

    RAISE PO_CORE_S.g_invalid_call_exc;

  END IF;  -- p_action IN ...

  x_supply_action := l_supply_action;
  x_return_status := 'S';

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_supply_action', x_supply_action);
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'U';
    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;
END get_supply_action_name;


END PO_DOCUMENT_ACTION_AUTH;

/
