--------------------------------------------------------
--  DDL for Package Body IGW_REPORT_PROCESSING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_REPORT_PROCESSING" as
-- $Header: igwburpb.pls 115.41 2002/11/15 00:47:57 ashkumar ship $
--------------------------------------------------------------------------------------------------
  Function get_proposal_id RETURN NUMBER is
  Begin
    RETURN IGW_REPORT_PROCESSING.G_PROPOSAL_ID;
  End;
--------------------------------------------------------------------------------------------------
  Function get_period_id RETURN NUMBER is
  Begin
    RETURN IGW_REPORT_PROCESSING.G_START_PERIOD;
  End;
--------------------------------------------------------------------------------------------------
  Function get_version_id RETURN NUMBER is
  Begin
    RETURN IGW_REPORT_PROCESSING.G_VERSION_ID;
  End;
--------------------------------------------------------------------------------------------------
  --used in setup budget category hierarchy form
  Function get_category(p_category_code VARCHAR2, p_proposal_form_number VARCHAR2)
                                RETURN VARCHAR2 is
  x_category VARCHAR2(80);
  Begin
    select distinct proposal_budget_category
    into   x_category
    from   igw_report_budget_seed
    where  proposal_form_number = p_proposal_form_number
    and	   proposal_budget_category_code = p_category_code;

    RETURN x_category;
  End;

--------------------------------------------------------------------------------------------------
  Function get_period_total(p_budget_category_code VARCHAR2
					, p_period_id NUMBER) RETURN NUMBER is
    l_version_id   number(4);
    l_period_total number(15,2);
  Begin
    --G_PROPOSAL_ID
    --G_PROPOSAL_FORM_NUMBER :=
    l_version_id := get_final_version(G_proposal_id);


    select period_total_direct_cost
    into   l_period_total
    from   igw_report_budget
    where  proposal_budget_category_code = p_budget_category_code
    and	   proposal_form_number = G_PROPOSAL_FORM_NUMBER
    and    proposal_id = G_PROPOSAL_ID
    and	   version_id = l_version_id
    and	   budget_period_id = p_period_id;

    RETURN l_period_total;
  Exception
    when no_data_found then
      RETURN null;
  End get_period_total;

--------------------------------------------------------------------------------------------------
  FUNCTION get_final_version(p_proposal_id   NUMBER) RETURN NUMBER is
    l_version_id	NUMBER(15);
  Begin
    select 	version_id
    into	l_version_id
    from	igw_budgets
    where	proposal_id = p_proposal_id
    and	final_version_flag = 'Y';

    RETURN l_version_id;
  Exception
    when no_data_found then
      fnd_message.set_name('IGW', 'IGW_NO_FINAL_BUDGET_VERSION');
      fnd_msg_pub.add;
      RETURN NULL;
      raise FND_API.G_EXC_ERROR;
    when others then
      RETURN NULL;
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'GET_FINAL_VERSION');
  End get_final_version;

--------------------------------------------------------------------------------------------------
  Function get_award_role(p_role_code VARCHAR2) RETURN VARCHAR2 is
    l_award_role	VARCHAR2(80);
  Begin
    select meaning
    into   l_award_role
    from   fnd_lookups
    where  lookup_type = 'AWARD_ROLE'
    and	   lookup_code = p_role_code;

    RETURN l_award_role;
  End;
--------------------------------------------------------------------------------------------------
  Function get_proposal_role(p_role_code VARCHAR2) RETURN VARCHAR2 is
    l_role	VARCHAR2(80);
  Begin
      select meaning
      into   l_role
      from   fnd_lookups
      where  lookup_type = 'IGW_PROPOSAL_ROLE_TYPES'
      and    lookup_code = p_role_code;
    RETURN l_role;
  End;
--------------------------------------------------------------------------------------------------

  PROCEDURE create_budget_justification (p_proposal_id			NUMBER
					,p_proposal_form_number		VARCHAR2
					,x_return_status    	OUT NOCOPY	VARCHAR2
					,x_msg_data         	OUT NOCOPY	VARCHAR2) is


    l_proposal_budg_category_code	VARCHAR2(30);
    l_budget_category_code		VARCHAR2(30);
    l_version_id			NUMBER(15);

    cursor c_budget_category is
    	select 	distinct proposal_budget_category
	,	budget_category_code
	,	details_required_flag
	from	igw_report_budget_seed
	where   proposal_form_number = p_proposal_form_number
        and	budget_category_code NOT IN ('84','SB');

    cursor c_itemized_budget is
	select 	expenditure_type
	,	budget_justification
	from	igw_budget_line_category_v	pbd
	where 	pbd.proposal_id = p_proposal_id
	and	pbd.version_id = l_version_id
	and	pbd.budget_category_code =l_budget_category_code;

-- a new procedure is created for this
/*
    cursor c_report_justification is
      select 	proposal_budget_category
      ,          justification
      from	igw_report_budg_justification
      where	proposal_id = p_proposal_id
      and	version_id =  l_version_id
      and	proposal_form_number = p_proposal_form_number;
*/

    l_item_budget_justification 	LONG;
    l_category_budget_just 		LONG;
    l_proposal_budget_just	 	LONG;

  BEGIN
    fnd_msg_pub.initialize;
    l_version_id := get_final_version(p_proposal_id);
    if l_version_id is null then
      raise FND_API.G_EXC_ERROR;
    end if;

    --deleting previously precessed data
    delete from igw_report_budg_justification
    where p_proposal_form_number = p_proposal_form_number
    and   proposal_id = p_proposal_id
    and   version_id = l_version_id;

/*
    --deleting inserted abstract into table igw_prop_abstracats
    delete from igw_prop_abstracts
    where  proposal_id = p_proposal_id
    and	   abstract_type_code = 'C.1'
    and	   abstract_type = 'IGW_ABSTRACT_TYPES';
*/


      l_proposal_budget_just := null;
      for rec_budget_category in c_budget_category
      LOOP
        l_budget_category_code := rec_budget_category.budget_category_code;
	l_category_budget_just := null;

        for rec_itemized_budget in c_itemized_budget
	LOOP
          if rec_itemized_budget.budget_justification is not null then
            if c_itemized_budget%ROWCOUNT = 1 then
  	      l_item_budget_justification := rec_itemized_budget.budget_justification||fnd_global.local_chr(10);
            else
              if l_item_budget_justification is not null then
  	        l_item_budget_justification := l_item_budget_justification||fnd_global.local_chr(10)||rec_itemized_budget.budget_justification||fnd_global.local_chr(10);
              else
                l_item_budget_justification := rec_itemized_budget.budget_justification;
              end if;
	    end if;
 	  end if;
	END LOOP; --rec_itemized_budget
        if l_item_budget_justification is not null then
          if c_budget_category%ROWCOUNT = 1 then
            l_category_budget_just := l_item_budget_justification;
	  else
            if l_category_budget_just is not null then
              l_category_budget_just := l_category_budget_just||fnd_global.local_chr(10)||l_item_budget_justification;
            else
              l_category_budget_just := l_item_budget_justification;
            end if;
  	  end if;
	end if;
      if l_category_budget_just /* l_proposal_budget_just */ is not null then
        --dbms_output.put_line('insrting'||l_category_budget_just);
        insert into igw_report_budg_justification(
						proposal_id
						,version_id
						,proposal_budget_category
						,justification
						,proposal_form_number)
					values(
						p_proposal_id
						,l_version_id
						,rec_budget_category.proposal_budget_category
						,l_category_budget_just
						,p_proposal_form_number);
    end if;

	l_item_budget_justification := null;
	l_category_budget_just := null;
      END LOOP; --rec_budget_category

-- a new procedure called dump_justification is created for the
-- following code
/*
    for rec_report_justification in c_report_justification
    LOOP
      l_proposal_budget_just := l_proposal_budget_just||rec_report_justification.proposal_budget_category||
                         fnd_global.local_chr(10)||rec_report_justification.justification;
    END LOOP; --rec_report_justification

    l_proposal_budget_just := nvl(substr(l_proposal_budget_just,1,4000),'NULL');
    insert into igw_prop_abstracts(
 				   proposal_id
				   ,abstract_type_code
				   ,abstract
				   ,abstract_type
                                   ,last_update_date
                                   ,last_updated_by
                                   ,creation_date
                                   ,created_by
                                   ,last_update_login )
                           values(
                                   p_proposal_id
                                   ,'C.1'
				   ,l_proposal_budget_just
				   ,'IGW_ABSTRACT_TYPES'
				   ,sysdate
				   ,fnd_global.user_id
				   ,sysdate
				   ,fnd_global.user_id
				   ,fnd_global.login_id);
*/
      x_return_status := 'S';
  EXCEPTION
    when FND_API.G_EXC_ERROR then
      x_return_status := 'E';
      --x_msg_data := l_msg_data;
      --x_msg_data := fnd_msg_pub.get(p_msg_index=>1, p_encoded=>'TRUE');
      --dbms_output.put_line('x_msg_data right after EXCEPTION is '||x_msg_data);
      --fnd_msg_pub.count_and_get(p_count => x_msg_count,
				--p_data => x_msg_data);
    when others then
      x_return_status := 'U';
      x_msg_data :=  SQLCODE||' '||SQLERRM;
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'CREATE_BUDGET_JUSTIFICATION');
  END create_budget_justification;
--------------------------------------------------------------------------------------------------
  PROCEDURE dump_justification (p_proposal_id			NUMBER
				,p_proposal_form_number		VARCHAR2
				,x_return_status    	OUT NOCOPY	VARCHAR2
				,x_msg_data         	OUT NOCOPY	VARCHAR2) is

    l_version_id			NUMBER(15);
    l_proposal_budget_just	 	LONG;

    cursor c_report_justification is
      select 	proposal_budget_category
      ,          justification
      from	igw_report_budg_justification
      where	proposal_id = p_proposal_id
      --and	version_id =  l_version_id
      and	proposal_form_number = p_proposal_form_number;


   BEGIN
    --deleting inserted abstract into table igw_prop_abstracats
    delete from igw_prop_abstracts
    where  proposal_id = p_proposal_id
    and	   abstract_type_code = 'C.1'
    and	   abstract_type = 'IGW_ABSTRACT_TYPES';

    for rec_report_justification in c_report_justification
    LOOP
      l_proposal_budget_just := l_proposal_budget_just||rec_report_justification.proposal_budget_category||
                         fnd_global.local_chr(10)||rec_report_justification.justification;
    END LOOP; --rec_report_justification

    l_proposal_budget_just := nvl(substr(l_proposal_budget_just,1,4000),'NULL');
    insert into igw_prop_abstracts(
 				   proposal_id
				   ,abstract_type_code
				   ,abstract
				   ,abstract_type
                                   ,last_update_date
                                   ,last_updated_by
                                   ,creation_date
                                   ,created_by
                                   ,last_update_login )
                           values(
                                   p_proposal_id
                                   ,'C.1'
				   ,l_proposal_budget_just
				   ,'IGW_ABSTRACT_TYPES'
				   ,sysdate
				   ,fnd_global.user_id
				   ,sysdate
				   ,fnd_global.user_id
				   ,fnd_global.login_id);

    x_return_status := 'S';

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      x_return_status := 'E';
      --dbms_output.put_line('x_msg_data right after EXCEPTION is '||x_msg_data);
      --fnd_msg_pub.count_and_get(p_count => x_msg_count,
				--p_data => x_msg_data);
    when others then
      x_return_status := 'U';
      x_msg_data :=  SQLCODE||' '||SQLERRM;
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'DUMP_JUSTIFICATION');
  END;


--------------------------------------------------------------------------------------------------

  PROCEDURE create_q_explanation	(p_proposal_form_number	VARCHAR2
					,x_return_status    	OUT NOCOPY	VARCHAR2
					,x_msg_data         	OUT NOCOPY	VARCHAR2) is
  cursor c_org_questions is
	select	organization_id
	,	question_number
	,	explanation
	from	igw_org_questions
	where	explanation is not null;
  BEGIN
    fnd_msg_pub.initialize;

    --deleting previously precessed data
    delete from igw_report_q_explanation
    where p_proposal_form_number = p_proposal_form_number;

    --inserting processed data for organization questions explanations;
    for rec_org_questions in c_org_questions
    LOOP
      insert into igw_report_q_explanation  (
						organization_id
						,question_number
						,explanation
						,proposal_form_number )
					values
					     (	rec_org_questions.organization_id
						,rec_org_questions.question_number
						,rec_org_questions.explanation
						,p_proposal_form_number );
    END LOOP; --rec_org_questions

  EXCEPTION
    when others then
      x_return_status := 'U';
      x_msg_data :=  SQLCODE||' '||SQLERRM;
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'IGW_REPORT_PROCESSING:CREATE_Q_EXPLANATION');
  END create_q_explanation;

--------------------------------------------------------------------------------------------------
  PROCEDURE create_base_rate	       (p_proposal_id			NUMBER
					,p_proposal_form_number		VARCHAR2
					,x_return_status    	OUT NOCOPY	VARCHAR2
					,x_msg_data         	OUT NOCOPY	VARCHAR2
					,x_msg_count	    	OUT NOCOPY 	NUMBER)  is

    l_version_id 	NUMBER;

    cursor c_no_of_periods is
	select 	budget_period_id
	,	start_date
	,	end_date
	from	igw_budget_periods
	where	proposal_id = p_proposal_id
	and	version_id = l_version_id;

    l_base_amount		NUMBER;
    l_total_indirect_cost       NUMBER;
    l_rate_applied		NUMBER;
    l_fiscal_start_date		DATE;
    l_fiscal_end_date		DATE;
    l_fiscal_year		NUMBER(4);
    l_return_status 		VARCHAR2(1);
    l_msg_data 			VARCHAR2(200);

  BEGIN
    fnd_msg_pub.initialize;
    l_version_id := get_final_version(p_proposal_id);

    --deleting previously precessed data
    delete from igw_report_budget_base_rate
    where p_proposal_form_number = p_proposal_form_number
    and   proposal_id = p_proposal_id
    and   version_id = l_version_id;

    --creating data for base amount, rate and indirect cost
    for rec_no_of_periods in c_no_of_periods
    LOOP
      	select 	sum(base_amt)
	into	l_base_amount
	from	igw_budget_category_v		pbcv
	,	igw_budget_details_cal_amts	pbdc
	,	igw_rate_classes		prc
	where	pbcv.line_item_id = pbdc.line_item_id
	and	pbdc.rate_class_id = prc.rate_class_id
	and	prc.rate_class_type = 'O'
	and	pbdc.apply_rate_flag = 'Y'
	and	pbcv.proposal_id = p_proposal_id
	and	pbcv.version_id = l_version_id
	and 	pbcv.budget_period_id = rec_no_of_periods.budget_period_id
	and	pbcv.oh_applied_flag = 'Y';

	select 	total_indirect_cost
	into	l_total_indirect_cost
	from	igw_budget_periods
	where	proposal_id = p_proposal_id
	and	version_id =  l_version_id
	and	budget_period_id = rec_no_of_periods.budget_period_id;

        l_rate_applied := l_total_indirect_cost/l_base_amount * 100;

        IGW_OVERHEAD_CAL.get_date_details(rec_no_of_periods.start_date
					,l_fiscal_year
					,l_fiscal_start_date
					,l_fiscal_end_date
					,l_return_status
					,l_msg_data);
	if l_return_status <> 'S' then
	  raise FND_API.G_EXC_ERROR;
        end if;
        if  l_fiscal_end_date < rec_no_of_periods.end_date  then
          l_fiscal_year := null;
        end if;

        insert into igw_report_budget_base_rate(proposal_id
						,version_id
						,budget_period_id
						,base_amount
						,rate_applied
						,total_indirect_cost
						,start_date
						,end_date
						,fiscal_year
						,proposal_form_number )
					values
					      ( p_proposal_id
						,l_version_id
						,rec_no_of_periods.budget_period_id
						,l_base_amount
						,l_rate_applied
						,l_total_indirect_cost
						,rec_no_of_periods.start_date
						,rec_no_of_periods.end_date
						,l_fiscal_year
						,p_proposal_form_number	);
    END LOOP; --rec_no_of_periods

    begin
      l_version_id := null;
      l_base_amount := null;
      l_total_indirect_cost := null;
      l_rate_applied := null;

      select version_id
      ,	     sum(nvl(total_indirect_cost,0))/sum(nvl(base_amount,0)) * 100
      ,      avg(base_amount)
      into   l_version_id
      ,      l_rate_applied
      ,      l_base_amount
      from   igw_report_budget_base_rate
      where  proposal_id = p_proposal_id
      and    proposal_form_number = p_proposal_form_number
      group by proposal_id, version_id;

      insert into igw_report_budget_base_rate(proposal_id
						,version_id
						,budget_period_id
						,base_amount
						,rate_applied
						,total_indirect_cost
						,start_date
						,end_date
						,fiscal_year
						,proposal_form_number )
					values
					      ( p_proposal_id
						,l_version_id
						,0
						,l_base_amount
						,l_rate_applied
						,null
						,null
						,null
						,null
						,p_proposal_form_number	);


    exception
      when no_data_found then null;
    end;

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
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'CREATE_BASE_RATE');
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
  END create_base_rate;


--------------------------------------------------------------------------------------------------

  /* Logic: First of all put all the lowest categories in igw_report_budget fetching
     their corresponding data from the database by the setting the recently updated flag to 'Y'.
     Then find their parent categories in the seed table and insert them into the above table
     ( if parent category alrady exists then update it instead of inserting). Repeat the
     process till the loop */

  PROCEDURE create_reporting_data(	p_proposal_id   		NUMBER
					,p_proposal_form_number		VARCHAR2
					,x_return_status    	OUT NOCOPY	VARCHAR2
					,x_msg_data         	OUT NOCOPY	VARCHAR2
					,x_msg_count	    	OUT NOCOPY 	NUMBER)  is

    l_budget_period_id			NUMBER(15);
    l_version_id			NUMBER(15);
    l_proposal_budget_category		VARCHAR2(80);
    l_budget_category_code		VARCHAR2(30);


    cursor c_lowest_category is
      	select  irs.budget_category_code
      	from 	igw_report_budget_seed irs
      	where   irs.proposal_form_number = p_proposal_form_number
	and	irs.budget_category_code not in
		(select distinct IR.proposal_budget_category_code
		from igw_report_budget_seed IR
		where  IR.proposal_form_number = p_proposal_form_number);

    cursor c_parent_category is
      	select  distinct proposal_budget_category_code
      	from   igw_report_budget_seed
      	where  proposal_form_number = p_proposal_form_number
      	and    budget_category_code IN (
				select proposal_budget_category_code
				from   igw_report_budget
				where  proposal_form_number =  p_proposal_form_number
				and    proposal_id = p_proposal_id
				and    recently_updated_flag = 'Y');


    cursor c_budget_period is
    	select 	budget_period_id
    	from	igw_budget_periods
    	where	proposal_id = p_proposal_id
        and	version_id = l_version_id;

    l_budget_category		VARCHAR2(80);
    l_period_direct_cost_amt	NUMBER(17,2);
    l_period_eb_amt		NUMBER(17,2);
    l_period_direct_cost_amt1	NUMBER(17,2);
    l_period_eb_amt1		NUMBER(17,2);
    l_post_award_exists    	VARCHAR2(3);
    l_proposal_role	   	VARCHAR2(80);
    l_parent_exists		VARCHAR2(1);
    l_found			NUMBER(1);
    l_expenditure_description 	LONG;
    l_return_status 		VARCHAR2(1);
    l_msg_data 			VARCHAR2(200);

  BEGIN
    fnd_msg_pub.initialize;
    l_version_id := get_final_version(p_proposal_id);
    if l_version_id is null then
      raise FND_API.G_EXC_ERROR;
    end if;

    G_START_PERIOD := 1;
    G_PROPOSAL_ID  := p_proposal_id;
    G_VERSION_ID := l_version_id;
    G_PROPOSAL_FORM_NUMBER := p_proposal_form_number;


    l_post_award_exists := igw_security.gms_enabled;

    --dbms_output.put_line('before role selection'||l_post_award_exists);

    --deleting previously precessed data
    delete from igw_report_budget
    where p_proposal_form_number = p_proposal_form_number
    and   proposal_id = p_proposal_id
    and   version_id = l_version_id;

    for rec_budget_period in c_budget_period
    LOOP
      l_budget_period_id := rec_budget_period.budget_period_id;

      for rec_lowest_category in c_lowest_category
      LOOP
        begin
     	  select  sum(base_amt)	period_amt
	  ,	  sum(eb_cost)	eb_amt
	  ,	  budget_period_id
	  into    l_period_direct_cost_amt
          ,	  l_period_eb_amt
	  ,	  l_budget_period_id
    	  from    igw_budget_category_v
	  where   budget_category_code = rec_lowest_category.budget_category_code
	  and	  proposal_id = p_proposal_id
          and     version_id = l_version_id
	  and	  budget_period_id = rec_budget_period.budget_period_id
	  group by proposal_id, version_id, budget_period_id;
        exception
          when no_data_found then null;
          --GOTO LABLE1;
        end;
        --dbms_output.put_line('stage1'||'code'||rec_lowest_category.budget_category_code);
        begin
          l_budget_category := null;
          select proposal_budget_category
          into	 l_budget_category
          from   igw_report_budget_seed
          where  proposal_form_number = p_proposal_form_number
          and	 budget_category_code = rec_lowest_category.budget_category_code;
        exception
          when no_data_found then
          begin
            select meaning
            into   l_budget_category
            from   igw_lookups_v
            where  lookup_type = 'IGW_BUDGET_CATEGORY'
            and	   lookup_code = rec_lowest_category.budget_category_code;
          exception
            when no_data_found then null;
          end;
	end;

        insert into igw_report_budget(
					proposal_id
					,version_id
					,budget_period_id
					,proposal_budget_category
					,proposal_budget_category_code
					,period_total_direct_cost
					,eb_total
					,proposal_form_number
					--,order_sequence
					,recently_updated_flag
							)
				values
	                	      ( p_proposal_id
					,l_version_id
					,l_budget_period_id
                                    	,l_budget_category
					,rec_lowest_category.budget_category_code
					,l_period_direct_cost_amt
					,l_period_eb_amt
					,p_proposal_form_number
					--,igw_report_budget_seed_s.nextval
					,'Y');

        <<LABLE1>>
	l_period_direct_cost_amt := null;
	l_period_eb_amt := null;

      END LOOP;  --rec_lowest_category


      <<LABLE2>>
      null;

      l_parent_exists := null;
      for rec_parent_category in c_parent_category
      LOOP
        l_parent_exists := null;
        begin
          select   '1'
          into     l_parent_exists
          from     igw_report_budget_seed
          where    budget_category_code = rec_parent_category.proposal_budget_category_code
          and	   rownum < 2;
        exception
          when no_data_found then null;
          l_parent_exists := null;
        end;

        begin
     	  select  sum(nvl(base_amt,0))	period_amt
	  ,	  sum(nvl(eb_cost,0))	eb_amt
	  ,	  budget_period_id
	  into    l_period_direct_cost_amt
          ,	  l_period_eb_amt
	  ,	  l_budget_period_id
    	  from    igw_budget_category_v
	  where   budget_category_code = rec_parent_category.proposal_budget_category_code
	  and	  proposal_id = p_proposal_id
          and     version_id = l_version_id
	  and	  budget_period_id = rec_budget_period.budget_period_id
	  group by proposal_id, version_id, budget_period_id;
        exception
          when no_data_found then null;
        end;


        select   sum(nvl(period_total_direct_cost,0))
	,	 sum(nvl(eb_total,0))
  	into     l_period_direct_cost_amt1
	,	 l_period_eb_amt1
        from     igw_report_budget
	where    proposal_id = p_proposal_id
  	and	 version_id = l_version_id
	and	 budget_period_id = rec_budget_period.budget_period_id
	and	 proposal_form_number = p_proposal_form_number
        and	 proposal_budget_category_code IN (
		select 	budget_category_code
		from 	igw_report_budget_seed
		where 	proposal_form_number = p_proposal_form_number
		and	proposal_budget_category_code = rec_parent_category.proposal_budget_category_code)
        group by proposal_id, version_id, budget_period_id;

          l_period_direct_cost_amt := nvl(l_period_direct_cost_amt,0) + nvl(l_period_direct_cost_amt1,0);
          l_period_eb_amt :=    nvl(l_period_eb_amt,0) + nvl(l_period_eb_amt1,0);

          if l_period_direct_cost_amt= 0 then
            l_period_direct_cost_amt := null;
          end if;

          if l_period_eb_amt= 0 then
            l_period_eb_amt := null;
          end if;


          begin
            l_budget_category := null;
            select proposal_budget_category
            into   l_budget_category
            from   igw_report_budget_seed
            where  proposal_form_number = p_proposal_form_number
            and	   budget_category_code = rec_parent_category.proposal_budget_category_code;
          exception
            when no_data_found then
            begin
              select meaning
              into   l_budget_category
              from   igw_lookups_v
              where  lookup_type = 'IGW_BUDGET_CATEGORY'
              and    lookup_code = rec_parent_category.proposal_budget_category_code;
            exception
              when no_data_found then null;
            end;
	  end;

          begin
            l_found := null;
            update igw_report_budget
            set    period_total_direct_cost = l_period_direct_cost_amt
	    ,      eb_total = l_period_eb_amt
            where  proposal_form_number = p_proposal_form_number
            and    proposal_id = p_proposal_id
	    and    version_id = l_version_id
  	    and	 budget_period_id = l_budget_period_id
	    and	 proposal_budget_category = l_budget_category
            and    proposal_budget_category_code = rec_parent_category.proposal_budget_category_code;

            if SQL%FOUND then
              l_found := 1;
            end if;
           end;

          if l_found is null then
            insert into igw_report_budget(
					proposal_id
					,version_id
					,budget_period_id
					,proposal_budget_category
					,proposal_budget_category_code
					,period_total_direct_cost
					,eb_total
					,proposal_form_number
					,recently_updated_flag
							)
				values
	                	      ( p_proposal_id
					,l_version_id
					,l_budget_period_id
                                    	,l_budget_category
					,rec_parent_category.proposal_budget_category_code
					,l_period_direct_cost_amt
					,l_period_eb_amt
					,p_proposal_form_number
					,'Y');
        end if;

        update igw_report_budget
        set    recently_updated_flag = 'N'
        where  proposal_form_number = p_proposal_form_number
        and    proposal_id = p_proposal_id
        and    proposal_budget_category_code IN (
	       select 	budget_category_code
	       from 	igw_report_budget_seed
	       where 	proposal_form_number = p_proposal_form_number
	       and	proposal_budget_category_code =                                   rec_parent_category.proposal_budget_category_code);

        if l_found = 1 then
          update igw_report_budget
          set    recently_updated_flag = 'Y'
          where  proposal_form_number = p_proposal_form_number
          and    proposal_id = p_proposal_id
          and    proposal_budget_category_code = rec_parent_category.proposal_budget_category_code;
        end if;



	l_period_direct_cost_amt := null;
        l_period_eb_amt := null;
      END LOOP;  --rec_parent_category

      if l_parent_exists = 1 THEN
        GOTO LABLE2;
      end if;
    END LOOP;  --rec_budget_period

/* marked as it iterferes with 194TS or any other tree hierarchy. coded for PHS 398 */
/*
  -- summing up expenditures into 'other' category for categories not included in seed data
    begin
      for rec_budget_period in c_budget_period
      LOOP
 	l_period_direct_cost_amt := null;
        l_period_eb_amt 	 := null;
	l_budget_period_id	 := null;
        begin
          select  sum(base_amt)	period_amt
	  ,	  sum(eb_cost)	eb_amt
	  ,	  budget_period_id
	  into	  l_period_direct_cost_amt
          ,	  l_period_eb_amt
	  ,	  l_budget_period_id
    	  from	  igw_budget_category_v
	  where	budget_category_code NOT IN
               (
		select budget_category_code
		from	igw_report_budget_seed
		where	proposal_form_number = p_proposal_form_number)
	  and	  proposal_id = p_proposal_id
          and 	  version_id = l_version_id
	  and	  budget_period_id = rec_budget_period.budget_period_id
	  group by proposal_id, version_id, budget_period_id;
        exception
          when no_data_found then null;
           -- GOTO LABLE2;

        end;


	update 	igw_report_budget
	set	period_total_direct_cost = l_period_direct_cost_amt
	,	eb_total = l_period_eb_amt
	where	proposal_form_number = p_proposal_form_number
	and	proposal_id = p_proposal_id
	and	version_id = l_version_id
	and	budget_period_id = rec_budget_period.budget_period_id
	and	proposal_budget_category_code = '39';
      END LOOP;
    end;
*/

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
      --dbms_output.put_line(x_msg_data);
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'CREATE_REPORTING_DATA');
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);

  END create_reporting_data;
--------------------------------------------------------------------------------------------------
  PROCEDURE create_itemized_budget(	p_proposal_id   		NUMBER
					,p_proposal_form_number		VARCHAR2
					,x_return_status    	OUT NOCOPY	VARCHAR2
					,x_msg_data         	OUT NOCOPY	VARCHAR2
					,x_msg_count	    	OUT NOCOPY 	NUMBER)  is

    l_budget_period_id			NUMBER(15);
    l_version_id			NUMBER(15);
    l_proposal_budget_category		VARCHAR2(80);
    l_proposal_budg_category_code	VARCHAR2(30);
    l_budget_category_code		VARCHAR2(30);

    cursor c_budget_category is
    	select 	proposal_budget_category
	,	budget_category_code
	,	details_required_flag
	from	igw_report_budget_seed
	where   proposal_form_number = p_proposal_form_number
        and     details_required_flag = 'Y';

    cursor c_itemized_budget is
	select 	line_item_description
	,	line_item_cost
	from	igw_budget_line_category_v	pbd
	where 	pbd.proposal_id = p_proposal_id
	and	pbd.version_id = l_version_id
	and	pbd.budget_period_id = 1
	and	pbd.budget_category_code =l_budget_category_code;

    l_budget_category		VARCHAR2(80);
    l_post_award_exists    	VARCHAR2(3);
    l_proposal_role	   	VARCHAR2(80);
    l_expenditure_description 	LONG;
    l_return_status 		VARCHAR2(1);
    l_msg_data 			VARCHAR2(200);

  BEGIN
    fnd_msg_pub.initialize;
    l_version_id := get_final_version(p_proposal_id);
    if l_version_id is null then
      raise FND_API.G_EXC_ERROR;
    end if;

    G_START_PERIOD := 1;
    G_PROPOSAL_ID  := p_proposal_id;
    G_VERSION_ID := l_version_id;


    delete from igw_report_itemized_budget
    where p_proposal_form_number = p_proposal_form_number
    and   proposal_id = p_proposal_id
    and   version_id = l_version_id
    and	  proposal_form_number = p_proposal_form_number;

    for rec_budget_category in c_budget_category
      LOOP
        --if rec_budget_category.details_required_flag = 'Y' then
	  l_budget_category_code := rec_budget_category.budget_category_code;
	  for rec_itemized_budget in c_itemized_budget
	  LOOP
           if rec_itemized_budget.line_item_description is not null then
            if c_itemized_budget%ROWCOUNT = 1 then
  	      l_expenditure_description :=rec_itemized_budget.line_item_description;
            else
	      l_expenditure_description := l_expenditure_description||';'||rec_itemized_budget.line_item_description;
            end if;
 	   end if;
          END LOOP; --rec_itemized_budget

          if l_expenditure_description is not null then
            insert into igw_report_itemized_budget (	proposal_id
							,version_id
							,budget_period_id
							,proposal_budget_category
							,expenditure_description
							,proposal_form_number)
						values
						     (	p_proposal_id
							,l_version_id
							,1
							,rec_budget_category.proposal_budget_category
							,l_expenditure_description
							,p_proposal_form_number);
           l_expenditure_description := null;
         end if;

       --end if;
     END LOOP; --rec_budget_category_code

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      x_return_status := l_return_status;
      x_msg_data := l_msg_data;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);

    when others then
      x_return_status := 'U';

      x_msg_data :=  SQLCODE||' '||SQLERRM;
      --dbms_output.put_line('the x_msg_dat is'||x_msg_data);
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'CREATE_ITEMIZED_BUDGET');
      --fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);

  END create_itemized_budget;

--------------------------------------------------------------------------------------------------

FUNCTION get_abstract(p_proposal_id        in INTEGER,
                      p_abstract_type_code in INTEGER) RETURN VARCHAR2 is

    v_abstract varchar2(4000):=null;

    cursor c  is
    select abstract
    from igw_prop_abstracts
    where proposal_id = p_proposal_id
    and   abstract_type_code =  p_abstract_type_code;

begin
    open c;
    fetch c into v_abstract;
    close c;
    return(v_abstract);

  exception
    when others then
    if c%isopen then
      close c;
    end if;
    return(v_abstract);
END get_abstract;

PROCEDURE get_answer(p_proposal_id in INTEGER,
                     P_question_no in VARCHAR2,
                     p_person_id   in INTEGER,
                     p_party_id    in  INTEGER,
                     p_organization_id in INTEGER,
                     p_response1     out NOCOPY VARCHAR2,
                     p_response2     out NOCOPY VARCHAR2) is
begin
  if p_person_id is null and p_organization_id is null  then
    select answer,
           explanation
    into  p_response1,
          p_response2
    from igw_prop_questions
    where proposal_id = p_proposal_id and
          question_number = p_question_no;
  elsif p_organization_id is not null then
   select answer,
          explanation
   into   p_response1,
          p_response2
   from   igw_org_questions
   where  organization_id = p_organization_id
   and    question_number = p_question_no;
  else
   select answer,
          explanation
   into p_response1,
        p_response2
   from igw_prop_person_questions
   where proposal_id = p_proposal_id and
         question_number = p_question_no and
         party_id = p_party_id;
  end if;
  exception
  when others then
    p_response1 := null;
    p_response2:= null;
end get_answer;


function get_response(p_proposal_id in INTEGER,
                     P_question_no in VARCHAR2,
                     p_person_id   in INTEGER default null,
                     p_party_id    in  INTEGER,
                     p_organization_id in INTEGER default null) return varchar2 is
v_response varchar2(2);
begin
  if p_person_id is null and p_organization_id is null  then
    select answer
    into  v_response
    from igw_prop_questions
    where proposal_id = p_proposal_id and
          question_number = p_question_no;
  elsif p_organization_id is not null then
   select answer
   into   v_response
   from   igw_org_questions
   where  organization_id = p_organization_id
   and    question_number = p_question_no;
  else
   select answer
   into v_response
   from igw_prop_person_questions
   where proposal_id = p_proposal_id and
         question_number = p_question_no and
         party_id = p_party_id;
  end if;
  return(v_response);
  exception
  when others then
   return(null);
end get_response;

function get_explanation(p_proposal_id in INTEGER,
                     P_question_no in VARCHAR2,
                     p_person_id   in INTEGER default null,
                     p_party_id    IN INTEGER,
                     p_organization_id in INTEGER default null) return varchar2 is
v_explanation varchar2(2005);
begin
  if p_person_id is null and p_organization_id is null  then
    select explanation
    into  v_explanation
    from igw_prop_questions
    where proposal_id = p_proposal_id and
          question_number = p_question_no;
  elsif p_organization_id is not null then
   select explanation
   into   v_explanation
   from   igw_org_questions
   where  organization_id = p_organization_id
   and    question_number = p_question_no;
  else
   select explanation
   into v_explanation
   from igw_prop_person_questions
   where proposal_id = p_proposal_id and
         question_number = p_question_no and
         party_id = p_person_id;
  end if;
  return(v_explanation);
  exception
  when others then
    return(null);
end get_explanation;

FUNCTION get_subjects(p_proposal_id in integer,
                      p_study_title_id integer,
                      p_subject_race in varchar2,
                      p_subject_gender in varchar2) RETURN INTEGER is
v_subjects integer;
begin
select no_of_subjects
into v_subjects
from igw_study_titles ST,
     igw_subject_information SI
where ST.proposal_id = p_proposal_id and
      ST.study_title_id = SI.study_title_id and
      SI.subject_race_code = p_subject_race and
      SI.subject_type_code = p_subject_gender and
      SI.study_title_id    = p_study_title_id;
return(v_subjects);
exception
when others then
return(null);
end get_subjects;

-- not changing person_id to party_id since the data job name is got from hr tables and
-- is presently not captured by external persons screen.
FUNCTION get_job_name(person_id_v in number) RETURN VARCHAR2 is
  segment varchar2(100);
  cursor job_cursor(segment_p varchar2) is
  select  decode(segment_p,'SEGMENT1',pjd.segment1,
                         'SEGMENT2',pjd.segment2,
                         'SEGMENT3',pjd.segment3,
                         'SEGMENT4',pjd.segment4,
                         'SEGMENT5',pjd.segment5,
                         'SEGMENT6',pjd.segment6,
                         'SEGMENT7',pjd.segment7,
                         'SEGMENT8',pjd.segment8,
                         'SEGMENT9',pjd.segment9,
                         'SEGMENT10',pjd.segment10,
                         'SEGMENT11',pjd.segment11,
                         'SEGMENT12',pjd.segment12,
                         'SEGMENT13',pjd.segment13,
                         'SEGMENT14',pjd.segment14,
                         'SEGMENT15',pjd.segment15,
                         'SEGMENT16',pjd.segment16,
                         'SEGMENT17',pjd.segment17,
                         'SEGMENT18',pjd.segment18,
                         'SEGMENT19',pjd.segment19,
                         'SEGMENT20',pjd.segment20,
                         'SEGMENT21',pjd.segment21,
                         'SEGMENT22',pjd.segment22,
                         'SEGMENT23',pjd.segment23,
                         'SEGMENT24',pjd.segment24,
                         'SEGMENT25',pjd.segment25,
                         'SEGMENT26',pjd.segment26,
                         'SEGMENT27',pjd.segment27,
                         'SEGMENT28',pjd.segment28,
                         'SEGMENT29',pjd.segment29,
                         'SEGMENT30',pjd.segment30)
   FROM   per_position_definitions pjd,
          per_all_positions        pap,
          per_assignments_x        paf,
          per_people_x             ppx
   WHERE  ppx.person_id              = paf.person_id
   and    ppx.business_group_id      = paf.business_group_id
   and    paf.primary_flag           = 'Y'
   and    paf.position_id            = pap.position_id
   and    pap.position_definition_id = pjd.position_definition_id
   and    ppx.person_id              = person_id_v;

  begin

   segment := fnd_profile.value('IGW_JOB_NAME_SEGMENT');

   if segment is null then
     return null;
   end if;
   open job_cursor(segment);
   fetch job_cursor into segment;
   if  not job_cursor%found then
      return null;
   else
     close job_cursor;
     return segment;
   end if;
exception
   when others then
    return null;
end get_job_name;


-- not changing person_id to party_id since the data phone number is got from hr tables and
-- is presently not captured by external persons screen. Also this info is required only for PI.
FUNCTION get_phone_number(v_person_id  in NUMBER,
                          v_phone_type in VARCHAR2) RETURN VARCHAR2 is
  v_phone_number varchar2(60);
  cursor c1 is select phone_number
  from per_phones
  where parent_id = v_person_id and
     parent_table = 'PER_ALL_PEOPLE_F' and
     phone_type = v_phone_type and
     date_to is null;
begin
  open c1;
  fetch c1 into v_phone_number;
  close c1;
  return v_phone_number;
exception
  when others then
  if c1%isopen then
    close c1;
  end if;
   return null;
END get_phone_number;



FUNCTION get_person_Degrees(person_id_p in NUMBER,
			    party_id_p  in  NUMBER,
                            proposal_id_p in number)
     return varchar2 is
  degrees varchar2(100);
  degree varchar2(80);
  counter integer := 1;
  cursor c1 is
  SELECT PER_D.DEGREE
  FROM IGW_PROP_PERSON_DEGREES PROP_D,
       IGW_PERSON_DEGREES PER_D
  WHERE PER_D.PERSON_DEGREE_ID = PROP_D.PERSON_DEGREE_ID AND
      PROP_D.SHOW_FLAG = 'Y' AND
      PER_D.PARTY_ID = party_id_p and
      PROP_D.proposal_id = proposal_id_p
  ORDER BY PROP_D.DEGREE_SEQUENCE;
BEGIN
  degrees := null;
  open c1;
  LOOP
    fetch c1 into degree;
    if c1%found then
      if degrees is null then
        degrees := degree;
      else
        degrees := degrees||','||degree;
      end if;
    else
     exit;
    end if;
    if counter = 3 then
     exit;
    end if;
    counter := counter + 1;
  end LOOP;
  close c1;
  return  degrees;
exception
  when others then
   if c1%isopen then
     close c1;
   end if;
   return null;
end get_person_degrees;



-- not changing org_id to party_id since the data org type is required only for applicant org which
-- is present in HR
FUNCTION get_org_type (p_org_id in integer,
                       p_org_type1 in Varchar2,
                       p_org_type2 in Varchar2 default null,
                       p_org_type3 in Varchar2 default null) return Varchar2 is
row_count integer;
begin
select count(*)
into row_count
from igw_org_types
where organization_id = p_org_id
and   organization_type_code in (p_org_type1, p_org_type2, p_org_type3);
if row_count > 0 then
  return('X');
end if;
return(NULL);
EXCEPTION
when others then
return(NULL);
END;
-------------------------------------------------------------------------------

 FUNCTION  get_org_party_name(p_party_id in number, p_org_id in number) RETURN VARCHAR2 is
   l_org_party_name  hz_parties.party_name%TYPE;
 begin
   if p_party_id is not null then
     select party_name
     into   l_org_party_name
     from   hz_parties
     where  party_id = p_party_id
     and    party_type = 'ORGANIZATION';
   elsif p_org_id is not null then
     select name
     into   l_org_party_name
     from   hr_organization_units
     where  organization_id = p_org_id;
   end if;
   return (l_org_party_name);
 exception
   when no_data_found then null;
   return (null);
 end;


END IGW_REPORT_PROCESSING;

/
