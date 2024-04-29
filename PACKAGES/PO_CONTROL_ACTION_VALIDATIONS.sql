--------------------------------------------------------
--  DDL for Package PO_CONTROL_ACTION_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CONTROL_ACTION_VALIDATIONS" AUTHID CURRENT_USER AS
/* $Header: PO_CONTROL_ACTION_VALIDATIONS.pls 120.0.12010000.3 2012/06/28 12:10:41 vlalwani noship $*/


c_cancel_api  CONSTANT VARCHAR2(30) :='CANCEL API';

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_cancel_action
--
--Effects: Validates the document for Cancel Action and insert the error in
--         online_eport_text table.
--Notes:
--  See the package body for more comments.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_cancel_action(
  p_da_call_rec IN OUT NOCOPY po_document_action_pvt.DOC_ACTION_CALL_TBL_REC_TYPE,
  p_key            IN po_session_gt.key%TYPE,
  p_user_id        IN po_lines.last_updated_by%TYPE,
  p_login_id       IN po_lines.last_update_login%TYPE,
  p_po_enc_flag    IN FINANCIALS_SYSTEM_PARAMETERS.purch_encumbrance_flag%TYPE,
  p_req_enc_flag   IN FINANCIALS_SYSTEM_PARAMETERS.req_encumbrance_flag%TYPE,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_data       OUT NOCOPY VARCHAR2,
  x_return_code    OUT NOCOPY VARCHAR2

);

-------------------------------------------------------------------------------
--Start of Comments
--Name: is_complex_work_po
--
-- Function:
-- This is wrapper function on  PO_COMPLEX_WORK_PVT.is_complex_work_po.
-- PO_COMPLEX_WORK_PVT.is_complex_work_po returns boolean,so cannot be used
-- in sql statmemt
-- So creating a wrapper on it, that will return 'Y'/'N'.
--Notes:
--  See the package body for more comments.
--End of Comments
-------------------------------------------------------------------------------

FUNCTION is_complex_work_po (p_doc_id IN NUMBER)
 RETURN VARCHAR2;

-------------------------------------------------------------------------------
--Start of Comments
--Name: val_doc_security
--
-- Function:
-- This is wrapper function on  PO_REQS_CONTROL_SV.val_doc_security.
-- PO_REQS_CONTROL_SV.val_doc_security returns boolean , so cannot be used
-- in sql statmemt
-- So creating a wrapper on it, that will return 'Y'/'N'.
--Notes:
--  See the package body for more comments.
--End of Comments
-------------------------------------------------------------------------------

FUNCTION val_doc_security (p_doc_agent_id            IN     NUMBER,
                           p_agent_id                IN     NUMBER,
                           p_doc_type                IN     VARCHAR2,
                           p_doc_subtype             IN     VARCHAR2) RETURN VARCHAR2;

END po_control_action_validations;

/
