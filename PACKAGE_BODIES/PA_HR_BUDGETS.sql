--------------------------------------------------------
--  DDL for Package Body PA_HR_BUDGETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_HR_BUDGETS" AS
/* $Header: PAHRBUDB.pls 120.3 2006/01/13 01:42:48 ssong noship $ */
--
  --
  PROCEDURE check_person_reference (p_person_id       IN number,
                                    Error_Message    OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
                                    Reference_Exist  OUT NOCOPY varchar2) --File.Sql.39 bug 4440895
  IS
     reference_exists  exception;
     dummy1            varchar2(1);

     -- Modified for perf bug 4887375
     cursor budget_ver( p_person_id number ) is
          select  null
          from    dual
          where   exists
            (select  null
             from    PA_BUDGET_VERSIONS            pa
             where   pa.BASELINED_BY_PERSON_ID   = P_PERSON_ID);

  BEGIN

      Error_Message := 'PA_HR_PER_IN_BUDG_VER';
      OPEN budget_ver(p_person_id);
      FETCH budget_ver INTO dummy1;
      IF budget_ver%found THEN
         CLOSE budget_ver;
         raise reference_exists;
      END IF;
      CLOSE budget_ver;

      Reference_Exist := 'N';
      Error_Message   := NULL;
      EXCEPTION
        WHEN reference_exists  THEN
          Reference_Exist := 'Y';
        WHEN others  THEN
          raise;
  END check_person_reference;

  PROCEDURE check_job_reference    (p_job_id          IN number,
                                    Error_Message    OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
                                    Reference_Exist  OUT NOCOPY varchar2) --File.Sql.39 bug 4440895
  IS
  BEGIN
      Reference_Exist := 'N';
      Error_Message   := NULL;
  END check_job_reference;

--
END pa_hr_budgets      ;

/
