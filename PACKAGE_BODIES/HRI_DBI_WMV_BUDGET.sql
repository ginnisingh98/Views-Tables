--------------------------------------------------------
--  DDL for Package Body HRI_DBI_WMV_BUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_DBI_WMV_BUDGET" AS
/* $Header: hribdgco.pkb 120.0 2005/05/29 07:01:54 appldev noship $ */
    --
    --**********************************************
    --*        Define global constants             *
    --**********************************************
    --
    g_con_context_type    CONSTANT VARCHAR2(30) := 'SUPERVISOR';
    g_con_info_category   CONSTANT VARCHAR2(30) := 'HRI_DBI_WMV_BUDGET';
    g_object_name         CONSTANT VARCHAR2(30) := 'HRI_DBI_WMV_BUDGET';
    --
    --***********************************************
    --*        Define global parameters             *
    --***********************************************
    --
    g_abv_type VARCHAR2(30);
    --
    --**********************************************************************************
    --* Calculate events between p_effective_start_date and p_effective_end_date*
    --**********************************************************************************
    --
    PROCEDURE calc_events ( p_effective_start_date IN DATE
                           ,p_effective_end_date   IN DATE) IS
    BEGIN
        INSERT INTO hri_dbi_wmv_budget_evts_tmp
                    ( supervisor_id
                     ,effective_start_date
                     ,effective_end_date
                     ,budget_version_id
                     ,budgeted_count)
                    SELECT DISTINCT org.org_information2, b.version_date_from, b.version_date_to,
                                    b.budget_version_id,0
                    FROM   hr_organization_information org,
                           hri_mb_budget_v b
                    WHERE  org.org_information_context = 'Organization Name Alias'
                    AND    org.org_information2 IS NOT NULL
                    AND    org.organization_id = b.organization_id
                    AND    b.position_control_flag_code = 'Y'
                    AND    b.version_date_from BETWEEN p_effective_start_date
                                                  AND   p_effective_end_date;
        COMMIT;
        --
        bis_collection_utilities.log('Events Population Done',1);
        --
    END calc_events;
    --
    --*******************************
    --* Calculate budgeted headcount*
    --*******************************
    --
    PROCEDURE get_budgeted_headcount IS

    BEGIN
        UPDATE hri_dbi_wmv_budget_evts_tmp hrp
        SET    hrp.budgeted_count = (SELECT sum(decode(g_abv_type,b.budget_unit1_system_type_cd, b.budget_unit1_value,
                                                              b.budget_unit2_system_type_cd, b.budget_unit2_value,
                                                              b.budget_unit1_system_type_cd,b.budget_unit3_value ))
                                     FROM HRI_MB_BUDGET_V b,
                                          HR_ORGANIZATION_INFORMATION org
                                     WHERE b.position_control_flag_code = 'Y'
                                     AND   b.organization_id = org.organization_id
                                     AND   org.org_information_context = 'Organization Name Alias'
                                     AND   org.org_information2 = hrp.supervisor_id
                                     AND   b.version_date_from = hrp.effective_start_date
                                     AND   b.budget_version_id = hrp.budget_version_id);

        COMMIT;
        --
        bis_collection_utilities.log('Budgeted Headcount Calculation Done',1);
        --
    END get_budgeted_headcount;
    --
    --*******************************
    --* Compare Dates               *
    --*******************************
    --
    FUNCTION comp_date(p_effective_start_date IN DATE,p_effective_end_date IN DATE) RETURN VARCHAR2 IS

    ret_val VARCHAR2(10);
    BEGIN
        IF p_effective_start_date > p_effective_end_date then
           ret_val := 'Y';
        ELSE
           ret_val := 'N';
        END IF;
        return ret_val;
   END comp_date;

    --
    -- ***********************************************************************
    -- * Fully refresh all summary data for the budgeted headcount           *
    -- * within the specified time period                                    *
    -- ***********************************************************************
    --
    PROCEDURE full_refresh( errbuf OUT NOCOPY VARCHAR2
                           ,retcode OUT NOCOPY NUMBER
                           ,p_effective_start_date IN VARCHAR2
                           ,p_effective_end_date   IN VARCHAR2) IS

              l_supervisor_id           NUMBER(32);
              l_location_id             NUMBER(32);
              l_budgeted_headcount      NUMBER;
              l_effective_date          DATE;
              l_effective_date1         DATE;
              l_effective_start_date    DATE;
              l_effective_end_date      DATE;

              CURSOR c_events IS
                     SELECT hrp.supervisor_id, hrp.effective_start_date, hrp.effective_end_date,
                            hrp.budgeted_count
                     FROM   hri_dbi_wmv_budget_evts_tmp hrp;
    BEGIN

         bis_collection_utilities.log('********************************',1);
         bis_collection_utilities.log('*HRI_DBI_WMV_BUDGET.FULL_REFRESH*',1);
         bis_collection_utilities.log('********************************',1);

         DELETE
         FROM   hr_ptl_summary_data psum
         WHERE  psum.sum_information_category = 'HRI_DBI_WMV_BUDGET'
         AND    psum.summary_context_type = 'SUPERVISOR';
         COMMIT;
         --
         bis_collection_utilities.log('Delete records from the HR_PORTAL_SUMMARY_DATA table',1);
         --
         --set dates
         l_effective_start_date := trunc(fnd_date.canonical_to_date(p_effective_start_date));
         l_effective_end_date := trunc(fnd_date.canonical_to_date(p_effective_end_date));

         --
         bis_collection_utilities.log('Effective Start Date : '||TO_CHAR(l_effective_start_date),1);
         bis_collection_utilities.log('Effective End Date : '||TO_CHAR(l_effective_end_date),1);
         --
         --set global parameters
         --
         g_abv_type := fnd_profile.value('BIS_WORKFORCE_MEASUREMENT_TYPE');
         --
         bis_collection_utilities.log('Workforce Measurement Value: '||g_abv_type,1);
         --
         --events population
         hri_dbi_wmv_budget.calc_events(l_effective_start_date,l_effective_end_date);
         --
         --calculate budgeted headcount
         hri_dbi_wmv_budget.get_budgeted_headcount;

         OPEN c_events;
         LOOP
            FETCH c_events INTO l_supervisor_id, l_effective_date, l_effective_date1, l_budgeted_headcount;
            EXIT WHEN c_events%NOTFOUND;

            l_location_id := null;

            INSERT INTO hr_ptl_summary_data
                      ( summary_data_id
                       ,summary_context_type
                       ,summary_context_id
                       ,effective_date
                       ,created_by
                       ,creation_date
                       ,object_version_number
                       ,sum_information_category
                       ,sum_information1
                       ,sum_information2
                       ,effective_end_date)
            VALUES    ( hr_ptl_summary_data_s.NEXTVAL
                       ,g_con_context_type
                       ,l_supervisor_id
                       ,l_effective_date
                       ,fnd_global.user_id
                       ,TRUNC(SYSDATE)
                       ,1
                       ,g_con_info_category
                       ,l_location_id
                       ,l_budgeted_headcount
                       ,TRUNC(l_effective_date1));
         END LOOP;
         CLOSE c_events;
         COMMIT;
         --
         bis_collection_utilities.log('Full Refresh Complete',1);
         --
         EXCEPTION
            WHEN OTHERS THEN
              errbuf := SQLERRM;
              retcode := SQLCODE;
    END full_refresh;
    --
    -- **********************************************************************
    -- * Refresh the summary data for the employee budgeted count           *
    -- **********************************************************************
    --
    PROCEDURE refresh_from_deltas ( errbuf  OUT NOCOPY VARCHAR2
                                   ,retcode OUT NOCOPY NUMBER ) IS

              l_effective_from_date    VARCHAR2(25);
              l_effective_to_date      VARCHAR2(25);

    BEGIN
              l_effective_from_date := fnd_date.date_to_canonical(TRUNC(bis_common_parameters.get_global_start_date));
              l_effective_to_date   := fnd_date.date_to_canonical(TRUNC(sysdate));

              hri_dbi_wmv_budget.full_refresh(errbuf,retcode,l_effective_from_date,l_effective_to_date);

    END refresh_from_deltas;
    --
    -- **********************************************************************
    -- * Refresh the materialized view for the employee budgeted count      *
    -- **********************************************************************
    --
    PROCEDURE refresh_mvs( errbuf  OUT NOCOPY VARCHAR2
                          ,retcode OUT NOCOPY NUMBER) IS
    BEGIN
         --
         bis_collection_utilities.log('****************************',1);
         bis_collection_utilities.log('*Refresh Materialized Views*',1);
         bis_collection_utilities.log('****************************',1);
         --
         dbms_mview.refresh('HRI_DBI_WMV_BUDGET_MV','C');
         --
         bis_collection_utilities.log('HRI_DBI_WMV_BUDGET_MV Materialized View refreshed',1);
         --
         fnd_stats.gather_table_stats('APPS','HRI_DBI_WMV_BUDGET_MV');
         --
         bis_collection_utilities.log('HRI_DBI_WMV_BUDGET_MV view statastics gathered',1);
         --
     EXCEPTION
        WHEN OTHERS THEN
            errbuf := SQLERRM;
            retcode := SQLCODE;
    END refresh_mvs;
END hri_dbi_wmv_budget;

/
