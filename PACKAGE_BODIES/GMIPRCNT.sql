--------------------------------------------------------
--  DDL for Package Body GMIPRCNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMIPRCNT" AS
/*  $Header: gmiprcnb.pls 120.1 2005/10/03 12:10:35 jsrivast noship $   */

/* ==================================================================
   Procedure: calculate_percent

   Description: This procedure calculates the percentage difference
     between the frozen/actual quantities in a physical inventory.
     For cases where zero in involved, the following mathematical
     overrides are made.
     Frozen = 0    Actual = 0   Percent Diff = 0
     Frozen = 0    Actual > 0   Percent Diff = 100
     Frozen  >0    Actual = 0   Percent Diff = 100
     Frozen  <0    Actual = 0   Percent Diff = 100
   ================================================================== */

FUNCTION CALCULATE_PERCENT(pfrozen IN NUMBER, pactual IN NUMBER)
RETURN NUMBER IS

p_percent              NUMBER;

BEGIN
   IF (pfrozen <= 0) THEN
      IF (pfrozen = 0) THEN
         IF (pactual = 0) THEN
            p_percent := 0;
         ELSE
            p_percent := 1;
         END IF;
      ELSE /*  less than zero  */
         IF (pactual >= 0) THEN
            p_percent := 1;
         ELSE
            p_percent := 0;
         END IF;
      END IF;
   ELSE
      IF (pactual = 0) THEN
         p_percent := 1;
      ELSE
         p_percent := ((pactual - pfrozen)/pfrozen);
      END IF;
   END IF;
   p_percent := ABS(p_percent);
   p_percent := (p_percent * 100);
   RETURN p_percent;

END CALCULATE_PERCENT;
END GMIPRCNT;

/
