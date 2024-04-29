--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_ACTION_HOLD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_ACTION_HOLD" AS
-- $Header: POXDAHFB.pls 120.2 2005/09/07 15:10:04 spangulu noship $

-- Private package constants

g_pkg_name CONSTANT varchar2(30) := 'PO_DOCUMENT_ACTION_PAUSE';
g_log_head CONSTANT VARCHAR2(50) := 'po.plsql.'|| g_pkg_name || '.';


PROCEDURE freeze_unfreeze(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
)
IS

d_progress     NUMBER;
d_module       VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_PAUSE.freeze_unfreeze';
d_msg             VARCHAR2(200);

l_allowed_states  PO_DOCUMENT_ACTION_UTIL.doc_state_rec_type;
l_doc_state_ok    BOOLEAN;
l_ret_sts         VARCHAR2(1);

l_user_id         NUMBER;
l_login_id        NUMBER;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_id', p_action_ctl_rec.document_id);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_type', p_action_ctl_rec.document_type);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_subtype', p_action_ctl_rec.document_subtype);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.action', p_action_ctl_rec.action);
  END IF;

  BEGIN

    d_progress := 10;

    l_user_id := FND_GLOBAL.USER_ID;
    l_login_id := FND_GLOBAL.LOGIN_ID;

    d_progress := 15;

    l_allowed_states.auth_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED;
    l_allowed_states.hold_flag := 'N';
    l_allowed_states.closed_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED;
    l_allowed_states.closed_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_OPEN;
    l_allowed_states.fully_reserved_flag := NULL;

    IF (p_action_ctl_rec.action = PO_DOCUMENT_ACTION_PVT.g_doc_action_FREEZE)
    THEN

      l_allowed_states.frozen_flag := 'N';

    ELSIF (p_action_ctl_rec.action = PO_DOCUMENT_ACTION_PVT.g_doc_action_UNFREEZE)
    THEN

      l_allowed_states.frozen_flag := 'Y';

    ELSE

      d_progress := 20;
      l_ret_sts := 'U';
      d_msg := 'Invalid action';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;  -- p_action_ctl_rec.action = ...

    d_progress := 30;

    l_doc_state_ok := PO_DOCUMENT_ACTION_UTIL.check_doc_state(
                         p_document_id => p_action_ctl_rec.document_id
                      ,  p_document_type => p_action_ctl_rec.document_type
                      ,  p_allowed_states => l_allowed_states
                      ,  x_return_status  => l_ret_sts
                      );

    IF (l_ret_sts <> 'S')
    THEN

      d_progress := 40;
      d_msg := 'check_doc_state not successful';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 50;

    IF (NOT l_doc_state_ok) THEN

      d_progress := 60;
      p_action_ctl_rec.return_code := 'STATE_FAILED';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF; -- if l_doc_state_ok

    IF (p_action_ctl_rec.document_type IN ('PO', 'PA'))
    THEN

      d_progress := 70;

      UPDATE po_headers poh
      SET poh.frozen_flag = DECODE(p_action_ctl_rec.action,
                               PO_DOCUMENT_ACTION_PVT.g_doc_action_FREEZE, 'Y',
                               PO_DOCUMENT_ACTION_PVT.g_doc_action_UNFREEZE, 'N')
       ,  poh.last_update_date = SYSDATE
       ,  poh.last_updated_by  = l_user_id
       ,  poh.last_update_login = l_login_id
      WHERE poh.po_header_id = p_action_ctl_rec.document_id;

    ELSIF (p_action_ctl_rec.document_type = 'RELEASE')
    THEN

      d_progress := 80;

      UPDATE po_releases por
      SET por.frozen_flag = DECODE(p_action_ctl_rec.action,
                               PO_DOCUMENT_ACTION_PVT.g_doc_action_FREEZE, 'Y',
                               PO_DOCUMENT_ACTION_PVT.g_doc_action_UNFREEZE, 'N')
       ,  por.last_update_date = SYSDATE
       ,  por.last_updated_by  = l_user_id
       ,  por.last_update_login = l_login_id
      WHERE por.po_release_id = p_action_ctl_rec.document_id;

    ELSE

      d_progress := 90;
      l_ret_sts := 'U';
      d_msg := 'Invalid document type';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;  -- p_action_ctl_rec.document_type ...

    d_progress := 100;

    PO_DOCUMENT_ACTION_UTIL.handle_ctl_action_history(
       p_document_id       => p_action_ctl_rec.document_id
    ,  p_document_type     => p_action_ctl_rec.document_type
    ,  p_document_subtype  => p_action_ctl_rec.document_subtype
    ,  p_line_id           => p_action_ctl_rec.line_id
    ,  p_shipment_id       => p_action_ctl_rec.shipment_id
    ,  p_action            => p_action_ctl_rec.action
    ,  p_reason            => p_action_ctl_rec.note
    ,  p_user_id           => l_user_id
    ,  p_login_id          => l_login_id
    ,  x_return_status     => l_ret_sts
    );

    IF (l_ret_sts <> 'S')
    THEN

      d_progress := 110;
      d_msg := 'handle_ctl_action_history not successful';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      IF (l_ret_sts = 'U')
      THEN
        IF (PO_LOG.d_exc) THEN
          PO_LOG.exc(d_module, d_progress, d_msg);
        END IF;
      END IF;

      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);

  END;

  p_action_ctl_rec.return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_code', p_action_ctl_rec.return_code);
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

END freeze_unfreeze;

PROCEDURE hold_unhold(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
)
IS

d_progress     NUMBER;
d_module       VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_PAUSE.hold_unhold';
d_msg             VARCHAR2(200);

l_allowed_states  PO_DOCUMENT_ACTION_UTIL.doc_state_rec_type;
l_doc_state_ok    BOOLEAN;
l_ret_sts         VARCHAR2(1);

l_user_id         NUMBER;
l_login_id        NUMBER;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_id', p_action_ctl_rec.document_id);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_type', p_action_ctl_rec.document_type);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_subtype', p_action_ctl_rec.document_subtype);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.action', p_action_ctl_rec.action);
  END IF;

  BEGIN

    d_progress := 10;

    l_user_id := FND_GLOBAL.USER_ID;
    l_login_id := FND_GLOBAL.LOGIN_ID;

    d_progress := 15;

    l_allowed_states.auth_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_status_INCOMPLETE;
    l_allowed_states.auth_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_status_INPROCESS;
    l_allowed_states.auth_states(3) := PO_DOCUMENT_ACTION_PVT.g_doc_status_REJECTED;
    l_allowed_states.auth_states(4) := PO_DOCUMENT_ACTION_PVT.g_doc_status_RETURNED;
    l_allowed_states.auth_states(5) := PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED;
    l_allowed_states.auth_states(6) := PO_DOCUMENT_ACTION_PVT.g_doc_status_REAPPROVAL;
    l_allowed_states.auth_states(7) := PO_DOCUMENT_ACTION_PVT.g_doc_status_PREAPPROVED;
    l_allowed_states.closed_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED;
    l_allowed_states.closed_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_OPEN;
    l_allowed_states.fully_reserved_flag := NULL;
    l_allowed_states.frozen_flag := NULL;

    IF (p_action_ctl_rec.action = PO_DOCUMENT_ACTION_PVT.g_doc_action_HOLD)
    THEN

      l_allowed_states.hold_flag := 'N';

    ELSIF (p_action_ctl_rec.action = PO_DOCUMENT_ACTION_PVT.g_doc_action_RELEASE_HOLD)
    THEN

      l_allowed_states.hold_flag := 'Y';

    ELSE

      d_progress := 20;
      l_ret_sts := 'U';
      d_msg := 'Invalid action';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;  -- p_action_ctl_rec.action = ...

    d_progress := 30;

    l_doc_state_ok := PO_DOCUMENT_ACTION_UTIL.check_doc_state(
                         p_document_id => p_action_ctl_rec.document_id
                      ,  p_document_type => p_action_ctl_rec.document_type
                      ,  p_allowed_states => l_allowed_states
                      ,  x_return_status  => l_ret_sts
                      );

    IF (l_ret_sts <> 'S')
    THEN

      d_progress := 40;
      d_msg := 'check_doc_state not successful';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 50;

    IF (NOT l_doc_state_ok) THEN

      d_progress := 60;
      p_action_ctl_rec.return_code := 'STATE_FAILED';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF; -- if l_doc_state_ok

    IF (p_action_ctl_rec.document_type IN ('PO', 'PA'))
    THEN

      d_progress := 70;

      UPDATE po_headers poh
      SET poh.user_hold_flag = DECODE(p_action_ctl_rec.action,
                                  PO_DOCUMENT_ACTION_PVT.g_doc_action_HOLD, 'Y',
                                  PO_DOCUMENT_ACTION_PVT.g_doc_action_RELEASE_HOLD, 'N')
       ,  poh.approved_flag = DECODE(p_action_ctl_rec.action,
                                  PO_DOCUMENT_ACTION_PVT.g_doc_action_HOLD,
                                    DECODE(poh.approved_flag, 'Y', 'R', poh.approved_flag),
                                  PO_DOCUMENT_ACTION_PVT.g_doc_action_RELEASE_HOLD, poh.approved_flag)
       ,  poh.authorization_status = DECODE(p_action_ctl_rec.action,
                                       PO_DOCUMENT_ACTION_PVT.g_doc_action_HOLD,
                                         DECODE(poh.authorization_status,
                                                  'APPROVED', 'REQUIRES REAPPROVAL',
                                                   poh.authorization_status),
                                       PO_DOCUMENT_ACTION_PVT.g_doc_action_RELEASE_HOLD, poh.authorization_status)
       ,  poh.last_update_date  = sysdate
       ,  poh.last_updated_by   = l_user_id
       ,  poh.last_update_login = l_login_id
      WHERE poh.po_header_id = p_action_ctl_rec.document_id;

      IF (p_action_ctl_rec.document_type = 'PO')
      THEN

        d_progress := 80;

        UPDATE po_line_locations poll
        SET poll.approved_flag = DECODE(p_action_ctl_rec.action,
                                   PO_DOCUMENT_ACTION_PVT.g_doc_action_HOLD,
                                     DECODE(poll.approved_flag, 'Y', 'R', poll.approved_flag),
                                   PO_DOCUMENT_ACTION_PVT.g_doc_action_RELEASE_HOLD, poll.approved_flag)
         ,  poll.last_update_date  = SYSDATE
         ,  poll.last_updated_by   = l_user_id
         ,  poll.last_update_login = l_login_id
        WHERE poll.po_header_id      = p_action_ctl_rec.document_id
          -- <Complex Work R12>: Include PREPAYMENT shipment_type
          AND poll.shipment_type in ('STANDARD', 'PLANNED', 'PREPAYMENT');

      END IF;  -- p_action_ctl_rec.document_type = 'PO'

    ELSIF (p_action_ctl_rec.document_type = 'RELEASE')
    THEN

      d_progress := 90;

      UPDATE po_releases por
      SET por.hold_flag = DECODE(p_action_ctl_rec.action,
                             PO_DOCUMENT_ACTION_PVT.g_doc_action_HOLD, 'Y',
                             PO_DOCUMENT_ACTION_PVT.g_doc_action_RELEASE_HOLD, 'N')
       ,  por.approved_flag = DECODE(p_action_ctl_rec.action,
                                  PO_DOCUMENT_ACTION_PVT.g_doc_action_HOLD,
                                    DECODE(por.approved_flag, 'Y', 'R', por.approved_flag),
                                  PO_DOCUMENT_ACTION_PVT.g_doc_action_RELEASE_HOLD, por.approved_flag)
       ,  por.authorization_status = DECODE(p_action_ctl_rec.action,
                                       PO_DOCUMENT_ACTION_PVT.g_doc_action_HOLD,
                                         DECODE(por.authorization_status,
                                                  'APPROVED', 'REQUIRES REAPPROVAL',
                                                   por.authorization_status),
                                       PO_DOCUMENT_ACTION_PVT.g_doc_action_RELEASE_HOLD, por.authorization_status)
       ,  por.last_update_date  = sysdate
       ,  por.last_updated_by   = l_user_id
       ,  por.last_update_login = l_login_id
      WHERE por.po_release_id = p_action_ctl_rec.document_id;

      d_progress := 100;

      UPDATE po_line_locations poll
      SET poll.approved_flag = DECODE(p_action_ctl_rec.action,
                                 PO_DOCUMENT_ACTION_PVT.g_doc_action_HOLD,
                                   DECODE(poll.approved_flag, 'Y', 'R', poll.approved_flag),
                                 PO_DOCUMENT_ACTION_PVT.g_doc_action_RELEASE_HOLD, poll.approved_flag)
       ,  poll.last_update_date  = SYSDATE
       ,  poll.last_updated_by   = l_user_id
       ,  poll.last_update_login = l_login_id
      WHERE poll.po_release_id      = p_action_ctl_rec.document_id
        AND poll.shipment_type in ('BLANKET', 'SCHEDULED');

    ELSE

      d_progress := 110;
      l_ret_sts := 'U';
      d_msg := 'Invalid document type';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;  -- p_action_ctl_rec.document_type ...

    d_progress := 120;

    PO_DOCUMENT_ACTION_UTIL.handle_ctl_action_history(
       p_document_id       => p_action_ctl_rec.document_id
    ,  p_document_type     => p_action_ctl_rec.document_type
    ,  p_document_subtype  => p_action_ctl_rec.document_subtype
    ,  p_line_id           => p_action_ctl_rec.line_id
    ,  p_shipment_id       => p_action_ctl_rec.shipment_id
    ,  p_action            => p_action_ctl_rec.action
    ,  p_reason            => p_action_ctl_rec.note
    ,  p_user_id           => l_user_id
    ,  p_login_id          => l_login_id
    ,  x_return_status     => l_ret_sts
    );

    IF (l_ret_sts <> 'S')
    THEN

      d_progress := 130;
      d_msg := 'handle_ctl_action_history not successful';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      IF (l_ret_sts = 'U')
      THEN
        IF (PO_LOG.d_exc) THEN
          PO_LOG.exc(d_module, d_progress, d_msg);
        END IF;
      END IF;

      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);

  END;

  p_action_ctl_rec.return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_code', p_action_ctl_rec.return_code);
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


END hold_unhold;




END PO_DOCUMENT_ACTION_HOLD;

/
