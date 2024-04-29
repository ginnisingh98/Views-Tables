--------------------------------------------------------
--  DDL for Package Body HRI_DBI_WMV_COUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_DBI_WMV_COUNT" AS
/* $Header: hriwmvco.pkb 120.0 2005/05/29 07:49:43 appldev noship $ */
--
--************************************************************
--* Calculate total ABV count as of p_effective_start_date-1 *
--************************************************************
--
PROCEDURE calc_wmv_count(p_effective_start_date IN DATE
                         ,p_effective_end_date   IN DATE)
IS
BEGIN
RETURN;
END;
--
--********************
--* Calculate events *
--********************
PROCEDURE calc_events(p_supervisor_id        IN NUMBER DEFAULT NULL
                      ,p_location_id          IN NUMBER DEFAULT NULL
                      ,p_effective_start_date IN DATE
                      ,p_effective_end_date   IN DATE)
IS
BEGIN
RETURN;
END;
--
--************************************
--*Calculate new hire + transfers in *
--************************************
--
PROCEDURE calc_new_hire_trans_in
IS
BEGIN
RETURN;
END;
--
--******************************************
--* Calculate terminations + transfers out *
--******************************************
--
PROCEDURE calc_term_trans_out
IS
BEGIN
RETURN;
END;
--
--******************************************************************
--* Calculate location transfers - no change to supervisors or job *
--******************************************************************
--
PROCEDURE calc_event_loc_transfer (p_effective_start_date IN DATE
                                      ,p_effective_end_date   IN DATE)
IS
BEGIN
RETURN;
END;
--
--******************************************************************
--* Calculate job transfers - no change to supervisors or location *
--******************************************************************
--
PROCEDURE calc_event_job_transfer (p_effective_start_date IN DATE
                                      ,p_effective_end_date   IN DATE)
IS
BEGIN
RETURN;
END;
--
--***************************************************************
--* Calculate job/location transfers - no change to supervisors *
--***************************************************************
--
PROCEDURE calc_event_job_loc_transfer (p_effective_start_date IN DATE
                                          ,p_effective_end_date   IN DATE)
IS
BEGIN
RETURN;
END;
--
--*********************************************************************
--
--*****************************
--* Calculate distinct events *
--*****************************
--
PROCEDURE calc_distinct_events
IS
BEGIN
RETURN;
END;
--
--************************************
--* Remove duplicates from Temp table*
--************************************
--
PROCEDURE calc_remove_duplicate
IS
BEGIN
RETURN;
END;
--
--*************************************
--*Print Global Temp Table in Log File*
--*************************************
--
PROCEDURE calc_print_temp_table
IS
BEGIN
RETURN;
END;
--
--****************
--* Full refresh *
--****************
--
PROCEDURE full_refresh( errbuf                 OUT NOCOPY VARCHAR2
                           ,retcode                OUT NOCOPY NUMBER
                           ,p_effective_start_date IN         VARCHAR2
                           ,p_effective_end_date   IN         VARCHAR2)
IS
BEGIN
RETURN;
END;
--
--***********************
--* Refresh from deltas *
--***********************
--
PROCEDURE refresh_from_deltas( errbuf  OUT NOCOPY VARCHAR2
                                  ,retcode OUT NOCOPY NUMBER)
IS
BEGIN
RETURN;
END;
--
--*****************************************************************
--* This procedure calculates period ago wmv_cout of a supervisor *
--*****************************************************************
--
FUNCTION period_ago_count( p_supervisor_id           IN NUMBER
                              ,p_effective_start_date    IN DATE
                              ,p_count_type              IN VARCHAR2)
    RETURN NUMBER
IS
BEGIN
RETURN NULL;
END;
--
--******************************************************************************
--* This procedure calculate period ago wmv_count of a supervisor by a country *
--******************************************************************************
FUNCTION period_ago_count_ctr( p_supervisor_id        IN NUMBER
                                  ,p_effective_start_date IN DATE
                                  ,p_country              IN VARCHAR2)
    RETURN NUMBER
IS
BEGIN
RETURN NULL;
END;
--
--********************
--*Refresh MV method *
--*******************
FUNCTION refresh_mv_method RETURN VARCHAR2
IS
BEGIN
RETURN NULL;
END;
--
--****************************
--*Refresh materialized views*
--****************************
--
PROCEDURE refresh_mvs( errbuf           OUT NOCOPY VARCHAR2
                          ,retcode          OUT NOCOPY NUMBER
                          ,complete_refresh IN         VARCHAR2 DEFAULT 'Y')
IS
BEGIN
RETURN;
END;
END hri_dbi_wmv_count;

/
