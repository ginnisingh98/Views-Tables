--------------------------------------------------------
--  DDL for Package Body PO_REQ_DOCUMENT_LOCK_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_DOCUMENT_LOCK_GRP" AS
/* $Header: POXGRLKB.pls 120.1 2005/06/29 18:36:50 shsiung noship $*/

-- Read the profile option that enables/disables the debug log
g_fnd_debug   VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name    CONSTANT VARCHAR2(30) := 'PO_REQ_DOCUMENT_LOCK_GRP';
c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.';

-------------------------------------------------------------------------------
--Start of Comments
--Name: lock_requisition
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  Locks the Requisition Header/Line/Distribution records.
--Function:
--  Locks the Requisition Header/Line/Distribution records.
--Parameters:
--IN:
--p_api_version
-- API version number expected by the caller
--p_req_header_id
-- Requisition Header ID indicating which requisition to lock.
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE lock_requisition (
    p_api_version     IN NUMBER,
    p_req_header_id   IN NUMBER,
    x_return_status   OUT NOCOPY VARCHAR2
) IS

l_api_version CONSTANT NUMBER := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'lock_requisition';
l_progress    VARCHAR2(3) := '000';

-- ORA-00054 is the resource busy exception, which is raised when we try
-- to lock a row that is already locked by another session.
resource_busy_exc EXCEPTION;
PRAGMA EXCEPTION_INIT(resource_busy_exc, -00054);

l_dummy NUMBER;

-- SQL What: Locks the header and all the lines, and distributions of the Req.
CURSOR lock_req_csr IS
    SELECT 1
    FROM po_requisition_headers H, po_requisition_lines L, po_req_distributions D
    WHERE H.requisition_header_id = p_req_header_id
    AND   H.requisition_header_id = L.requisition_header_id (+)
    AND   L.requisition_line_id = D.requisition_line_id (+)
    FOR UPDATE NOWAIT;

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

-- Try to lock the Requisition.
OPEN lock_req_csr;
FETCH lock_req_csr INTO l_dummy;
IF (lock_req_csr%NOTFOUND) THEN -- Cannot acquire the lock
    RAISE FND_API.G_EXC_ERROR;
END IF;
CLOSE lock_req_csr;

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR OR resource_busy_exc THEN -- Cannot acquire the lock
    FND_MESSAGE.set_name('PO', 'PO_DOC_CANNOT_LOCK');
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg ( G_PKG_NAME, l_api_name );
END lock_requisition;

END PO_REQ_DOCUMENT_LOCK_GRP;

/
