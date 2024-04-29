--------------------------------------------------------
--  DDL for Package Body PA_HR_BILL_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_HR_BILL_RATES" AS
/* $Header: PAHRBLRB.pls 115.0 99/07/16 15:04:54 porting shi $ */
--
  --
  PROCEDURE check_person_reference (p_person_id       IN number,
                                    Error_Message    OUT varchar2,
                                    Reference_Exist  OUT varchar2)
  IS
     reference_exists  exception;
     dummy1            varchar2(1);

     cursor bill_rate_over( p_person_id number ) is
         select  null
         from    pa_emp_bill_rate_overrides      pa
         where   pa.project_id > -1
         and   pa.task_id    > -1
         and   pa.person_id                    = P_PERSON_ID;

     cursor assign_over( p_person_id number ) is
         select  null
         from    pa_job_assignment_overrides     pa
         where ((pa.project_id > -1   AND
         pa.person_id                    = P_PERSON_ID)
         OR
         (pa.task_id > -1      AND
         pa.person_id                    = P_PERSON_ID));

     cursor bill_rate( p_person_id number ) is
                select
                        null
                from    pa_bill_rates_all                   pa
                where   pa.bill_rate_organization_id > -1
                  and   pa.std_bill_rate_schedule <> 'DUMMY'
                  and   pa.person_id                    = P_PERSON_ID;

  BEGIN

      Error_Message := 'PA_HR_PER_BILL_RATE_OVERD';
      OPEN bill_rate_over(p_person_id);
      FETCH bill_rate_over INTO dummy1;
      IF bill_rate_over%found THEN
         CLOSE bill_rate_over;
         raise reference_exists;
      END IF;
      CLOSE bill_rate_over;

      Error_Message := 'PA_HR_PER_ASSIGN_OVERD';
      OPEN assign_over(p_person_id);
      FETCH assign_over INTO dummy1;
      IF assign_over%found THEN
         CLOSE assign_over;
         raise reference_exists;
      END IF;
      CLOSE assign_over;

      Error_Message := 'PA_HR_PER_BILL_RATE';
      OPEN bill_rate(p_person_id);
      FETCH bill_rate INTO dummy1;
      IF bill_rate%found THEN
         CLOSE bill_rate;
         raise reference_exists;
      END IF;
      CLOSE bill_rate;

      Reference_Exist := 'N';
      Error_Message   := NULL;
      EXCEPTION
        WHEN reference_exists  THEN
          Reference_Exist := 'Y';
        WHEN others  THEN
          raise;
  END check_person_reference;

  PROCEDURE check_job_reference    (p_job_id          IN number,
                                    Error_Message    OUT varchar2,
                                    Reference_Exist  OUT varchar2)
  IS
     reference_exists  exception;
     dummy1            varchar2(1);

     cursor bill_rate( p_job_id    number ) is
         select  null
         from    pa_bill_rates_all   pa
         where   pa.job_id           = P_JOB_ID;

     cursor assign_over( p_job_id    number ) is
         select  null
         from    pa_job_assignment_overrides    pa
         where   pa.job_id                    = P_JOB_ID;

     cursor bill_rate_over( p_job_id    number ) is
         select  null
         from    PA_JOB_BILL_RATE_OVERRIDES    pa
         where   pa.job_id                    = P_JOB_ID;

     cursor bill_rate_title( p_job_id    number ) is
         select  null
         from    PA_JOB_BILL_TITLE_OVERRIDES    pa
         where   pa.job_id                    = P_JOB_ID;

  BEGIN

      Error_Message := 'PA_HR_JOB_BILL_RATE';
      OPEN bill_rate(p_job_id);
      FETCH bill_rate INTO dummy1;
      IF bill_rate%found THEN
         CLOSE bill_rate;
         raise reference_exists;
      END IF;
      CLOSE bill_rate;

      Error_Message := 'PA_HR_JOB_ASSIGN_OVERD';
      OPEN assign_over(p_job_id);
      FETCH assign_over INTO dummy1;
      IF assign_over%found THEN
         CLOSE assign_over;
         raise reference_exists;
      END IF;
      CLOSE assign_over;

      Error_Message := 'PA_HR_JOB_BILL_RATE_OVERD';
      OPEN bill_rate_over(p_job_id);
      FETCH bill_rate_over INTO dummy1;
      IF bill_rate_over%found THEN
         CLOSE bill_rate_over;
         raise reference_exists;
      END IF;
      CLOSE bill_rate_over;

      Error_Message := 'PA_HR_JOB_BILL_TITLE_OVERD';
      OPEN bill_rate_title(p_job_id);
      FETCH bill_rate_title INTO dummy1;
      IF bill_rate_title%found THEN
         CLOSE bill_rate_title;
         raise reference_exists;
      END IF;
      CLOSE bill_rate_title;

      Reference_Exist := 'N';
      Error_Message   := NULL;
      EXCEPTION
        WHEN reference_exists  THEN
          Reference_Exist := 'Y';
        WHEN others  THEN
          raise;
  END check_job_reference;

--
END pa_hr_bill_rates;

/
