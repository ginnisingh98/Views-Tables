--------------------------------------------------------
--  DDL for Package HRI_DBI_WMV_BUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_DBI_WMV_BUDGET" AUTHID CURRENT_USER AS
/* $Header: hribdgco.pkh 115.4 2003/04/14 12:03:13 jtitmas ship $ */
    --
    --********************
    --* Calculate events *
    --********************
    PROCEDURE calc_events( p_effective_start_date IN DATE
                          ,p_effective_end_date   IN DATE);
    --
    --******************************
    --*Calculate budgeted headcount*
    --*******************************
    PROCEDURE get_budgeted_headcount;
    --
    --***************************
    --* Full refresh *
    --****************************
     PROCEDURE full_refresh( errbuf                 OUT NOCOPY VARCHAR2
                            ,retcode                OUT NOCOPY NUMBER
                            ,p_effective_start_date IN VARCHAR2
                            ,p_effective_end_date   IN VARCHAR2);

    --
    --***********************
    --* Refresh from deltas *
    --***********************
    PROCEDURE refresh_from_deltas( errbuf  OUT NOCOPY VARCHAR2
                                  ,retcode OUT NOCOPY NUMBER);
    --
    --****************************
    --*Refresh Materialized Views*
    --****************************
    PROCEDURE refresh_mvs( errbuf  OUT NOCOPY VARCHAR2
                          ,retcode OUT NOCOPY NUMBER);
    --
    --****************************
    --*Compare Dates             *
    --****************************
    FUNCTION comp_date(p_effective_start_date IN DATE,
                       p_effective_end_date IN DATE) RETURN VARCHAR2;
    --
END hri_dbi_wmv_budget;

 

/
