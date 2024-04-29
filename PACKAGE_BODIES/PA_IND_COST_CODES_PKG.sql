--------------------------------------------------------
--  DDL for Package Body PA_IND_COST_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_IND_COST_CODES_PKG" AS
/* $Header: PAXCIICB.pls 120.1 2005/08/23 19:19:59 spunathi noship $ */

--  =====================================================================
--  This procedure performs a referential integrity check for indirect cost
--  codes.  Indirect cost code appears as a foreign key in the following
--  tables:
--     PA_COST_BASE_COST_CODES
--     PA_IND_COST_CODE_MULTIPLIERS
--     PA_COMPILED_MULTIPLIERS
--  The procedure first checks if the icc is referenced in
--  PA_COST_BASE_COST_CODES.  If it is, the outcome parameter is set to the
--  relevant error message name and processing stops.  If it is not, then the
--  procedure then checks for references in PA_IND_COST_CODE_MULTIPLIERS.  If
--  the icc is not referenced in this table, then the outcome parameter is set
--  to NULL and processing stops; there is no need to check
--  PA_COMPILED_MULTIPLIERS since the multiplier must first exist before it can
--  be compiled.  IF a icc multiplier does exist, then this procedure checks
--  further to see if a compiled mutliplier exists.

  PROCEDURE check_references(  X_icc_name  IN      VARCHAR2
                             , status      IN OUT  NOCOPY NUMBER
                             , outcome	   IN OUT  NOCOPY VARCHAR2 ) IS
	dummy	NUMBER;

  BEGIN
    outcome := NULL;         -- initialize
    status  := 0;

    SELECT  count(1)
      INTO  dummy
      FROM  dual
     WHERE EXISTS
            ( SELECT  1
                FROM  pa_cost_base_cost_codes
               WHERE  ind_cost_code = X_icc_name );

    IF ( dummy = 1 ) THEN    -- ICC referenced by at least one cost base
      outcome := 'PA_ICC_IN_COST_BASE';
      status  := 1;
    ELSE                     -- Check for icc multipliers
      SELECT  count(1)
        INTO  dummy
        FROM  dual
       WHERE EXISTS
              ( SELECT  1
                  FROM  pa_ind_cost_multipliers
                 WHERE  ind_cost_code = X_icc_name );

      IF ( dummy = 0 ) THEN
                             -- No icc multipliers exist
        outcome := NULL;
                             -- Outcome is error-free; okay to delete
      ELSE
                             -- At least one icc multiplier exists; now check
                             -- for compiled multipliers
        SELECT  count(1)
          INTO  dummy
          FROM  dual
         WHERE EXISTS
                ( SELECT  1
                    FROM  pa_compiled_multipliers
                   WHERE  ind_cost_code = X_icc_name );

        IF ( dummy = 0 ) THEN
                             -- No compiled multipliers exist
          outcome := 'PA_ICC_IN_MULTIPLIER';
          status  := 1;
        ELSE
		             -- At least one compiled multiplier exists
          outcome := 'PA_ICC_IN_COMPILED';
          status  := 1;
        END IF;

      END IF;

    END IF;

  EXCEPTION
    WHEN  OTHERS THEN
      status := SQLCODE;

  END check_references;


--  =====================================================================
--  This procedure checks if the indirect cost code being inserted already
--  exists, and if so, returns an error message.

  PROCEDURE check_unique(  X_icc_name  IN      VARCHAR2
			 , X_rowid     IN      VARCHAR2
                         , status      IN OUT  NOCOPY NUMBER
			 , outcome     IN OUT  NOCOPY VARCHAR2 ) IS
    dummy   	NUMBER;

  BEGIN
    outcome := NULL;
    status  := 0;

    SELECT 1
      INTO dummy
      FROM dual
     WHERE NOT EXISTS
            ( SELECT 1
                FROM pa_ind_cost_codes
               WHERE ind_cost_code = X_icc_name
                 AND  (   ( X_rowid IS NULL )
                       OR ( rowid <> X_rowid ) ) );

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      status  := 1;
      outcome := 'PA_SU_NAME_ALREADY_EXISTS';
    WHEN  OTHERS  THEN
      status  := SQLCODE;

  END check_unique;

END PA_IND_COST_CODES_PKG;

/
