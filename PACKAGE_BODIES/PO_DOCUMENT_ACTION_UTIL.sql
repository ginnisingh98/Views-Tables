--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_ACTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_ACTION_UTIL" AS
-- $Header: POXDAULB.pls 120.4.12010000.9 2014/10/17 02:11:06 roqiu ship $

-- Private package constants

g_pkg_name CONSTANT varchar2(30) := 'PO_DOCUMENT_ACTION_UTIL';
g_log_head CONSTANT VARCHAR2(50) := 'po.plsql.'|| g_pkg_name || '.';


-- Forward Declare Private Methods

PROCEDURE insert_auth_action_history(
   p_document_id        IN          NUMBER
,  p_revision_num       IN          NUMBER
,  p_document_type      IN          VARCHAR2
,  p_document_subtype   IN          VARCHAR2
,  p_action             IN          VARCHAR2
,  p_employee_id        IN          NUMBER
,  p_offline_code       IN          VARCHAR2
,  p_approval_path_id   IN          NUMBER
,  p_note               IN          VARCHAR2
,  p_user_id            IN          NUMBER
,  p_login_id           IN          NUMBER
,  x_return_status      OUT NOCOPY  VARCHAR2
);

PROCEDURE update_auth_action_history(
   p_document_id        IN          NUMBER
,  p_revision_num       IN          NUMBER
,  p_document_type      IN          VARCHAR2
,  p_action             IN          VARCHAR2
,  p_approval_path_id   IN          NUMBER
,  p_note               IN          VARCHAR2
,  p_user_id            IN          NUMBER
,  x_return_status      OUT NOCOPY  VARCHAR2
);

PROCEDURE handle_auth_action_history(
   p_document_id        IN          NUMBER
,  p_revision_num       IN          NUMBER
,  p_document_type      IN          VARCHAR2
,  p_document_subtype   IN          VARCHAR2
,  p_action             IN          VARCHAR2
,  p_fwd_to_id          IN          NUMBER
,  p_offline_code       IN          VARCHAR2
,  p_approval_path_id   IN          NUMBER
,  p_note               IN          VARCHAR2
,  p_employee_id        IN          NUMBER
,  p_user_id            IN          NUMBER
,  p_login_id           IN          NUMBER
,  p_old_status         IN          VARCHAR2
,  x_return_status      OUT NOCOPY  VARCHAR2
);
--<Bug 14271696 :Cancel Refactoring Project>
-- Made the procedure "update_doc_auth_status" public
-- as the same code logic was need while updating the doucmnet
-- during Cancel [Called from po_document_cancel_pvt.approve_entity(..)].
-- Cannot use "change_doc_auth_state" as it updates the action history table
-- For Cancel, action history will be stamped with action='CANCEL'
-- and not 'APPROVE' and 'SUBMIT'.
-- Action Histoy update is handled in Cancel code itself.


PROCEDURE update_doc_notifications(
   p_document_id        IN         NUMBER
,  p_document_type      IN         VARCHAR2
,  p_document_subtype   IN         VARCHAR2
,  p_notify_action      IN         VARCHAR2
,  p_notify_employee    IN         NUMBER
,  p_doc_creation_date  IN         DATE
,  p_user_id            IN         NUMBER
,  p_login_id           IN         NUMBER
,  x_return_status      OUT NOCOPY VARCHAR2
);


-- Public Methods

FUNCTION check_doc_state(
   p_document_id        IN     NUMBER
,  p_document_type      IN     VARCHAR2
,  p_line_id            IN     NUMBER     DEFAULT NULL
,  p_shipment_id        IN     NUMBER     DEFAULT NULL
,  p_allowed_states     IN     PO_DOCUMENT_ACTION_UTIL.DOC_STATE_REC_TYPE
,  x_return_status      OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS

i                 BINARY_INTEGER;

l_fully_res_flag  financials_system_parameters.req_encumbrance_flag%TYPE;
l_auth_status     po_releases.authorization_status%TYPE;
l_head_closed     po_releases.closed_code%TYPE;

l_user_hold_flag  po_releases.hold_flag%TYPE;
l_ship_closed     po_line_locations.closed_code%TYPE;
l_line_closed     po_lines.closed_code%TYPE;
l_closed_code     VARCHAR2(26);
l_frozen_flag     po_releases.frozen_flag%TYPE;

l_state_found     BOOLEAN;

d_progress        NUMBER;
d_module          VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_UTIL.check_doc_state';

l_ret_sts         VARCHAR2(1);
l_ret_val         BOOLEAN;

CURSOR state_rel(docid NUMBER) IS
  SELECT nvl(por.authorization_status, 'INCOMPLETE'),
         nvl(por.closed_code, 'OPEN'),
         nvl(por.frozen_flag, 'N'),
         nvl(por.hold_flag, 'N')
  FROM po_releases por
  WHERE por.po_release_id = docid;

CURSOR state_po(docid NUMBER) IS
  SELECT nvl(poh.authorization_status, 'INCOMPLETE'),
         nvl(poh.closed_code, 'OPEN'),
         nvl(poh.frozen_flag, 'N'),
         nvl(poh.user_hold_flag, 'N')
  FROM po_headers poh
  WHERE poh.po_header_id = docid;

CURSOR state_req(docid NUMBER) IS
  SELECT nvl(prh.authorization_status, 'INCOMPLETE'),
         nvl(prh.closed_code, 'OPEN')
  FROM po_requisition_headers prh
  WHERE prh.requisition_header_id = docid;

CURSOR ship_closed(shipid NUMBER) IS
  SELECT nvl(poll.closed_code, 'OPEN')
  FROM po_line_locations poll
  WHERE poll.line_location_id = shipid;

CURSOR line_closed(lineid NUMBER) is
  SELECT nvl(pol.closed_code, 'OPEN')
  FROM po_lines pol
  WHERE pol.po_line_id = lineid;


BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_line_id', p_line_id);
    PO_LOG.proc_begin(d_module, 'p_shipment_id', p_shipment_id);
  END IF;

  l_ret_val := FALSE;

  d_progress := 10;

  BEGIN

    IF (p_document_type = 'RELEASE')
    THEN

      d_progress := 20;

      OPEN state_rel(p_document_id);
      FETCH state_rel
      INTO l_auth_status, l_head_closed, l_frozen_flag, l_user_hold_flag;
      CLOSE state_rel;

      d_progress := 30;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'l_auth_status', l_auth_status);
        PO_LOG.stmt(d_module, d_progress, 'l_head_closed', l_head_closed);
        PO_LOG.stmt(d_module, d_progress, 'l_frozen_flag', l_frozen_flag);
        PO_LOG.stmt(d_module, d_progress, 'l_user_hold_flag', l_user_hold_flag);

      END IF;

      IF (p_shipment_id IS NOT NULL)
      THEN

        d_progress := 40;

        OPEN ship_closed(p_shipment_id);
        FETCH ship_closed INTO l_ship_closed;
        CLOSE ship_closed;

        d_progress := 50;
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'l_ship_closed', l_ship_closed);
        END IF;

      END IF;

    ELSIF (p_document_type in ('PO', 'PA'))
    THEN

      d_progress := 60;

      OPEN state_po(p_document_id);
      FETCH state_po
      INTO l_auth_status, l_head_closed, l_frozen_flag, l_user_hold_flag;
      CLOSE state_po;

      d_progress := 70;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'l_auth_status', l_auth_status);
        PO_LOG.stmt(d_module, d_progress, 'l_head_closed', l_head_closed);
        PO_LOG.stmt(d_module, d_progress, 'l_frozen_flag', l_frozen_flag);
        PO_LOG.stmt(d_module, d_progress, 'l_user_hold_flag', l_user_hold_flag);

      END IF;

      IF (p_shipment_id IS NOT NULL) THEN

        d_progress := 80;

        OPEN ship_closed(p_shipment_id);
        FETCH  ship_closed INTO l_ship_closed;
        CLOSE ship_closed;

        d_progress := 90;
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'l_ship_closed', l_ship_closed);
        END IF;

      END IF;

      IF (p_line_id IS NOT NULL) THEN

        d_progress := 100;

        OPEN line_closed(p_line_id);
        FETCH  line_closed INTO l_line_closed;
        CLOSE line_closed;

        d_progress := 110;
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'l_line_closed', l_line_closed);
        END IF;

      END IF;

    ELSIF (p_document_type = 'REQUISITION') THEN

      d_progress := 120;

      OPEN state_req(p_document_id);
      FETCH state_req INTO l_auth_status, l_head_closed;
      CLOSE state_req;

      d_progress := 130;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'l_auth_status', l_auth_status);
        PO_LOG.stmt(d_module, d_progress, 'l_head_closed', l_head_closed);
      END IF;

    ELSE

      d_progress := 140;
      l_ret_sts := 'U';
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, 'Bad Document Type');
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, 'Bad Document Type');
      END IF;
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    l_state_found := FALSE;
    d_progress := 150;

    FOR i in p_allowed_states.auth_states.FIRST .. p_allowed_states.auth_states.LAST

    LOOP
      IF p_allowed_states.auth_states(i) = l_auth_status
      THEN
        l_state_found := TRUE;
        EXIT;
      END IF;
    END LOOP;

    d_progress := 160;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_state_found', l_state_found);
    END IF;

    IF NOT l_state_found
    THEN

      d_progress := 170;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Current Authorization Status Not Allowed.');

      END IF;

      l_ret_sts := 'S';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;


    l_closed_code := NVL(l_ship_closed, l_line_closed);
    l_closed_code := NVL(l_closed_code, l_head_closed);

    d_progress := 180;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_closed_code', l_closed_code);
    END IF;

    l_state_found := FALSE;

    FOR i in p_allowed_states.closed_states.FIRST .. p_allowed_states.closed_states.LAST

    LOOP
      IF p_allowed_states.closed_states(i) = l_closed_code
      THEN
        l_state_found := TRUE;
        EXIT;
      END IF;
    END LOOP;

    d_progress := 190;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_state_found', l_state_found);
    END IF;

    IF NOT l_state_found
    THEN

      d_progress := 200;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Current Closed Status Not Allowed.');

      END IF;

      l_ret_sts := 'S';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;


    IF ((p_allowed_states.fully_reserved_flag IS NOT NULL)
      AND ( PO_CORE_S.is_encumbrance_on(p_doc_type => p_document_type, p_org_id => NULL)))

    THEN

      d_progress := 210;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Encumbrance is on.  Checking reserved state');

      END IF;

      PO_CORE_S.is_fully_reserved(
           p_doc_type => p_document_type
        ,  p_doc_level => PO_CORE_S.g_doc_level_HEADER
        ,  p_doc_level_id => p_document_id
        ,  x_fully_reserved_flag => l_fully_res_flag
        );

      d_progress := 220;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'l_fully_res_flag', l_fully_res_flag);

      END IF;

      IF (p_allowed_states.fully_reserved_flag <> l_fully_res_flag)
      THEN

        d_progress := 230;
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'Current Encumbrance reservation state not allowed.');

        END IF;

        l_ret_sts := 'S';
        RAISE PO_CORE_S.g_early_return_exc;

      END IF; -- IF p_allowed_states.fully_reserved_flag <> l_fully_res_flag

    END IF; -- IF p_allowed_states.fully_reserved_flag IS NOT NULL

    IF (p_document_type IN ('PO', 'PA', 'RELEASE'))
    THEN

      d_progress := 240;

      IF ((p_allowed_states.frozen_flag IS NOT NULL)
         AND (p_allowed_states.frozen_flag <> l_frozen_flag))
      THEN

        d_progress := 250;
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'Frozen flags do not match.');
          PO_LOG.stmt(d_module, d_progress, 'p_allowed_states.frozen_flag', p_allowed_states.frozen_flag);

          PO_LOG.stmt(d_module, d_progress, 'l_frozen_flag', l_frozen_flag);
        END IF;

        l_ret_sts := 'S';
        RAISE PO_CORE_S.g_early_return_exc;

      END IF;  -- p_allowed_states.frozen_flag IS NOT NULL

      IF ((p_allowed_states.hold_flag IS NOT NULL)
         AND (p_allowed_states.hold_flag <> l_user_hold_flag))
      THEN

        d_progress := 260;
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'Hold flags do not match.');
          PO_LOG.stmt(d_module, d_progress, 'p_allowed_states.hold_flag', p_allowed_states.hold_flag);

          PO_LOG.stmt(d_module, d_progress, 'l_user_hold_flag', l_user_hold_flag);
        END IF;

        l_ret_sts := 'S';
        RAISE PO_CORE_S.g_early_return_exc;

      END IF;  -- p_allowed_states.hold_flag IS NOT NULL

    END IF;  -- IF p_document_type IN ('PO', 'PA', 'RELEASE')

    d_progress := 270;
    l_ret_sts := 'S';
    l_ret_val := TRUE;

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      NULL;
  END;

  x_return_status := l_ret_sts;

  d_progress := 280;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_return(d_module, l_ret_val);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN (l_ret_val);

EXCEPTION

  WHEN OTHERS THEN

    IF state_rel%ISOPEN THEN
      CLOSE state_rel;
    END IF;

    IF state_po%ISOPEN THEN
      CLOSE state_po;
    END IF;

    IF state_req%ISOPEN THEN
      CLOSE state_req;
    END IF;

    IF ship_closed%ISOPEN THEN
      CLOSE ship_closed;
    END IF;

    IF line_closed%ISOPEN THEN
      CLOSE line_closed;
    END IF;

    x_return_status := 'U';

    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, SQLCODE, SQLERRM);
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_return(d_module, l_ret_val);
      PO_LOG.proc_end(d_module);
    END IF;

    return FALSE;

END check_doc_state;



PROCEDURE get_doc_preparer_id(
   p_document_id        IN     NUMBER
,  p_document_type      IN     VARCHAR2
,  x_return_status      OUT NOCOPY VARCHAR2
,  x_preparer_id        OUT NOCOPY  NUMBER
)
IS

d_progress        NUMBER;
d_module          VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_UTIL.get_doc_preparer_id';

l_ret_sts         VARCHAR2(1);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
  END IF;

  l_ret_sts := 'S';

  IF (p_document_type = 'RELEASE')
  THEN

    d_progress := 20;

    SELECT por.agent_id
    INTO x_preparer_id
    FROM po_releases_all por
    WHERE por.po_release_id = p_document_id;

    d_progress := 30;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'x_preparer_id', x_preparer_id);
    END IF;

  ELSIF (p_document_type in ('PO', 'PA'))
  THEN

    d_progress := 40;

    SELECT poh.agent_id
    INTO x_preparer_id
    FROM po_headers_all poh
    WHERE poh.po_header_id = p_document_id;

    d_progress := 50;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'x_preparer_id', x_preparer_id);
    END IF;

  ELSIF (p_document_type = 'REQUISITION') THEN

    d_progress := 60;

    SELECT porh.preparer_id
    INTO x_preparer_id
    FROM po_requisition_headers_all porh
    WHERE porh.requisition_header_id = p_document_id;

    d_progress := 70;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'x_preparer_id', x_preparer_id);
    END IF;

  ELSE

    l_ret_sts := 'U';

    d_progress := 80;
    PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, 'Bad Document Type');
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, 'Bad Document Type');
    END IF;

  END IF;

  x_return_status := l_ret_sts;

  d_progress := 100;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_preparer_id', x_preparer_id);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

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

END get_doc_preparer_id;



PROCEDURE get_employee_info(
   p_user_id            IN          NUMBER
,  x_return_status      OUT NOCOPY  VARCHAR2
,  x_employee_flag      OUT NOCOPY  BOOLEAN
,  x_employee_id        OUT NOCOPY  NUMBER
,  x_employee_name      OUT NOCOPY  VARCHAR2
,  x_location_id        OUT NOCOPY  NUMBER
,  x_location_code      OUT NOCOPY  VARCHAR2
,  x_is_buyer_flag      OUT NOCOPY  BOOLEAN
)
IS

d_progress        NUMBER;
d_module          VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_UTIL.get_employee_info';

l_temp_var   VARCHAR2(1);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
  END IF;

  BEGIN
    d_progress := 10;

    SELECT hr.person_id, hr.full_name, hr.location_id
    INTO x_employee_id, x_employee_name, x_location_id
    FROM FND_USER fnd, PO_WORKFORCE_CURRENT_X hr      -- <BUG 6615913>
    WHERE fnd.user_id = p_user_id
      AND fnd.employee_id = hr.person_id;

    x_employee_flag := TRUE;

    d_progress := 20;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'x_employee_id', x_employee_id);
      PO_LOG.stmt(d_module, d_progress, 'x_employee_name', x_employee_name);
      PO_LOG.stmt(d_module, d_progress, 'x_location_id', x_location_id);
    END IF;

  EXCEPTION
    WHEN no_data_found THEN
      x_employee_flag := FALSE;
      x_location_id := NULL;
  END;

  d_progress := 30;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'x_employee_flag', x_employee_flag);
  END IF;

  IF (x_location_id IS NOT NULL)
  THEN

    d_progress := 40;

    BEGIN

      SELECT hr.location_code
      INTO x_location_code
      FROM HR_LOCATIONS hr,
           FINANCIALS_SYSTEM_PARAMETERS fsp,
           ORG_ORGANIZATION_DEFINITIONS ood
      WHERE hr.location_id = x_location_id
        AND hr.inventory_organization_id = ood.organization_id (+)
        AND nvl(ood.set_of_books_id, fsp.set_of_books_id) = fsp.set_of_books_id;

      d_progress := 50;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'x_location_code', x_location_code);
      END IF;

    EXCEPTION
      WHEN no_data_found THEN
        x_location_id := NULL;
    END;

  END IF;  -- x_location_id IS NOT NULL

  d_progress := 60;

  IF (x_employee_flag)
  THEN
    BEGIN

      SELECT 'X'
      INTO l_temp_var
      FROM po_agents poa
      WHERE poa.agent_id = x_employee_id
        AND SYSDATE between nvl(poa.start_date_active, SYSDATE - 1) and NVL(poa.end_date_active, SYSDATE + 1);

      x_is_buyer_flag := TRUE;

      d_progress := 70;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'x_is_buyer_flag', x_is_buyer_flag);
      END IF;

    EXCEPTION
      WHEN no_data_found THEN
        x_is_buyer_flag := FALSE;
        d_progress := 75;
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'x_is_buyer_flag', x_is_buyer_flag);
        END IF;
    END;

  END IF;  -- if x_employee_flag

  x_return_status := 'S';
  d_progress := 100;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_employee_flag', x_employee_flag);
    PO_LOG.proc_end(d_module, 'x_employee_id', x_employee_id);
    PO_LOG.proc_end(d_module, 'x_employee_name', x_employee_name);
    PO_LOG.proc_end(d_module, 'x_location_id', x_location_id);
    PO_LOG.proc_end(d_module, 'x_location_code', x_location_code);
    PO_LOG.proc_end(d_module, 'x_is_buyer_flag', x_is_buyer_flag);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

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

END get_employee_info;


PROCEDURE get_employee_id(
   p_user_id            IN          NUMBER
,  x_return_status      OUT NOCOPY  VARCHAR2
,  x_employee_flag      OUT NOCOPY  BOOLEAN
,  x_employee_id        OUT NOCOPY  NUMBER
)
IS

d_progress        NUMBER;
d_module          VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_UTIL.get_employee_id';

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
  END IF;

  BEGIN

    d_progress := 10;

    SELECT hr.person_id
    INTO x_employee_id
    FROM FND_USER fnd, PER_WORKFORCE_CURRENT_X hr   --R12 CWK Enhancement
    WHERE fnd.user_id = p_user_id
      AND fnd.employee_id = hr.person_id;

    x_employee_flag := TRUE;

    d_progress := 20;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'x_employee_id', x_employee_id);
    END IF;

  EXCEPTION
    WHEN no_data_found THEN
      x_employee_flag := FALSE;
      x_employee_id := NULL;
  END;


  x_return_status := 'S';
  d_progress := 100;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_employee_flag', x_employee_flag);
    PO_LOG.proc_end(d_module, 'x_employee_id', x_employee_id);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

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

END get_employee_id;


PROCEDURE change_doc_auth_state(
   p_document_id        IN          NUMBER
,  p_document_type      IN          VARCHAR2
,  p_document_subtype   IN          VARCHAR2
,  p_action             IN          VARCHAR2
,  p_fwd_to_id          IN          NUMBER
,  p_offline_code       IN          VARCHAR2
,  p_approval_path_id   IN          NUMBER
,  p_note               IN          VARCHAR2
,  p_new_status         IN          VARCHAR2
,  p_notify_action      IN          VARCHAR2
,  p_notify_employee    IN          NUMBER
,  x_return_status      OUT NOCOPY  VARCHAR2
)
IS

l_user_id      NUMBER;
l_login_id     NUMBER;

l_ret_sts      VARCHAR2(1);
l_err_msg      VARCHAR2(200);

l_emp_flag       BOOLEAN;
l_emp_id         PER_EMPLOYEES_CURRENT_X.employee_id%TYPE;

l_old_status     PO_HEADERS.authorization_status%TYPE;
l_creation_date  PO_HEADERS.creation_date%TYPE;
l_revision_num   PO_HEADERS.revision_num%TYPE;

d_progress        NUMBER;
d_module          VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_UTIL.change_doc_auth_state';

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_action', p_action);
    PO_LOG.proc_begin(d_module, 'p_fwd_to_id', p_fwd_to_id);
    PO_LOG.proc_begin(d_module, 'p_offline_code', p_offline_code);
    PO_LOG.proc_begin(d_module, 'p_approval_path_id', p_approval_path_id);
    PO_LOG.proc_begin(d_module, 'p_note', p_note);
    PO_LOG.proc_begin(d_module, 'p_new_status', p_new_status);
    PO_LOG.proc_begin(d_module, 'p_notify_action', p_notify_action);
    PO_LOG.proc_begin(d_module, 'p_notify_employee', p_notify_employee);
  END IF;

  l_user_id := FND_GLOBAL.USER_ID;
  l_login_id := FND_GLOBAL.LOGIN_ID;

  d_progress := 10;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'l_user_id', l_user_id);
    PO_LOG.stmt(d_module, d_progress, 'l_login_id', l_login_id);
  END IF;

  BEGIN

    get_employee_id(
       p_user_id          => l_user_id
    ,  x_return_status    => l_ret_sts
    ,  x_employee_flag    => l_emp_flag
    ,  x_employee_id      => l_emp_id
    );

    IF (l_ret_sts <> 'S')
    THEN

      d_progress := 20;
      l_err_msg := 'get_employee_id not successful';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 30;

    IF (NOT l_emp_flag)
    THEN

      l_emp_id := NULL;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'user is not employee');
      END IF;

    END IF;

    d_progress := 40;

    IF (p_document_type = 'REQUISITION')
    THEN

      d_progress := 50;

      SELECT porh.authorization_status, porh.creation_date, 0
      INTO l_old_status, l_creation_date, l_revision_num
      FROM PO_REQUISITION_HEADERS porh
      WHERE porh.requisition_header_id = p_document_id;

    ELSIF (p_document_type IN ('PA', 'PO'))
    THEN

      d_progress := 60;

      SELECT NVL(poh.authorization_status, PO_DOCUMENT_ACTION_PVT.g_doc_status_INCOMPLETE),
             poh.creation_date,
             poh.revision_num
      INTO   l_old_status,
             l_creation_date,
             l_revision_num
      FROM   PO_HEADERS poh
      WHERE  poh.po_header_id = p_document_id;

    ELSIF (p_document_type = 'RELEASE')
    THEN

      d_progress := 70;

      SELECT NVL(por.authorization_status, PO_DOCUMENT_ACTION_PVT.g_doc_status_INCOMPLETE),
             por.creation_date,
             por.revision_num
      INTO   l_old_status,
             l_creation_date,
             l_revision_num
      FROM   PO_RELEASES por
      WHERE  por.po_release_id = p_document_id;    -- <Bug 4118145 - Issue 2>

    ELSE

      d_progress := 80;
      l_err_msg := 'Bad Document Type';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 90;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_old_status', l_old_status);
      PO_LOG.stmt(d_module, d_progress, 'l_creation_date', l_creation_date);
      PO_LOG.stmt(d_module, d_progress, 'l_revision_num', l_revision_num);
    END IF;

    handle_auth_action_history(
       p_document_id        => p_document_id
    ,  p_revision_num       => l_revision_num
    ,  p_document_type      => p_document_type
    ,  p_document_subtype   => p_document_subtype
    ,  p_action             => p_action
    ,  p_fwd_to_id          => p_fwd_to_id
    ,  p_offline_code       => p_offline_code
    ,  p_approval_path_id   => p_approval_path_id
    ,  p_note               => p_note
    ,  p_employee_id        => l_emp_id
    ,  p_user_id            => l_user_id
    ,  p_login_id           => l_login_id
    ,  p_old_status         => l_old_status
    ,  x_return_status      => l_ret_sts
    );

    IF (l_ret_sts <> 'S')
    THEN

      d_progress := 100;
      l_err_msg := 'handle_auth_action_history not successful';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 110;

    IF (p_new_status IS NOT NULL)
    THEN

      update_doc_auth_status(
         p_document_id         => p_document_id
      ,  p_document_type       => p_document_type
      ,  p_document_subtype    => p_document_subtype
      ,  p_new_status          => p_new_status
      ,  p_user_id             => l_user_id
      ,  p_login_id            => l_login_id
      ,  x_return_status       => l_ret_sts
      );

      IF (l_ret_sts <> 'S')
      THEN

        d_progress := 120;
        l_err_msg := 'update_doc_auth_status not successful';
        RAISE PO_CORE_S.g_early_return_exc;

      END IF;

    END IF;  -- p_new_status IS NOT NULL

  l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
        l_ret_sts := 'U';
        PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, l_err_msg);
        IF (PO_LOG.d_exc) THEN
          PO_LOG.exc(d_module, d_progress, l_err_msg);
        END IF;

  END;

  x_return_status := l_ret_sts;
  d_progress := 130;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

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

END change_doc_auth_state;



PROCEDURE handle_ctl_action_history(
   p_document_id        IN          NUMBER
,  p_document_type      IN          VARCHAR2
,  p_document_subtype   IN          VARCHAR2
,  p_line_id            IN          NUMBER
,  p_shipment_id        IN          NUMBER
,  p_action             IN          VARCHAR2
,  p_reason             IN          VARCHAR2
,  p_user_id            IN          NUMBER
,  p_login_id           IN          NUMBER
,  x_return_status      OUT NOCOPY  VARCHAR2
)
IS

d_progress        NUMBER;
d_module          VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_UTIL.handle_ctl_action_history';
d_msg             VARCHAR2(200);

l_ret_sts         VARCHAR2(1);

l_emp_flag        BOOLEAN;
l_emp_id          NUMBER;

l_rollup_msg               VARCHAR2(256);
l_ctl_replaced_null_entry  BOOLEAN := FALSE;
l_count_hist               NUMBER;

l_revision_num             PO_HEADERS_ALL.revision_num%TYPE;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_action', p_action);
    PO_LOG.proc_begin(d_module, 'p_reason', p_reason);
    PO_LOG.proc_begin(d_module, 'p_line_id', p_line_id);
    PO_LOG.proc_begin(d_module, 'p_shipment_id', p_shipment_id);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
  END IF;

  d_progress := 10;

  BEGIN

    get_employee_id(
       p_user_id         => p_user_id
    ,  x_return_status   => l_ret_sts
    ,  x_employee_flag   => l_emp_flag
    ,  x_employee_id     => l_emp_id
    );

    IF (l_ret_sts <> 'S')
    THEN

      d_progress := 20;
      d_msg := 'get_employee_id not successful';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 30;

    IF (l_emp_flag IS NULL) THEN
      l_emp_id := NULL;
    END IF;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_emp_flag', l_emp_flag);
      PO_LOG.stmt(d_module, d_progress, 'l_emp_id', l_emp_id);
    END IF;

    d_progress := 40;

    l_rollup_msg := substr(FND_MESSAGE.GET_STRING('PO', 'PO_CLOSE_ROLLUP'), 1, 256);

    IF (p_action IN ('CANCEL', 'FINALLY CLOSE'))
    THEN

      d_progress := 50;

      UPDATE po_action_history poah
      SET poah.action_code = p_action
        , poah.action_date = SYSDATE
        , poah.offline_code = NULL
        , poah.employee_id = l_emp_id
        , poah.note = DECODE(p_shipment_id, NULL,
                        DECODE(p_line_id, NULL, p_reason, l_rollup_msg),
                        l_rollup_msg)
        , poah.last_updated_by = p_user_id
        , poah.last_update_date = SYSDATE
      WHERE poah.object_id = p_document_id
        AND poah.object_type_code = p_document_type
        AND poah.object_sub_type_code = p_document_subtype
        AND poah.action_code IS NULL;

      d_progress := 60;

      IF (NOT SQL%NOTFOUND)
      THEN

        l_ctl_replaced_null_entry := TRUE;

      END IF;

    END IF;  -- if (p_action IN ('CANCEL', 'FINALLY CLOSE'))

    d_progress := 100;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_ctl_repaced_null_entry', l_ctl_replaced_null_entry);
    END IF;

    IF (NOT l_ctl_replaced_null_entry)
    THEN

      d_progress := 110;

      UPDATE po_action_history poah
      SET poah.sequence_num = poah.sequence_num + 1
      WHERE poah.object_id = p_document_id
        AND poah.object_type_code = p_document_type
        AND poah.object_sub_type_code = p_document_subtype
        AND poah.action_code IS NULL;

      d_progress := 120;

      -- Bug 3136474: Was in Pro*C, but not in PL/SQL API
      -- Ported it over, as it will fix a PDOI issue.

      SELECT count(1)
      INTO l_count_hist
      FROM po_action_history poah
      WHERE poah.object_id = p_document_id
        AND poah.object_type_code = p_document_type
        AND poah.object_sub_type_code = p_document_subtype
        AND poah.action_code IS NOT NULL;

      d_progress := 130;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'l_count_hist', l_count_hist);
      END IF;

      IF (l_count_hist > 0)
      THEN

        d_progress := 140;

        -- Used Pro*C insert statement, as it was more accurate
        -- This SQL comes from: pocah.lpc
        -- The one in old POXPOACB.pls was incorrect.

        INSERT INTO po_action_history(
           object_id
        ,  object_type_code
        ,  object_sub_type_code
        ,  sequence_num
        ,  last_update_date
        ,  last_updated_by
        ,  creation_date
        ,  created_by
        ,  action_code
        ,  action_date
        ,  employee_id
        ,  note
        ,  object_revision_num
        ,  last_update_login
        ,  request_id
        ,  program_application_id
        ,  program_id
        ,  program_update_date
        ,  approval_path_id
        ,  offline_code
        )
        SELECT
           poah.object_id
        ,  poah.object_type_code
        ,  poah.object_sub_type_code
        ,  max(poah.sequence_num) + 1
        ,  SYSDATE
        ,  p_user_id
        ,  SYSDATE
        ,  p_user_id
        ,  p_action
        ,  SYSDATE
        ,  l_emp_id
        ,  DECODE(p_shipment_id,
                    NULL, DECODE(p_line_id, NULL, p_reason, l_rollup_msg),
                    l_rollup_msg)
        ,  max(poah.object_revision_num)
        ,  p_login_id
        ,  0
        ,  0
        ,  0
        ,  ''
        ,  0
        ,  ''
        FROM po_action_history poah
        WHERE poah.object_id = p_document_id
          AND poah.object_type_code = p_document_type
          AND poah.object_sub_type_code = p_document_subtype
          AND poah.action_code IS NOT NULL
        GROUP BY poah.object_id
              ,  poah.object_type_code
              ,  poah.object_sub_type_code
        ;

      ELSE

        d_progress := 150;

        -- only PDOI should come here
        -- so we're safe using headers_all

        SELECT max(poh.revision_num)
        INTO l_revision_num
        FROM po_headers_all poh
        WHERE poh.po_header_id = p_document_id;

        d_progress := 160;
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'l_revision_num', l_revision_num);
        END IF;

        INSERT INTO po_action_history(
           object_id
        ,  object_type_code
        ,  object_sub_type_code
        ,  sequence_num
        ,  last_update_date
        ,  last_updated_by
        ,  creation_date
        ,  created_by
        ,  action_code
        ,  action_date
        ,  employee_id
        ,  note
        ,  object_revision_num
        ,  last_update_login
        ,  request_id
        ,  program_application_id
        ,  program_id
        ,  program_update_date
        ,  approval_path_id
        ,  offline_code
        ) VALUES (
           p_document_id
        ,  p_document_type
        ,  p_document_subtype
        ,  1 --Bug 13370924 sequence_num starts at 1
        ,  SYSDATE
        ,  p_user_id
        ,  SYSDATE
        ,  p_user_id
        ,  p_action
        ,  SYSDATE
        ,  l_emp_id
        ,  DECODE(p_shipment_id,
                    NULL, DECODE(p_line_id, NULL, p_reason, l_rollup_msg),
                    l_rollup_msg)
        ,  l_revision_num
        ,  p_login_id
        ,  0
        ,  0
        ,  0
        ,  ''
        ,  0
        ,  ''
        );

      END IF;

    END IF;  -- if (not l_ctl_replaced_null_entry)

    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      l_ret_sts := 'U';
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, d_msg);
      END IF;
  END;

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

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

END handle_ctl_action_history;

-- Private Methods

PROCEDURE handle_auth_action_history(
   p_document_id        IN          NUMBER
,  p_revision_num       IN          NUMBER
,  p_document_type      IN          VARCHAR2
,  p_document_subtype   IN          VARCHAR2
,  p_action             IN          VARCHAR2
,  p_fwd_to_id          IN          NUMBER
,  p_offline_code       IN          VARCHAR2
,  p_approval_path_id   IN          NUMBER
,  p_note               IN          VARCHAR2
,  p_employee_id        IN          NUMBER
,  p_user_id            IN          NUMBER
,  p_login_id           IN          NUMBER
,  p_old_status         IN          VARCHAR2
,  x_return_status      OUT NOCOPY  VARCHAR2
)
IS

l_ret_sts      VARCHAR2(1);

d_progress        NUMBER;
d_module          VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_UTIL.handle_auth_action_history';

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_action', p_action);
    PO_LOG.proc_begin(d_module, 'p_fwd_to_id', p_fwd_to_id);
    PO_LOG.proc_begin(d_module, 'p_offline_code', p_offline_code);
    PO_LOG.proc_begin(d_module, 'p_approval_path_id', p_approval_path_id);
    PO_LOG.proc_begin(d_module, 'p_note', p_note);
    PO_LOG.proc_begin(d_module, 'p_employee_id', p_employee_id);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
    PO_LOG.proc_begin(d_module, 'p_old_status', p_old_status);
  END IF;

  d_progress := 10;

  BEGIN

    IF (p_old_status IN (PO_DOCUMENT_ACTION_PVT.g_doc_status_RETURNED,
                         PO_DOCUMENT_ACTION_PVT.g_doc_status_REJECTED,
                         PO_DOCUMENT_ACTION_PVT.g_doc_status_INCOMPLETE,
                         PO_DOCUMENT_ACTION_PVT.g_doc_status_REAPPROVAL))
    THEN

      insert_auth_action_history(
         p_document_id   => p_document_id
      ,  p_revision_num  => p_revision_num
      ,  p_document_type => p_document_type
      ,  p_document_subtype => p_document_subtype
      ,  p_action => 'SUBMIT'
      ,  p_employee_id  => p_employee_id
      ,  p_offline_code => NULL
      ,  p_approval_path_id => p_approval_path_id
      ,  p_note      => p_note
      ,  p_user_id   => p_user_id
      ,  p_login_id  => p_login_id
      ,  x_return_status => l_ret_sts
      );

      d_progress := 20;
      IF (l_ret_sts <> 'S') THEN
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      IF (p_action <> 'SUBMIT')
      THEN

        insert_auth_action_history(
           p_document_id   => p_document_id
        ,  p_revision_num  => p_revision_num
        ,  p_document_type => p_document_type
        ,  p_document_subtype => p_document_subtype
        ,  p_action => p_action
        ,  p_employee_id  => p_employee_id
        ,  p_offline_code => NULL
        ,  p_approval_path_id => p_approval_path_id
        ,  p_note      => p_note
        ,  p_user_id   => p_user_id
        ,  p_login_id  => p_login_id
        ,  x_return_status => l_ret_sts
        );

        d_progress := 30;
        IF (l_ret_sts <> 'S') THEN
          RAISE PO_CORE_S.g_early_return_exc;
        END IF;

      END IF;  -- p_action <> 'SUBMIT'

    ELSIF (p_old_status IN (PO_DOCUMENT_ACTION_PVT.g_doc_status_INPROCESS,
                            PO_DOCUMENT_ACTION_PVT.g_doc_status_PREAPPROVED))
    THEN

      update_auth_action_history(
         p_document_id     => p_document_id
      ,  p_revision_num    => p_revision_num
      ,  p_document_type   => p_document_type
      ,  p_action          => p_action
      ,  p_approval_path_id  => p_approval_path_id
      ,  p_note          => p_note
      ,  p_user_id       => p_user_id
      ,  x_return_status => l_ret_sts
      );

      d_progress := 40;
      IF (l_ret_sts <> 'S') THEN
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

    ELSIF (p_old_status IN (PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED))
    THEN

      insert_auth_action_history(
         p_document_id   => p_document_id
      ,  p_revision_num  => p_revision_num
      ,  p_document_type => p_document_type
      ,  p_document_subtype => p_document_subtype
      ,  p_action => p_action
      ,  p_employee_id  => p_employee_id
      ,  p_offline_code => NULL
      ,  p_approval_path_id => p_approval_path_id
      ,  p_note      => p_note
      ,  p_user_id   => p_user_id
      ,  p_login_id  => p_login_id
      ,  x_return_status => l_ret_sts
      );

      d_progress := 50;
      IF (l_ret_sts <> 'S') THEN
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

    END IF;  -- p_old_status IN ...

    IF (p_fwd_to_id IS NOT NULL)
    THEN

      -- bug4363736
      -- when inserting NULL action row, we should populate revision_num
      -- with the latest revision
      insert_auth_action_history(
         p_document_id   => p_document_id
      ,  p_revision_num  => p_revision_num
      ,  p_document_type => p_document_type
      ,  p_document_subtype => p_document_subtype
      ,  p_action => NULL
      ,  p_employee_id  => p_fwd_to_id
      ,  p_offline_code => p_offline_code
      ,  p_approval_path_id => NULL
      ,  p_note      => NULL
      ,  p_user_id   => p_user_id
      ,  p_login_id  => p_login_id
      ,  x_return_status => l_ret_sts
      );

      d_progress := 60;
      IF (l_ret_sts <> 'S') THEN
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      IF ((p_old_status = PO_DOCUMENT_ACTION_PVT.g_doc_status_PREAPPROVED)
        AND (p_action = PO_DOCUMENT_ACTION_PVT.g_doc_action_RESERVE))
      THEN

        update_auth_action_history(
           p_document_id     => p_document_id
        ,  p_revision_num    => p_revision_num
        ,  p_document_type   => p_document_type
        ,  p_action          => PO_DOCUMENT_ACTION_PVT.g_doc_action_APPROVE
        ,  p_approval_path_id  => p_approval_path_id
        ,  p_note          => p_note
        ,  p_user_id       => p_user_id
        ,  x_return_status => l_ret_sts
        );

        d_progress := 70;
        IF (l_ret_sts <> 'S') THEN
          RAISE PO_CORE_S.g_early_return_exc;
        END IF;

      END IF; -- p_old_status = ... and p_action =

    ELSIF ((p_old_status = PO_DOCUMENT_ACTION_PVT.g_doc_status_INPROCESS)
           AND (p_action in (PO_DOCUMENT_ACTION_PVT.g_doc_action_RESERVE,
                             PO_DOCUMENT_ACTION_PVT.g_doc_action_UNRESERVE)))
    THEN

      -- bug4363736
      -- when inserting NULL action row, we should populate revision_num
      -- with the latest revision
      insert_auth_action_history(
         p_document_id   => p_document_id
      ,  p_revision_num  => p_revision_num
      ,  p_document_type => p_document_type
      ,  p_document_subtype => p_document_subtype
      ,  p_action => NULL
      ,  p_employee_id  => p_employee_id
      ,  p_offline_code => NULL
      ,  p_approval_path_id => NULL
      ,  p_note      => NULL
      ,  p_user_id   => p_user_id
      ,  p_login_id  => p_login_id
      ,  x_return_status => l_ret_sts
      );

      d_progress := 80;
      IF (l_ret_sts <> 'S') THEN
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

    END IF;  -- p_fwd_to_id IS NOT NULL

    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      l_ret_sts := 'U';
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, 'Insert or update action history not successful');
      IF (PO_LOG.d_exc) THEN
          PO_LOG.exc(d_module, d_progress, 'Insert or update action history not successful');
      END IF;

  END;

  x_return_status := l_ret_sts;
  d_progress := 100;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

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

END handle_auth_action_history;


PROCEDURE update_doc_auth_status(
   p_document_id        IN          NUMBER
,  p_document_type      IN          VARCHAR2
,  p_document_subtype   IN          VARCHAR2
,  p_new_status         IN          VARCHAR2
,  p_user_id            IN          NUMBER
,  p_login_id           IN          NUMBER
,  x_return_status      OUT NOCOPY  VARCHAR2
)
IS

l_conterms_exist        PO_HEADERS.conterms_exist_flag%TYPE;
l_pending_signature     PO_HEADERS.pending_signature_flag%TYPE;

l_ret_sts               VARCHAR2(1);
l_err_msg               VARCHAR2(200);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);

d_progress        NUMBER;
d_module          VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_UTIL.update_doc_auth_status';

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_new_status', p_new_status);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
  END IF;

  BEGIN

    IF (p_document_type = 'REQUISITION')
    THEN

      d_progress := 10;
      --Bug 5151097 : Update Approved Date when Approved
      UPDATE PO_REQUISITION_HEADERS porh
      SET    porh.authorization_status   = p_new_status
      	  ,  porh.approved_date          = DECODE (p_new_status,
	                                   PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED,
					   SYSDATE,null)
          ,  porh.last_update_date       = SYSDATE
          ,  porh.last_updated_by        = p_user_id
          ,  porh.last_update_login      = p_login_id
      WHERE porh.requisition_header_id   = p_document_id;

      -- <REQINPOOL Start>
      d_progress := 15;

      PO_REQ_LINES_SV.update_reqs_in_pool_flag(
         x_req_line_id    =>  NULL
      ,  x_req_header_id  =>  p_document_id
      ,  x_return_status  => l_ret_sts
      );

      IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS)
      THEN
        d_progress := 17;
        l_err_msg := 'update_reqs_in_pool_flag not successful';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;
      -- <REQINPOOL End>

    ELSIF (p_document_type IN ('PO', 'PA'))
    THEN

      d_progress := 20;

	  -- PO AME Project : need to retain pending_signature_flag as E in case of
	  -- E-Signers do exists on the document
      UPDATE PO_HEADERS poh
      SET    poh.authorization_status   = p_new_status,
             poh.approved_flag = DECODE(p_new_status,
                PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED,    'Y',
                PO_DOCUMENT_ACTION_PVT.g_doc_status_REAPPROVAL,  'R',
                PO_DOCUMENT_ACTION_PVT.g_doc_status_REJECTED,    'F',
                PO_DOCUMENT_ACTION_PVT.g_doc_status_RETURNED,    'F',
                PO_DOCUMENT_ACTION_PVT.g_doc_status_INCOMPLETE,  'N',
                PO_DOCUMENT_ACTION_PVT.g_doc_status_INPROCESS,   'N',
                PO_DOCUMENT_ACTION_PVT.g_doc_status_PREAPPROVED, 'N'),
             poh.approved_date = DECODE(p_new_status,
                PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED,  SYSDATE,
                                                       poh.approved_date),
             poh.last_update_date     = SYSDATE,
             poh.last_updated_by      = p_user_id,
             poh.last_update_login   = p_login_id,
             poh.pending_signature_flag = DECODE(p_new_status,
                PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED,
                                DECODE(poh.acceptance_required_flag, 'S', 'Y',
								DECODE( poh.pending_signature_flag, 'E', 'E','N')),
                                poh.pending_signature_flag)
      WHERE poh.po_header_id = p_document_id;


      IF (p_new_status = PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED)
      THEN

        d_progress := 30;

        SELECT NVL(poh.pending_signature_flag, 'N'), NVL(poh.conterms_exist_flag, 'N')
        INTO l_pending_signature, l_conterms_exist
        FROM PO_HEADERS poh
        WHERE po_header_id = p_document_id;

        d_progress := 40;

        PO_CONTERMS_WF_PVT.UPDATE_CONTERMS_DATES(
                       p_po_header_id         => p_document_id
                    ,  p_po_doc_type          => p_document_type
                    ,  p_po_doc_subtype       => p_document_subtype
                    ,  p_conterms_exist_flag  => l_conterms_exist
                    ,  x_return_status        => l_ret_sts
                    ,  x_msg_count            => l_msg_count
                    ,  x_msg_data             => l_msg_data
                    );

        IF ((l_ret_sts = FND_API.G_RET_STS_UNEXP_ERROR)
          OR (l_ret_sts = FND_API.G_RET_STS_ERROR))
        THEN
          d_progress := 50;
          l_err_msg := 'update_conterms_dates not successful';
          RAISE PO_CORE_S.g_early_return_exc;
        END IF;

		-- PO AME Project : Check for 'E', pending_signature_flag in case of
		-- E-Signers and set doc to PreApproved status
        IF (l_pending_signature in ('Y', 'E'))
        THEN

          d_progress := 60;

          PO_DOCUMENT_ARCHIVE_GRP.ARCHIVE_PO(
                       p_api_version          => 1.0
                    ,  p_document_id          => p_document_id
                    ,  p_document_type        => p_document_type
                    ,  p_document_subtype     => p_document_subtype
                    ,  x_return_status        => l_ret_sts
                    ,  x_msg_count            => l_msg_count
                    ,  x_msg_data             => l_msg_data
                    );

          IF ((l_ret_sts = FND_API.G_RET_STS_UNEXP_ERROR)
            OR (l_ret_sts = FND_API.G_RET_STS_ERROR))
          THEN
            d_progress := 70;
            l_err_msg := 'archive_po not successful';
            RAISE PO_CORE_S.g_early_return_exc;
          END IF;

          d_progress := 80;

          -- PO AME Project : reset approved date as well.
          UPDATE PO_HEADERS poh
          SET    poh.authorization_status     = PO_DOCUMENT_ACTION_PVT.g_doc_status_PREAPPROVED
              ,  poh.approved_flag            = 'N'
              ,  poh.last_update_date         = SYSDATE
              ,  poh.last_updated_by          = p_user_id
              ,  poh.last_update_login        = p_login_id
			  ,  poh.approved_date            = NULL
          WHERE poh.po_header_id = p_document_id;


        END IF;  -- l_pending_signature in ('Y' , 'E')

        d_progress := 90;

        --call the PO_UPDATE_DATE_PKG to update the promised date based on BPA lead time.
        IF (l_pending_signature NOT IN ('Y', 'E')) THEN
          PO_UPDATE_DATE_PKG.update_promised_date_lead_time (p_document_id);
        END IF ;

        d_progress := 95;

        UPDATE PO_LINE_LOCATIONS_ALL poll
        SET    poll.approved_flag             = 'Y'
            ,  poll.approved_date             = SYSDATE
            ,  poll.last_update_date          = SYSDATE
            ,  poll.last_updated_by           = p_user_id
            ,  poll.last_update_login         = p_login_id
        WHERE poll.po_header_id = p_document_id
          AND poll.po_release_id IS NULL
          AND NVL(poll.approved_flag, 'N') <> 'Y'
          AND EXISTS ( SELECT 'PO Does not require signature'
                       FROM PO_HEADERS_ALL poh
                       WHERE poh.po_header_id = poll.po_header_id
                         AND NVL(poh.pending_signature_flag, 'N') NOT IN ('Y','E'));

      END IF;  -- p_new_status = g_doc_status_APPROVED

      IF (p_new_status = PO_DOCUMENT_ACTION_PVT.g_doc_status_REAPPROVAL)
      THEN

        d_progress := 100;

        UPDATE PO_LINE_LOCATIONS_ALL poll
        SET    poll.approved_flag             = 'R'
            ,  poll.last_update_date          = SYSDATE
            ,  poll.last_updated_by           = p_user_id
            ,  poll.last_update_login         = p_login_id
        WHERE poll.po_header_id = p_document_id
          AND poll.po_release_id IS NULL
          AND NVL(poll.approved_flag, 'N') = 'Y';

      END IF;  -- p_new_status = g_doc_status_REAPPROVAL

    ELSIF (p_document_type = 'RELEASE')
    THEN

      d_progress := 110;

      UPDATE PO_RELEASES por
      SET    por.authorization_status   = p_new_status,
             por.approved_flag = DECODE(p_new_status,
                PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED,    'Y',
                PO_DOCUMENT_ACTION_PVT.g_doc_status_REAPPROVAL,  'R',
                PO_DOCUMENT_ACTION_PVT.g_doc_status_REJECTED,    'F',
                PO_DOCUMENT_ACTION_PVT.g_doc_status_RETURNED,    'F',
                PO_DOCUMENT_ACTION_PVT.g_doc_status_INCOMPLETE,  'N',
                PO_DOCUMENT_ACTION_PVT.g_doc_status_INPROCESS,   'N',
                PO_DOCUMENT_ACTION_PVT.g_doc_status_PREAPPROVED, 'N'),
             por.approved_date = DECODE(p_new_status,
                PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED,  SYSDATE,
                                                       por.approved_date),
             por.last_update_date     = SYSDATE,
             por.last_updated_by      = p_user_id,
             por.last_update_login    = p_login_id
      WHERE por.po_release_id = p_document_id;

      IF (p_new_status = PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED)
      THEN

        d_progress := 120;

        UPDATE PO_LINE_LOCATIONS_ALL poll
        SET    poll.approved_flag             = 'Y'
            ,  poll.approved_date             = SYSDATE
            ,  poll.last_update_date          = SYSDATE
            ,  poll.last_updated_by           = p_user_id
            ,  poll.last_update_login         = p_login_id
        WHERE poll.po_release_id = p_document_id
          AND NVL(poll.approved_flag, 'N') <> 'Y';

      END IF;  -- p_new_status = g_doc_status_APPROVED

      IF (p_new_status = PO_DOCUMENT_ACTION_PVT.g_doc_status_REAPPROVAL)
      THEN

        d_progress := 130;

        UPDATE PO_LINE_LOCATIONS_ALL poll
        SET    poll.approved_flag             = 'R'
            ,  poll.last_update_date          = SYSDATE
            ,  poll.last_updated_by           = p_user_id
            ,  poll.last_update_login         = p_login_id
        WHERE poll.po_release_id = p_document_id
          AND NVL(poll.approved_flag, 'N') = 'Y';

      END IF;  -- p_new_status = g_doc_status_REAPPROVAL

    ELSE

      d_progress := 140;
      l_err_msg := 'Bad Document Type';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;  -- p_document_type = 'REQUISITION'

    d_progress := 150;
    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      l_ret_sts := 'U';
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, l_err_msg);
      IF (PO_LOG.d_exc) THEN
          PO_LOG.exc(d_module, d_progress, l_err_msg);
      END IF;
  END;


  x_return_status := l_ret_sts;
  d_progress := 200;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

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

END update_doc_auth_status;


-- Equivalent to: podusnotif
-- Does not appear to be used anymore
-- Translated just in case
PROCEDURE update_doc_notifications(
   p_document_id        IN         NUMBER
,  p_document_type      IN         VARCHAR2
,  p_document_subtype   IN         VARCHAR2
,  p_notify_action      IN         VARCHAR2
,  p_notify_employee    IN         NUMBER
,  p_doc_creation_date  IN         DATE
,  p_user_id            IN         NUMBER
,  p_login_id           IN         NUMBER
,  x_return_status      OUT NOCOPY VARCHAR2
)
IS

d_progress        NUMBER;
d_module          VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_UTIL.update_doc_notifications';

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_notify_action', p_notify_action);
    PO_LOG.proc_begin(d_module, 'p_notify_employee', p_notify_employee);
    PO_LOG.proc_begin(d_module, 'p_doc_creation_date', p_doc_creation_date);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
  END IF;

  d_progress := 10;

  DELETE FROM PO_NOTIFICATIONS pon
  WHERE pon.object_type_lookup_code = DECODE(p_document_type,
                                       'PO', p_document_subtype,
                                       'PA', p_document_subtype,
                                             p_document_type)
    AND pon.object_id = p_document_id
    AND pon.employee_id > -1;


  IF (p_notify_action IS NOT NULL)
  THEN

    d_progress := 20;

    INSERT INTO PO_NOTIFICATIONS(
        employee_id
     ,  object_type_lookup_code
     ,  object_id
     ,  last_update_date
     ,  last_updated_by
     ,  last_update_login
     ,  creation_date
     ,  created_by
     ,  object_creation_date
     ,  action_lookup_code
     )
     VALUES(
        p_notify_employee
     ,  DECODE(p_document_type,
                  'PO', p_document_subtype,
                  'PA', p_document_subtype,
                        p_document_type)
     ,  p_document_id
     ,  SYSDATE
     ,  p_user_id
     ,  p_login_id
     ,  SYSDATE
     ,  p_user_id
     ,  SYSDATE
     ,  p_notify_action
     );

  END IF;  -- p_notify_action IS NOT NULL

  x_return_status := 'S';
  d_progress := 100;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

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

END update_doc_notifications;



PROCEDURE insert_auth_action_history(
   p_document_id        IN          NUMBER
,  p_revision_num       IN          NUMBER
,  p_document_type      IN          VARCHAR2
,  p_document_subtype   IN          VARCHAR2
,  p_action             IN          VARCHAR2
,  p_employee_id        IN          NUMBER
,  p_offline_code       IN          VARCHAR2
,  p_approval_path_id   IN          NUMBER
,  p_note               IN          VARCHAR2
,  p_user_id            IN          NUMBER
,  p_login_id           IN          NUMBER
,  x_return_status      OUT NOCOPY  VARCHAR2
)
IS

l_sequence_num   PO_ACTION_HISTORY.sequence_num%TYPE;

d_progress        NUMBER;
d_module          VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_UTIL.insert_auth_action_history';

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_revision_num', p_revision_num);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_action', p_action);
    PO_LOG.proc_begin(d_module, 'p_employee_id', p_employee_id);
    PO_LOG.proc_begin(d_module, 'p_offline_code', p_offline_code);
    PO_LOG.proc_begin(d_module, 'p_approval_path_id', p_approval_path_id);
    PO_LOG.proc_begin(d_module, 'p_note', p_note);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
  END IF;

  d_progress := 10;


  SELECT max(poah.sequence_num) + 1
  INTO l_sequence_num
  FROM PO_ACTION_HISTORY poah
  WHERE poah.object_type_code = p_document_type
    AND poah.object_id = p_document_id;


  -- <Bug 4118145 - Issue 1 Start>

  d_progress := 15;

  IF (l_sequence_num IS NULL)
  THEN
    l_sequence_num := 1; --Bug 13370924
  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'l_sequence_num', l_sequence_num);
  END IF;
  -- <Bug 4118145 - Issue 1 End>

  d_progress := 20;

  INSERT INTO PO_ACTION_HISTORY
  (  object_id
  ,  object_type_code
  ,  object_sub_type_code
  ,  sequence_num
  ,  last_update_date
  ,  last_updated_by
  ,  creation_date
  ,  created_by
  ,  action_code
  ,  action_date
  ,  employee_id
  ,  note
  ,  object_revision_num
  ,  last_update_login
  ,  request_id
  ,  program_application_id
  ,  program_id
  ,  program_update_date
  ,  approval_path_id
  ,  offline_code
  )
  VALUES
  (  p_document_id
  ,  p_document_type
  ,  p_document_subtype
  ,  l_sequence_num
  ,  SYSDATE
  ,  p_user_id
  ,  SYSDATE
  ,  p_user_id
  ,  p_action
  ,  DECODE(p_action, '', to_date(NULL), SYSDATE)
  ,  p_employee_id
  ,  p_note
  ,  p_revision_num
  ,  p_login_id
  ,  0
  ,  0
  ,  0
  ,  ''
  ,  p_approval_path_id
  ,  p_offline_code
  );

  x_return_status := 'S';
  d_progress := 100;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

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

END insert_auth_action_history;

PROCEDURE update_auth_action_history(
   p_document_id        IN          NUMBER
,  p_revision_num       IN          NUMBER
,  p_document_type      IN          VARCHAR2
,  p_action             IN          VARCHAR2
,  p_approval_path_id   IN          NUMBER
,  p_note               IN          VARCHAR2
,  p_user_id            IN          NUMBER
,  x_return_status      OUT NOCOPY  VARCHAR2
)
IS

d_progress        NUMBER;
d_module          VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_UTIL.update_auth_action_history';
d_max_sequence_num    NUMBER;

BEGIN

  d_progress := 0;

--bug 18701804 begin
-- bug 19777779,add a function nvl to avoid exception when there are no action
-- history for PDOI auto-approved document.
  SELECT nvl(MAX(sequence_num),0)
  INTO d_max_sequence_num
  FROM PO_ACTION_HISTORY
  WHERE object_id = p_document_id
    AND object_type_code = p_document_type;

  d_progress := 1;


--bug 18701804 end

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_revision_num', p_revision_num);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_action', p_action);
    PO_LOG.proc_begin(d_module, 'p_approval_path_id', p_approval_path_id);
    PO_LOG.proc_begin(d_module, 'p_note', p_note);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'd_max_sequence_num', d_max_sequence_num); --bug 18701804
  END IF;

  d_progress := 10;

  UPDATE PO_ACTION_HISTORY
  SET   action_code           = p_action
      , action_date           = SYSDATE
      , note                  = p_note
      , last_updated_by       = p_user_id
      , last_update_date      = SYSDATE
      , object_revision_num   = p_revision_num
      , approval_path_id      = p_approval_path_id
  WHERE object_id = p_document_id
    AND object_type_code = p_document_type
    AND sequence_num = d_max_sequence_num; --bug 18701804


  x_return_status := 'S';
  d_progress := 100;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

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

END update_auth_action_history;


END PO_DOCUMENT_ACTION_UTIL;

/
