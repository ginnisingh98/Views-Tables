--------------------------------------------------------
--  DDL for Package Body PQH_BUDGET_ANALYSIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BUDGET_ANALYSIS_PKG" as
/* $Header: pqbgtanl.pkb 120.0 2005/05/29 01:30:54 appldev noship $ */
--
--
procedure salary_analysis(
	  errbuf		out nocopy varchar2
        , retcode		out nocopy varchar2
        , p_batch_name			varchar2
        , p_effective_date 		varchar2
        , p_start_org_id 		number
        , p_start_date  		varchar2
        , p_end_date     		varchar2
	, p_business_group_id		number
) is
  --
  l_proc_name	varchar2(30) := 'SALARY_ANALYSIS';
  --
  l_dummy		varchar2(10);
  l_effective_date	date;
  l_start_date		date;
  l_end_date		date;
  l_error_msg		varchar2(1000);
  l_parameter1_value    varchar2(100);
  l_parameter2_value    varchar2(100);
  l_parameter3_value    varchar2(100);
  l_parameter4_value    varchar2(100);
  l_parameter5_value    varchar2(100);
  l_parameter6_value    varchar2(100);
  l_parameter7_value    varchar2(100);
  l_parameter8_value    varchar2(100);
  l_parameter9_value    varchar2(100);
  --
  -- Cursor to fetch Positions for the given Organization
  --
  -- PMFLETCH Now selects from MLS view
  cursor c_positions(p_organization_id number, p_effective_date date) is
  select
  	pos.position_id, pos.job_id, name
  from
  	hr_all_positions_f_vl pos
  where
  	pos.organization_id = p_organization_id
  and	p_effective_date between pos.effective_start_date and pos.effective_end_date
  order by position_id;

  --
  -- Cursor to Fetch the Organization Structure Version
  --
  cursor c_org_version(p_effective_date  date) is
  select
  	ver.org_structure_version_id
  from
  	per_organization_structures str
      , per_org_structure_versions ver
  where
	str.position_control_structure_flg = 'Y'
  and   str.business_group_id = p_business_group_id
  and   ver.business_group_id = p_business_group_id
  and	str.organization_structure_id = ver.organization_structure_id
  and 	p_effective_date between ver.date_from and nvl(date_to, hr_general.end_of_time);

  --
  -- Cursor toFetch the Organizations for the given Organization Hierarchy
  --
  cursor c_org(p_org_structure_version_id number, p_start_org_id number) is
  SELECT
	    0 rn,
  	    0 level1,
        ORGANIZATION_ID
        FROM HR_ALL_ORGANIZATION_UNITS u
        WHERE ORGANIZATION_ID = p_start_org_id
        and business_group_id = p_business_group_id
        and exists
        (select null from per_org_structure_elements e
         where e.org_structure_version_id = p_org_structure_version_id
         and (e.organization_id_child = p_start_org_id
         or e.organization_id_parent = p_start_org_id) )
  UNION
  SELECT
  	rownum rn,
  	level level1,
	organization_id_child organization_id
  FROM PER_ORG_STRUCTURE_ELEMENTS A
  start with
  	organization_id_parent = p_start_org_id
  and   ORG_STRUCTURE_VERSION_ID = p_org_structure_version_id
  connect by
  	organization_id_parent = prior organization_id_child
  and 	ORG_STRUCTURE_VERSION_ID = p_org_structure_version_id;
  --
  --
  -- Cursor that checks the batch existance
  --
  cursor check_batch_name(p_batch_name varchar2)  is
  select
  	'x'
  from
  	pqh_process_log
  where
	log_context=p_batch_name;

  --
  -- Cursor to get the next batch Id for the Process Log
  --
  cursor c_batch is
  select
  	pqh_process_log_s.nextval
  from
  	dual;

  --
  -- Cursor to fetch the table_route_id of the table_alias
  --
  cursor c_table_route(p_table_alias varchar2) is
  SELECT
  	table_route_id
  from
  	pqh_table_route
  where
  	table_alias = p_table_alias;

  --
  -- Cursor to select workflow sequence no
  --
  cursor c_wf_seq_no is
  select pqh_wf_notifications_s.nextval
  from dual;

  --
  -- Cursor to select user name
  --
  cursor c_user_name(p_position_id number) is
  select user_name
  from fnd_user
  where employee_id =
    (select psf.supervisor_id
     from hr_all_positions_f psf
     where psf.position_id = p_position_id
     and l_effective_date >= psf.effective_start_date
     and l_effective_date <= psf.effective_end_date
    );
  --
  -- Local Variables
  --
  l_org_structure_version_id     number;
  --
  l_budgeted_sal                  number;
  l_reallocation_sal              number;
  l_actual_sal                    number;
  l_commitment_sal                number;
  l_actual_commitment_sal	  number;
  --
  l_actuals_status                number;
  l_batch_id                      number;
  l_table_route_id                number;
  --
  l_transaction_category_id	  number;
  l_workflow_seq_no		  number;
  l_user_name			  varchar2(30);
  l_apply_error_mesg		  varchar2(100);
  l_apply_error_num		  varchar2(100);
  --
  l_message_type_cd		  varchar2(10);
  l_message_type		  varchar2(100);
  l_message    		  	  varchar2(1000);
  --
  l_currency_code                 varchar2(40);
  --
  begin
  --
  hr_utility.set_location('Entering'|| l_proc_name, 10);
  retcode := 0;
  --
  hr_utility.set_location('Entering'|| l_proc_name, 11);
  --
  open check_batch_name(p_batch_name);
  fetch check_batch_name into l_dummy;
  if check_batch_name%found then
	retcode := -1;
        fnd_message.set_name('PQH', 'PQH_PLG_DUP_BATCH');
        fnd_message.set_token('BATCH_NAME', p_batch_name);
        errbuf := fnd_message.get;
        FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, errbuf);
    	return;
  end if;
  --
  hr_utility.set_location('Entering'|| l_proc_name, 13);
  --
  l_effective_date	:= fnd_date.canonical_to_date(p_effective_date);
  l_start_date		:= fnd_date.canonical_to_date(p_start_date);
  l_end_date		:= fnd_date.canonical_to_date(p_end_date);
  --
  -- Fetch the Organization Structure Version
  --
  open c_org_version(l_effective_date);
  fetch c_org_version into l_org_structure_version_id;
  close c_org_version;
  --
  --
  hr_utility.set_location('Entering'|| l_proc_name, 14);
  --
  --
  -- Fetch the batch Id into the l_batch_id
  --
  open c_batch;
  fetch c_batch into l_batch_id;
  close c_batch;
  --
  hr_utility.set_location('l_batch_id : '||l_batch_id ||' - ' || l_proc_name, 15);
  --
  -- Create the start record into the  Process Log
  --
  pqh_process_batch_log.start_log
  (
   p_batch_id         =>l_batch_id,
   p_module_cd        =>'POSITION_BUDGET_ANALYSIS',
   p_log_context      =>p_batch_name,
   p_information3     =>p_effective_date,
   p_information4     =>p_start_org_id,
   p_information5     =>p_start_date,
   p_information6     =>p_end_date
  );
  --
  --
  hr_utility.set_location('organization Structure Version  : '||l_org_structure_version_id ||' '|| l_proc_name, 100);
  hr_utility.set_location('start organization  : '||p_start_org_id ||' '|| l_proc_name, 100);

  --
  --  Fetch the Organizations from the Organization Hierarchy
  --
  for l_organization in c_org(l_org_structure_version_id, p_start_org_id)
  -- Analyse the Positions of each Organization
  loop

    hr_utility.set_location('organization  : '||l_organization.organization_id ||' '|| l_proc_name, 101);
    --
    -- Fetch table route Id for the Organization table(ORU)
    --
    open c_table_route('ORU');
    fetch c_table_route into l_table_route_id;
    -- Set table route id to null if the table route is not defined for ORU
    if c_table_route%notfound then
       l_table_route_id := null;
    end if;
    --
    close c_table_route;

    hr_utility.set_location('l_table_route_id  : '||l_table_route_id ||' '|| l_proc_name, 102);
    --
    --  Check for the type of the cofigurable message(PQH_UNDER_BGT_POSITIONS)
    --
    pqh_utility.set_message(8302,'PQH_UNDER_BGT_POSITIONS', l_organization.organization_id);
    --
    hr_utility.set_location('after pqh_utility.set_message  : '|| l_proc_name, 103);
    --
    l_message_type_cd := pqh_utility.get_message_type_cd;
    pqh_utility.set_message_token('UOM',
                  hr_general.decode_lookup('BUDGET_MEASUREMENT_TYPE','MONEY'));
    pqh_utility.set_message_token('ENTITY',
                  hr_general.decode_lookup('PQH_BUDGET_ENTITY','POSITION'));

    l_message := pqh_utility.get_message;
    --
    hr_utility.set_location('after pqh_utility.get_message  : '||l_message_type_cd|| l_proc_name, 104);
    --
    if l_message_type_cd in ('E','W') then
      if l_message_type_cd = 'E' then
        l_message_type := 'ERROR';
      else
        l_message_type := 'WARNING';
      end if;
    hr_utility.set_location('before pqh_process_batch_log.set_context_level  : '||
                       l_message_type_cd||l_proc_name, 105);
    hr_utility.set_location('before pqh.set_context_level  organization_id: '||
                                  l_organization.organization_id, 105);
    hr_utility.set_location('before pqh.set_context_level  l_table_route_id: '||
                                  l_table_route_id, 105);
    hr_utility.set_location('l_orglevel1: '||
                                  l_organization.level1, 105);
    hr_utility.set_location('org name: '||
                                  hr_general.decode_organization(l_organization.organization_id), 105);
    --
    --  Set the Process Log Context level for the Organization
    --
    pqh_process_batch_log.set_context_level
    (
     p_txn_id               =>l_organization.organization_id,
     p_txn_table_route_id   =>l_table_route_id,
     p_level                =>l_organization.level1 + 1,
     p_log_context          =>hr_general.decode_organization(l_organization.organization_id)
    );
    --
    hr_utility.set_location('Organization : '||l_organization.organization_id
			|| ' ' ||l_proc_name, 110);

    --
    -- Fetch Positions for the organization
    --
    for l_position in c_positions(l_organization.organization_id, l_effective_date)
    -- Analyse the Position Budgeted Salary
    loop

        hr_utility.set_location('l_position_id : '||l_position.position_id
                        || ' - ' || substr(l_position.name,1,40) , 110);
        --
        -- Get the Budgeted Salary of the Position for the given start date and end date
        --
        l_budgeted_sal      := pqh_budgeted_salary_pkg.get_pc_budgeted_salary(
                                   P_POSITION_ID        => l_position.position_id
                                  ,p_budget_entity      => 'POSITION'
                                  ,p_start_date         => l_start_date
                                  ,p_end_date           => l_end_date
                                  ,p_effective_date     => l_effective_date
                                  ,p_business_group_id  => p_business_group_id
                                  );
        --
        -- Get the Reallocation amount(Money) of the Position between the given start date and end date
        --
        l_reallocation_sal  := pqh_reallocation_pkg.get_reallocation(
                                   P_POSITION_ID        => l_position.position_id
                                  ,p_start_date         => l_start_date
                                  ,p_end_date           => l_end_date
                                  ,p_effective_date     => l_effective_date
                                  ,p_system_budget_unit => 'MONEY'
                                  ,p_budget_entity      => 'POSITION'
                                  ,p_business_group_id  => p_business_group_id
                                  );
	pqh_budget_analysis_pkg.get_pos_actual_commit_amt(
				 p_position_id       	=> l_position.position_id,
                                 p_start_date        	=> l_start_date,
                                 p_end_date          	=> l_end_date,
                                 p_effective_date	=> l_effective_date,
                                 p_actual_amount        => l_actual_sal,
				 p_commitment_amount    => l_commitment_sal,
				 p_total_amount         => l_actual_commitment_sal
                                 );

        l_currency_code := get_budget_currency(
                             P_POSITION_ID        => l_position.position_id
                                  ,p_budget_entity      => 'POSITION'
                                  ,p_start_date         => l_start_date
                                  ,p_end_date           => l_end_date
                                  ,p_effective_date     => l_effective_date
                                  ,p_business_group_id  => p_business_group_id
                                  );
        --
        -- Print the details of the Position
        --
        hr_utility.set_location('Position : '||l_position.position_id
				||' '||l_proc_name, 130);
        hr_utility.set_location('Budgeted Salary     : '||nvl(l_budgeted_sal,0)
				||' '||l_proc_name, 140);
        hr_utility.set_location('Budget Reallocation : '||nvl(l_reallocation_sal,0)
				||' '||l_proc_name, 140);
        hr_utility.set_location('Actual Salary       : '||nvl(l_actual_sal,0)
				||' '||l_proc_name, 150);
        hr_utility.set_location('Commitment Salary   : '||nvl(l_commitment_sal,0)
				||' '||l_proc_name, 160);
        hr_utility.set_location('Actual + Commitment Salary : '||nvl(l_actual_commitment_sal,0)
				||' '||l_proc_name, 160);
        --
        -- Check, whether the Position is Under Budgeted
        --
        if (nvl(l_budgeted_sal,0) + nvl(l_reallocation_sal,0) < nvl(l_actual_commitment_sal,0)) then
	    --
            -- If Under Budgeted
            --

            --
            -- Fetch table route Id for the Position table(PSF)
            --
            open c_table_route('PSF');
            fetch c_table_route into l_table_route_id;
            -- Set table route id to null if the table route is not defined for PSF
            if c_table_route%notfound then
              l_table_route_id := null;
            end if;
            --
            close c_table_route;
            --
            l_user_name := null;
            --
            open c_user_name(l_position.position_id);
            fetch c_user_name into l_user_name;
            close c_user_name;
            --
            --
            --  Set the Process Log Context Level for the Position
            --
            pqh_process_batch_log.set_context_level
            (
             p_txn_id               =>l_position.position_id,
             p_txn_table_route_id   =>l_table_route_id,
             p_level                =>l_organization.level1+2,
             p_log_context          =>hr_general.decode_position_latest_name(l_position.position_id)
            );

            --
            --  Insert the Log for the position
            --
            pqh_process_batch_log.insert_log
            (
             p_message_type_cd  =>l_message_type,
             p_message_text     =>l_message,
             p_information3	=>l_budgeted_sal,
             p_information4	=>l_reallocation_sal,
             p_information5	=>l_actual_sal,
             p_information6	=>l_commitment_sal,
             p_information7	=>l_user_name,
             p_information13     =>l_currency_code
            );

            --
            -- Fetch the FYI Notification Info
            --
	    l_transaction_category_id :=
		pqh_workflow.get_txn_cat('POSITION_TRANSACTION', p_business_group_id);
            --
            open c_wf_seq_no;
            fetch c_wf_seq_no into l_workflow_seq_no;
            close c_wf_seq_no;
            --
            hr_utility.set_location('l_position.position_id  : '|| l_position.position_id, 1111);
            hr_utility.set_location('l_user_name  : '|| l_user_name, 1111);
            --
            if l_user_name is not null then
              --
              hr_utility.set_location('l_user_name  : '|| l_user_name, 1112);
              --
              l_parameter1_value :=
                hr_general.decode_position_latest_name(l_position.position_id);
              l_parameter2_value := p_batch_name;
              l_parameter3_value := l_effective_date;
              l_parameter4_value :=
                hr_general.decode_organization(l_organization.organization_id);
              l_parameter5_value :=
                hr_general.decode_job(l_position.job_id);
              l_parameter6_value := l_budgeted_sal;
              l_parameter7_value := l_reallocation_sal;
              l_parameter8_value := l_actual_sal;
              l_parameter9_value := l_commitment_sal;
              --
              -- FYI Notifications call
              --
	      PQH_WF.process_user_action(
	         p_transaction_category_id        => l_transaction_category_id
	       , p_transaction_id                 => l_position.position_id
	       , p_workflow_seq_no                => l_workflow_seq_no
	       , p_user_action_cd                 => 'FYI_NOT'
	       , p_route_to_user                  => l_user_name
               , p_parameter1_value               => l_parameter1_value
               , p_parameter2_value               => l_parameter2_value
               , p_parameter3_value               => l_parameter3_value
               , p_parameter4_value               => l_parameter4_value
               , p_parameter5_value               => l_parameter5_value
               , p_parameter6_value               => l_parameter6_value
               , p_parameter7_value               => l_parameter7_value
               , p_parameter8_value               => l_parameter8_value
               , p_parameter9_value               => l_parameter9_value
               , p_apply_error_mesg               => l_apply_error_mesg
               , p_apply_error_num                => l_apply_error_num
	      );
            end if;
            --
            hr_utility.set_location(l_position.position_id || ' is under budgeted'
				||' '||l_proc_name, 170);
            --
        end if;
        --
    end loop;
    --
    end if;
    --
  end loop;
  --
  -- End the Process Log
  --
  pqh_process_batch_log.end_log;
            hr_utility.set_location('End Process'
				||' '||l_proc_name, 180);
  commit;
  exception
  when others then
    retcode := -1;
    --hr_utility.set_location('Error '||sqlerrm,190);
  --
end;
--
/*
FUNCTION get_position_commitment(p_position_id       in       number,
                                 p_start_date in       date,
                                 p_end_date   in       date) RETURN NUMBER
is
--
cursor c_budgets(p_start_date date, p_end_date date) is
select budget_id, budget_start_date, budget_end_date
from pqh_budgets
where
	nvl(position_control_flag,'X') = 'Y'
      and budgeted_entity_cd = 'POSITION'
and	((p_start_date <= budget_start_date
          and p_end_date >= budget_end_date
         ) or
        (p_start_date between budget_start_date and budget_end_date) or
        (p_end_date between budget_start_date and budget_end_date)
       )
     and (
          hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit1_id) = 'MONEY'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit2_id) = 'MONEY'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit3_id) = 'MONEY'
      );
--
calc_start_date		date;
calc_end_date		date;
l_budget_pos_cmmtmnt	number := 0;
l_pos_cmmtmnt		number := 0;
--
begin
  --
  for l_budgets in c_budgets(p_start_date, p_end_date)
  loop
    calc_start_date := greatest(l_budgets.budget_start_date, p_start_date);
    calc_end_date   := least(l_budgets.budget_end_date, p_end_date);
    --
    l_budget_pos_cmmtmnt := pqh_commitment_pkg.get_position_commitment(
                                  p_position_id         => p_position_id,
                                  p_budget_id		=> l_budgets.budget_id,
                                  p_frequency		=> null,
                                  p_period_start_date   => calc_start_date,
                                  p_period_end_date     => calc_end_date
                                  );
    --
    l_pos_cmmtmnt := nvl(l_pos_cmmtmnt,0) + nvl(l_budget_pos_cmmtmnt,0);
    --
  end loop;
  --
  return(l_pos_cmmtmnt);
  --
end;
*/
--
PROCEDURE get_pos_actual_commit_amt(p_position_id       in     number,
                                    p_start_date        in     date,
                                    p_end_date          in     date,
                                    p_effective_date	in     date,
                                    p_actual_amount     OUT  nocopy   number,
			            p_commitment_amount OUT   nocopy  number,
		   		    p_total_amount      OUT  nocopy   number
                                   ) is
--
cursor c_budgets(p_start_date date, p_end_date date, p_effective_date date) is
select bgt.budget_id, budget_version_id, budget_start_date, budget_end_date
from pqh_budgets bgt, pqh_budget_versions ver
where
 bgt.budget_id = ver.budget_id
and	(p_effective_date between date_from and date_to)
and nvl(position_control_flag,'X') = 'Y'
and budgeted_entity_cd = 'POSITION'
and	((p_start_date <= budget_start_date
          and p_end_date >= budget_end_date
         ) or
        (p_start_date between budget_start_date and budget_end_date) or
        (p_end_date between budget_start_date and budget_end_date)
       )
     and (
          hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit1_id) = 'MONEY'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit2_id) = 'MONEY'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit3_id) = 'MONEY'
      );
--
calc_start_date		date;
calc_end_date		date;
l_budget_pos_cmmtmnt	number := 0;
l_pos_cmmtmnt		number := 0;
l_budget_pos_actuals	number := 0;
l_pos_actuals		number := 0;
l_budget_pos_total_amt	number := 0;
l_pos_total_amt		number := 0;
--
begin
  --
  for l_budgets in c_budgets(p_start_date, p_end_date, p_effective_date)
  loop
    calc_start_date := greatest(l_budgets.budget_start_date, p_start_date);
    calc_end_date   := least(l_budgets.budget_end_date, p_end_date);
    --
    pqh_bdgt_actual_cmmtmnt_pkg.get_pos_money_amounts
    (
    p_budget_version_id         => l_budgets.budget_version_id,
    p_position_id               => p_position_id,
    p_start_date                => calc_start_date,
    p_end_date                  => calc_end_date,
    p_actual_amount             => l_budget_pos_actuals,
    p_commitment_amount         => l_budget_pos_cmmtmnt,
    p_total_amount              => l_budget_pos_total_amt
    );
    --
    l_pos_actuals := nvl(l_pos_actuals,0) + nvl(l_budget_pos_actuals,0);
    l_pos_cmmtmnt := nvl(l_pos_cmmtmnt,0) + nvl(l_budget_pos_cmmtmnt,0);
    l_pos_total_amt := nvl(l_pos_total_amt,0) + nvl(l_budget_pos_total_amt,0);
    --
  end loop;
  --
  p_actual_amount		:= trunc(l_pos_actuals,2);
  p_commitment_amount	:= trunc(l_pos_cmmtmnt,2);
  p_total_amount		:= trunc(l_pos_total_amt,2);
  --
--exception section added as part of nocopy changes
exception
  when others then
     p_actual_amount := Null;
     p_commitment_amount := Null;
     p_total_amount := Null;
     Raise;
--
end;
--
FUNCTION fyi_notification (p_transaction_id in number) RETURN varchar2
is
  l_document varchar2(4000);
  l_proc     varchar2(61) := 'fyi_notification' ;
  l_position_name   varchar2(1000);
BEGIN
  hr_utility.set_location('inside fyi notification'||l_proc,10);
  fnd_message.set_name('PQH','PQH_FYI_UNDER_BDGT_POS');
  fnd_message.set_token('POSITION',l_position_name);
  l_document := fnd_message.get;
  return l_document;
END fyi_notification;
--
--
--
procedure org_pos_temp(p_organization_id number
                          ,p_level1 number
                          ,p_batch_name	            varchar2
                          ,p_unit_of_measure        varchar2
                          ,p_business_group_id      number
                          ,p_effective_date         date
                          ,p_start_date             date
                          ,p_end_date               date
) is
 l_proc_name     varchar2(61) := 'org_pos_analysis' ;
 l_org_name            hr_all_organization_units.name%type;
 --
  l_parameter1_value    varchar2(100);
  l_parameter2_value    varchar2(100);
  l_parameter3_value    varchar2(100);
  l_parameter4_value    varchar2(100);
  l_parameter5_value    varchar2(100);
  l_parameter6_value    varchar2(100);
  l_parameter7_value    varchar2(100);
  l_parameter8_value    varchar2(100);
  l_parameter9_value    varchar2(100);
 --
  -- Cursor to fetch Organization name
  cursor c_org_name(p_org_id number) is
  select name
    from hr_all_organization_units u
   where organization_id = p_org_id;
  -- Cursor to fetch the table_route_id of the table_alias
  cursor c_table_route(p_table_alias varchar2) is
  SELECT
  	table_route_id
  from
  	pqh_table_route
  where
  	table_alias = p_table_alias;
  --
  -- Cursor to fetch Positions for the given Organization
  --
  -- PMFLETCH Now selects from MLS view
  cursor c_positions(p_organization_id number, p_effective_date date) is
  select pos.position_id, pos.job_id, name
  from   hr_all_positions_f_vl pos
  where  pos.organization_id = p_organization_id
  and	 p_effective_date between pos.effective_start_date and pos.effective_end_date
  order by position_id;
  --
  -- Cursor to select user name
  --
  cursor c_user_name(p_position_id number) is
  select user_name
  from fnd_user
  where employee_id =
    (select psf.supervisor_id
     from hr_all_positions_f psf
     where psf.position_id = p_position_id
     and p_effective_date >= psf.effective_start_date
     and p_effective_date <= psf.effective_end_date
    );
  --
  -- Cursor to select workflow sequence no
  --
  cursor c_wf_seq_no is
  select pqh_wf_notifications_s.nextval
  from dual;
  --
  -- Local Variables
  --
  l_org_structure_version_id     number;
  --
  l_budgeted_val                  number;
  l_reallocation_val              number;
  l_actual_val                    number;
  l_commitment_val                number;
  l_actual_commitment_val	  number;
  l_under_budget_val              number;
  l_budgeted_fte_date             date;
  --
  l_actuals_status                number;
  l_batch_id                      number;
  l_table_route_id                number;
  --
  l_transaction_category_id	  number;
  l_workflow_seq_no		  number;
  l_user_name			  varchar2(30);
  l_apply_error_mesg		  varchar2(100);
  l_apply_error_num		  varchar2(100);
  --
  l_message_type_cd		  varchar2(10);
  l_message_type		  varchar2(100);
  l_message    		  	  varchar2(1000);
  l_under_bgt_date                varchar2(100);
  --
  l_currency_code                 varchar2(40);
  --
begin
    hr_utility.set_location('organization  : '||p_organization_id ||' '|| l_proc_name, 101);
    --
    --
    open c_org_name(p_organization_id);
    fetch c_org_name into l_org_name;
    close c_org_name;
    --
    -- Fetch table route Id for the Organization table(ORU)
    --
    open c_table_route('ORU');
    fetch c_table_route into l_table_route_id;
    -- Set table route id to null if the table route is not defined for ORU
    if c_table_route%notfound then
       l_table_route_id := null;
    end if;
    --
    close c_table_route;

    hr_utility.set_location('l_table_route_id  : '||l_table_route_id ||' '|| l_proc_name, 102);
    --
    --  Check for the type of the cofigurable message(PQH_UNDER_BGT_POSITIONS)
    --
    pqh_utility.set_message(8302,'PQH_UNDER_BGT_POSITIONS', p_organization_id);
    --
    pqh_utility.set_message_token('UOM',
                  hr_general.decode_lookup('BUDGET_MEASUREMENT_TYPE',p_unit_of_measure));
    pqh_utility.set_message_token('ENTITY',
                  hr_general.decode_lookup('PQH_BUDGET_ENTITY','POSITION'));

    hr_utility.set_location('after pqh_utility.set_message  : '|| l_proc_name, 103);
    --
    l_message_type_cd := pqh_utility.get_message_type_cd;
    l_message := pqh_utility.get_message;
    --
    hr_utility.set_location('after pqh_utility.get_message  : '||l_message_type_cd|| l_proc_name, 104);
    --
    if l_message_type_cd in ('E','W') then
      if l_message_type_cd = 'E' then
        l_message_type := 'ERROR';
      else
        l_message_type := 'WARNING';
      end if;
    hr_utility.set_location('before pqh_process_batch_log.set_context_level  : '||
                       l_message_type_cd||l_proc_name, 105);
    hr_utility.set_location('before pqh.set_context_level  organization_id: '||
                                  p_organization_id, 105);
    hr_utility.set_location('before pqh.set_context_level  l_table_route_id: '||
                                  l_table_route_id, 105);
    hr_utility.set_location('l_orglevel1: '||
                                  p_level1, 105);
    hr_utility.set_location('org name: '||
                                  hr_general.decode_organization(p_organization_id), 105);
    --
    --  Set the Process Log Context level for the Organization
    --
    pqh_process_batch_log.set_context_level
    (
     p_txn_id               =>p_organization_id,
     p_txn_table_route_id   =>l_table_route_id,
     p_level                =>p_level1 + 1,
     p_log_context          =>hr_general.decode_organization(p_organization_id)
    );
    --
    hr_utility.set_location('Organization : '||p_organization_id
			|| ' ' ||l_proc_name, 110);
    --
    fnd_file.put_line(FND_FILE.LOG,'Primary Entity => ''POSITION''' || ' Unit of Measure => '||p_unit_of_measure);
    fnd_file.put_line(FND_FILE.LOG,'                                                       ');
    fnd_file.put_line(FND_FILE.LOG,'Organization => '|| l_org_name);
    fnd_file.put_line(FND_FILE.LOG,'                                                       ');
    fnd_file.put_line(FND_FILE.LOG,'Name    Budgeted Value   Reallocated Value   Actual Value   Commitment Value   Under Budgeted Value  Under Budgeted Date');
    fnd_file.put_line(FND_FILE.LOG,'                                                       ');

    --
    -- Fetch Positions for the organization
    --
    for l_position in c_positions(p_organization_id, p_effective_date)
    -- Analyse the Position Budgeted Salary
    loop

      hr_utility.set_location('l_position_id : '||l_position.position_id
                        || ' - ' || substr(l_position.name,1,40) , 110);

      if p_unit_of_measure = 'MONEY' then
        --
        -- Get the Budgeted Salary of the Position for the given start date and end date
        --
        l_budgeted_val        := pqh_budgeted_salary_pkg.get_pc_budgeted_salary(
                                   P_POSITION_ID        => l_position.position_id
                                  ,p_budget_entity      => 'POSITION'
                                  ,p_start_date         => p_start_date
                                  ,p_end_date           => p_end_date
                                  ,p_effective_date     => p_effective_date
                                  ,p_business_group_id  => p_business_group_id
                                  );
        hr_utility.set_location('After get_pc_budgeted_salary', 120);
	--
        -- Get the Reallocation amount(Money) of the Position between the given start date and end date
        --
        l_reallocation_val     := pqh_reallocation_pkg.get_reallocation(
                                   P_POSITION_ID        => l_position.position_id
                                  ,p_start_date         => p_start_date
                                  ,p_end_date           => p_end_date
                                  ,p_effective_date     => p_effective_date
                                  ,p_budget_entity      => 'POSITION'
                                  ,p_system_budget_unit => 'MONEY'
                                  ,p_business_group_id  => p_business_group_id
                                  );
        hr_utility.set_location('After get_reallocation', 130);

	pqh_bdgt_actual_cmmtmnt_pkg.get_actual_and_cmmtmnt(
                      p_position_id      => l_position.position_id
                    , p_start_date       => p_start_date
                    , p_end_date         => p_end_date
                    , p_effective_date   => p_effective_date
                    , p_budget_entity    => 'POSITION'
                    , p_actual_value	 => l_actual_val
                    , p_commt_value      => l_commitment_val
				--    p_total_amount     => l_actual_commitment_sal
                    , p_unit_of_measure  => 'MONEY'
                    , p_business_group_id=> p_business_group_id
                                 );
        --
         l_currency_code := get_budget_currency(
                           P_POSITION_ID        => l_position.position_id
                          ,p_budget_entity      => 'POSITION'
                          ,p_start_date         => p_start_date
                          ,p_end_date           => p_end_date
                          ,p_effective_date     => p_effective_date
                          ,p_business_group_id  => p_business_group_id
                              );
        --
        -- Print the details of the Position
        --
        hr_utility.set_location('Position : '||l_position.position_id
				||' '||l_proc_name, 130);
        hr_utility.set_location('Budgeted Salary     : '||l_budgeted_val
				||' '||l_proc_name, 140);
        hr_utility.set_location('Budget Reallocation : '||nvl(l_reallocation_val,0)
				||' '||l_proc_name, 140);
        hr_utility.set_location('Actual Salary       : '||nvl(l_actual_val,0)
				||' '||l_proc_name, 150);
        hr_utility.set_location('Commitment Salary   : '||nvl(l_commitment_val,0)
				||' '||l_proc_name, 160);
        hr_utility.set_location('Actual + Commitment Salary : '||nvl(l_actual_commitment_val,0)
				||' '||l_proc_name, 160);
	if l_budgeted_val is not null then
        --
        -- Check, whether the Position is Under Budgeted
        --
          if (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0) < nvl(l_actual_val,0) + nvl(l_commitment_val,0)) then
	    --
            -- If Under Budgeted
            --
            l_under_budget_val := (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) - (nvl(l_actual_val,0) + nvl(l_commitment_val,0));
            --
            -- Fetch table route Id for the Position table(PSF)
            --
            open c_table_route('PSF');
            fetch c_table_route into l_table_route_id;
            -- Set table route id to null if the table route is not defined for PSF
            if c_table_route%notfound then
              l_table_route_id := null;
            end if;
            --
            close c_table_route;
            --
            l_user_name := null;
            --
            open c_user_name(l_position.position_id);
            fetch c_user_name into l_user_name;
            close c_user_name;
            --
            --
            fnd_file.put_line(FND_FILE.LOG,l_position.name||'    '||l_budgeted_val||'   '||l_reallocation_val||'   '||l_actual_val||'   '||l_commitment_val||'   '||l_under_budget_val||'  ');
            --
            --  Set the Process Log Context Level for the Position
            --
            pqh_process_batch_log.set_context_level
            (
             p_txn_id               =>l_position.position_id,
             p_txn_table_route_id   =>l_table_route_id,
             p_level                =>p_level1+2,
             p_log_context          =>hr_general.decode_position_latest_name(l_position.position_id)
            );

            --
            --  Insert the Log for the position
            --
            pqh_process_batch_log.insert_log
            (
             p_message_type_cd  =>l_message_type,
             p_message_text     =>l_message,
             p_information3	=>round(l_budgeted_val,2),
             p_information4	=>round(l_reallocation_val,2),
             p_information5	=>round(l_actual_val,2),
             p_information6	=>round(l_commitment_val,2),
             p_information7	=>l_user_name,
             p_information8     =>'POSITION',
             p_information9     =>p_unit_of_measure,
             p_information10    =>l_under_bgt_date,
             p_information11    =>p_batch_name,
             p_information12    =>'REPORT',
             p_information13    =>l_currency_code

            );

            --
            -- Fetch the FYI Notification Info
            --
	    l_transaction_category_id :=
		pqh_workflow.get_txn_cat('POSITION_TRANSACTION', p_business_group_id);
            --
            open c_wf_seq_no;
            fetch c_wf_seq_no into l_workflow_seq_no;
            close c_wf_seq_no;
            --
            hr_utility.set_location('l_position.position_id  : '|| l_position.position_id, 1111);
            hr_utility.set_location('l_user_name  : '|| l_user_name, 1111);
            --
            if l_user_name is not null then
              --
              hr_utility.set_location('l_user_name  : '|| l_user_name, 1112);
              --
              l_parameter1_value :=
                hr_general.decode_position_latest_name(l_position.position_id);
              l_parameter2_value := p_batch_name;
              l_parameter3_value := p_effective_date;
              l_parameter4_value :=
                hr_general.decode_organization(p_organization_id);
              l_parameter5_value :=
                hr_general.decode_job(l_position.job_id);
              l_parameter6_value := l_budgeted_val;
              l_parameter7_value := l_reallocation_val;
              l_parameter8_value := l_actual_val;
              l_parameter9_value := l_commitment_val;
              --
              -- FYI Notifications call
              --
	      PQH_WF.process_user_action(
	         p_transaction_category_id        => l_transaction_category_id
	       , p_transaction_id                 => l_position.position_id
	       , p_workflow_seq_no                => l_workflow_seq_no
	       , p_user_action_cd                 => 'FYI_NOT'
	       , p_route_to_user                  => l_user_name
               , p_parameter1_value               => l_parameter1_value
               , p_parameter2_value               => l_parameter2_value
               , p_parameter3_value               => l_parameter3_value
               , p_parameter4_value               => l_parameter4_value
               , p_parameter5_value               => l_parameter5_value
               , p_parameter6_value               => l_parameter6_value
               , p_parameter7_value               => l_parameter7_value
               , p_parameter8_value               => l_parameter8_value
               , p_parameter9_value               => l_parameter9_value
               , p_apply_error_mesg               => l_apply_error_mesg
               , p_apply_error_num                => l_apply_error_num
	      );
            end if;
            --
            hr_utility.set_location(l_position.position_id || ' is under budgeted'
				||' '||l_proc_name, 170);
            --
          end if;--for under budget
	end if; -- 14/05/02

      elsif p_unit_of_measure = 'HOURS' then
        --
        -- Get the Budgeted hours of the Position for the given start date and end date
        --
        l_budgeted_val  := pqh_budgeted_salary_pkg.get_budgeted_hours
                             (P_POSITION_ID        => l_position.position_id
                             ,p_start_date         => p_start_date
                             ,p_end_date           => p_end_date
                             ,p_effective_date     => p_effective_date
                             ,p_budget_entity      => 'POSITION'
                             ,p_business_group_id  => p_business_group_id
                              );

        --
        -- Get the Reallocation hours of the Position between the given start date and end date
        --
        l_reallocation_val  := pqh_reallocation_pkg.get_reallocation
                            (P_POSITION_ID        => l_position.position_id
                            ,p_start_date         => p_start_date
                            ,p_end_date           => p_end_date
                            ,p_effective_date     => p_effective_date
                            ,p_budget_entity      => 'POSITION'
                            ,p_system_budget_unit => 'HOURS'
                            ,p_business_group_id  => p_business_group_id
                             );
        --
        --Get the Actual hours of the position between the given start date and end date
        --
        pqh_bdgt_actual_cmmtmnt_pkg.get_actual_and_cmmtmnt
        		    ( p_position_id        => l_position.position_id
        		     ,p_start_date         => p_start_date
        		     ,p_end_date	       => p_end_date
        		     ,p_effective_date     => p_effective_date
        		     ,p_budget_entity      => 'POSITION'
        		     ,p_unit_of_measure    => 'HOURS'
        		     ,p_business_group_id  => p_business_group_id
        		     ,p_actual_value	   => l_actual_val
        		     ,p_commt_value       => l_commitment_val
		             );
        --

        --
        -- Print the details of the Position
        --
        hr_utility.set_location('Position : '||l_position.position_id
				||' '||l_proc_name, 130);
        hr_utility.set_location('Budgeted Hours     : '||l_budgeted_val
				||' '||l_proc_name, 140);
        hr_utility.set_location('Reallocation Hours: '||nvl(l_reallocation_val,0)
				||' '||l_proc_name, 140);
        hr_utility.set_location('Actual Hours       : '||nvl(l_actual_val,0)
				||' '||l_proc_name, 150);

        if l_budgeted_val is not null then
   	  if (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) < nvl(l_actual_val,0) then

	    --
            -- If Under Budgeted
            --
	    l_under_budget_val := (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) - nvl(l_actual_val,0);
            --
            -- Fetch table route Id for the Position table(PSF)
            --
            open c_table_route('PSF');
            fetch c_table_route into l_table_route_id;
            -- Set table route id to null if the table route is not defined for PSF
            if c_table_route%notfound then
              l_table_route_id := null;
            end if;
            --
            close c_table_route;
            --
            l_user_name := null;
            --
            open c_user_name(l_position.position_id);
            fetch c_user_name into l_user_name;
            close c_user_name;
            --
            --
            fnd_file.put_line(FND_FILE.LOG,l_position.name||'    '||l_budgeted_val||'   '||l_reallocation_val||'   '||l_actual_val||'   '||0||'   '||l_under_budget_val||'  ');
            --
            --  Set the Process Log Context Level for the Position
            --
            pqh_process_batch_log.set_context_level
            (
             p_txn_id               =>l_position.position_id,
             p_txn_table_route_id   =>l_table_route_id,
             p_level                =>p_level1+2,
             p_log_context          =>hr_general.decode_position_latest_name(l_position.position_id)
            );

            --
            --  Insert the Log for the position
            --
            pqh_process_batch_log.insert_log
            (
             p_message_type_cd  =>l_message_type,
             p_message_text     =>l_message,
             p_information3     =>round(l_budgeted_val,2),
             p_information4     =>round(l_reallocation_val,2),
             p_information5     =>round(l_actual_val,2),
             p_information7     =>l_user_name,
             p_information8     =>'POSITION',
             p_information9     =>p_unit_of_measure,
             p_information10    =>l_under_bgt_date,
             p_information11    =>p_batch_name,
             p_information12    =>'REPORT'
            );

            --
            -- Fetch the FYI Notification Info
            --
	    l_transaction_category_id :=
		pqh_workflow.get_txn_cat('POSITION_TRANSACTION', p_business_group_id);
            --
            open c_wf_seq_no;
            fetch c_wf_seq_no into l_workflow_seq_no;
            close c_wf_seq_no;
            --
            hr_utility.set_location('l_position.position_id  : '|| l_position.position_id, 1111);
            hr_utility.set_location('l_user_name  : '|| l_user_name, 1111);
            --
            if l_user_name is not null then
              --
              hr_utility.set_location('l_user_name  : '|| l_user_name, 1112);
              --
              l_parameter1_value :=
                hr_general.decode_position_latest_name(l_position.position_id);
              l_parameter2_value := p_batch_name;
              l_parameter3_value := p_effective_date;
              l_parameter4_value :=
                hr_general.decode_organization(p_organization_id);
              l_parameter5_value :=
                hr_general.decode_job(l_position.job_id);
              l_parameter6_value := l_budgeted_val;
              l_parameter7_value := l_reallocation_val;
              l_parameter8_value := l_actual_val;
              --
              -- FYI Notifications call
              --
	      PQH_WF.process_user_action(
                p_transaction_category_id        => l_transaction_category_id
               ,p_transaction_id                 => l_position.position_id
               ,p_workflow_seq_no                => l_workflow_seq_no
               ,p_user_action_cd                 => 'FYI_NOT'
               ,p_route_to_user                  => l_user_name
               ,p_parameter1_value               => l_parameter1_value
               ,p_parameter2_value               => l_parameter2_value
               ,p_parameter3_value               => l_parameter3_value
               ,p_parameter4_value               => l_parameter4_value
               ,p_parameter5_value               => l_parameter5_value
               ,p_parameter6_value               => l_parameter6_value
               ,p_parameter7_value               => l_parameter7_value
               ,p_parameter8_value               => l_parameter8_value
               ,p_apply_error_mesg               => l_apply_error_mesg
               ,p_apply_error_num                => l_apply_error_num
	      );
            end if;
            --
            hr_utility.set_location(l_position.position_id || ' is under budgeted'
				||' '||l_proc_name, 170);
            --

   	  end if;
        end if; --14/05/02

      else -- p_unit_of_measure is 'FTE' or 'Headcount' etc

        --
        -- Get the Budgeted FTE or Headcount of the Position for the given start date and end date
        --
        l_budgeted_val  := pqh_psf_bus.get_budgeted_fte
                             (p_position_id        => l_position.position_id
                             ,p_start_date         => p_start_date
                             ,p_end_date           => p_end_date
                             ,p_budget_entity      => 'POSITION'
                             ,p_unit_of_measure    => p_unit_of_measure
                             ,p_business_group_id  => p_business_group_id
                             ,p_budgeted_fte_date  => l_budgeted_fte_date
                              );

        --
        -- Get the Reallocation FTE or Headcount of the Position between the given start date and end date
        --
        l_reallocation_val  := pqh_reallocation_pkg.get_reallocation
                            (P_POSITION_ID        => l_position.position_id
                            ,p_start_date         => p_start_date
                            ,p_end_date           => p_end_date
                            ,p_effective_date     => p_effective_date
                            ,p_budget_entity      => 'POSITION'
                            ,p_system_budget_unit => p_unit_of_measure
                            ,p_business_group_id  => p_business_group_id
                             );
        --
        --Get the Actual FTE or Headcount of the position between the given start date and end date
        --
        pqh_bdgt_actual_cmmtmnt_pkg.get_actual_and_cmmtmnt
        		    ( p_position_id        => l_position.position_id
        		     ,p_start_date         => p_start_date
        		     ,p_end_date           => p_end_date
        		     ,p_effective_date     => p_effective_date
        		     ,p_budget_entity      => 'POSITION'
        		     ,p_unit_of_measure    => p_unit_of_measure
        		     ,p_business_group_id  => p_business_group_id
        		     ,p_actual_value	   => l_actual_val
        		     ,p_commt_value        => l_commitment_val
		             );

        --
        -- Print the details of the Position
        --
        hr_utility.set_location('Position : '||l_position.position_id
				||' '||l_proc_name, 130);
        hr_utility.set_location('Unit of measure : '||p_unit_of_measure
				||' '||l_proc_name, 130);
        hr_utility.set_location('Budgeted      : '||l_budgeted_val
				||' '||l_proc_name, 140);
        hr_utility.set_location('Reallocation: '||nvl(l_reallocation_val,0)
				||' '||l_proc_name, 140);
        hr_utility.set_location('Actual       : '||nvl(l_actual_val,0)
				||' '||l_proc_name, 150);

        if l_budgeted_val is not null then
	  if (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) < nvl(l_actual_val,0) then

	    --
            -- If Under Budgeted
            --
	    l_under_budget_val := (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) - nvl(l_actual_val,0);
            --
            -- Fetch table route Id for the Position table(PSF)
            --
            --
            open c_table_route('PSF');
            fetch c_table_route into l_table_route_id;
            -- Set table route id to null if the table route is not defined for PSF
            if c_table_route%notfound then
              l_table_route_id := null;
            end if;
            --
            close c_table_route;
            --
            l_user_name := null;
            --
            open c_user_name(l_position.position_id);
            fetch c_user_name into l_user_name;
            close c_user_name;
            --
            --
            fnd_file.put_line(FND_FILE.LOG,l_position.name||'    '||l_budgeted_val||'   '||l_reallocation_val||'   '||l_actual_val||'   '||0||'   '||l_under_budget_val||'  '||l_budgeted_fte_date);
            --
            --  Set the Process Log Context Level for the Position
            --
            pqh_process_batch_log.set_context_level
            (
             p_txn_id               =>l_position.position_id,
             p_txn_table_route_id   =>l_table_route_id,
             p_level                =>p_level1+2,
             p_log_context          =>hr_general.decode_position_latest_name(l_position.position_id)
            );

            --
            --  Insert the Log for the position
            --
            pqh_process_batch_log.insert_log
            (
             p_message_type_cd  =>l_message_type,
             p_message_text     =>l_message,
             p_information3	    =>round(l_budgeted_val,2),
             p_information4     =>round(l_reallocation_val,2),
             p_information5     =>round(l_actual_val,2),
             p_information7     =>l_user_name,
             p_information8     =>'POSITION',
             p_information9     =>p_unit_of_measure,
             p_information10    =>to_char(l_budgeted_fte_date,'YYYY/MM/DD'),
             p_information11    =>p_batch_name,
             p_information12    =>'REPORT'
            );

            --
            -- Fetch the FYI Notification Info
            --
	    l_transaction_category_id :=
		pqh_workflow.get_txn_cat('POSITION_TRANSACTION', p_business_group_id);
            --
            open c_wf_seq_no;
            fetch c_wf_seq_no into l_workflow_seq_no;
            close c_wf_seq_no;
            --
            hr_utility.set_location('l_position.position_id  : '|| l_position.position_id, 1111);
            hr_utility.set_location('l_user_name  : '|| l_user_name, 1111);
            --
            if l_user_name is not null then
              --
              hr_utility.set_location('l_user_name  : '|| l_user_name, 1112);
              --
              l_parameter1_value :=
                hr_general.decode_position_latest_name(l_position.position_id);
              l_parameter2_value := p_batch_name;
              l_parameter3_value := p_effective_date;
              l_parameter4_value :=
                hr_general.decode_organization(p_organization_id);
              l_parameter5_value :=
                hr_general.decode_job(l_position.job_id);
              l_parameter6_value := l_budgeted_val;
              l_parameter7_value := l_reallocation_val;
              l_parameter8_value := l_actual_val;
              --
              -- FYI Notifications call
              --
	      PQH_WF.process_user_action(
	         p_transaction_category_id        => l_transaction_category_id
	       , p_transaction_id                 => l_position.position_id
	       , p_workflow_seq_no                => l_workflow_seq_no
	       , p_user_action_cd                 => 'FYI_NOT'
	       , p_route_to_user                  => l_user_name
               , p_parameter1_value               => l_parameter1_value
               , p_parameter2_value               => l_parameter2_value
               , p_parameter3_value               => l_parameter3_value
               , p_parameter4_value               => l_parameter4_value
               , p_parameter5_value               => l_parameter5_value
               , p_parameter6_value               => l_parameter6_value
               , p_parameter7_value               => l_parameter7_value
               , p_parameter8_value               => l_parameter8_value
               , p_apply_error_mesg               => l_apply_error_mesg
               , p_apply_error_num                => l_apply_error_num
	      );
            end if;
            --
            hr_utility.set_location(l_position.position_id || ' is under budgeted'
				||' '||l_proc_name, 170);
            --
 	  end if;
        end if; --14/05/02

      end if;--for uom
        --
    end loop;
    --
    end if;
    --
  end;
--
--
--POSITIONS
--To calculate the Under budgeted positions for all units of measure...
--
Procedure position_analysis(
	      errbuf		out nocopy varchar2
        , retcode		out nocopy varchar2
        , p_batch_name			varchar2
        , p_effective_date 		varchar2
        , p_start_org_id 		number
        , p_org_structure_id		number
        , p_start_date  		varchar2
        , p_end_date     		varchar2
        , p_unit_of_measure             varchar2
	, p_business_group_id		number
) is
  --
  l_proc_name	        varchar2(30) := 'POSITION_ANALYSIS';
  --
  l_dummy		varchar2(50);
  l_effective_date	date;
  l_start_date		date;
  l_end_date		date;
  l_start_org_id    number;
  --
  -- Cursor to Fetch the Organization Structure Version
  --
  cursor c_org_version(p_effective_date  date) is
  select ver.org_structure_version_id
  from 	 per_organization_structures str
       , per_org_structure_versions ver
  where	str.position_control_structure_flg = 'Y'
  and   str.organization_structure_id = p_org_structure_id
  and   str.business_group_id = p_business_group_id
  and   ver.business_group_id = p_business_group_id
  and	str.organization_structure_id = ver.organization_structure_id
  and 	p_effective_date between ver.date_from and nvl(date_to, hr_general.end_of_time);
  --
  -- Cursor to fetch the top Org of Hierarchy
  --
  cursor c_top_org(p_org_structure_version_id number) is
  select organization_id_parent organization_id
  from per_org_structure_elements a
  where org_structure_version_id = p_org_structure_version_id
  and not exists (
    select organization_id_child organization_id
    from per_org_structure_elements b
    where org_structure_version_id = p_org_structure_version_id
    and b.organization_id_child = a.organization_id_parent
    )
  and rownum <2;

  --
  -- Cursor to Fetch the Organizations for the given Organization Hierarchy
  --
  -- Bug Fix : 2464692  Change : Cursor exteded with new parameter p_effective_date
  --
  cursor c_org(p_org_structure_version_id number, p_start_org_id number,p_effective_date date) is
  select 0 rn,
  	     0 level1,
         organization_id
  from  hr_all_organization_units u
  where organization_id = p_start_org_id
        and   business_group_id = p_business_group_id
        and exists
        (select null from per_org_structure_elements e
         where e.org_structure_version_id = p_org_structure_version_id
         and   (e.organization_id_child = p_start_org_id
         or    e.organization_id_parent = p_start_org_id ) )
  union
  select rownum rn,
         level level1,
	     organization_id_child organization_id
  from   per_org_structure_elements a
  start with
  	organization_id_parent = p_start_org_id
  and   org_structure_version_id = p_org_structure_version_id
  connect by
  	organization_id_parent = prior organization_id_child
  and 	org_structure_version_id = p_org_structure_version_id;
  --
    --
    -- Bug Fix : 2464692
    -- Retrives all Internal Organizations under the given business group
    -- as on that effective date in case of p_start_org_id and
    -- p_org_structure_id are null
    --
   cursor c_all_org(p_business_group_id number, p_effective_date date) is
    select   rownum rn,
      	   0 level1,
             organization_id
    from hr_all_organization_units
    where business_group_id = p_business_group_id
    and INTERNAL_EXTERNAL_FLAG ='INT'
    and p_effective_date between date_from and nvl(date_to, hr_general.end_of_time);
  --
  -- Cursor that checks the batch existance
  --
  cursor check_batch_name(p_batch_name varchar2)  is
  select 'x'
  from 	 pqh_process_log
  where  log_context=p_batch_name;
  --
  -- Cursor to get the next batch Id for the Process Log
  --
  cursor c_batch is
  select pqh_process_log_s.nextval
  from 	dual;
  --
  -- Local Variables
  --
  l_org_structure_version_id     number;
  --
  l_batch_id              number;
  --
  begin
  --
  hr_utility.set_location('Entering'|| l_proc_name, 10);
  retcode := 0;
  --
  hr_utility.set_location('Entering'|| l_proc_name, 11);
  --
  open check_batch_name(p_batch_name);
  fetch check_batch_name into l_dummy;
  if check_batch_name%found then
	retcode := -1;
        fnd_message.set_name('PQH', 'PQH_PLG_DUP_BATCH');
        fnd_message.set_token('BATCH_NAME', p_batch_name);
        errbuf := fnd_message.get;
        FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, errbuf);
    	return;
  end if;
  --
  hr_utility.set_location('Entering'|| l_proc_name, 13);
  --
  l_effective_date	:= fnd_date.canonical_to_date(p_effective_date);
  l_start_date		:= fnd_date.canonical_to_date(p_start_date);
  l_end_date		:= fnd_date.canonical_to_date(p_end_date);
  --
  -- Fetch the Organization Structure Version
  --
  open c_org_version(l_effective_date);
  fetch c_org_version into l_org_structure_version_id;
  close c_org_version;
  --
  --
  hr_utility.set_location('Entering'|| l_proc_name, 14);
  --
  --
  -- Fetch the batch Id into the l_batch_id
  --
  open c_batch;
  fetch c_batch into l_batch_id;
  close c_batch;
  --
  hr_utility.set_location('l_batch_id : '||l_batch_id ||' - ' || l_proc_name, 15);
  --
  -- Create the start record into the  Process Log
  --
  pqh_process_batch_log.start_log
  (
   p_batch_id         =>l_batch_id,
   p_module_cd        =>'POSITION_BUDGET_ANALYSIS',
   p_log_context      =>p_batch_name,
   p_information3     =>p_effective_date,
   p_information4     =>p_start_org_id,
   p_information5     =>p_start_date,
   p_information6     =>p_end_date,
   p_information7     =>p_org_structure_id,
   p_information8     =>'POSITION',
   p_information9     =>p_unit_of_measure
  );
  --
  --
  hr_utility.set_location('Organization Structure Version  : '||l_org_structure_version_id ||' '|| l_proc_name, 100);
  hr_utility.set_location('start organization  : '||p_start_org_id ||' '|| l_proc_name, 100);

  if (l_org_structure_version_id is not null ) then
   l_start_org_id := p_start_org_id;
   -- Bug Fix :2481824 ,get Top Org in Hierarchy as p_start_org_id
   if (p_start_org_id is null) then
     open c_top_org(l_org_structure_version_id);
     fetch c_top_org into l_start_org_id;
     close c_top_org;
   end if;
   --
   if l_start_org_id is not null then
    --
    --  Fetch the Organizations from the Organization Hierarchy
    for l_organization in c_org(l_org_structure_version_id, l_start_org_id,l_effective_date)
    -- Analyse the Positions of each Organization
    loop
      --
      hr_utility.set_location('organization  : '||l_organization.organization_id ||' '|| l_proc_name, 101);
      --
      org_pos_temp(p_organization_id  => l_organization.organization_id
                ,p_level1           => l_organization.level1
                ,p_batch_name	    => p_batch_name
                ,p_unit_of_measure  => p_unit_of_measure
                ,p_business_group_id=> p_business_group_id
                ,p_effective_date   => l_effective_date
                ,p_start_date       => l_start_date
                ,p_end_date         => l_end_date
                );
      --
      end loop;
    end if;
  elsif (p_start_org_id is null)
  then
    for l_organization in c_all_org(p_business_group_id, l_effective_date)
    -- Analyse the Positions of each Organization
    loop
      --
      hr_utility.set_location('organization  : '||l_organization.organization_id ||' '|| l_proc_name, 101);
      --
      org_pos_temp(p_organization_id  => l_organization.organization_id
                ,p_level1           => l_organization.level1
                ,p_batch_name	    => p_batch_name
                ,p_unit_of_measure  => p_unit_of_measure
                ,p_business_group_id=> p_business_group_id
                ,p_effective_date   => l_effective_date
                ,p_start_date       => l_start_date
                ,p_end_date         => l_end_date
                );
    --
    end loop;
  end if;
  --
  -- End the Process Log
  --
  pqh_process_batch_log.end_log;
            hr_utility.set_location('End Process'
				||' '||l_proc_name, 180);
  commit;
  exception
  when others then
    retcode := -1;
  --
end;


---*******************-----
--JOBS
--To calculate the Under budgeted jobs for all units of measure...
--
Procedure job_analysis(
	  errbuf		out nocopy varchar2
        , retcode		out nocopy varchar2
        , p_batch_name			varchar2
        , p_effective_date 		varchar2
        , p_start_date  		varchar2
        , p_end_date     		varchar2
        , p_unit_of_measure             varchar2
	, p_business_group_id		number
) is
  --
  l_proc_name	        varchar2(30) := 'JOB_ANALYSIS';
  --
  l_dummy		varchar2(50);
  l_effective_date	date;
  l_start_date		date;
  l_end_date		date;
  l_error_msg		varchar2(1000);
  l_parameter1_value    varchar2(100);
  l_parameter2_value    varchar2(100);
  l_parameter3_value    varchar2(100);
  l_parameter4_value    varchar2(100);
  l_parameter5_value    varchar2(100);
  l_parameter6_value    varchar2(100);
  l_parameter7_value    varchar2(100);
  l_parameter8_value    varchar2(100);
  l_parameter9_value    varchar2(100);
  --
  -- Cursor to fetch Jobs
  --

  cursor c_jobs(p_effective_date date, p_start_date1 date, p_end_date1 date) is
  select distinct bdet.job_id, job.name
  from   pqh_budgets bud,
  	      pqh_budget_versions bver,
       	 pqh_budget_details bdet,
         per_jobs_tl job
  where  bud.business_group_id = p_business_group_id
  and    bud.position_control_flag = 'Y'
  and    bud.budgeted_entity_cd = 'JOB'
  and    (p_start_date1 <= bud.budget_end_date
           and p_end_date1 >= bud.budget_start_date)
  and    bver.budget_id = bud.budget_id
  and    bver.budget_version_id = bdet.budget_version_id
  and    bdet.job_id = job.job_id
  and    job.language = userenv('LANG');

  --
  -- Cursor that checks the batch existance
  --
  cursor check_batch_name(p_batch_name varchar2)  is
  select 'x'
  from 	 pqh_process_log
  where  log_context=p_batch_name;

  --
  -- Cursor to get the next batch Id for the Process Log
  --
  cursor c_batch is
  select
  	pqh_process_log_s.nextval
  from
  	dual;

  --
  -- Cursor to fetch the table_route_id of the table_alias
  --
  cursor c_table_route(p_table_alias varchar2) is
  SELECT
  	table_route_id
  from
  	pqh_table_route
  where
  	table_alias = p_table_alias;

  --
  -- Local Variables
  --
  l_budgeted_val                  number;
  l_reallocation_val              number;
  l_actual_val                    number;
  l_commitment_val                number;
  l_actual_commitment_val	  number;
  l_under_budget_val              number;
  l_budgeted_fte_date             date;
  --
  l_actuals_status                number;
  l_batch_id                      number;
  l_table_route_id                number;
  --
  l_apply_error_mesg		  varchar2(100);
  l_apply_error_num		  varchar2(100);
  --
  l_message_type_cd		  varchar2(10);
  l_message_type		  varchar2(100);
  l_message    		  	  varchar2(1000);
  l_under_bgt_date                varchar2(100);
  --
  l_currency_code                 varchar2(40);
  --
  begin
  --
  hr_utility.set_location('Entering'|| l_proc_name, 10);
  retcode := 0;
  --
  hr_utility.set_location('Entering'|| l_proc_name, 11);
  --
  open check_batch_name(p_batch_name);
  fetch check_batch_name into l_dummy;
  if check_batch_name%found then
	retcode := -1;
        fnd_message.set_name('PQH', 'PQH_PLG_DUP_BATCH');
        fnd_message.set_token('BATCH_NAME', p_batch_name);
        errbuf := fnd_message.get;
        FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, errbuf);
    	return;
  end if;
  --
  hr_utility.set_location('Entering'|| l_proc_name, 13);
  --
  l_effective_date	:= fnd_date.canonical_to_date(p_effective_date);
  l_start_date		:= fnd_date.canonical_to_date(p_start_date);
  l_end_date		:= fnd_date.canonical_to_date(p_end_date);
  --
  -- Fetch the batch Id into the l_batch_id
  --
  open c_batch;
  fetch c_batch into l_batch_id;
  close c_batch;
  --
  hr_utility.set_location('l_batch_id : '||l_batch_id ||' - ' || l_proc_name, 15);

  hr_utility.set_location('l_effective_date: '||to_char(l_effective_date), 155);
  hr_utility.set_location('l_start_date: '||to_char(l_start_date), 156);
  hr_utility.set_location('l_end_date: '||to_char(l_end_date), 157);
  --
  -- Create the start record into the  Process Log
  --
  pqh_process_batch_log.start_log
  (
   p_batch_id         =>l_batch_id,
   p_module_cd        =>'POSITION_BUDGET_ANALYSIS',
   p_log_context      =>p_batch_name,
   p_information3     =>p_effective_date,
   p_information5     =>p_start_date,
   p_information6     =>p_end_date,
   p_information8     =>'JOB',
   p_information9     =>p_unit_of_measure
  );
  --
  --
  -- Fetch table route Id for the Job table(JOB)
  --
  open c_table_route('JOB');
  fetch c_table_route into l_table_route_id;
  -- Set table route id to null if the table route is not defined for JOB
  if c_table_route%notfound then
     l_table_route_id := null;
  end if;
    --
  close c_table_route;

  hr_utility.set_location('l_table_route_id  : '||l_table_route_id ||' '|| l_proc_name, 102);
  --
  --  Check for the type of the cofigurable message(PQH_UNDER_BGT_POSITIONS)
  --
  pqh_utility.set_message(8302,'PQH_UNDER_BGT_POSITIONS', 200);
  --
  pqh_utility.set_message_token('UOM',
                  hr_general.decode_lookup('BUDGET_MEASUREMENT_TYPE',p_unit_of_measure));
  pqh_utility.set_message_token('ENTITY',
                  hr_general.decode_lookup('PQH_BUDGET_ENTITY','JOB'));

  hr_utility.set_location('after pqh_utility.set_message  : '|| l_proc_name, 103);
  --
  l_message_type_cd := pqh_utility.get_message_type_cd;
  l_message := pqh_utility.get_message;
  --
  hr_utility.set_location('after pqh_utility.get_message  : '||l_message_type_cd|| l_proc_name, 104);
  --
  if l_message_type_cd in ('E','W') then
    if l_message_type_cd = 'E' then
      l_message_type := 'ERROR';
    else
      l_message_type := 'WARNING';
    end if;
    hr_utility.set_location('before pqh_process_batch_log.set_context_level  : '||
                                l_message_type_cd||l_proc_name, 105);
    hr_utility.set_location('before pqh.set_context_level  l_table_route_id: '||
                                l_table_route_id, 105);
    --
    --  Set the Process Log Context level....What should it be?
    --
    /*pqh_process_batch_log.set_context_level
    (
     p_txn_id               =>l_organization.organization_id,
     p_txn_table_route_id   =>l_table_route_id,
     p_level                =>l_organization.level1 + 1,
    p_log_context          =>hr_general.decode_organization(l_organization.organization_id)
    ); */
    --
    -- Fetch Jobs
    --
    -- Print the output on concurrent log
    --
    fnd_file.put_line(FND_FILE.LOG,'Primary Entity => ''JOB''' || ' Unit of Measure => '||p_unit_of_measure);
    fnd_file.put_line(FND_FILE.LOG,'                                                       ');
    fnd_file.put_line(FND_FILE.LOG,'Name    Budgeted Value   Reallocated Value   Actual Value   Commitment Value  Under Budgeted Value  Under Budgeted Date');
    fnd_file.put_line(FND_FILE.LOG,'                                                       ');

    for l_job in c_jobs(l_effective_date, l_start_date, l_end_date)
    loop

      hr_utility.set_location('l_job_id : '||l_job.job_id , 110);

      if p_unit_of_measure = 'MONEY' then
        --
        -- Get the Budgeted Salary of the Job for the given start date and end date
        --
        l_budgeted_val        := pqh_budgeted_salary_pkg.get_pc_budgeted_salary(
                                   p_job_id             => l_job.job_id
                                  ,p_start_date         => l_start_date
                                  ,p_end_date           => l_end_date
                                  ,p_effective_date     => l_effective_date
                                  ,p_business_group_id  => p_business_group_id
                                  ,p_budget_entity      => 'JOB'
                                  );
        --
        -- Get the Reallocation amount(Money) of the Job between the given start date and end date
        --
        l_reallocation_val        := pqh_reallocation_pkg.get_reallocation(
                                   p_job_id             => l_job.job_id
                                  ,p_start_date         => l_start_date
                                  ,p_end_date           => l_end_date
                                  ,p_effective_date     => l_effective_date
                                  ,p_budget_entity      => 'JOB'
                                  ,p_system_budget_unit => 'MONEY'
                                  ,p_business_group_id  => p_business_group_id
                                  );

	pqh_bdgt_actual_cmmtmnt_pkg.get_actual_and_cmmtmnt(
				  p_job_id       	=> l_job.job_id
                                 ,p_start_date        	=> l_start_date
                                 ,p_end_date          	=> l_end_date
                                 ,p_effective_date	=> l_effective_date
                                 ,p_budget_entity       => 'JOB'
                                , p_actual_value	=> l_actual_val
				, p_commt_value         => l_commitment_val
				-- p_total_amount         => l_actual_commitment_sal --to be checked
				 ,p_unit_of_measure     => 'MONEY'
				 ,p_business_group_id   => p_business_group_id
                                 );
        --
         l_currency_code := get_budget_currency(
                             p_job_id                   => l_job.job_id
                                  ,p_budget_entity      => 'JOB'
                                  ,p_start_date         => l_start_date
                                  ,p_end_date           => l_end_date
                                  ,p_effective_date     => l_effective_date
                                  ,p_business_group_id  => p_business_group_id
                                  );
        --
        -- Print the details of the job
        --
        hr_utility.set_location('Job : '||l_job.job_id
				||' '||l_proc_name, 130);
        hr_utility.set_location('Budgeted Value     : '||l_budgeted_val
				||' '||l_proc_name, 140);
        hr_utility.set_location('Reallocation Value : '||nvl(l_reallocation_val,0)
				||' '||l_proc_name, 140);
        hr_utility.set_location('Actual Value       : '||nvl(l_actual_val,0)
				||' '||l_proc_name, 150);
        hr_utility.set_location('Commitment Value   : '||nvl(l_commitment_val,0)
				||' '||l_proc_name, 160);
        hr_utility.set_location('Actual + Commitment Value : '||nvl(l_actual_commitment_val,0)
				||' '||l_proc_name, 160);
        --
        -- Check, whether the Job is Under Budgeted
        --
        if l_budgeted_val is not null then
          if (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0) < nvl(l_actual_val,0) + nvl(l_commitment_val,0)) then
	    --
            -- If Under Budgeted
            --

            --
            -- Fetch table route Id for the Position table(PSF)
            --
           /* open c_table_route('PSF');
            fetch c_table_route into l_table_route_id;
            -- Set table route id to null if the table route is not defined for PSF
            if c_table_route%notfound then
              l_table_route_id := null;
            end if;
            --
            close c_table_route;

            l_user_name := null;
            --
            open c_user_name(l_position.position_id);
            fetch c_user_name into l_user_name;
            close c_user_name; */

            --
            l_under_budget_val := (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) - (nvl(l_actual_val,0) + nvl(l_commitment_val,0));
            --
            --
    fnd_file.put_line(FND_FILE.LOG,l_job.name||'    '||l_budgeted_val||'   '||l_reallocation_val||'   '||l_actual_val||'   '||l_commitment_val||'   '||l_under_budget_val||'  ');
            --
            --  Set the Process Log Context Level for the job
            --
            pqh_process_batch_log.set_context_level
            (
             p_txn_id               =>l_job.job_id,
             p_txn_table_route_id   =>l_table_route_id, -- later
             p_level                =>1,
             p_log_context          =>hr_general.decode_job(l_job.job_id)
            );

            --
            --  Insert the Log for the job
            --
            pqh_process_batch_log.insert_log
            (
             p_message_type_cd  =>l_message_type,
             p_message_text     =>l_message,
             p_information3	=>round(l_budgeted_val,2),
             p_information4	=>round(l_reallocation_val,2),
             p_information5	=>round(l_actual_val,2),
             p_information6	=>round(l_commitment_val,2),  -- p_information7	=>l_user_name
             p_information8     =>'JOB',
             p_information9     =>p_unit_of_measure,
             p_information10    =>l_under_bgt_date,
             p_information11    =>p_batch_name,
             p_information12    =>'REPORT',
             p_information13    => l_currency_code
            );

            --
            hr_utility.set_location(l_job.job_id || ' is under budgeted'
				||' '||l_proc_name, 170);
            --
          end if;--for under budget
        end if; --14/05/02

      elsif p_unit_of_measure = 'HOURS' then
        --
        -- Get the Budgeted hours of the Job for the given start date and end date
        --
        l_budgeted_val  := pqh_budgeted_salary_pkg.get_budgeted_hours
                             (p_job_id             => l_job.job_id
                             ,p_start_date         => l_start_date
                             ,p_end_date           => l_end_date
                             ,p_effective_date     => l_effective_date
                             ,p_budget_entity      => 'JOB'
                             ,p_business_group_id  => p_business_group_id
                              );

        --
        -- Get the Reallocation hours of the Job between the given start date and end date
        --
        l_reallocation_val  := pqh_reallocation_pkg.get_reallocation
                            (p_job_id             => l_job.job_id
                            ,p_start_date         => l_start_date
                            ,p_end_date           => l_end_date
                            ,p_effective_date     => l_effective_date
                            ,p_budget_entity      => 'JOB'
                            ,p_system_budget_unit => 'HOURS'
                            ,p_business_group_id  => p_business_group_id
                             );
        --
        --Get the Actual hours of the job between the given start date and end date
        --
        pqh_bdgt_actual_cmmtmnt_pkg.get_actual_and_cmmtmnt
        		    ( p_job_id             => l_job.job_id
			     ,p_start_date         => l_start_date
		             ,p_end_date	   => l_end_date
                             ,p_effective_date     => l_effective_date
		             ,p_unit_of_measure    => 'HOURS'
		             ,p_budget_entity      => 'JOB'
		             ,p_business_group_id  => p_business_group_id
                             , p_actual_value	   => l_actual_val
    			     , p_commt_value       => l_commitment_val
		             );

        --
        -- Print the details of the Job
        --
        hr_utility.set_location('Job : '||l_job.job_id
				||' '||l_proc_name, 130);
        hr_utility.set_location('Budgeted Hours     : '||l_budgeted_val
				||' '||l_proc_name, 140);
        hr_utility.set_location('Reallocation Hours: '||nvl(l_reallocation_val,0)
				||' '||l_proc_name, 140);
        hr_utility.set_location('Actual Hours       : '||nvl(l_actual_val,0)
				||' '||l_proc_name, 150);

        if l_budgeted_val is not null then
      	  if (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) < nvl(l_actual_val,0) then

	    --
            -- If Under Budgeted
            --
	    -- New table route --pqcptca.ldt---also change in Process log form
            --
            -- Fetch table route Id for the Job table
            --
            /*open c_table_route('PSF');
            fetch c_table_route into l_table_route_id;
            -- Set table route id to null if the table route is not defined for PSF
            if c_table_route%notfound then
              l_table_route_id := null;
            end if;
            --
            close c_table_route;
            --
            l_user_name := null;
            --
            open c_user_name(l_position.position_id);
            fetch c_user_name into l_user_name;
            close c_user_name; */
            --
            --
            l_under_budget_val := (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) - nvl(l_actual_val,0);

     fnd_file.put_line(FND_FILE.LOG,l_job.name||'    '||l_budgeted_val||'   '||l_reallocation_val||'   '||l_actual_val||'   '||0||'   '||l_under_budget_val||'  ');
            --
            --
            --  Set the Process Log Context Level for the Job
            --
            pqh_process_batch_log.set_context_level
            (
             p_txn_id               =>l_job.job_id,
             p_txn_table_route_id   =>l_table_route_id,
             p_level                =>1,
             p_log_context          =>hr_general.decode_job(l_job.job_id)
            );

            --
            --  Insert the Log for the Job
            --
            pqh_process_batch_log.insert_log
            (
             p_message_type_cd  =>l_message_type,
             p_message_text     =>l_message,
             p_information3	=>round(l_budgeted_val,2),
             p_information4	=>round(l_reallocation_val,2),
             p_information5	=>round(l_actual_val,2),
             p_information7	=>null,
             p_information8     =>'JOB',
             p_information9     =>p_unit_of_measure,
             p_information10    =>l_under_bgt_date,
             p_information11    =>p_batch_name,
             p_information12    =>'REPORT'
            );


   	  end if;
        end if;

      else -- p_unit_of_measure is 'FTE' or 'Headcount' etc

        --
        -- Get the Budgeted FTE or Headcount of the Job for the given start date and end date
        --

	l_budgeted_val  := pqh_psf_bus.get_budgeted_fte
                             (p_job_id             => l_job.job_id
                             ,p_start_date         => l_start_date
                             ,p_end_date           => l_end_date
                             ,p_budget_entity      => 'JOB'
                             ,p_unit_of_measure    => p_unit_of_measure
                             ,p_business_group_id  => p_business_group_id
                             ,p_budgeted_fte_date  => l_budgeted_fte_date
                              );

        --
        -- Get the Reallocation FTE or Headcount of the Job between the given start date and end date
        --
        l_reallocation_val  := pqh_reallocation_pkg.get_reallocation
                            (p_job_id             => l_job.job_id
                            ,p_start_date         => l_start_date
                            ,p_end_date           => l_end_date
                            ,p_effective_date     => l_effective_date
                            ,p_budget_entity      => 'JOB'
                            ,p_system_budget_unit => p_unit_of_measure
                            ,p_business_group_id  => p_business_group_id
                             );
        --
        --Get the Actual FTE or Headcount of the job between the given start date and end date
        --
        pqh_bdgt_actual_cmmtmnt_pkg.get_actual_and_cmmtmnt
        		    ( p_job_id             => l_job.job_id
			    , p_start_date         => l_start_date
		            , p_end_date	   => l_end_date
		             ,p_effective_date     => l_effective_date
		             ,p_budget_entity      => 'JOB'
		            , p_unit_of_measure    => p_unit_of_measure
		            , p_business_group_id  => p_business_group_id
                            , p_actual_value	   => l_actual_val
        		    , p_commt_value        => l_commitment_val
		             );

        --
        -- Print the details of the Job
        --
        hr_utility.set_location('Job : '||l_job.job_id
				||' '||l_proc_name, 130);
        hr_utility.set_location('Unit of measure : '||p_unit_of_measure
				||' '||l_proc_name, 130);
        hr_utility.set_location('Budgeted      : '||l_budgeted_val
				||' '||l_proc_name, 140);
        hr_utility.set_location('Reallocation: '||nvl(l_reallocation_val,0)
				||' '||l_proc_name, 140);
        hr_utility.set_location('Actual       : '||nvl(l_actual_val,0)
				||' '||l_proc_name, 150);

        if l_budgeted_val is not null then
	  if (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) < nvl(l_actual_val,0) then

	    --
            -- If Under Budgeted
            --

	    l_under_budget_val := (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) - nvl(l_actual_val,0);
            --
            -- Fetch table route Id for the Position table(PSF)
            --
            /*open c_table_route('PSF');
            fetch c_table_route into l_table_route_id;
            -- Set table route id to null if the table route is not defined for PSF
            if c_table_route%notfound then
              l_table_route_id := null;
            end if;
            --
            close c_table_route;
            --
            l_user_name := null;
            --
            open c_user_name(l_position.position_id);
            fetch c_user_name into l_user_name;
            close c_user_name; */
            --
            -- Print the details on concurrent log
            --

    fnd_file.put_line(FND_FILE.LOG,l_job.name||'    '||l_budgeted_val||'   '||l_reallocation_val||'   '||l_actual_val||'   '||0||'   '||l_under_budget_val||'  '||l_budgeted_fte_date);

            --
            --  Set the Process Log Context Level for the job
            --
            pqh_process_batch_log.set_context_level
            (
             p_txn_id               =>l_job.job_id,
             p_txn_table_route_id   =>l_table_route_id,
             p_level                =>1,
             p_log_context          =>hr_general.decode_job(l_job.job_id)
            );

            --
            --  Insert the Log for the job
            --
            pqh_process_batch_log.insert_log
            (
             p_message_type_cd  =>l_message_type,
             p_message_text     =>l_message,
             p_information3	=>round(l_budgeted_val,2),
             p_information4	=>round(l_reallocation_val,2),
             p_information5	=>round(l_actual_val,2),
             p_information7	=>null,
             p_information8     =>'JOB',
             p_information9     =>p_unit_of_measure,
             p_information10    =>to_char(l_budgeted_fte_date,'RRRR/MM/DD'),--l_under_bgt_date,
             p_information11    =>p_batch_name,
             p_information12    =>'REPORT'

            );

            --
            hr_utility.set_location(l_job.job_id || ' is under budgeted'
				||' '||l_proc_name, 170);
            --
 	  end if;--FYI
        end if; --14/05/02

      end if;--for uom
        --
    end loop;
    --
    end if;
  --
  --
  -- End the Process Log
  --
  pqh_process_batch_log.end_log;
            hr_utility.set_location('End Process'
				||' '||l_proc_name, 180);
  commit;
  exception
  when others then
    retcode := -1;
   -- hr_utility.set_location('Error '||sqlerrm,190);
  --
end;
--
-- GRADES
--To calculate the Under budgeted grades for all units of measure...
--
Procedure grade_analysis(
	  errbuf		out nocopy varchar2
        , retcode		out nocopy varchar2
        , p_batch_name			varchar2
        , p_effective_date 		varchar2
        , p_start_date  		varchar2
        , p_end_date     		varchar2
        , p_unit_of_measure             varchar2
	, p_business_group_id		number
) is
  --
  l_proc_name	        varchar2(30) := 'GRADE_ANALYSIS';
  --
  l_dummy		varchar2(50);
  l_effective_date	date;
  l_start_date		date;
  l_end_date		date;
  l_error_msg		varchar2(1000);
  l_parameter1_value    varchar2(100);
  l_parameter2_value    varchar2(100);
  l_parameter3_value    varchar2(100);
  l_parameter4_value    varchar2(100);
  l_parameter5_value    varchar2(100);
  l_parameter6_value    varchar2(100);
  l_parameter7_value    varchar2(100);
  l_parameter8_value    varchar2(100);
  l_parameter9_value    varchar2(100);
  --
  -- Cursor to fetch Grades
  --

  cursor c_grades(p_effective_date date, p_start_date1 date, p_end_date1 date) is
  select distinct bdet.grade_id, grd.name
  from   pqh_budgets bud,
  	 pqh_budget_versions bver,
  	 pqh_budget_details bdet,
     per_grades_tl grd
  where  bud.business_group_id = p_business_group_id
  and    bud.position_control_flag = 'Y'
  and    bud.budgeted_entity_cd = 'GRADE'
  and    (p_start_date1 <= bud.budget_end_date
           and p_end_date1 >= bud.budget_start_date)
  and    bver.budget_id = bud.budget_id
  and    bver.budget_version_id = bdet.budget_version_id
  and    bdet.grade_id = grd.grade_id
  and    grd.language = userenv('LANG');

  --
  -- Cursor that checks the batch existance
  --
  cursor check_batch_name(p_batch_name varchar2)  is
  select 'x'
  from 	 pqh_process_log
  where  log_context=p_batch_name;

  --
  -- Cursor to get the next batch Id for the Process Log
  --
  cursor c_batch is
  select
  	pqh_process_log_s.nextval
  from
  	dual;

  --
  -- Cursor to fetch the table_route_id of the table_alias
  --
  cursor c_table_route(p_table_alias varchar2) is
  SELECT
  	table_route_id
  from
  	pqh_table_route
  where
  	table_alias = p_table_alias;

  --
  -- Local Variables
  --
  l_budgeted_val                  number;
  l_reallocation_val              number;
  l_actual_val                    number;
  l_commitment_val                number;
  l_actual_commitment_val	  number;
  l_under_budget_val              number;
  l_budgeted_fte_date             date;
  --
  l_actuals_status                number;
  l_batch_id                      number;
  l_table_route_id                number;
  --
  l_apply_error_mesg		  varchar2(100);
  l_apply_error_num		  varchar2(100);
  --
  l_message_type_cd		  varchar2(10);
  l_message_type		  varchar2(100);
  l_message    		  	  varchar2(1000);
  l_under_bgt_date                varchar2(100);
  --
  l_currency_code                 varchar2(40);
  --
  begin
  --
  hr_utility.set_location('Entering'|| l_proc_name, 10);
  retcode := 0;
  --
  hr_utility.set_location('Entering'|| l_proc_name, 11);
  --
  open check_batch_name(p_batch_name);
  fetch check_batch_name into l_dummy;
  if check_batch_name%found then
	retcode := -1;
        fnd_message.set_name('PQH', 'PQH_PLG_DUP_BATCH');
        fnd_message.set_token('BATCH_NAME', p_batch_name);
        errbuf := fnd_message.get;
        FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, errbuf);
    	return;
  end if;
  --
  hr_utility.set_location('Entering'|| l_proc_name, 13);
  --
  l_effective_date	:= fnd_date.canonical_to_date(p_effective_date);
  l_start_date		:= fnd_date.canonical_to_date(p_start_date);
  l_end_date		:= fnd_date.canonical_to_date(p_end_date);
  --
  -- Fetch the batch Id into the l_batch_id
  --
  open c_batch;
  fetch c_batch into l_batch_id;
  close c_batch;
  --
  hr_utility.set_location('l_batch_id : '||l_batch_id ||' - ' || l_proc_name, 15);
  --
  -- Create the start record into the  Process Log
  --
  pqh_process_batch_log.start_log
  (
   p_batch_id         =>l_batch_id,
   p_module_cd        =>'POSITION_BUDGET_ANALYSIS',
   p_log_context      =>p_batch_name,
   p_information3     =>p_effective_date,
   p_information5     =>p_start_date,
   p_information6     =>p_end_date,
   p_information8     =>'GRADE',
   p_information9     =>p_unit_of_measure
   );
  --
  --
  -- Fetch table route Id for the Grade table(GRD)
  --
  open c_table_route('GRD');
  fetch c_table_route into l_table_route_id;
  -- Set table route id to null if the table route is not defined for GRD
  if c_table_route%notfound then
     l_table_route_id := null;
  end if;
    --
  close c_table_route;

  hr_utility.set_location('l_table_route_id  : '||l_table_route_id ||' '|| l_proc_name, 102);
  --
  --  Check for the type of the cofigurable message(PQH_UNDER_BGT_POSITIONS)
  --
  pqh_utility.set_message(8302,'PQH_UNDER_BGT_POSITIONS',200);
  pqh_utility.set_message_token('UOM',
                  hr_general.decode_lookup('BUDGET_MEASUREMENT_TYPE',p_unit_of_measure));
  pqh_utility.set_message_token('ENTITY',
                  hr_general.decode_lookup('PQH_BUDGET_ENTITY','GRADE'));

  --
  hr_utility.set_location('after pqh_utility.set_message  : '|| l_proc_name, 103);
  --
  l_message_type_cd := pqh_utility.get_message_type_cd;
  l_message := pqh_utility.get_message;
  --
  hr_utility.set_location('after pqh_utility.get_message  : '||l_message_type_cd|| l_proc_name, 104);
  --
  if l_message_type_cd in ('E','W') then
    if l_message_type_cd = 'E' then
      l_message_type := 'ERROR';
    else
      l_message_type := 'WARNING';
    end if;
    hr_utility.set_location('before pqh_process_batch_log.set_context_level  : '||
                                l_message_type_cd||l_proc_name, 105);
    hr_utility.set_location('before pqh.set_context_level  l_table_route_id: '||
                                l_table_route_id, 105);
    --
    --  Set the Process Log Context level....What should it be?
    --
    /*pqh_process_batch_log.set_context_level
    (
     p_txn_id               =>l_organization.organization_id,
     p_txn_table_route_id   =>l_table_route_id,
     p_level                =>l_organization.level1 + 1,
    p_log_context          =>hr_general.decode_organization(l_organization.organization_id)
    ); */
    --
    --
    fnd_file.put_line(FND_FILE.LOG,'Primary Entity => ''GRADE''' || ' Unit of Measure => '||p_unit_of_measure);
    fnd_file.put_line(FND_FILE.LOG,'                                                       ');
    fnd_file.put_line(FND_FILE.LOG,'Name    Budgeted Value   Reallocated Value   Actual Value   Commitment Value   Under Budgeted Value  Under Budgeted Date');
    fnd_file.put_line(FND_FILE.LOG,'                                                       ');
    --
    -- Fetch Grades
    --
    for l_grade in c_grades(l_effective_date, l_start_date, l_end_date)
    loop

      hr_utility.set_location('l_grade_id : '||l_grade.grade_id|| ' - ' || substr(l_grade.name,1,40) , 110);

      if p_unit_of_measure = 'MONEY' then
        --
        -- Get the Budgeted Salary of the Grade for the given start date and end date
        --
        l_budgeted_val        := pqh_budgeted_salary_pkg.get_pc_budgeted_salary(
                                   p_grade_id           => l_grade.grade_id
                                  ,p_start_date         => l_start_date
                                  ,p_end_date           => l_end_date
                                  ,p_effective_date     => l_effective_date
                                  ,p_business_group_id  => p_business_group_id
                                  ,p_budget_entity      => 'GRADE'
                                  );
        --
        -- Get the Reallocation amount(Money) of the Grade between the given start date and end date
        --
        l_reallocation_val        := pqh_reallocation_pkg.get_reallocation(
                                   p_grade_id           => l_grade.grade_id
                                  ,p_start_date         => l_start_date
                                  ,p_end_date           => l_end_date
                                  ,p_effective_date     => l_effective_date
                                  ,p_budget_entity      => 'GRADE'
                                  ,p_system_budget_unit => 'MONEY'
                                  ,p_business_group_id  => p_business_group_id
                                  );
	pqh_bdgt_actual_cmmtmnt_pkg.get_actual_and_cmmtmnt(
				  p_grade_id       	=> l_grade.grade_id
                                 ,p_start_date        	=> l_start_date
                                 ,p_end_date          	=> l_end_date
                                 ,p_effective_date	=> l_effective_date
                                 ,p_budget_entity       => 'GRADE'
                                , p_actual_value	=> l_actual_val
				, p_commt_value         => l_commitment_val
				-- p_total_amount         => l_actual_commitment_sal --to be checked
				 ,p_unit_of_measure  => 'MONEY'
				 , p_business_group_id   => p_business_group_id
                                 );
        --
        l_currency_code := get_budget_currency(
                                   p_grade_id => l_grade.grade_id
                                  ,p_budget_entity      => 'GRADE'
                                  ,p_start_date         => l_start_date
                                  ,p_end_date           => l_end_date
                                  ,p_effective_date     => l_effective_date
                                  ,p_business_group_id  => p_business_group_id
                                  );
        --
        -- Print the details of the grade
        --
        hr_utility.set_location('Grade : '||l_grade.grade_id
				||' '||l_proc_name, 130);
        hr_utility.set_location('Budgeted Value     : '||l_budgeted_val
				||' '||l_proc_name, 140);
        hr_utility.set_location('Reallocation Value : '||nvl(l_reallocation_val,0)
				||' '||l_proc_name, 140);
        hr_utility.set_location('Actual Value       : '||nvl(l_actual_val,0)
				||' '||l_proc_name, 150);
        hr_utility.set_location('Commitment Value   : '||nvl(l_commitment_val,0)
				||' '||l_proc_name, 160);
        hr_utility.set_location('Actual + Commitment Value : '||nvl(l_actual_commitment_val,0)
				||' '||l_proc_name, 160);
        --
        -- Check, whether the Grade is Under Budgeted
        --
        if l_budgeted_val is not null then
          if (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0) < nvl(l_actual_val,0) + nvl(l_commitment_val,0)) then
	    --
            -- If Under Budgeted
            --

            --
            -- Fetch table route Id for the Position table(PSF)
            --
           /* open c_table_route('PSF');
            fetch c_table_route into l_table_route_id;
            -- Set table route id to null if the table route is not defined for PSF
            if c_table_route%notfound then
              l_table_route_id := null;
            end if;
            --
            close c_table_route;

            l_user_name := null;
            --
            open c_user_name(l_position.position_id);
            fetch c_user_name into l_user_name;
            close c_user_name; */
            --
            --
            l_under_budget_val := (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) - (nvl(l_actual_val,0) + nvl(l_commitment_val,0));
            --
     fnd_file.put_line(FND_FILE.LOG,l_grade.name||'    '||l_budgeted_val||'   '||l_reallocation_val||'   '||l_actual_val||'   '||l_commitment_val||'   '||l_under_budget_val||'  ');
            --
            --  Set the Process Log Context Level for the grade
            --
            pqh_process_batch_log.set_context_level
            (
             p_txn_id               =>l_grade.grade_id,
             p_txn_table_route_id   =>l_table_route_id, -- later
             p_level                =>1,
             p_log_context          =>hr_general.decode_grade(l_grade.grade_id)
            );

            --
            --  Insert the Log for the grade
            --
            pqh_process_batch_log.insert_log
            (
             p_message_type_cd  =>l_message_type,
             p_message_text     =>l_message,
             p_information3	=>round(l_budgeted_val,2),
             p_information4	=>round(l_reallocation_val,2),
             p_information5	=>round(l_actual_val,2),
             p_information6	=>round(l_commitment_val,2),
             p_information8     =>'GRADE',
             p_information9     =>p_unit_of_measure,
             p_information10    =>l_under_bgt_date,
             p_information11    =>p_batch_name,
             p_information12    =>'REPORT',
             p_information13    => l_currency_code
            );

            --
            hr_utility.set_location(l_grade.grade_id || ' is under budgeted'
				||' '||l_proc_name, 170);
            --
          end if;--for under budget
	end if; --14/05/02

      elsif p_unit_of_measure = 'HOURS' then
        --
        -- Get the Budgeted hours of the Grade for the given start date and end date
        --
        l_budgeted_val  := pqh_budgeted_salary_pkg.get_budgeted_hours
                             (p_grade_id           => l_grade.grade_id
                             ,p_start_date         => l_start_date
                             ,p_end_date           => l_end_date
                             ,p_effective_date     => l_effective_date
                             ,p_budget_entity      => 'GRADE'
                             ,p_business_group_id  => p_business_group_id
                              );

        --
        -- Get the Reallocation hours of the Grade between the given start date and end date
        --
        l_reallocation_val  := pqh_reallocation_pkg.get_reallocation
                            (p_grade_id           => l_grade.grade_id
                            ,p_start_date         => l_start_date
                            ,p_end_date           => l_end_date
                            ,p_effective_date     => l_effective_date
                            ,p_budget_entity      => 'GRADE'
                            ,p_system_budget_unit => 'HOURS'
                            ,p_business_group_id  => p_business_group_id
                             );
        --
        --Get the Actual hours of the Grade between the given start date and end date
        --
        pqh_bdgt_actual_cmmtmnt_pkg.get_actual_and_cmmtmnt
        		    ( p_grade_id           => l_grade.grade_id
			    , p_start_date         => l_start_date
		            , p_end_date	   => l_end_date
		            , p_effective_date      => l_effective_date
		            , p_budget_entity      => 'GRADE'
		            , p_unit_of_measure    => 'HOURS'
		            , p_business_group_id  => p_business_group_id
                            , p_actual_value	   => l_actual_val
  			    , p_commt_value        => l_commitment_val
		             );

        --
        -- Print the details of the Grade
        --
        hr_utility.set_location('Grade : '||l_grade.grade_id
				||' '||l_proc_name, 130);
        hr_utility.set_location('Budgeted Hours     : '||l_budgeted_val
				||' '||l_proc_name, 140);
        hr_utility.set_location('Reallocation Hours: '||nvl(l_reallocation_val,0)
				||' '||l_proc_name, 140);
        hr_utility.set_location('Actual Hours       : '||nvl(l_actual_val,0)
				||' '||l_proc_name, 150);

        if l_budgeted_val is not null then
          if (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) < nvl(l_actual_val,0) then

	    --
            -- If Under Budgeted
            --
            l_under_budget_val := (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) - nvl(l_actual_val,0);
            --
	    -- New table route --pqcptca.ldt---also change in Process log form
            --
            -- Fetch table route Id for the Job table
            --
            /*open c_table_route('PSF');
            fetch c_table_route into l_table_route_id;
            -- Set table route id to null if the table route is not defined for PSF
            if c_table_route%notfound then
              l_table_route_id := null;
            end if;
            --
            close c_table_route;
            --
            l_user_name := null;
            --
            open c_user_name(l_position.position_id);
            fetch c_user_name into l_user_name;
            close c_user_name; */
            --
            --
            --
       fnd_file.put_line(FND_FILE.LOG,l_grade.name||'    '||l_budgeted_val||'   '||l_reallocation_val||'   '||l_actual_val||'   '||0||'   '||l_under_budget_val||'  ');
            --
            --  Set the Process Log Context Level for the Grade
            --
            pqh_process_batch_log.set_context_level
            (
             p_txn_id               =>l_grade.grade_id,
             p_txn_table_route_id   =>l_table_route_id,
             p_level                =>1,
             p_log_context          =>hr_general.decode_grade(l_grade.grade_id)
            );

            --
            --  Insert the Log for the Grade
            --
            pqh_process_batch_log.insert_log
            (
             p_message_type_cd  =>l_message_type,
             p_message_text     =>l_message,
             p_information3	=>round(l_budgeted_val,2),
             p_information4	=>round(l_reallocation_val,2),
             p_information5	=>round(l_actual_val,2),
             p_information7	=>null,
             p_information8     =>'GRADE',
             p_information9     =>p_unit_of_measure,
             p_information10    =>l_under_bgt_date,
             p_information11    =>p_batch_name,
             p_information12    =>'REPORT'

            );


   	  end if;
	end if; --14/05/02

      else -- p_unit_of_measure is 'FTE' or 'Headcount' etc

        --
        -- Get the Budgeted FTE or Headcount of the Grade for the given start date and end date
        --

	l_budgeted_val  := pqh_psf_bus.get_budgeted_fte
                             (p_grade_id           => l_grade.grade_id
                             ,p_start_date         => l_start_date
                             ,p_end_date           => l_end_date
                             ,p_budget_entity      => 'GRADE'
                             ,p_unit_of_measure    => p_unit_of_measure
                             ,p_business_group_id  => p_business_group_id
                             ,p_budgeted_fte_date  => l_budgeted_fte_date
                              );

        --
        -- Get the Reallocation FTE or Headcount of the Grade between the given start date and end date
        --
        l_reallocation_val  := pqh_reallocation_pkg.get_reallocation
                            (p_grade_id           => l_grade.grade_id
                            ,p_start_date         => l_start_date
                            ,p_end_date           => l_end_date
                            ,p_effective_date     => l_effective_date
                            ,p_budget_entity      => 'GRADE'
                            ,p_system_budget_unit => p_unit_of_measure
                            ,p_business_group_id  => p_business_group_id
                             );
        --
        --Get the Actual FTE or Headcount of the Grade between the given start date and end date
        --
        pqh_bdgt_actual_cmmtmnt_pkg.get_actual_and_cmmtmnt
        		    (p_grade_id            => l_grade.grade_id
			    , p_start_date         => l_start_date
		            , p_end_date	   => l_end_date
		            , p_effective_date     => l_effective_date
		            , p_budget_entity      => 'GRADE'
		            , p_unit_of_measure    => p_unit_of_measure
		            , p_business_group_id  => p_business_group_id
                            , p_actual_value	=> l_actual_val
		            , p_commt_value         => l_commitment_val
		             );

        --
        -- Print the details of the Grade
        --
        hr_utility.set_location('Grade : '||l_grade.grade_id
				||' '||l_proc_name, 130);
        hr_utility.set_location('Unit of measure : '||p_unit_of_measure
				||' '||l_proc_name, 130);
        hr_utility.set_location('Budgeted      : '||l_budgeted_val
				||' '||l_proc_name, 140);
        hr_utility.set_location('Reallocation: '||nvl(l_reallocation_val,0)
				||' '||l_proc_name, 140);
        hr_utility.set_location('Actual       : '||nvl(l_actual_val,0)
				||' '||l_proc_name, 150);

        if l_budgeted_val is not null then
   	  if (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) < nvl(l_actual_val,0) then

	    --
            -- If Under Budgeted
            --
	    l_under_budget_val := (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) - nvl(l_actual_val,0);
            --
            -- Fetch table route Id for the Position table(PSF)
            --
            /*open c_table_route('PSF');
            fetch c_table_route into l_table_route_id;
            -- Set table route id to null if the table route is not defined for PSF
            if c_table_route%notfound then
              l_table_route_id := null;
            end if;
            --
            close c_table_route;
            --
            l_user_name := null;
            --
            open c_user_name(l_position.position_id);
            fetch c_user_name into l_user_name;
            close c_user_name; */
            --
            --
            --
       fnd_file.put_line(FND_FILE.LOG,l_grade.name||'    '||l_budgeted_val||'   '||l_reallocation_val||'   '||l_actual_val||'   '||0||'   '||l_under_budget_val||'  '||l_budgeted_fte_date);
            --
            --  Set the Process Log Context Level for the grade
            --
            pqh_process_batch_log.set_context_level
            (
             p_txn_id               =>l_grade.grade_id,
             p_txn_table_route_id   =>l_table_route_id,
             p_level                =>1,
             p_log_context          =>hr_general.decode_grade(l_grade.grade_id)
            );

            --
            --  Insert the Log for the grade
            --
            pqh_process_batch_log.insert_log
            (
             p_message_type_cd  =>l_message_type,
             p_message_text     =>l_message,
             p_information3	=>round(l_budgeted_val,2),
             p_information4	=>round(l_reallocation_val,2),
             p_information5	=>round(l_actual_val,2),
             p_information7	=>null,
             p_information8     =>'GRADE',
             p_information9     =>p_unit_of_measure,
             p_information10    =>to_char(l_budgeted_fte_date,'RRRR/MM/DD'),
             p_information11    =>p_batch_name,
             p_information12    =>'REPORT'
            );

            --
            hr_utility.set_location(l_grade.grade_id || ' is under budgeted'
				||' '||l_proc_name, 170);
            --
 	  end if;
	end if; --14/05/02


      end if;--for uom
        --
    end loop;
    --
    end if;
    --
  --
  -- End the Process Log
  --
  pqh_process_batch_log.end_log;
            hr_utility.set_location('End Process'
				||' '||l_proc_name, 180);
  commit;
  exception
  when others then
    retcode := -1;
  --
end;
--
-- ORGANIZATION TEMP
--
procedure org_temp(p_organization_id number
                          ,p_level1 number
                          ,p_batch_name	            varchar2
                          ,p_unit_of_measure        varchar2
                          ,p_business_group_id      number
                          ,p_effective_date         date
                          ,p_start_date             date
                          ,p_end_date               date
) is
  l_proc_name     varchar2(61) := 'org_temp' ;
  l_org_name      hr_all_organization_units.name%type;
  --
  -- Cursor to fetch Organization name
  --
  cursor c_org_name(p_org_id number) is
  select name
    from hr_all_organization_units u
   where organization_id = p_org_id;
  --
  --
  -- Cursor to fetch the table_route_id of the table_alias
  --
  cursor c_table_route(p_table_alias varchar2) is
  SELECT
  	table_route_id
  from
  	pqh_table_route
  where
  	table_alias = p_table_alias;
  --
  -- Local Variables
  --
  l_budgeted_val                  number;
  l_reallocation_val              number;
  l_actual_val                    number;
  l_commitment_val                number;
  l_actual_commitment_val	  number;
  l_under_budget_val              number;
  l_budgeted_fte_date             date;
  --
  l_table_route_id                number;
  l_user_name			  varchar2(30);
  --
  l_message_type_cd		  varchar2(10);
  l_message_type		  varchar2(100);
  l_message    		  	  varchar2(1000);
  l_under_bgt_date                varchar2(100);
  --
  l_currency_code                 varchar2(40);
  --
BEGIN
    hr_utility.set_location('organization  : '||p_organization_id ||' '|| l_proc_name, 101);

    open c_org_name(p_organization_id);
    fetch c_org_name into l_org_name;
    close c_org_name;
    --
    -- Fetch table route Id for the Organization table(ORU)
    --
    open c_table_route('ORU');
    fetch c_table_route into l_table_route_id;
    -- Set table route id to null if the table route is not defined for ORU
    if c_table_route%notfound then
       l_table_route_id := null;
    end if;
    --
    close c_table_route;

    hr_utility.set_location('l_table_route_id  : '||l_table_route_id ||' '|| l_proc_name, 102);
    --
    --  Check for the type of the cofigurable message(PQH_UNDER_BGT_POSITIONS)
    --
    pqh_utility.set_message(8302,'PQH_UNDER_BGT_POSITIONS', p_organization_id);
    --
    pqh_utility.set_message_token('UOM',
                  hr_general.decode_lookup('BUDGET_MEASUREMENT_TYPE',p_unit_of_measure));
    pqh_utility.set_message_token('ENTITY',
                  hr_general.decode_lookup('PQH_BUDGET_ENTITY','ORGANIZATION'));

    hr_utility.set_location('after pqh_utility.set_message  : '|| l_proc_name, 103);
    --
    l_message_type_cd := pqh_utility.get_message_type_cd;
    l_message := pqh_utility.get_message;
    --
    hr_utility.set_location('after pqh_utility.get_message  : '||l_message_type_cd|| l_proc_name, 104);
    --
    if l_message_type_cd in ('E','W') then
      if l_message_type_cd = 'E' then
        l_message_type := 'ERROR';
      else
        l_message_type := 'WARNING';
      end if;
      hr_utility.set_location('before pqh_process_batch_log.set_context_level  : '||
                         l_message_type_cd||l_proc_name, 105);
      hr_utility.set_location('before pqh.set_context_level  organization_id: '||
                                  p_organization_id, 105);
      hr_utility.set_location('before pqh.set_context_level  l_table_route_id: '||
                                  l_table_route_id, 105);
      hr_utility.set_location('l_orglevel1: '||
                                  p_level1, 105);
      hr_utility.set_location('org name: '||
          hr_general.decode_organization(p_organization_id), 105);
      --
      --  Set the Process Log Context level for the Organization
      --
      pqh_process_batch_log.set_context_level
      (
       p_txn_id               =>p_organization_id,
       p_txn_table_route_id   =>l_table_route_id,
       p_level                =>p_level1 + 1,
       p_log_context          =>hr_general.decode_organization(P_organization_id)
      );
      --
      hr_utility.set_location('Organization : '||p_organization_id
		               	|| ' ' ||l_proc_name, 110);

      if p_unit_of_measure = 'MONEY' then
        --
        -- Get the Budgeted Salary of the organization for the given start date and end date
        --
        l_budgeted_val        := pqh_budgeted_salary_pkg.get_pc_budgeted_salary(
                                   p_organization_id    => p_organization_id
                                  ,p_budget_entity      => 'ORGANIZATION'
                                  ,p_start_date         => p_start_date
                                  ,p_end_date           => p_end_date
                                  ,p_effective_date     => p_effective_date
                                  ,p_business_group_id  => p_business_group_id
                                  );
        --
        -- Get the Reallocation amount(Money) of the organization between the given start date and end date
        --
        l_reallocation_val        := pqh_reallocation_pkg.get_reallocation(
                                   p_organization_id    => p_organization_id
                                  ,p_start_date         => p_start_date
                                  ,p_end_date           => p_end_date
                                  ,p_effective_date     => p_effective_date
                                  ,p_budget_entity      => 'ORGANIZATION'
                                  ,p_system_budget_unit => 'MONEY'
                                  ,p_business_group_id  => p_business_group_id
                                  );
        pqh_bdgt_actual_cmmtmnt_pkg.get_actual_and_cmmtmnt(
			                 	  p_organization_id     => p_organization_id
                                 ,p_start_date        	=> p_start_date
                                 ,p_end_date          	=> p_end_date
                                 ,p_effective_date	    => p_effective_date
		                         ,p_budget_entity       => 'ORGANIZATION'
                                 ,p_actual_value	    => l_actual_val
		                  		 ,p_commt_value         => l_commitment_val
                				 -- p_total_amount         => l_actual_commitment_sal
		                  		 ,p_unit_of_measure     => 'MONEY'
				                 ,p_business_group_id   => p_business_group_id
                                 );
        --
        l_currency_code := get_budget_currency(
                                   p_organization_id    => p_organization_id
                                  ,p_budget_entity      => 'ORGANIZATION'
                                  ,p_start_date         => p_start_date
                                  ,p_end_date           => p_end_date
                                  ,p_effective_date     => p_effective_date
                                  ,p_business_group_id  => p_business_group_id
                                  );
        --
        -- Print the details of the organization
        --
        hr_utility.set_location('Organization : '||p_organization_id
                    				||' '||l_proc_name, 130);
        hr_utility.set_location('Budgeted Salary     : '||l_budgeted_val
                    				||' '||l_proc_name, 140);
        hr_utility.set_location('Budget Reallocation : '||nvl(l_reallocation_val,0)
                    				||' '||l_proc_name, 140);
        hr_utility.set_location('Actual Salary       : '||nvl(l_actual_val,0)
                    				||' '||l_proc_name, 150);
        hr_utility.set_location('Commitment Salary   : '||nvl(l_commitment_val,0)
                    				||' '||l_proc_name, 160);
        hr_utility.set_location('Actual + Commitment Salary : '||nvl(l_actual_commitment_val,0)
                    				||' '||l_proc_name, 160);
        --
        -- Check, whether the organization is Under Budgeted
        --
        if l_budgeted_val is not null then
          if (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0) < nvl(l_actual_val,0) + nvl(l_commitment_val,0)) then
       	    --
            -- If Under Budgeted
            --
            --
            -- Fetch table route Id for the organization table(PSF)
            --
            --
            l_under_budget_val := (nvl(l_budgeted_val,0) +
                               nvl(l_reallocation_val,0)) - (nvl(l_actual_val,0)
                               + nvl(l_commitment_val,0));
            --
            --
            fnd_file.put_line(FND_FILE.LOG,l_org_name||'    '||l_budgeted_val||
                        '   '||l_reallocation_val||'   '||l_actual_val||'   '||
                        l_commitment_val||'   '||l_under_budget_val||'  ');
            --
            --  Set the Process Log Context Level for the Organization
            --
/*
            pqh_process_batch_log.set_context_level
            (
             p_txn_id               =>l_organization.organization_id,
             p_txn_table_route_id   =>l_table_route_id,
             p_level                =>l_organization.level1+2,
             p_log_context          =>hr_general.decode_organization(l_organization.organization_id)
            );
*/
            --
            --  Insert the Log for the organization
            --
            pqh_process_batch_log.insert_log
            (
             p_message_type_cd  =>l_message_type,
             p_message_text     =>l_message,
             p_information3	=>round(l_budgeted_val,2),
             p_information4	=>round(l_reallocation_val,2),
             p_information5	=>round(l_actual_val,2),
             p_information6	=>round(l_commitment_val,2),
             p_information7	=>l_user_name,
             p_information8     =>'ORGANIZATION',
             p_information9     =>p_unit_of_measure,
             p_information10    =>l_under_bgt_date,
             p_information11    =>p_batch_name,
             p_information12    =>'REPORT',
             p_information13    => l_currency_code
            );
            --
            hr_utility.set_location(p_organization_id ||
                  ' is under budgeted'	||' '||l_proc_name, 170);
            --
          end if;--for under budget
	       end if;

      elsif p_unit_of_measure = 'HOURS' then
        --
        -- Get the Budgeted hours of the organization for the given start date and end date
        --
        l_budgeted_val  := pqh_budgeted_salary_pkg.get_budgeted_hours
                             (p_organization_id    => p_organization_id
                             ,p_start_date         => p_start_date
                             ,p_end_date           => p_end_date
                             ,p_effective_date     => p_effective_date
                             ,p_budget_entity      => 'ORGANIZATION'
                             ,p_business_group_id  => p_business_group_id
                              );

        --
        -- Get the Reallocation hours of the organization between the given start date and end date
        --
        l_reallocation_val  := pqh_reallocation_pkg.get_reallocation
                            (p_organization_id    => p_organization_id
                            ,p_start_date         => p_start_date
                            ,p_end_date           => p_end_date
                            ,p_effective_date     => p_effective_date
                            ,p_budget_entity      => 'ORGANIZATION'
                            ,p_system_budget_unit => 'HOURS'
                            ,p_business_group_id  => p_business_group_id
                             );
        --
        --Get the Actual hours of the organization between the given start date and end date
        --
        pqh_bdgt_actual_cmmtmnt_pkg.get_actual_and_cmmtmnt
        		    ( p_organization_id    => p_organization_id
                     ,p_start_date         => p_start_date
                     ,p_end_date	       => p_end_date
		             ,p_effective_date     => p_effective_date
		             ,p_budget_entity      => 'ORGANIZATION'
		             ,p_unit_of_measure    => 'HOURS'
		             ,p_business_group_id  => p_business_group_id
                     ,p_actual_value	   => l_actual_val
		             ,p_commt_value        => l_commitment_val
		             );

        --
        -- Print the details of the organization
        --
        hr_utility.set_location('Organization : '||p_organization_id
		             		||' '||l_proc_name, 130);
        hr_utility.set_location('Budgeted Hours     : '||l_budgeted_val
		             		||' '||l_proc_name, 140);
        hr_utility.set_location('Reallocation Hours: '||nvl(l_reallocation_val,0)
		             		||' '||l_proc_name, 140);
        hr_utility.set_location('Actual Hours       : '||nvl(l_actual_val,0)
		             		||' '||l_proc_name, 150);

        if l_budgeted_val is not null then
	         if (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0))
                                              < nvl(l_actual_val,0) then

	           --
            -- If Under Budgeted
            --
            l_under_budget_val := (nvl(l_budgeted_val,0)
                         + nvl(l_reallocation_val,0)) - nvl(l_actual_val,0);
            --
	           fnd_file.put_line(FND_FILE.LOG,l_org_name||'    '||
                         l_budgeted_val||'   '||l_reallocation_val||'   '||
                         l_actual_val||'   '||l_commitment_val||'   '||
                         l_under_budget_val||'  ');
            --
            --  Set the Process Log Context Level for the organization
            --
/*
            pqh_process_batch_log.set_context_level
            (
             p_txn_id               =>l_organization.organization_id,
             p_txn_table_route_id   =>l_table_route_id,
             p_level                =>l_organization.level1+2,
             p_log_context          =>hr_general.decode_organization(l_organization.organization_id)
            );
*/
            --
            --  Insert the Log for the organization
            --
            pqh_process_batch_log.insert_log
            (
             p_message_type_cd  =>l_message_type,
             p_message_text     =>l_message,
             p_information3	=>round(l_budgeted_val,2),
             p_information4	=>round(l_reallocation_val,2),
             p_information5	=>round(l_actual_val,2),
             p_information7	=>l_user_name,
             p_information8     =>'ORGANIZATION',
             p_information9     =>p_unit_of_measure,
             p_information10    =>l_under_bgt_date,
             p_information11    =>p_batch_name,
             p_information12    =>'REPORT'
            );

            hr_utility.set_location(p_organization_id ||
                  ' is under budgeted'	||' '||l_proc_name, 170);
            --

   	  end if;
	end if;

      else -- p_unit_of_measure is 'FTE' or 'Headcount' etc

        --
        -- Get the Budgeted FTE or Headcount of the organization for the given start date and end date
        --

	       l_budgeted_val  := pqh_psf_bus.get_budgeted_fte
                             (p_organization_id    => p_organization_id
                             ,p_start_date         => p_start_date
                             ,p_end_date           => p_end_date
                             ,p_budget_entity      => 'ORGANIZATION'
                             ,p_unit_of_measure    => p_unit_of_measure
                             ,p_business_group_id  => p_business_group_id
                             ,p_budgeted_fte_date  => l_budgeted_fte_date
                              );

        --
        -- Get the Reallocation FTE or Headcount of the organization between the given start date and end date
        --
        l_reallocation_val  := pqh_reallocation_pkg.get_reallocation
                            (p_organization_id    => p_organization_id
                            ,p_start_date         => p_start_date
                            ,p_end_date           => p_end_date
                            ,p_effective_date     => p_effective_date
                            ,p_budget_entity      => 'ORGANIZATION'
                            ,p_system_budget_unit => p_unit_of_measure
                            ,p_business_group_id  => p_business_group_id
                             );
        --
        --Get the Actual FTE or Headcount of the organization between the given start date and end date
        --
        pqh_bdgt_actual_cmmtmnt_pkg.get_actual_and_cmmtmnt
        		    ( p_organization_id    => p_organization_id
			        , p_start_date         => p_start_date
		            , p_end_date	       => p_end_date
		            , p_effective_date     => p_effective_date
		            , p_budget_entity      => 'ORGANIZATION'
		            , p_unit_of_measure    => p_unit_of_measure
		            , p_business_group_id  => p_business_group_id
                    , p_actual_value	   => l_actual_val
 		            , p_commt_value        => l_commitment_val
		             );

        --
        -- Print the details of the organization
        --
        hr_utility.set_location('Organization : '||p_organization_id
				||' '||l_proc_name, 130);
        hr_utility.set_location('Unit of measure : '||p_unit_of_measure
				||' '||l_proc_name, 130);
        hr_utility.set_location('Budgeted      : '||l_budgeted_val
				||' '||l_proc_name, 140);
        hr_utility.set_location('Reallocation: '||nvl(l_reallocation_val,0)
				||' '||l_proc_name, 140);
        hr_utility.set_location('Actual       : '||nvl(l_actual_val,0)
				||' '||l_proc_name, 150);

        if l_budgeted_val is not null then
 	  if (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) < nvl(l_actual_val,0) then

	    --
            -- If Under Budgeted
            l_under_budget_val := (nvl(l_budgeted_val,0) + nvl(l_reallocation_val,0)) - nvl(l_actual_val,0);
            --
            --
         fnd_file.put_line(FND_FILE.LOG,l_org_name||'    '||l_budgeted_val||'   '||l_reallocation_val||'   '||l_actual_val||'   '||l_commitment_val||'   '||l_under_budget_val||'  '||l_budgeted_fte_date);
            --
            --  Set the Process Log Context Level for the organization
            --
/*
            pqh_process_batch_log.set_context_level
            (
             p_txn_id               =>l_organization.organization_id,
             p_txn_table_route_id   =>l_table_route_id,
             p_level                =>l_organization.level1+2,
             p_log_context          =>hr_general.decode_organization(l_organization.organization_id)
            );
*/
            --
            --  Insert the Log for the organization
            --
            pqh_process_batch_log.insert_log
            (
             p_message_type_cd  =>l_message_type,
             p_message_text     =>l_message,
             p_information3	=>round(l_budgeted_val,2),
             p_information4	=>round(l_reallocation_val,2),
             p_information5	=>round(l_actual_val,2),
             p_information7	=>l_user_name,
             p_information8     =>'ORGANIZATION',
             p_information9     =>p_unit_of_measure,
             p_information10    =>to_char(l_budgeted_fte_date,'YYYY/MM/DD'), --l_under_bgt_date,
             p_information11    =>p_batch_name,
             p_information12    =>'REPORT'
            );
            --
            hr_utility.set_location(p_organization_id ||
                           ' is under budgeted'	||' '||l_proc_name, 170);
            --
 	        end if;
       	end if;
      end if;--for uom
      --
    end if;
    --
end;


--
-- ORGANIZATION
--
--
--To calculate the Under budgeted positions for all units of measure...
--
Procedure organization_analysis(
	  errbuf		out nocopy varchar2
        , retcode		out nocopy varchar2
        , p_batch_name			varchar2
        , p_effective_date 		varchar2
        , p_start_org_id 		number
        , p_org_structure_id		number
        , p_start_date  		varchar2
        , p_end_date     		varchar2
        , p_unit_of_measure             varchar2
	, p_business_group_id		number
) is
  --
  l_proc_name	        varchar2(30) := 'ORGANIZATION_ANALYSIS';
  --
  l_dummy		varchar2(50);
  l_effective_date	date;
  l_start_date		date;
  l_end_date		date;
  l_start_org_id    number;
  l_error_msg		varchar2(1000);
  l_parameter1_value    varchar2(100);
  l_parameter2_value    varchar2(100);
  l_parameter3_value    varchar2(100);
  l_parameter4_value    varchar2(100);
  l_parameter5_value    varchar2(100);
  l_parameter6_value    varchar2(100);
  l_parameter7_value    varchar2(100);
  l_parameter8_value    varchar2(100);
  l_parameter9_value    varchar2(100);
  --
  -- Cursor to Fetch the Organization Structure Version
  --
  cursor c_org_version(p_effective_date  date) is
  select ver.org_structure_version_id
  from 	 per_organization_structures str
       , per_org_structure_versions ver
  where	str.position_control_structure_flg = 'Y'
  and   str.organization_structure_id = p_org_structure_id
  and   str.business_group_id = p_business_group_id
  and   ver.business_group_id = p_business_group_id
  and	str.organization_structure_id = ver.organization_structure_id
  and 	p_effective_date between ver.date_from and nvl(date_to, hr_general.end_of_time);
  --
  -- Cursor to fetch the top Org of Hierarchy
  --
  cursor c_top_org(p_org_structure_version_id number) is
  select organization_id_parent organization_id
  from per_org_structure_elements a
  where org_structure_version_id = p_org_structure_version_id
  and not exists (
    select organization_id_child organization_id
    from per_org_structure_elements b
    where org_structure_version_id = p_org_structure_version_id
    and b.organization_id_child = a.organization_id_parent
    )
  and rownum <2;
  --
  -- Cursor to Fetch the Organizations for the given Organization Hierarchy
  --
  -- Bug Fix : 2464692  : Change : added p_effective_date parameter
  --
  cursor c_org(p_org_structure_version_id number, p_start_org_id number,p_effective_date date) is
  select 0 rn,
  	     0 level1,
         organization_id
        from  hr_all_organization_units u
        where organization_id = p_start_org_id
        and   business_group_id = p_business_group_id
        and exists
        (select null from per_org_structure_elements e
         where e.org_structure_version_id = p_org_structure_version_id
         and  (e.organization_id_child = p_start_org_id
         or    e.organization_id_parent = p_start_org_id) )
  union
  select rownum rn,
  	 level level1,
	 organization_id_child organization_id
  from   per_org_structure_elements a
  start with
  	organization_id_parent = p_start_org_id
  and   org_structure_version_id = p_org_structure_version_id
  connect by
  	organization_id_parent = prior organization_id_child
  and 	org_structure_version_id = p_org_structure_version_id;
    --
    -- Bug Fix : 2464692
    -- Retrives all Internal Organizations under the given business group
    -- as on that effective date in case of p_start_org_id and
    -- p_org_structure_id are null
    --
   cursor c_all_org(p_business_group_id number, p_effective_date date) is
    select   rownum rn,
      	   0 level1,
             organization_id
    from hr_all_organization_units
    where business_group_id = p_business_group_id
    and INTERNAL_EXTERNAL_FLAG ='INT'
    and p_effective_date between date_from and nvl(date_to, hr_general.end_of_time);
  --
  -- Cursor that checks the batch existance
  --
  cursor check_batch_name(p_batch_name varchar2)  is
  select 'x'
  from 	 pqh_process_log
  where  log_context=p_batch_name;

  --
  -- Cursor to get the next batch Id for the Process Log
  --
  cursor c_batch is
  select
  	pqh_process_log_s.nextval
  from
  	dual;
  --
  -- Cursor to select workflow sequence no
  --
  cursor c_wf_seq_no is
  select pqh_wf_notifications_s.nextval
  from dual;
  --
  -- Local Variables
  --
  l_org_structure_version_id     number;
  --
  l_batch_id                      number;
  --
  l_workflow_seq_no		  number;
  l_apply_error_mesg		  varchar2(100);
  l_apply_error_num		  varchar2(100);
  --
  begin
  --
  hr_utility.set_location('Entering'|| l_proc_name, 10);
  retcode := 0;
  --
  hr_utility.set_location('Entering'|| l_proc_name, 11);
  --
  open check_batch_name(p_batch_name);
  fetch check_batch_name into l_dummy;
  if check_batch_name%found then
	retcode := -1;
        fnd_message.set_name('PQH', 'PQH_PLG_DUP_BATCH');
        fnd_message.set_token('BATCH_NAME', p_batch_name);
        errbuf := fnd_message.get;
        FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, errbuf);
    	return;
  end if;
  --
  hr_utility.set_location('Entering'|| l_proc_name, 13);
  --
  l_effective_date	:= fnd_date.canonical_to_date(p_effective_date);
  l_start_date		:= fnd_date.canonical_to_date(p_start_date);
  l_end_date		:= fnd_date.canonical_to_date(p_end_date);
  --
  -- Fetch the Organization Structure Version
  --
  open c_org_version(l_effective_date);
  fetch c_org_version into l_org_structure_version_id;
  close c_org_version;
  --
  --
  hr_utility.set_location('Entering'|| l_proc_name, 14);
  --
  --
  -- Fetch the batch Id into the l_batch_id
  --
  open c_batch;
  fetch c_batch into l_batch_id;
  close c_batch;
  --
  hr_utility.set_location('l_batch_id : '||l_batch_id ||' - ' || l_proc_name, 15);
  --
  -- Create the start record into the  Process Log
  --
  pqh_process_batch_log.start_log
  (
   p_batch_id         =>l_batch_id,
   p_module_cd        =>'POSITION_BUDGET_ANALYSIS',
   p_log_context      =>p_batch_name,
   p_information3     =>p_effective_date,
   p_information4     =>p_start_org_id,
   p_information5     =>p_start_date,
   p_information6     =>p_end_date,
   p_information7     =>p_org_structure_id,
   p_information8     =>'ORGANIZATION',
   p_information9     =>p_unit_of_measure
  );
  --
  --
  hr_utility.set_location('Organization Structure Version  : '||l_org_structure_version_id ||' '|| l_proc_name, 100);
  hr_utility.set_location('start organization  : '||p_start_org_id ||' '|| l_proc_name, 100);
  --
  --
  fnd_file.put_line(FND_FILE.LOG,'Primary Entity => ''ORGANIZATION''' || ' Unit of Measure => '||p_unit_of_measure);
  fnd_file.put_line(FND_FILE.LOG,'                                                       ');
  fnd_file.put_line(FND_FILE.LOG,'Name    Budgeted Value   Reallocated Value   Actual Value   Commitment Value   Under Budgeted Value  Under Budgeted Date');
  fnd_file.put_line(FND_FILE.LOG,'                                                       ');

  if (l_org_structure_version_id is not null ) then
   l_start_org_id := p_start_org_id;
   -- Bug Fix :2481824 ,get Top Org in Hierarchy as p_start_org_id
   if (p_start_org_id is null) then
     open c_top_org(l_org_structure_version_id);
     fetch c_top_org into l_start_org_id;
     close c_top_org;
   end if;
   --
   if l_start_org_id is not null then
    --
    --  Fetch the Organizations from the Organization Hierarchy
    for l_organization in c_org(l_org_structure_version_id, l_start_org_id,l_effective_date)
    loop
      --
      hr_utility.set_location('organization  : '||l_organization.organization_id ||' '|| l_proc_name, 101);
      --
      org_temp(  p_organization_id  => l_organization.organization_id
                ,p_level1           => l_organization.level1
                ,p_batch_name	    => p_batch_name
                ,p_unit_of_measure  => p_unit_of_measure
                ,p_business_group_id=> p_business_group_id
                ,p_effective_date   => l_effective_date
                ,p_start_date       => l_start_date
                ,p_end_date         => l_end_date
                );
    end loop;
    --
   end if;
  elsif (p_start_org_id is null)
  then
    for l_organization in c_all_org(p_business_group_id, l_effective_date)
    loop
      --
      hr_utility.set_location('organization  : '||l_organization.organization_id ||' '|| l_proc_name, 101);
      --
      org_temp(  p_organization_id  => l_organization.organization_id
                ,p_level1           => l_organization.level1
                ,p_batch_name	    => p_batch_name
                ,p_unit_of_measure  => p_unit_of_measure
                ,p_business_group_id=> p_business_group_id
                ,p_effective_date   => l_effective_date
                ,p_start_date       => l_start_date
                ,p_end_date         => l_end_date
                );
    end loop;
  end if;
  --
  -- End the Process Log
  --
  pqh_process_batch_log.end_log;
            hr_utility.set_location('End Process'
				||' '||l_proc_name, 180);
  commit;
  exception
  when others then
    retcode := -1;
  --
end;
--
--
---*******************-----
--Procedure to calculate Under Budgeted values for all primary entities

Procedure get_entity(errbuf	            OUT nocopy varchar2
		    , retcode	            OUT nocopy  varchar2
                    , p_batch_name	    IN  varchar2
		    , p_effective_date      IN	varchar2
		    , p_start_date	    IN  varchar2
     		    , p_end_date	    IN  varchar2
		    , p_entity_code	    IN  varchar2
		    , p_unit_of_measure     IN 	varchar2
		    , p_business_group_id   IN	number
		    , p_start_org_id 	    IN  number default null
		    , p_org_structure_id    IN  number default null
		     ) Is
Begin
--fnd_file.put_line(FND_FILE.LOG,'p_batch_name '||p_batch_name||'-')

--
-- Bug fix : 2483240
--
/* Commented for Bug Fix : 2464692

If p_entity_code in ('POSITION','ORGANIZATION','ALL') then
--
	If (nvl(p_start_org_id,0) =0 or nvl(p_org_structure_id,0)=0  )
	   then
	   --
	          fnd_message.set_name('PQH', 'PQH_ENTITY_REQUIRED');


	          If p_entity_code ='POSITION' then
	          --
	           fnd_message.set_token('ENTITY_NAME',hr_general.decode_lookup('PQH_BUDGET_ENTITY',p_entity_code)||'s');
	           --
	          Elsif p_entity_code ='ORGANIZATION' then
	          --
	            fnd_message.set_token('ENTITY_NAME',hr_general.decode_lookup('PQH_BUDGET_ENTITY',p_entity_code)||'s');
	          --
	          Else
	            fnd_message.set_token('ENTITY_NAME',hr_general.decode_lookup('UNDER_BDGT_EXTRA_TYPES',p_entity_code));
	          End if;
	          --
	         errbuf := fnd_message.get;
          	 retcode := -1;
  		fnd_file.put_line(FND_FILE.LOG,errbuf);
  		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, errbuf);
  		return;
  	   End if;
 --
 End if;
*/

If p_entity_code = 'POSITION' then
  position_analysis(p_batch_name         => p_batch_name
        	  , p_effective_date     => p_effective_date
         	  , p_start_org_id       => p_start_org_id
         	  , p_org_structure_id   => p_org_structure_id
        	  , p_start_date         => p_start_date
        	  , p_end_date           => p_end_date
		  , p_business_group_id  => p_business_group_id
		  , p_unit_of_measure    => p_unit_of_measure
		  , errbuf 	         => errbuf
        	  , retcode              => retcode
		   );
Elsif p_entity_code = 'JOB' then
  job_analysis(p_batch_name         => p_batch_name
             , p_effective_date     => p_effective_date
             , p_start_date         => p_start_date
             , p_end_date           => p_end_date
  	     , p_business_group_id  => p_business_group_id
  	     , p_unit_of_measure    => p_unit_of_measure
  	     , errbuf 	            => errbuf
             , retcode              => retcode
	       );

Elsif p_entity_code = 'GRADE' then
  grade_analysis(p_batch_name         => p_batch_name
               , p_effective_date     => p_effective_date
               , p_start_date         => p_start_date
               , p_end_date           => p_end_date
  	       , p_business_group_id  => p_business_group_id
  	       , p_unit_of_measure    => p_unit_of_measure
  	       , errbuf 	      => errbuf
               , retcode              => retcode
	        );
Elsif p_entity_code = 'ORGANIZATION' then
  organization_analysis(p_batch_name         => p_batch_name
              , p_effective_date     => p_effective_date
              , p_start_org_id       => p_start_org_id
              , p_org_structure_id   => p_org_structure_id
              , p_start_date         => p_start_date
              , p_end_date           => p_end_date
  	      , p_business_group_id  => p_business_group_id
  	      , p_unit_of_measure    => p_unit_of_measure
       	      , errbuf 	             => errbuf
              , retcode              => retcode
	       );
Elsif p_entity_code = 'OPEN' then
  --

  fnd_file.put_line(FND_FILE.LOG,'Budgets cannot be controlled with Primary Entity OPEN');

  --
Elsif nvl(p_entity_code,'ALL') = 'ALL' then
--batch name will be appended by the entity code

  position_analysis(p_batch_name       => p_batch_name || ' - Position'
          	, p_effective_date     => p_effective_date
          	, p_start_org_id       => p_start_org_id
          	, p_org_structure_id   => p_org_structure_id
          	, p_start_date         => p_start_date
          	, p_end_date           => p_end_date
  		, p_business_group_id  => p_business_group_id
  		, p_unit_of_measure    => p_unit_of_measure
  		, errbuf 	       => errbuf
          	, retcode              => retcode
		  );

  organization_analysis
               (p_batch_name         => p_batch_name ||' - Organization'
              , p_effective_date     => p_effective_date
              , p_start_org_id       => p_start_org_id
              , p_org_structure_id   => p_org_structure_id
              , p_start_date         => p_start_date
              , p_end_date           => p_end_date
  	      , p_business_group_id  => p_business_group_id
  	      , p_unit_of_measure    => p_unit_of_measure
       	      , errbuf 	             => errbuf
              , retcode              => retcode
	       );


  job_analysis(p_batch_name         => p_batch_name ||' - Job'
             , p_effective_date     => p_effective_date
             , p_start_date         => p_start_date
             , p_end_date           => p_end_date
  	     , p_business_group_id  => p_business_group_id
  	     , p_unit_of_measure    => p_unit_of_measure
  	     , errbuf 	            => errbuf
             , retcode              => retcode
	       );

  grade_analysis(p_batch_name         => p_batch_name || ' - Grade'
               , p_effective_date     => p_effective_date
               , p_start_date         => p_start_date
               , p_end_date           => p_end_date
  	       , p_business_group_id  => p_business_group_id
  	       , p_unit_of_measure    => p_unit_of_measure
  	       , errbuf 	      => errbuf
               , retcode              => retcode
	        );
End if;
--Exception section added as part of nocopy changes
Exception
  When Others Then
     retcode := -1;

End;

function get_budget_currency(   p_position_id 	in number default null
				  ,p_job_id             in number default null
				  ,p_grade_id           in number default null
				  ,p_organization_id    in number default null
				  ,p_budget_entity      in varchar2
                                  ,p_start_date       	in date default sysdate
                                  ,p_end_date       	in date default sysdate
                                  ,p_effective_date 	in date default sysdate
                                  ,p_business_group_id  in number
                                  ) return varchar2 is
--
--
--
-- Cursor to fetch the Budgeted Currency on the given dates
--
   cursor c_currency is
    select bud.currency_code
    from
        pqh_budgets bud,
        pqh_budget_versions bver,
        pqh_budget_details bdet,
        pqh_budget_periods bper,
        per_time_periods stp,
        per_time_periods etp,
        pqh_budget_sets bsets,
        pqh_budget_elements bele,
        pqh_bdgt_cmmtmnt_elmnts bcl
    where nvl(bud.position_control_flag,'X') = 'Y'
    and bud.budgeted_entity_cd = p_budget_entity
    and bud.business_group_id = p_business_group_id
    and	((p_start_date <= bud.budget_start_date
          and p_end_date >= bud.budget_end_date)
          or
         (p_start_date between bud.budget_start_date and bud.budget_end_date) or
         (p_end_date between bud.budget_start_date and bud.budget_end_date)
        )
    and ( hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit1_id) = 'MONEY'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit2_id) = 'MONEY'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit3_id) = 'MONEY'
        )
    and bud.budget_id = bver.budget_id
    and trunc(p_effective_date) between trunc(bver.date_from) and trunc(bver.date_to)
    and nvl(p_organization_id, nvl(bdet.organization_id,  -1)) =
                               nvl(bdet.organization_id,  -1)
    and nvl(p_job_id,          nvl(bdet.job_id,   -1)) =
		               nvl(bdet.job_id,   -1)
    and nvl(p_position_id,     nvl(bdet.position_id,      -1)) =
			       nvl(bdet.position_id,      -1)
    and nvl(p_grade_id,        nvl(bdet.grade_id,         -1)) =
			       nvl(bdet.grade_id,         -1)
    and bver.budget_version_id = bdet.budget_version_id
    and bper.budget_detail_id = bdet.budget_detail_id
    and bper.start_time_period_id = stp.time_period_id
    and bper.end_time_period_id = etp.time_period_id
    and etp.end_date >= p_start_date
    and stp.start_date <= p_end_date
    and bsets.budget_period_id = bper.budget_period_id
    and bele.budget_set_id = bsets.budget_set_id
    and bud.budget_id = bcl.budget_id
    and bele.element_type_id = bcl.element_type_id;

    cursor c_currency_code is
    select currency_code
                from per_business_groups
                where business_group_id = p_business_group_id;
    --
    --
    -- Local Variables
    --
    l_currency_code     varchar2(40);
    --
begin
  --
  --
  for l_currency in c_currency
  loop
       /* open c_currency;
       fetch c_currency into l_currency_code;
       close c_currency; */
       l_currency_code := l_currency.currency_code;

  end loop;


--
    if l_currency_code is null then
       open c_currency_code;
       fetch c_currency_code into l_currency_code;
       close c_currency_code;
    end if;
  --
  -- Return the currency code
  --
  return(l_currency_code);
  --
end;


End;

/
