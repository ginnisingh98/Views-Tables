--------------------------------------------------------
--  DDL for Package Body PO_REQ_DOCUMENT_UPDATE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_DOCUMENT_UPDATE_GRP" AS
/* $Header: POXGCRQB.pls 115.1 2003/09/24 03:53:48 bmunagal noship $*/

G_PKG_NAME CONSTANT varchar2(30) := 'PO_REQ_DOCUMENT_UPDATE_GRP';

c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.';

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-------------------------------------------------------------------------------
--Start of Comments
--Name: validate_inputs
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  The following Validations done, called by req_status_check Group procedure.
--    1. The ID input tables p_req_header_id, p_req_line_id should be of same size.
--    2. Each entity specifies a required field Requisition Header ID
--       Note that the Line is optional but a Header is required.
--Notes:
--  Detailed comments maintained in PVT Package Body PO_REQ_DOCUMENT_CHECKS_PVT.req_status_check
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_inputs (
    p_api_version         IN NUMBER,
    p_req_changes         IN OUT NOCOPY PO_REQ_CHANGES_REC_TYPE,
    p_update_source       IN VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
) IS

l_api_name    CONSTANT VARCHAR(30) := 'validate_inputs';
l_progress    VARCHAR2(3) := '000';
l_count       NUMBER := p_req_changes.line_changes.req_line_id.count;
l_dummy_table_number    po_tbl_number := po_tbl_number();
l_dummy_table_date    po_tbl_date := po_tbl_date();

BEGIN

--Initialize any null Tables to a dummy table of null values with length of req_line_id.count
l_progress := '010';
l_dummy_table_number.extend(l_count);
l_dummy_table_date.extend(l_count);

IF p_req_changes.line_changes.unit_price IS NULL THEN
    p_req_changes.line_changes.unit_price := l_dummy_table_number;
END IF;
IF p_req_changes.line_changes.currency_unit_price IS NULL THEN
    p_req_changes.line_changes.currency_unit_price := l_dummy_table_number;
END IF;
IF p_req_changes.line_changes.quantity IS NULL THEN
    p_req_changes.line_changes.quantity := l_dummy_table_number;
END IF;
IF p_req_changes.line_changes.secondary_quantity IS NULL THEN
    p_req_changes.line_changes.secondary_quantity := l_dummy_table_number;
END IF;
IF p_req_changes.line_changes.need_by_date IS NULL THEN
    p_req_changes.line_changes.need_by_date := l_dummy_table_date;
END IF;
IF p_req_changes.line_changes.deliver_to_location_id IS NULL THEN
    p_req_changes.line_changes.deliver_to_location_id := l_dummy_table_number;
END IF;
IF p_req_changes.line_changes.assignment_start_date IS NULL THEN
    p_req_changes.line_changes.assignment_start_date := l_dummy_table_date;
END IF;
IF p_req_changes.line_changes.assignment_end_date IS NULL THEN
    p_req_changes.line_changes.assignment_end_date := l_dummy_table_date;
END IF;
IF p_req_changes.line_changes.amount IS NULL THEN
    p_req_changes.line_changes.amount := l_dummy_table_number;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END validate_inputs;

-------------------------------------------------------------------------------
--Start of Comments
--Name: update_requisition
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Group procedure to updates a Requisition. Validates and calls private procedure
--  This currently does not do any validations. The may do validations in the future.
--Notes:
--  Detailed comments maintained in PVT Package Body PO_REQ_DOCUMENT_UPDATE_PVT.update_requisition
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE update_requisition (
    p_api_version         IN NUMBER,
    p_req_changes         IN OUT NOCOPY PO_REQ_CHANGES_REC_TYPE,
    p_update_source       IN VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
) IS

l_api_name    CONSTANT VARCHAR(30) := 'UPDATE_REQUISITION';
l_api_version CONSTANT NUMBER := 1.0;
l_progress    VARCHAR2(3) := '000';

BEGIN

--Standard call to check for call compatibility
IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Validate/Default Input
l_progress := '005';
validate_inputs(
    p_api_version => 1.0,
    p_req_changes => p_req_changes,
    p_update_source => p_update_source,
    x_return_status  => x_return_status,
    x_msg_count  => x_msg_count,
    x_msg_data  => x_msg_data);

--Call the private procedure to update requisition
l_progress := '010';
PO_REQ_DOCUMENT_UPDATE_PVT.update_requisition(
    p_api_version => 1.0,
    p_req_changes => p_req_changes,
    p_update_source => p_update_source,
    x_return_status  => x_return_status,
    x_msg_count  => x_msg_count,
    x_msg_data  => x_msg_data);

l_progress := '020';

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

END update_requisition;


END PO_REQ_DOCUMENT_UPDATE_GRP;

/
