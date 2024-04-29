--------------------------------------------------------
--  DDL for Package Body PO_DRAFTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DRAFTS_GRP" AS
/* $Header: PO_DRAFTS_GRP.plb 120.10.12010000.2 2011/10/13 10:37:41 vlalwani ship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_DRAFTS_GRP');

-----------------------------------------------------------------------
--Start of Comments
--Name: get_online_auth_status_code
--Function:
--  Gets the online authoring status. It states who is making draft changes
--  and at what stage the draft chages are at.
--Parameters:
--IN:
--p_api_version
--  API Version
--p_po_header_id
--  document header id
--IN OUT:
--OUT:
--x_return_status
--  Return Status
--x_online_auth_status_code
--  Online Authoring status of the document. Possible values:
-- All of the following contants are defined in this package:
--   g_NO_DRAFT if no draft changes exist
--   g_SUPPLIER_SUBMISSION_PENDING if supplier is making draft changes
--   g_SUPPLIER_CHANGES_SUBMITTED if supplier's changes are pending acceptance
--   g_CAT_ADMIN_SUBMISSION_PENDING if cat admin is making draft changes
--   g_CAT_ADMIN_CHANGES_SUBMITTED if cat admin's changes are pending acceptance
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_online_auth_status_code
( p_api_version             IN NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  p_po_header_id            IN NUMBER,
  x_online_auth_status_code OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'get_online_auth_status_code';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || '.' || d_api_name || '.';
d_position NUMBER;

l_api_version NUMBER := 1.0;

l_draft_id PO_DRAFTS.draft_id%TYPE;
l_draft_status PO_DRAFTS.status%TYPE;
l_draft_owner_role PO_DRAFTS.owner_role%TYPE;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (NOT FND_API.compatible_api_call
          ( p_current_version_number => l_api_version,
            p_caller_version_number => p_api_version,
            p_api_name => d_api_name,
            p_pkg_name => d_pkg_name
          )
      ) THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_online_auth_status_code := g_NO_DRAFT;

  PO_DRAFTS_PVT.find_draft
  ( p_po_header_id     => p_po_header_id,
    x_draft_id         => l_draft_id,
    x_draft_status     => l_draft_status,
    x_draft_owner_role => l_draft_owner_role
  );

  d_position := 10;

  IF (l_draft_id IS NOT NULL) THEN
    IF (l_draft_owner_role = PO_GLOBAL.g_ROLE_SUPPLIER) THEN
      IF (l_draft_status IN (PO_DRAFTS_PVT.g_status_DRAFT,
                             PO_DRAFTS_PVT.g_status_PDOI_PROCESSING)) THEN

        d_position := 20;
        x_online_auth_status_code := g_SUPPLIER_SUBMISSION_PENDING;

      ELSIF (l_draft_status = PO_DRAFTS_PVT.g_status_IN_PROCESS) THEN

        d_position := 30;
        x_online_auth_status_code := g_SUPPLIER_CHANGES_SUBMITTED;
      END IF;

    ELSIF  (l_draft_owner_role = PO_GLOBAL.g_ROLE_CAT_ADMIN) THEN
      IF (l_draft_status IN (PO_DRAFTS_PVT.g_status_DRAFT,
                             PO_DRAFTS_PVT.g_status_PDOI_PROCESSING)) THEN

        d_position := 40;
        x_online_auth_status_code := g_CAT_ADMIN_SUBMISSION_PENDING;

      ELSIF (l_draft_status = PO_DRAFTS_PVT.g_status_IN_PROCESS) THEN
        d_position := 50;
        x_online_auth_status_code := g_CAT_ADMIN_CHANGES_SUBMITTED;
      END IF;

    END IF;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_online_auth_status_code', x_online_auth_status_code);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
END get_online_auth_status_code;


-----------------------------------------------------------------------
--Start of Comments
--Name: supplier_auth_allowed
--Function:
--  Checks whether supplier authoring is allowed. To satisfy, document has to
--  meet the following:
--  1) Has to be a global agreement
--  2) Functional Lock can be obtained
--  3) Document is in updatable status (Not Cancelled, etc.)
--Parameters:
--IN:
--p_api_version
--  API Version
--p_po_header_id
--  document header id
--IN OUT:
--OUT:
--x_return_status
--  Return Status
--x_authoring_allowed
--  returns whether supplier authoring is allowed
--  FND_API.G_TRUE if authoring is allowed
--  FND_API.G_FALSE if authoring is not allowed
--x_message
--  reason for the failure, if authoring is not allowed
--End of Comments
------------------------------------------------------------------------
PROCEDURE supplier_auth_allowed
( p_api_version       IN NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2,
  p_po_header_id      IN NUMBER,
  x_authoring_allowed OUT NOCOPY VARCHAR2,
  x_message           OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'supplier_auth_allowed';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || '.' || d_api_name || '.';
d_position NUMBER;

l_api_version NUMBER := 1.0;

l_locking_applicable VARCHAR2(1);
l_unlock_required VARCHAR2(1);

l_po_status_rec PO_STATUS_REC_TYPE;
l_update_allowed VARCHAR2(1);
l_return_status VARCHAR2(1);
BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (NOT FND_API.compatible_api_call
          ( p_current_version_number => l_api_version,
            p_caller_version_number => p_api_version,
            p_api_name => d_api_name,
            p_pkg_name => d_pkg_name
          )
      ) THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_authoring_allowed := FND_API.G_TRUE;
  x_message := NULL;

  d_position := 10;

  IF (NOT PO_GA_PVT.is_global_agreement(p_po_header_id => p_po_header_id)) THEN
    x_authoring_allowed := FND_API.G_FALSE;
    x_message := 'PO_ONLINE_AUTH_NA';
    RETURN;
  END IF;

  d_position := 20;

  -- check whether supplier can take the functional lock of the document
  PO_DRAFTS_PVT.update_permission_check
  ( p_calling_module     => PO_DRAFTS_PVT.g_call_mod_HTML_UI,
    p_po_header_id       => p_po_header_id,
    p_role               => PO_GLOBAL.g_role_SUPPLIER,
    x_update_allowed     => x_authoring_allowed,
    x_locking_applicable => l_locking_applicable,
    x_unlock_required    => l_unlock_required,
    x_message            => x_message
  );

  IF (x_authoring_allowed = FND_API.G_FALSE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'update permission check failed');
    END IF;
  END IF;

  d_position := 30;

  -- bug4862194
  -- Removed the call to po_status_check because the checks for
  -- po status is already done when the agreement edit page is accessed.


  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
END supplier_auth_allowed;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_upload_status_info
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Parameters:
--IN:
--p_po_header_id
--  header_id of the document
--p_role
--  Role of the user
--IN OUT:
--OUT:
--  upload_status_code
--  upload_requestor_role_id id of the role
--  upload_job_id latest upload job id
--  upload_status_display
--  upload_is_error
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
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
) IS

d_api_name CONSTANT VARCHAR2(30) := 'get_upload_status_info';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || '.' || d_api_name || '.';
d_position NUMBER;

l_api_version NUMBER := 1.0;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (NOT FND_API.compatible_api_call
          ( p_current_version_number => l_api_version,
            p_caller_version_number => p_api_version,
            p_api_name => d_api_name,
            p_pkg_name => d_pkg_name
          )
      ) THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  d_position := 10;

  PO_DRAFTS_PVT.get_upload_status_info
  ( p_po_header_id => p_po_header_id,
    p_role => p_role,
    x_upload_status_code => x_upload_status_code,
    x_upload_requestor_role_id => x_upload_requestor_role_id,
    x_upload_job_number => x_upload_job_number,
    x_upload_status_display => x_upload_status_display,
    x_upload_is_error => x_upload_is_error --Bug#5518826
  );


  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
END get_upload_status_info;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_in_process_upload_info
--Function:
--  Return the information for the upload that in progress regardless
--  of the role
--Parameters:
--IN:
--p_po_header_id
--  header_id of the document
--p_role
--  role of the user
--IN OUT:
--OUT:
--  upload_in_progress: FND_API.G_TRUE if there's one upload that's not yet
--                      complete
--  upload_status_code
--  upload_requestor_role
--  upload_requestor_role_id id of the role
--  upload_job_id latest upload job id
--  upload_status_display
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
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
) IS

d_api_name CONSTANT VARCHAR2(30) := 'get_in_process_upload_info';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || '.' || d_api_name || '.';
d_position NUMBER;

l_api_version NUMBER := 1.0;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (NOT FND_API.compatible_api_call
          ( p_current_version_number => l_api_version,
            p_caller_version_number => p_api_version,
            p_api_name => d_api_name,
            p_pkg_name => d_pkg_name
          )
      ) THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  d_position := 10;

  PO_DRAFTS_PVT.get_in_process_upload_info
  ( p_po_header_id => p_po_header_id,
    x_upload_in_progress => x_upload_in_progress,
    x_upload_status_code => x_upload_status_code,
    x_upload_requestor_role => x_upload_requestor_role,
    x_upload_requestor_role_id => x_upload_requestor_role_id,
    x_upload_job_number => x_upload_job_number,
    x_upload_status_display => x_upload_status_display
  );


  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
END get_in_process_upload_info;

-----------------------------------------------------------------------
--Start of Comments
--Name: discard_upload_error
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  This procedure removes draft control record and unlock the document when
--  there is no draft changes for the doucment. This is called when
--  supplier/cat admin discards error.
--Parameters:
--IN:
--p_api_version
--  API Version
--p_po_header_id
--  document header id
--IN OUT:
--OUT:
--x_return_status
--  Return Status
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE discard_upload_error
( p_api_version IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
	p_po_header_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'discard_upload_error';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || '.' || d_api_name || '.';
d_position NUMBER;

l_api_version NUMBER := 1.0;
l_return_status VARCHAR2(1);

l_draft_id NUMBER;
 -- Bug 13037956
l_draft_status PO_DRAFTS.status%TYPE;
l_draft_owner_role PO_DRAFTS.owner_role%TYPE;

l_changes_exist_tbl PO_TBL_VARCHAR1;
l_unlock VARCHAR2(1) := FND_API.G_FALSE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (NOT FND_API.compatible_api_call
          ( p_current_version_number => l_api_version,
            p_caller_version_number => p_api_version,
            p_api_name => d_api_name,
            p_pkg_name => d_pkg_name
          )
      ) THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Bug 13037956  starts
  -- Getting the lock owner role as well
  PO_DRAFTS_PVT.find_draft
  ( p_po_header_id => p_po_header_id,
    x_draft_id => l_draft_id,
    x_draft_status =>l_draft_status,
    x_draft_owner_role =>l_draft_owner_role
  );

  d_position := 10;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.stmt(d_module, d_position, 'draft id for headerid ' ||
		            p_po_header_id || ' : ' || l_draft_id);
  END IF;

  -- document should be unlocked when:
  -- draft does not exist
  -- draft exists, but no changes have been inserted into draft tables.
  IF (l_draft_id IS NOT NULL) THEN
    d_position := 20;

    l_changes_exist_tbl :=
      PO_DRAFTS_PVT.changes_exist_for_draft
      ( p_draft_id_tbl => PO_TBL_NUMBER(l_draft_id)
      );

    -- Bug 13037956  starts
    -- changes_exist_for_draft returns true even when the current requset for uplaod fails
    -- if the any of teh previous  upload requests was successful but
    -- In such  case, the draft (po_drafts) status need to be set back to 'DRAFT'
    -- for cat.admin/supplier
    -- and draft record (po_drafts) should be deleted for role= Buyer as For Buyer the draft record is not retained

    IF (l_changes_exist_tbl(1) = FND_API.G_FALSE OR l_draft_owner_role =PO_GLOBAL.g_role_BUYER) THEN
      d_position := 30;

      l_unlock := FND_API.G_TRUE;

      PO_DRAFTS_PVT.remove_draft_changes
      ( p_draft_id => l_draft_id,
        p_exclude_ctrl_tbl => FND_API.G_FALSE,
        x_return_status => l_return_status
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSE

      PO_DRAFTS_PVT.update_draft_status( p_draft_id => l_draft_id,
                                         p_new_status =>PO_DRAFTS_PVT.g_status_DRAFT);

    END IF;
    -- Bug 13037956  ends
  ELSE
    d_position := 40;

    IF (PO_LOG.d_proc) THEN
      PO_LOG.stmt(d_module, d_position, 'draft changes do not exist. Simply unlock doc.');
    END IF;

    l_unlock := FND_API.G_TRUE;
  END IF;

  d_position := 50;

  IF ( l_unlock = FND_API.G_TRUE ) THEN
    PO_DRAFTS_PVT.unlock_document
    ( p_po_header_id => p_po_header_id
    );
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
END discard_upload_error;

-----------------------------------------------------------------------
--Start of Comments
--Name: lock_document_with_validate
--Function:
--  Same as lock_document, except that it performs update_permission_check
--  procedure before going to lock_document procedure.
--Parameters:
--IN:
--p_api_version
--  API Version
--p_calling_module
--  indicates where the procedure is called from. Possible Values
--p_po_header_id
--  document header id
--p_role
--  role of the user
--p_role_user_id
--  role id of the user
--OUT:
--x_locking_allowed
--  indicate whether locking was permitted
--x_message
--  error message when locking has not been permitted
--x_message_text
--  Display message when locking has not been permitted
--End of Comments
------------------------------------------------------------------------
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
) IS
d_api_name CONSTANT VARCHAR2(30) := 'lock_document_with_validate';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;
l_api_version NUMBER := 1.0;

l_message VARCHAR2(2000);
l_locking_applicable VARCHAR2(1);
l_unlock_required VARCHAR2(1);

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (NOT FND_API.compatible_api_call
          ( p_current_version_number => l_api_version,
            p_caller_version_number => p_api_version,
            p_api_name => d_api_name,
            p_pkg_name => d_pkg_name
          )
      ) THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  d_position := 10;

  PO_DRAFTS_PVT.lock_document_with_validate
  ( p_calling_module => p_calling_module,
    p_po_header_id   => p_po_header_id,
    p_role => p_role,
    p_role_user_id => p_role_user_id,
    x_locking_allowed => x_locking_allowed,
    x_message => x_message,
    x_message_text => x_message_text
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
END lock_document_with_validate;

END PO_DRAFTS_GRP;

/
