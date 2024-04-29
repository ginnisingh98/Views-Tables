--------------------------------------------------------
--  DDL for Package PA_MOAC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MOAC_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAXMOUTS.pls 120.1 2005/06/15 22:03:22 dlanka noship $ */
/* ============================================================================
  Procedure Name: PROCEDURE mo_init_set_context

  DESCRIPTION   : New procedure added for MOAC. This procedure would be invoked by Public APIs
                  to initialize proper multi-org context.

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :


  PARAMETERS    : p_org_id       NUMBER
                  p_product_code      VARCHAR2 DEFAULT 'PA'

  ALGORITHM     : This procedure would be invoked by Public/AMG APIs to initialize
                  and set org context to Single. This procedure checks if the P_ORG_ID
		  passed is valid or not using get_valid_ou function. If it is not
		  valid then error is thrown, else OU context is set to Single
  NOTES         :
=========================================================================== */
PROCEDURE MO_INIT_SET_CONTEXT
(
  p_org_id                     IN OUT NOCOPY  NUMBER ,
  p_product_code               IN  VARCHAR2 DEFAULT 'PA',
  p_msg_count                  OUT NOCOPY NUMBER,
  p_msg_data                   OUT NOCOPY VARCHAR2,
  p_return_status              OUT NOCOPY VARCHAR2
);

-- ==========================================================================
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
  p_org_id          hr_all_organization_units_tl.organization_id%TYPE
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
  p_product_code            IN VARCHAR2  DEFAULT 'PA',
  p_default_org_id     OUT NOCOPY hr_operating_units.organization_id%TYPE,
  p_default_ou_name    OUT NOCOPY hr_operating_units.name%TYPE,
  p_ou_count           OUT NOCOPY NUMBER
);
-- ========================================================================
FUNCTION GET_VALID_OU
(
  p_org_id  hr_operating_units.organization_id%TYPE DEFAULT NULL ,
  p_product_code varchar2  DEFAULT 'PA'
)
RETURN NUMBER ;
--
-- This function should be used to determine and get valid operating unit. This function
-- checks if the p_org_id that is passed exists in the global temporary table or not. If it
-- does not exist, then it would throw up error. Before calling this function, global temp
-- table should be populated using MO initialization routine.
-- If the passed org_id exists in the global temporary table, then same is returned. If the
-- p_org_Id is NULL, this function tries to retrieve current org id or gets the default
-- operating unit
--

PROCEDURE INITIALIZE (p_product_code VARCHAR2  DEFAULT 'PA') ;
--
-- This procedure invokes MO Global initialization routine by passing
-- product short code. This procedure would populate the global temporary table with the
-- operating units that a user has access to.
--

PROCEDURE SET_POLICY_CONTEXT
(
  p_access_mode           VARCHAR2,
  p_org_id                hr_operating_units.organization_id%TYPE
);
--
-- This procedure is used to initialize org context. If the access mode is S, the context
-- is set to Single and p_Org_id is set as current org_id, if the access mode is M, the context
-- is set to Multiple and then current org_id would be set to NULL.
--

FUNCTION CHECK_ACCESS
(
  p_org_id               hr_operating_units.organization_id%TYPE,
  p_product_code VARCHAR2  DEFAULT 'PA'
)
RETURN VARCHAR2;
--
-- This function is used to know if the ORG_ID that is passed has been set in
-- the context and if it is valid or not. This function checks if the org_id exists in the
-- global temorary table or not, if it is present function returns 'Y', else returns 'N'. Global
-- temporary table gets populated when proper org context is initialized.
--

END PA_MOAC_UTILS;

 

/
