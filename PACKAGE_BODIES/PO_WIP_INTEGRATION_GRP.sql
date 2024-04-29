--------------------------------------------------------
--  DDL for Package Body PO_WIP_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WIP_INTEGRATION_GRP" AS
/* $Header: POXGWIPB.pls 115.3 2004/01/15 03:06:03 tpoon noship $*/

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_pkg_name CONSTANT varchar2(30) := 'PO_WIP_INTEGRATION_GRP';
g_module_prefix  CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';

-----------------------------------------------------------------------------
--Start of Comments
--Name: update_document
--Function:
--  Calls the PO Change API, which validates and applies the requested
--  changes and any derived changes to the Purchase Order, Purchase
--  Agreement, or Release.
--Notes:
--  For details, see the comments on PO_DOCUMENT_UPDATE_GRP.update_document.
--End of Comments
-----------------------------------------------------------------------------
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
  x_api_errors             OUT NOCOPY PO_API_ERRORS_REC_TYPE
) IS
  l_api_name     CONSTANT VARCHAR(30) := 'UPDATE_DOCUMENT';
  l_api_version  CONSTANT NUMBER := 1.0;
BEGIN
  -- Standard API initialization:
  IF NOT FND_API.Compatible_API_Call ( l_api_version, p_api_version,
                                       l_api_name, g_pkg_name ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Call the PO Change API.
  PO_DOCUMENT_UPDATE_GRP.update_document(
    p_api_version => 1.0,
    p_init_msg_list => p_init_msg_list,
    x_return_status => x_return_status,
    p_changes => p_changes,
    p_run_submission_checks => p_run_submission_checks,
    p_launch_approvals_flag => p_launch_approvals_flag,
    p_buyer_id => p_buyer_id,
    p_update_source => p_update_source,
    p_override_date => p_override_date,
    x_api_errors => x_api_errors
  );
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Add the errors on the API message list to x_api_errors.
    PO_DOCUMENT_UPDATE_PVT.add_message_list_errors (
      p_api_errors => x_api_errors,
      x_return_status => x_return_status
    );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    -- Add the unexpected error to the API message list.
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_api_name );
    -- Add the errors on the API message list to x_api_errors.
    PO_DOCUMENT_UPDATE_PVT.add_message_list_errors (
      p_api_errors => x_api_errors,
      x_return_status => x_return_status
    );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END update_document;


-----------------------------------------------------------------------------
--Start of Comments
--Name: cancel_document
--Function:
--  Wrapper for WIP to Cancel Purchasing Document
--  Calls the PO Control API with Action=CANCEL to cancel the Purchase Order,
--  Purchase Agreement, or Release.
--Notes:
--  For details, see the comments on PO_Document_Control_GRP.control_document.
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE cancel_document (
    p_api_version            IN NUMBER,
    p_doc_type               IN PO_TBL_VARCHAR30,
    p_doc_subtype            IN PO_TBL_VARCHAR30,
    p_doc_id                 IN PO_TBL_NUMBER,
    p_doc_num                IN PO_TBL_VARCHAR30,
    p_release_id             IN PO_TBL_NUMBER,
    p_release_num            IN PO_TBL_NUMBER,
    p_doc_line_id            IN PO_TBL_NUMBER,
    p_doc_line_num           IN PO_TBL_NUMBER,
    p_doc_line_loc_id        IN PO_TBL_NUMBER,
    p_doc_shipment_num       IN PO_TBL_NUMBER,
    p_source                 IN VARCHAR2,
    p_cancel_date            IN DATE,
    p_cancel_reason          IN VARCHAR2,
    p_cancel_reqs_flag       IN VARCHAR2,
    p_print_flag             IN VARCHAR2,
    p_note_to_vendor         IN VARCHAR2,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2
) IS

l_api_name     CONSTANT VARCHAR(30) := 'CANCEL_DOCUMENT';
l_progress     VARCHAR2(3) := '000';

BEGIN

-- Call Control Document API to Cancel PO Documents
l_progress := '010';
FOR i IN 1..p_doc_id.count LOOP

    l_progress := '020';
    PO_Document_Control_GRP.control_document
           (p_api_version      => p_api_version,
            p_init_msg_list    => FND_API.G_FALSE,
            p_commit           => FND_API.G_FALSE,
            x_return_status    => x_return_status,
            p_doc_type         => p_doc_type(i),
            p_doc_subtype      => p_doc_subtype(i),
            p_doc_id           => p_doc_id(i),
            p_doc_num          => p_doc_num(i),
            p_release_id       => p_release_id(i),
            p_release_num      => p_release_num(i),
            p_doc_line_id      => p_doc_line_id(i),
            p_doc_line_num     => p_doc_line_num(i),
            p_doc_line_loc_id  => p_doc_line_loc_id(i),
            p_doc_shipment_num => p_doc_shipment_num(i),
            p_source           => p_source,
            p_action           => 'CANCEL',
            p_action_date      => p_cancel_date,
            p_cancel_reason    => p_cancel_reason,
            p_cancel_reqs_flag => p_cancel_reqs_flag,
            p_print_flag       => p_print_flag,
            p_note_to_vendor   => p_note_to_vendor);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

END LOOP;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END cancel_document;


-----------------------------------------------------------------------------
--Start of Comments
--Name: cancel_document
--Function:
--  Wrapper for WIP to Update Requisition. Calls Requisition Update Group API
--Notes:
-- Detailed comments maintained in the Package Body PO_REQ_DOCUMENT_UPDATE_PVT.update_requisition
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE update_requisition (
    p_api_version            IN NUMBER,
    p_req_changes            IN OUT NOCOPY PO_REQ_CHANGES_REC_TYPE,
    p_update_source          IN VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2
) IS

BEGIN

--Call the group procedure to update requisition
PO_REQ_DOCUMENT_UPDATE_GRP.update_requisition(
    p_api_version => p_api_version,
    p_req_changes => p_req_changes,
    p_update_source => p_update_source,
    x_return_status  => x_return_status,
    x_msg_count  => x_msg_count,
    x_msg_data  => x_msg_data);

END update_requisition;

-- Wrapper for WIP to Cancel Requisition
-- Detailed comments maintained in the Package Body PO_REQ_DOCUMENT_CANCEL_PVT.cancel_requisition
PROCEDURE cancel_requisition (
    p_api_version            IN NUMBER,
    p_req_header_id          IN PO_TBL_NUMBER,
    p_req_line_id            IN PO_TBL_NUMBER,
    p_cancel_date            IN DATE,
    p_cancel_reason          IN VARCHAR2,
    p_source                 IN VARCHAR2,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2
) IS

BEGIN

--Call the group procedure to cancel requisition
PO_REQ_DOCUMENT_CANCEL_GRP.cancel_requisition(
    p_api_version => 1.0,
    p_req_header_id => p_req_header_id,
    p_req_line_id => p_req_line_id,
    p_cancel_date => p_cancel_date,
    p_cancel_reason => p_cancel_reason,
    p_source => p_source,
    x_return_status  => x_return_status,
    x_msg_count  => x_msg_count,
    x_msg_data  => x_msg_data);

END cancel_requisition;

END PO_WIP_INTEGRATION_GRP;

/
