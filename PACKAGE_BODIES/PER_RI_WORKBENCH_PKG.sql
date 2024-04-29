--------------------------------------------------------
--  DDL for Package Body PER_RI_WORKBENCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_WORKBENCH_PKG" As
/* $Header: perriwkb.pkb 120.3.12010000.2 2008/09/11 06:52:43 psengupt ship $ */
Procedure load_workbench_item_row
  (   p_workbench_item_code            In  Varchar2
     ,p_workbench_item_name            In  Varchar2
     ,p_workbench_item_description     In  Varchar2
     ,p_menu_name                      In  Varchar2
     ,p_workbench_item_sequence        In  Number
     ,p_workbench_parent_item_code     In  Varchar2
     ,p_workbench_item_creation_date   In  Date
     ,p_workbench_item_type            In  Varchar2
     ,p_effective_date                 In  Date
   ) Is

Cursor csr_wbi Is
   Select object_version_number ovn
   From per_ri_workbench_items_vl
   Where workbench_item_code = p_workbench_item_code ;

Cursor csr_menu Is
   Select menu_id
   From fnd_menus
   Where menu_name = p_menu_name;

l_menu_id Number;
l_ovn Number(9);

Begin
  Open csr_wbi;
  Fetch csr_wbi Into l_ovn;

  Open csr_menu;
  Fetch csr_menu Into l_menu_id;
  Close csr_menu;

      If csr_wbi%NotFound Then
        PER_RI_WORKBENCH_ITEM_API.CREATE_WORKBENCH_ITEM(
              P_VALIDATE                         => FALSE
             ,P_WORKBENCH_ITEM_CODE              => p_workbench_item_code
             ,P_WORKBENCH_ITEM_NAME              => p_workbench_item_name
             ,P_WORKBENCH_ITEM_DESCRIPTION       =>  p_workbench_item_description
             ,P_MENU_ID                          => l_menu_id
             ,P_WORKBENCH_ITEM_SEQUENCE          => p_workbench_item_sequence
             ,P_WORKBENCH_PARENT_ITEM_CODE       =>  p_workbench_parent_item_code
             ,P_WORKBENCH_ITEM_CREATION_DATE     =>  p_workbench_item_creation_date
             ,P_WORKBENCH_ITEM_TYPE              => p_workbench_item_type
             ,P_EFFECTIVE_DATE                   => p_effective_date
             ,P_OBJECT_VERSION_NUMBER            => l_ovn
                                                 );
       Else

        PER_RI_WORKBENCH_ITEM_API.UPDATE_WORKBENCH_ITEM(
              P_VALIDATE                      => FALSE
             ,P_WORKBENCH_ITEM_CODE           => p_workbench_item_code
             ,P_WORKBENCH_ITEM_NAME           => p_workbench_item_name
             ,P_WORKBENCH_ITEM_DESCRIPTION    => p_workbench_item_description
             ,P_MENU_ID                       => l_menu_id
             ,P_WORKBENCH_ITEM_SEQUENCE       => p_workbench_item_sequence
             ,P_WORKBENCH_PARENT_ITEM_CODE    => p_workbench_parent_item_code
             ,P_WORKBENCH_ITEM_TYPE           => p_workbench_item_type
             ,P_EFFECTIVE_DATE                => p_effective_date
             ,P_OBJECT_VERSION_NUMBER         => l_ovn
                                                 );
       End If;

    close csr_wbi;
End load_workbench_item_row;

Procedure translate_workbench_item_row(p_workbench_item_code         Varchar2
                                      ,p_workbench_item_name         Varchar2
                                      ,p_workbench_item_description  Varchar2
                                      ) Is
Begin

 per_wbt_upd.upd_tl
     (p_workbench_item_code        => p_workbench_item_code
     ,p_workbench_item_name        => p_workbench_item_name
     ,p_workbench_item_description => p_workbench_item_description
     ,p_language_code              => userenv('LANG')
     );

End translate_workbench_item_row;

Procedure load_setup_task_row
     (p_setup_task_code                In     varchar2
     ,p_workbench_item_code            in     varchar2
     ,p_setup_task_name                In     Varchar2
     ,p_setup_task_description         In     Varchar2
     ,p_setup_task_sequence            in     number
     ,p_setup_task_status              in     varchar2
     ,p_setup_task_creation_date       in     date
     ,p_setup_task_last_mod_date       in     date
     ,p_setup_task_type                in     varchar2
     ,p_setup_task_action              in     varchar2
     ,p_effective_date                 in     date
      ) Is
Cursor csr_st Is
   Select object_version_number ovn
   From per_ri_setup_tasks
   Where setup_task_code = p_setup_task_code ;

   l_ovn Number(9);

Begin
   Open csr_st;
   Fetch csr_st Into l_ovn;

   If csr_st%NotFound Then

   per_ri_setup_task_api.create_setup_task(
        p_validate                      => FALSE
       ,p_setup_task_code               => p_setup_task_code
       ,p_workbench_item_code           => p_workbench_item_code
       ,p_setup_task_name               => p_setup_task_name
       ,p_setup_task_description        => p_setup_task_description
       ,p_setup_task_sequence           => p_setup_task_sequence
       ,p_setup_task_status             => p_setup_task_status
       ,p_setup_task_creation_date      => p_setup_task_creation_date
       ,p_setup_task_last_mod_date      => p_setup_task_last_mod_date
       ,p_setup_task_type               => p_setup_task_type
       ,p_setup_task_action             => p_setup_task_action
       ,p_effective_date                => p_effective_date
       ,p_object_version_number         => l_ovn
        );



   Else

      per_ri_setup_task_api.update_setup_task(
       p_validate                      => FALSE
      ,p_setup_task_code               => p_setup_task_code
      ,p_workbench_item_code           => p_workbench_item_code
      ,p_setup_task_name               => p_setup_task_name
      ,p_setup_task_description        => p_setup_task_description
      ,p_setup_task_sequence           => p_setup_task_sequence
      ,p_setup_task_type               => p_setup_task_type
      ,p_setup_task_action             => p_setup_task_action
      ,p_effective_date                => p_effective_date
      ,p_object_version_number         => l_ovn
        );


   End If;


   Close csr_st;


End;

Procedure translate_setup_task_row
          (p_setup_task_code                In     varchar2
          ,p_setup_task_name                In     Varchar2
          ,p_setup_task_description         In     Varchar2
   ) Is
Begin
    per_stl_upd.upd_tl
       ( p_setup_task_code          => p_setup_task_code
        ,p_setup_task_name          => p_setup_task_name
        ,p_setup_task_description   => p_setup_task_description
        ,p_language_code            => userenv('LANG')
       );

End;

Procedure load_setup_sub_task_row
           (p_setup_sub_task_code            In  Varchar2
           ,p_setup_sub_task_name            In  Varchar2
           ,p_setup_sub_task_description     In  Varchar2
           ,p_setup_task_code                In  Varchar2
           ,p_setup_sub_task_sequence        In  Number
           ,p_setup_sub_task_status          In  Varchar2
           ,p_setup_sub_task_type            In  Varchar2
           ,p_setup_sub_task_dp_link         In  Varchar2
           ,p_setup_sub_task_action          In  Varchar2
           ,p_setup_sub_task_creation_date   In  Date
           ,p_setup_sub_task_last_mod_date   In  Date
           ,p_legislation_code               In  Varchar2
           ,p_effective_date                 In  Date
     ) Is
Cursor csr_sst Is
   Select object_version_number ovn
   From per_ri_setup_sub_tasks
   Where setup_sub_task_code = p_setup_sub_task_code ;

   l_ovn Number(9);

Begin
   Open csr_sst;
   Fetch csr_sst Into l_ovn;

   If csr_sst%NotFound Then

   per_ri_setup_sub_task_api.create_setup_sub_task(
       p_setup_sub_task_code           => p_setup_sub_task_code
      ,p_setup_sub_task_name           => p_setup_sub_task_name
      ,p_setup_sub_task_description    => p_setup_sub_task_description
      ,p_setup_task_code               => p_setup_task_code
      ,p_setup_sub_task_sequence       => p_setup_sub_task_sequence
      ,p_setup_sub_task_status         => p_setup_sub_task_status
      ,p_setup_sub_task_type           => p_setup_sub_task_type
      ,p_setup_sub_task_dp_link        => p_setup_sub_task_dp_link
      ,p_setup_sub_task_action         => p_setup_sub_task_action
      ,p_setup_sub_task_creation_date  => p_setup_sub_task_creation_date
      ,p_setup_sub_task_last_mod_date  => p_setup_sub_task_last_mod_date
      ,p_legislation_code              => p_legislation_code
      ,p_effective_date                => p_effective_date
      ,p_object_version_number         => l_ovn
                                      ) ;



   Else

      per_ri_setup_sub_task_api.update_setup_sub_task(
       p_setup_sub_task_code            => p_setup_sub_task_code
       ,p_setup_sub_task_name           => p_setup_sub_task_name
       ,p_setup_sub_task_description    => p_setup_sub_task_description
       ,p_setup_task_code               => p_setup_task_code
       ,p_setup_sub_task_sequence       => p_setup_sub_task_sequence
       ,p_setup_sub_task_type           => p_setup_sub_task_type
       ,p_setup_sub_task_dp_link        => p_setup_sub_task_dp_link
       ,p_setup_sub_task_action         => p_setup_sub_task_action
       ,p_legislation_code              => p_legislation_code
       ,p_effective_date                => p_effective_date
       ,p_object_version_number         => l_ovn
                                      ) ;
   End If;


   Close csr_sst;
End;

Procedure translate_setup_sub_task_row
          (p_setup_sub_task_code                In     varchar2
          ,p_setup_sub_task_name                In     Varchar2
          ,p_setup_sub_task_description         In     Varchar2
    ) Is
Begin

  per_sst_upd.upd_tl
    ( p_setup_sub_task_code         => p_setup_sub_task_code
     ,p_setup_sub_task_name         => p_setup_sub_task_name
     ,p_setup_sub_task_description  => p_setup_sub_task_description
     ,p_language_code               => userenv('LANG')
    );

End;

Procedure load_view_report_row
          (p_workbench_view_report_code     In Varchar2
          ,p_workbench_view_report_name     In Varchar2
          ,p_wb_view_report_description     In Varchar2
          ,p_workbench_item_code            In Varchar2
          ,p_workbench_view_report_type     In Varchar2
          ,p_workbench_view_report_action   In Varchar2
          ,p_workbench_view_country         In Varchar2
          ,p_wb_view_report_instruction     In Varchar2
          ,p_effective_date                 In  Date
    	  ,p_primary_industry               In  Varchar2
          ,p_enabled_flag                   In Varchar2 default 'Y'
           ) Is
Cursor csr_vr Is
   Select object_version_number ovn
   From per_ri_view_reports
   Where workbench_view_report_code = p_workbench_view_report_code ;

   l_ovn Number(9);

Begin
   Open csr_vr;
   Fetch csr_vr Into l_ovn;

   If csr_vr%NotFound Then

  per_ri_view_report_api.create_view_report( p_workbench_view_report_code        => p_workbench_view_report_code
                ,p_workbench_view_report_name       =>  p_workbench_view_report_name
                ,p_wb_view_report_description       =>  p_wb_view_report_description
                ,p_workbench_item_code              => p_workbench_item_code
                ,p_workbench_view_report_type       =>  p_workbench_view_report_type
                ,p_workbench_view_report_action     =>  p_workbench_view_report_action
                ,p_workbench_view_country           =>  p_workbench_view_country
                ,p_wb_view_report_instruction       =>  p_wb_view_report_instruction
                ,p_language_code                    => userenv('LANG')
                ,p_effective_date                   => p_effective_date
                ,p_object_version_number            => l_ovn
        		,p_primary_industry		            => p_primary_industry
                ,p_enabled_flag                     => p_enabled_flag);


   Else

     per_ri_view_report_api.update_view_report(p_workbench_view_report_code      => p_workbench_view_report_code
                 ,p_workbench_view_report_name       =>  p_workbench_view_report_name
                 ,p_wb_view_report_description       =>  p_wb_view_report_description
                 ,p_workbench_item_code              => p_workbench_item_code
                 ,p_workbench_view_report_type       =>  p_workbench_view_report_type
                 ,p_workbench_view_report_action     =>  p_workbench_view_report_action
                 ,p_workbench_view_country           =>  p_workbench_view_country
                 ,p_wb_view_report_instruction       =>  p_wb_view_report_instruction
                 ,p_language_code                    => userenv('LANG')
                 ,p_effective_date                   => p_effective_date
                 ,p_object_version_number            => l_ovn
        		 ,p_primary_industry		         => p_primary_industry
                 ,p_enabled_flag                     => p_enabled_flag);


   End If;

   Close csr_vr;
End;

Procedure translate_view_report_row
          (p_workbench_view_report_code     In Varchar2
          ,p_workbench_view_report_name     In Varchar2
          ,p_wb_view_report_description     In Varchar2
          ) Is

Begin

  per_rvt_upd.upd_tl
      (p_workbench_view_report_code   => p_workbench_view_report_code
      ,p_workbench_view_report_name   => p_workbench_view_report_name
      ,p_wb_view_report_description   => p_wb_view_report_description
      ,p_language_code                => userenv('LANG')
      ) ;
End translate_view_report_row;

Procedure load_workbench_item_dependency
          (p_workbench_item_code  In Varchar2
          ,p_dependent_item_code  In Varchar2
          ,p_dependency_item_sequence In  Number
         ) Is

Cursor csr_dep Is
   Select 1
   From per_ri_dependencies
   where workbench_item_code = p_workbench_item_code
     and dependent_item_code = p_dependent_item_code ;

l_temp Number;

Begin

Open csr_dep;
Fetch csr_dep Into l_temp;
   If csr_dep%NotFound Then
      Insert Into  per_ri_dependencies(workbench_item_code,dependent_item_code,dependency_item_sequence)
                                values(p_workbench_item_code,p_dependent_item_code,p_dependency_item_sequence) ;
   Else
      update per_ri_dependencies
      set dependency_item_sequence = p_dependency_item_sequence
      where workbench_item_code = p_workbench_item_code
      and dependent_item_code = p_dependent_item_code ;
   End If;


End load_workbench_item_dependency;

Procedure sync_dp_user_keys
          (p_setup_sub_task_code  In Varchar2
          ,p_business_group_id    In Number
         ) Is

Cursor csr_job_group_id Is
   Select pjg.internal_name , pjg.job_group_id
     From per_job_groups pjg
    Where not exists
      (Select 1 From hr_pump_batch_line_user_keys uk where uk.user_key_value =  'RI~JOB_GROUP_NAME~'||pjg.internal_name)
      and (pjg.business_group_id Is Null or pjg.business_group_id =  p_business_group_id );

Cursor csr_benchmark_job_id Is
   Select pj.name, pj.job_id
     From per_jobs pj
    where not exists
      (Select 1 From hr_pump_batch_line_user_keys uk where uk.user_key_value =  'RI~BENCHMARK_JOB_NAME~'||pj.name)
      and pj.business_group_id = p_business_group_id
      and pj.benchmark_job_flag='Y';

Begin

If p_setup_sub_task_code = 'JOB' or p_setup_sub_task_code = 'JOB_CRPFLOW' Then

   --1.Job Group
   For i In csr_job_group_id Loop

     hr_pump_utils.add_user_key(p_user_key_value   =>substr('RI~JOB_GROUP_NAME~'||i.internal_name,1,240)
                               ,p_unique_key_id   => i.job_group_id
                               );

   End Loop;

   --2.Benchmark Job
   For i in csr_benchmark_job_id Loop

     hr_pump_utils.add_user_key(p_user_key_value  =>substr('RI~BENCHMARK_JOB_NAME~'||i.name,1,240)
                               ,p_unique_key_id  =>i.job_id
                               );
   End Loop;

End If;

End sync_dp_user_keys;

Procedure set_id_flex_num
          (p_setup_sub_task_code  In Varchar2
          ,p_business_group_id    In Number
         ) Is
begin
if p_setup_sub_task_code = 'JOB' then
   update bne_interface_cols_b
      set oa_flex_num = (select job_structure FROM per_business_groups WHERE  business_group_id = p_business_group_id )
    where interface_code like 'PER_RI_JOB_INTF' and val_type = 'KEYFLEX' and application_id = 800;
elsif p_setup_sub_task_code = 'POSITION' then
    update bne_interface_cols_b
      set oa_flex_num = (select position_structure FROM per_business_groups  WHERE business_group_id = p_business_group_id )
    where interface_code like 'PER_RI_POSITION_INTF' and val_type =  'KEYFLEX' and application_id = 800;
elsif p_setup_sub_task_code = 'GRADE' then
     update bne_interface_cols_b
      set oa_flex_num = (select grade_structure FROM per_business_groups WHERE  business_group_id = p_business_group_id )
    where interface_code like 'PER_RI_GRADE_INTF' and val_type = 'KEYFLEX' and application_id = 800;
end if;
end;

Procedure crp_insert_request
		  (p_setup_task_code In varchar2,
		   p_context_code In varchar2,
		   p_request_id In varchar2,
                   p_bg_id      In number)

is

begin

insert into
PER_RI_REQUESTS(SETUP_TASK_CODE,REQUEST_ID,CONTEXT_CODE,BUSINESS_GROUP_ID)
values (p_setup_task_code,to_number(p_request_id),p_context_code,p_bg_id);


end crp_insert_request;

Function chk_dff_structure(p_flexfield_name Varchar2
                          ,p_legislation_code Varchar2
			  ,p_app_id Varchar2
                          )
Return Varchar2 Is

Cursor csr_get_structure Is
  Select descriptive_flex_context_code
    From fnd_descr_flex_contexts
   Where descriptive_flexfield_name = p_flexfield_name
     and (descriptive_flex_context_code = p_legislation_code or  descriptive_flex_context_code = p_legislation_code || '_GLB')
     and enabled_flag = 'Y'
     and application_id = p_app_id ;


l_context Varchar2(30) := ' ';

Begin
   Open csr_get_structure;
   Fetch csr_get_structure Into l_context;
   Close csr_get_structure;

 Return l_context;

End chk_dff_structure;

End per_ri_workbench_pkg;

/
