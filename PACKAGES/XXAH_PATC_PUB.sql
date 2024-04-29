--------------------------------------------------------
--  DDL for Package XXAH_PATC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_PATC_PUB" AS
/**************************************************************************
 * HISTORY
 * =======
 *
 * VERSION DATE        AUTHOR(S)         DESCRIPTION
 * ------- ----------- ---------------   ------------------------------------
 * 1.00    03-JAN-2008 Marc Smeenge      Initial creation.
 * 1.01    09-JAN-2008 Ralph Hopman      Include show_project.
 * 1.02    28-JAN-2008 Ralph Hopman      Use type DATE for dates.
 * 1.1     29-SEP-2008 Kevin Bouwmeester Adapted for Equens
 * 1.2     04-DEC-2009 Kevin Bouwmeester Adapted for Ahold
 *************************************************************************/

  /**************************************************************************
   *
   * FUNCTION  show_project
   *
   *
   * DESCRIPTION: Determine wheter this project should be listed in the LOV,
   *              possible return values Y/N.
   *
   * PARAMETERS
   * ==========
   * NAME               TYPE           DESCRIPTION
   * -----------------  -------------  --------------------------------------
   * p_project_id       IN: NUMBER     Identification of project
   * p_resource_id      IN: NUMBER     Person for whom TC is entered
   * p_date_from        IN: DATE       Start date of timecard
   * p_date_to          IN: DATE       End date of timecard
   *
   *************************************************************************/
  FUNCTION show_project(p_project_id IN pa_projects_all.project_id%TYPE
                       ,p_resource_id IN per_all_people_f.person_id%TYPE
                       ,p_date_from IN DATE
                       ,p_date_to IN DATE) RETURN VARCHAR2;

  /**************************************************************************
   *
   * FUNCTION  show_task
   *
   *
   * DESCRIPTION: Determine wheter this task should be listed in the LOV,
   *              possible return values Y/N.
   *
   * PARAMETERS
   * ==========
   * NAME               TYPE           DESCRIPTION
   * -----------------  -------------  --------------------------------------
   * p_task_id          IN: NUMBER     Identification of task
   * p_project_id       IN: NUMBER     Identification of project
   * p_resource_id      IN: NUMBER     Person for whom TC is entered
   * p_date_from        IN: DATE       Start date of timecard
   * p_date_to          IN: DATE       End date of timecard
   *
   *************************************************************************/
  FUNCTION show_task(p_task_id IN pa_tasks.task_id%TYPE
                    ,p_project_id IN pa_projects_all.project_id%TYPE
                    ,p_resource_id IN per_all_people_f.person_id%TYPE
                    ,p_date_from IN DATE
                    ,p_date_to IN DATE) RETURN VARCHAR2;
END XXAH_PATC_PUB;
 

/
