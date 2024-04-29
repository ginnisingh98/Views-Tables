--------------------------------------------------------
--  DDL for Package PO_DRAFTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DRAFTS_GRP" AUTHID CURRENT_USER AS
/* $Header: PO_DRAFTS_GRP.pls 120.7 2006/09/18 14:24:19 arudas noship $ */

g_NO_DRAFT CONSTANT VARCHAR2(30) := 'NO_DRAFT';
g_SUPPLIER_SUBMISSION_PENDING CONSTANT VARCHAR2(30) := 'SUPPLIER_SUBMISSION_PENDING';
g_SUPPLIER_CHANGES_SUBMITTED CONSTANT VARCHAR2(30) := 'SUPPLIER_CHANGES_SUBMITTED';
g_CAT_ADMIN_SUBMISSION_PENDING CONSTANT VARCHAR2(30) := 'CAT_ADMIN_SUBMISSION_PENDING';
g_CAT_ADMIN_CHANGES_SUBMITTED CONSTANT VARCHAR2(30) := 'CAT_ADMIN_CHANGES_SUBMITTED';

PROCEDURE get_online_auth_status_code
( p_api_version             IN NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  p_po_header_id            IN NUMBER,
  x_online_auth_status_code OUT NOCOPY VARCHAR2
);

PROCEDURE supplier_auth_allowed
( p_api_version       IN NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2,
  p_po_header_id      IN NUMBER,
  x_authoring_allowed OUT NOCOPY VARCHAR2,
  x_message           OUT NOCOPY VARCHAR2
);

PROCEDURE get_upload_status_info
( p_api_version       IN NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2,
  p_po_header_id IN NUMBER,
  p_role IN VARCHAR2,
  x_upload_status_code OUT NOCOPY VARCHAR2,
  x_upload_requestor_role_id OUT NOCOPY NUMBER,
  x_upload_job_number OUT NOCOPY NUMBER,
  x_upload_status_display OUT NOCOPY VARCHAR2,
  x_upload_is_error OUT NOCOPY NUMBER
);

PROCEDURE get_in_process_upload_info
( p_api_version IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
	p_po_header_id IN NUMBER,
  x_upload_in_progress OUT NOCOPY VARCHAR2,
  x_upload_status_code OUT NOCOPY VARCHAR2,
  x_upload_requestor_role OUT NOCOPY VARCHAR2,
  x_upload_requestor_role_id OUT NOCOPY NUMBER,
  x_upload_job_number OUT NOCOPY NUMBER,
  x_upload_status_display OUT NOCOPY VARCHAR2
);

PROCEDURE discard_upload_error
( p_api_version IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
	p_po_header_id IN NUMBER
);

PROCEDURE lock_document_with_validate
( p_api_version IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  p_calling_module IN VARCHAR2,
  p_po_header_id IN NUMBER,
  p_role IN VARCHAR2,
  p_role_user_id IN NUMBER,
  x_locking_allowed OUT NOCOPY VARCHAR2,
  x_message OUT NOCOPY VARCHAR2,
  x_message_text OUT NOCOPY VARCHAR2
);

END PO_DRAFTS_GRP;

 

/
