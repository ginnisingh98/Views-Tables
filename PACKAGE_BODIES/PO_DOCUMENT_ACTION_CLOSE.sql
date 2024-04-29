--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_ACTION_CLOSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_ACTION_CLOSE" AS
-- $Header: POXDACLB.pls 120.9.12010000.18 2014/05/13 22:21:53 pla ship $

-- Private package constants

g_pkg_name CONSTANT varchar2(30) := 'PO_DOCUMENT_ACTION_CLOSE';
g_log_head CONSTANT VARCHAR2(50) := 'po.plsql.'|| g_pkg_name || '.';

-- Private package types

TYPE g_tbl_number IS TABLE OF NUMBER;

TYPE g_tbl_closed_code IS TABLE OF PO_LINE_LOCATIONS.closed_code%TYPE;

-- Forward declare private methods

FUNCTION manual_close_submission_check(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_document_subtype  IN      VARCHAR2
,  p_action            IN      VARCHAR2
,  p_calling_mode      IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  p_origin_doc_id     IN      NUMBER -- Bug#5462677
,  x_return_status     OUT NOCOPY  VARCHAR2
,  x_online_report_id  OUT NOCOPY  NUMBER
) RETURN BOOLEAN;

FUNCTION manual_close_state_check(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_action            IN      VARCHAR2
,  p_calling_mode      IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  x_return_status     OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN;

FUNCTION auto_close_state_check(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  x_return_status     OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN;

PROCEDURE handle_close_encumbrance(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_document_subtype  IN      VARCHAR2
,  p_action            IN      VARCHAR2
,  p_calling_mode      IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  p_origin_doc_id     IN      NUMBER
,  p_action_date       IN      DATE
,  p_use_gl_date       IN      VARCHAR2
,  x_return_status     OUT NOCOPY  VARCHAR2
,  x_return_code       OUT NOCOPY  VARCHAR2
,  x_online_report_id  OUT NOCOPY  NUMBER
,  x_enc_flag          OUT NOCOPY  BOOLEAN
);

PROCEDURE manual_update_closed_status(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_document_subtype  IN      VARCHAR2
,  p_action            IN      VARCHAR2
,  p_calling_mode      IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  p_user_id           IN      NUMBER
,  p_login_id          IN      NUMBER
,  p_employee_id       IN      NUMBER
,  p_reason            IN      VARCHAR2
,  p_enc_flag          IN      BOOLEAN
,  p_action_date       IN      DATE        -- Bug#18705290
,  p_use_gl_date       IN      VARCHAR2    -- Bug#18705290
,  x_return_status     OUT NOCOPY  VARCHAR2
);

PROCEDURE auto_update_closed_status(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_calling_mode      IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  p_employee_id       IN      NUMBER
,  p_user_id           IN      NUMBER  --bug4964600
,  p_login_id          IN      NUMBER  --bug4964600
,  p_reason            IN      VARCHAR2
,  x_return_status     OUT NOCOPY  VARCHAR2
);

PROCEDURE rollup_close_state(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_document_subtype  IN      VARCHAR2
,  p_action            IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  p_user_id           IN      NUMBER
,  p_login_id          IN      NUMBER
,  p_employee_id       IN      NUMBER
,  p_reason            IN      VARCHAR2
,  p_action_date       IN      DATE
,  p_calling_mode      IN      VARCHAR2
,  x_return_status     OUT NOCOPY  VARCHAR2
);

PROCEDURE handle_manual_close_supply(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_action            IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  x_return_status     OUT NOCOPY  VARCHAR2
);

PROCEDURE handle_auto_close_supply(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  x_return_status     OUT NOCOPY  VARCHAR2
);

-- Public methods

------------------------------------------------------------------------------
--Start of Comments
--Name: manual_close_po
--Pre-reqs:
--  Document is locked.
--  Org context is set to that of document.
--Modifies:
--  None, directly.
--Locks:
--  None.
--Function:
--  This procedure applies the logic of an open or close action
--  onto a document entity.
--  The logic is:
--    1. get user_id, login_id, and employee_id
--    2. do a document state check, e.g. has proper authorization status
--    3. do a document submission check; only relevant for final close
--    4. for invoice open from AP, reopen finally closed shipments
--       these shipments are initially reopened to status closed.
--    5. handle encumbrance for AP invoice open and final close
--    6. update lowest level closed status
--    7. rollup closed status changes as necessary to higher levels
--       this also handles the action history
--    8. handle supply
--Replaces:
--  This method covers poccstatus in poccs.lpc.
--Parameters:
--IN:
--  p_action_ctl_rec
--    Record containing all necessary parameters for close action.
--OUT:
--  p_action_ctl_rec
--    Record contains variables that record output values depending
--    on the action.  All actions will populate at least a return_status.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE manual_close_po(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
)
IS

d_module      VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CLOSE.manual_close_po';
d_progress    NUMBER;
d_msg         VARCHAR2(200);

l_ret_sts     VARCHAR2(1);

l_user_id     NUMBER;
l_login_id    NUMBER;

l_emp_flag    BOOLEAN;
l_emp_id      NUMBER;

l_state_check_ok    BOOLEAN;
l_sub_check_ok      BOOLEAN;
l_enc_flag          BOOLEAN;
l_ret_code          VARCHAR2(25);

l_rollback_flag     BOOLEAN   :=   FALSE;


BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_id', p_action_ctl_rec.document_id);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_type', p_action_ctl_rec.document_type);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_subtype', p_action_ctl_rec.document_subtype);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.line_id', p_action_ctl_rec.line_id);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.shipment_id', p_action_ctl_rec.shipment_id);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.action', p_action_ctl_rec.action);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.note', p_action_ctl_rec.note);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.called_from_conc', p_action_ctl_rec.called_from_conc);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.calling_mode', p_action_ctl_rec.calling_mode);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.origin_doc_id', p_action_ctl_rec.origin_doc_id);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.action_date', p_action_ctl_rec.action_date);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.use_gl_date', p_action_ctl_rec.use_gl_date);
  END IF;

  SAVEPOINT DA_MANUAL_CLOSE_SP;

  BEGIN

    d_progress := 10;

    l_user_id := FND_GLOBAL.USER_ID;

    IF (l_user_id = -1)
    THEN
      d_progress := 20;
      l_ret_sts := 'U';
      d_msg := 'user id not found';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 30;

    IF (p_action_ctl_rec.called_from_conc)
    THEN
      l_login_id := FND_GLOBAL.CONC_LOGIN_ID;
    ELSE
      l_login_id := FND_GLOBAL.LOGIN_ID;
    END IF;

    -- <Bug 4118145: Issue 7>: From approval workflow,
    -- login_id can be -1; this is now allowed.
    -- Validation of login_id, if desired, it is left to the caller

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_login_id', l_login_id);
      PO_LOG.stmt(d_module, d_progress, 'l_user_id', l_user_id);
    END IF;

    d_progress := 50;

    PO_DOCUMENT_ACTION_UTIL.get_employee_id(
       p_user_id       => l_user_id
    ,  x_return_status => l_ret_sts
    ,  x_employee_flag => l_emp_flag
    ,  x_employee_id   => l_emp_id
    );

    IF (l_ret_sts <> 'S')
    THEN
      d_progress := 60;
      l_ret_sts := 'U';
      d_msg := 'get_employee_id not successful';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    IF (NOT l_emp_flag)
    THEN

      -- See Bug 236640; in Pro*C, we just set to NULL
      -- commenting out exception raising
      -- l_ret_sts := 'U';
      -- d_msg := 'user is not an employee';
      -- RAISE PO_CORE_S.g_early_return_exc;

      d_progress := 70;
      l_emp_id := NULL;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'user is not an employee');
      END IF;

    END IF;

    d_progress := 80;

    l_state_check_ok := manual_close_state_check(
       p_document_id     => p_action_ctl_rec.document_id
    ,  p_document_type   => p_action_ctl_rec.document_type
    ,  p_action          => p_action_ctl_rec.action
    ,  p_calling_mode    => p_action_ctl_rec.calling_mode
    ,  p_line_id         => p_action_ctl_rec.line_id
    ,  p_shipment_id     => p_action_ctl_rec.shipment_id
    ,  x_return_status   => l_ret_sts
    );

    IF (l_ret_sts <> 'S')
    THEN
      d_progress := 90;
      l_ret_sts := 'U';
      d_msg := 'manual_close_state_check not successful';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    IF (NOT l_state_check_ok)
    THEN
      d_progress := 100;
      l_ret_sts := 'S';
      d_msg := 'document state is not valid for action';
      p_action_ctl_rec.return_code := 'STATE_FAILED';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 110;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'State check passed.');
    END IF;

    l_sub_check_ok := manual_close_submission_check(
       p_document_id      => p_action_ctl_rec.document_id
    ,  p_document_type    => p_action_ctl_rec.document_type
    ,  p_document_subtype => p_action_ctl_rec.document_subtype
    ,  p_action           => p_action_ctl_rec.action
    ,  p_calling_mode     => p_action_ctl_rec.calling_mode
    ,  p_line_id          => p_action_ctl_rec.line_id
    ,  p_shipment_id      => p_action_ctl_rec.shipment_id
    ,  p_origin_doc_id    => p_action_ctl_rec.origin_doc_id -- Bug#5462677
    ,  x_return_status    => l_ret_sts
    ,  x_online_report_id => p_action_ctl_rec.online_report_id
    );

    IF (l_ret_sts <> 'S')
    THEN
      d_progress := 120;
      l_ret_sts := 'U';
      d_msg := 'manual_close_submission_check not successful';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    IF (NOT l_sub_check_ok)
    THEN
      d_progress := 130;
      l_ret_sts := 'S';
      d_msg := 'document submission check failed';
      p_action_ctl_rec.return_code := 'SUBMISSION_FAILED';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 140;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'Submission check passed.');
    END IF;


    d_progress := 200;

    -- From this point forward, need to rollback on early return or exception
    -- PO_DOCUMENT_ACTION_PVT.do_action, which normally handles rolling back for other actions,
    -- only rolls back on return_status = 'U'. Since we return 'S' for any encumbrance
    -- functional errors, we want to undo the following AP INVOICE OPEN update SQL in those cases
    l_rollback_flag := TRUE;

    IF ((p_action_ctl_rec.calling_mode = 'AP')
      AND (p_action_ctl_rec.action = PO_DOCUMENT_ACTION_PVT.g_doc_action_OPEN_INV))
    THEN

      d_progress := 210;

      UPDATE po_line_locations poll
      SET closed_code = 'CLOSED'
      WHERE poll.line_location_id = p_action_ctl_rec.shipment_id
        AND poll.closed_code = 'FINALLY CLOSED';

    END IF;  -- if p_action_ctl_rec.calling_mode = 'AP' ...


    IF ((p_action_ctl_rec.action = PO_DOCUMENT_ACTION_PVT.g_doc_action_FINALLY_CLOSE)
     OR ((p_action_ctl_rec.calling_mode = 'AP') AND
          (p_action_ctl_rec.action = PO_DOCUMENT_ACTION_PVT.g_doc_action_OPEN_INV)))
    THEN

      d_progress := 220;

      handle_close_encumbrance(
         p_document_id        => p_action_ctl_rec.document_id
      ,  p_document_type      => p_action_ctl_rec.document_type
      ,  p_document_subtype   => p_action_ctl_rec.document_subtype
      ,  p_action             => p_action_ctl_rec.action
      ,  p_calling_mode       => p_action_ctl_rec.calling_mode
      ,  p_line_id            => p_action_ctl_rec.line_id
      ,  p_shipment_id        => p_action_ctl_rec.shipment_id
      ,  p_origin_doc_id      => p_action_ctl_rec.origin_doc_id
      ,  p_action_date        => p_action_ctl_rec.action_date
      ,  p_use_gl_date        => p_action_ctl_rec.use_gl_date
      ,  x_return_status      => l_ret_sts
      ,  x_return_code        => l_ret_code
      ,  x_online_report_id   => p_action_ctl_rec.online_report_id
      ,  x_enc_flag           => l_enc_flag
      );

      IF (l_ret_sts <> 'S')
      THEN
        d_progress := 230;
        l_ret_sts := 'U';
        d_msg := 'unexpected error in handle_close_encumbrance';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      IF (l_ret_code IS NOT NULL)
      THEN
        d_progress := 240;
        l_ret_sts := 'S';
        p_action_ctl_rec.return_code := l_ret_code;
        d_msg := 'encumbrance handling not fully successful';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

    END IF;  -- if p_action = FINALLY CLOSE or ...

    d_progress := 250;

    manual_update_closed_status(
       p_document_id      => p_action_ctl_rec.document_id
    ,  p_document_type    => p_action_ctl_rec.document_type
    ,  p_document_subtype => p_action_ctl_rec.document_subtype
    ,  p_action           => p_action_ctl_rec.action
    ,  p_calling_mode     => p_action_ctl_rec.calling_mode
    ,  p_line_id          => p_action_ctl_rec.line_id
    ,  p_shipment_id      => p_action_ctl_rec.shipment_id
    ,  p_user_id          => l_user_id
    ,  p_login_id         => l_login_id
    ,  p_employee_id      => l_emp_id
    ,  p_reason           => p_action_ctl_rec.note
    ,  p_enc_flag         => l_enc_flag
    ,  p_action_date      => p_action_ctl_rec.action_date    -- Bug#18705290
    ,  p_use_gl_date      => p_action_ctl_rec.use_gl_date    -- Bug#18705290
    ,  x_return_status    => l_ret_sts
    );

    IF (l_ret_sts <> 'S')
    THEN
      d_progress := 260;
      l_ret_sts := 'U';
      d_msg := 'unexpected error in updating closed status';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 270;

    rollup_close_state(
       p_document_id      => p_action_ctl_rec.document_id
    ,  p_document_type    => p_action_ctl_rec.document_type
    ,  p_document_subtype => p_action_ctl_rec.document_subtype
    ,  p_action           => p_action_ctl_rec.action
    ,  p_line_id          => p_action_ctl_rec.line_id
    ,  p_shipment_id      => p_action_ctl_rec.shipment_id
    ,  p_user_id          => l_user_id
    ,  p_login_id         => l_login_id
    ,  p_employee_id      => l_emp_id
    ,  p_reason           => p_action_ctl_rec.note
    ,  p_action_date      => SYSDATE
    ,  p_calling_mode     => p_action_ctl_rec.calling_mode
    ,  x_return_status    => l_ret_sts
    );

    IF (l_ret_sts <> 'S')
    THEN
      d_progress := 280;
      l_ret_sts := 'U';
      d_msg := 'unexpected error in rolling up closed status';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 290;

    IF ((p_action_ctl_rec.document_type <> 'PA') AND
        (p_action_ctl_rec.action NOT IN (PO_DOCUMENT_ACTION_PVT.g_doc_action_CLOSE_INV,
                                         PO_DOCUMENT_ACTION_PVT.g_doc_action_OPEN_INV)))
    THEN

     d_progress := 300;

      handle_manual_close_supply(
         p_document_id     => p_action_ctl_rec.document_id
      ,  p_document_type   => p_action_ctl_rec.document_type
      ,  p_action          => p_action_ctl_rec.action
      ,  p_line_id         => p_action_ctl_rec.line_id
      ,  p_shipment_id     => p_action_ctl_rec.shipment_id
      ,  x_return_status   => l_ret_sts
      );

      IF (l_ret_sts <> 'S')
      THEN
        d_progress := 310;
        l_ret_sts := 'U';
        d_msg := 'unexpected error in handling mtl supply';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

    END IF;  -- p_document_type <> 'PA' and ...


--Bug9717420<START> PO_CATALOG_INDEX_PVT.rebuild_index should be called
--to rebuild the index when the POs closed code is altered.

    IF ((p_action_ctl_rec.document_type = 'PA') AND
        (p_action_ctl_rec.document_subtype = 'BLANKET'))
    THEN

      PO_CATALOG_INDEX_PVT.rebuild_index
      (
        p_type => PO_CATALOG_INDEX_PVT.TYPE_BLANKET
      , p_po_header_id => P_ACTION_CTL_REC.document_id
      );

    END IF;
--Bug9717420<END>

    -- <Bug 14271696 :Cancel Refactoring Project Starts >
    -- <Recalculate Qty/Amount Canceled on Finally Close Action>
    -- On Finally Close action, recalculating the amount/qty canceled on
    -- PO/Release Shipments/Distributions and Line qty.
    -- This is to show correct PO total if in case the Invoice is canceled
    -- after the Po is canceled.
    -- So from now, if the Invoice is canceled after the the Po is canceled
    -- Then to see the correct PO total, User ahs to finally close the PO.


    IF (p_action_ctl_rec.action
         = PO_DOCUMENT_ACTION_PVT.g_doc_action_FINALLY_CLOSE) THEN

      PO_Document_Cancel_PVT.calculate_qty_cancel(
        p_api_version       =>1.0,
        p_init_msg_list     => FND_API.G_FALSE,
        p_doc_header_id     =>p_action_ctl_rec.document_id,
        p_line_id           =>p_action_ctl_rec.line_id,
        p_line_location_id  =>p_action_ctl_rec.shipment_id,
        p_document_type     =>p_action_ctl_rec.document_type,
        p_doc_subtype       =>p_action_ctl_rec.document_subtype,
        p_action_date       =>p_action_ctl_rec.action_date,
        x_return_status     =>l_ret_sts);

    END IF;

    IF (l_ret_sts = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (l_ret_sts = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

     -- <Bug 14271696 :Cancel Refactoring Project ends >

    p_action_ctl_rec.return_code := NULL;
    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      IF (l_ret_sts = 'S') THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, d_msg);
        END IF;
      ELSIF (l_ret_sts = 'U') THEN
        IF (PO_LOG.d_exc) THEN
          PO_LOG.exc(d_module, d_progress, d_msg);
        END IF;
        PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
      END IF;

      IF (l_rollback_flag) THEN
        ROLLBACK TO DA_MANUAL_CLOSE_SP;
      END IF;
  END;

  -- <Bug 4118145: Issue 7>: Return l_ret_sts instead of a hardcoded 'S'.
  p_action_ctl_rec.return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_code', p_action_ctl_rec.return_code);
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.online_report_id', p_action_ctl_rec.online_report_id);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    p_action_ctl_rec.return_status := 'U';

    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
      PO_LOG.proc_return(d_module, FALSE);
      PO_LOG.proc_end(d_module);
    END IF;

    IF (l_rollback_flag) THEN
      ROLLBACK TO DA_MANUAL_CLOSE_SP;
    END IF;

    RETURN;

END manual_close_po;

------------------------------------------------------------------------------
--Start of Comments
--Name: auto_close_po
--Pre-reqs:
--  Document is locked.
--  Org context is set to that of document.
--Modifies:
--  None, directly.
--Locks:
--  None.
--Function:
--  This procedure handles the logic for automatically opening or closing
--  a document entity based on the quantity/amount received/billed.
--  The logic is:
--    1. For purchase agreements, immediately return successfully.
--    2. get user_id, login_id, and employee_id
--    3. do a document state check, e.g. has proper authorization status
--    4. update shipment closed statuses based on quantities/amounts
--    5. rollup closed status changes as necessary to higher levels
--       this also handles the action history
--    6. handle supply
--Replaces:
--  This method covers pocupdate_close in pocup.lpc.
--Parameters:
--IN:
--  p_action_ctl_rec
--    Record containing all necessary parameters for close action.
--OUT:
--  p_action_ctl_rec
--    Record contains variables that record output values depending
--    on the action.  All actions will populate at least a return_status.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE auto_close_po(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
)
IS

d_module      VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CLOSE.auto_close_po';
d_progress    NUMBER;
d_msg         VARCHAR2(200);

l_ret_sts     VARCHAR2(1);

l_user_id     NUMBER;
l_login_id    NUMBER;

l_emp_flag    BOOLEAN;
l_emp_id      NUMBER;

l_state_check_ok    BOOLEAN;
l_reason            VARCHAR2(256);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_id', p_action_ctl_rec.document_id);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_type', p_action_ctl_rec.document_type);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_subtype', p_action_ctl_rec.document_subtype);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.line_id', p_action_ctl_rec.line_id);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.shipment_id', p_action_ctl_rec.shipment_id);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.action', p_action_ctl_rec.action);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.called_from_conc', p_action_ctl_rec.called_from_conc);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.calling_mode', p_action_ctl_rec.calling_mode);
  END IF;

  d_progress := 3;
  l_reason := FND_MESSAGE.GET_STRING('PO', 'PO_UPDATE_CLOSE_ROLLUP');

  BEGIN

    d_progress := 5;
    --bug8668066
    IF (p_action_ctl_rec.document_type = 'PA' AND p_action_ctl_rec.document_subtype = 'CONTRACT')
    THEN
      d_progress := 7;
      l_ret_sts := 'S';
      d_msg := 'do nothing for a PA';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 10;

    l_user_id := FND_GLOBAL.USER_ID;

    IF (l_user_id = -1)
    THEN
      d_progress := 20;
      l_ret_sts := 'U';
      d_msg := 'user id not found';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 30;

    IF (p_action_ctl_rec.called_from_conc)
    THEN
      l_login_id := FND_GLOBAL.CONC_LOGIN_ID;
    ELSE
      l_login_id := FND_GLOBAL.LOGIN_ID;
    END IF;

    d_progress := 40;


    -- <Bug 4118145: Issue 4>: From approval workflow,
    -- login_id can be -1; this is now allowed.

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_login_id', l_login_id);
      PO_LOG.stmt(d_module, d_progress, 'l_user_id', l_user_id);
    END IF;

    d_progress := 50;

    PO_DOCUMENT_ACTION_UTIL.get_employee_id(
       p_user_id       => l_user_id
    ,  x_return_status => l_ret_sts
    ,  x_employee_flag => l_emp_flag
    ,  x_employee_id   => l_emp_id
    );

    IF (l_ret_sts <> 'S')
    THEN
      d_progress := 60;
      l_ret_sts := 'U';
      d_msg := 'get_employee_id not successful';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    IF (NOT l_emp_flag)
    THEN

      d_progress := 70;
      l_emp_id := NULL;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'user is not an employee');
      END IF;

    END IF;

    d_progress := 80;

    l_state_check_ok := auto_close_state_check(
       p_document_id     => p_action_ctl_rec.document_id
    ,  p_document_type   => p_action_ctl_rec.document_type
    ,  p_line_id         => p_action_ctl_rec.line_id
    ,  p_shipment_id     => p_action_ctl_rec.shipment_id
    ,  x_return_status   => l_ret_sts
    );

    IF (l_ret_sts <> 'S')
    THEN
      d_progress := 90;
      l_ret_sts := 'U';
      d_msg := 'auto_close_state_check not successful';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    IF (NOT l_state_check_ok)
    THEN
      d_progress := 100;
      l_ret_sts := 'S';
      d_msg := 'document state is not valid for action';
      p_action_ctl_rec.return_code := 'STATE_FAILED';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 110;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'State check passed.');
    END IF;

    auto_update_closed_status(
       p_document_id      => p_action_ctl_rec.document_id
    ,  p_document_type    => p_action_ctl_rec.document_type
    ,  p_calling_mode     => p_action_ctl_rec.calling_mode
    ,  p_line_id          => p_action_ctl_rec.line_id
    ,  p_shipment_id      => p_action_ctl_rec.shipment_id
    ,  p_user_id          => l_user_id   --bug4964600
    ,  p_login_id         => l_login_id  --bug4964600
    ,  p_employee_id      => l_emp_id
    ,  p_reason           => l_reason
    ,  x_return_status    => l_ret_sts
    );

    IF (l_ret_sts <> 'S')
    THEN
      d_progress := 120;
      l_ret_sts := 'U';
      d_msg := 'unexpected error in updating closed status';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 130;

    rollup_close_state(
       p_document_id      => p_action_ctl_rec.document_id
    ,  p_document_type    => p_action_ctl_rec.document_type
    ,  p_document_subtype => p_action_ctl_rec.document_subtype
    ,  p_action           => p_action_ctl_rec.action
    ,  p_line_id          => p_action_ctl_rec.line_id
    ,  p_shipment_id      => p_action_ctl_rec.shipment_id
    ,  p_user_id          => l_user_id
    ,  p_login_id         => l_login_id
    ,  p_employee_id      => l_emp_id
    ,  p_reason           => l_reason
    ,  p_action_date      => SYSDATE
    ,  p_calling_mode     => p_action_ctl_rec.calling_mode
    ,  x_return_status    => l_ret_sts
    );

    IF (l_ret_sts <> 'S')
    THEN
      d_progress := 140;
      l_ret_sts := 'U';
      d_msg := 'unexpected error in rolling up closed status';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;


    IF (p_action_ctl_rec.calling_mode <> 'AP')
    THEN

      d_progress := 150;

      handle_auto_close_supply(
         p_document_id     => p_action_ctl_rec.document_id
      ,  p_document_type   => p_action_ctl_rec.document_type
      ,  p_line_id         => p_action_ctl_rec.line_id
      ,  p_shipment_id     => p_action_ctl_rec.shipment_id
      ,  x_return_status   => l_ret_sts
      );

      IF (l_ret_sts <> 'S')
      THEN
        d_progress := 160;
        l_ret_sts := 'U';
        d_msg := 'unexpected error in handling mtl supply';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

    END IF;  -- if p_action_ctl_rec.calling_mode <> 'AP'


--Bug9717420<START> PO_CATALOG_INDEX_PVT.rebuild_index should be called
--to rebuild the index when the POs closed code is altered.
   IF ((p_action_ctl_rec.document_type = 'PA') AND
        (p_action_ctl_rec.document_subtype = 'BLANKET'))
    THEN

      PO_CATALOG_INDEX_PVT.rebuild_index
      (
        p_type => PO_CATALOG_INDEX_PVT.TYPE_BLANKET
      , p_po_header_id => P_ACTION_CTL_REC.document_id
      );

   END IF;

   --Bug9717420<END>


    p_action_ctl_rec.return_code := NULL;
    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      IF (l_ret_sts = 'S') THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, d_msg);
        END IF;
      ELSIF (l_ret_sts = 'U') THEN
        IF (PO_LOG.d_exc) THEN
          PO_LOG.exc(d_module, d_progress, d_msg);
        END IF;
        PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
      END IF;
  END;

  p_action_ctl_rec.return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_code', p_action_ctl_rec.return_code);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    p_action_ctl_rec.return_status := 'U';

    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
      PO_LOG.proc_return(d_module, FALSE);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END auto_close_po;



-- Private methods

------------------------------------------------------------------------------
--Start of Comments
--Name: manual_close_state_check
--Pre-reqs:
--  Org context is set to that of document.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function does the document state check for a manual
--  close action.  Checks authorization status at the header level
--  and closed status at the lowest entity id passed in (e.g shipment over
--  header).
--  The logic is:
--    1. for AP invoice open, check if a level higher than
--       the shipment being re-opened is finally closed.  If so, state_failed.
--    2. depending on action, build the allowed states record.
--    3. call the doc state check utility method
--Replaces:
--  This logic is inside of poccstatus in poccs.lpc.
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO'
--  p_action
--    A manual close action.  Use g_doc_action_<> constant where possible.
--    'INVOICE OPEN', 'INVOICE CLOSE', 'OPEN', 'CLOSE', 'RECEIVE OPEN'
--    'RECEIVE CLOSE', 'FINALLY CLOSE'
--  p_calling_mode
--    'PO', 'RCV', or 'AP'
--  p_line_id
--    If acting on a header, pass NULL
--    If acting on a line, pass in the po_line_id of the line.
--    If acting on a shipment, pass in the po_line_id of the shipment's line.
--  p_shipment_id
--    If acting on a header, pass NULL
--    If acting on a line, pass NULL
--    If acting on a shipment, pass in the line_location_id of the shipment
--OUT:
--  x_return_status
--    'S': state check had no unexpected errors
--         In this case, check return value of function
--    'U': state check failed with unexpected errors
--  return value:
--    FALSE: Document state check failed
--    TRUE: state check was successful
--End of Comments
-------------------------------------------------------------------------------
FUNCTION manual_close_state_check(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_action            IN      VARCHAR2
,  p_calling_mode      IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  x_return_status     OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS

d_module     VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CLOSE.manual_close_state_check';
d_progress   NUMBER;
d_msg        VARCHAR2(200);

l_allowed_states       PO_DOCUMENT_ACTION_UTIL.doc_state_rec_type;
l_line_finally_closed  NUMBER;

l_state_check_ok       BOOLEAN;

l_ret_sts   VARCHAR2(1);
l_ret_val   BOOLEAN;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_line_id', p_line_id);
    PO_LOG.proc_begin(d_module, 'p_shipment_id', p_shipment_id);
    PO_LOG.proc_begin(d_module, 'p_action', p_action);
    PO_LOG.proc_begin(d_module, 'p_calling_mode', p_calling_mode);
  END IF;

  BEGIN

    d_progress := 10;

    IF ((p_calling_mode = 'AP') AND (p_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_OPEN_INV))
    THEN

      -- bug 3454885
      -- If a parent entity of the shipment is FINALLY CLOSED,
      -- then do not update the shipment to CLOSED.
      -- This would cause an inconsistent state, as the FINAL CLOSE
      -- action would not be allowed on the parent if this shipment
      -- was not FINALLY CLOSED.

      -- The COUNT(*) will return either 0 or 1, and no exception handling
      -- is necessary for NO_DATA_FOUND (0 will be returned).

      --SQL What:
      --    Determine if any parent entity of the shipment is finally closed.
      --SQL Why:
      --    The shipment cannot be re-opened if a parent entity is
      --    finally closed.
      --SQL Where:
      --    Outer joins are used because POs do not have Release headers,
      --    and only SRs have source shipments.

      d_progress := 20;

      SELECT count(*)
      INTO l_line_finally_closed
      FROM po_line_locations_all poll
        ,  po_lines_all pol
        ,  po_releases_all por
        ,  po_line_locations_all ppo_ll
      WHERE poll.line_location_id = p_shipment_id
      AND   pol.po_line_id = poll.po_line_id
      AND   por.po_release_id(+) = poll.po_release_id
      AND   ppo_ll.line_location_id(+) = poll.source_shipment_id
      AND ( pol.closed_code = PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_FIN_CLOSED
         OR por.closed_code = PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_FIN_CLOSED
         OR ppo_ll.closed_code = PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_FIN_CLOSED
         )
      ;

      IF (l_line_finally_closed > 0)
      THEN
        d_progress := 30;
        l_ret_sts := 'S';
        d_msg := 'line is finally closed for this shipment';
        l_ret_val := FALSE;
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

    END IF;  -- p_calling_mode = 'AP' AND p_action = 'INVOICE OPEN'

    d_progress := 40;

    l_allowed_states.auth_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED;
    l_allowed_states.hold_flag := NULL;
    l_allowed_states.frozen_flag := NULL;
    l_allowed_states.fully_reserved_flag := NULL;

    IF (p_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_CLOSE_INV)
    THEN

      l_allowed_states.closed_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_OPEN;
      l_allowed_states.closed_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED_RCV;

    ELSIF (p_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_CLOSE_RCV)
    THEN

      l_allowed_states.closed_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_OPEN;
      l_allowed_states.closed_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED_INV;

    ELSIF (p_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_CLOSE)
    THEN

      l_allowed_states.closed_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_OPEN;
      l_allowed_states.closed_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED_RCV;
      l_allowed_states.closed_states(3) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED_INV;

    ELSIF (p_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_FINALLY_CLOSE)
    THEN

      l_allowed_states.closed_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_OPEN;
      l_allowed_states.closed_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED_RCV;
      l_allowed_states.closed_states(3) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED_INV;
      l_allowed_states.closed_states(4) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED;

    ELSIF (p_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_OPEN)
    THEN

      l_allowed_states.closed_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_OPEN;
      l_allowed_states.closed_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED_RCV;
      l_allowed_states.closed_states(3) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED_INV;
      l_allowed_states.closed_states(4) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED;

    ELSIF (p_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_OPEN_INV)
    THEN

      l_allowed_states.closed_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_OPEN;
      l_allowed_states.closed_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED_INV;
      l_allowed_states.closed_states(3) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED;

      -- <Bug 4118145, Issue 9 Start>
      -- Allow finally closed for AP re-open finally closed document (AP invoice open)

      IF (p_calling_mode = 'AP')
      THEN
        l_allowed_states.closed_states(4) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_FIN_CLOSED;
      END IF;

      -- <Bug 4118145, Issue 9 End>

    ELSIF (p_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_OPEN_RCV)
    THEN

      l_allowed_states.closed_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_OPEN;
      l_allowed_states.closed_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED_RCV;
      l_allowed_states.closed_states(3) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED;

    ELSE

        d_progress := 50;
        l_ret_sts := 'U';
        d_msg := 'unsupported close action';
        RAISE PO_CORE_S.g_early_return_exc;

    END IF;  -- p_action = ...

    d_progress := 60;

    l_state_check_ok := PO_DOCUMENT_ACTION_UTIL.check_doc_state(
                           p_document_id    => p_document_id
                        ,  p_document_type  => p_document_type
                        ,  p_line_id        => p_line_id
                        ,  p_shipment_id    => p_shipment_id
                        ,  p_allowed_states => l_allowed_states
                        ,  x_return_status  => l_ret_sts
                        );

    IF (l_ret_sts <> 'S')
    THEN
      d_progress := 70;
      l_ret_sts := 'U';
      d_msg := 'check_doc_state not successful';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 80;
    l_ret_val := l_state_check_ok;
    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      IF (l_ret_sts = 'S') THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, d_msg);
        END IF;
      ELSIF (l_ret_sts = 'U') THEN
        IF (PO_LOG.d_exc) THEN
          PO_LOG.exc(d_module, d_progress, d_msg);
        END IF;
        PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
        l_ret_val := FALSE;
      END IF;
  END;

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_return(d_module, l_ret_val);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN l_ret_val;

EXCEPTION
  WHEN others THEN
    x_return_status := 'U';

    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_return(d_module, FALSE);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN FALSE;

END manual_close_state_check;

------------------------------------------------------------------------------
--Start of Comments
--Name: auto_close_state_check
--Pre-reqs:
--  Org context is set to that of document.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function does the document state check for the auto
--  close action.  Checks authorization status at the header level
--  and closed status at the lowest entity id passed in (e.g shipment over
--  header).
--  The logic is:
--    1. build the allowed states record.
--    2. call the doc state check utility method
--Replaces:
--  This logic is inside of pocupdate_close in pocup.lpc.
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO'
--  p_line_id
--    If acting on a header, pass NULL
--    If acting on a line, pass in the po_line_id of the line.
--    If acting on a shipment, pass in the po_line_id of the shipment's line.
--  p_shipment_id
--    If acting on a header, pass NULL
--    If acting on a line, pass NULL
--    If acting on a shipment, pass in the line_location_id of the shipment
--OUT:
--  x_return_status
--    'S': state check had no unexpected errors
--         In this case, check return value of function
--    'U': state check failed with unexpected errors
--  return value:
--    FALSE: Document state check failed
--    TRUE: state check was successful
--End of Comments
-------------------------------------------------------------------------------
FUNCTION auto_close_state_check(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  x_return_status     OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS

d_module     VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CLOSE.auto_close_state_check';
d_progress   NUMBER;
d_msg        VARCHAR2(200);

l_allowed_states       PO_DOCUMENT_ACTION_UTIL.doc_state_rec_type;

l_state_check_ok       BOOLEAN;

l_ret_sts   VARCHAR2(1);
l_ret_val   BOOLEAN;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_line_id', p_line_id);
    PO_LOG.proc_begin(d_module, 'p_shipment_id', p_shipment_id);
  END IF;

  BEGIN

    d_progress := 10;

    l_allowed_states.auth_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED;
    l_allowed_states.auth_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_status_INCOMPLETE;
    l_allowed_states.auth_states(3) := PO_DOCUMENT_ACTION_PVT.g_doc_status_INPROCESS;
    l_allowed_states.auth_states(4) := PO_DOCUMENT_ACTION_PVT.g_doc_status_REJECTED;
    l_allowed_states.auth_states(5) := PO_DOCUMENT_ACTION_PVT.g_doc_status_RETURNED;
    l_allowed_states.auth_states(6) := PO_DOCUMENT_ACTION_PVT.g_doc_status_REAPPROVAL;
    l_allowed_states.auth_states(7) := PO_DOCUMENT_ACTION_PVT.g_doc_status_PREAPPROVED;
    l_allowed_states.auth_states(8) := PO_DOCUMENT_ACTION_PVT.g_doc_status_SENT;

    l_allowed_states.hold_flag := NULL;
    l_allowed_states.frozen_flag := NULL;
    l_allowed_states.fully_reserved_flag := NULL;

    l_allowed_states.closed_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_OPEN;
    l_allowed_states.closed_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED_RCV;
    l_allowed_states.closed_states(3) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED_INV;
    l_allowed_states.closed_states(4) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED;

    d_progress := 20;

    l_state_check_ok := PO_DOCUMENT_ACTION_UTIL.check_doc_state(
                           p_document_id    => p_document_id
                        ,  p_document_type  => p_document_type
                        ,  p_line_id        => p_line_id
                        ,  p_shipment_id    => p_shipment_id
                        ,  p_allowed_states => l_allowed_states
                        ,  x_return_status  => l_ret_sts
                        );

    IF (l_ret_sts <> 'S')
    THEN
      d_progress := 30;
      l_ret_sts := 'U';
      d_msg := 'check_doc_state not successful';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 40;
    l_ret_val := l_state_check_ok;
    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      IF (l_ret_sts = 'S') THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, d_msg);
        END IF;
      ELSIF (l_ret_sts = 'U') THEN
        IF (PO_LOG.d_exc) THEN
          PO_LOG.exc(d_module, d_progress, d_msg);
        END IF;
        PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
        l_ret_val := FALSE;
      END IF;
  END;

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_return(d_module, l_ret_val);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN l_ret_val;

EXCEPTION
  WHEN others THEN
    x_return_status := 'U';

    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_return(d_module, FALSE);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN FALSE;

END auto_close_state_check;

------------------------------------------------------------------------------
--Start of Comments
--Name: manual_close_submission_check
--Pre-reqs:
--  Org context is set to that of document.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function does the document submission check for a manual
--  close action.  Submission checks are only necessary for final close.
--  The logic is:
--    1. if action is not final close, return successfully.
--    2. call PO_DOCUMENT_CHECKS_GRP api to run final close submission check.
--    3. for SPO and releases, run an extra drop ship check
--Replaces:
--  This logic merges code from manual_close in POXPOACB.pls
--  and poccstatus in poccs.lpc.
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO'
--  p_document_subtype
--    'RELEASE': 'BLANKET', 'SCHEDULED'
--    'PO': 'PLANNED', 'STANDARD'
--  p_action
--    A manual close action.  Use g_doc_action_<> constant where possible.
--    'INVOICE OPEN', 'INVOICE CLOSE', 'OPEN', 'CLOSE', 'RECEIVE OPEN'
--    'RECEIVE CLOSE', 'FINALLY CLOSE'
--  p_calling_mode
--    'PO', 'RCV', or 'AP'
--  p_line_id
--    If acting on a header, pass NULL
--    If acting on a line, pass in the po_line_id of the line.
--    If acting on a shipment, pass in the po_line_id of the shipment's line.
--  p_shipment_id
--    If acting on a header, pass NULL
--    If acting on a line, pass NULL
--    If acting on a shipment, pass in the line_location_id of the shipment
--OUT:
--  x_return_status
--    'S': submission check had no unexpected errors
--         In this case, check return value of function
--    'U': state check failed with unexpected errors
--  return value:
--    TRUE: Document submission check passed without errors
--    FALSE: submission check caught at least one error
--  x_online_report_id:
--    ID into online_report_text table to get submission check messages
--End of Comments
-------------------------------------------------------------------------------
FUNCTION manual_close_submission_check(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_document_subtype  IN      VARCHAR2
,  p_action            IN      VARCHAR2
,  p_calling_mode      IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  p_origin_doc_id     IN      NUMBER -- Bug#5462677
,  x_return_status     OUT NOCOPY  VARCHAR2
,  x_online_report_id  OUT NOCOPY  NUMBER
) RETURN BOOLEAN
IS

d_module     VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CLOSE.manual_close_submission_check';
d_progress   NUMBER;
d_msg        VARCHAR2(200);

l_ret_val   BOOLEAN;
l_ret_sts        VARCHAR2(1);

l_sub_check_sts          VARCHAR2(1);
l_document_level         VARCHAR2(25);
l_document_level_id      NUMBER;
l_msg_data               VARCHAR2(2000);
l_doc_check_error_rec    DOC_CHECK_RETURN_TYPE;

l_dropship_chk_succ      BOOLEAN;
l_dropship_chk_retcode   VARCHAR2(25);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_shipment_id', p_shipment_id);
    PO_LOG.proc_begin(d_module, 'p_action', p_action);
    PO_LOG.proc_begin(d_module, 'p_calling_mode', p_calling_mode);
  END IF;

  BEGIN

    d_progress := 10;

    IF (p_action <> PO_DOCUMENT_ACTION_PVT.g_doc_action_FINALLY_CLOSE)
    THEN

      d_progress := 20;
      x_online_report_id := NULL;
      l_ret_sts := 'S';
      l_ret_val := TRUE;
      d_msg := 'No submission checks needed.';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 100;

    IF (p_shipment_id IS NOT NULL)
    THEN

      l_document_level := PO_DOCUMENT_CHECKS_GRP.g_document_level_SHIPMENT;
      l_document_level_id := p_shipment_id;

    ELSIF (p_line_id IS NOT NULL)
    THEN

      l_document_level := PO_DOCUMENT_CHECKS_GRP.g_document_level_LINE;
      l_document_level_id := p_line_id;

    ELSE

      l_document_level := PO_DOCUMENT_CHECKS_GRP.g_document_level_HEADER;
      l_document_level_id := p_document_id;

    END IF;

    d_progress := 110;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_document_level', l_document_level);
      PO_LOG.stmt(d_module, d_progress, 'l_document_level_id', l_document_level_id);
    END IF;

    PO_DOCUMENT_CHECKS_GRP.po_submission_check(
       p_api_version        => 1.0
    ,  p_action_requested   => PO_DOCUMENT_CHECKS_GRP.g_action_FINAL_CLOSE_CHECK
    ,  p_document_type      => p_document_type
    ,  p_document_subtype   => p_document_subtype
    ,  p_document_level     => l_document_level
    ,  p_document_level_id  => l_document_level_id
    ,  p_org_id             => NULL
    ,  p_requested_changes  => NULL
    ,  p_check_asl          => FALSE
    ,  p_origin_doc_id      => p_origin_doc_id --Bug#5462677
    ,  x_return_status      => l_ret_sts
    ,  x_sub_check_status   => l_sub_check_sts
    ,  x_msg_data           => l_msg_data
    ,  x_online_report_id   => x_online_report_id
    ,  x_doc_check_error_record => l_doc_check_error_rec
    );

    IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS)
    THEN
      d_progress := 120;
      l_ret_sts := 'U';
      d_msg := 'unexpected error in po_submission_check';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    IF (l_sub_check_sts <> FND_API.G_RET_STS_SUCCESS)
    THEN
      d_progress := 130;
      l_ret_sts := 'S';
      l_ret_val := FALSE;
      d_msg := 'submission check failed';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

   d_progress := 140;

   IF ((p_document_type = 'RELEASE')
        OR (p_document_type = 'PO' AND p_document_subtype = 'STANDARD'))
   THEN

     d_progress := 150;

     l_dropship_chk_succ := PO_CONTROL_CHECKS.chk_drop_ship(
                               p_doctyp      => p_document_type
                            ,  p_docid       => p_document_id
                            ,  p_lineid      => p_line_id
                            ,  p_shipid      => p_shipment_id
                            ,  p_reportid    => x_online_report_id
                            ,  p_action      => 'FINALLY CLOSE'
                            ,  p_return_code => l_dropship_chk_retcode
                            );

      IF (NOT l_dropship_chk_succ)
      THEN
        d_progress := 160;
        l_ret_sts := 'U';
        d_msg := 'unexpected error in chk_drop_ship';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      IF (l_dropship_chk_retcode = 'SUBMISSION_FAILED')
      THEN
        d_progress := 170;
        l_ret_sts := 'S';
        l_ret_val := FALSE;
        d_msg := 'dropship check failed';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

    END IF;  -- if p_document_type = 'RELEASE' ...

    d_progress := 180;

    l_ret_sts := 'S';
    l_ret_val := TRUE;

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      IF (l_ret_sts = 'S') THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, d_msg);
        END IF;
      ELSIF (l_ret_sts = 'U') THEN
        IF (PO_LOG.d_exc) THEN
          PO_LOG.exc(d_module, d_progress, d_msg);
        END IF;
        PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
        l_ret_val := FALSE;
      END IF;
  END;

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_online_report_id', x_online_report_id);
    PO_LOG.proc_return(d_module, l_ret_val);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN l_ret_val;

EXCEPTION
  WHEN others THEN
    x_return_status := 'U';

    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_return(d_module, FALSE);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN FALSE;

END manual_close_submission_check;


------------------------------------------------------------------------------
--Start of Comments
--Name: handle_close_encumbrance
--Pre-reqs:
--  Org context is set to that of document.
--Modifies:
--  None, directly.
--Locks:
--  None, directly.
--Function:
--  This procedure handles encumbrance for the manual close actions
--  final close and AP invoice open.
--  The logic is:
--    1. determine if an encumbrance situation applies.  return successfully
--       if not encumbrance action is required.
--    2. call appropriate PO_DOCUMENT_FUNDS_PVT api
--    3. wrap the return values of the API into our return values
--Replaces:
--  This logic is inside of poccstatus in poccs.lpc.
--Parameters:
--IN:
--  p_document_id
--    ID of the document's header (e.g. po_release_id, po_header_id, ...)
--  p_document_type
--    'RELEASE', 'PO'
--  p_action
--    'INVOICE OPEN', 'FINALLY CLOSE'
--  p_calling_mode
--    'FINALLY CLOSE': 'PO', 'RCV', or 'AP'
--    'INVOICE OPEN': 'AP'
--  p_line_id
--    If acting on a header, pass NULL
--    If acting on a line, pass in the po_line_id of the line.
--    If acting on a shipment, pass in the po_line_id of the shipment's line.
--  p_shipment_id
--    If acting on a header, pass NULL
--    If acting on a line, pass NULL
--    If acting on a shipment, pass in the line_location_id of the shipment
--  p_origin_doc_id
--    For calling mode = 'AP', the id of the invoice
--    Required for encumbrance/JFMIP purposes
--  p_action_date
--    passed to encumbrance APIs
--  p_use_gl_date
--    'Y' or 'N'; passed to encumbrance APIs
--OUT:
--  x_return_status
--    'S': procedure had no unexpected errors
--         In this case, check x_return_code of procedure
--    'U': procedure failed with unexpected errors
--  x_return_code:
--    'P', 'F', 'T': Encumbrance call not fully successful.
--    NULL: encumbrance action was fully successful
--  x_online_report_id
--    ID into online_report_text table to get encumbrance error messages
--  x_enc_flag
--    TRUE: encumbrance action was required
--    FALSE: encumbrance action was not required
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE handle_close_encumbrance(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_document_subtype  IN      VARCHAR2
,  p_action            IN      VARCHAR2
,  p_calling_mode      IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  p_origin_doc_id     IN      NUMBER
,  p_action_date       IN      DATE
,  p_use_gl_date       IN      VARCHAR2
,  x_return_status     OUT NOCOPY  VARCHAR2
,  x_return_code       OUT NOCOPY  VARCHAR2
,  x_online_report_id  OUT NOCOPY  NUMBER
,  x_enc_flag          OUT NOCOPY  BOOLEAN
)
IS

d_module     VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CLOSE.handle_close_encumbrance';
d_progress   NUMBER;
d_msg        VARCHAR2(200);

l_ret_sts   VARCHAR2(1);

l_enc_ret_code           VARCHAR2(10);
l_document_level         VARCHAR2(25);
l_document_level_id      NUMBER;

l_enc_flag          BOOLEAN;
l_bpa_enc_required  VARCHAR2(1);



BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_line_id', p_line_id);
    PO_LOG.proc_begin(d_module, 'p_shipment_id', p_shipment_id);
    PO_LOG.proc_begin(d_module, 'p_action', p_action);
    PO_LOG.proc_begin(d_module, 'p_calling_mode', p_calling_mode);
    PO_LOG.proc_begin(d_module, 'p_action_date', p_action_date);
    PO_LOG.proc_begin(d_module, 'p_origin_doc_id', p_origin_doc_id);
  END IF;

  BEGIN

    d_progress := 10;

    l_enc_flag := PO_CORE_S.is_encumbrance_on(
                     p_doc_type => p_document_type
                  ,  p_org_id => NULL
                  );

    IF ((l_enc_flag) AND (p_document_type = 'PA') AND (p_document_subtype = 'CONTRACT'))
    THEN

      d_progress := 20;
      l_enc_flag := FALSE;

    ELSIF ((l_enc_flag) AND (p_document_type = 'PA') AND (p_document_subtype = 'BLANKET'))
    THEN

      IF ((p_shipment_id IS NOT NULL) OR (p_line_id IS NOT NULL))
      THEN

        d_progress := 30;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'Trying to finally close/open invoice a BPA, but not at header level.');
        END IF;

        l_enc_flag := FALSE;

      ELSE

        d_progress := 40;

        SELECT NVL(poh.encumbrance_required_flag, 'N')
        INTO l_bpa_enc_required
        FROM po_headers_all poh
        WHERE poh.po_header_id = p_document_id;

        d_progress := 50;
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'l_bpa_enc_required', l_bpa_enc_required);
        END IF;

        IF (l_bpa_enc_required = 'Y')
        THEN
          l_enc_flag := TRUE;
        ELSE
          l_enc_flag := FALSE;
        END IF;  -- l_bpa_enc_required = 'Y'

      END IF;  -- if p_shipment_id is not null or...

    END IF;  -- if l_enc_flag and document_type = 'PA' ...

    --
    -- Bug#18453368 :  assign l_enc_flag to x_enc_flag
    --
    x_enc_flag := l_enc_flag;
    -- end of bug#18453368

    d_progress := 60;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_enc_flag', l_enc_flag);
    END IF;

    IF (NOT l_enc_flag) THEN
      d_progress := 70;
      d_msg := 'encumbrance action not required';
      x_return_code := NULL;
      x_online_report_id := NULL;
      l_ret_sts := 'S';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 80;

    IF (p_shipment_id IS NOT NULL)
    THEN

      l_document_level := PO_DOCUMENT_FUNDS_PVT.g_doc_level_SHIPMENT;
      l_document_level_id := p_shipment_id;

    ELSIF (p_line_id IS NOT NULL)
    THEN

      l_document_level := PO_DOCUMENT_FUNDS_PVT.g_doc_level_LINE;
      l_document_level_id := p_line_id;

    ELSE

      l_document_level := PO_DOCUMENT_FUNDS_PVT.g_doc_level_HEADER;
      l_document_level_id := p_document_id;

    END IF; -- if p_shipment_id is not null


    IF (p_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_FINALLY_CLOSE)
    THEN

      d_progress := 90;

      PO_DOCUMENT_FUNDS_PVT.do_final_close(
         x_return_status      => l_ret_sts
      ,  p_doc_type           => p_document_type
      ,  p_doc_subtype        => p_document_subtype
      ,  p_doc_level          => l_document_level
      ,  p_doc_level_id       => l_document_level_id
      ,  p_use_enc_gt_flag    => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO
      ,  p_use_gl_date        => p_use_gl_date
      ,  p_override_date      => p_action_date
      ,  p_invoice_id         => p_origin_doc_id
      ,  x_po_return_code     => l_enc_ret_code
      ,  x_online_report_id   => x_online_report_id
      );

    ELSE /* INVOICE OPEN */

      d_progress := 100;

     PO_DOCUMENT_FUNDS_PVT.undo_final_close(
         x_return_status      => l_ret_sts
      ,  p_doc_type           => p_document_type
      ,  p_doc_subtype        => p_document_subtype
      ,  p_doc_level          => l_document_level
      ,  p_doc_level_id       => l_document_level_id
      ,  p_use_enc_gt_flag    => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO
      ,  p_override_funds     => PO_DOCUMENT_FUNDS_PVT.g_parameter_USE_PROFILE
      ,  p_use_gl_date        => p_use_gl_date
      ,  p_override_date      => p_action_date
      ,  p_invoice_id         => p_origin_doc_id
      ,  x_po_return_code     => l_enc_ret_code
      ,  x_online_report_id   => x_online_report_id
      );

    END IF;  -- if p_action = FINALLY CLOSE

    IF (l_ret_sts <> FND_API.g_ret_sts_success)
    THEN

      d_progress := 110;
      l_ret_sts := 'U';
      d_msg := 'unexpected error in encumbrance action';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 120;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_enc_ret_code', l_enc_ret_code);
      PO_LOG.stmt(d_module, d_progress, 'x_online_report_id', x_online_report_id);
    END IF;


    IF ((l_enc_ret_code = PO_DOCUMENT_FUNDS_PVT.g_return_SUCCESS)
         OR (l_enc_ret_code = PO_DOCUMENT_FUNDS_PVT.g_return_WARNING))
    THEN

      d_progress := 125;
      d_msg := 'encumbrance action fully successful';
      x_return_code := NULL;

    ELSIF (l_enc_ret_code = PO_DOCUMENT_FUNDS_PVT.g_return_PARTIAL)
    THEN

      d_progress := 130;
      d_msg := 'encumbrance action partially successful';
      x_return_code := 'P';

    ELSIF (l_enc_ret_code = PO_DOCUMENT_FUNDS_PVT.g_return_FAILURE)
    THEN

      d_progress := 140;
      d_msg := 'encumbrance action failure';
      x_return_code := 'F';

    ELSIF (l_enc_ret_code = PO_DOCUMENT_FUNDS_PVT.g_return_FATAL)
    THEN

      d_progress := 150;
      d_msg := 'encumbrance action fatal';
      x_return_code := 'T';

    ELSE

      d_progress := 160;
      l_ret_sts := 'U';
      d_msg := 'Bad return code from encumbrance call';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;  -- if l_enc_ret_code IN (...)

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, d_msg);
    END IF;

    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      IF (l_ret_sts = 'S') THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, d_msg);
        END IF;
        x_enc_flag := l_enc_flag;
      ELSIF (l_ret_sts = 'U') THEN
        IF (PO_LOG.d_exc) THEN
          PO_LOG.exc(d_module, d_progress, d_msg);
        END IF;
        PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
      END IF;
  END;

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_online_report_id', x_online_report_id);
    PO_LOG.proc_end(d_module, 'x_return_code', x_return_code);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    x_return_status := 'U';

    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END handle_close_encumbrance;


PROCEDURE manual_update_closed_status(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_document_subtype  IN      VARCHAR2
,  p_action            IN      VARCHAR2
,  p_calling_mode      IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  p_user_id           IN      NUMBER
,  p_login_id          IN      NUMBER
,  p_employee_id       IN      NUMBER
,  p_reason            IN      VARCHAR2
,  p_enc_flag          IN      BOOLEAN
,  p_action_date       IN      DATE          -- Bug#18705290
,  p_use_gl_date       IN      VARCHAR2      -- Bug#18705290
,  x_return_status     OUT NOCOPY  VARCHAR2
)
IS

d_module     VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CLOSE.manual_update_close_status';
d_progress   NUMBER;
d_msg        VARCHAR2(200);

l_ret_sts   VARCHAR2(1);

l_id_tbl    g_tbl_number;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_line_id', p_line_id);
    PO_LOG.proc_begin(d_module, 'p_shipment_id', p_shipment_id);
    PO_LOG.proc_begin(d_module, 'p_action', p_action);
    PO_LOG.proc_begin(d_module, 'p_calling_mode', p_calling_mode);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_employee_id', p_employee_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
    PO_LOG.proc_begin(d_module, 'p_reason', p_reason);
    PO_LOG.proc_begin(d_module, 'p_enc_flag', p_enc_flag);
    PO_LOG.proc_begin(d_module, 'p_action_date', p_action_date);    -- Bug#18705290
    PO_LOG.proc_begin(d_module, 'p_use_gl_date', p_use_gl_date);    -- Bug#18705290
  END IF;

  d_progress := 10;

  IF ((p_document_type = 'PA') and (p_document_subtype = 'BLANKET'))
  THEN

    d_progress := 20;

    IF (p_line_id IS NOT NULL)
    THEN

      d_progress := 21;

      SELECT pol.po_line_id
      BULK COLLECT INTO l_id_tbl
      FROM po_lines pol
      WHERE pol.po_line_id = p_line_id;

    ELSE

      d_progress := 22;

      SELECT pol.po_line_id
      BULK COLLECT INTO l_id_tbl
      FROM po_lines pol
      WHERE pol.po_header_id = p_document_id;

    END IF;

    d_progress := 25;

    FORALL i IN 1..l_id_tbl.COUNT
      UPDATE po_lines pol
      SET pol.last_update_date  = SYSDATE
        , pol.last_updated_by   = p_user_id
        , pol.last_update_login = p_login_id
        , pol.closed_date = DECODE(p_action,
                                     'CLOSE', SYSDATE,
                                     'FINALLY CLOSE', SYSDATE,  -- Bug 4369988
                                     NULL)
        , pol.closed_by = p_employee_id
        , pol.closed_reason = p_reason
        , pol.closed_code = DECODE(p_action,
                                     'CLOSE', 'CLOSED',
                                     'FINALLY CLOSE', 'FINALLY CLOSED',
                                     'OPEN', 'OPEN')
      WHERE pol.po_line_id = l_id_tbl(i)
        AND NVL(pol.closed_code, 'OPEN') <> 'FINALLY CLOSED';

	/*< Bug 16294336 > commented this condition as it is not allowing
	to close documents with UOM as 'A', 'B' or 'C'
        AND NVL(pol.unit_meas_lookup_code, 'X') =
                   DECODE(pol.unit_meas_lookup_code,
                            'A', p_document_type,
                            'B', p_document_subtype,
                            'C', p_document_subtype,
                            NVL(pol.unit_meas_lookup_code, 'X'))
	*/


    d_progress := 27;

  ELSIF ((p_document_type = 'PA') and (p_document_subtype = 'CONTRACT')) then

    d_progress := 30;

    UPDATE po_headers poh
    SET poh.last_update_date  = SYSDATE
      , poh.last_updated_by   = p_user_id
      , poh.last_update_login = p_login_id
      , poh.closed_date = DECODE(p_action,
                                     'CLOSE', SYSDATE,
                                     'FINALLY CLOSE', SYSDATE,  -- Bug 4369988
                                     NULL)
      , poh.closed_code = DECODE(p_action,
                                   'CLOSE', 'CLOSED',
                                   'FINALLY CLOSE', 'FINALLY CLOSED',
                                   'OPEN', 'OPEN')
    WHERE poh.po_header_id = p_document_id
      AND NVL(poh.closed_code, 'OPEN') <> 'FINALLY CLOSED';

      /*< Bug 16294336 > commented this condition as it is not allowing
	to close documents with UOM as 'A', 'B' or 'C'
      AND poh.type_lookup_code =
              DECODE(poh.type_lookup_code,
                        'A', p_document_type,
                        'B', p_document_subtype,
                        'C', p_document_subtype,
                        poh.type_lookup_code)
      */

    d_progress := 35;


  ELSE

    d_progress := 40;

    IF (p_shipment_id IS NOT NULL)
    THEN

      d_progress := 41;

      SELECT poll.line_location_id
      BULK COLLECT INTO l_id_tbl
      FROM po_line_locations poll
      WHERE poll.line_location_id = p_shipment_id;

    ELSIF(p_line_id IS NOT NULL)
    THEN

      d_progress := 42;

      SELECT poll.line_location_id
      BULK COLLECT INTO l_id_tbl
      FROM po_line_locations poll
      WHERE poll.po_line_id = p_line_id;

    ELSIF(p_document_type = 'RELEASE')
    THEN

      d_progress := 43;

      SELECT poll.line_location_id
      BULK COLLECT INTO l_id_tbl
      FROM po_line_locations poll
      WHERE poll.po_release_id = p_document_id;

    ELSE

      d_progress := 44;

      SELECT poll.line_location_id
      BULK COLLECT INTO l_id_tbl
      FROM po_line_locations poll
      WHERE poll.po_header_id = p_document_id;

    END IF;

    d_progress := 45;

    --<DBI Req Fulfillment 11.5.11 Start >
    -- Modifed the exisiting sql for shipment closure dates

    FORALL i IN 1..l_id_tbl.COUNT
      UPDATE po_line_locations poll
      SET poll.last_update_date  = SYSDATE
        , poll.last_updated_by   = p_user_id
        , poll.last_update_login = p_login_id
        , poll.closed_date = DECODE(p_action,
                               'CLOSE', DECODE(NVL(poll.closed_code, 'OPEN'),
 	                                           'CLOSED', poll.closed_date,
 	                                           SYSDATE),            -- <Bug#14258051>
                               'FINALLY CLOSE', SYSDATE,
                               'INVOICE CLOSE', DECODE(NVL(poll.closed_code, 'OPEN'),
                                                  'CLOSED FOR RECEIVING', SYSDATE,
                                                  NULL),
                               'RECEIVE CLOSE', DECODE(NVL(poll.closed_code, 'OPEN'),
                                                  'CLOSED FOR INVOICE', SYSDATE,
                                                  NULL)
                             )
        , poll.closed_by = DECODE(p_calling_mode,
                             'AP', DECODE(p_action, 'INVOICE OPEN', NULL, p_employee_id),
                              p_employee_id
                           )
        , poll.closed_reason = DECODE(p_calling_mode,
                                 'AP', DECODE(p_action, 'INVOICE OPEN', NULL, p_reason),
                                 p_reason
                               )
        , poll.closed_code = DECODE(p_action,
                               'CLOSE', 'CLOSED',
                               'FINALLY CLOSE', 'FINALLY CLOSED',
                               'INVOICE CLOSE', DECODE(NVL(poll.closed_code, 'OPEN'),
                                                  'CLOSED FOR RECEIVING', 'CLOSED',
                                                  'OPEN', 'CLOSED FOR INVOICE',
                                                  poll.closed_code),  -- <Bug 4490151>
                               'RECEIVE CLOSE', DECODE(NVL(poll.closed_code, 'OPEN'),
                                                  'CLOSED FOR INVOICE', 'CLOSED',
                                                  'OPEN', 'CLOSED FOR RECEIVING',
                                                  poll.closed_code),  -- <Bug 4490151>
                               'OPEN', DECODE(poll.consigned_flag,
                                         'Y', 'CLOSED FOR INVOICE',
                                         'OPEN'),
                               'INVOICE OPEN', DECODE(poll.consigned_flag,
                                                 'Y', poll.closed_code,
                                                 DECODE(NVL(poll.closed_code, 'OPEN'),
                                                   'CLOSED FOR INVOICE', 'OPEN',
                                                   'CLOSED', 'CLOSED FOR RECEIVING',
                                                   poll.closed_code)),  -- <Bug 4490151>
                               'RECEIVE OPEN', DECODE(NVL(poll.closed_code, 'OPEN'),
                                                 'CLOSED FOR RECEIVING', 'OPEN',
                                                 'CLOSED', 'CLOSED FOR INVOICE',
                                                 poll.closed_code)   -- <Bug 4490151>
                             )
        , poll.shipment_closed_date = DECODE(p_action,
                                        'CLOSE', SYSDATE,
                                        'INVOICE CLOSE', DECODE(NVL(poll.closed_code, 'OPEN'),
                                                           'CLOSED FOR RECEIVING', SYSDATE,
                                                           poll.shipment_closed_date),  -- <Bug 4490151>
                                        'RECEIVE CLOSE', DECODE(NVL(poll.closed_code, 'OPEN'),
                                                           'CLOSED FOR INVOICE', SYSDATE,
                                                           poll.shipment_closed_date),  -- <Bug 4490151>
                                        'OPEN', NULL,
                                        'INVOICE OPEN', NULL,
                                        'RECEIVE OPEN', NULL,
                                        'FINALLY CLOSE', NVL(poll.shipment_closed_date, SYSDATE)
                                      )
        , poll.closed_for_invoice_date = DECODE(p_action,
                                           'CLOSE', DECODE(NVL(poll.closed_code, 'OPEN'),
                                                      'CLOSED FOR RECEIVING', SYSDATE,
                                                      'OPEN', SYSDATE,
                                                      poll.closed_for_invoice_date),
                                          'INVOICE CLOSE', SYSDATE,
                                          'OPEN', NULL,
                                          'INVOICE OPEN', NULL,
                                          'FINALLY CLOSE', NVL(poll.closed_for_invoice_date, SYSDATE),
                                          poll.closed_for_invoice_date
                                        )
        , poll.closed_for_receiving_date = DECODE(p_action,
                                             'CLOSE', DECODE(NVL(poll.closed_code, 'OPEN'),
                                                      'CLOSED FOR INVOICE', SYSDATE,
                                                      'OPEN', SYSDATE,
                                                      poll.closed_for_receiving_date),
                                             'RECEIVE CLOSE', SYSDATE,
                                             'OPEN', NULL,
                                             'RECEIVE OPEN', NULL,
                                             'FINALLY CLOSE', NVL(poll.closed_for_receiving_date, SYSDATE),
                                             poll.closed_for_receiving_date
                                           )
      WHERE poll.line_location_id = l_id_tbl(i)
        AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
        AND poll.shipment_type =
              DECODE(p_document_type,
                -- <Complex Work R12>: STANDARD doc subtype no longer implies
                -- 'STANDARD' shipptype; it can also be PREPAYMENT.
                'PO', DECODE(p_document_subtype, 'STANDARD', poll.shipment_type, 'PLANNED'),
                'RELEASE', DECODE(p_document_subtype, 'SCHEDULED', 'SCHEDULED', 'BLANKET'))
        ;

    --<DBI Req Fulfillment 11.5.11 End >

    d_progress := 46;

  END IF;  -- p_document_type = ..

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'Updated' || SQL%ROWCOUNT || ' closed code rows.' );
  END IF;

  d_progress := 100;


  IF ((p_action = 'FINALLY CLOSE')
         OR ((p_calling_mode = 'AP') AND (p_action = 'INVOICE OPEN')))
    AND (p_document_type <> 'PA')
    AND (p_enc_flag)
  THEN

    d_progress := 140;

    -- If Action is Finally Close and Encumbrance is ON and Document is not
    -- a PA, we need to update gl_closed_date in po_distributions to the
    -- System Date

    -- <JFMIP:Re-open Finally Match Shipment FPI START>
    -- If Action is Invoice Open and Calling from AP, we need to null out
    -- update gl_closed_date in po_distributions

    IF (p_shipment_id IS NOT NULL)
    THEN

      d_progress := 141;

      SELECT pod.po_distribution_id
      BULK COLLECT INTO l_id_tbl
      FROM po_distributions pod
      WHERE pod.line_location_id = p_shipment_id;

    ELSIF(p_line_id IS NOT NULL)
    THEN

      d_progress := 142;

      SELECT pod.po_distribution_id
      BULK COLLECT INTO l_id_tbl
      FROM po_distributions pod
      WHERE pod.po_line_id = p_line_id
        AND pod.po_release_id IS NULL;

      -- existing bug? the release_id = NULL filter was missing in POXPOACB.pls


    ELSIF(p_document_type = 'RELEASE')
    THEN

      d_progress := 143;

      SELECT pod.po_distribution_id
      BULK COLLECT INTO l_id_tbl
      FROM po_distributions pod
      WHERE pod.po_release_id = p_document_id;

    ELSE

      d_progress := 144;

      SELECT pod.po_distribution_id
      BULK COLLECT INTO l_id_tbl
      FROM po_distributions pod
      WHERE pod.po_header_id = p_document_id
        AND pod.po_release_id IS NULL;

      -- existing bug? the release_id = NULL filter was missing in POXPOACB.pls

    END IF;


    d_progress := 150;

    -- Bug#18705290: gl_closed_date = gl_encumbered_date if p_use_gl_date = Y
    -- otherwise, gl_closed_date = p_action_date
    --
    FORALL i IN 1..l_id_tbl.COUNT
      UPDATE po_distributions pod
      SET pod.gl_closed_date = DECODE(p_action, 'FINALLY CLOSE', DECODE (p_use_gl_date,
                                                                         'Y', POD.gl_encumbered_date,
                                                                          p_action_date),
                                                 NULL)
      WHERE pod.po_distribution_id = l_id_tbl(i)
      ;

    d_progress := 160;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'Updated' || SQL%ROWCOUNT || ' distribution gl_closed_dates' );
    END IF;

  END IF;  -- if p_action = 'FINALLY CLOSE' OR ...

  x_return_status := 'S';

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN others THEN
    x_return_status := 'U';

    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END manual_update_closed_status;

/*bug 16432524  The status of the Order document can be updated to "Closed for Invoicing"/"Closed" only
if the Quantity billed is equal to the ordered Quantity.*/
PROCEDURE auto_update_closed_status(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_calling_mode      IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  p_employee_id       IN      NUMBER
,  p_user_id           IN      NUMBER  --bug4964600
,  p_login_id          IN      NUMBER  --bug4964600
,  p_reason            IN      VARCHAR2
,  x_return_status     OUT NOCOPY  VARCHAR2
)
IS

d_module     VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CLOSE.auto_update_close_status';
d_progress   NUMBER;
d_msg        VARCHAR2(200);

l_ret_sts   VARCHAR2(1);

l_id_tbl    g_tbl_number;
 l_closed_code_tbl  g_tbl_closed_code; --14252818
l_authorization_status VARCHAR(25); --bug8258112
l_AUTO_CLOSE_TWO_WAY varchar2(1) := NVL(fnd_profile.VALUE('AUTO_CLOSE_TWO_WAY_MATCHED_SHIPMENTS_FULLY_INVOICED'),'N'); -- 11730977

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_line_id', p_line_id);
    PO_LOG.proc_begin(d_module, 'p_shipment_id', p_shipment_id);
    PO_LOG.proc_begin(d_module, 'p_calling_mode', p_calling_mode);
    PO_LOG.proc_begin(d_module, 'p_employee_id', p_employee_id);
  END IF;
--BUG8660866
d_progress := 1;
  IF (p_document_type = 'PA') THEN
  IF(p_line_id IS NOT NULL) THEN
d_progress := 2;
  UPDATE po_lines pol
  SET pol.last_update_date  = SYSDATE
    , pol.last_updated_by   = p_user_id
    , pol.last_update_login = p_login_id
    , pol.closed_date = SYSDATE
    , pol.closed_by = p_employee_id
    , pol.closed_reason = p_reason
    , pol.closed_code =  'CLOSED'
  WHERE pol.po_line_id = p_line_id
    AND pol.cancel_flag = 'Y'
    AND NVL(pol.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED');

    ELSE
d_progress :=3;
      UPDATE po_lines pol
  SET pol.last_update_date  = SYSDATE
    , pol.last_updated_by   = p_user_id
    , pol.last_update_login = p_login_id
    , pol.closed_date = SYSDATE
    , pol.closed_by = p_employee_id
    , pol.closed_reason = p_reason
    , pol.closed_code = 'CLOSED'
  WHERE pol.po_header_id = p_document_id
    AND pol.cancel_flag = 'Y'
    AND NVL(pol.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED');

    END IF;
    END IF;
--BUG8660866
  IF (p_document_type <> 'PA') THEN

  IF (p_shipment_id IS NOT NULL)
  THEN

    d_progress := 10;

    SELECT poll.line_location_id,poll.closed_code
    BULK COLLECT INTO l_id_tbl,l_closed_code_tbl
    FROM po_line_locations poll
    WHERE poll.line_location_id = p_shipment_id;

  ELSIF (p_line_id IS NOT NULL)
  THEN

    d_progress := 20;

    SELECT poll.line_location_id,poll.closed_code
    BULK COLLECT INTO l_id_tbl,l_closed_code_tbl
    FROM po_line_locations poll
    WHERE poll.po_line_id = p_line_id
      AND poll.po_release_id IS NULL;

  ELSIF (p_document_type = 'RELEASE')
  THEN

    d_progress := 30;

    SELECT poll.line_location_id,poll.closed_code
    BULK COLLECT INTO l_id_tbl,l_closed_code_tbl
    FROM po_line_locations poll
    WHERE poll.po_release_id = p_document_id;

  ELSE

    d_progress := 40;

    SELECT poll.line_location_id,poll.closed_code
    BULK COLLECT INTO l_id_tbl,l_closed_code_tbl
    FROM po_line_locations poll
    WHERE poll.po_header_id = p_document_id
      AND poll.po_release_id IS NULL;

  END IF;

  --bug8258112 Getting the authorization status of the document.
  --<BUG 8566664 Adding IF condition for releases>

  IF (p_document_type = 'RELEASE') THEN

	SELECT NVL(authorization_status, 'INCOMPLETE')
	  INTO l_authorization_status
	  FROM po_releases_all
	 WHERE po_release_id = p_document_id;

  ELSE

	SELECT Nvl(authorization_status, 'INCOMPLETE')
	  INTO l_authorization_status
	  FROM po_headers_all
	 WHERE po_header_id = p_document_id;

  END IF;

  IF (p_calling_mode = 'PO')
  THEN

    -- As part of bug# 3325173: Algorithmic logic for the decode statement below
    --
    -- IF some quantity is remaining to be BILLED (OPEN)
    --    (after adjusting quantity cancelled/billed and invoice close tolerance)
    -- THEN
    --    IF some quantity is remaining to be RECEIVED (OPEN)
    --     (after adjusting quantity cancelled/accepted/delivered/received
    --      and receive close tolerance)
    --    THEN
    --      CLOSED_CODE = 'OPEN';
    --    ELSE (CLOSED FOR RECEIVING)
    --      CLOSED_CODE = 'CLOSED FOR RECEIVING';
    --    END IF;
    -- ELSE (CLOSED FOR INVOICE)
    --    IF some quantity is remaining to be RECEIVED (OPEN)
    --     (after adjusting quantity cancelled/accepted/delivered/received
    --      and receive close tolerance)
    --    THEN
    --       CLOSED_CODE = 'CLOSED FOR INVOICE';
    --    ELSE (CLOSED FOR RECEIVING)
    --       CLOSED_CODE = 'CLOSED'  -- comment was previously incorrect
    --    END IF;
    -- END IF;
    --
    -- Note: For Services Line types, where matching_basis is AMOUNT, the
    -- same logic as above applies, except that all quantity columns are
    -- replaced with respective amount columns.

    -- <Complex Work R12>: Change query to check for greatest of financed and billed

 --Bug8258112 If the document is in requires reapproval or in process then
 -- you can update the closed code of a line location which is in the
 -- requires reapproval status or if the line location is approved
 -- the cancel flag should be Y (for the current line getting cancelled
 -- it will be Y already)

    d_progress := 50;

   IF (l_authorization_status IN ('REQUIRES REAPPROVAL', 'IN PROCESS')) THEN
    FORALL i IN 1..l_id_tbl.Count


      UPDATE po_line_locations poll
      SET poll.closed_code =
        (
           SELECT DECODE(poll.matching_basis,
              'AMOUNT',
                    DECODE(
                          DECODE(sign(
                                ((poll.amount - NVL(poll.amount_cancelled, 0))
                                   * (1 - NVL(poll.invoice_close_tolerance,
                                            NVL(posp.invoice_close_tolerance, 0))/100))
                                 - NVL(poll.amount_billed, 0)),--bug 16432524
                          1, 'OPEN',
                          'CLOSED FOR INVOICE'),
                    'CLOSED FOR INVOICE',
                          DECODE(
                                DECODE(sign(
                                      ((poll.amount - NVL(poll.amount_cancelled, 0))
                                         * (1 - NVL(poll.receive_close_tolerance,
                                                  NVL(posp.receive_close_tolerance, 0))/100))
                                       - DECODE(posp.receive_close_code,
                                           'ACCEPTED', NVL(poll.amount_accepted, 0),
                                           'DELIVERED', sum(NVL(pod.amount_delivered, 0)),
                                           NVL(poll.amount_received, 0))),
                                1, 'OPEN',
                                'CLOSED FOR RECEIVING'),
                          'CLOSED FOR RECEIVING', 'CLOSED',
                          decode(nvl(l_AUTO_CLOSE_TWO_WAY,'N'),'Y', -- Bug 11730977 start
                     decode(nvl(poll.receipt_required_flag,'N'),'N',decode(nvl(poll.inspection_required_flag,'N'),'N','CLOSED','CLOSED FOR INVOICE')),'N','CLOSED FOR INVOICE')),-- Bug 11730977 end
                    'OPEN',
                          DECODE(
                                DECODE(sign(
                                      ((poll.amount - NVL(poll.amount_cancelled, 0))
                                         * (1 - NVL(poll.receive_close_tolerance,
                                                  NVL(posp.receive_close_tolerance, 0))/100))
                                       - DECODE(posp.receive_close_code,
                                           'ACCEPTED', NVL(poll.amount_accepted, 0),
                                           'DELIVERED', sum(NVL(pod.amount_delivered, 0)),
                                           NVL(poll.amount_received, 0))),
                                1, 'OPEN',
                                'CLOSED FOR RECEIVING'),
                          'CLOSED FOR RECEIVING', 'CLOSED FOR RECEIVING',
                          'OPEN')),
              -- else QUANTITY BASIS
                    DECODE(
                          DECODE(sign(
                                ((poll.quantity - NVL(poll.quantity_cancelled, 0))
                                   * (1 - NVL(poll.invoice_close_tolerance,
                                            NVL(posp.invoice_close_tolerance, 0))/100))
                                 - NVL(poll.quantity_billed, 0)),--bug 16432524
                          1, 'OPEN',
                          'CLOSED FOR INVOICE'),
                    'CLOSED FOR INVOICE',
                          DECODE(
                                DECODE(sign(
                                      ((poll.quantity - NVL(poll.quantity_cancelled, 0))
                                         * (1 - NVL(poll.receive_close_tolerance,
                                                  NVL(posp.receive_close_tolerance, 0))/100))
                                       - DECODE(posp.receive_close_code,
                                           'ACCEPTED', NVL(poll.quantity_accepted, 0),
                                           'DELIVERED', sum(NVL(pod.quantity_delivered, 0)),
                                           NVL(poll.quantity_received, 0))),
                                1, 'OPEN',
                                'CLOSED FOR RECEIVING'),
                          'CLOSED FOR RECEIVING', 'CLOSED',
										 decode(nvl(l_AUTO_CLOSE_TWO_WAY,'N'),'Y', -- Bug 11730977 start
                     decode(nvl(poll.receipt_required_flag,'N'),'N',decode(nvl(poll.inspection_required_flag,'N'),'N','CLOSED','CLOSED FOR INVOICE')),'N','CLOSED FOR INVOICE')), -- Bug 11730977 end
                    'OPEN',
                          DECODE(
                                DECODE(sign(
                                      ((poll.quantity - NVL(poll.quantity_cancelled, 0))
                                         * (1 - NVL(poll.receive_close_tolerance,
                                                  NVL(posp.receive_close_tolerance, 0))/100))
                                       - DECODE(posp.receive_close_code,
                                           'ACCEPTED', NVL(poll.quantity_accepted, 0),
                                           'DELIVERED', sum(NVL(pod.quantity_delivered, 0)),
                                           NVL(poll.quantity_received, 0))),
                                1, 'OPEN',
                                'CLOSED FOR RECEIVING'),
                          'CLOSED FOR RECEIVING', 'CLOSED FOR RECEIVING',
                          'OPEN')))
           FROM po_distributions pod
              , po_system_parameters posp
           WHERE poll.line_location_id = l_id_tbl(i)
             AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
             AND pod.line_location_id = poll.line_location_id
           GROUP BY poll.quantity
                  , poll.quantity_cancelled
                  , poll.quantity_billed
                  , poll.quantity_financed
                  , poll.quantity_accepted
                  , poll.quantity_received
                  , poll.amount
                  , poll.amount_cancelled
                  , poll.amount_billed
                  , poll.amount_financed
                  , poll.amount_accepted
                  , poll.amount_received
                  , poll.matching_basis
                  , poll.invoice_close_tolerance
                  , poll.receive_close_tolerance
                  , posp.receive_close_code
                  , posp.receive_close_tolerance
                  , posp.invoice_close_tolerance
        )
      WHERE poll.line_location_id = l_id_tbl(i)
        AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
        AND (Nvl(poll.approved_flag,'N') <> 'Y'
             OR (Nvl(poll.approved_flag,'N') ='Y' AND Nvl(poll.cancel_flag,'N') = 'Y'));


     ELSE

     --Bug 8258112 If the authorization status is APPROVED..

     --
      d_progress := 60;
      FORALL i IN 1..l_id_tbl.Count
      UPDATE po_line_locations poll
      SET poll.closed_code =
        (
           SELECT DECODE(poll.matching_basis,
              'AMOUNT',
                    DECODE(
                          DECODE(sign(
                                ((poll.amount - NVL(poll.amount_cancelled, 0))
                                   * (1 - NVL(poll.invoice_close_tolerance,
                                            NVL(posp.invoice_close_tolerance, 0))/100))
                                 - NVL(poll.amount_billed, 0)),--bug 16432524
                          1, 'OPEN',
                          'CLOSED FOR INVOICE'),
                    'CLOSED FOR INVOICE',
                          DECODE(
                                DECODE(sign(
                                      ((poll.amount - NVL(poll.amount_cancelled, 0))
                                         * (1 - NVL(poll.receive_close_tolerance,
                                                  NVL(posp.receive_close_tolerance, 0))/100))
                                       - DECODE(posp.receive_close_code,
                                           'ACCEPTED', NVL(poll.amount_accepted, 0),
                                           'DELIVERED', sum(NVL(pod.amount_delivered, 0)),
                                           NVL(poll.amount_received, 0))),
                                1, 'OPEN',
                                'CLOSED FOR RECEIVING'),
                          'CLOSED FOR RECEIVING', 'CLOSED',
                          'CLOSED FOR INVOICE'),
                    'OPEN',
                          DECODE(
                                DECODE(sign(
                                      ((poll.amount - NVL(poll.amount_cancelled, 0))
                                         * (1 - NVL(poll.receive_close_tolerance,
                                                  NVL(posp.receive_close_tolerance, 0))/100))
                                       - DECODE(posp.receive_close_code,
                                           'ACCEPTED', NVL(poll.amount_accepted, 0),
                                           'DELIVERED', sum(NVL(pod.amount_delivered, 0)),
                                           NVL(poll.amount_received, 0))),
                                1, 'OPEN',
                                'CLOSED FOR RECEIVING'),
                          'CLOSED FOR RECEIVING', 'CLOSED FOR RECEIVING',
                          'OPEN')),
              -- else QUANTITY BASIS
                    DECODE(
                          DECODE(sign(
                                ((poll.quantity - NVL(poll.quantity_cancelled, 0))
                                   * (1 - NVL(poll.invoice_close_tolerance,
                                            NVL(posp.invoice_close_tolerance, 0))/100))
                                 - NVL(poll.quantity_billed, 0)),--bug 16432524
                          1, 'OPEN',
                          'CLOSED FOR INVOICE'),
                    'CLOSED FOR INVOICE',
                          DECODE(
                                DECODE(sign(
                                      ((poll.quantity - NVL(poll.quantity_cancelled, 0))
                                         * (1 - NVL(poll.receive_close_tolerance,
                                                  NVL(posp.receive_close_tolerance, 0))/100))
                                       - DECODE(posp.receive_close_code,
                                           'ACCEPTED', NVL(poll.quantity_accepted, 0),
                                           'DELIVERED', sum(NVL(pod.quantity_delivered, 0)),
                                           NVL(poll.quantity_received, 0))),
                                1, 'OPEN',
                                'CLOSED FOR RECEIVING'),
                          'CLOSED FOR RECEIVING', 'CLOSED',
                          'CLOSED FOR INVOICE'),
                    'OPEN',
                          DECODE(
                                DECODE(sign(
                                      ((poll.quantity - NVL(poll.quantity_cancelled, 0))
                                         * (1 - NVL(poll.receive_close_tolerance,
                                                  NVL(posp.receive_close_tolerance, 0))/100))
                                       - DECODE(posp.receive_close_code,
                                           'ACCEPTED', NVL(poll.quantity_accepted, 0),
                                           'DELIVERED', sum(NVL(pod.quantity_delivered, 0)),
                                           NVL(poll.quantity_received, 0))),
                                1, 'OPEN',
                                'CLOSED FOR RECEIVING'),
                          'CLOSED FOR RECEIVING', 'CLOSED FOR RECEIVING',
                          'OPEN')))
           FROM po_distributions pod
              , po_system_parameters posp
           WHERE poll.line_location_id = l_id_tbl(i)
             AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
             AND pod.line_location_id = poll.line_location_id
           GROUP BY poll.quantity
                  , poll.quantity_cancelled
                  , poll.quantity_billed
                  , poll.quantity_financed
                  , poll.quantity_accepted
                  , poll.quantity_received
                  , poll.amount
                  , poll.amount_cancelled
                  , poll.amount_billed
                  , poll.amount_financed
                  , poll.amount_accepted
                  , poll.amount_received
                  , poll.matching_basis
                  , poll.invoice_close_tolerance
                  , poll.receive_close_tolerance
                  , posp.receive_close_code
                  , posp.receive_close_tolerance
                  , posp.invoice_close_tolerance
        )
      WHERE poll.line_location_id = l_id_tbl(i)
        AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED';


END IF; --end if(l_authorization_status in..

    d_progress := 70;

 --bug8258112


  ELSIF (p_calling_mode = 'RCV')
  THEN

    -- As part of bug# 3325173: Algorithmic logic for the decode statement below
    --
    -- IF some quantity is remaining to be RECEIVED (OPEN)
    --  (after adjusting quantity cancelled/accepted/delivered/received
    --   and receive close tolerance)
    -- THEN
    --     IF Shipment closed_code is 'CLOSED'
    --     THEN
    --       CLOSED_CODE = 'CLOSED FOR INVOICE';
    --     ELSE IF Shipment closed_code is 'CLOSED FOR RECEIVING'
    --       CLOSED_CODE = 'OPEN';
    --     ELSE
    --       Don't modify the shipment closed code
    --     END IF;
    -- ELSE (CLOSED FOR RECEIVING)
    --     IF Shipment closed_code is 'OPEN'
    --     THEN
    --       CLOSED_CODE = 'CLOSED FOR RECEIVING';
    --     ELSE IF Shipment closed_code is 'CLOSED FOR INVOICE'
    --       CLOSED_CODE = 'CLOSED'; -- comment was previously incorrect
    --     ELSE
    --       Don't modify the shipment closed code
    --     END IF;
    -- END IF;
    --
    -- Note: For Services Line types, where matching_basis is AMOUNT, the
    -- same logic as above applies, except that all quantity columns are
    -- replaced with respective amount columns.

    d_progress := 80;

    FORALL i IN 1..l_id_tbl.COUNT
      UPDATE po_line_locations poll
      SET poll.closed_code =
        (
           SELECT DECODE(poll.matching_basis,
              'AMOUNT',
                    DECODE(
                          DECODE(sign(
                                ((poll.amount - NVL(poll.amount_cancelled, 0))
                                   * (1 - NVL(poll.receive_close_tolerance,
                                            NVL(posp.receive_close_tolerance, 0))/100))
                                   - DECODE(posp.receive_close_code,
                                       'ACCEPTED', NVL(poll.amount_accepted, 0),
                                       'DELIVERED', sum(NVL(pod.amount_delivered, 0)),
                                       NVL(poll.amount_received, 0))),
                          1, 'OPEN',
                          'CLOSED FOR RECEIVING'),
                    'CLOSED FOR RECEIVING',
                          DECODE(NVL(poll.closed_code, 'OPEN'),
                          'OPEN', 'CLOSED FOR RECEIVING',
                          'CLOSED FOR INVOICE', 'CLOSED',
                          poll.closed_code),
                    'OPEN',
                          DECODE(poll.closed_code,
                          'CLOSED', decode(nvl(l_AUTO_CLOSE_TWO_WAY,'N'),'Y', -- Bug 11730977 start
                          decode(nvl(poll.receipt_required_flag,'N'),'N',decode(nvl(poll.inspection_required_flag,'N'),'N',
                          'CLOSED','CLOSED FOR INVOICE')),'N','CLOSED FOR INVOICE'), ---- Bug 11730977 end
                          'CLOSED FOR RECEIVING', 'OPEN',
                          poll.closed_code)),
              -- else QUANTITY BASIS
                    DECODE(
                          DECODE(sign(
                                ((poll.quantity - NVL(poll.quantity_cancelled, 0))
                                   * (1 - NVL(poll.receive_close_tolerance,
                                            NVL(posp.receive_close_tolerance, 0))/100))
                                   - DECODE(posp.receive_close_code,
                                       'ACCEPTED', NVL(poll.quantity_accepted, 0),
                                       'DELIVERED', sum(NVL(pod.quantity_delivered, 0)),
                                       NVL(poll.quantity_received, 0))),
                          1, 'OPEN',
                          'CLOSED FOR RECEIVING'),
                    'CLOSED FOR RECEIVING',
                          DECODE(NVL(poll.closed_code, 'OPEN'),
                          'OPEN', 'CLOSED FOR RECEIVING',
                          'CLOSED FOR INVOICE', 'CLOSED',
                          poll.closed_code),
                    'OPEN',
                          DECODE(poll.closed_code,
                          'CLOSED',
                           decode(nvl(l_AUTO_CLOSE_TWO_WAY,'N'),'Y', -- Bug 11730977 start
                          decode(nvl(poll.receipt_required_flag,'N'),'N',decode(nvl(poll.inspection_required_flag,'N'),'N',
                          'CLOSED','CLOSED FOR INVOICE')),'N','CLOSED FOR INVOICE'), -- Bug 11730977 end
                          'CLOSED FOR RECEIVING', 'OPEN',
                          poll.closed_code)))
           FROM po_distributions pod
              , po_system_parameters posp
           WHERE poll.line_location_id = l_id_tbl(i)
             AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
             AND pod.line_location_id = poll.line_location_id
           GROUP BY poll.quantity
                  , poll.quantity_cancelled
                  , poll.quantity_accepted
                  , poll.quantity_received
                  , poll.amount
                  , poll.amount_cancelled
                  , poll.amount_accepted
                  , poll.amount_received
                  , poll.matching_basis
                  , poll.receive_close_tolerance
                  , posp.receive_close_code
                  , poll.closed_code
                  , posp.receive_close_tolerance
        )
      WHERE poll.line_location_id = l_id_tbl(i)
        AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED';

    d_progress := 90;

  ELSIF  (p_calling_mode = 'AP')
  THEN

    -- As part of bug# 3325173: Algorithmic logic for the decode statement below
    --
    -- IF some quantity is remaining to be INVOICED (OPEN)
    --    (after adjusting quantity cancelled/billed and invoice close tolerance)
    -- THEN
    --     IF Shipment closed_code is 'CLOSED'
    --     THEN
    --       CLOSED_CODE = 'CLOSED FOR RECEIVING';
    --     ELSE IF Shipment closed_code is 'CLOSED FOR INVOICE'
    --       CLOSED_CODE = 'OPEN';
    --     ELSE
    --       Don't modify the shipment closed code
    --     END IF;
    -- ELSE (CLOSED FOR INVOICE)
    --     IF Shipment closed_code is 'OPEN'
    --     THEN
    --       CLOSED_CODE = 'CLOSED FOR INVOICE';
    --     ELSE IF Shipment closed_code is 'CLOSED FOR RECEIVING'
    --       CLOSED_CODE = 'CLOSED';
    --     ELSE
    --       Don't modify the shipment closed code
    --     END IF;
    -- END IF;
    --
    -- Note: For Services Line types, where matching_basis is AMOUNT, the
    -- same logic as above applies, except that all quantity columns are
    -- replaced with respective amount columns.

    -- <Complex Work R12>: Change query to check for greatest of financed and billed

    d_progress := 100;

    FORALL i IN 1..l_id_tbl.COUNT
      UPDATE po_line_locations poll
      SET poll.closed_code =
        (
           SELECT DECODE(poll.matching_basis,
              'AMOUNT',
                    DECODE(
                          DECODE(sign(
                                ((poll.amount - NVL(poll.amount_cancelled, 0))
                                   * (1 - NVL(poll.invoice_close_tolerance,
                                            NVL(posp.invoice_close_tolerance, 0))/100))
                                   - NVL(poll.amount_billed, 0)),--bug 16432524
                          1, 'OPEN',
                          'CLOSED FOR INVOICE'),
                    'CLOSED FOR INVOICE',
  									 DECODE(NVL(poll.closed_code, 'OPEN'),'OPEN',-- 11730977 start
                     decode(nvl(l_AUTO_CLOSE_TWO_WAY,'N'),'Y',
                     decode(nvl(poll.receipt_required_flag,'N'),'N',decode(nvl(poll.inspection_required_flag,'N'),'N','CLOSED','CLOSED FOR INVOICE')),'N','CLOSED FOR INVOICE'),
                            'CLOSED FOR RECEIVING',
                            'CLOSED',
                            poll.closed_code), -- 11730977 end
                    'OPEN',
                          DECODE(poll.closed_code,
                          'CLOSED', 'CLOSED FOR RECEIVING',
                          'CLOSED FOR INVOICE', 'OPEN',
                          poll.closed_code)),
              -- else QUANTITY BASIS
                    DECODE(
                          DECODE(sign(
                                ((poll.quantity - NVL(poll.quantity_cancelled, 0))
                                   * (1 - NVL(poll.invoice_close_tolerance,
                                            NVL(posp.invoice_close_tolerance, 0))/100))
                                   - NVL(poll.quantity_billed, 0)),--bug 16432524
                          1, 'OPEN',
                          'CLOSED FOR INVOICE'),
                    'CLOSED FOR INVOICE',
                     DECODE(NVL(poll.closed_code, 'OPEN'),'OPEN', -- 11730977 start
                     decode(nvl(l_AUTO_CLOSE_TWO_WAY,'N'),'Y',
                      decode(nvl(poll.receipt_required_flag,'N'),'N',decode(nvl(poll.inspection_required_flag,'N'),'N','CLOSED','CLOSED FOR INVOICE')),'N','CLOSED FOR INVOICE'),
                            'CLOSED FOR RECEIVING',
                            'CLOSED',
                            poll.closed_code), -- 11730977 end
                    'OPEN',
                          DECODE(poll.closed_code,
                          'CLOSED', 'CLOSED FOR RECEIVING',
                          'CLOSED FOR INVOICE', 'OPEN',
                          poll.closed_code)))
           FROM po_distributions pod
              , po_system_parameters posp
           WHERE poll.line_location_id = l_id_tbl(i)
             AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
             AND pod.line_location_id = poll.line_location_id
           GROUP BY poll.quantity
                  , poll.quantity_cancelled
                  , poll.quantity_billed
                  , poll.quantity_financed
                  , poll.amount
                  , poll.amount_cancelled
                  , poll.amount_billed
                  , poll.amount_financed
                  , poll.matching_basis
                  , poll.invoice_close_tolerance
                  , poll.closed_code
                  , posp.invoice_close_tolerance
        )
      WHERE poll.line_location_id = l_id_tbl(i)
        AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED';

    d_progress := 110;

  END IF;  -- if p_calling_mode = 'PO'

  d_progress := 200;

  -- combined two queries into one by using decodes
  -- previously, the closed_code <> CLOSED and = CLOSED were split up
  -- Bug 5480524: removed the closed date is null and <> open condition
  -- as thats not required.
  FORALL i IN 1..l_id_tbl.COUNT
    UPDATE po_line_locations poll
    SET poll.closed_date = DECODE(NVL(poll.closed_code, 'OPEN'), 'CLOSED', SYSDATE, NULL)
      , poll.closed_reason = DECODE(NVL(poll.closed_code, 'OPEN'), 'CLOSED', p_reason, NULL)
      , poll.closed_by = DECODE(NVL(poll.closed_code, 'OPEN'), 'CLOSED', p_employee_id, NULL)
    WHERE poll.line_location_id = l_id_tbl(i)
	   AND poll.closed_code <> l_closed_code_tbl(i)
      AND NVL(poll.closed_code, 'OPEN') IN ('CLOSED','OPEN','CLOSED FOR INVOICE', 'CLOSED FOR RECEIVING');



  d_progress := 210;

  --<DBI Requisition Fulfillment 11.5.11 Start>
  --  update the shipment closure dates
  -- use po_line_locations instead of po_line_locations all
  -- this is to leverage l_id_tbl from above

  FORALL i IN 1..l_id_tbl.COUNT
    UPDATE po_line_locations poll
    SET poll.shipment_closed_date = DECODE(poll.closed_code,
                                    'CLOSED', NVL(poll.shipment_closed_date,
                                              PO_ACTIONS.get_closure_dates('CLOSE', poll.line_location_id)),
                                    NULL)
      , poll.closed_for_receiving_date = DECODE(poll.closed_code,
                                         'CLOSED FOR RECEIVING', NVL(poll.closed_for_receiving_date,
                                              PO_ACTIONS.get_closure_dates('RECEIVE CLOSE', poll.line_location_id)),
                                         'CLOSED FOR INVOICE', NULL,
                                         'CLOSED', NVL(poll.closed_for_receiving_date,
                                              PO_ACTIONS.get_closure_dates('RECEIVE CLOSE', poll.line_location_id)),
                                         'OPEN', NULL)
      , poll.closed_for_invoice_date = DECODE(poll.closed_code,
                                       'CLOSED FOR RECEIVING', NULL,
                                       'CLOSED FOR INVOICE', NVL(poll.closed_for_invoice_date,
                                            PO_ACTIONS.get_closure_dates('INVOICE CLOSE', poll.line_location_id)),
                                       'CLOSED', NVL(poll.closed_for_invoice_date,
                                            PO_ACTIONS.get_closure_dates('INVOICE CLOSE', poll.line_location_id)),
                                       'OPEN', NULL)
      , poll.last_update_date  = SYSDATE     --bug4964600
      , poll.last_updated_by   = p_user_id    --bug4964600
      , poll.last_update_login = p_login_id   --bug4964600
    WHERE poll.line_location_id = l_id_tbl(i)
      AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED';

  --<DBI Requisition Fulfillment 11.5.11 End>
  END IF;
--BUG8660866
  d_progress := 220;

  x_return_status := 'S';

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN others THEN
    x_return_status := 'U';

    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END auto_update_closed_status;


PROCEDURE rollup_close_state(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_document_subtype  IN      VARCHAR2
,  p_action            IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  p_user_id           IN      NUMBER
,  p_login_id          IN      NUMBER
,  p_employee_id       IN      NUMBER
,  p_reason            IN      VARCHAR2
,  p_action_date       IN      DATE
,  p_calling_mode      IN      VARCHAR2
,  x_return_status     OUT NOCOPY  VARCHAR2
) IS

d_module      VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CLOSE.rollup_close_state';
d_progress    NUMBER;
d_msg         VARCHAR2(200);

l_ret_sts     VARCHAR2(1);

l_rollup_msg   VARCHAR2(256);
l_rollup_code  PO_LINES.closed_code%TYPE;

l_lineid_tbl   g_tbl_number;

l_hist_action         VARCHAR2(30);
l_update_action_hist  BOOLEAN;

l_none_open_one_closed PO_LINE_LOCATIONS.closed_code%TYPE;
l_all_finally_closed   PO_LINE_LOCATIONS.closed_code%TYPE;


-- we use cursors for performance reasons during create releases
-- See: Bug 1834138 (perf issue) and Bug 2361826 (bug in cursor)

CURSOR rollup_rel_open(p_rel_id NUMBER) IS
  SELECT 'OPEN'
  FROM po_line_locations poll
  WHERE poll.po_release_id = p_rel_id
    AND NVL(poll.closed_code, 'OPEN') IN ('OPEN', 'CLOSED FOR INVOICE', 'CLOSED FOR RECEIVING')
    AND rownum = 1;

CURSOR rollup_rel_not_fc(p_rel_id NUMBER) IS
  SELECT 'CLOSED'
  FROM po_line_locations poll
  WHERE poll.po_release_id = p_rel_id
    AND NVL(poll.closed_code, 'CLOSED') = 'CLOSED'
    AND rownum = 1;


BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_action', p_action);
    PO_LOG.proc_begin(d_module, 'p_line_id', p_line_id);
    PO_LOG.proc_begin(d_module, 'p_shipment_id', p_shipment_id);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
    PO_LOG.proc_begin(d_module, 'p_employee_id', p_employee_id);
    PO_LOG.proc_begin(d_module, 'p_reason', p_reason);
    PO_LOG.proc_begin(d_module, 'p_action_date', p_action_date);
    PO_LOG.proc_begin(d_module, 'p_calling_mode', p_calling_mode);
  END IF;

  d_progress := 10;

  l_rollup_msg := substr(FND_MESSAGE.GET_STRING('PO', 'PO_CLOSE_ROLLUP'), 1, 256);

  IF (p_document_type = 'PO')
  THEN

    d_progress := 20;

    IF (p_shipment_id IS NOT NULL)
    THEN

      d_progress := 30;

      SELECT pol.po_line_id
      BULK COLLECT INTO l_lineid_tbl
      FROM po_lines pol
      WHERE pol.po_line_id =
            ( SELECT poll.po_line_id
              FROM po_line_locations poll
              WHERE poll.line_location_id = p_shipment_id)
      ;

    ELSIF (p_line_id IS NOT NULL)
    THEN


      d_progress := 40;

      SELECT pol.po_line_id
      BULK COLLECT INTO l_lineid_tbl
      FROM po_lines pol
      WHERE pol.po_line_id = p_line_id;


    ELSE

      d_progress := 50;

      SELECT pol.po_line_id
      BULK COLLECT INTO l_lineid_tbl
      FROM po_lines pol
      WHERE pol.po_header_id = p_document_id;

    END IF;  -- p_shipment_id IS NOT NULL

    d_progress := 60;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'Count of lines = ' || to_char(l_lineid_tbl.COUNT));
    END IF;

    FOR i IN 1..l_lineid_tbl.COUNT
    LOOP

      d_progress := 70;

      IF ((p_shipment_id IS NULL) AND (p_action = 'FINALLY CLOSE'))
      THEN

        d_progress := 71;

        -- roll up 'FINALLY CLOSE' only if it was taken at the line or header level
        -- otherwise, we will roll up 'CLOSED' as set later.

        l_none_open_one_closed := 'CLOSED';
        l_all_finally_closed := 'FINALLY CLOSED';


      ELSIF ((p_shipment_id IS NULL) AND (p_action = 'OPEN'))
      THEN

        d_progress := 72;

        l_none_open_one_closed := 'OPEN';
        l_all_finally_closed := 'OPEN';

      ELSE

        d_progress := 73;

        l_none_open_one_closed := 'CLOSED';
        l_all_finally_closed := 'CLOSED';

      END IF;  -- if p_shipment_id is null and ...

      d_progress := 75;

      SELECT DECODE(max(DECODE(poll.closed_code,
                        'CLOSED', 2,
                        'FINALLY CLOSED', 1,
                        3)),
             3, 'OPEN',
             2, l_none_open_one_closed,
             1, l_all_finally_closed )
        INTO l_rollup_code
        FROM po_line_locations poll
        WHERE poll.po_line_id = l_lineid_tbl(i)
          AND poll.po_release_id IS NULL
          AND poll.shipment_type <> 'PREPAYMENT';  -- <Complex Work R12>

      d_progress := 76;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'l_lineid_tbl(i)', l_lineid_tbl(i));
        PO_LOG.stmt(d_module, d_progress, 'l_rollup_code', l_rollup_code);
      END IF;

      d_progress := 80;

      UPDATE po_lines pol
      SET pol.closed_code = l_rollup_code
        , pol.last_update_date = SYSDATE
        , pol.last_updated_by = p_user_id
        , pol.last_update_login = p_login_id
        , pol.closed_by = p_employee_id
        , pol.closed_date = DECODE(l_rollup_code,
                                     'CLOSED', SYSDATE,
                                     'FINALLY CLOSED', SYSDATE,
                                      NULL)
        , pol.closed_reason = DECODE(p_shipment_id, NULL, p_reason, l_rollup_msg)
      WHERE pol.po_line_id = l_lineid_tbl(i)
        AND NVL(pol.closed_code, 'OPEN') <> l_rollup_code
        AND (((p_action = 'INVOICE OPEN') AND (p_calling_mode = 'AP'))
            OR (NVL(pol.closed_code, 'OPEN') <> 'FINALLY CLOSED'));

      -- Above, needed to incorporate the fix for bug 1837339 as in poccr.lpc, but also
      -- allow roll up of undo final close when called from AP, as in POXPOACB.pls

      d_progress := 100;

      -- bug 5142689, removed the fnd logging here.Otherwise,SQL%ROWCOUNT in the
      -- following IF part will refer to what happens inside logging.

      --Bug 5574493: Removed code to roll down to financing Pay items

    END LOOP;

  END IF;  -- (if p_document_type = 'PO')


  d_progress := 200;

  -- If any Line is Open, Open the Header. If there are no Open Lines
  -- and there are Closed Lines then Close the Header. If there are no
  -- Open or Closed Lines but there are Finally Closed Lines then Close
  -- the Header

  IF ((p_document_type IN ('PO', 'PA')) AND (p_document_subtype <> 'CONTRACT'))
  THEN

    d_progress := 210;


    IF ((p_shipment_id IS NULL) AND (p_line_id IS NULL) AND (p_action = 'FINALLY CLOSE'))
    THEN

      d_progress := 211;

      -- roll up 'FINALLY CLOSE' only if it was taken at the header level
      -- otherwise, we will roll up 'CLOSED'

      l_none_open_one_closed := 'CLOSED';
      l_all_finally_closed := 'FINALLY CLOSED';

    ELSIF ((p_shipment_id IS NULL) AND (p_line_id IS NULL) AND (p_action = 'OPEN'))
    THEN

      d_progress := 213;

      l_none_open_one_closed := 'OPEN';
      l_all_finally_closed := 'OPEN';

    ELSE

      d_progress := 215;

      l_none_open_one_closed := 'CLOSED';
      l_all_finally_closed := 'CLOSED';

    END IF;  -- if p_shipment_id is null and ...

    d_progress := 218;

    SELECT DECODE(max(DECODE(pol.closed_code,
                      'CLOSED', 2,
                      'FINALLY CLOSED', 1,
                      3)),
           3, 'OPEN',
           2, l_none_open_one_closed,
           1, l_all_finally_closed)
    INTO l_rollup_code
    FROM po_lines pol
    WHERE pol.po_header_id = p_document_id;

    d_progress := 220;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_rollup_code', l_rollup_code);
    END IF;

    UPDATE po_headers poh
    SET poh.closed_code = l_rollup_code
       , poh.last_update_date = SYSDATE
       , poh.last_updated_by = p_user_id
       , poh.last_update_login = p_login_id
       , poh.closed_date = decode(l_rollup_code,
                                   'CLOSED', SYSDATE,
                                   'FINALLY CLOSED', SYSDATE,
                                   NULL)
    WHERE poh.po_header_id = p_document_id
      AND NVL(poh.closed_code, 'OPEN') <> l_rollup_code;

    d_progress := 230;

    -- bug 5142689, removed the fnd logging here.Otherwise, NOT SQL%NOTFOUND in the
    -- following IF part will refer to what happens inside logging.

    -- If a record was updated, we need to update the Action History
    IF (NOT SQL%NOTFOUND)
    THEN
      l_update_action_hist := TRUE;
      l_hist_action := NULL;
    ELSE
      l_update_action_hist := FALSE;
    END IF;  -- if not sql%notfound

  ELSIF (p_document_type = 'RELEASE')
  THEN

    d_progress := 300;

    OPEN rollup_rel_open(p_document_id);
    FETCH rollup_rel_open INTO l_rollup_code;
    CLOSE rollup_rel_open;

    IF (l_rollup_code IS NULL)
    THEN

      d_progress := 301;

      IF ((p_shipment_id IS NULL) AND (p_action = 'FINALLY CLOSE'))
      THEN

        d_progress := 302;

        -- roll up 'FINALLY CLOSE' only if it was taken at the release header level
        -- and there all release shipments are finally closed.

        OPEN rollup_rel_not_fc(p_document_id);
        FETCH rollup_rel_not_fc INTO l_rollup_code;
        CLOSE rollup_rel_not_fc;

        l_rollup_code := NVL(l_rollup_code, 'FINALLY CLOSED');

      ELSIF ((p_shipment_id IS NULL) AND (p_action = 'OPEN'))
      THEN

        d_progress := 303;

        l_rollup_code := 'OPEN';

      ELSE

        d_progress := 305;

        l_rollup_code := 'CLOSED';

      END IF;  -- if p_shipment_id is null and ..

    END IF;  -- if l_rollup_code is null

    d_progress := 310;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_rollup_code', l_rollup_code);
    END IF;

    UPDATE po_releases por
    SET por.closed_code = l_rollup_code
      , por.last_update_date = SYSDATE
      , por.last_updated_by = p_user_id
      , por.last_update_login = p_login_id
    WHERE por.po_release_id = p_document_id
      AND NVL(por.closed_code, 'OPEN') <> l_rollup_code;

    d_progress := 320;

    -- bug 5142689, removed the fnd logging here.Otherwise,NOT SQL%NOTFOUND in the
    -- following IF part will refer to what happens inside logging.

    -- If a record was updated, we need to update the Action History
    IF (NOT SQL%NOTFOUND)
    THEN
      l_update_action_hist := TRUE;
      l_hist_action := NULL;
    ELSE
      l_update_action_hist := FALSE;
    END IF;  -- if not sql%notfound

  ELSIF ((p_document_type = 'PA') AND (p_document_subtype = 'CONTRACT'))
  THEN

    l_update_action_hist := TRUE;
    l_hist_action := p_action;

  END IF;  -- if (p_document_type IN 'PO', 'PA') AND ...


  d_progress := 400;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'l_update_action_hist', l_update_action_hist);
  END IF;

  IF (l_update_action_hist)
  THEN

    d_progress := 410;

    IF (l_hist_action IS NULL)
    THEN

      IF (l_rollup_code = 'CLOSED')
      THEN

        l_hist_action := 'CLOSE';

      ELSIF (l_rollup_code = 'FINALLY CLOSED')
      THEN

        l_hist_action := 'FINALLY CLOSE';

      ELSE

        l_hist_action := 'OPEN';

      END IF;  -- if (l_rollup_code = 'CLOSE')

    END IF;  -- if (l_hist_action IS NULL)

    d_progress := 420;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_hist_action', l_hist_action);
    END IF;

    PO_DOCUMENT_ACTION_UTIL.handle_ctl_action_history(
       p_document_id          => p_document_id
    ,  p_document_type        => p_document_type
    ,  p_document_subtype     => p_document_subtype
    ,  p_line_id              => p_line_id
    ,  p_shipment_id          => p_shipment_id
    ,  p_action               => l_hist_action
    ,  p_user_id              => p_user_id
    ,  p_login_id             => p_login_id
    ,  p_reason               => p_reason
    ,  x_return_status        => l_ret_sts
    );

    IF (l_ret_sts <> 'S')
    THEN

      d_progress := 430;
      l_ret_sts := 'U';
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, 'handle_ctl_action_history not successful');
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, 'handle_ctl_action_history not successful');
      END IF;

    END IF;

  ELSE

    l_ret_sts := 'S';

  END IF;  -- if (l_action_hist);

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN

    IF rollup_rel_open%ISOPEN
    THEN
      close rollup_rel_open;
    END IF;

    IF rollup_rel_not_fc%ISOPEN
    THEN
      close rollup_rel_not_fc;
    END IF;

    x_return_status := 'U';

    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END rollup_close_state;

PROCEDURE handle_manual_close_supply(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_action            IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  x_return_status     OUT NOCOPY  VARCHAR2
)
IS

d_module     VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CLOSE.handle_manual_close_supply';
d_progress   NUMBER;
d_msg        VARCHAR2(200);

l_ret_sts        VARCHAR2(1);
l_supply_action  VARCHAR2(30);
l_supply_ret     BOOLEAN;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_line_id', p_line_id);
    PO_LOG.proc_begin(d_module, 'p_shipment_id', p_shipment_id);
    PO_LOG.proc_begin(d_module, 'p_action', p_action);
  END IF;

  d_progress := 10;

  IF (p_document_type = 'PO')
  THEN

    IF p_action IN (PO_DOCUMENT_ACTION_PVT.g_doc_action_OPEN,
                    PO_DOCUMENT_ACTION_PVT.g_doc_action_OPEN_RCV)
    THEN

      IF (p_shipment_id IS NOT NULL)
      THEN

        l_supply_action := 'Create_PO_Shipment_Supply';

      ELSIF (p_line_id IS NOT NULL)
      THEN

        l_supply_action := 'Create_PO_Line_Supply';

      ELSE

        l_supply_action := 'Create_PO_Supply';

      END IF;  -- p_shipment_id is not null

    ELSIF p_action IN (PO_DOCUMENT_ACTION_PVT.g_doc_action_CLOSE,
                       PO_DOCUMENT_ACTION_PVT.g_doc_action_CLOSE_RCV,
                       PO_DOCUMENT_ACTION_PVT.g_doc_action_FINALLY_CLOSE)
    THEN

      IF (p_shipment_id IS NOT NULL)
      THEN

        l_supply_action := 'Remove_PO_Shipment_Supply';

      ELSIF (p_line_id IS NOT NULL)
      THEN

        l_supply_action := 'Remove_PO_Line_Supply';

      ELSE

        l_supply_action := 'Remove_PO_Supply';

      END IF;  -- p_shipment_id is not null

    END IF;  -- p_action IN ...

  ELSIF (p_document_type = 'RELEASE')
  THEN

    IF p_action IN (PO_DOCUMENT_ACTION_PVT.g_doc_action_OPEN,
                    PO_DOCUMENT_ACTION_PVT.g_doc_action_OPEN_RCV)
    THEN

      IF (p_shipment_id IS NOT NULL)
      THEN

        l_supply_action := 'Create_Release_Shipment_Supply';

      ELSE

         l_supply_action := 'Create_Release_Supply';

      END IF;  -- p_shipment_id is not null


    ELSIF p_action IN (PO_DOCUMENT_ACTION_PVT.g_doc_action_CLOSE,
                       PO_DOCUMENT_ACTION_PVT.g_doc_action_CLOSE_RCV,
                       PO_DOCUMENT_ACTION_PVT.g_doc_action_FINALLY_CLOSE)
    THEN

      IF (p_shipment_id IS NOT NULL)
      THEN

        l_supply_action := 'Remove_Release_Shipment';

      ELSE

        l_supply_action := 'Remove_Release_Supply';

      END IF;  -- p_shipment_id is not null


    END IF;  -- p_action IN...

  END IF;  -- p_document_type = PO

  d_progress := 20;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'l_supply_action', l_supply_action);
  END IF;

  l_supply_ret := PO_SUPPLY.po_req_supply(
                     p_docid         => p_document_id
                  ,  p_lineid        => p_line_id
                  ,  p_shipid        => p_shipment_id
                  ,  p_action        => l_supply_action
                  ,  p_recreate_flag => FALSE
                  ,  p_qty           => 0
                  ,  p_receipt_date  => SYSDATE
                  );

  IF (NOT l_supply_ret)
  THEN

    d_progress := 30;
    x_return_status := 'U';
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, 'po_req_supply call not successful');
    END IF;
    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, 'po_req_supply call not successful');

  ELSE

    d_progress := 40;
    x_return_status := 'S';
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'po_req_supply call was successful');
    END IF;

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    x_return_status := 'U';

    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END handle_manual_close_supply;

PROCEDURE handle_auto_close_supply(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  x_return_status     OUT NOCOPY  VARCHAR2
)
IS

d_module     VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CLOSE.handle_auto_close_supply';
d_progress   NUMBER;
d_msg        VARCHAR2(200);

l_ret_sts        VARCHAR2(1);
l_supply_action  VARCHAR2(30);
l_supply_ret     BOOLEAN;

l_ship_id_tbl      g_tbl_number;
l_closed_code_tbl  g_tbl_closed_code;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_line_id', p_line_id);
    PO_LOG.proc_begin(d_module, 'p_shipment_id', p_shipment_id);
  END IF;

  IF (p_shipment_id IS NOT NULL)
  THEN

    d_progress := 10;

    SELECT poll.line_location_id, poll.closed_code
    BULK COLLECT INTO l_ship_id_tbl, l_closed_code_tbl
    FROM po_line_locations poll
    WHERE poll.line_location_id = p_shipment_id
      AND NVL(poll.approved_flag, 'N') = 'Y'
      AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED';

  ELSIF (p_line_id IS NOT NULL)
  THEN

    d_progress := 20;

    SELECT poll.line_location_id, poll.closed_code
    BULK COLLECT INTO l_ship_id_tbl, l_closed_code_tbl
    FROM po_line_locations poll
    WHERE poll.po_line_id = p_line_id
      AND NVL(poll.approved_flag, 'N') = 'Y'
      AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED';

  ELSIF (p_document_type = 'RELEASE')
  THEN

    d_progress := 30;

    SELECT poll.line_location_id, poll.closed_code
    BULK COLLECT INTO l_ship_id_tbl, l_closed_code_tbl
    FROM po_line_locations poll
    WHERE poll.po_release_id = p_document_id
      AND NVL(poll.approved_flag, 'N') = 'Y'
      AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED';

  ELSE

    d_progress := 40;

    SELECT poll.line_location_id, poll.closed_code
    BULK COLLECT INTO l_ship_id_tbl, l_closed_code_tbl
    FROM po_line_locations poll
    WHERE poll.po_header_id = p_document_id
      AND NVL(poll.approved_flag, 'N') = 'Y'
      AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED';

  END IF;  -- if p_shipment_id is not null

  d_progress := 50;

  -- Initialize return status to success.
  -- We will fail if any supply call fails.
  l_ret_sts := 'S';

  FOR i IN 1..l_ship_id_tbl.COUNT
  LOOP

    d_progress := 60;

    IF (p_document_type = 'PO')
    THEN

      IF (l_closed_code_tbl(i) IN ('CLOSED', 'CLOSED FOR RECEIVING'))
      THEN

          l_supply_action := 'Remove_PO_Shipment_Supply';

      ELSE

          l_supply_action := 'Create_PO_Shipment_Supply';

      END IF;  -- if l_closed_code_tbl(i) IN ...

    ELSIF (p_document_type = 'RELEASE')
    THEN

      IF (l_closed_code_tbl(i) IN ('CLOSED', 'CLOSED FOR RECEIVING'))
      THEN

          l_supply_action := 'Remove_Release_Shipment';

      ELSE

          l_supply_action := 'Create_Release_Shipment_Supply';

      END IF;  -- if l_closed_code_tbl(i) IN ...

    END IF;  -- if p_document_type = 'PO'

    d_progress := 70;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_ship_it_tbl(i)', l_ship_id_tbl(i));
      PO_LOG.stmt(d_module, d_progress, 'l_supply_action', l_supply_action);
    END IF;

    l_supply_ret := PO_SUPPLY.po_req_supply(
                       p_docid         => p_document_id
                    ,  p_lineid        => p_line_id
                    ,  p_shipid        => l_ship_id_tbl(i)
                    ,  p_action        => l_supply_action
                    ,  p_recreate_flag => FALSE
                    ,  p_qty           => 0
                    ,  p_receipt_date  => SYSDATE
                  );

    d_progress := 80;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_supply_ret', l_supply_ret);
    END IF;

    IF (NOT l_supply_ret)
    THEN

      d_progress := 90;

      l_ret_sts := 'U';
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, 'supply action not successful');
        PO_LOG.stmt(d_module, d_progress, 'l_ship_it_tbl(i)', l_ship_id_tbl(i));
        PO_LOG.stmt(d_module, d_progress, 'l_supply_action', l_supply_action);
      END IF;

      EXIT;

    END IF;

  END LOOP;

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    x_return_status := 'U';

    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END handle_auto_close_supply;


END PO_DOCUMENT_ACTION_CLOSE;

/
