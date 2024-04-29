--------------------------------------------------------
--  DDL for Package Body PER_GET_ASG_POS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GET_ASG_POS" AS
/* $Header: pegetpos.pkb 120.0.12010000.1 2009/08/17 05:34:20 sathkris noship $ */
  function start_date (p_assignment_id	in number,
			p_position_id  	in number,
			p_effective_start_date in date,
			p_effective_end_date   in date) return date is
-- set up the variables used in the cursor

  c_effective_start_date date := null;
  c_effective_end_date date := null;
  r_effective_start_date date := p_effective_start_date;

  cursor c1 is
    select effective_start_date,
           effective_end_date
    from per_all_assignments_f x
    where p_assignment_id = x.assignment_id
    and p_position_id = x.position_id
    and   p_effective_start_date >= x.effective_start_date
    order by x.effective_start_date desc;
  begin
    open c1;
    loop
      fetch c1 into c_effective_start_date, c_effective_end_date ;
      exit when c1%notfound;
      if r_effective_start_date -1 = c_effective_end_date  then
        r_effective_start_date := c_effective_start_date;
      end if ;
    end loop;
    close c1;
    return r_effective_start_date;
  end start_date;
--
  function end_date (p_assignment_id 	in number,
			p_position_id	in number,
			p_effective_start_date in date,
			p_effective_end_date in date ) return date is

-- set up the variables used in the cursor

  c_effective_start_date date := null;
  c_effective_end_date date  := null;
  r_effective_end_date date  := p_effective_end_date;


-- Get the start and end dates of rows >= the row passed in
  cursor c1 is
    select asg.effective_start_date,
 	   asg.effective_end_date
    from	 per_all_assignments_f asg
		,per_assignment_status_types past
    where p_assignment_id = assignment_id
    and   p_position_id = position_id
    and   p_effective_start_date <= effective_start_date
    and ( asg.assignment_status_type_id = past.assignment_status_type_id
	  and past.per_system_status <> 'TERM_ASSIGN')
    -- start changes for 8357127
    and   assignment_type = (
          select assignment_type
          from per_all_assignments_f
          where assignment_id = p_assignment_id
          and  p_effective_start_date between effective_start_date and effective_end_date
          )
    -- end changes for 8357127
    order by asg.effective_start_date asc;

  begin
    open c1;
      loop
        fetch c1 into c_effective_start_date, c_effective_end_date;
        exit when c1%notfound;
        -- if the next record is contiguous, use it's EED
        if r_effective_end_date = c_effective_start_date -1 then
          r_effective_end_date := c_effective_end_date;
        end if;
      end loop;
    close c1;
    -- If date is eot, NULL is returned
    if r_effective_end_date <> hr_general.end_of_time then
      return r_effective_end_date;
    else
      return NULL;
    end if;
  end end_date;
  --
end per_get_asg_pos;

/
