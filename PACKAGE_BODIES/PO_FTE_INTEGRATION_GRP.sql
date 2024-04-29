--------------------------------------------------------
--  DDL for Package Body PO_FTE_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_FTE_INTEGRATION_GRP" AS
/* $Header: POXGFTEB.pls 120.1 2005/06/29 18:35:12 shsiung noship $ */

--CONSTANTS
g_pkg_name  CONSTANT VARCHAR2(30) := 'PO_FTE_INTEGRATION_GRP';
c_log_head  CONSTANT VARCHAR2(50) := 'po.plsql.'|| g_pkg_name || '.';
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_po_release_attributes
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Get attributes of Standard Purchase Order and Blanket Release for
--  Transportation delivery record.
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_line_location_id
--  Corresponding to po_line_location_id
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_msg_count
--  Error messages number.
--x_msg_data
--  Error messages body.
--x_po_release_attributes
--Testing:
--  Call this API when only line_location_id exists.
--End of Comments
-------------------------------------------------------------------------------


PROCEDURE get_po_release_attributes
(
    p_api_version            IN         NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    p_line_location_id       IN         NUMBER,
    x_po_releases_attributes OUT NOCOPY po_release_rec_type
)
IS
l_api_name       CONSTANT VARCHAR2(100) := 'get_po_release_attributes';
l_api_version    CONSTANT NUMBER        := 1.0;
l_progress       VARCHAR2(3)            := '001';

BEGIN
    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(
            log_level => FND_LOG.LEVEL_STATEMENT,
            module    => c_log_head || '.'||l_api_name||'.' || l_progress,
            message   => 'Check API Call Compatibility');
        END IF;
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
               p_current_version_number => l_api_version,
               p_caller_version_number  => p_api_version,
               p_api_name               => l_api_name,
               p_pkg_name               => g_pkg_name) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress:='010';
    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(
            log_level => FND_LOG.LEVEL_STATEMENT,
            module    => c_log_head || '.'||l_api_name||'.' || l_progress,
            message   => 'Call PO_FTE_INTEGRATION_PVT.get_po_release_attributes');
        END IF;
    END IF;

    PO_FTE_INTEGRATION_PVT.get_po_release_attributes(
        p_api_version            => p_api_version,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_line_location_id       => p_line_location_id,
        x_po_releases_attributes => x_po_releases_attributes);

    l_progress:='020';
    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(
            log_level => FND_LOG.LEVEL_STATEMENT,
            module    => c_log_head || '.'||l_api_name||'.' || l_progress,
            message   => 'Call returns with status' || x_return_status);
        END IF;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
              FND_LOG.string( log_level => FND_LOG.LEVEL_EXCEPTION,
                            module    => c_log_head || '.'||l_api_name,
                            message   => 'unexpected error');
            END IF;
        END IF;
        FND_MSG_PUB.add_exc_msg ( G_PKG_NAME, l_api_name );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END get_po_release_attributes;

-- Following wrappers for FTE Team to po_status_check API added in DropShip FPJ project

-------------------------------------------------------------------------------
--Start of Comments
--Name: po_status_check
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This is just a wrapper provided for Transportation Team for po_status_check
--  This just calls group procedure PO_DOCUMENT_CHECKS_GRP.po_status_check
--  Detailed comments maintained in PVT Package Body PO_DOCUMENT_CHECKS_PVT.po_status_check
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE po_status_check (
    p_api_version         IN NUMBER,
    p_header_id           IN PO_TBL_NUMBER,
    p_release_id          IN PO_TBL_NUMBER,
    p_document_type       IN PO_TBL_VARCHAR30,
    p_document_subtype    IN PO_TBL_VARCHAR30,
    p_document_num        IN PO_TBL_VARCHAR30,
    p_vendor_order_num    IN PO_TBL_VARCHAR30,
    p_line_id             IN PO_TBL_NUMBER,
    p_line_location_id    IN PO_TBL_NUMBER,
    p_distribution_id     IN PO_TBL_NUMBER,
    p_mode                IN VARCHAR2,
    p_lock_flag           IN VARCHAR2 := 'N',
    x_po_status_rec       OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2
) IS

l_api_name    CONSTANT VARCHAR(30) := 'PO_STATUS_CHECK';

BEGIN

--Call the group procedure to actually validate and do po status check
PO_DOCUMENT_CHECKS_GRP.po_status_check(
    p_api_version => p_api_version,
    p_header_id => p_header_id,
    p_release_id => p_release_id,
    p_document_type => p_document_type,
    p_document_subtype => p_document_subtype,
    p_document_num => p_document_num,
    p_vendor_order_num => p_vendor_order_num,
    p_line_id => p_line_id,
    p_line_location_id => p_line_location_id,
    p_distribution_id => p_distribution_id,
    p_mode => p_mode,
    p_lock_flag => p_lock_flag,
    x_po_status_rec => x_po_status_rec,
    x_return_status  => x_return_status);

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);

END po_status_check;

-------------------------------------------------------------------------------
--Start of Comments
--Name: po_status_check
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  A convenience procedure for a single entity and takes in scalar input IDs.
--  This is just a wrapper provided for Transportation Team for po_status_check.
--  This just calls group procedure PO_DOCUMENT_CHECKS_GRP.po_status_check.
--  Detailed comments maintained in PVT Package Body PO_DOCUMENT_CHECKS_PVT.po_status_check
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE po_status_check (
    p_api_version           IN NUMBER,
    p_header_id             IN NUMBER := NULL,
    p_release_id            IN NUMBER := NULL,
    p_document_type         IN VARCHAR2 := NULL,
    p_document_subtype      IN VARCHAR2 := NULL,
    p_document_num          IN VARCHAR2 := NULL,
    p_vendor_order_num      IN VARCHAR2 := NULL,
    p_line_id               IN NUMBER := NULL,
    p_line_location_id      IN NUMBER := NULL,
    p_distribution_id       IN NUMBER := NULL,
    p_mode                  IN VARCHAR2,
    p_lock_flag             IN VARCHAR2 := 'N',
    x_po_status_rec         OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status         OUT NOCOPY VARCHAR2
) IS

l_api_name    CONSTANT VARCHAR(30) := 'PO_STATUS_CHECK';

BEGIN

--Call the group procedure to actually validate and do po status check
PO_DOCUMENT_CHECKS_GRP.po_status_check(
    p_api_version => p_api_version,
    p_header_id => p_header_id,
    p_release_id => p_release_id,
    p_document_type => p_document_type,
    p_document_subtype => p_document_subtype,
    p_document_num => p_document_num,
    p_vendor_order_num => p_vendor_order_num,
    p_line_id => p_line_id,
    p_line_location_id => p_line_location_id,
    p_distribution_id => p_distribution_id,
    p_mode => p_mode,
    p_lock_flag => p_lock_flag,
    x_po_status_rec => x_po_status_rec,
    x_return_status  => x_return_status);

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);

END po_status_check;

END PO_FTE_INTEGRATION_GRP;

/
