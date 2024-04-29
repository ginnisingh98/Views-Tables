--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_ACTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_ACTION_UTIL" AUTHID CURRENT_USER AS
-- $Header: POXDAULS.pls 120.0.12010000.2 2012/07/06 15:10:45 vlalwani ship $

-- Global Constants


-- Global Types

TYPE DOC_STATE_ARRAY_TBL_TYPE IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

TYPE DOC_STATE_REC_TYPE IS RECORD
 (
    auth_states            DOC_STATE_ARRAY_TBL_TYPE,
    closed_states          DOC_STATE_ARRAY_TBL_TYPE,
    hold_flag              VARCHAR(1),
    frozen_flag            VARCHAR(1),
    fully_reserved_flag    VARCHAR(1)
 );


-- Methods


FUNCTION check_doc_state(
   p_document_id        IN     NUMBER
,  p_document_type      IN     VARCHAR2
,  p_line_id            IN     NUMBER      DEFAULT NULL
,  p_shipment_id        IN     NUMBER      DEFAULT NULL
,  p_allowed_states     IN     PO_DOCUMENT_ACTION_UTIL.DOC_STATE_REC_TYPE
,  x_return_status      OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN;


PROCEDURE get_doc_preparer_id(
   p_document_id        IN     NUMBER
,  p_document_type      IN     VARCHAR2
,  x_return_status      OUT NOCOPY  VARCHAR2
,  x_preparer_id        OUT NOCOPY  NUMBER
);

PROCEDURE get_employee_id(
   p_user_id            IN          NUMBER
,  x_return_status      OUT NOCOPY  VARCHAR2
,  x_employee_flag      OUT NOCOPY  BOOLEAN
,  x_employee_id        OUT NOCOPY  NUMBER
);


PROCEDURE get_employee_info(
   p_user_id            IN          NUMBER
,  x_return_status      OUT NOCOPY  VARCHAR2
,  x_employee_flag      OUT NOCOPY  BOOLEAN
,  x_employee_id        OUT NOCOPY  NUMBER
,  x_employee_name      OUT NOCOPY  VARCHAR2
,  x_location_id        OUT NOCOPY  NUMBER
,  x_location_code      OUT NOCOPY  VARCHAR2
,  x_is_buyer_flag      OUT NOCOPY  BOOLEAN
);

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
);


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
);

--<Bug 14271696 :Cancel Refactoring Project>
-- Made the procedure "update_doc_auth_status" public
-- as the same code logic was need while updating the doucmnet
-- during Cancel [Called from po_document_cancel_pvt.approve_entity(..)].
-- Cannot use "change_doc_auth_state" as it updates the action history table
-- For Cancel, action history will be stamped with action='CANCEL'
-- and not 'APPROVE' and 'SUBMIT'.
-- Action Histoy update is handled in Cancel code itself.
PROCEDURE update_doc_auth_status(
   p_document_id        IN          NUMBER
,  p_document_type      IN          VARCHAR2
,  p_document_subtype   IN          VARCHAR2
,  p_new_status         IN          VARCHAR2
,  p_user_id            IN          NUMBER
,  p_login_id           IN          NUMBER
,  x_return_status      OUT NOCOPY  VARCHAR2
);

END PO_DOCUMENT_ACTION_UTIL;

/
