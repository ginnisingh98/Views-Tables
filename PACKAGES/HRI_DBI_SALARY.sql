--------------------------------------------------------
--  DDL for Package HRI_DBI_SALARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_DBI_SALARY" AUTHID CURRENT_USER AS
/* $Header: hrisalsu.pkh 120.0 2005/05/29 07:48:12 appldev noship $ */

PROCEDURE full_refresh( p_start_date    IN  DATE,
                        p_end_date      IN  DATE );

PROCEDURE full_refresh( errbuf          OUT NOCOPY VARCHAR2,
                        retcode         OUT NOCOPY NUMBER,
                        p_start_date    IN  VARCHAR2,
                        p_end_date      IN  VARCHAR2 );

PROCEDURE refresh_direct( p_start_date   IN DATE,
                          p_end_date     IN DATE );

PROCEDURE refresh_from_deltas( errbuf    OUT NOCOPY VARCHAR2,
                               retcode   OUT NOCOPY NUMBER);

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
     ) return number;

    --
    --*********************************************************************
    --* This procedure calculates period ago total salary of a supervisor *
    --*********************************************************************
    --
    FUNCTION period_ago_salary( p_supervisor_id           IN NUMBER
                               ,p_effective_start_date    IN DATE
                               ,p_salary_type             IN VARCHAR2
                               ,p_currency_conv_date      IN DATE)
    RETURN NUMBER;

    --
    --**************************************************************************
    --* This procedure calculates period ago salary by country of a supervisor *
    --**************************************************************************
    --

    FUNCTION period_ago_sal_ctr( p_supervisor_id        IN NUMBER
                                ,p_effective_start_date IN DATE
                                ,p_country              IN VARCHAR2
                                ,p_currency_conv_date   IN DATE)

    RETURN NUMBER;
    --
    --*******************
    --*Refresh MV Method*
    --*******************
    --
    FUNCTION refresh_mv_method RETURN VARCHAR2;
    --
    --****************************
    --*Refresh Materialized Views*
    --****************************
    PROCEDURE refresh_mvs( errbuf  OUT NOCOPY VARCHAR2
                          ,retcode OUT NOCOPY NUMBER
                          ,complete_refresh IN  VARCHAR2 DEFAULT 'Y');

END hri_dbi_salary;

 

/
