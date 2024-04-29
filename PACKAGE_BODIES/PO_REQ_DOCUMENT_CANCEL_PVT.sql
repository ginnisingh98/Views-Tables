--------------------------------------------------------
--  DDL for Package Body PO_REQ_DOCUMENT_CANCEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_DOCUMENT_CANCEL_PVT" AS
/* $Header: POXVRCAB.pls 120.1 2005/06/29 18:50:19 shsiung noship $*/

--CONSTANTS

G_PKG_NAME CONSTANT varchar2(30) := 'PO_REQ_DOCUMENT_CANCEL_PVT';

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
--  Cancels a Requisition by calling the C code through Doc Manager.
--  This API can process requisitions from multiple operating units.
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_req_header_id
--  Specifies Requisition Header ID.
--p_req_line_id
--  Specifies Requisition Line ID.
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_msg_count
--  The number of messages put into FND Message Stack by this API
--x_msg_data
--  First message put into FND Message Stack by this API
--Testing:
--  All the input table parameters should have the exact same length.
--    They may have null values at some indexes, but need to identify an entity uniquely
--  Call the API when only Requisition Exist, PO/Release Exist
--    and for all the combinations of attributes.
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

l_encumbrance_flag VARCHAR2(1);
l_oe_installed_flag VARCHAR2(1) := 'Y';
l_req_subtype PO_REQUISITION_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;

l_po_return_code VARCHAR2(25);
l_online_report_id NUMBER;
l_req_control_error_rc  VARCHAR2(1);

-- Bug 3362534 START
l_document_org_id       PO_REQUISITION_HEADERS_ALL.org_id%TYPE;
l_original_org_id     NUMBER  := PO_MOAC_UTILS_PVT.GET_CURRENT_ORG_ID ;  -- <R12 MOAC> added
-- Bug 3362534 END

BEGIN

IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || '.'||l_api_name||'.'
          || l_progress, 'Entering Procedure '||l_api_name);
    END IF;
END IF;

-- Standard call to check for call compatibility
l_progress := '010';
IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

FOR i IN 1..p_req_line_id.count LOOP

    SELECT type_lookup_code,
           org_id -- Bug 3362534
    INTO l_req_subtype,
         l_document_org_id
    FROM PO_REQUISITION_HEADERS_ALL
    WHERE requisition_header_id = p_req_header_id(i);

    -- Bug 3362534 START
    -- Set the org context to the operating unit of the document.
    PO_MOAC_UTILS_PVT.set_org_context(l_document_org_id) ;               -- <R12 MOAC>

    -- Check whether req encumbrance is enabled for this operating unit.
    IF PO_CORE_S.is_encumbrance_on (
        p_doc_type => PO_CORE_S.g_doc_type_REQUISITION,
        p_org_id   => l_document_org_id )
    THEN
        l_encumbrance_flag := 'Y';
    ELSE
        l_encumbrance_flag := 'N';
    END IF;
    -- Bug 3362534 END

    l_progress := '020';
    IF po_reqs_control_sv.val_reqs_action(
        x_req_header_id       =>  p_req_header_id(i),
        x_req_line_id         =>  p_req_line_id(i),
        x_agent_id            =>  null,
        x_req_doc_type        =>  'REQUISITION',
        x_req_doc_subtype     =>  l_req_subtype,
        x_req_control_action  =>  'CANCEL REQUISITION',
        x_req_control_reason  =>  p_cancel_reason,
        x_req_action_date     =>  p_cancel_date,
        x_encumbrance_flag    =>  l_encumbrance_flag,
        x_oe_installed_flag   =>  l_oe_installed_flag) = FALSE
    THEN
        FND_MESSAGE.set_name('PO', 'PO_REQ_CANCEL_ERROR');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_encumbrance_flag = 'Y' THEN

        l_progress := '030';
        PO_DOCUMENT_FUNDS_PVT.do_cancel(
            x_return_status  => x_return_status,
            p_doc_type       => 'REQUISITION',
            p_doc_subtype    => l_req_subtype,
            p_doc_level      => 'LINE',
            p_doc_level_id   => p_req_line_id(i),
            p_use_enc_gt_flag=> PO_DOCUMENT_FUNDS_PVT.g_parameter_NO,
            p_override_funds => PO_DOCUMENT_FUNDS_PVT.g_parameter_USE_PROFILE,
            p_use_gl_date    => PO_DOCUMENT_FUNDS_PVT.g_parameter_USE_PROFILE,
            p_override_date  => p_cancel_date,
            x_po_return_code => l_po_return_code,
            x_online_report_id=> l_online_report_id);

        IF l_po_return_code <> PO_DOCUMENT_FUNDS_PVT.g_return_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_progress := '040';
        po_reqs_control_sv.update_reqs_status(
            x_req_header_id       =>  p_req_header_id(i),
            x_req_line_id         =>  p_req_line_id(i),
            x_agent_id            =>  null,
            x_req_doc_type        =>  'REQUISITION',
            x_req_doc_subtype     =>  l_req_subtype,
            x_req_control_action  =>  'CANCEL REQUISITION',
            x_req_control_reason  =>  p_cancel_reason,
            x_req_action_date     =>  p_cancel_date,
            x_encumbrance_flag    =>  l_encumbrance_flag,
            x_oe_installed_flag   =>  l_oe_installed_flag,
	    x_req_control_error_rc =>  l_req_control_error_rc);

        IF l_req_control_error_rc = 'Y' THEN
            FND_MESSAGE.set_name('PO', 'PO_REQ_CANCEL_ERROR');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF; --End of IF l_encumbrance_flag = 'Y'

END LOOP;

l_progress := '050';
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Bug 3362534 Set the org context back to the original operating unit.
PO_MOAC_UTILS_PVT.set_org_context(l_original_org_id) ;       -- <R12 MOAC>

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Bug 3362534 Set the org context back to the original operating unit.
        PO_MOAC_UTILS_PVT.set_org_context(l_original_org_id) ;       -- <R12 MOAC>
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Bug 3362534 Set the org context back to the original operating unit.
        PO_MOAC_UTILS_PVT.set_org_context(l_original_org_id) ;       -- <R12 MOAC>
    WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Bug 3362534 Set the org context back to the original operating unit.
        PO_MOAC_UTILS_PVT.set_org_context(l_original_org_id) ;       -- <R12 MOAC>

END cancel_requisition;

END PO_REQ_DOCUMENT_CANCEL_PVT;

/
