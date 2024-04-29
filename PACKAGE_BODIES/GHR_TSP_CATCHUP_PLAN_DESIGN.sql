--------------------------------------------------------
--  DDL for Package Body GHR_TSP_CATCHUP_PLAN_DESIGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_TSP_CATCHUP_PLAN_DESIGN" AS
/* $Header: ghtspcpd.pkb 120.2 2006/10/23 20:38:40 bgarg noship $ */

--
-- Package Variables
--
   g_package varchar2(100) := 'ghr_tsp_catchup_plan_design.';

  Procedure create_tspc_program_and_plans (p_target_business_group_id in Number) is
--
      l_proc                Varchar2(100):= g_package||'create_tspc_program_and_plans';
      p_validate                    Number := 0;
      p_copy_entity_txn_id          Number;
      p_effective_date              Date;
      p_prefix_suffix_cd            Varchar2(2);
      p_prefix_suffix_text          Varchar2(2);
      p_reuse_object_flag           Varchar2(1);
      p_transaction_category_id     Number(15);
      l_effective_start_date        Date;
      l_effective_end_date          Date;
      Nothing_To_Do                 Exception;

--
      Cursor get_txn_category_id is
                   select transaction_category_id
                   from   pqh_transaction_categories
                   where  short_name = 'BEN_PDCPWZ';
      Cursor get_copy_txn_id is
                   select copy_entity_txn_id
                   from   pqh_copy_entity_txns
                   where  transaction_category_id = p_transaction_category_id
                   and    context_business_group_id = 0
                   and    display_name = 'GHR_TSP_CATCHUP_SEED_PROGRAM_DESIGN';
     Cursor update_program_status is
         select * from ben_pgm_f
         where  name = 'Federal Thrift Savings Plan (TSP) Catch Up Contributions'
         and    business_group_id = p_target_business_group_id;
--
 Begin

   hr_utility.set_location('Entering:'|| g_package||l_proc, 5);

   Open get_txn_category_id;
   Fetch get_txn_category_id into p_transaction_category_id;
   hr_utility.trace('Transaction Category Id  :'|| p_transaction_category_id);
   hr_utility.set_location('Opening cursor get_copy_txn_id      '||l_proc, 10);
   --dbms_output.put_line('txn category id   '||p_transaction_category_id);

   Open get_copy_txn_id;
   fetch get_copy_txn_id into p_copy_entity_txn_id;
   If get_copy_txn_id%notfound  then
      Raise Nothing_to_do;
   End If;
   hr_utility.trace('Copy entity Txn. Id  :'|| p_copy_entity_txn_id);
   --dbms_output.put_line('copy_entity_txn_id  :'||p_copy_entity_txn_id );


   --   Set the variables
   p_effective_date            := to_date('12/31/2005','MM/DD//YYYY');
   p_prefix_suffix_cd          := null;
   p_prefix_suffix_text        := null;
   p_reuse_object_flag         := 'Y';

   BEN_PD_COPY_TO_BEN_five.g_ghr_mode := 'TRUE';

   --dbms_output.put_line('now calling..........');
   BEN_PD_COPY_TO_BEN_TWO.create_stg_to_ben_rows(p_validate,
                                                 p_copy_entity_txn_id,
                                                 p_effective_date,
                                                 p_prefix_suffix_text,
                                                 p_reuse_object_flag,
                                                 p_target_business_group_id,
                                                 p_prefix_suffix_cd);
   For i in update_program_status Loop
       ben_Program_api.update_program(
                p_pgm_id                   => i.pgm_id
                ,p_effective_start_date    => l_effective_start_date
                ,p_effective_end_date      => l_effective_end_date
                ,p_pgm_stat_cd             => 'A'
                ,p_object_version_number   => i.object_version_number
                ,p_effective_date          => i.effective_start_date
                ,p_datetrack_mode          => 'CORRECTION'
       );
   End Loop;

  If get_txn_category_id%ISOPEN then
     CLOSE get_txn_category_id;
  End If;
  If get_copy_txn_id%ISOPEN then
     CLOSE get_copy_txn_id;
  End If;
  hr_utility.set_location('Leaving  :'|| g_package||l_proc, 50);

  Exception
     When Nothing_to_do Then
       If get_txn_category_id%ISOPEN then
           CLOSE get_txn_category_id;
       End If;
       If get_copy_txn_id%ISOPEN then
           CLOSE get_copy_txn_id;
       End If;
       null;
     When others then
       If get_txn_category_id%ISOPEN then
           CLOSE get_txn_category_id;
       End If;
       If get_copy_txn_id%ISOPEN then
           CLOSE get_copy_txn_id;
       End If;
       hr_utility.set_location('Leaving  :'|| g_package||l_proc, 70);
       Raise;
  End create_tspc_program_and_plans;



  Procedure populate_tspc_plan_design (p_errbuf     OUT NOCOPY VARCHAR2,
                                       p_retcode    OUT NOCOPY NUMBER,
                                       p_target_business_group_id in Number) is

      Cursor c_check_pgm_tsp_exists is
             select 'Y' tsp_exists from ben_pgm_f
             where  name = 'Federal Thrift Savings Plan (TSP)'
             and    business_group_id = p_target_business_group_id
             and    pgm_stat_cd = 'A';

      Cursor check_pgm_exists is
             select 'Y' from ben_pgm_f
             where  name = 'Federal Thrift Savings Plan (TSP) Catch Up Contributions'
             and    business_group_id = p_target_business_group_id;

      l_proc           varchar2(100):= substr(g_package||'Populate_tspc_plan_design',1,30);
      p_exists         Varchar2(1):= 'N';
      p_tsp_exists     Varchar2(1):= 'N';
      l_err_msg        Varchar2(2000);
      Nothing_To_Do    Exception;


  Begin
      hr_utility.set_location('entering  :'|| g_package||l_proc, 10);
      hr_utility.trace('Business Group Id   ' ||p_target_business_group_id);
      --Check if TSP program is installed before implementing catchUP.
      --If TSP open is not installed then TSP CatchUP should not run.
      p_tsp_exists := 'N';
      For check_pgm_tsp_exists  in c_check_pgm_tsp_exists loop
          p_tsp_exists := check_pgm_tsp_exists.tsp_exists;
          exit;
      End loop;
      If p_tsp_exists = 'N' then
         l_err_msg := 'Federal Thrift Savings Plan (TSP) program is not installed in the business group '||p_target_business_group_id||'. Please install it before installing Federal Thrift Savings Plan (TSP) Catch Up Contributions Program.';
         Raise nothing_to_do;
      End If;
      -- Check if TSP CatchUP is already installed.
      -- If Yes, then program should not run.
      Open check_pgm_exists;
      Fetch check_pgm_exists into p_exists;
      If check_pgm_exists%NOTFOUND Then
         p_exists := 'N';
      End If;
      If p_exists = 'Y' then
         l_err_msg := 'Federal Thrift Savings Plan (TSP) Catch Up Contributions program is already installed in the business_group '||p_target_business_group_id;
         Raise nothing_to_do;
      End If;

      savepoint  create_tspc_plan_design;
        --dbms_output.put_line('now starting plan design  ' ||p_target_business_group_id);
      create_tspc_program_and_plans(p_target_business_group_id);
      hr_utility.trace('After create_program_and_plans....');
      commit;
      If check_pgm_exists%ISOPEN then
           CLOSE check_pgm_exists;
      End If;
      hr_utility.set_location('Leaving  :'|| g_package||l_proc, 50);
  Exception
     When Nothing_to_do Then
        If check_pgm_exists%ISOPEN then
           CLOSE check_pgm_exists;
        End If;
        ghr_wgi_pkg.create_ghr_errorlog
          (p_program_name            =>  l_proc,
           p_log_text                =>  l_err_msg,
           p_message_name            =>  null,
           p_log_date                =>  sysdate
           );
       commit;
     When others then
        If check_pgm_exists%ISOPEN then
           CLOSE check_pgm_exists;
        End If;
       hr_utility.set_location('Leaving  :'|| g_package||l_proc, 60);
       hr_utility.trace('Error  ' ||sqlerrm(sqlcode));
       l_err_msg := substr(p_target_business_group_id||':'||nvl(fnd_message.get,sqlerrm),1,1999) ;
       rollback to create_tspc_plan_design;
       ghr_wgi_pkg.create_ghr_errorlog
          (p_program_name            =>  l_proc,
           p_log_text                =>  l_err_msg,
           p_message_name            =>  null,
           p_log_date                =>  sysdate
           );
       commit;
  End populate_tspc_plan_design;


  Procedure get_recs_for_tspc_migration(p_errbuf     OUT NOCOPY Varchar2
                                       ,p_retcode    OUT NOCOPY Number
                                       ,p_business_group_id in Number)  is

	-- Modified cursor for 11.5.10 Performance changes
	-- Added link between pay_element_types_f and pay_element_entries_f on element_type_id
    Cursor c_emp_tspc(c_business_group_id in number, c_element_name in pay_element_types_f.element_name%type)  is
    select
           e.assignment_id            assignment_id,
           decode(name,'Catch Up Amount','Amount', name) Name,
           screen_entry_value,
           e.effective_start_date,
           g.person_id
    from   pay_element_types_f		  a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f,
           per_assignments_f      g
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    a.element_type_id      = e.element_type_id
    and    g.business_group_id    = c_business_group_id
    and    e.effective_end_date   = hr_api.g_eot
    --and    trunc(sysdate) between e.effective_start_date and e.effective_End_date
    and    trunc(e.effective_start_date) between f.effective_start_date and f.effective_End_date
    and    g.assignment_id =  e.assignment_id
    and    trunc(e.effective_start_date) between g.effective_start_date and g.effective_end_date
    and    UPPER(a.element_name)   = c_element_name
    and    ghr_general.return_number(screen_entry_value) > 0
    order by 1, 2 desc;
	l_element_name pay_element_types_f.element_name%type;

  BEGIN
	  -- 11.5.10 Performance Changes
	  l_element_name := NVL(UPPER(pqp_fedhr_uspay_int_utils.return_new_element_name ('TSP Catch Up Contribution',p_business_group_id,sysdate,NULL)),'$Sys_Def$');

       -- set program name
       ghr_mto_int.set_log_program_name('GHR_TSP_CATCHUP_MIGRATION');

      for emp_rec in c_emp_tspc(p_business_group_id,l_element_name) loop
        ghr_general.ghr_tsp_catchup_migrate(emp_rec.assignment_id,
                                    'Amount',
                                    emp_rec.screen_entry_value,
                                    emp_rec.effective_start_date,
                                    p_business_group_id,
                                    emp_rec.person_id);
        commit;
      end loop;
  End get_recs_for_tspc_migration;


     Procedure update_alternate_check_date(p_errbuf     OUT NOCOPY Varchar2
                                          ,p_retcode    OUT NOCOPY Number
                                          ,p_payroll_id in  Number
                                          ,p_date_start in  Varchar2
                                          ,p_date_to    in  Varchar2
                                          ,p_chk_offset in  Number)  IS


         l_proc           varchar2(100):= 'Update_Alternate_Chcek_Date';
         l_date_start     Date;
         l_date_to        Date;
         l_row_id         Varchar2(200);
         l_tprec          per_time_periods%rowtype;

         Cursor c_get_rowid is
           select ROWID
           from   per_time_periods
           where  payroll_id = p_payroll_id
           --and    start_date between nvl(p_date_start,hr_api.g_sot) and nvl(p_date_to,hr_api.g_eot);
           and    start_date between l_date_start and l_date_to ;

         Cursor c_get_details is
           select * from per_time_periods where rowid = l_row_id;
    Begin
        hr_utility.set_location('entering  :'|| g_package||l_proc, 10);

        l_date_start  := nvl(fnd_date.canonical_to_date(p_date_start),hr_api.g_sot);
	l_date_to     := nvl(fnd_date.canonical_to_date(p_date_to),hr_api.g_eot);

        hr_utility.set_location( g_package||l_proc, 20);
        for get_rowid in c_get_rowid loop
            l_row_id  := get_rowid.ROWID;

            hr_utility.set_location( g_package||l_proc, 30);
            for get_details in c_get_details loop
               l_tprec := get_details;
               hr_utility.set_location( g_package||l_proc, 40);
               per_time_periods_pkg.update_row
                     (X_Rowid  			=> l_row_id,
                      X_Time_Period_Id       	=> l_tprec.time_period_id,
                      X_Payroll_Id           	=> l_tprec.payroll_id  ,
                      X_End_Date             	=> l_tprec.end_date,
                      X_Period_Name          	=> l_tprec.period_name,
                      X_Period_Num           	=> l_tprec.period_Num,
                      X_Period_Type          	=> l_tprec.period_type,
                      X_Start_Date           	=> l_tprec.start_date,
                      X_Cut_Off_Date         	=> l_tprec.cut_off_date,
                      X_Default_Dd_Date      	=> l_tprec.default_dd_date,
                      X_Description          	=> l_tprec.description,
                      X_Pay_Advice_Date      	=> l_tprec.pay_advice_date,
                      X_Period_Set_Name      	=> l_tprec.period_set_name,
                      X_Period_Year          	=> l_tprec.period_year,
                      X_Proc_Period_Type       	=> l_tprec.proc_period_type,
                      X_Quarter_Num             => l_tprec.quarter_num,
                      X_Quickpay_Display_Number => l_tprec.quickpay_display_number,
                      X_Regular_Payment_Date    => (l_tprec.end_date + p_chk_offset),
                      X_Run_Display_Number      => l_tprec.run_display_number,
                      X_Status                  => l_tprec.status,
                      X_Year_Number             => l_tprec.year_number,
                      X_Attribute_Category      => l_tprec.attribute_category,
                      X_Attribute1              => l_tprec.attribute1,
                      X_Attribute2              => l_tprec.attribute2,
                      X_Attribute3              => l_tprec.attribute3,
                      X_Attribute4              => l_tprec.attribute4,
                      X_Attribute5              => l_tprec.attribute5,
                      X_Attribute6              => l_tprec.attribute6,
                      X_Attribute7              => l_tprec.attribute7,
                      X_Attribute8              => l_tprec.attribute8,
                      X_Attribute9              => l_tprec.attribute9,
                      X_Attribute10             => l_tprec.attribute10,
                      X_Attribute11             => l_tprec.attribute11,
                      X_Attribute12             => l_tprec.attribute12,
                      X_Attribute13             => l_tprec.attribute13,
                      X_Attribute14             => l_tprec.attribute14,
                      X_Attribute15             => l_tprec.attribute15,
                      X_Attribute16             => l_tprec.attribute16,
                      X_Attribute17             => l_tprec.attribute17,
                      X_Attribute18             => l_tprec.attribute18,
                      X_Attribute19             => l_tprec.attribute19,
                      X_Attribute20             => l_tprec.attribute20,
                      X_Prd_Information_Category => l_tprec.prd_Information_Category,
                      X_Prd_Information1        => l_tprec.Prd_Information1,
                      X_Prd_Information2        => l_tprec.Prd_Information2,
                      X_Prd_Information3        => l_tprec.Prd_Information3,
                      X_Prd_Information4        => l_tprec.Prd_Information4,
                      X_Prd_Information5        => l_tprec.Prd_Information5,
                      X_Prd_Information6        => l_tprec.Prd_Information6,
                      X_Prd_Information7        => l_tprec.Prd_Information7,
                      X_Prd_Information8        => l_tprec.Prd_Information8,
                      X_Prd_Information9        => l_tprec.Prd_Information9,
                      X_Prd_Information10       => l_tprec.Prd_Information10,
                      X_Prd_Information11       => l_tprec.Prd_Information11,
                      X_Prd_Information12       => l_tprec.Prd_Information12,
                      X_Prd_Information13       => l_tprec.Prd_Information13,
                      X_Prd_Information14       => l_tprec.Prd_Information14,
                      X_Prd_Information15       => l_tprec.Prd_Information15,
                      X_Prd_Information16       => l_tprec.Prd_Information16,
                      X_Prd_Information17       => l_tprec.Prd_Information17,
                      X_Prd_Information18       => l_tprec.Prd_Information18,
                      X_Prd_Information19       => l_tprec.Prd_Information19,
                      X_Prd_Information20       => l_tprec.Prd_Information20,
                      X_Prd_Information21       => l_tprec.Prd_Information21,
                      X_Prd_Information22       => l_tprec.Prd_Information22,
                      X_Prd_Information23       => l_tprec.Prd_Information23,
                      X_Prd_Information24       => l_tprec.Prd_Information24,
                      X_Prd_Information25       => l_tprec.Prd_Information25,
                      X_Prd_Information26       => l_tprec.Prd_Information26,
                      X_Prd_Information27       => l_tprec.Prd_Information27,
                      X_Prd_Information28       => l_tprec.Prd_Information28,
                      X_Prd_Information29       => l_tprec.Prd_Information29,
                      X_Prd_Information30       => l_tprec.Prd_Information30,
                      X_Payslip_view_Date       => l_tprec.payslip_view_date
                    );
            End loop;
        End Loop;
        hr_utility.set_location('leaving  :'|| g_package||l_proc, 50);
    Exception
       when others then
         hr_utility.set_location('Error Leaving  :'|| g_package||l_proc, 100);
         hr_utility.trace('Error  ' ||sqlerrm(sqlcode));
    End update_alternate_check_date;
end ghr_tsp_catchup_plan_design;

/
