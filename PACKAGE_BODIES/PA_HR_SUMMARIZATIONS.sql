--------------------------------------------------------
--  DDL for Package Body PA_HR_SUMMARIZATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_HR_SUMMARIZATIONS" AS
/* $Header: PAHRSUMB.pls 115.1 99/08/19 17:42:12 porting shi $ */
--
  --
  PROCEDURE check_person_reference (p_person_id       IN number,
                                    Error_Message    OUT varchar2,
                                    Reference_Exist  OUT varchar2)
  IS
     reference_exists  exception;
     dummy1            varchar2(1);

     cursor resource_map( p_person_id number ) is
                select  null
                from    PA_RESOURCE_MAPS         pa
                where   pa.person_id                    = P_PERSON_ID;

/* -- sowong - these lines of code are removed since PA EMPLOYEE ACCUM
   --          references are not needed (see bug 967781).

     cursor emp_accum( p_person_id number ) is
                select  null
                from    PA_EMPLOYEE_ACCUM_ALL         pa
                where   pa.person_id                = P_PERSON_ID;
*/

     cursor txn_accum( p_person_id number ) is
                select  null
                from    PA_TXN_ACCUM         pa
                where   pa.person_id       = P_PERSON_ID;

  BEGIN

      Error_Message := 'PA_HR_PER_IN_RES_MAP_DET';
      OPEN resource_map(p_person_id);
      FETCH resource_map INTO dummy1;
      IF resource_map%found THEN
         CLOSE resource_map;
         raise reference_exists;
      END IF;
      CLOSE resource_map;

/* -- sowong - these lines of code are removed since PA EMPLOYEE ACCUM
   --          references are not needed (see bug 967781).

      Error_Message := 'PA_HR_PER_EMP_ACCUM';
      OPEN emp_accum(p_person_id);
      FETCH emp_accum INTO dummy1;
      IF emp_accum%found THEN
         CLOSE emp_accum;
         raise reference_exists;
      END IF;
      CLOSE emp_accum;
*/

      Error_Message := 'PA_HR_PER_TXN_ACCUM';
      OPEN txn_accum(p_person_id);
      FETCH txn_accum INTO dummy1;
      IF txn_accum%found THEN
         CLOSE txn_accum;
         raise reference_exists;
      END IF;
      CLOSE txn_accum;

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

     cursor txn_accum( p_job_id    number ) is
                select  null
                from    PA_TXN_ACCUM         pa
                where   pa.job_id          = P_JOB_ID;

  BEGIN
      Error_Message := 'PA_HR_JOB_TXN_ACCUM';
      OPEN txn_accum(p_job_id);
      FETCH txn_accum INTO dummy1;
      IF txn_accum%found THEN
         CLOSE txn_accum;
         raise reference_exists;
      END IF;
      CLOSE txn_accum;

      Reference_Exist := 'N';
      Error_Message   := NULL;
      EXCEPTION
        WHEN reference_exists  THEN
          Reference_Exist := 'Y';
        WHEN others  THEN
          raise;
  END check_job_reference;

--
END pa_hr_summarizations  ;

/
