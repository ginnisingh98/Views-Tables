--------------------------------------------------------
--  DDL for Package Body WIP_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_PERSON" AS
 /* $Header: wiphrdmb.pls 115.8 2004/02/27 01:46:19 yowang ship $ */


  PROCEDURE wip_predel_validation (p_person_id	number) IS
	v_delete_permitted	varchar2(1);

  BEGIN
	/* Sets package variables to store location name and stage number which
	 * enables unexpected errors to be located more easily
	 */
	hr_utility.set_location('WIP_PERSON.WIP_PREDEL_VALIDATION', 1);

	begin
	  select 'Y'
	  into v_delete_permitted
	  from sys.dual
	  where not exists (
		select null
		from wip_employee_labor_rates welr
		where welr.employee_id = P_PERSON_ID);

	exception
	  when NO_DATA_FOUND then
		hr_utility.set_message(706, 'WIP_EMPLOYEE_DELETE');
		hr_utility.raise_error;
	end;

	hr_utility.set_location('WIP_PERSON.WIP_PREDEL_VALIDATION', 2);

	begin
	  select 'Y'
	  into v_delete_permitted
	  from sys.dual
 	  where not exists (
		select null
		from wip_transactions wt
		where wt.employee_id = P_PERSON_ID);

	exception
	  when NO_DATA_FOUND then
		hr_utility.set_message(706, 'WIP_EMPLOYEE_DELETE');
		hr_utility.raise_error;
	end;


        hr_utility.set_location('WIP_PERSON.WIP_PREDEL_VALIDATION', 3);

        begin
          select 'Y'
          into v_delete_permitted
          from sys.dual
          where not exists (
                select null
                  from bom_resource_employees be,
                       wip_op_resource_instances wi
                 where be.organization_id = wi.organization_id
                   and be.instance_id = wi.instance_id
                   and be.person_id = P_PERSON_ID);

        exception
          when NO_DATA_FOUND then
                hr_utility.set_message(706, 'WIP_EMPLOYEE_DELETE');
                hr_utility.raise_error;
        end;

  END wip_predel_validation;

END wip_person;

/
