--------------------------------------------------------
--  DDL for Package Body IGW_BUDGET_OPERATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_BUDGET_OPERATIONS" as
--$Header: igwbuopb.pls 115.37 2003/08/08 23:31:37 ashkumar ship $

  FUNCTION check_exp_assignment  (p_expenditure_type	VARCHAR2
				  ,p_expenditure_category_flag  	VARCHAR2
				  ,p_rate_class_id	NUMBER
				  ,p_rate_type_id	NUMBER)  RETURN BOOLEAN is
    l_dummy 	VARCHAR2(10);
    l_expenditure_category   VARCHAR2(30);
  BEGIN
    if p_expenditure_category_flag = 'Y' then
      l_expenditure_category := p_expenditure_type;
    elsif  p_expenditure_category_flag = 'N' then
      select 	expenditure_category
      into	l_expenditure_category
      from	igw_expenditure_types_v
      where	expenditure_type = p_expenditure_type;
    end if;

    select 	'1'
    into	l_dummy
    from 	igw_exp_type_rate_types
    where   	expenditure_category = l_expenditure_category   /* p_expenditure_type */
    and		rate_class_id = p_rate_class_id
    and		rate_type_id = p_rate_type_id
    and 	rownum < 2;

    RETURN TRUE;
  EXCEPTION
    when no_data_found then
      RETURN FALSE;
  END check_exp_assignment;

------------------------------------------------------------------------------------
/* this procedure is obsoleted, duplicated procedure below to recalculate individually */

/*
  PROCEDURE recalculate_budget (p_proposal_id		NUMBER
				,p_version_id		NUMBER
				,p_activity_type_code	VARCHAR2
				,p_oh_rate_class_id	NUMBER
				,x_return_status    OUT NOCOPY	VARCHAR2
				,x_msg_data         OUT NOCOPY	VARCHAR2
				,x_msg_count	    OUT NOCOPY NUMBER) is

  cursor c_budget_periods is
  select budget_period_id
  , 	 start_date
  ,	 end_date
  from   igw_budget_periods
  where  proposal_id = p_proposal_id
  and	 version_id = p_version_id;

  l_budget_period_id	NUMBER(15);

  cursor c_budget_details is
  select pbd.line_item_id
  ,	 pbd.expenditure_type
  ,	 pbd.expenditure_category_flag
  ,	 pbd.apply_inflation_flag
  ,	 pbd.line_item_cost
  ,      pbd.cost_sharing_amount
  ,	 pbd.location_code
  ,	 et.personnel_attached_flag
  ,	 pbd.budget_period_id
  ,	 pbd.proposal_id
  ,	 pbd.version_id
  from	 igw_budget_details   	pbd
  ,	 igw_budget_expenditures_v et
  where  pbd.expenditure_type = et.budget_expenditure
  and	 pbd.expenditure_category_flag = et.expenditure_category_flag
  and	 pbd.proposal_id = p_proposal_id
  and	 pbd.budget_period_id = l_budget_period_id
  and	 pbd.version_id = p_version_id;


  l_line_item_id 	NUMBER(15);

  cursor c_budget_personnel is
  select budget_personnel_detail_id
  ,      start_date
  ,	 end_date
  ,	 percent_charged
  ,	 cost_sharing_percent
  ,	 person_id
  ,	 appointment_type_code
  from	 igw_budget_personnel_details
  where  line_item_id = l_line_item_id;

  l_base_amount			NUMBER;
  l_rate_class_id_oh		NUMBER(15);
  l_rate_type_id_oh		NUMBER(15);
  l_rate_class_id_eb		NUMBER(15);
  l_rate_type_id_eb		NUMBER(15);
  l_rate_class_id_inf		NUMBER(15);
  l_rate_type_id_inf		NUMBER(15);
  l_rate_class_id_oh_d		NUMBER(15);
  l_rate_type_id_oh_d		NUMBER(15);
  l_rate_class_id_eb_d		NUMBER(15);
  l_rate_type_id_eb_d		NUMBER(15);
  l_calculated_cost_share 	NUMBER;
  l_calculated_cost_share_ov 	NUMBER;
  l_oh_value			NUMBER;
  l_oh_value_ov			NUMBER;
  l_eb_value			NUMBER;
  l_eb_value_ov			NUMBER;
  l_oh_value_d			NUMBER;
  l_oh_value_ov_d		NUMBER;
  l_eb_value_d			NUMBER;
  l_eb_value_ov_d		NUMBER;
  l_inflated_salary		NUMBER;
  l_inflated_salary_ov		NUMBER;
  l_effective_date		DATE;
  l_appointment_type_code	VARCHAR2(30);
  l_apply_rate_flag_oh		VARCHAR2(1);
  l_apply_rate_flag_eb		VARCHAR2(1);
  l_apply_rate_flag		VARCHAR2(1);
  l_calculation_base		NUMBER;
  l_direct_cost1		NUMBER;
  l_cost_share1			NUMBER;
  l_underrecovery		NUMBER;
  l_cost_share2 		NUMBER;
  l_indirect_cost		NUMBER;
  l_cost_share3 		NUMBER;
  l_direct_cost2 		NUMBER;
  l_total_cost			NUMBER;
  l_total_direct_cost		NUMBER;
  l_total_indirect_cost		NUMBER;
  l_cost_sharing_amt		NUMBER;
  l_underrecovery_amount	NUMBER;
  l_total_cost_limit		NUMBER;
  l_calculated_cost_oh		NUMBER;
  l_cost_sharing_oh		NUMBER;
  l_calculated_cost_eb		NUMBER;
  l_cost_sharing_eb		NUMBER;
  l_salary_requested_upd	NUMBER;
  l_cost_sharing_amount_upd	NUMBER;
  l_underrecovery_amount_upd	NUMBER;
  l_return_status		VARCHAR2(1);
  l_msg_data 			VARCHAR2(200);
  l_msg_count			NUMBER(10);

  BEGIN
    fnd_msg_pub.initialize;
    for rec_budget_periods in c_budget_periods
    LOOP
      l_budget_period_id := rec_budget_periods.budget_period_id;
      for rec_budget_details in c_budget_details
      LOOP
        l_line_item_id := rec_budget_details.line_item_id;
        l_rate_class_id_oh := p_oh_rate_class_id;
        IGW_OVERHEAD_CAL.get_rate_id(rec_budget_details.expenditure_type
					,rec_budget_details.expenditure_category_flag
					, 'O'
					,l_rate_class_id_oh
					,l_rate_type_id_oh
			                ,l_return_status
					,l_msg_data);

        if l_return_status <> 'S' then
          raise FND_API.G_EXC_ERROR;
        end if;


        if rec_budget_details.personnel_attached_flag = 'N' then

          if rec_budget_details.apply_inflation_flag = 'Y' then
            IGW_OVERHEAD_CAL.get_rate_id(rec_budget_details.expenditure_type
					,rec_budget_details.expenditure_category_flag
					,'I'
					, l_rate_class_id_inf
					,l_rate_type_id_inf
					,l_return_status
					,l_msg_data);
            if l_return_status <> 'S' then
              raise FND_API.G_EXC_ERROR;
            end if;
          end if;
	  BEGIN
	    select apply_rate_flag
	    into   l_apply_rate_flag_oh
	    from   igw_budget_details_cal_amts
	    where  line_item_id = rec_budget_details.line_item_id;
          EXCEPTION
            when no_data_found then
              l_apply_rate_flag_oh := 'Y';
          End;

          l_base_amount := rec_budget_details.line_item_cost;

          IGW_OVERHEAD_CAL.calc_oh(p_proposal_id
			,p_version_id
			,l_base_amount
		  	,rec_budget_periods.start_date
		  	,rec_budget_periods.end_date
                        ,l_oh_value
                        ,l_oh_value_ov
			,p_activity_type_code
			,rec_budget_details.location_code
			,l_rate_class_id_oh
			,l_rate_type_id_oh
  			,l_return_status
  			,l_msg_data
			,l_msg_count);

            if l_return_status <> 'S' then
              raise FND_API.G_EXC_ERROR;
            end if;

          if l_apply_rate_flag_oh = 'N' then
            l_oh_value_ov := 0;
            l_calculated_cost_share_ov := 0;
          elsif l_apply_rate_flag_oh = 'Y' then
            IGW_OVERHEAD_CAL.calc_oh(p_proposal_id
			,p_version_id
			,rec_budget_details.cost_sharing_amount
		  	,rec_budget_periods.start_date
		  	,rec_budget_periods.end_date
                        ,l_calculated_cost_share
                        ,l_calculated_cost_share_ov
			,p_activity_type_code
			,rec_budget_details.location_code
			,l_rate_class_id_oh
			,l_rate_type_id_oh
  			,l_return_status
  			,l_msg_data
			,l_msg_count);
            if l_return_status <> 'S' then
              raise FND_API.G_EXC_ERROR;
            end if;
          end if;


          update igw_budget_details
          set	 line_item_cost = l_base_amount
	  ,	 underrecovery_amount = nvl(l_oh_value - l_oh_value_ov,0)
	  where  line_item_id = rec_budget_details.line_item_id;

          delete from igw_budget_details_cal_amts
          where  line_item_id = rec_budget_details.line_item_id;

          if check_exp_assignment(rec_budget_details.expenditure_type
				 ,rec_budget_details.expenditure_category_flag
				 ,l_rate_class_id_oh
				 ,l_rate_type_id_oh)	 then


	    IGW_GENERATE_PERIODS.create_budget_detail_amts(p_proposal_id
							,p_version_id
							,rec_budget_details.budget_period_id
							,rec_budget_details.line_item_id
							,l_rate_class_id_oh
							,l_rate_type_id_oh
							,l_apply_rate_flag_oh
							,nvl(l_oh_value_ov,0)
							,nvl(l_calculated_cost_share_ov,0));
          end if;

        elsif rec_budget_details.personnel_attached_flag = 'Y' then
          IGW_OVERHEAD_CAL.get_rate_id(rec_budget_details.expenditure_type
					,rec_budget_details.expenditure_category_flag
					,'E'
		,l_rate_class_id_eb,l_rate_type_id_eb,l_return_status, l_msg_data);

          if l_return_status <> 'S' then
            raise FND_API.G_EXC_ERROR;
          end if;
          for rec_budget_personnel in c_budget_personnel
          LOOP
  	    BEGIN
              select pca.apply_rate_flag
	      into   l_apply_rate_flag_oh
	      from   igw_budget_personnel_cal_amts  pca
	      ,	     igw_budget_personnel_details   pbd
	      where  pbd.budget_personnel_detail_id = rec_budget_personnel.budget_personnel_detail_id
  	      and    pca.budget_personnel_detail_id = pbd.budget_personnel_detail_id
              and    pca.rate_class_id = (	select  pr.rate_class_id
					from 	igw_rate_classes  pr
					where 	pca.rate_class_id = pr.rate_class_id
					and	pr.rate_class_type = 'O');
            EXCEPTION
              when no_data_found then
	        l_apply_rate_flag_oh := 'Y';
            End;

            BEGIN
              select pca.apply_rate_flag
	      into   l_apply_rate_flag_eb
	      from   igw_budget_personnel_cal_amts  pca
	      ,	     igw_budget_personnel_details   pbd
	      where  pbd.budget_personnel_detail_id = rec_budget_personnel.budget_personnel_detail_id
	      and    pca.budget_personnel_detail_id = pbd.budget_personnel_detail_id
              and    pca.rate_class_id = (	select  pr.rate_class_id
					from 	igw_rate_classes  pr
					where 	pca.rate_class_id = pr.rate_class_id
					and	pr.rate_class_type = 'E');
            EXCEPTION
              when no_data_found then
                l_apply_rate_flag_eb := 'Y';
            End;

            ---get base amount
	    select 	calculation_base
  	    ,		effective_date
	    ,		appointment_type_code
   	    into	l_calculation_base
            ,		l_effective_date
	    ,		l_appointment_type_code
	    from	igw_budget_persons
	    where	proposal_id = p_proposal_id
	    and		version_id = p_version_id
	    and		person_id = rec_budget_personnel.person_id
 	    and		appointment_type_code = rec_budget_personnel.appointment_type_code;

            IGW_OVERHEAD_CAL.calc_salary(p_proposal_id
			,p_version_id
			,l_calculation_base
			,l_effective_date
			,l_appointment_type_code
			,rec_budget_personnel.start_date
			,rec_budget_personnel.end_date
                        ,l_inflated_salary
                        ,l_inflated_salary_ov
			,rec_budget_details.expenditure_type
			,rec_budget_details.expenditure_category_flag
			,p_activity_type_code
			,rec_budget_details.location_code
  			,l_return_status
  			,l_msg_data
			,l_msg_count);
            if l_return_status <> 'S' then
              raise FND_API.G_EXC_ERROR;
            end if;

            l_inflated_salary := rec_budget_personnel.percent_charged/100 * l_inflated_salary;
            l_inflated_salary_ov := rec_budget_personnel.percent_charged/100 * l_inflated_salary_ov;
            if l_apply_rate_flag_oh = 'N' then
              l_rate_class_id_oh_d := null;
              l_rate_type_id_oh_d := null;
            else
              l_rate_class_id_oh_d := l_rate_class_id_oh;
              l_rate_type_id_oh_d := l_rate_type_id_oh;
            end if;
            if l_apply_rate_flag_eb = 'N' then
              l_rate_class_id_eb_d := null;
              l_rate_type_id_eb_d := null;
            else
              l_rate_class_id_eb_d := l_rate_class_id_eb;
              l_rate_type_id_eb_d := l_rate_type_id_eb;
            end if;


            IGW_OVERHEAD_CAL.calc_oh_eb (p_proposal_id
			,p_version_id
			,l_inflated_salary_ov
			,rec_budget_personnel.start_date
			,rec_budget_personnel.end_date
                        ,l_oh_value
                        ,l_oh_value_ov
			,l_eb_value
			,l_eb_value_ov
			,p_activity_type_code
			,rec_budget_details.location_code
			,l_rate_class_id_oh_d
			,l_rate_type_id_oh_d
			,l_rate_class_id_eb_d
			,l_rate_type_id_eb_d
  			,l_return_status
  			,l_msg_data
			,l_msg_count);
            if l_return_status <> 'S' then
              raise FND_API.G_EXC_ERROR;
            end if;

            IGW_OVERHEAD_CAL.calc_oh_eb (p_proposal_id
			,p_version_id
			,l_inflated_salary_ov
			,rec_budget_personnel.start_date
			,rec_budget_personnel.end_date
                        ,l_oh_value_d
                        ,l_oh_value_ov_d
			,l_eb_value_d
			,l_eb_value_ov_d
			,p_activity_type_code
			,rec_budget_details.location_code
			,l_rate_class_id_oh
			,l_rate_type_id_oh
			,l_rate_class_id_eb
			,l_rate_type_id_eb
  			,l_return_status
  			,l_msg_data
			,l_msg_count);
            if l_return_status <> 'S' then
              raise FND_API.G_EXC_ERROR;
            end if;


            if l_apply_rate_flag_oh = 'N' then
              l_oh_value_ov := 0;
            end if;
            if l_apply_rate_flag_eb = 'N' then
              l_eb_value_ov := 0;
	    end if;

            update igw_budget_personnel_details
            set	   salary_requested = l_inflated_salary_ov
            ,	   cost_sharing_amount = rec_budget_personnel.cost_sharing_percent/100 *
							l_inflated_salary_ov
            ,      underrecovery_amount = nvl(l_oh_value_d - l_oh_value_ov,0)
	    where  budget_personnel_detail_id =  rec_budget_personnel.budget_personnel_detail_id;


            delete from igw_budget_personnel_cal_amts
	    where  budget_personnel_detail_id = rec_budget_personnel.budget_personnel_detail_id;

            if check_exp_assignment(rec_budget_details.expenditure_type
				 ,rec_budget_details.expenditure_category_flag
				 ,l_rate_class_id_oh
				 ,l_rate_type_id_oh)	then
      	        IGW_GENERATE_PERIODS.create_budget_personnel_amts (
	    	     		 	    rec_budget_personnel.budget_personnel_detail_id
					    ,l_rate_class_id_oh
					    ,l_rate_type_id_oh
					    ,l_apply_rate_flag_oh
					    ,nvl(l_oh_value_ov,0)
					    ,rec_budget_personnel.cost_sharing_percent/100 * l_oh_value_ov);
            end if;
            if check_exp_assignment(rec_budget_details.expenditure_type
				 ,rec_budget_details.expenditure_category_flag
				 ,l_rate_class_id_eb
				 ,l_rate_type_id_eb)	then
      	        IGW_GENERATE_PERIODS.create_budget_personnel_amts (
	    	     		 	    rec_budget_personnel.budget_personnel_detail_id
					    ,l_rate_class_id_eb
					    ,l_rate_type_id_eb
					    ,l_apply_rate_flag_eb
					    ,nvl(l_eb_value_ov,0)
					    ,rec_budget_personnel.cost_sharing_percent/100 * l_eb_value);
            end if;

          END LOOP; --rec_budget_personnel


          delete from igw_budget_details_cal_amts
          where  line_item_id = rec_budget_details.line_item_id;

   		select 	sum(nvl(ppc.calculated_cost,0))
		,	sum(nvl(ppc.calculated_cost_sharing,0))
                into	l_calculated_cost_oh
		,	l_cost_sharing_oh
      		from	igw_budget_personnel_cal_amts   ppc
      		,      	igw_budget_personnel_details    ppd
		where  	ppd.line_item_id = rec_budget_details.line_item_id
		and 	ppd.budget_personnel_detail_id = ppc.budget_personnel_detail_id
		and	ppc.rate_class_id = l_rate_class_id_oh
		and	ppc.rate_type_id = l_rate_type_id_oh;

   		select 	sum(nvl(ppc.calculated_cost,0))
		,	sum(nvl(ppc.calculated_cost_sharing,0))
                into	l_calculated_cost_eb
		,	l_cost_sharing_eb
      		from	igw_budget_personnel_cal_amts   ppc
      		,      	igw_budget_personnel_details    ppd
		where  	ppd.line_item_id = rec_budget_details.line_item_id
		and 	ppd.budget_personnel_detail_id = ppc.budget_personnel_detail_id
		and	ppc.rate_class_id = l_rate_class_id_eb
		and	ppc.rate_type_id = l_rate_type_id_eb;

          if check_exp_assignment(rec_budget_details.expenditure_type
				 ,rec_budget_details.expenditure_category_flag
				 ,l_rate_class_id_oh
				 ,l_rate_type_id_oh)	then
  	    IGW_GENERATE_PERIODS.create_budget_detail_amts(rec_budget_details.proposal_id
							,rec_budget_details.version_id
							,rec_budget_details.budget_period_id
							,rec_budget_details.line_item_id
							,l_rate_class_id_oh
							,l_rate_type_id_oh
							,'Y'
							,nvl(l_calculated_cost_oh,0)
							,nvl(l_cost_sharing_oh,0));
          end if;

          if check_exp_assignment(rec_budget_details.expenditure_type
				 ,rec_budget_details.expenditure_category_flag
				 ,l_rate_class_id_eb
				 ,l_rate_type_id_eb)	then
	    IGW_GENERATE_PERIODS.create_budget_detail_amts(rec_budget_details.proposal_id
							,rec_budget_details.version_id
							,rec_budget_details.budget_period_id
							,rec_budget_details.line_item_id
							,l_rate_class_id_eb
							,l_rate_type_id_eb
							,'Y'
							,nvl(l_calculated_cost_eb,0)
							,nvl(l_cost_sharing_eb,0));
          end if;

--changed as recalculate should insert and delete overhead and eb amounts

	  select  sum(nvl(ppd.salary_requested,0))
	  , 	  sum(nvl(ppd.cost_sharing_amount,0))
	  ,	  sum(nvl(ppd.underrecovery_amount,0))
          into	  l_salary_requested_upd
	  ,	  l_cost_sharing_amount_upd
	  ,	  l_underrecovery_amount_upd
	  from    igw_budget_personnel_details  ppd
	  where   ppd.line_item_id = rec_budget_details.line_item_id;

          update igw_budget_details  pdb
          set    line_item_cost = nvl(l_salary_requested_upd,0)
	  ,	 cost_sharing_amount = nvl(l_cost_sharing_amount_upd,0)
          ,	 underrecovery_amount = nvl(l_underrecovery_amount_upd,0)
          where  pdb.line_item_id = rec_budget_details.line_item_id;

        end if;
      end LOOP; --rec_budget_details


        select 	nvl(sum(line_item_cost),0)
	, 	nvl(sum(cost_sharing_amount),0)
	, 	nvl(sum(underrecovery_amount),0)
        into	l_direct_cost1
	,	l_cost_share1
	,	l_underrecovery
        from	igw_budget_details
        where   proposal_id = p_proposal_id
        and	version_id = p_version_id
	and	budget_period_id = rec_budget_periods.budget_period_id;

        select 	nvl(sum(calculated_cost_sharing),0)
	, 	nvl(sum(calculated_cost),0)
        into	l_cost_share2
	,	l_indirect_cost
  	from 	igw_budget_details_cal_amts pc
        where   proposal_id = p_proposal_id
        and	version_id = p_version_id
	and	budget_period_id = rec_budget_periods.budget_period_id
        and	pc.rate_class_id = (	select  pr.rate_class_id
					from 	igw_rate_classes  pr
					where 	pc.rate_class_id = pr.rate_class_id
					and	pr.rate_class_type = 'O');
        select 	nvl(sum(calculated_cost_sharing),0)
	, 	nvl(sum(calculated_cost),0)
        into	l_cost_share3
	,	l_direct_cost2
  	from 	igw_budget_details_cal_amts pc
        where   proposal_id = p_proposal_id
        and	version_id = p_version_id
	and	budget_period_id = rec_budget_periods.budget_period_id
        and	pc.rate_class_id = (	select  pr.rate_class_id
					from 	igw_rate_classes  pr
					where 	pc.rate_class_id = pr.rate_class_id
					and	pr.rate_class_type = 'E');

        update 	igw_budget_periods
	set	total_cost = (l_direct_cost1+l_direct_cost2+l_indirect_cost)
	,	total_direct_cost = (l_direct_cost1+l_direct_cost2)
	,	total_indirect_cost = l_indirect_cost
	,	cost_sharing_amount = (l_cost_share1+l_cost_share2+l_cost_share3)
	,	underrecovery_amount = l_underrecovery
        where   proposal_id = p_proposal_id
        and	version_id = p_version_id
	and	budget_period_id = rec_budget_periods.budget_period_id;

    end LOOP; --rec_budget_periods


      	select 	nvl(sum(total_cost),0)
	,	nvl(sum(total_direct_cost),0)
	,	nvl(sum(total_indirect_cost),0)
	,	nvl(sum(cost_sharing_amount),0)
	,	nvl(sum(underrecovery_amount),0)
	,	nvl(sum(total_cost_limit),0)
	into 	l_total_cost
	,	l_total_direct_cost
	,	l_total_indirect_cost
	,	l_cost_sharing_amt
	,	l_underrecovery_amount
	,	l_total_cost_limit
 	from	igw_budget_periods
	where	proposal_id = p_proposal_id
	and	version_id = p_version_id;


        update 	igw_budgets
	set	total_cost = l_total_cost
	,	total_direct_cost = l_total_direct_cost
	,	total_indirect_cost = l_total_indirect_cost
	,	cost_sharing_amount = l_cost_sharing_amt
	,	underrecovery_amount = l_underrecovery_amount
	,	total_cost_limit = l_total_cost_limit
	where	proposal_id = p_proposal_id
	and	version_id = p_version_id;

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
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'RECALCULATE_BUDGET');
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
  end  recalculate_budget;
*/
-----------------------------------------------------------------------------------------------
  PROCEDURE copy_budget(p_proposal_id			NUMBER
			,p_target_proposal_id	 	NUMBER
			,p_version_id			NUMBER
                        ,p_copy_first_period		VARCHAR2
			,p_copy_type			VARCHAR2
			,p_budget_type_code		VARCHAR2
			,x_return_status    	OUT NOCOPY	VARCHAR2
			,x_msg_data         	OUT NOCOPY	VARCHAR2
			,x_msg_count	    	OUT NOCOPY 	NUMBER) is

  /* The values for p_copy_type can be 'B'
     for budget and 'P' for proposal.

     The values for p_copy_first_period is 'S'
     for a single period

     The values for p_budget_type_code are 'PROPOSAL_BUDGET'
     for any normal budget version in PRE-AWARD system and
     'AWARD_BUDGET' for the version that will used to
     export to POST-AWARD system */


  cursor c_budgets is
  select *
  from   igw_budgets
  where  proposal_id = p_proposal_id
  and	 version_id = nvl(p_version_id, version_id);

  l_version_id			NUMBER(4);

  cursor c_budget_periods is
  select *
  from   igw_budget_periods
  where  proposal_id = p_proposal_id
  and	 version_id = l_version_id;

  l_budget_period_id	NUMBER(15);

  cursor c_budget_details is
  select pbd.line_item_id
  , 	 pbd.expenditure_type
  ,	 pbd.budget_category_code
  , 	 pbd.expenditure_category_flag
  ,	 pbd.line_item_description
  ,	 pbd.based_on_line_item
  ,	 pbd.line_item_cost
  ,      pbd.cost_sharing_amount
  ,	 pbd.underrecovery_amount
  ,	 pbd.apply_inflation_flag
  ,	 pbd.budget_justification
  ,	 pbd.location_code
  ,	 et.personnel_attached_flag
  ,	 pbd.budget_period_id
  from	 igw_budget_details   	pbd
  ,	 igw_budget_expenditures_v et
  where  pbd.expenditure_type = et.budget_expenditure
  and	 pbd.expenditure_category_flag = et.expenditure_category_flag
  and	 pbd.proposal_id = p_proposal_id
  and	 pbd.budget_period_id = l_budget_period_id
  and	 pbd.version_id = l_version_id;

  l_line_item_id		NUMBER(15);


  cursor c_budget_detail_amts is
  select *
  from 	 igw_budget_details_cal_amts
  where  line_item_id = l_line_item_id;


  cursor c_budget_personnel is
  select *
  from   igw_budget_personnel_details
  where  line_item_id = l_line_item_id;

  l_budget_personnel_detail_id 	NUMBER(15);

  cursor c_budget_personnel_amts is
  select *
  from   igw_budget_personnel_cal_amts
  where  budget_personnel_detail_id = l_budget_personnel_detail_id;

  cursor c_budget_persons is
  select *
  from   igw_budget_persons
  where  proposal_id = p_proposal_id
  and	 version_id = l_version_id;

  cursor c_prop_rates is
  select *
  from   igw_prop_rates
  where  proposal_id = p_proposal_id
  and    version_id = l_version_id;

  l_target_version_id		NUMBER(4);
  l_dummy_line_item_id		NUMBER(15);
  l_dummy_personnel_id		NUMBER(15);
  l_based_on_line_item		NUMBER(15);
  l_counter			NUMBER(15) :=1;
  l_loop_counter		NUMBER(15) :=1;
  l_direct_cost1		NUMBER;
  l_cost_share1			NUMBER;
  l_underrecovery		NUMBER;
  l_cost_share2 		NUMBER;
  l_indirect_cost		NUMBER;
  l_cost_share3 		NUMBER;
  l_direct_cost2		NUMBER;
  l_total_cost			NUMBER;
  l_total_direct_cost		NUMBER;
  l_total_indirect_cost		NUMBER;
  l_cost_sharing_amt		NUMBER;
  l_underrecovery_amount	NUMBER;
  l_total_cost_limit		NUMBER;
  l_return_status		VARCHAR2(1);
  l_msg_data 			VARCHAR2(200);
  l_msg_count			NUMBER(10);



  BEGIN
    fnd_msg_pub.initialize;

    if p_copy_type = 'B' then
      select max(version_id)+1
      into   l_target_version_id
      from   igw_budgets
      where  proposal_id = p_proposal_id;

    --dbms_output.put_line('the max version id available is '||l_target_version_id);
    end if;
    l_version_id := p_version_id;

    for rec_budgets in c_budgets
    LOOP
      if p_copy_type = 'P' then
        if p_version_id is not null then
          l_target_version_id := 1;
        else
          l_target_version_id := rec_budgets.version_id;
          --dbms_output.put_line('the l_target_version_id '||l_target_version_id);
        end if;
      end if;
      l_version_id := rec_budgets.version_id;

      insert into igw_budgets( proposal_id
 				,version_id
				,start_date
				,end_date
				,total_cost
				,total_direct_cost
				,total_indirect_cost
				,cost_sharing_amount
				,underrecovery_amount
				,residual_funds
				,total_cost_limit
				,oh_rate_class_id
				,proposal_form_number
				,comments
				,final_version_flag
				,budget_type_code
				,record_version_number
                                ,apply_inflation_setup_rates
                                ,apply_eb_setup_rates
                                ,apply_oh_setup_rates
                                ,enter_budget_at_period_level
				,last_update_date
				,last_updated_by
				,creation_date
				,created_by
				,last_update_login
				,attribute_category
				,attribute1
				,attribute2
				,attribute3
				,attribute4
				,attribute5
				,attribute6
				,attribute7
				,attribute8
				,attribute9
				,attribute10
				,attribute11
				,attribute12
				,attribute13
				,attribute14
				,attribute15)
			values( p_target_proposal_id
				,l_target_version_id
				,rec_budgets.start_date
				,rec_budgets.end_date
				,rec_budgets.total_cost
				,rec_budgets.total_direct_cost
				,rec_budgets.total_indirect_cost
				,rec_budgets.cost_sharing_amount
				,rec_budgets.underrecovery_amount
				,rec_budgets.residual_funds
				,rec_budgets.total_cost_limit
				,rec_budgets.oh_rate_class_id
				,rec_budgets.proposal_form_number
				,rec_budgets.comments
				,'N'
				,p_budget_type_code
				,1
                                ,rec_budgets.apply_inflation_setup_rates
                                ,rec_budgets.apply_eb_setup_rates
                                ,rec_budgets.apply_oh_setup_rates
                                ,rec_budgets.enter_budget_at_period_level
				,sysdate
				,fnd_global.user_id
				,sysdate
				,fnd_global.user_id
				,fnd_global.login_id
				,rec_budgets.attribute_category
				,rec_budgets.attribute1
				,rec_budgets.attribute2
				,rec_budgets.attribute3
				,rec_budgets.attribute4
				,rec_budgets.attribute5
				,rec_budgets.attribute6
				,rec_budgets.attribute7
				,rec_budgets.attribute8
				,rec_budgets.attribute9
				,rec_budgets.attribute10
				,rec_budgets.attribute11
				,rec_budgets.attribute12
				,rec_budgets.attribute13
				,rec_budgets.attribute14
				,rec_budgets.attribute15);

      for rec_budget_periods in c_budget_periods
      LOOP
        if p_copy_first_period = 'S' then
          EXIT when l_loop_counter = 2;
        end if;

        insert into igw_budget_periods(  proposal_id
					,version_id
					,budget_period_id
					,start_date
					,end_date
					,total_cost
					,total_direct_cost
					,total_indirect_cost
					,cost_sharing_amount
					,underrecovery_amount
					,total_cost_limit
					,program_income
					,program_income_source
				        ,record_version_number
					,last_update_date
					,last_updated_by
					,creation_date
					,created_by
					,last_update_login)
				values( p_target_proposal_id
					,l_target_version_id
					,rec_budget_periods.budget_period_id
					,rec_budget_periods.start_date
					,rec_budget_periods.end_date
					,rec_budget_periods.total_cost
					,rec_budget_periods.total_direct_cost
					,rec_budget_periods.total_indirect_cost
					,rec_budget_periods.cost_sharing_amount
					,rec_budget_periods.underrecovery_amount
					,rec_budget_periods.total_cost_limit
					,rec_budget_periods.program_income
					,rec_budget_periods.program_income_source
					,1
					,sysdate
					,fnd_global.user_id
					,sysdate
					,fnd_global.user_id
					,fnd_global.login_id);

        l_budget_period_id := rec_budget_periods.budget_period_id;

        for rec_budget_details in c_budget_details
        LOOP
          if l_counter = 1 then
            l_based_on_line_item := null;
          elsif l_counter = 2 then
            select igw_budget_details_s.currval into l_based_on_line_item from dual;
          end if;

          IGW_GENERATE_PERIODS.create_budget_detail (
						p_target_proposal_id
						,l_target_version_id
						,rec_budget_details.budget_period_id
						,l_dummy_line_item_id
						,rec_budget_details.expenditure_type
						,rec_budget_details.budget_category_code
						,rec_budget_details.expenditure_category_flag
						,rec_budget_details.line_item_description
						,l_based_on_line_item
						,rec_budget_details.line_item_cost
						,rec_budget_details.cost_sharing_amount
						,rec_budget_details.underrecovery_amount
						,rec_budget_details.apply_inflation_flag
						,rec_budget_details.budget_justification
						,rec_budget_details.location_code);


          if rec_budget_details.personnel_attached_flag = 'Y' then
            l_line_item_id := rec_budget_details.line_item_id;
            for rec_budget_personnel in c_budget_personnel
            LOOP

              insert into igw_budget_personnel_details (
	 			 budget_personnel_detail_id
				,proposal_id
				,version_id
				,budget_period_id
				,line_item_id
				,person_id
				,party_id
				,start_date
				,end_date
				,period_type_code
				,appointment_type_code
				,salary_requested
				,percent_charged
				,percent_effort
				,cost_sharing_percent
				,cost_sharing_amount
				,underrecovery_amount
				,record_version_number
				,last_update_date
				,last_updated_by
				,creation_date
				,created_by
				,last_update_login)
			values (igw_budget_personnel_s.nextval
				,p_target_proposal_id
				,l_target_version_id
				,rec_budget_details.budget_period_id
				,igw_budget_details_s.currval
				,rec_budget_personnel.person_id
				,rec_budget_personnel.party_id
				,rec_budget_personnel.start_date
				,rec_budget_personnel.end_date
				,rec_budget_personnel.period_type_code
				,rec_budget_personnel.appointment_type_code
				,rec_budget_personnel.salary_requested
				,rec_budget_personnel.percent_charged
				,rec_budget_personnel.percent_effort
				,rec_budget_personnel.cost_sharing_percent
				,rec_budget_personnel.cost_sharing_amount
				,rec_budget_personnel.underrecovery_amount
				,1
				,sysdate
				,fnd_global.user_id
				,sysdate
				,fnd_global.user_id
				,fnd_global.login_id);

	      l_budget_personnel_detail_id := rec_budget_personnel.budget_personnel_detail_id;
              for rec_budget_personnel_amts in c_budget_personnel_amts
              LOOP
                select igw_budget_personnel_s.currval into l_dummy_personnel_id from dual;
      	        IGW_GENERATE_PERIODS.create_budget_personnel_amts (
	    	     		 	    l_dummy_personnel_id
					    ,rec_budget_personnel_amts.rate_class_id
					    ,rec_budget_personnel_amts.rate_type_id
					    ,rec_budget_personnel_amts.apply_rate_flag
					    ,rec_budget_personnel_amts.calculated_cost
					    ,rec_budget_personnel_amts.calculated_cost_sharing);
              END LOOP; --personnel amts
            END LOOP; --personnel
          end if;
          l_line_item_id := rec_budget_details.line_item_id;
          for rec_budget_detail_amts in c_budget_detail_amts
          LOOP

            select igw_budget_details_s.currval into l_dummy_line_item_id from dual;

  	    IGW_GENERATE_PERIODS.create_budget_detail_amts(p_target_proposal_id
						,l_target_version_id
						,rec_budget_details.budget_period_id
						,l_dummy_line_item_id
						,rec_budget_detail_amts.rate_class_id
						,rec_budget_detail_amts.rate_type_id
						,rec_budget_detail_amts.apply_rate_flag
						,rec_budget_detail_amts.calculated_cost
						,rec_budget_detail_amts.calculated_cost_sharing);

          END LOOP; --rec_budget_detail_amts
        l_counter := l_counter + 1;
        END LOOP; --budget details
        l_loop_counter := l_loop_counter + 1;
      END LOOP; -- budget periods
      for rec_budget_persons in c_budget_persons
      LOOP
        insert into igw_budget_persons(	proposal_id
					,version_id
					,person_id
					,party_id
					,appointment_type_code
					,effective_date
					,calculation_base
				        ,record_version_number
					,last_update_date
					,last_updated_by
					,creation_date
					,created_by
					,last_update_login)
				values( p_target_proposal_id
					,l_target_version_id
					,rec_budget_persons.person_id
					,rec_budget_persons.party_id
					,rec_budget_persons.appointment_type_code
					,rec_budget_persons.effective_date
					,rec_budget_persons.calculation_base
					,1
					,sysdate
					,fnd_global.user_id
					,sysdate
					,fnd_global.user_id
					,fnd_global.login_id);
      END LOOP; --budget_persons

      for rec_prop_rates in c_prop_rates
      LOOP

        insert into igw_prop_rates(	proposal_id
					,version_id
					,rate_class_id
					,rate_type_id
					,fiscal_year
					,location_code
					,activity_type_code
					,start_date
					,applicable_rate
					,institute_rate
				        ,record_version_number
					,last_update_date
					,last_updated_by
					,creation_date
					,created_by
					,last_update_login)
				values( p_target_proposal_id
					,l_target_version_id
					,rec_prop_rates.rate_class_id
					,rec_prop_rates.rate_type_id
					,rec_prop_rates.fiscal_year
					,rec_prop_rates.location_code
					,rec_prop_rates.activity_type_code
					,rec_prop_rates.start_date
					,rec_prop_rates.applicable_rate
					,rec_prop_rates.institute_rate
					,1
					,sysdate
					,fnd_global.user_id
					,sysdate
					,fnd_global.user_id
					,fnd_global.login_id);
      END LOOP;--rec_prop_rates
    END LOOP; -- budgets
    if p_copy_first_period = 'S' then
        select 	nvl(sum(line_item_cost),0)
	, 	nvl(sum(cost_sharing_amount),0)
	, 	nvl(sum(underrecovery_amount),0)
        into	l_direct_cost1
	,	l_cost_share1
	,	l_underrecovery
        from	igw_budget_details
        where   proposal_id = p_target_proposal_id
        and	version_id = l_target_version_id
	and	budget_period_id = 1;

        select 	nvl(sum(calculated_cost_sharing),0)
	, 	nvl(sum(calculated_cost),0)
        into	l_cost_share2
	,	l_indirect_cost
  	from 	igw_budget_details_cal_amts pc
        where   proposal_id = p_target_proposal_id
        and	version_id = l_target_version_id
	and	budget_period_id = 1
        and	pc.rate_class_id = (	select  pr.rate_class_id
					from 	igw_rate_classes  pr
					where 	pc.rate_class_id = pr.rate_class_id
					and	pr.rate_class_type = 'O');
        select 	nvl(sum(calculated_cost_sharing),0)
	, 	nvl(sum(calculated_cost),0)
        into	l_cost_share3
	,	l_direct_cost2
  	from 	igw_budget_details_cal_amts pc
        where   proposal_id = p_target_proposal_id
        and	version_id = l_target_version_id
	and	budget_period_id = 1
        and	pc.rate_class_id = (	select  pr.rate_class_id
					from 	igw_rate_classes  pr
					where 	pc.rate_class_id = pr.rate_class_id
					and	pr.rate_class_type = 'E');

        update 	igw_budget_periods
	set	total_cost = (l_direct_cost1+l_direct_cost2+l_indirect_cost)
	,	total_direct_cost = (l_direct_cost1+l_direct_cost2)
	,	total_indirect_cost = l_indirect_cost
	,	cost_sharing_amount = (l_cost_share1+l_cost_share2+l_cost_share3)
	,	underrecovery_amount = l_underrecovery
        where   proposal_id = p_target_proposal_id
        and	version_id = l_target_version_id
	and	budget_period_id = 1;



      	select 	nvl(sum(total_cost),0)
	,	nvl(sum(total_direct_cost),0)
	,	nvl(sum(total_indirect_cost),0)
	,	nvl(sum(cost_sharing_amount),0)
	,	nvl(sum(underrecovery_amount),0)
	,	nvl(sum(total_cost_limit),0)
	into 	l_total_cost
	,	l_total_direct_cost
	,	l_total_indirect_cost
	,	l_cost_sharing_amt
	,	l_underrecovery_amount
	,	l_total_cost_limit
 	from	igw_budget_periods
	where	proposal_id = p_target_proposal_id
	and	version_id = l_target_version_id;


        update 	igw_budgets
	set	total_cost = l_total_cost
	,	total_direct_cost = l_total_direct_cost
	,	total_indirect_cost = l_total_indirect_cost
	,	cost_sharing_amount = l_cost_sharing_amt
	,	underrecovery_amount = l_underrecovery_amount
	,	total_cost_limit = l_total_cost_limit
	where	proposal_id = p_target_proposal_id
	and	version_id = l_target_version_id;

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
      --dbms_output.put_line(x_msg_data);
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'COPY_BUDGET');
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
  END copy_budget;
-----------------------------------------------------------------------------------------
  Function get_proposal_id RETURN NUMBER is
  Begin
    RETURN IGW_BUDGET_OPERATIONS.G_PROPOSAL_ID;
  End;
-------------------------------------------------------------------------------------------
  Function get_version_id RETURN NUMBER is
  Begin
    RETURN IGW_BUDGET_OPERATIONS.G_VERSION_ID;
  End;

----------------------------------------------------------------------------------------
  Function get_period_id RETURN NUMBER is
  Begin
    RETURN IGW_BUDGET_OPERATIONS.G_START_PERIOD;
  End;

------------------------------------------------------------------------------------------------
  Procedure set_global_variables(p_start_period 	NUMBER
				 ,p_proposal_id 	NUMBER
				 ,p_version_id  	NUMBER) is

  Begin
    IGW_BUDGET_OPERATIONS.G_START_PERIOD :=p_start_period;
    IGW_BUDGET_OPERATIONS.G_PROPOSAL_ID :=p_proposal_id;
    IGW_BUDGET_OPERATIONS.G_VERSION_ID :=p_version_id;
  End;
--------------------------------------------------------------------------------------------
  PROCEDURE recalculate_budget(p_proposal_id		      NUMBER
			       ,p_version_id		      NUMBER
                               ,p_budget_period_id            NUMBER   :=NULL
                               ,p_line_item_id                NUMBER   :=NULL
                               ,p_budget_personnel_detail_id  NUMBER   :=NULL
			       ,p_activity_type_code	      VARCHAR2 :=NULL
			       ,p_oh_rate_class_id	      NUMBER   :=NULL
			       ,x_return_status          OUT NOCOPY  VARCHAR2
			       ,x_msg_data               OUT NOCOPY  VARCHAR2
			       ,x_msg_count	         OUT NOCOPY  NUMBER) is



  cursor c_budget_version is
  select enter_budget_at_period_level
  ,      apply_inflation_setup_rates
  ,      apply_eb_setup_rates
  ,      apply_oh_setup_rates
  from   igw_budgets
  where  proposal_id = p_proposal_id
  and	 version_id = p_version_id;


  cursor c_budget_periods is
  select budget_period_id
  , 	 start_date
  ,	 end_date
  ,      total_direct_cost
  ,      total_indirect_cost
  ,      total_cost
  from   igw_budget_periods
  where  proposal_id = p_proposal_id
  and	 version_id = p_version_id
  and    budget_period_id = nvl(p_budget_period_id, budget_period_id);

  l_budget_period_id	NUMBER(15);

  cursor c_budget_details is
  select pbd.line_item_id
  ,	 pbd.expenditure_type
  ,	 pbd.expenditure_category_flag
  ,	 pbd.apply_inflation_flag
  ,	 pbd.line_item_cost
  ,      pbd.cost_sharing_amount
  ,	 pbd.location_code
  ,	 et.personnel_attached_flag
  ,	 pbd.budget_period_id
  ,	 pbd.proposal_id
  ,	 pbd.version_id
  from	 igw_budget_details   	pbd
  ,	 igw_budget_expenditures_v et
  where  pbd.expenditure_type = et.budget_expenditure
  and	 pbd.expenditure_category_flag = et.expenditure_category_flag
  and	 pbd.proposal_id = p_proposal_id
  and	 pbd.budget_period_id = l_budget_period_id
  and	 pbd.version_id = p_version_id
  and    pbd.line_item_id = nvl(p_line_item_id, line_item_id);


  l_line_item_id 	NUMBER(15);

  cursor c_budget_personnel is
  select budget_personnel_detail_id
  ,      start_date
  ,	 end_date
  ,	 percent_charged
  ,	 cost_sharing_percent
  ,	 person_id
  ,	 party_id
  ,	 appointment_type_code
  from	 igw_budget_personnel_details
  where  line_item_id = l_line_item_id
  and    budget_personnel_detail_id = nvl(p_budget_personnel_detail_id, budget_personnel_detail_id);

  l_pers_cost_sharing_amt       NUMBER; -- Bug 2702314
  l_base_amount			NUMBER;
  l_rate_class_id_oh		NUMBER(15);
  l_rate_type_id_oh		NUMBER(15);
  l_rate_class_id_eb		NUMBER(15);
  l_rate_type_id_eb		NUMBER(15);
  l_rate_class_id_inf		NUMBER(15);
  l_rate_type_id_inf		NUMBER(15);
  l_rate_class_id_oh_d		NUMBER(15);
  l_rate_type_id_oh_d		NUMBER(15);
  l_rate_class_id_eb_d		NUMBER(15);
  l_rate_type_id_eb_d		NUMBER(15);
  l_calculated_cost_share 	NUMBER;
  l_calculated_cost_share_ov 	NUMBER;
  l_oh_value			NUMBER;
  l_oh_value_ov			NUMBER;
  l_eb_value			NUMBER;
  l_eb_value_ov			NUMBER;
  l_oh_value_d			NUMBER;
  l_oh_value_ov_d		NUMBER;
  l_eb_value_d			NUMBER;
  l_eb_value_ov_d		NUMBER;
  l_inflated_salary		NUMBER;
  l_inflated_salary_ov		NUMBER;
  l_effective_date		DATE;
  l_appointment_type_code	VARCHAR2(30);
  l_apply_rate_flag_oh		VARCHAR2(1);
  l_apply_rate_flag_eb		VARCHAR2(1);
  l_apply_rate_flag		VARCHAR2(1);
  l_calculation_base		NUMBER;
  l_direct_cost1		NUMBER;
  l_cost_share1			NUMBER;
  l_underrecovery		NUMBER;
  l_cost_share2 		NUMBER;
  l_indirect_cost		NUMBER;
  l_cost_share3 		NUMBER;
  l_direct_cost2 		NUMBER;
  l_total_cost			NUMBER;
  l_total_direct_cost		NUMBER;
  l_total_indirect_cost		NUMBER;
  l_cost_sharing_amt		NUMBER;
  l_underrecovery_amount	NUMBER;
  l_total_cost_limit		NUMBER;
  l_calculated_cost_oh		NUMBER;
  l_cost_sharing_oh		NUMBER;
  l_calculated_cost_eb		NUMBER;
  l_cost_sharing_eb		NUMBER;
  l_salary_requested_upd	NUMBER;
  l_cost_sharing_amount_upd	NUMBER;
  l_underrecovery_amount_upd	NUMBER;
  l_activity_type_code          NUMBER := p_activity_type_code;
  l_oh_rate_class_id            NUMBER := p_oh_rate_class_id;
  l_enter_budget_at_period_level    VARCHAR2(1);
  l_apply_inflation_setup_rates  VARCHAR2(1);
  l_apply_eb_setup_rates        VARCHAR2(1);
  l_apply_oh_setup_rates        VARCHAR2(1);
  l_calculated_cost_share_ov_usr  NUMBER;
  l_oh_value_ov_usr             NUMBER;
  l_eb_value_ov_usr             NUMBER;
  l_calculated_cost_share_eb_usr  NUMBER;
  l_return_status		VARCHAR2(1);
  l_msg_data 			VARCHAR2(200);
  l_msg_count			NUMBER(10);

  BEGIN
   fnd_msg_pub.initialize;
   x_return_status := 'S';

   /* getting needed values if not provided */
   if (p_version_id is not null and p_proposal_id is not null) then
     if p_activity_type_code is null then
       select activity_type_code
       into   l_activity_type_code
       from   igw_proposals_all
       where  proposal_id = p_proposal_id;
     end if;

     if p_oh_rate_class_id is null then
       select oh_rate_class_id
       into   l_oh_rate_class_id
       from   igw_budgets
       where  proposal_id = p_proposal_id
       and    version_id = p_version_id;
     end if;
   end if;

   open c_budget_version;
   fetch c_budget_version into l_enter_budget_at_period_level
            , l_apply_inflation_setup_rates
            , l_apply_eb_setup_rates
            , l_apply_oh_setup_rates;
   close c_budget_version;

  if l_enter_budget_at_period_level = 'N' then
    for rec_budget_periods in c_budget_periods
    LOOP
      l_budget_period_id := rec_budget_periods.budget_period_id;
      for rec_budget_details in c_budget_details
      LOOP
        l_line_item_id := rec_budget_details.line_item_id;
        l_rate_class_id_oh := l_oh_rate_class_id;
        IGW_OVERHEAD_CAL.get_rate_id(rec_budget_details.expenditure_type
					,rec_budget_details.expenditure_category_flag
					, 'O'
					,l_rate_class_id_oh
					,l_rate_type_id_oh
			                ,l_return_status
					,l_msg_data);

        if l_return_status <> 'S' then
          raise FND_API.G_EXC_ERROR;
        end if;


        if rec_budget_details.personnel_attached_flag = 'N' then

          if rec_budget_details.apply_inflation_flag = 'Y' then
            IGW_OVERHEAD_CAL.get_rate_id(rec_budget_details.expenditure_type
					,rec_budget_details.expenditure_category_flag
					,'I'
					, l_rate_class_id_inf
					,l_rate_type_id_inf
					,l_return_status
					,l_msg_data);
            if l_return_status <> 'S' then
              raise FND_API.G_EXC_ERROR;
            end if;
          end if;
	  BEGIN
	    select apply_rate_flag, calculated_cost, calculated_cost_sharing
	    into   l_apply_rate_flag_oh, l_oh_value_ov_usr, l_calculated_cost_share_ov_usr
	    from   igw_budget_details_cal_amts
	    where  line_item_id = rec_budget_details.line_item_id;
          EXCEPTION
            when no_data_found then
              l_apply_rate_flag_oh := 'Y';
          End;

          l_base_amount := rec_budget_details.line_item_cost;

           /* NON_PERSONNEL: the reason why we are calculating cal_oh twice  is because, once to calculate cost share amt
              for line and second time to calculate cost share for Overhead line. */
          IGW_OVERHEAD_CAL.calc_oh(p_proposal_id
			,p_version_id
			,l_base_amount
		  	,rec_budget_periods.start_date
		  	,rec_budget_periods.end_date
                        ,l_oh_value
                        ,l_oh_value_ov
			,l_activity_type_code
			,rec_budget_details.location_code
			,l_rate_class_id_oh
			,l_rate_type_id_oh
  			,l_return_status
  			,l_msg_data
			,l_msg_count);

            if l_return_status <> 'S' then
              raise FND_API.G_EXC_ERROR;
            end if;

          if l_apply_rate_flag_oh = 'N' then
            l_oh_value_ov := 0;
            l_calculated_cost_share_ov := 0;
          elsif l_apply_rate_flag_oh = 'Y' then
            if l_apply_oh_setup_rates = 'Y' then
              /*this proc is for calculationg Overhead cost share amt from line cost share amt */
              IGW_OVERHEAD_CAL.calc_oh(p_proposal_id
			,p_version_id
			,rec_budget_details.cost_sharing_amount
		  	,rec_budget_periods.start_date
		  	,rec_budget_periods.end_date
                        ,l_calculated_cost_share
                        ,l_calculated_cost_share_ov
			,l_activity_type_code
			,rec_budget_details.location_code
			,l_rate_class_id_oh
			,l_rate_type_id_oh
  			,l_return_status
  			,l_msg_data
			,l_msg_count);
              if l_return_status <> 'S' then
                raise FND_API.G_EXC_ERROR;
              end if;
            end if;
          end if;

         if l_apply_oh_setup_rates = 'Y' then
           /* underrecovery is Oh value using setup rates minus oh value using setup/overwritten rates */
           update igw_budget_details
           set	 line_item_cost = l_base_amount
	   ,	 underrecovery_amount = nvl(l_oh_value - l_oh_value_ov,0)
	   where  line_item_id = rec_budget_details.line_item_id;
        else
           update igw_budget_details
           set	 line_item_cost = l_base_amount
	   ,	 underrecovery_amount = nvl(l_oh_value - l_oh_value_ov_usr,0)
	   where  line_item_id = rec_budget_details.line_item_id;
        end if;

         delete from igw_budget_details_cal_amts
         where  line_item_id = rec_budget_details.line_item_id;

          if check_exp_assignment(rec_budget_details.expenditure_type
				 ,rec_budget_details.expenditure_category_flag
				 ,l_rate_class_id_oh
				 ,l_rate_type_id_oh)	 then

            if l_apply_oh_setup_rates = 'Y' then
	      IGW_GENERATE_PERIODS.create_budget_detail_amts(p_proposal_id
							,p_version_id
							,rec_budget_details.budget_period_id
							,rec_budget_details.line_item_id
							,l_rate_class_id_oh
							,l_rate_type_id_oh
							,l_apply_rate_flag_oh
							,nvl(l_oh_value_ov,0)
							,nvl(l_calculated_cost_share_ov,0));
            else
	      IGW_GENERATE_PERIODS.create_budget_detail_amts(p_proposal_id
							,p_version_id
							,rec_budget_details.budget_period_id
							,rec_budget_details.line_item_id
							,l_rate_class_id_oh
							,l_rate_type_id_oh
							,l_apply_rate_flag_oh
							,nvl(l_oh_value_ov_usr,0)
							,nvl(l_calculated_cost_share_ov_usr,0));
            end if;
          end if;

        elsif rec_budget_details.personnel_attached_flag = 'Y' then
          IGW_OVERHEAD_CAL.get_rate_id(rec_budget_details.expenditure_type
					,rec_budget_details.expenditure_category_flag
					,'E'
		,l_rate_class_id_eb,l_rate_type_id_eb,l_return_status, l_msg_data);

          if l_return_status <> 'S' then
            raise FND_API.G_EXC_ERROR;
          end if;
          for rec_budget_personnel in c_budget_personnel
          LOOP
  	    BEGIN
              select pca.apply_rate_flag , calculated_cost, calculated_cost_sharing
	      into   l_apply_rate_flag_oh, l_oh_value_ov_usr, l_calculated_cost_share_ov_usr
	      from   igw_budget_personnel_cal_amts  pca
	      ,	     igw_budget_personnel_details   pbd
	      where  pbd.budget_personnel_detail_id = rec_budget_personnel.budget_personnel_detail_id
  	      and    pca.budget_personnel_detail_id = pbd.budget_personnel_detail_id
              and    pca.rate_class_id = (	select  pr.rate_class_id
					from 	igw_rate_classes  pr
					where 	pca.rate_class_id = pr.rate_class_id
					and	pr.rate_class_type = 'O');
            EXCEPTION
              when no_data_found then
	        l_apply_rate_flag_oh := 'Y';
            End;

            BEGIN
              select pca.apply_rate_flag , calculated_cost, calculated_cost_sharing
	      into   l_apply_rate_flag_eb,  l_eb_value_ov_usr, l_calculated_cost_share_eb_usr
	      from   igw_budget_personnel_cal_amts  pca
	      ,	     igw_budget_personnel_details   pbd
	      where  pbd.budget_personnel_detail_id = rec_budget_personnel.budget_personnel_detail_id
	      and    pca.budget_personnel_detail_id = pbd.budget_personnel_detail_id
              and    pca.rate_class_id = (	select  pr.rate_class_id
					from 	igw_rate_classes  pr
					where 	pca.rate_class_id = pr.rate_class_id
					and	pr.rate_class_type = 'E');
            EXCEPTION
              when no_data_found then
                l_apply_rate_flag_eb := 'Y';
            End;

            ---get base amount
	    select 	calculation_base
  	    ,		effective_date
	    ,		appointment_type_code
   	    into	l_calculation_base
            ,		l_effective_date
	    ,		l_appointment_type_code
	    from	igw_budget_persons
	    where	proposal_id = p_proposal_id
	    and		version_id = p_version_id
	    --and		person_id = rec_budget_personnel.person_id
	    and		party_id = rec_budget_personnel.party_id
 	    and		appointment_type_code = rec_budget_personnel.appointment_type_code;

            IGW_OVERHEAD_CAL.calc_salary(p_proposal_id
			,p_version_id
			,l_calculation_base
			,l_effective_date
			,l_appointment_type_code
			,rec_budget_personnel.start_date
			,rec_budget_personnel.end_date
                        ,l_inflated_salary
                        ,l_inflated_salary_ov
			,rec_budget_details.expenditure_type
			,rec_budget_details.expenditure_category_flag
			,l_activity_type_code
			,rec_budget_details.location_code
  			,l_return_status
  			,l_msg_data
			,l_msg_count);
            if l_return_status <> 'S' then
              raise FND_API.G_EXC_ERROR;
            end if;

            l_inflated_salary := rec_budget_personnel.percent_charged/100 * l_inflated_salary;

l_pers_cost_sharing_amt := rec_budget_personnel.cost_sharing_percent/100 * l_inflated_salary_ov; -- Bug 2702314

            l_inflated_salary_ov := rec_budget_personnel.percent_charged/100 * l_inflated_salary_ov;
            if l_apply_rate_flag_oh = 'N' then
              l_rate_class_id_oh_d := null;
              l_rate_type_id_oh_d := null;
            else
              l_rate_class_id_oh_d := l_rate_class_id_oh;
              l_rate_type_id_oh_d := l_rate_type_id_oh;
            end if;
            if l_apply_rate_flag_eb = 'N' then
              l_rate_class_id_eb_d := null;
              l_rate_type_id_eb_d := null;
            else
              l_rate_class_id_eb_d := l_rate_class_id_eb;
              l_rate_type_id_eb_d := l_rate_type_id_eb;
            end if;

           /* PERSONNEL: the reason why we are calculating cal_oh_eb twice  is because of multiple combinations of apply rate
             flag for eb and oh. we always need to calculate with setup rates(1st time). Second time we need based on
             apply rate flag. Cost share amt is calculed internally based on the cost share percentage unlike for NON-PERSONNEL*/

            IGW_OVERHEAD_CAL.calc_oh_eb (p_proposal_id
			,p_version_id
			,l_inflated_salary_ov
			,rec_budget_personnel.start_date
			,rec_budget_personnel.end_date
                        ,l_oh_value
                        ,l_oh_value_ov
			,l_eb_value
			,l_eb_value_ov
			,l_activity_type_code
			,rec_budget_details.location_code
			,l_rate_class_id_oh_d
			,l_rate_type_id_oh_d
			,l_rate_class_id_eb_d
			,l_rate_type_id_eb_d
  			,l_return_status
  			,l_msg_data
			,l_msg_count);
            if l_return_status <> 'S' then
              raise FND_API.G_EXC_ERROR;
            end if;

            IGW_OVERHEAD_CAL.calc_oh_eb (p_proposal_id
			,p_version_id
			,l_inflated_salary_ov
			,rec_budget_personnel.start_date
			,rec_budget_personnel.end_date
                        ,l_oh_value_d
                        ,l_oh_value_ov_d
			,l_eb_value_d
			,l_eb_value_ov_d
			,l_activity_type_code
			,rec_budget_details.location_code
			,l_rate_class_id_oh
			,l_rate_type_id_oh
			,l_rate_class_id_eb
			,l_rate_type_id_eb
  			,l_return_status
  			,l_msg_data
			,l_msg_count);
            if l_return_status <> 'S' then
              raise FND_API.G_EXC_ERROR;
            end if;


            if l_apply_rate_flag_oh = 'N' then
              l_oh_value_ov := 0;
            end if;
            if l_apply_rate_flag_eb = 'N' then
              l_eb_value_ov := 0;
	    end if;

            if l_apply_oh_setup_rates = 'Y' then
              /* underrecovery is setup calculation amt minus actual calculation */
              update igw_budget_personnel_details
              set	   salary_requested = l_inflated_salary_ov
                           ,cost_sharing_amount = l_pers_cost_sharing_amt       -- Bug 2702314
              --,	   cost_sharing_amount = rec_budget_personnel.cost_sharing_percent/100 *
--		  					l_inflated_salary_ov
              ,      underrecovery_amount = nvl(l_oh_value_d - l_oh_value_ov,0)
	      where  budget_personnel_detail_id =  rec_budget_personnel.budget_personnel_detail_id;
            else
              update igw_budget_personnel_details
              set	   salary_requested = l_inflated_salary_ov
                          ,cost_sharing_amount = l_pers_cost_sharing_amt -- Bug 2702314
              --,	   cost_sharing_amount = rec_budget_personnel.cost_sharing_percent/100 *
--		  					l_inflated_salary_ov
              ,      underrecovery_amount = nvl(l_oh_value_d - l_oh_value_ov_usr,0)
	      where  budget_personnel_detail_id =  rec_budget_personnel.budget_personnel_detail_id;
            end if;


            delete from igw_budget_personnel_cal_amts
	    where  budget_personnel_detail_id = rec_budget_personnel.budget_personnel_detail_id;


            if check_exp_assignment(rec_budget_details.expenditure_type
				 ,rec_budget_details.expenditure_category_flag
				 ,l_rate_class_id_oh
				 ,l_rate_type_id_oh)	then
              if l_apply_oh_setup_rates = 'Y' then
      	        IGW_GENERATE_PERIODS.create_budget_personnel_amts (
	    	     		 	    rec_budget_personnel.budget_personnel_detail_id
					    ,l_rate_class_id_oh
					    ,l_rate_type_id_oh
					    ,l_apply_rate_flag_oh
					    ,nvl(l_oh_value_ov,0)
					    ,rec_budget_personnel.cost_sharing_percent/100 * nvl(l_oh_value_ov,0));
              else
      	        IGW_GENERATE_PERIODS.create_budget_personnel_amts (
	    	     		 	    rec_budget_personnel.budget_personnel_detail_id
					    ,l_rate_class_id_oh
					    ,l_rate_type_id_oh
					    ,l_apply_rate_flag_oh
					    ,nvl(l_oh_value_ov_usr,0)
					    ,rec_budget_personnel.cost_sharing_percent/100 * nvl(l_oh_value_ov_usr,0));
              end if;
            end if;

            if check_exp_assignment(rec_budget_details.expenditure_type
				 ,rec_budget_details.expenditure_category_flag
				 ,l_rate_class_id_eb
				 ,l_rate_type_id_eb)	then
              if l_apply_eb_setup_rates = 'Y' then
      	        IGW_GENERATE_PERIODS.create_budget_personnel_amts (
	    	     		 	    rec_budget_personnel.budget_personnel_detail_id
					    ,l_rate_class_id_eb
					    ,l_rate_type_id_eb
					    ,l_apply_rate_flag_eb
					    ,nvl(l_eb_value_ov,0)
					    ,rec_budget_personnel.cost_sharing_percent/100 * nvl(l_eb_value,0));
              else
      	        IGW_GENERATE_PERIODS.create_budget_personnel_amts (
	    	     		 	    rec_budget_personnel.budget_personnel_detail_id
					    ,l_rate_class_id_eb
					    ,l_rate_type_id_eb
					    ,l_apply_rate_flag_eb
					    ,nvl(l_eb_value_ov_usr,0)
					    ,rec_budget_personnel.cost_sharing_percent/100 * nvl(l_eb_value_ov_usr,0));
              end if;
            end if;

          END LOOP; --rec_budget_personnel


          delete from igw_budget_details_cal_amts
          where  line_item_id = rec_budget_details.line_item_id;

   		select 	sum(nvl(ppc.calculated_cost,0))
		,	sum(nvl(ppc.calculated_cost_sharing,0))
                into	l_calculated_cost_oh
		,	l_cost_sharing_oh
      		from	igw_budget_personnel_cal_amts   ppc
      		,      	igw_budget_personnel_details    ppd
		where  	ppd.line_item_id = rec_budget_details.line_item_id
		and 	ppd.budget_personnel_detail_id = ppc.budget_personnel_detail_id
		and	ppc.rate_class_id = l_rate_class_id_oh
		and	ppc.rate_type_id = l_rate_type_id_oh;

   		select 	sum(nvl(ppc.calculated_cost,0))
		,	sum(nvl(ppc.calculated_cost_sharing,0))
                into	l_calculated_cost_eb
		,	l_cost_sharing_eb
      		from	igw_budget_personnel_cal_amts   ppc
      		,      	igw_budget_personnel_details    ppd
		where  	ppd.line_item_id = rec_budget_details.line_item_id
		and 	ppd.budget_personnel_detail_id = ppc.budget_personnel_detail_id
		and	ppc.rate_class_id = l_rate_class_id_eb
		and	ppc.rate_type_id = l_rate_type_id_eb;

          if check_exp_assignment(rec_budget_details.expenditure_type
				 ,rec_budget_details.expenditure_category_flag
				 ,l_rate_class_id_oh
				 ,l_rate_type_id_oh)	then
  	    IGW_GENERATE_PERIODS.create_budget_detail_amts(rec_budget_details.proposal_id
							,rec_budget_details.version_id
							,rec_budget_details.budget_period_id
							,rec_budget_details.line_item_id
							,l_rate_class_id_oh
							,l_rate_type_id_oh
							,'Y'
							,nvl(l_calculated_cost_oh,0)
							,nvl(l_cost_sharing_oh,0));
          end if;

          if check_exp_assignment(rec_budget_details.expenditure_type
				 ,rec_budget_details.expenditure_category_flag
				 ,l_rate_class_id_eb
				 ,l_rate_type_id_eb)	then
	    IGW_GENERATE_PERIODS.create_budget_detail_amts(rec_budget_details.proposal_id
							,rec_budget_details.version_id
							,rec_budget_details.budget_period_id
							,rec_budget_details.line_item_id
							,l_rate_class_id_eb
							,l_rate_type_id_eb
							,'Y'
							,nvl(l_calculated_cost_eb,0)
							,nvl(l_cost_sharing_eb,0));
          end if;

          --changed as recalculate should insert and delete overhead and eb amounts

	  select  sum(nvl(ppd.salary_requested,0))
	  , 	  sum(nvl(ppd.cost_sharing_amount,0))
	  ,	  sum(nvl(ppd.underrecovery_amount,0))
          into	  l_salary_requested_upd
	  ,	  l_cost_sharing_amount_upd
	  ,	  l_underrecovery_amount_upd
	  from    igw_budget_personnel_details  ppd
	  where   ppd.line_item_id = rec_budget_details.line_item_id;

          update igw_budget_details  pdb
          set    line_item_cost = nvl(l_salary_requested_upd,0)
	  ,	 cost_sharing_amount = nvl(l_cost_sharing_amount_upd,0)
          ,	 underrecovery_amount = nvl(l_underrecovery_amount_upd,0)
          where  pdb.line_item_id = rec_budget_details.line_item_id;

        end if;    --rec_budget_details.personnel_attached_flag
      end LOOP; --rec_budget_details


        select 	nvl(sum(line_item_cost),0)
	, 	nvl(sum(cost_sharing_amount),0)
	, 	nvl(sum(underrecovery_amount),0)
        into	l_direct_cost1
	,	l_cost_share1
	,	l_underrecovery
        from	igw_budget_details
        where   proposal_id = p_proposal_id
        and	version_id = p_version_id
	and	budget_period_id = rec_budget_periods.budget_period_id;

        select 	nvl(sum(calculated_cost_sharing),0)
	, 	nvl(sum(calculated_cost),0)
        into	l_cost_share2
	,	l_indirect_cost
  	from 	igw_budget_details_cal_amts pc
        where   proposal_id = p_proposal_id
        and	version_id = p_version_id
	and	budget_period_id = rec_budget_periods.budget_period_id
        and	pc.rate_class_id = (	select  pr.rate_class_id
					from 	igw_rate_classes  pr
					where 	pc.rate_class_id = pr.rate_class_id
					and	pr.rate_class_type = 'O');
        select 	nvl(sum(calculated_cost_sharing),0)
	, 	nvl(sum(calculated_cost),0)
        into	l_cost_share3
	,	l_direct_cost2
  	from 	igw_budget_details_cal_amts pc
        where   proposal_id = p_proposal_id
        and	version_id = p_version_id
	and	budget_period_id = rec_budget_periods.budget_period_id
        and	pc.rate_class_id = (	select  pr.rate_class_id
					from 	igw_rate_classes  pr
					where 	pc.rate_class_id = pr.rate_class_id
					and	pr.rate_class_type = 'E');

        update 	igw_budget_periods
	set	total_cost = (l_direct_cost1+l_direct_cost2+l_indirect_cost)
	,	total_direct_cost = (l_direct_cost1+l_direct_cost2)
	,	total_indirect_cost = l_indirect_cost
	,	cost_sharing_amount = (l_cost_share1+l_cost_share2+l_cost_share3)
	,	underrecovery_amount = l_underrecovery
        where   proposal_id = p_proposal_id
        and	version_id = p_version_id
	and	budget_period_id = rec_budget_periods.budget_period_id;

    end LOOP; --rec_budget_periods
  elsif  l_enter_budget_at_period_level = 'Y' then
    for rec_budget_periods in c_budget_periods
    LOOP
      update igw_budget_periods
      set    total_cost = nvl(rec_budget_periods.total_direct_cost,0) + nvl(rec_budget_periods.total_indirect_Cost,0)
      where  proposal_id = p_proposal_id
      and    version_id = p_version_id
      and    budget_period_id = rec_budget_periods.budget_period_id;
    END LOOP;   --rec_budget_period and l_enter_budget_at_period_level = 'Y'

   end if;  --l_enter_budget_at_period_level = 'N'


      	select 	nvl(sum(total_cost),0)
	,	nvl(sum(total_direct_cost),0)
	,	nvl(sum(total_indirect_cost),0)
	,	nvl(sum(cost_sharing_amount),0)
	,	nvl(sum(underrecovery_amount),0)
	--,	nvl(sum(total_cost_limit),0)
	into 	l_total_cost
	,	l_total_direct_cost
	,	l_total_indirect_cost
	,	l_cost_sharing_amt
	,	l_underrecovery_amount
	--,	l_total_cost_limit
 	from	igw_budget_periods
	where	proposal_id = p_proposal_id
	and	version_id = p_version_id;


        update 	igw_budgets
	set	total_cost = l_total_cost
	,	total_direct_cost = l_total_direct_cost
	,	total_indirect_cost = l_total_indirect_cost
	,	cost_sharing_amount = l_cost_sharing_amt
	,	underrecovery_amount = l_underrecovery_amount
	--,	total_cost_limit = l_total_cost_limit
	where	proposal_id = p_proposal_id
	and	version_id = p_version_id;

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
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'RECALCULATE_BUDGET');
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
  end  recalculate_budget;


END IGW_BUDGET_OPERATIONS;

/
