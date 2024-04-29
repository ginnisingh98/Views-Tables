--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_ACTION_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_ACTION_CHECK" AS
-- $Header: POXDACKB.pls 120.8.12010000.7 2014/05/04 06:09:38 mazhong ship $

-- Private package constants

g_pkg_name CONSTANT varchar2(30) := 'PO_DOCUMENT_ACTION_CHECK';
g_log_head CONSTANT VARCHAR2(50) := 'po.plsql.'|| g_pkg_name || '.';

g_chktype_DOC_TOTAL_LIMIT CONSTANT VARCHAR2(20) := 'DOC TOTAL LIMIT';
g_chktype_ACCOUNT_LIMIT CONSTANT VARCHAR2(20) := 'ACCOUNT LIMIT';
g_chktype_ITEM_LIMIT CONSTANT VARCHAR2(20) := 'ITEM LIMIT';
g_chktype_CATEGORY_LIMIT CONSTANT VARCHAR2(20) := 'CATEGORY LIMIT';
g_chktype_LOCATION_LIMIT CONSTANT VARCHAR2(20) := 'LOCATION LIMIT';

g_chktype_ACCOUNT_EXISTS CONSTANT VARCHAR2(20) := 'ACCOUNT EXISTS';

 /*=======================================================================+
 | FILENAME
 |   POXDACKB.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package:  PO_DOCUMENT_ACTION_CHECK
 |
 | NOTES
 | MODIFIED    (MM/DD/YY)
 | Xiao Lv      04/14/2009     Add code for PO notification of Indian Localization
 *=======================================================================*/

-- Private package types
TYPE AUTH_CHECK_TYPES_REC IS RECORD
 (
    check_accounts         BOOLEAN,
    check_items            BOOLEAN,
    check_item_categories  BOOLEAN,
    check_locations        BOOLEAN,
    check_doc_totals       BOOLEAN
 );

TYPE AUTH_CHECK_IDS_REC IS RECORD
 (
    object_id              NUMBER,
    position_id            NUMBER,
    job_id                 NUMBER,
    ctl_function_id        NUMBER,
    fsp_org_id             NUMBER,
    coa_id                 NUMBER,
    item_cat_struct_id     NUMBER
 );

-- Forward declare private methods

PROCEDURE authority_checks_setup(
   p_action_to_verify    IN     VARCHAR2
,  p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_employee_id         IN     NUMBER
,  x_auth_checks_to_do   OUT NOCOPY AUTH_CHECK_TYPES_REC
,  x_auth_check_ids      OUT NOCOPY AUTH_CHECK_IDS_REC
,  x_using_positions     OUT NOCOPY BOOLEAN
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_functional_error    OUT NOCOPY VARCHAR2
);


PROCEDURE check_doc_total_limit(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_session_gt_key      IN     NUMBER
,  p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_authorized_yn       OUT NOCOPY VARCHAR2
);

PROCEDURE check_account_limit(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_session_gt_key      IN     NUMBER
,  p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_authorized_yn       OUT NOCOPY VARCHAR2
);

PROCEDURE check_account_exists(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_session_gt_key      IN     NUMBER
,  p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_authorized_yn       OUT NOCOPY VARCHAR2
);

PROCEDURE check_item_limit(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_session_gt_key      IN     NUMBER
,  p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_authorized_yn       OUT NOCOPY VARCHAR2
);

PROCEDURE check_category_limit(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_session_gt_key      IN     NUMBER
,  p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_authorized_yn       OUT NOCOPY VARCHAR2
);

PROCEDURE check_location_limit(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_session_gt_key      IN     NUMBER
,  p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_authorized_yn       OUT NOCOPY VARCHAR2
);

PROCEDURE get_range_limit_sql(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_check_type          IN     VARCHAR2
,  p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_range_check_sql     OUT NOCOPY VARCHAR2
);

PROCEDURE get_range_exists_sql(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_check_type          IN     VARCHAR2
,  p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_range_check_sql     OUT NOCOPY VARCHAR2
);

PROCEDURE get_flex_where_sql(
   p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  p_check_type          IN     VARCHAR2
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_flex_sql            OUT NOCOPY VARCHAR2
);

PROCEDURE populate_session_gt(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  x_session_gt_key      OUT NOCOPY NUMBER
,  x_return_status       OUT NOCOPY VARCHAR2
);

PROCEDURE decode_result(
   p_document_type IN VARCHAR2
,  p_result_val    IN NUMBER
,  x_authorized_yn OUT NOCOPY VARCHAR2
);

-- Public methods


PROCEDURE approve_status_check(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
)
IS

d_progress       NUMBER;
d_module         VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CHECK.approve_status_check';

l_allowed_states  PO_DOCUMENT_ACTION_UTIL.doc_state_rec_type;
l_doc_state_ok    BOOLEAN;
l_ret_sts         VARCHAR2(1);
d_msg             VARCHAR2(200);

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

    l_allowed_states.auth_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_status_INPROCESS;
    l_allowed_states.auth_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_status_PREAPPROVED;
    l_allowed_states.auth_states(3) := PO_DOCUMENT_ACTION_PVT.g_doc_status_INCOMPLETE;
    l_allowed_states.auth_states(4) := PO_DOCUMENT_ACTION_PVT.g_doc_status_REJECTED;
    l_allowed_states.auth_states(5) := PO_DOCUMENT_ACTION_PVT.g_doc_status_RETURNED;
    l_allowed_states.auth_states(6) := PO_DOCUMENT_ACTION_PVT.g_doc_status_REAPPROVAL;
    l_allowed_states.hold_flag := 'N';
    l_allowed_states.frozen_flag := 'N';
    l_allowed_states.closed_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED;
    l_allowed_states.closed_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_OPEN;
    l_allowed_states.fully_reserved_flag := NULL;

    d_progress := 20;

    l_doc_state_ok := PO_DOCUMENT_ACTION_UTIL.check_doc_state(
                         p_document_id => p_action_ctl_rec.document_id
                      ,  p_document_type => p_action_ctl_rec.document_type
                      ,  p_allowed_states => l_allowed_states
                      ,  x_return_status  => l_ret_sts
                      );

    IF (l_ret_sts <> 'S')
    THEN

      d_progress := 30;
      d_msg := 'check_doc_state not successful';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 40;

    IF (l_doc_state_ok) THEN

      d_progress := 50;
      p_action_ctl_rec.return_code := NULL;

    ELSE

      d_progress := 60;
      p_action_ctl_rec.return_code := 'STATE_FAILED';

    END IF; -- if l_doc_state_ok

    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      l_ret_sts := 'U';
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, d_msg);
      END IF;
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

END approve_status_check;

PROCEDURE reject_status_check(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
)
IS

d_progress       NUMBER;
d_module         VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CHECK.reject_status_check';

l_allowed_states  PO_DOCUMENT_ACTION_UTIL.doc_state_rec_type;
l_doc_state_ok    BOOLEAN;
l_ret_sts         VARCHAR2(1);
d_msg             VARCHAR2(200);

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

    l_allowed_states.auth_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_status_INPROCESS;
    l_allowed_states.auth_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_status_PREAPPROVED;
    l_allowed_states.hold_flag := 'N';
    l_allowed_states.frozen_flag := 'N';
    l_allowed_states.closed_states(1) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_CLOSED;
    l_allowed_states.closed_states(2) := PO_DOCUMENT_ACTION_PVT.g_doc_closed_sts_OPEN;
    l_allowed_states.fully_reserved_flag := NULL;

    d_progress := 20;

    l_doc_state_ok := PO_DOCUMENT_ACTION_UTIL.check_doc_state(
                         p_document_id => p_action_ctl_rec.document_id
                      ,  p_document_type => p_action_ctl_rec.document_type
                      ,  p_allowed_states => l_allowed_states
                      ,  x_return_status  => l_ret_sts
                      );

    IF (l_ret_sts <> 'S')
    THEN

      d_progress := 30;
      d_msg := 'check_doc_state not successful';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 40;

    IF (l_doc_state_ok) THEN

      d_progress := 50;
      p_action_ctl_rec.return_code := NULL;

    ELSE

      d_progress := 60;
      p_action_ctl_rec.return_code := 'STATE_FAILED';

    END IF; -- if l_doc_state_ok

    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      l_ret_sts := 'U';
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, d_msg);
      END IF;
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
END reject_status_check;

PROCEDURE authority_check(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
)
IS

d_progress       NUMBER;
d_module         VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CHECK.authority_check';

l_authority_verified   VARCHAR2(1);
l_action_to_verify     VARCHAR2(30) := PO_DOCUMENT_ACTION_PVT.g_doc_action_APPROVE;
l_auth_checks_to_do    AUTH_CHECK_TYPES_REC;
l_auth_check_ids       AUTH_CHECK_IDS_REC;
l_using_positions      BOOLEAN;

l_session_gt_key       NUMBER;

l_ret_sts  VARCHAR2(1);
d_msg      VARCHAR2(200);

l_authorized_yn  VARCHAR2(1);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_id', p_action_ctl_rec.document_id);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_type', p_action_ctl_rec.document_type);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.document_subtype', p_action_ctl_rec.document_subtype);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.action', p_action_ctl_rec.action);
    PO_LOG.proc_begin(d_module, 'p_action_ctl_rec.employee_id', p_action_ctl_rec.employee_id);
  END IF;

  BEGIN

    d_progress := 10;

    authority_checks_setup(
       p_action_to_verify  => l_action_to_verify
    ,  p_document_id       => p_action_ctl_rec.document_id
    ,  p_document_type     => p_action_ctl_rec.document_type
    ,  p_document_subtype  => p_action_ctl_rec.document_subtype
    ,  p_employee_id       => p_action_ctl_rec.employee_id
    ,  x_auth_checks_to_do => l_auth_checks_to_do
    ,  x_auth_check_ids    => l_auth_check_ids
    ,  x_using_positions   => l_using_positions
    ,  x_return_status     => l_ret_sts
    ,  x_functional_error  => p_action_ctl_rec.functional_error
    );

    IF (l_ret_sts = 'U')
    THEN
      d_progress := 20;
      d_msg := 'unexpected error in authority_checks_setup';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    IF (l_ret_sts = 'E')
    THEN
      d_progress := 30;
      d_msg := 'functional error in authority_checks_setup';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 40;

    populate_session_gt(
       p_document_id       => p_action_ctl_rec.document_id
    ,  p_document_type     => p_action_ctl_rec.document_type
    ,  p_document_subtype  => p_action_ctl_rec.document_subtype
    ,  x_session_gt_key    => l_session_gt_key
    ,  x_return_status     => l_ret_sts
    );

    IF (l_ret_sts <> 'S')
    THEN
      d_progress := 50;
      l_ret_sts := 'U';
      d_msg := 'populate_session_gt not successful';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 60;

    IF (l_auth_checks_to_do.check_doc_totals) THEN

      d_progress := 70;

      check_doc_total_limit(
         p_document_id        => p_action_ctl_rec.document_id
      ,  p_document_type      => p_action_ctl_rec.document_type
      ,  p_document_subtype   => p_action_ctl_rec.document_subtype
      ,  p_session_gt_key     => l_session_gt_key
      ,  p_auth_check_ids     => l_auth_check_ids
      ,  x_return_status      => l_ret_sts
      ,  x_authorized_yn      => l_authorized_yn
      );

      IF (l_ret_sts <> 'S')
      THEN
        d_progress := 80;
        d_msg := 'check_doc_total_limit not successful';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      IF (l_authorized_yn <> 'Y')
      THEN
        d_progress := 90;
        d_msg := 'functional error in check_doc_total_limit';
        p_action_ctl_rec.functional_error := fnd_message.get_string('PO', 'PO_AUT_DOC_TOT_FAIL');
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      d_progress := 100;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Passed document total check.');
      END IF;

    END IF;  -- IF check_doc_totals

    IF (l_auth_checks_to_do.check_accounts) THEN

      d_progress := 110;

      check_account_exists(
         p_document_id        => p_action_ctl_rec.document_id
      ,  p_document_type      => p_action_ctl_rec.document_type
      ,  p_document_subtype   => p_action_ctl_rec.document_subtype
      ,  p_session_gt_key     => l_session_gt_key
      ,  p_auth_check_ids     => l_auth_check_ids
      ,  x_return_status      => l_ret_sts
      ,  x_authorized_yn      => l_authorized_yn
      );

      IF (l_ret_sts <> 'S')
      THEN
        d_progress := 120;
        d_msg := 'check_account_exists not successful';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      IF (l_authorized_yn <> 'Y')
      THEN
        d_progress := 130;
        d_msg := 'functional error in check_account_exists';
        p_action_ctl_rec.functional_error := fnd_message.get_string('PO', 'PO_AUT_ACCOUNT_NOT_EXISTS');
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      d_progress := 140;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Passed account exists check.');
      END IF;

      check_account_limit(
         p_document_id        => p_action_ctl_rec.document_id
      ,  p_document_type      => p_action_ctl_rec.document_type
      ,  p_document_subtype   => p_action_ctl_rec.document_subtype
      ,  p_session_gt_key     => l_session_gt_key
      ,  p_auth_check_ids     => l_auth_check_ids
      ,  x_return_status      => l_ret_sts
      ,  x_authorized_yn      => l_authorized_yn
      );

      IF (l_ret_sts <> 'S')
      THEN
        d_progress := 150;
        d_msg := 'check_account_limit not successful';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      IF (l_authorized_yn <> 'Y')
      THEN
        d_progress := 160;
        d_msg := 'functional error in check_account_limit';
        p_action_ctl_rec.functional_error := fnd_message.get_string('PO', 'PO_AUT_ACCOUNT_LIMIT_FAIL');
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      d_progress := 170;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Passed account limit check.');
      END IF;

    END IF;  -- IF check_accounts

    IF (l_auth_checks_to_do.check_locations) THEN

      d_progress := 180;

      check_location_limit(
         p_document_id        => p_action_ctl_rec.document_id
      ,  p_document_type      => p_action_ctl_rec.document_type
      ,  p_document_subtype   => p_action_ctl_rec.document_subtype
      ,  p_session_gt_key     => l_session_gt_key
      ,  p_auth_check_ids     => l_auth_check_ids
      ,  x_return_status      => l_ret_sts
      ,  x_authorized_yn      => l_authorized_yn
      );

      IF (l_ret_sts <> 'S')
      THEN
        d_progress := 190;
        d_msg := 'check_location_limit not successful';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      IF (l_authorized_yn <> 'Y')
      THEN
        d_progress := 200;
        d_msg := 'functional error in check_location_limit';
        p_action_ctl_rec.functional_error := fnd_message.get_string('PO', 'PO_AUT_LOC_LIMIT_FAIL');
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      d_progress := 210;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Passed location limit check.');
      END IF;

    END IF;  -- IF check_locations

    IF (l_auth_checks_to_do.check_items) THEN

      d_progress := 220;

      check_item_limit(
         p_document_id        => p_action_ctl_rec.document_id
      ,  p_document_type      => p_action_ctl_rec.document_type
      ,  p_document_subtype   => p_action_ctl_rec.document_subtype
      ,  p_session_gt_key     => l_session_gt_key
      ,  p_auth_check_ids     => l_auth_check_ids
      ,  x_return_status      => l_ret_sts
      ,  x_authorized_yn      => l_authorized_yn
      );

      IF (l_ret_sts <> 'S')
      THEN
        d_progress := 230;
        d_msg := 'check_item_limit not successful';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      IF (l_authorized_yn <> 'Y')
      THEN
        d_progress := 240;
        d_msg := 'functional error in check_item_limit';
        p_action_ctl_rec.functional_error := fnd_message.get_string('PO', 'PO_AUT_ITEM_LIMIT_FAIL');
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      d_progress := 250;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Passed item limit check.');
      END IF;

    END IF;  -- IF check_items

    IF (l_auth_checks_to_do.check_item_categories) THEN

      d_progress := 260;

      check_category_limit(
         p_document_id        => p_action_ctl_rec.document_id
      ,  p_document_type      => p_action_ctl_rec.document_type
      ,  p_document_subtype   => p_action_ctl_rec.document_subtype
      ,  p_session_gt_key     => l_session_gt_key
      ,  p_auth_check_ids     => l_auth_check_ids
      ,  x_return_status      => l_ret_sts
      ,  x_authorized_yn      => l_authorized_yn
      );

      IF (l_ret_sts <> 'S')
      THEN
        d_progress := 270;
        d_msg := 'check_category_limit not successful';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      IF (l_authorized_yn <> 'Y')
      THEN
        d_progress := 280;
        d_msg := 'functional error in check_category_limit';
        p_action_ctl_rec.functional_error := fnd_message.get_string('PO', 'PO_AUT_CATEGORY_LIMIT_FAIL');
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      d_progress := 290;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Passed category limit check.');
      END IF;

    END IF;  -- IF check_locations

    d_progress := 300;
    l_authority_verified := 'Y';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
      IF ((l_ret_sts = 'U') and (PO_LOG.d_exc)) THEN
        PO_LOG.exc(d_module, d_progress, d_msg);
      END IF;
      IF (l_ret_sts = 'E' OR (NVL(l_authorized_yn, 'N') <> 'Y')) THEN
        PO_LOG.stmt(d_module, d_progress, 'Error: ' || d_msg);
        l_authority_verified := 'N';
      END IF;
  END;

  IF (NVL(l_authority_verified,'X') = 'N')
  THEN
    p_action_ctl_rec.return_code := 'AUTHORIZATION_FAILED';
  ELSE
    p_action_ctl_rec.return_code := NULL;
  END IF;

  p_action_ctl_rec.return_status := l_ret_sts;
  IF (p_action_ctl_rec.return_status = 'E') THEN
    p_action_ctl_rec.return_status := 'S';
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_status', p_action_ctl_rec.return_status);
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.return_code', p_action_ctl_rec.return_code);
    PO_LOG.proc_end(d_module, 'p_action_ctl_rec.functional_error', p_action_ctl_rec.functional_error);
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

END authority_check;


PROCEDURE authority_checks_setup(
   p_action_to_verify    IN     VARCHAR2
,  p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_employee_id         IN     NUMBER
,  x_auth_checks_to_do   OUT NOCOPY AUTH_CHECK_TYPES_REC
,  x_auth_check_ids      OUT NOCOPY AUTH_CHECK_IDS_REC
,  x_using_positions     OUT NOCOPY BOOLEAN
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_functional_error    OUT NOCOPY VARCHAR2
)
IS

d_progress       NUMBER;
d_module         VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CHECK.authority_checks_setup';

l_ret_sts      VARCHAR2(1);
d_msg      VARCHAR2(200);

l_emp_flag       BOOLEAN;
l_emp_id         PER_EMPLOYEES_CURRENT_X.employee_id%TYPE;
l_emp_name       PER_EMPLOYEES_CURRENT_X.full_name%TYPE;
l_emp_loc_id     PER_EMPLOYEES_CURRENT_X.location_id%TYPE;
l_emp_loc_code   HR_LOCATIONS.location_code%TYPE;
l_emp_is_buyer   BOOLEAN;

l_using_pos_str  FINANCIALS_SYSTEM_PARAMETERS.use_positions_flag%TYPE;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_action_to_verify', p_action_to_verify);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_employee_id', p_employee_id);
  END IF;

  d_progress := 10;

  BEGIN

    SELECT structure_id
    INTO x_auth_check_ids.item_cat_struct_id
    FROM mtl_default_sets_view mfsv
    WHERE mfsv.functional_area_id = 2;

    d_progress := 15;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'x_auth_check_ids.item_cat_struct_id', x_auth_check_ids.item_cat_struct_id);
    END IF;

    IF (p_employee_id IS NULL)
    THEN

      d_progress := 20;

      PO_DOCUMENT_ACTION_UTIL.get_employee_info(
         p_user_id       =>  FND_GLOBAL.USER_ID
      ,  x_return_status => l_ret_sts
      ,  x_employee_flag => l_emp_flag
      ,  x_employee_id   => l_emp_id
      ,  x_employee_name => l_emp_name
      ,  x_location_id   => l_emp_loc_id
      ,  x_location_code => l_emp_loc_code
      ,  x_is_buyer_flag => l_emp_is_buyer
      );

      IF (l_ret_sts <> 'S')
      THEN
        d_progress := 20;
        l_ret_sts := 'U';
        d_msg := 'get_employee_id not successful';
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      IF (NOT l_emp_flag)
      THEN
        d_progress := 30;
        l_ret_sts := 'E';
        d_msg := 'No employee flag returned';
        x_functional_error := fnd_message.get_string('PO', 'PO_ALL_NO_EMP_ID_FOR_USER_ID');
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

    ELSE

      d_progress := 40;

      PO_EMPLOYEES_SV.get_employee_name(
         x_emp_id    => p_employee_id
      ,  x_emp_name  => l_emp_name
      );

      l_emp_id := p_employee_id;

    END IF;  -- p_employee_id IS NULL

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_emp_id', l_emp_id);
      PO_LOG.stmt(d_module, d_progress, 'l_emp_name', l_emp_name);
    END IF;

    d_progress := 50;

    SELECT glsob.chart_of_accounts_id
        ,  NVL(fsp.use_positions_flag, 'N')
        ,  fsp.inventory_organization_id
    INTO x_auth_check_ids.coa_id
      ,  l_using_pos_str
      ,  x_auth_check_ids.fsp_org_id
    FROM financials_system_parameters fsp,
         gl_sets_of_books glsob
    WHERE fsp.set_of_books_id = glsob.set_of_books_id;

    d_progress := 60;

    IF (l_using_pos_str = 'Y')
    THEN
      x_using_positions := TRUE;
    ELSE
      x_using_positions := FALSE;
    END IF;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_using_pos_str', l_using_pos_str);
      PO_LOG.stmt(d_module, d_progress, 'x_using_positions', x_using_positions);
      PO_LOG.stmt(d_module, d_progress, 'x_auth_check_ids.fsp_org_id', x_auth_check_ids.fsp_org_id);
      PO_LOG.stmt(d_module, d_progress, 'x_auth_check_ids.coa_id', x_auth_check_ids.coa_id);
    END IF;

    IF (x_using_positions)
    THEN

      d_progress := 70;
      --Bug18652153, add per system status filtering to avoid multiple assignment case
      --'ACTIVE_ASSIGN' for employee assignment
      --'ACTIVE_CWK' for contingent worker
      SELECT nvl(paf.position_id, 0)
      INTO x_auth_check_ids.position_id
      FROM PER_ALL_ASSIGNMENTS_F paf   -- <BUG 6615913>
      WHERE paf.person_id = l_emp_id
        AND paf.assignment_type IN  ('E','C')    --R12 CWK enhancement
        AND paf.primary_flag = 'Y'
        AND trunc(sysdate) BETWEEN paf.effective_start_date AND paf.effective_end_date
        and exists
       (select 1
          from per_assignment_status_types pst
         where pst.assignment_status_type_id = paf.assignment_status_type_id
           and pst.per_system_status in ('ACTIVE_ASSIGN', 'ACTIVE_CWK'));

      d_progress := 80;
      IF (x_auth_check_ids.position_id = 0)
      THEN
        d_progress := 90;
        l_ret_sts := 'E';
        d_msg := 'position_id is 0';
        x_functional_error := fnd_message.get_string('PO', 'PO_ALL_NO_POSITION_ID');
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      x_auth_check_ids.job_id := NULL;

    ELSE

      d_progress := 90;

      SELECT nvl(paf.job_id, 0)
      INTO x_auth_check_ids.job_id
      FROM PER_ALL_ASSIGNMENTS_F paf  -- <BUG 6615913>
      WHERE paf.person_id = l_emp_id
        AND paf.assignment_type IN  ('E','C')    --R12 CWK enhancement
        AND paf.primary_flag = 'Y'
        AND trunc(sysdate) BETWEEN paf.effective_start_date AND paf.effective_end_date;

      d_progress := 100;

      IF (x_auth_check_ids.job_id = 0)
      THEN
        d_progress := 110;
        l_ret_sts := 'E';
        d_msg := 'job_id is 0';
        x_functional_error := fnd_message.get_string('PO', 'PO_ALL_NO_JOB_ID');
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      x_auth_check_ids.position_id := NULL;

    END IF;  -- if x_using_positions

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'x_auth_check_ids.position_id', x_auth_check_ids.position_id);
      PO_LOG.stmt(d_module, d_progress, 'x_auth_check_ids.job_id', x_auth_check_ids.job_id);
    END IF;

    d_progress := 120;

    BEGIN

      SELECT pocf.control_function_id
      INTO x_auth_check_ids.ctl_function_id
      FROM po_control_functions pocf
      WHERE pocf.document_type_code = p_document_type
        AND pocf.document_subtype = p_document_subtype
        AND pocf.action_type_code = p_action_to_verify
        AND pocf.enabled_flag = 'Y';

    EXCEPTION
      WHEN no_data_found THEN
        d_progress := 125;
        l_ret_sts := 'E';
        d_msg := 'no control function id available';
        x_functional_error := fnd_message.get_string('PO', 'PO_ALL_NO_CONTROL_FUCNTION_ID');
        RAISE PO_CORE_S.g_early_return_exc;
    END;

    d_progress := 130;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'x_auth_check_ids.ctl_function_id', x_auth_check_ids.ctl_function_id);
    END IF;

    x_auth_check_ids.object_id := p_document_id;

    d_progress := 140;

    IF (p_document_type IN ('REQUISITION', 'PO', 'RELEASE'))
    THEN

      -- all checks
      d_progress := 150;
      x_auth_checks_to_do.check_accounts := TRUE;
      x_auth_checks_to_do.check_items := TRUE;
      x_auth_checks_to_do.check_item_categories := TRUE;
      x_auth_checks_to_do.check_locations := TRUE;
      x_auth_checks_to_do.check_doc_totals := TRUE;

    ELSIF ((p_document_type = 'PA') and (p_document_subtype = 'BLANKET'))
    THEN

      -- item only checks, plus doc total check
      d_progress := 160;
      x_auth_checks_to_do.check_accounts := FALSE;
      x_auth_checks_to_do.check_items := TRUE;
      x_auth_checks_to_do.check_item_categories := TRUE;
      x_auth_checks_to_do.check_locations := FALSE;
      x_auth_checks_to_do.check_doc_totals := TRUE;

    ELSIF ((p_document_type = 'PA') and (p_document_subtype = 'CONTRACT'))
    THEN

      -- no checks other than doc total check
      d_progress := 170;
      x_auth_checks_to_do.check_accounts := FALSE;
      x_auth_checks_to_do.check_items := FALSE;
      x_auth_checks_to_do.check_item_categories := FALSE;
      x_auth_checks_to_do.check_locations := FALSE;
      x_auth_checks_to_do.check_doc_totals := TRUE;

    ELSE

      d_progress := 180;
      l_ret_sts := 'U';
      d_msg := 'bad document type or subtype';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;  -- p_document_type IN ...

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'x_auth_checks_to_do.check_accounts', x_auth_checks_to_do.check_accounts);
      PO_LOG.stmt(d_module, d_progress, 'x_auth_checks_to_do.check_items', x_auth_checks_to_do.check_items);
      PO_LOG.stmt(d_module, d_progress, 'x_auth_checks_to_do.check_item_categories', x_auth_checks_to_do.check_item_categories);
      PO_LOG.stmt(d_module, d_progress, 'x_auth_checks_to_do.check_locations', x_auth_checks_to_do.check_locations);
      PO_LOG.stmt(d_module, d_progress, 'x_auth_checks_to_do.check_doc_totals', x_auth_checks_to_do.check_doc_totals);
    END IF;

    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
      IF ((l_ret_sts = 'U') and (PO_LOG.d_exc)) THEN
        PO_LOG.exc(d_module, d_progress, d_msg);
      END IF;
      IF (l_ret_sts = 'E') THEN
        PO_LOG.stmt(d_module, d_progress, 'Error: ' || d_msg);
      END IF;
  END;

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_auth_check_ids.object_id', x_auth_check_ids.object_id);
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

END authority_checks_setup;

PROCEDURE check_doc_total_limit(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_session_gt_key      IN     NUMBER
,  p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_authorized_yn       OUT NOCOPY VARCHAR2
)
IS

d_progress       NUMBER;
d_module         VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CHECK.check_doc_total_limit';

l_result            NUMBER;
l_amt_limit_nvl     NUMBER;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_session_gt_key', p_session_gt_key);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.object_id', p_auth_check_ids.object_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.position_id', p_auth_check_ids.position_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.job_id', p_auth_check_ids.job_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.ctl_function_id', p_auth_check_ids.ctl_function_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.fsp_org_id', p_auth_check_ids.fsp_org_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.coa_id', p_auth_check_ids.coa_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.item_cat_struct_id', p_auth_check_ids.item_cat_struct_id);
  END IF;

  IF (p_document_type = 'PA')
  THEN
    l_amt_limit_nvl := 0;
  ELSE
    l_amt_limit_nvl := -1;
  END IF;

  d_progress := 10;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'l_amt_limit_nvl', l_amt_limit_nvl);
  END IF;



  SELECT sign(min(nvl(POCR.amount_limit, l_amt_limit_nvl) - sum(pgt.num1)))
  INTO l_result
  FROM po_control_rules pocr
    ,  po_control_groups pocg
    ,  po_position_controls popc
    ,  po_session_gt pgt
  WHERE pgt.key = p_session_gt_key
    AND pgt.num1 IS NOT NULL
    AND pgt.num2 IS NULL                -- Bug 4610058
    -- <Bug 4605781 Start>
    AND ((p_auth_check_ids.position_id IS NULL) OR
          (popc.position_id = p_auth_check_ids.position_id))
    AND ((p_auth_check_ids.job_id IS NULL) OR
          (popc.job_id = p_auth_check_ids.job_id))
    -- <Bug 4605781 End>
    AND sysdate BETWEEN NVL(popc.start_date, sysdate - 1) AND NVL(popc.end_date, sysdate + 1)
    AND popc.control_function_id = p_auth_check_ids.ctl_function_id
    AND pocg.enabled_flag = 'Y'
    AND pocg.control_group_id = popc.control_group_id
    AND pocr.control_group_id = pocg.control_group_id
    AND pocr.object_code = 'DOCUMENT_TOTAL'
    AND NVL(pocr.inactive_date, sysdate + 1) > sysdate
  GROUP BY  pocr.control_rule_id, pocr.amount_limit;

  d_progress := 20;

  -- bug4772633
  -- For PA, if document total control rule is not defined, the above sql
  -- returns NULL. In that case, it means that approval is not allowed
  IF (p_document_type = 'PA') THEN
    l_result := NVL(l_result, -2);
  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'l_result', l_result);
  END IF;

  decode_result(
     p_document_type => p_document_type
  ,  p_result_val => l_result
  ,  x_authorized_yn => x_authorized_yn);

  d_progress := 30;
  x_return_status := 'S';

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_authorized_yn', x_authorized_yn);
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

END check_doc_total_limit;


PROCEDURE check_location_limit(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_session_gt_key      IN     NUMBER
,  p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_authorized_yn       OUT NOCOPY VARCHAR2
)
IS

d_progress       NUMBER;
d_module         VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CHECK.check_location_limit';

l_result           NUMBER;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_session_gt_key', p_session_gt_key);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.object_id', p_auth_check_ids.object_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.position_id', p_auth_check_ids.position_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.job_id', p_auth_check_ids.job_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.ctl_function_id', p_auth_check_ids.ctl_function_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.fsp_org_id', p_auth_check_ids.fsp_org_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.coa_id', p_auth_check_ids.coa_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.item_cat_struct_id', p_auth_check_ids.item_cat_struct_id);
  END IF;

  SELECT sign(min(nvl(POCR.amount_limit, -1) - sum(pgt.num1)))
  INTO l_result
  FROM po_control_rules pocr
    ,  po_control_groups pocg
    ,  po_position_controls popc
    ,  po_session_gt pgt
  WHERE pgt.key = p_session_gt_key
    AND pgt.num1 IS NOT NULL
    AND pgt.num2 IS NULL         -- Bug 4610058
    AND pgt.char1 = 'N'
    AND pgt.char2 <> 'FINALLY CLOSED'
    -- <Bug 4605781 Start>
    AND ((p_auth_check_ids.position_id IS NULL) OR
          (popc.position_id = p_auth_check_ids.position_id))
    AND ((p_auth_check_ids.job_id IS NULL) OR
          (popc.job_id = p_auth_check_ids.job_id))
    -- <Bug 4605781 End>
    AND sysdate BETWEEN NVL(popc.start_date, sysdate - 1) AND NVL(popc.end_date, sysdate + 1)
    AND popc.control_function_id = p_auth_check_ids.ctl_function_id
    AND pocg.enabled_flag = 'Y'
    AND pocg.control_group_id = popc.control_group_id
    AND pocr.control_group_id = pocg.control_group_id
    AND pocr.object_code = 'LOCATION' --Bug#4901549
    AND NVL(pocr.inactive_date, sysdate + 1) > sysdate
    AND pocr.location_id = pgt.num4
  GROUP BY  pocr.control_rule_id, pocr.amount_limit;

  d_progress := 10;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'l_result', l_result);
  END IF;

  decode_result(
     p_document_type => p_document_type
  ,  p_result_val => l_result
  ,  x_authorized_yn => x_authorized_yn);

  d_progress := 20;

  x_return_status := 'S';

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_authorized_yn', x_authorized_yn);
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

END check_location_limit;


PROCEDURE check_account_limit(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_session_gt_key      IN     NUMBER
,  p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_authorized_yn       OUT NOCOPY VARCHAR2
)
IS

d_progress       NUMBER;
d_module         VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CHECK.check_account_limit';

l_sql                 VARCHAR2(8000);
l_result              NUMBER;
l_ret_sts             VARCHAR2(1);
d_msg      VARCHAR2(200);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_session_gt_key', p_session_gt_key);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.object_id', p_auth_check_ids.object_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.position_id', p_auth_check_ids.position_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.job_id', p_auth_check_ids.job_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.ctl_function_id', p_auth_check_ids.ctl_function_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.fsp_org_id', p_auth_check_ids.fsp_org_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.coa_id', p_auth_check_ids.coa_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.item_cat_struct_id', p_auth_check_ids.item_cat_struct_id);
  END IF;

  BEGIN

    d_progress := 10;

    get_range_limit_sql(
       p_document_id     => p_document_id
    ,  p_document_type   => p_document_type
    ,  p_document_subtype => p_document_subtype
    ,  p_check_type       => g_chktype_ACCOUNT_LIMIT
    ,  p_auth_check_ids   => p_auth_check_ids
    ,  x_return_status    => l_ret_sts
    ,  x_range_check_sql  => l_sql
    );

    d_progress := 20;

    IF (l_ret_sts <> 'S')
    THEN
      d_msg := 'get_range_limit_sql not successful';
      l_ret_sts := 'U';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_sql', l_sql);
    END IF;

    d_progress := 30;

    EXECUTE IMMEDIATE l_sql
      INTO l_result
      USING p_session_gt_key, p_auth_check_ids.position_id
          , p_auth_check_ids.position_id, p_auth_check_ids.job_id
          , p_auth_check_ids.job_id, p_auth_check_ids.ctl_function_id
          , 'ACCOUNT_RANGE';

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_result', l_result);
    END IF;

    decode_result(
       p_document_type => p_document_type
    ,  p_result_val => l_result
    ,  x_authorized_yn => x_authorized_yn);

    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, d_msg);
      END IF;
  END;

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_authorized_yn', x_authorized_yn);
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
END check_account_limit;

PROCEDURE check_account_exists(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_session_gt_key      IN     NUMBER
,  p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_authorized_yn       OUT NOCOPY VARCHAR2
)
IS

d_progress       NUMBER;
d_module         VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CHECK.check_account_exists';

l_sql                 VARCHAR2(8000);
l_result              NUMBER;
l_ret_sts             VARCHAR2(1);
d_msg      VARCHAR2(200);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_session_gt_key', p_session_gt_key);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.object_id', p_auth_check_ids.object_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.position_id', p_auth_check_ids.position_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.job_id', p_auth_check_ids.job_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.ctl_function_id', p_auth_check_ids.ctl_function_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.fsp_org_id', p_auth_check_ids.fsp_org_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.coa_id', p_auth_check_ids.coa_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.item_cat_struct_id', p_auth_check_ids.item_cat_struct_id);
  END IF;

  BEGIN

    d_progress := 10;

    get_range_exists_sql(
       p_document_id     => p_document_id
    ,  p_document_type   => p_document_type
    ,  p_document_subtype => p_document_subtype
    ,  p_check_type       => g_chktype_ACCOUNT_EXISTS
    ,  p_auth_check_ids   => p_auth_check_ids
    ,  x_return_status    => l_ret_sts
    ,  x_range_check_sql  => l_sql
    );

    d_progress := 20;

    IF (l_ret_sts <> 'S')
    THEN
      d_msg := 'get_range_exists_sql not successful';
      l_ret_sts := 'U';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_sql', l_sql);
    END IF;

    d_progress := 30;

    EXECUTE IMMEDIATE l_sql
      INTO l_result
      USING p_session_gt_key, p_auth_check_ids.position_id
          , p_auth_check_ids.position_id, p_auth_check_ids.job_id
          , p_auth_check_ids.job_id, p_auth_check_ids.ctl_function_id
          , 'ACCOUNT_RANGE';

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_result', l_result);
    END IF;

    decode_result(
       p_document_type => p_document_type
    ,  p_result_val => l_result
    ,  x_authorized_yn => x_authorized_yn);

    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, d_msg);
      END IF;
  END;

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_authorized_yn', x_authorized_yn);
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

END check_account_exists;

PROCEDURE check_item_limit(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_session_gt_key      IN     NUMBER
,  p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_authorized_yn       OUT NOCOPY VARCHAR2
)
IS

l_sql                 VARCHAR2(8000);
l_result              NUMBER;
l_ret_sts             VARCHAR2(1);

d_progress       NUMBER;
d_module         VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CHECK.check_item_limit';

d_msg      VARCHAR2(200);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_session_gt_key', p_session_gt_key);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.object_id', p_auth_check_ids.object_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.position_id', p_auth_check_ids.position_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.job_id', p_auth_check_ids.job_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.ctl_function_id', p_auth_check_ids.ctl_function_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.fsp_org_id', p_auth_check_ids.fsp_org_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.coa_id', p_auth_check_ids.coa_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.item_cat_struct_id', p_auth_check_ids.item_cat_struct_id);
  END IF;

  BEGIN

    d_progress := 10;

    get_range_limit_sql(
       p_document_id     => p_document_id
    ,  p_document_type   => p_document_type
    ,  p_document_subtype => p_document_subtype
    ,  p_check_type       => g_chktype_ITEM_LIMIT
    ,  p_auth_check_ids   => p_auth_check_ids
    ,  x_return_status    => l_ret_sts
    ,  x_range_check_sql  => l_sql
    );

    d_progress := 20;

    IF (l_ret_sts <> 'S')
    THEN
      d_msg := 'get_range_limit_sql not successful';
      l_ret_sts := 'U';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_sql', l_sql);
    END IF;

    d_progress := 30;

    EXECUTE IMMEDIATE l_sql
      INTO l_result
      USING p_session_gt_key, p_auth_check_ids.position_id
          , p_auth_check_ids.position_id, p_auth_check_ids.job_id
          , p_auth_check_ids.job_id, p_auth_check_ids.ctl_function_id
          , 'ITEM_RANGE';

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_result', l_result);
    END IF;

    decode_result(
       p_document_type => p_document_type
    ,  p_result_val => l_result
    ,  x_authorized_yn => x_authorized_yn);

    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, d_msg);
      END IF;
  END;

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_authorized_yn', x_authorized_yn);
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

END check_item_limit;

PROCEDURE check_category_limit(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_session_gt_key      IN     NUMBER
,  p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_authorized_yn       OUT NOCOPY VARCHAR2
)
IS

l_sql                 VARCHAR2(8000);
l_result              NUMBER;
l_ret_sts             VARCHAR2(1);

d_progress       NUMBER;
d_module         VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CHECK.check_category_limit';

d_msg      VARCHAR2(200);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_session_gt_key', p_session_gt_key);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.object_id', p_auth_check_ids.object_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.position_id', p_auth_check_ids.position_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.job_id', p_auth_check_ids.job_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.ctl_function_id', p_auth_check_ids.ctl_function_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.fsp_org_id', p_auth_check_ids.fsp_org_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.coa_id', p_auth_check_ids.coa_id);
    PO_LOG.proc_begin(d_module, 'p_auth_check_ids.item_cat_struct_id', p_auth_check_ids.item_cat_struct_id);
  END IF;

  BEGIN

    d_progress := 10;

    get_range_limit_sql(
       p_document_id     => p_document_id
    ,  p_document_type   => p_document_type
    ,  p_document_subtype => p_document_subtype
    ,  p_check_type       => g_chktype_CATEGORY_LIMIT
    ,  p_auth_check_ids   => p_auth_check_ids
    ,  x_return_status    => l_ret_sts
    ,  x_range_check_sql  => l_sql
    );

    d_progress := 20;

    IF (l_ret_sts <> 'S')
    THEN
      d_msg := 'get_range_limit_sql not successful';
      l_ret_sts := 'U';
      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_sql', l_sql);
    END IF;

    d_progress := 30;

    EXECUTE IMMEDIATE l_sql
      INTO l_result
      USING p_session_gt_key, p_auth_check_ids.position_id
          , p_auth_check_ids.position_id, p_auth_check_ids.job_id
          , p_auth_check_ids.job_id, p_auth_check_ids.ctl_function_id
          , 'ITEM_CATEGORY_RANGE';

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_result', l_result);
    END IF;

    decode_result(
       p_document_type => p_document_type
    ,  p_result_val => l_result
    ,  x_authorized_yn => x_authorized_yn);

    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, d_msg);
      END IF;
  END;

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_authorized_yn', x_authorized_yn);
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

END check_category_limit;

PROCEDURE get_range_limit_sql(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_check_type          IN     VARCHAR2
,  p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_range_check_sql     OUT NOCOPY VARCHAR2
)
IS

-- x_range_check_sql buffer size should be at least 8000 characters.

d_progress       NUMBER;
d_module         VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CHECK.get_range_limit_sql';

l_flex_segment_where          VARCHAR2(4000);

l_sum_col     VARCHAR2(80);
l_flex_table  VARCHAR2(80);
l_flex_join   VARCHAR2(80);

l_ret_sts     VARCHAR2(1);
l_hint varchar2(100); -- bug 11724074 declaring variable.
d_msg     VARCHAR2(200);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_check_type', p_check_type);
  END IF;

  BEGIN

    IF (p_check_type = g_chktype_ACCOUNT_LIMIT)
    THEN

      d_progress := 10;

      l_sum_col := 'pgt.num1';
      l_flex_table := ' , gl_code_combinations glcc ';
      l_flex_join := ' AND glcc.code_combination_id = pgt.num3 ';

    ELSIF (p_check_type = g_chktype_ITEM_LIMIT)
    THEN

      d_progress := 20;

      IF (p_document_type <> 'PA')
      THEN
        l_sum_col := 'pgt.num1';
      ELSE
        l_sum_col := 'pgt.num2';
      END IF;

      -- bug 11724074 : Adding leading hint to improve performance
      l_hint := ' /*+ leading(pgt mtsi pocr) use_nl(pocr)*/ '; -- bug 11724074
      l_flex_table := ' , mtl_system_items mtsi ';
      l_flex_join := ' AND mtsi.inventory_item_id = pgt.num5 AND mtsi.organization_id = ' || p_auth_check_ids.fsp_org_id || ' ';

    ELSIF (p_check_type = g_chktype_CATEGORY_LIMIT)
    THEN

      d_progress := 30;

      IF (p_document_type <> 'PA')
      THEN
        l_sum_col := 'pgt.num1';
      ELSE
        l_sum_col := 'pgt.num2';
      END IF;

      -- bug 11724074 : Adding leading hint to improve performance
      l_hint := ' /*+ leading(pgt mtcat pocr) use_nl(pocr)*/ '; -- bug 11724074
      l_flex_table := ' , mtl_categories mtcat ';
      l_flex_join := ' AND mtcat.category_id = pgt.num6 ';

    ELSE

      d_progress := 40;
      l_ret_sts := 'U';
      d_msg := 'check type not supported';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_sum_col', l_sum_col);
      PO_LOG.stmt(d_module, d_progress, 'l_flex_table', l_flex_table);
      PO_LOG.stmt(d_module, d_progress, 'l_flex_join', l_flex_join);
    END IF;

    d_progress := 50;

    get_flex_where_sql(
       p_auth_check_ids => p_auth_check_ids
    ,  p_check_type     => p_check_type
    ,  x_return_status  => l_ret_sts
    ,  x_flex_sql       => l_flex_segment_where
    );

    IF (l_ret_sts <> 'S') THEN

      d_progress := 60;
      l_ret_sts := 'U';
      d_msg := 'get_flex_where_sql not successful';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 70;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_flex_segment_where', l_flex_segment_where);
    END IF;

    -- Bind variables created in sql string:
    -- 1 - key into po_session_gt table
    -- 2 - p_auth_check_ids.position_id
    -- 3 - p_auth_check_ids.job_id
    -- 4 - p_auth_check_ids.ctl_function_id
    -- 5 - object code in po_control_rules, e.g. 'ACCOUNT_RANGE'
    -- added hint for performance check for bug 11724074

    x_range_check_sql := 'SELECT '
	     || l_hint   -- bug 11724074
             || 'sign(min(nvl(POCR.amount_limit, -1) '
             || ' - sum(' || l_sum_col || ')))'
             || ' FROM po_session_gt pgt, po_control_rules pocr'
             || ' , po_control_groups pocg, po_position_controls popc'
             || l_flex_table
             || ' WHERE pgt.key = :1 AND ' || l_sum_col || ' IS NOT NULL'
             || ' AND pgt.char1 = DECODE(POCR.RULE_TYPE_CODE,''INCLUDE'',nvl(pgt.char1, ''N''),''EXCLUDE'',''N'') ' --Bug 13835378 fix
             || ' AND pgt.char2 <> ''FINALLY CLOSED'' '
             || l_flex_join
             -- <Bug 4605781 Start>
             || ' AND ((:2 IS NULL) OR (popc.position_id = :3))'
             || ' AND ((:4 IS NULL) OR (popc.job_id = :5))'
             -- <Bug 4605781 End>
             || ' AND sysdate BETWEEN NVL(popc.start_date, sysdate - 1) AND NVL(popc.end_date, sysdate + 1)'
             || ' AND popc.control_function_id = :6'
             || ' AND pocg.enabled_flag = ''Y'' '
             || ' AND pocg.control_group_id = popc.control_group_id'
             || ' AND pocr.control_group_id = pocg.control_group_id'
             || ' AND pocr.object_code = :7 '
             || ' AND NVL(pocr.inactive_date, sysdate + 1) > sysdate '
             || l_flex_segment_where
             || ' GROUP BY  pocr.control_rule_id, pocr.amount_limit';

    d_progress := 80;
    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, d_msg);
      END IF;
  END;

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_range_check_sql', x_range_check_sql);
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

END get_range_limit_sql;

PROCEDURE get_range_exists_sql(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  p_check_type          IN     VARCHAR2
,  p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_range_check_sql     OUT NOCOPY VARCHAR2
)
IS

-- x_range_check_sql buffer size should be at least 8000 characters.

l_flex_segment_where          VARCHAR2(4000);
l_flex_table  VARCHAR2(80);
l_flex_join   VARCHAR2(80);

l_ret_sts     VARCHAR2(1);

d_msg     VARCHAR2(200);
d_progress    NUMBER;
d_module      VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CHECK.get_range_exists_sql';

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_check_type', p_check_type);
  END IF;

  BEGIN

    IF (p_check_type = g_chktype_ACCOUNT_EXISTS)
    THEN

      d_progress := 10;

      l_flex_table := ' , gl_code_combinations glcc ';
      l_flex_join := ' AND glcc.code_combination_id = pgt.num3 ';

    ELSE

      d_progress := 20;
      l_ret_sts := 'U';
      d_msg := 'check type not supported';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_flex_table', l_flex_table);
      PO_LOG.stmt(d_module, d_progress, 'l_flex_join', l_flex_join);
    END IF;

    d_progress := 30;

    get_flex_where_sql(
       p_auth_check_ids => p_auth_check_ids
    ,  p_check_type     => p_check_type
    ,  x_return_status  => l_ret_sts
    ,  x_flex_sql       => l_flex_segment_where
    );

    IF (l_ret_sts <> 'S') THEN

      d_progress := 40;
      l_ret_sts := 'U';
      d_msg := 'get_flex_where_sql not successful';
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 50;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_flex_segment_where', l_flex_segment_where);
    END IF;

    -- Bind variables created in sql string:
    -- 1 - key into po_session_gt table
    -- 2 - p_auth_check_ids.position_id
    -- 3 - p_auth_check_ids.job_id
    -- 4 - p_auth_check_ids.ctl_function_id
    -- 5 - object code in po_control_rules, e.g. 'ACCOUNT_RANGE'

    x_range_check_sql := 'SELECT nvl(min(-1),0) '
             || ' FROM po_session_gt pgt '
             || l_flex_table
             || ' WHERE pgt.key = :1 '
	     || ' AND pgt.char1 = ''N'' '  --Bug 13835378 fix. Canceled lines should be ignored.
             || l_flex_join
             || ' AND NOT EXISTS ( '
             || ' SELECT ''account is in range'' '
             || ' FROM po_control_rules pocr, po_control_groups pocg'
             || ' , po_position_controls popc '
             -- <Bug 4605781 Start>
             || ' WHERE ((:2 IS NULL) OR (popc.position_id = :3))'
             || ' AND ((:4 IS NULL) OR (popc.job_id = :5))'
             -- <Bug 4605781 End>
             || ' AND sysdate BETWEEN NVL(popc.start_date, sysdate - 1) AND NVL(popc.end_date, sysdate + 1)'
             || ' AND popc.control_function_id = :6'
             || ' AND pocg.enabled_flag = ''Y'' '
             || ' AND pocg.control_group_id = popc.control_group_id'
             || ' AND pocr.control_group_id = pocg.control_group_id'
             || ' AND pocr.object_code = :7 '
             || ' AND NVL(pocr.inactive_date, sysdate + 1) > sysdate '
             || l_flex_segment_where
             || ' ) ';


    d_progress := 60;
    l_ret_sts := 'S';

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      PO_DOCUMENT_ACTION_PVT.error_msg_append(d_module, d_progress, d_msg);
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, d_msg);
      END IF;
  END;

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_range_check_sql', x_range_check_sql);
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

END get_range_exists_sql;

PROCEDURE get_flex_where_sql(
   p_auth_check_ids      IN     AUTH_CHECK_IDS_REC
,  p_check_type          IN     VARCHAR2
,  x_return_status       OUT NOCOPY VARCHAR2
,  x_flex_sql            OUT NOCOPY VARCHAR2
)
IS

l_flexfield_rec  FND_FLEX_KEY_API.flexfield_type;
l_structure_rec  FND_FLEX_KEY_API.structure_type;
l_segment_rec    FND_FLEX_KEY_API.segment_type;
l_segment_tbl    FND_FLEX_KEY_API.segment_list;

l_appl_short_name   VARCHAR2(8);
l_flex_code         VARCHAR2(8);
l_structure_code    NUMBER;
l_table_alias       VARCHAR2(8);

l_segment_number NUMBER;
l_idx            NUMBER;
l_segment        VARCHAR2(160);

d_msg     VARCHAR2(200);
d_progress    NUMBER;
d_module      VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CHECK.get_flex_where_sql';

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_check_type', p_check_type);
  END IF;

  x_flex_sql := ' ';

  IF ((p_check_type = g_chktype_ACCOUNT_LIMIT)
       OR (p_check_type = g_chktype_ACCOUNT_EXISTS))
  THEN

    d_progress := 10;
    l_appl_short_name := 'SQLGL';
    l_flex_code := 'GL#';
    l_structure_code := p_auth_check_ids.coa_id;
    l_table_alias := 'glcc';

  ELSIF (p_check_type = g_chktype_ITEM_LIMIT)
  THEN

    d_progress := 20;
    l_appl_short_name := 'INV';
    l_flex_code := 'MSTK';
    l_structure_code := 101;
    l_table_alias := 'mtsi';

  ELSIF (p_check_type = g_chktype_CATEGORY_LIMIT)
  THEN

    d_progress := 30;
    l_appl_short_name := 'INV';
    l_flex_code := 'MCAT';
    l_structure_code := p_auth_check_ids.item_cat_struct_id;
    l_table_alias := 'mtcat';

  ELSE

    d_progress := 40;
    d_msg := 'check type not supported';
    RAISE PO_CORE_S.g_early_return_exc;

  END IF;  -- p_check_type = ...

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'l_appl_short_name', l_appl_short_name);
    PO_LOG.stmt(d_module, d_progress, 'l_flex_code', l_flex_code);
    PO_LOG.stmt(d_module, d_progress, 'l_structure_code', l_structure_code);
    PO_LOG.stmt(d_module, d_progress, 'l_table_alias', l_table_alias);
  END IF;

  d_progress := 50;

  -- Call FND_FLEX_KEY_API to get flexfield information
  FND_FLEX_KEY_API.set_session_mode('customer_data');

  d_progress := 60;

  -- Retrieve flexfield sgements
  l_flexfield_rec := FND_FLEX_KEY_API.find_flexfield(l_appl_short_name,l_flex_code);
  d_progress := 65;
  l_structure_rec := FND_FLEX_KEY_API.find_structure(l_flexfield_rec, l_structure_code);

  d_progress := 70;

  FND_FLEX_KEY_API.get_segments(
     flexfield => l_flexfield_rec
  ,  structure => l_structure_rec
  ,  nsegments => l_segment_number
  ,  segments  => l_segment_tbl
  );

  d_progress := 80;

  -- Construct the where condition for the flexfield values to be
  -- within range of the control rule's values.
  FOR l_idx IN 1..l_segment_number
  LOOP

    d_progress := 90;

    l_segment_rec := FND_FLEX_KEY_API.find_segment(l_flexfield_rec,l_structure_rec,l_segment_tbl(l_idx));

	 l_segment := 'NVL(' || l_table_alias || '.' || l_segment_rec.column_name || ', ''0'')';

    x_flex_sql := x_flex_sql || ' AND '|| l_segment || ' BETWEEN '
       || ' NVL(POCR.' || l_segment_rec.column_name || '_low, ' || l_segment
       || ' ) AND NVL(POCR.' || l_segment_rec.column_name ||'_high, ' || l_segment || ') ';

  END LOOP;  -- FOR l_idx IN 1..l_segment_number

  x_return_status := 'S';

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_flex_sql', x_flex_sql);
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

END get_flex_where_sql;



PROCEDURE populate_session_gt(
   p_document_id         IN     NUMBER
,  p_document_type       IN     VARCHAR2
,  p_document_subtype    IN     VARCHAR2
,  x_session_gt_key      OUT NOCOPY NUMBER
,  x_return_status       OUT NOCOPY VARCHAR2
)
IS

d_progress       NUMBER;
d_module         VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CHECK.populate_session_gt';
--add by Xiao Lv for PO Notification 14-Apr-2009, begin
-------------------------------------------------------------
lv_tax_region   VARCHAR2(30);

-------------------------------------------------------------
--add by Xiao Lv for PO Notification 14-Apr-2009, end

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
  END IF;

  /*
   * PO_SESSION_GT:
   * key = key into table
   * num1 = unit total for most checks
   * num2 = unit total for item/cat limit checks for PAs only
   * num3 = code combination id (for account limit check)
   * num4 = location id (for location check)
   * num5 = item_id (for item check)
   * num6 = category_id (for category check)
   * char1 = cancel_flag
   * char2 = closed_code
   */

  SELECT PO_SESSION_GT_S.nextval INTO x_session_gt_key FROM dual;

  d_progress := 10;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'x_session_gt_key', x_session_gt_key);
  END IF;

  IF (p_document_type = 'PO')
  THEN

    d_progress := 20;

    INSERT INTO PO_SESSION_GT(
       key
    ,  num1
    ,  num2
    ,  num3
    ,  num4
    ,  num5
    ,  num6
    ,  char1
    ,  char2
    )
      SELECT
         x_session_gt_key
      ,  (DECODE(pod.amount_ordered,
            NULL,(pod.quantity_ordered - NVL(pod.quantity_cancelled,0)) * poll.price_override,
            pod.amount_ordered - NVL(pod.amount_cancelled,0))
           + po_tax_sv.get_tax('PO',pod.po_distribution_id))
          * nvl(pod.rate,1)
      ,  NULL
      ,  pod.code_combination_id
      ,  poll.ship_to_location_id + 0
      ,  pol.item_id
      ,  pol.category_id
      ,  DECODE(nvl(pol.cancel_flag, 'N'), 'N', NVL(poll.cancel_flag, 'N'), pol.cancel_flag)
      ,  DECODE(nvl(pol.closed_code, 'OPEN'), 'OPEN', NVL(poll.closed_code, 'OPEN'), pol.closed_code)
      FROM po_headers poh
        ,  po_lines pol
        ,  po_line_locations poll
        ,  po_distributions pod
      WHERE poh.po_header_id = p_document_id
        AND pol.po_header_id = poh.po_header_id
        AND poll.po_line_id = pol.po_line_id
        AND poll.shipment_type <> 'PREPAYMENT'  -- <Complex Work R12>
        AND pod.line_location_id = poll.line_location_id
        AND ((poh.type_lookup_code <> 'PLANNED') OR
              ((poh.type_lookup_code = 'PLANNED') AND (poll.shipment_type = 'PLANNED')))
        ;


  ELSIF (p_document_type = 'REQUISITION')
  THEN

    d_progress := 30;

 /* bug 16168687 : replacing function get_req_distribution_total with
 	     get_req_dist_total*/

    INSERT INTO PO_SESSION_GT(
       key
    ,  num1
    ,  num2
    ,  num3
    ,  num4
    ,  num5
    ,  num6
    ,  char1
    ,  char2
    )
      SELECT
         x_session_gt_key
      ,  po_calculatereqtotal_pvt.get_req_dist_total(
                   porl.requisition_header_id,porl.requisition_line_id,pord.distribution_id)
      ,  NULL
      ,  pord.code_combination_id
      ,  porl.deliver_to_location_id
      ,  porl.item_id
      ,  porl.category_id
      ,  'N'
      ,  'OPEN'                      -- Bug 4610058
      FROM po_req_distributions pord
        ,  po_requisition_lines porl
      WHERE porl.requisition_header_id = p_document_id
        AND porl.requisition_line_id = pord.requisition_line_id
        AND NVL(porl.cancel_flag, 'N') = 'N'
        AND NVL(porl.modified_by_agent_flag, 'N') = 'N';

  ELSIF (p_document_type = 'RELEASE')
  THEN

    d_progress := 40;

    INSERT INTO PO_SESSION_GT(
       key
    ,  num1
    ,  num2
    ,  num3
    ,  num4
    ,  num5
    ,  num6
    ,  char1
    ,  char2
    )
      SELECT
         x_session_gt_key
      ,  (DECODE(pod.amount_ordered,
            NULL, (pod.quantity_ordered - NVL(pod.quantity_cancelled,0)) * poll.price_override,
            pod.amount_ordered - NVL(pod.amount_cancelled,0))
           + po_tax_sv.get_tax('RELEASE',pod.po_distribution_id))
          * NVL(pod.rate,1)
      ,  NULL
      ,  pod.code_combination_id
      ,  poll.ship_to_location_id
      ,  pol.item_id
      ,  pol.category_id
      ,  DECODE(nvl(pol.cancel_flag, 'N'), 'N', NVL(poll.cancel_flag, 'N'), pol.cancel_flag)
      ,  DECODE(nvl(pol.closed_code, 'OPEN'), 'OPEN', NVL(poll.closed_code, 'OPEN'), pol.closed_code)
      FROM po_distributions pod
        ,  po_line_locations poll
        ,  po_lines pol
      WHERE poll.po_release_id = p_document_id
        AND poll.po_line_id = pol.po_line_id
        AND pod.line_location_id = poll.line_location_id;

  ELSIF (p_document_type = 'PA')
  THEN

    d_progress := 50;

    INSERT INTO PO_SESSION_GT(
       key
    ,  num1
    ,  num2
    ,  num3
    ,  num4
    ,  num5
    ,  num6
    ,  char1
    ,  char2
    )
      SELECT
         x_session_gt_key
      ,  nvl(poh.blanket_total_amount,0) * nvl(poh.rate,1)
      ,  NULL
      ,  NULL
      ,  NULL
      ,  NULL
      ,  NULL
      ,  'N'
      ,  'OPEN'                      -- Bug 4610058
      FROM po_headers poh
      WHERE poh.po_header_id = p_document_id;

    d_progress := 60;

    INSERT INTO PO_SESSION_GT(
       key
    ,  num1
    ,  num2
    ,  num3
    ,  num4
    ,  num5
    ,  num6
    ,  char1
    ,  char2
    )
      SELECT
         x_session_gt_key
      ,  NULL
      -- Bug 4610058 Start : Should not sum up lines here; that will be done
      -- in the range_limit dynamic sql.
      ,  GREATEST(NVL(pol.committed_amount,0),
                  NVL(pol.quantity_committed, 0) * NVL (pol.unit_price, 0) * NVL (poh.rate, 1))
      -- Bug 4510058 End
      ,  NULL
      ,  NULL
      ,  pol.item_id                 -- Bug 4610058
      ,  pol.category_id             -- Bug 4610058
      ,  NVL(pol.cancel_flag, 'N')   -- Bug 4610058
      ,  'OPEN'                      -- Bug 4610058
      FROM po_headers poh
        ,  po_lines pol
      WHERE poh.po_header_id = p_document_id
        AND pol.po_header_id = poh.po_header_id
        AND NVL(pol.cancel_flag, 'N') = 'N';


  ELSE

    d_progress := 70;
    RAISE PO_CORE_S.g_early_return_exc;

  END IF;  -- p_document_type
--add by Xiao Lv for PO Notification 14-Apr-2009, begin
----------------------------------------------------------------------------

    lv_tax_region := JAI_PO_WF_UTIL_PUB.Get_Tax_Region (pv_document_type => p_document_type
                                                      , pn_document_id   => p_document_id);

    IF ( lv_tax_region = 'JAI')
    THEN
       JAI_PO_WF_UTIL_PUB.Populate_Session_GT( p_document_id
                                             , p_document_type
                                             , p_document_subtype
                                             , x_session_gt_key);
    END IF; -- lv_tax_region = 'JAI'
----------------------------------------------------------------------------
--add by Xiao Lv for PO Notification 14-Apr-2009, end

  x_return_status := 'S';

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

END populate_session_gt;

PROCEDURE decode_result(
   p_document_type IN VARCHAR2
,  p_result_val    IN NUMBER
,  x_authorized_yn OUT NOCOPY VARCHAR2
)
IS

l_result  NUMBER;
d_module         VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_ACTION_CHECK.decode_result';
BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_result_val', p_result_val);
  END IF;

  -- Bug 4610058: No need for special case for 'PA', which was a result
  -- of incorrect comments in old Pro*C code. If no rows are returned for 'PA'
  -- check should still pass.

  l_result := NVL(p_result_val, 0);


  IF (l_result < 0)
  THEN
    x_authorized_yn := 'N';
  ELSE
    x_authorized_yn := 'Y';
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_authorized_yn', x_authorized_yn);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

END decode_result;


END PO_DOCUMENT_ACTION_CHECK;

/
