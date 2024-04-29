--------------------------------------------------------
--  DDL for Package Body PO_SHARED_PROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SHARED_PROC_PVT" AS
/* $Header: POXVSPSB.pls 120.0.12010000.3 2013/10/18 06:00:41 inagdeo ship $ */

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_SHARED_PROC_PVT');

-- Debugging booleans used to bypass logging when turned off
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

g_pkg_name CONSTANT VARCHAR2(20) := 'PO_SHARED_PROC_PVT';
g_module_prefix CONSTANT VARCHAR2(30) := 'po.plsql.' || g_pkg_name || '.';

-- Transaction flows are supported if INV FPJ or higher is installed
g_is_txn_flow_supported CONSTANT BOOLEAN :=
    (INV_CONTROL.get_current_release_level >= INV_RELEASE.get_j_release_level);

c_ENTITY_TYPE_LINE CONSTANT VARCHAR2(30) := PO_VALIDATIONS.c_ENTITY_TYPE_LINE;

--------------------------------------------------------------------------------
--Start of Comments
--Name: check_transaction_flow
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB on error.
--Locks:
--  None.
--Function:
--  Check if an inventory transaction flow exists for input parameters given.
--  Appends to the API message list upon error.
--Parameters:
--IN:
--p_init_msg_list
--p_start_ou_id
--  Start OU of the transaction flow.
--p_end_ou_id
--  End OU of the transaction flow. Defaults to OU of p_ship_to_org_id if this
--  is NULL.
--p_ship_to_org_id
--  The ship-to organization of the transaction flow.
--p_item_category_id
--  Item category ID of the transaction flow, if one exists.
--p_transaction_date
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_error - if an error occurred
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_transaction_flow_header_id
--  The unique header ID of the transaction flow, if any valid inter-company
--  relationship exists.  If not flow was found, then this is NULL.
--  (MTL_TRANSACTION_FLOW_HEADERS.header_id%TYPE)
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE check_transaction_flow
(
    p_init_msg_list              IN  VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    p_start_ou_id                IN  NUMBER,
    p_end_ou_id                  IN  NUMBER,
    p_ship_to_org_id             IN  NUMBER,
    p_item_category_id           IN  NUMBER,
    p_transaction_date           IN  DATE,
    x_transaction_flow_header_id OUT NOCOPY NUMBER
)
IS

l_end_ou_id MTL_TRANSACTION_FLOW_HEADERS.end_org_id%TYPE := p_end_ou_id;

l_qual_code_tbl  INV_TRANSACTION_FLOW_PUB.number_tbl;
l_qual_val_tbl   INV_TRANSACTION_FLOW_PUB.number_tbl;

l_new_accounting_flag MTL_TRANSACTION_FLOW_HEADERS.new_accounting_flag%TYPE;
l_txn_flow_exists VARCHAR2(1);

l_progress VARCHAR2(3);
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);

BEGIN
    l_progress := '000';

    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    l_progress := '010';

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
            (p_log_head => g_module_prefix||'check_transaction_flow',
             p_token    => 'invoked',
             p_message  => 'startou ID: '||p_start_ou_id||' endou ID: '||
                          p_end_ou_id||' shipto org: '||p_ship_to_org_id||
                          ' item cat ID: '||p_item_category_id||' txn date: '||
                          TO_CHAR(p_transaction_date,'DD-MON-RRRR HH24:MI:SS'));
    END IF;

    -- Make sure that transaction flows are supported
    IF (NOT g_is_txn_flow_supported) THEN
        -- Transaction flows not supported, so return immediately
        x_transaction_flow_header_id := NULL;
        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt
                (p_log_head => g_module_prefix||'check_transaction_flow',
                 p_token    => l_progress,
                 p_message  => 'Transaction flows not supported');
        END IF;
        RETURN;
    END IF;

    -- Default the End operating unit if it is NULL
    IF (l_end_ou_id IS NULL) THEN
        l_progress := '020';
        PO_CORE_S.get_inv_org_ou_id(x_return_status => x_return_status,
                                    p_inv_org_id    => p_ship_to_org_id,
                                    x_ou_id         => l_end_ou_id);

        IF (x_return_status <> FND_API.g_ret_sts_success) THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF;
    END IF;

    l_progress := '030';

    -- Never use a transaction flow if the start and end OU's are equal
    IF (p_start_ou_id = l_end_ou_id) THEN
        x_transaction_flow_header_id := NULL;
        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt
                (p_log_head => g_module_prefix||'check_transaction_flow',
                 p_token    => l_progress,
                 p_message  => 'Start OU and End OU same, so just return');
        END IF;
        RETURN;
    END IF;

    -- Initialize tables if have item_category_id
    IF (p_item_category_id IS NOT NULL) THEN
        l_qual_code_tbl(1) := get_inv_qualifier_code;
        l_qual_val_tbl(1) := p_item_category_id;
    END IF;

    l_progress := '040';

    -- Try to get a valid transaction flow
    INV_TRANSACTION_FLOW_PUB.check_transaction_flow
      (p_api_version          => 1.0,
       x_return_status        => x_return_status,
       x_msg_count            => l_msg_count,
       x_msg_data             => l_msg_data,
       p_start_operating_unit => p_start_ou_id,
       p_end_operating_unit   => l_end_ou_id,
       p_flow_type            => INV_TRANSACTION_FLOW_PUB.g_procuring_flow_type,
       p_organization_id      => p_ship_to_org_id,
       p_qualifier_code_tbl   => l_qual_code_tbl,
       p_qualifier_value_tbl  => l_qual_val_tbl,
       p_transaction_date     => p_transaction_date,
       x_header_id            => x_transaction_flow_header_id,
       x_new_accounting_flag  => l_new_accounting_flag,
       x_transaction_flow_exists => l_txn_flow_exists);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        l_progress := '050';
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        l_progress := '060';
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_progress := '070';

    -- Null out the header ID if the txn flow does not exist
    IF (l_txn_flow_exists IS NULL) OR
       (l_txn_flow_exists <> INV_TRANSACTION_FLOW_PUB.g_transaction_flow_found)
    THEN
        x_transaction_flow_header_id := NULL;
    END IF;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
            (p_log_head => g_module_prefix||'check_transaction_flow',
             p_token    => l_progress,
             p_message  => 'transaction flow = '||x_transaction_flow_header_id);
    END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
        x_transaction_flow_header_id := NULL;
        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt
                (p_log_head => g_module_prefix||'check_transaction_flow',
                 p_token    => l_progress,
                 p_message  => 'Expected error occurred.');
        END IF;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        x_transaction_flow_header_id := NULL;
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
                (p_log_head => g_module_prefix||'check_transaction_flow',
                 p_progress => l_progress);
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        x_transaction_flow_header_id := NULL;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'check_transaction_flow',
                                p_error_text     => 'Progress: '||l_progress||
                                           ' Error: '||SUBSTRB(SQLERRM,1,215));
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
                (p_log_head => g_module_prefix||'check_transaction_flow',
                 p_progress => l_progress);
        END IF;
END check_transaction_flow;

---------------------------------------------------------------------------
--Start of Comments
--Name: get_coa_from_inv_org
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  To get the Chart of Account (COA) tied to a Set of Books that, in turn, is
--  tied to a Operating Unit to which a given Inventory Org belongs.
--Parameters:
--IN:
--p_inv_org_id
--  The ID of an Inventory Organization
--Returns:
--  NUMBER: The COA of SOB tied to the OU to which a given Inv Org belongs.
--          -1, if there is a NO_DATA_FOUND exception in the query.
--Testing:
--End of Comments
---------------------------------------------------------------------------
FUNCTION get_coa_from_inv_org
(
    p_inv_org_id IN NUMBER
)
RETURN NUMBER
IS
 l_coa_id GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;
BEGIN
  --SQL WHAT: Derive the COA tied to a Set of Books that, in turn, is
  --          tied to a Operating Unit to which a given Inventory Org belongs.
  --SQL WHY:  To define the Destination Account flexfield structure.
  SELECT gsb.chart_of_accounts_id
  INTO l_coa_id
  FROM gl_sets_of_books gsb,
       hr_organization_information hoi,
       mtl_parameters mp
  WHERE mp.organization_id = p_inv_org_id
    AND mp.organization_id = hoi.organization_id
    AND hoi.org_information_context = 'Accounting Information'
    AND TO_NUMBER(hoi.org_information1) = gsb.set_of_books_id;

  return(l_coa_id);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return -1; -- may be raised as an exception in the calling program
  WHEN OTHERS THEN
    IF ( g_debug_unexp )
    THEN
        PO_DEBUG.debug_exc ( p_log_head => g_module_prefix || 'get_coa_from_inv_org'
                           , p_progress => '000' );
    END IF;
    RAISE;
END get_coa_from_inv_org;


---------------------------------------------------------------------------
--Start of Comments
--Name: get_ou_and_coa_from_inv_org
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  To get the Chart of Account (COA) tied to a Set of Books that, in turn, is
--  tied to a Operating Unit to which a given Inventory Org belongs.
--  Also, get the OU's org ID to which the Inventory Org belongs.
--Parameters:
--IN:
--p_inv_org_id
--  The ID of an Inventory Organization
--OUT:
--x_ou_id         OUT NOCOPY NUMBER
--  The OU's org ID to which the Inventory Org belongs.
--x_coa_id        OUT NOCOPY NUMBER,
--  The Chart of Account (COA) tied to a Set of Books that, in turn, is
--  tied to a Operating Unit to which a given Inventory Org belongs.
--x_return_status OUT NOCOPY VARCHAR2
--  FND_API.g_ret_sts_success: if the query is executed successfully.
--  FND_API.g_ret_sts_error: if NO_DATA_FOUND exception occurs.
--  FND_API.g_ret_sts_unexp_error: if any other exception occurs.
--Testing:
--End of Comments
---------------------------------------------------------------------------
PROCEDURE get_ou_and_coa_from_inv_org
(
    p_inv_org_id    IN  NUMBER,
    x_coa_id        OUT NOCOPY NUMBER,
    x_ou_id         OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
  --SQL WHAT: Derive the COA tied to a Set of Books that, in turn, is
  --          tied to a Operating Unit to which a given Inventory Org belongs.
  --          Also, get the OU's org ID to which the Inventory Org belongs.
  --SQL WHY:  To define the Destination Account flexfield structure.
  SELECT TO_NUMBER(hoi.org_information3), gsb.chart_of_accounts_id
  INTO x_ou_id, x_coa_id
  FROM gl_sets_of_books gsb,
       hr_organization_information hoi,
       mtl_parameters mp
  WHERE mp.organization_id = p_inv_org_id
    AND mp.organization_id = hoi.organization_id
    AND hoi.org_information_context = 'Accounting Information'
    AND TO_NUMBER(hoi.org_information1) = gsb.set_of_books_id;

  x_return_status := FND_API.g_ret_sts_success;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     -- may be raised as an exception in the calling program
    x_return_status := FND_API.g_ret_sts_error;
  WHEN OTHERS THEN
    IF ( g_debug_stmt )
    THEN
        PO_DEBUG.debug_exc ( p_log_head => g_module_prefix || 'get_ou_and_coa_from_inv_org'
                           , p_progress => '000' );
    END IF;
    x_return_status := FND_API.g_ret_sts_unexp_error;
END get_ou_and_coa_from_inv_org;

---------------------------------------------------------------------------
--Start of Comments
--Name: is_SPS_distribution
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Determines if it is a Shared Procurement Services (SPS) distribution.
--Parameters:
--IN:
--  p_document_type_code
--    : The PO's document type code.
--  p_ship_to_ou_id NUMBER
--    : Destination(Ship-to) OU's org ID
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
--  None
--RETURN:
--  BOOLEAN -- TRUE : if it is a SPS distribution
--             FALSE: otherwise
--Testing:
--End of Comments
---------------------------------------------------------------------------
FUNCTION is_SPS_distribution
(
    p_destination_type_code      IN VARCHAR2,
    p_document_type_code         IN VARCHAR2,
    p_purchasing_ou_id           IN NUMBER,
    p_project_id                 IN NUMBER,
    p_ship_to_ou_id              IN NUMBER,
    p_transaction_flow_header_id IN NUMBER
)
RETURN BOOLEAN
IS
  l_is_SPS_distribution BOOLEAN := FALSE;
BEGIN
  -- A distribution is a SPS distribution, if it meets the following 4
  -- conditions:
  -- 1. The PO is a Standard PO.
  -- 2. DOU <> POU.
  -- 3. A transaction flow is defined between DOU and POU.
  -- 4. For Expense destination types, NO Project is specified on the
  --    distribution.
  l_is_SPS_distribution := FALSE;
  IF ( (p_document_type_code = 'STANDARD') AND
       (p_ship_to_ou_id <> p_purchasing_ou_id) AND
       (p_transaction_flow_header_id IS NOT NULL) ) THEN
    l_is_SPS_distribution := TRUE;
  END IF;

  -- <bug 3379488>
  -- Removed the project related checks since we have decided not to allow
  -- the entry for project information if there is a trx flow defined for expense dest.

  RETURN l_is_SPS_distribution;
END is_SPS_distribution;

-------------------------------------------------------------------------------
--Start of Comments
--Name: IS_PA_PROJECT_REFERENCED
--Pre-reqs:
--  Assumes that project_id is necessary and sufficient indicator of project reference.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Checks whether destination type is expense for the line and project_id field
--  on the corresponding distribution lines is not NULL
--Parameters:
--IN:
--p_requisition_line_id
--  The unique identifier of requisition line to be examined
--Returns:
--  TRUE if PA_PROJECT is referenced, FALSE otherwise
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_pa_project_referenced
(
    p_requisition_line_id IN NUMBER
)
RETURN BOOLEAN
IS
l_valid_pa_project_referenced  VARCHAR2(1);
BEGIN
        --SQL WHAT: Matches destination_type_code as expense at line level
        --            Also looks for project information at distribution level
        --SQL WHY: This check is required as in SPS project we need to
        --                     prevent procurement across OUs in this scenerio

    SELECT 'Y'
    INTO    l_valid_pa_project_referenced
    FROM    po_requisition_lines_all prl
    WHERE   prl.requisition_line_id = p_requisition_line_id
      AND   prl.destination_type_code = 'EXPENSE'
      AND   EXISTS
              (SELECT 'valid pa information'
               FROM    po_req_distributions_all prd                 -- <HTMLAC>
               WHERE   prd.requisition_line_id = p_requisition_line_id
               AND     prd.project_id IS NOT NULL);

	IF l_valid_pa_project_referenced = 'Y' THEN
		RETURN (TRUE);
	ELSE
		RETURN (FALSE);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		RETURN (FALSE);
END is_pa_project_referenced;

-------------------------------------------------------------------------------
--Start of Comments
--Name: Validate_cross_ou_purchasing
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  This function validates that its OK to cross operating unit boundaries
--  for creation of Purchase Order. Following checks are done
--  (checks 1, 2, 4, 5, 6, 7, 8, 9, and 10 are performed only for Standard POs;
--   for Global Agreements, these checks will be performed upon creation
--   of the Standard PO release).
--     1. Line is not VMI enabled
--     2. Consigned relationship should not exist
--     3. Item is valid in the involved Operating Units
--     4. PA Project reference for destination type of expense should not exist
--     5. Destination Inv Org should not be OPM enabled
--     6. Following scenario should not exist: Destination OU is same as
--        Purchasing OU but is different from Req OU
--     7. Transaction flow between Purchasing OU and Destination OU should exist
--     8. For Services Line type, if 'HR: Cross Business Groups' is NO then ROU
--        and POU should rollup to the same Business Group
--     9. If the deliver-to-location on req Line is customer location then
--        OM family pack J should be installed
--     10.If Encumbrance is enabled for Purchasing/Requesting Org, then
--        Purchasing Org should not be different than Requesting Org
--Parameters:
--IN
--p_api_version
--  standard parameter which specifies the API version
--p_requisition_line_id
--  The req line which needs to investigated
--p_requesting_org_id
--  The OU of requisition raising OU
--p_purchasing_org_id
--  The OU where PO will be created
--p_item_id
--  Can be NULL
--p_source_doc_id
--  If a GA is referenced then this parameter contains
--  the GA header_id otherwise its NULL
--p_vmi_flag
--  'Y' or 'N' indicating whether line is vmi enabled
--p_cons_from_supp_flag
--  'Y' or 'N' corresponding to consigned_from_supp_flag
--  This attribute is obtained from ASL attributes.
--p_document_type
--  Document Type of the outcome document.
--OUT
--x_return_status
--  Standard return status parameter. This parameter tells
--  whether all validations are passed.
--x_errormsg_name
--  This parameter contains  relevant message when return status is
--  not G_RET_STS_SUCCESS
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_cross_ou_purchasing
(
    p_api_version         IN NUMBER,
    p_requisition_line_id IN NUMBER,
    p_requesting_org_id   IN NUMBER,
    p_purchasing_org_id   IN NUMBER,
    p_item_id             IN NUMBER,
    p_source_doc_id       IN NUMBER,
    p_vmi_flag            IN VARCHAR2,
    p_cons_from_supp_flag IN VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_error_msg_name      OUT NOCOPY VARCHAR2,
    p_document_type       IN VARCHAR2 := 'STANDARD'                 -- <HTMLAC>
)
IS

l_pa_project                 BOOLEAN := FALSE;
l_transaction_flow_status    VARCHAR2(1);
l_dest_inv_org_ou_id         PO_SYSTEM_PARAMETERS_ALL.org_id%TYPE;
l_transaction_flow_header_id MTL_TRANSACTION_FLOW_HEADERS.header_id%TYPE;
l_category_id                PO_REQUISITION_LINES_ALL.category_id%TYPE;
l_api_name                   CONSTANT VARCHAR2 (30) := 'validate_cross_ou_purchasing';
l_api_version                CONSTANT NUMBER        := 1.0;
l_dest_inv_org_id            PO_REQUISITION_LINES_ALL.destination_organization_id%TYPE;
l_owning_org_id              PO_HEADERS_ALL.org_id%TYPE;
l_deliver_to_location_id     PO_REQUISITION_LINES_ALL.deliver_to_location_id%TYPE;
l_is_customer_location       VARCHAR2(1) := 'N';
l_progress                   VARCHAR2(3) := '000';
l_item_valid_status          VARCHAR2(1);
l_item_valid_msg_name        FND_NEW_MESSAGES.message_name%TYPE;
x_app_name                   VARCHAR2(10);
l_purchase_basis             PO_REQUISITION_LINES_ALL.purchase_basis%TYPE;
l_pou_bus_group_id           HR_ALL_ORGANIZATION_UNITS.business_group_id%TYPE;
l_rou_bus_group_id           HR_ALL_ORGANIZATION_UNITS.business_group_id%TYPE;
l_item_in_linv_pou           VARCHAR2(1) := 'Y'; -- Bug 3433867

BEGIN

    l_progress := '001';
    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name
                                     )
    THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_progress := '002';

    -- Bug 3379488: Only perform the original checks when ROU and POU are not
    -- the same; perform a new check for project information of expense
    -- destination in the ELSE clause (when ROU and POU are the same)
    IF p_requesting_org_id <> p_purchasing_org_id THEN

       l_progress := '003';

        --CHECK 1: The line should not be VMI enabled

        IF ( p_document_type = 'STANDARD' ) THEN                    -- <HTMLAC>

            IF p_vmi_flag = 'Y' THEN
               x_error_msg_name := 'PO_CROSS_OU_VMI_CHECK';
               x_return_status := FND_API.G_RET_STS_ERROR;
               Return;
            END IF;

        END IF;

        l_progress := '004';

        --CHECK 2: If Consigned relationship exists then we error out

        IF ( p_document_type = 'STANDARD' ) THEN                    -- <HTMLAC>

            IF p_cons_from_supp_flag = 'Y' THEN
                x_error_msg_name := 'PO_CROSS_OU_CONSIGNED_CHECK';
                x_return_status := FND_API.G_RET_STS_ERROR;
                Return;
            END IF;

        END IF;

       l_progress := '005';
       --CHECK 3: Item should be valid in following  OUs -
       --For Lines with GA reference: Requesting, Owning and Purchasing
       --For lines with no source doc info: Requesting and Purchasing
       IF PO_GA_PVT.is_global_agreement(p_source_doc_id) THEN
          l_owning_org_id := PO_GA_PVT.get_org_id(p_source_doc_id);
          do_item_validity_checks(
                      p_item_id             => p_item_id,
                      p_org_id              => p_purchasing_org_id,
                      p_valid_org_id        => l_owning_org_id,
                      p_do_osp_check        => TRUE,
                      x_return_status       => l_item_valid_status,
                      x_item_valid_msg_name => l_item_valid_msg_name);

          IF l_item_valid_status = FND_API.G_RET_STS_ERROR THEN
             x_error_msg_name := l_item_valid_msg_name;
             x_return_status := FND_API.G_RET_STS_ERROR;
             Return;
          END IF;

          do_item_validity_checks(
                      p_item_id             => p_item_id,
                      p_org_id              => p_requesting_org_id,
                      p_valid_org_id        => l_owning_org_id,
                      p_do_osp_check        => TRUE,
                      x_return_status       => l_item_valid_status,
                      x_item_valid_msg_name => l_item_valid_msg_name);

          IF l_item_valid_status = FND_API.G_RET_STS_ERROR THEN
             x_error_msg_name := l_item_valid_msg_name;
             x_return_status := FND_API.G_RET_STS_ERROR;
             Return;
          END IF;

       ELSE
          do_item_validity_checks(
                      p_item_id             => p_item_id,
                      p_org_id              => p_purchasing_org_id,
                      p_valid_org_id        => p_requesting_org_id,
                      p_do_osp_check        => FALSE,
                      x_return_status       => l_item_valid_status,
                      x_item_valid_msg_name => l_item_valid_msg_name);

          IF l_item_valid_status = FND_API.G_RET_STS_ERROR THEN
             x_error_msg_name := l_item_valid_msg_name;
             x_return_status := FND_API.G_RET_STS_ERROR;
             Return;
          END IF;

       END IF;

        l_progress := '006';

        --CHECK 4:Procurement across OUs is not supported for PA Projects
        --Check whether destination type is expense for the line and project_id
        --field on the corresponding distribution line is not NULL

        IF ( p_document_type = 'STANDARD' ) THEN                    -- <HTMLAC>

            l_pa_project := is_pa_project_referenced(p_requisition_line_id);

            IF l_pa_project THEN
                x_error_msg_name := 'PO_CROSS_OU_PA_PROJECT_CHECK';
          		x_return_status := FND_API.G_RET_STS_ERROR;
          		Return;
            END IF;

        END IF;

       l_progress := '007';
       --SQL WHAT: Get the necessary information from the given requisition line
       --SQL WHY: This information is needed for validation checks later
       SELECT prl.category_id,
              nvl(prl.destination_organization_id, fsp.inventory_organization_id),
              prl.deliver_to_location_id
       INTO   l_category_id, l_dest_inv_org_id, l_deliver_to_location_id
       FROM   po_requisition_lines_all prl, financials_system_params_all fsp
       WHERE  prl.requisition_line_id = p_requisition_line_id
       AND    prl.org_id = fsp.org_id; -- Bug 3379488: Use base table for joins

       -- MC INVCONV START
       /**
        l_progress := '008';

        --CHECK 5:Procurment across OUs is not supported for OPM enabled
        --destination inventory orgs

        IF ( p_document_type = 'STANDARD' ) THEN                    -- <HTMLAC>

            IF (PO_GML_DB_COMMON.check_process_org(l_dest_inv_org_id) = 'Y') THEN

                x_error_msg_name := 'PO_CROSS_OU_OPM_INV_CHECK';
          		x_return_status := FND_API.G_RET_STS_ERROR;
          		Return;

            END IF;

        END IF;
	**/
       -- MC INVCONV END

       l_progress := '009';
       --Get the operating unit of destination inv org
       IF (l_dest_inv_org_id IS NOT NULL) THEN
          PO_CORE_S.get_inv_org_ou_id(x_return_status => x_return_status,
                                      p_inv_org_id    => l_dest_inv_org_id,
                                      x_ou_id         => l_dest_inv_org_ou_id);

          IF (x_return_status <> FND_API.g_ret_sts_success) THEN
             RAISE FND_API.g_exc_unexpected_error;
          END IF;
       END IF;

        l_progress := '010';

        --CHECK 6:If (DOU=POU)<>ROU then we are preventing the PO creation.
        --This is scoped out due to accounting complexities

        IF ( p_document_type = 'STANDARD' ) THEN                    -- <HTMLAC>

            IF (l_dest_inv_org_ou_id = p_purchasing_org_id AND

                l_dest_inv_org_ou_id <> p_requesting_org_id) THEN
            	x_error_msg_name := 'PO_CROSS_OU_DEST_OU_CHECK';
          		x_return_status := FND_API.G_RET_STS_ERROR;
          		Return;

            END IF;

        END IF;

        l_progress := '011';

        --CHECK 7:Procurement across OUs is allowed only when a valid
        --transaction flow exists between Purchasing OU and Destination OU.
        --If the category_id is NOT NULL then we use it to find flow. The
        --API forst check if a flow exists with given category otherwise it
        --tries to find a non category specific transaction flow.

        IF ( p_document_type = 'STANDARD' ) THEN                    -- <HTMLAC>

            Check_transaction_flow(
             p_init_msg_list              => FND_API.G_FALSE,
          	 x_return_status              => l_transaction_flow_status,
          	 p_start_ou_id                => p_purchasing_org_id,
          	 p_end_ou_id                  => l_dest_inv_org_ou_id,
          	 p_ship_to_org_id             => l_dest_inv_org_id,
          	 p_item_category_id           => l_category_id,
          	 p_transaction_date           => SYSDATE,
          	 x_transaction_flow_header_id => l_transaction_flow_header_id
       		);

            l_progress := '012';

            --If transaction flow does not exist then return error

            IF ((l_transaction_flow_status <> FND_API.G_RET_STS_SUCCESS) OR
                l_transaction_flow_header_id is NULL) THEN
          	    x_error_msg_name := 'PO_CROSS_OU_TRNX_FLOW_CHECK';
          	    x_return_status := FND_API.G_RET_STS_ERROR;
          	    Return;
            END IF;

            -- Bug 3433867 Start
            -- CHECK 7.5: Need to validate the item in the logical inv org of
            -- the POU if valid transaction flow exists and item id is not null

            IF  (   ( l_transaction_flow_header_id IS NOT NULL )
                AND ( p_item_id IS NOT NULL ) )
            THEN
                check_item_in_linv_pou
             	(x_return_status              => l_transaction_flow_status,
              	 p_item_id                    => p_item_id,
              	 p_transaction_flow_header_id => l_transaction_flow_header_id,
              	 x_item_in_linv_pou           => l_item_in_linv_pou);

                IF (l_transaction_flow_status <> FND_API.g_ret_sts_success) OR
                   (l_item_in_linv_pou <> 'Y')
                THEN
                    x_error_msg_name := 'PO_ITEM_IN_LINV_POU_CHECK';
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    return;
                END IF;

            END IF;
            -- Bug 3433867 End

        END IF; -- ( p_document_type = 'STANDARD' )

        l_progress := '013';

        --CHECK 8:For Services Line type, if 'HR: Cross Business Groups' is NO
        --then ROU and POU should rollup to the same Business Group
        --Identify if the line type is SERVICE type

        IF ( p_document_type = 'STANDARD' ) THEN                    -- <HTMLAC>

            IF nvl(hr_general.get_xbg_profile, 'N') = 'N' THEN

                SELECT prl.purchase_basis,
                       hrou_po.business_group_id,
                       hrou_req.business_group_id
                INTO   l_purchase_basis,
                       l_pou_bus_group_id,
                       l_rou_bus_group_id
                FROM   po_requisition_lines_all prl,
                       hr_all_organization_units hrou_po,
                       hr_all_organization_units hrou_req
                WHERE  prl.requisition_line_id = p_requisition_line_id
                AND    hrou_po.organization_id = p_purchasing_org_id
                AND    hrou_req.organization_id = p_requesting_org_id;

                IF (l_purchase_basis = 'TEMP LABOR') AND
                   (l_pou_bus_group_id <> l_rou_bus_group_id)
                THEN
                    x_error_msg_name := 'PO_CROSS_OU_SERVICES_CHECK';
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    Return;
                END IF;
            END IF; --cross business group profile check

        END IF;

       l_progress := '014';
       --CHECK 9:If the deliver-to-location on req Line is customer location then
       --OM family pack J should be installed to handle cross OU purchasing in
       --international drop ship scenerio.
       BEGIN
         SELECT 'Y'
         INTO   l_is_customer_location
         FROM   HZ_LOCATIONS
         WHERE  nvl(address_expiration_date, trunc(sysdate + 1)) > trunc(sysdate)
         AND    location_id = l_deliver_to_location_id;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
             l_is_customer_location := 'N';
         WHEN OTHERS THEN
             RAISE;
       END;

       IF (l_is_customer_location = 'Y' AND
           (NOT OE_CODE_CONTROL.code_release_level >= '110510')) THEN
          x_error_msg_name := 'PO_CROSS_OU_CUST_LOC_CHECK';
          x_return_status := FND_API.G_RET_STS_ERROR;
          Return;
       END IF;

        --<Bug 3313252 mbhargav START>
        l_progress := '015';

        --CHECK 10: If Encumbrance is enabled for Purchasing/Requesting Org and
        --purchasing org is different than requesting org then we error out

        IF ( p_document_type = 'STANDARD' ) THEN                    -- <HTMLAC>

            IF p_requesting_org_id <> p_purchasing_org_id AND
              (PO_CORE_S.is_encumbrance_on(p_doc_type => 'ANY',p_org_id   => p_requesting_org_id)
               OR
               PO_CORE_S.is_encumbrance_on(p_doc_type => 'ANY',p_org_id   => p_purchasing_org_id)
              )
            THEN
                x_error_msg_name := 'PO_GA_ENCUMBRANCE_CHECK';
                x_return_status := FND_API.G_RET_STS_ERROR;
                Return;
            END IF;

        END IF;
        --<Bug 3313252 mbhargav END>

    ELSE -- p_requesting_org_id = p_purchasing_org_id

       l_progress := '016';
       l_pa_project := is_pa_project_referenced(p_requisition_line_id);

       IF l_pa_project THEN

          l_progress := '017';
          --SQL WHAT: Get the necessary information from the given requisition line
          --SQL WHY: This information is needed for validation checks later
          SELECT prl.category_id,
                 nvl(prl.destination_organization_id,
                     fsp.inventory_organization_id),
                 prl.deliver_to_location_id
          INTO   l_category_id, l_dest_inv_org_id, l_deliver_to_location_id
          FROM   po_requisition_lines_all prl, financials_system_params_all fsp
          WHERE  prl.requisition_line_id = p_requisition_line_id
          AND    prl.org_id = fsp.org_id;

          l_progress := '018';

          --Get the operating unit of destination inv org
          IF (l_dest_inv_org_id IS NOT NULL) THEN
             PO_CORE_S.get_inv_org_ou_id(x_return_status => x_return_status,
                                         p_inv_org_id    => l_dest_inv_org_id,
                                         x_ou_id         => l_dest_inv_org_ou_id);

             IF (x_return_status <> FND_API.g_ret_sts_success) THEN
                 RAISE FND_API.g_exc_unexpected_error;
             END IF;
          END IF;

          l_progress := '019';
          check_transaction_flow(
            p_init_msg_list              => FND_API.G_FALSE,
            x_return_status              => l_transaction_flow_status,
            p_start_ou_id                => p_purchasing_org_id,
            p_end_ou_id                  => l_dest_inv_org_ou_id,
            p_ship_to_org_id             => l_dest_inv_org_id,
            p_item_category_id           => l_category_id,
            p_transaction_date           => SYSDATE,
            x_transaction_flow_header_id => l_transaction_flow_header_id
          );

          l_progress := '020';
          IF (l_transaction_flow_status <> FND_API.g_ret_sts_success) THEN
             RAISE FND_API.g_exc_unexpected_error;
          END IF;

          l_progress := '021';
          --If transaction flow exists and project is attached, return error
          IF l_transaction_flow_header_id is NOT NULL THEN
             x_error_msg_name := 'PO_CROSS_OU_PA_PROJECT_CHECK';
             x_return_status := FND_API.G_RET_STS_ERROR;
             return;
          END IF;

       END IF; -- l_pa_project is TRUE

    END IF; -- p_requesting_org_id != p_purchasing_org_id
    -- Bug 3379488 End

    --All checks passed. Return success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_message.parse_encoded(FND_MSG_PUB.get,x_app_name,x_error_msg_name);
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_message.parse_encoded(FND_MSG_PUB.get,x_app_name,x_error_msg_name);
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name,
              SUBSTRB(SQLERRM , 1 , 200) || ' at location ' || l_progress);
         fnd_message.parse_encoded(FND_MSG_PUB.get,x_app_name,x_error_msg_name);
END validate_cross_ou_purchasing;


-----------------------------------------------------------------------<HTMLAC>
-------------------------------------------------------------------------------
--Start of Comments
--Name: validate_cross_ou_tbl
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Wrapper procedure allowing nested table inputs and outputs for
--  bulk processing on procedure validate_cross_ou_purchasing.
--Parameters:
--IN
--p_req_line_id_tbl
--  Nested table of Req Line IDs which need to be validated
--p_requesting_org_id_tbl
--  Nested table containing Req Lines' OUs
--p_purchasing_org_id
--  OU where PO will be created
--p_document_type_tbl
--  Document Type of the outcome document.
--p_item_id_tbl
--  Nested table containing Item Id of Req Line
--p_source_doc_id_tbl
--  Nested table containing header ID of GA (if one is referenced);
--  otherwise contains NULL
--p_vmi_flag_tbl
--  Nested table of 'Y' or 'N' indicating whether line is vmi enabled
--p_consigned_flag_tbl
--  Nested table of 'Y' or 'N' corresponding to consigned_from_supp_flag
--  This attribute is obtained from ASL attributes.
--OUT
--x_valid_flag_tbl
--  Nested table of 'Y' or 'N' indicating whether all validations passed
--x_error_msg_tbl
--  Nested table of error messages for each line when that line failed
--  validation (this is not G_RET_STS_SUCCESS)
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE validate_cross_ou_tbl
(
    p_req_line_id_tbl        IN         PO_TBL_NUMBER
,   p_requesting_org_id_tbl  IN         PO_TBL_NUMBER
,   p_purchasing_org_id      IN         NUMBER
,   p_document_type          IN         VARCHAR2
,   p_item_id_tbl            IN         PO_TBL_NUMBER
,   p_source_doc_id_tbl      IN         PO_TBL_NUMBER
,   p_vmi_flag_tbl           IN         PO_TBL_VARCHAR1
,   p_consigned_flag_tbl     IN         PO_TBL_VARCHAR1
,   x_valid_flag_tbl         OUT NOCOPY PO_TBL_VARCHAR1
,   x_error_msg_tbl          OUT NOCOPY PO_TBL_VARCHAR30
)
IS
    l_return_status          VARCHAR2(1);
    l_error_msg_name         VARCHAR2(30);
    l_valid_flag_tbl         PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
    l_error_msg_tbl          PO_TBL_VARCHAR30 := PO_TBL_VARCHAR30();

BEGIN
    l_valid_flag_tbl.extend(p_req_line_id_tbl.COUNT);
    l_error_msg_tbl.extend(p_req_line_id_tbl.COUNT);

    -- Loop through all Req Line IDs and run validation on each line.

    FOR i IN p_req_line_id_tbl.FIRST..p_req_line_id_tbl.LAST
    LOOP

        validate_cross_ou_purchasing
        (   p_api_version          => 1.0
        ,   p_requisition_line_id  => p_req_line_id_tbl(i)
        ,   p_requesting_org_id    => p_requesting_org_id_tbl(i)
        ,   p_purchasing_org_id    => p_purchasing_org_id
        ,   p_item_id              => p_item_id_tbl(i)
        ,   p_source_doc_id        => p_source_doc_id_tbl(i)
        ,   p_vmi_flag             => p_vmi_flag_tbl(i)
        ,   p_cons_from_supp_flag  => p_consigned_flag_tbl(i)
        ,   x_return_status        => l_return_status
        ,   x_error_msg_name       => l_error_msg_name
        ,   p_document_type        => p_document_type
        );

        -- Set OUT parameters.
		--
        IF ( l_return_status = FND_API.G_RET_STS_SUCCESS )
        THEN
            l_valid_flag_tbl(i) := 'Y';
            l_error_msg_tbl(i) := NULL;
        ELSE
            l_valid_flag_tbl(i) := 'N';
            l_error_msg_tbl(i) := l_error_msg_name;
        END IF;

    END LOOP;

    x_valid_flag_tbl := l_valid_flag_tbl;
    x_error_msg_tbl := l_error_msg_tbl;

END validate_cross_ou_tbl;

--------------------------------------------------------------------------------
--Start of Comments
--Name: check_item_in_inventory_org
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Checks if p_item_id and p_item_revision are available in p_inv_org_id.
--  Appends to API message list upon error.
--Parameters:
--IN:
--p_init_msg_list
--p_item_id
--  The item ID.
--p_item_revision
--  The item revision of the item ID.
--p_inv_org_id
--  The inventory org ID to be validated against.
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_in_inv_org
--  TRUE if:
--      - item is a one-time item
--      OR
--      - item exists in p_inv_org_id
--      - item revision is available in the inventory org
--      OR
--      - item exists in p_inv_org_id
--      - item revision is NULL
--  FALSE otherwise.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE check_item_in_inventory_org
(
    p_init_msg_list IN  VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    p_item_id       IN  NUMBER,
    p_item_revision IN  VARCHAR2,
    p_inv_org_id    IN  NUMBER,
    x_in_inv_org    OUT NOCOPY BOOLEAN
)
IS

l_valid_flag VARCHAR2(1);
l_progress VARCHAR2(3);

BEGIN
    l_progress := '000';

    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    l_progress := '010';

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
            (p_log_head => g_module_prefix||'check_item_in_inventory_org',
             p_token    => 'invoked',
             p_message  => 'item ID: '||p_item_id||' item rev: '||
                           p_item_revision||' invorg ID: '||p_inv_org_id);
    END IF;

    IF (p_item_id IS NOT NULL) THEN         -- If not a one-time item

        BEGIN

            IF (p_item_revision IS NULL) THEN
                l_progress := '020';
                SELECT 'Y'
                  INTO l_valid_flag
                  FROM mtl_system_items_b msi,
                       mtl_parameters mp
                 WHERE msi.inventory_item_id = p_item_id
                   AND msi.organization_id = p_inv_org_id
                   AND mp.organization_id = msi.organization_id;
            ELSE
                l_progress := '030';

                --SQL What: Check that item and revision exist in dest org
                --SQL Why: To validate the item and revision
                SELECT 'Y'
                  INTO l_valid_flag
                  FROM mtl_system_items_b msi,
                       mtl_item_revisions_b mir,
                       mtl_parameters mp
                 WHERE msi.inventory_item_id = p_item_id
                   AND msi.organization_id = p_inv_org_id
                   AND mir.organization_id = msi.organization_id
                   AND mir.inventory_item_id = msi.inventory_item_id
                   AND mir.revision = p_item_revision
                   AND mp.organization_id = msi.organization_id;
            END IF;

            -- Successful query means that item exists in inventory org
            x_in_inv_org := TRUE;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_progress := '040';
                x_in_inv_org := FALSE;
        END;

    ELSE
        -- one-time items always pass this check
        l_progress := '050';
        x_in_inv_org := TRUE;

    END IF;  --< if item_id not null >

    IF g_debug_stmt THEN
        PO_DEBUG.debug_var
            (p_log_head => g_module_prefix||'check_item_in_inventory_org',
             p_progress => l_progress,
             p_name     => 'x_in_inv_org',
             p_value    => x_in_inv_org);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        x_in_inv_org := FALSE;
        FND_MSG_PUB.add_exc_msg
            (p_pkg_name       => g_pkg_name,
             p_procedure_name => 'check_item_in_inventory_org',
             p_error_text     => 'Progress: '||l_progress||' Error: '||
                                 SUBSTRB(SQLERRM,1,215));
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_module_prefix||'check_item_in_inventory_org',
                p_progress => l_progress);
        END IF;
END check_item_in_inventory_org;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_ship_to_org
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Validates the ship-to org with the current OU.  The ship-to org is valid
--  if:
--    - It is within the current set of books
--    OR
--    - It is outside the current set of books
--    - A valid inter-company relationship (i.e. transaction flow) exists
--      between the current OU
--    - The current OU does not use encumbrance
--    - The ship-to org is not an OPM org
--
--  Appends to the API message list upon error.
--Parameters:
--IN:
--p_init_msg_list
--  Standard API parameter to initialize message list.
--p_ship_to_org_id
--  The ship-to org ID
--p_item_category_id
--  The category ID of the line item for this shipment
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_error - if an error occurred
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_is_valid
--  TRUE if validation succeeds.  FALSE otherwise.
--x_in_current_sob
--  TRUE if the ship-to org is in the current OU's set of books.
--  FALSE otherwise.
--x_check_txn_flow
--  TRUE if it is allowable to check for transaction flows.
--  FALSE otherwise.
--x_transaction_flow_header_id
--  The unique header ID of the transaction flow, if any valid inter-company
--  relationship exists.  If no flow is found, then this is set to NULL.
--  (MTL_TRANSACTION_FLOW_HEADERS.header_id%TYPE)
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_ship_to_org
(
    p_init_msg_list              IN  VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    p_ship_to_org_id             IN  NUMBER,
    p_item_category_id           IN  NUMBER,
    p_item_id                    IN  NUMBER, -- Bug 3433867
    x_is_valid                   OUT NOCOPY BOOLEAN,
    x_in_current_sob             OUT NOCOPY BOOLEAN,
    x_check_txn_flow             OUT NOCOPY BOOLEAN,
    x_transaction_flow_header_id OUT NOCOPY NUMBER
)
IS

l_current_ou_id  FINANCIALS_SYSTEM_PARAMS_ALL.org_id%TYPE;
l_current_sob_id FINANCIALS_SYSTEM_PARAMS_ALL.set_of_books_id%TYPE;
l_current_p_enc_flag FINANCIALS_SYSTEM_PARAMS_ALL.purch_encumbrance_flag%TYPE;
l_current_r_enc_flag FINANCIALS_SYSTEM_PARAMS_ALL.req_encumbrance_flag%TYPE;

l_end_ou_id            NUMBER; -- query converts to number
l_ship_to_org_sob_id   NUMBER; -- query converts to number
l_ship_to_org_opm_flag MTL_PARAMETERS.process_enabled_flag%TYPE;

l_return_status VARCHAR2(1);
l_progress VARCHAR2(3);

l_item_in_linv_pou VARCHAR2(1):= 'Y'; -- Bug 3433867

BEGIN
    l_progress := '000';

    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    l_progress := '010';

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
           (p_log_head => g_module_prefix||'validate_ship_to_org',
            p_token    => 'invoked',
            p_message  => 'shipto org ID: '||p_ship_to_org_id||
                          ' item cat ID: '||p_item_category_id);
    END IF;

    l_progress := '020';

    SELECT org_id,
           set_of_books_id,
           NVL(purch_encumbrance_flag, 'N'),
           NVL(req_encumbrance_flag, 'N')
      INTO l_current_ou_id,
           l_current_sob_id,
           l_current_p_enc_flag,
           l_current_r_enc_flag
      FROM financials_system_parameters;

    l_progress := '030';

    --SQL What: Get ship-to Org related info
    --SQL Why: Need to call txn flow API and perform extra txn flow validation
    SELECT TO_NUMBER(hoi.org_information3),
           TO_NUMBER(hoi.org_information1)
           -- MC INVCONV START
           --mp.process_enabled_flag
           -- MC INVCONV END
      INTO l_end_ou_id,
           l_ship_to_org_sob_id
           --l_ship_to_org_opm_flag
      FROM hr_organization_information hoi
           --mtl_parameters mp
     WHERE
     -- MC INVCONV START
         hoi.organization_id = p_ship_to_org_id
       --mp.organization_id = p_ship_to_org_id
       --AND mp.organization_id = hoi.organization_id
     -- MC INVCONV END
       AND hoi.org_information_context = 'Accounting Information';

    l_progress := '040';

    x_in_current_sob := (l_current_sob_id = l_ship_to_org_sob_id);

    IF (x_in_current_sob) THEN
        -- ship-to org is in the current OU's SOB. Need to check for a valid
        -- transaction flow for accounting purposes only if they are supported
        x_check_txn_flow := g_is_txn_flow_supported;
        x_is_valid := (NOT x_check_txn_flow);

    ELSIF (g_is_txn_flow_supported) AND
          (l_current_p_enc_flag = 'N') AND
          (l_current_r_enc_flag = 'N')
          -- MC INVCONV START
          -- AND (l_ship_to_org_opm_flag <> 'Y')
          -- MC INVCONV END
    THEN
        -- Ship-to org is outside SOB, but transaction flows are supported,
        -- encumbrance is off in current OU, and ship-to org not OPM org.
        --
        -- In this scenario, ship-to org cannot be valid without a txn flow, so
        -- need to check for one
        x_check_txn_flow := TRUE;
        x_is_valid := FALSE;

    ELSE
        -- Cannot be a valid ship-to org because it is outside the current SOB
        -- and it is not allowable use transaction flows in this scenario
        x_check_txn_flow := FALSE;
        x_is_valid := FALSE;
    END IF;

    l_progress := '050';

    IF (x_check_txn_flow) THEN

        l_progress := '060';

        -- Try to get a valid transaction flow
        check_transaction_flow
           (p_init_msg_list              => FND_API.g_false,
            x_return_status              => l_return_status,
            p_start_ou_id                => l_current_ou_id,
            p_end_ou_id                  => l_end_ou_id,
            p_ship_to_org_id             => p_ship_to_org_id,
            p_item_category_id           => p_item_category_id,
            p_transaction_date           => SYSDATE,
            x_transaction_flow_header_id => x_transaction_flow_header_id);

        IF (l_return_status = FND_API.g_ret_sts_error) THEN
            l_progress := '070';
            RAISE FND_API.g_exc_error;
        ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
            l_progress := '080';
            RAISE FND_API.g_exc_unexpected_error;
        END IF;

        l_progress := '090';

        -- Bug 3433867 Start
        -- Need to validate the item in the logical inv org of the POU if a
        -- valid transaction flow exists and item id is not null
        IF x_transaction_flow_header_id IS NOT NULL AND p_item_id IS NOT NULL THEN
           check_item_in_linv_pou
             (x_return_status              => l_return_status,
              p_item_id                    => p_item_id,
              p_transaction_flow_header_id => x_transaction_flow_header_id,
              x_item_in_linv_pou           => l_item_in_linv_pou);
           IF l_return_status = FND_API.g_ret_sts_error THEN
              l_progress := '091';
              RAISE FND_API.g_exc_error;
           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              l_progress := '092';
              RAISE FND_API.g_exc_unexpected_error;
           ELSIF l_return_status = FND_API.g_ret_sts_success
                 AND (l_item_in_linv_pou <> 'Y') THEN
              x_is_valid := FALSE;
              x_transaction_flow_header_id := NULL;
           ELSE
              x_is_valid := TRUE;
           END IF;
        END IF;
        -- Bug 3433867 End

        IF ((x_transaction_flow_header_id IS NULL) AND (NOT x_in_current_sob))
        THEN
            -- Transaction does not exist, and ship-to org is outside SOB
            x_is_valid := FALSE;

        ELSE
            x_is_valid := TRUE;
        END IF;

    END IF;  --< if check txn flow >

    IF g_debug_stmt THEN
        PO_DEBUG.debug_var
            (p_log_head => g_module_prefix||'validate_ship_to_org',
             p_progress => l_progress,
             p_name     => 'x_in_current_sob',
             p_value    => x_in_current_sob);
        PO_DEBUG.debug_var
            (p_log_head => g_module_prefix||'validate_ship_to_org',
             p_progress => l_progress,
             p_name     => 'x_check_txn_flow',
             p_value    => x_check_txn_flow);
        PO_DEBUG.debug_var
            (p_log_head => g_module_prefix||'validate_ship_to_org',
             p_progress => l_progress,
             p_name     => 'x_is_valid',
             p_value    => x_is_valid);
    END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        -- There should be an error message appended to the API message list
        x_return_status := FND_API.g_ret_sts_error;
        x_is_valid := FALSE;
        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt
                (p_log_head => g_module_prefix||'validate_ship_to_org',
                 p_token    => l_progress,
                 p_message  => 'Expected error occurred.');
        END IF;
    WHEN FND_API.g_exc_unexpected_error THEN
        -- There should be an error message appended to the API message list
        x_return_status := FND_API.g_ret_sts_unexp_error;
        x_is_valid := FALSE;
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_module_prefix||'validate_ship_to_org',
                p_progress => l_progress);
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        x_is_valid := FALSE;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'validate_ship_to_org',
                                p_error_text     => 'Progress: '||l_progress||
                                           ' Error: '||SUBSTRB(SQLERRM,1,215));
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_module_prefix||'validate_ship_to_org',
                p_progress => l_progress);
        END IF;
END validate_ship_to_org;

--------------------------------------------------------------------------------
--Start of Comments
--Name: is_txn_flow_supported
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines if the current installation supports transaction flows.
--Returns:
--  TRUE if transaction flows are supported in the current installation.
--  FALSE otherwise.
--End of Comments
--------------------------------------------------------------------------------
FUNCTION is_txn_flow_supported RETURN BOOLEAN
IS
BEGIN
    RETURN g_is_txn_flow_supported;
END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_inv_qualifier_code
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the global variable INV_TRANSACTION_FLOW_PUB.g_qualifier_code
--Returns:
--  INV_TRANSACTION_FLOW_PUB.g_qualifier_code.
--End of Comments
--------------------------------------------------------------------------------
FUNCTION get_inv_qualifier_code RETURN NUMBER
IS
BEGIN
    RETURN INV_TRANSACTION_FLOW_PUB.g_qualifier_code;
END get_inv_qualifier_code;

--------------------------------------------------------------------------------
--Start of Comments
--Name: do_item_validity_checks
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the global variable INV_TRANSACTION_FLOW_PUB.g_qualifier_code
--Parameters:
--IN
--p_item_id Item to check
--p_org_id  The org where Item is to be verified
--p_valid_org_id The org where Item is VALID
--p_do_osp_check The parameter which tells whether OSP error needs to be reported
--OUT
--x_return_status Returns error if any of the three checks fail
--x_item_valid_msg_data The error message corresponding to the error. Returns
--  NULL if x_return_status is SUCCESS
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE do_item_validity_checks(
                      p_item_id             IN NUMBER,
                      p_org_id              IN NUMBER,
                      p_valid_org_id        IN NUMBER,
                      p_do_osp_check        IN BOOLEAN,
                      x_return_status       OUT NOCOPY VARCHAR2,
                      x_item_valid_msg_name OUT NOCOPY VARCHAR2)
IS
l_is_purchasable BOOLEAN;
l_is_same_uom_class BOOLEAN;
l_is_not_osp_item BOOLEAN;

BEGIN
        PO_GA_PVT.validate_item(
                       x_return_status   => x_return_status,
                       p_item_id         => p_item_id,
                       p_org_id          => p_org_id,
                       p_valid_org_id    => p_valid_org_id,
                       x_is_purchasable  => l_is_purchasable,
                       x_is_same_uom_class => l_is_same_uom_class,
                       x_is_not_osp_item => l_is_not_osp_item);

        IF (x_return_status <> FND_API.g_ret_sts_success) THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF;

        IF NOT l_is_purchasable
        THEN
            x_item_valid_msg_name := 'PO_CROSS_OU_ITEM_PURCH_CHECK';
            RAISE FND_API.g_exc_error;

        ELSIF NOT l_is_same_uom_class
        THEN
            x_item_valid_msg_name := 'PO_CROSS_OU_UOM_CHECK';
            RAISE FND_API.g_exc_error;

        ELSIF (p_do_osp_check AND NOT l_is_not_osp_item)
        THEN
            x_item_valid_msg_name := 'PO_CROSS_OU_OSP_CHECK';
            RAISE FND_API.g_exc_error;
        END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'do_item_validity_checks',
                                p_error_text     => NULL);
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_module_prefix||'do_item_validity_checks',
                p_progress => '500');
        END IF;
END do_item_validity_checks;

---------------------------------------------------------------------------
--Start of Comments
--Name: get_logical_inv_org_id
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Get the org id for the Logical Inventory Org associated with
--  the given Transaction Flow. This LINV would belong to the POU.
--Parameters:
--IN:
--  p_transaction_flow_header_id
--   : The Transaction Flow Header ID associated with the Transaction flow
--     between the POU and the DOU
--OUT:
--  None.
--RETURN
--  NUMBER: The Org ID of the Logical Inventory Org.
--Testing:
--End of Comments
---------------------------------------------------------------------------
FUNCTION get_logical_inv_org_id(p_transaction_flow_header_id IN NUMBER)
RETURN NUMBER
IS
  l_logical_inv_org_id NUMBER := NULL;
BEGIN
  --SQL WHAT: Get the org id for the Logical Inventory Org associated with
  --          the given Transaction Flow. This LINV would belong to the POU.
  --SQL WHY:  The LINV's org id is used in several queries where the SPS
  --          Charge Account is being derived.
  --NOTE:     This function is called only when the TRANSACTION_FLOW_HEADER_ID
  --          is NOT NULL.
  SELECT from_organization_id
  INTO l_logical_inv_org_id
  FROM MTL_TRANSACTION_FLOW_LINES
  WHERE header_id = p_transaction_flow_header_id AND
        line_number = 1;

  RETURN l_logical_inv_org_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL; -- May be raised as an exception in the calling procedure.
  WHEN OTHERS THEN
    RAISE;
END get_logical_inv_org_id;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_po_setup_parameters
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the out parameters from po setup
--Parameters:
--IN
--p_org_id  The operating unit
--OUT
--x_po_num_code Containg the value from column user_defined_po_num_code(MANUAL/AUTOMATIC)
--x_po_num_type Containg the value from column manual_po_num_type(NUMERIC/ALPHANUMERIC)
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_po_setup_parameters(
    p_org_id         IN NUMBER,
    x_po_num_code    OUT NOCOPY VARCHAR2,
    x_po_num_type    OUT NOCOPY VARCHAR2)
IS
BEGIN
      select user_defined_po_num_code, manual_po_num_type
      into  x_po_num_code, x_po_num_type
      from  po_system_parameters_all
      where org_id = p_org_id;
EXCEPTION
    when others then
        IF ( g_debug_stmt )
        THEN
            PO_DEBUG.debug_exc ( p_log_head => g_module_prefix || 'get_po_setup_parameters'
                               , p_progress => '000' );
        END IF;
        RAISE;
END;

-- Bug 3433867: added the following procedure to perform extra item validation
-- for Shared Procurement
--------------------------------------------------------------------------------
--Start of Comments
--Name: check_item_in_linv_pou
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Checks if an item exists in the logical inventory org of the POU of a given
--  transaction flow
--Parameters:
--IN
--p_transaction_flow_header_id
--  Transaction flow header ID, unqiue identifier of transaction flows
--p_item_id
--  Item ID, unqiue identifier of items
--OUT
--x_return_status:
--  FND_API.g_ret_sts_success: if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error: if unexpected error occured
--x_item_in_linv_pou
--  If 'Y', the item exists in the logical inventory org of the POU; otherwise,
--  it does not
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE check_item_in_linv_pou
(
    x_return_status              OUT NOCOPY VARCHAR2,
    p_item_id                    IN  NUMBER,
    p_transaction_flow_header_id IN  NUMBER,
    x_item_in_linv_pou           OUT NOCOPY VARCHAR2
)
IS
    l_progress           VARCHAR2(3) := '000';
    l_log_head           CONSTANT VARCHAR2(100):= g_module_prefix
                                                  ||'check_item_in_linv_pou';
    l_logical_inv_org_id MTL_TRANSACTION_FLOW_LINES.from_organization_id%TYPE;
    l_item_in_inv_org    BOOLEAN;

BEGIN
    l_progress := '010';

    IF g_debug_stmt THEN
       PO_DEBUG.debug_stmt(p_log_head => l_log_head,
                           p_token    => l_progress,
                           p_message  => 'Transaction flow header id: '
                                         || p_transaction_flow_header_id
                                         || 'Item id: ' || p_item_id);
    END IF;

    x_return_status := FND_API.g_ret_sts_success;
    x_item_in_linv_pou := 'N';

    IF p_transaction_flow_header_id IS NULL THEN
       return;
    ELSIF p_item_id IS NULL THEN
       x_item_in_linv_pou := 'Y';
       return;
    END IF;

    l_progress := '020';
    l_logical_inv_org_id := get_logical_inv_org_id
      (p_transaction_flow_header_id => p_transaction_flow_header_id);

    IF g_debug_stmt THEN
       PO_DEBUG.debug_stmt(p_log_head => l_log_head,
                           p_token    => l_progress,
                           p_message  => 'POUs logical inventory org id: '
                                         || l_logical_inv_org_id);
    END IF;

    l_progress := '030';
    IF l_logical_inv_org_id IS NOT NULL THEN
       check_item_in_inventory_org(
         p_init_msg_list => 'T',
         x_return_status => x_return_status,
         p_item_id       => p_item_id,
         p_item_revision => NULL,
         p_inv_org_id    => l_logical_inv_org_id,
         x_in_inv_org    => l_item_in_inv_org
       );
       IF x_return_status <> FND_API.g_ret_sts_success THEN
          l_progress := '040';
          RAISE FND_API.g_exc_unexpected_error;
       END IF;
    ELSE
       l_progress := '050';
       x_return_status := FND_API.g_ret_sts_unexp_error;
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_progress := '060';

    IF l_item_in_inv_org THEN
       x_item_in_linv_pou := 'Y';
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    x_item_in_linv_pou := 'N';
    IF g_debug_unexp THEN
       PO_DEBUG.debug_exc(p_log_head => l_log_head,
                          p_progress => l_progress);
    END IF;
END check_item_in_linv_pou;

-- <<PDOI Enhancement Bug#17063664 Start>>

-------------------------------------------------------------------------------
--Start of Comments
--Name: validate_cross_ou_purchasing
--Function:
--  Overloaded procedure which allows nested table inputs and outputs for
--  bulk processing of cross ou validation.
--  This bulk procedure calls validateset which perform the below checks
--  to validate cross operating unit boundaries for creation of Purchase Order.
--  Following checks will be handled by the different validate sets.
--  (checks 1, 2, 4, 5, 6, 7, 8, 9, and 10 are performed only for Standard POs;
--   for Global Agreements, these checks will be performed upon creation
--   of the Standard PO release).
--     1. Line is not VMI enabled
--        valdateset is c_cross_ou_vmi_check
--     2. Consigned relationship should not exist
--        valdateset is c_cross_ou_consigned_check
--     3. Item is valid in the involved Operating Units
--        valdateset is c_cross_ou_item_validity_check
--     4. PA Project reference for destination type of expense should not exist
--        valdateset is c_cross_ou_pa_project_check
--     6. Following scenario should not exist: Destination OU is same as
--          Purchasing OU but is different from Req OU
--        valdateset is c_cross_ou_dest_ou_check
--     7. Transaction flow between Purchasing OU and Destination OU should exist
--        valdateset is c_cross_ou_trnx_flow_check
--     8. For Services Line type, if 'HR: Cross Business Groups' is NO then ROU
--          and POU should rollup to the same Business Group
--        valdateset is c_cross_ou_services_check
--     9. If the deliver-to-location on req Line is customer location then
--          OM family pack should be installed
--        valdateset is c_cross_ou_cust_loc_check
--     10.If Encumbrance is enabled for Purchasing/Requesting Org, then
--          Purchasing Org should not be different than Requesting Org
--        valdateset is c_cross_ou_ga_encumbrance_check
--Parameters:
--IN:
--  p_line_id_tbl
--    Nested table of Interface Line IDs
--  p_requisition_line_id_tbl
--    Nested table of Req Line IDs which need to be validated
--  p_item_id_tbl
--    Nested table containing Item Id of Req Line
--  p_vendor_id_tbl
--    Nested table containing Item Id of Req Line
--  p_vendor_site_id_tbl
--    Nested table containing Item Id of Req Line--p_requesting_org_id_tbl
--  p_source_doc_id_tbl
--    Nested table containing header ID of GA (if one is referenced);
--      otherwise contains NULL
--  p_purchasing_org_id_tbl
--    Nested table of OU's where the PO will be created
--  p_document_type_tbl
--    Document Type of the outcome document.
--IN OUT:
--  x_result_set_id
--    Identifier for the output results in PO_VALIDATION_RESULTS.
--  x_results
--    The results of the validations.
--OUT:
--  x_result_type
--    Provides a summary of the validation results.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_cross_ou_purchasing
(
    p_line_id_tbl                  IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl      IN PO_TBL_NUMBER ,
    p_item_id_tbl                  IN PO_TBL_NUMBER ,
    p_vmi_flag_tbl                 IN PO_TBL_VARCHAR1 ,
    p_cons_from_supp_flag_tbl      IN PO_TBL_VARCHAR1 ,
    p_txn_flow_header_id_tbl       IN PO_TBL_NUMBER ,
    p_source_doc_id_tbl            IN PO_TBL_NUMBER ,
    p_purchasing_org_id_tbl        IN PO_TBL_NUMBER ,
    p_requesting_org_id_tbl        IN PO_TBL_NUMBER ,
    p_dest_inv_org_ou_id_tbl       IN PO_TBL_NUMBER ,
    p_deliver_to_location_id_tbl   IN PO_TBL_NUMBER ,
    p_destination_org_id_tbl       IN PO_TBL_NUMBER ,
    p_destination_type_code_tbl    IN PO_TBL_VARCHAR30 ,
    p_document_type_tbl            IN PO_TBL_VARCHAR30 ,
    x_result_set_id                IN OUT NOCOPY NUMBER,
    x_results                      IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE ,
    x_result_type                  OUT NOCOPY VARCHAR2
)
IS

  d_api_name CONSTANT VARCHAR2(100)   := 'validate_cross_ou_purchasing';
  d_module   CONSTANT VARCHAR2(255)   := d_pkg_name || d_api_name || '.';
  d_position NUMBER                   := 0;

  l_lines PO_REQ_REF_VAL_TYPE         := PO_REQ_REF_VAL_TYPE();
  l_lines_same_ou PO_REQ_REF_VAL_TYPE := PO_REQ_REF_VAL_TYPE();
  l_data_key NUMBER;
  l_txn_flow_status    VARCHAR2(1);
  l_txn_flow_header_id MTL_TRANSACTION_FLOW_HEADERS.header_id%TYPE;
  l_line_id_tbl PO_TBL_NUMBER;
  l_cross_ou_count NUMBER;
  is_txn_flow_supported  VARCHAR2(1);
  l_result_type1 VARCHAR2(30);
  l_result_type2 VARCHAR2(30);
  l_result_type3 VARCHAR2(30);

BEGIN

  d_position := 0;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  IF (x_results IS NULL) THEN
    x_results := po_validation_results_type.new_instance();
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_module, 'line_id', p_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'requisition_line_id', p_requisition_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'item_id', p_item_id_tbl);
    PO_LOG.proc_begin(d_module, 'vmi_flag', p_vmi_flag_tbl);
    PO_LOG.proc_begin(d_module, 'cons_from_supp_flag', p_cons_from_supp_flag_tbl);
    PO_LOG.proc_begin(d_module, 'txn_flow_header_id', p_txn_flow_header_id_tbl);
    PO_LOG.proc_begin(d_module, 'source_doc_id', p_source_doc_id_tbl);
    PO_LOG.proc_begin(d_module, 'purchasing_org_id', p_purchasing_org_id_tbl);
    PO_LOG.proc_begin(d_module, 'requesting_org_id', p_requesting_org_id_tbl);
    PO_LOG.proc_begin(d_module, 'dest_inv_org_ou_id', p_dest_inv_org_ou_id_tbl);
    PO_LOG.proc_begin(d_module, 'deliver_to_location_id', p_deliver_to_location_id_tbl);
    PO_LOG.proc_begin(d_module, 'ship_to_org_id', p_destination_org_id_tbl);
    PO_LOG.proc_begin(d_module, 'destination_type_code', p_destination_type_code_tbl);
    PO_LOG.proc_begin(d_module, 'document_type', p_document_type_tbl);
    po_log.LOG(po_log.c_proc_begin, d_module, NULL, 'x_results', x_results);
    po_log.proc_begin(d_module, 'x_result_set_id', x_result_set_id);
  END IF;

  d_position := 10;
  l_data_key := PO_CORE_S.get_session_gt_nextval();

  -- Fetch the required attributes and insert into PO_SESSION_GT
  -- table where the req line id is populated.
  --SQL What: Query to get all the input params and requisition related
  --          attributes (where the req line id is populated) to store
  --          in po_sesstion_gt
  --SQL Why: Need to insert attributes in po_session_gt which are used to
  --         perform cross ou validations
  --SQL Join: org_id between prl & fsp
  --          organization_id between mp & hoi
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_SESSION_GT
    (KEY
    , num1   -- interface line id
    , num2   -- requisition_line_id
    , num3   -- item id
    , num4   -- source document id
    , num5   -- purchasing org id
    , num6   -- requesting_org_id
	  , num7   -- dest_inv_org_ou_id
    , num8   -- deliver_to_location_id
    , num9   -- destination_org_id
    , num10  -- txn_flow_header_id
    , char1  -- document type
    , char2  -- vmi_flag
    , char3  -- cons_from_supp_flag
    , char4  -- destination_type
    )
    SELECT l_data_key
      , p_line_id_tbl(i)
      , p_requisition_line_id_tbl(i)
      , p_item_id_tbl(i)
      , p_source_doc_id_tbl(i)
      , p_purchasing_org_id_tbl(i)
	    , p_requesting_org_id_tbl(i)
	    , p_dest_inv_org_ou_id_tbl(i)
	    , p_deliver_to_location_id_tbl(i)
	    , p_destination_org_id_tbl(i)
      , p_txn_flow_header_id_tbl(i)
      , p_document_type_tbl(i)
	    , p_vmi_flag_tbl(i)
      , p_cons_from_supp_flag_tbl(i)
      , p_destination_type_code_tbl(i)
    FROM DUAL
    WHERE p_requisition_line_id_tbl(i) IS NOT NULL;

  d_position := 20;

  --SQL What: Query to check whether there is any valid project exists for expense
  --          type distributions of the requistion and update in po_session_gt
  --SQL Why: Need this flag in the procedure cross_ou_pa_project_check
  UPDATE PO_SESSION_GT pst
  SET pst.char6 =      -- project_referenced_flag
    (SELECT 'Y'
     FROM DUAL
     WHERE pst.char4 = 'EXPENSE'  -- destination_type
       AND EXISTS
       (SELECT 'valid pa information'
        FROM po_req_distributions_all prd
        WHERE prd.requisition_line_id = pst.num2   -- requisition_line_id
          AND prd.project_id           IS NOT NULL))
  WHERE pst.key = l_data_key;

  d_position := 30;

  --SQL WHAT: Get the number of records for which purchasing org and
  --  requesting org are different
  --SQL WHY: Need to perform cross ou validations only when purchasing
  --  org and requesting org are different.
  SELECT count(*) INTO l_cross_ou_count
  FROM PO_SESSION_GT pst
  WHERE pst.key = l_data_key
  AND pst.num5 <> pst.num6;  -- purchasing_org_id<>requesting_org_id

  IF l_cross_ou_count > 0 THEN

  d_position := 40;

    --SQL What: Query to get global_agreement_flag and org_id of the source
    --          document
    --SQL Why: Need to insert these attributes in po_session_gt which are used to
    --         perform cross ou validations
    UPDATE PO_SESSION_GT pst
    SET (pst.char5, pst.index_num1) =      -- global_agreement_flag, owning_org_id
      (SELECT global_agreement_flag, org_id
      FROM po_headers_all
      WHERE pst.key = l_data_key
        AND pst.num4 IS NOT NULL      -- from_header_id
        AND po_header_id = pst.num4   -- from_header_id
        AND pst.num5 <> pst.num6);  -- purchasing_org_id<>requesting_org_id

  END IF; -- l_cross_ou_count > 0

  d_position := 50;

  --SQL What: Query to get the data (for which cross ou exists) from PO_SESSION_GT
  --          and insert into into the record l_lines, then delete the records.
  --SQL Why: Need to store the attributes in l_lines record which is used to pass
  --          as an argument to the procedure PO_VALIDATIONS.validate_cross_ou_purchasing
  DELETE FROM po_session_gt
  WHERE  key = l_data_key AND num5 <> num6
  RETURNING num1, num2, num3, num4, num5, num6, num7, num8,
    num9, num10, char1, char2, char3, char5, char6, index_num1
  BULK COLLECT INTO
    l_lines.interface_id,
    l_lines.requisition_line_id,
    l_lines.item_id,
    l_lines.source_doc_id,
    l_lines.org_id,
    l_lines.requesting_org_id,
    l_lines.dest_inv_org_ou_id,
    l_lines.deliver_to_location_id,
    l_lines.destination_org_id,
    l_lines.txn_flow_header_id,
    l_lines.hdr_type_lookup_code,
    l_lines.vmi_flag,
    l_lines.cons_from_supp_flag,
    l_lines.global_agreement_flag,
    l_lines.project_referenced_flag,
    l_lines.owning_org_id;

  d_position := 60;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module, d_position, 'interface_id', l_lines.interface_id);
    PO_LOG.stmt(d_module, d_position, 'requisition_line_id', l_lines.requisition_line_id);
    PO_LOG.stmt(d_module, d_position, 'item_id', l_lines.item_id);
    PO_LOG.stmt(d_module, d_position, 'source_doc_id', l_lines.source_doc_id);
    PO_LOG.stmt(d_module, d_position, 'purchasing_org_id', l_lines.org_id);
    PO_LOG.stmt(d_module, d_position, 'requesting_org_id', l_lines.requesting_org_id);
    PO_LOG.stmt(d_module, d_position, 'dest_inv_org_ou_id', l_lines.dest_inv_org_ou_id);
    PO_LOG.stmt(d_module, d_position, 'deliver_to_location_id', l_lines.deliver_to_location_id);
    PO_LOG.stmt(d_module, d_position, 'destination_org_id', l_lines.destination_org_id);
    PO_LOG.stmt(d_module, d_position, 'txn_flow_header_id', l_lines.txn_flow_header_id);
    PO_LOG.stmt(d_module, d_position, 'hdr_type_lookup_code', l_lines.hdr_type_lookup_code);
    PO_LOG.stmt(d_module, d_position, 'vmi_flag', l_lines.vmi_flag);
    PO_LOG.stmt(d_module, d_position, 'cons_from_supp_flag', l_lines.cons_from_supp_flag);
    PO_LOG.stmt(d_module, d_position, 'global_agreement_flag', l_lines.global_agreement_flag);
    PO_LOG.stmt(d_module, d_position, 'project_referenced_flag', l_lines.project_referenced_flag);
    PO_LOG.stmt(d_module, d_position, 'owning_org_id', l_lines.owning_org_id);
  END IF;

  d_position := 70;

  -- Call validate_set to perform cross OU validations
  PO_VALIDATIONS.validate_cross_ou_purchasing(
    p_req_reference => l_lines ,
    x_result_set_id => x_result_set_id ,
    x_result_type   => l_result_type1 ,
    x_results       => x_results
  );

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module, d_position, 'x_result_set_id', x_result_set_id);
    PO_LOG.stmt(d_module, d_position, 'l_result_type1', l_result_type1);
  END IF;

  d_position := 80;

  --SQL What: Query to get the data (for which ou's are same) from PO_SESSION_GT
  --          and insert into the record l_lines_same_ou, then delete the records.
  --SQL Why: Need to store the attributes in l_lines_same_ou record which is used
  --         to perform validations when ou's are same
  DELETE FROM po_session_gt
  WHERE  key = l_data_key AND num5 = num6
  RETURNING num1, num2, num5, num6, num7,
    num9, num10, char1, char6
  BULK COLLECT INTO
    l_lines_same_ou.interface_id,
    l_lines_same_ou.requisition_line_id,
    l_lines_same_ou.org_id,
    l_lines_same_ou.requesting_org_id,
    l_lines_same_ou.dest_inv_org_ou_id,
    l_lines_same_ou.destination_org_id,
    l_lines_same_ou.txn_flow_header_id,
    l_lines_same_ou.hdr_type_lookup_code,
    l_lines_same_ou.project_referenced_flag;

   d_position := 90;

   IF PO_LOG.d_stmt THEN
     PO_LOG.stmt(d_module, d_position, 'interface_id', l_lines_same_ou.interface_id);
     PO_LOG.stmt(d_module, d_position, 'requisition_line_id', l_lines_same_ou.requisition_line_id);
     PO_LOG.stmt(d_module, d_position, 'purchasing_org_id', l_lines_same_ou.org_id);
     PO_LOG.stmt(d_module, d_position, 'requesting_org_id', l_lines_same_ou.requesting_org_id);
     PO_LOG.stmt(d_module, d_position, 'dest_inv_org_ou_id', l_lines_same_ou.dest_inv_org_ou_id);
     PO_LOG.stmt(d_module, d_position, 'destination_org_id', l_lines_same_ou.destination_org_id);
     PO_LOG.stmt(d_module, d_position, 'txn_flow_header_id', l_lines_same_ou.txn_flow_header_id);
     PO_LOG.stmt(d_module, d_position, 'hdr_type_lookup_code', l_lines_same_ou.hdr_type_lookup_code);
   END IF;

  d_position := 100;

  -- Transaction Flow should not exists between purchasing org and ship-to org
  -- when there exists a valid project reference
  FORALL i IN 1 .. l_lines_same_ou.interface_id.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , result_type
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , PO_VALIDATIONS.c_result_type_FAILURE
  , c_ENTITY_TYPE_LINE
  , l_lines_same_ou.interface_id(i)
  , 'REQUISITION_LINE_ID'
  , l_lines_same_ou.requisition_line_id(i)
  , 'PO_CROSS_OU_PA_PROJECT_CHECK'
  FROM
    DUAL
  WHERE
    l_lines_same_ou.txn_flow_header_id(i) IS NOT NULL
  AND l_lines_same_ou.project_referenced_flag(i) = 'Y';

  d_position := 110;

  IF (SQL%ROWCOUNT > 0) THEN
    l_result_type2 := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    l_result_type2 := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  d_position := 120;

  IF(g_is_txn_flow_supported) THEN
    is_txn_flow_supported := 'Y';
  ELSE
    is_txn_flow_supported := 'N';
  END IF;

  -- Validates the ship-to org with the current OU.
  -- The ship-to org is valid if:
  --    - It is within the current set of books
  --      : The current OU does not use encumbrance
  --    OR
  --    - It is outside the current set of books
  --      : A valid inter-company relationship (i.e. transaction flow) exists
  --        between the current OU
  FORALL i IN 1 .. l_lines_same_ou.interface_id.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , result_type
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , PO_VALIDATIONS.c_result_type_FAILURE
  , c_ENTITY_TYPE_LINE
  , l_lines_same_ou.interface_id(i)
  , 'SHIP_TO_ORGANIZATION_ID '
  , l_lines_same_ou.requisition_line_id(i)
  , 'PO_PDOI_TXN_FLOW_API_ERROR'
  FROM
    financials_system_parameters fsp
  , hr_organization_information hoi
  WHERE fsp.org_id                = l_lines_same_ou.org_id(i)
  AND hoi.organization_id         = l_lines_same_ou.destination_org_id(i)
  AND hoi.org_information_context = 'Accounting Information'
  AND (
    CASE
      WHEN fsp.set_of_books_id = to_number(hoi.org_information1)
        THEN DECODE(is_txn_flow_supported, 'Y', 'Y', 'N')
      WHEN is_txn_flow_supported = 'Y' AND NVL(purch_encumbrance_flag, 'N') = 'N'
          AND NVL(req_encumbrance_flag, 'N')   = 'N'
        THEN NVL2(l_lines_same_ou.txn_flow_header_id(i), 'Y', 'N')
      ELSE 'N'
    END) = 'N';

  d_position := 130;

  IF (SQL%ROWCOUNT > 0) THEN
    l_result_type3 := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    l_result_type3 := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module, d_position, 'x_result_set_id', x_result_set_id);
    PO_LOG.stmt(d_module, d_position, 'l_result_type1', l_result_type1);
    PO_LOG.stmt(d_module, d_position, 'l_result_type2', l_result_type2);
    PO_LOG.stmt(d_module, d_position, 'l_result_type3', l_result_type3);
  END IF;

  IF(l_result_type1 = PO_VALIDATIONS.c_result_type_FAILURE
      OR l_result_type2 = PO_VALIDATIONS.c_result_type_FAILURE
      OR l_result_type3 = PO_VALIDATIONS.c_result_type_FAILURE) THEN
     x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
     x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_result_set_id', x_result_set_id);
    PO_LOG.proc_end(d_module, 'x_result_type', x_result_type);
    PO_LOG.log(po_log.c_proc_end, d_module, NULL, 'x_results', x_results);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_module, d_position, NULL);
  END IF;
  RAISE;

END validate_cross_ou_purchasing;

-- CHECK#1
-------------------------------------------------------------------------------
--Start of Comments
--Name: cross_ou_vmi_check
--Function:
--  Procedure to verify whether VMI is enabled for the group of
--    Requisitions.
--Parameters:
--IN:
--  p_line_id_tbl
--    Nested table of Interface Line IDs
--  p_requisition_line_id_tbl
--    Nested table of Req Line IDs which need to be validated
--  p_vmi_flag_tbl
--    Nested table of 'Y' or 'N' indicating whether line is vmi enabled
--  p_document_type_tbl
--    Nested table of document type of the outcome documents.
--IN OUT:
--  x_result_set_id
--    Identifier for the output results in PO_VALIDATION_RESULTS.
--OUT:
--  x_result_type
--    Provides a summary of the validation results.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE cross_ou_vmi_check
(
    p_line_id_tbl             IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl IN PO_TBL_NUMBER ,
    p_vmi_flag_tbl            IN PO_TBL_VARCHAR1 ,
    p_document_type_tbl       IN PO_TBL_VARCHAR30 ,
    x_result_set_id           IN OUT NOCOPY NUMBER ,
    x_result_type             OUT NOCOPY VARCHAR2
)
IS

  d_api_name CONSTANT VARCHAR2(100)  := 'cross_ou_vmi_check';
  d_module   CONSTANT VARCHAR2(255)  := d_pkg_name || d_api_name || '.';
  d_position NUMBER                  := 0;

BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_module, 'p_line_id_tbl', p_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_requisition_line_id_tbl', p_requisition_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_vmi_flag_tbl', p_vmi_flag_tbl);
    PO_LOG.proc_begin(d_module, 'p_document_type_tbl', p_document_type_tbl);
    PO_LOG.proc_begin(d_module, 'x_result_set_id', x_result_set_id);
  END IF;

  d_position          := 001;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id   := PO_VALIDATIONS.next_result_set_id();
  END IF;

  d_position := 002;

  --SQL What: Query to verify whether VMI is enabled or not
  --SQL Why: If requisition line is VMI enabled, cross ou should not be allowed
  --         and insert error record into PO_VALIDATION_RESULTS_GT
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , result_type
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , PO_VALIDATIONS.c_result_type_FAILURE
  , c_ENTITY_TYPE_LINE
  , p_line_id_tbl(i)
  , 'REQUISITION_LINE_ID'
  , p_requisition_line_id_tbl(i)
  , 'PO_CROSS_OU_VMI_CHECK'
  FROM
    DUAL
  WHERE
    p_vmi_flag_tbl(i)              = 'Y'
  AND p_document_type_tbl(i)       = 'STANDARD';

  d_position      := 003;
  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_module, 'x_result_set_id', x_result_set_id);
    PO_LOG.proc_end(d_module, 'x_result_type', x_result_type);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_module, d_position, NULL);
  END IF;
  RAISE;
END cross_ou_vmi_check;

-- CHECK#2
-------------------------------------------------------------------------------
--Start of Comments
--Name: cross_ou_consigned_check
--Function:
--  Procedure to verify consigned setting of the ASL
--Parameters:
--IN:
--  p_line_id_tbl
--    Nested table of Interface Line IDs
--  p_requisition_line_id_tbl
--    Nested table of Req Line IDs which need to be validated
--  p_cons_from_supp_flag_tbl
--    Nested table of 'Y' or 'N' corresponding to consigned_from_supp_flag
--    This attribute is obtained from ASL attributes.
--  p_document_type_tbl
--    Nested table of document type of the outcome documents.
--IN OUT:
--  x_result_set_id
--    Identifier for the output results in PO_VALIDATION_RESULTS.
--OUT:
--  x_result_type
--    Provides a summary of the validation results.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE cross_ou_consigned_check
(
    p_line_id_tbl             IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl IN PO_TBL_NUMBER ,
    p_cons_from_supp_flag_tbl IN PO_TBL_VARCHAR1 ,
    p_document_type_tbl       IN PO_TBL_VARCHAR30 ,
    x_result_set_id           IN OUT NOCOPY NUMBER ,
    x_result_type             OUT NOCOPY VARCHAR2
)
IS

  d_api_name CONSTANT VARCHAR2(100)  := 'cross_ou_consigned_check';
  d_module   CONSTANT VARCHAR2(255)  := d_pkg_name || d_api_name || '.';
  d_position NUMBER                  := 0;

BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_module, 'p_line_id_tbl', p_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_requisition_line_id_tbl', p_requisition_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_cons_from_supp_flag_tbl', p_cons_from_supp_flag_tbl);
    PO_LOG.proc_begin(d_module, 'p_document_type_tbl', p_document_type_tbl);
    PO_LOG.proc_begin(d_module, 'x_result_set_id', x_result_set_id);
  END IF;

  d_position          := 001;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id   := PO_VALIDATIONS.next_result_set_id();
  END IF;

  d_position := 002;

  --SQL What: Query to verify whether consigned relationship exists or not
  --SQL Why: If consigned relationship exists, then cross ou should not be
  --         allowed and insert error record into PO_VALIDATION_RESULTS_GT
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , result_type
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , PO_VALIDATIONS.c_result_type_FAILURE
  , c_ENTITY_TYPE_LINE
  , p_line_id_tbl(i)
  , 'REQUISITION_LINE_ID'
  , p_requisition_line_id_tbl(i)
  , 'PO_CROSS_OU_CONSIGNED_CHECK'
  FROM
    DUAL
  WHERE
    p_cons_from_supp_flag_tbl(i)   = 'Y'
  AND p_document_type_tbl(i)       = 'STANDARD';

  d_position      := 003;
  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_module, 'x_result_set_id', x_result_set_id);
    PO_LOG.proc_end(d_module, 'x_result_type', x_result_type);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_module, d_position, NULL);
  END IF;
  RAISE;
END cross_ou_consigned_check;

-- CHECK#3
-------------------------------------------------------------------------------
--Start of Comments
--Name: cross_ou_item_validity_check
--Function:
--  Do item validity checks accross OUs
--Parameters:
--IN:
--  p_line_id_tbl
--    Nested table of Interface Line IDs
--  p_requisition_line_id_tbl
--    Nested table of Req Line IDs which need to be validated
--  p_item_id_tbl
--    Nested table containing Item Id of Req Line
--  p_global_agreement_flag_tbl
--    Nested table of 'Y' or 'N' which indicates that the source
--    document is global or not
--  p_purchasing_org_id_tbl
--    Nested table of OU's where the PO will be created
--  p_requesting_org_id_tbl
--    Nested table containing Req Line OU's
--  p_owning_org_id_tbl
--    Nested table of OU's where the Source document exists
--  p_document_type_tbl
--    Nested table of document type of the outcome documents.
--IN OUT:
--  x_result_set_id
--    Identifier for the output results in PO_VALIDATION_RESULTS.
--OUT:
--  x_result_type
--    Provides a summary of the validation results.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE cross_ou_item_validity_check
(
    p_line_id_tbl             IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl IN PO_TBL_NUMBER ,
    p_item_id_tbl             IN PO_TBL_NUMBER ,
    p_global_agreement_flag_tbl IN PO_TBL_VARCHAR1 ,
    p_purchasing_org_id_tbl   IN PO_TBL_NUMBER ,
    p_requesting_org_id_tbl   IN PO_TBL_NUMBER ,
    p_owning_org_id_tbl       IN PO_TBL_NUMBER ,
    p_document_type_tbl       IN PO_TBL_VARCHAR30 ,
    x_result_set_id           IN OUT NOCOPY NUMBER ,
    x_result_type             OUT NOCOPY VARCHAR2
)
IS

  d_api_name CONSTANT VARCHAR2(100) := 'cross_ou_item_validity_check';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER                 := 0;

  l_result_count1 NUMBER            := 0;
  l_result_count2 NUMBER            := 0;
  l_result_count3 NUMBER            := 0;
BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_module, 'p_line_id_tbl', p_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_requisition_line_id_tbl', p_requisition_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_item_id_tbl', p_item_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_purchasing_org_id_tbl', p_purchasing_org_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_requesting_org_id_tbl', p_requesting_org_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_owning_org_id_tbl', p_owning_org_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_document_type_tbl', p_purchasing_org_id_tbl);
    PO_LOG.proc_begin(d_module, 'x_result_set_id', x_result_set_id);
  END IF;

  d_position          := 001;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id   := PO_VALIDATIONS.next_result_set_id();
  END IF;

  d_position := 002;

  --SQL What: Query to verify whether the item is valid between purchasing and
  --          owning org's only when lines having GA reference
  --SQL Why: If item is osp item or not purchasable or uom's are different,
  --         then cross ou should not be allowed and insert error records
  --         into PO_VALIDATION_RESULTS_GT
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , result_type
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , PO_VALIDATIONS.c_result_type_FAILURE
  , c_ENTITY_TYPE_LINE
  , p_line_id_tbl(i)
  , 'REQUISITION_LINE_ID'
  , p_requisition_line_id_tbl(i)
  , (CASE
      WHEN itv.purchasable_flag <> 'Y' THEN 'PO_CROSS_OU_ITEM_PURCH_CHECK'
      WHEN itv.uom_class <> itv.valid_uom_class THEN 'PO_CROSS_OU_UOM_CHECK'
      WHEN itv.osp_flag <> 'N' THEN 'PO_CROSS_OU_OSP_CHECK'
    END)
  FROM
    (SELECT ITEMS1.purchasing_enabled_flag purchasable_flag,
      ITEMS1.outside_operation_flag osp_flag,
      UOM1.uom_class uom_class,
      UOM2.uom_class valid_uom_class
     FROM financials_system_params_all FSP1,
      financials_system_params_all FSP2, -- valid org
      mtl_system_items_b ITEMS1,
      mtl_system_items_b ITEMS2, -- valid org
      mtl_units_of_measure_tl UOM1,
      mtl_units_of_measure_tl UOM2 -- valid org
     WHERE FSP1.org_id            = p_purchasing_org_id_tbl(i)
     AND ITEMS1.inventory_item_id = p_item_id_tbl(i)
     AND ITEMS1.organization_id   = FSP1.inventory_organization_id
     AND UOM1.uom_code            = ITEMS1.primary_uom_code
     AND UOM1.language            = USERENV('LANG')
     AND FSP2.org_id              = p_owning_org_id_tbl(i)
     AND ITEMS2.inventory_item_id = p_item_id_tbl(i)
     AND ITEMS2.organization_id   = FSP2.inventory_organization_id
     AND UOM2.uom_code            = ITEMS2.primary_uom_code
     AND UOM2.language            = USERENV('LANG')) itv
  WHERE p_item_id_tbl(i)   IS NOT NULL
    AND p_purchasing_org_id_tbl(i) <> p_owning_org_id_tbl(i)
    AND p_global_agreement_flag_tbl(i) = 'Y';

  IF (SQL%ROWCOUNT > 0) THEN
    l_result_count1 := SQL%ROWCOUNT;
  END IF;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module, d_position, 'l_result_count1', l_result_count1);
  END IF;

  d_position      := 003;

  --SQL What: Query to verify whether the item is valid between requesting and
  --          owning org's only when lines having GA reference
  --SQL Why: If item is osp item or not purchasable or uom's are different,
  --         then cross ou should not be allowed and insert error records
  --         into PO_VALIDATION_RESULTS_GT
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , result_type
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , PO_VALIDATIONS.c_result_type_FAILURE
  , c_ENTITY_TYPE_LINE
  , p_line_id_tbl(i)
  , 'REQUISITION_LINE_ID'
  , p_requisition_line_id_tbl(i)
  , (CASE
      WHEN itv.purchasable_flag <> 'Y' THEN 'PO_CROSS_OU_ITEM_PURCH_CHECK'
      WHEN itv.uom_class <> itv.valid_uom_class THEN 'PO_CROSS_OU_UOM_CHECK'
      WHEN itv.osp_flag <> 'N' THEN 'PO_CROSS_OU_OSP_CHECK'
    END)
  FROM
    (SELECT ITEMS1.purchasing_enabled_flag purchasable_flag,
      ITEMS1.outside_operation_flag osp_flag,
      UOM1.uom_class uom_class,
      UOM2.uom_class valid_uom_class
     FROM financials_system_params_all FSP1,
      financials_system_params_all FSP2, -- valid org
      mtl_system_items_b ITEMS1,
      mtl_system_items_b ITEMS2, -- valid org
      mtl_units_of_measure_tl UOM1,
      mtl_units_of_measure_tl UOM2 -- valid org
     WHERE FSP1.org_id            = p_requesting_org_id_tbl(i)
     AND ITEMS1.inventory_item_id = p_item_id_tbl(i)
     AND ITEMS1.organization_id   = FSP1.inventory_organization_id
     AND UOM1.uom_code            = ITEMS1.primary_uom_code
     AND UOM1.language            = USERENV('LANG')
     AND FSP2.org_id              = p_owning_org_id_tbl(i)
     AND ITEMS2.inventory_item_id = p_item_id_tbl(i)
     AND ITEMS2.organization_id   = FSP2.inventory_organization_id
     AND UOM2.uom_code            = ITEMS2.primary_uom_code
     AND UOM2.language            = USERENV('LANG')) itv
  WHERE p_item_id_tbl(i) IS NOT NULL
    AND p_requesting_org_id_tbl(i) <> p_owning_org_id_tbl(i)
    AND p_global_agreement_flag_tbl(i) = 'Y';

  IF (SQL%ROWCOUNT > 0) THEN
    l_result_count2 := SQL%ROWCOUNT;
  END IF;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module, d_position, 'l_result_count2', l_result_count2);
  END IF;

  d_position      := 004;

  --SQL What: Query to verify whether the item is valid between purchasing and
  --          requesting org's when no source doc info exists
  --SQL Why: If item is not purchasable or uom's are different,
  --         then cross ou should not be allowed and insert error records
  --         into PO_VALIDATION_RESULTS_GT
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , result_type
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , PO_VALIDATIONS.c_result_type_FAILURE
  , c_ENTITY_TYPE_LINE
  , p_line_id_tbl(i)
  , 'REQUISITION_LINE_ID'
  , p_requisition_line_id_tbl(i)
  , (CASE
      WHEN itv.purchasable_flag <> 'Y' THEN 'PO_CROSS_OU_ITEM_PURCH_CHECK'
      WHEN itv.uom_class <> itv.valid_uom_class THEN 'PO_CROSS_OU_UOM_CHECK'
    END)
  FROM
    (SELECT ITEMS1.purchasing_enabled_flag purchasable_flag,
      UOM1.uom_class uom_class,
      UOM2.uom_class valid_uom_class
     FROM financials_system_params_all FSP1,
      financials_system_params_all FSP2, -- valid org
      mtl_system_items_b ITEMS1,
      mtl_system_items_b ITEMS2, -- valid org
      mtl_units_of_measure_tl UOM1,
      mtl_units_of_measure_tl UOM2 -- valid org
     WHERE FSP1.org_id            = p_purchasing_org_id_tbl(i)
     AND ITEMS1.inventory_item_id = p_item_id_tbl(i)
     AND ITEMS1.organization_id   = FSP1.inventory_organization_id
     AND UOM1.uom_code            = ITEMS1.primary_uom_code
     AND UOM1.language            = USERENV('LANG')
     AND FSP2.org_id              = p_requesting_org_id_tbl(i)
     AND ITEMS2.inventory_item_id = p_item_id_tbl(i)
     AND ITEMS2.organization_id   = FSP2.inventory_organization_id
     AND UOM2.uom_code            = ITEMS2.primary_uom_code
     AND UOM2.language            = USERENV('LANG')) itv
  WHERE p_item_id_tbl(i)   IS NOT NULL
    AND p_purchasing_org_id_tbl(i) = p_requesting_org_id_tbl(i)
    AND p_global_agreement_flag_tbl(i) <> 'Y';

  IF (SQL%ROWCOUNT > 0) THEN
    l_result_count3 := SQL%ROWCOUNT;
  END IF;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module, d_position, 'l_result_count3', l_result_count3);
  END IF;

  IF (l_result_count1>0 OR l_result_count2>0 OR l_result_count3>0) THEN
    x_result_type   := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_module, 'x_result_set_id', x_result_set_id);
    PO_LOG.proc_end(d_module, 'x_result_type', x_result_type);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_module, d_position, NULL);
  END IF;
  RAISE;
END cross_ou_item_validity_check;

-- CHECK#4
-------------------------------------------------------------------------------
--Start of Comments
--Name: cross_ou_pa_project_check
--Function:
--  Checks whether destination type is expense for the line and project_id field
--    on the corresponding distribution lines is not NULL
--Parameters:
--IN:
--  p_line_id_tbl
--    Nested table of Interface Line IDs
--  p_requisition_line_id_tbl
--    Nested table of Req Line IDs which need to be validated
--  p_project_referenced_flag_tbl
--    Nested table of 'Y' or 'N' which indicates whether there is any
--    valid project exists or not for the requisition
--  p_document_type_tbl
--    Nested table of document type of the outcome documents.
--IN OUT:
--  x_result_set_id
--    Identifier for the output results in PO_VALIDATION_RESULTS.
--OUT:
--  x_result_type
--    Provides a summary of the validation results.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE cross_ou_pa_project_check
(
    p_line_id_tbl                 IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl     IN PO_TBL_NUMBER ,
    p_project_referenced_flag_tbl IN PO_TBL_VARCHAR1 ,
    p_document_type_tbl           IN PO_TBL_VARCHAR30 ,
    x_result_set_id               IN OUT NOCOPY NUMBER ,
    x_result_type                 OUT NOCOPY VARCHAR2
)
IS

  d_api_name CONSTANT VARCHAR2(100)  := 'cross_ou_pa_project_check';
  d_module   CONSTANT VARCHAR2(255)  := d_pkg_name || d_api_name || '.';
  d_position NUMBER                  := 0;

BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_module, 'p_line_id_tbl', p_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_requisition_line_id_tbl', p_requisition_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_project_referenced_flag_tbl', p_project_referenced_flag_tbl);
    PO_LOG.proc_begin(d_module, 'p_document_type_tbl', p_document_type_tbl);
    PO_LOG.proc_begin(d_module, 'x_result_set_id', x_result_set_id);
  END IF;

  d_position          := 001;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id   := PO_VALIDATIONS.next_result_set_id();
  END IF;

  d_position := 002;

  --SQL What: Query to check whether there is any valid project exists for expense
  --          type distributions of the requistion
  --SQL Why: If valid PA Project exists, then cross ou should not be
  --         allowed and insert error records into PO_VALIDATION_RESULTS_GT
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , result_type
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , PO_VALIDATIONS.c_result_type_FAILURE
  , c_ENTITY_TYPE_LINE
  , p_line_id_tbl(i)
  , 'REQUISITION_LINE_ID'
  , p_requisition_line_id_tbl(i)
  , 'PO_CROSS_OU_PA_PROJECT_CHECK'
  FROM
    DUAL
  WHERE
    p_project_referenced_flag_tbl(i)   = 'Y'
  AND p_document_type_tbl(i)           = 'STANDARD';

  d_position      := 003;
  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_module, 'x_result_set_id', x_result_set_id);
    PO_LOG.proc_end(d_module, 'x_result_type', x_result_type);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_module, d_position, NULL);
  END IF;
  RAISE;
END cross_ou_pa_project_check;

-- CHECK#6
-------------------------------------------------------------------------------
--Start of Comments
--Name: cross_ou_dest_ou_check
--Function:
--  If (DOU=POU) AND (DOU<>ROU) then we are preventing the PO creation.
--Parameters:
--IN:
--  p_line_id_tbl
--    Nested table of Interface Line IDs
--  p_requisition_line_id_tbl
--    Nested table of Req Line IDs which need to be validated
--  p_dest_inv_org_ou_id_tbl
--    Nested table of Operating Unit's associated with the
--    destination org_id of requisition OR inventory org_id
--    specified in Financial System Parameters.
--  p_purchasing_org_id_tbl
--    Nested table of OU's where the PO will be created
--  p_requesting_org_id_tbl
--    Nested table containing Req Line OU's
--  p_document_type_tbl
--    Nested table of document type of the outcome documents.
--IN OUT:
--  x_result_set_id
--    Identifier for the output results in PO_VALIDATION_RESULTS.
--OUT:
--  x_result_type
--    Provides a summary of the validation results.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE cross_ou_dest_ou_check
(
    p_line_id_tbl             IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl IN PO_TBL_NUMBER ,
    p_dest_inv_org_ou_id_tbl  IN PO_TBL_NUMBER ,
    p_purchasing_org_id_tbl   IN PO_TBL_NUMBER ,
    p_requesting_org_id_tbl   IN PO_TBL_NUMBER ,
    p_document_type_tbl       IN PO_TBL_VARCHAR30 ,
    x_result_set_id           IN OUT NOCOPY NUMBER ,
    x_result_type             OUT NOCOPY VARCHAR2
)
IS

  d_api_name CONSTANT VARCHAR2(100)  := 'cross_ou_dest_ou_check';
  d_module   CONSTANT VARCHAR2(255)  := d_pkg_name || d_api_name || '.';
  d_position NUMBER                  := 0;

BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_module, 'p_line_id_tbl', p_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_requisition_line_id_tbl', p_requisition_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_dest_inv_org_ou_id_tbl', p_dest_inv_org_ou_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_purchasing_org_id_tbl', p_purchasing_org_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_requesting_org_id_tbl', p_requesting_org_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_document_type_tbl', p_document_type_tbl);
    PO_LOG.proc_begin(d_module, 'x_result_set_id', x_result_set_id);
  END IF;

  d_position          := 001;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id   := PO_VALIDATIONS.next_result_set_id();
  END IF;

  d_position := 002;

  --SQL What: Query to check the condition (DOU=POU) AND (DOU<>ROU)
  --SQL Why: The Purchase Order cannot be created in the Deliver-To Org when its
  --         backing requisition is from another operating unit
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , result_type
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , PO_VALIDATIONS.c_result_type_FAILURE
  , c_ENTITY_TYPE_LINE
  , p_line_id_tbl(i)
  , 'REQUISITION_LINE_ID'
  , p_requisition_line_id_tbl(i)
  , 'PO_CROSS_OU_DEST_OU_CHECK'
  FROM
    DUAL
  WHERE
    p_dest_inv_org_ou_id_tbl(i)    =  p_purchasing_org_id_tbl(i)
  AND p_dest_inv_org_ou_id_tbl(i)  <> p_requesting_org_id_tbl(i)
  AND p_document_type_tbl(i)       =  'STANDARD';

  d_position      := 003;
  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_module, 'x_result_set_id', x_result_set_id);
    PO_LOG.proc_end(d_module, 'x_result_type', x_result_type);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_module, d_position, NULL);
  END IF;
  RAISE;
END cross_ou_dest_ou_check;

-- CHECK#7
-------------------------------------------------------------------------------
--Start of Comments
--Name: cross_ou_trnx_flow_check
--Function:
--  Check if an inventory transaction flow exists.
--Parameters:
--IN:
--  p_line_id_tbl
--    Nested table of Interface Line IDs
--  p_requisition_line_id_tbl
--    Nested table of Req Line IDs which need to be validated
--  p_transaction_flow_header_id_tbl
--    Nested table of header ID's of the transaction flow, if any valid
--    inter-company relationship exists.
--  p_item_id_tbl
--    Nested table containing Item Id of Req Line
--  p_document_type_tbl
--    Nested table of document type of the outcome documents.
--IN OUT:
--  x_result_set_id
--    Identifier for the output results in PO_VALIDATION_RESULTS.
--OUT:
--  x_result_type
--    Provides a summary of the validation results.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE cross_ou_txn_flow_check
(
    p_line_id_tbl                    IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl        IN PO_TBL_NUMBER ,
    p_txn_flow_header_id_tbl         IN PO_TBL_NUMBER ,
    p_item_id_tbl                    IN PO_TBL_NUMBER ,
    p_document_type_tbl              IN PO_TBL_VARCHAR30 ,
    x_result_set_id                  IN OUT NOCOPY NUMBER ,
    x_result_type                    OUT NOCOPY VARCHAR2
)
IS

  d_api_name CONSTANT VARCHAR2(100)  := 'cross_ou_txn_flow_check';
  d_module   CONSTANT VARCHAR2(255)  := d_pkg_name || d_api_name || '.';
  d_position NUMBER                  := 0;

  l_result_count1 NUMBER             := 0;
  l_result_count2 NUMBER             := 0;

BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_module, 'p_line_id_tbl', p_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_requisition_line_id_tbl', p_requisition_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_txn_flow_header_id_tbl'
                           , p_txn_flow_header_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_document_type_tbl', p_document_type_tbl);
    PO_LOG.proc_begin(d_module, 'x_result_set_id', x_result_set_id);
  END IF;

  d_position          := 001;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id   := PO_VALIDATIONS.next_result_set_id();
  END IF;

  d_position := 002;

  --SQL What: Query to check whether transaction flow exists between
  --          Purchasing OU and Destination OU
  --SQL Why: If transaction flow does not exist, then cross ou should not be
  --         allowed and insert error record into PO_VALIDATION_RESULTS
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , result_type
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , PO_VALIDATIONS.c_result_type_FAILURE
  , c_ENTITY_TYPE_LINE
  , p_line_id_tbl(i)
  , 'REQUISITION_LINE_ID'
  , p_requisition_line_id_tbl(i)
  , 'PO_CROSS_OU_TRNX_FLOW_CHECK'
  FROM
    DUAL
  WHERE
    p_txn_flow_header_id_tbl(i)    IS NULL
  AND p_document_type_tbl(i)       =  'STANDARD';

  d_position := 003;
  IF (SQL%ROWCOUNT > 0) THEN
    l_result_count1 := SQL%ROWCOUNT;
  END IF;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module, d_position, 'l_result_count1', l_result_count1);
  END IF;

  d_position := 004;

  --SQL What: Query to validate the below conditions:
  --          Item should exist in logical inv ou for the transaction flow
  --          if transaction flow exists and item id is not null
  --SQL Why: If the above conditions are not satisfied, then cross ou should
  --         not be allowed and insert error record into PO_VALIDATION_RESULTS
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , result_type
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , PO_VALIDATIONS.c_result_type_FAILURE
  , c_ENTITY_TYPE_LINE
  , p_line_id_tbl(i)
  , 'REQUISITION_LINE_ID'
  , p_requisition_line_id_tbl(i)
  , 'PO_ITEM_IN_LINV_POU_CHECK'
  FROM
    DUAL
  WHERE
    p_item_id_tbl(i)                  IS NOT NULL
  AND p_txn_flow_header_id_tbl(i) IS NOT NULL
  AND p_document_type_tbl(i)           = 'STANDARD'
  AND NOT EXISTS
    (SELECT 'Inventory Org exists and Item exists in Inventory Org'
     FROM mtl_system_items_b msi,
       mtl_parameters mp,
       mtl_transaction_flow_lines mtfl
     WHERE msi.inventory_item_id = p_item_id_tbl(i)
     and msi.organization_id     = mtfl.from_organization_id
     AND mtfl.header_id          = p_txn_flow_header_id_tbl(i)
     AND mtfl.line_number        = 1
     AND mtfl.from_organization_id IS NOT NULL
     AND mp.organization_id      = msi.organization_id);

  d_position      :=  005;
  IF (SQL%ROWCOUNT > 0) THEN
    l_result_count2 := SQL%ROWCOUNT;
  END IF;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module, d_position, 'l_result_count2', l_result_count2);
  END IF;

  d_position      :=  006;
  IF (l_result_count1>0 OR l_result_count2>0) THEN
    x_result_type   := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_module, 'x_result_set_id', x_result_set_id);
    PO_LOG.proc_end(d_module, 'x_result_type', x_result_type);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_module, d_position, NULL);
  END IF;
  RAISE;
END cross_ou_txn_flow_check;

-- CHECK#8
-------------------------------------------------------------------------------
--Start of Comments
--Name: cross_ou_services_check
--Function:
--  If 'HR: Cross Business Groups' is NO
--    then ROU and POU should rollup to the same Business Group
--Parameters:
--IN:
--  p_line_id_tbl
--    Nested table of Interface Line IDs
--  p_requisition_line_id_tbl
--    Nested table of Req Line IDs which need to be validated
--  p_purchasing_org_id_tbl
--    Nested table of OU's where the PO will be created
--  p_requesting_org_id_tbl
--    Nested table containing Req Line OU's
--  p_document_type_tbl
--    Nested table of document type of the outcome documents.
--IN OUT:
--  x_result_set_id
--    Identifier for the output results in PO_VALIDATION_RESULTS.
--OUT:
--  x_result_type
--    Provides a summary of the validation results.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE cross_ou_services_check
(
    p_line_id_tbl             IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl IN PO_TBL_NUMBER ,
    p_purchasing_org_id_tbl   IN PO_TBL_NUMBER ,
    p_requesting_org_id_tbl   IN PO_TBL_NUMBER ,
    p_document_type_tbl       IN PO_TBL_VARCHAR30 ,
    x_result_set_id           IN OUT NOCOPY NUMBER ,
    x_result_type             OUT NOCOPY VARCHAR2
)
IS

  d_api_name CONSTANT VARCHAR2(100)  := 'cross_ou_services_check';
  d_module   CONSTANT VARCHAR2(255)  := d_pkg_name || d_api_name || '.';
  d_position NUMBER                  := 0;

  l_xbg_profile VARCHAR2(1);

BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_module, 'p_line_id_tbl', p_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_requisition_line_id_tbl', p_requisition_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_purchasing_org_id_tbl', p_purchasing_org_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_requesting_org_id_tbl', p_requesting_org_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_document_type_tbl', p_document_type_tbl);
    PO_LOG.proc_begin(d_module, 'x_result_set_id', x_result_set_id);
  END IF;

  d_position          := 001;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id   := PO_VALIDATIONS.next_result_set_id();
  END IF;

  d_position := 002;

    -- Fetch xbg_profile from hr_general
  l_xbg_profile := NVL(hr_general.get_xbg_profile, 'N');

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module, d_position, 'l_xbg_profile', l_xbg_profile);
  END IF;

  d_position := 003;

  --SQL What: If 'HR: Cross Business Groups' is NO
  --          then ROU and POU should rollup to the same Business Group
  --SQL Why: The Job Title specified on the selected requisition lines cannot be purchased
  --         in the designated Purchasing Org, hence cross ou should not be allowed and
  --         insert error records into PO_VALIDATION_RESULTS_GT
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , result_type
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , PO_VALIDATIONS.c_result_type_FAILURE
  , c_ENTITY_TYPE_LINE
  , p_line_id_tbl(i)
  , 'REQUISITION_LINE_ID'
  , p_requisition_line_id_tbl(i)
  , 'PO_CROSS_OU_SERVICES_CHECK'
  FROM po_requisition_lines_all prl,
    hr_all_organization_units hrou_po,
    hr_all_organization_units hrou_req
  WHERE prl.requisition_line_id  = p_requisition_line_id_tbl(i)
  AND hrou_po.organization_id    = p_purchasing_org_id_tbl(i)
  AND hrou_req.organization_id   = p_requesting_org_id_tbl(i)
  AND prl.purchase_basis         = 'TEMP LABOR'
  AND hrou_po.business_group_id  <> hrou_req.business_group_id
  AND p_document_type_tbl(i)     = 'STANDARD'
  AND l_xbg_profile              = 'N';

  d_position      := 004;
  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_module, 'x_result_set_id', x_result_set_id);
    PO_LOG.proc_end(d_module, 'x_result_type', x_result_type);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_module, d_position, NULL);
  END IF;
  RAISE;
END cross_ou_services_check;

-- CHECK#9
-------------------------------------------------------------------------------
--Start of Comments
--Name: cross_ou_cust_loc_check
--Function:
--  If the deliver-to-location on req Line is customer location then
--    OM family pack should be installed to handle cross OU purchasing in
--    international drop ship scenerio.
--Parameters:
--IN:
--  p_line_id_tbl
--    Nested table of Interface Line IDs
--  p_requisition_line_id_tbl
--    Nested table of Req Line IDs which need to be validated
--  p_deliver_to_location_id_tbl
--    Nested table of deliver_to_location_id's of the Requisition
--  p_document_type_tbl
--    Nested table of document type of the outcome documents.
--IN OUT:
--  x_result_set_id
--    Identifier for the output results in PO_VALIDATION_RESULTS.
--OUT:
--  x_result_type
--    Provides a summary of the validation results.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE cross_ou_cust_loc_check
(
    p_line_id_tbl                IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl    IN PO_TBL_NUMBER ,
    p_deliver_to_location_id_tbl IN PO_TBL_NUMBER ,
    p_document_type_tbl          IN PO_TBL_VARCHAR30 ,
    x_result_set_id              IN OUT NOCOPY NUMBER ,
    x_result_type                OUT NOCOPY VARCHAR2
)
IS

  d_api_name CONSTANT VARCHAR2(100)  := 'cross_ou_cust_loc_check';
  d_module   CONSTANT VARCHAR2(255)  := d_pkg_name || d_api_name || '.';
  d_position NUMBER                  := 0;

  l_code_release_level VARCHAR2(10);

BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_module, 'p_line_id_tbl', p_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_requisition_line_id_tbl', p_requisition_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_deliver_to_location_id_tbl', p_deliver_to_location_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_document_type_tbl', p_document_type_tbl);
    PO_LOG.proc_begin(d_module, 'x_result_set_id', x_result_set_id);
  END IF;

  d_position          := 001;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id   := PO_VALIDATIONS.next_result_set_id();
  END IF;

  d_position := 002;

  -- Fetch code_release_level from OE_CODE_CONTROL
  l_code_release_level := OE_CODE_CONTROL.code_release_level;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module, d_position, 'l_code_release_level', l_code_release_level);
  END IF;

  d_position := 003;

  --SQL What: Query to check whether deliver-to-location on req Line is customer location
  --          and OM is installed or not
  --SQL Why: If the deliver-to-location on req Line is customer location then
  --         OM family pack should be installed to handle cross OU purchasing in
  --         international drop ship scenerio.
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , result_type
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , PO_VALIDATIONS.c_result_type_FAILURE
  , c_ENTITY_TYPE_LINE
  , p_line_id_tbl(i)
  , 'REQUISITION_LINE_ID'
  , p_requisition_line_id_tbl(i)
  , 'PO_CROSS_OU_CUST_LOC_CHECK'
  FROM
    DUAL
  WHERE
    (NOT l_code_release_level >= '110510')
  AND EXISTS
    (SELECT 'Deliver to location on Req is Ct location'
     FROM HZ_LOCATIONS
     WHERE NVL(address_expiration_date, TRUNC(sysdate + 1)) > TRUNC(sysdate)
     AND location_id                                        = p_deliver_to_location_id_tbl(i));

  d_position      := 004;
  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_module, 'x_result_set_id', x_result_set_id);
    PO_LOG.proc_end(d_module, 'x_result_type', x_result_type);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_module, d_position, NULL);
  END IF;
  RAISE;
END cross_ou_cust_loc_check;

-- CHECK#10
-------------------------------------------------------------------------------
--Start of Comments
--Name: cross_ou_ga_encumbrance_check
--Function:
--  Check whether the Encumbrance is enabled for Purchasing/Requesting Org.
--Parameters:
--IN:
--  p_line_id_tbl
--    Nested table of Interface Line IDs
--  p_requisition_line_id_tbl
--    Nested table of Req Line IDs which need to be validated
--  p_requesting_org_id_tbl
--    Nested table containing Req Line OU's
--  p_purchasing_org_id_tbl
--    Nested table of OU's where the PO will be created
--  p_document_type_tbl
--    Nested table of document type of the outcome documents.
--IN OUT:
--  x_result_set_id
--    Identifier for the output results in PO_VALIDATION_RESULTS.
--OUT:
--  x_result_type
--    Provides a summary of the validation results.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE cross_ou_ga_encumbrance_check
(
    p_line_id_tbl             IN PO_TBL_NUMBER ,
    p_requisition_line_id_tbl IN PO_TBL_NUMBER ,
    p_requesting_org_id_tbl   IN PO_TBL_NUMBER ,
    p_purchasing_org_id_tbl   IN PO_TBL_NUMBER ,
    p_document_type_tbl       IN PO_TBL_VARCHAR30 ,
    x_result_set_id           IN OUT NOCOPY NUMBER ,
    x_result_type             OUT NOCOPY VARCHAR2
)
IS

  d_api_name CONSTANT VARCHAR2(100)  := 'cross_ou_ga_encumbrance_check';
  d_module   CONSTANT VARCHAR2(255)  := d_pkg_name || d_api_name || '.';
  d_position NUMBER                  := 0;

BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_module, 'p_line_id_tbl', p_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_requisition_line_id_tbl', p_requisition_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_requesting_org_id_tbl', p_requesting_org_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_purchasing_org_id_tbl', p_purchasing_org_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_document_type_tbl', p_document_type_tbl);
    PO_LOG.proc_begin(d_module, 'x_result_set_id', x_result_set_id);
  END IF;

  d_position          := 001;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id   := PO_VALIDATIONS.next_result_set_id();
  END IF;

  d_position := 002;

  -- Encumbrance should not be enabled for Purchasing/Requesting Org
  -- when purchasing org is different than requesting org

  --SQL What: Query to check whether encumbrance is enabled or not
  --SQL Why: If encumbrance is enabled for Purchasing/Requesting Org,
  --         then cross ou should not be allowed and insert error record
  --         into PO_VALIDATION_RESULTS
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , result_type
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , PO_VALIDATIONS.c_result_type_FAILURE
  , c_ENTITY_TYPE_LINE
  , p_line_id_tbl(i)
  , 'REQUISITION_LINE_ID'
  , p_requisition_line_id_tbl(i)
  , 'PO_GA_ENCUMBRANCE_CHECK'
  FROM
    DUAL
  WHERE
    p_requesting_org_id_tbl(i)     <>  p_purchasing_org_id_tbl(i)
  AND p_document_type_tbl(i)       =  'STANDARD'
  AND (EXISTS
    (SELECT 'Encumbrance is ON in Requesting Org'
     FROM financials_system_params_all fsp
     WHERE fsp.org_id              = p_requesting_org_id_tbl(i)
     AND (fsp.req_encumbrance_flag = 'Y' OR FSP.purch_encumbrance_flag = 'Y'))
  OR EXISTS
    (SELECT 'Encumbrance is ON in Purchasing Org'
     FROM financials_system_params_all fsp
     WHERE fsp.org_id              = p_purchasing_org_id_tbl(i)
     AND (fsp.req_encumbrance_flag = 'Y' OR FSP.purch_encumbrance_flag = 'Y')));

  d_position      := 003;
  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_module, 'x_result_set_id', x_result_set_id);
    PO_LOG.proc_end(d_module, 'x_result_type', x_result_type);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_module, d_position, NULL);
  END IF;
  RAISE;
END cross_ou_ga_encumbrance_check;

-- <<PDOI Enhancement Bug#17063664 End>>

END PO_SHARED_PROC_PVT;

/
