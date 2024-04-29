--------------------------------------------------------
--  DDL for Package Body IGW_GENERATE_PERIODS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_GENERATE_PERIODS" as
-- $Header: igwbugpb.pls 115.29 2002/11/19 23:47:56 vmedikon ship $
  PROCEDURE create_budget_detail(
    l_proposal_id 		IGW_budget_periods.proposal_id%TYPE
    ,l_version_id  		IGW_budget_periods.version_id%TYPE
    ,l_budget_period_id		IGW_budget_periods.budget_period_id%TYPE
    ,l_line_item_id	 	IGW_budget_details.line_item_id%TYPE
    ,l_expenditure_type		IGW_budget_details.expenditure_type%TYPE
    ,l_budget_category_code     IGW_budget_details.budget_category_code%TYPE
    ,l_expenditure_category_flag	IGW_budget_details.expenditure_category_flag%TYPE
    ,l_line_item_description	IGW_budget_details.line_item_description%TYPE
    ,l_based_on_line_item	IGW_budget_details.based_on_line_item%TYPE
    ,l_line_item_cost		NUMBER
    ,l_cost_sharing_amount	NUMBER
    ,l_underrecovery_amount	NUMBER
    ,l_apply_inflation_flag	VARCHAR2
    ,l_budget_justification	IGW_budget_details.budget_justification%TYPE
    ,l_location_code		VARCHAR2) is
  BEGIN
    insert into IGW_budget_details(
				proposal_id
				,version_id
				,budget_period_id
				,line_item_id
				,expenditure_type
				,budget_category_code
				,expenditure_category_flag
				,line_item_description
				,based_on_line_item
				,line_item_cost
				,cost_sharing_amount
				,underrecovery_amount
				,apply_inflation_flag
				,budget_justification
				,location_code
				,record_version_number
				,last_update_date
				,last_updated_by
				,creation_date
				,created_by
				,last_update_login )
			values (
				l_proposal_id
				,l_version_id
				,l_budget_period_id
				,igw_budget_details_s.nextval
				,l_expenditure_type
				,l_budget_category_code
				,l_expenditure_category_flag
				,l_line_item_description
				,l_based_on_line_item
				,l_line_item_cost
				,l_cost_sharing_amount
				,l_underrecovery_amount
				,l_apply_inflation_flag
				,l_budget_justification
				,l_location_code
				,1
				,sysdate
				,fnd_global.user_id
				,sysdate
				,fnd_global.user_id
				,fnd_global.login_id);

  END create_budget_detail;

  PROCEDURE create_budget_personnel_amts (
    l_budget_personnel_detail_id  NUMBER
    ,l_rate_class_id  		  NUMBER
    ,l_rate_type_id		  NUMBER
    ,l_apply_rate_flag	 	  VARCHAR2
    ,l_calculated_cost		  NUMBER
    ,l_calculated_cost_sharing	  NUMBER) IS
  BEGIN
    insert into igw_budget_personnel_cal_amts (
				budget_personnel_detail_id
				,rate_class_id
				,rate_type_id
				,apply_rate_flag
				,calculated_cost
				,calculated_cost_sharing
				,record_version_number
				,last_update_date
				,last_updated_by
				,creation_date
				,created_by
				,last_update_login)
			values(
				l_budget_personnel_detail_id
				,l_rate_class_id
				,l_rate_type_id
				,l_apply_rate_flag
				,l_calculated_cost
				,l_calculated_cost_sharing
				,1
				,sysdate
				,fnd_global.user_id
				,sysdate
				,fnd_global.user_id
				,fnd_global.login_id);
  END create_budget_personnel_amts;

  PROCEDURE create_budget_detail_amts (p_proposal_id			NUMBER
					,p_version_id			NUMBER
					,p_budget_period_id		NUMBER
					,p_line_item_id			NUMBER
					,p_rate_class_id		NUMBER
					,p_rate_type_id			NUMBER
					,p_apply_rate_flag		VARCHAR2
					,p_calculated_cost		NUMBER
					,p_calculated_cost_sharing	NUMBER) is
  BEGIN
   insert into igw_budget_details_cal_amts (
				proposal_id
				,version_id
				,budget_period_id
				,line_item_id
				,rate_class_id
				,rate_type_id
				,apply_rate_flag
				,calculated_cost
				,calculated_cost_sharing
				,record_version_number
				,last_update_date
				,last_updated_by
				,creation_date
				,created_by
				,last_update_login)
			values	(
				p_proposal_id
				,p_version_id
				,p_budget_period_id
				,p_line_item_id
				,p_rate_class_id
				,p_rate_type_id
				,p_apply_rate_flag
				,p_calculated_cost
				,p_calculated_cost_sharing
				,1
				,sysdate
				,fnd_global.user_id
				,sysdate
				,fnd_global.user_id
				,fnd_global.login_id);
  END;

--------------------------------------------------------------------------------------------
  /* Lines are not generated for expenditure types/categories with
  personnel attached flag if the periods are not exactly 12 month
  periods. The reason being that if a personnel in the first budget line
  is for 12 months, and if the last period is only 10 months(say), how do
  we allocate that person?
  */

  PROCEDURE generate_lines    (	p_proposal_id		NUMBER
				,p_version_id	 	NUMBER
				,p_budget_period_id	NUMBER
				,p_activity_type_code	VARCHAR2
				,p_oh_rate_class_id	NUMBER
				,x_return_status    OUT NOCOPY	VARCHAR2
				,x_msg_data         OUT NOCOPY	VARCHAR2
				,x_msg_count	    OUT NOCOPY NUMBER) is

  cursor c_budget_version is
  select apply_inflation_setup_rates
  ,      apply_eb_setup_rates
  ,      apply_oh_setup_rates
  ,      enter_budget_at_period_level
  from   igw_budgets
  where  proposal_id = p_proposal_id
  and    version_id = p_version_id;


  cursor c_budget_periods is
  select count(*)
  from	 igw_budget_periods
  where  proposal_id = p_proposal_id
  and	 version_id = p_version_id;


  cursor c_budget_details is
  select pbd.proposal_id
  ,      pbd.version_id
  , 	 pbd.budget_period_id
  ,	 pbd.line_item_id
  ,	 pbd.expenditure_type
  ,	 pbd.budget_category_code
  ,	 pbd.expenditure_category_flag
  , 	 pbd.line_item_description
  ,	 pbd.line_item_cost
  , 	 pbd.cost_sharing_amount
  ,	 pbd.underrecovery_amount
  ,	 pbd.apply_inflation_flag
  ,	 pbd.budget_justification
  ,	 pbd.location_code
  ,	 et.personnel_attached_flag
  from	 igw_budget_details   	pbd
  ,	 igw_budget_expenditures_v et
  where  pbd.expenditure_type = et.budget_expenditure
  and	 pbd.expenditure_category_flag = et.expenditure_category_flag
  and	 pbd.proposal_id = p_proposal_id
  and	 pbd.budget_period_id = p_budget_period_id
  and	 pbd.version_id = p_version_id;

  l_line_item_id	NUMBER(15);

  cursor c_budget_personnel is
  select budget_personnel_detail_id
  ,	 line_item_id
  ,	 person_id
  ,	 party_id
  ,	 start_date
  ,	 end_date
  ,	 period_type_code
  ,	 appointment_type_code
  ,	 salary_requested
  ,	 percent_charged
  ,	 percent_effort
  ,	 cost_sharing_percent
  ,	 underrecovery_amount
  from	 igw_budget_personnel_details
  where	 line_item_id = l_line_item_id;

  l_dummy_personnel_id		NUMBER;
  l_salary_requested		NUMBER;
  l_cost_sharing_amount		NUMBER;
  l_no_of_periods		NUMBER(10);
  l_base_amount			NUMBER;
  l_input_amount	 	NUMBER;
  l_calculated_cost_share	NUMBER;
  l_calculated_cost_share_ov	NUMBER;
  l_calculated_percent		NUMBER;
  l_budget_period_id		NUMBER(10);
  l_rate_class_id_oh		NUMBER(15);
  l_rate_type_id_oh		NUMBER(15);
  l_rate_class_id_eb		NUMBER(15);
  l_rate_type_id_eb		NUMBER(15);
  l_rate_class_id_oh_d		NUMBER(15);
  l_rate_type_id_oh_d		NUMBER(15);
  l_rate_class_id_eb_d		NUMBER(15);
  l_rate_type_id_eb_d		NUMBER(15);
  l_rate_class_id_inf		NUMBER(15);
  l_rate_type_id_inf		NUMBER(15);
  l_budget_end_date		DATE;
  l_budget_start_date		DATE;
  l_max_budget_end_date		DATE;
  l_max_budget_start_date	DATE;
  l_personnel_start_date	DATE;
  l_personnel_end_date		DATE;
  l_dummy_value			VARCHAR2(1);
  l_oh_value			NUMBER;
  l_eb_value			NUMBER;
  l_oh_value_ov			NUMBER;
  l_eb_value_ov			NUMBER;
  l_calculation_base		NUMBER;
  l_effective_date		DATE;
  l_sum_cost			NUMBER;
  l_sum_cost_share		NUMBER;
  l_inflated_salary		NUMBER;
  l_inflated_salary_ov		NUMBER;
  l_line_item_seq		NUMBER;
  l_direct_cost1		NUMBER;
  l_direct_cost2		NUMBER;
  l_cost_share1			NUMBER;
  l_cost_share2			NUMBER;
  l_cost_share3			NUMBER;
  l_underrecovery		NUMBER;
  l_indirect_cost		NUMBER;
  l_total_cost			NUMBER;
  l_total_direct_cost		NUMBER;
  l_total_indirect_cost		NUMBER;
  l_cost_sharing_amt		NUMBER;
  l_underrecovery_amount	NUMBER;
  l_total_cost_limit		NUMBER;
  l_appointment_type_code	VARCHAR2(30);
  l_apply_rate_flag_oh		VARCHAR2(1);
  l_apply_rate_flag_eb		VARCHAR2(1);
  l_value                       VARCHAR2(10);
  l_apply_inflation_setup_rates VARCHAR2(1);
  l_apply_eb_setup_rates        VARCHAR2(1);
  l_apply_oh_setup_rates        VARCHAR2(1);
  l_enter_budget_at_period_level VARCHAR2(1);
  l_return_status		VARCHAR2(1);
  l_msg_data 			VARCHAR2(200);
  l_msg_count			NUMBER(10);

  BEGIN
    fnd_msg_pub.initialize;
    begin
      select '1'
      into   l_value
      from   igw_budget_details  pbd
      where  pbd.proposal_id = p_proposal_id
      and    pbd.version_id = p_version_id
      and    pbd.budget_period_id <> 1
      and    rownum < 2;

      if  l_value is not null then
        fnd_message.set_name('IGW', 'IGW_CANNOT_GENERATE_PERIODS');
        fnd_msg_pub.add;
        l_return_status := 'E';
        RAISE FND_API.G_EXC_ERROR;
      end if;
    exception
      when no_data_found then null;
    end;

    open c_budget_version;
    fetch c_budget_version into  l_apply_inflation_setup_rates
                                ,l_apply_eb_setup_rates
				,l_apply_oh_setup_rates
				,l_enter_budget_at_period_level;
    close c_budget_version;

    open c_budget_periods;
    fetch c_budget_periods into l_no_of_periods;
    close c_budget_periods;
  for rec_budget_details in c_budget_details
    LOOP
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
      BEGIN
        select 	apply_rate_flag
	into   	l_apply_rate_flag_oh
	from   	igw_budget_details_cal_amts
	where  	line_item_id = rec_budget_details.line_item_id;
      EXCEPTION
        when no_data_found then null;
      End;
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
	l_input_amount := rec_budget_details.line_item_cost;
        l_budget_period_id := rec_budget_details.budget_period_id;

      for i in 1 .. (l_no_of_periods-1)
      LOOP

	l_budget_period_id := l_budget_period_id + 1;

        begin
          select start_date, end_date
 	  into	 l_budget_start_date
	  ,	 l_budget_end_date
	  from	 igw_budget_periods
	  where	 proposal_id = p_proposal_id
	  and	 version_id = p_version_id
	  and	 budget_period_id = l_budget_period_id;
        exception
          when no_data_found then
            l_msg_data := 'IGW_PERIOD_NOT_CONSECUTIVE';
            l_return_status := 'E';
            fnd_message.set_name('IGW', 'IGW_PERIOD_NOT_CONSECUTIVE');
            fnd_msg_pub.add;
            RAISE FND_API.G_EXC_ERROR;
        end;


        if i = (l_no_of_periods - 1) then
          begin
            select max(end_date)
	    into 	 l_budget_end_date
	    from 	 igw_budget_periods
  	    where	 proposal_id = p_proposal_id
  	    and	 version_id = p_version_id;
          exception
            when no_data_found then
              l_msg_data := 'IGW_PERIOD_NOT_CONSECUTIVE';
              l_return_status := 'E';
              fnd_message.set_name('IGW', 'IGW_PERIOD_NOT_CONSECUTIVE');
              fnd_msg_pub.add;
              RAISE FND_API.G_EXC_ERROR;
          end;
        end if;


        if rec_budget_details.apply_inflation_flag = 'Y' then

          IGW_OVERHEAD_CAL.calc_inflation(p_proposal_id
					,p_version_id
					,l_input_amount
		  			,l_budget_start_date
		  			,l_budget_end_date
		  			,l_base_amount
		  			,p_activity_type_code
		  			,rec_budget_details.location_code
			   		,l_rate_class_id_inf
			   		,l_rate_type_id_inf
		  			,l_return_status
		  			,l_msg_data
					,l_msg_count);

            if l_return_status <> 'S' then
              raise FND_API.G_EXC_ERROR;
            end if;
        else
          l_base_amount := rec_budget_details.line_item_cost;
        end if;

        /* NON_PERSONNEL: the reason why we are calculating cal_oh twice  is because, once to calculate cost share amt
           for line and second time to calculate cost share for Overhead line. */

	/* if oh_setup_rates is not applied then don't calculate oh */
	if l_apply_oh_setup_rates = 'N' then
	  l_oh_value := 0;
	  l_oh_value_ov := 0;
	else
          IGW_OVERHEAD_CAL.calc_oh(p_proposal_id
			,p_version_id
			,l_base_amount
			,l_budget_start_date
			,l_budget_end_date
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
	end if;

        /* if oh_setup_rates is not applied then don't calculate oh */
	if l_apply_oh_setup_rates = 'N' then
	  l_calculated_cost_share := 0;
	  l_calculated_cost_share_ov := 0;
	else
          if l_apply_rate_flag_oh = 'N' then
            l_oh_value_ov := 0;
          elsif l_apply_rate_flag_oh = 'Y' then
            IGW_OVERHEAD_CAL.calc_oh(p_proposal_id
			,p_version_id
			,rec_budget_details.cost_sharing_amount
			,l_budget_start_date
			,l_budget_end_date
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
        end if;

          create_budget_detail (
				rec_budget_details.proposal_id
				,rec_budget_details.version_id
				,l_budget_period_id
				,l_line_item_id
				,rec_budget_details.expenditure_type
				,rec_budget_details.budget_category_code
				,rec_budget_details.expenditure_category_flag
				,rec_budget_details.line_item_description
				,rec_budget_details.line_item_id
				,l_base_amount
				,rec_budget_details.cost_sharing_amount
				,(l_oh_value - l_oh_value_ov)
				,rec_budget_details.apply_inflation_flag
				,rec_budget_details.budget_justification
				,rec_budget_details.location_code);

          if l_rate_class_id_oh is not null and l_rate_type_id_oh is not null then
            insert into igw_budget_details_cal_amts (
				proposal_id
				,version_id
				,budget_period_id
				,line_item_id
				,rate_class_id
				,rate_type_id
				,apply_rate_flag
				,calculated_cost
				,calculated_cost_sharing
				,last_update_date
				,last_updated_by
				,creation_date
				,created_by
				,last_update_login)
			values	(
				rec_budget_details.proposal_id
				,rec_budget_details.version_id
				,l_budget_period_id
				,igw_budget_details_s.currval
				,l_rate_class_id_oh
				,l_rate_type_id_oh
				,l_apply_rate_flag_oh
				,nvl(l_oh_value_ov,0)
				,nvl(l_calculated_cost_share_ov,0)
				,sysdate
				,fnd_global.user_id
				,sysdate
				,fnd_global.user_id
				,fnd_global.login_id);
          end if;
          l_input_amount := l_base_amount;
      END LOOP;

    elsif rec_budget_details.personnel_attached_flag = 'Y' then
      IGW_OVERHEAD_CAL.get_rate_id(rec_budget_details.expenditure_type
				  ,rec_budget_details.expenditure_category_flag
				  ,'E'
				  ,l_rate_class_id_eb
				  ,l_rate_type_id_eb
				  ,l_return_status
				  , l_msg_data);

      if l_return_status <> 'S' then
        raise FND_API.G_EXC_ERROR;
      end if;

      select     max(end_date), max(start_date)
      into 	 l_max_budget_end_date, l_max_budget_start_date
      from 	 igw_budget_periods
      where	 proposal_id = p_proposal_id
      and	 version_id = p_version_id;

      l_line_item_id := rec_budget_details.line_item_id;
      l_budget_period_id := p_budget_period_id;

      BEGIN
        select 	'1'
        into	l_dummy_value
        from	igw_budget_periods
        where	((end_date-start_date) < 364 or (end_date-start_date) > 365)
        --and 	start_date <> l_max_budget_start_date
        and	 proposal_id = p_proposal_id
         and	 version_id = p_version_id
        and	rownum <2;
      EXCEPTION
        when no_data_found then
        null;
      END;

      for i in 1 .. (l_no_of_periods-1)
      LOOP
	l_budget_period_id := l_budget_period_id + 1;
        begin
          select start_date, end_date
          into	 l_budget_start_date
	  ,	 l_budget_end_date
  	  from	 igw_budget_periods
  	  where	 proposal_id = p_proposal_id
	  and	 version_id = p_version_id
	  and	 budget_period_id = l_budget_period_id;
        exception
          when no_data_found then
            l_msg_data := 'IGW_PERIOD_NOT_CONSECUTIVE';
            l_return_status := 'E';
            fnd_message.set_name('IGW', 'IGW_PERIOD_NOT_CONSECUTIVE');
            fnd_msg_pub.add;
            RAISE FND_API.G_EXC_ERROR;
        end;

        if i = (l_no_of_periods - 1) then
          l_budget_end_date := l_max_budget_end_date;
        end if;


          create_budget_detail (
				rec_budget_details.proposal_id
				,rec_budget_details.version_id
				,l_budget_period_id
				,l_line_item_id
				,rec_budget_details.expenditure_type
				,rec_budget_details.budget_category_code
				,rec_budget_details.expenditure_category_flag
				,rec_budget_details.line_item_description
				,rec_budget_details.line_item_id
				,0
				,0
				,rec_budget_details.underrecovery_amount
				,rec_budget_details.apply_inflation_flag
				,rec_budget_details.budget_justification
				,rec_budget_details.location_code);

          if l_rate_class_id_oh is not null and l_rate_type_id_oh is not null then
            insert into igw_budget_details_cal_amts (
				proposal_id
				,version_id
				,budget_period_id
				,line_item_id
				,rate_class_id
				,rate_type_id
				,apply_rate_flag
				,calculated_cost
				,calculated_cost_sharing
				,last_update_date
				,last_updated_by
				,creation_date
				,created_by
				,last_update_login)
			values	(
				rec_budget_details.proposal_id
				,rec_budget_details.version_id
				,l_budget_period_id
				,igw_budget_details_s.currval
				,l_rate_class_id_oh
				,l_rate_type_id_oh
				,l_apply_rate_flag_oh
				,0
				,0
				,sysdate
				,fnd_global.user_id
				,sysdate
				,fnd_global.user_id
				,fnd_global.login_id);
          end if;

          if l_rate_class_id_eb is not null and l_rate_type_id_eb is not null then
            insert into igw_budget_details_cal_amts (
				proposal_id
				,version_id
				,budget_period_id
				,line_item_id
				,rate_class_id
				,rate_type_id
				,apply_rate_flag
				,calculated_cost
				,calculated_cost_sharing
				,last_update_date
				,last_updated_by
				,creation_date
				,created_by
				,last_update_login)
			values	(
				rec_budget_details.proposal_id
				,rec_budget_details.version_id
				,l_budget_period_id
				,igw_budget_details_s.currval
				,l_rate_class_id_eb
				,l_rate_type_id_eb
				,l_apply_rate_flag_eb
				,0
				,0
				,sysdate
				,fnd_global.user_id
				,sysdate
				,fnd_global.user_id
				,fnd_global.login_id);
        end if;

        if l_dummy_value is null then
          for rec_budget_personnel in c_budget_personnel
          LOOP
	    BEGIN
              select pca.apply_rate_flag
	      into   l_apply_rate_flag_oh
	      from   igw_budget_personnel_cal_amts  pca
	      ,	     igw_budget_personnel_details   pbd
	      where  pbd.budget_personnel_detail_id =                                                                                                            rec_budget_personnel.budget_personnel_detail_id
	      and    pca.budget_personnel_detail_id = pbd.budget_personnel_detail_id
              and    pca.rate_class_id = (select  pr.rate_class_id
					from 	igw_rate_classes  pr
					where 	pca.rate_class_id = pr.rate_class_id
					and	pr.rate_class_type = 'O');
            EXCEPTION
              when no_data_found then null;
            End;

	    BEGIN
              select pca.apply_rate_flag
	      into   l_apply_rate_flag_eb
	      from   igw_budget_personnel_cal_amts  pca
	      ,	     igw_budget_personnel_details   pbd
	      where  pbd.budget_personnel_detail_id =                                                                                                                 rec_budget_personnel.budget_personnel_detail_id
	      and    pca.budget_personnel_detail_id = pbd.budget_personnel_detail_id
              and    pca.rate_class_id = (select  pr.rate_class_id
					from 	igw_rate_classes  pr
					where 	pca.rate_class_id = pr.rate_class_id
					and	pr.rate_class_type = 'E');
            EXCEPTION
              when no_data_found then null;
            End;
            l_personnel_start_date:= add_months(rec_budget_personnel.start_date, 12*i);

            if i = (l_no_of_periods - 1) then
              if add_months(rec_budget_personnel.end_date, 12*i) > l_budget_end_date then
                l_personnel_end_date := l_budget_end_date;
              else
                l_personnel_end_date := add_months(rec_budget_personnel.end_date, 12*i);
              end if;
            else
              l_personnel_end_date := add_months(rec_budget_personnel.end_date, 12*i);
            end if;


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
			,l_personnel_start_date
			,l_personnel_end_date
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

           /* if oh_setup_rates is not applied then don't calculate oh */
	   if l_apply_oh_setup_rates = 'N' then
	    l_oh_value := 0;
	    l_oh_value_ov := 0;
	   end if;

           /* if eb_setup_rates is not applied then don't calculate eb */
	   if l_apply_eb_setup_rates = 'N' then
	    l_eb_value := 0;
	    l_eb_value_ov := 0;
	   end if;

           /* No need to calculate eb and oh if setup rates flags are equal to N */
           if l_apply_oh_setup_rates <> 'N' and l_apply_eb_setup_rates <> 'N'  then
  	     IGW_OVERHEAD_CAL.calc_oh_eb (p_proposal_id
			,p_version_id
			,l_inflated_salary
			,l_personnel_start_date
			,l_personnel_end_date
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
	   end if;

           /* No need to calculate eb and oh if setup rates flags are equal to N */
	   /* Recalculate budget is being called at the end. Hence all the amounts will be sunk after this operation */

            if l_apply_oh_setup_rates <> 'N' and l_apply_eb_setup_rates <> 'N'  then
              IGW_OVERHEAD_CAL.calc_oh_eb (p_proposal_id
			,p_version_id
			,l_inflated_salary
			,l_personnel_start_date
			,l_personnel_end_date
                        ,l_oh_value
                        ,l_oh_value_ov
			,l_eb_value
			,l_eb_value_ov
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
            end if;

            if l_apply_rate_flag_oh = 'N' then
              l_oh_value_ov := 0;
            end if;
            if l_apply_rate_flag_eb = 'N' then
              l_eb_value_ov := 0;
	    end if;

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
				,last_update_date
				,last_updated_by
				,creation_date
				,created_by
				,last_update_login)
			values (
				igw_budget_personnel_s.nextval
				,rec_budget_details.proposal_id
				,rec_budget_details.version_id
				,l_budget_period_id
				,igw_budget_details_s.currval
				,rec_budget_personnel.person_id
				,rec_budget_personnel.party_id
				,l_personnel_start_date
				,l_personnel_end_date
				,rec_budget_personnel.period_type_code
				,rec_budget_personnel.appointment_type_code
				,l_inflated_salary_ov
				,rec_budget_personnel.percent_charged
				,rec_budget_personnel.percent_effort
				,rec_budget_personnel.cost_sharing_percent
			        ,rec_budget_personnel.cost_sharing_percent/100 *l_inflated_salary_ov
				,l_oh_value_ov - l_oh_value
				,sysdate
				,fnd_global.user_id
				,sysdate
				,fnd_global.user_id
				,fnd_global.login_id);

            select  igw_budget_personnel_s.currval into l_dummy_personnel_id from dual;
            if l_rate_class_id_oh is not null and l_rate_type_id_oh is not null then
	      create_budget_personnel_amts (
	    	     l_dummy_personnel_id
		    ,l_rate_class_id_oh
		    ,l_rate_type_id_oh
		    ,l_apply_rate_flag_oh
		    ,l_oh_value_ov
		    ,rec_budget_personnel.cost_sharing_percent/100 * l_oh_value_ov);
            end if;

            if l_rate_class_id_eb is not null and l_rate_type_id_eb is not null then
  	      create_budget_personnel_amts (
	    	     l_dummy_personnel_id
		    ,l_rate_class_id_eb
		    ,l_rate_type_id_eb
		    ,l_apply_rate_flag_eb
		    ,l_eb_value_ov
		    ,rec_budget_personnel.cost_sharing_percent/100 * l_eb_value_ov);
            end if;
          END LOOP;  --for rec_personnel_budget
        end if;
      select 	igw_budget_details_s.currval
      into	l_line_item_seq
      from  	dual;


     update igw_budget_details_cal_amts pdc
      set    pdc.calculated_cost =
   		(select nvl(sum(ppc.calculated_cost),0)
      		from   igw_budget_personnel_cal_amts       ppc
      		,	     igw_budget_personnel_details  ppd
      		,	     igw_budget_details	    pd
      		where  pd.line_item_id = ppd.line_item_id
      		and    ppd.budget_personnel_detail_id =ppc.budget_personnel_detail_id
      		and    pd.proposal_id = p_proposal_id
      		and    pd.version_id = p_version_id
      		and    pd.budget_period_id = l_budget_period_id
      		and    pd.line_item_id = l_line_item_seq
      		and    ppc.rate_class_id = pdc.rate_class_id
      		and    ppc.rate_type_id = pdc.rate_type_id)
      ,   pdc.calculated_cost_sharing =
      		(select nvl(sum(ppc.calculated_cost_sharing),0)
      		from   igw_budget_personnel_cal_amts       ppc
      		,	     igw_budget_personnel_details  ppd
      		,	     igw_budget_details	    pd
      		where  pd.line_item_id = ppd.line_item_id
      		and    ppd.budget_personnel_detail_id = ppc.budget_personnel_detail_id
      		and    pd.proposal_id = p_proposal_id
      		and    pd.version_id = p_version_id
      		and    pd.budget_period_id = l_budget_period_id
      		and    pd.line_item_id = l_line_item_seq
      		and    ppc.rate_class_id = pdc.rate_class_id
      		and    ppc.rate_type_id = pdc.rate_type_id)
      where  pdc.line_item_id = l_line_item_seq;

      update igw_budget_details  pdb
      set    line_item_cost =
		(select nvl(sum(salary_requested),0)
		from	igw_budget_personnel_details  ppd
		where	ppd.line_item_id = l_line_item_seq)
      ,	     cost_sharing_amount =
		(select nvl(sum(cost_sharing_amount),0)
		from	igw_budget_personnel_details  ppd
		where	ppd.line_item_id = l_line_item_seq)
      where  pdb.line_item_id = l_line_item_seq;


        END LOOP; --for periods
      end if;

    END LOOP;   --for rec_budget_detail

      for i in 1 .. (l_no_of_periods-1)
      LOOP
        select 	nvl(sum(line_item_cost),0)
	, 	nvl(sum(cost_sharing_amount),0)
	, 	nvl(sum(underrecovery_amount),0)
        into	l_direct_cost1
	,	l_cost_share1
	,	l_underrecovery
        from	igw_budget_details
        where   proposal_id = p_proposal_id
        and	version_id = p_version_id
	and	budget_period_id = i+1;

        select 	nvl(sum(calculated_cost_sharing),0)
	, 	nvl(sum(calculated_cost),0)
        into	l_cost_share2
	,	l_indirect_cost
  	from 	igw_budget_details_cal_amts pc
        where   proposal_id = p_proposal_id
        and	version_id = p_version_id
	and	budget_period_id = i+1
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
	and	budget_period_id = i+1
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
	and	budget_period_id = i+1;

      END LOOP;

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

	IGW_BUDGET_OPERATIONS.recalculate_budget (
                                p_proposal_id         => p_proposal_id
				,p_version_id         => p_version_id
				,p_activity_type_code => p_activity_type_code
				,p_oh_rate_class_id   => p_oh_rate_class_id
				,x_return_status      => x_return_status
				,x_msg_data           => x_msg_data
				,x_msg_count          => x_msg_count);

    x_return_status := 'S';

    /* Persons are not projected if periods are of not equal length. Reason
       being, if a person works for 3 months in a period, and if the next period
       length is of only 2 months, how do we project that person? Same logic
       applies to apply to later periods for expenditure type/category
       involving persons */

    if l_dummy_value is not null then
              l_msg_data := 'IGW_BUDGET_PERIOD_NOT_EQUAL';
              l_return_status := 'S';
              fnd_message.set_name('IGW', 'IGW_BUDGET_PERIOD_NOT_EQUAL');
              fnd_msg_pub.add;
              --raised the error volutarily to get the message count
              RAISE FND_API.G_EXC_ERROR;
    end if;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      x_return_status := l_return_status;
      x_msg_data := l_msg_data;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
    when others then
      x_return_status := 'U';
      x_msg_data :=  SQLCODE||' '||SQLERRM;
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'GENERATE_LINES');
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
  END generate_lines;
------------------------------------------------------------------------------------------------

  PROCEDURE apply_future_periods(p_proposal_id		NUMBER
				,p_version_id	 	NUMBER
				,p_budget_period_id	NUMBER
				,p_line_item_id		NUMBER
				,p_activity_type_code	VARCHAR2
				,p_oh_rate_class_id	NUMBER
				,x_return_status    OUT NOCOPY	VARCHAR2
				,x_msg_data         OUT NOCOPY	VARCHAR2
				,x_msg_count	    OUT NOCOPY NUMBER) is

  cursor c_budget_periods is
  select count(*)
  from	 igw_budget_periods
  where  proposal_id = p_proposal_id
  and	 version_id = p_version_id
  and	 budget_period_id > p_budget_period_id;

  cursor c_budget_details is
  select pbd.proposal_id
  ,      pbd.version_id
  ,	 pbd.expenditure_type
  ,	 pbd.budget_category_code
  ,	 pbd.expenditure_category_flag
  ,	 pbd.line_item_id
  , 	 pbd.line_item_description
  ,	 pbd.line_item_cost
  , 	 pbd.cost_sharing_amount
  ,	 pbd.underrecovery_amount
  ,	 pbd.apply_inflation_flag
  ,	 pbd.budget_justification
  ,	 pbd.location_code
  ,	 et.personnel_attached_flag
  from	 igw_budget_details   	pbd
  ,	 igw_budget_expenditures_v et
  where  pbd.expenditure_type = et.budget_expenditure
  and	 pbd.expenditure_category_flag = et.expenditure_category_flag
  and	 pbd.line_item_id = p_line_item_id;


  l_line_item_id	NUMBER(15);

  cursor c_budget_personnel is
  select budget_personnel_detail_id
  ,	 line_item_id
  ,	 person_id
  ,	 party_id
  ,	 start_date
  ,	 end_date
  ,	 period_type_code
  ,	 appointment_type_code
  ,	 salary_requested
  ,	 percent_charged
  ,	 percent_effort
  ,	 cost_sharing_percent
  ,	 underrecovery_amount
  from	 igw_budget_personnel_details
  where	 line_item_id = l_line_item_id;

  l_dummy_personnel_id		NUMBER;
  l_no_of_periods		NUMBER(10);
  l_input_amount		NUMBER;
  l_base_amount			NUMBER;
  l_oh_value			NUMBER;
  l_eb_value			NUMBER;
  l_oh_value_ov			NUMBER;
  l_eb_value_ov			NUMBER;
  l_budget_start_date		DATE;
  l_budget_end_date		DATE;
  l_max_budget_end_date		DATE;
  l_max_budget_start_date	DATE;
  l_personnel_start_date	DATE;
  l_personnel_end_date		DATE;
  l_effective_date		DATE;
  l_dummy_value			VARCHAR2(1);
  l_budget_period_id		NUMBER(10);
  l_rate_class_id_oh		NUMBER(15);
  l_rate_type_id_oh		NUMBER(15);
  l_rate_class_id_eb		NUMBER(15);
  l_rate_type_id_eb		NUMBER(15);
  l_rate_class_id_oh_d		NUMBER(15);
  l_rate_type_id_oh_d		NUMBER(15);
  l_rate_class_id_eb_d		NUMBER(15);
  l_rate_type_id_eb_d		NUMBER(15);
  l_rate_class_id_inf		NUMBER(15);
  l_calculated_percent		NUMBER;
  l_rate_type_id_inf		NUMBER(15);
  l_dummy_based_on		VARCHAR2(10);
  l_dummy_line_item_cost	NUMBER;
  l_apply_rate_flag_oh		VARCHAR2(1);
  l_apply_rate_flag_eb		VARCHAR2(1);
  l_inflated_salary		NUMBER;
  l_inflated_salary_ov		NUMBER;
  l_line_item_seq		NUMBER;
  l_direct_cost1		NUMBER;
  l_direct_cost2		NUMBER;
  l_cost_share1			NUMBER;
  l_cost_share2			NUMBER;
  l_cost_share3			NUMBER;
  l_underrecovery		NUMBER;
  l_indirect_cost		NUMBER;
  l_total_cost			NUMBER;
  l_total_direct_cost		NUMBER;
  l_total_indirect_cost		NUMBER;
  l_cost_sharing_amt		NUMBER;
  l_underrecovery_amount	NUMBER;
  l_calculation_base		NUMBER;
  l_total_cost_limit		NUMBER;
  l_calculated_cost_share	NUMBER;
  l_calculated_cost_share_ov	NUMBER;
  l_appointment_type_code	VARCHAR2(30);
  l_return_status		VARCHAR2(1);
  l_msg_data 			VARCHAR2(200);
  l_msg_count			NUMBER(10);
  BEGIN
    fnd_msg_pub.initialize;
    open c_budget_periods;
    fetch c_budget_periods into l_no_of_periods;
    close c_budget_periods;

    for rec_budget_details in c_budget_details
    LOOP
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
          when no_data_found then null;
        End;

        BEGIN
         select distinct based_on_line_item
         into   l_dummy_based_on
         from   igw_budget_details
         where  based_on_line_item = rec_budget_details.line_item_id;
       EXCEPTION
         when no_data_found then null;
       End;


          if l_dummy_based_on is not null then
            delete from igw_budget_details_cal_amts
            where  line_item_id IN (select line_item_id
 				    from  igw_budget_details pd
				    where pd.based_on_line_item = l_dummy_based_on);

            delete from igw_budget_details
            where  based_on_line_item = l_dummy_based_on;
          end if;

        l_input_amount := rec_budget_details.line_item_cost;
        for i in (p_budget_period_id+1) .. (p_budget_period_id+l_no_of_periods)
        LOOP
          begin
            select  start_date, end_date
            into    l_budget_start_date
	    ,	    l_budget_end_date
	    from    igw_budget_periods
  	    where   proposal_id = p_proposal_id
	    and	    version_id = p_version_id
	    and	    budget_period_id = i;
          exception
            when no_data_found then
              l_msg_data := 'IGW_PERIOD_NOT_CONSECUTIVE';
              l_return_status := 'E';
              fnd_message.set_name('IGW', 'IGW_PERIOD_NOT_CONSECUTIVE');
              fnd_msg_pub.add;
              RAISE FND_API.G_EXC_ERROR;
          end;



          if  rec_budget_details.apply_inflation_flag = 'Y' then

            IGW_OVERHEAD_CAL.calc_inflation(p_proposal_id
					,p_version_id
					,l_input_amount
		  			,l_budget_start_date
		  			,l_budget_end_date
		  			,l_base_amount
		  			,p_activity_type_code
		  			,rec_budget_details.location_code
			   		,l_rate_class_id_inf
			   		,l_rate_type_id_inf
		  			,l_return_status
		  			,l_msg_data
					,l_msg_count);

              if l_return_status <> 'S' then
                raise FND_API.G_EXC_ERROR;
              end if;
          else
            l_base_amount := rec_budget_details.line_item_cost;
          end if;

          l_input_amount := l_base_amount;

            IGW_OVERHEAD_CAL.calc_oh(p_proposal_id
			,p_version_id
			,l_base_amount
			,l_budget_start_date
			,l_budget_end_date
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

          elsif l_apply_rate_flag_oh = 'Y' then

            IGW_OVERHEAD_CAL.calc_oh(p_proposal_id
			,p_version_id
			,rec_budget_details.cost_sharing_amount
			,l_budget_start_date
			,l_budget_end_date
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

            create_budget_detail (
				rec_budget_details.proposal_id
				,rec_budget_details.version_id
				,i
				,l_line_item_id
				,rec_budget_details.expenditure_type
				,rec_budget_details.budget_category_code
				,rec_budget_details.expenditure_category_flag
				,rec_budget_details.line_item_description
				,rec_budget_details.line_item_id
				,l_base_amount
				,rec_budget_details.cost_sharing_amount
				,(l_oh_value - l_oh_value_ov)
				,rec_budget_details.apply_inflation_flag
				,rec_budget_details.budget_justification
				,rec_budget_details.location_code);




	    if l_rate_class_id_oh is not null and l_rate_type_id_oh is not null then
              insert into igw_budget_details_cal_amts (
				proposal_id
				,version_id
				,budget_period_id
				,line_item_id
				,rate_class_id
				,rate_type_id
				,apply_rate_flag
				,calculated_cost
				,calculated_cost_sharing
				,last_update_date
				,last_updated_by
				,creation_date
				,created_by
				,last_update_login)
			values	(
				rec_budget_details.proposal_id
				,rec_budget_details.version_id
				,i
				,igw_budget_details_s.currval
				,l_rate_class_id_oh
				,l_rate_type_id_oh
				,l_apply_rate_flag_oh
				,l_oh_value
				,l_calculated_cost_share
				,sysdate
				,fnd_global.user_id
				,sysdate
				,fnd_global.user_id
				,fnd_global.login_id);

            end if;
        END LOOP;
      elsif rec_budget_details.personnel_attached_flag = 'Y' then
        IGW_OVERHEAD_CAL.get_rate_id(rec_budget_details.expenditure_type
					,rec_budget_details.expenditure_category_flag
					,'E'
		,l_rate_class_id_eb,l_rate_type_id_eb,l_return_status, l_msg_data);

        if l_return_status <> 'S' then
          raise FND_API.G_EXC_ERROR;
        end if;
        l_input_amount := rec_budget_details.line_item_cost;

        select   max(end_date), max(start_date)
        into 	 l_max_budget_end_date, l_max_budget_start_date
        from 	 igw_budget_periods
        where	 proposal_id = p_proposal_id
        and	 version_id = p_version_id;

        l_line_item_id := rec_budget_details.line_item_id;
        l_budget_period_id := p_budget_period_id;

      BEGIN
        select 	'1'
        into	l_dummy_value
        from	igw_budget_periods
        where	((end_date-start_date) < 364 or (end_date-start_date) > 365)
        --and 	start_date <> l_max_budget_start_date
        and	 proposal_id = p_proposal_id
         and	 version_id = p_version_id
        and	rownum <2;
      EXCEPTION
        when no_data_found then
        null;
      END;
      BEGIN
       select distinct based_on_line_item
       into   l_dummy_based_on
       from   igw_budget_details
       where  based_on_line_item = rec_budget_details.line_item_id;

     EXCEPTION
       when no_data_found then null;
     End;

     if l_dummy_based_on is not null then

       delete from igw_budget_personnel_cal_amts
       where budget_personnel_detail_id IN (select budget_personnel_detail_id
						from  igw_budget_details pd
						,     igw_budget_personnel_details ppd
						where pd.line_item_id = ppd.line_item_id
						and   pd.based_on_line_item = l_dummy_based_on);

       delete from igw_budget_personnel_details
       where  line_item_id IN (select line_item_id
 				    from  igw_budget_details pd
				    where pd.based_on_line_item = l_dummy_based_on);

       delete from igw_budget_details_cal_amts
       where  line_item_id IN (select line_item_id
 	     		       from  igw_budget_details pd
			       where pd.based_on_line_item = l_dummy_based_on);

       delete from igw_budget_details
       where  based_on_line_item = l_dummy_based_on;
     end if;

        for i in (p_budget_period_id+1) .. (p_budget_period_id+l_no_of_periods)
        LOOP
          begin
            select  start_date, end_date
            into    l_budget_start_date
	    ,	    l_budget_end_date
	    from    igw_budget_periods
	    where   proposal_id = p_proposal_id
	    and	    version_id = p_version_id
	    and	    budget_period_id = i;
          exception
            when no_data_found then
              l_msg_data := 'IGW_PERIOD_NOT_CONSECUTIVE';
              l_return_status := 'E';
              fnd_message.set_name('IGW', 'IGW_PERIOD_NOT_CONSECUTIVE');
              fnd_msg_pub.add;
              RAISE FND_API.G_EXC_ERROR;
          end;


          create_budget_detail (
				rec_budget_details.proposal_id
				,rec_budget_details.version_id
				,i
				,l_line_item_id
				,rec_budget_details.expenditure_type
				,rec_budget_details.budget_category_code
				,rec_budget_details.expenditure_category_flag
				,rec_budget_details.line_item_description
				,rec_budget_details.line_item_id
				,0
				,0
				,rec_budget_details.underrecovery_amount
				,rec_budget_details.apply_inflation_flag
				,rec_budget_details.budget_justification
				,rec_budget_details.location_code);

          if l_rate_class_id_oh is not null and l_rate_type_id_oh is not null then
            insert into igw_budget_details_cal_amts (
				proposal_id
				,version_id
				,budget_period_id
				,line_item_id
				,rate_class_id
				,rate_type_id
				,apply_rate_flag
				,calculated_cost
				,calculated_cost_sharing
				,last_update_date
				,last_updated_by
				,creation_date
				,created_by
				,last_update_login)
			values	(
				rec_budget_details.proposal_id
				,rec_budget_details.version_id
				,i
				,igw_budget_details_s.currval
				,l_rate_class_id_oh
				,l_rate_type_id_oh
				,'Y'
				,0
				,0
				,sysdate
				,fnd_global.user_id
				,sysdate
				,fnd_global.user_id
				,fnd_global.login_id);
          end if;

	  if l_rate_class_id_eb is not null and l_rate_type_id_eb is not null then
            insert into igw_budget_details_cal_amts (
				proposal_id
				,version_id
				,budget_period_id
				,line_item_id
				,rate_class_id
				,rate_type_id
				,apply_rate_flag
				,calculated_cost
				,calculated_cost_sharing
				,last_update_date
				,last_updated_by
				,creation_date
				,created_by
				,last_update_login)
			values	(
				rec_budget_details.proposal_id
				,rec_budget_details.version_id
				,i
				,igw_budget_details_s.currval
				,l_rate_class_id_eb
				,l_rate_type_id_eb
				,'Y'
				,0
				,0
				,sysdate
				,fnd_global.user_id
				,sysdate
				,fnd_global.user_id
				,fnd_global.login_id);
         end if;


        if l_dummy_value is null then
          for rec_budget_personnel in c_budget_personnel
          LOOP

	  BEGIN
            select pca.apply_rate_flag
	    into   l_apply_rate_flag_oh
	    from   igw_budget_personnel_cal_amts  pca
	    ,	   igw_budget_personnel_details   pbd
	      where  pbd.budget_personnel_detail_id = rec_budget_personnel.budget_personnel_detail_id
	    and	   pca.budget_personnel_detail_id = pbd.budget_personnel_detail_id
            and	   pca.rate_class_id = (	select  pr.rate_class_id
					from 	igw_rate_classes  pr
					where 	pca.rate_class_id = pr.rate_class_id
					and	pr.rate_class_type = 'O');
          EXCEPTION
            when no_data_found then null;
          End;

	  BEGIN
            select pca.apply_rate_flag
	    into   l_apply_rate_flag_eb
	    from   igw_budget_personnel_cal_amts  pca
	    ,	   igw_budget_personnel_details   pbd
	      where  pbd.budget_personnel_detail_id = rec_budget_personnel.budget_personnel_detail_id
	    and	   pca.budget_personnel_detail_id = pbd.budget_personnel_detail_id
            and	   pca.rate_class_id = (	select  pr.rate_class_id
					from 	igw_rate_classes  pr
					where 	pca.rate_class_id = pr.rate_class_id
					and	pr.rate_class_type = 'E');
          EXCEPTION
            when no_data_found then null;
          End;
            l_personnel_start_date:= add_months(rec_budget_personnel.start_date,
								12*(i-p_budget_period_id));

            if i = (p_budget_period_id+l_no_of_periods) then
              if add_months(rec_budget_personnel.end_date, 12*(i-p_budget_period_id)) > l_budget_end_date then
                l_personnel_end_date := l_budget_end_date;
              else
                l_personnel_end_date := add_months(rec_budget_personnel.end_date, 12*(i-p_budget_period_id));
              end if;
            else
              l_personnel_end_date := add_months(rec_budget_personnel.end_date,
								12*(i-p_budget_period_id));
            end if;

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
			,l_personnel_start_date
			,l_personnel_end_date
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
			,l_inflated_salary
			,l_personnel_start_date
			,l_personnel_end_date
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
				,last_update_date
				,last_updated_by
				,creation_date
				,created_by
				,last_update_login)
			values (
				igw_budget_personnel_s.nextval
				,rec_budget_details.proposal_id
				,rec_budget_details.version_id
				,i
				,igw_budget_details_s.currval
				,rec_budget_personnel.person_id
				,rec_budget_personnel.party_id
				,l_personnel_start_date
				,l_personnel_end_date
				,rec_budget_personnel.period_type_code
				,rec_budget_personnel.appointment_type_code
				,l_inflated_salary
				,rec_budget_personnel.percent_charged
				,rec_budget_personnel.percent_effort
				,rec_budget_personnel.cost_sharing_percent
				,rec_budget_personnel.cost_sharing_percent/100 * l_inflated_salary
				,rec_budget_personnel.underrecovery_amount
				,sysdate
				,fnd_global.user_id
				,sysdate
				,fnd_global.user_id
				,fnd_global.login_id);

            select  igw_budget_personnel_s.currval into l_dummy_personnel_id from dual;
            if l_rate_class_id_oh is not null and l_rate_type_id_oh is not null then
	        create_budget_personnel_amts (
	    	     l_dummy_personnel_id
		    ,l_rate_class_id_oh
		    ,l_rate_type_id_oh
		    ,l_apply_rate_flag_oh
		    ,l_oh_value
		    ,rec_budget_personnel.cost_sharing_percent/100 * l_oh_value);
            end if;

            if l_rate_class_id_eb is not null and l_rate_type_id_eb is not null then
      	        create_budget_personnel_amts (
	    	     l_dummy_personnel_id
		    ,l_rate_class_id_eb
		    ,l_rate_type_id_eb
		    ,l_apply_rate_flag_eb
		    ,l_eb_value
		    ,rec_budget_personnel.cost_sharing_percent/100 * l_eb_value);
            end if;

          END LOOP;  --for rec_personnel_budget
        end if;

      select 	igw_budget_details_s.currval
      into	l_line_item_seq
      from  	dual;

      update igw_budget_details_cal_amts pdc
      set    pdc.calculated_cost =
   		(select nvl(sum(ppc.calculated_cost),0)
      		from   igw_budget_personnel_cal_amts       ppc
      		,	     igw_budget_personnel_details  ppd
      		,	     igw_budget_details	    pd
      		where  pd.line_item_id = ppd.line_item_id
      		and    ppd.budget_personnel_detail_id =ppc.budget_personnel_detail_id
      		and    pd.proposal_id = p_proposal_id
      		and    pd.version_id = p_version_id
      		and    pd.budget_period_id = i
      		and    pd.line_item_id = l_line_item_seq
      		and    ppc.rate_class_id = pdc.rate_class_id
      		and    ppc.rate_type_id = pdc.rate_type_id)
      ,   pdc.calculated_cost_sharing =
      		(select nvl(sum(ppc.calculated_cost_sharing),0)
      		from   igw_budget_personnel_cal_amts       ppc
      		,	     igw_budget_personnel_details  ppd
      		,	     igw_budget_details	    pd
      		where  pd.line_item_id = ppd.line_item_id
      		and    ppd.budget_personnel_detail_id = ppc.budget_personnel_detail_id
      		and    pd.proposal_id = p_proposal_id
      		and    pd.version_id = p_version_id
      		and    pd.budget_period_id = i
      		and    pd.line_item_id = l_line_item_seq
      		and    ppc.rate_class_id = pdc.rate_class_id
      		and    ppc.rate_type_id = pdc.rate_type_id)
      where  pdc.line_item_id = l_line_item_seq;


      update igw_budget_details  pdb
      set    line_item_cost =
		(select nvl(sum(salary_requested),0)
		from	igw_budget_personnel_details  ppd
		where	ppd.line_item_id = l_line_item_seq)
      ,	     cost_sharing_amount =
		(select nvl(sum(cost_sharing_amount),0)
		from	igw_budget_personnel_details  ppd
		where	ppd.line_item_id = l_line_item_seq)
      where  pdb.line_item_id = l_line_item_seq;


        END LOOP; --for periods
      end if;

    END LOOP;   --for rec_budget_detail

      for i in (p_budget_period_id+1) .. (p_budget_period_id+l_no_of_periods)
      LOOP
        select 	nvl(sum(line_item_cost),0)
	, 	nvl(sum(cost_sharing_amount),0)
	, 	nvl(sum(underrecovery_amount),0)
        into	l_direct_cost1
	,	l_cost_share1
	,	l_underrecovery
        from	igw_budget_details
        where   proposal_id = p_proposal_id
        and	version_id = p_version_id
	and	budget_period_id = i;

        select 	nvl(sum(calculated_cost_sharing),0)
	, 	nvl(sum(calculated_cost),0)
        into	l_cost_share2
	,	l_indirect_cost
  	from 	igw_budget_details_cal_amts pc
        where   proposal_id = p_proposal_id
        and	version_id = p_version_id
	and	budget_period_id = i
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
	and	budget_period_id = i
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
	and	budget_period_id = i;

      END LOOP;

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

	IGW_BUDGET_OPERATIONS.recalculate_budget (
                                p_proposal_id         => p_proposal_id
				,p_version_id         => p_version_id
				,p_activity_type_code => p_activity_type_code
				,p_oh_rate_class_id   => p_oh_rate_class_id
				,x_return_status      => x_return_status
				,x_msg_data           => x_msg_data
				,x_msg_count          => x_msg_count);

    /* Persons are not projected if periods are of not equal length. Reason
       being, if a person works for 3 months in a period, and if the next period
       length is of only 2 months, how do we project that person? Same logic
       applies to apply to later periods for expenditure type/category
       involving persons */

    if l_dummy_value is not null then
              l_msg_data := 'IGW_BUDGET_PERIOD_NOT_EQUAL';
              l_return_status := 'S';
              fnd_message.set_name('IGW', 'IGW_BUDGET_PERIOD_NOT_EQUAL');
              fnd_msg_pub.add;
              --raised the error volutarily to get the message count
              RAISE FND_API.G_EXC_ERROR;
    end if;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      x_return_status := l_return_status;
      x_msg_data := l_msg_data;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
    when others then
      x_return_status := 'U';
      x_msg_data :=  SQLCODE||' '||SQLERRM;
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'APPLY_FUTURE_PERIODS');
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
  END apply_future_periods;
----------------------------------------------------------------------------------------------

  PROCEDURE sync_to_cost_limit( p_proposal_id			NUMBER
				,p_version_id	 		NUMBER
				,p_budget_period_id		NUMBER
				,p_line_item_id			NUMBER
				,p_activity_type_code		VARCHAR2
				,p_line_item_cost		NUMBER
				,p_total_cost_limit		NUMBER
				,x_line_item_cost   	   OUT NOCOPY	NUMBER
                                ,x_calculated_cost  	   OUT NOCOPY	NUMBER
				,x_return_status           OUT NOCOPY	VARCHAR2
				,x_msg_data                OUT NOCOPY	VARCHAR2
				,x_msg_count	           OUT NOCOPY  NUMBER) is

  cursor c_budget_periods is
  select total_cost
  from	 igw_budget_periods
  where  proposal_id = p_proposal_id
  and	 version_id = p_version_id
  and 	 budget_period_id = p_budget_period_id;

  l_line_item_cost		NUMBER;
  l_total_cost			NUMBER;
  l_calculated_cost		NUMBER;
  l_diff_amount			NUMBER;
  l_oh_percent			NUMBER;
  l_return_status		VARCHAR2(1);
  l_msg_data 			VARCHAR2(200);
  l_msg_count			NUMBER(10);

  insufficient_amount		EXCEPTION;

  BEGIN
    fnd_msg_pub.initialize;
    open c_budget_periods;
    fetch c_budget_periods into l_total_cost;
    close c_budget_periods;

    begin
      select calculated_cost
      into   l_calculated_cost
      from   igw_budget_details_cal_amts
      where  line_item_id = p_line_item_id;
    exception
      when no_data_found then null;
    end;

    l_diff_amount :=  nvl(p_total_cost_limit,0) + nvl(p_line_item_cost,0) +
				 nvl(l_calculated_cost,0)  - nvl(l_total_cost,0);

    --dbms_output.put_line('l_diff_amount'||l_diff_amount);
    --dbms_output.put_line('(p_total_cost_limit'||p_total_cost_limit);
    --dbms_output.put_line('p_line_item_cost'||p_line_item_cost);
    --dbms_output.put_line('l_calculated_cost'||l_calculated_cost);
    --dbms_output.put_line('l_total_cost'||l_total_cost);

    if l_diff_amount < 0 then
      raise insufficient_amount;
      null;
    elsif l_diff_amount >= 0 then
      if p_line_item_cost = 0 then
        l_oh_percent := 0;
      else
        l_oh_percent := nvl(l_calculated_cost,0)/p_line_item_cost;
      end if;
      --dbms_output.put_line('l_oh_percent'||l_oh_percent);
      x_line_item_cost := l_diff_amount/(1+l_oh_percent);
      x_calculated_cost:= l_diff_amount - x_line_item_cost;
    end if;
    x_return_status := 'S';

   EXCEPTION
    when FND_API.G_EXC_ERROR then
      x_return_status := l_return_status;
      x_msg_data := l_msg_data;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);

    when insufficient_amount then
      x_return_status := 'E';
      x_msg_data := 'IGW_INSUFFICIENT_AMOUNT';
      fnd_message.set_name('IGW', 'IGW_INSUFFICIENT_AMOUNT');
    --dbms_output.put_line('FIRING  THE FOLLOWING'||'IGW_INSUFFICIENT_AMOUNT');
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
			p_data => x_msg_data);
    when others then
      x_return_status := 'U';
      x_msg_data :=  SQLCODE||' '||SQLERRM;
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'SYNC_TO_COST_LIMIT');
      fnd_msg_pub.count_and_get(p_count => x_msg_count,	p_data => x_msg_data);

  END sync_to_cost_limit;
------------------------------------------------------------------------------------------

  PROCEDURE sync_to_cost_limit_wrap(
				p_line_item_id			NUMBER
				,p_line_item_cost		NUMBER
				,x_return_status           OUT NOCOPY	VARCHAR2
				,x_msg_data                OUT NOCOPY	VARCHAR2
				,x_msg_count	           OUT NOCOPY  NUMBER) is

    l_proposal_id            NUMBER;
    l_version_id             NUMBER;
    l_budget_period_id       NUMBER;

    l_activity_type_code     VARCHAR2(30);
    l_expenditure_type       VARCHAR2(30);
    l_period_cost_limit      NUMBER;
    l_new_line_item_cost     NUMBER;
    l_new_calculated_cost    NUMBER;

    l_expenditure_category_flag   VARCHAR2(1);
    l_personnel_attached_flag     VARCHAR2(1);


    l_return_status	     VARCHAR2(1);
    l_msg_data 		     VARCHAR2(200);
    l_msg_count		     NUMBER(10);
    l_msg_index_out          NUMBER;

    cursor c_budget is
    select proposal_id
    ,      version_id
    ,      budget_period_id
    ,      expenditure_category_flag
    ,      expenditure_type
    from   igw_budget_details
    where  line_item_id = p_line_item_id;
  Begin
    x_return_status := 'S';

    --fnd_msg_pub.initialize;

    open c_budget;
    fetch c_budget into l_proposal_id, l_version_id
      , l_budget_period_id, l_expenditure_category_flag, l_expenditure_type;
    close c_budget;


    if l_expenditure_category_flag = 'Y' then
      begin
        select personnel_attached_flag
        into 	 l_personnel_attached_flag
        from 	 igw_expenditure_categories_v
        where	 expenditure_category = l_expenditure_type;
      exception
        when no_data_found then
        null;
      end;
    elsif l_expenditure_category_flag = 'N' then
      begin
        select   personnel_attached_flag
        into 	 l_personnel_attached_flag
        from 	 igw_expenditure_categories_v
        where	 expenditure_category =  (select expenditure_category from igw_expenditure_types_v
					  where  expenditure_type = l_expenditure_type);
      exception
        when no_data_found then
        null;
      end;
    end if;

    if l_personnel_attached_flag = 'Y' then
      fnd_message.set_name('IGW', 'IGW_NO_PERSONNEL_SYNC');
      fnd_msg_pub.add;
      Raise FND_API.G_EXC_ERROR;
    end if;

    begin
      select activity_type_code
      into   l_activity_type_code
      from   igw_proposals_all
      where  proposal_id = l_proposal_id;
    exception
      when others then
        RAISE;
    end;

    begin
      select total_cost_limit
      into   l_period_cost_limit
      from   igw_budget_periods
      where  proposal_id = l_proposal_id
      and    version_id  = l_version_id
      and    budget_period_id = l_budget_period_id;
    exception
      when others then
        RAISE;
    end;


    --dbms_output.put_line('proposal_id'||l_proposal_id);
    --dbms_output.put_line('l_version_id'||l_version_id);
    --dbms_output.put_line('l_budget_period_id'||l_budget_period_id);
    --dbms_output.put_line('p_line_item_id'||p_line_item_id);
    --dbms_output.put_line('l_activity_type_code'||l_activity_type_code);
    --dbms_output.put_line('p_line_item_cost'||p_line_item_cost);
    --dbms_output.put_line('l_period_cost_limit'||l_period_cost_limit);



    igw_generate_periods.sync_to_cost_limit(
                                p_proposal_id		 => l_proposal_id
				,p_version_id	 	 => l_version_id
				,p_budget_period_id	 => l_budget_period_id
				,p_line_item_id		 => p_line_item_id
				,p_activity_type_code    => l_activity_type_code
				,p_line_item_cost	 => p_line_item_cost
				,p_total_cost_limit	 => l_period_cost_limit
				,x_line_item_cost   	 => l_new_line_item_cost
                                ,x_calculated_cost  	 => l_new_calculated_cost
				,x_return_status         => l_return_status
				,x_msg_data              => l_msg_data
				,x_msg_count	         => x_msg_count);

    --dbms_output.put_line('l_new_line_item_cost'||l_new_line_item_cost);
    --dbms_output.put_line('l_new_calculated_cost'||l_new_calculated_cost);
    --dbms_output.put_line('l_msg_data'||l_msg_data);
    --dbms_output.put_line('l_return_status'||l_return_status);
    --dbms_output.put_line('x_msg_count'||x_msg_count);

    x_return_status := l_return_status;

    If x_msg_count > 0 THEN
      If x_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => x_msg_data,
          p_msg_index_out  => l_msg_index_out );

      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;


    update igw_budget_details
    set line_item_cost = nvl(l_new_line_item_cost, line_item_cost)
    where  line_item_id = p_line_item_id;

    update igw_budget_details_cal_amts
    set calculated_cost = nvl(l_new_calculated_cost, calculated_cost)
    where  line_item_id = p_line_item_id;


    IGW_BUDGET_OPERATIONS.recalculate_budget (
                                p_proposal_id         => l_proposal_id
				,p_version_id         => l_version_id
                                ,p_budget_period_id   => l_budget_period_id
				,x_return_status      => x_return_status
				,x_msg_data           => x_msg_data
				,x_msg_count          => x_msg_count);

    --x_return_status := l_return_status;



  Exception
    when FND_API.G_EXC_ERROR then
      --x_return_status := l_return_status;
      --x_msg_data := l_msg_data;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
    when others then
      x_return_status := 'U';
      x_msg_data :=  SQLCODE||' '||SQLERRM;
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'SYNC_TO_COST_LIMIT_WRAP');
      fnd_msg_pub.count_and_get(p_count => x_msg_count,	p_data => x_msg_data);
  End;
------------------------------------------------------------------------------------------
  PROCEDURE sync_to_cost_limit_wrap_2(
				p_line_item_id			NUMBER
				,p_line_item_cost		NUMBER
				,x_return_status           OUT NOCOPY	VARCHAR2
				,x_msg_data                OUT NOCOPY	VARCHAR2
				,x_msg_count	           OUT NOCOPY  NUMBER) is


    l_line_item_cost         NUMBER;
    l_return_status	     VARCHAR2(1);
    l_msg_data 		     VARCHAR2(200);
    l_msg_count		     NUMBER(10);
    l_msg_index_out          NUMBER;

    cursor c_line_item_cost is
    select line_item_cost
    from   igw_budget_details
    where  line_item_id = p_line_item_id;

  Begin
    x_return_status := 'S';
    fnd_msg_pub.initialize;



    sync_to_cost_limit_wrap(p_line_item_id
			   ,p_line_item_cost
			   ,x_return_status
			   ,x_msg_data
			   ,x_msg_count   );

    /* There is a reason why to execute sync_to_cost_limit when p_line_item_cost is equal to 0. It is because
       when p_line_item_cost is 0, we don't know the indirect cost rate. Executing once exceeds the total cost. */
    if p_line_item_cost = 0 then
      open c_line_item_cost;
      fetch c_line_item_cost into l_line_item_cost;
      close c_line_item_cost;
      sync_to_cost_limit_wrap(p_line_item_id
			   ,l_line_item_cost
			   ,x_return_status
			   ,x_msg_data
			   ,x_msg_count   );
    end if;
  Exception
    when FND_API.G_EXC_ERROR then
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
    when others then
      x_return_status := 'U';
      x_msg_data :=  SQLCODE||' '||SQLERRM;
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, 'SYNC_TO_COST_LIMIT_WRAP_2');
      fnd_msg_pub.count_and_get(p_count => x_msg_count,	p_data => x_msg_data);
  End;


END IGW_GENERATE_PERIODS;

/
