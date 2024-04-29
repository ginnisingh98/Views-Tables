--------------------------------------------------------
--  DDL for Package Body HR_PROCESS_ASSIGNMENT_STEP_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PROCESS_ASSIGNMENT_STEP_SS" as
/* $Header: hrpspwrs.pkb 120.11.12010000.2 2010/03/03 14:25:29 gpurohit ship $ */

g_package      constant varchar2(75):='HR_PROCESS_ASSIGNMENT_STEP_SS.';
g_api_name     constant varchar2(75):=g_package || 'PROCESS_API';

procedure process_step_save
(p_item_type IN varchar2,
 p_item_key IN varchar2,
 p_actId in varchar2,
 p_login_person_id in varchar2,
 p_effective_date in varchar2,
 p_effective_date_option in varchar2,
 p_assignment_id in number,
 p_placement_id in number,
 p_step_id in number,
 p_grade_id in number,
 p_grade_ladder_pgm_id in number,
 p_object_version_number in number,
 p_business_group_id in number,
 p_effective_start_date in date,
 p_effective_end_date in date,
 p_reason in varchar2 default hr_api.g_varchar2,
 p_salary_change_warning    in out nocopy varchar2,
 p_gsp_post_process_warning out nocopy varchar2,
 p_gsp_salary_effective_date out nocopy date,
 p_flow_mode     in varchar2 default null,
 p_rptg_grp_id             IN VARCHAR2 DEFAULT NULL,
 p_plan_id                 IN VARCHAR2 DEFAULT NULL,
 p_page_error               in out nocopy varchar2,
 p_page_error_msg           in out nocopy varchar2
)
IS
 l_datetrack_update_mode varchar2(50);
 dummy varchar2(5);

 lb_grd_ldr_exists_flag boolean default false;
 l_effective_date date;
 ltt_salary_data  sshr_sal_prop_tab_typ;

 l_transaction_id number;
 l_transaction_step_id number default null;
 l_trns_object_version_number number default null;
 l_trans_tbl            hr_transaction_ss.transaction_table;
 l_count number;
 l_result                     varchar2(100) default null;

  l_assignment_id number;
  l_grade_ladder_pgm_id      number;
 l_last_step_change_date date;
 lv_gsp_review_proc_call VARCHAR2(30) default null;
 lv_gsp_flow_mode  VARCHAR2(30) default null;
 ln_gsp_step_id NUMBER;
 ln_gsp_activity_id NUMBER;

  l_grade_id     number;
  l_pay_basis_id number;
  l_pay_basis_id_proc    number;
  ln_gsp_txn_id  number;
  ln_gsp_update_mode  varchar2(10);
  lc_temp_grade_ladder_id NUMBER;
   lc_temp_upd_sal_cd    varchar2(30);

 l_proc     varchar2(72)     :=	g_package||'process_step_save';

  cursor last_step_change_date is
    select max(pspp.effective_start_date)
    from per_spinal_point_placements_f pspp
    where pspp.placement_id=p_placement_id;

  cursor step_correction_date is
    select null
    from   per_spinal_point_placements_f pspp
    where  pspp.placement_id             = p_placement_id
    and    pspp.effective_start_date      = l_effective_date;

  cursor csr_assignment is
    select assignment_id,assignment_type, pay_basis_id
    from per_all_assignments_f
    where assignment_id = p_assignment_id and
    l_effective_date between effective_start_date and effective_end_date;

  cursor csr_assignment_proc is
    select grade_id,grade_ladder_pgm_id,pay_basis_id
    from per_all_assignments_f
    where assignment_id = l_assignment_id and
    l_effective_date between effective_start_date and effective_end_date;

  cursor csr_placement_db is
    select step_id,reason
    from per_spinal_point_placements_f
    where placement_id=p_placement_id and
    l_effective_date between effective_start_date and effective_end_date;

  cursor csr_placement is
    select step_id, reason, object_version_number,
    effective_start_date, effective_end_date
    from per_spinal_point_placements_f
    where placement_id = p_placement_id and
    l_effective_date between effective_start_date and effective_end_date;

    CURSOR lc_sal_updateable_grade_ladder is
     select pgm_id, update_salary_cd  from ben_pgm_f
        where
         pgm_id = l_grade_ladder_pgm_id
         and l_effective_date between effective_start_date and effective_end_date;

 l_person_id number;
 l_assignment_type   varchar2(5);
 l_step_id   number;
 l_reason    varchar2(30);
 l_step_id_db   number;
 l_reason_db    varchar2(30);
 l_object_version_number  number;
 l_effective_start_date     date;
 l_effective_end_date     date;

 g_registration boolean :=false;
 g_applicant_hire boolean := false;
 g_normal_flow   boolean :=  false;

begin

  hr_utility.set_location('Entering:'||l_proc, 5);

hr_assignment_common_save_web.get_step
          (p_item_type           => p_item_type
          ,p_item_key            => p_item_key
          ,p_api_name            => g_api_name
          ,p_transaction_step_id => l_transaction_step_id
          ,p_transaction_id      => l_transaction_id);


l_effective_date := to_date(p_effective_date,g_date_format);
p_gsp_salary_effective_date := l_effective_date;
l_assignment_id :=  p_assignment_id;

open csr_placement_db;
fetch csr_placement_db into l_step_id_db, l_reason_db;
close csr_placement_db;

if (nvl(p_step_id,hr_api.g_number) = nvl(l_step_id_db,hr_api.g_number)) AND
      (nvl(p_reason,hr_api.g_varchar2) = nvl(l_reason_db,hr_api.g_varchar2)) then

    if l_transaction_step_id is not null then
      hr_transaction_ss.delete_transaction_step
         (p_transaction_step_id => l_transaction_step_id
          ,p_login_person_id => p_login_person_id);
      delete_pay_step(
         p_item_type => p_item_type,
         p_item_key  =>  p_item_key,
         p_login_person_id => p_login_person_id);
    end if;

    return;
end if;

  if p_flow_mode is not null and
     p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
  then
    hr_utility.set_location('p_flow_mode = hr_process_assignment_ss.g_new_hire_registration:'||l_proc,10);
    g_registration := true;
  end if;

  hr_pay_rate_gsp_ss.check_grade_ladder_exists(
                   p_business_group_id =>  p_business_group_id,
                   p_effective_date =>  l_effective_date,
                   p_grd_ldr_exists_flag => lb_grd_ldr_exists_flag);

  if(lb_grd_ldr_exists_flag) then
    ltt_salary_data := sshr_sal_prop_tab_typ(sshr_sal_prop_obj_typ(
                null,-- pay_proposal_id       NUMBER,
                l_assignment_id,-- assignment_id         NUMBER,
                p_business_group_id,--business_group_id   NUMBER,
                l_effective_date,--effective_date        DATE,
                null,--comments              VARCHAR2(2000),
                null,--next_sal_review_date  DATE,
                null,--salary_change_amount  NUMBER ,
                null,--salary_change_percent NUMBER ,
                null,--annual_change         NUMBER ,
                null,--proposed_salary       NUMBER ,
                null,--proposed_percent      NUMBER ,
                null,--proposal_reason       VARCHAR2(30),
                null,--ranking               NUMBER,
                null,--current_salary        NUMBER,
                null,--performance_review_id NUMBER,
                null,--multiple_components   VARCHAR2(1),
                null,--element_entry_id      NUMBER ,
                null,--selection_mode        VARCHAR2(1),
                null,--ovn                   NUMBER,
                null,--currency              VARCHAR2(15),
                null,--pay_basis_name        VARCHAR2(80),
                null,--annual_equivalent     NUMBER ,
                null,--total_percent        NUMBER ,
                null,--quartile              NUMBER ,
                null,--comparatio            NUMBER ,
                null,--lv_selection_mode     VARCHAR2(1),
                null,--attribute_category           VARCHAR2(150),
                null,--attribute1            VARCHAR2(150),
                null,--attribute2            VARCHAR2(150),
                null,--attribute3            VARCHAR2(150),
                null,--attribute4            VARCHAR2(150),
                null,--attribute5            VARCHAR2(150),
                null,--attribute6            VARCHAR2(150),
                null,--attribute7            VARCHAR2(150),
                null,--attribute8            VARCHAR2(150),
                null,--attribute9            VARCHAR2(150),
                null,--attribute10           VARCHAR2(150),
                null,--attribute11           VARCHAR2(150),
                null,--attribute12           VARCHAR2(150),
                null,--attribute13           VARCHAR2(150),
                null,--attribute14           VARCHAR2(150),
                null,--attribute15           VARCHAR2(150),
                null,--attribute16           VARCHAR2(150),
                null,--attribute17           VARCHAR2(150),
                null,--attribute18           VARCHAR2(150),
                null,--attribute19           VARCHAR2(150),
                null,--attribute20           VARCHAR2(150),
                null, --no_of_components       NUMBER,
                null,  -- salary_basis_change_type varchar2(30)
                null,  -- default_date           date
                null,  -- default_bg_id          number
                null,  -- default_currency       VARCHAR2(15)
                null,  -- default_format_string  VARCHAR2(40)
                null,  -- default_salary_basis_name  varchar2(30)
                null,  -- default_pay_basis_name     varchar2(80)
                null,  -- default_pay_basis      varchar2(30)
                null,  -- default_pay_annual_factor  number
                null,  -- default_grade          VARCHAR2(240)
                null,  -- default_grade_annual_factor number
                null,  -- default_minimum_salary      number
                null,  -- default_maximum_salary      number
                null,  -- default_midpoint_salary     number
                null,  -- default_prev_salary         number
                null,  -- default_last_change_date    date
                null,  -- default_element_entry_id    number
                null,  -- default_basis_changed       number
                null,  -- default_uom                 VARCHAR2(30)
                null,  -- default_grade_uom           VARCHAR2(30)
                null,  -- default_change_amount       number
                null,  -- default_change_percent      number
                null,  -- default_quartile            number
                null,  -- default_comparatio          number
                null,  -- default_last_pay_change     varchar2(200)
                null,  -- default_flsa_status         varchar2(80)
                null,  -- default_currency_symbol     varchar2(4)
                null,   -- default_precision           number
                null,    -- salary_effective_date    date
                null,    -- gsp_dummy_txn            varchar2(30)
                null,
                null,
                null,
                null,
                null
          ));
      -- store the current salary in the ltt_salary_data
      hr_pay_rate_gsp_ss.get_employee_current_salary(
                            p_assignment_id =>  l_assignment_id,
                            P_effective_date => l_effective_date,
                            p_ltt_salary_data => ltt_salary_data);

      if p_flow_mode is not null and
         p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
      then
           ltt_salary_data(1).current_salary := 0;
      end if;
  end if;

  open csr_assignment;
  fetch csr_assignment into l_assignment_id,l_assignment_type, l_pay_basis_id;
  if (csr_assignment%notfound and g_registration) then
      hr_utility.set_location('New Hire:'||l_proc, 15);
      savepoint new_hire;
      hr_new_user_reg_ss.processNewUserTransaction
        (WfItemType => p_item_type
        ,WfItemKey => p_item_key
        ,PersonId => l_person_id
        ,AssignmentId => l_assignment_id);
  elsif (l_assignment_type = 'A') then
    hr_utility.set_location('Applicant Hire:'||l_proc, 20);
    g_applicant_hire := true;
    SAVEPOINT applicant_hire;

    hr_new_user_reg_ss.process_selected_transaction(p_item_type => p_item_type,
                                                   		p_item_key => p_item_key
                                                  		,p_api_name => 'HR_PROCESS_PERSON_SS.PROCESS_API');
    hr_new_user_reg_ss.process_selected_transaction(p_item_type => p_item_type,
                                                   		 p_item_key => p_item_key
                    			 ,p_api_name => 'HR_PROCESS_ADDRESS_SS.PROCESS_API');
    hr_new_user_reg_ss.process_selected_transaction(p_item_type => p_item_type,
                                                   		  p_item_key => p_item_key
	                    		 ,p_api_name => 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API');
  else
    hr_utility.set_location('Normal Flow:'||l_proc, 25);
    g_normal_flow := true;
    savepoint normal_flow;
    hr_new_user_reg_ss.process_selected_transaction(p_item_type => p_item_type,
                                                   		p_item_key => p_item_key
			,p_api_name => 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API');
  end if;
  close csr_assignment;

open csr_assignment_proc;
fetch csr_assignment_proc into l_grade_id, l_grade_ladder_pgm_id,l_pay_basis_id_proc;
close csr_assignment_proc;

open csr_placement;
fetch csr_placement into l_step_id, l_reason, l_object_version_number,
                    l_effective_start_date, l_effective_end_date;
close csr_placement;

  open last_step_change_date;
  fetch last_step_change_date into l_last_step_change_date;
  if last_step_change_date%found then
      if l_effective_date>l_last_step_change_date then
        hr_utility.set_location('Datetrack Mode Update:'||l_proc, 30);
        l_datetrack_update_mode:='UPDATE';
      else
        open step_correction_date;
        fetch step_correction_date into dummy;
        if step_correction_date%FOUND then
          hr_utility.set_location('Datetrack Mode Correct:'||l_proc, 35);
          l_datetrack_update_mode:='CORRECTION';
        else
          hr_utility.set_location('Datetrack Mode Update Change Insert:'||l_proc, 40);
          l_datetrack_update_mode:='UPDATE_CHANGE_INSERT';
        end if;
        close step_correction_date;
      end if;
  end if;
  close last_step_change_date;

if p_placement_id is null then
    create_step
    (p_validate => true,
    p_effective_date => l_effective_date,
    p_business_group_id => p_business_group_id,
    p_assignment_id => l_assignment_id,
    p_step_id   => p_step_id,
    p_reason    => p_reason,
    p_placement_id      => p_placement_id,
    p_object_version_number     => l_object_version_number,
    p_effective_start_date     => l_effective_start_date,
    p_effective_end_date       => l_effective_end_date,
    p_gsp_post_process_warning     => p_gsp_post_process_warning,
    p_ltt_salary_data => ltt_salary_data,
    p_page_error    => p_page_error,
    p_page_error_msg    => p_page_error_msg);
else
    update_step
    (p_validate => true,
    p_effective_date => l_effective_date,
    p_datetrack_update_mode => l_datetrack_update_mode,
    p_step_id   => p_step_id,
    p_reason    => p_reason,
    p_business_group_id => p_business_group_id,
    p_assignment_id => l_assignment_id,
    p_placement_id      => p_placement_id,
    p_object_version_number     => l_object_version_number,
    p_effective_start_date     => l_effective_start_date,
    p_effective_end_date       => l_effective_end_date,
    p_gsp_post_process_warning     => p_gsp_post_process_warning,
    p_ltt_salary_data => ltt_salary_data,
    p_page_error    => p_page_error,
    p_page_error_msg    => p_page_error_msg);
end if;

hr_utility.set_location('After calling placement api:'||l_proc, 45);

if p_flow_mode is not null and
   p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
then
   rollback to new_hire;
end if;

if (g_applicant_hire) then
   rollback to applicant_hire;
end if;

if (g_normal_flow) then
    rollback to normal_flow;
end if;

if l_transaction_step_id is null  then
      l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);

    if l_transaction_id is null then
        hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => -1
           ,funmode    => 'RUN'
           ,p_login_person_id       => p_login_person_id
           ,result                  => l_result
           ,p_plan_id               => p_plan_id
           ,p_rptg_grp_id           => p_rptg_grp_id
           ,p_effective_date_option => p_effective_date_option);

        l_transaction_id:=hr_transaction_ss.get_transaction_id
                        (p_item_type   =>   p_item_type
                        ,p_item_key    =>   p_item_key);
    end if;

   hr_transaction_api.Set_Process_Order_String(p_item_type => p_item_type
                                                ,p_item_key  => p_item_key
                                                ,p_actid => -1);

    hr_transaction_api.create_transaction_step
      (p_validate              => false
      ,p_creator_person_id     => p_login_person_id
      ,p_transaction_id        => l_transaction_id
      ,p_api_name              => g_api_name
      ,p_item_type             => p_item_type
      ,p_item_key              => p_item_key
      ,p_activity_id           => -1
      ,p_transaction_step_id   => l_transaction_step_id
      ,p_object_version_number => l_trns_object_version_number
      );
end if;


  l_count:=1;
  l_trans_tbl(l_count).param_name      := 'P_ASSIGNMENT_ID';
  l_trans_tbl(l_count).param_value     :=  l_assignment_id;
  l_trans_tbl(l_count).param_original_value := l_assignment_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_EFFECTIVE_DATE_OPTION';
  l_trans_tbl(l_count).param_value     :=  p_effective_date_option;
  l_trans_tbl(l_count).param_original_value := p_effective_date_option;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_LOGIN_PERSON_ID';
  l_trans_tbl(l_count).param_value     :=  p_login_person_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_EFFECTIVE_DATE';
  l_trans_tbl(l_count).param_value     :=  p_effective_date;
  l_trans_tbl(l_count).param_original_value := p_effective_date; --ns
  l_trans_tbl(l_count).param_data_type := 'DATE';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_PLACEMENT_ID';
  l_trans_tbl(l_count).param_value     :=  p_placement_id;
  l_trans_tbl(l_count).param_original_value := p_placement_id;  --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_STEP_ID';
  l_trans_tbl(l_count).param_value     :=  p_step_id;
  l_trans_tbl(l_count).param_original_value := l_step_id_db;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;			-- grade and grade_ladder_pgm not used anywhere
  l_trans_tbl(l_count).param_name      := 'P_GRADE_ID';
  l_trans_tbl(l_count).param_value     :=  l_grade_id;
    l_trans_tbl(l_count).param_original_value := p_grade_id;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_GRADE_LADDER_PGM_ID';
  l_trans_tbl(l_count).param_value     :=  l_grade_ladder_pgm_id;
  l_trans_tbl(l_count).param_original_value := p_grade_ladder_pgm_id; --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_BUSINESS_GROUP_ID';
  l_trans_tbl(l_count).param_value     :=  p_business_group_id;
  l_trans_tbl(l_count).param_original_value := p_business_group_id; --ns
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_REASON';
  l_trans_tbl(l_count).param_value     :=  p_reason;
  l_trans_tbl(l_count).param_original_value := l_reason_db; --ns
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_EFFECTIVE_START_DATE';
  l_trans_tbl(l_count).param_value     :=  to_char(l_effective_start_date,g_date_format);
  l_trans_tbl(l_count).param_original_value := to_char(p_effective_start_date,g_date_format);
  l_trans_tbl(l_count).param_data_type := 'DATE';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_EFFECTIVE_END_DATE';
  l_trans_tbl(l_count).param_value     :=  to_char(l_effective_end_date,g_date_format);
  l_trans_tbl(l_count).param_original_value := to_char(p_effective_end_date,g_date_format);
  l_trans_tbl(l_count).param_data_type := 'DATE';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_OBJECT_VERSION_NUMBER';
  l_trans_tbl(l_count).param_value     :=  l_object_version_number;
  l_trans_tbl(l_count).param_original_value := p_object_version_number;
  l_trans_tbl(l_count).param_data_type := 'NUMBER';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_FLOW_MODE';
  l_trans_tbl(l_count).param_value     :=  p_flow_mode;
  l_trans_tbl(l_count).param_original_value := p_flow_mode;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_DATETRACK_UPDATE_MODE';
  l_trans_tbl(l_count).param_value     :=  l_datetrack_update_mode;
  l_trans_tbl(l_count).param_original_value := l_datetrack_update_mode;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_REVIEW_PROC_CALL';
  l_trans_tbl(l_count).param_value     :=  'HrAssignment';
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

  l_count:=l_count+1;
  l_trans_tbl(l_count).param_name      := 'P_REVIEW_ACTID';
  l_trans_tbl(l_count).param_value     :=  -1;
  l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


    hr_transaction_ss.save_transaction_step
    (p_item_type             => p_item_type
    ,p_item_key              => p_item_key
    ,p_actid                 => -1
    ,p_login_person_id     => p_login_person_id
    ,p_transaction_step_id   => l_transaction_step_id
    ,p_transaction_data      => l_trans_tbl
    ,p_plan_id           =>      p_plan_id
    ,p_rptg_grp_id        => p_rptg_grp_id
    ,p_effective_date_option  => p_effective_date_option
    );

open lc_sal_updateable_grade_ladder;
fetch lc_sal_updateable_grade_ladder into lc_temp_grade_ladder_id,lc_temp_upd_sal_cd;
close lc_sal_updateable_grade_ladder;

  if(lb_grd_ldr_exists_flag) then

    if (( (ltt_salary_data(1).salary_change_amount < 0)
            or  (ltt_salary_data(1).salary_change_amount > 0))) THEN
        lv_gsp_review_proc_call := 'HrPayRate';
        lv_gsp_flow_mode := p_flow_mode ;
        ln_gsp_activity_id := -1;
     -- increment the process order for displaying pay rate page
     -- in review page
     hr_transaction_api.Set_Process_Order_String(p_item_type => p_item_type
                      ,p_item_key  => p_item_key
                      ,p_actid => ln_gsp_activity_id);

     -- display warning only once, thats next time onwards
     -- ignore salary change warning

     if(p_salary_change_warning <> 'IGNORE') then
       p_salary_change_warning := 'WARNING';
     end if;

     p_gsp_salary_effective_date := ltt_salary_data(1).salary_effective_date;

     -- Save the Pay Rate GSP Txn
     if (lc_temp_upd_sal_cd = 'SALARY_BASIS') then
        PER_SSHR_CHANGE_PAY.get_transaction_step(
             p_item_type          =>    p_item_type,
             p_item_key           => p_item_key,
             p_activity_id         => -1,
             p_login_person_id    => p_login_person_id,
             p_api_name           => 'PER_SSHR_CHANGE_PAY.PROCESS_API',
             p_transaction_id      =>    ln_gsp_txn_id,
             p_transaction_step_id   => ln_gsp_step_id,
             p_update_mode           => ln_gsp_update_mode,
             p_effective_date_option   =>    p_effective_date_option);

        hr_pay_rate_gsp_ss.create_pay_txn(
            p_ltt_salary_data =>  ltt_salary_data,
            p_transaction_id    =>  ln_gsp_txn_id,
            p_transaction_step_id   =>  ln_gsp_step_id,
            p_item_type         =>  p_item_type,
            p_item_key          =>  p_item_key,
            p_assignment_id     =>  l_assignment_id,
            p_effective_date    =>  l_effective_date,
            p_pay_basis_id      =>  l_pay_basis_id_proc,
            p_old_pay_basis_id  =>  l_pay_basis_id,
            p_business_group_id =>  p_business_group_id
            );
     else

     hr_pay_rate_gsp_ss.save_gsp_txn(
        p_item_type             => p_item_type,
        p_item_key              => p_item_key,
        p_act_id                 => ln_gsp_activity_id,
        p_ltt_salary_data      => ltt_salary_data,
        p_review_proc_call     => lv_gsp_review_proc_call,
        p_flow_mode            => lv_gsp_flow_mode,
        p_step_id              => ln_gsp_step_id,
        p_rptg_grp_id        => p_rptg_grp_id,
        p_plan_id    => p_plan_id,
        p_effective_date_option  => p_effective_date_option
       );
     end if;

   else
        -- there is no change in grade or step and no change in salary
        -- then remove the existing PayRate Transaction if any with
        -- activityId = -1

        -- Need to see if an asg txn step id exists or not.
        delete_pay_step(
         p_item_type => p_item_type,
         p_item_key  =>  p_item_key,
         p_login_person_id => p_login_person_id);
    end if;
  end if;

hr_utility.set_location('Exiting:'||l_proc, 50);
EXCEPTION
   when hr_utility.hr_error then
      hr_message.provide_error;
      p_page_error := hr_message.last_message_app;
      p_page_error_msg := hr_message.get_message_text;
      hr_utility.set_location('Exiting: p_page_error '||p_page_error||l_proc, 50);
      hr_utility.set_location('Exiting: p_page_error_msg '||p_page_error_msg||l_proc, 50);
      if(g_registration) then
         rollback to new_hire;
      end if;
      if (g_applicant_hire) then
         rollback to applicant_hire;
      end if;
      if (g_normal_flow) then
         rollback to normal_flow;
      end if;

   when others then
      if(g_registration) then
         rollback to new_hire;
      end if;
      if (g_applicant_hire) then
         rollback to applicant_hire;
      end if;
      if (g_normal_flow) then
         rollback to normal_flow;
      end if;
      raise;

end process_step_save;

PROCEDURE create_step
     ( p_validate IN boolean default false,
       p_effective_date in date,
       p_business_group_id in number,
       p_assignment_id in number,
       p_placement_id in number,
       p_step_id in number,
       p_object_version_number  in number,
       p_effective_start_date  in date,
       p_effective_end_date  in date,
       p_reason in varchar2 default hr_api.g_varchar2,
       p_gsp_post_process_warning out nocopy varchar2,
       p_ltt_salary_data    IN OUT NOCOPY  sshr_sal_prop_tab_typ,
       p_page_error               in out nocopy varchar2,
       p_page_error_msg           in out nocopy varchar2
       )
       is
       l_object_version_number number;
       l_placement_id number;
       l_effective_start_date date;
       l_effective_end_date date;
       lb_grd_ldr_exists_flag boolean default false;

       l_proc   varchar2(72)  := g_package||'create_step';

begin

  hr_utility.set_location('Entering:'||l_proc, 5);

   l_object_version_number := p_object_version_number;
   savepoint create_step;
      hr_sp_placement_api.create_spp
      (p_effective_date => p_effective_date,
      p_assignment_id     => p_assignment_id,
      p_business_group_id       => p_business_group_id,
      p_placement_id => l_placement_id,
      p_object_version_number => l_object_version_number,
      p_step_id => p_step_id,
      p_reason=> p_reason,
      p_effective_start_date  => l_effective_start_date,
      p_effective_end_date    => l_effective_end_date,
      p_gsp_post_process_warning       => p_gsp_post_process_warning
      );

  hr_utility.set_location('After calling placement api:'||l_proc, 10);

           hr_pay_rate_gsp_ss.check_grade_ladder_exists(
                   p_business_group_id =>  p_business_group_id,
                   p_effective_date =>  p_effective_date,
                   p_grd_ldr_exists_flag => lb_grd_ldr_exists_flag);

      if(lb_grd_ldr_exists_flag) then
       hr_pay_rate_gsp_ss.get_employee_salary(
                            p_assignment_id =>  p_assignment_id,
                            P_effective_date => p_effective_date,
                            p_ltt_salary_data => p_ltt_salary_data);
     end if;

     if p_validate then
        rollback to create_step;
     end if;

  hr_utility.set_location('Leaving:'||l_proc, 15);
EXCEPTION
      WHEN others THEN
          rollback to create_step;
          raise;

END create_step;


PROCEDURE update_step
(p_validate in boolean default false,
p_effective_date in date,
p_datetrack_update_mode in varchar2 default 'UPDATE',
p_placement_id in number,
p_business_group_id in number,
p_assignment_id in number,
p_step_id in number,
p_object_version_number in number,
p_effective_start_date in date,
p_effective_end_date in date,
p_reason in varchar2 default hr_api.g_varchar2,
p_gsp_post_process_warning out nocopy varchar2,
p_ltt_salary_data    IN OUT NOCOPY  sshr_sal_prop_tab_typ,
p_page_error               in out nocopy varchar2,
p_page_error_msg           in out nocopy varchar2
)
IS
     l_object_version_number number;
     l_effective_start_date date;
     l_effective_end_date date;
       lb_grd_ldr_exists_flag boolean default false;
  l_proc   varchar2(72)  := g_package||'update_step';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

l_object_version_number := p_object_version_number;
l_effective_start_date := p_effective_start_date;
l_effective_end_date := p_effective_end_date;
savepoint update_step;
      hr_sp_placement_api.update_spp
      (p_effective_date => p_effective_date,
      p_datetrack_mode   => p_datetrack_update_mode,
      p_placement_id => p_placement_id,
      p_object_version_number => l_object_version_number,
      p_step_id => p_step_id,
      p_reason=> p_reason,
      p_effective_start_date  => l_effective_start_date,
      p_effective_end_date    => l_effective_end_date,
      p_gsp_post_process_warning       => p_gsp_post_process_warning
      );

  hr_utility.set_location('After calling placement api:'||l_proc, 10);

     hr_pay_rate_gsp_ss.check_grade_ladder_exists(
                   p_business_group_id =>  p_business_group_id,
                   p_effective_date =>  p_effective_date,
                   p_grd_ldr_exists_flag => lb_grd_ldr_exists_flag);

      if(lb_grd_ldr_exists_flag) then
       hr_utility.set_location('if(lb_grd_ldr_exists_flag) then:'||l_proc,15);
       hr_pay_rate_gsp_ss.get_employee_salary(
                            p_assignment_id =>  p_assignment_id,
                            P_effective_date => p_effective_date,
                            p_ltt_salary_data => p_ltt_salary_data);
     end if;

if p_validate then
    rollback to update_step;
end if;

  hr_utility.set_location('Leaving:'||l_proc, 20);

EXCEPTION
      WHEN others THEN
           rollback to update_step;
           raise;
END update_step;

procedure  process_api
(p_validate                 in     boolean default false
,p_transaction_step_id      in     number
,p_effective_date           in     varchar2 default null
)
is
l_gsp_post_process_warning varchar2(1000);
l_effective_date date;
l_object_version_number number;
l_effective_start_date date;
l_effective_end_date date;
l_placement_id number;
l_assignment_id number;
l_step_id   number;
l_reason    varchar2(30);
l_spinal_point  varchar2(30);
l_business_group_id number;
l_datetrack_update_mode varchar2(50);
ltt_salary_data  sshr_sal_prop_tab_typ;
l_page_error               varchar2(2000);
l_page_error_msg           varchar2(2000);

  l_proc   varchar2(72)  := g_package||'process_api';

begin

  hr_utility.set_location('Entering:'||l_proc, 5);

  if (p_effective_date is not null) then
    l_effective_date:= to_date(p_effective_date,g_date_format);
  else
    l_effective_date:= to_date(
      hr_transaction_ss.get_wf_effective_date
        (p_transaction_step_id => p_transaction_step_id),g_date_format);
  end if;

get_transaction_data
(p_transaction_step_id   => p_transaction_step_id
,p_assignment_id     => l_assignment_id
,p_step_id       => l_step_id
,p_placement_id => l_placement_id
,p_effective_start_date => l_effective_start_date
,p_effective_end_date => l_effective_end_date
,p_object_version_number => l_object_version_number
,p_reason              => l_reason
,p_business_group_id   => l_business_group_id
,p_spinal_point     =>    l_spinal_point
);

  if (( hr_process_person_ss.g_assignment_id is not null) and
                (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID))
  then
    l_assignment_id := hr_process_person_ss.g_assignment_id;
  end if;


l_datetrack_update_mode:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DATETRACK_UPDATE_MODE');

    ltt_salary_data := sshr_sal_prop_tab_typ(sshr_sal_prop_obj_typ(
                null,-- pay_proposal_id       NUMBER,
                null,-- assignment_id         NUMBER,
                null,--business_group_id     NUMBER,
                null,--effective_date        DATE,
                null,--comments              VARCHAR2(2000),
                null,--next_sal_review_date  DATE,
                null,--salary_change_amount  NUMBER ,
                null,--salary_change_percent NUMBER ,
                null,--annual_change         NUMBER ,
                null,--proposed_salary       NUMBER ,
                null,--proposed_percent      NUMBER ,
                null,--proposal_reason       VARCHAR2(30),
                null,--ranking               NUMBER,
                null,--current_salary        NUMBER,
                null,--performance_review_id NUMBER,
                null,--multiple_components   VARCHAR2(1),
                null,--element_entry_id      NUMBER ,
                null,--selection_mode        VARCHAR2(1),
                null,--ovn                   NUMBER,
                null,--currency              VARCHAR2(15),
                null,--pay_basis_name        VARCHAR2(80),
                null,--annual_equivalent     NUMBER ,
                null,--total_percent        NUMBER ,
                null,--quartile              NUMBER ,
                null,--comparatio            NUMBER ,
                null,--lv_selection_mode     VARCHAR2(1),
                null,--attribute_category           VARCHAR2(150),
                null,--attribute1            VARCHAR2(150),
                null,--attribute2            VARCHAR2(150),
                null,--attribute3            VARCHAR2(150),
                null,--attribute4            VARCHAR2(150),
                null,--attribute5            VARCHAR2(150),
                null,--attribute6            VARCHAR2(150),
                null,--attribute7            VARCHAR2(150),
                null,--attribute8            VARCHAR2(150),
                null,--attribute9            VARCHAR2(150),
                null,--attribute10           VARCHAR2(150),
                null,--attribute11           VARCHAR2(150),
                null,--attribute12           VARCHAR2(150),
                null,--attribute13           VARCHAR2(150),
                null,--attribute14           VARCHAR2(150),
                null,--attribute15           VARCHAR2(150),
                null,--attribute16           VARCHAR2(150),
                null,--attribute17           VARCHAR2(150),
                null,--attribute18           VARCHAR2(150),
                null,--attribute19           VARCHAR2(150),
                null,--attribute20           VARCHAR2(150),
                null, --no_of_components       NUMBER,
                null,  -- salary_basis_change_type varchar2(30)
                null,  -- default_date           date
                null,  -- default_bg_id          number
                null,  -- default_currency       VARCHAR2(15)
                null,  -- default_format_string  VARCHAR2(40)
                null,  -- default_salary_basis_name  varchar2(30)
                null,  -- default_pay_basis_name     varchar2(80)
                null,  -- default_pay_basis      varchar2(30)
                null,  -- default_pay_annual_factor  number
                null,  -- default_grade          VARCHAR2(240)
                null,  -- default_grade_annual_factor number
                null,  -- default_minimum_salary      number
                null,  -- default_maximum_salary      number
                null,  -- default_midpoint_salary     number
                null,  -- default_prev_salary         number
                null,  -- default_last_change_date    date
                null,  -- default_element_entry_id    number
                null,  -- default_basis_changed       number
                null,  -- default_uom                 VARCHAR2(30)
                null,  -- default_grade_uom           VARCHAR2(30)
                null,  -- default_change_amount       number
                null,  -- default_change_percent      number
                null,  -- default_quartile            number
                null,  -- default_comparatio          number
                null,  -- default_last_pay_change     varchar2(200)
                null,  -- default_flsa_status         varchar2(80)
                null,  -- default_currency_symbol     varchar2(4)
                null,   -- default_precision           number
                null,    -- salary_effective_date    date
                null,
                null,
                null,
                null,
                null,
                null
                ));

if l_placement_id is null then
create_step
(p_validate => p_validate,
p_effective_date => l_effective_date,
p_business_group_id => l_business_group_id,
p_assignment_id => l_assignment_id,
p_step_id   => l_step_id,
p_reason    => l_reason
,p_placement_id      => l_placement_id
,p_object_version_number     => l_object_version_number
,p_effective_start_date     => l_effective_start_date
,p_effective_end_date       => l_effective_end_date
,p_gsp_post_process_warning     => l_gsp_post_process_warning
,p_ltt_salary_data => ltt_salary_data
,p_page_error    => l_page_error
,p_page_error_msg    => l_page_error_msg);
else
update_step
(p_validate => p_validate,
p_effective_date => l_effective_date,
p_datetrack_update_mode => l_datetrack_update_mode,
p_step_id   => l_step_id,
p_reason    => l_reason,
p_business_group_id => l_business_group_id,
p_assignment_id => l_assignment_id
,p_placement_id      => l_placement_id
,p_object_version_number     => l_object_version_number
,p_effective_start_date     => l_effective_start_date
,p_effective_end_date       => l_effective_end_date
,p_gsp_post_process_warning     => l_gsp_post_process_warning
,p_ltt_salary_data => ltt_salary_data
,p_page_error    => l_page_error
,p_page_error_msg    => l_page_error_msg);
end if;

  hr_utility.set_location('Leaving:'||l_proc, 10);

end process_api;

procedure  get_transaction_data
(p_transaction_step_id                 in     number
,p_assignment_id      out  nocopy   number
,p_step_id           out   nocopy  number
,p_placement_id out  nocopy  number
,p_effective_start_date out   nocopy  date
,p_effective_end_date out   nocopy  date
,p_object_version_number out   nocopy  number
,p_reason              out   nocopy  varchar2
,p_business_group_id   out   nocopy  number
,p_spinal_point out nocopy  varchar2
)
is

l_spinal_point per_spinal_points.spinal_point%type;
l_proc   varchar2(72)  := g_package||'get_transaction_data';

cursor get_spinal_point is
select spinal_point from
per_spinal_points psp, per_spinal_point_steps_f psps where
psp.spinal_point_id=psps.spinal_point_id and psps.step_id=p_step_id;

begin

  hr_utility.set_location('Entering:'||l_proc, 5);

p_assignment_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_ASSIGNMENT_ID');
p_step_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_STEP_ID');

open get_spinal_point;
fetch get_spinal_point into l_spinal_point;
close get_spinal_point;

p_spinal_point := l_spinal_point;

p_placement_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_PLACEMENT_ID');

p_effective_start_date:=
    hr_transaction_api.get_date_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_EFFECTIVE_START_DATE');

p_effective_end_date:=
    hr_transaction_api.get_date_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_EFFECTIVE_END_DATE');

p_object_version_number:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_OBJECT_VERSION_NUMBER');

p_reason:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_REASON');

p_business_group_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_BUSINESS_GROUP_ID');

  hr_utility.set_location('Leaving:'||l_proc, 10);

end get_transaction_data;

procedure delete_pay_step
(p_item_type                in     wf_items.item_type%TYPE
,p_item_key                 in     wf_items.item_key%TYPE
,p_login_person_id          in      varchar2)	is

 l_transaction_id number;
 ln_gsp_step_id NUMBER;
 lv_gsp_activity_id VARCHAR2(30) default null;

begin
    hr_assignment_common_save_web.get_step
         (p_item_type           => p_item_type
         ,p_item_key            => p_item_key
         ,p_api_name            => 'PER_SSHR_CHANGE_PAY.PROCESS_API'
         ,p_transaction_step_id => ln_gsp_step_id
         ,p_transaction_id      => l_transaction_id);

     if (ln_gsp_step_id is null) then
        hr_assignment_common_save_web.get_step
         (p_item_type           => p_item_type
         ,p_item_key            => p_item_key
         ,p_api_name            => 'HR_PAY_RATE_SS.PROCESS_API'
         ,p_transaction_step_id => ln_gsp_step_id
         ,p_transaction_id      => l_transaction_id);
     end if;

         IF (ln_gsp_step_id IS NOT NULL)
         THEN
           lv_gsp_activity_id := hr_transaction_api.get_varchar2_value
               (p_transaction_step_id => ln_gsp_step_id
              ,p_name                => 'P_REVIEW_ACTID');
           -- for Pay Rate GSP Txn, Review Activity Id  is -1
           if((lv_gsp_activity_id is not null) and (to_number(lv_gsp_activity_id) = -1))
           THEN
            hr_transaction_ss.delete_transaction_step
                (p_transaction_step_id => ln_gsp_step_id
                 ,p_login_person_id => p_login_person_id);
           delete from per_pay_transactions where TRANSACTION_STEP_ID=ln_gsp_step_id;
           end if;
         END IF;
end delete_pay_step;
--------------------------------------------------------------

end hr_process_assignment_step_ss;

/
