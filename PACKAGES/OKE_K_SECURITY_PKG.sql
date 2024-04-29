--------------------------------------------------------
--  DDL for Package OKE_K_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_K_SECURITY_PKG" AUTHID CURRENT_USER AS
/* $Header: OKEKSECS.pls 120.0 2005/05/25 17:55:23 appldev noship $ */
--
-- Global Constants
--
G_EDIT_ACCESS   CONSTANT    VARCHAR2(30) := 'EDIT';
G_VIEW_ACCESS   CONSTANT    VARCHAR2(30) := 'VIEW';
G_NO_ACCESS     CONSTANT    VARCHAR2(30) := 'NONE';

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
) RETURN VARCHAR2;


--
--  Name          : Get_User_K_Access
--  Pre-reqs      : FND_GLOBAL.INITIALIZE
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
) RETURN VARCHAR2;


--
--  Name          : Get_Emp_K_Access
--  Pre-reqs      : FND_GLOBAL.INITIALIZE
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
) RETURN VARCHAR2;


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
) RETURN VARCHAR2;


--
--  Name          : Get_User_K_Role
--  Pre-reqs      : FND_GLOBAL.INITIALIZE
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
) RETURN VARCHAR2;


--
--  Name          : Get_Emp_K_Role
--  Pre-reqs      : FND_GLOBAL.INITIALIZE
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
) RETURN VARCHAR2;


PROCEDURE Set_Assignment_Date
( P_Date             IN    DATE
);

FUNCTION  Get_Assignment_Date
RETURN DATE;

FUNCTION Function_Allowed
( X_Role_ID           IN  NUMBER
, X_Function_Name     IN  VARCHAR2
) RETURN VARCHAR2;

END OKE_K_SECURITY_PKG;

 

/
