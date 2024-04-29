--------------------------------------------------------
--  DDL for Package Body PO_CUSTOM_SUBMISSION_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CUSTOM_SUBMISSION_CHECK_PVT" AS
  /* $Header: PO_CUSTOM_SUBMISSION_CHECK_PVT.plb 120.0.12010000.2 2009/01/12 07:04:20 mugoel noship $*/

  ------------------------------------------------------------------------------
  -- Define private package constants.
  ------------------------------------------------------------------------------
  g_pkg_name CONSTANT VARCHAR2(50) := 'PO_CUSTOM_SUBMISSION_CHECK_PVT';

  d_do_pre_submission_check CONSTANT VARCHAR2(100) :=
    po_log.get_subprogram_base(po_log.get_package_base(g_pkg_name),
                               'do_pre_submission_check');

  d_do_post_submission_check CONSTANT VARCHAR2(100) :=
    po_log.get_subprogram_base(po_log.get_package_base(g_pkg_name),
                               'do_post_submission_check');

  ------------------------------------------------------------------------------
  -- Define public procedures.
  ------------------------------------------------------------------------------

  /**
   * Public Procedure: do_pre_submission_check
   * Requires:
   *   IN PARAMETERS:
   *     p_api_version:       Version number of API that caller expects.
   *     p_document_id:       Id of the document to validate
   *     p_action_requested:  The action to perform
   *     p_document_type:     The type of the document to perform
   *                          the submission check on.
   *     p_document_subtype:  The subtype of the document.
   *     p_document_level:    The type of id that is being passed.
   *     p_document_level_id: Id of the doc level type on which to perform the
   *                          check.
   *     p_requested_changes: This object contains all the requested changes to
   *                          the document.
   *     p_check_asl:         Determines whether or not to perform the checks:
   *                          PO_SUB_ITEM_NOT_APPROVED/PO_SUB_ITEM_ASL_DEBARRED
   *     p_req_chg_initiator: Caller of the change request if its a change
   *                          request.
   *     p_online_report_id:  Id to be used when inserting records into
   *                          PO_ONLINE_REPORT_TEXT_GT table.
   *     p_user_id:           User performing the action
   *     p_login_id:          Last update login_id
   *     p_sequence:          Sequence number of last reported error
   *
   * Modifies: None. [The custom code has to be written by customer.]
   * Effects:  This procedure runs the custom document submission checks on
   *           passed in document.
   * Returns:
   *  x_return_status:  FND_API.G_RET_STS_SUCCESS if API succeeds
   *                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
   *
   * NOTE: For writing custom code, please refer to the instructions given at
   *       the top of this file.
   */
  PROCEDURE do_pre_submission_check(
    p_api_version                    IN             NUMBER,
    p_document_id                    IN             NUMBER,
    p_action_requested               IN             VARCHAR2,
    p_document_type                  IN             VARCHAR2,
    p_document_subtype               IN             VARCHAR2,
    p_document_level                 IN             VARCHAR2,
    p_document_level_id              IN             NUMBER,
    p_requested_changes              IN             PO_CHANGES_REC_TYPE,
    p_check_asl                      IN             BOOLEAN,
    p_req_chg_initiator              IN             VARCHAR2,
    p_origin_doc_id                  IN             NUMBER,
    p_online_report_id               IN             NUMBER,
    p_user_id                        IN             NUMBER,
    p_login_id                       IN             NUMBER,
    p_sequence                       IN OUT NOCOPY  NUMBER,
    x_return_status                  OUT NOCOPY     VARCHAR2
  )
  IS
    l_api_name    CONSTANT varchar2(50)  := 'do_pre_submission_check';
    l_api_version CONSTANT NUMBER        := 1.0;
    d_mod         CONSTANT VARCHAR2(100) := d_do_pre_submission_check;
    d_position    NUMBER := 0;

  BEGIN
    IF po_log.d_proc
    THEN
      po_log.proc_begin(d_mod, 'p_api_version', p_api_version);
      po_log.proc_begin(d_mod, 'p_action_requested', p_action_requested);
      po_log.proc_begin(d_mod, 'p_document_type', p_document_type);
      po_log.proc_begin(d_mod, 'p_document_subtype', p_document_subtype);
      po_log.proc_begin(d_mod, 'p_document_level', p_document_level);
      po_log.proc_begin(d_mod, 'p_document_level_id', p_document_level_id);
      po_log.proc_begin(d_mod, 'p_check_asl', p_check_asl);
      po_log.proc_begin(d_mod, 'p_req_chg_initiator', p_req_chg_initiator);
      po_log.proc_begin(d_mod, 'p_origin_doc_id', p_origin_doc_id);
      po_log.proc_begin(d_mod, 'p_online_report_id', p_online_report_id);
      po_log.proc_begin(d_mod, 'p_user_id', p_user_id);
      po_log.proc_begin(d_mod, 'p_login_id', p_login_id);
      po_log.proc_begin(d_mod, 'p_sequence', p_sequence);
    END IF;

    -- Standard call to check for call compatibility
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name,
                                       g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    d_position := 10;

    -- TODO: Add custom code here.

    -- *** Sample Code START ***
    --
    -- * Insert errors into PO_ONLINE_REPORT_TEXT_GT table *
    --INSERT INTO po_online_report_text_gt
    --           (online_report_id,
    --           last_update_login,
    --            last_updated_by,
    --            last_update_date,
    --            created_by,
    --            creation_date,
    --            line_num,
    --            shipment_num,
    --            distribution_num,
    --            SEQUENCE,
    --            text_line,
    --            message_name)
    --SELECT p_online_report_id,
    --       p_login_id,
    --       p_user_id,
    --       SYSDATE,
    --       p_user_id,
    --       SYSDATE,
    --       pol.line_num,
    --       0,
    --       0,
    --       p_sequence + ROWNUM,
    --       SUBSTR(FND_MESSAGE.GET_STRING('PO', 'MESSAGE_NAME'),1,240),
    --       'MESSAGE_NAME'
    --FROM   po_headers_gt poh,
    --       po_lines_gt pol
    --WHERE  poh.po_header_id = p_document_id
    --       AND pol.po_header_id = poh.po_header_id
    --       AND 1=2;
    --
    -- * Increment the p_sequence with number of errors reported in last query *
    --p_sequence := p_sequence + SQL%ROWCOUNT;
    --
    -- *** Sample Code END ***

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    d_position := 100;

  EXCEPTION
    WHEN OTHERS
    THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF po_log.d_exc
      THEN
        PO_LOG.exc(d_mod, d_position, SQLCODE || ': ' || SQLERRM);
        PO_LOG.proc_end(d_mod, 'd_position', d_position);
        PO_LOG.proc_end(d_mod, 'x_return_status', x_return_status);
        PO_LOG.proc_end(d_mod);
      END IF;

  END do_pre_submission_check;

  /**
   * Public Procedure: do_post_submission_check
   * Requires:
   *   IN PARAMETERS:
   *     p_api_version:       Version number of API that caller expects.
   *     p_document_id:       Id of the document to validate
   *     p_action_requested:  The action to perform
   *     p_document_type:     The type of the document to perform
   *                          the submission check on.
   *     p_document_subtype:  The subtype of the document.
   *     p_document_level:    The type of id that is being passed.
   *     p_document_level_id: Id of the doc level type on which to perform the
   *                          check.
   *     p_requested_changes: This object contains all the requested changes to
   *                          the document.
   *     p_check_asl:         Determines whether or not to perform the checks:
   *                          PO_SUB_ITEM_NOT_APPROVED/PO_SUB_ITEM_ASL_DEBARRED
   *     p_req_chg_initiator: Caller of the change request if its a change
   *                          request.
   *     p_online_report_id:  Id to be used when inserting records into
   *                          PO_ONLINE_REPORT_TEXT_GT table.
   *     p_user_id:           User performing the action
   *     p_login_id:          Last update login_id
   *     p_sequence:          Sequence number of last reported error
   *
   * Modifies: None. [The custom code has to be written by customer.]
   * Effects:  This procedure runs the custom document submission checks on
   *           passed in document.
   * Returns:
   *  x_return_status:  FND_API.G_RET_STS_SUCCESS if API succeeds
   *                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
   *
   * NOTE: For writing custom code, please refer to the instructions given at
   *       the top of this file.
   */
  PROCEDURE do_post_submission_check(
    p_api_version                    IN             NUMBER,
    p_document_id                    IN             NUMBER,
    p_action_requested               IN             VARCHAR2,
    p_document_type                  IN             VARCHAR2,
    p_document_subtype               IN             VARCHAR2,
    p_document_level                 IN             VARCHAR2,
    p_document_level_id              IN             NUMBER,
    p_requested_changes              IN             PO_CHANGES_REC_TYPE,
    p_check_asl                      IN             BOOLEAN,
    p_req_chg_initiator              IN             VARCHAR2,
    p_origin_doc_id                  IN             NUMBER,
    p_online_report_id               IN             NUMBER,
    p_user_id                        IN             NUMBER,
    p_login_id                       IN             NUMBER,
    p_sequence                       IN OUT NOCOPY  NUMBER,
    x_return_status                  OUT NOCOPY     VARCHAR2
  )
  IS
    l_api_name    CONSTANT varchar2(50)  := 'do_post_submission_check';
    l_api_version CONSTANT NUMBER        := 1.0;
    d_mod         CONSTANT VARCHAR2(100) := d_do_post_submission_check;
    d_position    NUMBER := 0;

  BEGIN
    IF po_log.d_proc
    THEN
      po_log.proc_begin(d_mod, 'p_api_version', p_api_version);
      po_log.proc_begin(d_mod, 'p_action_requested', p_action_requested);
      po_log.proc_begin(d_mod, 'p_document_type', p_document_type);
      po_log.proc_begin(d_mod, 'p_document_subtype', p_document_subtype);
      po_log.proc_begin(d_mod, 'p_document_level', p_document_level);
      po_log.proc_begin(d_mod, 'p_document_level_id', p_document_level_id);
      po_log.proc_begin(d_mod, 'p_check_asl', p_check_asl);
      po_log.proc_begin(d_mod, 'p_req_chg_initiator', p_req_chg_initiator);
      po_log.proc_begin(d_mod, 'p_origin_doc_id', p_origin_doc_id);
      po_log.proc_begin(d_mod, 'p_online_report_id', p_online_report_id);
      po_log.proc_begin(d_mod, 'p_user_id', p_user_id);
      po_log.proc_begin(d_mod, 'p_login_id', p_login_id);
      po_log.proc_begin(d_mod, 'p_sequence', p_sequence);
    END IF;

    -- Standard call to check for call compatibility
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name,
                                       g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    d_position := 10;

    -- TODO: Add custom code here.

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    d_position := 100;

  EXCEPTION
    WHEN OTHERS
    THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF po_log.d_exc
      THEN
        PO_LOG.exc(d_mod, d_position, SQLCODE || ': ' || SQLERRM);
        PO_LOG.proc_end(d_mod, 'd_position', d_position);
        PO_LOG.proc_end(d_mod, 'x_return_status', x_return_status);
        PO_LOG.proc_end(d_mod);
      END IF;

  END do_post_submission_check;

END PO_CUSTOM_SUBMISSION_CHECK_PVT;

/
