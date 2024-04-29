--------------------------------------------------------
--  DDL for Package Body PO_AP_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_AP_INTEGRATION_PVT" AS
/* $Header: POXVAPIB.pls 115.1 2004/03/25 07:17:01 axian noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_AP_INTEGRATION_PVT';

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_invoice_numbering_options
--Pre-reqs:
--  p_org_id is not null
--Modifies:
--  FND_MSG_PUB on error
--Locks:
--  None
--Function:
--  Retrieves the invoice numbering options: the gapless invoice numbering
--  flag and the buying company identifier
--Parameters:
--IN:
--p_api_version:
--  Version number of API that caller expects. It should match the constant
--  'l_api_version' defined in the procedure.
--p_org_id
--  Operating unit ID that will be used to retrieve OU-specific invoice
--  numbering options
--OUT:
--x_return_status:
--  FND_API.g_ret_sts_success -- if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error -- if an unexpected error occurred
--x_msg_data:
--  Error message text in case of exception/error
--x_buying_company_identifier:
--  Self-bill buying company identifier from the Purchasing Options of the
--  input OU
--x_gapless_inv_num_flag:
--  If gapless invoice numbering is enabled, return Y; else return N
--Testing:
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_invoice_numbering_options
(
  p_api_version                 IN  NUMBER,
  p_org_id                      IN  NUMBER,
  x_return_status               OUT NOCOPY VARCHAR2,
  x_msg_data                    OUT NOCOPY VARCHAR2,
  x_buying_company_identifier   OUT NOCOPY VARCHAR2,
  x_gapless_inv_num_flag        OUT NOCOPY VARCHAR2
)
IS
  l_api_version       CONSTANT NUMBER := 1.0;
  l_api_name          CONSTANT VARCHAR2(30) := 'get_invoice_numbering_options';
  l_progress          VARCHAR2(3) := '000';

BEGIN
  l_progress := '010';

  -- Standard call to check for call compatibility
  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status:= FND_API.g_ret_sts_success;
  l_progress := '020';

  -- SQL What: Get invoice number options from PO system parameters
  -- SQL Why: Need to pass back x_gapless_inv_num_flag and x_buying_company_identifier
  SELECT nvl(gapless_inv_num_flag, 'N'), buying_company_identifier
  INTO   x_gapless_inv_num_flag, x_buying_company_identifier
  FROM   PO_SYSTEM_PARAMETERS_ALL
  WHERE  org_id = p_org_id;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_gapless_inv_num_flag := 'N';
       x_buying_company_identifier := NULL;
       x_return_status := FND_API.g_ret_sts_unexp_error;
       x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                     p_encoded   => 'F');
  WHEN OTHERS THEN
       x_gapless_inv_num_flag := 'N';
       x_buying_company_identifier := NULL;
       x_return_status := FND_API.g_ret_sts_unexp_error;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
          FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                  p_procedure_name => l_api_name,
                                  p_error_text     => SUBSTRB(SQLERRM, 1, 200)
                                                ||' at location '||l_progress);
       END IF;
       x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                     p_encoded   => 'F');

END get_invoice_numbering_options;

END PO_AP_INTEGRATION_PVT;

/
