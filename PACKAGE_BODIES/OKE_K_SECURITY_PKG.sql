--------------------------------------------------------
--  DDL for Package Body OKE_K_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_K_SECURITY_PKG" AS
/* $Header: OKEKSECB.pls 120.2 2005/11/07 18:26:52 ifilimon noship $ */

--
-- Private Global Cached Variables
--
G_A_Hdr_ID      NUMBER       := NULL;
G_A_User_ID     NUMBER       := NULL;
G_A_Emp_ID      NUMBER       := NULL;
G_Access_Level  VARCHAR2(30) := NULL;
G_R_Hdr_ID      NUMBER       := NULL;
G_R_User_ID     NUMBER       := NULL;
G_R_Emp_ID      NUMBER       := NULL;
G_Role_ID       NUMBER       := NULL;
G_Assignment_Date DATE       := NULL;

--
-- Private Global Cursors
--
CURSOR G_Emp_CSR ( C_User_ID NUMBER ) IS
  SELECT employee_id
  FROM   fnd_user
  WHERE  user_id = C_User_ID;

CURSOR G_Owner_CSR ( C_K_Header_ID NUMBER
                   , C_User_ID     NUMBER )
IS
  SELECT decode(count(1),1,'EDIT','NONE')
  FROM   okc_k_headers_all_b
  WHERE  id = C_K_Header_ID
  AND    created_by = C_User_ID;

--
--  Name          : Get_K_Access
--  Pre-reqs      : FND_GLOBAL.INITIALIZE
--  Function      : This function returns the access level of
--                  the current user for the given contract
--
--  Parameters    :
--  IN            : P_K_HEADER_ID        NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2
--
--  Note          : The return value is cached for performance
--                  reasons.  If you need to have real-time
--                  information, you should use the functions
--                  Get_User_K_Access() or Get_Emp_K_Access() instead.
--

FUNCTION Get_K_Access
( P_K_Header_ID      IN    NUMBER
) RETURN VARCHAR2 IS

BEGIN
  --
  -- If input parameter is not given, there is no need to go any
  -- further.
  --
  IF ( P_K_Header_ID IS NULL ) THEN
    RETURN ( NULL );
  END IF;

  --
  -- The input and output are all cached into global variables to
  -- speed up repeated lookups.  If the input parameters of the
  -- current lookup matches the input parameters of the previous
  -- lookup, the cached result will be used instead of hitting the DB
  -- again.
  --
  IF (  G_Access_Level IS NULL
     OR G_A_User_ID <> FND_GLOBAL.User_ID
     OR G_A_Hdr_ID <> P_K_Header_ID ) THEN
    --
    -- No cache output or input parameters have changed; recache
    --
    G_Access_Level := Get_Emp_K_Access ( P_K_Header_ID
                                       , OKE_UTILS.Curr_Emp_ID );
    G_A_Hdr_ID     := P_K_Header_ID;
    G_A_User_ID    := FND_GLOBAL.User_ID;

    IF ( G_Access_Level = G_NO_ACCESS ) THEN
      --
      -- Current user is not defined in contract role, check to
      -- see if he/she is the creator of the record
      --
      OPEN G_Owner_CSR ( G_A_Hdr_ID , G_A_User_ID );
      FETCH G_Owner_CSR INTO G_Access_Level;
      CLOSE G_Owner_CSR;

    END IF;

  END IF;

  RETURN ( G_Access_Level );

EXCEPTION
  WHEN OTHERS THEN
    RETURN ( NULL );

END;


--
--  Name          : Get_User_K_Access
--  Pre-reqs      : None
--  Function      : This function returns the access level of
--                  the given user for the given contract
--
--  Parameters    :
--  IN            : K_HEADER_ID        NUMBER
--                  K_USER_ID          NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Get_User_K_Access
( P_K_Header_ID      IN    NUMBER
, P_User_ID          IN    NUMBER
) RETURN VARCHAR2 IS

  L_Emp_ID        NUMBER;
  L_Access_Level  VARCHAR2(30);

BEGIN
  --
  -- If input parameter is not given, there is no need to go any
  -- further.
  --
  IF ( P_K_Header_ID IS NULL OR NVL(P_User_ID , -1) = -1 ) THEN
    RETURN ( NULL );
  END IF;

  L_Emp_ID := NULL;

  --
  -- Getting employee information for the given user from FND_USER.
  -- Access information are kept by employees.
  --
  OPEN G_Emp_CSR ( P_User_ID );
  FETCH G_Emp_CSR INTO L_Emp_ID;
  CLOSE G_Emp_CSR;

  --
  -- If employee is not linked to the user, stop here.
  --
  IF ( L_Emp_ID IS NULL ) THEN
    RETURN ( NULL );
  END IF;

  L_Access_Level := Get_Emp_K_Access ( P_K_Header_ID , L_Emp_ID );

  IF ( L_Access_Level = G_NO_ACCESS ) THEN
    --
    -- Current user is not defined in contract role, check to
    -- see if he/she is the creator of the record
    --
    OPEN G_Owner_CSR ( P_K_Header_ID , P_User_ID );
    FETCH G_Owner_CSR INTO L_Access_Level;
    CLOSE G_Owner_CSR;
  END IF;

  RETURN ( L_Access_Level );

EXCEPTION
  WHEN OTHERS THEN
    RETURN ( NULL );

END Get_User_K_Access;


--
--  Name          : Get_Emp_K_Access
--  Pre-reqs      : None
--  Function      : This function returns the access level of
--                  the given employee for the given contract
--
--  Parameters    :
--  IN            : P_K_HEADER_ID      NUMBER
--                  P_EMP_ID           NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Get_Emp_K_Access
( P_K_Header_ID      IN    NUMBER
, P_Emp_ID           IN    NUMBER
) RETURN VARCHAR2 IS

  CURSOR csr ( C_Role_ID NUMBER )
  IS
    SELECT default_access_level
    FROM   pa_project_role_types prt
    WHERE  prt.project_role_id = C_Role_ID;

  L_Access_Level  VARCHAR2(30);
  L_Role_ID       NUMBER;

BEGIN
  --
  -- If input parameter is not given, there is no need to go any
  -- further.
  --
  IF ( P_K_Header_ID IS NULL OR P_Emp_ID IS NULL ) THEN
    RETURN ( NULL );
  END IF;

  --
  -- First get the contract role for the given employee and
  -- contract.
  --
  L_Role_ID := Get_Emp_K_Role ( P_K_Header_ID , P_Emp_ID );

  --
  -- If No role is found, the employee is not allowed to access
  -- the contract.
  --
  IF ( L_Role_ID IS NULL ) THEN
    RETURN( G_NO_ACCESS );
  END IF;

  --
  -- Now, get the default access level from the role definition.
  --
  OPEN csr ( L_Role_ID );
  FETCH csr INTO L_Access_Level;

  --
  -- There is a weird situation; the employee is assigned a certain
  -- role but the role does not exist.  It probably means a role is
  -- deleted by mistake.
  --
  IF ( csr%notfound ) THEN
    CLOSE csr;
    L_Access_Level := G_NO_ACCESS;
  ELSE
    CLOSE csr;
  END IF;

  RETURN ( L_Access_Level );

EXCEPTION
  WHEN OTHERS THEN
    RETURN ( NULL );

END Get_Emp_K_Access;


--
--  Name          : Get_K_Role
--  Pre-reqs      : FND_GLOBAL.INITIALIZE
--  Function      : This function returns the role of the
--                  current user for the given contract
--
--  Parameters    :
--  IN            : P_K_HEADER_ID        NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2
--
--  Note          : The return value is cached for performance
--                  reasons.  If you need to have real-time
--                  information, you should use the functions
--                  Get_User_K_Access() or Get_Emp_K_Access() instead.
--

FUNCTION Get_K_Role
( P_K_Header_ID      IN    NUMBER
) RETURN VARCHAR2 IS

BEGIN
  --
  -- If input parameter is not given, there is no need to go any
  -- further.
  --
  IF ( P_K_Header_ID IS NULL ) THEN
    RETURN ( NULL );
  END IF;

  --
  -- The input and output are all cached into global variables to
  -- speed up repeated lookups.  If the input parameters of the
  -- current lookup matches the input parameters of the previous
  -- lookup, the cached result will be used instead of hitting the DB
  -- again.
  --
  IF (  G_Role_ID IS NULL
     OR G_R_User_ID <> FND_GLOBAL.User_ID
     OR G_R_Hdr_ID <> P_K_Header_ID ) THEN
    --
    -- No cache output or input parameters have changed; recache
    --
    G_Role_ID   := Get_Emp_K_Role ( P_K_Header_ID
                                  , OKE_UTILS.Curr_Emp_ID );
    G_R_Hdr_ID  := P_K_Header_ID;
    G_R_User_ID := FND_GLOBAL.User_ID;

  END IF;

  RETURN ( G_Role_ID );

EXCEPTION
  WHEN OTHERS THEN
    RETURN ( NULL );

END Get_K_Role;


--
--  Name          : Get_User_K_Role
--  Pre-reqs      : None
--  Function      : This function returns the role of the
--                  given user for the given contract
--
--  Parameters    :
--  IN            : K_HEADER_ID        NUMBER
--                  K_USER_ID          NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Get_User_K_Role
( P_K_Header_ID      IN    NUMBER
, P_User_ID          IN    NUMBER
) RETURN VARCHAR2 IS

  L_Emp_ID NUMBER;

BEGIN
  --
  -- If input parameter is not given, there is no need to go any
  -- further.
  --
  IF ( P_K_Header_ID IS NULL OR NVL(P_User_ID , -1) = -1 ) THEN
    RETURN ( NULL );
  END IF;

  L_Emp_ID := NULL;

  --
  -- Getting employee information for the given user from FND_USER.
  -- Access information are kept by employees.
  --
  OPEN G_Emp_CSR ( P_User_ID );
  FETCH G_Emp_CSR INTO L_Emp_ID;
  CLOSE G_Emp_CSR;

  --
  -- If employee is not linked to the user, stop here.
  --
  IF ( L_Emp_ID IS NULL ) THEN
    RETURN ( NULL );
  END IF;

  RETURN ( Get_Emp_K_Role ( P_K_Header_ID , L_Emp_ID ) );

EXCEPTION
  WHEN OTHERS THEN
    RETURN ( NULL );

END Get_User_K_Role;


--
--  Name          : Get_Emp_K_Role
--  Pre-reqs      : None
--  Function      : This function returns the role of the
--                  given employee for the given contract
--
--  Parameters    :
--  IN            : P_K_HEADER_ID      NUMBER
--                  P_EMP_ID           NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Get_Emp_K_Role
( P_K_Header_ID      IN    NUMBER
, P_Emp_ID           IN    NUMBER
) RETURN VARCHAR2 IS

  CURSOR csr ( C_K_Header_ID NUMBER
             , C_Emp_ID      NUMBER )
  IS
/*
  This version somehow results in FTS

    SELECT project_role_id
    FROM   pa_project_parties pp
    ,      oke_k_headers kh
    WHERE  kh.k_header_id = C_K_Header_ID
    AND (  (   pp.object_type = 'OKE_K_HEADERS'
           AND pp.object_id   = kh.k_header_id
           )
        OR (   pp.object_type = 'OKE_PROGRAMS'
           AND pp.object_id in (kh.program_id , 0)
           )
        )
    AND    pp.resource_type_id = 101
    AND    pp.resource_source_id = C_Emp_ID
    AND    sysdate
           BETWEEN nvl( pp.start_date_active , sysdate - 1)
           AND     nvl( pp.end_date_active , sysdate + 1)
*/
    --
    -- First part of the union retrieves contract level as well as
    -- site level assignment
    --
    SELECT Project_Role_ID
    ,      decode(pp.object_type, 'OKE_K_HEADERS', 1, 3) Sort_Order
    FROM   pa_project_parties pp
    WHERE  ( pp.object_type , pp.object_id ) IN
           ( ( 'OKE_K_HEADERS' , C_K_Header_ID )
           , ( 'OKE_PROGRAMS'  , 0 )
           )
    AND    pp.resource_type_id = 101
    AND    pp.resource_source_id = C_Emp_ID
    AND    trunc(sysdate)
           BETWEEN nvl( trunc(pp.start_date_active) , trunc(sysdate) - 1)
           AND     nvl( trunc(pp.end_date_active) , trunc(sysdate) + 1)
    UNION ALL
    --
    -- Second part of the union retrieves program level assignment.
    -- This is separated from the first part because it requires a
    -- join to OKE_K_HEADERS and for some reason the combined SELECT
    -- results in a FTS of PA_PROJECT_PARTIES.
    --
    SELECT Project_Role_ID
    ,      2
    FROM   pa_project_parties pp
    ,      oke_k_headers kh
    WHERE  kh.k_header_id = C_K_Header_ID
    AND    pp.object_type = 'OKE_PROGRAMS'
    AND    pp.object_id = kh.program_id
    AND    pp.resource_type_id = 101
    AND    pp.resource_source_id = C_Emp_ID
    AND    trunc(sysdate)
           BETWEEN nvl( trunc(pp.start_date_active) , trunc(sysdate) - 1)
           AND     nvl( trunc(pp.end_date_active) , trunc(sysdate) + 1)
    ORDER BY 2;

  L_Role_ID  NUMBER;
  L_Dummy    NUMBER;

BEGIN
  --
  -- If input parameter is not given, there is no need to go any
  -- further.
  --
  IF ( P_K_Header_ID IS NULL OR P_Emp_ID IS NULL ) THEN
    RETURN ( NULL );
  END IF;

  OPEN csr ( P_K_Header_ID , P_Emp_ID );
  FETCH csr INTO L_Role_ID , L_Dummy;
  CLOSE csr;

  RETURN ( L_Role_ID );

EXCEPTION
  WHEN OTHERS THEN
    RETURN ( NULL );

END Get_Emp_K_Role;


PROCEDURE Set_Assignment_Date
( P_Date             IN    DATE
) IS

BEGIN

  G_Assignment_Date := P_Date;

END Set_Assignment_Date;


FUNCTION  Get_Assignment_Date
RETURN DATE IS
BEGIN

  IF ( G_Assignment_Date IS NULL ) THEN
    RETURN TRUNC(SYSDATE);
  ELSE
    RETURN G_Assignment_Date;
  END IF;

END Get_Assignment_Date;

FUNCTION Function_Allowed
( X_Role_ID           IN  NUMBER
, X_Function_Name     IN  VARCHAR2
) RETURN VARCHAR2 IS

  flag VARCHAR2(1) := 'F';

  CURSOR c1 IS
    SELECT 'T'
    FROM   fnd_form_functions    ff
    ,      fnd_menu_entries      me
    ,      pa_project_role_types prt
    WHERE  prt.project_role_id = X_Role_ID
      AND  me.menu_id = prt.menu_id
      AND  me.grant_flag = 'Y'
      AND  ff.function_id = me.function_id
      AND  ff.function_name = X_Function_Name;

  BEGIN

    OPEN c1;
    FETCH c1 INTO flag;
    CLOSE c1;

    return flag;

  END Function_Allowed;



END OKE_K_SECURITY_PKG;

/
