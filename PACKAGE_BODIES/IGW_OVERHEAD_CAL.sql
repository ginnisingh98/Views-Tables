--------------------------------------------------------
--  DDL for Package Body IGW_OVERHEAD_CAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_OVERHEAD_CAL" as
-- $Header: igwbuovb.pls 115.31 2002/11/14 18:48:26 vmedikon ship $

  PROCEDURE get_date_details(	p_input_date		 DATE
				,x_fiscal_year	     OUT NOCOPY NUMBER
				,x_fiscal_start_date OUT NOCOPY DATE
				,x_fiscal_end_date   OUT NOCOPY DATE
				,x_return_status     OUT NOCOPY VARCHAR2
				,x_msg_data	     OUT NOCOPY VARCHAR2) is

  l_profile_date	 VARCHAR2(4);
  l_profile_date_number  NUMBER;
  l_date_number  	 NUMBER;
  l_fiscal_year  	 NUMBER;
  l_dummy_start	   	 VARCHAR2(8);
  l_dummy_end	   	 VARCHAR2(8);
  BEGIN

    l_profile_date := fnd_profile.value('IGW_FISCAL_YEAR_START_MMDD');
    l_profile_date_number := l_profile_date;
    --dbms_output.put_line('the l_profile_date_number is '||l_profile_date_number);

    l_date_number:= to_number(to_char(p_input_date, 'MM'||'DD'));

    if l_date_number <  l_profile_date_number and
    				l_date_number >= 101 then
      l_fiscal_year:= to_number(to_char(p_input_date, 'YYYY'));
      --dbms_output.put_line('the l_fiscal_year is '||l_fiscal_year);
    else
      l_fiscal_year:= to_number(to_char(p_input_date, 'YYYY')) + 1;
     --dbms_output.put_line('the l_fiscal_year is ELSE '||l_fiscal_year);
    end if;

    l_dummy_start := l_profile_date||l_fiscal_year;
    l_dummy_end   := l_profile_date||(l_fiscal_year+1);
    x_fiscal_start_date := add_months(to_date(l_dummy_start, 'MMDDYYYY'),-12);
    x_fiscal_end_date := add_months(to_date(l_dummy_end, 'MMDDYYYY') -1, -12);
    -- don't use the fiscal date obtained above. Use the one below. This is fix for BUG 2317219
    -- The fiscal start date and end date above, however, seem to be correct under all conditions
    x_fiscal_year := greatest(to_number(to_char(x_fiscal_start_date, 'YYYY')),to_number(to_char(x_fiscal_end_date, 'YYYY')));

  END get_date_details;

  PROCEDURE get_rate_id    (p_expenditure_type 		VARCHAR2
			   ,p_expenditure_category_flag VARCHAR2
			   ,p_rate_class_type	 	VARCHAR2
			   ,x_rate_class_id    IN OUT NOCOPY	NUMBER
			   ,x_rate_type_id     OUT NOCOPY	NUMBER
			   ,x_return_status    OUT NOCOPY	VARCHAR2
			   ,x_msg_data         OUT NOCOPY	VARCHAR2) is
    l_parent_category   VARCHAR2(30);
    cursor c_rate_id is
    select rc.rate_class_id
    ,      rt.rate_type_id
    from   igw_rate_classes 	  rc
    , 	   igw_rate_types 	  rt
    ,	   igw_exp_type_rate_types rct
    where  rc.rate_class_id = rt.rate_class_id
    and	   rt.rate_type_id = rct.rate_type_id
    and    rc.rate_class_id = rct.rate_class_id
    and    rct.expenditure_category = l_parent_category
    and    rc.rate_class_type = p_rate_class_type
    and    rc.rate_class_id = nvl(x_rate_class_id,rc.rate_class_id);
  BEGIN
    if p_expenditure_category_flag = 'N' then
      select parent_category
      into   l_parent_category
      from   igw_budget_expenditures_v
      where  budget_expenditure = p_expenditure_type
      and    expenditure_category_flag = p_expenditure_category_flag
      and    parent_category is not null;
    elsif p_expenditure_category_flag = 'Y' then
      l_parent_category := p_expenditure_type;
    end if;
    open c_rate_id;
    fetch c_rate_id into x_rate_class_id, x_rate_type_id;
    close c_rate_id;
  EXCEPTION
    when others then
      x_return_status := 'U';
      x_msg_data :=  SQLCODE||' '||SQLERRM;
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'GET_FISCAL_YEAR');
  END;


  PROCEDURE get_rate (	p_proposal_id		NUMBER
			,p_version_id		NUMBER
			,p_fiscal_year 		NUMBER
			,p_activity_type_code   VARCHAR2
			,p_location_code 	VARCHAR2
			,p_rate_class_id 	NUMBER
			,p_rate_type_id 	NUMBER
			,x_rate		   OUT NOCOPY  NUMBER
			,x_rate_ov	   OUT NOCOPY  NUMBER
			,x_start_date	   OUT NOCOPY	DATE
			,x_return_status   OUT NOCOPY	VARCHAR2
			,x_msg_data        OUT NOCOPY  VARCHAR2) is

  l_activity_type	VARCHAR2(80);
  l_location		VARCHAR2(80);
  l_rate_class		VARCHAR2(250);
  l_rate_type		VARCHAR2(250);

  BEGIN
    if p_rate_class_id is null and p_rate_type_id is null then
      x_rate := 0;
      x_rate_ov := 0;
    else
      begin
        --selecting values for tokens
--commented for GMSINSTALL
--independent of post-award

        select  meaning
	into	l_activity_type
	from 	fnd_lookups
	where   lookup_type = 'IGW_ACTIVITY_TYPES'
  	and	lookup_code = p_activity_type_code;
--     end if;

        --selecting values for tokens
        select  meaning
	into	l_location
	from 	fnd_lookups
	where   lookup_type = 'IGW_LOCATION'
  	and	lookup_code = p_location_code;

        --selecting values for tokens
 	select  rc.description
	,	rt.description
	into	l_rate_class
	,	l_rate_type
	from	igw_rate_classes   rc
	,	igw_rate_types	    rt
	where	rc.rate_class_id = rt.rate_class_id
	and	rc.rate_class_id = p_rate_class_id
	and	rt.rate_type_id = p_rate_type_id;

        begin
          select rate,start_date
          into   x_rate, x_start_date
          from   igw_institute_rates 	ir
          where  ir.rate_class_id = p_rate_class_id
          and    ir.rate_type_id = p_rate_type_id
          and    ir.activity_type_code = p_activity_type_code
          and    ir.location_code = p_location_code
          and    ir.fiscal_year = p_fiscal_year;
        exception
          when no_data_found then null;
        end;

        begin
          select   applicable_rate, start_date
          into 	   x_rate_ov, x_start_date
          from 	   igw_prop_rates
          where    rate_class_id = p_rate_class_id
          and      rate_type_id = p_rate_type_id
          and      activity_type_code = p_activity_type_code
          and      location_code = p_location_code
          and      fiscal_year = p_fiscal_year
  	  and 	   proposal_id = p_proposal_id
	  and	   version_id = p_version_id;
        exception
          when no_data_found then
	    x_rate_ov := x_rate;
            x_start_date := x_start_date;
        end;
      end;
    end if;
    x_return_status := 'S';
  EXCEPTION
    when no_data_found then
    null;
/* commenting out NOCOPY because we don't want to show these message on recalculations */
/*
      x_return_status := 'I';
      x_msg_data := 'IGW_FISCAL_YEAR_UNDEFINED';
      fnd_message.set_name('IGW', 'IGW_FISCAL_RATE_UNDEFINED');
      fnd_message.set_token('ACTIVITY_TYPE', l_activity_type);
      fnd_message.set_token('LOCATION_CODE', l_location);
      fnd_message.set_token('FISCAL_YEAR', p_fiscal_year);
      fnd_message.set_token('RATE_CLASS', l_rate_class);
      fnd_message.set_token('RATE_TYPE', l_rate_type);
      fnd_msg_pub.add;
*/

    when others then
      x_return_status := 'U';
      x_msg_data :=  SQLCODE||' '||SQLERRM;
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'GET_RATE');
  END get_rate;

---------------------------------------------------------------------
FUNCTION get_applicable_rate (
                               p_proposal_id            number
                               ,p_version_id            number
                               ,p_rate_class_id         number
                               ,p_rate_type_id          number
			       ,p_activity_type_code    varchar2
                               ,p_location_code         varchar2
                               ,p_fiscal_year           number) RETURN NUMBER IS

  l_applicable_rate     number(15);
begin
  select applicable_rate
  into   l_applicable_rate
  from   igw_prop_rates
  where  proposal_id = p_proposal_id
  and    version_id = p_version_id
  and    rate_class_id = p_rate_class_id
  and    rate_type_id = p_rate_type_id
  and    location_code = p_location_code
  and    activity_type_code = p_activity_type_code
  and    fiscal_year = p_fiscal_year;

  return l_applicable_rate;
exception
  when others then
    return null;
end;

-----------------------------------------------------------------------------

  PROCEDURE calc_oh (	p_proposal_id		NUMBER
			,p_version_id		NUMBER
			,p_base_amount 		NUMBER
			,p_budget_start_date 	DATE
			,p_budget_end_date  	DATE
                        ,x_oh_value 	    OUT NOCOPY	NUMBER
                        ,x_oh_value_ov 	    OUT NOCOPY	NUMBER
			,p_activity_type_code 	VARCHAR2
			,p_location_code 	VARCHAR2
			,p_rate_class_id 	NUMBER
			,p_rate_type_id 	NUMBER
			,x_return_status    OUT NOCOPY	VARCHAR2
			,x_msg_data         OUT NOCOPY	VARCHAR2
			,x_msg_count	    OUT NOCOPY NUMBER) is

  l_no_of_days 		NUMBER;
  l_start_fiscal_year 	NUMBER(4);
  l_end_fiscal_year 	NUMBER(4);
  l_new_fiscal_year 	NUMBER(4);
  l_fiscal_diff		NUMBER(4);
  l_oh 			NUMBER;
  l_oh_ov 		NUMBER;
  l_rate_start_date	DATE;
  l_start_date 		DATE;
  l_end_date 		DATE;
  l_start_f_start_date  DATE;
  l_start_f_end_date    DATE;
  l_end_f_start_date    DATE;
  l_end_f_end_date      DATE;
  l_oh_rate 		NUMBER(5,2);
  l_oh_rate_ov 		NUMBER(5,2);
  l_return_status	VARCHAR2(1);
  l_msg_data 		VARCHAR2(200);

  BEGIN
    fnd_msg_pub.initialize;
    l_no_of_days := (p_budget_end_date - p_budget_start_date) +1 ;
    get_date_details(p_budget_start_date
		 	,l_start_fiscal_year
			,l_start_f_start_date
			,l_start_f_end_date
			,l_return_status
			,l_msg_data);
    if l_return_status <> 'S' then
       raise FND_API.G_EXC_ERROR;
    end if;

    get_date_details(p_budget_end_date
		 	,l_end_fiscal_year
			,l_end_f_start_date
			,l_end_f_end_date
			,l_return_status
			,l_msg_data);

    if l_return_status <> 'S' then
       raise FND_API.G_EXC_ERROR;
    end if;
    l_fiscal_diff := (l_end_fiscal_year - l_start_fiscal_year) +1;
    l_start_date := p_budget_start_date;
    l_new_fiscal_year := l_start_fiscal_year;
    l_end_date := l_start_f_end_date;
    for i IN 1 .. l_fiscal_diff
    LOOP

      if l_fiscal_diff = 1 and i = 1 then
        l_end_date := p_budget_end_date;
      end if;

      get_rate(p_proposal_id
	       ,p_version_id
	       ,l_new_fiscal_year
	       ,p_activity_type_code
	       ,p_location_code
	       ,p_rate_class_id
	       ,p_rate_type_id
	       ,l_oh_rate
	       ,l_oh_rate_ov
	       ,l_rate_start_date
	       ,l_return_status
	       ,l_msg_data);

      if l_return_status NOT IN ('S','I') then
        raise FND_API.G_EXC_ERROR;
      end if;

      --dbms_output.put_line('the oh_rate is '||l_oh_rate);
      --dbms_output.put_line('the l_no_of_days '||l_no_of_days);
      --dbms_output.put_line('the l_start_Date '||l_start_date);
      --dbms_output.put_line('the l_end_Date '||l_end_date);
      --dbms_output.put_line('the the base amount '||p_base_amount);

      l_oh := p_base_amount * ((l_end_date - l_start_date)+ 1)/l_no_of_days
							 * l_oh_rate/100;

      l_oh_ov := p_base_amount * ((l_end_date - l_start_date)+ 1)/l_no_of_days
							 * l_oh_rate_ov/100;

      --dbms_output.put_line('the l_oh is '||l_oh);

      l_new_fiscal_year := l_new_fiscal_year + 1;
      l_start_date := l_end_date +1;
      l_end_date := add_months(l_end_date,12);
      if p_budget_end_date< l_end_date then
        l_end_date := p_budget_end_date;
      end if;

      if i = (l_fiscal_diff) then
        l_end_date := p_budget_end_date;
      end if;
      x_oh_value := nvl(l_oh,0) + nvl(x_oh_value,0);
      x_oh_value_ov := nvl(l_oh_ov,0) + nvl(x_oh_value_ov,0);

    END LOOP;
    x_return_status := 'S';
  EXCEPTION
    when FND_API.G_EXC_ERROR then
      x_return_status := l_return_status;
      x_msg_data := l_msg_data;
     fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
    when others then
      x_return_status := 'U';
      x_msg_data :=  SQLCODE||' '||SQLERRM;
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'CALC_OH');
     fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
  END calc_oh;


  PROCEDURE calc_oh_eb(	p_proposal_id		NUMBER
			,p_version_id		NUMBER
			,p_base_amount 		NUMBER
			,p_budget_start_date 	DATE
			,p_budget_end_date  	DATE
                        ,x_oh_value 	    OUT NOCOPY	NUMBER
                        ,x_oh_value_ov 	    OUT NOCOPY	NUMBER
                        ,x_eb_value 	    OUT NOCOPY	NUMBER
                        ,x_eb_value_ov 	    OUT NOCOPY	NUMBER
			,p_activity_type_code 	VARCHAR2
			,p_location_code 	VARCHAR2
			,p_rate_class_id_oh	NUMBER
			,p_rate_type_id_oh 	NUMBER
			,p_rate_class_id_eb	NUMBER
			,p_rate_type_id_eb	NUMBER
			,x_return_status    OUT NOCOPY	VARCHAR2
			,x_msg_data         OUT NOCOPY	VARCHAR2
			,x_msg_count	    OUT NOCOPY NUMBER) is

  l_no_of_days 		NUMBER;
  l_start_fiscal_year 	NUMBER(4);
  l_end_fiscal_year 	NUMBER(4);
  l_new_fiscal_year 	NUMBER(4);
  l_fiscal_diff		NUMBER(4);
  l_oh 			NUMBER;
  l_oh_ov 		NUMBER;
  l_rate_start_date	DATE;
  l_start_date 		DATE;
  l_end_date 		DATE;
  l_start_f_start_date  DATE;
  l_start_f_end_date    DATE;
  l_end_f_start_date    DATE;
  l_end_f_end_date      DATE;
  l_rate 		NUMBER(5,2);
  l_rate_ov 		NUMBER(5,2);
  l_eb 			NUMBER;
  l_eb_ov 		NUMBER;
  l_return_status 	VARCHAR2(1);
  l_msg_data 		VARCHAR2(200);

  BEGIN
    fnd_msg_pub.initialize;
    l_no_of_days := (p_budget_end_date - p_budget_start_date) +1 ;
    get_date_details(p_budget_start_date
		 	,l_start_fiscal_year
			,l_start_f_start_date
			,l_start_f_end_date
			,l_return_status
			,l_msg_data);

    if l_return_status <> 'S' then
       raise FND_API.G_EXC_ERROR;
    end if;

    get_date_details(p_budget_end_date
		 	,l_end_fiscal_year
			,l_end_f_start_date
			,l_end_f_end_date
			,l_return_status
			,l_msg_data);

    if l_return_status <> 'S' then
       raise FND_API.G_EXC_ERROR;
    end if;
    l_fiscal_diff := (l_end_fiscal_year - l_start_fiscal_year) +1;
    --dbms_output.put_line('the fiscal diff is '||l_fiscal_diff);
    l_start_date := p_budget_start_date;
    l_new_fiscal_year := l_start_fiscal_year;
    l_end_date := l_start_f_end_date;

    if l_return_status <> 'S' then
       raise FND_API.G_EXC_ERROR;
    end if;

    for i IN 1 .. l_fiscal_diff
    LOOP

      if l_fiscal_diff = 1 and i = 1 then
        l_end_date := p_budget_end_date;
      end if;

      get_rate(p_proposal_id
	       ,p_version_id
               ,l_new_fiscal_year
	       ,p_activity_type_code
	       ,p_location_code
	       ,p_rate_class_id_eb
	       ,p_rate_type_id_eb
	       ,l_rate
	       ,l_rate_ov
	       ,l_rate_start_date
	       ,l_return_status
	       ,l_msg_data);
      --dbms_output.put_line('the rate for eb is '||l_rate);
      --dbms_output.put_line('the rate for eb_ov is '||l_rate_ov);
      if l_return_status NOT IN ('S','I') then
        raise FND_API.G_EXC_ERROR;
      end if;

      l_eb := nvl(p_base_amount * ((l_end_date - l_start_date)+ 1)/l_no_of_days
							 * nvl(l_rate,0)/100,0);

      l_eb_ov := nvl(p_base_amount * ((l_end_date - l_start_date)+ 1)/l_no_of_days
							 * nvl(l_rate_ov,0)/100,0);
      --dbms_output.put_line('the l_eb is '||l_eb);
      --dbms_output.put_line('the l_end_date_eb is '||l_end_date);
      --dbms_output.put_line('the l_start_date_eb is '||l_start_date);
      --dbms_output.put_line('the l_no_of_days_eb is '||l_no_of_days);

      get_rate(p_proposal_id
	       ,p_version_id
	       ,l_new_fiscal_year
	       ,p_activity_type_code
	       ,p_location_code
	       ,p_rate_class_id_oh
	       ,p_rate_type_id_oh
	       ,l_rate
	       ,l_rate_ov
	       ,l_rate_start_date
	       ,l_return_status
	       ,l_msg_data);
      --dbms_output.put_line('the rate for oh is '||l_rate);
      if l_return_status NOT IN ('S','I') then
        raise FND_API.G_EXC_ERROR;
      end if;


      l_oh := ((p_base_amount + ((nvl(l_eb,0) * l_no_of_days/((l_end_date - l_start_date)+ 1)))) *
                       ((l_end_date - l_start_date)+ 1))/l_no_of_days * l_rate/100;


      l_oh_ov := ((p_base_amount + ((nvl(l_eb_ov,0) * l_no_of_days/((l_end_date - l_start_date)+ 1)))) *
                    ((l_end_date - l_start_date)+ 1))/l_no_of_days * l_rate_ov/100;

      --dbms_output.put_line('the l_oh is '||l_oh);
      --dbms_output.put_line('the l_end_date_oh is '||l_end_date);
      --dbms_output.put_line('the l_start_date_oh is '||l_start_date);
      --dbms_output.put_line('the l_no_of_days_oh is '||l_no_of_days);

      l_new_fiscal_year := l_new_fiscal_year + 1;
      l_start_date := l_end_date +1;
      l_end_date := add_months(l_end_date,12);
      if p_budget_end_date< l_end_date then
        l_end_date := p_budget_end_date;
      end if;

      if i = (l_fiscal_diff) then
        l_end_date := p_budget_end_date;
      end if;
      x_eb_value := l_eb + nvl(x_eb_value,0);
      x_eb_value_ov := l_eb_ov + nvl(x_eb_value_ov,0);
      x_oh_value := l_oh + nvl(x_oh_value,0);
      x_oh_value_ov := l_oh_ov + nvl(x_oh_value_ov,0);

    END LOOP;
     x_return_status := 'S';

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      x_return_status := l_return_status;
      x_msg_data := l_msg_data;
     fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
    when others then
      x_return_status := 'U';
      x_msg_data :=  SQLCODE||' '||SQLERRM;
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'CALC_OH_EB');
     fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
  END calc_oh_eb;

/* Inflation is calculated based on each fiscal year. If
a period falls in two(or more) fiscal years, the inflation is calculated
based on the two(or more) rates available for the two(or more) fiscal years.
For each part, number of days of the period falling in each fiscal year
and the corresponding rate for the fiscal year is taken to calculate
the inflation
*/

  PROCEDURE calc_inflation(p_proposal_id		NUMBER
			   ,p_version_id		NUMBER
			   ,p_base_amount 		NUMBER
			   ,p_budget_start_date 	DATE
			   ,p_budget_end_date  	        DATE
                           ,x_inflated_amt	  OUT NOCOPY	NUMBER
			   ,p_activity_type_code 	VARCHAR2
			   ,p_location_code 	        VARCHAR2
			   ,p_rate_class_id_inf		NUMBER
			   ,p_rate_type_id_inf 		NUMBER
			   ,x_return_status       OUT NOCOPY	VARCHAR2
			   ,x_msg_data            OUT NOCOPY	VARCHAR2
			   ,x_msg_count	          OUT NOCOPY   NUMBER) is

  l_no_of_days 		NUMBER;
  l_start_fiscal_year 	NUMBER(4);
  l_end_fiscal_year 	NUMBER(4);
  l_new_fiscal_year 	NUMBER(4);
  l_fiscal_diff		NUMBER(4);
  l_inflated_amount	NUMBER;
  l_base_amount		NUMBER;
  l_rate_start_date	DATE;
  l_start_date 		DATE;
  l_end_date 		DATE;
  l_start_f_start_date  DATE;
  l_start_f_end_date    DATE;
  l_end_f_start_date    DATE;
  l_end_f_end_date      DATE;
  l_inflated_rate 	NUMBER(5,2);
  l_inflated_rate_ov 	NUMBER(5,2);
  l_return_status	VARCHAR2(1);
  l_msg_data 		VARCHAR2(200);
  BEGIN
    fnd_msg_pub.initialize;
    l_base_amount := p_base_amount;
    l_no_of_days := (p_budget_end_date - p_budget_start_date) +1 ;
    get_date_details(p_budget_start_date
		 	,l_start_fiscal_year
			,l_start_f_start_date
			,l_start_f_end_date
			,l_return_status
			,l_msg_data);
    if l_return_status <> 'S' then
       raise FND_API.G_EXC_ERROR;
    end if;

    get_date_details(p_budget_end_date
		 	,l_end_fiscal_year
			,l_end_f_start_date
			,l_end_f_end_date
			,l_return_status
			,l_msg_data);

    if l_return_status <> 'S' then
       raise FND_API.G_EXC_ERROR;
    end if;

    /*fiscal diff is calculated to seed how many fiscal years
    is a period spans into */

    l_fiscal_diff := (l_end_fiscal_year - l_start_fiscal_year) +1;
    l_start_date := p_budget_start_date;
    l_new_fiscal_year := l_start_fiscal_year;
    l_end_date := l_start_f_end_date;
    --dbms_output.put_line('l_fiscal_diff is'||l_fiscal_diff);

    for i IN 1 .. l_fiscal_diff
    LOOP

      if l_fiscal_diff = 1 and i = 1 then
        l_end_date := p_budget_end_date;
      end if;
      get_rate(p_proposal_id
	       ,p_version_id
	       ,l_new_fiscal_year
	       ,p_activity_type_code
	       ,p_location_code
	       ,p_rate_class_id_inf
	       ,p_rate_type_id_inf
	       ,l_inflated_rate
	       ,l_inflated_rate_ov
	       ,l_rate_start_date
	       ,l_return_status
	       ,l_msg_data);
      if l_return_status NOT IN ('S','I') then
        raise FND_API.G_EXC_ERROR;
      end if;
/*
      --dbms_output.put_line('the inflated_rate is '||l_inflated_rate);
      --dbms_output.put_line('the l_no_of_days '||l_no_of_days);
      --dbms_output.put_line('the l_start_Date '||l_start_date);
      --dbms_output.put_line('the l_end_Date '||l_end_date);
      --dbms_output.put_line('the the base amount '||l_base_amount);
*/
      l_inflated_amount := l_base_amount * ((l_end_date - l_start_date)+ 1)/l_no_of_days
							 * l_inflated_rate_ov/100;
      --dbms_output.put_line('the inflated amount is  '||l_inflated_amount);
      l_new_fiscal_year := l_new_fiscal_year + 1;
      l_start_date := l_end_date+1;

      if p_budget_end_date > add_months(l_end_date,12) then
        l_end_date := add_months(l_end_date,12);
      else
        l_end_date := p_budget_end_date;
      end if;

      if i = (l_fiscal_diff) then
        l_end_date := p_budget_end_date;
      end if;
      --l_base_amount := l_base_amount + nvl(l_inflated_amount,0);
      --x_inflated_amt := l_base_amount;
      x_inflated_amt := nvl(x_inflated_amt,0) + nvl(l_inflated_amount,0);
    END LOOP;
    x_inflated_amt := l_base_amount + x_inflated_amt;
    x_return_status := 'S';
  EXCEPTION
    when FND_API.G_EXC_ERROR then
      x_return_status := l_return_status;
      x_msg_data := l_msg_data;
     fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
    when others then
      x_return_status := 'U';
      x_msg_data :=  SQLCODE||' '||SQLERRM;
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'CALC_INFLATION');
     fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
  END calc_inflation;




  PROCEDURE calc_sal_between_months(p_end_date		 DATE
				    ,p_start_date	 DATE
				    ,p_base_amount	 NUMBER
				    ,x_final_sal     OUT NOCOPY NUMBER
				    ,x_return_status OUT NOCOPY VARCHAR2
				    ,x_msg_data	     OUT NOCOPY VARCHAR2) IS
  l_start_date1		DATE;
  l_end_date1		DATE;
  l_end_date2		DATE;
  l_base_amount1	NUMBER;
  l_base_amount2	NUMBER;
  l_base_amount3	NUMBER;
  l_months_diff		NUMBER(10);
  BEGIN
    l_end_date1 := add_months(last_day(p_end_date), -1);
    l_start_date1:= last_day(p_start_date);
    --dbms_output.put_line('l_end_date1 and l_start_date1 are'||l_end_date1||'and'||l_start_date1);
    l_months_diff:= months_between((l_end_date1+1 ), (l_start_date1 +1));
    --dbms_output.put_line('l_months_diff is >>> '||l_months_diff);

    l_base_amount1 := (p_end_date - (l_end_date1))/(last_day(p_end_date)-l_end_date1)*p_base_amount/12;
    --dbms_output.put_line('l_base_amount1 is >>>> '||l_base_amount1);

    l_base_amount2 := ((l_start_date1 - p_start_date) + 1)/(l_start_date1-add_months(l_start_date1, -1))
						 * p_base_amount/12;

    --dbms_output.put_line('l_base_amount2 is>>>> '||l_base_amount2);

    l_base_amount3 := l_months_diff * p_base_amount/12;
    --dbms_output.put_line('l_base_amount3 is>>>>>'||l_base_amount3);

    x_final_sal := l_base_amount1 + l_base_amount2 + l_base_amount3;
  EXCEPTION
    when others then
      x_return_status := 'U';
      x_msg_data :=  SQLCODE||' '||SQLERRM;
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'CALC_SAL_BETWEEN_MONTHS');
  END calc_sal_between_months;


  PROCEDURE calc_salary(p_proposal_id			NUMBER
			,p_version_id			NUMBER
			,p_base_amount 			NUMBER
			,p_effective_date		DATE
			,p_appointment_type		VARCHAR2
			,p_line_start_date 		DATE
			,p_line_end_date  		DATE
                        ,x_inflated_salary    	OUT NOCOPY	NUMBER
                        ,x_inflated_salary_ov 	OUT NOCOPY	NUMBER
			,p_expenditure_type 		VARCHAR2
			,p_expenditure_category_flag	VARCHAR2
			,p_activity_type_code 		VARCHAR2
			,p_location_code 		VARCHAR2
			,x_return_status    	OUT NOCOPY	VARCHAR2
			,x_msg_data         	OUT NOCOPY	VARCHAR2
			,x_msg_count	    	OUT NOCOPY 	NUMBER) is

  l_loop_counter	NUMBER(10);
  l_effect_fiscal_year 	NUMBER(4);
  l_effect_f_start_date DATE;
  l_effect_f_end_date DATE;
  l_start_f_start_date 	DATE;
  l_start_f_end_date 	DATE;
  l_end_f_start_date 	DATE;
  l_end_f_end_date 	DATE;
  l_start_date 		DATE;
  l_end_date 		DATE;
  l_rate_start_date	DATE;
  l_final_amount1	NUMBER;
  l_final_amount1_ov	NUMBER;
  l_final_amount2	NUMBER;
  l_final_amount2_ov	NUMBER;
  l_base_amount		NUMBER;
  l_base_amount_ov		NUMBER;
  l_final_amount	NUMBER;
  l_final_amount_ov	NUMBER;
  l_inflated_amount	NUMBER;
  l_rate_class_id_inf	NUMBER(15);
  l_rate_type_id_inf	NUMBER(15);
  l_inflation_rate	NUMBER(5,2);
  l_inflation_rate_ov	NUMBER(5,2);
  l_start_fiscal_year 	NUMBER(4);
  l_end_fiscal_year 	NUMBER(4);
  l_new_fiscal_year 	NUMBER(4);
  l_fiscal_diff		NUMBER(4);
  l_return_status 	VARCHAR2(1);
  l_msg_data 		VARCHAR2(200);

  cursor c_inf_rates is
    select rate,start_date, fiscal_year
    from   igw_institute_rates 	ir
    where  ir.rate_class_id = l_rate_class_id_inf
    and    ir.rate_type_id = l_rate_type_id_inf
    and    ir.activity_type_code = p_activity_type_code
    and    ir.location_code = p_location_code
    and    (ir.start_date > p_line_start_date and ir.start_date <= p_line_end_date);

  BEGIN
    fnd_msg_pub.initialize;
    if p_appointment_type = '12' then
      l_base_amount := p_base_amount;
    elsif p_appointment_type = '11' then
      l_base_amount := p_base_amount * 12/11;
    elsif p_appointment_type = '10' then
      l_base_amount := p_base_amount * 12/10;
    elsif p_appointment_type = '9' then
      l_base_amount := p_base_amount * 12/9;
    elsif p_appointment_type = '8' then
      l_base_amount := p_base_amount * 12/8;
    elsif p_appointment_type = '7' then
      l_base_amount := p_base_amount * 12/7;
    elsif p_appointment_type = '6' then
      l_base_amount := p_base_amount * 12/6;
    elsif p_appointment_type = '5' then
      l_base_amount := p_base_amount * 12/5;
    elsif p_appointment_type = '4' then
      l_base_amount := p_base_amount * 12/4;
    elsif p_appointment_type = '3' then
      l_base_amount := p_base_amount * 12/03;
    elsif p_appointment_type = '2' then
      l_base_amount := p_base_amount * 12/2;
    elsif p_appointment_type = '1' then
      l_base_amount := p_base_amount * 12/1;
    end if;
    --dbms_output.put_line('the base amount is'||l_base_amount);
    l_base_amount_ov := l_base_amount;
    get_date_details(p_effective_date
			,l_effect_fiscal_year
			,l_effect_f_start_date
			,l_effect_f_end_date
			,l_return_status
			,l_msg_data);
    if l_return_status <> 'S' then
      raise FND_API.G_EXC_ERROR;
    end if;
    get_date_details(p_line_start_date
			,l_start_fiscal_year
			,l_start_f_start_date
			,l_start_f_end_date  --USED LATER DOWN
			,l_return_status
			,l_msg_data);
    --dbms_output.put_line('the l_start_fiscal_year is  '||l_start_fiscal_year);
    --dbms_output.put_line('the l_start_f_end_date is  '||l_start_f_end_date);
    if l_return_status <> 'S' then
       raise FND_API.G_EXC_ERROR;
    end if;
    get_date_details(p_line_end_date
			,l_end_fiscal_year
			,l_end_f_start_date
			,l_end_f_end_date
			,l_return_status
			,l_msg_data);
    --dbms_output.put_line('the l_end_fiscal_year is  '||l_end_fiscal_year);

    if l_return_status <> 'S' then
       raise FND_API.G_EXC_ERROR;
    end if;
    l_loop_counter := (l_start_fiscal_year - l_effect_fiscal_year) + 1;
    --dbms_output.put_line('the loop counter l_loop_counter is  '||l_loop_counter);
    l_new_fiscal_year := l_effect_fiscal_year;
    get_rate_id (p_expenditure_type
		 ,p_expenditure_category_flag
		 ,'I'
		 ,l_rate_class_id_inf
		 ,l_rate_type_id_inf
		 ,l_return_status
		 ,l_msg_data);
    --dbms_output.put_line('the l_rate_class_id_inf is  '||l_rate_class_id_inf);
    --dbms_output.put_line('the l_rate_type_id_inf is  '||l_rate_type_id_inf);

      if l_return_status <> 'S' then
        raise FND_API.G_EXC_ERROR;
      end if;

    /*the following code inflates the salary(if any) till the period line
      start date including the first day of the period start date. */

    for i in 1 .. l_loop_counter
    LOOP  --infation calculation loop
    --dbms_output.put_line('the l_new_fiscal_year is  '||l_new_fiscal_year);

        get_rate(p_proposal_id
		 ,p_version_id
		 ,l_new_fiscal_year
	         ,p_activity_type_code
	         ,p_location_code
	         ,l_rate_class_id_inf
	         ,l_rate_type_id_inf
	         ,l_inflation_rate
	         ,l_inflation_rate_ov
		 ,l_rate_start_date
	         ,l_return_status
	         ,l_msg_data);
        --dbms_output.put_line('the l_rate_start_date for inflation is   '||l_rate_start_date);
        --dbms_output.put_line('the l_inflation_rate is '|| l_inflation_rate);
        --dbms_output.put_line('the l_inflation_rate_ov is '|| l_inflation_rate_ov);
        if l_return_status NOT IN ('S','I') then
          raise FND_API.G_EXC_ERROR;
        end if;
      if l_inflation_rate is not null then
        if i = 1 and l_rate_start_date <= p_effective_date then
          l_base_amount := l_base_amount;
          l_base_amount_ov := l_base_amount_ov;
        elsif i = l_loop_counter and l_rate_start_date > p_line_start_date then
          l_base_amount := l_base_amount;
          l_base_amount_ov := l_base_amount_ov;
        else
          l_base_amount_ov := l_base_amount_ov * (1 + l_inflation_rate_ov/100);
          l_base_amount := l_base_amount * (1 + l_inflation_rate/100);
        end if;
      else
        l_base_amount := l_base_amount;
        l_base_amount_ov := l_base_amount_ov;
      end if;
      --dbms_output.put_line('the l_base_amount is '||l_base_amount);
      --dbms_output.put_line('the l_base_amount_ov is '||l_base_amount_ov);
      l_new_fiscal_year := l_new_fiscal_year + 1;
    END LOOP;  --inflation calculation loop

    --INITIALIZING VARIABLES FOR REUSAGE
    l_fiscal_diff:= (l_end_fiscal_year - l_start_fiscal_year) + 1;
    --dbms_output.put_line('the l_fiscal_diff is  '||l_fiscal_diff);
    l_new_fiscal_year := l_start_fiscal_year;
    l_start_date := p_line_start_date;
    l_rate_start_date:= null;
    l_inflation_rate_ov := null;

    /* the following section is if a particular expenditure type is not assigned to
       inflation rate class */
    if l_rate_class_id_inf is null and l_rate_type_id_inf is null then
      l_end_date := p_line_end_date;
      --dbms_output.put_line('1st stage');
      calc_sal_between_months(l_end_date
				,l_start_date
				,l_base_amount
 				,l_final_amount
				,l_return_status
				,l_msg_data);

          if l_return_status <> 'S' then
            raise FND_API.G_EXC_ERROR;
          end if;

      calc_sal_between_months(l_end_date
				,l_start_date
				,l_base_amount_ov
 				,l_final_amount_ov
				,l_return_status
				,l_msg_data);

          if l_return_status <> 'S' then
            raise FND_API.G_EXC_ERROR;
          end if;

      x_inflated_salary := l_final_amount;
      x_inflated_salary_ov := l_final_amount_ov;
    else

    /* following is the code till go through the loop
       for all the inflation rates found in the cursor */

      for rec_inf_rates in c_inf_rates
      LOOP
        l_end_date := rec_inf_rates.start_date-1;
        --dbms_output.put_line('l_start_date in the loop'||l_start_date);
        --dbms_output.put_line('l_end_date in the loop'||l_end_date);
        --dbms_output.put_line('l_base_amount 1st'||l_base_amount);

          calc_sal_between_months(l_end_date
				,l_start_date
				,l_base_amount
 				,l_final_amount1
				,l_return_status
				,l_msg_data);

          if l_return_status <> 'S' then
            raise FND_API.G_EXC_ERROR;
          end if;

          calc_sal_between_months(l_end_date
				,l_start_date
				,l_base_amount_ov
 				,l_final_amount1_ov
				,l_return_status
				,l_msg_data);
          if l_return_status <> 'S' then
            raise FND_API.G_EXC_ERROR;
          end if;

        l_start_date := rec_inf_rates.start_date;


        l_final_amount := nvl(l_final_amount,0)+ nvl(l_final_amount1,0);


        l_final_amount_ov := nvl(l_final_amount_ov,0) + nvl(l_final_amount1_ov,0);

        l_new_fiscal_year := l_new_fiscal_year + 1;

        x_inflated_salary := l_final_amount;
        x_inflated_salary_ov := l_final_amount_ov;

        --initializing local variables to zero
        l_final_amount1 := null;

        begin
          select   applicable_rate
          into 	   l_inflation_rate_ov
          from 	   igw_prop_rates
          where    rate_class_id = l_rate_class_id_inf
          and      rate_type_id = l_rate_type_id_inf
          and      activity_type_code = p_activity_type_code
          and      location_code = p_location_code
          and      fiscal_year = rec_inf_rates.fiscal_year
  	  and 	   proposal_id = p_proposal_id
	  and	   version_id = p_version_id;
        exception
          when no_data_found then
            l_inflation_rate_ov := rec_inf_rates.rate;
        end;

        l_base_amount := l_base_amount * (1 +rec_inf_rates.rate/100);
        l_base_amount_ov := l_base_amount_ov * (1 +l_inflation_rate_ov/100);

      END LOOP;
      --dbms_output.put_line('l_final_amount is outside the loop'||l_final_amount);

      l_start_date := nvl(l_end_date+1,p_line_start_date);
      l_end_date := p_line_end_date;
      --dbms_output.put_line('l_start_date outside'||l_start_date);
      --dbms_output.put_line('l_end_date outside'||l_end_date);
      --dbms_output.put_line('l_base_amount 1st'||l_base_amount);

      /* following amount is calculated for the last part for the dates
      between last inflation record found and the p_line_end_date */


          calc_sal_between_months(l_end_date
				,l_start_date
				,l_base_amount
 				,l_final_amount2
				,l_return_status
				,l_msg_data);

          if l_return_status <> 'S' then
            raise FND_API.G_EXC_ERROR;
          end if;
          --dbms_output.put_line('l_final_amount2 is '||l_final_amount2);

          calc_sal_between_months(l_end_date
				,l_start_date
				,l_base_amount_ov
 				,l_final_amount2_ov
				,l_return_status
				,l_msg_data);
          if l_return_status <> 'S' then
            raise FND_API.G_EXC_ERROR;
          end if;

        l_final_amount := nvl(l_final_amount,0)+ nvl(l_final_amount2,0);


        l_final_amount_ov := nvl(l_final_amount_ov,0) + nvl(l_final_amount2_ov,0);

        x_inflated_salary := l_final_amount;
        x_inflated_salary_ov := l_final_amount_ov;
    end if;
    x_return_status := 'S';
  EXCEPTION
    when FND_API.G_EXC_ERROR then
      x_return_status := l_return_status;
      x_msg_data := l_msg_data;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
    when others then
      x_return_status := 'U';
      x_msg_data :=  SQLCODE||' '||SQLERRM;
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'CALC_INFLATION');
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
  END calc_salary;


END IGW_OVERHEAD_CAL;

/
