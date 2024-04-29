--------------------------------------------------------
--  DDL for Package Body IGW_BUDGETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_BUDGETS_PVT" AS
--$Header: igwvbvsb.pls 115.35 2004/04/14 22:28:47 vmedikon ship $

procedure manage_budget_deletion
	(p_delete_level                     VARCHAR2
        ,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
        ,p_budget_period_id                 NUMBER    := null
        ,p_line_item_id                     NUMBER    := null
        ,p_budget_personnel_detail_id       NUMBER    := null
        ,x_return_status               OUT NOCOPY  VARCHAR2) IS
/* possible values of p_delete_level are  'BUDGET_VERSION', 'BUDGET_PERIOD', 'BUDGET_LINE', 'BUDGET_PERSONNEL' */
  l_api_name   varchar2(30)  := 'MANAGE_BUDGET_DELETION';
begin
  if p_delete_level = 'BUDGET_VERSION' then

    delete from igw_budget_persons
    where  proposal_id = p_proposal_id
    and    version_id = p_version_id;

    delete from igw_budget_personnel_cal_amts  pbp
    where  pbp.budget_personnel_detail_id IN (select pb.budget_personnel_detail_id
                                              from   igw_budget_personnel_details pb
                                              where  pb.proposal_id = p_proposal_id
                                              and    pb.version_id = p_version_id);


    delete from igw_budget_personnel_details
    where  proposal_id = p_proposal_id
    and    version_id = p_version_id;

    delete from igw_budget_details_cal_amts
    where  proposal_id = p_proposal_id
    and    version_id = p_version_id;

    delete from igw_budget_details
    where  proposal_id = p_proposal_id
    and    version_id = p_version_id;

    delete from igw_budget_periods
    where  proposal_id = p_proposal_id
    and    version_id = p_version_id;

    delete from igw_prop_rates
    where  proposal_id = p_proposal_id
    and    version_id = p_version_id;

  elsif p_delete_level = 'BUDGET_PERIOD' then

    delete from igw_budget_personnel_cal_amts  pbp
    where  pbp.budget_personnel_detail_id IN (select pb.budget_personnel_detail_id
                                              from   igw_budget_personnel_details pb
                                              where  pb.proposal_id = p_proposal_id
                                              and    pb.version_id = p_version_id
                                              and    pb.budget_period_id = p_budget_period_id);

    delete from igw_budget_personnel_details
    where  proposal_id = p_proposal_id
    and    version_id = p_version_id
    and    budget_period_id = p_budget_period_id;

    delete from igw_budget_details_cal_amts
    where  proposal_id = p_proposal_id
    and    version_id = p_version_id
    and    budget_period_id = p_budget_period_id;

    delete from igw_budget_details
    where  proposal_id = p_proposal_id
    and    version_id = p_version_id
    and    budget_period_id = p_budget_period_id;

  elsif  p_delete_level = 'BUDGET_LINE' then

    delete from igw_budget_personnel_cal_amts  pbp
    where  pbp.budget_personnel_detail_id IN (select pb.budget_personnel_detail_id
                                              from   igw_budget_personnel_details pb
                                              where  pb.line_item_id = p_line_item_id);

    delete from igw_budget_personnel_details
    where  line_item_id  = p_line_item_id;

    delete from igw_budget_details_cal_amts
    where  line_item_id  = p_line_item_id;

  elsif p_delete_level = 'BUDGET_PERSONNEL' then

    delete from igw_budget_personnel_cal_amts  pbp
    where  pbp.budget_personnel_detail_id = p_budget_personnel_detail_id;

  end if;
exception
  when others then
    x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;
    Fnd_Msg_Pub.Add_Exc_Msg(
      p_pkg_name       => G_package_name,
      p_procedure_name => l_api_name);
    RAISE Fnd_Api.G_Exc_Unexpected_Error;
end;
---------------------------------------------------------------------------------------

  PROCEDURE copy_budget(p_proposal_id			IN	NUMBER
  		       ,p_proposal_installment_id	IN	NUMBER
  		       ,x_return_status    		OUT NOCOPY	VARCHAR2
		       ,x_msg_data         		OUT NOCOPY	VARCHAR2
		       ,x_msg_count	    		OUT NOCOPY 	NUMBER) is

    cursor c_budget_details is
    SELECT ibc.proposal_id
    ,      ibc.budget_period_id
    ,      ibc.expenditure_type
    ,	   ibc.expenditure_category_flag
    ,      nvl(ibc.line_item_cost,0)+nvl(igw_budget_integration.get_eb_cost_ss(ibc.line_item_id),0)  direct_cost
    ,      ibc.line_item_cost
    ,      igw_budget_integration.get_oh_cost_ss(ibc.line_item_id)    indirect_cost
    ,      ibp.start_date
    ,      ibp.end_date
    FROM   igw_budgets                 ib
    ,      igw_budget_periods          ibp
    ,      igw_budget_details       ibc
    WHERE  ib.proposal_id = ibp.proposal_id
    AND    ib.version_id = ibp.version_id
    AND    ib.final_version_flag = 'Y'
    AND    ibp.proposal_id = ibc.proposal_id
    AND    ibp.version_id = ibc.version_id
    AND    ibp.budget_period_id = ibc.budget_period_id
    AND    ib.proposal_id = ibc.proposal_id
    AND    ib.version_id = ibc.version_id
    AND    ib.proposal_id = p_proposal_id;

/* commented out for cursor c_budget_Details as rounded amounts were coming up due to
   igw_budget_complete_v  */
/*
    SELECT ibc.proposal_id
    ,      ibc.budget_period_id
    ,      ibc.expenditure_type
    ,	   ibc.expenditure_category_flag
    ,      nvl(ibc.line_item_cost,0)+nvl(ibc.eb_cost,0)  direct_cost
    ,      ibc.oh_cost    indirect_cost
    ,      ibp.start_date
    ,      ibp.end_date
    FROM   igw_budgets                 ib
    ,      igw_budget_periods          ibp
    ,      igw_budget_complete_v       ibc
    WHERE  ib.proposal_id = ibp.proposal_id
    AND    ib.version_id = ibp.version_id
    AND    ib.final_version_flag = 'Y'
    AND    ibp.proposal_id = ibc.proposal_id
    AND    ibp.version_id = ibc.version_id
    AND    ibp.budget_period_id = ibc.budget_period_id
    AND    ib.proposal_id = ibc.proposal_id
    AND    ib.version_id = ibc.version_id
    AND    ib.proposal_id = p_proposal_id;
*/


    cursor c_budget_indirect_cost is
    SELECT ibc.budget_period_id
    ,      sum(igw_budget_integration.get_oh_cost_ss(ibc.line_item_id))    indirect_cost
    FROM   igw_budgets                 ib
    ,      igw_budget_periods          ibp
    ,      igw_budget_details       ibc
    WHERE  ib.proposal_id = ibp.proposal_id
    AND    ib.version_id = ibp.version_id
    AND    ib.final_version_flag = 'Y'
    AND    ibp.proposal_id = ibc.proposal_id
    AND    ibp.version_id = ibc.version_id
    AND    ibp.budget_period_id = ibc.budget_period_id
    AND    ib.proposal_id = ibc.proposal_id
    AND    ib.version_id = ibc.version_id
    AND    ib.proposal_id = p_proposal_id
    GROUP BY ibc.budget_period_id;

/* commented out for cursor c_budget_Details as rounded amounts were coming up due to
   igw_budget_complete_v  */
/*
    SELECT ibc.budget_period_id
    ,      sum(ibc.oh_cost)    indirect_cost
    FROM   igw_budgets                 ib
    ,      igw_budget_periods          ibp
    ,      igw_budget_complete_v       ibc
    WHERE  ib.proposal_id = ibp.proposal_id
    AND    ib.version_id = ibp.version_id
    AND    ib.final_version_flag = 'Y'
    AND    ibp.proposal_id = ibc.proposal_id
    AND    ibp.version_id = ibc.version_id
    AND    ibp.budget_period_id = ibc.budget_period_id
    AND    ib.proposal_id = ibc.proposal_id
    AND    ib.version_id = ibc.version_id
    AND    ib.proposal_id = p_proposal_id
    GROUP BY ibc.budget_period_id;
*/

    l_award_budget_id           NUMBER(15);
    l_award_id			NUMBER(15);
    l_project_id		NUMBER(15);
    l_task_id			NUMBER(15);
    l_version_id                NUMBER(15);
    l_period_name		VARCHAR2(30);
    l_start_date		DATE;
    l_end_date			DATE;
    l_time_phased_type_code	VARCHAR2(30);
    l_awd_start_date		DATE;
    l_awd_end_date		DATE;
    l_proj_start_date		DATE;
    l_proj_end_date		DATE;
    l_budget_start_date		DATE;
    l_budget_end_date		DATE;
    l_return_status		VARCHAR2(1);
    l_msg_data 			VARCHAR2(200);
    l_msg_count			NUMBER(10);
    x_rowid                     ROWID;
    l_entry_level_code          varchar2(30);

  BEGIN
    --fnd_msg_pub.initialize;
    x_return_status := 'S';

   --  dbms_output.put_line('--------till here 1----------');

    SELECT version_id
    INTO l_version_id
    FROM igw_budgets
    WHERE proposal_id = p_proposal_id
    AND   final_version_flag = 'Y';

 --   dbms_output.put_line('--------till here 2----------');

    select project_id, task_id
    into l_project_id, l_task_id
    from igw_project_fundings
    where proposal_installment_id = p_proposal_installment_id
    AND ROWNUM < 2;

 --   dbms_output.put_line('--------till here 3----------');

    select ia.award_id
    into l_award_id
    from igw_awards ia,
         igw_installments ii
    where ii.proposal_installment_id = p_proposal_installment_id
    and   ii.proposal_award_id = ia.proposal_award_id;

 --   dbms_output.put_line('--------till here 4----------');

     select  pbem.time_phased_type_code
     ,       pbem.entry_level_code
     into    l_time_phased_type_code
     ,       l_entry_level_code
     from    pa_projects_all        pp
     ,       pa_project_types_all   ppt
     ,       pa_budget_entry_methods   pbem
     where   pp.project_id = l_project_id
     and     pp.project_type = ppt.project_type
     and     ppt.cost_budget_entry_method_code = pbem.budget_entry_method_code;


   -- use l_budget_start_date and l_budget_end_date obtained below if time_phased_type_code = 'N'
     select   nvl(preaward_date, start_date_active), end_date_active
              into     l_awd_start_date, l_awd_end_date
              from     gms_awards_all
              where    award_id = l_award_id;

 --    dbms_output.put_line('--------till here 6----------');

              select   nvl(start_date,l_awd_start_date), nvl(completion_date,l_awd_end_date)
              into     l_proj_start_date, l_proj_end_date
              from     pa_projects_all
              where    project_id = l_project_id;

   --   dbms_output.put_line('--------till here 7----------');

              l_msg_data := 'after project date selection';

              l_budget_start_date := greatest(l_awd_start_date,l_proj_start_date);
              l_budget_end_date := least(l_awd_end_date,l_proj_end_date);

  /* -- commented by Debashis and rewritten below
  Bug 2702671 (ENTER AWARD BUDGET SCREEN: THE DEFAULT TASK NUMBER IS NOT CORRECT)
    --populate the task id if project requires task
    if l_entry_level_code in ('T','M') then
      select task_id
      into   l_task_id
      from   pa_tasks_top_v
      where  project_id = l_project_id
      and    wbs_sort_order = (select min(wbs_sort_order) from pa_tasks_top_v where project_id = l_project_id);
    elsif  l_entry_level_code = 'L' then
      select task_id
      into   l_task_id
      from   pa_tasks_lowest_v
      where  project_id = l_project_id
      and    wbs_sort_order = (select min(wbs_sort_order) from pa_tasks_lowest_v where project_id = l_project_id);
    end if;
    */
     if l_entry_level_code = 'T' then
     -- l_task_id is already known since funding is always at top task level
        null;
    elsif  l_entry_level_code = 'L' then
   --bug 3527151 no data found raising exception
     begin
      select task_id
      into   l_task_id
      from   pa_tasks_lowest_v
      where  project_id = l_project_id
      and    top_task_id = l_task_id
      and    wbs_sort_order = (select min(wbs_sort_order)
                               from pa_tasks_lowest_v
                               where project_id = l_project_id
                               and   top_task_id = l_task_id);
     exception
       when no_data_found then null;
     end;
   elsif  l_entry_level_code = 'M' then
   --bug 3527151 no data found raising exception
     begin
      select task_id
      into   l_task_id
      from   pa_tasks
      where  project_id = l_project_id
      and    (PA_TASK_UTILS.CHECK_CHILD_EXISTS(TASK_ID) = 0 or TOP_TASK_ID = task_id)
      and     top_task_id = l_task_id
      and    rownum < 2;
     exception
       when no_data_found then null;
     end;
    end if;


    for rec_budget_details in c_budget_details
    LOOP
      select igw_award_budget_s.nextval into l_award_budget_id from dual;

   if (l_time_phased_type_code IN ('G', 'P')) then
     Begin
     --dbms_output.put_line('--------till here 8----------');
     --dbms_output.put_line('start date'||greatest(rec_budget_details.start_date, l_budget_start_date));
     --dbms_output.put_line('end date'||least(rec_budget_details.end_date ,l_budget_end_date) );
     --dbms_output.put_line('l_time_phased_type_code'||l_time_phased_type_code);
       select   period_name
       into     l_period_name
       from     pa_budget_periods_v pv
       where    period_type_code = l_time_phased_type_code
       and      period_start_date >=  l_budget_start_date
       and      period_end_date <= l_budget_end_date
       and      rownum < 2;
   --    dbms_output.put_line('--------till here 9----------');
     Exception
       when no_data_found then
            Fnd_Message.SET_NAME('IGW','IGW_SS_XFER_NO_PERIOD_FOUND');
            Fnd_Message.set_token('EXPENDITURE', rec_budget_details.expenditure_type);
            Fnd_Message.set_token('START_DATE', rec_budget_details.start_date);
            Fnd_Message.set_token('END_DATE', rec_budget_details.end_date);
            Fnd_Msg_Pub.ADD;
            x_return_status := 'E';
     End;

      igw_award_budgets_tbh.insert_row(
	 p_award_budget_id              => l_award_budget_id
	,p_proposal_installment_id      => p_proposal_installment_id
	,p_budget_period_id             => rec_budget_details.budget_period_id
	,p_expenditure_type_cat         => rec_budget_details.expenditure_type
	,p_expenditure_category_flag    => rec_budget_details.expenditure_category_flag
	,p_budget_amount                => rec_budget_details.direct_cost
	,p_indirect_flag                => 'N'
	,p_project_id 	                => l_project_id
        ,p_task_id                      => l_task_id
	,p_period_name                  => l_period_name
	,p_start_date                   => rec_budget_details.start_date
	,p_end_date                     => rec_budget_details.end_date
	,p_transferred_flag		=> 'N'
        ,x_rowid                        => x_rowid
        ,x_return_status                => l_return_status);

    elsif (l_time_phased_type_code = 'R') then
    -- Bug 2702677 (ENTER AWARD BUDGET SCREEN: THE START, END DATE SHOULD DEFAULT FROM INSTALLMENT)
    -- This should only happen for time phase = R
       select start_date, end_date
       into   l_start_date, l_end_date
       from   igw_installments
       where  proposal_installment_id = p_proposal_installment_id;

   --  dbms_output.put_line('--------till here 10----------');
      igw_award_budgets_tbh.insert_row(
	 p_award_budget_id              => l_award_budget_id
	,p_proposal_installment_id      => p_proposal_installment_id
	,p_budget_period_id             => rec_budget_details.budget_period_id
	,p_expenditure_type_cat         => rec_budget_details.expenditure_type
	,p_expenditure_category_flag    => rec_budget_details.expenditure_category_flag
	,p_budget_amount                => rec_budget_details.direct_cost
	,p_indirect_flag                => 'N'
	,p_project_id 	                => l_project_id
        ,p_task_id                      => l_task_id
	,p_period_name                  => null
	,p_start_date                   => l_start_date  -- rec_budget_details.start_date
	,p_end_date                     => l_end_date  -- rec_budget_details.end_date
	,p_transferred_flag		=> 'N'
        ,x_rowid                        => x_rowid
        ,x_return_status                => l_return_status);
    elsif (l_time_phased_type_code = 'N') then
   --  dbms_output.put_line('--------till here 11----------');
      igw_award_budgets_tbh.insert_row(
	 p_award_budget_id              => l_award_budget_id
	,p_proposal_installment_id      => p_proposal_installment_id
	,p_budget_period_id             => rec_budget_details.budget_period_id
	,p_expenditure_type_cat         => rec_budget_details.expenditure_type
	,p_expenditure_category_flag    => rec_budget_details.expenditure_category_flag
	,p_budget_amount                => rec_budget_details.direct_cost
	,p_indirect_flag                => 'N'
	,p_project_id 	                => l_project_id
        ,p_task_id                      => l_task_id
	,p_period_name                  => null
	,p_start_date                   => l_budget_start_date
	,p_end_date                     => l_budget_end_date
	,p_transferred_flag		=> 'N'
        ,x_rowid                        => x_rowid
        ,x_return_status                => l_return_status);
    end if;


    END LOOP;

    for rec_budget_indirect_cost in c_budget_indirect_cost
    LOOP
       if (rec_budget_indirect_cost.indirect_cost > 0) then
            select igw_award_budget_s.nextval into l_award_budget_id from dual;

            select start_date, end_date
            into l_start_date, l_end_date
            from igw_budget_periods
            where proposal_id = p_proposal_id
            and   version_id = l_version_id
            and   budget_period_id = rec_budget_indirect_cost.budget_period_id;

             if (l_time_phased_type_code IN ('G', 'P')) then
               Begin
                  select   period_name
          	  into     l_period_name
                  from     pa_budget_periods_v
                  where    period_type_code = l_time_phased_type_code
                  and      period_start_date >=  l_budget_start_date
                  and      period_end_date <= l_budget_end_date
                  and      rownum < 2;
               Exception
      		 when no_data_found then
                 Fnd_Message.SET_NAME('IGW','IGW_SS_XFER_INVALID_PERIODNAME');    --change this message
                 Fnd_Msg_Pub.ADD;
                 x_return_status := 'E';
               End;

                 igw_award_budgets_tbh.insert_row(
	 	 	p_award_budget_id              => l_award_budget_id
			,p_proposal_installment_id      => p_proposal_installment_id
			,p_budget_period_id             => rec_budget_indirect_cost.budget_period_id
			,p_expenditure_type_cat         => null
			,p_expenditure_category_flag    => null
			,p_budget_amount                => rec_budget_indirect_cost.indirect_cost
			,p_indirect_flag                => 'Y'
			,p_project_id 	                => l_project_id
        		,p_task_id                      => l_task_id
			,p_period_name                  => l_period_name
			,p_start_date                   => l_start_date
			,p_end_date                     => l_end_date
			,p_transferred_flag		=> 'N'
        		,x_rowid                        => x_rowid
        		,x_return_status                => l_return_status);
             elsif (l_time_phased_type_code = 'R') then

               -- Bug 2702677 (ENTER AWARD BUDGET SCREEN: THE START, END DATE SHOULD DEFAULT FROM INSTALLMENT)
               -- This should only happen for time phase = R
               select start_date, end_date
               into   l_start_date, l_end_date
               from   igw_installments
               where  proposal_installment_id = p_proposal_installment_id;

                  igw_award_budgets_tbh.insert_row(
	 	 	 p_award_budget_id              => l_award_budget_id
			,p_proposal_installment_id      => p_proposal_installment_id
			,p_budget_period_id             => rec_budget_indirect_cost.budget_period_id
			,p_expenditure_type_cat         => null
			,p_expenditure_category_flag    => null
			,p_budget_amount                => rec_budget_indirect_cost.indirect_cost
			,p_indirect_flag                => 'Y'
			,p_project_id 	                => l_project_id
        		,p_task_id                      => l_task_id
			,p_period_name                  => null
			,p_start_date                   => l_start_date
			,p_end_date                     => l_end_date
			,p_transferred_flag		=> 'N'
        		,x_rowid                        => x_rowid
        		,x_return_status                => l_return_status);
               elsif (l_time_phased_type_code = 'N') then
      		igw_award_budgets_tbh.insert_row(
	 		 p_award_budget_id              => l_award_budget_id
			,p_proposal_installment_id      => p_proposal_installment_id
			,p_budget_period_id             => rec_budget_indirect_cost.budget_period_id
			,p_expenditure_type_cat         => null
			,p_expenditure_category_flag    => null
			,p_budget_amount                => rec_budget_indirect_cost.indirect_cost
			,p_indirect_flag                => 'Y'
			,p_project_id 	                => l_project_id
        		,p_task_id                      => l_task_id
			,p_period_name                  => null
			,p_start_date                   => l_budget_start_date
			,p_end_date                     => l_budget_end_date
			,p_transferred_flag		=> 'N'
        		,x_rowid                        => x_rowid
        		,x_return_status                => l_return_status);
             end if;
        end if;
       END LOOP;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      x_return_status := 'E';
      x_msg_data := l_msg_data;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
      raise;
    when others then
      x_return_status := 'U';
      x_msg_data :=  SQLCODE||' '||SQLERRM;
      --dbms_output.put_line(x_msg_data);
      fnd_msg_pub.add_exc_msg(G_package_name, 'COPY_BUDGET');
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data => x_msg_data);
      raise;
  END copy_budget;

---------------------------------------------------------------------------------------
  PROCEDURE copy_final_to_award_budget(
                         p_proposal_id			IN	NUMBER
                        ,p_proposal_installment_id	IN	NUMBER
			,x_return_status    		OUT NOCOPY	VARCHAR2
			,x_msg_data         		OUT NOCOPY	VARCHAR2
               		,x_msg_count	    		OUT NOCOPY 	NUMBER) is


  l_api_name           varchar2(30)  := 'COPY_FINAL_TO_AWARD_BUDGET';
  l_final_version      number(4);
  l_award_budget_count NUMBER(4);
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(250);

  BEGIN
    fnd_msg_pub.initialize;
    x_return_status := 'S';

    begin
   --   dbms_output.put_line('copy finaL 1');
      select version_id
      into   l_final_version
      from   igw_budgets
      where  proposal_id = p_proposal_id
      and    final_version_flag = 'Y';
    exception
      when no_data_found then
        x_return_status := Fnd_Api.G_Ret_Sts_Error;
        Fnd_Message.Set_Name('IGW','IGW_SS_BUD_NO_FINAL_VERSION');
        Fnd_Msg_Pub.Add;
        RAISE  FND_API.G_EXC_ERROR;
    end;


    begin
      select count(*)
      into l_award_budget_count
      from igw_award_budgets
      where proposal_installment_id = p_proposal_installment_id
      and transferred_flag = 'N';
    end ;
  --   dbms_output.put_line('copy finaL 1, count' || l_award_budget_count);

    if l_award_budget_count = 0 then

      if l_final_version is not null then

        copy_budget(p_proposal_id		=> p_proposal_id
        	   ,p_proposal_installment_id	=> p_proposal_installment_id
		   ,x_return_status    		=> l_return_status
		   ,x_msg_data         		=> l_msg_data
		   ,x_msg_count	    		=> l_msg_count);

	if l_return_status <> 'S' then
          x_return_status := 'E';
          RAISE  FND_API.G_EXC_ERROR;
        end if;
      end if;
    end if;

  --following commit needed as it is called before rendering a screen
  COMMIT;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := 'E';
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
     rollback;
    when others then
     x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;
     Fnd_Msg_Pub.Add_Exc_Msg(
       p_pkg_name       => G_package_name,
       p_procedure_name => l_api_name);
     fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
     rollback;
     RAISE Fnd_Api.G_Exc_Unexpected_Error;
  END;
-----------------------------------------------------------------------------------------
procedure get_rate_class_id(p_rate_class_name  IN  VARCHAR2
                            , x_rate_class_id  OUT NOCOPY NUMBER
                            , x_return_status  OUT NOCOPY VARCHAR2) is

  l_api_name   varchar2(30)  := 'GET_RATE_CLASS_ID';

begin
  select rate_class_id
  into   x_rate_class_id
  from   igw_rate_classes
  where  description = p_rate_class_name;

exception
  when no_data_found OR too_many_rows  then
    x_return_status := Fnd_Api.G_Ret_Sts_Error;
    Fnd_Message.Set_Name('IGW','IGW_SS_BUD_RATE_CLASS_INV');
    Fnd_Msg_Pub.Add;
  when others then
    x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;
    Fnd_Msg_Pub.Add_Exc_Msg(
      p_pkg_name       => G_package_name,
      p_procedure_name => l_api_name);
    RAISE Fnd_Api.G_Exc_Unexpected_Error;
end; --get_rate_class_id
------------------------------------------------------------------------------------------------

procedure check_final_version(p_proposal_id      IN  NUMBER
                              ,p_version_id       IN  NUMBER
                              , x_return_status  OUT NOCOPY VARCHAR2) is

  l_api_name                 varchar2(30)  := 'CHECK_FINAL_VERSION';
  l_final_version_flag       varchar2(1);

begin
  x_return_status := 'S';

  select final_version_flag
  into   l_final_version_flag
  from   igw_budgets
  where  proposal_id = p_proposal_id
  and    version_id <> nvl(p_version_id,0)
  and    final_version_flag = 'Y';

  if l_final_version_flag = 'Y' then
    x_return_status := Fnd_Api.G_Ret_Sts_Error;
    Fnd_Message.Set_Name('IGW','IGW_SS_BUD_DUP_FINAL_VERSION');
    Fnd_Msg_Pub.Add;
  end if;

exception
  when no_data_found then
    null;
  when others then
    x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;
    Fnd_Msg_Pub.Add_Exc_Msg(
      p_pkg_name       => G_package_name,
      p_procedure_name => l_api_name);
    RAISE Fnd_Api.G_Exc_Unexpected_Error;
end; --get_rate_class_id
---------------------------------------------------------------------------------------
procedure validate_budget_entry(p_proposal_id      IN  NUMBER
                                ,p_version_id       IN  NUMBER
                                ,x_return_status  OUT NOCOPY VARCHAR2) is

  l_api_name                 varchar2(30)  := 'VALIDATE_BUDGET_ENTRY';
  l_line_item_id             number(15);

  cursor c_budget_lines is
  select line_item_id
  from   igw_budget_details
  where  proposal_id = p_proposal_id
  and    version_id = p_version_id;
begin
  x_return_status := 'S';

  open c_budget_lines;
  fetch c_budget_lines into l_line_item_id;
  close c_budget_lines;
  if l_line_item_id is not null then
    x_return_status := Fnd_Api.G_Ret_Sts_Error;
    Fnd_Message.Set_Name('IGW','IGW_SS_BUD_LINES_EXIST');
    Fnd_Msg_Pub.Add;
  end if;

exception
  when others then
    x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;
    Fnd_Msg_Pub.Add_Exc_Msg(
      p_pkg_name       => G_package_name,
      p_procedure_name => l_api_name);
    RAISE Fnd_Api.G_Exc_Unexpected_Error;
end; --validate_budget_entry
--------------------------------------------------------------------------------

procedure validate_sponsor_hierarchy(p_proposal_form_number   IN  VARCHAR2
                                     ,x_proposal_form_number  OUT NOCOPY VARCHAR2
                                     ,x_return_status         OUT NOCOPY VARCHAR2) is

  l_api_name   varchar2(30)  := 'VALIDATE_SPONSOR_HIERARCHY';
begin
  select distinct proposal_form_number
  into   x_proposal_form_number
  from   igw_report_seed_header_v
  where  proposal_form_number = p_proposal_form_number;
exception
  when no_data_found OR too_many_rows  then
    x_return_status := Fnd_Api.G_Ret_Sts_Error;
    Fnd_Message.Set_Name('IGW','IGW_SS_BUD_SPONSOR_HIERAR_INV');
    Fnd_Msg_Pub.Add;
  when others then
    x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;
    Fnd_Msg_Pub.Add_Exc_Msg(
      p_pkg_name       => G_package_name,
      p_procedure_name => l_api_name);
    RAISE Fnd_Api.G_Exc_Unexpected_Error;
end; --get_rate_class_id

----------------------------------------------------------------------------------
  procedure create_budget_version
       (p_init_msg_list               IN    VARCHAR2   := FND_API.G_TRUE
        ,p_commit                     IN    VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only              IN    VARCHAR2   := FND_API.G_TRUE
	,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_start_date		            DATE       := null
  	,p_end_date		            DATE       := null
  	,p_total_cost		            NUMBER     := 0
  	,p_total_direct_cost	            NUMBER     := 0
	,p_total_indirect_cost	            NUMBER     := 0
	,p_cost_sharing_amount	            NUMBER     := 0
	,p_underrecovery_amount	            NUMBER     := 0
	,p_residual_funds	            NUMBER     := 0
	,p_total_cost_limit	            NUMBER
	,p_oh_rate_class_id	            NUMBER
        ,p_oh_rate_class_name               VARCHAR2
	,p_proposal_form_number             VARCHAR2
	,p_comments		            VARCHAR2
	,p_final_version_flag	            VARCHAR2   := 'N'
	,p_budget_type_code	            VARCHAR2   := 'PROPOSAL_BUDGET'
        ,p_enter_budget_at_period_level     VARCHAR2
        ,p_apply_inflation_setup_rates      VARCHAR2
        ,p_apply_eb_setup_rates             VARCHAR2
        ,p_apply_oh_setup_rates             VARCHAR2
	,p_attribute_category	            VARCHAR2 := null
	,p_attribute1		            VARCHAR2 := null
	,p_attribute2		            VARCHAR2 := null
	,p_attribute3		            VARCHAR2 := null
	,p_attribute4		            VARCHAR2 := null
	,p_attribute5		            VARCHAR2 := null
	,p_attribute6		            VARCHAR2 := null
	,p_attribute7		            VARCHAR2 := null
	,p_attribute8		            VARCHAR2 := null
	,p_attribute9		            VARCHAR2 := null
	,p_attribute10		            VARCHAR2 := null
	,p_attribute11		            VARCHAR2 := null
	,p_attribute12		            VARCHAR2 := null
	,p_attribute13		            VARCHAR2 := null
	,p_attribute14		            VARCHAR2 := null
	,p_attribute15  	            VARCHAR2 := null
        ,x_rowid                        OUT NOCOPY ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2) IS

  l_api_name           VARCHAR2(30)    := 'CREATE_BUDGET_VERSION';
  l_rate_class_id      NUMBER(15)      := p_oh_rate_class_id;
  l_start_date         DATE            := p_start_date;
  l_end_date           DATE            := p_end_date;
  l_period_start_date  DATE;
  l_period_end_date    DATE;
  l_budget_period      NUMBER;
  l_version_id         NUMBER          := p_version_id;
  l_proposal_form_number  Varchar2(30) := p_proposal_form_number;
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_data               VARCHAR2(250);
  l_msg_index_out      NUMBER;

BEGIN
    IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT create_budget_version;
    END IF;

    if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
    end if;

    --checking for duplicate final version
    if p_final_version_flag = 'Y' then
      check_final_version(p_proposal_id, l_version_id, l_return_status);
      IF l_return_status = FND_API.G_RET_STS_ERROR     THEN
        x_return_status := 'E';
      END IF;
    end if;

    --Rate class
    --rate class is a poplist hence take the value as it is
    l_rate_class_id := p_oh_rate_class_id;
/*
    IF p_oh_rate_class_name  is  null THEN
      l_rate_class_id := null;
    ELSE
    --ELSIF p_oh_rate_class_id is null THEN
        get_rate_class_id(p_rate_class_name   => p_oh_rate_class_name
                          ,x_rate_class_id    => l_rate_class_id
                          ,x_return_status    => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_ERROR     THEN
        x_return_status := 'E';
      END IF;
    END IF;
*/

    --Sponsor Hierarchy
    validate_sponsor_hierarchy(p_proposal_form_number
                               ,l_proposal_form_number
                               ,x_return_status );

    IF l_return_status = FND_API.G_RET_STS_ERROR     THEN
      x_return_status := 'E';
    END IF;

    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;

    x_return_status := 'S';

    if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

      begin
        select proposal_start_date, proposal_end_date
        into   l_start_date, l_end_date
        from   igw_proposals_all
        where  proposal_id = p_proposal_id;
      exception
        when others then
        raise;
      end;

      begin
        select nvl(max(version_id),0)+1
        into   l_version_id
        from   igw_budgets
        where  proposal_id = p_proposal_id;
      exception
        when no_data_found then
          l_version_id := nvl(p_version_id,0) + 1;
        when others then
        raise;
      end;

      igw_budgets_tbh.insert_row(
	p_proposal_id            => p_proposal_id
	,p_version_id             => l_version_id
	,p_start_date             => l_start_date
	,p_end_date               => l_end_date
	,p_total_cost             => p_total_cost
	,p_total_direct_cost      => p_total_direct_cost
	,p_total_indirect_cost    => p_total_indirect_cost
	,p_cost_sharing_amount    => p_cost_sharing_amount
	,p_underrecovery_amount   => p_underrecovery_amount
	,p_residual_funds         => p_residual_funds
	,p_total_cost_limit       => p_total_cost_limit
	,p_oh_rate_class_id       => l_rate_class_id
	,p_proposal_form_number   => p_proposal_form_number
	,p_comments               => p_comments
	,p_final_version_flag     => p_final_version_flag
	,p_budget_type_code	  => p_budget_type_code
        ,p_enter_budget_at_period_level  => p_enter_budget_at_period_level
        ,p_apply_inflation_setup_rates   => p_apply_inflation_setup_rates
        ,p_apply_eb_setup_rates   => p_apply_eb_setup_rates
        ,p_apply_oh_setup_rates   => p_apply_oh_setup_rates
        ,p_attribute_category     => p_attribute_category
	,p_attribute1             => p_attribute1
	,p_attribute2             => p_attribute2
	,p_attribute3             => p_attribute3
	,p_attribute4             => p_attribute4
	,p_attribute5             => p_attribute5
	,p_attribute6             => p_attribute6
	,p_attribute7             => p_attribute7
	,p_attribute8             => p_attribute8
	,p_attribute9             => p_attribute9
	,p_attribute10            => p_attribute10
	,p_attribute11            => p_attribute11
	,p_attribute12            => p_attribute12
	,p_attribute13            => p_attribute13
	,p_attribute14            => p_attribute14
	,p_attribute15            => p_attribute15
        ,x_rowid                  => x_rowid
        ,x_return_status          => l_return_status);

       x_return_status := l_return_status;


       l_period_start_date := l_start_date;
       l_period_end_date   := add_months(l_period_start_date,12)-1;
       l_budget_period     := 0;
       <<PERIOD_LOOP>>
         LOOP
           l_budget_period := nvl(l_budget_period,0) +1;

           if l_period_end_date < l_end_date then
             igw_budget_periods_tbh.insert_row(
     	           p_proposal_id             => p_proposal_id
     	           ,p_version_id             => l_version_id
                   ,p_budget_period_id       => l_budget_period
	           ,p_start_date             => l_period_start_date
	           ,p_end_date               => l_period_end_date
	           ,p_total_cost             => 0
	           ,p_total_direct_cost      => 0
	           ,p_total_indirect_cost    => 0
	           ,p_cost_sharing_amount    => 0
	           ,p_underrecovery_amount   => 0
	           ,p_total_cost_limit       => 0
	           ,p_program_income         => 0
	           ,p_program_income_source  => null
                   ,x_rowid                  => x_rowid
                   ,x_return_status          => l_return_status);

                   x_return_status := l_return_status;

             l_period_start_date := l_period_end_date +1;
             l_period_end_date := add_months(l_period_start_date,12)-1;
             GOTO PERIOD_LOOP;
           else
             l_period_end_date := l_end_date;
             igw_budget_periods_tbh.insert_row(
     	           p_proposal_id             => p_proposal_id
     	           ,p_version_id             => l_version_id
                   ,p_budget_period_id       => l_budget_period
	           ,p_start_date             => l_period_start_date
	           ,p_end_date               => l_period_end_date
	           ,p_total_cost             => 0
	           ,p_total_direct_cost      => 0
	           ,p_total_indirect_cost    => 0
	           ,p_cost_sharing_amount    => 0
	           ,p_underrecovery_amount   => 0
	           ,p_total_cost_limit       => 0
	           ,p_program_income         => 0
	           ,p_program_income_source  => null
                   ,x_rowid                  => x_rowid
                   ,x_return_status          => l_return_status);

                   x_return_status := l_return_status;
             EXIT;
           end if;
          END LOOP PERIOD_LOOP;

    end if; -- p_validate_only = 'Y'

    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_budget_version;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_budget_version;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO create_budget_version;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
    RAISE;


END; --CREATE BUDGET VERSION


------------------------------------------------------------------------------------------
  procedure update_budget_version
       (p_init_msg_list               IN    VARCHAR2   := FND_API.G_TRUE
        ,p_commit                     IN    VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only              IN    VARCHAR2   := FND_API.G_TRUE
	,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_start_date		            DATE
  	,p_end_date		            DATE
  	,p_total_cost		            NUMBER
  	,p_total_direct_cost	            NUMBER
	,p_total_indirect_cost	            NUMBER
	,p_cost_sharing_amount	            NUMBER
	,p_underrecovery_amount	            NUMBER
	,p_residual_funds	            NUMBER
	,p_total_cost_limit	            NUMBER
	,p_oh_rate_class_id	            NUMBER
        ,p_oh_rate_class_name               VARCHAR2
	,p_proposal_form_number             VARCHAR2
	,p_comments		            VARCHAR2
	,p_final_version_flag	            VARCHAR2
	,p_budget_type_code	            VARCHAR2 := 'PROPOSAL_BUDGET'
        ,p_enter_budget_at_period_level     VARCHAR2
        ,p_apply_inflation_setup_rates      VARCHAR2
        ,p_apply_eb_setup_rates             VARCHAR2
        ,p_apply_oh_setup_rates             VARCHAR2
	,p_attribute_category	            VARCHAR2 := null
	,p_attribute1		            VARCHAR2 := null
	,p_attribute2		            VARCHAR2 := null
	,p_attribute3		            VARCHAR2 := null
	,p_attribute4		            VARCHAR2 := null
	,p_attribute5		            VARCHAR2 := null
	,p_attribute6		            VARCHAR2 := null
	,p_attribute7		            VARCHAR2 := null
	,p_attribute8		            VARCHAR2 := null
	,p_attribute9		            VARCHAR2 := null
	,p_attribute10		            VARCHAR2 := null
	,p_attribute11		            VARCHAR2 := null
	,p_attribute12		            VARCHAR2 := null
	,p_attribute13		            VARCHAR2 := null
	,p_attribute14		            VARCHAR2 := null
	,p_attribute15  	            VARCHAR2 := null
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2) IS

  cursor c_rate_class is
  select oh_rate_class_id
  from   igw_budgets
  where  rowid = p_rowid;

  l_api_name           VARCHAR2(30)     := 'UPDATE_BUDGET_VERSION';
  l_rate_class_id      NUMBER(15)       := p_oh_rate_class_id;
  l_orig_rate_class_id NUMBER(15);
  l_proposal_form_number  Varchar2(30) := p_proposal_form_number;
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_data               VARCHAR2(250);
  l_msg_index_out      NUMBER;
  l_dummy              VARCHAR2(1);


BEGIN
    IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT update_budget_version;
    END IF;

    if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
     end if;

    x_return_status := 'S';


    --checking for duplicate final version
    if p_final_version_flag = 'Y' then
      check_final_version(p_proposal_id, p_version_id, l_return_status);
      IF l_return_status = FND_API.G_RET_STS_ERROR     THEN
        x_return_status := 'E';
      END IF;
    end if;

    --Rate class
    --rate class is a poplist hence take the value as it is
    l_rate_class_id := p_oh_rate_class_id;
/*
    IF p_oh_rate_class_name  is  null THEN
      l_rate_class_id := null;
    ELSE
    --ELSIF p_oh_rate_class_id is null THEN
        get_rate_class_id(p_rate_class_name   => p_oh_rate_class_name
                          ,x_rate_class_id    => l_rate_class_id
                          ,x_return_status    => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_ERROR     THEN
        x_return_status := 'E';
      END IF;
    END IF;
*/

    /* commented it out NOCOPY because we need to recalculate for almost all the cases even when
       check boxes for apply rates are changed */
/*
    if p_rowid is not null then
      open c_rate_class;
      fetch c_rate_class into l_orig_rate_class_id;
      close c_rate_class;
    end if;
*/

    IGW_UTILS.Check_Date_Validity(
                           p_context_field    => 'BUDGET_VERSION_DATE'
                           ,p_start_date      => nvl(p_start_date, sysdate-1)
                           ,p_end_date        => nvl(p_end_date, sysdate+1)
                           ,x_return_status   => l_return_status);

    IF l_return_status = FND_API.G_RET_STS_ERROR     THEN
      x_return_status := 'E';
    END IF;

    validate_sponsor_hierarchy(p_proposal_form_number
                               ,l_proposal_form_number
                               ,x_return_status );

    IF l_return_status = FND_API.G_RET_STS_ERROR     THEN
      x_return_status := 'E';
    END IF;

    --validate budget entry
    if p_enter_budget_at_period_level = 'Y' then
      validate_budget_entry(p_proposal_id, p_version_id, l_return_status);
      IF l_return_status = FND_API.G_RET_STS_ERROR     THEN
        x_return_status := 'E';
      END IF;
    end if;

    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;

    BEGIN
      SELECT 'x' INTO l_dummy
      FROM   igw_budgets
      WHERE  ((proposal_id  = p_proposal_id  AND   version_id = p_version_id)
	  OR rowid = p_rowid)
      AND record_version_number  = p_record_version_number;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('IGW','IGW_SS_RECORD_CHANGED');
        FND_MSG_PUB.Add;
        x_msg_data := 'IGW_SS_RECORD_CHANGED';
        x_return_status := 'E' ;
    END;

    l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         If l_msg_count = 1 THEN
          fnd_msg_pub.get
           (p_encoded        => FND_API.G_TRUE ,
            p_msg_index      => 1,
            p_data           => l_data,
            p_msg_index_out  => l_msg_index_out );

            x_msg_data := l_data;
         End if;
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

    if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

      igw_budgets_tbh.update_row(
        p_rowid                   =>  p_rowid
	,p_proposal_id            => p_proposal_id
	,p_version_id             => p_version_id
	,p_start_date             => p_start_date
	,p_end_date               => p_end_date
	,p_total_cost             => p_total_cost
	,p_total_direct_cost      => p_total_direct_cost
	,p_total_indirect_cost    => p_total_indirect_cost
	,p_cost_sharing_amount    => p_cost_sharing_amount
	,p_underrecovery_amount   => p_underrecovery_amount
	,p_residual_funds         => p_residual_funds
	,p_total_cost_limit       => p_total_cost_limit
	,p_oh_rate_class_id       => l_rate_class_id
	,p_proposal_form_number   => p_proposal_form_number
	,p_comments               => p_comments
	,p_final_version_flag     => p_final_version_flag
	,p_budget_type_code	  => p_budget_type_code
        ,p_enter_budget_at_period_level     => p_enter_budget_at_period_level
        ,p_apply_inflation_setup_rates   => p_apply_inflation_setup_rates
        ,p_apply_eb_setup_rates   => p_apply_eb_setup_rates
        ,p_apply_oh_setup_rates   => p_apply_oh_setup_rates
        ,p_attribute_category     => p_attribute_category
	,p_attribute1             => p_attribute1
	,p_attribute2             => p_attribute2
	,p_attribute3             => p_attribute3
	,p_attribute4             => p_attribute4
	,p_attribute5             => p_attribute5
	,p_attribute6             => p_attribute6
	,p_attribute7             => p_attribute7
	,p_attribute8             => p_attribute8
	,p_attribute9             => p_attribute9
	,p_attribute10            => p_attribute10
	,p_attribute11            => p_attribute11
	,p_attribute12            => p_attribute12
	,p_attribute13            => p_attribute13
	,p_attribute14            => p_attribute14
	,p_attribute15            => p_attribute15
        ,p_record_version_number  => p_record_version_number
        ,x_return_status          => l_return_status);

        x_return_status := l_return_status;

        --updating budget lines for inflation flag with new value
        update igw_budget_details
        set    apply_inflation_flag = p_apply_inflation_setup_rates
        where  proposal_id = p_proposal_id
        and    version_id = p_version_id;

        --Recalculate only if rate class is different.
        --if l_rate_class_id <> l_orig_rate_class_id then
       /* Need to recalculate for almost all the cases even when
          check boxes for apply rates are changed */

	  IGW_BUDGET_OPERATIONS.recalculate_budget (
                                p_proposal_id         => p_proposal_id
				,p_version_id         => p_version_id
				,x_return_status      => l_return_status
				,x_msg_data           => x_msg_data
				,x_msg_count          => x_msg_count);

          x_return_status := l_return_status;
        --end if;

    end if; -- p_validate_only = 'Y'

    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_budget_version;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_budget_version;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO update_budget_version;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
    RAISE;

END; --UPDATE BUDGET VERSIONS

-------------------------------------------------------------------------------------------

procedure delete_budget_version
       (p_init_msg_list                 IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                       IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only                IN  VARCHAR2   := FND_API.G_TRUE
        ,p_proposal_id                  IN  NUMBER
        ,p_version_id                   IN  NUMBER
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2)is

  l_api_name          VARCHAR2(30)    := 'DELETE_BUDGET_VERSION';
  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_data              VARCHAR2(250);
  l_msg_index_out     NUMBER;
  l_dummy             VARCHAR2(1);



BEGIN
    IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT delete_budget_version;
    END IF;

    if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
     end if;

    x_return_status := 'S';

    BEGIN
      SELECT 'x' INTO l_dummy
      FROM   igw_budgets
      WHERE  ((proposal_id  = p_proposal_id  AND   version_id = p_version_id)
	 OR rowid = p_rowid)
      AND record_version_number  = p_record_version_number;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('IGW','IGW_SS_RECORD_CHANGED');
        FND_MSG_PUB.Add;
        x_msg_data := 'IGW_SS_RECORD_CHANGED';
        x_return_status := 'E' ;
    END;

    l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         If l_msg_count = 1 THEN
          fnd_msg_pub.get
           (p_encoded        => FND_API.G_TRUE ,
            p_msg_index      => 1,
            p_data           => l_data,
            p_msg_index_out  => l_msg_index_out );

            x_msg_data := l_data;
         End if;
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

    if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then

     igw_budgets_tbh.delete_row (
       p_rowid => p_rowid,
       p_proposal_id => p_proposal_id,
       p_version_id =>  p_version_id,
       p_record_version_number => p_record_version_number,
       x_return_status => l_return_status);

       igw_budgets_pvt.manage_budget_deletion(
                   p_delete_level        =>  'BUDGET_VERSION'
		   ,p_proposal_id        =>  p_proposal_id
		   ,p_version_id         =>  p_version_id
                   ,x_return_status      =>  l_return_status);

      x_return_status := l_return_status;
    end if; -- p_validate_only = 'Y'


    l_msg_count := FND_MSG_PUB.count_msg;
    If l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      If l_msg_count = 1 THEN
        fnd_msg_pub.get
         (p_encoded        => FND_API.G_TRUE ,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out );

          x_msg_data := l_data;
      End if;
      RAISE  FND_API.G_EXC_ERROR;
    End if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
  IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO delete_budget_version;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   fnd_msg_pub.add_exc_msg(p_pkg_name       => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO delete_budget_version;
    END IF;
    x_return_status := 'E';

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO delete_budget_version;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => G_package_name,
                            p_procedure_name => l_api_name,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
    RAISE;


END; --DELETE BUDGET VERSION

END IGW_BUDGETS_PVT;

/
