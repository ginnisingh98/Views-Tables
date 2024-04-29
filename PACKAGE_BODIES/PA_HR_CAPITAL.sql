--------------------------------------------------------
--  DDL for Package Body PA_HR_CAPITAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_HR_CAPITAL" AS
/* $Header: PAHRCAPB.pls 120.2 2005/08/19 16:18:44 ramurthy noship $ */
--
  --
  PROCEDURE check_person_reference (p_person_id       IN number,
                                    Error_Message    OUT NOCOPY varchar2,
                                    Reference_Exist  OUT NOCOPY varchar2)
  IS
     reference_exists  exception;
     dummy1            varchar2(1);

     cursor asset_all( p_person_id number ) is
                select  null
                from    PA_PROJECT_ASSETS_ALL         pa
                where   pa.ASSIGNED_TO_PERSON_ID    = P_PERSON_ID;
  BEGIN

      Error_Message := 'PA_HR_PER_ASSET';
      OPEN asset_all(p_person_id);
      FETCH asset_all INTO dummy1;
      IF asset_all%found THEN
         CLOSE asset_all;
         raise reference_exists;
      END IF;
      CLOSE asset_all;

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
END pa_hr_capital      ;

/
