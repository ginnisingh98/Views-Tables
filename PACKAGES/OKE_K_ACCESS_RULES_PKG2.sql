--------------------------------------------------------
--  DDL for Package OKE_K_ACCESS_RULES_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_K_ACCESS_RULES_PKG2" AUTHID CURRENT_USER as
/* $Header: OKEKAR2S.pls 115.6 2002/11/19 22:58:11 jxtang ship $ */

--
--  Name          : Compile_Rules
--  Pre-reqs      : FND_GLOBAL.INITIALIZE
--  Function      : This function compiles access rules for the
--                  given contract role.
--
--  Parameters    :
--  IN            : X_ROLE_ID            NUMBER
--  OUT           : None
--
--  Returns       : BOOLEAN
--

FUNCTION Compile_Rules
( X_Role_ID                 IN        VARCHAR2
) RETURN BOOLEAN;


--
--  Name          : Copy_Rules
--  Pre-reqs      : FND_GLOBAL.INITIALIZE
--  Function      : This function copies access rules from the
--                  source role to the target role.
--
--  Parameters    :
--  IN            : X_ROLE_ID            NUMBER
--  OUT           : None
--
--  Returns       : BOOLEAN
--

FUNCTION Copy_Rules
( X_Source_Role_ID          IN        VARCHAR2
, X_Target_Role_ID          IN        VARCHAR2
, X_Copy_Option             IN        VARCHAR2
) RETURN BOOLEAN;


--
--  Name          : Compile
--  Pre-reqs      : Invoke from Concurrent Manager
--  Function      : This PL/SQL concurrent program compiles
--                  access rules for all contract roles or
--                  a specific role.
--
--  Parameters    :
--  IN            : X_ROLE_ID            NUMBER
--  OUT           : ERRBUF               VARCHAR2
--                  RETCODE              NUMBER
--
--  Returns       : None
--

PROCEDURE Compile
( ERRBUF                    OUT NOCOPY       VARCHAR2
, RETCODE                   OUT NOCOPY       NUMBER
, X_ROLE_ID                 IN        NUMBER   DEFAULT NULL
);

end OKE_K_ACCESS_RULES_PKG2;

 

/
