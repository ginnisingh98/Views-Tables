--------------------------------------------------------
--  DDL for Package Body PA_MOAC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MOAC_UTILS" AS
-- $Header: PAXMOUTB.pls 120.5 2006/02/15 10:12:38 dlanka noship $

-- **************************************************************** /
-- Function to check Projects implementations for an ORG_ID
-- Returns 'TURE' if PA is implemented or FALSE if not.
-- ---------------------------------------------------------------
Function pa_implemented (x_org_id number) return boolean is
	l_var varchar2 (1);
Begin

select '1'
into l_var
from dual
where exists (select ORG_ID
              from pa_implementations_all
             where org_id = x_org_id);

return TRUE;
Exception
when no_data_found then
 return FALSE;
when others then
 return FALSE ;

end pa_implemented ;

-- ****************************************************************/
FUNCTION GET_OU_COUNT RETURN NUMBER IS

-- This function would return count of Operating Units a user has access to.
-- It would return 0 in case there is no access or initialization is not done.
--
BEGIN
  RETURN MO_GLOBAL.GET_OU_COUNT;
END GET_OU_COUNT;

-- ****************************************************************/
FUNCTION GET_VALID_OU
( p_org_id  hr_operating_units.organization_id%TYPE DEFAULT NULL , p_product_code VARCHAR2  )
RETURN NUMBER
--
-- This function is used to determine and get valid operating unit where Projects is implmented.
-- Returns ORG_ID if valid and PA is implemneted or retruns NULL if invalid or PA is not implemented.

-- This function uses  MO_GLOBAL.GET_VALID_ORG(p_org_id) to get valid org_id.
-- MO_GLOBAL.GET_VALID_ORG gets org_id in the following order if p_org_id IS NULL
--   1. get_current_org_id
--   2. get_default_org_id

-- MO_GLOBAL.GET_VALID_ORG retruns p_org_id if Valid or returns NULL if invalid .
-- If p_org_id  does not exist in Global table, then it would throw up error.
-- Before calling this function, global temp table should be populated using MO initialization routine.

IS
 l_org_id NUMBER ;
 l_status  VARCHAR2(1);

BEGIN
   l_org_id := p_org_id ;

 -- Replacing this call with mo_global.validate_orgid_pub_api
 -- provided by MOAC team
 --   l_org_id :=  MO_GLOBAL.GET_VALID_ORG(p_org_id);

 -- VALIDATE_ORGID_PUB_API will retrun either
 -- Success ( 'S','O','C','D') or Failure ( 'F')

      mo_global.validate_orgid_pub_api( l_org_id, 'Y',l_status );

 -- Checking if Projects is implemented or not

  If l_org_id is not null and l_status IN ( 'S','O','C','D')  then
       If p_product_code = 'PA' then
          If  pa_implemented (l_org_id) then
             RETURN l_org_id ;
          else
             RETURN NULL  ;
          end if ;
       elsif p_product_code = 'GMS' then
          If gms_install.enabled(l_org_id) then
             RETURN l_org_id ;
          else
             RETURN NULL  ;
          end if;
       End if ;
  else
   RETURN NULL  ;
  End if ;

END GET_VALID_OU;

/*-- -------------------------------------------------------------------------------
  Procedure Name: PROCEDURE mo_init_set_context

  DESCRIPTION   : New procedure added for MOAC. This procedure would be invoked by Public APIs
                  to initialize proper multi-org context.

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  PARAMETERS    : p_org_id     IN OUT NOCOPY NUMBER
                : p_product_code  IN  Default 'PA'
                : p_msg_count     OUT NOCOPY NUMBER,
                : p_msg_data      OUT NOCOPY VARCHAR2,
                : p_return_status OUT NOCOPY  ( 'S' -- Success , 'F' -- failure, 'U' -- unexpected )

  ALGORITHM     : This procedure would be invoked by Public/AMG APIs to initialize
                  and set org context. This procedure checks if the P_ORG_ID
 		  passed is valid or not using get_valid_ou function. If it is not
		  valid then error is thrown, else OU context is set to Single .
  NOTES         :

-- ****************************************************************/

PROCEDURE MO_INIT_SET_CONTEXT(p_org_id           IN OUT NOCOPY  NUMBER
                             , p_product_code    IN     VARCHAR2 DEFAULT 'PA'
                             , p_msg_count       OUT NOCOPY NUMBER
                             , p_msg_data        OUT NOCOPY VARCHAR2
                             , p_return_status   OUT NOCOPY VARCHAR2 ) IS

BEGIN
   p_return_status := 'S' ;
 -- Conditionally doing MO intialization
  If NVL(mo_global.get_ou_count, 0)  = 0  then -- Fix for bug : 5037365
    MO_GLOBAL.INIT(p_product_code);
  end if ;

  If p_org_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM then
     p_org_id := FND_API.G_MISS_NUM ;
  end if ;
     p_org_id := GET_VALID_OU(p_org_id, p_product_code);

    IF p_org_id IS NULL THEN
       FND_MSG_PUB.Initialize;

      p_return_status := FND_API.G_RET_STS_ERROR;

	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

		FND_MESSAGE.SET_NAME('PA','PA_MOAC_PASS_VALID_ORG');
		FND_MSG_PUB.add;
		FND_MSG_PUB.Count_And_Get
				(   p_count  =>	p_msg_count 	,
				    p_data   =>	p_msg_data	);
	END IF;
    else
        MO_GLOBAL.SET_POLICY_CONTEXT('S',p_org_id);
    END IF;
END MO_INIT_SET_CONTEXT;


-- **************************************************************** /
-- FUNCTION GET_CURRENT_ORG_ID : This function would return the ORG ID set
-- for the current session if the context is set to Single, for Multi-context
-- this function would return NULL. This function is a wrapper that makes
-- call to MO_GLOBAL.GET_CURRENT_ORG_ID.

FUNCTION GET_CURRENT_ORG_ID
RETURN NUMBER
IS
BEGIN
  RETURN MO_GLOBAL.GET_CURRENT_ORG_ID;
END GET_CURRENT_ORG_ID;

-- ***********************************************************************

FUNCTION GET_OU_NAME
(
  p_ORG_ID                hr_all_organization_units_tl.organization_id%TYPE
)
RETURN VARCHAR2
IS
--
-- This function would return OU Name for the ORG_ID passed.
-- If the ORG_ID is NULL or invalid, it would return NULL
-- This function is a wrapper that makes call to MO_GLOBAL.GET_OU_NAME
--
BEGIN
  RETURN MO_GLOBAL.GET_OU_NAME(p_org_id);
END GET_OU_NAME;

-- ****************************************************************/
PROCEDURE GET_DEFAULT_OU
(
  p_product_code            IN VARCHAR2  DEFAULT 'PA',
  p_default_org_id     OUT NOCOPY hr_operating_units.organization_id%TYPE,
  p_default_ou_name    OUT NOCOPY hr_operating_units.name%TYPE,
  p_ou_count           OUT NOCOPY NUMBER
) IS
--
-- This procedure should be used to get the default operating unit for a user
-- using MO_UTILS.GET_DEFAULT_OU.Also verifies whether Projects is implemented or not.
-- If Projects is not implemented returns NULL for default org_id and Name
--
--NOTE :
--=====

   --Here we need to check whether Projects is implemented for that OU

 l_default_org_id hr_operating_units.organization_id%TYPE  ;
 l_default_ou_name hr_operating_units.name%TYPE  ;
 l_ou_count NUMBER ;
BEGIN
  MO_UTILS.GET_DEFAULT_OU( l_default_org_id,
                           l_default_ou_name,
			   l_ou_count
			 );

   If l_default_org_id IS NOT NULL then
        if p_product_code = 'PA' then
          if  pa_implemented(l_default_org_id) then
              p_default_org_id := l_default_org_id ;
              p_default_ou_name := l_default_ou_name ;
              p_ou_count := l_ou_count ;
          else
              p_default_org_id := NULL;
              p_default_ou_name := NULL ;
              p_ou_count := l_ou_count ;
          end if ;
        elsif p_product_code = 'GMS' then
         if   gms_install.enabled(l_default_org_id) then
              p_default_org_id := l_default_org_id ;
              p_default_ou_name := l_default_ou_name ;
              p_ou_count := l_ou_count ;
          else
              p_default_org_id := NULL;
              p_default_ou_name := NULL ;
              p_ou_count := l_ou_count ;
          end if ;
       end if;
   else
              p_default_org_id := NULL;
              p_default_ou_name := NULL ;
              p_ou_count := l_ou_count ;
   end if;

END GET_DEFAULT_OU;

-- ****************************************************************/
PROCEDURE INITIALIZE(p_product_code  VARCHAR2 DEFAULT 'PA')
--
-- This procedure invokes MO Global initialization routine by passing PA as
-- product short code. This procedure would populate the global temporary table with the
-- operating units that a user has access to.
--
IS
BEGIN
  MO_GLOBAL.INIT(p_product_code);
END INITIALIZE;
-- ****************************************************************/
PROCEDURE SET_POLICY_CONTEXT
(
  p_access_mode      VARCHAR2,
  p_org_id           hr_operating_units.organization_id%TYPE
)
IS
--
-- This procedure is used to initialize org context. If the access mode is S, the context
-- is set to Single and p_Org_id is set as current org_id, if the access mode is M, the context
-- is set to Multiple and then current org_id would be set to NULL.
--
BEGIN
  IF p_access_mode ='S' THEN
     MO_GLOBAL.SET_POLICY_CONTEXT('S',p_org_id);
  ELSIF p_access_mode = 'M' THEN
     MO_GLOBAL.SET_POLICY_CONTEXT('M',NULL);
  END IF;
END SET_POLICY_CONTEXT;

-- ****************************************************************/

FUNCTION CHECK_ACCESS
(
  p_org_id  hr_operating_units.organization_id%TYPE, p_product_code  varchar2 DEFAULT 'PA')
RETURN VARCHAR2
-- This function checks if the org_id exists in the
-- global temorary table or not, if it is present function returns 'Y', else returns 'N'.
-- Global temporary table gets populated if MOAC is initialized.
--
IS
 l_access VARCHAR(1) ;
BEGIN
    l_access :=  MO_GLOBAL.CHECK_ACCESS(p_org_id);
    If l_access = 'N' then
       RETURN l_access ;
    else
      if  p_product_code = 'PA' then
          If pa_implemented( p_org_id) then
            Return l_access ;
          else Return 'N';
          end if;
      elsif  p_product_code = 'GMS' then
          if gms_install.enabled(p_org_id) then
          Return l_access ;
          else Return 'N';
          end if;
      end if ;
    end if ;

END CHECK_ACCESS;
-- ****************************************************************/
END PA_MOAC_UTILS;

/
