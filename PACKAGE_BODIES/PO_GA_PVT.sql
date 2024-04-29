--------------------------------------------------------
--  DDL for Package Body PO_GA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_GA_PVT" AS
/* $Header: POXVGAB.pls 120.0.12010000.2 2011/08/05 08:40:07 inagdeo ship $ */

--<Bug 2721740 mbhargav>
G_PKG_NAME CONSTANT varchar2(30) := 'PO_GA_PVT';

--< Shared Proc FPJ Start >
-- Debugging booleans used to bypass logging when turned off
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

g_module_prefix CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';
--< Shared Proc FPJ End >


/*=============================================================================

    FUNCTION:       get_org_id

    DESCRIPTION:    Gets the owning org_id for the particular po_header_id.

=============================================================================*/
FUNCTION get_org_id
(
    p_po_header_id	  	PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN PO_HEADERS_ALL.org_id%TYPE
IS
    x_org_id	PO_HEADERS_ALL.org_id%TYPE;

BEGIN

    SELECT	org_id
    INTO 	x_org_id
    FROM	po_headers_all
    WHERE	po_header_id = p_po_header_id;

    return (x_org_id);

EXCEPTION

    WHEN OTHERS THEN
    	return (NULL);

END get_org_id;


/*=============================================================================

    FUNCTION:        get_current_org

    DESCRIPTION:     Gets the org_id for the current session.

=============================================================================*/
FUNCTION get_current_org
RETURN PO_SYSTEM_PARAMETERS.org_id%TYPE
IS
    x_org_id 	PO_SYSTEM_PARAMETERS.org_id%TYPE;
BEGIN

    SELECT	org_id
    INTO    x_org_id
    FROM	po_system_parameters;

    return (x_org_id);

EXCEPTION
    WHEN OTHERS THEN
	   return (NULL);

END get_current_org;


/*=============================================================================

    FUNCTION:        is_owning_org

    DESCRIPTION:     Returns TRUE if the current org is the owning org of the
                     po_header_id and the document is a Global Agreement.
                     FALSE otherwise.

=============================================================================*/
FUNCTION is_owning_org
(
    p_po_header_id           IN    PO_HEADERS.po_header_id%TYPE
)
RETURN BOOLEAN
IS
    l_global_agreement_flag        PO_HEADERS.global_agreement_flag%TYPE;
BEGIN

    SELECT    global_agreement_flag
    INTO      l_global_agreement_flag       -- all documents held in PO_HEADERS
    FROM      po_headers                    -- are "owned" by the current org
    WHERE     po_header_id = p_po_header_id;

    IF ( l_global_agreement_flag = 'Y' ) THEN-- document must also be a GA
        return (TRUE);                       -- for it to have an "owning org"
    ELSE
        return (FALSE);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        return (FALSE);

END is_owning_org;

--< Shared Proc FPJ Start >
-- Modified signature, and fixed implementation to use _TL table
--------------------------------------------------------------------------------
--Start of Comments
--Name: get_org_name
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Gets the translated name of the operating unit p_org_id.
--Parameters:
--IN:
--p_org_id
--  The operating unit ID
--Returns:
--  The translated operating unit name of p_org_id.  If an exception occurs,
--  then returns NULL.
--Testing:
--End of Comments
--------------------------------------------------------------------------------
FUNCTION get_org_name(p_org_id IN NUMBER) RETURN VARCHAR2
IS
    l_name HR_ALL_ORGANIZATION_UNITS_TL.name%TYPE;
BEGIN

    SELECT  name
    INTO    l_name
    FROM    hr_all_organization_units_tl
    WHERE   organization_id = p_org_id
    AND     language = USERENV('LANG');

    return (l_name);

EXCEPTION

    WHEN OTHERS THEN
	    return (NULL);

END get_org_name;
--< Shared Proc FPJ End >

/*=============================================================================

	FUNCTION:      is_global_agreement

	DESCRIPTION:   Returns TRUE if the po_header_id is a Global Agreement.
                   FALSE otherwise.

=============================================================================*/
FUNCTION is_global_agreement
(
    p_po_header_id	  	PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN BOOLEAN
IS
    l_global_agreement_flag	      PO_HEADERS_ALL.global_agreement_flag%TYPE;

BEGIN
    SELECT	global_agreement_flag
    INTO	l_global_agreement_flag
    FROM	po_headers_all
    WHERE	po_header_id = p_po_header_id;

    IF (l_global_agreement_flag = 'Y') THEN
	    return (TRUE);
    ELSE
	    return (FALSE);
    END IF;

EXCEPTION

    WHEN OTHERS THEN
	return (FALSE);

END is_global_agreement;


--=============================================================================
-- Function    : is_enabled
-- Type        : Private
--
-- Pre-reqs    : p_po_header_id must refer to a Global Agreement.
-- Modifies    : -
-- Description : Determines if the current OU is an enabled Requesting Org for
--               the input GA doc.
--
-- Parameters  : p_po_header_id - document ID for the Global Agreement
--
-- Returns     : TRUE if current OU is an enabled Requesting Org for the GA.
--               FALSE otherwise.
-- Exceptions  : -
-- Notes       : Functionality changed due to new column purchasing_org_id added
--               in Shared Proc FPJ.
--=============================================================================
FUNCTION is_enabled ( p_po_header_id   IN  PO_HEADERS_ALL.po_header_id%TYPE )
RETURN BOOLEAN
IS
    l_enabled_flag    PO_GA_ORG_ASSIGNMENTS.enabled_flag%TYPE;

BEGIN

    --SQL Gets the 'enabled_flag' to determine if
    --SQL the current OU is enabled for the given
    --SQL Global Agreement.
    --
    SELECT    pgoa.enabled_flag
    INTO      l_enabled_flag
    FROM      po_ga_org_assignments    pgoa,
              po_system_parameters     psp
    WHERE     pgoa.po_header_id = p_po_header_id   -- input GA ID
    AND       pgoa.organization_id = psp.org_id;   -- current OU

    IF ( l_enabled_flag = 'Y' ) THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

EXCEPTION

    WHEN OTHERS THEN
        return (FALSE);

END is_enabled;


/*=============================================================================

    FUNCTION:       enabled_orgs_exist

    DESCRIPTION:    Returns TRUE if enabled orgs (other than the Owning OU) for
                    the particular 'po_header_id' exist, and FALSE otherwise.

=============================================================================*/
FUNCTION enabled_orgs_exist
(
    p_po_header_id		IN	PO_HEADERS_ALL.po_header_id%TYPE ,
    p_owning_org_id		IN	PO_HEADERS_ALL.org_id%TYPE
)
RETURN BOOLEAN
IS
 	l_enabled_orgs_exist	VARCHAR2(1) := 'N';
BEGIN

    SELECT 	'Y'
    INTO	l_enabled_orgs_exist
    FROM	po_ga_org_assignments
    WHERE	po_header_id = p_po_header_id      -- for the current GA
    AND		organization_id <> p_owning_org_id -- for OUs besides Owning OU
    AND 	enabled_flag = 'Y'                 -- that are enabled
    HAVING	count(*) > 0;

    IF ( l_enabled_orgs_exist = 'Y' ) THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        return (FALSE);                         -- no rows exist

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('enabled_orgs_exist','000',sqlcode);
        RAISE;

END enabled_orgs_exist;


--=============================================================================
-- Function    : is_referenced
-- Type        : Private
--
-- Pre-reqs    : p_po_line_id must refer to a Global Agreement line ID.
-- Modifies    : -
--
-- Description : Determines if any Standard POs (in any status) reference
--               the GA line.
--
-- Parameters  : p_po_line_id - line ID for the Global Agreement
--
-- Returns     : TRUE  - if Standard POs exist which reference this line
--               FALSE - otherwise
--
-- Exceptions  : -
--=============================================================================
FUNCTION is_referenced
(
    p_po_line_id             IN      PO_LINES_ALL.from_line_id%TYPE
)
RETURN BOOLEAN
IS
    l_count                  NUMBER;

BEGIN

    SELECT    count('Standard POs referencing GA line')
    INTO      l_count
    FROM      po_lines_all
    WHERE     from_line_id = p_po_line_id;

    IF ( l_count > 0 ) THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        return (FALSE);

END is_referenced;


--< Shared Proc FPJ Start >
-- Modified signature, and fixed implementation to use _TL table
/*=============================================================================

    PROCEDURE:	    get_ga_values

    DESCRIPTION:    Based on po_header_id, fetches the global_agreement_flag,
                    owning_org_id, owning_org_name. If po_header_id is not a
                    Global Agreement, returns 'N' for global_agreement_flag and
                    NULL's for owning_org_id and owning_org_name.

=============================================================================*/
PROCEDURE get_ga_values
(
    p_po_header_id           IN  NUMBER,
    x_global_agreement_flag  OUT NOCOPY VARCHAR2,
    x_owning_org_id          OUT NOCOPY NUMBER,
    x_owning_org_name        OUT NOCOPY VARCHAR2
)
IS
    l_global_agreement_flag          PO_HEADERS_ALL.global_agreement_flag%TYPE;

BEGIN
    SELECT    nvl(poh.global_agreement_flag, 'N'),
              decode(poh.global_agreement_flag,         -- only return values
                     'Y', poh.org_id,                   -- if Global Agreement.
                     NULL ),                            -- else, return NULL
              decode(poh.global_agreement_flag,
                     'Y', hrou.name,
                     NULL )
    INTO      x_global_agreement_flag,
              x_owning_org_id,
              x_owning_org_name
    FROM      po_headers_all                poh,
              hr_all_organization_units_tl  hrou
    WHERE     poh.po_header_id = p_po_header_id
    AND       hrou.organization_id = poh.org_id
    AND       hrou.language = USERENV('LANG');

EXCEPTION

    WHEN OTHERS THEN
        po_message_s.sql_error('PO_GA_PVT.get_ga_values', '000', sqlcode);

END get_ga_values;
--< Shared Proc FPJ End >

--=============================================================================
-- Function    : is_expired
-- Type        : Private
--
-- Pre-reqs    : p_po_header_id/p_po_line_id must refer to Global Agreement
-- Modifies    : -
--
-- Description : Determines if the Global Agreement/line are expired.
--
-- Parameters  : p_po_header_id - document ID for the Global Agreement
--               p_po_line_id   - line ID for Global Agreement
--
-- Returns     : TRUE  - if Global Agreement is expired
--               FALSE - otherwise
--
-- Exceptions  : -
--=============================================================================
FUNCTION is_expired
(
    p_po_line_id         IN    PO_LINES_ALL.po_line_id%TYPE
)
RETURN BOOLEAN
IS
    l_header_end_date        PO_HEADERS_ALL.end_date%TYPE;
    l_line_expiration_date   PO_LINES_ALL.expiration_date%TYPE;

BEGIN

    --SQL Get the end_date for the header
    --SQL and the expiration_date for the line
    --
    SELECT    poh.end_date,
              pol.expiration_date
    INTO      l_header_end_date,
              l_line_expiration_date
    FROM      po_headers_all         poh,
              po_lines_all           pol
    WHERE     poh.po_header_id = pol.po_header_id        -- JOIN
    AND       pol.po_line_id = p_po_line_id;

    -- Both the header end_date and line expiration_date must be in the future
    -- for the GA/line to not be expired
    --
    IF  (   ( trunc(sysdate) <= trunc(nvl(l_header_end_date, sysdate)) )
        AND ( trunc(sysdate) <= trunc(nvl(l_line_expiration_date, sysdate)) ) )
    THEN
        return (FALSE);
    ELSE
        return (TRUE);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        return (TRUE);

END is_expired;


--=============================================================================
-- Function    : is_approved
-- Type        : Private
--
-- Pre-reqs    : p_po_line_id must refer to a Global Agreement line ID.
-- Modifies    : -
--
-- Description : Determines if the Global Agreement is...
--               (a) Approved
--               (b) not Cancelled
--               (c) not On Hold
--               (d) not Finally Closed
--               and if the Global Agreement line is...
--               (a) not Cancelled
--               (b) not On Hold
--               (c) not Finally Closed
--
-- Parameters  : p_po_line_id - line ID for the Global Agreement
--
-- Returns     : TRUE  - if Global Agreement meets above requirements
--               FALSE - otherwise
--
-- Exceptions  : -
--=============================================================================
FUNCTION is_approved
(
    p_po_line_id        IN   PO_LINES_ALL.po_line_id%TYPE
)
RETURN BOOLEAN
IS
    l_count             NUMBER;

BEGIN

    --SQL Count the number of records that meet the requirements
    --SQL listed in the specifications. If the requirements are met
    --SQL for the particular line_id, the count should return 1.
    --SQL Else, count should return 0.
    --
    SELECT    count('Line exists with following conditions.')
    INTO      l_count
    FROM      po_headers_all     poh,
              po_lines_all       pol
    WHERE
              nvl(poh.cancel_flag,   'N')     = 'N'
    AND       nvl(poh.closed_code,   'OPEN') <> 'FINALLY CLOSED'
    AND       nvl(poh.approved_flag, 'N')     = 'Y'
    AND       nvl(poh.user_hold_flag,'N')     = 'N'

    AND       nvl(pol.cancel_flag,   'N')     = 'N'
    AND       nvl(pol.closed_code,   'OPEN') <> 'FINALLY CLOSED'
    AND       nvl(pol.user_hold_flag,'N')     = 'N'

    AND       poh.po_header_id = pol.po_header_id        -- JOIN
    AND       pol.po_line_id = p_po_line_id;

    -- Exactly 1 row should be retrieved if requirements are met.
    --
    IF ( l_count = 1 ) THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

EXCEPTION

    WHEN OTHERS THEN
        return (FALSE);

END is_approved;


--=============================================================================
-- Function    : is_ga_valid
-- Type        : Private
--
-- Pre-reqs    : p_po_header_id/p_po_line_id must be a GA document/line ID.
-- Modifies    : -
--
-- Description : Determines if the Global Agreement line is valid...
--               (1) GA/line is not expired
--               (2) GA/line Approved (NOT Cancelled, On Hold, Finally Closed)
--
-- Parameters  : p_po_header_id - document ID for the Global Agreement
--               p_po_line_id   - ID of the Global Agreement line
--
-- Returns     : TRUE  - if Global Agreement line is valid
--               FALSE - otherwise
--
-- Exceptions  : -
-- Notes       : Functionality changed by Shared Proc FPJ. No longer performs
--               enabled org assignment validation.
--=============================================================================
FUNCTION is_ga_valid
(
    p_po_header_id      IN   PO_HEADERS_ALL.po_header_id%TYPE ,
    p_po_line_id        IN   PO_LINES_ALL.po_line_id%TYPE
)
RETURN BOOLEAN
IS
BEGIN

    --< Shared Proc FPJ > Bug 3301427: Removed org assignment check. This
    -- function should not validate against OU's for enabled org assignments.
    IF  (   ( NOT is_expired(p_po_line_id) )
        AND ( is_approved(p_po_line_id) ) )
    THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

EXCEPTION

    WHEN OTHERS THEN
        return (FALSE);

END is_ga_valid;


--=============================================================================
-- Function    : is_date_valid
-- Type        : Private
--
-- Pre-reqs    : p_po_header_id must be a valid document ID.
-- Modifies    : -
--
-- Description : Determines if the input date falls between the document's
--               Start and End dates. If the input date is NULL, it is valid.
--
-- Parameters  : p_po_header_id  - document ID for the GA or Quotation
--               p_date          - date to compare
--
-- Returns     : TRUE  - if p_date falls between document's Start/End dates.
--               FALSE - otherwise.
--
-- Exceptions  : -
--=============================================================================
FUNCTION is_date_valid
(
    p_po_header_id      IN   PO_HEADERS_ALL.po_header_id%TYPE ,
    p_date              IN   DATE
)
RETURN BOOLEAN
IS
    l_start_date        PO_HEADERS_ALL.start_date%TYPE;
    l_end_date          PO_HEADERS_ALL.end_date%TYPE;

BEGIN

    -- If the input date is NULL, then treat as valid.
    --
    IF ( p_date IS NULL ) THEN
        return (TRUE);
    END IF;

    --SQL Get the Start/End dates for the given document.
    --
    SELECT    start_date,
              end_date
    INTO      l_start_date,
              l_end_date
    FROM      po_headers_all
    WHERE     po_header_id = p_po_header_id;

    --< NBD TZ/Timestamp FPJ Start >
    -- The IN parameter p_date would be the need-by-date which is now
    -- timestamped. Whereas the efeectivity dates are not timestamped.
    -- The boundary case of the need-by-date comparision with the End
    -- Effectivity Date would fail if the dates are not truncated. Therefore,
    -- truncating the dates during the comparison.
    --IF ( p_date BETWEEN nvl(l_start_date, p_date-1)
    --                AND nvl(l_end_date, p_date+1) )
    IF ( trunc(p_date) BETWEEN trunc(nvl(l_start_date, p_date-1))
                    AND trunc(nvl(l_end_date, p_date+1)) )
    --< NBD TZ/Timestamp FPJ End >
    THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('is_date_valid','000',sqlcode);
        RAISE;

END is_date_valid;


--< Shared Proc FPJ Start>
-- Rewrote to be a procedure
--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_item
--Pre-reqs:
--  None.
--Modifies:
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Performs item validity checks between p_org_id and p_valid_org_id.  Appends
--  to the API message list upon error.
--Parameters:
--IN:
--p_item_id
--  The item ID to validate
--p_org_id
--  The org ID of the OU to validate against p_valid_org_id
--p_valid_org_id
--  The org ID of the OU where this item is already valid (e.g. GA owning org)
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_is_purchasable
--  TRUE if the item master item in the Financial Options Inventory Organization
--    of p_org_id is defined as 'purchasable', or if this is a one-time item, or
--    p_org_id equals p_valid_org_id.
--  FALSE otherwise.
--x_is_same_uom_class
--  TRUE if the item in p_org_id shares the same UOM class as p_valid_org_id, or
--    if this is a one-time item, or p_org_id equals p_valid_org_id.
--  FALSE otherwise.
--x_is_not_osp_item
--  TRUE if the item is NOT defined as 'Outside Processing' in p_org_id, or if
--    this is a one-time item, or p_org_id equals p-valid_org_id.
--  FALSE otherwise.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_item
(   x_return_status     OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_valid_org_id      IN  NUMBER,
    x_is_purchasable    OUT NOCOPY BOOLEAN,
    x_is_same_uom_class OUT NOCOPY BOOLEAN,
    x_is_not_osp_item   OUT NOCOPY BOOLEAN
)
IS
    l_purchasable_flag          MTL_SYSTEM_ITEMS_B.purchasing_enabled_flag%TYPE;
    l_osp_flag                  MTL_SYSTEM_ITEMS_B.outside_operation_flag%TYPE;
    l_uom_class                 MTL_UNITS_OF_MEASURE_TL.uom_class%TYPE;
    l_valid_uom_class           MTL_UNITS_OF_MEASURE_TL.uom_class%TYPE;
    l_progress                  VARCHAR2(3);

BEGIN
    l_progress := '000';
    x_return_status := FND_API.g_ret_sts_success;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
            (p_log_head => g_module_prefix||'validate_item',
             p_token    => 'invoked',
             p_message  => 'item ID: '||p_item_id||' org ID: '||p_org_id||
                           ' valid org ID: '||p_valid_org_id);
    END IF;

    IF ( p_item_id IS NULL) OR          -- item is a one-time item
       ( p_org_id = p_valid_org_id )    -- or same OU's
    THEN
	    x_is_purchasable := TRUE;
	    x_is_same_uom_class := TRUE;
	    x_is_not_osp_item := TRUE;
    ELSE

        l_progress := '010';

        SELECT
                ITEMS1.purchasing_enabled_flag,
                ITEMS1.outside_operation_flag,
                UOM1.uom_class,
                UOM2.uom_class
        INTO
                l_purchasable_flag,
                l_osp_flag,
                l_uom_class,
                l_valid_uom_class
        FROM
                financials_system_params_all    FSP1,
                financials_system_params_all    FSP2,          -- valid org
                mtl_system_items_b              ITEMS1,
                mtl_system_items_b              ITEMS2,        -- valid org
                mtl_units_of_measure_tl         UOM1,
                mtl_units_of_measure_tl         UOM2           -- valid org
        WHERE
                FSP1.org_id              =      p_org_id
        AND     ITEMS1.inventory_item_id =      p_item_id
        AND     ITEMS1.organization_id   =      FSP1.inventory_organization_id
        AND     UOM1.uom_code            =      ITEMS1.primary_uom_code
        AND     UOM1.language            =      USERENV('LANG')
        AND     FSP2.org_id              =      p_valid_org_id
        AND     ITEMS2.inventory_item_id =      p_item_id
        AND     ITEMS2.organization_id   =      FSP2.inventory_organization_id
        AND     UOM2.uom_code            =      ITEMS2.primary_uom_code
        AND     UOM2.language            =      USERENV('LANG');

        x_is_purchasable := (l_purchasable_flag = 'Y');
        x_is_same_uom_class := (l_uom_class = l_valid_uom_class);
        x_is_not_osp_item := (l_osp_flag = 'N');

    END IF;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_var
           (p_log_head => g_module_prefix||'validate_item',
            p_progress => l_progress,
            p_name     => 'x_is_purchasable',
            p_value    => x_is_purchasable);
        PO_DEBUG.debug_var
           (p_log_head => g_module_prefix||'validate_item',
            p_progress => l_progress,
            p_name     => 'x_is_same_uom_class',
            p_value    => x_is_same_uom_class);
        PO_DEBUG.debug_var
           (p_log_head => g_module_prefix||'validate_item',
            p_progress => l_progress,
            p_name     => 'x_is_not_osp_item',
            p_value    => x_is_not_osp_item);
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_is_purchasable := FALSE;
        x_is_same_uom_class := FALSE;
        x_is_not_osp_item := FALSE;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'validate_item',
                                p_error_text     => 'Progress: '||l_progress||
                                           ' Error: '||SUBSTRB(SQLERRM,1,215));
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_module_prefix||'validate_item',
                p_progress => l_progress);
        END IF;
END validate_item;

/*=============================================================================

    FUNCTION:       is_ship_to_org_valid

    DESCRIPTION:    Returns TRUE if the Ship-To Org specified in the
                    Price Break is in the same Set of Books as the current org.
                    FALSE otherwise.

=============================================================================*/
FUNCTION is_ship_to_org_valid
(
    p_ship_to_org_id	PO_LINE_LOCATIONS_ALL.ship_to_organization_id%TYPE
)
RETURN BOOLEAN
IS
    l_current_sob       ORG_ORGANIZATION_DEFINITIONS.set_of_books_id%TYPE;
    l_ga_sob            ORG_ORGANIZATION_DEFINITIONS.set_of_books_id%TYPE;

BEGIN

-- Bug 3014005
-- If the ship to org is not specified on the price break as we could only
-- have quantity price breaks we need to return true for that case.

    IF p_ship_to_org_id is null THEN
        return (TRUE);
    END IF;

    SELECT     FSP.set_of_books_id,
               OOD.set_of_books_id
    INTO       l_current_sob,
               l_ga_sob
    FROM       financials_system_parameters	FSP,
               org_organization_definitions	OOD
    WHERE      OOD.organization_id = p_ship_to_org_id;

    IF ( l_current_sob = l_ga_sob ) THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        return (FALSE);

END is_ship_to_org_valid;


/*=============================================================================

    FUNCTION:       get_vendor_site_id

    DESCRIPTION:    Returns the vendor_site_id for the current org specified in
                    the input Global Agreement. Returns NULL if the current org
                    is not enabled for the Global Agreement.

=============================================================================*/
FUNCTION get_vendor_site_id
(
    p_po_header_id      PO_GA_ORG_ASSIGNMENTS.po_header_id%TYPE
)
RETURN PO_GA_ORG_ASSIGNMENTS.vendor_site_id%TYPE
IS
    x_vendor_site_id    PO_GA_ORG_ASSIGNMENTS.vendor_site_id%TYPE;

BEGIN

    SELECT    pgoa.vendor_site_id
    INTO      x_vendor_site_id
    FROM      po_ga_org_assignments    pgoa,
              po_system_parameters     psp
    WHERE     pgoa.po_header_id = p_po_header_id
    AND       pgoa.organization_id = psp.org_id
    AND       pgoa.enabled_flag = 'Y';           --<Shared Proc FPJ>

    return (x_vendor_site_id);

EXCEPTION
    WHEN OTHERS THEN
        return (NULL);

END get_vendor_site_id;


--=============================================================================
-- PROCEDURE   : get_currency_info                       <2694908>
-- TYPE        : Private
--
-- PRE-REQS    : p_po_header_id must refer to a Global Agreement.
-- MODIFIES    : -
--
-- DESCRIPTION : Retrieves all currency-related info for the Global Agreement
--               (i.e. currency_code, rate_type, rate_date, rate).
--
-- PARAMETERS  : p_po_header_id  - document ID for the GA
--
-- RETURNS     : x_currency_code - Currency of the GA
--               x_rate_type     - Default rate type for current org
--               x_rate_date     - sysdate
--               x_rate          - Rate between GA and functional currency
--
-- EXCEPTIONS  : GL_CURRENCY_API.no_rate - No rate exists
--               GL_CURRENCY_API.invalid_currency - Invalid currency
--=============================================================================
PROCEDURE get_currency_info
(
    p_po_header_id      IN         PO_HEADERS_ALL.po_header_id%TYPE ,
    x_currency_code     OUT NOCOPY PO_HEADERS_ALL.currency_code%TYPE ,
    x_rate_type         OUT NOCOPY PO_HEADERS_ALL.rate_type%TYPE,
    x_rate_date         OUT NOCOPY PO_HEADERS_ALL.rate_date%TYPE,
    x_rate              OUT NOCOPY PO_HEADERS_ALL.rate%TYPE
)
IS
    l_set_of_books_id   FINANCIALS_SYSTEM_PARAMETERS.set_of_books_id%TYPE;
BEGIN

    -- Get Currency Code specifically for the Global Agreement
    SELECT    currency_code
    INTO      x_currency_code
    FROM      po_headers_all
    WHERE     po_header_id = p_po_header_id;

    -- Get the current Set of Books ID
    SELECT    set_of_books_id
    INTO      l_set_of_books_id
    FROM      financials_system_parameters;

    -- Get the default Rate Type for the current org
    SELECT    default_rate_type
    INTO      x_rate_type
    FROM      po_system_parameters;

    -- Set Rate Date equal to current date
    x_rate_date := sysdate;

    -- Retrieve rate based on above values
    x_rate := PO_CORE_S.get_conversion_rate( l_set_of_books_id ,
                                             x_currency_code   ,
                                             x_rate_date       ,
                                             x_rate_type       );
EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_currency_code := NULL;
        x_rate_type := NULL;
        x_rate_date := NULL;
        x_rate := NULL;

END get_currency_info;


--=============================================================================
-- FUNCTION    : rate_exists                         -- <2709419>
-- TYPE        : Private
--
-- PRE-REQS    : -
-- MODIFIES    : -
--
-- DESCRIPTION : Determines if a Rate is defined in the current org for
--               the input document's currency and the functional currency.
--
-- PARAMETERS  : p_po_header_id  - document ID for the GA
--
-- RETURNS     : TRUE if a Rate is defined in the current org between the GA
--               and functional currency. FALSE otherwise.
--=============================================================================
FUNCTION rate_exists
(
    p_po_header_id      IN         PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN BOOLEAN
IS
    l_currency_code        PO_HEADERS_ALL.currency_code%TYPE;
    l_sob_id               FINANCIALS_SYSTEM_PARAMETERS.set_of_books_id%TYPE;
    l_rate_type            PO_SYSTEM_PARAMETERS.default_rate_type%TYPE;
    x_rate                 PO_HEADERS_ALL.rate%TYPE;

BEGIN

    SELECT  currency_code
    INTO    l_currency_code
    FROM    po_headers_all
    WHERE   po_header_id = p_po_header_id;

    SELECT  set_of_books_id
    INTO    l_sob_id
    FROM    financials_system_parameters;

    SELECT  default_rate_type
    INTO    l_rate_type
    FROM    po_system_parameters;

    x_rate := PO_CORE_S.get_conversion_rate( l_sob_id        ,
                                             l_currency_code ,
                                             sysdate         ,
                                             l_rate_type     );
    IF ( x_rate IS NULL )
    THEN
        return (FALSE);
    ELSE
        return (TRUE);
    END IF;

EXCEPTION

    WHEN OTHERS THEN
        return (FALSE);

END rate_exists;

--<Bug 2721740 mbhargav START>
--=============================================================================
-- PROCEDURE   : sync_ga__line_attachments                     <2721740>
-- TYPE        : Private
--
-- PRE-REQS    : -
-- MODIFIES    : -
--
-- DESCRIPTION : This procedure called when 'SAVE' is issued on enter PO form
--               copies attachment from referenced GA header and GA line to
--               Standard PO line. This is alos called from post-query on lines block
--
-- PARAMETERS  : p_po_header_id - GA header Id
--               p_po_line_id  -  GA Line Id
-- RETURNS     : -
---
-- EXCEPTIONS  : -
--==========================================================================
PROCEDURE sync_ga_line_attachments(
		  p_po_header_id IN PO_HEADERS_ALL.po_header_id%TYPE,
		  p_po_line_id  IN PO_LINES_ALL.po_line_id%TYPE,
                  x_return_status    OUT NOCOPY VARCHAR2,
                  x_msg_data         OUT NOCOPY VARCHAR2) IS

l_count_po_line_att NUMBER := 0;
l_count_ga_line_att NUMBER := 0;

l_api_name  CONSTANT VARCHAR2(30) := 'SYNC_GA_LINE_ATTACHMENTS';
l_api_return_status VARCHAR2(1);
l_api_msg_data      VARCHAR2(2000);

BEGIN
    IF is_global_agreement(p_po_header_id) THEN

          --<Bug 2887275 mbhargav>
          --Changed the call to delete_attachments. Explicitely passing
          --'Y' for x_automatically_added_flag as we want to delete only
          --those attachment references that have been added automatically
          --in procedure reference_attachments
          --first delete all references on PO_IN_GA_LINES
	  fnd_attached_documents2_pkg.delete_attachments('PO_IN_GA_LINES',
                                     p_po_line_id,
                                     '', '', '', '', 'N', 'Y');

          --Copy reference from entity 'PO_LINES' to enity 'PO_IN_GA_LINES'
          reference_attachments(
                        p_api_version  => 1.0,
                        p_from_entity_name => 'PO_LINES',
                        p_from_pk1_value   => p_po_line_id,
                        p_from_pk2_value   => '',
                        p_from_pk3_value   => '',
                        p_from_pk4_value   => '',
                        p_from_pk5_value   => '',
                        p_to_entity_name   => 'PO_IN_GA_LINES',
                        p_to_pk1_value     => p_po_line_id,
                        p_to_pk2_value     => '',
                        p_to_pk3_value     => '',
                        p_to_pk4_value     => '',
                        p_to_pk5_value     => '',
                        p_automatically_added_flag => 'Y',
                        x_return_status    => l_api_return_status,
                        x_msg_data         => l_api_msg_data);

           IF l_api_return_status = FND_API.G_RET_STS_ERROR THEN
                 x_msg_data := l_api_msg_data;
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 x_msg_data := l_api_msg_data;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

   END IF; --references a GA

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                    p_encoded => 'F');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END sync_ga_line_attachments;

--=============================================================================
-- PROCEDURE   : reference_attachments                     <2721740>
-- TYPE        : Public API
--
-- PRE-REQS    : -
-- MODIFIES    : -
--
-- DESCRIPTION : This API does a shallow copy of attachments from entity
--               p_from_entity_name to entity p_to_entity_name. By shallow copy
--               we mean it copies only the reference and not the actual physical
--               copy of attachments.
--
-- PARAMETERS  : -
--
-- RETURNS     : x_return_status - values FND_API.G_RET_STS_SUCCESS
--                                        FND_API.G_RET_STS_ERROR
--                                        FND_API.G_RET_STS_UNEXP_ERROR
--               x_msg_data in case of failure
---
-- EXCEPTIONS  : -
--==========================================================================
PROCEDURE reference_attachments(
                        p_api_version      IN NUMBER,
                        p_from_entity_name IN VARCHAR2,
                        p_from_pk1_value   IN VARCHAR2,
                        p_from_pk2_value   IN VARCHAR2 DEFAULT NULL,
                        p_from_pk3_value   IN VARCHAR2 DEFAULT NULL,
                        p_from_pk4_value   IN VARCHAR2 DEFAULT NULL,
                        p_from_pk5_value   IN VARCHAR2 DEFAULT NULL,
                        p_to_entity_name   IN VARCHAR2,
                        p_to_pk1_value     IN VARCHAR2,
                        p_to_pk2_value     IN VARCHAR2 DEFAULT NULL,
                        p_to_pk3_value     IN VARCHAR2 DEFAULT NULL,
                        p_to_pk4_value     IN VARCHAR2 DEFAULT NULL,
                        p_to_pk5_value     IN VARCHAR2 DEFAULT NULL,
                        p_automatically_added_flag IN VARCHAR2 DEFAULT NULL,
                        x_return_status    OUT NOCOPY VARCHAR2,
                        x_msg_data         OUT NOCOPY VARCHAR2) IS


l_api_name  CONSTANT VARCHAR2(30) := 'REFERENCE_ATTACHMENTS';
l_api_version CONSTANT NUMBER := 1.0;

BEGIN
        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --Insert new records in fnd_attached_documents table to create
        --reference from p_from_entity_name to p_to_entity_name
        INSERT INTO fnd_attached_documents(
                       ATTACHED_DOCUMENT_ID,
                       DOCUMENT_ID,
                       CREATION_DATE,
                       CREATED_BY,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       LAST_UPDATE_LOGIN,
                       SEQ_NUM,
                       ENTITY_NAME,
                       PK1_VALUE,
                       PK2_VALUE,
                       PK3_VALUE,
                       PK4_VALUE,
                       PK5_VALUE,
                       AUTOMATICALLY_ADDED_FLAG,
                       PROGRAM_APPLICATION_ID,
                       PROGRAM_ID,
                       PROGRAM_UPDATE_DATE,
                       REQUEST_ID,
                       ATTRIBUTE_CATEGORY,
                       ATTRIBUTE1,
                       ATTRIBUTE2,
                       ATTRIBUTE3,
                       ATTRIBUTE4,
                       ATTRIBUTE5,
                       ATTRIBUTE6,
                       ATTRIBUTE7,
                       ATTRIBUTE8,
                       ATTRIBUTE9,
                       ATTRIBUTE10,
                       ATTRIBUTE11,
                       ATTRIBUTE12,
                       ATTRIBUTE13,
                       ATTRIBUTE14,
                       ATTRIBUTE15,
                       COLUMN1,
                       APP_SOURCE_VERSION,
                       CATEGORY_ID,
                       STATUS)
          SELECT  fnd_attached_documents_s.nextval,
                       fad.DOCUMENT_ID,
                       fad.CREATION_DATE,
                       fad.CREATED_BY,
                       fad.LAST_UPDATE_DATE,
                       fad.LAST_UPDATED_BY,
                       fad.LAST_UPDATE_LOGIN,
                       SEQ_NUM,
                       p_to_entity_name, --entity_name
                       p_to_pk1_value,  --pk1 value
                       p_to_pk2_value,  --PK2_VALUE,
                       p_to_pk3_value,  --PK3_VALUE,
                       p_to_pk4_value,  --PK4_VALUE,
                       p_to_pk5_value,  --PK5_VALUE,
                       nvl(p_AUTOMATICALLY_ADDED_FLAG,AUTOMATICALLY_ADDED_FLAG),
                       fad.PROGRAM_APPLICATION_ID,
                       fad.PROGRAM_ID,
                       fad.PROGRAM_UPDATE_DATE,
                       fad.REQUEST_ID,
                       ATTRIBUTE_CATEGORY,
                       ATTRIBUTE1,
                       ATTRIBUTE2,
                       ATTRIBUTE3,
                       ATTRIBUTE4,
                       ATTRIBUTE5,
                       ATTRIBUTE6,
                       ATTRIBUTE7,
                       ATTRIBUTE8,
                       ATTRIBUTE9,
                       ATTRIBUTE10,
                       ATTRIBUTE11,
                       ATTRIBUTE12,
                       ATTRIBUTE13,
                       ATTRIBUTE14,
                       ATTRIBUTE15,
                       COLUMN1,
                       fad.APP_SOURCE_VERSION,
                       fad.CATEGORY_ID,
                       fad.STATUS
           FROM  fnd_attached_documents fad, fnd_documents fd, financials_system_parameters fsp
           WHERE entity_name = p_from_entity_name
            AND  pk1_value = p_from_pk1_value
            AND (p_from_pk2_value IS NULL
                OR p_from_pk2_value = pk2_value)
            AND (p_from_pk3_value IS NULL
                OR p_from_pk3_value = pk3_value)
             AND (p_from_pk4_value IS NULL
                OR p_from_pk4_value = pk4_value)
             AND (p_from_pk5_value IS NULL
                OR p_from_pk5_value = pk5_value)
             --<Bug 2872552 mbhargav START>
             AND fad.document_id = fd.document_id
             AND (fd.publish_flag = 'Y'
                  --Security level is Organization
                  OR (fd.security_type = 1 AND fd.security_id = fsp.org_id)
                  --Security level is Set Of Books
                  OR (fd.security_type = 2 AND fd.security_id = fsp.set_of_books_id)
                  --Security level is NONE
                  OR (fd.security_type = 4)
                 );
             --<Bug 2872552 mbhargav END>

    x_return_status := FND_API.G_RET_STS_SUCCESS;

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

        x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                    p_encoded => 'F');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END reference_attachments;
--<Bug 2721740 mbhargav END>

-- <GC FPJ START>

--=============================================================================
-- PROCEDURE   : is_purchasing_site_on_ga                     <GC FPJ>
-- TYPE        : Public
--
-- PRE-REQS    : -
-- MODIFIES    : -
--
-- DESCRIPTION : This procedure checks whether global ga is purchasing
--               enabled given a vendor site
--
-- PARAMETERS  : p_po_header_id - GC header_id
--               p_vendor_site_id - target site
-- RETURNS     : x_result : FND_API.G_TRUE if enabled,
--                          FND_API.G_FALSE otherwise
---
-- EXCEPTIONS  : -
--==========================================================================

PROCEDURE is_purchasing_site_on_ga
(   p_po_header_id       IN         NUMBER,
    p_vendor_site_id     IN         NUMBER,
    x_result             OUT NOCOPY VARCHAR2
) IS

l_is_enabled VARCHAR2(1) := 'N';

BEGIN

    SELECT 'Y'
    INTO   l_is_enabled
    FROM   po_headers_all POH
    WHERE  POH.po_header_id = p_po_header_id
    AND    EXISTS (SELECT 1
                   FROM   po_ga_org_assignments PGOA
                   WHERE  PGOA.po_header_id = p_po_header_id
                   AND    PGOA.vendor_site_id = p_vendor_site_id
                   AND    PGOA.enabled_flag = 'Y');

    IF (l_is_enabled = 'Y') THEN
        x_result := FND_API.G_TRUE;
    ELSE
        x_result := FND_API.G_FALSE;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_result := FND_API.G_FALSE;
END is_purchasing_site_on_ga;


--=============================================================================
-- PROCEDURE   : is_local_document                           <GC FPJ>
-- TYPE        : Public
--
-- PRE-REQS    : -
-- MODIFIES    : -
--
-- DESCRIPTION : Check whether the document is local document with document
--               type specified by p_type_lookup_code
--
-- PARAMETERS  : p_po_header_id - po_header_id
--               p_type_lookup_code - doc subtype of the document
-- RETURNS     : TRUE if document is local
--               FALSE if document is a global document, or if document type
--               does not match the one specified in p_type_lookup_code
--
-- EXCEPTIONS  : -
--==========================================================================

FUNCTION is_local_document (p_po_header_id     IN NUMBER,
                            p_type_lookup_code IN VARCHAR2) RETURN BOOLEAN
IS

l_global VARCHAR2(1);

BEGIN

    SELECT NVL(POH.global_agreement_flag, 'N')
    INTO   l_global
    FROM   po_headers_all POH
    WHERE  POH.po_header_id = p_po_header_id
    AND    POH.type_lookup_code = p_type_lookup_code;

    IF (l_global = 'Y') THEN   -- global doc
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('is_local_document', '000', sqlcode);
END is_local_document;
-- <GC FPJ END>

--<Shared Proc FPJ START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_PURCHASING_ORG_ID
--Pre-reqs:
--  Assumes that p_po_header_id is valid
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Hit the enabled org form of given GA and get purchasing org for
--  the current org as enabled org.
--Parameters:
--IN:
--p_po_header_id
--  unique identifier of the document
--Returns:
--  Returns the purchasing_org_id for the current org specified in
--  the input Global Agreement. Returns NULL if the current org
--  is not enabled for the Global Agreement.
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_purchasing_org_id (
   p_po_header_id   IN NUMBER
)
   RETURN NUMBER
IS
   x_purchasing_org_id   po_ga_org_assignments.purchasing_org_id%TYPE;
BEGIN
   --SQL WHAT: Join to psp to get current org
   --SQL WHY: Need to get purchasing org_id
   SELECT 	pgoa.purchasing_org_id
     INTO 	x_purchasing_org_id
     FROM 	po_ga_org_assignments pgoa, po_system_parameters psp
    WHERE 	pgoa.po_header_id = p_po_header_id
      AND 	pgoa.organization_id = psp.org_id
      AND 	pgoa.enabled_flag = 'Y';

   RETURN (x_purchasing_org_id);
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN (NULL);
END get_purchasing_org_id;


--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_item_revision
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Validates that p_ga_item_revision for p_item_id is available in both
--  p_org_id and p_owning_org_id. Appends to the API message list upon error.
--Parameters:
--IN:
--p_item_id
--  The item ID on the GA line
--p_org_id
--  The org ID of the OU to test against p_owning_org_id
--p_ga_item_revision
--  The item revision on the GA line. (MTL_ITEM_REVISIONS_B.revision%TYPE)
--p_owning_org_id
--  The GA Owning Org ID
--p_check_rev_control
--  If TRUE, then the revision control property of the item in p_org_id will be
--  used during validation. If FALSE, then it will not be used.
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_is_valid
--  TRUE if:
--      - p_item_id is a one-time item
--      OR
--      - p_org_id is equal to p_owning_org_id
--      OR
--      - p_ga_item_revision is available in both p_org_id and p_owning_org_id
--      OR
--      - p_check_rev_control is TRUE
--      - p_item_id in p_org_id does not use revision control
--
--  FALSE otherwise.
--x_item_revision
--  The valid item revision for the item in p_org_id. This will be NULL if
--  p_ga_item_revision is not available in p_org_id, but revision control for
--  p_item_id in p_org_id is off.
--  (MTL_ITEM_REVISIONS_B.revision%TYPE)
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_item_revision
(
    x_return_status     OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_ga_item_revision  IN  VARCHAR2,
    p_owning_org_id     IN  NUMBER,
    p_check_rev_control IN  BOOLEAN,
    x_is_valid          OUT NOCOPY BOOLEAN,
    x_item_revision     OUT NOCOPY VARCHAR2
)
IS

l_rev_control MTL_SYSTEM_ITEMS.revision_qty_control_code%TYPE;
l_progress VARCHAR2(3);

BEGIN
    l_progress := '000';
    x_return_status := FND_API.g_ret_sts_success;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
           (p_log_head => g_module_prefix||'validate_item_revision',
            p_token    => 'invoked',
            p_message  => 'item ID: '||p_item_id||' org ID: '||p_org_id||
                          ' ga item rev: '||p_ga_item_revision||' ownorg ID: '||
                          p_owning_org_id);
    END IF;

    IF (p_item_id IS NULL) OR              -- One-time item
       (p_org_id = p_owning_org_id) OR     -- Same org
       (p_ga_item_revision IS NULL)        -- GA item revision is NULL
    THEN
        x_item_revision := p_ga_item_revision;
        x_is_valid := TRUE;
        RETURN;
    END IF;

    l_progress := '010';
    BEGIN
        --SQL What: Check that p_ga_item_revision is available in p_org_id and
        --  p_owning_org_id.
        --SQL Why: Validate that p_org_id can source p_ga_item_revision from
        --  p_owning_org_id
        SELECT mir_ga.revision
          INTO x_item_revision
          FROM financials_system_params_all fspa_ga,  -- GA owning org
               financials_system_params_all fspa,
               mtl_item_revisions_b         mir_ga,   -- GA revision
               mtl_item_revisions_b         mir
         WHERE fspa_ga.org_id           = p_owning_org_id
           AND mir_ga.organization_id   = fspa_ga.inventory_organization_id
           AND mir_ga.inventory_item_id = p_item_id
           AND mir_ga.revision          = p_ga_item_revision
           AND fspa.org_id              = p_org_id
           AND mir.organization_id      = fspa.inventory_organization_id
           AND mir.inventory_item_id    = mir_ga.inventory_item_id
           AND mir.revision             = mir_ga.revision;

        -- If SQL was successful, return here
        x_is_valid := TRUE;
        RETURN;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Could not match revisions the first time, so only continue if the
            -- API caller wants to check revision control
            IF (NOT p_check_rev_control) THEN
                x_is_valid := FALSE;
                RETURN;
            END IF;
    END;

    l_progress := '020';

    -- The first check failed, but the API caller wants to check the revision
    -- control in p_org_id

    --SQL What: Get the revision control property of p_item_id in p_org_id where
    --  p_ga_item_revision exists in p_owning_org_id
    --SQL Why: Check if p_org_id can still source the item revision
    SELECT NVL(msi.revision_qty_control_code, 1)
      INTO l_rev_control
      FROM financials_system_params_all fspa_ga,   -- GA owning org
           financials_system_params_all fspa,
           mtl_item_revisions_b mir_ga,              -- GA revision
           mtl_system_items_b msi
     WHERE fspa_ga.org_id           = p_owning_org_id
       AND mir_ga.organization_id   = fspa_ga.inventory_organization_id
       AND mir_ga.inventory_item_id = p_item_id
       AND mir_ga.revision          = p_ga_item_revision
       AND fspa.org_id              = p_org_id
       AND msi.inventory_item_id    = mir_ga.inventory_item_id
       AND msi.organization_id      = fspa.inventory_organization_id;

    IF (l_rev_control = 1) THEN
        -- Revision control is off, so validation passes.
        -- Need to set the x_item_revision to NULL.
        x_item_revision := NULL;
        x_is_valid := TRUE;
    ELSE
        -- Revision control is on, so validation fails
        x_item_revision := NULL;
        x_is_valid := FALSE;
    END IF;  --< if rev control = 1>

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_is_valid := FALSE;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'validate_item_revision',
                                p_error_text     => 'Progress: '||l_progress||
                                           ' Error: '||SUBSTRB(SQLERRM,1,215));
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_module_prefix || 'validate_item_revision',
                p_progress => l_progress);
        END IF;
END validate_item_revision;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_item_in_org
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Performs item and item revision validity checks between p_org_id and
--  p_owning_org_id. Appends to the API message list upon error.
--Parameters:
--IN:
--p_item_id
--  The item ID on the GA line
--p_org_id
--  The org ID of the OU to compare against p_owning_org_id
--p_ga_org_type
--  The type of OU that p_org_id is for the GA. Acceptable values are the
--  global variables g_requesting_org_type or g_purchasing_org_type.  Calls
--  APP_EXCEPTION.invalid_argument if the parameter is not one of these values.
--p_ga_item_revision
--  The item revision on the GA line. (MTL_ITEM_REVISIONS_B.revision%TYPE)
--p_owning_org_id
--  The GA Owning Org ID
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_error - if an error occurred
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_is_valid
--  TRUE if:
--     - item is a one-time item
--     OR
--     - item master item defined in Financial Options Inventory Organization of
--       p_org_id as 'purchasable'
--     - item in p_org_id must share same 'UOM' as p_owning_org_id
--     - item not defined as 'Outside Processing' in p_org_id
--     - p_ga_item_revision in p_owning_org_id is available in p_org_id. If
--           - it is not available AND
--           - p_ga_org_type is g_requesting_org_type AND
--           - revision control is off in p_org_id
--       then the revision check passes and x_item_revision will be NULL.
--
--  FALSE otherwise.
--x_item_revision
--  The valid item revision for the item in p_org_id.
-- (MTL_ITEM_REVISIONS_B.revision%TYPE)
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_item_in_org
(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_item_id          IN  NUMBER,
    p_org_id           IN  NUMBER,
    p_ga_org_type      IN  VARCHAR2,
    p_ga_item_revision IN  VARCHAR2,
    p_owning_org_id    IN  NUMBER,
    x_is_valid         OUT NOCOPY BOOLEAN,
    x_item_revision    OUT NOCOPY VARCHAR2
)
IS

l_check_rev_control BOOLEAN;
l_is_purchasable    BOOLEAN;
l_is_same_uom_class BOOLEAN;
l_is_not_osp_item   BOOLEAN;
l_progress          VARCHAR2(3);

BEGIN
    l_progress := '000';
    x_return_status := FND_API.g_ret_sts_success;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
            (p_log_head => g_module_prefix||'validate_item_in_org',
             p_token    => 'invoked',
             p_message  => 'item ID: '||p_item_id||' org ID: '||p_org_id||
                           ' orgtype: '||p_ga_org_type||' ga item rev: '||
                           p_ga_item_revision||' ownorg ID: '||p_owning_org_id);
    END IF;

    -- Only do revision check if GA revision is not NULL
    IF (p_ga_item_revision IS NOT NULL) THEN

        IF (p_ga_org_type = g_requesting_org_type) THEN
            -- Pass in TRUE because Requesting Org may use revision control
            l_check_rev_control := TRUE;
        ELSIF (p_ga_org_type = g_purchasing_org_type) THEN
            -- Pass in FALSE because Purchasing Org must always match exactly
            l_check_rev_control := FALSE;
        ELSE
            l_progress := '010';

            -- Invalid parameter, so raise error here
            APP_EXCEPTION.invalid_argument
                (procname => 'PO_GA_PVT.validate_item_in_org',
                 argument => 'p_ga_org_type',
                 value => p_ga_org_type);
        END IF;

        l_progress := '020';

        validate_item_revision(x_return_status     => x_return_status,
                               p_item_id           => p_item_id,
                               p_org_id            => p_org_id,
                               p_ga_item_revision  => p_ga_item_revision,
                               p_owning_org_id     => p_owning_org_id,
                               p_check_rev_control => l_check_rev_control,
                               x_is_valid          => x_is_valid,
                               x_item_revision     => x_item_revision);

        IF (x_return_status = FND_API.g_ret_sts_error) THEN
            RAISE FND_API.g_exc_error;
        ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF;

        IF (NOT x_is_valid) THEN
            -- revision check failed, so validation fails. No need to continue
            RETURN;
        END IF;

    END IF;  --<if ga item revision not null>

    l_progress := '030';

    -- Check item validity
    validate_item(x_return_status     => x_return_status,
                  p_item_id           => p_item_id,
                  p_org_id            => p_org_id,
                  p_valid_org_id      => p_owning_org_id,
                  x_is_purchasable    => l_is_purchasable,
                  x_is_same_uom_class => l_is_same_uom_class,
                  x_is_not_osp_item   => l_is_not_osp_item);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    x_is_valid := (l_is_purchasable AND l_is_same_uom_class AND
                   l_is_not_osp_item);

EXCEPTION
    WHEN APP_EXCEPTION.application_exception THEN
        x_return_status := FND_API.g_ret_sts_error;
        FND_MSG_PUB.add;
        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt
                (p_log_head => g_module_prefix||'validate_item_in_org',
                 p_token    => l_progress,
                 p_message  => 'APPLICATION_EXCEPTION caught.');
        END IF;
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'validate_item_in_org',
                                p_error_text     => 'Progress: '||l_progress||
                                           ' Error: '||SUBSTRB(SQLERRM,1,215));
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_module_prefix || 'validate_item_in_org',
                p_progress => l_progress);
        END IF;
END validate_item_in_org;

--------------------------------------------------------------------------------
--Start of Comments
--Name: val_enabled_purchasing_org
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Validate that x_purchasing_org_id is a Purchasing Org for the GA, with an
--  enabled status. If x_purchasing_org_id is NULL, the current OU will be
--  used as the Purchasing Org. Appends to the API message list upon error.
--Parameters:
--IN:
--p_po_header_id
--  The po_header_id of the GA.
--IN OUT:
--x_purchasing_org_id
--  The Purchasing Org ID, or NULL to use the current OU. If NULL, this will be
--  set to be the current OU if x_is_valid is TRUE.
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_is_valid
--  TRUE if x_purchasing_org_id is valid and enabled for use for the GA.
--  FALSE otherwise.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE val_enabled_purchasing_org
(
    x_return_status     OUT    NOCOPY VARCHAR2,
    p_po_header_id      IN     NUMBER,
    x_purchasing_org_id IN OUT NOCOPY NUMBER,
    x_is_valid          OUT    NOCOPY BOOLEAN
)
IS

l_valid_flag VARCHAR2(1);
l_progress VARCHAR2(3);

BEGIN
    l_progress := '000';
    x_return_status := FND_API.g_ret_sts_success;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
           (p_log_head => g_module_prefix||'val_enabled_purchasing_org',
            p_token    => 'invoked',
            p_message  => 'po_header_id: '||p_po_header_id||
                          ' purchorg ID: '||x_purchasing_org_id);
    END IF;

    IF (x_purchasing_org_id IS NULL) THEN
        l_progress := '010';

        SELECT pgoa.purchasing_org_id
          INTO x_purchasing_org_id
          FROM po_ga_org_assignments pgoa,
               po_system_parameters psp
         WHERE pgoa.po_header_id = p_po_header_id
           AND pgoa.purchasing_org_id = psp.org_id
           AND pgoa.enabled_flag = 'Y'
           AND rownum = 1;

    ELSE
        l_progress := '020';

        SELECT 'Y'
          INTO l_valid_flag
          FROM po_ga_org_assignments
         WHERE po_header_id = p_po_header_id
           AND purchasing_org_id = x_purchasing_org_id
           AND enabled_flag = 'Y'
           AND rownum = 1;

    END IF;

    l_progress := '030';

    -- Successful select means that it is a valid enabled purchasing org
    x_is_valid := TRUE;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_var
           (p_log_head => g_module_prefix||'val_enabled_purchasing_org',
            p_progress => l_progress,
            p_name     => 'x_is_valid',
            p_value    => x_is_valid);
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_is_valid := FALSE;
        IF g_debug_stmt THEN
            PO_DEBUG.debug_var
               (p_log_head => g_module_prefix||'val_enabled_purchasing_org',
                p_progress => l_progress,
                p_name     => 'x_is_valid',
                p_value    => x_is_valid);
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'val_enabled_purchasing_org',
                                p_error_text     => 'Progress: '||l_progress||
                                           ' Error: '||SUBSTRB(SQLERRM,1,215));
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_module_prefix||'val_enabled_purchasing_org',
                p_progress => l_progress);
        END IF;
END val_enabled_purchasing_org;

--------------------------------------------------------------------------------
--Start of Comments
--Name: val_enabled_requesting_org
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Validate that x_requesting_org_id is a Requesting Org for the GA, with an
--  enabled status. If x_requesting_org_id is NULL, the current OU is used as
--  the Requesting Org. Appends to the API message list upon error.
--Parameters:
--IN:
--p_po_header_id
--  The po_header_id of the GA.
--IN OUT:
--x_requesting_org_id
--  The Requesting Org ID, or NULL to use the current OU. If NULL, this will be
--  set to be the current OU if x_is_valid is TRUE.
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_is_valid
--  TRUE if p_requesting_org_id is valid and enabled for use for the GA.
--  FALSE otherwise.
--x_purchasing_org_id
--  The Purchasing Org ID for the org assignment of the Requesting Org. Only
--  has a valid value if x_is_valid is TRUE.
--  (PO_GA_ORG_ASSIGNMENTS.purchasing_org_id%TYPE)
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE val_enabled_requesting_org
(
    x_return_status     OUT    NOCOPY VARCHAR2,
    p_po_header_id      IN     NUMBER,
    x_requesting_org_id IN OUT NOCOPY NUMBER,
    x_is_valid          OUT    NOCOPY BOOLEAN,
    x_purchasing_org_id OUT    NOCOPY NUMBER
)
IS

l_progress VARCHAR2(3);

BEGIN
    l_progress := '000';
    x_return_status := FND_API.g_ret_sts_success;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
           (p_log_head => g_module_prefix||'val_enabled_requesting_org',
            p_token    => 'invoked',
            p_message  => 'po_header_id: '||p_po_header_id||
                         ' reqorg ID: '||x_requesting_org_id);
    END IF;

    IF (x_requesting_org_id IS NULL) THEN
        l_progress := '010';

        SELECT pgoa.purchasing_org_id,
               pgoa.organization_id
          INTO x_purchasing_org_id,
               x_requesting_org_id
          FROM po_ga_org_assignments pgoa,
               po_system_parameters psp
         WHERE pgoa.po_header_id = p_po_header_id
           AND pgoa.organization_id = psp.org_id
           AND pgoa.enabled_flag = 'Y';

    ELSE
        l_progress := '020';

        SELECT purchasing_org_id
          INTO x_purchasing_org_id
          FROM po_ga_org_assignments
         WHERE po_header_id = p_po_header_id
           AND organization_id = x_requesting_org_id
           AND enabled_flag = 'Y';

    END IF;

    l_progress := '030';

    -- Successful select means that it is a valid enabled requesting org
    x_is_valid := TRUE;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_var
           (p_log_head => g_module_prefix||'val_enabled_requesting_org',
            p_progress => l_progress,
            p_name     => 'x_is_valid',
            p_value    => x_is_valid);
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_purchasing_org_id := NULL;
        x_is_valid := FALSE;
        IF g_debug_stmt THEN
            PO_DEBUG.debug_var
               (p_log_head => g_module_prefix||'val_enabled_requesting_org',
                p_progress => l_progress,
                p_name     => 'x_is_valid',
                p_value    => x_is_valid);
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'val_enabled_requesting_org',
                                p_error_text     => 'Progress: '||l_progress||
                                           ' Error: '||SUBSTRB(SQLERRM,1,215));
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_module_prefix||'val_enabled_requesting_org',
                p_progress => l_progress);
        END IF;
END val_enabled_requesting_org;

---------------------------------------------------------------------------
--Start of Comments
--Name: validate_in_purchasing_org
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Validates the item in the Purchasing Org p_purchasing_org_id against the
--  Owning Org. If p_purchasing_org_id is NULL, then the current OU is used
--  as the Purchasing Org. Appends to the API message list upon error.
--Parameters:
--IN:
--p_po_header_id
--  The header ID of the GA
--p_item_id
--  The item ID on the GA line
--p_purchasing_org_id
--  The org ID of the Purchasing Org, or NULL to use the current OU.
--p_ga_item_revision
--  The item revision on the GA line. (MTL_ITEM_REVISIONS_B.revision%TYPE)
--p_owning_org_id
--  The GA Owning Org ID
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_error - if an error occurred
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_is_pou_valid
--  TRUE if p_purchasing_org_id is a valid Purchasing Org for the GA.
--  FALSE otherwise.
--x_is_item_valid:
--  TRUE if x_is_pou_valid is TRUE, and all item validations succeed for the
--    Purchasing Org.
--  FALSE otherwise.
--x_item_revision
--  The valid item revision for the item in the Purchasing Org
--  p_purchasing_org_id.  (MTL_ITEM_REVISIONS_B.revision%TYPE)
--End of Comments
---------------------------------------------------------------------------
PROCEDURE validate_in_purchasing_org
(
    x_return_status     OUT NOCOPY VARCHAR2,
    p_po_header_id      IN  NUMBER,
    p_item_id           IN  NUMBER,
    p_purchasing_org_id IN  NUMBER,
    p_ga_item_revision  IN  VARCHAR2,
    p_owning_org_id     IN  NUMBER,
    x_is_pou_valid      OUT NOCOPY BOOLEAN,
    x_is_item_valid     OUT NOCOPY BOOLEAN,
    x_item_revision     OUT NOCOPY VARCHAR2
)
IS

l_purchasing_org_id
    PO_GA_ORG_ASSIGNMENTS.purchasing_org_id%TYPE := p_purchasing_org_id;
l_item_revision MTL_ITEM_REVISIONS_B.revision%TYPE;
l_progress VARCHAR2(3);

BEGIN
    l_progress := '000';
    x_return_status := FND_API.g_ret_sts_success;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
           (p_log_head => g_module_prefix||'validate_in_purchasing_org',
            p_token    => 'invoked',
            p_message  => 'po_header_id: '||p_po_header_id||' item ID: '||
                          p_item_id||' purchorg ID: '||p_purchasing_org_id||
                          ' ownorg ID: '||p_owning_org_id);
    END IF;

    l_progress := '010';

    -- First ensure that p_purchasing_org_id is a valid Purchasing Org
    val_enabled_purchasing_org(x_return_status     => x_return_status,
                               p_po_header_id      => p_po_header_id,
                               x_purchasing_org_id => l_purchasing_org_id,
                               x_is_valid          => x_is_pou_valid);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF (NOT x_is_pou_valid) THEN
        -- p_purchasing_org_id is not a valid Purchasing Org, so return
        x_is_item_valid := FALSE;
        RETURN;
    END IF;

    l_progress := '020';

    -- p_purchasing_org_id is a valid Purchasing Org. Validate item against
    -- the Purchasing Org
    validate_item_in_org(x_return_status    => x_return_status,
                         p_item_id          => p_item_id,
                         p_org_id           => l_purchasing_org_id,
                         p_ga_org_type      => g_purchasing_org_type,
                         p_ga_item_revision => p_ga_item_revision,
                         p_owning_org_id    => p_owning_org_id,
                         x_is_valid         => x_is_item_valid,
                         x_item_revision    => x_item_revision);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_var
           (p_log_head => g_module_prefix||'validate_in_purchasing_org',
            p_progress => l_progress,
            p_name     => 'x_is_item_valid',
            p_value    => x_is_item_valid);
    END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'validate_in_purchasing_org',
                                p_error_text     => 'Progress: '||l_progress||
                                           ' Error: '||SUBSTRB(SQLERRM,1,215));
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_module_prefix||'validate_in_purchasing_org',
                p_progress => l_progress);
        END IF;
END validate_in_purchasing_org;

---------------------------------------------------------------------------
--Start of Comments
--Name: validate_in_requesting_org
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Validates the item in the Requesting Org p_requesting_org_id against the
--  Owning Org. Also performs item validations with the Purchasing Org of this
--  org assignment against the Owning Org. If p_requesting_org_id is NULL,
--  then the current OU is used as the Requesting Org. Appends to the API
--  message list upon error.
--Parameters:
--IN:
--p_po_header_id
--  The header ID of the GA
--p_item_id
--  The item ID on the GA line
--p_requesting_org_id
--  The org ID of the Requesting Org, or NULL to use the current OU.
--p_ga_item_revision
--  The item revision on the GA line. (MTL_ITEM_REVISIONS_B.revision%TYPE)
--p_owning_org_id
--  The GA Owning Org ID
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_error - if an error occurred
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_is_rou_valid
--  TRUE if p_requesting_org_id is a valid Requesting Org for the GA.
--  FALSE otherwise.
--x_is_item_valid:
--  TRUE if x_is_rou_valid is TRUE, and all item validations succeed for the
--    Requesting Org.
--  FALSE otherwise.
--x_item_revision
--  The valid item revision for the item in the Requesting Org
--  p_requesting_org_id.  (MTL_ITEM_REVISIONS_B.revision%TYPE)
--End of Comments
---------------------------------------------------------------------------
PROCEDURE validate_in_requesting_org
(
    x_return_status     OUT NOCOPY VARCHAR2,
    p_po_header_id      IN  NUMBER,
    p_item_id           IN  NUMBER,
    p_requesting_org_id IN  NUMBER,
    p_ga_item_revision  IN  VARCHAR2,
    p_owning_org_id     IN  NUMBER,
    x_is_rou_valid      OUT NOCOPY BOOLEAN,
    x_is_item_valid     OUT NOCOPY BOOLEAN,
    x_item_revision     OUT NOCOPY VARCHAR2
)
IS

l_requesting_org_id
    PO_GA_ORG_ASSIGNMENTS.organization_id%TYPE := p_requesting_org_id;
l_purchasing_org_id PO_GA_ORG_ASSIGNMENTS.purchasing_org_id%TYPE;
l_dummy_revision MTL_ITEM_REVISIONS_B.revision%TYPE;
l_progress VARCHAR2(3);

BEGIN
    l_progress := '000';
    x_return_status := FND_API.g_ret_sts_success;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
           (p_log_head => g_module_prefix||'validate_in_requesting_org',
            p_token    => 'invoked',
            p_message  => 'po_header_id: '||p_po_header_id||' item ID: '||
                          p_item_id||' reqorg ID: '||p_requesting_org_id||
                          ' ownorg ID: '||p_owning_org_id);
    END IF;

    l_progress := '010';

    -- First ensure that p_requesting_org_id is a valid Requesting Org
    val_enabled_requesting_org(x_return_status     => x_return_status,
                               p_po_header_id      => p_po_header_id,
                               x_requesting_org_id => l_requesting_org_id,
                               x_is_valid          => x_is_rou_valid,
                               x_purchasing_org_id => l_purchasing_org_id);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF (NOT x_is_rou_valid) THEN
        -- p_requesting_org_id is not a valid Requesting Org, so return
        x_is_item_valid := FALSE;
        RETURN;
    END IF;

    l_progress := '020';

    -- p_requesting_org_id is a valid Requesting Org. Validate item against the
    -- Requesting Org
    validate_item_in_org(x_return_status    => x_return_status,
                         p_item_id          => p_item_id,
                         p_org_id           => l_requesting_org_id,
                         p_ga_org_type      => g_requesting_org_type,
                         p_ga_item_revision => p_ga_item_revision,
                         p_owning_org_id    => p_owning_org_id,
                         x_is_valid         => x_is_item_valid,
                         x_item_revision    => x_item_revision);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF (NOT x_is_item_valid) THEN
        -- This Requesting Org failed item validity, so return here
        RETURN;
    END IF;

    l_progress := '030';

    -- Now validate item against the Purchasing Org for this Requesting Org
    validate_item_in_org(x_return_status    => x_return_status,
                         p_item_id          => p_item_id,
                         p_org_id           => l_purchasing_org_id,
                         p_ga_org_type      => g_purchasing_org_type,
                         p_ga_item_revision => p_ga_item_revision,
                         p_owning_org_id    => p_owning_org_id,
                         x_is_valid         => x_is_item_valid,
                         x_item_revision    => l_dummy_revision);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_var
           (p_log_head => g_module_prefix||'validate_in_requesting_org',
            p_progress => l_progress,
            p_name     => 'x_is_item_valid',
            p_value    => x_is_item_valid);
    END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'validate_in_requesting_org',
                                p_error_text     => 'Progress: '||l_progress||
                                           ' Error: '||SUBSTRB(SQLERRM,1,215));
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_module_prefix||'validate_in_requesting_org',
                p_progress => l_progress);
        END IF;
END validate_in_requesting_org;

---------------------------------------------------------------------------
--Start of Comments
--Name: requesting_org_type
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the global variable g_requesting_org_type
--Returns:
--  g_requesting_org_type
--End of Comments
---------------------------------------------------------------------------
FUNCTION requesting_org_type RETURN VARCHAR2
IS
BEGIN
    RETURN g_requesting_org_type;
END requesting_org_type;

---------------------------------------------------------------------------
--Start of Comments
--Name: purchasing_org_type
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the global variable g_purchasing_org_type
--Returns:
--  g_purchasing_org_type
--End of Comments
---------------------------------------------------------------------------
FUNCTION purchasing_org_type RETURN VARCHAR2
IS
BEGIN
    RETURN g_purchasing_org_type;
END purchasing_org_type;

---------------------------------------------------------------------------
--Start of Comments
--Name: owning_org_type
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the global variable g_owning_org_type
--Returns:
--  g_owning_org_type
--End of Comments
---------------------------------------------------------------------------
FUNCTION owning_org_type RETURN VARCHAR2
IS
BEGIN
    RETURN g_owning_org_type;
END owning_org_type;


--<Shared Proc FPJ END>

--Bug 12618619
PROCEDURE sync_all_ga_line_attachments(
		  p_po_header_id IN PO_HEADERS_ALL.po_header_id%TYPE,
                  x_return_status    OUT NOCOPY VARCHAR2,
                  x_msg_data         OUT NOCOPY VARCHAR2) IS

l_count_po_line_att NUMBER := 0;
l_count_ga_line_att NUMBER := 0;

l_api_name  CONSTANT VARCHAR2(30) := 'SYNC_ALL_GA_LINE_ATTACHMENTS';
l_api_return_status VARCHAR2(1);
l_api_msg_data      VARCHAR2(2000);

cursor lines_csr is
select from_line_id, decode(from_header_id, NULL,contract_id, from_header_id ) from po_lines_merge_v where po_header_id = p_po_header_id;

l_po_line_id PO_LINES_ALL.po_line_id%type;
l_src_doc_id PO_HEADERS_ALL.po_header_id%TYPE;


BEGIN

open lines_csr;

	loop
		fetch lines_csr into l_po_line_id,l_src_doc_id;
			exit when lines_csr%NOTFOUND;

    IF is_global_agreement(l_src_doc_id) THEN




          --<Bug 2887275 mbhargav>
          --Changed the call to delete_attachments. Explicitely passing
          --'Y' for x_automatically_added_flag as we want to delete only
          --those attachment references that have been added automatically
          --in procedure reference_attachments
          --first delete all references on PO_IN_GA_LINES
	  fnd_attached_documents2_pkg.delete_attachments('PO_IN_GA_LINES',
                                     l_po_line_id,
                                     '', '', '', '', 'N', 'Y');

          --Copy reference from entity 'PO_LINES' to enity 'PO_IN_GA_LINES'
          reference_attachments(
                        p_api_version  => 1.0,
                        p_from_entity_name => 'PO_LINES',
                        p_from_pk1_value   => l_po_line_id,
                        p_from_pk2_value   => '',
                        p_from_pk3_value   => '',
                        p_from_pk4_value   => '',
                        p_from_pk5_value   => '',
                        p_to_entity_name   => 'PO_IN_GA_LINES',
                        p_to_pk1_value     => l_po_line_id,
                        p_to_pk2_value     => '',
                        p_to_pk3_value     => '',
                        p_to_pk4_value     => '',
                        p_to_pk5_value     => '',
                        p_automatically_added_flag => 'Y',
                        x_return_status    => l_api_return_status,
                        x_msg_data         => l_api_msg_data);

           IF l_api_return_status = FND_API.G_RET_STS_ERROR THEN
                 x_msg_data := l_api_msg_data;
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 x_msg_data := l_api_msg_data;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

 END IF; --references a GA

				end loop;
				close lines_csr;



   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                    p_encoded => 'F');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END sync_all_ga_line_attachments;

END PO_GA_PVT;

/
