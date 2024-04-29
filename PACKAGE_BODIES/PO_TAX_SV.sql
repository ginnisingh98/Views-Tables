--------------------------------------------------------
--  DDL for Package Body PO_TAX_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_TAX_SV" AS
/* $Header: POXPTAXB.pls 115.6 2003/08/29 22:28:38 zxzhang ship $ */

G_PKG_NAME CONSTANT varchar2(30) := 'PO_TAX_SV';
G_MODULE_PREFIX CONSTANT VARCHAR2(60) := 'po.plsql.' || G_PKG_NAME || '.';
G_FND_DEBUG VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_FND_DEBUG_LEVEL VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_LEVEL'),'0');

FUNCTION get_tax(x_calling_form	IN VARCHAR2,
		x_distribution_id	IN NUMBER) return NUMBER is

x_recoverable_tax NUMBER;
x_nonrecoverable_tax NUMBER;

x_progress  VARCHAR2(3) := '000';

BEGIN

  x_progress := '001';

  IF x_calling_form = 'PO' OR x_calling_form = 'RELEASE' THEN
    SELECT recoverable_tax, nonrecoverable_tax
    INTO   x_recoverable_tax, x_nonrecoverable_tax
    FROM   po_distributions_all
    WHERE  po_distribution_id = x_distribution_id;

  ELSIF x_calling_form = 'REQ' THEN
    SELECT recoverable_tax, nonrecoverable_tax
    INTO   x_recoverable_tax, x_nonrecoverable_tax
    FROM   po_req_distributions_all
    where  distribution_id = x_distribution_id;

  END IF;

  return(nvl(x_nonrecoverable_tax, 0));

EXCEPTION
  WHEN OTHERS THEN
    return(nvl(x_nonrecoverable_tax, 0));

END get_tax;


-- <FPJ Retroactive Price START>
--------------------------------------------------------------------------------
--Start of Comments
--Name: Get_All_PO_Tax
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure returns non-recoverable tax, recoverable tax,
--  prior non-recoverable tax (from archive), and prior recoverable
--  tax (from archive).
--Parameters:
--IN:
--p_api_version
--  Version number of API that caller expects. It
--  should match the l_api_version defined in the
--  procedure (expected value : 1.0)
--p_distribution_id
--  The distribution id of the document: refer to po_distribution_id
--OUT:
--x_recoverable_tax
--  recoverable tax
--x_non_recoverable_tax
--  non-recoverable tax
--x_old_recoverable_tax
--  prior recoverable tax (from archive)
--x_old_non_recoverable_tax
--  prior non-recoverable tax (from archive)
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
--------------------------------------------------------------------------------
Procedure Get_All_PO_Tax(
                     p_api_version             IN         NUMBER,
                     p_distribution_id         IN         NUMBER,
                     x_recoverable_tax         OUT NOCOPY NUMBER,
                     x_non_recoverable_tax     OUT NOCOPY NUMBER,
                     x_old_recoverable_tax     OUT NOCOPY NUMBER,
                     x_old_non_recoverable_tax OUT NOCOPY NUMBER,
                     x_return_status           OUT NOCOPY VARCHAR2,
                     x_msg_data                OUT NOCOPY VARCHAR2)
IS
  l_api_name	CONSTANT varchar2(30) := 'Get_All_PO_Tax';
  l_api_version	CONSTANT NUMBER       := 1.0;
  l_progress	VARCHAR2(3);
BEGIN
  l_progress := '000';
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '010';
  SELECT pd.recoverable_tax new_tax,
         pd.nonrecoverable_tax new_nr_tax,
         pda.recoverable_tax old_tax,
         pda.nonrecoverable_tax old_nr_tax
  INTO   x_recoverable_tax,
         x_non_recoverable_tax,
         x_old_recoverable_tax,
         x_old_non_recoverable_tax
  FROM   po_distributions_all pd,
         po_distributions_archive_all pda
  WHERE  pd.po_distribution_id = p_distribution_id
  AND    pd.po_distribution_id = pda.po_distribution_id (+)
  AND    pda.latest_external_flag (+) = 'Y';

  l_progress := '020';
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_data := NULL;
EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('Exception of Get_All_PO_Tax()',
                           l_progress , sqlcode);
    FND_MSG_PUB.Add;
    x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                  p_encoded => 'F');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

-- <FPJ Retroactive Price END>

END po_tax_sv;


/
