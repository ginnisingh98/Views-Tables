--------------------------------------------------------
--  DDL for Package Body PO_JL_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_JL_INTERFACE_PVT" AS
/* $Header: POXVJLIB.pls 120.1 2005/06/21 02:52:56 vsanjay noship $ */

-- Debugging booleans used to bypass logging when turned off
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

g_pkg_name CONSTANT VARCHAR2(20) := 'PO_JL_INTERFACE_PVT';
g_module_prefix CONSTANT VARCHAR2(30) := 'po.plsql.' || g_pkg_name || '.';


--------------------------------------------------------------------------------
--Start of Comments
--Name: get_trx_reason_code
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB on error.
--Locks:
--  None.
--Function:
--  Derives default transaction reason codes based upon the input parameters
--  given. Defaulting logic implemented by JL team. Appends to the API message
--  list upon error.
--Parameters:
--IN:
--p_fsp_inv_org_id
--  The item validation inventory org ID of p_org_id.
--p_inventory_org_id_tbl
--  A table of inventory org ID's to derive transaction reason codes for. These
--  elements should correspond to p_item_id_tbl.
--p_item_id_tbl
--  A table of item ID's to derive transaction reason codes for. These elements
--  should correpsond to p_inventory_org_id_tbl.
--p_org_id
--  The operating unit ID to derive defaulting rules.
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_trx_reason_code_tbl
--  A table of transaction reason codes corresponding to the input tables.
--x_error_code_tbl
--  A table of error codes corresponding to the input tables. A value of zero
--  means there is no error for that element in the table.
--End of Comments
--------------------------------------------------------------------------------

/*Bug#4430300 Replaced the references to JLBR data types with the po standard data types
and also removed all the JL_BR package references */

PROCEDURE get_trx_reason_code
    ( p_fsp_inv_org_id       IN  NUMBER
    , p_inventory_org_id_tbl IN  po_tbl_number
    , p_item_id_tbl          IN  po_tbl_number
    , p_org_id               IN  NUMBER
    , x_return_status        OUT NOCOPY VARCHAR2
    , x_trx_reason_code_tbl  OUT NOCOPY po_tbl_varchar100
    , x_error_code_tbl       OUT NOCOPY po_tbl_number
    )
IS

l_api_name CONSTANT VARCHAR2(30) := 'get_trx_reason_code';
l_progress VARCHAR2(3);

BEGIN

    l_progress := '000';
    x_return_status :=  FND_API.g_ret_sts_success;


EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF g_debug_unexp THEN
            PO_DEBUG.debug_unexp(g_module_prefix||l_api_name,l_progress,
                                 'Unexpected error from API call');
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => l_api_name||'-'||l_progress);
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc(g_module_prefix||l_api_name,l_progress);
        END IF;
END get_trx_reason_code;


--------------------------------------------------------------------------------
--Start of Comments
--Name: get_trx_reason_code
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB on error.
--Locks:
--  None.
--Function:
--  Derives a default transaction reason code based upon the input parameters
--  given. Defaulting logic implemented by JL team. Appends to the API message
--  list upon error.
--Parameters:
--IN:
--p_fsp_inv_org_id
--  The item validation inventory org ID of p_org_id.
--p_inventory_org_id
--  The inventory org ID to derive a transaction reason code for.
--p_item_id
--  The item ID to derive a transaction reason code for.
--p_org_id
--  The operating unit ID to derive defaulting rules.
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error - an error occurred
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_trx_reason_code
--  The derived transaction reason code.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_trx_reason_code
    ( p_fsp_inv_org_id    IN  NUMBER
    , p_inventory_org_id  IN  NUMBER
    , p_item_id           IN  NUMBER
    , p_org_id            IN  NUMBER
    , x_return_status     OUT NOCOPY VARCHAR2
    , x_trx_reason_code   OUT NOCOPY VARCHAR2
    )
IS

l_api_name CONSTANT VARCHAR2(30) := 'get_trx_reason_code_2';
l_progress VARCHAR2(3);

/*Bug#4430300 Replaced the references to JLBR data types with the po standard data types */

l_trx_reason_code_tbl  po_tbl_varchar100 ;
l_error_code_tbl      po_tbl_number;

BEGIN
    l_progress := '000';

    x_return_status :=  FND_API.g_ret_sts_success;


EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(g_module_prefix||l_api_name,l_progress,
                                'Expected error from API call');
        END IF;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF g_debug_unexp THEN
            PO_DEBUG.debug_unexp(g_module_prefix||l_api_name,l_progress,
                                 'Unexpected error from API call');
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => l_api_name||'-'||l_progress);
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc(g_module_prefix||l_api_name,l_progress);
        END IF;
END get_trx_reason_code;


--------------------------------------------------------------------------------
--Start of Comments
--Name: chk_def_trx_reason_flag
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB on error.
--Locks:
--  None.
--Function:
--  Check if transaction reason defaulting is available in the current org
--  context. Appends to the API message list upon error.
--Parameters:
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_def_trx_reason_flag
--  A flag: 'Y' default transaction reason
--          'N' do not default transaction reason
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE chk_def_trx_reason_flag
    ( x_return_status       OUT NOCOPY VARCHAR2
    , x_def_trx_reason_flag OUT NOCOPY VARCHAR2
    )
IS

l_api_name CONSTANT VARCHAR2(30) := 'chk_def_trx_reason_flag';
l_progress VARCHAR2(3);

BEGIN
    l_progress := '000';
     x_return_status :=  FND_API.g_ret_sts_success;

EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF g_debug_unexp THEN
            PO_DEBUG.debug_unexp(g_module_prefix||l_api_name,l_progress,
                                 'Unexpected error from API call');
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => l_api_name||'-'||l_progress);
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc(g_module_prefix||l_api_name,l_progress);
        END IF;
END chk_def_trx_reason_flag;

END PO_JL_INTERFACE_PVT;

/
