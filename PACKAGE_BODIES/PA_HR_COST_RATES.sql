--------------------------------------------------------
--  DDL for Package Body PA_HR_COST_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_HR_COST_RATES" AS
/* $Header: PAHRCRTB.pls 120.2 2005/08/19 16:18:47 ramurthy noship $ */
--
  --
  PROCEDURE check_person_reference (p_person_id       IN number,
                                    Error_Message    OUT NOCOPY varchar2,
                                    Reference_Exist  OUT NOCOPY varchar2)
  IS
     reference_exists  exception;
     dummy1            varchar2(1);

     cursor cost_dist( p_person_id number ) is
                select  null
                from    PA_COST_DIST_OVERRIDES         pa
                where   pa.person_id                    = P_PERSON_ID;

     cursor compens_detail( p_person_id number ) is
         select  null
         from    PA_COMPENSATION_DETAILS_ALL         pa
         where   pa.person_id                    = P_PERSON_ID;

/* *****************
     cursor proj_task( p_person_id number ) is
                select  null
                from    PA_PROJECT_TASK_ALIASES         pa
                where   pa.person_id                    = P_PERSON_ID;
************* */

  BEGIN

      Error_Message := 'PA_HR_PER_COST_DIST_OVER';
      OPEN cost_dist(p_person_id);
      FETCH cost_dist INTO dummy1;
      IF cost_dist%found THEN
         CLOSE cost_dist;
         raise reference_exists;
      END IF;
      CLOSE cost_dist;

      Error_Message := 'PA_HR_PER_COMP_DETAILS';
      OPEN compens_detail(p_person_id);
      FETCH compens_detail INTO dummy1;
      IF compens_detail%found THEN
         CLOSE compens_detail;
         raise reference_exists;
      END IF;
      CLOSE compens_detail;

/* *************
      Error_Message := 'PA_HR_PER_PRJ_TASK_ALIAS';
      OPEN proj_task(p_person_id);
      FETCH proj_task INTO dummy1;
      IF proj_task%found THEN
         CLOSE proj_task;
         raise reference_exists;
      END IF;
      CLOSE proj_task;
*** */

      Reference_Exist := 'N';
      Error_Message   := NULL;
      EXCEPTION
        WHEN reference_exists  THEN
          Reference_Exist := 'Y';
        WHEN others  THEN
          raise;
  END check_person_reference;

  PROCEDURE check_job_reference    (p_job_id          IN number,
                                    Error_Message    OUT NOCOPY varchar2,
                                    Reference_Exist  OUT NOCOPY varchar2)
  IS
  BEGIN
      Reference_Exist := 'N';
      Error_Message   := NULL;
  END check_job_reference;

--
END pa_hr_cost_rates;

/
