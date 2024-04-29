--------------------------------------------------------
--  DDL for Package Body PO_EDI_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_EDI_INTEGRATION_GRP" AS
/* $Header: POXGEDIB.pls 115.1 2004/06/30 03:05:49 zxzhang noship $*/

 --CONSTANTS

 G_PKG_NAME CONSTANT varchar2(30) := 'PO_EDI_INTEGRATION_GRP';

 c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.';

 -- Read the profile option that enables/disables the debug log
 g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

 g_debug_stmt  CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
 g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

/**
* Public Procedure: archive_po
* Requires:
*   IN PARAMETERS:
*     p_api_version:       Version number of API that caller expects. It
*                          should match the l_api_version defined in the
*                          procedure (expected value : 1.0)
*     p_document_id:       The id of the document that needs to be archived.
*     p_document_type:     The type of the document to archive
*                          PO : For Standard/Planned
*                          PA : For Blanket/Contract
*                          RELEASE : Release
*     p_document_subtype:  The subtype of the document.
*                          Valid Document types and Document subtypes are
*                          Document Type      Document Subtype
*                          RELEASE      --->  SCHEDULED/BLANKET
*                          PO           --->  PLANNED/STANDARD
*                          PA           --->  CONTRACT/BLANKET
*
* Modifies: Arcives the document. Inserts an copy of the document in the
*           archive tables
* Effects:  This procedure archives the document that is passed in
*
* Returns:
*  x_return_status:    FND_API.G_RET_STS_SUCCESS if API succeeds
*                      FND_API.G_RET_STS_ERROR if API fails
*                      FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
*  x_msg_data:         Contains error msg in case x_return_status returned
*                      FND_API.G_RET_STS_ERROR or FND_API.G_RET_STS_UNEXP_ERROR
*/
PROCEDURE archive_po(p_api_version         IN         NUMBER,
  		     p_document_id         IN         NUMBER,
  		     p_document_type       IN         VARCHAR2,
  		     p_document_subtype    IN         VARCHAR2,
  		     x_return_status       OUT NOCOPY VARCHAR2,
                     x_msg_count	   OUT NOCOPY NUMBER,
  		     x_msg_data            OUT NOCOPY VARCHAR2)
IS
  l_api_name    CONSTANT VARCHAR(30) := 'ARCHIVE_PO';
  l_api_version CONSTANT NUMBER := 1.0;
  l_progress    VARCHAR2(3) := '000';
  l_log_head    CONSTANT VARCHAR2(100) := c_log_head || '.' || l_api_name;
BEGIN

  PO_DOCUMENT_ARCHIVE_GRP.archive_po(
    p_api_version      => p_api_version,
    p_document_id      => p_document_id,
    p_document_type    => p_document_type,
    p_document_subtype => p_document_subtype,
    x_return_status    => x_return_status,
    x_msg_count        => x_msg_count,
    x_msg_data         => x_msg_data);

END archive_po;


END PO_EDI_INTEGRATION_GRP;

/
