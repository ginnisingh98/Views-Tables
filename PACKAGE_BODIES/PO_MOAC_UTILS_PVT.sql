--------------------------------------------------------
--  DDL for Package Body PO_MOAC_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_MOAC_UTILS_PVT" AS
/*$Header: POXVMOUB.pls 120.8.12010000.2 2008/08/04 08:34:07 rramasam ship $*/

-----------------------------------------------------------------------------
-- Declare private package variables.
-----------------------------------------------------------------------------
g_pkg_name CONSTANT VARCHAR2(30)
  := 'PO_MOAC_UTILS_PVT';

D_PACKAGE_BASE CONSTANT VARCHAR2(100) := PO_LOG.get_package_base(g_pkg_name);


-------------------------------------------------------------------------------
--Start of Comments
--Name: SET_ORG_CONTEXT
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This procedure would be used to set the Org Context. This procedure replaces
-- setting of ORG Context using FND CLIENT INFO or DBMS APPLICATION INFO calls.
-- This procedure first checks if the global temp table is already populated or
-- not, if it is not populated it would invoke initialize routine and then set
-- the org context to single and set current ou to the p_org_id.
--Parameters:
--IN:
--p_org_id
--  This contains the org_id for which the context needs to be set.
--IN OUT:
--  None.
--OUT:
--  None.
--Notes:
-- The algorithm of the procedure is as follows :
-- Check for the current orgid. If p_org_id does not match with the current org_id
-- call the initialize routine. Then set the policy context to the p_org_id.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE SET_ORG_CONTEXT
(
  p_org_id   IN   NUMBER
)
IS
  l_progress      VARCHAR2(3) := NULL;

  l_current_org_id  hr_all_organization_units_tl.organization_id%TYPE;

  l_access_mode VARCHAR2(1);
  l_ou_count NUMBER;
  l_is_mo_init_done VARCHAR2(1);
BEGIN
  l_progress := '010';

 --<R12 MOAC IMPACTS START>

  -- bug5562486
  -- Rewrote the whole procedure to call expensive MO init procedure only when
  -- absolutely necessary

  l_is_mo_init_done := MO_GLOBAL.is_mo_init_done;

  IF (l_is_mo_init_done <> 'Y') THEN
    PO_MOAC_UTILS_PVT.initialize;
  END IF;

  l_progress := '020';

  IF (p_org_id IS NOT NULL) THEN

    l_access_mode    := MO_GLOBAL.get_access_mode;

    IF ( l_access_mode = 'S') THEN

      l_current_org_id := PO_MOAC_UTILS_PVT.get_current_org_id;

      -- If access mode is already single, then we need to call
      -- set_policy_context only if the org is different from current org
      IF ( l_current_org_id IS NULL OR
           l_current_org_id <> p_org_id) THEN

        l_progress := '030';
        PO_MOAC_UTILS_PVT.set_policy_context('S', p_org_id);
      END IF;
    ELSE
      l_progress := '040';
      PO_MOAC_UTILS_PVT.set_policy_context('S', p_org_id);

    END IF;

  ELSE

    l_ou_count := PO_MOAC_UTILS_PVT.get_ou_count;

    IF (l_ou_count > 1) THEN
      PO_MOAC_UTILS_PVT.set_policy_context ('M', NULL);
    END IF;

  END IF;


 --<R12 MOAC IMPACTS END>
EXCEPTION
  WHEN OTHERS THEN
     po_message_s.sql_error('po_moac_utils_pvt.set_org_context', l_progress, sqlcode);
  RAISE;
END set_org_context;

-------------------------------------------------------------------------------
--Start of Comments
--Name: MO_INIT
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This procedure would be invoked by Public APIs to initialize proper multi-org
-- context. This procedure checks if the P_ORG_ID passed is valid or not using
-- get_valid_org function. If it is not valid then error is thrown, else OU
-- context is set to Single and current OU is set to P_ORG_ID. If p_org_id is
-- NULL, then the get_valid_org routine would derive either current OU or
-- default OU and return this value. Again context is set to single and current
-- OU is set to the value returned from get_valid_org if there is no existing
-- context(in case of default OU).
--Parameters:
--IN:
--p_org_id
--  This contains the org_id for which the context needs to be set.
--IN OUT:
--  None.
--OUT:
--  None.
--Notes:
--
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE MO_INIT(p_org_id   IN   NUMBER     )
IS
  l_org_id  hr_all_organization_units_tl.organization_id%TYPE;
  l_progress      VARCHAR2(3) := NULL;
BEGIN
  l_progress := '010';
  l_org_id := GET_VALID_ORG(p_org_id);
  l_progress := '020';
  IF l_org_id IS NULL THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  SET_ORG_CONTEXT(l_org_id);
EXCEPTION
  WHEN OTHERS THEN
     po_message_s.sql_error('po_moac_utils_pvt.mo_init', l_progress, sqlcode);
  RAISE;
END MO_INIT;

-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_CURRENT_ORG_ID
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This function would be used to return current org_id. This function would
-- return the ORG ID set for the current session if the context is set to
-- Single, for Multi-context this function would return NULL. This function
-- is a wrapper that makes a call to MO_GLOBAL.GET_CURRENT_ORG_ID.
--Parameters:
--IN:
--  None.
--IN OUT:
--  None.
--OUT:
--  None.
--Returns:
-- Returns the ORG ID set for the current session if the context is set to
-- Single. Else for Multi-context this function returns NULL.
--Notes:
--
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION GET_CURRENT_ORG_ID
RETURN NUMBER
IS
  l_progress      VARCHAR2(3) := NULL;
BEGIN
  l_progress := '010';
  RETURN MO_GLOBAL.GET_CURRENT_ORG_ID();
EXCEPTION
  WHEN OTHERS THEN
     po_message_s.sql_error('po_moac_utils_pvt.get_current_org_id', l_progress, sqlcode);
  RAISE;
END GET_CURRENT_ORG_ID;

-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_OU_NAME
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This function would return Operating Unit Name for the ORG_ID passed.
--Parameters:
--IN:
--p_org_id
--  This contains the org_id for which the context needs to be set.
--IN OUT:
--  None.
--OUT:
--  None.
--Returns:
-- Returns the Operating Unit name corresponding to the org_id parameter.
-- Returns NULL if the ORG_ID is NULL or invalid.
--Notes:
-- This function is a wrapper that makes call to MO_GLOBAL.GET_OU_NAME.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION GET_OU_NAME
(
  p_org_id        IN        NUMBER
)
RETURN VARCHAR2
IS
--
-- This function would return OU Name for the ORG_ID passed.
-- If the ORG_ID is NULL or invalid, it would return NULL
-- This function is a wrapper that makes call to MO_GLOBAL.GET_OU_NAME
--
-- OU Name could be NULL in case global temp table is not
-- populated, in such cases get the OU name from HR view
-- This is needed for CLP
--
l_ou_name      hr_operating_units.name%TYPE;
  l_progress      VARCHAR2(3) := NULL;

BEGIN
  l_progress := '010';

  l_ou_name := MO_GLOBAL.GET_OU_NAME(p_org_id);

  l_progress := '020';
  IF l_ou_name IS NULL THEN
     SELECT
     hrou.name
     INTO
     l_ou_name
     FROM
     hr_operating_units hrou
     WHERE
     hrou.organization_id = p_org_id;
  END IF;
  l_progress := '030';

  RETURN l_ou_name;

EXCEPTION
  WHEN OTHERS THEN
     po_message_s.sql_error('po_moac_utils_pvt.get_ou_name', l_progress, sqlcode);
  RAISE;
END GET_OU_NAME;

-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_OU_COUNT
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This function would return the number of Operating Units the user currently
-- has access to currently.
--Parameters:
--IN:
--  None.
--IN OUT:
--  None.
--OUT:
--  None.
--Returns:
-- Returns the number of Operating Units the user has access to currently.
--Notes:
-- This function is a wrapper that makes call to MO_GLOBAL.GET_OU_COUNT.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION GET_OU_COUNT
RETURN NUMBER
IS
  l_progress      VARCHAR2(3) := NULL;
BEGIN
  l_progress := '010';
  RETURN MO_GLOBAL.GET_OU_COUNT ();
EXCEPTION
  WHEN OTHERS THEN
     po_message_s.sql_error('po_moac_utils_pvt.get_ou_count', l_progress, sqlcode);
  RAISE;
END GET_OU_COUNT;

-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_DEFAULT_OU
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This procedure should be used to get the default operating unit for a user.
--Parameters:
--IN:
-- None
--IN OUT:
-- None
--OUT:
-- x_default_org_id
--  This will contain the default org_id.
-- x_default_ou_name
--  This will contain the default operating unit name.
-- x_ou_count
--  This will contain the number of operating units the user has access to.
--Notes:
-- This procedure is a wrapper that makes call to MO_GLOBAL.GET_DEFAULT_OU.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE GET_DEFAULT_OU
(
  x_default_org_id  OUT NOCOPY   NUMBER,
  x_default_ou_name OUT NOCOPY   VARCHAR2,
  x_ou_count        OUT NOCOPY   NUMBER
)
IS
  l_progress      VARCHAR2(3) := NULL;
BEGIN
  l_progress := '010';
  MO_UTILS.GET_DEFAULT_OU( x_default_org_id,
                           x_default_ou_name,
                           x_ou_count
                          );
EXCEPTION
  WHEN OTHERS THEN
     po_message_s.sql_error('po_moac_utils_pvt.get_default_ou', l_progress, sqlcode);
  RAISE;
END GET_DEFAULT_OU;

-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_VALID_ORG
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This function should be used to determine and get a valid operating unit.
-- This function checks if the p_org_id that is passed exists in the global
-- temporary table or not. If it does not exist, then it would throw up an
-- error. Before calling this function, global temp table should be populated
-- using MO initialization routine. If the passed org_id exists in the global
-- temporary table, then same is returned. If the p_org_Id is NULL, this
-- function tries to retrieve current org id or gets the default operating unit.
--Parameters:
--IN:
--p_org_id
--  This contains the org_id whose validity needs to be confirmed.
--IN OUT:
--  None.
--OUT:
--  None.
--Returns:
-- Returns the org_id as per validity. Refer details under function section.
--Notes:
-- This function is a wrapper that makes call to MO_GLOBAL.GET_VALID_ORG.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION GET_VALID_ORG
(
  p_org_id  IN  NUMBER
)
RETURN NUMBER
IS
  l_progress      VARCHAR2(3) := NULL;
BEGIN
  l_progress := '010';
  RETURN MO_GLOBAL.GET_VALID_ORG(p_org_id);
EXCEPTION
  WHEN OTHERS THEN
     po_message_s.sql_error('po_moac_utils_pvt.get_valid_org', l_progress, sqlcode);
  RAISE;
END GET_VALID_ORG;

-------------------------------------------------------------------------------
--Start of Comments
--Name: INITIALIZE
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This procedure invokes MO Global initialization routine by passing PO as
-- product short code. This procedure would populate the global temporary
-- table with the operating units that a user has access to.
--Parameters:
--IN:
--  None.
--IN OUT:
--  None.
--OUT:
--  None.
--Notes:
-- This procedure is a wrapper that makes call to MO_GLOBAL.INIT.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE INITIALIZE
IS
  l_progress      VARCHAR2(3) := NULL;
BEGIN
  l_progress := '010';
  MO_GLOBAL.INIT('PO');
EXCEPTION
  WHEN OTHERS THEN
     po_message_s.sql_error('po_moac_utils_pvt.initialize', l_progress, sqlcode);
  RAISE;
END INITIALIZE;

-------------------------------------------------------------------------------
--Start of Comments
--Name: SET_POLICY_CONTEXT
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This procedure is used to initialize org context. If the access mode is S,
-- the context is set to Single and p_Org_id is set as current org_id. If the
-- access mode is M, the context is set to Multiple and then current org_id
-- would be set to NULL.
--Parameters:
--IN:
--p_access_mode
-- This specifies the access mode ( 'S' for Single, 'M' for multiple )
--p_org_id
-- This contains the org_id whose context needs to be set when access mode
-- is Single ('S').
--IN OUT:
--  None.
--OUT:
--  None.
--Notes:
-- This procedure is a wrapper that makes call to MO_GLOBAL.SET_POLICY_CONTEXT.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE SET_POLICY_CONTEXT
(
  p_access_mode    IN    VARCHAR2,
  p_org_id         IN    NUMBER
)
IS
  l_progress      VARCHAR2(3) := NULL;
BEGIN
  l_progress := '010';
  MO_GLOBAL.SET_POLICY_CONTEXT(p_access_mode,p_org_id);
EXCEPTION
  WHEN OTHERS THEN
     po_message_s.sql_error('po_moac_utils_pvt.set_policy_context', l_progress, sqlcode);
  RAISE;
END SET_POLICY_CONTEXT;

-------------------------------------------------------------------------------
--Start of Comments
--Name: CHECK_ACCESS
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This function is used to know if the ORG_ID that is passed has been set in
-- the context and if it is valid or not in the current context. This function
-- checks if the org_id exists in the global temorary table or not, if it is
-- present function returns 'Y', else returns 'N'. Global temporary table gets
-- populated when proper org context is initialized.
--Parameters:
--IN:
--p_org_id
--  This contains the org_id whose accessibility needs to be confirmed.
--IN OUT:
--  None.
--OUT:
--  None.
--Returns:
-- Returns 'Y' or 'N' as per accessibility.
--Notes:
-- This function is a wrapper that makes call to MO_GLOBAL.CHECK_ACCESS.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION CHECK_ACCESS
(
  p_org_id  IN  NUMBER
)
RETURN VARCHAR2
IS
  l_progress      VARCHAR2(3) := NULL;
  l_retval VARCHAR2(1) := 'N';
BEGIN
  l_progress := '010';
  RETURN MO_GLOBAL.CHECK_ACCESS(p_org_id);
  /*IF MO_GLOBAL.get_ou_name(p_org_id) IS NOT NULL THEN
    l_retval := 'Y';
  END IF;
  RETURN l_retval;*/
EXCEPTION
  WHEN OTHERS THEN
     po_message_s.sql_error('po_moac_utils_pvt.check_access', l_progress, sqlcode);
  RAISE;
END CHECK_ACCESS;

-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_OU_SHORTCODE
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This function would return OU Short Code for the ORG_ID passed. If the
-- ORG_ID is NULL or invalid, it would return NULL.
--Parameters:
--IN:
--p_org_id
--  This contains the org_id whose OU short code is required.
--IN OUT:
--  None.
--OUT:
--  None.
--Returns:
-- Returns the OU Short Code corresponding to p_org_id. Returns NULL if the
-- ORG_ID is NULL or invalid.
--Notes:
--
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION GET_OU_SHORTCODE
(
  p_org_id     IN       NUMBER
)
RETURN VARCHAR2
IS
l_ou_short_code    HR_ORGANIZATION_INFORMATION.ORG_INFORMATION5%TYPE;
  l_progress      VARCHAR2(3) := NULL;
BEGIN

  l_progress := '010';
    SELECT HROI.ORG_INFORMATION5
    INTO   l_ou_short_code
    FROM   HR_ORGANIZATION_INFORMATION HROI
    WHERE  HROI.ORGANIZATION_ID = p_org_id
      AND  HROI.ORG_INFORMATION_CONTEXT = 'Operating Unit Information';

  l_progress := '020';
    RETURN l_ou_short_code;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN NULL;
END GET_OU_SHORTCODE;

-------------------------------------------------------------------------------
--Start of Comments
--Name: SET_REQUEST_CONTEXT
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This procedure should be used to set the Operating Unit context for Reports/
-- Concurrent programs that require single OU context.
--Parameters:
--IN:
--p_org_id
--  This contains the org_id whose context needs to be set.
--IN OUT:
--  None.
--OUT:
--  None.
--Notes:
--
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE SET_REQUEST_CONTEXT
(
  p_org_id     IN       NUMBER
)
--
-- This procedure is a wrapper for fnd_request.set_org_id
--
IS
  l_progress      VARCHAR2(3) := NULL;
BEGIN
  l_progress := '010';
  fnd_request.set_org_id(p_org_id);

EXCEPTION
  WHEN OTHERS THEN
     po_message_s.sql_error('po_moac_utils_pvt.set_request_context', l_progress, sqlcode);
  RAISE;
END;


-- Bug 5124686: moved get_entity_org_id to this package from PO_CORE_S
-- Also added support for additional document types
-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_ENTITY_ORG_ID
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This procedure gets the Operating Unit ID for Req/PO/PA/Release entity
-- at any level -> Header/Line/Shipment/Distribution
--Parameters:
--IN:
--p_document_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id
--  Id of the doc level type for which to retrieve org information
--RETURNS:
--  The org_id of the passed in entity
--Notes:
--
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION GET_ENTITY_ORG_ID
(
  p_doc_type IN VARCHAR2
, p_doc_level IN VARCHAR2
, p_doc_level_id IN NUMBER
) RETURN NUMBER
IS
  l_org_id HR_ALL_ORGANIZATION_UNITS.organization_id%type := NULL;
  l_module_name CONSTANT VARCHAR2(100) := 'get_entity_org_id';
  d_module_base CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER := 0;
BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_doc_type', p_doc_type);
    PO_LOG.proc_begin(d_module_base, 'p_doc_level', p_doc_level);
    PO_LOG.proc_begin(d_module_base, 'p_doc_level_id', p_doc_level_id);
  END IF;

  IF p_doc_type = g_doc_type_REQUISITION THEN
    d_progress:=100;

    IF p_doc_level = g_doc_level_HEADER THEN
      d_progress := 110;

      select prh.org_id
      into l_org_id
      from po_requisition_headers_all prh
      where prh.requisition_header_id = p_doc_level_id;

    ELSIF p_doc_level = g_doc_level_LINE THEN
      d_progress := 120;

      select prl.org_id
      into l_org_id
      from po_requisition_lines_all prl
      where prl.requisition_line_id = p_doc_level_id;

    ELSIF p_doc_level = g_doc_level_DISTRIBUTION THEN
      d_progress := 130;

      select prd.org_id
      into l_org_id
      from po_req_distributions_all prd
      where prd.distribution_id = p_doc_level_id;

    END IF;

  ELSE -- doc type is PO/PA/RELEASE
    d_progress := 200;

    IF p_doc_level = g_doc_level_HEADER THEN
      d_progress := 210;

      IF p_doc_type IN (g_doc_type_PO, g_doc_type_PA) THEN
        d_progress := 220;

        SELECT poh.org_id
        INTO l_org_id
        FROM po_headers_all poh
        WHERE poh.po_header_id = p_doc_level_id;

      ELSIF p_doc_type = g_doc_type_RELEASE THEN
        d_progress := 230;

        SELECT por.org_id
        INTO l_org_id
        FROM po_releases_all por
        WHERE por.po_release_id = p_doc_level_id;

      END IF;

    ELSIF p_doc_level = g_doc_level_LINE THEN
      d_progress := 240;

      SELECT pol.org_id
      INTO l_org_id
      FROM po_lines_all pol
      WHERE pol.po_line_id = p_doc_level_id;

    ELSIF p_doc_level = g_doc_level_SHIPMENT THEN
      d_progress := 250;

      SELECT poll.org_id
      INTO l_org_id
      FROM po_line_locations_all poll
      WHERE poll.line_location_id = p_doc_level_id;

    ELSIF p_doc_level = g_doc_level_DISTRIBUTION THEN
      d_progress := 260;

      SELECT pod.org_id
      INTO l_org_id
      FROM po_distributions_all pod
      WHERE pod.po_distribution_id = p_doc_level_id;

    END IF;

  END IF; -- p_doc_type is Requisition or not

  d_progress := 300;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module_base, l_org_id);
  END IF;

  RETURN l_org_id;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base,d_progress,SQLERRM);
    END IF;
    RAISE;
END;
-- <Bug#4581621 Start>
-------------------------------------------------------------------------------
--Start of Comments
--Name: validate_orgid_pub_api
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This procedure is a wrapper on the MO_GLOBAL.validate_orgid_pub_api
--Parameters:
--IN:
--x_org_id
--  Org id which needs to be validated
--Notes:
-- To be used in public API's only for backward compatibilty.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_orgid_pub_api(x_org_id IN OUT NOCOPY  NUMBER)
IS
  l_status     varchar2(1);
  l_module_name CONSTANT VARCHAR2(100) := 'validate_orgid_pub_api';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER := 0;
BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'x_org_id', x_org_id);
  END IF;

  MO_GLOBAL.validate_orgid_pub_api(org_id => x_org_id,
                                   error_mesg_suppr => 'N',
                                   status => l_status);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base, 'x_org_id', x_org_id);
    PO_LOG.proc_end(d_module_base);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base,d_progress,SQLERRM);
    END IF;
    RAISE;
END validate_orgid_pub_api;
-- <Bug#4581621 End>
END PO_MOAC_UTILS_PVT;

/
