--------------------------------------------------------
--  DDL for Package Body PO_REQ_DOCUMENT_CANCEL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_DOCUMENT_CANCEL_GRP" AS
/* $Header: POXGRCAB.pls 115.0 2003/08/28 06:29:01 bmunagal noship $*/

G_PKG_NAME CONSTANT varchar2(30) := 'PO_REQ_DOCUMENT_CANCEL_GRP';

c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.';

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-------------------------------------------------------------------------------
--Start of Comments
--Name: cancel_requisition
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Group procedure to cancel a Requisition. Validates and calls private procedure
--  This currently does not do any validations. This may do validations in the future.
--Notes:
--  Detailed comments maintained in PVT Package Body PO_REQ_DOCUMENT_CANCEL_PVT.cancel_requisition
--End of Comments
-------------------------------------------------------------------------------
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

l_api_name    CONSTANT VARCHAR(30) := 'cancel_requisition';
l_api_version CONSTANT NUMBER := 1.0;
l_progress    VARCHAR2(3) := '000';

BEGIN

--Standard call to check for call compatibility
IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Call the private procedure to cancel requisition
l_progress := '010';
PO_REQ_DOCUMENT_CANCEL_PVT.cancel_requisition(
    p_api_version => 1.0,
    p_req_header_id => p_req_header_id,
    p_req_line_id => p_req_line_id,
    p_cancel_date => p_cancel_date,
    p_source => p_source,
    p_cancel_reason => p_cancel_reason,
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

END cancel_requisition;


END PO_REQ_DOCUMENT_CANCEL_GRP;

/
