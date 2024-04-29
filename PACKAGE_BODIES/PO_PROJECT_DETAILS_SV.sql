--------------------------------------------------------
--  DDL for Package Body PO_PROJECT_DETAILS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PROJECT_DETAILS_SV" AS
/* $Header: POXPROJB.pls 120.1.12010000.2 2009/07/03 08:18:40 ggandhi ship $ */

--< Bug 3265539 Start >
-- Debugging booleans used to bypass logging when turned off
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_PROJECT_DETAILS_SV';
g_module_prefix CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';

---------------------------------------------------------------------------
--Start of Comments
--Name: get_project_task_num
--Pre-reqs:
--  None.
--Modifies:
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Gets the project number and task number given their ID's. Appends to the API
--  message list upon error.
--Parameters:
--IN:
--p_project_id
--p_task_id
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_project_num
--  The project number. If not found, this will be NULL.
--x_task_num
--  The task number. If not found, this will be NULL.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_project_task_num
(
    x_return_status OUT NOCOPY NUMBER,
    p_project_id    IN NUMBER,
    p_task_id       IN NUMBER,
    x_project_num   OUT NOCOPY VARCHAR2,
    x_task_num      OUT NOCOPY VARCHAR2
)
IS

l_progress VARCHAR2(3) := '000';
l_return_status VARCHAR2(1);

BEGIN
    IF (p_project_id IS NOT NULL) THEN

        l_progress := '010';
        all_proj_idtonum_wpr(x_return_status  => l_return_status,
                             p_project_id     => p_project_id,
                             x_project_number => x_project_num);

        IF (l_return_status <> FND_API.g_ret_sts_success) THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF;

        IF (p_task_id IS NOT NULL) THEN
            l_progress := '020';
            BEGIN
                SELECT task_number
                  INTO x_task_num
                  FROM pa_tasks
                 WHERE task_id = p_task_id
                   AND project_id = p_project_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;
            END;
        END IF;  --< if task id not null >

    END IF;  --< if project id not null >

EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
                (p_log_head => g_module_prefix||'get_project_task_num',
                 p_progress => l_progress);
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'get_project_task_num',
                                p_error_text     => 'Progress: '||l_progress||
                                           ' Error: '||SUBSTRB(SQLERRM,1,215));
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
                (p_log_head => g_module_prefix||'get_project_task_num',
                 p_progress => l_progress);
        END IF;
END get_project_task_num ;
--< Bug 3265539 End >


procedure get_project_details(
		p_receipt_source_code in varchar2,
		p_po_distribution_id  in number,
		p_req_distribution_id in number,
	    p_oe_order_line_id    in number,
		p_project_id in out NOCOPY number,
		p_task_id    in out NOCOPY number,
		p_project_num in out NOCOPY varchar2,
		p_task_num   in out NOCOPY varchar2
) IS

x_progress varchar2(3) := '000' ;
l_return_status VARCHAR2(1);       --< Bug 3265539 >

BEGIN


      IF (p_receipt_source_code <> 'CUSTOMER') THEN

          IF (p_po_distribution_id IS NOT NULL ) THEN

             x_progress := '010';

             SELECT project_id, task_id
             INTO   p_project_id, p_task_id
             FROM   po_distributions
             WHERE  po_distribution_id = p_po_distribution_id;

          ELSIF (p_req_distribution_id IS NOT NULL) THEN

             x_progress := '020';

             SELECT project_id, task_id
             INTO   p_project_id, p_task_id
             FROM   po_req_distributions
             WHERE  distribution_id = p_req_distribution_id;

          END IF;

       ELSE

            IF (p_oe_order_line_id IS NOT NULL ) THEN

             x_progress := '030';
/* Bug 8623668 Changing the view oe_order_lines to oe_order_lines_all as this fix is needed for an receiving bug
 8429238*/
             SELECT project_id, task_id
             INTO   p_project_id,p_task_id
             FROM   oe_order_lines_all
             WHERE  line_id = p_oe_order_line_id;

            END IF;

        END IF;

	    IF p_project_id is not null  THEN

-- Bug#1965131.Commented the following.

/**
                   AND
			p_task_id is not null) THEN
**/

            x_progress := '040';

            --< Bug 3265539 Start > Changed signature
            get_project_task_num(x_return_status => l_return_status,
                                 p_project_id    => p_project_id,
                                 p_task_id       => p_task_id,
                                 x_project_num   => p_project_num,
                                 x_task_num      => p_task_num);

            IF (l_return_status <> FND_API.g_ret_sts_success) THEN
                RAISE APP_EXCEPTION.application_exception;
            END IF;
            --< Bug 3265539 End >

		END IF ;

EXCEPTION

	WHEN OTHERS THEN
		po_message_s.sql_error('get_project_details',x_progress,sqlcode);
		raise ;

END get_project_details ;

--< Bug 3265539 Start >
---------------------------------------------------------------------------
--Start of Comments
--Name: all_proj_idtonum_wpr
--Pre-reqs:
--  None.
--Modifies:
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  This is a wrapper gets the project number of the given project ID using the
--  PJM function PJM_PROJECT.all_proj_idtonum. Appends to the API message list
--  upon error.
--Parameters:
--IN:
--p_project_id
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_project_number
--  The project number. If not found, this will be NULL.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE all_proj_idtonum_wpr
(
    x_return_status  OUT NOCOPY VARCHAR2,
    p_project_id     IN NUMBER,
    x_project_number OUT NOCOPY VARCHAR2
)
IS
BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    x_project_number := PJM_PROJECT.all_proj_idtonum
                            (x_project_id => p_project_id);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_project_number := NULL;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'all_proj_idtonum_wpr');
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_module_prefix||'all_proj_idtonum_wpr',
                p_progress => '000');
        END IF;
END all_proj_idtonum_wpr;

---------------------------------------------------------------------------
--Start of Comments
--Name: validate_proj_references_wpr
--Pre-reqs:
--  None.
--Modifies:
--  FND_MESSAGE
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  This is a wrapper that validates the project by calling the PJM API
--  PJM_PROJECT.validate_proj_references. The parameter p_operating_unit gets
--  defaulted if it is NULL. Appends to the API message list upon error.
--Parameters:
--IN:
--p_inventory_org_id
--  Typically the destination inventory org ID of the Req line, or the ship-to
--  org ID of the PO shipment.
--p_operating_unit
--  The operating unit to validate in. For standard behavior, this should be the
--  operating unit associated with p_inventory_org_id.  If this param is NULL,
--  then it is defaulted according to the standard.
--p_project_id
--p_task_id
--p_date1
--  Typically the need by date of the Req line/PO shipment. This is passed into
--  the PJM API truncated.
--p_date2
--  Typically the promised date of the PO shipment, and NULL for a Req line.
--  This is passed into the PJM API truncated.
--p_calling_function
--  Used for any custom validations in PJM_PROJECT_EXT.val_project_references.
--  Typically, this is a module name like 'POXPOEPO' or 'PDOI'.
--OUT:
--x_error_code
--  Error code returned by PJM API.
--x_return_code
--  Return code of the PJM API function call.  Valid values are:
--      PO_PROJECT_DETAILS_SV.pjm_validate_success
--      PO_PROJECT_DETAILS_SV.pjm_validate_warning
--      PO_PROJECT_DETAILS_SV.pjm_validate_failure
--Notes:
--  This is a simple wrapper for the PJM API that should be used for all calls
--  within PO to provide visibility and flexibility.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_proj_references_wpr
(
    p_inventory_org_id  IN NUMBER,
    p_operating_unit    IN NUMBER,
    p_project_id        IN NUMBER,
    p_task_id           IN NUMBER,
    p_date1             IN DATE,
    p_date2             IN DATE,
    p_calling_function  IN VARCHAR2,
    x_error_code        OUT NOCOPY VARCHAR2,
    x_return_code       OUT NOCOPY VARCHAR2
)
IS

l_progress VARCHAR2(3);
l_return_status VARCHAR2(1);
l_pjm_org_id FINANCIALS_SYSTEM_PARAMS_ALL.org_id%TYPE;

BEGIN
    l_progress := '000';

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
            (p_log_head => g_module_prefix||'validate_proj_references_wpr',
             p_token    => 'BEGIN',
             p_message  => 'inv org ID: '||p_inventory_org_id||' ou ID: '||
                p_operating_unit||' project ID: '||p_project_id||' task ID: '||
                p_task_id||' date1: '||TO_CHAR(p_date1,'DD-MON-RRRR HH24:MI:SS')
                ||' date2: '||TO_CHAR(p_date2,'DD-MON-RRRR HH24:MI:SS')||
                ' calling function: '||p_calling_function);
    END IF;

    IF (p_operating_unit IS NULL) THEN
        l_progress := '010';

        -- Default the operating unit if not passed in
        PO_CORE_S.get_inv_org_ou_id(x_return_status => l_return_status,
                                    p_inv_org_id    => p_inventory_org_id,
                                    x_ou_id         => l_pjm_org_id);

        IF (l_return_status <> FND_API.g_ret_sts_success) THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF;
    ELSE
        l_pjm_org_id := p_operating_unit;
    END IF;

    l_progress := '020';

    --< NBD TZ/Timestamp FPJ >
    -- Truncate the timestamped dates. Inside the API they would be used in a
    -- comparison with effectivity dates that are not timestamped.
    x_return_code :=
        PJM_PROJECT.validate_proj_references
           (x_inventory_org_id => p_inventory_org_id,
            x_operating_unit   => l_pjm_org_id,
            x_project_id       => p_project_id,
            x_task_id          => p_task_id,
            x_date1            => TRUNC(p_date1),
            x_date2            => TRUNC(p_date2),
            x_calling_function => p_calling_function,
            x_error_code       => x_error_code);

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
            (p_log_head => g_module_prefix||'validate_proj_references_wpr',
             p_token    => 'END',
             p_message  => 'return code: '||x_return_code||' error code: '||
                           x_error_code);
    END IF;
EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_code := pjm_validate_failure;
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
                (p_log_head => g_module_prefix||'validate_proj_references_wpr',
                 p_progress => l_progress);
        END IF;
    WHEN OTHERS THEN
        x_return_code := pjm_validate_failure;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'validate_proj_references_wpr',
                                p_error_text     => 'Progress: '||l_progress||
                                           ' Error: '||SUBSTRB(SQLERRM,1,215));
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_module_prefix||'validate_proj_references_wpr',
                p_progress => l_progress);
        END IF;
END validate_proj_references_wpr;

--------------------------------------------------------------------------------
--Start of Comments
--Name: pjm_validate_success
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the global package variable PJM_PROJECT.g_validate_success.
--Returns:
--  PJM_PROJECT.g_validate_success
--End of Comments
--------------------------------------------------------------------------------
FUNCTION pjm_validate_success RETURN VARCHAR2
IS
BEGIN
    RETURN PJM_PROJECT.g_validate_success;
END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: pjm_validate_warning
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the global package variable PJM_PROJECT.g_validate_warning.
--Returns:
--  PJM_PROJECT.g_validate_warning
--End of Comments
--------------------------------------------------------------------------------
FUNCTION pjm_validate_warning RETURN VARCHAR2
IS
BEGIN
    RETURN PJM_PROJECT.g_validate_warning;
END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: pjm_validate_failure
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the global package variable PJM_PROJECT.g_validate_failure.
--Returns:
--  PJM_PROJECT.g_validate_failure
--End of Comments
--------------------------------------------------------------------------------
FUNCTION pjm_validate_failure RETURN VARCHAR2
IS
BEGIN
    RETURN PJM_PROJECT.g_validate_failure;
END;

--< Bug 3265539 End >

--< Bug 4338241 Start >
--Adding these 2 functions for Unit Number
FUNCTION pjm_unit_eff_enabled RETURN VARCHAR2
IS
BEGIN
  RETURN PJM_UNIT_EFF.ENABLED;
END;

FUNCTION pjm_unit_eff_item
(
    p_item_id IN NUMBER,
    p_org_id  IN NUMBER
) RETURN VARCHAR2
IS
BEGIN
  RETURN PJM_UNIT_EFF.UNIT_EFFECTIVE_ITEM(p_item_id, p_org_id);
END;
--< Bug 4338241 END >

END PO_PROJECT_DETAILS_SV ;

/
