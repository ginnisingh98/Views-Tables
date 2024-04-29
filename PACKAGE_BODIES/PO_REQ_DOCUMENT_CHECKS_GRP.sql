--------------------------------------------------------
--  DDL for Package Body PO_REQ_DOCUMENT_CHECKS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_DOCUMENT_CHECKS_GRP" AS
/* $Header: POXGRCKB.pls 115.2 2003/09/24 03:58:06 bmunagal noship $*/

G_PKG_NAME CONSTANT varchar2(30) := 'PO_REQ_DOCUMENT_CHECKS_GRP';

c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.';

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


-- The following new procedures for status check added in DropShip FPJ project

-------------------------------------------------------------------------------
--Start of Comments
--Name: validate_status_check_inputs
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
PROCEDURE validate_status_check_inputs (
    p_api_version         IN NUMBER,
    p_req_header_id       IN PO_TBL_NUMBER,
    p_req_line_id         IN OUT NOCOPY PO_TBL_NUMBER,
    p_req_distribution_id IN OUT NOCOPY PO_TBL_NUMBER,
    p_mode                IN VARCHAR2,
    p_lock_flag           IN VARCHAR2 := 'N',
    x_req_status_rec      OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
) IS

l_api_name    CONSTANT VARCHAR(30) := 'VALIDATE_STATUS_CHECK_INPUTS';
l_progress    VARCHAR2(3) := '000';
l_count       NUMBER := p_req_header_id.COUNT;
l_dummy_table_number    po_tbl_number := po_tbl_number();

BEGIN

--Initialize any null Tables to a dummy table of null values with length of p_header_id.COUNT
l_progress := '007';
l_dummy_table_number.extend(l_count);
IF p_req_line_id IS NULL THEN
    p_req_line_id := l_dummy_table_number;
END IF;
IF p_req_distribution_id IS NULL THEN
    p_req_distribution_id := l_dummy_table_number;
END IF;

--Validate that Input ID Tables are all of the same size
l_progress := '010';
IF l_count <> p_req_line_id.count THEN

    FND_MESSAGE.set_name('PO', 'PO_STATCHK_GENERAL_ERROR');
    FND_MESSAGE.set_token('ERROR_TEXT', 'The input table ID parameters are not of same size !');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
END IF;

--Validate that a Requisition Header is specified for all indexes
l_progress := '020';
FOR i IN 1..l_count LOOP

    --For each index, Input IDs should refer to a valid entity
    IF p_req_header_id(i) is null THEN
        FND_MESSAGE.set_name('PO', 'PO_STATCHK_GENERAL_ERROR');
        FND_MESSAGE.set_token('ERROR_TEXT', 'There is no Header specified at index ' || i);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

END LOOP;

l_progress := '030';

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END validate_status_check_inputs;

-------------------------------------------------------------------------------
--Start of Comments
--Name: req_status_check
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Group procedure to find the status of a Requisition
--  This validates inputs and calls the private procedure req_status_check
--Notes:
--  For details on validations, refer to Group Procedure validate_status_check_inputs
--  Detailed comments maintained in PVT Package Body PO_REQ_DOCUMENT_CHECKS_PVT.req_status_check
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE req_status_check (
    p_api_version         IN NUMBER,
    p_req_header_id       IN PO_TBL_NUMBER,
    p_req_line_id         IN PO_TBL_NUMBER,
    p_req_distribution_id IN PO_TBL_NUMBER,
    p_mode                IN VARCHAR2,
    p_lock_flag           IN VARCHAR2 := 'N',
    x_req_status_rec      OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
) IS

l_api_name    CONSTANT VARCHAR(30) := 'req_status_check';
l_api_version CONSTANT NUMBER := 1.0;
l_progress    VARCHAR2(3) := '000';
l_req_line_id          PO_TBL_NUMBER := p_req_line_id;
l_req_distribution_id  PO_TBL_NUMBER := p_req_distribution_id;

BEGIN

--Standard call to check for call compatibility
IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Validate Input Parameters
l_progress := '010';
validate_status_check_inputs (
    p_api_version => p_api_version,
    p_req_header_id => p_req_header_id,
    p_req_line_id => l_req_line_id,
    p_req_distribution_id => l_req_distribution_id,
    p_mode => p_mode,
    p_lock_flag => p_lock_flag,
    x_req_status_rec => x_req_status_rec,
    x_return_status  => x_return_status,
    x_msg_count  => x_msg_count,
    x_msg_data  => x_msg_data);

--Call the private procedure to actually do req status check
l_progress := '020';
PO_REQ_DOCUMENT_CHECKS_PVT.req_status_check(
    p_api_version => p_api_version,
    p_req_header_id => p_req_header_id,
    p_req_line_id => l_req_line_id,
    p_req_distribution_id => l_req_distribution_id,
    p_mode => p_mode,
    p_lock_flag => p_lock_flag,
    x_req_status_rec => x_req_status_rec,
    x_return_status  => x_return_status,
    x_msg_count  => x_msg_count,
    x_msg_data  => x_msg_data);

l_progress := '030';

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

END req_status_check;

-------------------------------------------------------------------------------
--Start of Comments
--Name: req_status_check
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Finds the status of a Purchase Order or a Release
--  This is a convenience procedure for a single entity and takes in scalar input IDs
--  This in turn calls the group procedure req_status_check that takes Table input IDs
--Notes:
--  Detailed comments maintained in PVT Package Body PO_REQ_DOCUMENT_CHECKS_PVT.req_status_check
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE req_status_check (
    p_api_version         IN NUMBER,
    p_req_header_id       IN NUMBER,
    p_req_line_id         IN NUMBER := NULL,
    p_req_distribution_id IN NUMBER := NULL,
    p_mode                IN VARCHAR2,
    p_lock_flag           IN VARCHAR2 := 'N',
    x_req_status_rec      OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
) IS

l_api_name    CONSTANT VARCHAR(30) := 'req_status_check';
l_api_version CONSTANT NUMBER := 1.0;
l_progress    VARCHAR2(3) := '000';

BEGIN

--Standard call to check for call compatibility
IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Call the overloaded procedure that takes in Table IDs after
--  creating size=1 Tables of IDs 1 with value of the scalar input IDs
l_progress := '010';
PO_REQ_DOCUMENT_CHECKS_GRP.req_status_check(
    p_api_version => p_api_version,
    p_req_header_id => PO_TBL_NUMBER(p_req_header_id),
    p_req_line_id => PO_TBL_NUMBER(p_req_line_id),
    p_req_distribution_id => PO_TBL_NUMBER(p_req_distribution_id),
    p_mode => p_mode,
    p_lock_flag => p_lock_flag,
    x_req_status_rec => x_req_status_rec,
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

END req_status_check;


END PO_REQ_DOCUMENT_CHECKS_GRP;

/
