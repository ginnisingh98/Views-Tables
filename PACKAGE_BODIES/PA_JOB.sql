--------------------------------------------------------
--  DDL for Package Body PA_JOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_JOB" AS
/* $Header: PAJOBB.pls 120.2 2005/08/25 12:25:44 ramurthy noship $ */
--
    /*
    NAME
      pa_predel_validation
    DESCRIPTION
      Foreign key reference check.
  */
  --
  PROCEDURE check_business_group(p_job_id IN number,
                                 Other_Business_group OUT NOCOPY varchar2); --File.Sql.39 bug 4440895
  PROCEDURE phase2(p_job_id number);

  PROCEDURE pa_predel_validation (p_job_id   number) IS
  Allow_deletion       exception;
  Not_Allow_deletion   exception;
  Error_Message        varchar2(30);
  Reference_Exist      varchar2(1);
  Other_Business_group      varchar2(1);
  BEGIN

      check_business_group(p_job_id,
                           Other_Business_group);
      if ( Other_Business_group = 'Y' ) then
       raise Allow_deletion;
      end if;

      Pa_Hr_Project_setup.Check_job_reference(p_job_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

      Pa_Hr_Resource.Check_job_reference(p_job_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

      Pa_Hr_Summarizations.Check_job_reference(p_job_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

      Pa_Hr_Budgets.Check_job_reference(p_job_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

      Pa_Hr_Cost_Rates.Check_job_reference(p_job_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

      Pa_Hr_Transactions.Check_job_reference(p_job_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

      Pa_Hr_Bill_Rates.Check_job_reference(p_job_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

      Pa_Hr_Agreements.Check_job_reference(p_job_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

      Pa_Hr_Invoice.Check_job_reference(p_job_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

      Pa_Hr_Capital.Check_job_reference(p_job_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

   exception
     when Allow_deletion then
       Return;
     when Not_Allow_deletion then
       hr_utility.set_message (275, Error_Message);
       hr_utility.raise_error;
     when OTHERS then
       raise;

  END pa_predel_validation;

  PROCEDURE check_business_group (p_job_id   IN number,
                                  Other_Business_group OUT NOCOPY varchar2) IS --File.Sql.39 bug 4440895
  job_delete_allowed  VARCHAR2(1);
  BEGIN

    select 'X'
    into   job_delete_allowed
    from   sys.dual
    where not exists (
     select null
     from  pa_implementations_all imp,
	   per_jobs job
     where job.job_id = p_job_id
     and   job.business_group_id = imp.business_group_id );
     Other_Business_group := 'Y';
  exception
    when NO_DATA_FOUND then
      Other_Business_group := 'N';
    when OTHERS then
      Raise;
/* **
     when NO_DATA_FOUND then
     hr_utility.set_message (275, 'PA_JOB_PHS1_NO_DEL');
     hr_utility.raise_error;
** */
  END check_business_group;

  PROCEDURE phase2 (p_job_id   number) IS
    dummy	VARCHAR2(240);	--	used for into argument
    cursor pa_job_exists is
      SELECT 'The Job may not be deleted if PA is installed and implemented'
      FROM   fnd_product_installations fpi
      ,      pa_implementations_all imp
      WHERE  fpi.application_id = 275
      AND    fpi.status         = 'I';

  BEGIN
      --
      --      hr_utility.set_location('PA_JOB.PA_PREDEL_VALIDATION', 1);
      --
    open pa_job_exists;
    fetch pa_job_exists into dummy;
    if pa_job_exists%found then
       hr_utility.set_message (275,'PA_JOB_CANT_DELETE');
       hr_utility.raise_error;
    end if;
    close pa_job_exists;
      --
  END phase2;

END pa_job;

/
