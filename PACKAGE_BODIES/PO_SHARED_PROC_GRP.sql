--------------------------------------------------------
--  DDL for Package Body PO_SHARED_PROC_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SHARED_PROC_GRP" AS
/* $Header: POXGSPSB.pls 115.3 2003/09/30 23:05:15 mbhargav noship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');

g_pkg_name CONSTANT VARCHAR2(20) := 'PO_SHARED_PROC_GRP';
g_module_prefix CONSTANT VARCHAR2(30) := 'po.plsql.' || g_pkg_name || '.';


--------------------------------------------------------------------------------
--Start of Comments
--Name: check_shared_proc_scenario
--Pre-reqs:
--  None.
--Modifies:
--  FND_MSG_PUB on error.
--Locks:
--  None.
--Function:
--  Determines if it is a Shared Procurement Services (SPS) scenario.
--Parameters:
--IN:
--  p_api_version
--    : Version number of API that caller expects. It should match the
--      constant 'l_api_version' defined in the procedure.
--  p_init_msg_list
--    : API standard parameter that indicates if the FND message list
--      needs to be reset at the start of this procedure.
--  p_document_type_code
--    : The PO's document type code.
--  p_ship_to_inv_org_id NUMBER
--    : Destination(Ship-to) Inventory Org ID
--  p_purchasing_ou_id NUMBER,
--    : Purchasing OU's org ID
--  p_transaction_flow_header_id NUMBER,
--    : Transaction flow's header ID, if a Txn flow exists between the
--      DOU and POU
--  p_project_id NUMBER,
--    : Project ID specified on the distribution
--  p_destination_type_code VARCHAR2
--    : Destination Type Code specified on the distribution
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_error - if an error occurred
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_is_shared_proc_scenario
--  'Y'  if it is a shared procurement scenario.
--  'N' otherwise.
--Testing:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE check_shared_proc_scenario
(
    p_api_version                IN  NUMBER,
    p_init_msg_list              IN  VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    p_destination_type_code      IN  VARCHAR2,
    p_document_type_code         IN  VARCHAR2,
    p_project_id                 IN  NUMBER,
    p_purchasing_ou_id           IN  NUMBER,
    p_ship_to_inv_org_id         IN  NUMBER,
    p_transaction_flow_header_id IN  NUMBER,
    x_is_shared_proc_scenario    OUT NOCOPY VARCHAR2
)
IS
  l_api_version       CONSTANT NUMBER := 1.0;
  l_api_name          CONSTANT VARCHAR2(30) := 'check_shared_proc_scenario';
  l_ship_to_ou_id     NUMBER;
  l_ship_to_ou_coa_id NUMBER;
  l_return_status     VARCHAR2(1);
  l_is_shared_proc_scenario BOOLEAN;
BEGIN
  -- Standard call to check for call compatibility
  IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                     l_api_name, g_pkg_name) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- Start standard API initialization
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Derive the Ship-to-OU ID from the p_ship_to_inv_org_id
  PO_SHARED_PROC_PVT.get_ou_and_coa_from_inv_org(
                   p_inv_org_id    => p_ship_to_inv_org_id, -- IN
                   x_coa_id        => l_ship_to_ou_coa_id,  -- OUT
                   x_ou_id         => l_ship_to_ou_id,      -- OUT
                   x_return_status => l_return_status);     -- OUT

  IF (l_return_status <> FND_API.g_ret_sts_success) THEN
    APP_EXCEPTION.raise_exception(
                   exception_type => 'SHARED_PROC_EXCEPTION',
                   exception_code => 0,
                   exception_text => 'PO_SHARED_PROC_PVT.' ||
                                     'get_ou_and_coa_from_inv_org');
  END IF;

  -- Call the private function
  l_is_shared_proc_scenario := PO_SHARED_PROC_PVT.is_SPS_distribution(
                 p_destination_type_code      => p_destination_type_code,
                 p_document_type_code         => p_document_type_code,
                 p_purchasing_ou_id           => p_purchasing_ou_id,
                 p_project_id                 => p_project_id,
                 p_ship_to_ou_id              => l_ship_to_ou_id,
                 p_transaction_flow_header_id => p_transaction_flow_header_id);

  IF (l_is_shared_proc_scenario) THEN
    x_is_shared_proc_scenario := 'Y';
  ELSE
    x_is_shared_proc_scenario := 'N';
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;
  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                            p_procedure_name => l_api_name);
END check_shared_proc_scenario;

END PO_SHARED_PROC_GRP;

/
