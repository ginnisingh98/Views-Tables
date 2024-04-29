--------------------------------------------------------
--  DDL for Package Body PO_AP_RETROACTIVE_UPDATE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_AP_RETROACTIVE_UPDATE_GRP" AS
/* $Header: POXAPRAB.pls 120.1 2005/07/12 03:05:57 vsanjay noship $ */

G_PKG_NAME CONSTANT varchar2(30) := 'PO_AP_RETROACTIVE_UPDATE_GRP';

c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.';

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--------------------------------------------------------------------------------
--Start of Comments
--Name: Update_Invoice_Flag
--Pre-reqs:
--  None.
--Modifies:
--  Update po_distributions_all.invoice_adjument_flag.
--Locks:
--  None.
--Function:
--  This procedure updates invoice adjument flag which is used
--  by AP to create invoice adjument
--Parameters:
--IN:
--p_api_version
--  Version number of API that caller expects. It
--  should match the l_api_version defined in the
--  procedure (expected value : 1.0)
--p_dist_ids
--  The ids of the distributions
--p_flags
--  The invoice adjustment flags
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if API succeeds
--  FND_API.G_RET_STS_ERROR if API fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_msg_data
--  Contains error msg in case x_return_status returned
--  FND_API.G_RET_STS_ERROR or FND_API.G_RET_STS_UNEXP_ERROR
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Update_Invoice_Flag(p_api_version     IN         NUMBER,
			      p_dist_ids        IN         DBMS_SQL.NUMBER_TABLE,
			      p_flags           IN         DBMS_SQL.VARCHAR2_TABLE,
			      x_return_status   OUT NOCOPY VARCHAR2,
                              x_msg_count       OUT NOCOPY NUMBER,
			      x_msg_data        OUT NOCOPY VARCHAR2)
IS

  l_api_name	CONSTANT varchar2(30) := 'Update_Invoice_Flag';
  l_api_version	CONSTANT NUMBER       := 1.0;
  l_progress	VARCHAR2(3);
  l_document_id	NUMBER;

BEGIN

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
            || l_progress,'Updating invoice adjustment flag');
   END IF;
 END IF;

  l_progress := '040';
  FORALL i in 1..p_dist_ids.COUNT
     UPDATE po_distributions_all
     SET    invoice_adjustment_flag = p_flags(i)
     WHERE  po_distribution_id = p_dist_ids(i);

  l_progress := '100';
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                  p_encoded => 'F');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count  := 0;
  WHEN FND_API.G_EXC_ERROR THEN
    x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                  p_encoded => 'F');
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count  := 0;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
    END IF;

    IF (g_fnd_debug = 'Y') THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
      FND_LOG.string(FND_LOG.level_unexpected, c_log_head ||
                     l_api_name || '.others_exception', 'EXCEPTION: Location is '
                     || l_progress || ' SQL CODE is '||sqlcode);
     END IF;
    END IF;

    x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                  p_encoded => 'F');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count  := 0;

END Update_Invoice_Flag;


END PO_AP_RETROACTIVE_UPDATE_GRP; -- Package spec

/
