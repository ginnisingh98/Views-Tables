--------------------------------------------------------
--  DDL for Package Body PA_HR_PROJECT_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_HR_PROJECT_SETUP" AS
/* $Header: PAHRPRJB.pls 120.2 2005/08/23 22:28:31 avaithia noship $ */
--
  --
  PROCEDURE check_person_reference (p_person_id       IN number,
                                    Error_Message    OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
                                    Reference_Exist  OUT NOCOPY varchar2) --File.Sql.39 bug 4440895
  IS
     reference_exists  exception;
     dummy1            varchar2(1);

     cursor proj_player( p_person_id number ) is
                select  null
                from    PA_PROJECT_PLAYERS         pa
                where   pa.person_id                    = P_PERSON_ID;

     cursor tasks( p_person_id number ) is
                select  null
                from    PA_TASKS         pa
                where   pa.TASK_MANAGER_PERSON_ID   = P_PERSON_ID;

  BEGIN
      Error_Message := 'PA_HR_PER_IN_PRJ_PLAY';
      OPEN proj_player(p_person_id);
      FETCH proj_player INTO dummy1;
      IF proj_player%found THEN
         CLOSE proj_player;
         raise reference_exists;
      END IF;
      CLOSE proj_player;

      Error_Message := 'PA_HR_PER_IN_TASK_DETAILS';
      OPEN tasks(p_person_id);
      FETCH tasks INTO dummy1;
      IF tasks%found THEN
         CLOSE tasks;
         raise reference_exists;
      END IF;
      CLOSE tasks;

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
END pa_hr_project_setup;

/
