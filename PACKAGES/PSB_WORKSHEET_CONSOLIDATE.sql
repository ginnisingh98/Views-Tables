--------------------------------------------------------
--  DDL for Package PSB_WORKSHEET_CONSOLIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WORKSHEET_CONSOLIDATE" AUTHID CURRENT_USER AS
/* $Header: PSBVWCDS.pls 120.2 2005/07/13 11:30:29 shtripat ship $ */

/* ----------------------------------------------------------------------- */

PROCEDURE Consolidate_Worksheets
( p_api_version          IN   NUMBER,
  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status        OUT  NOCOPY  VARCHAR2,
  p_global_worksheet_id  IN   NUMBER
);

/* ----------------------------------------------------------------------- */

PROCEDURE Validate_Consolidation
( p_api_version          IN   NUMBER,
  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status        OUT  NOCOPY  VARCHAR2,
  p_global_worksheet_id  IN   NUMBER
);

/* ----------------------------------------------------------------------- */

END PSB_WORKSHEET_CONSOLIDATE;

 

/
