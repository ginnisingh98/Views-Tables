--------------------------------------------------------
--  DDL for Package PA_IND_COST_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_IND_COST_CODES_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXCIICS.pls 120.1 2005/08/23 19:18:16 spunathi noship $ */

--  =====================================================================
--  This procedure performs a referential integrity check for indirect cost
--  codes.  Indirect cost code appears as a foreign key in the following
--  tables:
--     PA_COST_BASE_COST_CODES
--     PA_IND_COST_CODE_MULTIPLIERS
--     PA_COMPILED_MULTIPLIERS

  PROCEDURE check_references(  X_icc_name  IN      VARCHAR2
                             , status      IN OUT  NOCOPY NUMBER
			     , outcome	   IN OUT  NOCOPY VARCHAR2 );

--  =====================================================================
--  This procedure checks if the indirect cost code being inserted already
--  exists, and if so, returns an error message.

  PROCEDURE check_unique(  X_icc_name  IN      VARCHAR2
                         , X_rowid     IN      VARCHAR2
                         , status      IN OUT  NOCOPY NUMBER
                         , outcome     IN OUT  NOCOPY VARCHAR2 );

END PA_IND_COST_CODES_PKG;

 

/
