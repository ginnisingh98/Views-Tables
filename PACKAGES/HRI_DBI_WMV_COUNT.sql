--------------------------------------------------------
--  DDL for Package HRI_DBI_WMV_COUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_DBI_WMV_COUNT" AUTHID CURRENT_USER AS
/* $Header: hriwmvco.pkh 120.0 2005/05/29 07:49:50 appldev noship $ */
    --
    --************************************************************
    --* Calculate total ABV count as of p_effective_start_date-1 *
    --************************************************************
    --
    PROCEDURE calc_wmv_count( p_effective_start_date IN DATE
                             ,p_effective_end_date   IN DATE);
    --
    --********************
    --* Calculate events *
    --********************
    PROCEDURE calc_events( p_supervisor_id        IN NUMBER DEFAULT NULL
                          ,p_location_id          IN NUMBER DEFAULT NULL
                          ,p_effective_start_date IN DATE
                          ,p_effective_end_date   IN DATE);
    --
    --************************************
    --*Calculate new hire + transfers in *
    --************************************
    --
    PROCEDURE calc_new_hire_trans_in;
    --
    --******************************************
    --* Calculate terminations + transfers out *
    --******************************************
    --
    PROCEDURE calc_term_trans_out;
    --
    --******************************************************************
    --* Calculate location transfers - no change to supervisors or job *
    --******************************************************************
    --
    PROCEDURE calc_event_loc_transfer (p_effective_start_date IN DATE
                                      ,p_effective_end_date   IN DATE);
    --
    --******************************************************************
    --* Calculate job transfers - no change to supervisors or location *
    --******************************************************************
    --
    PROCEDURE calc_event_job_transfer (p_effective_start_date IN DATE
                                      ,p_effective_end_date   IN DATE);
    --
    --***************************************************************
    --* Calculate job/location transfers - no change to supervisors *
    --***************************************************************
    --
    PROCEDURE calc_event_job_loc_transfer (p_effective_start_date IN DATE
                                          ,p_effective_end_date   IN DATE);
    --
    --*********************************************************************
    --
    --*****************************
    --* Calculate distinct events *
    --*****************************
    --
    PROCEDURE calc_distinct_events;
    --
    --************************************
    --* Remove duplicates from Temp table*
    --************************************
    --
    PROCEDURE calc_remove_duplicate;
    --
    --*************************************
    --*Print Global Temp Table in Log File*
    --*************************************
    --
    PROCEDURE calc_print_temp_table;
    --
    --****************
    --* Full refresh *
    --****************
    --
    PROCEDURE full_refresh( errbuf                 OUT NOCOPY VARCHAR2
                           ,retcode                OUT NOCOPY NUMBER
                           ,p_effective_start_date IN         VARCHAR2
                           ,p_effective_end_date   IN         VARCHAR2);
    --
    --***********************
    --* Refresh from deltas *
    --***********************
    --
    PROCEDURE refresh_from_deltas( errbuf  OUT NOCOPY VARCHAR2
                                  ,retcode OUT NOCOPY NUMBER);
    --
    --*****************************************************************
    --* This procedure calculates period ago wmv_cout of a supervisor *
    --*****************************************************************
    --
    FUNCTION period_ago_count( p_supervisor_id           IN NUMBER
                              ,p_effective_start_date    IN DATE
                              ,p_count_type              IN VARCHAR2)
    RETURN NUMBER;
    --
    --******************************************************************************
    --* This procedure calculate period ago wmv_count of a supervisor by a country *
    --******************************************************************************
    FUNCTION period_ago_count_ctr( p_supervisor_id        IN NUMBER
                                  ,p_effective_start_date IN DATE
                                  ,p_country              IN VARCHAR2)
    RETURN NUMBER;
    --
    --********************
    --*Refresh MV method *
    --*******************
    FUNCTION refresh_mv_method RETURN VARCHAR2;
    --
    --****************************
    --*Refresh materialized views*
    --****************************
    --
    PROCEDURE refresh_mvs( errbuf           OUT NOCOPY VARCHAR2
                          ,retcode          OUT NOCOPY NUMBER
                          ,complete_refresh IN         VARCHAR2 DEFAULT 'Y');
    --
END hri_dbi_wmv_count;

 

/
