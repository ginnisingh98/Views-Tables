--------------------------------------------------------
--  DDL for Package Body PA_LOOKUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_LOOKUPS_PKG" AS
/* $Header: PAXSLKPB.pls 115.0 99/07/16 15:32:32 porting ship $  */
------------------------------------------------------------------------------
PROCEDURE check_unique (x_return_status 	IN OUT NUMBER
			, x_lookup_type		IN     VARCHAR2
			, x_lookup_code		IN     VARCHAR2
			, x_meaning		IN     VARCHAR2)
IS
	x_dummy NUMBER;

BEGIN
	x_return_status := 0;

	select 	1
	into    x_dummy
	from	sys.dual
	where 	not exists
			(select 1
			 from 	pa_lookups p
			 where  p.lookup_type = x_lookup_type
			 and   ((UPPER(p.lookup_code) = UPPER(x_lookup_code)) or
						 (UPPER(p.meaning) = UPPER(x_meaning)))
			 );

	x_return_status := 0;

	EXCEPTION
		WHEN NO_DATA_FOUND then
		x_return_status := 1;

		WHEN OTHERS then
		x_return_status  := SQLCODE;

END check_unique;

-----------------------------------------------------------------------------
PROCEDURE check_references (x_return_status 	IN OUT NUMBER
			    , x_stage		IN OUT NUMBER
			    , x_lookup_code     IN     VARCHAR2)
IS
	x_dummy NUMBER;


BEGIN
	x_return_status	:= 0;

	if  (x_stage = 10)  then
-- Credit Type

	    Begin
	    	select	1
	    	into    x_dummy
	    	from 	sys.dual
	    	where 	not exists
			(select 1
			 from pa_credit_receivers cr
			 where cr.credit_type_code = x_lookup_code);

		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 11;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
	    End;
	    Return;

	elsif	(x_stage = 20)	then
-- Unit Type

	   Begin
-- Unit Type, Expenditure Types
		select	1
	    	into    x_dummy
	    	from 	sys.dual
	    	where 	not exists
			(select 1
			 from pa_expenditure_types et
			 where et.unit_of_measure  = x_lookup_code);

		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 21;
			return;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
			return;
	    End;

	   Begin
-- Unit Type, Bill Rates
		select	1
	    	into    x_dummy
	    	from 	sys.dual
	    	where 	not exists
			(select 1
			 from pa_bill_rates br
			 where br.bill_rate_unit  = x_lookup_code);

		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 22;
			return;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
			return;
	    End;
	  Begin
-- Unit Type, Resources
		select	1
	    	into    x_dummy
	    	from 	sys.dual
	    	where 	not exists
			(select 1
			 from pa_resources r
			 where r.unit_of_measure  = x_lookup_code);

		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 23;
			return;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
			return;
	    End;
	Begin
-- Unit Type, Employee Bill Rates Overrides
		select	1
	    	into    x_dummy
	    	from 	sys.dual
	    	where 	not exists
			(select 1
			 from pa_emp_bill_rate_overrides eb
			 where eb.bill_rate_unit  = x_lookup_code);

		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 24;
			return;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
			return;
	    End;
	Begin
-- Unit Type, Job Bill Rate Overrides
		select	1
	    	into    x_dummy
	    	from 	sys.dual
	    	where 	not exists
			(select 1
			 from pa_job_bill_rate_overrides jb
			 where jb.bill_rate_unit  = x_lookup_code);

		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 25;
			return;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
			return;
	    End;
	    Return;

	elsif	(x_stage = 30)	then


--  Service Type

	Begin
-- Service Type, Project Types
		select	1
	    	into    x_dummy
	    	from 	sys.dual
	    	where 	not exists
			(select 1
			 from pa_project_types pt
			 where pt.service_type_code  = x_lookup_code);

		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 31;
			return;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
			return;
	    End;

	Begin
-- Service Type, Tasks
		select	1
	    	into    x_dummy
	    	from 	sys.dual
	    	where 	not exists
			(select 1
			 from pa_tasks t
			 where t.service_type_code  = x_lookup_code);

		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 32;
			return;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
			return;
	    End;
	    Return;

	elsif	(x_stage = 40)	then

--  Revenue Category

	Begin
-- Revenue Category, Expenditure Types
		select	1
	    	into    x_dummy
	    	from 	sys.dual
	    	where 	not exists
			(select 1
			 from pa_expenditure_types et
			 where et.revenue_category_code = x_lookup_code);

		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 41;
			return;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
			return;
	    End;
	Begin
-- Revenue Category, Event Types
		select	1
	    	into    x_dummy
	    	from 	sys.dual
	    	where 	not exists
			(select 1
			 from pa_event_types et
			 where et.revenue_category_code = x_lookup_code);

		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 42;
			return;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
			return;
	    End;
	Begin
-- Revenue Category, Resource Txn Attributes
		select	1
	    	into    x_dummy
	    	from 	sys.dual
	    	where 	not exists
			(select 1
			 from pa_resource_txn_attributes rt
			 where rt.revenue_category = x_lookup_code);

		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 43;
			return;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
			return;
	    End;
	    Return;

	elsif	(x_stage = 50)	then
-- Project Statuses
	Begin
		select	1
	    	into    x_dummy
	    	from 	sys.dual
	    	where 	not exists
			(select 1
			 from pa_projects p
			 where p.project_status_code = x_lookup_code);

		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 51;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
	    End;
	    Return;

	elsif	(x_stage = 60)	then

--  Customer Project Relationship

	Begin
		select	1
	    	into    x_dummy
	    	from 	sys.dual
	    	where 	not exists
			(select 1
			 from pa_project_customers pc
			 where pc.project_relationship_code = x_lookup_code);

		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 61;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
	    End;
	    Return;

	elsif	(x_stage = 70)	then

-- Project Contact Type

	Begin
		select	1
	    	into    x_dummy
	    	from 	sys.dual
	    	where 	not exists
			(select 1
			 from pa_project_contacts pc
			 where pc.project_contact_type_code  = x_lookup_code);

		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 71;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
	    End;
	    Return;

	elsif	(x_stage = 80)	then

-- Budget Change Reason

	Begin
-- Budget Change Reason, Budget Lines
		select	1
	    	into    x_dummy
	    	from 	sys.dual
	    	where 	not exists
			(select 1
			 from pa_budget_lines bl
			 where bl.change_reason_code  = x_lookup_code);

		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 81;
			return;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
			return;
	    End;
	Begin
-- Budget Change Reason, Budget Versions
		select	1
	    	into    x_dummy
	    	from 	sys.dual
	    	where 	not exists
			(select 1
			 from pa_budget_versions bv
			 where bv.change_reason_code  = x_lookup_code);

		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 82;
			return;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
			return;
	    End;
	    Return;

    elsif	(x_stage = 90)	then
  -- PM Product code  Pa projects
         Begin
              select 1 into x_dummy
              from sys.dual
              where not exists
                 (select 1 from pa_projects where pm_product_code
                  = x_lookup_code );
		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 92;
			return;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
			return;
	    End;
  -- PM Product code  Pa budget versions
         Begin
              select 1 into x_dummy
              from sys.dual
              where not exists
                 (select 1 from pa_budget_versions where pm_product_code
                  = x_lookup_code );
		EXCEPTION
			WHEN NO_DATA_FOUND then
			x_return_status := 1;
			x_stage	:= 93;
			return;

			WHEN OTHERS then
			x_return_status  := SQLCODE;
			return;
	    End;
	    Return;
	end if;

END check_references;
--===========================================================================
END pa_lookups_pkg;

/
