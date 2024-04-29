--------------------------------------------------------
--  DDL for Package Body HRWSDPR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRWSDPR" as
/* $Header: pywsdpr1.pkb 115.0 99/07/17 06:50:29 porting ship $ */
  procedure get_period_for_date (p_payroll_id		number,
				 p_given_date		date,
				 p_period	IN OUT	varchar2,
				 p_start_date	IN OUT	date,
				 p_end_date	IN OUT	date,
				 p_session_date		date) is
    cursor c is
  	select period_name, start_date, end_date
  	from   per_time_periods  ptp
  	where  p_payroll_id	= ptp.payroll_id
	and    p_given_date	between ptp.start_date and ptp.end_date
	and    ptp.start_date   <= p_session_date;
  begin
    open  c;
    fetch c into p_period, p_start_date, p_end_date;
    if (c%notfound) then
      close c;
      hr_utility.set_message (801, 'HR_6552_PAY_OUTSIDE_PERIODS');
      hr_utility.raise_error;
    else
      close c;
    end if;
  end get_period_for_date;

end hrwsdpr;

/
