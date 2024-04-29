--------------------------------------------------------
--  DDL for Package PO_MOAC_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_MOAC_UTILS_PVT" AUTHID CURRENT_USER AS
/*$Header: POXVMOUS.pls 120.3 2006/08/23 08:17:41 arudas noship $*/

-----------------------------------------------------------------------------
-- Public variables
-----------------------------------------------------------------------------

-- Document types

g_doc_type_REQUISITION           CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := 'REQUISITION'
   ;
g_doc_type_PO                    CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := 'PO'
   ;
g_doc_type_PA                    CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := 'PA'
   ;
g_doc_type_RELEASE               CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := 'RELEASE'
   ;


-- Document levels

g_doc_level_HEADER               CONSTANT
   VARCHAR2(30)
   := 'HEADER'
   ;
g_doc_level_LINE                 CONSTANT
   VARCHAR2(30)
   := 'LINE'
   ;
g_doc_level_SHIPMENT             CONSTANT
   VARCHAR2(30)
   := 'SHIPMENT'
   ;
g_doc_level_DISTRIBUTION         CONSTANT
   VARCHAR2(30)
   := 'DISTRIBUTION'
   ;


/* ===========================================================================
  PROCEDURE NAME: set_org_context ( p_org_id        NUMBER      DEFAULT NULL )

  DESCRIPTION   : This procedure would be used to set the Org Context.
                  This procedure replaces setting of ORG Context using FND CLIENT INFO
		  or DBMS APPLICATION INFO calls. This procedure first checks if the
		  global temp table is already populated or not, if it is not populated
		  it would invoke initialize routine and then set the org context to
		  single and set current ou to the p_org_id.


  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : Kirti Pal Singh

  PARAMETERS    : p_org_id       NUMBER

  ALGORITHM     : Check for the current orgid. If p_org_id does not match with the
                  current org_id call the initialize routine.
		  Then set the policy context to the p_org_id.

  NOTES         :

=========================================================================== */

PROCEDURE set_org_context
(
  p_org_id         IN      NUMBER      DEFAULT NULL
);

/* ============================================================================
  Procedure Name: PROCEDURE mo_init

  DESCRIPTION   : New procedure added for MOAC. This procedure would be invoked by Public APIs
                  to initialize proper multi-org context.

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : Kirti Pal Singh

  PARAMETERS    : p_org_id       NUMBER

  ALGORITHM     : This procedure would be invoked by Public APIs to initialize
                  proper multi-org context. This procedure checks if the P_ORG_ID
		  passed is valid or not using get_valid_org function. If it is not
		  valid then error is thrown, else OU context is set to Single and
		  current OU is set to P_ORG_ID. If p_org_id is NULL, then the
		  get_valid_org routine would derive either current OU or default
		  OU and return this value. Again context is set to single and
		  current OU is set to the value returned from get_valid_org if
		  there is no existing context(in case of default OU).

  NOTES         :
=========================================================================== */
PROCEDURE MO_INIT
(
  p_org_id       IN         NUMBER      DEFAULT NULL
);

FUNCTION GET_CURRENT_ORG_ID
RETURN NUMBER;
--
-- This function would return the ORG ID set for the current session
-- if the context is set to Single, for Multi-context this function
-- would return NULL. This function is a wrapper that makes call to
-- MO_GLOBAL.GET_CURRENT_ORG_ID
--

FUNCTION GET_OU_NAME
(
  p_org_id    IN      NUMBER
)
RETURN VARCHAR2;
--
-- This function would return OU Name for the ORG_ID passed.
-- If the ORG_ID is NULL or invalid, it would return NULL
-- This function is a wrapper that makes call to MO_GLOBAL.GET_OU_NAME
--

FUNCTION GET_OU_COUNT
RETURN NUMBER;
--
-- This function would return count of Operating Units a user has access to.
-- It would return 0 in case there is no access or context is not set. This
-- function is a wrapper that makes call to MO_GLOBAL.GET_OU_COUNT
--

PROCEDURE GET_DEFAULT_OU
(
  x_default_org_id     OUT NOCOPY NUMBER,
  x_default_ou_name    OUT NOCOPY VARCHAR2,
  x_ou_count           OUT NOCOPY NUMBER
);
--
-- This procedure should be used to get the default operating unit for a user
-- This is a wrapper procedure that invokes call to MO_UTILS.GET_DEFAULT_OU
--

FUNCTION GET_VALID_ORG
(
  p_org_id  IN  NUMBER
)
RETURN NUMBER;
--
-- This function should be used to determine and get valid operating unit. This function
-- checks if the p_org_id that is passed exists in the global temporary table or not. If it
-- does not exist, then it would throw up error. Before calling this function, global temp
-- table should be populated using MO initialization routine.
-- If the passed org_id exists in the global temporary table, then same is returned. If the
-- p_org_Id is NULL, this function tries to retrieve current org id or gets the default
-- operating unit
--

PROCEDURE INITIALIZE;
--
-- This procedure invokes MO Global initialization routine by passing PO as
-- product short code. This procedure would populate the global temporary table with the
-- operating units that a user has access to.
--

PROCEDURE SET_POLICY_CONTEXT
(
  p_access_mode     IN      VARCHAR2,
  p_org_id          IN      NUMBER
);
--
-- This procedure is used to initialize org context. If the access mode is S, the context
-- is set to Single and p_Org_id is set as current org_id, if the access mode is M, the context
-- is set to Multiple and then current org_id would be set to NULL.
--

FUNCTION CHECK_ACCESS
(
  p_org_id       IN        NUMBER
)
RETURN VARCHAR2;
--
-- This function is used to know if the ORG_ID that is passed has been set in
-- the context and if it is valid or not. This function checks if the org_id exists in the
-- global temorary table or not, if it is present function returns 'Y', else returns 'N'. Global
-- temporary table gets populated when proper org context is initialized.
--

FUNCTION GET_OU_SHORTCODE
(
  p_org_id     IN      NUMBER
)
RETURN VARCHAR2;
--
-- This function would return OU Short Code for the ORG_ID passed.
-- If the ORG_ID is NULL or invalid, it would return NULL
--

PROCEDURE SET_REQUEST_CONTEXT
(
  p_org_id     IN      NUMBER
);
--
-- This procedure is a wrapper for fnd_request.set_org_id
--

-- Bug 5124686: moved get_entity_org_id to this package from PO_CORE_S
-- Also added support for additional document types
FUNCTION GET_ENTITY_ORG_ID
(
  p_doc_type IN VARCHAR2
, p_doc_level IN VARCHAR2
, p_doc_level_id IN NUMBER
) RETURN NUMBER;
--
-- Returns the org_id of the passed-in entity
--

PROCEDURE validate_orgid_pub_api(x_org_id IN OUT NOCOPY  NUMBER);-- <Bug#4581621>

END PO_MOAC_UTILS_PVT;

 

/
