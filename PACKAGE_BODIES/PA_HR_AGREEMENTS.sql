--------------------------------------------------------
--  DDL for Package Body PA_HR_AGREEMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_HR_AGREEMENTS" AS
/* $Header: PAHRAGRB.pls 120.2 2005/08/16 15:39:34 hsiu noship $ */
--
  --
  PROCEDURE check_person_reference (p_person_id       IN number,
                                    Error_Message    OUT NOCOPY varchar2,
                                    Reference_Exist  OUT NOCOPY varchar2)
  IS
     reference_exists  exception;
     dummy1            varchar2(1);

     cursor agr_all( p_person_id1 number ) is
       select  null
       from    pa_agreements_all   pa
       where   pa.owned_by_person_id  = P_PERSON_ID1;

  BEGIN

      Error_Message := 'PA_HR_PER_AGREEMENT';
      OPEN agr_all(p_person_id);
      FETCH agr_all INTO dummy1;
      IF agr_all%found THEN
         CLOSE agr_all;
         raise reference_exists;
      END IF;
      CLOSE agr_all;

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
END pa_hr_agreements;

/
