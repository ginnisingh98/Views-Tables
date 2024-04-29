--------------------------------------------------------
--  DDL for Package Body HRI_DBI_SALARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_DBI_SALARY" AS
/* $Header: hrisalsu.pkb 120.0 2005/05/29 07:48:06 appldev noship $ */

PROCEDURE full_refresh( p_start_date    IN  DATE,
                        p_end_date      IN  DATE ) IS
BEGIN
RETURN;
END;

PROCEDURE full_refresh( errbuf          OUT NOCOPY VARCHAR2,
                        retcode         OUT NOCOPY NUMBER,
                        p_start_date    IN  VARCHAR2,
                        p_end_date      IN  VARCHAR2 ) IS
BEGIN
RETURN;
END;

PROCEDURE refresh_direct( p_start_date   IN DATE,
                          p_end_date     IN DATE ) IS
BEGIN
RETURN;
END;

PROCEDURE refresh_from_deltas( errbuf    OUT NOCOPY VARCHAR2,
                               retcode   OUT NOCOPY NUMBER) IS
BEGIN
RETURN;
END;

--
-- ***********************************************************************
-- * Function to convert salary
-- ***********************************************************************
Function convert_salary(
          p_from_currency   IN VARCHAR2,
          p_to_currency     IN VARCHAR2,
          p_amount          IN NUMBER,
          p_effective_date  IN DATE,
          p_rate_type       IN VARCHAR2
     ) return number IS
BEGIN
RETURN NULL;
END;

--
--*********************************************************************
--* This procedure calculates period ago total salary of a supervisor *
--*********************************************************************
--
FUNCTION period_ago_salary(     p_supervisor_id                IN NUMBER
                               ,p_effective_start_date    IN DATE
                               ,p_salary_type             IN VARCHAR2
                               ,p_currency_conv_date      IN DATE)
    RETURN NUMBER IS
BEGIN
RETURN NULL;
END    ;

--
--**************************************************************************
--* This procedure calculates period ago salary by country of a supervisor *
--**************************************************************************
--
FUNCTION period_ago_sal_ctr( p_supervisor_id        IN NUMBER
                                ,p_effective_start_date IN DATE
                                ,p_country              IN VARCHAR2
                                ,p_currency_conv_date   IN DATE)

    RETURN NUMBER IS
BEGIN
RETURN NULL;
END;
--
--*******************
--*Refresh MV Method*
--*******************
--
FUNCTION refresh_mv_method RETURN VARCHAR2 IS
BEGIN
RETURN NULL;
END;
--
--****************************
--*Refresh Materialized Views*
--****************************
PROCEDURE refresh_mvs( errbuf  OUT NOCOPY VARCHAR2
                       ,retcode OUT NOCOPY NUMBER
                       ,complete_refresh IN  VARCHAR2 DEFAULT 'Y') IS
BEGIN
RETURN;
END;


END hri_dbi_salary;

/
