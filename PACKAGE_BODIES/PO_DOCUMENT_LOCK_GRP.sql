--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_LOCK_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_LOCK_GRP" AS
/* $Header: POXGLOKB.pls 120.2.12010000.3 2012/06/28 11:43:53 vlalwani ship $*/

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_pkg_name      CONSTANT VARCHAR2(30) := 'PO_DOCUMENT_LOCK_GRP';
g_module_prefix CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';

-------------------------------------------------------------------------------
--Start of Comments
--Name: lock_document
--Pre-reqs:
--  The operating unit context must be set before calling this API - i.e.:
--Function:
--  Locks the document, including the header and all the lines, shipments,
--  and distributions, as appropriate.
--Modifies:
--  Acquires database locks on the document.
--Parameters:
--IN:
--p_api_version
-- API version number expected by the caller
--p_init_msg_list
-- If FND_API.G_TRUE, the API will initialize the standard API message list.
--p_document_type
-- type of document to lock: 'PO', 'PA', or 'RELEASE'
--p_document_id
-- ID of the document to lock - po_header_id for POs and PAs;
-- po_release_id for releases
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if the API successfully locked the document.
--  FND_API.G_RET_STS_ERROR if the API could not lock the document, because
--    the lock is being held by another session.
--  FND_API.G_RET_STS_UNEXP_ERROR if an unexpected error occurred, such as
--    invalid document type or document ID.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE lock_document (
  p_api_version     IN NUMBER,
  p_init_msg_list   IN VARCHAR2,
  x_return_status   OUT NOCOPY VARCHAR2,
  p_document_type   IN VARCHAR2,
  p_document_id     IN NUMBER
) IS
  l_api_version CONSTANT NUMBER := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'LOCK_DOCUMENT';

  -- ORA-00054 is the resource busy exception, which is raised when we try
  -- to lock a row that is already locked by another session.
  resource_busy_exc EXCEPTION;
  PRAGMA EXCEPTION_INIT(resource_busy_exc, -00054);

  l_dummy NUMBER;

  -- SQL What: Locks the header and all the lines, shipments, and
  --           distributions of the PO.
  -- SQL Why:  To prevent others from modifying the document.
  CURSOR lock_po_csr IS
    SELECT 1
    FROM po_headers POH, po_lines POL, po_line_locations PLL,
         po_distributions POD
    WHERE POH.po_header_id = p_document_id
    AND   POH.po_header_id = POL.po_header_id (+) -- JOIN
    AND   POL.po_line_id = PLL.po_line_id (+) -- JOIN
    -- Need NVL(..) because we cannot use (+) with the IN operator:
    -- <Complex Work R12>: Include PREPAYMENT shipment_types in locking.
    AND   NVL(PLL.shipment_type, 'STANDARD') IN ('STANDARD', 'PLANNED', 'PREPAYMENT')
    AND   PLL.line_location_id = POD.line_location_id (+)  -- JOIN
    FOR UPDATE NOWAIT;

  -- SQL What: Locks the header and all the lines and price breaks of the PA.
  -- SQL Why:  To prevent others from modifying the document.
  CURSOR lock_pa_csr IS
    SELECT 1
    FROM po_headers POH, po_lines POL, po_line_locations PLL
    WHERE POH.po_header_id = p_document_id
    AND   POH.po_header_id = POL.po_header_id (+)  -- JOIN
    AND   POL.po_line_id = PLL.po_line_id (+) -- JOIN
    AND   PLL.shipment_type (+) = 'PRICE BREAK'
    FOR UPDATE NOWAIT;

  -- SQL What: Locks the release and all its shipments and distributions.
  -- SQL Why:  To prevent others from modifying the document.
  CURSOR lock_release_csr IS
    SELECT 1
    FROM po_releases POR, po_line_locations PLL, po_distributions POD
    WHERE POR.po_release_id = p_document_id
    AND   POR.po_release_id = PLL.po_release_id (+) -- JOIN
    AND   PLL.line_location_id = POD.line_location_id (+) -- JOIN
    FOR UPDATE NOWAIT;

  -- <Document Manager Rewrite 11.5.11 Start>
  CURSOR lock_req_csr IS
    SELECT 1
    FROM po_requisition_headers porh, po_requisition_lines porl,
         po_req_distributions pord
    WHERE porh.requisition_header_id = p_document_id
      AND porh.requisition_header_id = porl.requisition_header_id (+) -- JOIN
      AND porl.requisition_line_id = pord.requisition_line_id (+) -- JOIN
    FOR UPDATE NOWAIT;
  -- <Document Manager Rewrite 11.5.11 End>

BEGIN
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name,
                    'Entering ' || l_api_name );
    END IF;
  END IF;

  -- Standard API initialization:
  IF NOT FND_API.compatible_api_call ( l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- For each document type, verify that the requested document exists,
  -- then try to lock it.
  IF (p_document_type = 'PO') THEN

    -- Verify that the PO exists.
    BEGIN
      SELECT 1
      INTO l_dummy
      FROM po_headers
      WHERE po_header_id = p_document_id
      AND   type_lookup_code IN ('STANDARD','PLANNED');
    EXCEPTION
      WHEN no_data_found THEN
        FND_MESSAGE.set_name('PO', 'PO_INVALID_DOC_IDS');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    -- Try to lock the PO.
    OPEN lock_po_csr;
    FETCH lock_po_csr INTO l_dummy;
    IF (lock_po_csr%NOTFOUND) THEN -- Cannot acquire the lock
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE lock_po_csr;

  ELSIF (p_document_type = 'PA') THEN

    -- Verify that the PA exists.
    BEGIN
      SELECT 1
      INTO l_dummy
      FROM po_headers
      WHERE po_header_id = p_document_id
      AND   type_lookup_code IN ('BLANKET','CONTRACT');
    EXCEPTION
      WHEN no_data_found THEN
        FND_MESSAGE.set_name('PO', 'PO_INVALID_DOC_IDS');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    -- Try to lock the PA.
    OPEN lock_pa_csr;
    FETCH lock_pa_csr INTO l_dummy;
    IF (lock_pa_csr%NOTFOUND) THEN -- Cannot acquire the lock
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE lock_pa_csr;

  ELSIF (p_document_type = 'RELEASE') THEN

    -- Verify that the release exists.
    BEGIN
      SELECT 1
      INTO l_dummy
      FROM po_releases
      WHERE po_release_id = p_document_id;
    EXCEPTION
      WHEN no_data_found THEN
        FND_MESSAGE.set_name('PO', 'PO_INVALID_DOC_IDS');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    -- Try to lock the release.
    OPEN lock_release_csr;
    FETCH lock_release_csr INTO l_dummy;
    IF (lock_release_csr%NOTFOUND) THEN -- Cannot acquire the lock
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE lock_release_csr;

  -- <Document Manager Rewrite 11.5.11 Start>
  ELSIF (p_document_type = 'REQUISITION') THEN

    -- Verify that the requisition exists.
    BEGIN
      SELECT 1
      INTO l_dummy
      FROM po_requisition_headers porh
      WHERE porh.requisition_header_id = p_document_id;
    EXCEPTION
      WHEN no_data_found THEN
        FND_MESSAGE.set_name('PO', 'PO_INVALID_DOC_IDS');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    -- Try to lock the requisition.
    OPEN lock_req_csr;
    FETCH lock_req_csr INTO l_dummy;
    IF (lock_req_csr%NOTFOUND) THEN -- Cannot acquire the lock
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE lock_req_csr;

  -- <Document Manager Rewrite 11.5.11 End>
  ELSE -- invalid document type

    FND_MESSAGE.set_name('PO', 'PO_INVALID_DOC_TYPE');
    FND_MESSAGE.set_token('TYPE', p_document_type);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF; -- p_document_type

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string( FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name,
                    'Exiting ' || l_api_name );
    END IF;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR OR resource_busy_exc THEN -- Cannot acquire the lock
    FND_MESSAGE.set_name('PO', 'PO_DOC_CANNOT_LOCK');
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
        FND_LOG.string( FND_LOG.LEVEL_ERROR, g_module_prefix || l_api_name,
                      FND_MSG_PUB.get(p_msg_index => FND_MSG_PUB.G_LAST,
                                      p_encoded => FND_API.G_FALSE) );
      END IF;
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name,
                      FND_MSG_PUB.get(p_msg_index => FND_MSG_PUB.G_LAST,
                                      p_encoded => FND_API.G_FALSE) );
      END IF;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg ( G_PKG_NAME, l_api_name );
    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || l_api_name,
                      FND_MSG_PUB.get(p_msg_index => FND_MSG_PUB.G_LAST,
                                      p_encoded => FND_API.G_FALSE) );
      END IF;
    END IF;
END lock_document;




-------------------------------------------------------------------------------
--<Bug 14207546 :Cancel Refactoring Project >
--Start of Comments
--Name: lock_document
--Pre-reqs:
--  The operating unit context must be set before calling this API - i.e.:
--Function:
--    Locks the document, including the header and all the lines, shipments,
--    and distributions, as appropriate.
--    documents to be locked are available in po_session_gt with key=po_sesiongt_key
--Modifies:
--  Acquires database locks on the document.
--Parameters:
--IN:
-- p_api_version :
--    API version number expected by the caller
-- p_init_msg_list:
--  If FND_API.G_TRUE, the API will initialize the standard API message list.
-- po_sesiongt_key:
--   Docuements to be locked are manitined in po_session_gt
--   po_sesiongt_key is the key in po_session_gt to identify
--   the intended records in the table
--  p_online_report_id:
--   If the locking of any of teh document contained in po_session_gt fails
--   Then an appropriate error message will be inserted in po_online_report_text
--   table with online_report_id=p_online_report_id
--  p_user_id
--   Current User Id
--  p_login_id
--    Current User login ID

--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if the API successfully locked the document.
--  FND_API.G_RET_STS_ERROR if the API could not lock the document, because
--    the lock is being held by another session.
--  FND_API.G_RET_STS_UNEXP_ERROR if an unexpected error occurred, such as
--    invalid document type or document ID.
--End of Comments
-------------------------------------------------------------------------------


 PROCEDURE lock_document (
   p_online_report_id IN NUMBER,
   p_api_version      IN NUMBER,
   p_init_msg_list    IN VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2,
   p_user_id          IN po_lines.last_updated_by%TYPE,
   p_login_id         IN po_lines.last_update_login%TYPE ,
   po_sesiongt_key    IN po_session_gt.key%TYPE)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'LOCK_DOCUMENT.';
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix || d_api_name;

    l_progress VARCHAR2(3);
    l_api_version CONSTANT NUMBER := 1.0;
    l_sequence          po_online_report_text.sequence%TYPE;


    -- ORA-00054 is the resource busy exception, which is raised when we try
    -- to lock a row that is already locked by another session.
    resource_busy_exc EXCEPTION;
    PRAGMA EXCEPTION_INIT(resource_busy_exc, -00054);

    l_dummy po_tbl_NUMBER;


    -- SQL What: Locks the header and all the lines, shipments, and
    --           distributions of the PO.
    -- SQL Why:  To prevent others from modifying the document.
    CURSOR lock_po_csr IS
      SELECT 1
      FROM po_headers POH,
           po_lines POL,
           po_line_locations PLL,
           po_distributions POD,
           po_session_gt gt
      WHERE gt.KEY=po_sesiongt_key
            AND POH.po_header_id =gt.char4
            AND gt.char1 = 'PO'
            AND POH.po_header_id = POL.po_header_id (+) -- JOIN
            AND POL.po_line_id = PLL.po_line_id (+) -- JOIN
            AND NVL(PLL.shipment_type, 'STANDARD') IN ('STANDARD', 'PLANNED', 'PREPAYMENT')
            AND PLL.line_location_id = POD.line_location_id (+)  -- JOIN
      FOR UPDATE NOWAIT;


    -- SQL What: Locks the header and all the lines and price breaks of the PA.
    -- SQL Why:  To prevent others from modifying the document.
    CURSOR lock_pa_csr IS
      SELECT 1
      FROM po_headers POH,
           po_lines POL,
           po_line_locations PLL,
           po_session_gt gt
      WHERE gt.KEY=po_sesiongt_key
            AND POH.po_header_id =gt.char4
            AND gt.char1 = 'PA'
            AND POH.po_header_id = POL.po_header_id (+)  -- JOIN
            AND POL.po_line_id = PLL.po_line_id (+) -- JOIN
            AND PLL.shipment_type (+) = 'PRICE BREAK'
      FOR UPDATE NOWAIT;

    -- SQL What: Locks the release and all its shipments and distributions.
    -- SQL Why:  To prevent others from modifying the document.
    CURSOR lock_release_csr IS
      SELECT 1
      FROM po_releases POR, po_line_locations PLL,
           po_distributions POD,
           po_session_gt gt
      WHERE gt.KEY=po_sesiongt_key
            AND POR.po_release_id =gt.char4
            AND gt.char1 = 'RELEASE'
            AND POR.po_release_id = PLL.po_release_id (+) -- JOIN
            AND PLL.line_location_id = POD.line_location_id (+) -- JOIN
      FOR UPDATE NOWAIT;

  BEGIN


    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        FND_LOG.string( FND_LOG.LEVEL_PROCEDURE, g_module_prefix || d_api_name,
                    'Entering ' || d_api_name );
      END IF;
    END IF;

    l_progress :='000';

    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        PO_DEBUG.debug_begin(d_module);
        PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
        PO_DEBUG.debug_var(d_module,l_progress,'p_api_version',p_api_version);
        PO_DEBUG.debug_var(d_module,l_progress,'p_init_msg_list',p_init_msg_list);
        PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
        PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
        PO_DEBUG.debug_var(d_module,l_progress,'po_sesiongt_key',po_sesiongt_key);
      END IF;
    END IF;


    -- Standard API initialization:
    IF NOT FND_API.compatible_api_call ( l_api_version, p_api_version,
                                        d_api_name, G_PKG_NAME ) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF (FND_API.to_boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
    END IF;


    l_progress :='001';

    SELECT Nvl(Max(sequence) ,0)
    INTO   l_sequence
    FROM   PO_ONLINE_REPORT_TEXT
    WHERE  online_report_id=p_online_report_id;

    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        PO_DEBUG.debug_var(d_module,l_progress,'l_sequence',l_sequence);
      END IF;
    END IF;


    l_progress :='002';

    -- Try to lock the PO.
    OPEN lock_po_csr;
    FETCH lock_po_csr BULK COLLECT INTO l_dummy;
    CLOSE lock_po_csr;

    l_progress :='003';


    -- Try to lock the PA.
    OPEN lock_pa_csr;
    FETCH lock_pa_csr BULK COLLECT INTO l_dummy;
    CLOSE lock_pa_csr;

    l_progress :='004';
    -- Try to lock the release.
    OPEN lock_release_csr;
    FETCH lock_release_csr BULK COLLECT INTO l_dummy;
    CLOSE lock_release_csr;


    x_return_status := FND_API.G_RET_STS_SUCCESS;


    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        FND_LOG.string( FND_LOG.LEVEL_PROCEDURE, g_module_prefix || d_api_name,
                    'Exiting ' || d_api_name );
      END IF;
    END IF;

  EXCEPTION
    WHEN resource_busy_exc THEN -- Cannot acquire the lock
      INSERT INTO PO_ONLINE_REPORT_TEXT
        (ONLINE_REPORT_ID,
        LAST_UPDATE_LOGIN,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        CREATED_BY,
        CREATION_DATE,
        LINE_NUM,
        SHIPMENT_NUM,
        DISTRIBUTION_NUM,
        SEQUENCE,
        TEXT_LINE,
        transaction_id,
        transaction_level)
      VALUES
        ( p_online_report_id,
        p_login_id,
        p_user_id,
        SYSDATE,
        p_user_id,
        SYSDATE,
        0,
        0,
        0,
        l_sequence + 1,
        PO_CORE_S.get_translated_text
          ('PO_DOC_CANNOT_LOCK'),
        0,
        0);

      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
          FND_LOG.string( FND_LOG.LEVEL_ERROR, g_module_prefix || d_api_name,
                         FND_MSG_PUB.get(p_msg_index => FND_MSG_PUB.G_LAST,
                                         p_encoded => FND_API.G_FALSE) );
        END IF;
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || d_api_name,
                      FND_MSG_PUB.get(p_msg_index => FND_MSG_PUB.G_LAST,
                                      p_encoded => FND_API.G_FALSE) );
        END IF;
      END IF;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg ( G_PKG_NAME, d_api_name );
      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED, g_module_prefix || d_api_name,
                      FND_MSG_PUB.get(p_msg_index => FND_MSG_PUB.G_LAST,
                                      p_encoded => FND_API.G_FALSE) );
        END IF;
      END IF;
  END lock_document;



END PO_DOCUMENT_LOCK_GRP;

/
