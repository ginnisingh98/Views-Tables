--------------------------------------------------------
--  DDL for Package Body PQP_GB_SWF_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_SWF_ARCHIVE" as
/* $Header: pqpgbswfar.pkb 120.0.12010000.6 2010/03/04 13:34:56 dwkrishn noship $ */

  -- Global variables
  g_census_year         number;
  g_census_day          date;
  g_cont_data_st_date   date;
  g_cont_data_end_date  date;
  g_lea_number          number;
  g_data_ret_type       varchar2(10);
  g_estb_number         number;
  g_exclude_absence     varchar2(3);
  g_exclude_qual        varchar2(3);
  g_business_group_id   number;
  g_debug               boolean;

  --
  -- Set to 'Y' if PQP_GB_SWF_CONTRACT_TYPE = ASG_CAT, dates used from per_all_assignments_f
  -- Set to 'N' if PQP_GB_SWF_CONTRACT_TYPE = , dates used from pqp_assignment_attributes_f
  g_pick_from_asg       varchar2(10);
  --
  g_teacher_sql_str     varchar2(3000);
  g_teach_dff_name      varchar2(30);
  g_qts_sql_str         varchar2(3000);
  g_qts_route_sql_str   varchar2(3000);
  g_hlta_dff_name       varchar2(30);
  g_hlta_sql_str        varchar2(3000);
  g_cont_post_sql_str   varchar2(3000);
  g_cont_post_src       varchar2(30);
  g_origin_sql_str      varchar2(3000);
  g_origin_dff          varchar2(30);
  g_destination_dff     varchar2(30);
  g_destination_sql_str varchar2(3000);
  g_role_src            varchar2(30);
  g_role_sql_str        varchar2(3000);
  g_addl_role_src       varchar2(30);
  g_addl_role_sql_str   varchar2(3000);

  -- person level globals
  -- these should be destroyed before they pass to the new thread

  type abs_details_rec is record
       (person_id               number(20)
        ,date_start             date
        ,date_start_dcsf        varchar2(10)
        ,date_end               date
        ,date_end_dcsf          varchar2(10)
        ,days_lost              varchar2(6)
        ,absence_category       varchar2(50)
        ,estab_no               number
        );

  type abs_details_tab is table of
     abs_details_rec index by binary_integer;

  type qual_details_rec is record
       (person_id        number
        ,qual_code       varchar2(10)
        ,sub1            varchar2(10)
        ,sub2            varchar2(10)
        ,verified        varchar2(10)
        ,estab_no        number
        );

  type qual_details_tab is table of
     qual_details_rec index by binary_integer;

  type addl_payment_dtl_rec is record
       ( addl_payment_cat       varchar2(15)
        ,addl_payment_amt       number(10)
        );

  type addl_payment_dtl_tab is table of
     addl_payment_dtl_rec index by binary_integer;

  type addl_role_tab is table of
      hr_lookups.meaning%type index by binary_integer;

  type act_info_rec is record
       ( assignment_id          number(20)
        ,person_id              number(20)
        ,effective_date         date
        ,action_info_category   varchar2(50)
        ,act_info1              varchar2(300)
        ,act_info2              varchar2(300)
        ,act_info3              varchar2(300)
        ,act_info4              varchar2(300)
        ,act_info5              varchar2(300)
        ,act_info6              varchar2(300)
        ,act_info7              varchar2(300)
        ,act_info8              varchar2(300)
        ,act_info9              varchar2(300)
        ,act_info10             varchar2(300)
        ,act_info11             varchar2(300)
        ,act_info12             varchar2(300)
        ,act_info13             varchar2(300)
        ,act_info14             varchar2(300)
        ,act_info15             varchar2(300)
        ,act_info16             varchar2(300)
        ,act_info17             varchar2(300)
        ,act_info18             varchar2(300)
        ,act_info19             varchar2(300)
        ,act_info20             varchar2(300)
        ,act_info21             varchar2(300)
        ,act_info22             varchar2(300)
        ,act_info23             varchar2(300)
        ,act_info24             varchar2(300)
        ,act_info25             varchar2(300)
        ,act_info26             varchar2(300)
        ,act_info27             varchar2(300)
        ,act_info28             varchar2(300)
        ,act_info29             varchar2(300)
        ,act_info30             varchar2(300)
       );
  type action_info_table is table of
     act_info_rec index by binary_integer;

  g_package    constant varchar2(20):= 'pqp_gb_swf_archive.';

-------------------------------Procedure insert_archive_row ---------------------------
-- Inserts rows to be archived to pay_action_information table with the context specified

procedure insert_archive_row(p_assactid       in number,
                             p_effective_date in date,
                             p_tab_rec_data   in action_info_table) is
     l_proc  constant varchar2(50):= g_package||'insert_archive_row';
     l_ovn       number;
     l_action_id number;
begin
     hr_utility.set_location('Entering: '||l_proc,1);
     if p_tab_rec_data.count > 0 then
        for i in p_tab_rec_data.first .. p_tab_rec_data.last loop

            hr_utility.trace('Defining category '|| p_tab_rec_data(i).action_info_category);
            hr_utility.trace('action_context_id = '|| p_assactid);
            hr_utility.trace('p_tab_rec_data(i).action_info_category = '|| p_tab_rec_data(i).action_info_category);
            if p_tab_rec_data(i).action_info_category is not null then
               pay_action_information_api.create_action_information(
                p_action_information_id => l_action_id,
                p_object_version_number => l_ovn,
                p_action_information_category => p_tab_rec_data(i).action_info_category,
                p_action_context_id    => p_assactid,
                p_action_context_type  => 'AAP',
                p_assignment_id        => p_tab_rec_data(i).assignment_id,
                p_effective_date       => p_effective_date,
                p_action_information1  => p_tab_rec_data(i).act_info1,
                p_action_information2  => p_tab_rec_data(i).act_info2,
                p_action_information3  => p_tab_rec_data(i).act_info3,
                p_action_information4  => p_tab_rec_data(i).act_info4,
                p_action_information5  => p_tab_rec_data(i).act_info5,
                p_action_information6  => p_tab_rec_data(i).act_info6,
                p_action_information7  => p_tab_rec_data(i).act_info7,
                p_action_information8  => p_tab_rec_data(i).act_info8,
                p_action_information9  => p_tab_rec_data(i).act_info9,
                p_action_information10 => p_tab_rec_data(i).act_info10,
                p_action_information11 => p_tab_rec_data(i).act_info11,
                p_action_information12 => p_tab_rec_data(i).act_info12,
                p_action_information13 => p_tab_rec_data(i).act_info13,
                p_action_information14 => p_tab_rec_data(i).act_info14,
                p_action_information15 => p_tab_rec_data(i).act_info15,
                p_action_information16 => p_tab_rec_data(i).act_info16,
                p_action_information17 => p_tab_rec_data(i).act_info17,
                p_action_information18 => p_tab_rec_data(i).act_info18,
                p_action_information19 => p_tab_rec_data(i).act_info19,
                p_action_information20 => p_tab_rec_data(i).act_info20,
                p_action_information21 => p_tab_rec_data(i).act_info21,
                p_action_information22 => p_tab_rec_data(i).act_info22,
                p_action_information23 => p_tab_rec_data(i).act_info23,
                p_action_information24 => p_tab_rec_data(i).act_info24,
                p_action_information25 => p_tab_rec_data(i).act_info25,
                p_action_information26 => p_tab_rec_data(i).act_info26,
                p_action_information27 => p_tab_rec_data(i).act_info27,
                p_action_information28 => p_tab_rec_data(i).act_info28,
                p_action_information29 => p_tab_rec_data(i).act_info29,
                p_action_information30 => p_tab_rec_data(i).act_info30
                );
            end if;
        end loop;
     end if;
     hr_utility.set_location('Leaving: '||l_proc,999);
end insert_archive_row;


-------------------------------Procedure dyn_sql --------------------------------------
procedure dyn_sql
is
     l_proc      constant varchar2(50) := g_package || ' dyn_sql';
     l_exp       exception;

  cursor  get_context_values is
  select  pcv_information1  ,
          pcv_information3  ,
          pcv_information4
  from    pqp_configuration_values pcv
  where   pcv.pcv_information_category = 'PQP_GB_SWF_TEACHER_NUM'
  and     pcv.business_group_id        = g_business_group_id;

  cursor  get_qts_source is
  select  pcv_information1
  from    pqp_configuration_values pcv
  where   pcv.pcv_information_category = 'PQP_GB_SWF_QTS_SRC'
  and     pcv.business_group_id        = g_business_group_id;

  cursor  get_qts_route_source is
  select  pcv_information1,
          pcv_information2
  from    pqp_configuration_values pcv
  where   pcv.pcv_information_category = 'PQP_GB_SWF_QTS_ROUTE_SRC'
  and     pcv.business_group_id        = g_business_group_id;

  cursor  get_hlta_source is
  select  pcv_information1,
          pcv_information4,
          decode(pcv_information1,'JOB',pcv_information3,   pcv_information5)
  from    pqp_configuration_values pcv
  where   pcv.pcv_information_category = 'PQP_GB_SWF_HLTA_STATUS_SRC'
  and     pcv.business_group_id        = g_business_group_id;

  cursor  get_post_source is
  select  pcv_information1,
          pcv_information3
  from    pqp_configuration_values pcv
  where   pcv.pcv_information_category = 'PQP_GB_SWF_POST_SOURCE'
  and     pcv.business_group_id        = g_business_group_id;

  cursor  get_origin_source is
  select  pcv_information1,
          pcv_information2,
          pcv_information3
  from    pqp_configuration_values pcv
  where   pcv.pcv_information_category = 'PQP_GB_SWF_ORIGIN_SRC'
  and     pcv.business_group_id        = g_business_group_id;

  cursor  get_destination_source is
  select  pcv_information1,
          pcv_information2,
          pcv_information3
  from    pqp_configuration_values pcv
  where   pcv.pcv_information_category = 'PQP_GB_SWF_DESTINATION_SRC' -- Check in database
  and     pcv.business_group_id        = g_business_group_id;

  cursor get_role_source is
  select  pcv_information1,
          pcv_information3
  from    pqp_configuration_values pcv
  where   pcv.pcv_information_category = 'PQP_GB_SWF_ROLE_SOURCE'
  and     pcv.business_group_id        = g_business_group_id;

  cursor get_addl_role_source is
  select  pcv_information1,
          pcv_information2,
          pcv_information3
  from    pqp_configuration_values pcv
  where   pcv.pcv_information_category = 'PQP_GB_SWF_ADD_ROLE_SOURCE'
  and     pcv.business_group_id        = g_business_group_id;

  ---
  l_context varchar2(150);
  l_column  varchar2(30);
  sql_str  varchar2(1000);
  l_qts_grade_seg_name  varchar2(30);
  l_qts_route_dff_name  varchar2(30);
  l_qts_route_seg_name  varchar2(30);
  l_hlta_seg_name       varchar2(30);
  l_hlta_context_name   varchar2(30);
  l_cont_post_seg       varchar2(30);
  l_origin_context      varchar2(30);
  l_origin_segment      varchar2(30);
  l_destination_context varchar2(30);
  l_destination_segment varchar2(30);
  l_role_segment        varchar2(30);
  l_addl_role_context   varchar2(30);
  l_addl_role_segment   varchar2(30);



begin
  hr_utility.set_location('Entering '|| l_proc, 10);


    hr_utility.set_location('Teachers Number : building teachers number start ', 20);

  open  get_context_values;
  fetch get_context_values into g_teach_dff_name,l_context,l_column;
  close get_context_values;

  if g_teach_dff_name is null then
    fnd_file.put_line(fnd_file.log,'Staff Details - Teachers Number  ');
  end if;

    hr_utility.set_location('Teachers Number DFF name :'||g_teach_dff_name,20);
    hr_utility.set_location('Teachers Number Context name :'||l_context,30);
    hr_utility.set_location('Teachers Number Column name :'||l_column,40);




  if g_teach_dff_name =  'PER_PEOPLE' then
    g_teacher_sql_str :=
             'select '||l_column||
             ' from per_all_people_f where ATTRIBUTE_CATEGORY = '''||l_context||'''
             and person_id = :person_id
             and :effective_date between effective_start_date and effective_end_date';

  elsif g_teach_dff_name =   'Extra Person Info DDF' then
    g_teacher_sql_str :=  'select max('||l_column||')'||
             ' from per_people_extra_info where information_type = '''||l_context||'''
              and person_id = :person_id
              and '||l_column ||' is not null ';

  end if;


      hr_utility.set_location('Teachers Number SQL Str :'||g_teacher_sql_str,60);
      hr_utility.set_location('Teachers Number : building teachers number End ',70);
      hr_utility.set_location('QT status : building QT status  start ',80);


   open  get_qts_source;
   fetch get_qts_source into l_qts_grade_seg_name;
   close get_qts_source;

   if l_qts_grade_seg_name is not null then
    g_qts_sql_str:=
          'select max(hr_general.decode_lookup(''YES_NO'',pcv.pcv_information4))
          from per_all_assignments_f paf,
            per_grades pgr,
            per_grade_definitions pgd ,
            pqp_configuration_values pcv
          where paf.business_group_id + 0 = :bg_id
          and paf.business_group_id       = pgr.business_group_id
          and pcv.business_group_id       = paf.business_group_id
          and pgr.grade_definition_id     = pgd.grade_definition_id
          and paf.grade_id                = pgr.grade_id
          and :eff_date between paf.effective_start_date and paf.effective_end_date
          and person_id                    = :person_id
          and pcv.pcv_information_category = ''PQP_GB_SWF_QTS_MAPPING''
          and ((pcv_information3          is null
          and pgd.'||l_qts_grade_seg_name||'                 = pcv.pcv_information2 )
          or (pcv_information3            is not null
          and pgd.'||l_qts_grade_seg_name||' between pcv.pcv_information2 and pcv_information3))';
    end if;


      hr_utility.set_location('QTS SQL Str :'||g_teacher_sql_str,90);
      hr_utility.set_location('QT status : building QT status  end ',100);


    open get_qts_route_source;
    fetch get_qts_route_source into l_qts_route_dff_name,l_qts_route_seg_name;
    close get_qts_route_source;

    if l_qts_route_dff_name = 'GRD' then
      g_qts_route_sql_str:=
      'select max(pcv.pcv_information4)
      from  per_all_assignments_f paf,
            per_grades pgr,
            per_grade_definitions pgd ,
            pqp_configuration_values pcv
      where paf.business_group_id + 0 = :bg_id
      and paf.business_group_id       = pgr.business_group_id
      and pcv.business_group_id       = paf.business_group_id
      and pgr.grade_definition_id     = pgd.grade_definition_id
      and paf.grade_id                = pgr.grade_id
      and :eff_date between paf.effective_start_date and paf.effective_end_date
      and person_id                    = :person_id
      and pcv.pcv_information_category = ''PQP_GB_SWF_QTS_ROUTE_MAPPING''
      and ((pcv_information3          is null
      and pgd.'||l_qts_route_seg_name||'                 = pcv.pcv_information2 )
      or (pcv_information3            is not null
      and pgd.'||l_qts_route_seg_name||' between pcv.pcv_information2 and pcv_information3))';
    elsif l_qts_route_dff_name = 'JOB' then
      g_qts_route_sql_str:=
      'select max(pcv.pcv_information4) QT_status
      from  per_all_assignments_f paf,
            per_jobs job,
            per_job_definitions jobdef  ,
            pqp_configuration_values pcv
      where paf.business_group_id + 0 = :bg_id
      and paf.business_group_id = job.business_group_id
      and pcv.business_group_id = paf.business_group_id
      and job.job_definition_id = jobdef.job_definition_id
      and paf.job_id = job.job_id
      and :eff_date between paf.effective_start_date and paf.effective_end_date
      and person_id = :person_id
      and pcv.pcv_information_category = ''PQP_GB_SWF_QTS_ROUTE_MAPPING''
      and jobdef.'||l_qts_route_seg_name||' = pcv.pcv_information2';
    elsif l_qts_route_dff_name = 'POS' then
      g_qts_route_sql_str:=
      'select max(pcv.pcv_information4) QT_status
      from  per_all_assignments_f paf,
            per_positions pos,
            per_position_definitions posdef  ,
            pqp_configuration_values pcv
      where paf.business_group_id + 0 = :bg_id
      and paf.business_group_id = pos.business_group_id
      and pcv.business_group_id = paf.business_group_id
      and pos.position_definition_id = posdef.position_definition_id
      and paf.position_id = pos.position_id
      and :eff_date between paf.effective_start_date and paf.effective_end_date
      and person_id = :person_id
      and pcv.pcv_information_category = ''PQP_GB_SWF_QTS_ROUTE_MAPPING''
      and posdef.'||l_qts_route_seg_name||' = pcv.PCV_INFORMATION2';
    end if;

    open  get_hlta_source;
    fetch get_hlta_source into g_hlta_dff_name,l_hlta_context_name,l_hlta_seg_name;
    close get_hlta_source;

    if    g_hlta_dff_name = 'JOB' then
      g_hlta_sql_str:=
      'select max(hr_general.decode_lookup(''YES_NO'',pcv.pcv_information3))
      from  per_all_assignments_f paf,
            per_jobs job,
            per_job_definitions jobdef  ,
            pqp_configuration_values pcv
      where paf.business_group_id + 0 = :bg_id
      and paf.business_group_id = job.business_group_id
      and pcv.business_group_id = paf.business_group_id
      and job.job_definition_id = jobdef.job_definition_id
      and paf.job_id = job.job_id
      and :eff_date between paf.effective_start_date and paf.effective_end_date
      and person_id = :person_id
      and pcv.pcv_information_category = ''PQP_GB_SWF_HLTA_STATUS_MAPPING''
      and jobdef.'||l_hlta_seg_name||' = pcv.pcv_information2';

    elsif g_hlta_dff_name = 'PER_PEOPLE' then
     g_hlta_sql_str:=
   'select max(hr_general.decode_lookup(''YES_NO'',pcv.pcv_information3))
      from per_all_people_f pap,
           pqp_configuration_values pcv
      where attribute_category = '''||l_hlta_context_name||'''
     and pap.person_id = :person_id
     and :effective_date between pap.effective_start_date and pap.effective_end_date
     and pcv.business_group_id = pap.business_group_id
     and pcv.pcv_information_category = ''PQP_GB_SWF_HLTA_STATUS_MAPPING''
     and pap.'||l_hlta_seg_name||' = pcv.pcv_information2';
    elsif g_hlta_dff_name = 'PER_ASSIGNMENTS' then
     g_hlta_sql_str:=
    'select max(hr_general.decode_lookup(''YES_NO'',pcv.pcv_information3))
      from per_all_assignments_f paf,
           pqp_configuration_values pcv
      where ass_attribute_category = '''||l_hlta_context_name||'''
     and paf.person_id = :person_id
     and :effective_date between paf.effective_start_date and paf.effective_end_date
     and pcv.business_group_id = paf.business_group_id
     and pcv.pcv_information_category = ''PQP_GB_SWF_HLTA_STATUS_MAPPING''
     and pap.'||l_hlta_seg_name||' = pcv.pcv_information2';
    end if;

    open  get_post_source;
    fetch get_post_source into g_cont_post_src,l_cont_post_seg;
    close get_post_source;

    if g_cont_post_src = 'GRD' then
      g_cont_post_sql_str:=
      'select pcv.pcv_information4
      from  per_all_assignments_f paf,
            per_grades pgr,
            per_grade_definitions pgd ,
            pqp_configuration_values pcv
      where paf.business_group_id + 0 = :bg_id
      and paf.business_group_id       = pgr.business_group_id
      and pcv.business_group_id       = paf.business_group_id
      and pgr.grade_definition_id     = pgd.grade_definition_id
      and paf.grade_id                = pgr.grade_id
      and :eff_date between paf.effective_start_date and paf.effective_end_date
      and paf.assignment_id                    = :assignment_id
      and pcv.pcv_information_category = ''PQP_GB_SWF_POST_MAPPING''
      and ((pcv_information3          is null
      and pgd.'||l_cont_post_seg||'                 = pcv.pcv_information2 )
      or (pcv_information3            is not null
      and pgd.'||l_cont_post_seg||' between pcv.pcv_information2 and pcv_information3))';
    elsif g_cont_post_src = 'JOB' then
      g_cont_post_sql_str:=
      'select pcv.pcv_information4
      from  per_all_assignments_f paf,
            per_jobs job,
            per_job_definitions jobdef  ,
            pqp_configuration_values pcv
      where paf.business_group_id + 0 = :bg_id
      and paf.business_group_id = job.business_group_id
      and pcv.business_group_id = paf.business_group_id
      and job.job_definition_id = jobdef.job_definition_id
      and paf.job_id = job.job_id
      and :eff_date between paf.effective_start_date and paf.effective_end_date
      and paf.assignment_id                    = :assignment_id
      and pcv.pcv_information_category = ''PQP_GB_SWF_POST_MAPPING''
      and jobdef.'||l_cont_post_seg||' = pcv.pcv_information2';
    elsif g_cont_post_src = 'POS' then
      g_cont_post_sql_str:=
      'select pcv.pcv_information4
      from  per_all_assignments_f paf,
            per_positions pos,
            per_position_definitions posdef  ,
            pqp_configuration_values pcv
      where paf.business_group_id + 0 = :bg_id
      and paf.business_group_id = pos.business_group_id
      and pcv.business_group_id = paf.business_group_id
      and pos.position_definition_id = posdef.position_definition_id
      and paf.position_id = pos.position_id
      and :eff_date between paf.effective_start_date and paf.effective_end_date
      and paf.assignment_id                    = :assignment_id
      and pcv.pcv_information_category = ''PQP_GB_SWF_POST_MAPPING''
      and posdef.'||l_cont_post_seg||' = pcv.pcv_information2';
    end if;

    open  get_origin_source;
    fetch get_origin_source into g_origin_dff,l_origin_context,l_origin_segment;
    close get_origin_source;

    if g_origin_dff = 'PER_ASSIGNMENTS' then
      g_origin_sql_str:=
      'select '||l_origin_segment||'
      from per_all_assignments_f where ass_attribute_category = '''||l_origin_context||'''
      and assignment_id = :assignment_id
      and :effective_date between effective_start_date and effective_end_date';
    elsif g_origin_dff = 'PER_PEOPLE' then
      g_origin_sql_str:=
      'select '||l_origin_segment||
      ' from per_all_people_f where ATTRIBUTE_CATEGORY = '''||l_origin_context||'''
      and person_id = :person_id
      and :effective_date between effective_start_date and effective_end_date';
    end if;

    open  get_destination_source;
    fetch get_destination_source into g_destination_dff,l_destination_context,l_destination_segment;
    close get_destination_source;

    if g_destination_dff = 'PER_ASSIGNMENTS' then
      g_destination_sql_str:=
      'select '||l_destination_segment||'
      from per_all_assignments_f where ass_attribute_category = '''||l_destination_context||'''
      and assignment_id = :assignment_id
      and :effective_date between effective_start_date and effective_end_date';
    elsif g_destination_dff = 'PER_PEOPLE' then
      g_destination_sql_str:=
      'select '||l_destination_segment||
      ' from per_periods_of_service where ATTRIBUTE_CATEGORY = '''||l_destination_context||'''
      and person_id = :person_id';
    end if;

    open  get_role_source;
    fetch get_role_source into g_role_src,l_role_segment;
    close get_role_source;

    if g_role_src = 'GRD' then
     g_role_sql_str:=
      'select pcv.pcv_information4
      from  per_all_assignments_f paf,
            per_grades pgr,
            per_grade_definitions pgd ,
            pqp_configuration_values pcv
      where paf.business_group_id + 0 = :bg_id
      and paf.business_group_id       = pgr.business_group_id
      and pcv.business_group_id       = paf.business_group_id
      and pgr.grade_definition_id     = pgd.grade_definition_id
      and paf.grade_id                = pgr.grade_id
      and :eff_date between paf.effective_start_date and paf.effective_end_date
      and paf.assignment_id                    = :assignment_id
      and pcv.pcv_information_category = ''PQP_GB_SWF_ROLE_MAPPING''
      and ((pcv_information3          is null
      and pgd.'||l_role_segment||'                 = pcv.pcv_information2 )
      or (pcv_information3            is not null
      and pgd.'||l_role_segment||' between pcv.pcv_information2 and pcv_information3))';
    elsif g_role_src = 'JOB' then
    g_role_sql_str:=
      'select pcv.pcv_information4
      from  per_all_assignments_f paf,
            per_jobs job,
            per_job_definitions jobdef  ,
            pqp_configuration_values pcv
      where paf.business_group_id + 0 = :bg_id
      and paf.business_group_id = job.business_group_id
      and pcv.business_group_id = paf.business_group_id
      and job.job_definition_id = jobdef.job_definition_id
      and paf.job_id = job.job_id
      and :eff_date between paf.effective_start_date and paf.effective_end_date
      and paf.assignment_id                    = :assignment_id
      and pcv.pcv_information_category = ''PQP_GB_SWF_ROLE_MAPPING''
      and jobdef.'||l_role_segment||' = pcv.pcv_information2';
    elsif g_role_src = 'POS' then
    g_role_sql_str:=
      'select pcv.pcv_information4
      from  per_all_assignments_f paf,
            per_positions pos,
            per_position_definitions posdef  ,
            pqp_configuration_values pcv
      where paf.business_group_id + 0 = :bg_id
      and paf.business_group_id = pos.business_group_id
      and pcv.business_group_id = paf.business_group_id
      and pos.position_definition_id = posdef.position_definition_id
      and paf.position_id = pos.position_id
      and :eff_date between paf.effective_start_date and paf.effective_end_date
      and paf.assignment_id                    = :assignment_id
      and pcv.pcv_information_category = ''PQP_GB_SWF_ROLE_MAPPING''
      and posdef.'||l_role_segment||' = pcv.pcv_information2';
    end if;

    open  get_addl_role_source;
    fetch get_addl_role_source into g_addl_role_src,l_addl_role_context,l_addl_role_segment;
    close get_addl_role_source;

    if g_addl_role_src = 'Extra Position Info DDF' then
    g_addl_role_sql_str:=
    		'select pcv.pcv_information4
		from per_all_assignments_f paa,
		     per_position_extra_info pei,
		     pqp_configuration_values pcv
		where paa.assignment_id = :p_assignment_id
		and   pei.position_id = paa.position_id
		and   pei.information_type = '''||l_addl_role_context||'''
		and   pcv.pcv_information_category = ''PQP_GB_SWF_ROLE_MAPPING''
		and   paa.business_group_id = pcv.business_group_id
		and   pei.'||l_addl_role_segment||' = pcv.pcv_information2
		and   :effective_date between paa.effective_start_date and paa.effective_end_date';
    elsif g_addl_role_src = 'Extra Job Info DDF' then
   	 g_addl_role_sql_str:=
       'select pcv.pcv_information4
		from per_all_assignments_f paa,
		     per_job_extra_info jei,
		     pqp_configuration_values pcv
		where paa.assignment_id = :p_assignment_id
		and   jei.job_id = paa.job_id
		and   jei.information_type = '''||l_addl_role_context||'''
		and   pcv.pcv_information_category = ''PQP_GB_SWF_ROLE_MAPPING''
		and   paa.business_group_id = pcv.business_group_id
		and   jei.'||l_addl_role_segment||' = pcv.pcv_information2
		and   :effective_date between paa.effective_start_date and paa.effective_end_date';
    elsif g_addl_role_src = 'Assignment Developer DF' then
    g_addl_role_sql_str:=
    		'select pcv.pcv_information4
		from   per_assignment_extra_info aei,
		       pqp_configuration_values pcv
		where  aei.assignment_id = :p_assignment_id
		and    aei.information_type = '''||l_addl_role_context||'''
		and    pcv.pcv_information_category = ''PQP_GB_SWF_ROLE_MAPPING''
        and    pcv.business_group_id = :bg_id
		and    aei.'||l_addl_role_segment||' = pcv.pcv_information2';
    end if;

    hr_utility.set_location('Leaving '|| l_proc, 110);
exception
     when others then
          hr_utility.set_location('Leaving '|| l_proc, 999);
          hr_utility.set_location(sqlerrm,9999);
          hr_utility.raise_error;
end dyn_sql;
-------------------------------Procedure pay_message_lines ---------------------------
-- Procedure to insert error messages to pay_message_lines
-- pragma autonomous_transaction is used here to isolate this transaction from
-- the parent this is done to retain the error messages in the table even if
-- the program errors and the process is rolled back
procedure populate_run_msg(assignment_action_id   in    number
                           ,p_message_text        in    varchar2
                             ,p_message_level         in      varchar2 default 'F'
           )
is
  pragma autonomous_transaction;
  l_proc  constant varchar2(50):= g_package||'populate_run_msg';
  begin
    hr_utility.set_location(' Entering:'||l_proc,111);

    insert into pay_message_lines(line_sequence,
                                  payroll_id,
                                  message_level,
                                  source_id,
                                  source_type,
                                  line_text)
                           values(
                                  pay_message_lines_s.nextval
                                 ,null
                                 ,p_message_level
                                 ,assignment_action_id
                                 ,'A'
                                 ,substr(p_message_text,1,240)
                                );

    hr_utility.set_location(' Entering:'||l_proc,999);
    commit;
    exception when others then
      hr_utility.trace('Error occured in populate_run_msg');
      hr_utility.set_location(' Leaving with error:'||l_proc,000);
      raise;
end populate_run_msg;

-------------------------------Procedure range_cursor --------------------------
-- select all people in the BG, filter out non appropriate ones in
-- action_creation procedure.
-- sqlstr must contain one and only one entry of :payroll_action_id
-- it must be ordered by person_id
procedure range_cursor     (pactid  in number,
                            sqlstr  out nocopy varchar2)

is
  l_proc  constant varchar2(35) := g_package
                                   ||'range_cursor';
begin
  hr_utility.set_location('Entering: '
                          ||l_proc,1);


  sqlstr := 'select distinct person_id '
            ||'from per_all_people_f ppf, '
            ||'pay_payroll_actions ppa '
            ||'where ppa.payroll_action_id = :payroll_action_id '
            ||'and ppa.business_group_id = ppf.business_group_id '
            ||'order by ppf.person_id';

  hr_utility.trace(' Range Cursor Statement : '
                   ||sqlstr);

  hr_utility.set_location(' Leaving: '
                          ||l_proc,100);
exception
  when others then
    hr_utility.set_location(' Leaving: '
                            ||l_proc,50);

    fnd_file.put_line(fnd_file.log,substr('Error in rangecode '
                                          ||sqlerrm(sqlcode),1,80));

    -- Return cursor that selects no rows
    sqlstr := 'select 1 from dual where to_char(:payroll_action_id) = dummy';
end range_cursor;
------------------------------function check_action-----------------------------
-- Function checks if assignment action already created for the payroll action
-- and assignment
function check_action(p_pactid  in number,
                      p_assignment_id in number) return boolean is
  l_proc constant varchar2(50):= g_package||'check_max_action';
  l_action number;
  l_ret    boolean := true;

  cursor check_action_exists is
  select assignment_action_id
  from pay_assignment_actions
  where payroll_action_id = p_pactid
  and assignment_id = p_assignment_id;

begin
    open check_action_exists;
    fetch check_action_exists into l_action;
    if check_action_exists%found then
      l_ret:= false;
    end if;
    close check_action_exists;

    return l_ret;
end check_action;

------------------------------function check_max_action-------------------------
-- Checks if an assignment action passed is the max for the particular payroll
-- action and person.This helps determine if the absence and qualification
-- records are to be archived or not Absence and wualification are archived only
-- if the assignment action is highest so that they get archived only once per person.

function check_max_action(p_assactid  in number,
                      p_person_id in number,
                      p_pactid    in number)  return boolean
is
     l_proc constant varchar2(50):= g_package||'check_max_action';
     l_action number;
     l_ret    boolean;

     cursor csr_check_action is
     select min(assignment_action_id)
     from pay_assignment_actions
     where assignment_id in (select assignment_id
                             from  per_all_assignments_f
                             where person_id = p_person_id)
     and  payroll_action_id = p_pactid;



begin

     hr_utility.set_location('Entering: '||l_proc,1);

     open  csr_check_action;
     fetch csr_check_action into l_action;
     close csr_check_action;

     if l_action = p_assactid then
        l_ret := true;
     else
        l_ret := false;
     end if;

     hr_utility.set_location('Leaving: '||l_proc,999);
     return l_ret;
end check_max_action;
------------------------------procedure action_creation-------------------------
-- creates assignment action for the assignments selected by the cursor
procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is


  cursor csr_parameter_info
  is
  select(pay_gb_eoy_archive.get_parameter(legislative_parameters,'CENSUS_YEAR')) census_year,
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,'CENSUS_DAY')) census_day,
  add_months(to_date((pay_gb_eoy_archive.get_parameter(legislative_parameters,'CONT_ST_DAY'))),-12) cont_st_day,
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,'CONT_END_DAY')) cont_end_day,
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,'LEA_NUM')) lea_num,
  upper((pay_gb_eoy_archive.get_parameter(legislative_parameters,'DATA_RETURN_TYPE'))) data_return_type,
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,'ESTB_NUM')) estb_num,
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,'EXCLUDE_ABS')) exclude_abs,
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,'EXCLUDE_QUAL')) exclude_qual,
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,'ASG_SET')) asg_set,
  effective_date,
  business_group_id
  from   pay_payroll_actions
  where  payroll_action_id = pactid;


  cursor csr_asg (p_asg_set_id    number)
  is
  select distinct asg.assignment_id,
                  asg.person_id
  from   per_all_assignments_f asg,
         hr_location_extra_info hlei,
         per_people_extra_info pei,
         (select  distinct min(asg1.effective_start_date) over( partition by assignment_id) effective_start_date,
            max(asg1.effective_end_date) over( partition by assignment_id)  effective_end_date,
            first_value(location_id)over( partition by assignment_id order by asg1.effective_end_date desc ) location_id,
            asg1.assignment_id
          from per_all_assignments_f asg1,
               per_assignment_status_types pas
          where asg1.assignment_status_type_id = pas.assignment_status_type_id
          and   pas.per_system_status = 'ACTIVE_ASSIGN') min_max
  where  asg.person_id between stperson and endperson
  and asg.business_group_id + 0 = g_business_group_id
  and min_max.location_id = hlei.location_id
  and hlei.information_type = 'PQP_GB_EDU_ESTB_INFO'
  and hlei.lei_information6 = g_lea_number
  and (g_estb_number is null
       or hlei.lei_information2 = g_estb_number)
  and pei.person_id = asg.person_id

  and pei.information_type = 'PQP_SCHOOL_WORKFORCE_CENSUS'
  and pei.pei_information5 <> 'OTHER'

  and min_max.assignment_id = asg.assignment_id

  and (min_max.effective_end_date between g_cont_data_st_date and g_cont_data_end_date -- contract change or the contract is terminated

	or  (g_census_day between min_max.effective_start_date and min_max.effective_end_date
	    ) -- Check for snapshot data

	or  (g_exclude_absence = 'No'                                                   -- Check absence existance only if it is not excluded
            and exists (select 1 -- If an absence exists in the previous calander year
                        from   per_absence_attendances abs
                        where  abs.person_id = asg.person_id
                        and abs.business_group_id = asg.business_group_id
                        and (abs.date_end between g_cont_data_st_date and g_cont_data_end_date
                              or abs.date_start between g_cont_data_st_date and g_cont_data_end_date))
	    )
	or  (g_exclude_qual = 'No' -- Qualification present or not?
            and g_census_day between min_max.effective_start_date and min_max.effective_end_date   -- check if contract is still
            and exists (select 1 from per_qualifications qual                              -- valid only if qual data is included
                      where qual.person_id = asg.person_id )
            )
	)

  -- 28 Days Condition
  and decode(min_max.effective_end_date,hr_general.end_of_time,to_date(g_census_day),min_max.effective_end_date)-
                     min_max.effective_start_date >= 28
  -- 28 Days Condition

  and (g_data_ret_type <> 'TYPE3'
       or (g_data_ret_type = 'TYPE3' and pei.pei_information5 = 'CENTRAL_STAFF'))

  and (p_asg_set_id is null -- don't check for assignment set in this case
        or exists (select 1
                   from   hr_assignment_sets has1
                   where  has1.assignment_set_id = p_asg_set_id
                   and has1.business_group_id = asg.business_group_id
                   and nvl(has1.payroll_id,asg.payroll_id) = asg.payroll_id
                   and (not exists (select 1 -- chk no amendments
                                    from   hr_assignment_set_amendments hasa1
                                    where  hasa1.assignment_set_id = has1.assignment_set_id)
                         or exists (select 1 -- chk include amendments
                                    from   hr_assignment_set_amendments hasa2
                                    where  hasa2.assignment_set_id = has1.assignment_set_id
                                    and hasa2.assignment_id = asg.assignment_id
                                    and nvl(hasa2.include_or_exclude,'I') = 'I')
                         or (not exists (select 1 --chk no exlude amendments
                                         from   hr_assignment_set_amendments hasa3
                                         where  hasa3.assignment_set_id = has1.assignment_set_id
                                         and hasa3.assignment_id = asg.assignment_id
                                         and nvl(hasa3.include_or_exclude,'I') = 'E')
                             and not exists (select 1 --and chk no Inc amendments
                                             from   hr_assignment_set_amendments hasa4
                                             where  hasa4.assignment_set_id = has1.assignment_set_id
                                             and nvl(hasa4.include_or_exclude,'I') = 'I')
                            ) -- end checking exclude amendments
                       ) -- done checking amendments
                  ) -- done asg set check when not null
      ); -- end of asg set check


  cursor csr_contract   (p_asg_set_id    number)
  is
  select distinct asg.assignment_id,asg.person_id
  from   per_all_assignments_f asg,
         pqp_assignment_attributes_f att,
         hr_location_extra_info hlei,
         per_people_extra_info pei,
         (select min(att1.effective_start_date) effective_start_date,
                 max(att1.effective_end_date) effective_end_date,
                 att1.assignment_id
          from  pqp_assignment_attributes_f att1
          group by assignment_id ) min_max,

          (select    first_value(location_id)over( partition by assignment_id order by asg1.effective_end_date desc ) location_id,
          asg1.assignment_id
          from per_all_assignments_f asg1,
               per_assignment_status_types pas
          where asg1.assignment_status_type_id = pas.assignment_status_type_id
          and   pas.per_system_status = 'ACTIVE_ASSIGN') loc
  where  asg.person_id between stperson and endperson
  and asg.business_group_id + 0 = g_business_group_id
  and att.business_group_id = asg.business_group_id
  and asg.assignment_id = att.assignment_id
  and loc.assignment_id = asg.assignment_id
  and loc.location_id = hlei.location_id
  and hlei.information_type = 'PQP_GB_EDU_ESTB_INFO'
  and hlei.lei_information6 = g_lea_number
  and (g_estb_number is null
       or hlei.lei_information2 = g_estb_number)
  and pei.person_id = asg.person_id

  and pei.pei_information5 <> 'OTHER'
  and pei.information_type = 'PQP_SCHOOL_WORKFORCE_CENSUS'

  and min_max.assignment_id = asg.assignment_id

  and (min_max.effective_end_date between g_cont_data_st_date and g_cont_data_end_date -- contract change or the contract is terminated

	or  (g_census_day between min_max.effective_start_date and min_max.effective_end_date
	    ) -- Check for snapshot data only

	or  (g_exclude_absence = 'No' -- Check absence existance only if it is not excluded
            and exists (select 1 -- If an absence exists in the previous calander year
                        from   per_absence_attendances abs
                        where  abs.person_id = asg.person_id
                        and abs.business_group_id = asg.business_group_id
                        and (abs.date_end between g_cont_data_st_date and g_cont_data_end_date
                              or abs.date_start between g_cont_data_st_date and g_cont_data_end_date))
	    )

      	or  (g_exclude_qual = 'No' -- Qualification present or not?
            and g_census_day between min_max.effective_start_date and min_max.effective_end_date   -- check if contract is still
            and exists (select 1 from per_qualifications qual                              -- valid only if qual data is included
                      where qual.person_id = asg.person_id )
            )

      )

  -- 28 Days Condition
  and decode(min_max.effective_end_date,hr_general.end_of_time,to_date(g_census_day),min_max.effective_end_date)-
                     min_max.effective_start_date >= 28
  -- 28 Days Condition

  and (g_data_ret_type <> 'TYPE3'
       or (g_data_ret_type = 'TYPE3' and pei.pei_information5 = 'CENTRAL_STAFF'))

  and (p_asg_set_id is null -- don't check for assignment set in this case
        or exists (select 1
                   from   hr_assignment_sets has1
                   where  has1.assignment_set_id = p_asg_set_id
                   and has1.business_group_id = asg.business_group_id
                   and nvl(has1.payroll_id,asg.payroll_id) = asg.payroll_id
                   and (not exists (select 1 -- chk no amendments
                                    from   hr_assignment_set_amendments hasa1
                                    where  hasa1.assignment_set_id = has1.assignment_set_id)
                         or exists (select 1 -- chk include amendments
                                    from   hr_assignment_set_amendments hasa2
                                    where  hasa2.assignment_set_id = has1.assignment_set_id
                                    and hasa2.assignment_id = asg.assignment_id
                                    and nvl(hasa2.include_or_exclude,'I') = 'I')
                         or (not exists (select 1 --chk no exlude amendments
                                         from   hr_assignment_set_amendments hasa3
                                         where  hasa3.assignment_set_id = has1.assignment_set_id
                                         and hasa3.assignment_id = asg.assignment_id
                                         and nvl(hasa3.include_or_exclude,'I') = 'E')
                             and not exists (select 1 --and chk no Inc amendments
                                             from   hr_assignment_set_amendments hasa4
                                             where  hasa4.assignment_set_id = has1.assignment_set_id
                                             and nvl(hasa4.include_or_exclude,'I') = 'I')
                            ) -- end checking exclude amendments
                       ) -- done checking amendments
                  ) -- done asg set check when not null
      ); -- end of asg set check


  cursor contract_type is
  select distinct pcv_information1
  from   pqp_configuration_values
  where  pcv_information_category = 'PQP_GB_SWF_CONTRACT_TYPE'
  and    business_group_id        = g_business_group_id;

-- Local variables
  l_arch             boolean := true;
  l_proc             constant varchar2(35):= g_package||'action_creation';
  l_ass_act_id       pay_assignment_actions.assignment_action_id%type;
  l_asg_set          hr_assignment_sets.assignment_set_id%type;
  l_effective_date   date;
  e_contract_type_nt_defined    exception;
  l_contract_type     varchar2(50);
begin
  if chunk = 1 then
    hr_utility.set_location('Entering: '||l_proc,1);
  end if;
  -----
  open csr_parameter_info;
  fetch csr_parameter_info into g_census_year,
                                --g_census_term,
                                g_census_day,
                                g_cont_data_st_date,
                                g_cont_data_end_date,
                                g_lea_number,
                                g_data_ret_type,
                                g_estb_number,
                                g_exclude_absence,
                                g_exclude_qual,
                                l_asg_set,
                                l_effective_date,
                                g_business_group_id;
  close csr_parameter_info;

  -------
  open  contract_type;
  fetch contract_type into l_contract_type;
  close contract_type;

  if l_contract_type is not null then
     if l_contract_type = 'ASG_CAT' then
       g_pick_from_asg  := 'Y';
     else
       g_pick_from_asg  := 'N';
     end if;
  else
     fnd_file.put_line(fnd_file.log,'Contract Details - Contract Type Configuration is not set.Please configure and proce');
     raise e_contract_type_nt_defined;
  end if;
  if chunk = 1 then
     hr_utility.set_location('g_pick_from_asg : ' || g_pick_from_asg,30);
  end if;


  if chunk = 1 then
       hr_utility.set_location('g_census_year : ' || g_census_year,30);
       hr_utility.set_location('g_census_day  : ' || g_census_day,30);
       hr_utility.set_location('g_cont_data_st_date  : ' || g_cont_data_st_date,30);
       hr_utility.set_location('g_cont_data_end_date : ' || g_cont_data_end_date,30);
       hr_utility.set_location('g_lea_number  : ' || g_lea_number,30);
       hr_utility.set_location('g_estb_number : ' || g_estb_number,30);
       hr_utility.set_location('g_exclude_qual: ' || g_exclude_qual,30);
       hr_utility.set_location('l_asg_set     : ' || l_asg_set,30);
       hr_utility.set_location('l_effective_date    : ' || l_effective_date,30);
       hr_utility.set_location('g_business_group_id : ' || g_business_group_id,30);
  end if;

    if g_pick_from_asg = 'N' then

      for asg_rec in csr_contract(l_asg_set) loop
          -- Check if assignment action already created for this assignment
          l_arch := check_action(pactid,asg_rec.assignment_id);
          if l_arch then
              -- hr_utility.set_location('Creating assignment action for ' || asg_rec.assignment_id,30);
              select pay_assignment_actions_s.nextval
              into   l_ass_act_id
              from   dual;
              --
              -- insert into pay_assignment_actions.
              hr_nonrun_asact.insact(l_ass_act_id,
                                     asg_rec.assignment_id,
                                     pactid,
                                     chunk,
                                     null);
          end if;
      end loop; -- end asg_rec
    elsif g_pick_from_asg = 'Y' then
      if chunk = 1 then
           hr_utility.set_location('Entering csr_asg',40);
      end if;
      for asg_rec in csr_asg(l_asg_set) loop
          -- Check if assignment action already created for this assignment
          l_arch := check_action(pactid,asg_rec.assignment_id);
          if l_arch then
              -- hr_utility.set_location('Creating assignment action for ' || asg_rec.assignment_id,30);
              select pay_assignment_actions_s.nextval
              into   l_ass_act_id
              from   dual;
              --
              -- insert into pay_assignment_actions.
              hr_nonrun_asact.insact(l_ass_act_id,
                                     asg_rec.assignment_id,
                                     pactid,
                                     chunk,
                                     null);
          end if;
      end loop; -- end asg_rec
    end if;

end action_creation;

------------------------------function get_teachers_number--------------------------------------
-- Fetches teachers number depending on the configuration DFF PQP_GB_SWF_TEACHER_NUM
-- If value is from person EIT/Qualification table function fetches the first not null value
-- for the column defined in the configuration.
function get_teachers_number(p_person_id in number
                            , p_effective_date in date) return varchar2 is
  cursor  qual_mbr_num is
  select  membership_number
  from    per_qualifications
  where   person_id = p_person_id
  and     membership_number is not null;
  ---
  e_teacher_no_nt_found exception;
  l_teachers_num    varchar2(100);
  l_proc      constant varchar2(50) := g_package || ' get_teachers_number';
begin
  hr_utility.set_location('Entering '|| l_proc, 10);

  if g_debug then
    hr_utility.set_location('p_person_id :'||p_person_id,10);
    hr_utility.set_location('p_effective_date :'||p_effective_date,10);
  end if;

  if g_teach_dff_name =  'PER_PEOPLE' then

    execute immediate g_teacher_sql_str into l_teachers_num using p_person_id, p_effective_date;

  elsif g_teach_dff_name =   'Extra Person Info DDF' then

    execute immediate g_teacher_sql_str into l_teachers_num using p_person_id;

  elsif g_teach_dff_name =  'QUAL_MEMBERSHIP_NUMBER'then
    open  qual_mbr_num;
    fetch qual_mbr_num into l_teachers_num;
    close qual_mbr_num;
  end if;

  return l_teachers_num;

  hr_utility.set_location('Leaving '|| l_proc, 100);
  exception when
    no_data_found then
      hr_utility.set_location('Leaving with error '|| l_proc, 888);
      return null;
    when others  then
      hr_utility.set_location('Leaving with error '|| l_proc, 999);
      hr_utility.set_location(sqlerrm,999);
      return null;
end get_teachers_number;

------------------------------function get_dcsf_values--------------------------
-- This function queries PQP_CONFIGURATION_VALUES table for the given context
-- and returns the dcsf equivalent for the passed value.
-- This function is used for the following context.
-- PQP_GB_SWF_ETHNIC_CODES        Staff Details - Ethnic Origin
-- PQP_GB_SWF_PAY_SCALE_MAPPING   Pay - Pay Scale
-- PQP_GB_SWF_QTS_ROUTE_SRC Staff Details - QTS Route source
-- PQP_GB_SWF_QUAL_SUBJECT_MAP    Qualifications - Subject
function get_dcsf_values(p_context_name in varchar2,
                         p_value        in varchar2) return varchar2
is
  l_return pqp_configuration_values.pcv_attribute2%type;
  l_proc  constant varchar2(50):= g_package||'get_dcsf_values';

  cursor get_config_values (p_context_name in varchar2 , p_value in varchar2) is
  select pcv_information2
  from   pqp_configuration_values
  where  pcv_information_category = p_context_name
  and    pcv_information1 = p_value
  and    business_group_id = g_business_group_id;

begin

  open get_config_values(p_context_name,p_value);
  fetch get_config_values into l_return;
  close get_config_values;

  return l_return;

end get_dcsf_values;
------------------------------function fetch_staff_rec--------------------------
-- fetches details for staff details module.Validates the fetched values with
-- staff_details_validate if no errors , details are archived.
function fetch_staff_details( p_assactid   in number,
                          p_effective_date in date,
                          p_staff_rec      out nocopy act_info_rec) return boolean is

  l_proc  constant varchar2(50):= g_package||'fetch_staff_rec';


  cursor csr_person_details(csr_effective_date date) is
  select /*+ ORDERED */
          pap.person_id,
          pap.employee_number,
          paa.assignment_id,
          pap.first_name,
          pap.last_name ,
          paa.assignment_number,
          pap.national_identifier,
          decode(pap.sex,'M','1','F','2','9') sex,
          pap.previous_last_name,
					per_information1 ethnic_code,
          pap.date_of_birth date_of_birth,
					to_char(pap.date_of_birth,'YYYY-MM-DD') dob_dcsf
  from    pay_assignment_actions act,
          per_all_assignments_f      paa,
          per_all_people_f           pap
  where  act.assignment_action_id = p_assactid
  and    act.assignment_id = paa.assignment_id
  and    paa.person_id = pap.person_id
  and    csr_effective_date between paa.effective_start_date and paa.effective_end_date
  and    csr_effective_date between pap.effective_start_date and pap.effective_end_date;

  cursor get_swf_dff_vaues(p_person_id in number) is
  select  hr_general.decode_lookup('YES_NO',pei_information1 ) qt_sts,
          fnd_date.canonical_to_date(pei_information2)  qt_status_date,
          pei_information3  qts_route,
          pei_information4  teacher_number,
          pei_information5  workforce_inc_typ,
          hr_general.decode_lookup('YES_NO',pei_information9)  hlta_sts,
          pei_information10 origin
  from    per_people_extra_info pei
  where   pei.information_type = 'PQP_SCHOOL_WORKFORCE_CENSUS'
  and     pei.person_id        = p_person_id;
  --
  cursor csr_disablity(p_person_id number, csr_effective_date date) is
  select 'YES'
  from   per_disabilities_f pdf
  where  pdf.person_id = p_person_id
  and    csr_effective_date between pdf.effective_start_date and pdf.effective_end_date;
  --
  cursor csr_cont_eff_date_asg is
  select max(effective_end_date)
  from   pay_assignment_actions act,
         per_all_assignments_f      paa,
         per_assignment_status_types pas
  where  act.assignment_action_id = p_assactid
  and    act.assignment_id = paa.assignment_id
  and    paa.assignment_status_type_id = pas.assignment_status_type_id
  and   pas.per_system_status = 'ACTIVE_ASSIGN';

  cursor csr_cont_eff_date_contract is
  select max(effective_end_date)
  from   pay_assignment_actions act,
         pqp_assignment_attributes_f    att
  where  act.assignment_action_id = p_assactid
  and    act.assignment_id = att.assignment_id;

  cursor get_person_id(p_effective_date date) is
  select ppf.person_id,ppf.employee_number
  from   pay_assignment_actions act,
         per_all_assignments_f      paa,
         per_all_people_f       ppf
  where  act.assignment_action_id = p_assactid
  and    act.assignment_id = paa.assignment_id
  and    ppf.person_id     = paa.person_id
  and    p_effective_date between paa.effective_start_date and paa.effective_end_date
  and    p_effective_date between ppf.effective_start_date and ppf.effective_end_date;

  cursor get_estab_no( p_assignment_id in number , p_effective_date in date) is
  select hlei.lei_information2
  from   per_all_assignments_f asg,
         hr_location_extra_info hlei
  where asg.business_group_id + 0 = g_business_group_id
  and   asg.location_id = hlei.location_id
  and   asg.assignment_id = p_assignment_id
  and   p_effective_date between asg.effective_start_date and asg.effective_end_date
  and   asg.location_id = hlei.location_id
  and   hlei.information_type = 'PQP_GB_EDU_ESTB_INFO'
  and   hlei.lei_information6 = g_lea_number;


  l_staff_rec                 csr_person_details%rowtype;
  l_swf_def_values_rec        get_swf_dff_vaues%rowtype;
  l_asg_active_on_census_day  boolean := true; -- variable set to true if he is active on census day
  l_person_id                 number;
  l_employee_number           per_all_people_f.employee_number%type;
  l_qt_status                 hr_lookups.meaning%type;
  l_qts_route                 hr_lookups.meaning%type;
  l_disablity                 varchar2(5) := 'NO';
  l_hlta_status               hr_lookups.meaning%type;
  l_teachers_number           varchar2(240);
  l_arch                      boolean;
  l_effective_date            date;
  e_cont_eff_dt_nt_found      exception;
  l_estab_number              number;
  l_valid_ethnic_code	      varchar2(1);
  l_asg_end_date              date;


begin
  hr_utility.set_location('Entering: '||l_proc,1);
  l_arch := true;


       hr_utility.set_location('Session_id Fetch person :'|| sys_context('userenv','sessionid'),777777);
       hr_utility.set_location('g_census_year : ' || g_census_year,30);
       hr_utility.set_location('g_census_day  : ' || g_census_day,30);
       hr_utility.set_location('g_cont_data_st_date  : ' || g_cont_data_st_date,30);
       hr_utility.set_location('g_cont_data_end_date : ' || g_cont_data_end_date,30);
       hr_utility.set_location('g_lea_number  : ' || g_lea_number,30);
       hr_utility.set_location('g_estb_number : ' || g_estb_number,30);
       hr_utility.set_location('g_exclude_qual: ' || g_exclude_qual,30);
       hr_utility.set_location('l_effective_date    : ' || l_effective_date,30);
       hr_utility.set_location('g_business_group_id : ' || g_business_group_id,30);
       hr_utility.set_location('g_qts_route_sql_str : ' || g_qts_route_sql_str,30);
       hr_utility.set_location('g_qts_sql_str : ' || g_qts_sql_str,30);
       hr_utility.set_location('g_hlta_sql_str : ' || g_hlta_sql_str,30);

  -- check if staff is present as of census day
  open csr_person_details(g_census_day);
   fetch csr_person_details into l_staff_rec;
    if csr_person_details%notfound then
      l_asg_active_on_census_day := false; -- continuous data to be archived
      hr_utility.set_location('Staff record not present on census day'||'Assignment act ID :'||p_assactid,1);
    end if;
  close csr_person_details;

  -- if staff present as of census day then the effective date for the contract
  -- is census day.
  if l_asg_active_on_census_day then
    l_effective_date := g_census_day;
    l_person_id:= l_staff_rec.person_id;
    l_employee_number:= l_staff_rec.employee_number;


    -- the person is active but the contract is end-dated.
    -- pick the least of contract end date and census day.
    if g_pick_from_asg <> 'Y' then
      open  csr_cont_eff_date_contract;
      fetch csr_cont_eff_date_contract into l_effective_date;
      close csr_cont_eff_date_contract;

      l_effective_date := least(g_census_day,l_effective_date);
    end if;
  else
    -- if staff not present as of census day then the effective date is either
    -- assignment End date or the contract type End date depending on the
    -- configuration
    if g_pick_from_asg = 'Y' THEN
      open  csr_cont_eff_date_asg;
      fetch csr_cont_eff_date_asg into l_effective_date;
      close csr_cont_eff_date_asg;

    ELSE -- pick from pqp contract types

      open  csr_cont_eff_date_contract;
      fetch csr_cont_eff_date_contract into l_effective_date;
      close csr_cont_eff_date_contract;

      -- the person is terminated but the contract is valid till EOT
      -- get least of contract end date and assignment end date.
      open  csr_cont_eff_date_asg;
      fetch csr_cont_eff_date_asg into l_asg_end_date;
      close csr_cont_eff_date_asg;

      l_effective_date := least(l_effective_date,l_asg_end_date);
    end if;

    open  get_person_id(l_effective_date);
    fetch get_person_id into l_person_id,l_employee_number;
    close get_person_id;

    open csr_person_details(l_effective_date);
    fetch csr_person_details into l_staff_rec;
      if csr_person_details%notfound then
        hr_utility.set_location('Staff record could not be fetched as of ' || l_effective_date ||' for Assignment act ID :'||p_assactid,9999);
        fnd_file.put_line(fnd_file.log,'Staff record could not be fetched as of ' || l_effective_date ||' for Assignment act ID :'||p_assactid);
        --raise e_cont_eff_dt_nt_found;
      end if;
    close  csr_person_details;

  end if;

  -- if extablishment number is not entered as parameter, compute it here

    open  get_estab_no(l_staff_rec.assignment_id,l_effective_date);
    fetch get_estab_no into l_estab_number;
    close get_estab_no;

  if g_estb_number is not null  and g_estb_number <> l_estab_number then
  l_arch := false;
  hr_utility.set_location('This assignment should not be processed',99);
  end if;



  open csr_disablity(l_person_id,l_effective_date);
  fetch csr_disablity into l_disablity;
  close csr_disablity;
  -- Dynamic SQL execution starts.
  -- if any dynamic sql fails, it gets reported in the log file and the process
  -- continues
  begin
    l_teachers_number:= get_teachers_number(l_person_id,l_effective_date);
    exception when others then
       hr_utility.set_location('Teachers Number could not be fetched as of ' || l_effective_date ||'for Person ID :'||l_person_id,9999);
  end;

  begin
    execute immediate g_qts_sql_str into l_qt_status using g_business_group_id,l_effective_date, l_person_id;
    exception when others then
       hr_utility.set_location('QT status could not be fetched as of ' || l_effective_date ||'for Person ID :'||l_person_id,9999);
  end;

    hr_utility.set_location('l_qt_status :'||l_qt_status,10);

  begin
    execute immediate g_qts_route_sql_str into l_qts_route using g_business_group_id,l_effective_date, l_person_id;
    exception when others then
       hr_utility.set_location('QTS Route could not be fetched as of' || l_effective_date ||'for Person ID :'||l_person_id,9999);
  end;

  begin
    if g_hlta_dff_name = 'JOB' then
      execute immediate g_hlta_sql_str into l_hlta_status using g_business_group_id,l_effective_date, l_person_id;
    elsif g_hlta_dff_name in ('PER_PEOPLE','PER_ASSIGNMENTS') then
      execute immediate g_hlta_sql_str into l_hlta_status using l_person_id, l_effective_date;
    end if;

    exception when others then
      hr_utility.set_location('HLTA status could not be fetched as of' || l_effective_date ||'for Person ID :'||l_person_id,9999);
  end;

  -- Specific staff details can be entered in the extra person information
  -- fetch those values and use them if the computed value(thru configuration)
  -- is null
  open  get_swf_dff_vaues(l_person_id);
  fetch get_swf_dff_vaues into l_swf_def_values_rec;
  close get_swf_dff_vaues;



  l_staff_rec.ethnic_code	:= get_dcsf_values('PQP_GB_SWF_ETHNIC_CODES',l_staff_rec.ethnic_code);
  l_teachers_number :=  nvl(l_teachers_number,l_swf_def_values_rec.teacher_number);
   if l_swf_def_values_rec.qt_status_date < g_census_day then
     l_qt_status       :=  nvl(l_qt_status,l_swf_def_values_rec.qt_sts);
   end if;
  l_qts_route       :=  nvl(l_qts_route,l_swf_def_values_rec.qts_route);
  l_hlta_status     :=  nvl(l_hlta_status,l_swf_def_values_rec.hlta_sts);

  -- Validation starts
  -- the numbers in the comment denotes the validation numbers in SWF tech spec
  -- If any error occurs, insert into pay_message_lines with the procedure
  -- populate_run_msg.

  -- 4100
	if l_qt_status = 'Yes' and l_teachers_number is null then
			l_arch := false;
			hr_utility.set_location('Teachers number error',10);
			populate_run_msg(p_assactid,'Qualified Teacher with Teacher Number missing');
	end if;

	-- 4105
	if l_teachers_number is not null and length(l_teachers_number) <> 7 then
			l_arch := false;
			hr_utility.set_location('Teachers number error',20);
			populate_run_msg(p_assactid,'Teacher number is not 7 digits');
	end if;


	begin
		l_teachers_number := to_number(l_teachers_number);
		exception when others then
		    l_arch := false;
		hr_utility.set_location('Teachers number has invalid characters',20);
		populate_run_msg(p_assactid,'Teachers number has invalid characters');
	end;


	-- 4110
  if l_staff_rec.last_name is null then
    l_arch := false;
    populate_run_msg(p_assactid,'Family Name is missing');
    hr_utility.set_location('last Name error',10);
  elsif l_staff_rec.last_name is not null and instr(l_staff_rec.last_name,'  ') > 0 then
    l_arch := false;
    populate_run_msg(p_assactid,'Family Name contains too many consecutive spaces');
    hr_utility.set_location('last Name error',10);
  end if;

	-- 4120
  if l_staff_rec.first_name is null then
     l_arch := false;
     hr_utility.set_location('First Name error',10);
     populate_run_msg(p_assactid,'Given Name is missing');
  elsif l_staff_rec.first_name is not null and instr(l_staff_rec.first_name,'  ') > 0 then
    l_arch := false;
    hr_utility.set_location('First Name error',20);
    populate_run_msg(p_assactid,'Given Name contains too many consecutive spaces');
  end if;

  -- 4140
  if instr(l_staff_rec.previous_last_name,'  ') > 0 then
    l_arch := false;
    hr_utility.set_location('Previous Name error',10);
    populate_run_msg(p_assactid,'Former Family Name contains too many consecutive spaces');
  end if;

	-- 4150,4160Q,4155
  if l_staff_rec.national_identifier is null then
    l_arch := false ;
    populate_run_msg(p_assactid,'Member of workforce with missing NI Number');
    hr_utility.set_location('NI error',20);
  elsif l_staff_rec.national_identifier is not null and
    hr_gb_utility.ni_validate(l_staff_rec.national_identifier,sysdate) <> 0 then
    l_arch := false;
    populate_run_msg(p_assactid,'NI Number has invalid Format');
    hr_utility.set_location('NI error',10);
	if substr(l_staff_rec.national_identifier,1,2) in ('GB','BG','NK','KN','TN','NT','ZZ') then
                l_arch := false;
		populate_run_msg(p_assactid,'Appears to be a temporary or non-standard NI Number.  This must be resolved or removed');
		hr_utility.set_location('NI error',10);
	end if;
  end if;

	--4180
  if l_staff_rec.sex is null then
    l_arch := false;
    populate_run_msg(p_assactid,'Gender is missing');
    hr_utility.set_location('Gender error',10);
  end if;

	-- 4190
  if l_staff_rec.dob_dcsf is null then
  l_arch := false;
    populate_run_msg(p_assactid,'Date of Birth missing');
    hr_utility.set_location('DOB error',30);
  end if;

	-- 4190
  if not(months_between(g_census_day,l_staff_rec.date_of_birth)/12 between 15 and 100) then
    l_arch := false;
    populate_run_msg(p_assactid,'Person''s age must be between 15 and 100 years');
    hr_utility.set_location('Age error',30);
  end if;
	-- 4210Q
 if not(months_between(trunc(g_census_day),l_staff_rec.date_of_birth)/12 between 16 and 70) then
    populate_run_msg(p_assactid,'Please check: Person''s age expected to be between 16 and 70 years','W');
    hr_utility.set_location('Age warning',30);
  end if;

	--4220
	if l_staff_rec.ethnic_code is not null then
		begin
			select	 'Y'
				into	 l_valid_ethnic_code
				from	 dual
			 where	 exists
				 (select lookup_code
				  from	 hr_lookups hl
				  where	 hl.lookup_type = 'UK_ETHNIC_CODES'
						 and hl.enabled_flag = 'Y'
						 and hl.lookup_code = l_staff_rec.ethnic_code);
			exception
			when others
			then
				l_arch := false;
				populate_run_msg (p_assactid, 'Ethnicity is invalid ');
				hr_utility.set_location ('Ethnicity error', 10);
		end;
	end if;

	if l_staff_rec.ethnic_code is not null and length(l_staff_rec.ethnic_code) <> 4 then
				l_arch := false;
				populate_run_msg (p_assactid, 'Ethnicity is invalid ');
				hr_utility.set_location ('Ethnicity length error', 10);
	end if;

	if l_staff_rec.ethnic_code is null then
		populate_run_msg (p_assactid, 'Please Check: Ethnicity is missing ','W');
		hr_utility.set_location ('Ethnicity length error', 10);
	end if;

  -- 4225 Disablity hardcoded, cannot be other than YES or NO.
	-- 4230
	if l_qt_status is not null and l_qt_status not in ('Yes','No') then
			l_arch := false;
			populate_run_msg (p_assactid, 'QT Status is invalid ');
			hr_utility.set_location (l_qt_status||' QT status error', 10);
	end if;

	-- 4235Q
	if l_qt_status = 'Yes' and months_between(trunc(g_census_day),l_staff_rec.date_of_birth)/12 < 21 then
			populate_run_msg (p_assactid, 'Person cannot be shown as having QT status and be under 21 on 1 January','W');
			hr_utility.set_location ('QT status Age error', 10);
	end if;

	-- 4240
	if l_hlta_status is not null and l_hlta_status not in ('Yes','No') then
			l_arch := false;
			populate_run_msg (p_assactid, 'HLTA Status is invalid ');
			hr_utility.set_location (l_hlta_status||' HLTA status error', 10);
	end if;

	-- 4245
	if l_hlta_status = 'Yes' and months_between(trunc(g_census_day),l_staff_rec.date_of_birth)/12 < 18 then
			l_arch := false;
			populate_run_msg (p_assactid, 'Person cannot be shown as having HLTA status and be under 18 on 1 January');
			hr_utility.set_location (l_hlta_status||' HLTA status Age error', 10);
	end if;

	-- 4250
	if l_qts_route is not null then
		begin
			select	 'Y'
			into	 l_valid_ethnic_code
			from	 dual
			where	 exists(select	lookup_code
				from	hr_lookups hl
				where	hl.lookup_type = 'PQP_GB_SWF_QTS_ROUTES'
				and     hl.enabled_flag = 'Y'
				and     hl.lookup_code = l_qts_route);
			exception
				when others
				then
					l_arch := false;
					populate_run_msg (p_assactid, 'QTS Route is invalid');
					hr_utility.set_location (l_qts_route||' QTS route error', 10);
		 end;
	end if;

	if l_qts_route is not null and length(l_qts_route) <> 4 then
				l_arch := false;
				populate_run_msg (p_assactid, 'QTS Route is invalid');
				hr_utility.set_location (l_qts_route||' QTS route length error', 10);
	end if;

-- DO NOT CHANGE the archive structure as many values from this are passed as
-- input values for othe procedures in archive code

  p_staff_rec.action_info_category  := 'GB_SWF_STAFF_DETAILS';
  p_staff_rec.person_id             := l_staff_rec.person_id;
  p_staff_rec.assignment_id         := l_staff_rec.assignment_id;
  p_staff_rec.effective_date        := sysdate;
  p_staff_rec.act_info1             := l_staff_rec.person_id;
  p_staff_rec.act_info2             := l_estab_number;
  p_staff_rec.act_info3             := l_teachers_number;
  p_staff_rec.act_info4             := l_staff_rec.last_name;
  p_staff_rec.act_info5             := l_staff_rec.first_name;
  p_staff_rec.act_info6             := l_staff_rec.previous_last_name;
  p_staff_rec.act_info7             := l_staff_rec.national_identifier;
  p_staff_rec.act_info8             := l_staff_rec.sex;
  p_staff_rec.act_info9             := l_staff_rec.dob_dcsf;
  p_staff_rec.act_info10            := l_staff_rec.ethnic_code;
  p_staff_rec.act_info11            := l_disablity;
  p_staff_rec.act_info12            := l_qt_status; 	 -- passed as in parameter to fetch_payment_details
  p_staff_rec.act_info13            := l_hlta_status; 	 -- passed as in parameter to fetch_contract_details
  p_staff_rec.act_info14            := l_qts_route;
  p_staff_rec.act_info15            := null; --l_abs_on_cd;
  p_staff_rec.act_info16            := l_effective_date; -- passed as in parameter to all functions
																												 -- called in archive code


  hr_utility.set_location('Leaving: '||l_proc,999);
  return l_arch;
   exception
    when others then
        hr_utility.trace(sqlerrm);
        hr_utility.set_location('leaving with error: '||l_proc,9999);
        raise;
end fetch_staff_details;

/*-------------------------function run_user_formula --------------------------*/
-- This function executes the user fourmula and provides the results
-- for date of arrival, the format the formula should return is 'YYYY-MM-DD'
-- for hours per week and fte hours, the formula should return values in
-- number(s).numbers(s) format
-- The formula will throw an error if the format is anything other than the
-- specified format
function run_user_formula(p_formula_id    in      ff_formulas_f.formula_name%type
                         ,p_assignment_id   in      number
                         ,p_effective_date  in      date
                         ,p_business_group_id in    number
                         ,p_assignment_number in    varchar2
                         )
return varchar2 is

  cursor get_formula_id is
  select ff.formula_id,ff.formula_name
    from ff_formulas_f ff
   where ff.formula_id        = p_formula_id
     and ff.business_group_id  = p_business_group_id
     and p_effective_date       between ff.effective_start_date and ff.effective_end_date;
--
  l_inputs     ff_exec.inputs_t;
  p_inputs     ff_exec.inputs_t;
  l_outputs    ff_exec.outputs_t;
  l_result     varchar2(25);
  l_formula_id  ff_formulas_f.formula_id%type;
  l_formula_name  ff_formulas_f.formula_name%type;
  l_warning_msg varchar2(300);

  l_proc  constant varchar2(50):= g_package||'run_user_formula';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
-- setting the contexts
   p_inputs(1).name   := 'ASSIGNMENT_ID';
   p_inputs(1).value  := p_assignment_id;
   p_inputs(2).name   := 'EFFECTIVE_DATE';
   p_inputs(2).value  := fnd_date.date_to_canonical(p_effective_date);
   p_inputs(3).name   := 'BUSINESS_GROUP_ID';
   p_inputs(3).value  := p_business_group_id;

   l_formula_id := null;
   open get_formula_id;
   fetch get_formula_id into l_formula_id,l_formula_name;
   if get_formula_id%notfound then
         hr_utility.set_location('formula -'||l_formula_name||'- not present/effective in table',11);
         l_warning_msg := 'formula -'||l_formula_name||'- not present or effective for assignment '||p_assignment_number||' on '||p_effective_date;
         fnd_file.put_line (fnd_file.log, l_warning_msg);
   end if;
   close get_formula_id;

   if l_formula_id is not null then
     hr_utility.trace(' Inside run_user_formula '||l_formula_name);
     ff_exec.init_formula(l_formula_id, p_effective_date , l_inputs, l_outputs);

     if l_inputs.count > 0 and p_inputs.count > 0 then
        for i in 1..l_inputs.count
        loop
           for j in 1..p_inputs.count
           loop
              if l_inputs(i).name = p_inputs(j).name then
                 l_inputs(i).value := p_inputs(j).value;
              exit;
              end if;
           end loop;
        end loop;
     end if;

     for i in 1..l_inputs.count loop
           hr_utility.trace(' i= '||i||' name '||l_inputs(i).name ||' value '||l_inputs(i).value);
     end loop;

    ff_exec.run_formula(l_inputs,l_outputs);
    hr_utility.trace(' calculated value from user formula '||l_outputs(1).value);
    l_result := l_outputs(1).value ;
  end if;

  hr_utility.set_location('Leaving: '||l_proc,999);

  return l_result;

   exception
      when others then
          hr_utility.trace(sqlerrm);
          hr_utility.set_location('leaving with error: '||l_proc,9999);
          raise;
end;


/*-------------------------Procedure run_seeded_formula --------------------------*/
-- This procedure executes the formula GB_CALCULATE_FTE_USING_PQP_CONTRACT_TYPES
-- and returns if any error or the calculated FTE Ratio Value
procedure run_seeded_formula(p_assignment_id   in      number
                         ,p_effective_date  in      date
                         ,p_business_group_id in    number
                         ,p_assignment_number in    varchar2
			 ,fte_ratio	     out NOCOPY   number
			 ,error_message      out NOCOPY   varchar2
                         ) is


  cursor get_formula_id is
  select ff.formula_id,ff.formula_name
    from ff_formulas_f ff
   where ff.formula_name       = 'GB_CALCULATE_FTE_USING_PQP_CONTRACT_TYPES'
     and ff.legislation_code  = 'GB'
     and p_effective_date       between ff.effective_start_date and ff.effective_end_date;
--
  l_inputs     ff_exec.inputs_t;
  p_inputs     ff_exec.inputs_t;
  l_outputs    ff_exec.outputs_t;
  l_result     varchar2(25);
  l_formula_id  ff_formulas_f.formula_id%type;
  l_formula_name  ff_formulas_f.formula_name%type;
  l_warning_msg varchar2(300);

  l_proc  constant varchar2(50):= g_package||'run_seeded_formula';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
-- setting the contexts
   p_inputs(1).name   := 'ASSIGNMENT_ID';
   p_inputs(1).value  := p_assignment_id;
   p_inputs(2).name   := 'DATE_EARNED';
   p_inputs(2).value  := fnd_date.date_to_canonical(p_effective_date);
   p_inputs(3).name   := 'BUSINESS_GROUP_ID';
   p_inputs(3).value  := p_business_group_id;

   l_formula_id := null;
   open get_formula_id;
   fetch get_formula_id into l_formula_id,l_formula_name;
   if get_formula_id%notfound then
         hr_utility.set_location('formula -'||l_formula_name||'- not present/effective in table',11);
         l_warning_msg := 'formula -'||l_formula_name||'- not present or effective for assignment '||p_assignment_number||' on '||p_effective_date;
         fnd_file.put_line (fnd_file.log, l_warning_msg);
   end if;
   close get_formula_id;

   if l_formula_id is not null then
     hr_utility.trace(' Inside run_seeded_formula '||l_formula_name);
     ff_exec.init_formula(l_formula_id, p_effective_date , l_inputs, l_outputs);

     if l_inputs.count > 0 and p_inputs.count > 0 then
        for i in 1..l_inputs.count
        loop
           for j in 1..p_inputs.count
           loop
              if l_inputs(i).name = p_inputs(j).name then
                 l_inputs(i).value := p_inputs(j).value;
              exit;
              end if;
           end loop;
        end loop;
     end if;

     for i in 1..l_inputs.count loop
           hr_utility.trace(' i= '||i||' name '||l_inputs(i).name ||' value '||l_inputs(i).value);
     end loop;

    ff_exec.run_formula(l_inputs,l_outputs);

    for i in 1..l_outputs.count loop
           hr_utility.trace(' i= '||i||' name '||l_outputs(i).name ||' value '||l_outputs(i).value);

	   if l_outputs(i).name = 'FTE' then
		fte_ratio := l_outputs(i).value;
	   end if;

	   if l_outputs(i).name = 'ERROR_MESSAGE' then
		error_message := l_outputs(i).value;
	   end if;
    end loop;

  end if;

  hr_utility.set_location('Leaving: '||l_proc,999);

   exception
      when others then
          hr_utility.trace(sqlerrm);
          hr_utility.set_location('leaving with error: '||l_proc,9999);
          raise;
end run_seeded_formula;

---------------------------function fetch_addl_payment_details -----------------

function fetch_addl_payment_details(p_assactid in number,
                                    p_assignment_id  in number,
                                    p_effective_date in date,
                                    p_addl_payments out nocopy addl_payment_dtl_tab) return boolean is

 l_proc  constant varchar2(50):= g_package||'fetch_addl_payment_details';

 begin
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('Parameters         : ',20);
    hr_utility.set_location('p_assactid         : '||p_assactid,20);
    hr_utility.set_location('p_assignment_id    : '||p_assignment_id,20);
    hr_utility.set_location('p_effective_date   : '||p_effective_date,20);

     begin
        select pexi.eei_information1,to_char(nvl(sum(prrv.result_value),0),'fm999999.00')
        bulk collect into p_addl_payments
        from per_all_assignments_f       paf,
             pay_element_entries_f       pee,
             pay_element_type_extra_info pexi,
             pay_run_results             prr,
             pay_input_values_f          piv,
             pay_run_result_values       prrv,
             pay_assignment_actions   assact,
      	   pay_payroll_actions      pact,
      	   per_time_periods         pptp
       where paf.assignment_id = p_assignment_id
         and paf.assignment_id = pee.assignment_id
         and pee.element_type_id =  pexi.element_type_id
         and pexi.information_type = 'PQP_SWFC_ADDITIONAL_PAYMNT_CAT'
         and pexi.element_type_id = prr.element_type_id
         and prr.assignment_action_id = assact.assignment_action_id
         and assact.payroll_action_id = pact.payroll_action_id
         and pact.time_period_id  = pptp.time_period_id
         and pptp.regular_payment_date between add_months(trunc(g_census_day),-12) and trunc(g_census_day)-1
         and prr.run_result_id = prrv.run_result_id
         and prr.status in ('P','PA')
         and prrv.input_value_id = piv.input_value_id
         and piv.element_type_id = pexi.element_type_id
         and piv.name = 'Pay Value'
         and p_effective_date between paf.effective_start_date and paf.effective_end_date
         and p_effective_date between pee.effective_start_date and pee.effective_end_date
         and p_effective_date between piv.effective_start_date and piv.effective_end_date
         group by pexi.eei_information1;

          exception
                when others then
                  hr_utility.trace(sqlerrm);
                  hr_utility.set_location('leaving with error: '||l_proc,9999);
                  raise;
        end;
    hr_utility.set_location('Leaving: '||l_proc,99);
  return true;
end fetch_addl_payment_details;

---------------------------function fetch_role_details -------------------------
-- this is called in fetch_payment_details procedure. There is no separate call
-- from archive code.

function fetch_role_details   (p_assactid       in number,
                              p_effective_date in date,
                              p_person_id      in number,
                              p_assignment_id  in number,
                              p_addl_role    out nocopy addl_role_tab) return boolean is

  l_proc  constant varchar2(50):= g_package||'fetch_role_details';

  cursor get_assignment_details is
  select paa.assignment_number   assignment_number,
       paa.employee_category   employee_cat,
       paa.employment_category assignment_cat
  from per_all_assignments_f paa
 where paa.assignment_id = p_assignment_id
   and p_effective_date between paa.effective_start_date and paa.effective_end_date;

   cursor role_dcsf(p_role in varchar2) is
   select pcv_information4
     from pqp_configuration_values
    where business_group_id = g_business_group_id
      and pcv_information_category = 'PQP_GB_SWF_ROLE_MAPPING'
      and pcv_information2 = p_role;


  l_main_role         hr_lookups.lookup_code%type;
  l_assignment_number per_all_assignments_f.assignment_number%type;
  l_asg_cat           per_all_assignments_f.employment_category%type;
  l_employee_cat      per_all_assignments_f.employee_category%type;
  l_role_tab_idx      pls_integer;


begin
  hr_utility.set_location('Entering: '||l_proc,10);
  hr_utility.set_location('p_assactid       : '||p_assactid,20);
  hr_utility.set_location('p_effective_date : '||p_effective_date,20);
  hr_utility.set_location('p_person_id      : '||p_person_id,20);
  hr_utility.set_location('p_assignment_id  : '||p_assignment_id,20);


  if g_role_src in ('JOB','GRD','POS') then
    --fetch main role
    begin
      execute immediate g_role_sql_str into l_main_role using g_business_group_id,p_effective_date, p_assignment_id;
        exception when others then
          hr_utility.set_location('main role could not be fetched as of ' || p_effective_date ||' for Assignment ID :'||p_assignment_id,9999);
    end;
  elsif g_role_src in ('EMP_CAT','EMPLOYEE_CATG') then -- asg category
      open  get_assignment_details;
      fetch get_assignment_details into l_assignment_number,l_employee_cat,l_asg_cat;
      close get_assignment_details;
  end if;

  if g_role_src = 'EMP_CAT' then
    open role_dcsf(l_asg_cat);
    fetch role_dcsf into l_main_role;
    close role_dcsf;
  elsif g_role_src= 'EMPLOYEE_CATG' then
    open role_dcsf(l_employee_cat);
    fetch role_dcsf into l_main_role;
    close role_dcsf;
  end if;

  if l_main_role is null then
    hr_utility.set_location('Main role not fetched for Assignment no :'||l_assignment_number,9999);
  end if;

  -- Bulk collect additional roles into p_addl_role
  if g_addl_role_src = 'Assignment Developer DF' then
    begin
      execute immediate g_addl_role_sql_str bulk collect into p_addl_role using p_assignment_id,g_business_group_id;
        exception when others then
          hr_utility.set_location('Error while fetching Additional Role for Assignment ID :'||p_assignment_id,7777);
    end;
  elsif g_addl_role_src in('Extra Position Info DDF','Extra Job Info DDF') then
    begin
      execute immediate g_addl_role_sql_str bulk collect into p_addl_role using p_assignment_id,p_effective_date;
        exception when others then
         hr_utility.set_location('Error while fetching Additional Role' || p_effective_date ||'for Assignment ID :'||p_assignment_id,8888);
    end;
  end if;

  l_role_tab_idx := p_addl_role.count;

  p_addl_role(l_role_tab_idx) := l_main_role; -- Append main role with all additional roles

  hr_utility.set_location('Leaving: '||l_proc,999);
 return true;
 exception when others then
   hr_utility.set_location('Leaving with error : '||l_proc,99999);
end fetch_role_details;

function fetch_hours_details(p_assactid     in number,
                             p_assignment_id in number ,
                             p_effective_date in date,
                             p_staff_cat    in varchar2,
			     p_person_id    in number,
			     p_contract_type in varchar2,
			     p_contract_end_date in varchar2,
                             p_hrs_rec   out nocopy act_info_rec) return boolean is

  cursor get_hrs_source is
  select pcv_information1 hrs_source
  from   pqp_configuration_values pcv
  where  pcv.pcv_information_category = 'PQP_GB_SWF_HOURS'
  and    pcv.business_group_id = g_business_group_id;

  cursor get_hrs_details(p_contract_type in varchar2) is
  select pcv_information1 hrs_source,
         pcv_information2 contract_type,
         pcv_information3 hrs_per_wk_formula,
         pcv_information4 wks_per_yr_source,
         pcv_information5 wks_per_yr_formula,
         pcv_information6 wks_per_yr_column
  from   pqp_configuration_values pcv
  where  pcv.pcv_information_category = 'PQP_GB_SWF_HOURS'
  and    nvl(pcv.pcv_information2,p_contract_type)  = p_contract_type
  and    pcv.business_group_id = g_business_group_id;

  cursor get_hrs_details_asg (p_staff_cat in varchar2) IS
  select pcv_information8 default_weeks_per_yr
  from   pqp_configuration_values pcv
  where  pcv.pcv_information_category = 'PQP_GB_SWF_HOURS'
  and    pcv.pcv_information7  = decode(p_staff_cat,1,'REGULAR_TEACHER',2,'AGENCY_TEACHER',3,'TEACHING_ASSISTANT',4,'OTHER_SUPPORT_STAFF')
  and    pcv.business_group_id = g_business_group_id;

  cursor get_asg_contract_details is
    select att.contract_type,work_pattern
    from   per_all_assignments_f paa,
           pqp_assignment_attributes_f att
    where  paa.assignment_id = p_assignment_id
    and    paa.assignment_id = att.assignment_id
    and    p_effective_date between att.effective_start_date and att.effective_end_date
    and    p_effective_date between paa.effective_start_date and paa.effective_end_date;

  cursor   get_asg_details is
   select  paa.assignment_number,paa.person_id,paa.frequency,paa.normal_hours
    from   per_all_assignments_f paa
    where  paa.assignment_id = p_assignment_id
    and    p_effective_date between paa.effective_start_date and paa.effective_end_date;

  cursor get_work_pattern(p_work_pattern in varchar2) is
  select val.value
  from pay_user_tables tab,
       pay_user_columns col,
       pay_user_rows_f r,
       pay_user_column_instances_f val
  where tab.user_table_name = 'PQP_COMPANY_WORK_PATTERNS'
  and tab.user_table_id=col.user_table_id
  and tab.user_table_id=r.user_table_id
  and col.user_column_id=val.user_column_id
  and r.user_row_id= val.user_row_id
  and col.user_column_name    = p_work_pattern
  and r.row_low_range_or_name = 'Number of Working Days'
  and g_census_day between r.effective_start_date and r.effective_end_date
  and g_census_day between val.effective_start_date and val.effective_end_date;


  cursor get_wk_per_yr(p_column_no in number,p_contract_type in varchar2) is
  select val.value
  from pay_user_tables tab,
       pay_user_columns col,
       pay_user_rows_f r,
       pay_user_column_instances_f val
  where tab.user_table_name = 'PQP_CONTRACT_TYPES'
  and tab.business_group_id = g_business_group_id
  and tab.user_table_id=col.user_table_id
  and tab.user_table_id=r.user_table_id
  and col.user_column_id=val.user_column_id
  and r.user_row_id= val.user_row_id
  and col.user_column_id    = p_column_no
  and r.row_low_range_or_name = p_contract_type
  and g_census_day between r.effective_start_date and r.effective_end_date
  and g_census_day between val.effective_start_date and val.effective_end_date;

  cursor get_fte_src is
  select pcv_information1,pcv_information2
  from   pqp_configuration_values pcv
  where  pcv.pcv_information_category = 'PQP_GB_SWF_FTE_HOURS'
  and    pcv.business_group_id = g_business_group_id;

  cursor get_fte_budget_hrs is
  select value
  from    per_assignment_budget_values_f
  where   assignment_id = p_assignment_id
  and     unit = 'HOURS'
  and     p_effective_date between effective_end_date and effective_start_date;

  l_proc      constant varchar2(50) := g_package || ' fetch_hours_details';
  l_hrs_details_rec   get_hrs_details%rowtype;
  l_contract_type     pqp_assignment_attributes_f.contract_type%type;
  l_assignment_number per_all_assignments_f.assignment_number%type;
  l_hrs_src           pqp_configuration_values.pcv_information1%type;
  l_hours_per_week    varchar2(20);
  l_weeks_per_yr      varchar2(20);
  l_work_pattern      pqp_assignment_attributes_f.work_pattern%type;
  l_frequency         per_all_assignments_f.frequency%type;
  l_no_of_hrs         per_all_assignments_f.normal_hours%type;
  l_person_id         per_all_assignments_f.person_id%type;
  l_no_of_days_per_wk number;
  l_fte_hrs           varchar2(1000);
  l_fte_src           varchar2(30);
  l_fte_formula_id    number;
  l_arch              boolean := true;
  l_fte_ratio	      number;
  l_error_message     varchar2(1000);
  l_check_if_num    number;
  l_error_flag varchar2(1) := 'N';

begin
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('Parameters         : ',20);
    hr_utility.set_location('p_assactid         : '||p_assactid,20);
    hr_utility.set_location('p_assignment_id    : '||p_assignment_id,20);
    hr_utility.set_location('p_staff_cat        : '||p_staff_cat,20);
    hr_utility.set_location('p_person_id        : '||p_person_id,20);
    hr_utility.set_location('p_effective_date   : '||p_effective_date,20);
    hr_utility.set_location('g_data_ret_type   : '||g_data_ret_type,20);


    open  get_hrs_source;
    fetch get_hrs_source into l_hrs_src;
    close get_hrs_source;

    open  get_asg_details;
    fetch get_asg_details into l_assignment_number,l_person_id,l_frequency,l_no_of_hrs;
    close get_asg_details;

    open  get_asg_contract_details;
    fetch get_asg_contract_details into l_contract_type,l_work_pattern;
    close get_asg_contract_details;

    if l_hrs_src = 'ASG' then

    if l_frequency = 'D' then
          open get_work_pattern(l_work_pattern);
          fetch get_work_pattern into l_no_of_days_per_wk;
          close get_work_pattern;

          l_no_of_hrs := l_no_of_hrs*l_no_of_days_per_wk;
    end if;

    l_hours_per_week := l_no_of_hrs;

    open  get_hrs_details_asg(p_staff_cat);
    fetch get_hrs_details_asg into l_weeks_per_yr;
    close get_hrs_details_asg;

    elsif l_hrs_src = 'CONTRACT_TYPE' then

    open  get_hrs_details(l_contract_type);
    fetch get_hrs_details into l_hrs_details_rec;
    close get_hrs_details;

    if l_contract_type is null then
      open  get_hrs_details('null');
      fetch get_hrs_details into l_hrs_details_rec;
      close get_hrs_details;
    end if;

    if l_hrs_details_rec.hrs_per_wk_formula is not null then
      begin
        l_hours_per_week := run_user_formula(l_hrs_details_rec.hrs_per_wk_formula,p_assignment_id,p_effective_date,g_business_group_id,l_assignment_number);
        hr_utility.set_location('Formula Result Value '||l_hours_per_week,20);
                exception when others then
                populate_run_msg(p_assactid,'Error while executing formula id '|| l_hrs_details_rec.hrs_per_wk_formula||'. Please refer Log file for details' );
                fnd_file.put_line(fnd_file.log,'Error while executing formula id '|| l_hrs_details_rec.hrs_per_wk_formula);
                fnd_file.put_line(fnd_file.log,sqlerrm);
      end;
    end if;

    if l_hrs_details_rec.wks_per_yr_source = 'FORMULA' then
        if l_hrs_details_rec.wks_per_yr_formula is not null then
          begin
            l_weeks_per_yr := run_user_formula(l_hrs_details_rec.wks_per_yr_formula,p_assignment_id,p_effective_date,g_business_group_id,l_assignment_number);
            hr_utility.set_location('Formula Result Value '||l_weeks_per_yr,20);
                exception when others then
                populate_run_msg(p_assactid,'Error while executing formula id '|| l_hrs_details_rec.wks_per_yr_formula||'. Please refer Log file for details' );
                fnd_file.put_line(fnd_file.log,'Error while executing formula id '|| l_hrs_details_rec.wks_per_yr_formula);
                fnd_file.put_line(fnd_file.log,sqlerrm);
          end;
        end if;
    elsif l_hrs_details_rec.wks_per_yr_source = 'COLUMN' then
         open  get_wk_per_yr(l_hrs_details_rec.wks_per_yr_column,l_contract_type);
         fetch get_wk_per_yr into l_weeks_per_yr;
         close get_wk_per_yr;
    end if;

    end if;

    l_fte_ratio := null;

    if p_staff_cat in (1 , 2) then
      l_fte_hrs := 32.5;
    elsif p_staff_cat = 3 then
      l_fte_hrs := 37;
    elsif p_staff_cat = 4 then
        open  get_fte_src;
        fetch get_fte_src into l_fte_src,l_fte_formula_id;
        close get_fte_src;

        if l_fte_src = 'CAL' and l_fte_formula_id is not null then
          begin
            l_fte_hrs := run_user_formula(l_fte_formula_id,p_assignment_id,p_effective_date,g_business_group_id,l_assignment_number);
            hr_utility.set_location('Formula Result Value '||l_fte_hrs,20);
                exception when others then
                populate_run_msg(p_assactid,'Error while executing formula id '|| l_fte_formula_id||'. Please refer Log file for details' );
                fnd_file.put_line(fnd_file.log,'Error while executing formula id '|| l_fte_formula_id);
                fnd_file.put_line(fnd_file.log,sqlerrm);
          end;
        elsif l_fte_src = 'ASG_BUDGET' then
            /*open  get_fte_budget_hrs;
            fetch get_fte_budget_hrs into l_fte_hrs;
            close get_fte_budget_hrs;*/

		run_seeded_formula(p_assignment_id
				 ,p_effective_date
				 ,g_business_group_id
				 ,l_assignment_number
				 ,l_fte_ratio
				 ,l_error_message
				 );


		l_fte_hrs := l_hours_per_week/l_fte_ratio;

                hr_utility.set_location('l_fte_ratio'||l_fte_ratio,20);
                hr_utility.set_location('l_hours_per_week'||l_hours_per_week,20);

		if l_error_message is not null then
			populate_run_msg(p_assactid,'Error while executing formula  GB_CALCULATE_FTE_USING_PQP_CONTRACT_TYPES.'||l_error_message );
			fnd_file.put_line(fnd_file.log,'Error while executing formula id '|| l_fte_formula_id);
			fnd_file.put_line(fnd_file.log,sqlerrm);
		end if;

		if l_fte_hrs = 0 or l_fte_hrs is null then
			l_arch := false;
			hr_utility.set_location('FTE Hrs is not defiled or FTE hrs is Zero',20);
  			populate_run_msg(p_assactid,'FTE Hrs is not defiled or FTE hrs is Zero. This could be if Work Pattern is not defined for the assignment');
		end if;

        end if;

    end if;

    if l_fte_ratio is null then -- to make sure it was not calculated previously
	l_fte_ratio := l_hours_per_week/l_fte_hrs;
    end if;

    if g_data_ret_type <> 'TYPE4' then
	    begin
		l_hours_per_week := to_char(to_number(l_hours_per_week),'fm99.00');
					l_check_if_num := l_hours_per_week;
		exception when others then
		hr_utility.set_location('Hours Per Week has invalid characters',20);
		populate_run_msg(p_assactid,'Hours Per Week has invalid characters');
	    end;

	    -- 4740
	    if p_staff_cat <> 4 and l_contract_type is not null and l_hours_per_week is null then
	      l_arch := false;
	      hr_utility.set_location('Hours worked per week is missing',20);
		populate_run_msg(p_assactid,'Hours worked per week is missing');
	    end if;

	    hr_utility.set_location('FTE Hours '|| l_fte_hrs,20);
	    begin
		l_fte_hrs := to_char(to_number(l_fte_hrs),'fm99.00');
		l_check_if_num := l_fte_hrs;
		exception when others then
		l_error_flag := 'Y';
		l_arch := false;
		hr_utility.set_location('FTE Hours has invalid characters '|| l_fte_hrs,20);
		populate_run_msg(p_assactid,'FTE Hours has invalid characters');
	    end;


	    -- 4760
	    if p_staff_cat <> 4 and l_fte_hrs is null then
	      l_arch := false;
	      hr_utility.set_location('FTE Hours per week is missing',20);
		populate_run_msg(p_assactid,'FTE Hours per week is missing');
	    end if;

	    -- 4765
	    if not(l_fte_hrs between 24 and 40) then
	      l_arch := false;
	      hr_utility.set_location('FTE hours should be at least 24 and no greater than 40',20);
	      populate_run_msg(p_assactid,'FTE hours should be at least 24 and no greater than 40');
	    end if;

	    -- 4770
	    begin
		l_weeks_per_yr := to_char(to_number(l_weeks_per_yr),'fm99');
		l_check_if_num := l_weeks_per_yr;
		exception when others then
		l_arch := false;
		hr_utility.set_location('Weeks per year has invalid characters',20);
		populate_run_msg(p_assactid,'Weeks per year has invalid characters');
	    end;
	    -- 4780
	    if p_staff_cat <> 4 and l_weeks_per_yr is null then
	      l_arch := false;
	      hr_utility.set_location('Weeks per year is missing',20);
		populate_run_msg(p_assactid,'Weeks per year is missing');
	    end if;

	   if l_error_flag <>'Y' then
	    if l_fte_hrs <> 0 and p_contract_type IN ('PRM','FXT','TMP') and l_fte_ratio > 1.5 then
	      l_arch := false;
	      hr_utility.set_location('FTE Error',20);
	      populate_run_msg(p_assactid,'The same person has a total Full Time Equivalent ratio greater than 1.5');
	    end if;

	    if l_fte_hrs <> 0 and p_contract_type IN ('PRM','FXT','TMP') and l_fte_ratio between 1.2 and 1.5 then
	      hr_utility.set_location('FTE Warning',20);
	      populate_run_msg(p_assactid,'Please Check: The same person has a total Full Time Equivalent ratio greater than 1.2 and less than or equal to 1.5','W');
	    end if;
	   end if;
   end if ; -- g_data_ret_type <> 'TYPE4'


    p_hrs_rec.action_info_category  := 'GB_SWF_HOURS_DETAILS';
    p_hrs_rec.person_id             := l_person_id;
    p_hrs_rec.assignment_id         := p_assignment_id;
    p_hrs_rec.effective_date        := sysdate;
    p_hrs_rec.act_info1             := l_hours_per_week;
    p_hrs_rec.act_info2             := l_fte_hrs;
    p_hrs_rec.act_info3             := l_weeks_per_yr;
    p_hrs_rec.act_info4             := p_person_id;
    p_hrs_rec.act_info5             := p_contract_type;
    p_hrs_rec.act_info6             := p_contract_end_date;
    p_hrs_rec.act_info7             := l_fte_ratio;

  return l_arch;
    exception when others then
              hr_utility.trace(sqlerrm);
              hr_utility.set_location('leaving with error: '||l_proc,7777);
              raise;
end fetch_hours_details;

---------------------------------function get_person_category-------------------
--- Functuon fetches the person category.This is not with respect to the person.
--- Its computed based on the assignment.This value is uesed in fetch_hours_details
--- to compute hours data.
--- The actual person category based on the ranking order will be determined in the
--- extract process from the archived data.The final determined value will be used to
--- conditionally display qualifications and absence data.
--  The function will return
-- 1 if  Regular Teacher ,    2 if   Agency Teacher
-- 3 if  Teaching Assistant,  4 if   Other Support Staff

function get_person_category(p_contract_type  in varchar2,
                             p_start_date     in date,
                             p_end_date       in date,
                             p_post           in varchar2,
                             p_role           in addl_role_tab) return varchar2 is

l_proc      constant varchar2(50) := g_package || ' get_person_category';
l_person_category       varchar2(30);
begin
    hr_utility.set_location('Entering: '||l_proc,10);
    if p_post <> 'SUP' then -- teachers
      if (p_contract_type = 'PRM'
      or
      p_contract_type = 'FXT' and months_between(p_end_date,p_start_date) >=1)
      or
      (p_contract_type = 'TMP' and p_end_date is not null
                                and months_between(p_end_date,p_start_date) >=1)
      or
      (p_contract_type = 'TMP' and p_end_date is null
                                and months_between(g_census_day,p_start_date) >=1) then
         l_person_category := 1; --'Regular Teacher'; -- Rank 1
       elsif (p_contract_type is not null and p_contract_type not in ('PRM','FXT','TMP')
                                        and p_end_date is not null
                                        and months_between(p_end_date,p_start_date) >=1)
              or
              (p_contract_type is not null and p_contract_type not in ('PRM','FXT','TMP')
                                        and p_end_date is null
                                        and months_between(g_census_day,p_start_date) >=1) then
         l_person_category := 2; --'Agency Teacher'; -- Rank 2
       end if;
     elsif p_post = 'SUP' then -- support staff
       if p_end_date is not null and months_between(p_end_date,p_start_date) >=1
          or
          p_end_date is null and months_between(g_census_day,p_start_date) >=1 then

          for i in p_role.first .. p_role.last loop
           if p_role(i) in ('HLTA','TASS') then
              l_person_category := 3; --'Teaching Assistant';
              exit;
           end if;
          end loop;
          if l_person_category is null then
             l_person_category := 4; --'Other Support Staff';
          end if;
        end if;
      end if;

    hr_utility.set_location('Entering: '||l_proc,10);
 return l_person_category;
end get_person_category;
---
----------------------------function fetch_absence_details----------------------
---
function fetch_absence_details(p_assactid  in number,
                               p_person_id in number,
                               p_estab_no  in number,
                               p_abs_tab   out nocopy abs_details_tab)return boolean is

l_proc  constant varchar2(50):= g_package||'fetch_absence_details';

cursor get_abs_source is
select pcv_information1
from   pqp_configuration_values pcv
where  pcv.pcv_information_category = 'PQP_GB_SWF_ABSENCE_CODE'
and    pcv.business_group_id = g_business_group_id;

--
l_abs_source    pqp_configuration_values.pcv_information1%type;
l_date_end_missing  varchar2(1) := 'N';
l_last_before_first varchar2(1) := 'N';
l_last_after_census varchar2(1) := 'N';
l_first_day_of_abs  varchar2(1) := 'N';
l_last_day_of_abs   varchar2(1) := 'N';
l_last_day_of_abs_41_days varchar2(1) := 'N';
l_no_of_last_day_missing number := 0;
l_wrking_days_lost_missing varchar2(1) := 'N';
l_arch  boolean := true;

begin
hr_utility.set_location('Entering: '||l_proc,10);
  open  get_abs_source;
  fetch get_abs_source into l_abs_source;
  close get_abs_source;

  if l_abs_source = 'ABSENCE_CATEGORY' then
    begin
      select paat.person_id,
             paat.date_start,
             to_char(paat.date_start,'YYYY-MM-DD'),
             paat.date_end,
             to_char(paat.date_end,'YYYY-MM-DD'),
             to_char(paat.absence_days,'fm999.0'),
             pcv.pcv_information5 absence_category,
             p_estab_no
        bulk collect into p_abs_tab
        from per_absence_attendances      paat,
             per_absence_attendance_types paatt,
             pqp_configuration_values     pcv
       where paat.absence_attendance_type_id = paatt.absence_attendance_type_id
         and paat.person_id = p_person_id
         and pcv.pcv_information_category = 'PQP_GB_SWF_ABSENCE_CODE'
         and pcv_information1 = 'ABSENCE_CATEGORY'
         and pcv.business_group_id = g_business_group_id
         and pcv_information3 = paatt.absence_category
         and (paat.date_end between g_cont_data_st_date and g_cont_data_end_date or
             paat.date_start between g_cont_data_st_date and g_cont_data_end_date);

            exception
            when others then
              hr_utility.trace(sqlerrm);
              hr_utility.set_location('leaving with error: '||l_proc,7777);
              raise;
    end;
  elsif l_abs_source = 'ABSENCE_TYPE' then
    begin
      select paat.person_id,
            paat.date_start,
            to_char(paat.date_start,'YYYY-MM-DD'),
            paat.date_end,
            to_char(paat.date_end,'YYYY-MM-DD'),
            to_char(paat.absence_days,'fm999.0'),
            pcv.pcv_information5 absence_type,
            p_estab_no
      bulk collect into p_abs_tab
       from per_absence_attendances      paat,
            pqp_configuration_values     pcv
      where paat.person_id = p_person_id
        and pcv.pcv_information_category = 'PQP_GB_SWF_ABSENCE_CODE'
        and pcv_information1 = 'ABSENCE_TYPE'
        and pcv.business_group_id = g_business_group_id
        and pcv_information4 = paat.absence_attendance_type_id
        and (paat.date_end between g_cont_data_st_date and g_cont_data_end_date or
            paat.date_start between g_cont_data_st_date and g_cont_data_end_date);

          exception
          when others then
            hr_utility.trace(sqlerrm);
            hr_utility.set_location('leaving with error: '||l_proc,7777);
            raise;
    end;
  elsif l_abs_source = 'ABSENCE_REASON' then
    begin
      select paat.person_id,
             paat.date_start,
             to_char(paat.date_start,'YYYY-MM-DD'),
             paat.date_end,
             to_char(paat.date_end,'YYYY-MM-DD'),
             to_char(paat.absence_days,'fm999.0'),
             pcv.pcv_information5 absence_reason,
             p_estab_no
        bulk collect into p_abs_tab
        from per_absence_attendances        paat,
             per_abs_attendance_reasons paatr,
             pqp_configuration_values       pcv
       where paatr.abs_attendance_reason_id = paat.abs_attendance_reason_id
         and paat.person_id = p_person_id
         and pcv.pcv_information_category = 'PQP_GB_SWF_ABSENCE_CODE'
         and pcv_information1 = 'ABSENCE_REASON'
         and pcv.business_group_id = g_business_group_id
         and pcv_information3 = paatr.name
         and (paat.date_end between g_cont_data_st_date and g_cont_data_end_date or
             paat.date_start between g_cont_data_st_date and g_cont_data_end_date);

        exception
        when others then
          hr_utility.trace(sqlerrm);
          hr_utility.set_location('leaving with error: '||l_proc,7777);
          raise;
    end;
  end if;

  if p_abs_tab.count >0 then
  	for i in p_abs_tab.first .. p_abs_tab.last loop
  	    if p_abs_tab(i).date_end is null then
  		l_date_end_missing := 'Y';
  		l_no_of_last_day_missing := l_no_of_last_day_missing +1;
  	    end if;

  	    if p_abs_tab(i).date_end < p_abs_tab(i).date_start then
  		l_last_before_first := 'Y';
  	    end if;

  	    if p_abs_tab(i).date_end is not null and p_abs_tab(i).days_lost is NULL and p_abs_tab(i).absence_category = 'SIC' then
  		l_wrking_days_lost_missing:= 'Y';
  	    end if;

  	    if p_abs_tab(i).date_end > g_census_day then
  		l_last_after_census := 'Y';
  	    end if;

	    if p_abs_tab(i).date_start < g_cont_data_st_date then
	       l_first_day_of_abs := 'Y';
            end if;

	    if p_abs_tab(i).date_end > g_cont_data_end_date then
	       l_last_day_of_abs := 'Y';
            end if;

	    if p_abs_tab(i).date_end - g_census_day > 41 then
	       l_last_day_of_abs_41_days := 'Y';
            end if;



  	end loop;

    -- 4920
    if l_first_day_of_abs = 'Y' then
      l_arch := false;
      hr_utility.set_location('First Day of absence must be in the academic year before Census day',20);
      populate_run_msg(p_assactid,'First Day of absence must be in the academic year before Census day');
    end if;

    -- 4936
    if l_last_day_of_abs = 'Y' then
      l_arch := false;
      hr_utility.set_location('Last Day of absence must be in the current or preceding academic year',20);
      populate_run_msg(p_assactid,'Last Day of absence must be in the current or preceding academic year');
    end if;

    --4945Q
    if l_last_day_of_abs_41_days = 'Y' then
      hr_utility.set_location('Please check: Last Day of absence is not expected to be after Census day',20);
      populate_run_msg(p_assactid,'Last Day of absence must be in the current or preceding academic year Census day','W');
    end if;

    if l_date_end_missing = 'Y' then
      hr_utility.set_location('Last Day of absence is missing - please check absence is ongoing',20);
      populate_run_msg(p_assactid,'Last Day of absence is missing - please check absence is ongoing','W');
    end if;

    if l_last_before_first = 'Y' then
      hr_utility.set_location('Last Day of absence cannot be before First Day of absence',20);
      populate_run_msg(p_assactid,'Last Day of absence cannot be before First Day of absence','W');
    end if;

    -- 4945Q
    if l_last_after_census = 'Y' then
      hr_utility.set_location('Please check: Last Day of absence should not be after the Census Day',20);
      populate_run_msg(p_assactid,'Please check: Last Day of absence should not be after the Census Day','W');
    end if;

    -- 4950Q
    if l_no_of_last_day_missing > 1 then
     hr_utility.set_location('Please check - more than one absence record without an end date',20);
     populate_run_msg(p_assactid,'Please check - more than one absence record without an end date','W');
    end if;

    if l_wrking_days_lost_missing = 'Y' then
     l_arch := false;
     hr_utility.set_location('Where Last Day of a sickness absence is provided then the number of Working Days Lost must also be provided',20);
     populate_run_msg(p_assactid,'Where Last Day of a sickness absence is provided then the number of Working Days Lost must also be provided');
    end if;

  end if;

  hr_utility.set_location('Leaving: '||l_proc,99);

return l_arch;
  exception when others then
    hr_utility.set_location('Leaving with error: '||l_proc,9999);
    raise;
end  fetch_absence_details;
------------------------------function fetch_contract_details--------------------------------------
--Fetches contract details
--Contract/Agreement Type , Start Date, End Date ,Post,Date of Arrival in School,Daily Rate,
--Destination,Origin,LA or School Level,Establishment
function fetch_contract_details ( p_assactid       in number,
                                  p_effective_date in date,
                                  p_person_id      in number,
								  p_hlta_status	   in varchar2,
								  p_estab_no       in number,
                                  p_contract_rec      out nocopy act_info_rec,
                                  p_role_tab          out nocopy addl_role_tab) return boolean is

  l_proc  constant varchar2(50):= g_package||'fetch_contract_details';
  -- if the
  cursor get_assignment_details is
  select paa.assignment_id          assignment_id,
         paa.assignment_number      assignment_number,
         paa.employment_category    contract_agg_type,
         paa.employee_category      employee_cat,
         paa.employment_category    assignment_cat
  from   pay_assignment_actions act,
         per_all_assignments_f      paa
  where  act.assignment_action_id = p_assactid
  and    act.assignment_id = paa.assignment_id
  and    p_effective_date between paa.effective_start_date and paa.effective_end_date;

  cursor get_assignment_dates(p_assignment_id number) is
  select min(paa.effective_start_date) contract_st_date,
         max(paa.effective_end_date)  contract_end_date,
		 to_char(min(paa.effective_start_date),'YYYY-MM-DD') contract_st_date_dcsf,
         decode(to_char(max(paa.effective_end_date) ,'YYYY-MM-DD'),'4712-12-31',null,
				  to_char(max(paa.effective_end_date) ,'YYYY-MM-DD'))contract_end_date_dcsf,
         to_char(min(paa.effective_start_date) ,'YYYY-MM-DD') date_of_arrival_dcsf
  from   per_all_assignments_f      paa,
         per_assignment_status_types pas
  where  paa.assignment_status_type_id = pas.assignment_status_type_id
  and    pas.per_system_status = 'ACTIVE_ASSIGN'
  and    paa.assignment_id = p_assignment_id;

  cursor get_asg_contract_details is
  select paa.assignment_id          assignment_id,
         paa.assignment_number      assignment_number,
         att.contract_type          contract_agg_type,
         paa.employee_category      employee_cat,
         paa.employment_category    assignment_cat
  from   per_all_assignments_f paa,
         pay_assignment_actions act,
         pqp_assignment_attributes_f att
  where  act.assignment_action_id = p_assactid
  and    act.assignment_id = att.assignment_id
  and    paa.assignment_id = att.assignment_id
  and    p_effective_date between att.effective_start_date and att.effective_end_date
  and    p_effective_date between paa.effective_start_date and paa.effective_end_date;


  cursor get_contract_dates(p_assignment_id number) is
  select min(att.effective_start_date)  contract_st_date,
         max(att.effective_end_date)  contract_end_date,
				 to_char(min(att.effective_start_date) ,'YYYY-MM-DD') contract_st_date_dcsf,
         decode(to_char(max(att.effective_end_date) ,'YYYY-MM-DD'),'4712-12-31',null,
				  to_char(max(att.effective_end_date) ,'YYYY-MM-DD'))contract_end_date_dcsf,
		to_char(min(paa.effective_start_date) ,'YYYY-MM-DD') date_of_arrival_dcsf
   from  pqp_assignment_attributes_f att,
         per_all_assignments_f paa
  where  att.assignment_id = p_assignment_id
    and  paa.assignment_id = att.assignment_id;

  cursor get_date_of_arrival_src is
  select pcv_information1, pcv_information2
  from   pqp_configuration_values
  where  business_group_id = g_business_group_id
  and    pcv_information_category = 'PQP_GB_SWF_CNTRT_ARRIVAL_DATE';

  cursor get_post(p_emp_or_asgcat in varchar2) is
  select  pcv_information4
  from    pqp_configuration_values pcv
  where   pcv.pcv_information_category = 'PQP_GB_SWF_POST_MAPPING'
  and     pcv_information2             = p_emp_or_asgcat
  and     pcv.business_group_id        = g_business_group_id;

  cursor  get_origin(l_origin in varchar2) is
  select  pcv_information3
  from    pqp_configuration_values pcv
  where   pcv.pcv_information_category = 'PQP_GB_SWF_ORIGIN_MAPPING'
  and     pcv_information2             = l_origin
  and     pcv.business_group_id        = g_business_group_id;

  cursor  get_destination(l_destination in varchar2) is
  select  pcv_information3
  from    pqp_configuration_values pcv
  where   pcv.pcv_information_category = 'PQP_GB_SWF_DESTINATION_MAPPING'
  and     pcv_information2             = l_destination
  and     pcv.business_group_id        = g_business_group_id;

  cursor get_daily_rate(p_assignment_id in number) is
  select aei_information1
  from   per_assignment_extra_info
  where  aei_information_category = 'PQP_SCHOOL_WORKFORCE_CENSUS'
  and    assignment_id = p_assignment_id;

  cursor  get_work_inc_type(p_person_id in number) is  --- Check what are the valid values
  select  decode(pei_information5,'CENTRAL_STAFF','L','SCHOOL_STAFF','S',null)  workforce_inc_typ          --- which can be archived
  from    per_people_extra_info pei
  where   pei.information_type = 'PQP_SCHOOL_WORKFORCE_CENSUS'
  and     pei.person_id        = p_person_id;

  cursor  get_pqp_contract_type_dcsf(p_pqp_cont_type in pqp_assignment_attributes_f.contract_type%type ) is
  select  pcv_information5
  from    pqp_configuration_values pcv
  where   pcv.pcv_information_category = 'PQP_GB_SWF_CONTRACT_TYPE'
  and     pcv_information4             = p_pqp_cont_type
  and     pcv.business_group_id        = g_business_group_id;

  cursor  get_asg_contract_type_dcsf(p_cont_type  in per_all_assignments_f.employment_category%type ) is
  select  pcv_information5
  from    pqp_configuration_values pcv
  where   pcv.pcv_information_category = 'PQP_GB_SWF_CONTRACT_TYPE'
  and     pcv_information3             = p_cont_type
  and     pcv.business_group_id        = g_business_group_id;


  l_asg_rec             get_assignment_details%rowtype;
  l_asg_dates_rec       get_assignment_dates%rowtype;
  l_post                hr_lookups.lookup_code%type;
  l_post_emp_cat        hr_lookups.lookup_code%type;
  l_post_asg_cat        hr_lookups.lookup_code%type;
  l_date_of_arrival_src pqp_configuration_values.pcv_information1%type;
  l_date_of_arrival     date;
  l_daily_rate          varchar2(150);
  l_origin              hr_lookups.lookup_code%type;
  l_dcsf_origin         hr_lookups.lookup_code%type;
  l_destination         hr_lookups.lookup_code%type;
  l_dcsf_destination    hr_lookups.lookup_code%type;
  l_la_or_school_level  varchar2(150);
  l_establishment       number := p_estab_no;
  l_contract_agg_type   hr_lookups.lookup_code%type;
  l_user_formula_name   ff_formulas_f.formula_name%type;
  l_arch_role           boolean;
  l_person_category     varchar2(30);
  l_arch 		boolean := true;
  l_valid_flag		varchar2(1);
  l_date_of_arrival_dcsf  varchar2(10);
  l_role_count		number;
begin
  hr_utility.set_location('Entering '|| l_proc, 10);
  hr_utility.set_location('Parameters       :', 20);
  hr_utility.set_location('p_effective_date :'|| p_effective_date, 20);
  hr_utility.set_location('p_person_id      :'|| p_person_id, 20);
  hr_utility.set_location('p_hlta_status    :'|| p_hlta_status, 20);

    if g_pick_from_asg is null then
     fnd_file.put_line(fnd_file.log,'Contract Details - Contract Type Configuration is not set.Please configure and proceed');
     hr_utility.raise_error;
    end if;

    if p_effective_date is null then
     fnd_file.put_line(fnd_file.log,'Contract Details - Contract effective date could not be determined.');
     hr_utility.raise_error;
    end if;

    open get_date_of_arrival_src;
    fetch get_date_of_arrival_src into l_date_of_arrival_src,l_user_formula_name;
    close get_date_of_arrival_src;

    if g_pick_from_asg = 'Y' then
    open  get_assignment_details;
    fetch get_assignment_details into l_asg_rec;
    close get_assignment_details;

    open get_assignment_dates(l_asg_rec.assignment_id);
    fetch get_assignment_dates into l_asg_dates_rec;
    close get_assignment_dates;

    open  get_asg_contract_type_dcsf(l_asg_rec.contract_agg_type);
    fetch get_asg_contract_type_dcsf into l_contract_agg_type;
    close get_asg_contract_type_dcsf;

    if l_date_of_arrival_src = 'CAL' then
      begin
        l_date_of_arrival_dcsf := run_user_formula(l_user_formula_name,l_asg_rec.assignment_id,g_census_day,g_business_group_id,l_asg_rec.assignment_number);
        hr_utility.set_location('Formula Result Value '||l_date_of_arrival_dcsf,20);
      exception when others then
        populate_run_msg(p_assactid,'Error while executing formula id '|| l_user_formula_name||'. Please refer Log file for details' );
        fnd_file.put_line(fnd_file.log,'Error while executing formula id '|| l_user_formula_name);
        fnd_file.put_line(fnd_file.log,sqlerrm);
       end;
    else
        l_date_of_arrival_dcsf := l_asg_dates_rec.date_of_arrival_dcsf;
    end if;

    else
      open  get_asg_contract_details;
      fetch get_asg_contract_details into l_asg_rec;
      close get_asg_contract_details;

      open get_contract_dates(l_asg_rec.assignment_id);
      fetch get_contract_dates into l_asg_dates_rec;
      close get_contract_dates;

      open  get_pqp_contract_type_dcsf(l_asg_rec.contract_agg_type);
      fetch get_pqp_contract_type_dcsf into l_contract_agg_type;
      close get_pqp_contract_type_dcsf;

      if l_date_of_arrival_src = 'CAL' then
        begin
          l_date_of_arrival_dcsf :=run_user_formula(l_user_formula_name,l_asg_rec.assignment_id,g_census_day,g_business_group_id,l_asg_rec.assignment_number);
          hr_utility.set_location('Formula Result Value '||l_date_of_arrival_dcsf,20);
          exception when others then
            populate_run_msg(p_assactid,'Error while executing formula '|| l_user_formula_name||'. Please refer Log file for details' );
            fnd_file.put_line(fnd_file.log,'Error while executing formula '|| l_user_formula_name);
            fnd_file.put_line(fnd_file.log,sqlerrm);
         end;
       else
          l_date_of_arrival_dcsf := l_asg_dates_rec.date_of_arrival_dcsf;
      end if;

    end if;

    if g_cont_post_src in ('JOB','GRD','POS') then
      begin
        execute immediate g_cont_post_sql_str into l_post using g_business_group_id,p_effective_date, l_asg_rec.assignment_id;
        exception when others then
         hr_utility.set_location('Post could not be fetched as of' || p_effective_date ||'for Assignment number :'||l_asg_rec.assignment_number,9999);
      end;
    elsif g_cont_post_src = 'EMP_CAT' then
      open  get_post(l_asg_rec.assignment_cat);
      fetch get_post into l_post;
      close get_post;
    elsif g_cont_post_src = 'EMPLOYEE_CATG' then
      open  get_post(l_asg_rec.employee_cat);
      fetch get_post into l_post;
      close get_post;
    end if;

    open  get_daily_rate(l_asg_rec.assignment_id);
    fetch get_daily_rate into l_daily_rate;
    close get_daily_rate;

    if g_origin_dff = 'PER_ASSIGNMENTS' then
      begin
        execute immediate g_origin_sql_str into l_origin using l_asg_rec.assignment_id, p_effective_date;
           exception when others then
            hr_utility.set_location('Origin could not be fetched as of ' || p_effective_date ||'for Assignment Number :'||l_asg_rec.assignment_number,8888);
      end;
    elsif g_origin_dff = 'PER_PEOPLE' then
      begin
        execute immediate g_origin_sql_str into l_origin using p_person_id, p_effective_date;
          exception when others then
            hr_utility.set_location('Origin could not be fetched as of ' || p_effective_date ||'for Assignment Number :'||l_asg_rec.assignment_number,9999);
      end;
    end if;

    open  get_origin(l_origin);
    fetch get_origin into l_dcsf_origin;
    close get_origin;

    if g_destination_dff = 'PER_ASSIGNMENTS' then
      begin
        execute immediate g_destination_sql_str into l_destination using l_asg_rec.assignment_id, p_effective_date;
           exception when others then
            hr_utility.set_location('Destination could not be fetched as of ' || p_effective_date ||'for Assignment Number :'||l_asg_rec.assignment_number,8888);
      end;
    elsif upper(g_destination_dff) like 'TERM%' then -- get the exact value
      begin
        execute immediate g_destination_sql_str into l_destination using p_person_id;
          exception when others then
            hr_utility.set_location('Destination could not be fetched as of ' || p_effective_date ||'for Assignment Number :'||l_asg_rec.assignment_number,9999);
      end;
    end if;

    open  get_destination(l_destination);
    fetch get_destination into l_dcsf_destination;
    close get_destination;

    open  get_work_inc_type(p_person_id);
    fetch get_work_inc_type into l_la_or_school_level;
    close get_work_inc_type;


    l_arch_role := fetch_role_details(p_assactid,p_effective_date,p_person_id,l_asg_rec.assignment_id,p_role_tab);

    l_person_category := get_person_category(l_contract_agg_type,l_asg_dates_rec.contract_st_date,l_asg_dates_rec.contract_end_date,l_post,p_role_tab);

    if l_person_category is null then
        l_arch := false;
	    hr_utility.set_location('Staff Category Could not be determined',10);
		populate_run_msg(p_assactid,'Staff Category Could not be determined.This could be becacuse of incorrect Post or Role or Contract Type.');
	end if;
		-- 4285
		if l_establishment is not null then
			  if not(
				       l_establishment between 1000 and 1099
						or l_establishment between 1800 and 1899
						or l_establishment between 2000 and 3999
						or l_establishment between 5200 and 5299
						or l_establishment between 5499 and 5900
						or l_establishment between 4000 and 4999
						or l_establishment between 5400 and 5499
						or l_establishment between 5900 and 5949
						or l_establishment between 6900 and 6924) then
							l_arch := false;
							hr_utility.set_location('Estab Number in Contract module is not valid',10);
							populate_run_msg(p_assactid,'Estab Number in Contract module is not valid');
			 end if;
		end if;

	 -- 4310
		if l_contract_agg_type is not null then
			begin
				select	 'Y'
					into	 l_valid_flag
					from	 dual
				 where	 exists(select	 lookup_code
						from	 hr_lookups hl
						where			 hl.lookup_type = 'PQP_GB_SWF_CNTRCT_AGRMNT_TYPES'
						and hl.enabled_flag = 'Y'
						and hl.lookup_code = l_contract_agg_type);
				exception
					when OTHERS then
						l_arch := false;
						populate_run_msg (p_assactid, 'Contract / Agreement Type is invalid');
						hr_utility.set_location ('Contract / Agreement Type is invalid', 10);
			end;

			if  length(l_contract_agg_type) <> 3 then
				l_arch := false;
				hr_utility.set_location('Contract / Agreement Type is invalid',10);
				populate_run_msg(p_assactid,'Contract / Agreement Type is invalid');
			end if;
		end if;

		-- 4350
		if l_asg_dates_rec.contract_st_date is null then
			l_arch := false;
			hr_utility.set_location('Start Date is missing',10);
			populate_run_msg(p_assactid,'Start Date is missing');
		end if;

		-- 4355
		if 	g_census_day < l_asg_dates_rec.contract_st_date then
			l_arch := false;
			hr_utility.set_location('Contract Start Date can not be in the future',10);
			populate_run_msg(p_assactid,'Contract Start Date can not be in the future');
		end if;

		-- 4357
		if months_between(trunc(g_census_day),l_asg_dates_rec.contract_st_date)/12 > 50 then
			l_arch := false;
			hr_utility.set_location('Contract / Agreement Start Date more than 50 years ago',10);
			populate_run_msg(p_assactid,'Contract / Agreement Start Date more than 50 years ago');
		end if;

		-- 4360

		if l_asg_dates_rec.contract_end_date <> hr_general.end_of_time then
			if  	not(l_asg_dates_rec.contract_st_date  between to_date('01-09-'||(g_census_year-1),'DD-MM-YYYY') and to_date('31-08-'||(g_census_year),'DD-MM-YYYY'))
				and not(l_asg_dates_rec.contract_end_date between to_date('01-09-'||(g_census_year-1),'DD-MM-YYYY') and to_date('31-08-'||(g_census_year),'DD-MM-YYYY'))
                and l_asg_dates_rec.contract_end_date < g_census_day then
				l_arch := false;
				hr_utility.set_location('Contract end date error',20);
				populate_run_msg(p_assactid,'Contract has invalid End date for this Census');
			end if;
		end if;

		-- 4361, 4362 Deleted

		-- 4370 already handled in select

		-- 4375
		/*if g_census_term <> 'SPRING' then -- Added as PRM and other contract types can exist in the system without end date
			if l_contract_agg_type <> 'FXT' and (l_asg_dates_rec.contract_end_date > g_census_day
			or months_between(l_asg_dates_rec.contract_end_date ,l_asg_dates_rec.contract_st_date) < 1) then
					l_arch := false;
					hr_utility.set_location('Contract / Agreement end date must be at least a month after the start date, and on or prior to Census Day, for this type of contract or agreement',20);
					populate_run_msg(p_assactid,'Contract / Agreement end date must be at least a month after the start date, and on or prior to Census Day, for this type of contract or agreement');
			end if;
		end if;*/

		-- 4380
		if l_contract_agg_type = 'FXT' and l_asg_dates_rec.contract_end_date_dcsf is null then
				l_arch := false;
				hr_utility.set_location('Contract / Agreement Type is Fixed Term therefore End Date must be specified',20);
				populate_run_msg(p_assactid,'Contract / Agreement Type is Fixed Term therefore End Date must be specified');
		end if;

		-- 4385
		if (l_person_category = 1 or l_person_category = 2) and l_asg_dates_rec.contract_end_date_dcsf is not null and l_asg_dates_rec.contract_end_date < g_census_day
			and l_dcsf_destination is null then

				l_arch := false;
				hr_utility.set_location('Destination code must be provided for completed contracts',20);
				populate_run_msg(p_assactid,'Destination code must be provided for completed contracts');
		end if;

		-- 4390Q
		if l_dcsf_destination is not null and l_asg_dates_rec.contract_end_date_dcsf is null then
				hr_utility.set_location('Please check: Destination code has been provided therefore contract End Date must be specified ',20);
				populate_run_msg(p_assactid,'Please check: Destination code has been provided therefore contract End Date must be specified ','W');
		end if;

		-- 4400
		if l_asg_dates_rec.contract_st_date > l_asg_dates_rec.contract_end_date then
				l_arch := false;
				hr_utility.set_location('Contract End Date cannot be before contract Start Date',20);
				populate_run_msg(p_assactid,'Contract End Date cannot be before contract Start Date');
		end if;

		-- 4410
		if l_post is null then
				l_arch := false;
				hr_utility.set_location('Post is missing',20);
				populate_run_msg(p_assactid,'Post is missing');
		end if;

		-- 4700/4710
		l_role_count := 0;

		for i in p_role_tab.first .. p_role_tab.last loop
			hr_utility.set_location('Roles for this contract'||p_role_tab(i),25);
			if p_role_tab(i) is not null then
				l_role_count := l_role_count+1;
			end if;
		end loop;

		if l_role_count = 0 then
			l_arch := false;
			hr_utility.set_location('Role Identifier is missing ',20);
			populate_run_msg(p_assactid,'No Role details have been supplied');
		end if;


		if l_post = 'SUP' then
		l_valid_flag := 'Y';
			for i in p_role_tab.first .. p_role_tab.last loop
					if p_role_tab(i) in ('ADVT', 'ASHT', 'DPHT', 'HDTR', 'MISC', 'MUSC', 'PERI', 'SPLY', 'TCHR', 'TMIS', 'TNON', 'TPRU') then
						l_valid_flag := 'N';
						exit;
					end if;
			end loop;
				if 	l_valid_flag = 'N' then
					l_arch := false;
					hr_utility.set_location('Post is inconsistent with Role Identifier',20);
					populate_run_msg(p_assactid,'Post is inconsistent with Role Identifier');
				end if;
		end if;

		-- 4414
		if l_post = 'HDT' then
				l_valid_flag := 'N';
				for i in p_role_tab.first .. p_role_tab.last loop
					if p_role_tab(i) = 'HDTR' then
						l_valid_flag := 'Y';
						exit;
					end if;
				end loop;
				if 	l_valid_flag = 'N' then
					l_arch := false;
					hr_utility.set_location('Post shown as Head Teacher.  One of the associated Roles must also be Head Teacher',20);
					populate_run_msg(p_assactid,'Post shown as Head Teacher.  One of the associated Roles must also be Head Teacher');
				end if;
		end if;

		-- 4415
		if l_post = 'DHT' then
				l_valid_flag := 'N';
				for i in p_role_tab.first .. p_role_tab.last loop
					if p_role_tab(i) = 'DPHT' then
						l_valid_flag := 'Y';
						exit;
					end if;
				end loop;
				if 	l_valid_flag = 'N' then
					l_arch := false;
					hr_utility.set_location('Post shown as Deputy Head.  One of the associated Roles must also be Deputy Head',20);
					populate_run_msg(p_assactid,'Post shown as Deputy Head.  One of the associated Roles must also be Deputy Head');
				end if;
		end if;

		-- 4416
		if l_post = 'AHT' then
				l_valid_flag := 'N';
				for i in p_role_tab.first .. p_role_tab.last loop
					if p_role_tab(i) = 'ASHT' then
						l_valid_flag := 'Y';
						exit;
					end if;
				end loop;
				if 	l_valid_flag = 'N' then
					l_arch := false;
					hr_utility.set_location('Post shown as Deputy Head.  One of the associated Roles must also be Deputy Head',20);
					populate_run_msg(p_assactid,'Post shown as Deputy Head.  One of the associated Roles must also be Deputy Head');
				end if;
		end if;

		--4417
		begin
		  l_valid_flag := 'N';
			for i in p_role_tab.first .. p_role_tab.last loop
				if p_role_tab(i) = 'HLTA' then
					l_valid_flag := 'Y';
					exit;
				end if;
			end loop;
			if l_valid_flag = 'Y' and p_hlta_status = 'No' then
				  l_arch := false;
					hr_utility.set_location('If role is HLTA then HLTA Status must be Yes',20);
					populate_run_msg(p_assactid,'If role is HLTA then HLTA Status must be Yes');
			end if;
		end;

		-- 4420

		if l_date_of_arrival_dcsf is not null then
		  l_date_of_arrival := to_date(l_date_of_arrival_dcsf,'YYYY-MM-DD');
		end if;

		-- 4425Q
		if months_between(trunc(g_census_day),l_date_of_arrival)/ 12 > 50 then
			hr_utility.set_location('Please check: Date of Arrival in School is more than 50 years ago',20);
			populate_run_msg(p_assactid,'Please check: Date of Arrival in School is more than 50 years ago','W');
		end if;


		-- 4430
		if l_person_category in (1,2,3) and l_la_or_school_level = 'S' and l_date_of_arrival_dcsf is null then
			l_arch := false;
			hr_utility.set_location('Date of Arrival in School must be supplied',20);
			populate_run_msg(p_assactid,'Date of Arrival in School must be supplied');
		end if;

		-- 4440Q
		if l_person_category in (1,2,3) and l_date_of_arrival > l_asg_dates_rec.contract_st_date  then
			hr_utility.set_location('Please check: Date of Arrival in School should not be later than the start of the contract  ',20);
			populate_run_msg(p_assactid,'Please check: Date of Arrival in School should not be later than the start of the contract','W');
		end if;

		-- 4570
		if  l_daily_rate is not null
                and (length(l_daily_rate) <> 1 or l_daily_rate not in ('Y','N')) then
			l_arch := false;
			hr_utility.set_location('Daily Rate is invalid',20);
			populate_run_msg(p_assactid,'Daily Rate is invalid');
		end if;

		-- 4580
		if l_dcsf_destination is not null then
			begin
					select	 'Y'
					into	 l_valid_flag
			    from	 dual
					where	 exists
					 (select lookup_code
						from	 hr_lookups hl
						where	 hl.lookup_type = 'PQP_GB_SWF_DESTINATION_CODES'
						and    hl.enabled_flag = 'Y'
						and    hl.lookup_code = l_dcsf_destination);
			exception
					when others
					then
						l_arch := false;
						populate_run_msg (p_assactid, 'Destination code is invalid');
						hr_utility.set_location ('Destination code is invalid', 10);
			end;

			if length(l_dcsf_destination) <> 6 then
				l_arch := false;
				populate_run_msg (p_assactid, 'Destination code is invalid');
				hr_utility.set_location ('Destination code is invalid', 20);
			end if;
		end if;

		-- 4600
		if l_dcsf_origin is not null then
			begin
					select	 'Y'
					into	 l_valid_flag
					from	 dual
					where	 exists
					 (select	 lookup_code
							from	 hr_lookups hl
						 where	 hl.lookup_type = 'PQP_GB_SWF_ORIGIN_CODES'
							 and   hl.enabled_flag = 'Y'
							 and   hl.lookup_code = l_dcsf_origin);
			exception
					when others
					then
							l_arch := false;
							populate_run_msg (p_assactid, 'Origin code is invalid');
							hr_utility.set_location ('Origin code is invalid', 10);
			end;

			if length(l_dcsf_origin) <> 6 then
				l_arch := false;
				populate_run_msg (p_assactid, 'Origin code is invalid');
				hr_utility.set_location ('Origin code is invalid', 20);
			end if;
		end if;

		-- 4610Q
		if l_person_category in (1,3) and l_asg_dates_rec.contract_st_date > to_date('31-08-2009','DD-MM-YYYY') and l_dcsf_origin is null then
			populate_run_msg (p_assactid, 'Please check: Origin should be provided','W');
			hr_utility.set_location ('Please check: Origin should be provided', 20);
		end if;

		-- Additional Validations

		if l_contract_agg_type is null then
		  	l_arch := false;
			populate_run_msg (p_assactid, 'Contract Aggreement type can not be null. This error could have occured if the DCSF mapping is incorrect or missing');
			hr_utility.set_location ('Contract Aggreement type can not be null. This error could have occured if the DCSF mapping is incorrect or missing', 20);
        end if;
  p_contract_rec.action_info_category  := 'GB_SWF_CONTRACT_DETAILS';
  p_contract_rec.person_id             := p_person_id;
  p_contract_rec.assignment_id         := l_asg_rec.assignment_id;
  p_contract_rec.effective_date        := g_census_day;
  p_contract_rec.act_info1             := p_person_id;
  p_contract_rec.act_info2             := l_contract_agg_type;

  -- passed as parameter to fetch_payment_details
  p_contract_rec.act_info3             := l_asg_dates_rec.contract_st_date_dcsf;
  p_contract_rec.act_info4             := l_asg_dates_rec.contract_end_date_dcsf;
  p_contract_rec.act_info5             := l_post;
  --
  p_contract_rec.act_info6             := l_date_of_arrival_dcsf;
  -- passed as parameter to fetch_payment_details
  p_contract_rec.act_info7             := l_daily_rate;
  --
  p_contract_rec.act_info8             := l_dcsf_destination;
  p_contract_rec.act_info9             := l_dcsf_origin;
  p_contract_rec.act_info10            := l_la_or_school_level;
  p_contract_rec.act_info11            := l_establishment;
  p_contract_rec.act_info12            := l_asg_rec.assignment_number;
  p_contract_rec.act_info13            := p_effective_date; -- staff effective_date
  -- passed as parameter to fetch_payment_details
  p_contract_rec.act_info14            := l_person_category;
  --
  hr_utility.set_location('Leaving '|| l_proc, 99);
return l_arch;
  exception when others then
      hr_utility.set_location(sqlerrm, 999);
      hr_utility.set_location('Leaving with error'|| l_proc, 999);
end fetch_contract_details;

-----------------------function fetch_qualification_details---------------------
function fetch_qualification_details (p_assactid   in number,
                                      p_person_id  in number,
                                      p_estab_no   in number,
                                      p_qual_tab     out nocopy qual_details_tab)
                                      return boolean is

  cursor get_qual_details is
  select qual.qualification_id qual_id,
         qualtyp.qualification_type_id qualification_type_id,
         qualtyp.category qual_cat,
         decode(qua_information_category, 'GB', qua_information1, null) qual_code_dff,
         decode(qua_information_category, 'GB', qua_information2, null) subject1_dff,
         decode(qua_information_category, 'GB', qua_information3, null) subject2_dff,
         decode(qua_information_category, 'GB', decode(qua_information4,'Y','true','false'), null) verified_dff
    from per_qualifications qual, per_qualification_types qualtyp
   where qual.person_id = p_person_id
     and qual.qualification_type_id = qualtyp.qualification_type_id;

  cursor subject_taken(p_qual_id in number) is
  select max(decode(seq, 1, subject_dcsf, null)) subject_1,
         max(decode(seq, 2, subject_dcsf, null)) subject_2
  from (select subject_dcsf, seq
          from (select pcv.pcv_information2 subject_dcsf, row_number() over(order by major desc) seq
                  from per_qualifications qual, per_subjects_taken sub,
                       pqp_configuration_values pcv
                 where qual.qualification_id = sub.qualification_id
                   and qual.person_id = p_person_id
                   and qual.qualification_id = p_qual_id
                   and pcv.pcv_information_category = 'PQP_GB_SWF_QUAL_SUBJECT_MAP'
                   and pcv.pcv_information1 = sub.subject
                   and pcv.business_group_id = g_business_group_id)
         where seq < 3);

  cursor get_qual_code_src is
  select pcv_information1
    from pqp_configuration_values pcv
   where pcv.pcv_information_category = 'PQP_GB_SWF_QUAL_CODE_MAP'
     and pcv.business_group_id = g_business_group_id;

   cursor get_qual_code_dcsf_cat(p_qual_cat in varchar2) is
   select pcv_information5
    from pqp_configuration_values pcv
   where pcv.pcv_information_category = 'PQP_GB_SWF_QUAL_CODE_MAP'
     and pcv.pcv_information3  = p_qual_cat
     and pcv.business_group_id = g_business_group_id;

   cursor get_qual_code_dcsf_typ(p_qual_typ in varchar2) is
   select pcv_information5
    from pqp_configuration_values pcv
   where pcv.pcv_information_category = 'PQP_GB_SWF_QUAL_CODE_MAP'
     and pcv.pcv_information4  = p_qual_typ
     and pcv.business_group_id = g_business_group_id;

  l_proc      constant varchar2(50) := g_package || ' fetch_qualification_details';
  l_qual_rec get_qual_details%rowtype;
  l_subject1 per_subjects_taken.subject%type;
  l_subject2 per_subjects_taken.subject%type;
  l_qual_code_src  pqp_configuration_values.pcv_information1%type;
  l_qual_code_dcsf pqp_configuration_values.pcv_information1%type;
  l_qual_tab_idx number := 1;
  l_invalid_qual_code varchar2(1)  := 'N';
  l_missing_qual_code varchar2(1)  := 'N';
  l_sub_code_1_invalid varchar2(1) := 'N';
  l_sub_code_2_invalid varchar2(1) := 'N';
  l_sub1_missing       varchar2(1) := 'N';
  l_missing_verified varchar2(1)   := 'N';
  l_same_sub_1_2     varchar2(1)   := 'N';
  l_arch boolean := true;
begin
  hr_utility.set_location('Entering :'||l_proc,10);
  hr_utility.set_location('Parameters   :',20);
  hr_utility.set_location('p_assactid   :'||p_assactid,20);
  hr_utility.set_location('p_person_id  :'||p_person_id,20);

  open  get_qual_code_src;
  fetch get_qual_code_src into l_qual_code_src;
  close get_qual_code_src;

  for  qual_cur in get_qual_details loop
    open  subject_taken(qual_cur.qual_id);
    fetch subject_taken into l_subject1, l_subject2;
    close subject_taken;

    if l_qual_code_src = 'QUALIFICATION_CATEGORY' then
      open  get_qual_code_dcsf_cat(qual_cur.qual_cat);
      fetch get_qual_code_dcsf_cat into l_qual_code_dcsf;
      close get_qual_code_dcsf_cat;
    elsif l_qual_code_src = 'QUALIFICATION_TYPE' then
      open  get_qual_code_dcsf_typ(qual_cur.qualification_type_id);
      fetch get_qual_code_dcsf_typ into l_qual_code_dcsf;
      close get_qual_code_dcsf_typ;
    end if;

    p_qual_tab(l_qual_tab_idx).person_id  := p_person_id;
    p_qual_tab(l_qual_tab_idx).qual_code  := nvl(qual_cur.qual_code_dff,l_qual_code_dcsf);
    p_qual_tab(l_qual_tab_idx).sub1       := nvl(qual_cur.subject1_dff,l_subject1);
    p_qual_tab(l_qual_tab_idx).sub2       := nvl(qual_cur.subject2_dff,l_subject2);
    p_qual_tab(l_qual_tab_idx).verified   := qual_cur.verified_dff;
    p_qual_tab(l_qual_tab_idx).estab_no   := p_estab_no;


  l_qual_tab_idx := l_qual_tab_idx +1;
  end loop;

  if p_qual_tab.count > 0 then
    for i in p_qual_tab.first .. p_qual_tab.last loop
      if p_qual_tab(i).qual_code not in ('PGCE', 'MAST', 'DOCT', 'BEDO', 'FRST', 'CTED', 'NVQ4', 'NNUK') then
          l_invalid_qual_code := 'Y';
      end if;

      if (p_qual_tab(i).sub1 is not null or p_qual_tab(i).sub2 is not null or p_qual_tab(i).verified is not null)
                                        and p_qual_tab(i).qual_code is null then
          l_missing_qual_code := 'Y';
      end if;

      if p_qual_tab(i).sub1 is not null and substr(p_qual_tab(i).sub1,1,1) not between 'A' and 'X'
                                                              or length(substr(p_qual_tab(i).sub1,2)) <>3
                                                              or substr(p_qual_tab(i).sub1,2) not between 100 and 990 then
          l_sub_code_1_invalid := 'Y';
      end if;

      if p_qual_tab(i).sub2 is not null and substr(p_qual_tab(i).sub2,1,1)
         not in ('A', 'B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'T', 'V', 'W', 'X')
         or length(substr(p_qual_tab(i).sub2,2)) <>3
         or substr(p_qual_tab(i).sub2,2) not between 100 and 990 then
            l_sub_code_2_invalid := 'Y';
      end if;

      if p_qual_tab(i).sub1 is null then
          l_sub1_missing := 'Y';
      end if;

      if (p_qual_tab(i).sub1 is not null or p_qual_tab(i).sub2 is not null or p_qual_tab(i).qual_code is not null)
                                        and p_qual_tab(i).verified is null then
          l_missing_verified := 'Y';
      end if;

      if p_qual_tab(i).sub1 = p_qual_tab(i).sub2 then
          l_same_sub_1_2 :='Y';
      end if;
    end loop;
  end if;


  if l_invalid_qual_code = 'Y' then
    l_arch := false;
	populate_run_msg (p_assactid, 'Qualification Code is invalid');
	hr_utility.set_location ('Qualification Code is invalid', 20);
  end if;


  if l_missing_qual_code = 'Y' then
    l_arch := false;
	populate_run_msg (p_assactid, 'Qualification Code is missing');
	hr_utility.set_location ('Qualification Code is missing', 20);
  end if;

  if l_sub_code_1_invalid = 'Y' then
    l_arch := false;
	populate_run_msg (p_assactid, 'Subject Code 1 is invalid');
	hr_utility.set_location ('Subject Code 1 is invalid', 20);
  end if;

  if l_sub_code_2_invalid = 'Y' then
    l_arch := false;
	populate_run_msg (p_assactid, 'Second qualification Subject Code 2 is invalid');
	hr_utility.set_location ('Second qualification Subject Code 2 is invalid', 20);
  end if;

  if l_sub1_missing = 'Y' then
    l_arch := false;
	populate_run_msg (p_assactid, 'Subject Code 1 is missing');
	hr_utility.set_location ('Subject Code 1 is missing', 20);
  end if;

  if l_same_sub_1_2 = 'Y' then
    l_arch := false;
	populate_run_msg (p_assactid, 'Qualification Subject Code 1 and Subject Code 2 cannot be the same');
	hr_utility.set_location ('Qualification Subject Code 1 and Subject Code 2 cannot be the same', 20);
  end if;

  if l_missing_verified = 'Y' then
    l_arch := false;
	populate_run_msg (p_assactid, 'Qualification Verified is missing');
	hr_utility.set_location ('Qualification Verified is missing', 20);
  end if;

  hr_utility.set_location('Leaving :'||l_proc,99);
return l_arch;
  exception when others then
      hr_utility.set_location(sqlerrm,999);
      hr_utility.set_location('Leaving with error:'||l_proc,999);
      raise;
end fetch_qualification_details;

------------------------------function fetch_payment_details--------------------
-- This is called from the archive code.
function fetch_payment_details  ( p_assactid        in number,
                                  p_effective_date  in date,
                                  p_person_id       in number,
                                  p_assignment_id   in number,
				  p_post	    in varchar2,
                                  p_qt_status	    in varchar2,
                                  p_person_category in varchar2,
                                  p_cont_st_date    in varchar2,
                                  p_cont_end_date   in varchar2,
                                  p_daily_rate	    in varchar2,
                                  p_payment_rec     out nocopy act_info_rec)
return boolean is

  cursor pay_scale is
  select ps.parent_spine_id
    from per_grade_spines_f     grs,
         per_grades             gdt,
         per_parent_spines      ps,
         per_all_assignments_f  asg
   where grs.grade_id = gdt.grade_id
     and grs.parent_spine_id = ps.parent_spine_id
     and asg.grade_id =  grs.grade_id
     and asg.assignment_id = p_assignment_id
     and p_effective_date between asg.effective_start_date and asg.effective_end_date
     and p_effective_date between grs.effective_start_date and grs.effective_end_date;

  cursor pay_scale_dcsf(p_pay_scale in per_parent_spines.parent_spine_id%type) is
  select pcv.pcv_information2
    from pqp_configuration_values pcv
   where pcv.pcv_information_category = 'PQP_GB_SWF_PAY_SCALE_MAPPING'
     and pcv.pcv_information1  = p_pay_scale
     and pcv.business_group_id = g_business_group_id;

  cursor spinal_points is
  select spinal_point,psp.spinal_point_id
    from per_spinal_point_placements_f pspp,
         per_spinal_point_steps_f      psps,
         per_spinal_points             psp
   where pspp.assignment_id = p_assignment_id
     and pspp.step_id = psps.step_id
     and psps.spinal_point_id = psp.spinal_point_id
     and p_effective_date between pspp.effective_start_date and pspp.effective_end_date
     and p_effective_date between psps.effective_start_date and psps.effective_end_date;


  cursor spinal_point_dcsf(p_pay_scale in per_parent_spines.parent_spine_id%type,
                           p_spinal_point in per_spinal_points.spinal_point_id%type) is
  select pcv.pcv_information3
    from pqp_configuration_values pcv
   where pcv.pcv_information_category = 'PQP_GB_SWF_SPINE_POINT_MAPPING'
     and pcv.pcv_information1  = p_pay_scale
     and pcv.pcv_information2  = p_spinal_point
     and pcv.business_group_id = g_business_group_id;

  cursor salary_rate (p_spinal_point_id in number) is
  select to_char(value,'fm999999.00')
    from pay_grade_rules_f pgr
   where grade_or_spinal_point_id = p_spinal_point_id
     and p_effective_date between pgr.effective_start_date and pgr.effective_end_date;

  cursor  get_regional_spine_source is
  select pcv_information1, pcv_information2, pcv_information3
    from pqp_configuration_values pcv
   where pcv.pcv_information_category = 'PQP_GB_SWF_REG_SPINE_SRC'
     and pcv.business_group_id = g_business_group_id;

  cursor reg_spinal_point_dcsf(p_pay_scale in per_parent_spines.name%type,
                           p_spinal_point in per_spinal_points.spinal_point%type) is
  select pcv.pcv_information4
    from pqp_configuration_values pcv
   where pcv.pcv_information_category = 'PQP_GB_SWF_REG_SPINE_MAP_PYSCL'
     and pcv.pcv_information1  = p_pay_scale
     and p_spinal_point    between pcv.pcv_information2 and pcv.pcv_information3
     and pcv.business_group_id = g_business_group_id;

   cursor safe_grd_sal is
   select decode(tp_safeguarded_rate_type,'SN','true','SP','true','G','true','false')
     from pqp_assignment_attributes_f
    where assignment_id= p_assignment_id;
---
  l_proc constant varchar2(50) := g_package || ' fetch_payment_details';
  l_regional_spine_context      varchar2(30);
  l_regional_spine_segment      varchar2(30);
  l_regional_spine_def_val      varchar2(30);
  l_regional_spine_sql_str      varchar2(3000);
  l_pay_scale                   per_parent_spines.parent_spine_id%type;
  l_pay_scale_dcsf              hr_lookups.lookup_code%type;
  l_spinal_point                per_spinal_points.spinal_point%type;
  l_spinal_point_dcsf           hr_lookups.lookup_code%type;
  l_reg_spinal_point_dcsf       hr_lookups.lookup_code%type;
  l_safe_grd_sal                varchar2(5);
  l_arch						            boolean := true;
  l_contract_st_date			      date := to_date(p_cont_st_date,'YYYY-MM-DD');
  l_contract_end_date			      date := to_date(p_cont_end_date,'YYYY-MM-DD');
  l_valid_flag					        varchar2(10);
  l_salary_rate					        number;
  l_spinal_point_id				      number;



begin
    hr_utility.set_location('Entering :'||l_proc,100);

    hr_utility.set_location('p_assactid         :' ||p_assactid,110);
    hr_utility.set_location('p_effective_date   :' ||p_effective_date,110);
    hr_utility.set_location('p_person_id        :' ||p_person_id,110);
    hr_utility.set_location('p_assignment_id    :' ||p_assignment_id,110);
    hr_utility.set_location('p_post             :' ||p_post,110);
    hr_utility.set_location('p_person_category  :' ||p_person_category,110);
    hr_utility.set_location('p_cont_st_date     :' ||p_cont_st_date,110);
    hr_utility.set_location('p_cont_end_date    :' ||p_cont_end_date,110);
    hr_utility.set_location('p_daily_rate       :' ||p_daily_rate,110);

    open  pay_scale;
    fetch pay_scale into l_pay_scale;
    close pay_scale;

    open  pay_scale_dcsf(l_pay_scale);
    fetch pay_scale_dcsf into l_pay_scale_dcsf;
    close pay_scale_dcsf;

    open  spinal_points;
    fetch spinal_points into l_spinal_point,l_spinal_point_id;
    close spinal_points;

    open  spinal_point_dcsf(l_pay_scale,l_spinal_point_id);
    fetch spinal_point_dcsf into l_spinal_point_dcsf;
    close spinal_point_dcsf;

    open  get_regional_spine_source;
    fetch get_regional_spine_source into l_regional_spine_context,l_regional_spine_segment,l_regional_spine_def_val;
    close get_regional_spine_source;

		open salary_rate(l_spinal_point_id);
		fetch salary_rate into l_salary_rate;
		close salary_rate;

    if l_regional_spine_context = 'GRD' then
      l_regional_spine_sql_str :='select pcv.pcv_information4
      from  per_all_assignments_f paf,
            per_grades pgr,
            per_grade_definitions pgd ,
            pqp_configuration_values pcv
      where paf.business_group_id + 0 = :bg_id
      and paf.business_group_id       = pgr.business_group_id
      and pcv.business_group_id       = paf.business_group_id
      and pgr.grade_definition_id     = pgd.grade_definition_id
      and paf.grade_id                = pgr.grade_id
      and :eff_date between paf.effective_start_date and paf.effective_end_date
      and paf.assignment_id                    = :assignment_id
      and pcv.pcv_information_category = ''PQP_GB_SWF_REG_SPINE_MAP_GRD''
      and ((pcv_information3          is null
      and pgd.'||l_regional_spine_segment||'                 = pcv.pcv_information2 )
      or (pcv_information3            is not null
      and pgd.'||l_regional_spine_segment||' between pcv.pcv_information2 and pcv_information3))';

      begin
        execute immediate l_regional_spine_sql_str into l_reg_spinal_point_dcsf using g_business_group_id,p_effective_date, p_assignment_id;
        exception when others then
         hr_utility.set_location('Spinal could not be fetched as of' || p_effective_date ||'for Assignment ID :'||p_assignment_id,9999);
      end;

    elsif l_regional_spine_context = 'PAYSCALE_SPINEPOINT' then
      open  reg_spinal_point_dcsf(l_pay_scale,l_spinal_point_id);
      fetch reg_spinal_point_dcsf into l_reg_spinal_point_dcsf;
      close reg_spinal_point_dcsf;
    elsif l_regional_spine_context = 'DEFAULT' then
       l_reg_spinal_point_dcsf := l_regional_spine_def_val;
    end if;

    open  safe_grd_sal;
    fetch safe_grd_sal into l_safe_grd_sal;
    close safe_grd_sal;

		-- 4460
		if length(l_pay_scale_dcsf) <> 2 then
				l_arch := false;
				hr_utility.set_location('Pay Scale is invalid',10);
				populate_run_msg(p_assactid,'Pay Scale is invalid');
		end if;

		-- 4470
		if  l_pay_scale_dcsf in('LD', 'TE', 'TU', 'EX' ,'AS')and p_qt_status <> 'Yes'  then
				l_arch := false;
				hr_utility.set_location('Pay Scale type inconsistent with Qualified Teacher Status',10);
				populate_run_msg(p_assactid,'Pay Scale type inconsistent with Qualified Teacher Status');
		end if;

		-- 4480
		if p_post = 'SUP' and l_pay_scale_dcsf in('LD', 'TE', 'TU', 'EX' ,'AS') then
				l_arch := false;
				hr_utility.set_location('Pay Scale is invalid for the given Post',10);
				populate_run_msg(p_assactid,'Pay Scale is invalid for the given Post');
		end if;

		-- 4490
		if  p_person_category in (1,2) and (l_contract_end_date is null or l_contract_end_date > g_census_day)
											and p_daily_rate = 'N' and p_post in('HDT','DHT','AHT') and l_pay_scale_dcsf <> 'LD' then
			  l_arch := false;
				hr_utility.set_location('Pay Scale is invalid for the given Post',20);
				populate_run_msg(p_assactid,'Pay Scale is invalid for the given Post');
		end if;

		-- 4500
		if p_person_category in (1,2) and (l_contract_end_date is null or l_contract_end_date > g_census_day)
											and p_daily_rate = 'N' and p_post = 'AST' and l_pay_scale_dcsf <> 'AS' then
				l_arch := false;
				hr_utility.set_location('Pay Scale is invalid for the given Post',30);
				populate_run_msg(p_assactid,'Pay Scale is invalid for the given Post');
		end if;

		-- 4505
		if p_person_category in (1,2) and (l_contract_end_date is null or l_contract_end_date > g_census_day)
											and p_daily_rate = 'N' and p_post = 'EXL' and l_pay_scale_dcsf <> 'EX' then
				l_arch := false;
				hr_utility.set_location('Pay Scale is invalid for the given Post',40);
				populate_run_msg(p_assactid,'Pay Scale is invalid for the given Post');
		end if;

		-- 4510

		if l_reg_spinal_point_dcsf is not null then
			begin
					select	 'Y'
						into	 l_valid_flag
						from	 dual
					 where	 exists
					 (select lookup_code
						 from	 hr_lookups hl
						 where	 hl.lookup_type = 'PQP_GB_REGIONAL_SPINE_CODE'
										 and hl.enabled_flag = 'Y'
										 and hl.lookup_code = l_reg_spinal_point_dcsf);
			exception
					when others
					then
					l_arch := false;
					hr_utility.set_location('Regional Pay Spine is invalid',10);
					populate_run_msg(p_assactid,'Regional Pay Spine is invalid');
			end;

				if  length(l_reg_spinal_point_dcsf) <> 2 then
					l_arch := false;
					hr_utility.set_location('Regional Pay Spine is invalid',20);
					populate_run_msg(p_assactid,'Regional Pay Spine is invalid');
				end if;
		end if;

		-- 4520
		if l_spinal_point_dcsf is not null then
			begin
					select	 'Y'
						into	 l_valid_flag
						from	 dual
					 where	 exists
											 (select lookup_code
											  from	 hr_lookups hl
											  where	 hl.lookup_type = 'PQP_GB_DCSF_SPINE_POINTS'
											  and    hl.enabled_flag = 'Y'
											  and    hl.lookup_code = l_spinal_point_dcsf);
			exception
					when others
					then
					l_arch := false;
					hr_utility.set_location('Spine Point is invalid',10);
					populate_run_msg(p_assactid,'Spine Point is invalid');
			end;

				if  length(l_spinal_point_dcsf) not between 1 and 6 then
					l_arch := false;
					hr_utility.set_location('Spine Point is invalid',20);
					populate_run_msg(p_assactid,'Spine Point is invalid');
				end if;
		end if;

		-- 4530 handled in the cursor
		-- 4540
		if p_person_category in (2,3) and (l_contract_end_date is null or l_contract_end_date > g_census_day)
																and p_daily_rate = 'N' and l_salary_rate is null  then
					l_arch := false;
					hr_utility.set_location('Salary Rate must be provided where Daily Rate is false',10);
					populate_run_msg(p_assactid,'Salary Rate must be provided where Daily Rate is false');
		end if;

		-- 4550
		if p_person_category in (2,3) and (l_contract_end_date is null or l_contract_end_date > g_census_day)
											 					and p_daily_rate = 'Y' and l_salary_rate is not null  then
					l_arch := false;
					hr_utility.set_location('Salary Rate must not be provided where Daily Rate is true',10);
					populate_run_msg(p_assactid,'Salary Rate must not be provided where Daily Rate is true');
		end if;

  p_payment_rec.action_info_category  := 'GB_SWF_PAYMENT_DETAILS';
  p_payment_rec.person_id             := p_person_id;
  p_payment_rec.assignment_id         := p_assignment_id;
  p_payment_rec.effective_date        := sysdate;
  p_payment_rec.act_info1             := l_pay_scale_dcsf;
  p_payment_rec.act_info2             := l_reg_spinal_point_dcsf;
  p_payment_rec.act_info3             := l_spinal_point_dcsf;
  p_payment_rec.act_info4             := l_salary_rate;
  p_payment_rec.act_info5             := l_safe_grd_sal;


    hr_utility.set_location('Leaving :'||l_proc,999);

return l_arch;
  exception when others then
      hr_utility.set_location('Leaving with error:'||l_proc,9999);
      raise;
end fetch_payment_details;

----------------------procedure archinit----------------------------------------
procedure archinit(p_payroll_action_id in number)
is
     l_proc      constant varchar2(50) := g_package || ' archinit';
     l_exp       exception;

 cursor param_details is
	select upper((pay_gb_eoy_archive.get_parameter(legislative_parameters,'DATA_RETURN_TYPE'))) data_return_type,
		(pay_gb_eoy_archive.get_parameter(legislative_parameters,'ESTB_NUM')) estb_num
	from pay_payroll_actions ppa
	where ppa.payroll_action_id = p_payroll_action_id;

	param_details_rec  param_details%rowtype;

begin
  hr_utility.set_location('Entering '|| l_proc, 10);
  open param_details;
  fetch param_details into param_details_rec;
  close param_details;

  if param_details_rec.data_return_type = 'TYPE3' and param_details_rec.estb_num is not null then
    raise_application_error(-20002,'Establishment number should not be entered for Type 3 Extract.');
    fnd_file.put_line(fnd_file.log,'Establishment number should not be entered for Type 3 Extract.');
    fnd_file.put_line(fnd_file.output,'Establishment number should not be entered for Type 3 Extract.');
    fnd_file.put_line(fnd_file.output,' ');
  end if;

  if param_details_rec.data_return_type = 'TYPE2' and param_details_rec.estb_num is null then
    raise_application_error(-20002,'Establishment number should be entered for Type 2 Extract.');
    fnd_file.put_line(fnd_file.log,'Establishment number should be entered for Type 2 Extract.');
    fnd_file.put_line(fnd_file.output,'Establishment number should be entered for Type 2 Extract.');
    fnd_file.put_line(fnd_file.output,' ');
  end if;


  hr_utility.set_location('Leaving '|| l_proc, 110);
exception
     when others then
          hr_utility.set_location('Leaving '|| l_proc, 999);
          hr_utility.set_location(sqlerrm,9999);
          hr_utility.raise_error;
end archinit;

---------------------------procedure archive_code-------------------------------
procedure archive_code(p_assactid       in number,
                       p_effective_date in date) is
     l_proc  constant varchar2(35):= g_package||'archive_code';
     error_found      exception;
     l_archive_tab    action_info_table;
     l_role_tab       addl_role_tab;
     l_archive_person    boolean:= true;
     l_archive_type      varchar2(20);
     l_archive_contract  boolean:= true;
     l_archive_payment   boolean:= true;
     l_archive_role      boolean:= true;
     l_archive_abs       boolean:= true;
     l_archive_qual      boolean:= true;
     l_archive_addl_payment boolean:= true;
     l_archive_hrs       boolean:= true;
     l_archive_tab_index pls_integer;
     l_abs_tab           abs_details_tab;
     l_qual_tab          qual_details_tab;
     p_addl_payment_tab  addl_payment_dtl_tab;
     l_pactid            number;
     l_contract_type	 varchar2(50);
     l_do_not_process_further boolean;
     -- Type 4
     l_assignment_id per_all_assignments_f.assignment_id%type;
     l_employment_category per_all_assignments_f.employment_category%type;
     l_assignment_number per_all_assignments_f.assignment_number%type;
     l_arch_role boolean :=true;
     l_epsy varchar2(1)  := 'N';
     p_role_tab          addl_role_tab;
     l_temp_or_perm      varchar2(10);
     l_fte_src           varchar2(30);
     l_fte_formula_id    number;
     l_error_message     varchar2(1000);
     l_fte_ratio	      number;
     l_fte_hrs          number;




  cursor csr_parameter_info  is
	select  (pay_gb_eoy_archive.get_parameter(legislative_parameters,'CENSUS_YEAR')) census_year,
		(pay_gb_eoy_archive.get_parameter(legislative_parameters,'CENSUS_DAY')) census_day,
		add_months(to_date((pay_gb_eoy_archive.get_parameter(legislative_parameters,'CONT_ST_DAY'))),-12) cont_st_day,
		(pay_gb_eoy_archive.get_parameter(legislative_parameters,'CONT_END_DAY')) cont_end_day,
		(pay_gb_eoy_archive.get_parameter(legislative_parameters,'LEA_NUM')) lea_num,
		upper((pay_gb_eoy_archive.get_parameter(legislative_parameters,'DATA_RETURN_TYPE'))) data_return_type,
		(pay_gb_eoy_archive.get_parameter(legislative_parameters,'ESTB_NUM')) estb_num,
		(pay_gb_eoy_archive.get_parameter(legislative_parameters,'EXCLUDE_ABS')) exclude_abs,
		(pay_gb_eoy_archive.get_parameter(legislative_parameters,'EXCLUDE_QUAL')) exclude_qual,
		business_group_id,
		ppa.payroll_action_id
	from pay_assignment_actions paa, pay_payroll_actions ppa
	where paa.assignment_action_id = p_assactid
	and paa.payroll_action_id = ppa.payroll_action_id;

  cursor csr_asg_no(p_census_day in date) is
  select paa.assignment_id , paa.employment_category, paa.assignment_number
  from   pay_assignment_actions act,
         per_all_assignments_f      paa,
         per_assignment_status_types pas
  where  act.assignment_action_id = p_assactid
  and    act.assignment_id = paa.assignment_id
  and    p_census_day between paa.effective_start_date and paa.effective_end_date
  and    paa.assignment_status_type_id = pas.assignment_status_type_id
  and    pas.per_system_status = 'ACTIVE_ASSIGN';

 cursor contract_type is
  select distinct pcv_information1
  from   pqp_configuration_values
  where  pcv_information_category = 'PQP_GB_SWF_CONTRACT_TYPE'
  and    business_group_id        = g_business_group_id;

  cursor get_fte_src is
  select pcv_information1,pcv_information2
  from   pqp_configuration_values pcv
  where  pcv.pcv_information_category = 'PQP_GB_SWF_FTE_HOURS'
  and    pcv.business_group_id = g_business_group_id;

begin
     hr_utility.set_location('Entering: '||l_proc,10);
 -----
  open csr_parameter_info;
  fetch csr_parameter_info into g_census_year,
                                g_census_day,
                                g_cont_data_st_date,
                                g_cont_data_end_date,
                                g_lea_number,
                                g_data_ret_type,
                                g_estb_number,
                                g_exclude_absence,
                                g_exclude_qual,
                                g_business_group_id,
                                l_pactid;
  close csr_parameter_info;

  open  contract_type;
  fetch contract_type into l_contract_type;
  close contract_type;

  if l_contract_type is not null then
     if l_contract_type = 'ASG_CAT' then
       g_pick_from_asg  := 'Y';
     else
       g_pick_from_asg  := 'N';
     end if;
  else
     fnd_file.put_line(fnd_file.log,'Contract Details - Contract Type Configuration is not set.Please configure and proce');
  end if;
  ------------------------------------------------------------------------------
  --dyn_sql call here. dyn_sql builds all the dynamic sql strings that are used
  -- in the archive procedures.this has been wrapped into a procedure to keep the
  -- dynamic sql logic separate from the archive code.
  dyn_sql;
  ------------------------------------------------------------------------------
     hr_utility.set_location('Archiving Starts for assignment_action_id :'||p_assactid ,20);
  -- archive starts
  -- l_archive_tab table will be populated with all the archive records and
  -- finally will be passed to the archive api. the first record will be put in
  -- 0th index and any new records that are to be populated are to be populated
  -- in l_archive_tab.count location to avoid no_data_found exception
  if g_data_ret_type <> 'TYPE4' then

    l_archive_person := fetch_staff_details(p_assactid,p_effective_date,l_archive_tab(0));

     hr_utility.set_location('Archiving Staff Details Complete: '||l_proc,100);

     l_archive_contract := fetch_contract_details(p_assactid,l_archive_tab(0).act_info16,l_archive_tab(0).person_id,l_archive_tab(0).act_info13,l_archive_tab(0).act_info2,l_archive_tab(1),l_role_tab);

     hr_utility.set_location('Archiving Contract Details Complete: '||l_proc,200);

     l_archive_payment := fetch_payment_details(p_assactid,l_archive_tab(0).act_info16,l_archive_tab(0).person_id,l_archive_tab(1).assignment_id,
			 l_archive_tab(1).act_info5,l_archive_tab(0).act_info12,l_archive_tab(1).act_info14, l_archive_tab(1).act_info3,l_archive_tab(1).act_info4,l_archive_tab(1).act_info7,l_archive_tab(2));

     hr_utility.set_location('Archiving Payment Details Complete: '||l_proc,300);

     l_archive_tab_index := l_archive_tab.count;


     for i in l_role_tab.first .. l_role_tab.last loop
        l_archive_tab(l_archive_tab_index).action_info_category  := 'GB_SWF_ROLE_DETAILS';
        l_archive_tab(l_archive_tab_index).person_id             :=  l_archive_tab(1).person_id;
        l_archive_tab(l_archive_tab_index).assignment_id         :=  l_archive_tab(1).assignment_id;
        l_archive_tab(l_archive_tab_index).effective_date        :=  sysdate;
        l_archive_tab(l_archive_tab_index).act_info1             :=  l_role_tab(i);

        l_archive_tab_index := l_archive_tab_index +1;
     end loop;

     hr_utility.set_location('Archiving Role Details Complete: '||l_proc,400);


     if check_max_action(p_assactid,l_archive_tab(0).person_id,l_pactid) then

          if g_exclude_absence = 'No' then

    			    l_archive_abs := fetch_absence_details(p_assactid,l_archive_tab(0).person_id,l_archive_tab(0).act_info2,l_abs_tab);
                    l_archive_tab_index := l_archive_tab.count;
                    if l_abs_tab.count >0 then
              				for i in l_abs_tab.first .. l_abs_tab.last loop
              					l_archive_tab(l_archive_tab_index).action_info_category  := 'GB_SWF_ABS_DETAILS';
              					l_archive_tab(l_archive_tab_index).person_id             := l_archive_tab(1).person_id;
              					l_archive_tab(l_archive_tab_index).assignment_id         := l_archive_tab(1).assignment_id;
              					l_archive_tab(l_archive_tab_index).effective_date        := sysdate;
              					l_archive_tab(l_archive_tab_index).act_info1             := l_abs_tab(i).person_id;
              					l_archive_tab(l_archive_tab_index).act_info2             := l_abs_tab(i).date_start_dcsf;
              					l_archive_tab(l_archive_tab_index).act_info3             := l_abs_tab(i).date_end_dcsf;
              					l_archive_tab(l_archive_tab_index).act_info4             := l_abs_tab(i).days_lost;
              					l_archive_tab(l_archive_tab_index).act_info5             := l_abs_tab(i).absence_category;
              					l_archive_tab(l_archive_tab_index).act_info6             := l_abs_tab(i).estab_no;

              					l_archive_tab_index := l_archive_tab_index +1;
              				 end loop;
    				      end if;
    			end if;

          hr_utility.set_location('Archiving Absence Complete: '||l_proc,500);

          if g_exclude_qual = 'No' then
    				l_archive_qual := fetch_qualification_details(p_assactid,l_archive_tab(0).person_id,l_archive_tab(0).act_info2,l_qual_tab);
    				l_archive_tab_index := l_archive_tab.count;
    				if l_qual_tab.count > 0 then
              for i in l_qual_tab.first .. l_qual_tab.last loop
      				    l_archive_tab(l_archive_tab_index).action_info_category  := 'GB_SWF_QUAL_DETAILS';
      					l_archive_tab(l_archive_tab_index).person_id             := l_archive_tab(1).person_id;
      					l_archive_tab(l_archive_tab_index).assignment_id         := l_archive_tab(1).assignment_id;
      					l_archive_tab(l_archive_tab_index).effective_date        := sysdate;
                        l_archive_tab(l_archive_tab_index).act_info1             := l_qual_tab(i).person_id;
      					l_archive_tab(l_archive_tab_index).act_info2             := l_qual_tab(i).qual_code;
      					l_archive_tab(l_archive_tab_index).act_info3             := l_qual_tab(i).sub1;
      					l_archive_tab(l_archive_tab_index).act_info4             := l_qual_tab(i).sub2;
      					l_archive_tab(l_archive_tab_index).act_info5             := l_qual_tab(i).verified;
      					l_archive_tab(l_archive_tab_index).act_info6             := l_qual_tab(i).estab_no;

                        l_archive_tab_index := l_archive_tab_index +1;
    				  end loop;
    				end if;
  			 end if;

 			  hr_utility.set_location('Archiving Qualification Complete: '||l_proc,600);
     end if; -- end check_max_action


		    l_archive_addl_payment := fetch_addl_payment_details(p_assactid,l_archive_tab(1).assignment_id,l_archive_tab(0).act_info16,p_addl_payment_tab);
        l_archive_tab_index:= l_archive_tab.count;
          if p_addl_payment_tab.count >0 then
      			for i in p_addl_payment_tab.first .. p_addl_payment_tab.last loop
      				l_archive_tab(l_archive_tab_index).action_info_category  := 'GB_SWF_ADD_PAYMENT_DETAILS';
      				l_archive_tab(l_archive_tab_index).person_id             := l_archive_tab(1).person_id;
      				l_archive_tab(l_archive_tab_index).assignment_id         := l_archive_tab(1).assignment_id;
      				l_archive_tab(l_archive_tab_index).effective_date        := sysdate;
      				l_archive_tab(l_archive_tab_index).act_info1             := p_addl_payment_tab(i).addl_payment_cat;
      				l_archive_tab(l_archive_tab_index).act_info2             := p_addl_payment_tab(i).addl_payment_amt;

      				l_archive_tab_index := l_archive_tab_index +1;
      			end loop;
         end if;


    hr_utility.set_location('Archiving Addl Payments Complete: '||l_proc,700);

    l_archive_tab_index:= l_archive_tab.count;

    l_archive_hrs := fetch_hours_details(p_assactid,l_archive_tab(1).assignment_id,l_archive_tab(0).act_info16,
    l_archive_tab(1).act_info14,l_archive_tab(0).person_id,l_archive_tab(1).act_info2,l_archive_tab(1).act_info4,l_archive_tab(l_archive_tab_index));

   	hr_utility.set_location('Archiving Hours Complete: '||l_proc,800);

    if l_archive_person and l_archive_contract and l_archive_payment and l_archive_abs and
       l_archive_qual   and l_archive_addl_payment and l_archive_hrs    then

         insert_archive_row(p_assactid, p_effective_date, l_archive_tab);
    else
        fnd_file.put_line(fnd_file.log,'Error(s) in assignment id: '||l_archive_tab(1).assignment_id||'. Please refer Output file for detailed error messages');
        raise_application_error(-20001,'Error(s) found while archiving data.');
    end if;

  else
     open csr_asg_no(g_census_day);
     fetch csr_asg_no into l_assignment_id,l_employment_category,l_assignment_number;
     close csr_asg_no;

     if l_assignment_id is not null then

	l_arch_role := fetch_role_details(p_assactid,g_census_day,null,l_assignment_id,l_role_tab);
       	hr_utility.set_location('Test 0: '||l_proc,800);

   for i in l_role_tab.first .. l_role_tab.last loop
  	  if  l_role_tab(i) = 'EPSY' then
  	     l_epsy := 'Y';
  	  end if;
  	end loop;

       	hr_utility.set_location('Test 1: '||l_proc,800);
	    if l_epsy = 'Y' then
		-- If the value for l_employment_category is seeded
		l_temp_or_perm := pqp_gb_t1_pension_extracts.get_translate_asg_emp_cat_code
			(l_employment_category
			,g_census_day
			,'Pension Extracts Employment Category Code'
			,null
			) ;
		-- if value for l_employment_category is not seeded
		l_temp_or_perm := pqp_gb_t1_pension_extracts.get_translate_asg_emp_cat_code
			(l_employment_category
			,g_census_day
			,'Pension Extracts Employment Category Code'
			,g_business_group_id
			) ;
       	hr_utility.set_location('Test 2: '||l_proc,800);

		l_archive_hrs := fetch_hours_details(p_assactid,l_assignment_id,g_census_day,4,null,l_contract_type, null,l_archive_tab(0) );
  	l_archive_tab_index:= l_archive_tab.count;
			hr_utility.set_location('Test 3: '||l_proc,800);
   for i in l_role_tab.first .. l_role_tab.last loop
			l_archive_tab(l_archive_tab_index).action_info_category  := 'GB_SWF_ROLE_DETAILS';
			l_archive_tab(l_archive_tab_index).person_id             :=  l_archive_tab(1).person_id;
			l_archive_tab(l_archive_tab_index).assignment_id         :=  l_archive_tab(1).assignment_id;
			l_archive_tab(l_archive_tab_index).effective_date        :=  sysdate;
			l_archive_tab(l_archive_tab_index).act_info1             :=  l_role_tab(i);
			l_archive_tab(l_archive_tab_index).act_info2             :=  l_temp_or_perm;

			l_archive_tab_index := l_archive_tab_index +1;
		end loop;

       	hr_utility.set_location('Test 4: '||l_proc,800);
		insert_archive_row(p_assactid, g_census_day, l_archive_tab);
	   end if;
	end if;
  end if;


    hr_utility.set_location('leaving: '||l_proc,999);

exception
     when others then
       hr_utility.trace(sqlerrm);
       hr_utility.set_location('Error in Archive: '||l_proc,999);
       raise;
end archive_code;

--------------------------- procedure deinit_code------------------------------

procedure deinit_code(pactid in number) is
   l_proc  constant varchar2(50) := g_package || 'deinit_code';
   l_counter number;
   l_temp   varchar2(100);

  cursor param_details
  is
  select(pay_gb_eoy_archive.get_parameter(legislative_parameters,'CENSUS_YEAR')) census_year,
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,'CENSUS_DAY')) census_day,
  add_months(to_date((pay_gb_eoy_archive.get_parameter(legislative_parameters,'CONT_ST_DAY'))),-12) cont_st_day,
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,'CONT_END_DAY')) cont_end_day,
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,'LEA_NUM')) lea_num,
  upper((pay_gb_eoy_archive.get_parameter(legislative_parameters,'DATA_RETURN_TYPE'))) data_return_type,
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,'ESTB_NUM')) estb_num,
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,'EXCLUDE_ABS')) exclude_abs,
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,'EXCLUDE_QUAL')) exclude_qual,
  (pay_gb_eoy_archive.get_parameter(legislative_parameters,'ASG_SET')) asg_set,
  effective_date,
  business_group_id
  from   pay_payroll_actions
  where  payroll_action_id = pactid;

   cursor csr_asg is
   select     distinct
              peo.first_name          f_name ,
              peo.middle_names        m_name,
              peo.last_name           l_name,
              peo.title               title,
              peo.employee_number     emp_no,
              paf.assignment_number   asg_no,
              peo.national_identifier ni_no,
              paa.assignment_action_id asg_act_id
       from   pay_payroll_actions    pay,
              pay_assignment_actions paa,
              per_all_assignments_f  paf,
              per_all_people_f       peo,
               (select max(effective_end_date) effective_date,assignment_id
                from per_all_assignments_f
                group by assignment_id) max_eff_date
       where  pay.payroll_action_id = pactid
       and    paa.payroll_action_id = pay.payroll_action_id
       and    paf.assignment_id = paa.assignment_id
       and    peo.person_id = paf.person_id
       and    max_eff_date.assignment_id = paf.assignment_id
       and exists (select 'X'
                   from pay_message_lines pml
                   where paa.assignment_action_id = pml.source_id)
       and    max_eff_date.effective_date between paf.effective_start_date and paf.effective_end_date
       and    max_eff_date.effective_date between peo.effective_start_date and peo.effective_end_date;


  cursor messages (p_asg_act_id in number) is
  select pml.line_text error_text
  from pay_message_lines pml
  where pml.source_id = p_asg_act_id
  and   pml.MESSAGE_LEVEL = 'F'
  and   pml.line_sequence < (select line_sequence
                             from pay_message_lines pml1
                             where pml1.source_id = p_asg_act_id
                             and   pml1.line_text like 'Error ORA-20001: Error(s) found while archiving data.')
  UNION ALL
  select pml.line_text error_text
  from pay_message_lines pml
  where pml.source_id = p_asg_act_id
  and   pml.message_level = 'W';


  param_details_rec param_details%rowtype;

  cursor asg_without_errors is
   select     distinct
              peo.first_name          f_name ,
              peo.middle_names        m_name,
              peo.last_name           l_name,
              peo.title               title,
              peo.employee_number     emp_no,
              paf.assignment_number   asg_no,
              peo.national_identifier ni_no,
              paa.assignment_action_id asg_act_id
       from   pay_payroll_actions    pay,
              pay_assignment_actions paa,
              per_all_assignments_f  paf,
              per_all_people_f       peo,
               (select max(effective_end_date) effective_date,assignment_id
                from per_all_assignments_f
                group by assignment_id) max_eff_date
       where  pay.payroll_action_id = pactid
       and    paa.payroll_action_id = pay.payroll_action_id
       and    paf.assignment_id = paa.assignment_id
       and    peo.person_id = paf.person_id
       and    max_eff_date.assignment_id = paf.assignment_id
       and not exists (select 'X'
                   from pay_message_lines pml
                   where paa.assignment_action_id = pml.source_id
		   and message_level <> 'W')
       and    max_eff_date.effective_date between paf.effective_start_date and paf.effective_end_date
       and    max_eff_date.effective_date between peo.effective_start_date and peo.effective_end_date;

       cursor fte_hrs is
	select action_information4 person_id,sum(action_information7)
	from pay_action_information pai,
	      pay_payroll_actions ppa,
	      pay_assignment_actions paa
	where ppa.payroll_action_id = pactid
	and ppa.payroll_action_id = paa.payroll_action_id
	and paa.assignment_action_id = pai.action_context_id
	and pai.action_information_category = 'GB_SWF_HOURS_DETAILS'
	and action_information5 IN ('PRM','TMP','FXT')
	and action_information6 is null
	group by action_information4
	having sum(action_information7) > 1.5;

	cursor emp_details (p_person_id IN number)is
	select       peo.first_name          f_name ,
	peo.middle_names        m_name,
	peo.last_name           l_name,
	peo.title               title,
	peo.employee_number     emp_no,
	peo.national_identifier ni_no
	from         per_all_people_f       peo
	where        person_id = p_person_id;

	emp_rec emp_details%rowtype;

	CURSOR hdtr_count IS
	select COUNT(*)
	from pay_action_information pai,
	      pay_payroll_actions ppa,
	      pay_assignment_actions paa
	where ppa.payroll_action_id = pactid
	and ppa.payroll_action_id = paa.payroll_action_id
	and paa.assignment_action_id = pai.action_context_id
	and pai.action_information_category = 'GB_SWF_ROLE_DETAILS'
	and action_information1 = 'HDTR';

	l_hdtr_count number;

  l_espf_full_time number;
  l_espf_part_time number;
  l_espf_fte  number;

  cursor epsy_head_count_prm is
  select COUNT(*)
	from pay_action_information pai,
	      pay_payroll_actions ppa,
	      pay_assignment_actions paa
	where ppa.payroll_action_id = pactid
	and ppa.payroll_action_id = paa.payroll_action_id
	and paa.assignment_action_id = pai.action_context_id
	and pai.action_information_category = 'GB_SWF_ROLE_DETAILS'
	and action_information1 = 'EPSY'
  and action_information2 = 'F';

  cursor epsy_head_count_part_time is
  select COUNT(*)
	from pay_action_information pai,
	      pay_payroll_actions ppa,
	      pay_assignment_actions paa
	where ppa.payroll_action_id = pactid
	and ppa.payroll_action_id = paa.payroll_action_id
	and paa.assignment_action_id = pai.action_context_id
	and pai.action_information_category = 'GB_SWF_ROLE_DETAILS'
	and action_information1 = 'EPSY'
  and action_information2 = 'P';

  cursor epsy_fte_sum_part_time is
  select sum(pai2.action_information7)
	from pay_action_information pai,
       pay_action_information pai2,
	     pay_payroll_actions ppa,
	     pay_assignment_actions paa
	where ppa.payroll_action_id = pactid
	and ppa.payroll_action_id = paa.payroll_action_id
	and paa.assignment_action_id = pai.action_context_id
  and pai.action_context_id = pai2.action_context_id
	and pai.action_information_category = 'GB_SWF_ROLE_DETAILS'
	and pai2.action_information_category = 'GB_SWF_HOURS_DETAILS'
	and pai.action_information1 = 'EPSY'
  and pai.action_information2 = 'P';


begin
    hr_utility.set_location('Entering: '||l_proc,10);
    open param_details;
    fetch param_details into param_details_rec;
    close param_details;

    fnd_file.put_line(fnd_file.output,'Parameter Details:');
    fnd_file.put_line(fnd_file.output,rpad('Census Year',25)||': '||param_details_rec.census_year);
    fnd_file.put_line(fnd_file.output,rpad('Census Day',25)||': '||param_details_rec.census_day);
    fnd_file.put_line(fnd_file.output,rpad('Continuous Start Day',25)||': '||param_details_rec.cont_st_day);
    fnd_file.put_line(fnd_file.output,rpad('Continuous End Day',25)||': '||param_details_rec.cont_end_day);
    fnd_file.put_line(fnd_file.output,rpad('LEA Number',25)||': '||param_details_rec.lea_num);
    fnd_file.put_line(fnd_file.output,rpad('Data Return Type',25)||': '||param_details_rec.data_return_type);
    fnd_file.put_line(fnd_file.output,rpad('Establishment Number',25)||': '||param_details_rec.estb_num);
    fnd_file.put_line(fnd_file.output,rpad('Exclude Absence',25)||': '||param_details_rec.exclude_abs);
    fnd_file.put_line(fnd_file.output,rpad('Exclude Qualification',25)||': '||param_details_rec.exclude_qual);
    fnd_file.put_line(fnd_file.output,rpad('Assignment Set',25)||': '||param_details_rec.asg_set);
    fnd_file.put_line(fnd_file.output,' ');
    fnd_file.put_line(fnd_file.output,' ');


if param_details_rec.data_return_type <> 'TYPE4' then
    fnd_file.put_line(fnd_file.output,rpad('Assignments Processed With Errors :',50));
    fnd_file.put_line(fnd_file.output,' ');
    for asg_rec in csr_asg loop
       fnd_file.put_line(fnd_file.output,rpad('Employee Number',19) ||
                                         rpad('NI Number',11) ||
                                         rpad('Assignment Number',19) ||
                                         rpad('Employee Name', 50));
       fnd_file.put_line(fnd_file.output,rpad('-',18,'-') || ' ' ||
                                         rpad('-',10,'-') || ' ' ||
                                         rpad('-',18,'-') || ' ' ||
                                         rpad('-',50,'-'));
       l_temp := asg_rec.l_name || ', '|| asg_rec.title || ' ' || asg_rec.f_name || ' ' || asg_rec.m_name;
       fnd_file.put_line(fnd_file.output,rpad(asg_rec.emp_no, 18) || ' ' ||
                                         rpad(asg_rec.ni_no ,10) || ' ' ||
                                         rpad(asg_rec.asg_no, 18) || ' ' ||
                                         rpad(l_temp,50));

       l_counter := 1;
         for msg_rec in messages(asg_rec.asg_act_id) loop
              if l_counter = 1 then
                fnd_file.put_line(fnd_file.output,rpad('Error Message(s) :',18));
              end if;
              fnd_file.put_line(fnd_file.output,substr(msg_rec.error_text,1,255));
              l_counter:= l_counter +1;
         end loop;
       fnd_file.put_line(fnd_file.output,' ');
    end loop;

    fnd_file.put_line(fnd_file.output,' ');
    fnd_file.put_line(fnd_file.output,' ');
    fnd_file.put_line(fnd_file.output,rpad('Assignments Processed Without Errors :',50));
    fnd_file.put_line(fnd_file.output,rpad('Employee Number',19) ||
                                      rpad('NI Number',11) ||
                                      rpad('Assignment Number',19) ||
                                      rpad('Employee Name', 50));
    fnd_file.put_line(fnd_file.output,rpad('-',18,'-') || ' ' ||
                                      rpad('-',10,'-') || ' ' ||
                                      rpad('-',18,'-') || ' ' ||
                                      rpad('-',50,'-'));

     for asg_rec in asg_without_errors loop

       l_temp := asg_rec.l_name || ', '|| asg_rec.title || ' ' || asg_rec.f_name || ' ' || asg_rec.m_name;
       fnd_file.put_line(fnd_file.output,rpad(asg_rec.emp_no, 18) || ' ' ||
                                         rpad(asg_rec.ni_no ,10) || ' ' ||
                                         rpad(asg_rec.asg_no, 18) || ' ' ||
                                         rpad(l_temp,50));
     end loop;

     l_counter := 0;
     for fte_hrs_errors in fte_hrs loop
	l_counter := l_counter + 1;
	if l_counter = 1 then
	 fnd_file.put_line(fnd_file.output,' ');
	 fnd_file.put_line(fnd_file.output,'The following person(s) has a total Full Time Equivalent ratio greater than 1.5');
	 	fnd_file.put_line(fnd_file.output,rpad('Employee Number',19) ||
                                      rpad('NI Number',11) ||
                                      rpad('Employee Name', 50));
		fnd_file.put_line(fnd_file.output,rpad('-',18,'-') || ' ' ||
                                      rpad('-',10,'-') || ' ' ||
                                      rpad('-',50,'-'));
	end if;

	 open emp_details(fte_hrs_errors.person_id);
	 fetch emp_details into emp_rec;
		 l_temp := emp_rec.l_name || ', '|| emp_rec.title || ' ' || emp_rec.f_name || ' ' || emp_rec.m_name;
		 fnd_file.put_line(fnd_file.output,rpad(emp_rec.emp_no, 18) || ' ' ||
                                         rpad(emp_rec.ni_no ,10) || ' ' ||
                                         rpad(l_temp,50));
	 close emp_details;

     end loop;

	open hdtr_count;
	fetch hdtr_count into l_hdtr_count;
	close hdtr_count;

	if param_details_rec.data_return_type <>'TYPE3' and l_hdtr_count = 0 then
	  fnd_file.put_line(fnd_file.output,'Atleast one staff record in this school''s return should show a role of Head Teacher');
        end if;
 end if ; --data_return_type <> 'TYPE4'

  if param_details_rec.data_return_type = 'TYPE4'  then
        open epsy_head_count_prm;
        fetch epsy_head_count_prm into l_espf_full_time;
        close epsy_head_count_prm ;

        open epsy_head_count_part_time;
        fetch epsy_head_count_part_time into l_espf_part_time;
        close epsy_head_count_part_time;

        open epsy_fte_sum_part_time;
        fetch epsy_fte_sum_part_time into l_espf_fte;
        close epsy_fte_sum_part_time;

    fnd_file.put_line(fnd_file.output,rpad('Full Time Educational Psychologists Count',60)||': '||l_espf_full_time);
    fnd_file.put_line(fnd_file.output,rpad('Part Time Educational Psychologists Count',60)||': '||l_espf_part_time);
    fnd_file.put_line(fnd_file.output,rpad('Total FTE- part Time Educational Psychologists ',60)||': '||l_espf_fte);


  end if;

    hr_utility.set_location('leaving: '||l_proc,999);
  exception
     when others then
       hr_utility.set_location('Error in deinit: '||sqlerrm||l_proc,999);
end deinit_code;

end pqp_gb_swf_archive;

/
