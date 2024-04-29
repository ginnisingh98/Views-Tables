--------------------------------------------------------
--  DDL for Package PSB_CONCURRENCY_CONTROL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_CONCURRENCY_CONTROL_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVCCLS.pls 120.2 2005/07/13 11:23:49 shtripat ship $ */

/* ----------------------------------------------------------------------- */

  --    API name        : Enforce_Concurrency_Control
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 05/18/1997 by Supriyo Ghosh
  --
  --    Notes           : Enforce Concurrency Control
  --

PROCEDURE Enforce_Concurrency_Control
( p_api_version              IN   NUMBER,
  p_validation_level         IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status            OUT  NOCOPY  VARCHAR2,
  p_concurrency_class        IN   VARCHAR2,
  p_concurrency_entity_name  IN   VARCHAR2,
  p_concurrency_entity_id    IN   NUMBER
);

PROCEDURE Release_Concurrency_Control(
  p_api_version              IN   NUMBER,
  p_validation_level         IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status            OUT  NOCOPY  VARCHAR2,
  p_concurrency_class        IN   VARCHAR2,
  p_concurrency_entity_name  IN   VARCHAR2,
  p_concurrency_entity_id    IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Get_Debug
  --    Type            : Private
  --    Pre-reqs        : None

FUNCTION Get_Debug RETURN VARCHAR2;

/* ----------------------------------------------------------------------- */


END PSB_CONCURRENCY_CONTROL_PVT;

 

/
