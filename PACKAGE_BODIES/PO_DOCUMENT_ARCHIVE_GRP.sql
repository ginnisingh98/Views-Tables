--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_ARCHIVE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_ARCHIVE_GRP" AS
/* $Header: POXPOARB.pls 120.1 2005/06/29 18:40:18 shsiung noship $ */

G_PKG_NAME CONSTANT varchar2(30) := 'PO_DOCUMENT_ARCHIVE_GRP';

c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.';

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

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

  l_api_name	CONSTANT varchar2(30) := 'ARCHIVE_PO';
  l_api_version	CONSTANT NUMBER       := 1.0;
  l_progress	VARCHAR2(3);
  l_document_id	NUMBER;

BEGIN

  -- Initialize OUT parameters
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := NULL;

  l_progress := '000';
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '010';
  IF g_fnd_debug = 'Y' THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
            || l_progress,'Doing Validation on passed in data');
     END IF;
  END IF;

  l_progress := '020';
  -- Check the required fields
  IF ((p_document_id is NULL) OR (p_document_type is NULL) OR
      (p_document_subtype IS NULL)) THEN
    FND_MESSAGE.set_name('PO', 'PO_ARC_GENERAL_ERROR');
    FND_MESSAGE.set_token('ERROR_TEXT', 'Mandatory parameters are NULL');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF; /*(p_document_id is NULL) OR (p_document_type is NULL)*/

  l_progress := '030';
  --check p_document_type
  IF p_document_type NOT IN ('RELEASE', 'PO', 'PA') THEN
    FND_MESSAGE.set_name('PO', 'PO_ARC_GENERAL_ERROR');
    FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid document type');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF; /*p_document_type NOT IN ('RELEASE', 'PO', 'PA')*/

  l_progress := '040';
  --check that document_subtype matches
  IF p_document_type = 'RELEASE' THEN
    IF p_document_subtype NOT IN ('SCHEDULED', 'BLANKET') THEN
    FND_MESSAGE.set_name('PO', 'PO_ARC_GENERAL_ERROR');
    FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid Release document subtype');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSIF p_document_type = 'PO' THEN
    IF p_document_subtype NOT IN ('STANDARD', 'PLANNED') THEN
    FND_MESSAGE.set_name('PO', 'PO_ARC_GENERAL_ERROR');
    FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid PO document subtype');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSIF p_document_type = 'PA' THEN
    IF p_document_subtype NOT IN ('BLANKET', 'CONTRACT') THEN
    FND_MESSAGE.set_name('PO', 'PO_ARC_GENERAL_ERROR');
    FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid PA document subtype');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF; /*p_document_type = 'RELEASE'*/

  l_progress := '040';
  --check that document_id passed exists
  BEGIN
    IF p_document_type IN ('PO', 'PA') THEN
      SELECT po_header_id
      INTO   l_document_id
      FROM   PO_HEADERS_ALL
      WHERE  po_header_id= p_document_id;
    ELSE --Its a release
      SELECT po_release_id
      INTO   l_document_id
      FROM   PO_RELEASES_ALL
      WHERE  po_release_id= p_document_id;
    END IF; /*p_document_type IN ('PO', 'PA')*/
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.set_name('PO', 'PO_ARC_GENERAL_ERROR');
      FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid document_id passed');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END;

  l_progress := '100';
  --Call the private Archive_PO
  PO_DOCUMENT_ARCHIVE_PVT.Archive_PO(
    p_api_version => p_api_version,
    p_document_id => p_document_id,
    p_document_type => p_document_type,
    p_document_subtype => p_document_subtype,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data);

  l_progress := '200';
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                  p_encoded => 'F');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                  p_encoded => 'F');
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
    END IF;

    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, c_log_head ||
                     l_api_name || '.others_exception', 'EXCEPTION: Location is '
                     || l_progress || ' SQL CODE is '||sqlcode
                     || ', EXCEPTION: '||sqlerrm);
      END IF;
    END IF;

    x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                  p_encoded => 'F');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END archive_po;

/**
* Public Procedure: archive_po
* This precedure accepts one more required IN PARAMETERS:
*   p_process: Process that called this routine: 'PRINT' or 'APPROVE'
*/
PROCEDURE archive_po(p_api_version         IN         NUMBER,
                     p_document_id         IN         NUMBER,
                     p_document_type       IN         VARCHAR2,
                     p_document_subtype    IN         VARCHAR2,
                     p_process             IN         VARCHAR2,
                     x_return_status       OUT NOCOPY VARCHAR2,
                     x_msg_count	   OUT NOCOPY NUMBER,
                     x_msg_data            OUT NOCOPY VARCHAR2)
IS
  l_api_name		CONSTANT varchar2(30) := 'ARCHIVE_PO';
  l_api_version		CONSTANT NUMBER       := 1.0;
  l_progress		VARCHAR2(3);
  l_when_to_archive	PO_DOCUMENT_TYPES.archive_external_revision_code%TYPE;
BEGIN

  -- Initialize OUT parameters
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := NULL;

  l_progress := '000';
  --check p_process
  IF (p_process is NULL OR
      p_process NOT IN ('PRINT', 'APPROVE')) THEN
    FND_MESSAGE.set_name('PO', 'PO_ARC_GENERAL_ERROR');
    FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid process value');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF; /* p_process NOT IN ('PRINT', 'APPROVE')*/

  l_progress := '010';
  -- Check if we need to archive the document
  SELECT archive_external_revision_code
  INTO   l_when_to_archive
  FROM   po_document_types
  WHERE  document_type_code = p_document_type
  AND    document_subtype   = p_document_subtype;

  l_progress := '020';
  IF p_process = l_when_to_archive THEN
    PO_DOCUMENT_ARCHIVE_GRP.Archive_PO(
      p_api_version => p_api_version,
      p_document_id => p_document_id,
      p_document_type => p_document_type,
      p_document_subtype => p_document_subtype,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data);
  END IF; /*p_process = l_when_to_archive*/

  l_progress := '100';
  -- Standard call to get message count and if count is 1,
  -- get message info.
  FND_MSG_PUB.Count_And_Get
  (p_count => x_msg_count,
   p_data  => x_msg_data
  );

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                  p_encoded => 'F');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                  p_encoded => 'F');
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
    END IF;

    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, c_log_head ||
                     l_api_name || '.others_exception', 'EXCEPTION: Location is '
                     || l_progress || ' SQL CODE is '||sqlcode
                     || ', EXCEPTION: '||sqlerrm);
      END IF;
    END IF;

    x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                  p_encoded => 'F');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END archive_po;

/**
* Public Procedure: archive_po
* This precedure overloads archive_po to eliminate OUT parameter x_msg_count
*/
PROCEDURE archive_po(p_api_version         IN         NUMBER,
                     p_document_id         IN         NUMBER,
                     p_document_type       IN         VARCHAR2,
                     p_document_subtype    IN         VARCHAR2,
                     x_return_status       OUT NOCOPY VARCHAR2,
                     x_msg_data            OUT NOCOPY VARCHAR2)
IS
  l_msg_count		NUMBER;
BEGIN
  archive_po(
    p_api_version	=> p_api_version,
    p_document_id	=> p_document_id,
    p_document_type	=> p_document_type,
    p_document_subtype	=> p_document_subtype,
    x_return_status	=> x_return_status,
    x_msg_count		=> l_msg_count,
    x_msg_data		=> x_msg_data);
END archive_po;

END PO_DOCUMENT_ARCHIVE_GRP; -- Package spec

/
