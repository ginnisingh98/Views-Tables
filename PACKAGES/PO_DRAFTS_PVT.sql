--------------------------------------------------------
--  DDL for Package PO_DRAFTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DRAFTS_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_DRAFTS_PVT.pls 120.20.12010000.3 2009/06/01 14:11:21 ababujan ship $ */

g_ACCEPT_ALL CONSTANT VARCHAR2(10) := 'ACCEPT_ALL';
g_REJECT_ALL CONSTANT VARCHAR2(10) := 'REJECT_ALL';
g_LINE_DISP  CONSTANT VARCHAR2(10) := 'LINE_DISP';

g_status_DRAFT           CONSTANT PO_DRAFTS.status%TYPE := 'DRAFT';
g_status_IN_PROCESS      CONSTANT PO_DRAFTS.status%TYPE := 'IN PROCESS';
g_status_PDOI_PROCESSING CONSTANT PO_DRAFTS.status%TYPE := 'PDOI PROCESSING';
g_status_PDOI_ERROR      CONSTANT PO_DRAFTS.status%TYPE := 'PDOI ERROR';
g_status_COMPLETED       CONSTANT PO_DRAFTS.status%TYPE := 'COMPLETED';

g_call_mod_HTML_UI   CONSTANT VARCHAR2(30) := 'HTML UI';
g_call_mod_PDOI      CONSTANT VARCHAR2(30) := 'PDOI';
g_call_mod_API       CONSTANT VARCHAR2(30) := 'API';
g_call_mod_FORM      CONSTANT VARCHAR2(30) := 'FORM';
g_call_mod_UNKNOWN   CONSTANT VARCHAR2(30) := 'UNKNOWN';
g_call_mod_FORMS_PO_SUMMARY   CONSTANT VARCHAR2(30) := 'FORMS PO SUMMARY'; --<Bug#4382472>
g_call_mod_HTML_UI_SAVE   CONSTANT VARCHAR2(30) := 'HTML UI SAVE';

g_upload_status_PENDING CONSTANT VARCHAR2(10) := 'PENDING';
g_upload_status_RUNNING CONSTANT VARCHAR2(10) := 'RUNNING';
g_upload_status_ERROR   CONSTANT VARCHAR2(10) := 'ERROR';

g_chg_accepted_flag_ACCEPT CONSTANT VARCHAR2(1) := 'Y';
g_chg_accepted_flag_REJECT CONSTANT VARCHAR2(1) := 'N';
g_chg_accepted_flag_NOTIFY CONSTANT VARCHAR2(1) := 'I'; -- bug5149827

TYPE DRAFT_INFO_REC_TYPE IS RECORD
( draft_id                      PO_DRAFTS.draft_id%TYPE,
  po_header_id                  PO_HEADERS_ALL.po_header_id%TYPE,
  doc_type                      PO_DOCUMENT_TYPES.document_type_code%TYPE,
  doc_subtype                   PO_DOCUMENT_TYPES.document_subtype%TYPE,
  ga_flag                       PO_HEADERS_ALL.global_agreement_flag%TYPE,
  new_document                  VARCHAR2(1),
  headers_changed               VARCHAR2(1),
  lines_changed                 VARCHAR2(1),
  line_locations_changed        VARCHAR2(1),
  distributions_changed         VARCHAR2(1),
  ga_org_assign_changed         VARCHAR2(1),
  price_diff_changed            VARCHAR2(1),
  notification_ctrl_changed     VARCHAR2(1),
  attr_values_changed           VARCHAR2(1),
  attr_values_tlp_changed       VARCHAR2(1),
  price_adj_changed             VARCHAR2(1) --Enhanced Pricing
);


FUNCTION draft_id_nextval RETURN NUMBER;

PROCEDURE populate_draft_info
( p_draft_id IN NUMBER,
  p_po_header_id IN NUMBER,
  x_draft_info OUT NOCOPY DRAFT_INFO_REC_TYPE
);

PROCEDURE transfer_draft_to_txn
( p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2,
  p_draft_id IN NUMBER,
  p_po_header_id IN NUMBER,
  p_delete_processed_draft IN VARCHAR2,
  p_acceptance_action IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE remove_draft_changes
( p_draft_id IN NUMBER,
  p_exclude_ctrl_tbl IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE apply_changes
( p_draft_info IN DRAFT_INFO_REC_TYPE
);

PROCEDURE find_draft
( p_po_header_id IN NUMBER,
  x_draft_id OUT NOCOPY NUMBER,
  x_draft_status OUT NOCOPY VARCHAR2,
  x_draft_owner_role OUT NOCOPY VARCHAR2
);

PROCEDURE find_draft
( p_po_header_id IN NUMBER,
  x_draft_id OUT NOCOPY NUMBER
);

PROCEDURE get_request_id
( p_draft_id IN NUMBER,
  x_request_id OUT NOCOPY NUMBER
);

PROCEDURE get_lock_owner_info
( p_po_header_id IN NUMBER,
  x_lock_owner_role OUT NOCOPY VARCHAR2,
  x_lock_owner_user_id OUT NOCOPY NUMBER
);

PROCEDURE set_lock_owner_info
( p_po_header_id IN NUMBER,
  p_role IN VARCHAR2,
  p_role_user_id IN NUMBER
);

PROCEDURE update_permission_check
( p_calling_module IN VARCHAR2,
  p_po_header_id IN NUMBER,
  p_role IN VARCHAR2,
  p_skip_cat_upload_chk IN VARCHAR2 := NULL,
  x_update_allowed OUT NOCOPY VARCHAR2,
  x_locking_applicable OUT NOCOPY VARCHAR2,
  x_unlock_required OUT NOCOPY VARCHAR2,
  x_message OUT NOCOPY VARCHAR2
);

PROCEDURE update_permission_check
( p_calling_module IN VARCHAR2,
  p_po_header_id IN NUMBER,
  p_role IN VARCHAR2,
  p_skip_cat_upload_chk IN VARCHAR2 := NULL,
  x_update_allowed OUT NOCOPY VARCHAR2,
  x_locking_applicable OUT NOCOPY VARCHAR2,
  x_unlock_required OUT NOCOPY VARCHAR2,
  x_message OUT NOCOPY VARCHAR2,
  x_token_name_tbl OUT NOCOPY PO_TBL_VARCHAR30,
  x_token_value_tbl OUT NOCOPY PO_TBL_VARCHAR2000
);

PROCEDURE update_permission_check
( p_calling_module IN VARCHAR2,
  p_po_header_id IN NUMBER,
  p_role IN VARCHAR2,
  p_skip_cat_upload_chk IN VARCHAR2 := NULL,
  x_update_allowed OUT NOCOPY VARCHAR2,
  x_locking_applicable OUT NOCOPY VARCHAR2,
  x_unlock_required OUT NOCOPY VARCHAR2,
  x_message OUT NOCOPY VARCHAR2,
  x_message_text OUT NOCOPY VARCHAR2
);

PROCEDURE unlock_document
( p_po_header_id IN NUMBER
);

PROCEDURE lock_document
( p_po_header_id IN NUMBER,
  p_role IN VARCHAR2,
  p_role_user_id IN NUMBER,
  p_unlock_current IN VARCHAR2
);

FUNCTION is_locking_applicable
( p_po_header_id IN NUMBER,
  p_role IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION is_draft_applicable
( p_po_header_id IN NUMBER,
  p_role IN VARCHAR2
) RETURN VARCHAR2;

PROCEDURE lock_document_with_validate
( p_calling_module IN VARCHAR2,
  p_po_header_id IN NUMBER,
  p_role IN VARCHAR2,
  p_role_user_id IN NUMBER,
  x_locking_allowed OUT NOCOPY VARCHAR2,
  x_message OUT NOCOPY VARCHAR2,
  x_message_text OUT NOCOPY VARCHAR2
);

PROCEDURE update_draft_status
( p_draft_id IN NUMBER,
  p_new_status IN VARCHAR2
);

FUNCTION pending_changes_exist
( p_po_header_id IN NUMBER
) RETURN VARCHAR2;

FUNCTION changes_exist_for_draft
( p_draft_id_tbl PO_TBL_NUMBER
) RETURN PO_TBL_VARCHAR1;

FUNCTION lock_merge_view_records
( p_view_name   IN VARCHAR2,
  p_entity_id     IN NUMBER,
  p_draft_id      IN NUMBER
) RETURN VARCHAR2;

FUNCTION is_pending_buyer_acceptance
( p_po_header_id IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_supplier_auth_enabled_flag
(p_po_header_id IN NUMBER
 ) RETURN VARCHAR2;

FUNCTION set_supplier_auth_enabled_flag
(p_po_header_id IN NUMBER,
 p_supplier_auth_enabled_flag IN VARCHAR2
 ) RETURN VARCHAR2;

FUNCTION get_cat_admin_auth_enable_flag
(p_po_header_id IN NUMBER
 ) RETURN VARCHAR2;

FUNCTION set_cat_admin_auth_enable_flag
(p_po_header_id IN NUMBER,
 p_cat_admin_auth_enable_flag IN VARCHAR2
 ) RETURN VARCHAR2;

-- bug 5014131 START
PROCEDURE get_upload_status_info
( p_po_header_id IN NUMBER,
  p_role IN VARCHAR2,
  x_upload_status_code OUT NOCOPY VARCHAR2,
  x_upload_requestor_role_id OUT NOCOPY NUMBER,
  x_upload_job_number OUT NOCOPY NUMBER,
  x_upload_status_display OUT NOCOPY VARCHAR2,
  x_upload_is_error OUT NOCOPY NUMBER
);

PROCEDURE get_in_process_upload_info
( p_po_header_id IN NUMBER,
  x_upload_in_progress OUT NOCOPY VARCHAR2,
  x_upload_status_code OUT NOCOPY VARCHAR2,
  x_upload_requestor_role OUT NOCOPY VARCHAR2,
  x_upload_requestor_role_id OUT NOCOPY NUMBER,
  x_upload_job_number OUT NOCOPY NUMBER,
  x_upload_status_display OUT NOCOPY VARCHAR2
);
-- bug 5014131 START

-- bug5090429 START
PROCEDURE unlock_document_and_send_notif
( p_commit       IN VARCHAR2 := FND_API.G_FALSE,
  p_po_header_id IN NUMBER
);
-- bug5090429 END

--<Bug#4382472 Start>
PROCEDURE unlock_document_and_send_notif
( p_commit       IN VARCHAR2 := FND_API.G_FALSE,
  p_po_header_id IN NUMBER,
  p_org_id       IN NUMBER,
  p_segment1     IN VARCHAR2,
  p_revision_num IN NUMBER
);

--<Bug#4382472 End>

END PO_DRAFTS_PVT;

/
