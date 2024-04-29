--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_UPDATE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_UPDATE_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGCPOS.pls 120.2.12010000.3 2013/09/12 10:49:47 jemishra ship $*/

-- <PO_CHANGE_API_FPJ START>
-- In file version 115.4, added an overloaded update_document procedure that
-- takes in changes as a PO_CHANGES_REC_TYPE object. This allows the caller to
-- request changes to multiple lines, shipments, and distributions at once.

-------------------------------------------------------------------------------
--Start of Comments
--Name: update_document
--Function:
-- Validates and applies the requested changes and any derived
-- changes to the Purchase Order, Purchase Agreement, or Release.
--Note:
-- For details, see the package body comments for
-- PO_DOCUMENT_UPDATE_PVT.update_document.
--End of Comments
--------------------------------------------------------------------------------

g_process_param_chge_only VARCHAR2(1) := 'N';  --<INVCONV R12>

PROCEDURE update_document (
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2,
  p_changes                IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  p_run_submission_checks  IN VARCHAR2,
  p_launch_approvals_flag  IN VARCHAR2,
  p_buyer_id               IN NUMBER,
  p_update_source          IN VARCHAR2,
  p_override_date          IN DATE,
  x_api_errors             OUT NOCOPY PO_API_ERRORS_REC_TYPE,
  p_approval_background_flag IN VARCHAR2 DEFAULT NULL,
  p_mass_update_releases   IN VARCHAR2 DEFAULT NULL, -- Bug 3373453
  p_req_chg_initiator      IN VARCHAR2 DEFAULT NULL --Bug 14549341
);

-- Bug 3605355 START
-------------------------------------------------------------------------------
--Start of Comments
--Name: launch_po_approval_wf
--Function:
--  Launches the Document Approval workflow for the given document.
--Note:
-- For details, see the package body comments for
-- PO_DOCUMENT_UPDATE_PVT.launch_po_approval_wf.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE launch_po_approval_wf (
  p_api_version           IN NUMBER,
  p_init_msg_list         IN VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2,
  p_document_id           IN NUMBER,
  p_document_type         IN PO_DOCUMENT_TYPES_ALL_B.document_type_code%TYPE,
  p_document_subtype      IN PO_DOCUMENT_TYPES_ALL_B.document_subtype%TYPE,
  p_preparer_id           IN NUMBER,
  p_approval_background_flag IN VARCHAR2,
  p_mass_update_releases  IN VARCHAR2
);
-- Bug 3605355 END

-- Parameter value constants:

G_PARAMETER_YES VARCHAR2(1) := PO_CORE_S.G_PARAMETER_YES;
G_PARAMETER_NO  VARCHAR2(1) := PO_CORE_S.G_PARAMETER_NO;

-- Constants for the p_update_source parameter of update_document:

G_UPDATE_SOURCE_OM CONSTANT VARCHAR2(20)
  := PO_DOCUMENT_UPDATE_PVT.G_UPDATE_SOURCE_OM; -- OM (Drop Ship Integration)

-- Entity type constants:

G_ENTITY_TYPE_CHANGES CONSTANT VARCHAR2(30)
  := PO_DOCUMENT_UPDATE_PVT.G_ENTITY_TYPE_CHANGES;
G_ENTITY_TYPE_LINES CONSTANT VARCHAR2(30)
  := PO_DOCUMENT_UPDATE_PVT.G_ENTITY_TYPE_LINES;
G_ENTITY_TYPE_SHIPMENTS CONSTANT VARCHAR2(30)
  := PO_DOCUMENT_UPDATE_PVT.G_ENTITY_TYPE_SHIPMENTS;
G_ENTITY_TYPE_DISTRIBUTIONS CONSTANT VARCHAR2(30)
  := PO_DOCUMENT_UPDATE_PVT.G_ENTITY_TYPE_DISTRIBUTIONS;

-- Use this constant in the change object to indicate that a field should be
-- set to NULL.
G_NULL_NUM CONSTANT NUMBER := PO_DOCUMENT_UPDATE_PVT.G_NULL_NUM;

-- <PO_CHANGE_API_FPJ END>

-- <PO_CHANGE_API_FPJ START>
-- In file version 115.3, removed the P_INTERFACE_TYPE and P_TRANSACTION_ID
-- parameters from UPDATE_DOCUMENT and added an X_API_ERRORS parameter.
-- The PO Change API will no longer write error messages to the
-- PO_INTERFACE_ERRORS table. Instead, all of the errors will be returned
-- in the x_api_errors object.
-- <PO_CHANGE_API_FPJ END>

/*=====================================================================
 * PROCEDURE update_document
 * API that updates qty, price or/and promised_date of a document.
 * Parameters:
 * - p_PO_NUMBER: po number of the document
 * - p_RELEASE_NUMBER: Null if not a release, otherwise, release number
 * - p_REVISION_NUMBER: should be the latest revision
 * - p_LINE_NUMBER: Line number of the doc.
 * - p_SHIPMENT_NUMBER: Shipment number
 * - p_NEW_QUANTITY : desired new quantity for a line/shipment
 * - p_NEW_PRICE    : desired new price for a line/shipment
 * - p_NEW_PROMISED_DATE: desired new promised date for a shipment
 * - p_NEW_NEED_BY_DATE: desired new need-by date for a shipment
 * - p_LAUNCH_APPROVALS_FLAG: determines whether approval workflow is
 *                            executed or not after update
 * - p_UPDATE_SOURCE: for future usage
 * - p_OVERRIDE_DATE: If funds are reserved for the document, this
 *                    parameter is to speicify the date that is used
 *                    to unreserve the doc. It's meaningless if
 *                    encumbrance is not used.
 * - p_VERSION: version of the API that is intended to be used
 * - x_result: return status of the call:
 *               1 if the API completed successfully;
 *               0 if there will any errors.
 * - x_api_errors: If x_result = 0, this object will contain all of the error
 *                 messages.
 * - - p_BUYER_NAME:  Added as a part of bug fix 2986718.
 *======================================================================*/
PROCEDURE update_document
(
  p_PO_NUMBER			IN	VARCHAR2,
  p_RELEASE_NUMBER		IN	NUMBER,
  p_REVISION_NUMBER		IN	NUMBER,
  p_LINE_NUMBER			IN	NUMBER,
  p_SHIPMENT_NUMBER		IN	NUMBER,
  p_NEW_QUANTITY		IN	NUMBER,
  p_NEW_PRICE			IN	NUMBER,
  p_NEW_PROMISED_DATE		IN	DATE,
  p_NEW_NEED_BY_DATE		IN	DATE,
  p_LAUNCH_APPROVALS_FLAG	IN	VARCHAR2,
  p_UPDATE_SOURCE		IN	VARCHAR2,
  p_OVERRIDE_DATE		IN	DATE,
  p_VERSION			IN	NUMBER,
  x_result			IN OUT NOCOPY	NUMBER,
  x_api_errors                  OUT NOCOPY PO_API_ERRORS_REC_TYPE,
  p_BUYER_NAME       IN           VARCHAR2  default NULL,
  --<INVCONV R12 START>
  p_secondary_qty               IN NUMBER ,
  p_preferred_grade             IN VARCHAR2
  --<INVCONV R12 END>
);


/*=====================================================================
 * PROCEDURE update_po
 * API that validates and applies the requested changes and any derived
 * changes to the Purchase Order
 * Parameters:
 * - p_api_version:
 *  -- API version number expected by the caller
 * - p_init_msg_list:
 *  -- If FND_API.G_TRUE, the API will initialize the standard API message list.
 * - x_return_status:
 *  --  FND_API.G_RET_STS_SUCCESS if the API succeeded and the changes are applied.
 *  --  FND_API.G_RET_STS_ERROR if one or more validations failed.
 *  --  FND_API.G_RET_STS_UNEXP_ERROR if an unexpected error occurred.
 * - p_changes:
 *  --  object with the changes to make to the document
 * - x_api_errors:
 *  --  If x_return_status is not FND_API.G_RET_STS_SUCCESS, this
 *  --  PL/SQL object will contain all the error messages, including field-level
 *  --  validation errors, submission checks errors, and unexpected errors.
 * - p_pop_int_err:
 *  --  If x_return_status is not FND_API.G_RET_STS_SUCCESS,
 *  --  if its value is Y, this will populate the errors in interface table
 *  --  it will parse x_api_errors and populates po_interface error table.
 * - x_err_lst_id
 *  --  Unique id mapped to request id column of po interface error
 *  --  to find all the errors from interface tables.
 *  --  this will be populated only when x_api_errors is not empty and
 *  --  p_pop_int_err is set to yes.
 *======================================================================*/
PROCEDURE update_document (
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2,
  p_changes                IN OUT NOCOPY po_pub_update_rec_type,
  x_api_errors             OUT NOCOPY PO_API_ERRORS_REC_TYPE
);

END PO_DOCUMENT_UPDATE_GRP;

/
