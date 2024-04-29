--------------------------------------------------------
--  DDL for Package Body PA_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERSON" AS
/* $Header: PAPERB.pls 120.1 2005/08/19 16:39:22 mwasowic noship $ */
--
  --
  PROCEDURE check_business_group (p_person_id   IN number,
                                  Other_Business_group OUT NOCOPY varchar2); --File.Sql.39 bug 4440895
  PROCEDURE phase2 (p_person_id   number);

  PROCEDURE pa_predel_validation (p_person_id   number)
  IS
  Allow_deletion       exception;
  Not_Allow_deletion   exception;
  Error_Message        varchar2(30);
  Reference_Exist      varchar2(30);
  Other_Business_group varchar2(1);
  BEGIN

      check_business_group(p_person_id,
                           Other_Business_group);
      if ( Other_Business_group = 'Y' ) then
       raise Allow_deletion;
      end if;

      Pa_Hr_Project_setup.Check_person_reference(p_person_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

/*Bug#2738741 - Commenting this code as we will be adding this as the last check
as this involved deletion of records also.

      Pa_Hr_Resource.Check_person_reference(p_person_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;
** */

      Pa_Hr_Summarizations.Check_person_reference(p_person_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

      Pa_Hr_Budgets.Check_person_reference(p_person_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

      Pa_Hr_Cost_Rates.Check_person_reference(p_person_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

      Pa_Hr_Transactions.Check_person_reference(p_person_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

      Pa_Hr_Bill_Rates.Check_person_reference(p_person_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

      Pa_Hr_Agreements.Check_person_reference(p_person_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

      Pa_Hr_Invoice.Check_person_reference(p_person_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

      Pa_Hr_Capital.Check_person_reference(p_person_id,
                                                 Error_Message,
                                                 Reference_Exist);
      if ( Reference_Exist = 'Y' ) then
       raise Not_Allow_deletion;
      end if;

/* Bug#2738741-Added the call at end instead of start as this call will be deleting records in
PA Tables */

      Pa_Hr_Resource.Check_person_reference(p_person_id,
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

  PROCEDURE check_business_group (p_person_id   IN number,
                                  Other_Business_group OUT NOCOPY varchar2) --File.Sql.39 bug 4440895
  IS
  per_delete_allowed  varchar2(1);
  BEGIN
    select 'X'
    into   per_delete_allowed
    from sys.dual
    where  not exists (
           select null
           from pa_implementations_all imp,
                per_all_people_f per
                -- per_person_types ptypes -- commenting out for CWK 11.5.10
           where per.person_id = p_person_id
           and   per.business_group_id = imp.business_group_id
	   and   (per.current_employee_flag = 'Y' OR  -- for 11.5.10 CWK
                  per.current_npw_flag = 'Y')); -- for FP M CWK
	   -- commenting out for CWK 11.5.10
           -- and   per.person_type_id    = ptypes.person_type_id
           -- and   ptypes.system_person_type like '%EMP%' );
     Other_Business_group := 'Y';
   exception
    when NO_DATA_FOUND then
      Other_Business_group := 'N';
    when OTHERS then
      Raise;
/* ***
     when NO_DATA_FOUND then
       hr_utility.set_message (275, 'PA_PER_PHS1_NO_DEL');
       hr_utility.raise_error;
** */
  END check_business_group;

  PROCEDURE phase2 (p_person_id   number)
  IS
  --
  v_delete_permitted    varchar2(1);
  dummy                 varchar2(240);
  cursor pa_per_exists is
  SELECT 'X'
  FROM   fnd_product_installations fpi
  ,      pa_implementations_all imp
  WHERE  fpi.application_id = 275
  AND    fpi.status         = 'I';
  --
  BEGIN
      --
      hr_utility.set_location('PA_PERSON.PA_PREDEL_VALIDATION', 1);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    pa_compensation_details         pa
                where   pa.person_id                    = P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6285_ALL_PA_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PA_PERSON.PA_PREDEL_VALIDATION', 2);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    pa_emp_bill_rate_overrides      pa
                where   pa.project_id > -1
                  and   pa.task_id    > -1
                  and   pa.person_id                    = P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6286_ALL_PA2_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PA_PERSON.PA_PREDEL_VALIDATION', 3);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    pa_job_assignment_overrides     pa
                where ((pa.project_id > -1   AND
                        pa.person_id                    = P_PERSON_ID)
                        OR
                       (pa.task_id > -1      AND
                        pa.person_id                    = P_PERSON_ID)));
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6287_ALL_PA3_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PA_PERSON.PA_PREDEL_VALIDATION', 4);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  /*+ INDEX ( pa PA_BILL_RATES_U1 ) */
                        null
                from    pa_bill_rates                   pa
                where   pa.bill_rate_organization_id > -1
                  and   pa.std_bill_rate_schedule <> 'DUMMY'
                  and   pa.person_id                    = P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6288_ALL_PA4_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PA_PERSON.PA_PREDEL_VALIDATION', 5);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    pa_project_players              pa
                where   pa.person_id                    = P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6289_ALL_PA5_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PA_PERSON.PA_PREDEL_VALIDATION', 6);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    pa_agreements                   pa
                where   pa.owned_by_person_id           = P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6290_ALL_PA6_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PA_PERSON.PA_PREDEL_VALIDATION', 7);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    pa_tasks                        pa
                where   pa.task_manager_person_id       = P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6295_ALL_PA7_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PA_PERSON.PA_PREDEL_VALIDATION', 8);
      --
      begin
        select /*+ INDEX (pa PA_CREDIT_RECEIVERS_U1) */
                'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    pa_credit_receivers             pa
                where   pa.person_id                    = P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6297_ALL_PA8_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PA_PERSON.PA_PREDEL_VALIDATION', 9);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    pa_expenditures                 pa
                where   pa.incurred_by_person_id        = P_PERSON_ID);

	select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    pa_expenditures                 pa
                where   pa.entered_by_person_id        = P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6300_ALL_PA9_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PA_PERSON.PA_PREDEL_VALIDATION', 10);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    pa_draft_invoices               pa
                where   pa.approved_by_person_id        = P_PERSON_ID
                or      pa.released_by_person_id        = P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6301_ALL_PA10_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --

/* -- sowong - these lines of code are removed since PA EMPLOYEE ACCUM
   --          references are not needed (see bug 967781).

      hr_utility.set_location('PA_PERSON.PA_PREDEL_VALIDATION', 11);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    pa_employee_accum               pa
                where   pa.person_id                    = P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6302_ALL_PA11_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
*/

      hr_utility.set_location('PA_PERSON.PA_PREDEL_VALIDATION', 12);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    pa_routings                     pa
                where  (pa.routed_to_person_id          = P_PERSON_ID
                        OR
                        pa.routed_from_person_id        = P_PERSON_ID));
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_7057_ALL_PA12_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PA_PERSON.PA_PREDEL_VALIDATION', 16);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    pa_transaction_controls         pa
                where   pa.project_id > -1
                  and   pa.person_id                    = P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_7061_ALL_PA16_PER_NO_DEL');
                hr_utility.raise_error;
      end;

      open pa_per_exists;
      fetch pa_per_exists into dummy;
      if pa_per_exists%found then
	 hr_utility.set_message (275,'PA_PER_CANT_DELETE');
	 hr_utility.raise_error;
      end if;
      close pa_per_exists;
      --
      --
  END phase2;
--
END pa_person;

/
