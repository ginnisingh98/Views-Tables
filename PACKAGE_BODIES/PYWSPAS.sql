--------------------------------------------------------
--  DDL for Package Body PYWSPAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYWSPAS" as
/* $Header: pywspas1.pkb 115.0 99/07/17 06:50:45 porting ship $ */
  --
  -- get the start date for the earliest record for the assignment,
  -- and the end date for the latest record for it. These delimit the
  -- session date range which may be set in called forms.
  --
  procedure get_date_limits (p_assignment_id		number,
			     p_earliest_date	IN OUT	date,
			     p_latest_date	IN OUT	date) is

    cursor c is
  	select min (effective_start_date),
	       max (effective_end_date)
  	from   per_assignments_f
  	where  assignment_id = p_assignment_id ;
  begin
    open  c;
    fetch c into p_earliest_date, p_latest_date;
    if (c%notfound) then
      close c;
      hr_utility.set_message (801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token ('PROCEDURE', 'pywspas.get_date_limits');
      hr_utility.set_message_token ('STEP', '1');
      hr_utility.raise_error;
    else
      close c;
    end if;
  end get_date_limits;

end pywspas;

/
