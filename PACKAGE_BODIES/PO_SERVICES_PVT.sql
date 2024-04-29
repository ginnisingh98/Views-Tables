--------------------------------------------------------
--  DDL for Package Body PO_SERVICES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SERVICES_PVT" AS
/* $Header: POXVSVCB.pls 115.15 2004/07/06 22:17:30 anhuang noship $ */

-- Debugging booleans used to bypass logging when turned off
g_debug_stmt  CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

g_pkg_name      CONSTANT VARCHAR2(20) := 'PO_SERVICES_PVT';
g_module_prefix CONSTANT VARCHAR2(30) := 'po.plsql.' || g_pkg_name || '.';

-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: allow_price_override
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves the Allow Price Override Flag for the given Blanket Line.
--Parameters:
--IN:
--p_po_line_id
--  Unique ID of the Blanket Line
--Returns:
--  BOOLEAN - Allow Price Override Flag of the line
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION allow_price_override(p_po_line_id NUMBER) RETURN BOOLEAN IS

l_allow_price_override_flag po_lines_all.allow_price_override_flag%TYPE :=
null;

BEGIN

    SELECT allow_price_override_flag
    INTO   l_allow_price_override_flag
    FROM   po_lines_all
    WHERE  po_line_id = p_po_line_id;

    IF (l_allow_price_override_flag = 'Y') THEN
        RETURN (TRUE);
    ELSE
        RETURN (FALSE);
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('PO_SERVICES_PVT.allow_price_override',
                               '',
                               sqlcode);
        RAISE;
END allow_price_override;


------------------------------------------------------------------<BUG 3248161>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_ap_compatibility_flag
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines if AP is on a sufficient Family Pack to support
--  Services Procurement. No "Amount"-based matching line types will be
--  allowed unless...
--  (a) (Oracle) AP is on Family Pack M or higher (11i.AP.M) (FIN.F), or
--  (b) (Oracle) AP is not installed (we will allow new Services line types
--      with 3rd party "AP" products, but will not support them), or
--  (c) (Oracle) AP is custom installed (we will allow new Services line types
--      with custom installed AP, but will not support it)
--Parameters:
--   None.
--Returns:
--  'Y' if the current install status of AP is sufficient to support the
--  new Services Procurement "Amount"-based matching line types.
--  'N' otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION get_ap_compatibility_flag
  RETURN VARCHAR2
IS
    l_api_name           VARCHAR2(30) := 'get_ap_compatibility_flag';
    l_log_head           VARCHAR2(100) := g_module_prefix || l_api_name;
    l_progress           VARCHAR2(3);

    l_install_status     VARCHAR2(1);                          -- <BUG 3449557>
    l_ap_family_pack     FND_PRODUCT_INSTALLATIONS.patch_level%TYPE;
    l_result             VARCHAR2(1) := 'N';

BEGIN

l_progress := '000'; PO_DEBUG.debug_begin(l_log_head);

    l_install_status := PO_CORE_S.get_product_install_status('SQLAP');

l_progress := '010'; PO_DEBUG.debug_var ( p_log_head => l_log_head
                                        , p_progress => l_progress
                                        , p_name     => 'AP Install Status'
                                        , p_value    => l_install_status
                                        );

    -- <BUG 3449557 START> Only check for the family pack version if AP
    -- is installed.
    --
    IF ( l_install_status = 'I' ) THEN

        AD_VERSION_UTIL.get_product_patch_level
        (   p_appl_id     => 200        -- AP
        ,   p_patch_level => l_ap_family_pack
        );

l_progress := '020'; PO_DEBUG.debug_var ( p_log_head => l_log_head
                                        , p_progress => l_progress
                                        , p_name     => 'AP Family Pack'
                                        , p_value    => l_ap_family_pack
                                        );

        IF ( l_ap_family_pack >= '11i.AP.M' )
        THEN
            l_result := 'Y';
        ELSE
            l_result := 'N';
        END IF;

l_progress := '030'; PO_DEBUG.debug_var ( p_log_head => l_log_head
                                        , p_progress => l_progress
                                        , p_name     => 'l_result'
                                        , p_value    => l_result
                                        );
    ELSE

        l_result := 'Y';                   -- Else, Oracle AP is not installed,
                                           -- return 'Y' for compatibility flag
    END IF; -- ( l_install_status )
    --
    -- <BUG 3449557 END>

l_progress := '040'; PO_DEBUG.debug_end(l_log_head);

    return (l_result);                                         -- <BUG 3449557>

EXCEPTION

    WHEN OTHERS THEN
        PO_DEBUG.debug_exc ( p_log_head => l_log_head
                           , p_progress => l_progress);
        RAISE;

END get_ap_compatibility_flag;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_contractor_status
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves the Contractor Status for the given Requisition Line.
--Parameters:
--IN:
--p_req_line_id
--  Unique ID of the Requisition Line
--Returns:
--  VARCHAR2 - Contractor Status of the given Req Line
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION get_contractor_status ( p_req_line_id IN NUMBER )
  RETURN VARCHAR2
IS
    l_contractor_status       PO_REQUISITION_LINES_ALL.contractor_status%TYPE;
BEGIN

    SELECT  contractor_status
    INTO    l_contractor_status
    FROM    po_requisition_lines_all
    WHERE   requisition_line_id = p_req_line_id;

    return (l_contractor_status);

EXCEPTION

    WHEN OTHERS THEN
        return (NULL);

END get_contractor_status;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_expense_line
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves information on the Expense Line corresponding to the input
--  Parent Temp Labor Requisition Line. If no Expense Line exists for the
--  particular input Line, then return NULL in the OUT parameters.
--Parameters:
--IN:
--p_parent_line_id - Unique Requisition Line ID of the Temp Labor Parent Line
--OUT:
--x_expense_line_id - Unique Requisition Line ID of the associated Expense Line
--x_expense_line_num - Requisition Line Num of the associated Expense Line
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE get_expense_line
(   p_parent_line_id     IN           NUMBER
,   x_expense_line_id    OUT NOCOPY   NUMBER
,   x_expense_line_num   OUT NOCOPY   NUMBER
)
IS BEGIN

    SELECT   requisition_line_id
    ,        line_num
    INTO     x_expense_line_id
    ,        x_expense_line_num
    FROM     po_requisition_lines_all
    WHERE    labor_req_line_id = p_parent_line_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_expense_line_id := NULL;
        x_expense_line_num := NULL;

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error ( 'PO_SERVICES_PVT.GET_EXPENSE_LINE', '000', SQLCODE );
        RAISE;

END get_expense_line;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_job_long_description
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves the Job Long Description for the given Req Line ID
--  Returns NULL if the Requisition Line does not exist.
--Parameters:
--IN:
--p_req_line_id
--  Unique ID of the Requisition Line
--Returns:
--  VARCHAR2 - Job Long Description
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION get_job_long_description
(
    p_req_line_id IN NUMBER
)
RETURN VARCHAR2
IS
    l_job_long_description  PO_REQUISITION_LINES_ALL.job_long_description%TYPE;

BEGIN

    SELECT job_long_description
    INTO   l_job_long_description
    FROM   po_requisition_lines_all
    WHERE  requisition_line_id = p_req_line_id;

    return (l_job_long_description);

EXCEPTION

    WHEN OTHERS THEN
        return (NULL);

END get_job_long_description;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_job_name
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves the Job Name for the given Job ID.
--  Returns NULL if the input Job ID is NULL.
--  Throws error if input Job ID is not NULL but does not exist in PER_JOBS.
--Parameters:
--IN:
--p_job_id
--  Unique ID of the Job
--Returns:
--  VARCHAR2 - Job Name
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION get_job_name ( p_job_id  IN  NUMBER )
  RETURN VARCHAR2
IS
    l_job_name      PER_JOBS_VL.name%TYPE;
BEGIN

    IF ( p_job_id IS NULL )
    THEN
        return (NULL);
    END IF;

    SELECT   name
    INTO     l_job_name
    FROM     per_jobs_vl
    WHERE    job_id = p_job_id;

    return (l_job_name);

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error( 'PO_SERVICES_PVT.GET_JOB_NAME','000',SQLCODE );
        RAISE;

END get_job_name;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_labor_req_line
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves information on the Parent Temp Labor Line corresponding to the
--  input Expense Requisition Line. If the input line is not an Expense line,
--  returns NULL for the OUT parameters.
--Parameters:
--IN:
--p_expense_line_id - Unique Requisition Line ID of the Expense Line
--OUT:
--x_parent_line_id - Unique Requisition Line ID of the Parent Temp Labor Line
--x_parent_line_num - Requisition Line Num of the Parent Temp Labor Line
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE get_labor_req_line
(   p_expense_line_id    IN          NUMBER
,   x_parent_line_id     OUT NOCOPY  NUMBER
,   x_parent_line_num    OUT NOCOPY  NUMBER
)
IS BEGIN

    SELECT   PRL2.requisition_line_id
    ,        PRL2.line_num
    INTO     x_parent_line_id
    ,        x_parent_line_num
    FROM     po_requisition_lines_all PRL1                      -- Expense Line
    ,        po_requisition_lines_all PRL2                      -- Parent Line
    WHERE    p_expense_line_id = PRL1.requisition_line_id
    AND      PRL1.labor_req_line_id = PRL2.requisition_line_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_parent_line_id := NULL;
        x_parent_line_num := NULL;

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error ( 'PO_SERVICES_PVT.GET_LABOR_REQ_LINE', '000', SQLCODE );
        RAISE;

END get_labor_req_line;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: is_expense_line
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines if a Requisition line is an Expense line
--  (i.e. is associated with a parent Temp Labor line).
--Parameters:
--IN:
--p_req_line_id
--  Unique ID of the Requisition Line
--Returns:
--  TRUE if the Requisition line is an Expense line. FALSE otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION is_expense_line
(
    p_req_line_id IN NUMBER
)
RETURN BOOLEAN
IS
    l_labor_req_line_id     PO_REQUISITION_LINES_ALL.labor_req_line_id%TYPE;

BEGIN

    SELECT labor_req_line_id
    INTO   l_labor_req_line_id
    FROM   po_requisition_lines_all
    WHERE  requisition_line_id = p_req_line_id;

    IF ( l_labor_req_line_id IS NOT NULL )
    THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        return (FALSE);

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error ( 'PO_SERVICES_PVT.is_expense_line', '000', SQLCODE );
        RAISE;

END is_expense_line;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: is_rate_based_line
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines if a po line is rate based line
--Parameters:
--IN:
--p_po_line_id
--  Unique ID of the PO Line
--Returns:
--  TRUE if the PO line is an rate based line. FALSE otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION is_rate_based_line
(
    p_po_line_id IN NUMBER
)
RETURN BOOLEAN
IS
    l_value_basis     PO_LINES_ALL.order_type_lookup_code%TYPE;

BEGIN

    IF p_po_line_id is null THEN
      return (FALSE);
    END IF;

    SELECT order_type_lookup_code
    INTO   l_value_basis
    FROM   po_lines_all
    WHERE  po_line_id = p_po_line_id;

    IF (  l_value_basis = 'RATE' )
    THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        return (FALSE);

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error ( 'PO_SERVICES_PVT.is_rate_based_line', '000', SQLCODE );
        RAISE;

END is_rate_based_line;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: validate_ship_to_org
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Validates the ship-to organization with respect to the specified job. The
--  ship-to organization must roll up to the same business group as the job on
--  the PO line for temp labor line types.
--Parameters:
--IN:
--p_job_id
--  The job ID of the PO line
--p_ship_to_org_id
--  The ship-to organization ID of the PO shipment
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_is_valid
--  TRUE if p_ship_to_org_id rolls up to the same business group as p_job_id, or
--    if p_job_id is NULL.
--  FALSE otherwise.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE validate_ship_to_org
(
    x_return_status  OUT NOCOPY VARCHAR2,
    p_job_id         IN  NUMBER,
    p_ship_to_org_id IN  NUMBER,
    x_is_valid       OUT NOCOPY BOOLEAN
)
IS

l_progress   VARCHAR2(3);
l_valid_flag VARCHAR2(1);

BEGIN
    l_progress := '000';
    x_return_status := FND_API.g_ret_sts_success;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
           (p_log_head => g_module_prefix||'validate_ship_to_org',
            p_token    => 'invoked',
            p_message  => 'job ID: '||p_job_id||' ship-to org ID: '||
                          p_ship_to_org_id);
    END IF;

    IF (p_job_id IS NOT NULL) THEN
        l_progress := '010';

        --SQL What: Check that ship-to org and job are in same business group
        --SQL Why: Ensure ship-to orgs of temp labor lines are valid
        SELECT 'Y'
          INTO l_valid_flag
          FROM per_jobs pj,
               hr_all_organization_units haou,
               mtl_parameters mp
         WHERE pj.job_id = p_job_id
           AND mp.organization_id = p_ship_to_org_id
           AND mp.organization_id = haou.organization_id
           AND haou.business_group_id = pj.business_group_id;

    END IF;

    x_is_valid := TRUE;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_var
            (p_log_head => g_module_prefix||'validate_ship_to_org',
             p_progress => l_progress,
             p_name     => 'x_is_valid',
             p_value    => x_is_valid);
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- x_return_status is still success here because this is not an error
        x_is_valid := FALSE;
        IF g_debug_stmt THEN
            PO_DEBUG.debug_var
                (p_log_head => g_module_prefix||'validate_ship_to_org',
                 p_progress => l_progress,
                 p_name     => 'x_is_valid',
                 p_value    => x_is_valid);
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
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

-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_po_amounts
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves total amount billed and received from all shipments for a
--  given line
--Parameters:
--IN:
--p_po_line_id - Unique PO Line ID
--OUT:
--x_amount_received - total amount received
--x_amount_billed - total amount billed
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE get_po_amounts
(   p_po_line_id       IN          NUMBER
,   x_amount_received  OUT NOCOPY  NUMBER
,   x_amount_billed    OUT NOCOPY  NUMBER
)
IS
BEGIN

    SELECT   sum(nvl(amount_received,0)),
             sum(nvl(amount_billed,0))
    INTO     x_amount_received,
             x_amount_billed
    FROM     po_line_locations_all
    WHERE    po_line_id = p_po_line_id
    AND      shipment_type = 'STANDARD';

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_amount_received := 0;
        x_amount_billed   := 0;

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error ( 'PO_SERVICES_PVT.GET_PO_AMOUNTS', '000', SQLCODE );
        RAISE;

END get_po_amounts;

-- Bug# 3465756: Added the following two new functions
-------------------------------------------------------------------------------
--Start of Comments
--Name: check_po_has_svc_line_with_req
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Check if a given PO contains at least one Services line, i.e. if the value
--  basis of any line is any of the following:
--           1. FIXED PRICE
--           2. RATE
--  Also checks if the services line has a backing requisition or not.
--Parameters:
--IN:
--p_po_header_id - Unique PO Header ID
--OUT:
--   None
--RETURN:
-- BOOLEAN - TRUE, if the PO has at least one Services Line with a backing req,
--           FALSE, otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION check_po_has_svc_line_with_req
(
  p_po_header_id IN NUMBER
) RETURN BOOLEAN
IS
  l_count_services_lines NUMBER;
BEGIN
  IF p_po_header_id is null THEN
    RETURN FALSE;
  END IF;

  l_count_services_lines := 0;

  SELECT count(*)
  INTO   l_count_services_lines
  FROM   po_lines_all POL,
         po_distributions_all POD
  WHERE  POL.po_header_id = p_po_header_id
    AND  POL.order_type_lookup_code IN ('FIXED PRICE', 'RATE')
    AND  POD.po_line_id = POL.po_line_id      -- Join between PO Lines and Distributions
    AND  POD.req_distribution_id IS NOT NULL; -- There exists a backing Req

  IF (l_count_services_lines > 0) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
  WHEN OTHERS THEN
    PO_MESSAGE_S.sql_error('PO_SERVICES_PVT.check_po_has_svc_line_with_req', '000', SQLCODE);
    RAISE;
END check_po_has_svc_line_with_req;

-------------------------------------------------------------------------------
--Start of Comments
--Name: is_FPS_po_line_with_req
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Checks if the given PO line is a Fixed Price Services line with a backing
--  requisition.
--Parameters:
--IN:
--p_po_line_id - Unique PO Line ID
--OUT:
--   None
--RETURN:
-- BOOLEAN - TRUE, if the PO line type is Fixed Price Services and has a backing req
--           FALSE, otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_FPS_po_line_with_req
(
   p_po_line_id IN NUMBER
) RETURN BOOLEAN
IS
  l_count NUMBER;
BEGIN
  IF p_po_line_id is null THEN
    RETURN FALSE;
  END IF;

  l_count := 0;

  SELECT count(*)
  INTO   l_count
  FROM   po_lines_all POL,
         po_distributions_all POD
  WHERE  POL.po_line_id = p_po_line_id
    AND  POL.order_type_lookup_code = 'FIXED PRICE'
    AND  POL.purchase_basis = 'SERVICES'
    AND  POD.po_line_id = POL.po_line_id
    AND  POD.req_distribution_id IS NOT NULL; -- There exists a backing Req.

  IF (l_count > 0) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
  WHEN OTHERS THEN
    PO_MESSAGE_S.sql_error('PO_SERVICES_PVT.is_FPS_po_line_with_req', '000', SQLCODE);
    RAISE;
END is_FPS_po_line_with_req;

-------------------------------------------------------------------------------
--Start of Comments
--Name: is_FPS_po_shipment_with_req
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Checks if the line type of a given PO Shipment is Fixed Price Services and
--  a backing requisition exists for the given PO Shipment.
--Parameters:
--IN:
--p_po_line_location_id - Unique PO Line Location ID
--OUT:
--   None
--RETURN:
-- BOOLEAN - TRUE, if the PO line type for the given Shipment is Fixed Price
--                 Services and has a backing requisition,
--           FALSE, otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_FPS_po_shipment_with_req
(
   p_po_line_location_id IN NUMBER
) RETURN BOOLEAN
IS
  l_count NUMBER;
BEGIN
  IF p_po_line_location_id is null THEN
    RETURN FALSE;
  END IF;

  l_count := 0;

  SELECT count(*)
  INTO   l_count
  FROM   po_line_locations_all POLL,
         po_lines_all POL,
         po_distributions_all POD
  WHERE  POLL.line_location_id = p_po_line_location_id
    AND  POL.po_line_id = POLL.po_line_id
    AND  POL.order_type_lookup_code = 'FIXED PRICE'
    AND  POL.purchase_basis = 'SERVICES'
    AND  POD.line_location_id = POLL.line_location_id
    AND  POD.req_distribution_id IS NOT NULL; -- There exists a backing Req.

  IF (l_count > 0) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
  WHEN OTHERS THEN
    PO_MESSAGE_S.sql_error('PO_SERVICES_PVT.is_FPS_po_shipment_with_req', '000', SQLCODE);
    RAISE;
END is_FPS_po_shipment_with_req;
-- Bug# 3465756: End

END PO_SERVICES_PVT;

/
