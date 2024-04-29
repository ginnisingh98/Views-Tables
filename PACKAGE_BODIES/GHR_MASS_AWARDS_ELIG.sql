--------------------------------------------------------
--  DDL for Package Body GHR_MASS_AWARDS_ELIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_MASS_AWARDS_ELIG" as
/* $Header: ghmawelg.pkb 120.1.12010000.3 2008/10/15 10:35:17 utokachi ship $ */

Procedure get_eligible_employees
(p_mass_award_id  in    number  ,
 p_action_type    in    varchar2, -- PREVIEW, FINAL
 p_errbuf         out nocopy  varchar2,
 p_retcode        out nocopy  varchar2,
 p_status         in  out   nocopy varchar2,
 p_maxcheck       out nocopy number
)

--Note : NAF Employees not to be considered for mass awards just like other areas like reports etc.

is

l_cursor_id          number;
l_cursor_kff_id      number;
l_cursor_pos_grp1_id number;
l_cursor_pos_grp2_id number;
l_cursor_pos_grd_id  number;
l_cursor_loc_ddf_id  number;
l_cursor_rating_id   number;
l_business_group_id  number;
l_per_id             number;
l_asg_id             number;
l_pos_id             number;
l_job_id             number;
l_loc_id             number;
l_grd_id             number;
l_sit                ghr_api.special_information_type;
l_asg_select         long;
l_numrows            number;
l_numrows_kff        number;
l_numrows_pos_grp1   number;
l_numrows_pos_grp2   number;
l_numrows_pos_grd    number;
l_numrows_loc_ddf    number;
l_numrows_rating     number;
l_pos_exists         boolean;
l_job_exists         boolean;
l_lei_exists         boolean;
l_rating_exists      boolean;
l_kff_select         long;
l_rating_select      long;
l_pos_grp1_select    long;
l_pos_grp2_select    long;
l_pos_grd_select     long;
l_loc_ddf_select     long;
l_poi_exists         boolean;
l_poc_exists         boolean;
l_ofs_exists         boolean;
l_ors_exists         boolean;
l_pay_plan_exists    boolean;
l_grade_exists       boolean;
l_count              number := 0;
l_pos_ei_data        per_position_extra_info%rowtype;
l_effective_date     date;
l_duty_station_code  ghr_duty_stations_f.duty_station_code%type;
l_errbuf             varchar2(2000);
l_retcode            number;
l_status             varchar2(30);
l_nc_status             varchar2(30); --Added for nocopy changes.
l_old_retcode        number;
l_succ_ctr           number := 0;
l_err_man_ctr        number := 0;
l_err_mass_ctr       number := 0;
l_desel_ctr          number := 0;
l_pos_grade_ei_id    number;

     l_new_line varchar2(1) := substr('
',1,1);

Cursor c_eff_date is
  Select effective_date
  from   ghr_mass_awards
  where  mass_award_id =  p_mass_award_id;

Cursor c_grade_kff(c_grade_id number) is
  select gdf.segment1 pay_plan,
         gdf.segment2 grade_or_level
  from   per_grades  grd,
         per_grade_definitions gdf
  where  grd.grade_id             =  c_grade_id
  and    grd.grade_definition_id  = gdf.grade_definition_id;


Cursor  c_business_group_id is
  Select  ppf.business_group_id
  from    per_people_f ppf
  where   ppf.person_id   =  l_per_id
  and     l_effective_date
  between ppf.effective_start_date
  and     ppf.effective_end_date;


Cursor  c_duty_station_code is
    Select    dsf.duty_station_code
    from      ghr_duty_stations_f dsf
    where     dsf.duty_station_id =
              (select lei.lei_information3
               from   hr_location_extra_info lei
               where  lei.location_id = l_loc_id
              )
    and       l_effective_date
    between   dsf.effective_start_date
    and       dsf.effective_end_date;

--Bug#2459352
     cursor  c_fed_employee(c_position_id IN NUMBER)  is
        select      pos.position_extra_info_id
            from        per_position_extra_info pos
            where       pos.position_id          =  c_position_id
            and         pos.information_type     =  'GHR_US_POS_VALID_GRADE';



  Procedure build_asg_sel
  (p_mass_award_id  in  number,
   p_asg_select      out NOCOPY long) is


  Cursor c_eff_date is
    Select n.code
    from   ghr_mass_awards m,
           ghr_nature_of_actions n
    where  mass_award_id = p_mass_award_id
           and n.nature_of_action_id = m.nature_of_action_id;

   Cursor c_asg_values is
      select     val.relational_operator,
                 val.value
       from      ghr_mass_award_criteria_cols col,
                 ghr_mass_award_criteria_vals val
       Where     col.table_name                  = 'ASSIGNMENT'
       and       col.column_name                 = 'Organization'
       and       val.mass_award_id               =  p_mass_award_id
       and       val.mass_award_criteria_col_id  =  col.mass_award_criteria_col_id
       order by  val.relational_operator;

   l_select          long;
   l_pre             varchar2(50);
   l_suf             varchar2(50);
   l_operator        varchar2(50);
   l_old_operator        varchar2(50);
   l_new_operator        varchar2(50);
   l_asg_exists      boolean := FALSE;
   l_noa_code       NUMBER;


   begin
     l_select     :=      ' Select   asg1.person_id,asg1.assignment_id,asg1.position_id , asg1.location_id,' ||
                          ' asg1.job_id , asg1.grade_id ,  org.name ' ||
                          ' from     per_assignments_f asg1,  ' ||
                          '          hr_organization_units org   ' ||
                          ' where    ' ||   'to_date(' || '''' || l_effective_date || '''' ||
                          ',' || '''' || 'DD-MON-YY' || ''''||  ')' ||
                          ' between  asg1.effective_start_date and  asg1.effective_end_date  ' ||
                          ' and      asg1.organization_id  = org.organization_id   ' ||
                          ' and      asg1.assignment_type =  ' ||
                          '''' || 'E'  || '''' ||
                          ' and      asg1.position_id is not null ' ;
    l_old_operator := null;
     for  asg_values in c_asg_values loop
       l_asg_exists   :=  TRUE;
       l_new_operator := asg_values.relational_operator;
       ghr_mass_awards_elig.derive_rel_operator
       (p_in_rel_operator   =>  asg_values.relational_operator,
        p_out_rel_operator  =>  l_operator,
        p_prefix            =>  l_pre,
        p_suffix            =>  l_suf
        );

    If l_new_operator = 'NOT EQUALS'
     or nvl(l_old_operator,'NOT EQUALS') = 'NOT EQUALS'  then
         If nvl(l_old_operator,'NOT EQUALS') = 'NOT EQUALS' and
            l_new_operator <> 'NOT EQUALS' then
             l_select := l_select || '  and (' ;
           Else
             l_select := l_select || ' and ';
           End if;
       Else
           l_select := l_select || ' or ' ;
      End if;


       l_select :=  l_select ||
                    'upper(org.name)' || ' ' || l_operator ||  '  ' ||
                     'upper('    ||  l_pre || asg_values.value || l_suf ||
                     ')'      ;
       l_old_operator := l_new_operator;

     end loop;
     If l_asg_exists then
         l_Select :=  l_select ||   ')  or 1 = 0 ' ;
       --l_Select :=  l_select ||   ' or 1 = 0 ' ;
     Else
       l_select :=  l_select || ' and 1 = 1 ';
     End if;

    for  i  in c_eff_date loop
      l_noa_code := i.code;
    end loop;

--bug 5482191
   if l_noa_code in ('885','886','887') then

     l_select := l_select ||' and ghr_pa_requests_pkg.get_personnel_system_indicator ('||
                 ' asg1.position_id,'||
	      'to_date(' || '''' || l_effective_date || '''' ||
                          ',' || '''' || 'DD-MON-YY' || ''''||  '))'||
			  '<>'||''''||'00'||'''';


    elsif l_noa_code in ('878','879') then

           l_select := l_select ||' and ghr_pa_requests_pkg.get_personnel_system_indicator ('||
                       ' asg1.position_id,'||
	      'to_date(' || '''' || l_effective_date || '''' ||
                          ',' || '''' || 'DD-MON-YY' || ''''||  '))'||
			  '='||''''||'00'||'''';



    end if;




     p_asg_select := l_select;
   end build_asg_sel;

   Procedure build_pos_job_kff_sel
   (p_mass_award_id  in  number,
    p_kff_select     out nocopy long,
    p_pos_exists     out nocopy boolean,
    p_job_exists     out nocopy boolean
    ) is

   l_select          long;
   l_pre             varchar2(50);
   l_suf             varchar2(50);
   l_operator        varchar2(50);
   l_old_operator        varchar2(50);
   l_table_name      varchar2(30);
   l_pos_kff_exists  boolean := FALSE;
   l_pos_exists      boolean := FALSE;
   l_job_exists      boolean := FALSE;
   l_curr_name       varchar2(50);
   l_old_name        varchar2(50);
   l_col_name        varchar2(150);


   cursor c_pos_kff_values is
     select  val.relational_operator,
             val.value,
             col.table_name,
             col.column_name
     from    ghr_mass_award_criteria_cols   col,
             ghr_mass_award_criteria_vals   val
     Where   val.mass_award_id               =  p_mass_award_id
     and     col.table_name                  = 'POSITION_KFF'
     and     val.mass_award_criteria_col_id  = col.mass_award_criteria_col_id
   union all
     Select  val.relational_operator,
             val.value,
             col.table_name,
             col.column_name
     from    ghr_mass_award_criteria_cols   col,
             ghr_mass_award_criteria_vals   val
     Where   val.mass_award_id               =  p_mass_award_id
     and     col.table_name                  = 'JOB_KFF'
     and     val.mass_award_criteria_col_id  = col.mass_award_criteria_col_id
     order by 3,1 ;



   Begin
       l_select  := 'Select 1 from dual where  ( 1  = 1  ' ;

      for pos_kff_values in c_pos_kff_values loop
  --       l_pos_kff_exists  :=  TRUE;

        ghr_mass_awards_elig.derive_rel_operator
        (p_in_rel_operator   =>  pos_kff_values.relational_operator,
         p_out_rel_operator  =>  l_operator,
         p_prefix            =>  l_pre,
         p_suffix            =>  l_suf
         );

        l_curr_name                 :=  pos_kff_values.column_name;
        l_table_name                :=  pos_kff_values.table_name;
--      l_pos_kff_exists            := true;


      If
        (nvl(l_curr_name,hr_api.g_varchar2)  <> nvl(l_old_name,hr_api.g_varchar2))
       or
        l_operator = ' <> '   or l_old_operator is null or l_old_operator = ' <> ' then
          l_old_name := l_curr_name;
          If l_curr_name =  'Position Title'    then
            l_pos_exists := true;
            l_col_name  :=  'ghr_api.get_position_title_pos';

          Elsif l_curr_name =  'Agency/Subelement Code'  then
            l_pos_exists := true;
            l_col_name  :=  'ghr_api.get_position_agency_code_pos';

         /*Elsif l_curr_name =  'Agency Code' then
             l_pos_exists := true;
             l_col_name := 'substr(ghr_api.get_position_agency_code_pos,1,2)';
         */
          Elsif l_curr_name = 'Occupational Series' then
            l_job_exists := true;
            l_col_name  :=  'ghr_api.get_job_occ_series_job';
          End if;
          If    l_table_name = 'POSITION_KFF' then
            l_pos_exists := true;
            If l_curr_name = 'Agency Code' then
              l_pos_exists := true;
              l_select  :=  l_select || ' ) '  ||  ' and (  '
                                || 'substr(ghr_api.get_position_agency_code_pos('
                                || ':pos_id'
                                || ',' || ':business_group_id'
                                || ',' || ':effective_date'
                                || '),1,2 )'
                                || l_operator || ' ' || l_pre || pos_kff_values.value || l_suf;
            Else

               l_select   :=  l_select  ||  ' ) ' ||  ' and (   '
                                  ||  l_col_name || '(:pos_id'  || ', ' || ':business_group_id' || ',' || ':effective_date' || ' ) '  || ' '
                                  || l_operator ||    ' ' || l_pre || pos_kff_values.value || l_suf;
             End if;


           Elsif l_table_name = 'JOB_KFF' then
             l_job_exists := true;
             l_select   :=  l_select  ||  ' )'   ||  ' and (   '
                                ||  l_col_name || '(:job_id'  || ', ' || ':business_group_id'  || ' ) '  || ' '
                                || l_operator ||    ' ' || l_pre || pos_kff_values.value || l_suf;
           End if;

         Else
           If    l_table_name = 'POSITION_KFF' then
             l_pos_exists := true;
             If l_curr_name = 'Agency Code' then
               l_pos_exists := true;
               l_select :=   l_select || '  or  '
                                 || 'substr(ghr_api.get_position_agency_code_pos('
                                 || ':pos_id'
                                 || ', ' || ':business_group_id'
                                 || ', '
                                 || ' :effective_date' ||'),1,2 )'
                                 || l_operator ||   '  ' || l_pre || pos_kff_values.value || l_suf  ;
             Else
               l_select :=   l_select  || '  or  '
                                 ||  l_col_name || '(:pos_id'   ||  ', ' || ':business_group_id' ||  ',' || ':effective_date' ||  ' ) '   || ' '
                                 || l_operator ||   '  ' || l_pre || pos_kff_values.value || l_suf  ;
             End if;

           Elsif l_table_name = 'JOB_KFF' then
             l_job_exists := true;
             l_select :=   l_select  || '  or  '
                               ||  l_col_name || '(:job_id'   ||  ', ' || ':business_group_id' || ' ) '   || ' '
                               || l_operator ||   '  ' || l_pre || pos_kff_values.value || l_suf  ;
           End if;
         End if;
         l_old_operator := l_operator;
       End loop;
      l_select := l_select || ' ) ';
      l_old_name  := Null;
      l_curr_name := Null;
      p_pos_exists  :=  l_pos_exists;
      p_job_exists  :=  l_job_exists;
      p_kff_select  :=  l_select;
EXCEPTION
  when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params
    p_kff_select    := null;
    p_pos_exists    := null;
    p_job_exists    := null;
    raise;
   End  build_pos_job_kff_sel;


 Procedure build_pos_grp2_sel
   (p_mass_award_id     in  number,
    p_pos_grp2_select   out nocopy long,
    p_poc_exists        out nocopy boolean
   ) is


   l_select  long;
   l_curr_name       varchar2(50);
   l_old_name        varchar2(50);
   l_pre             varchar2(50);
   l_suf             varchar2(50);
   l_operator        varchar2(50);
   l_old_operator        varchar2(50);


   Cursor c_pos_grp2_values is
     Select  val.relational_operator,
             val.value,
             col.column_name
     from    ghr_mass_award_criteria_cols col,
             ghr_mass_award_criteria_vals val
     Where   val.mass_award_id       = p_mass_award_id
     and     col.table_name          = 'POSITION_EXTRA_INFO'
     and     val.mass_award_criteria_col_id  = col.mass_award_criteria_col_id
     and     ( col.column_name = 'Position Occupied'
     )  order by 3,1;

  Begin
    l_select  := 'select 1 from dual where (1 = 1';

    for pos_grp2_rec in c_pos_grp2_values loop

      ghr_mass_awards_elig.derive_rel_operator
        (p_in_rel_operator   =>  pos_grp2_rec.relational_operator,
         p_out_rel_operator  =>  l_operator,
         p_prefix            =>  l_pre,
         p_suffix            =>  l_suf
         );

      l_curr_name       :=  pos_grp2_rec.column_name;
      If
        (nvl(l_curr_name,hr_api.g_varchar2)  <> nvl(l_old_name,hr_api.g_varchar2))
        or l_old_operator is null or l_operator = ' <> ' or l_old_operator = ' <> ' then
        l_old_name := l_curr_name;
        If    l_curr_name  =  'Position Occupied'    then
          p_poc_exists  := TRUE;
          l_select      :=  l_select || ' ) and (' ||
                           ':POC' || l_operator || '   '     || l_pre ||  pos_grp2_rec.value || l_suf ;
        End if;
      Else
        If l_curr_name = 'Position Occupied' then
          p_poc_exists  := TRUE;
          l_select   :=   l_select  || '  or  '   ||
                          ':POC' ||  l_operator || '   '   || l_pre ||  pos_grp2_rec.value || l_suf ;
        End if;
      End if;
      l_old_operator := l_operator;
    End loop;
   l_select     := l_select    || ' ) ';

   p_pos_grp2_select  :=  l_select;
EXCEPTION
  when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params
    p_pos_grp2_select   := null;
    p_poc_exists        := null;
    raise;
  end build_pos_grp2_sel;

 Procedure build_pos_grp1_sel
   (p_mass_award_id     in  number,
    p_pos_grp1_select   out nocopy long,
    p_poi_exists        out nocopy boolean,
    p_ofs_exists       out nocopy boolean,
    p_ors_exists      out nocopy boolean
   ) is


   l_select  long;
   l_curr_name       varchar2(50);
   l_old_name        varchar2(50);
   l_pre             varchar2(50);
   l_suf             varchar2(50);
   l_operator        varchar2(50);
   l_old_operator        varchar2(50);


   Cursor c_pos_grp1_values is
     Select  val.relational_operator,
             val.value,
             col.column_name
     from    ghr_mass_award_criteria_cols col,
             ghr_mass_award_criteria_vals val
     Where   val.mass_award_id       = p_mass_award_id
     and     col.table_name          = 'POSITION_EXTRA_INFO'
     and     val.mass_award_criteria_col_id  = col.mass_award_criteria_col_id
     and     ( col.column_name = 'Personnel Office ID'
     or        col.column_name = 'Office Symbol'
     or        col.column_name = 'Organization Structure ID'
     ) order by 3,1;

  Begin
    l_select  := 'select 1 from dual where (1 = 1';

    for pos_grp1_rec in c_pos_grp1_values loop

      ghr_mass_awards_elig.derive_rel_operator
        (p_in_rel_operator   =>  pos_grp1_rec.relational_operator,
         p_out_rel_operator  =>  l_operator,
         p_prefix            =>  l_pre,
         p_suffix            =>  l_suf
         );
      l_curr_name       :=  pos_grp1_rec.column_name;
      If
       (nvl(l_curr_name,hr_api.g_varchar2)  <> nvl(l_old_name,hr_api.g_varchar2))
        or  nvl(l_old_operator,' <> ' ) = ' <> ' or l_operator = ' <> ' then
        l_old_name := l_curr_name;
        If    l_curr_name  =  'Personnel Office ID'    then
          p_poi_exists  := TRUE;

          l_select      :=  l_select || ' ) and (' ||
                           ':POI' || l_operator || '   '     || l_pre ||  pos_grp1_rec.value || l_suf ;
        Elsif l_curr_name  =  'Office Symbol' then
          p_ofs_exists  := TRUE;
          l_select      :=  l_select || ' ) and (' ||
                           ':OFS' ||   l_operator  || '   '    || l_pre ||  pos_grp1_rec.value || l_suf ;
        Elsif l_curr_name  = 'Organization Structure ID' then
          p_ors_exists  := TRUE;
          l_select      :=  l_select || ' ) and (' ||
                           ':ORS' ||  l_operator || '   '   || l_pre ||  pos_grp1_rec.value || l_suf ;
        End if;
      Else
        If l_curr_name = 'Personnel Office ID' then
          p_poi_exists  := TRUE;
          l_select   :=   l_select  || '  or  '   ||
                          ':POI' ||  l_operator || '   '   || l_pre ||  pos_grp1_rec.value || l_suf ;
        Elsif l_curr_name  =  'Office Symbol' then
          p_ofs_exists  := TRUE;
          l_select      :=  l_select || ' or  ' ||
                           ':OFS' ||  l_operator  || '   '   || l_pre ||  pos_grp1_rec.value || l_suf ;
        Elsif l_curr_name  = 'Organization Structure ID' then
          p_ors_exists  := TRUE;
          l_select      :=  l_select || '  or  ' ||
                           ':ORS' ||  l_operator  || '   '  || l_pre ||  pos_grp1_rec.value || l_suf ;
        End if;
      End if;
     l_old_operator := l_operator;
    End loop;
   l_select     := l_select    || ' ) ';

   p_pos_grp1_select  :=  l_select;

EXCEPTION
  when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params

   p_pos_grp1_select   := null;
    p_poi_exists       := null;
    p_ofs_exists       := null;
    p_ors_exists       := null;
    raise;
 End  build_pos_grp1_sel;

   Procedure build_pos_grd_sel
   (p_mass_award_id    in  number,
    p_pos_grd_select   out nocopy long,
    p_pay_plan_exists  out nocopy boolean,
    p_grade_exists     out nocopy boolean
   ) is


   l_select  long;
   l_curr_name       varchar2(50);
   l_old_name        varchar2(50);
   l_pre             varchar2(50);
   l_suf             varchar2(50);
   l_operator        varchar2(50);
   l_old_operator        varchar2(50);


   Cursor c_pos_grp1_values is
     Select  val.relational_operator,
             val.value,
             col.column_name
     from    ghr_mass_award_criteria_cols col,
             ghr_mass_award_criteria_vals val
     Where   val.mass_award_id       = p_mass_award_id
     and     col.table_name          = 'POSITION_EXTRA_INFO'
     and     val.mass_award_criteria_col_id  = col.mass_award_criteria_col_id
     and     ( col.column_name = 'Pay Plan'
     or        col.column_name = 'Grade Or Level'
     ) order by 3,1;

  Begin
    l_select  := 'select 1 from dual where (1 = 1';

    for pos_grp1_rec in c_pos_grp1_values loop

      ghr_mass_awards_elig.derive_rel_operator
        (p_in_rel_operator   =>  pos_grp1_rec.relational_operator,
         p_out_rel_operator  =>  l_operator,
         p_prefix            =>  l_pre,
         p_suffix            =>  l_suf
         );

      l_curr_name       :=  pos_grp1_rec.column_name;
      l_old_operator    :=  Null;
      If
        (nvl(l_curr_name,hr_api.g_varchar2)  <> nvl(l_old_name,hr_api.g_varchar2))
       or
        l_operator = ' <> ' and nvl(l_old_operator,hr_api.g_varchar2) = ' <> ' then

        l_old_name := l_curr_name;
        If    l_curr_name  =  'Pay Plan'    then
          p_pay_plan_exists  := TRUE;
          l_select      :=  l_select || ' ) and (' ||
                           ':PP' || l_operator || '   '     || l_pre ||  pos_grp1_rec.value || l_suf ;
        Elsif l_curr_name  =  'Grade Or Level' then
          p_grade_exists  := TRUE;
          l_select      :=  l_select || ' ) and (' ||
                           ':GRD' ||   l_operator  || '   '    || l_pre ||  pos_grp1_rec.value || l_suf ;
        End if;
      Else
        If l_curr_name = 'Pay Plan' then
          p_pay_plan_exists  := TRUE;
          l_select   :=   l_select  || '  or  '   ||
                          ':PP' ||  l_operator || '   '   || l_pre ||  pos_grp1_rec.value || l_suf ;
        Elsif l_curr_name  =  'Grade Or Level' then
          p_grade_exists  := TRUE;
          l_select      :=  l_select || ' or  ' ||
                           ':GRD' ||  l_operator  || '   '   || l_pre ||  pos_grp1_rec.value || l_suf ;
        End if;
      End if;
      l_old_operator := l_operator;
    End loop;
   l_select     := l_select    || ' ) ';

   p_pos_grd_select  :=  l_select;
EXCEPTION
  when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params
    p_pos_grd_select   := null;
    p_pay_plan_exists  := null;
    p_grade_exists     := null;
    raise;

  End  build_pos_grd_sel;

  Procedure build_loc_ddf_sel
  (p_mass_award_id   in  number,
   p_loc_ddf_select  out nocopy long,
   p_lei_exists      out nocopy boolean
  )
  is

   l_select          long;
   l_pre             varchar2(50);
   l_suf             varchar2(50);
   l_operator        varchar2(50);
   l_old_operator    varchar2(50);
   l_new_operator    varchar2(50);
   l_lei_exists      boolean;
   l_exists          boolean;



  Cursor  c_loc_ddf_values is
    Select  val.relational_operator,
             val.value,
             col.column_name
     from    ghr_mass_award_criteria_cols col,
             ghr_mass_award_criteria_vals val
     Where   val.mass_award_id       = p_mass_award_id
     and     col.table_name          = 'LOCATION_EXTRA_INFO'
     and     val.mass_award_criteria_col_id  = col.mass_award_criteria_col_id
     order by 3,1;


  Begin
     l_select   :=   'Select 1 from dual  where  1 = 1  ' ;

  l_old_operator := null;
   for  loc_ddf_values in c_loc_ddf_values loop
     l_lei_exists   :=  TRUE;
     l_new_operator := loc_ddf_values.relational_operator;
     ghr_mass_awards_elig.derive_rel_operator
     (p_in_rel_operator   =>  loc_ddf_values.relational_operator,
      p_out_rel_operator  =>  l_operator,
      p_prefix            =>  l_pre,
      p_suffix            =>  l_suf
      );
      If nvl(l_old_operator,'NOT EQUALS') = 'NOT EQUALS' or l_operator = 'NOT EQUALS ' then

           l_select := l_select || ' and  ' ;
      Else
           l_select := l_select || ' or ' ;
      End if;


       l_select :=  l_select ||
                    'upper( ' || ':DSC' || ')' || ' ' || l_operator ||  '  ' ||
                     'upper('    ||  l_pre || loc_ddf_values.value || l_suf ||
                     ')'    ;
       l_old_operator := l_new_operator;
     end loop;

     If l_lei_exists then
       l_Select :=  l_select ||   ' or 1 = 0 ' ;
     Else
       l_select :=  l_select || ' and 1 = 1 ';
     End if;

     p_loc_ddf_select  := l_select;
     p_lei_exists      := l_lei_exists;
EXCEPTION
  when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params
   p_loc_ddf_select  := null;
   p_lei_exists      := null;
    raise;
   end build_loc_ddf_sel;


 Procedure build_rating_sel
  (p_mass_award_id      in  number,
   p_rating_select      out nocopy long,
   p_rating_exists      out nocopy boolean
  )
  is

   l_select          long;
   l_pre             varchar2(50);
   l_suf             varchar2(50);
   l_operator        varchar2(50);
   l_new_operator        varchar2(50);
   l_old_operator        varchar2(50);
   l_rating_exists      boolean;


  Cursor  c_rating_values is
    Select  val.relational_operator,
             val.value,
             col.column_name
     from    ghr_mass_award_criteria_cols col,
             ghr_mass_award_criteria_vals val
     Where   val.mass_award_id       = p_mass_award_id
     and     col.table_name          = 'PERSON_SIT'
     and     val.mass_award_criteria_col_id  = col.mass_award_criteria_col_id
     order by 3,1;



  Begin
     l_select   :=   'Select 1 from dual  where  1 = 1 ' ;

   l_old_operator := null;
   for  rating_values in c_rating_values loop
     l_rating_exists   :=  TRUE;
     l_new_operator   := rating_values.relational_operator;
     ghr_mass_awards_elig.derive_rel_operator
     (p_in_rel_operator   =>  rating_values.relational_operator,
      p_out_rel_operator  =>  l_operator,
      p_prefix            =>  l_pre,
      p_suffix            =>  l_suf
      );
           If nvl(l_old_operator,'NOT EQUALS') = 'NOT EQUALS' or l_operator = 'NOT EQUALS ' then
           l_select := l_select || ' and  ' ;
      Else
           l_select := l_select || ' or ' ;
      End if;

       l_select :=  l_select ||
                    'upper( ' || ':RATING' || ')' || ' ' || l_operator ||  '  ' ||
                     'upper('    ||  l_pre || rating_values.value || l_suf ||
                     ')'     ;
           l_old_operator := l_operator;
     end loop;

     If l_rating_exists then
       l_Select :=  l_select ||   ' or 1 = 0 ' ;
     Else
       l_select :=  l_select || ' and 1 = 1 ';
     End if;

     p_rating_select  := l_select;
     p_rating_exists  := l_rating_exists;
EXCEPTION
  when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params
   p_rating_select      := null;
   p_rating_exists      := null;
    raise;
   end build_rating_sel;


--Build Performance Rating SIT Select

Begin
 l_nc_status := p_status;
  for eff_date in c_eff_date loop
    l_effective_date :=  eff_date.effective_date;
  end loop;

  build_asg_sel(p_mass_award_id   =>  p_mass_award_id,
                p_asg_select       =>  l_asg_select
                );
   build_pos_job_kff_sel(p_mass_award_id  => p_mass_award_id,
                        p_kff_select     => l_kff_select,
                        p_pos_exists     => l_pos_exists,
                        p_job_exists     => l_job_exists
                        );

  build_pos_grp1_sel(p_mass_award_id     => p_mass_award_id,
                     p_pos_grp1_select   => l_pos_grp1_select,
                     p_poi_exists        => l_poi_exists,
                     p_ofs_exists        => l_ofs_exists,
                     p_ors_exists        => l_ors_exists
                     );


  build_pos_grp2_sel(p_mass_award_id     => p_mass_award_id,
                     p_pos_grp2_select   => l_pos_grp2_select,
                     p_poc_exists        => l_poc_exists
                     );

  build_pos_grd_sel(p_mass_award_id     => p_mass_award_id,
                     p_pos_grd_select    => l_pos_grd_select,
                     p_pay_plan_exists   => l_pay_plan_exists,
                     p_grade_exists      => l_grade_exists
                     );

   build_loc_ddf_sel(p_mass_award_id     => p_mass_award_id,
                     p_loc_ddf_select    => l_loc_ddf_select,
                     p_lei_exists        => l_lei_exists
                     );



  build_rating_sel(p_mass_award_id   =>  p_mass_award_id,
                   p_rating_select   =>  l_rating_select,
                   p_rating_exists   =>  l_rating_exists);



  l_cursor_id       := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(l_cursor_id,l_asg_select,DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN(l_cursor_id,1,l_per_id);
  DBMS_SQL.DEFINE_COLUMN(l_cursor_id,2,l_asg_id);
  DBMS_SQL.DEFINE_COLUMN(l_cursor_id,3,l_pos_id);
  DBMS_SQL.DEFINE_COLUMN(l_cursor_id,4,l_loc_id);
  DBMS_SQL.DEFINE_COLUMN(l_cursor_id,5,l_pos_id);
  DBMS_SQL.DEFINE_COLUMN(l_cursor_id,6,l_grd_id);
  l_numrows := DBMS_SQL.EXECUTE(l_cursor_id);

  Loop
   If DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 then
     exit;
   Else
     dbms_sql.column_value(l_cursor_id,1,l_per_id);
     dbms_sql.column_value(l_cursor_id,2,l_asg_id);
     dbms_sql.column_value(l_cursor_id,3,l_pos_id);
     dbms_sql.column_value(l_cursor_id,4,l_loc_id);
     dbms_sql.column_value(l_cursor_id,5,l_job_id);
     dbms_sql.column_value(l_cursor_id,6,l_grd_id);
-- Bug#2459352 Checking whether the employee belongs to federal org or not.

    open c_fed_employee(l_pos_id);
    fetch c_fed_employee into l_pos_grade_ei_id;
    IF c_fed_employee%found then

     l_cursor_kff_id   := DBMS_SQL.OPEN_CURSOR;

     DBMS_SQL.PARSE(l_cursor_kff_id,l_kff_select,DBMS_SQL.NATIVE);
     If l_pos_exists then
        For bus_gp_rec in c_business_group_id loop
          l_business_group_id  :=  bus_gp_rec.business_group_id;
        End loop;

        DBMS_SQL.bind_variable(l_cursor_kff_id,'pos_id',l_pos_id);
        DBMS_SQL.bind_variable(l_cursor_kff_id,'business_group_id',l_business_group_id);
        DBMS_SQL.bind_variable(l_cursor_kff_id,'effective_date',l_effective_date);
     End if;
     If  l_job_exists then
        For bus_gp_rec in c_business_group_id loop
          l_business_group_id  :=  bus_gp_rec.business_group_id;
        End loop;
        DBMS_SQL.bind_variable(l_cursor_kff_id,'job_id',l_job_id);
        DBMS_SQL.bind_variable(l_cursor_kff_id,'business_group_id',l_business_group_id);
     End if;
     l_numrows_kff := DBMS_SQL.EXECUTE(l_cursor_kff_id);
     Loop
       If DBMS_SQL.FETCH_ROWS(l_cursor_kff_id) = 0 then
          exit;
       Else
         l_cursor_pos_grp1_id  :=  DBMS_SQL.OPEN_CURSOR;
         DBMS_SQL.PARSE(l_cursor_pos_grp1_id,l_pos_grp1_select,DBMS_SQL.NATIVE);

          -- Get POS gRP1 from history
         ghr_history_fetch.fetch_positionei
         (p_position_id      =>  l_pos_id,
          p_information_type => 'GHR_US_POS_GRP1',
          p_date_effective   =>  l_effective_date,
          p_pos_ei_data      =>  l_pos_ei_data
          );
         If l_poi_exists then
           DBMS_SQL.bind_variable(l_cursor_pos_grp1_id,'POI',l_pos_ei_data.poei_information3);
         End if;
         If l_ofs_exists then
           DBMS_SQL.bind_variable(l_cursor_pos_grp1_id,'OFS',l_pos_ei_data.poei_information4);
         End if;
         If l_ors_exists then
           DBMS_SQL.bind_variable(l_cursor_pos_grp1_id,'ORS',l_pos_ei_data.poei_information5);
         End if;
         l_pos_ei_data := Null;
         l_numrows_pos_grp1 := DBMS_SQL.EXECUTE(l_cursor_pos_grp1_id);
          Loop
            If DBMS_SQL.FETCH_ROWS(l_cursor_pos_grp1_id) = 0 then
              exit;
            Else
              l_cursor_pos_grp2_id  :=  DBMS_SQL.OPEN_CURSOR;
              DBMS_SQL.PARSE(l_cursor_pos_grp2_id,l_pos_grp2_select,DBMS_SQL.NATIVE);

          -- Get POS gRP2 from history
         ghr_history_fetch.fetch_positionei
         (p_position_id      =>  l_pos_id,
          p_information_type => 'GHR_US_POS_GRP2',
          p_date_effective   =>  l_effective_date,
          p_pos_ei_data      =>  l_pos_ei_data
          );
         If l_poc_exists then
           DBMS_SQL.bind_variable(l_cursor_pos_grp2_id,'POC',l_pos_ei_data.poei_information3);
         End if;

         --l_pos_ei_data := Null;
         l_numrows_pos_grp2 := DBMS_SQL.EXECUTE(l_cursor_pos_grp2_id);
          Loop
            If DBMS_SQL.FETCH_ROWS(l_cursor_pos_grp2_id) = 0 then
              exit;
            Else

              -- Open cursor
              l_cursor_pos_grd_id  :=  DBMS_SQL.OPEN_CURSOR;
              DBMS_SQL.PARSE(l_cursor_pos_grd_id,l_pos_grd_select,DBMS_SQL.NATIVE);

                 If l_pay_plan_exists or l_grade_exists then

                -- Get POSITION VALID GRADE from history
                 ghr_history_fetch.fetch_positionei
                (p_position_id      =>  l_pos_id,
                 p_information_type => 'GHR_US_POS_VALID_GRADE',
                 p_date_effective   =>  l_effective_date,
                 p_pos_ei_data      =>  l_pos_ei_data
                 );
                If l_pay_plan_exists then
                      DBMS_SQL.bind_variable(l_cursor_pos_grd_id,'PP',hr_api.g_varchar2);
                End if;
                If l_grade_exists then
                      DBMS_SQL.bind_variable(l_cursor_pos_grd_id,'GRD',hr_api.g_varchar2);
                End if;

               If l_pos_ei_data.poei_information3 is not null then
                For grade_kff_rec in c_grade_kff(to_number(l_pos_ei_data.poei_information3))  loop
                  If l_pay_plan_exists then
                    If grade_kff_rec.pay_plan is not null then
                      DBMS_SQL.bind_variable(l_cursor_pos_grd_id,'PP',grade_kff_rec.pay_plan);
                    End if;
                  End if;

                  If l_grade_exists then
                    If grade_kff_rec.grade_or_level is not null then
                      DBMS_SQL.bind_variable(l_cursor_pos_grd_id,'GRD',grade_kff_rec.grade_or_level);
                    End if;
                  End if;

                End loop;

               End if;
              End if;

             l_numrows_pos_grd := DBMS_SQL.EXECUTE(l_cursor_pos_grd_id);
             Loop
               If DBMS_SQL.FETCH_ROWS(l_cursor_pos_grd_id) = 0 then
                  exit;
               Else
                 l_cursor_loc_ddf_id  := DBMS_SQL.OPEN_CURSOR;
                 DBMS_SQL.PARSE(l_cursor_loc_ddf_id,l_loc_ddf_select,DBMS_SQL.NATIVE);
                 If l_lei_exists then
                   for duty_station_code_rec in c_duty_station_code loop
                     l_duty_Station_code  :=   duty_station_code_rec.duty_Station_code;
                   end loop;
                   DBMS_SQL.bind_variable(l_cursor_loc_ddf_id,'DSC',l_duty_station_code);
                 End if;
                 l_numrows_loc_ddf  :=  DBMS_SQL.EXECUTE(l_cursor_loc_ddf_id);
                 Loop
                   If DBMS_SQL.FETCH_ROWS(l_cursor_loc_ddf_id) = 0 then
                     exit;
                   Else
                     l_cursor_rating_id  :=  DBMS_SQL.OPEN_CURSOR;
                     DBMS_SQL.PARSE(l_cursor_rating_id,l_rating_select,DBMS_SQL.NATIVE);
                     If l_rating_exists then
                       --get rating  record
                        ghr_api.return_special_information
                        (p_person_id       =>    l_per_id,
                         p_structure_name  =>    'US Fed Perf Appraisal',
                         p_effective_date  =>    l_effective_date,
                         p_special_info    =>    l_sit
                         );
                       DBMS_SQL.bind_variable(l_cursor_rating_id,'RATING',l_sit.segment2);
                     End if;
                     l_numrows_rating  :=  DBMS_SQL.EXECUTE(l_cursor_rating_id);
                     Loop
                       If DBMS_SQL.FETCH_ROWS(l_cursor_rating_id) = 0 then
                         exit;
                       Else
                         l_count  :=  l_count + 1;


                    -- Call appropriate procedure to Populate RPA/ RPA EI segments.
                         hr_utility.set_location('Eff. date in elig ' || l_effective_date,1);
                         hr_utility.set_location('p_mass_award_id in elig'  || p_mass_award_id,1);

                         ghr_mass_awards_pkg.build_rpa_for_mass_awards
                         (p_mass_award_id    =>    p_mass_award_id,
                          p_action_type      =>    p_action_type,
                          p_rpa_type         =>    'A',
                          p_effective_date   =>    l_effective_date,
                          p_person_id        =>    l_per_id,
                          p_assignment_id    =>    l_asg_id,
                          p_position_id      =>    l_pos_id,
                          p_job_id           =>    l_job_id,
                          p_location_id      =>    l_loc_id,
                          p_grade_id         =>    l_grd_id,
                          p_errbuf           =>    l_errbuf,
                          p_retcode          =>    l_retcode,
                          p_status           =>    l_status,
								  p_maxcheck         =>    p_maxcheck
                         );
                        -- Set counter for success, failure cases.
                        -- only in case where p_action_type = 'FINAL'
                        -- based on value in l_status.
                        -- l_success_ctr
                        -- l_err_man_ctr
                        -- l_err_mass_ctr
                        -- l_desel_ctr

       If l_old_retcode is null then
          l_old_retcode :=  l_retcode;
       End if;
       If l_old_retcode = '1' then
         l_retcode :=  l_old_retcode;
       Else
         l_old_retcode := l_retcode;
       End if;
         hr_utility.set_location('retcode interm  ' || l_retcode,1);
       If p_action_type = 'FINAL' then
         If l_status = 'SUCCESS' or l_status = 'PROCESSED' then
             l_succ_ctr  := l_succ_ctr + 1;
         Elsif l_status = 'MANUAL' or l_status = 'FAILURE'
               or l_status = 'OTHER'  then
             l_err_man_ctr  :=  l_err_man_ctr + 1;
         Elsif l_status  = 'GROUPBOX' then
             l_err_mass_ctr :=  l_err_mass_ctr + 1;
--Bug 4065700 added deselected prg: to the desel counter count.
         Elsif l_status  = 'DESELECTED' OR l_status =  'DESELECTED PRG:'  then
             l_desel_ctr :=  l_desel_ctr + 1;
         End if;
      End if;


                       End if;
                       l_duty_station_code := Null; -- Note : Move with appropriate loop
                     End loop;
                     DBMS_SQL.CLOSE_CURSOR(l_cursor_rating_id);
                   End if;
                 End loop;
                 DBMS_SQL.CLOSE_CURSOR(l_cursor_loc_ddf_id);
                End if;
             End loop;
             DBMS_SQL.CLOSE_CURSOR(l_cursor_pos_grd_id);
           End if;
           End loop;
           DBMS_SQL.CLOSE_CURSOR(l_cursor_pos_grp2_id);
           End if;
         End loop;
         DBMS_SQL.CLOSE_CURSOR(l_cursor_pos_grp1_id);
       End if;
     End loop;
     DBMS_SQL.CLOSE_CURSOR(l_cursor_kff_id);
    End If;
    close c_fed_employee;
   End if;
 End loop;
 DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

 /* Still  to do */
-- Set out parameters
--   p_errbuf   := ????
--   p_retcode  := ????
 p_retcode := l_retcode;          ----AVR
 If p_action_type = 'FINAL' then
   /*If ( p_retcode = 0 and l_succ_ctr <> 0 ) then
      p_errbuf :=  'Final Process executed successfully for all  ' ||
                   l_succ_ctr ||  'Employees' ;
    Else
    */ -- Commented this for the bug #4065700. No need of a special message when all employees executed successfully.
      p_errbuf  := ' '                                         || l_new_line ||
          'Final Process completed   '                         || l_new_line ||
          'Successful  : ' || to_char(l_succ_ctr)     || '  '  || l_new_line ||
          'Deselected  : ' || to_char(l_desel_ctr)    || '  '  || l_new_line ||
          'Failure     : ' || to_char(l_err_man_ctr)  || '  '  || l_new_line ||
          'Failure - Retained for Resubmission : '    || to_char(l_err_mass_ctr);
   --End if;
  End if;


 hr_utility.set_location('End of get eligible employees' ,1);
 hr_utility.set_location('retcode   ' || p_retcode,2);
 hr_utility.set_location('errbuf    ' || p_errbuf,3);

 EXCEPTION

	WHEN OTHERS THEN
	-- Reset IN OUT parameters and set OUT parameters
	--Added for NOCOPY CHanges.
		p_errbuf         := NULL;
		p_retcode        := NULL;
		p_status         := l_nc_status;
		p_maxcheck       := NULL;


end  get_eligible_employees;


Procedure derive_rel_operator
(p_in_rel_operator     in varchar2,
 p_out_rel_operator    out nocopy varchar2,
 p_prefix              out nocopy varchar2,
 p_suffix              out nocopy varchar2
) is
Begin
  If p_in_rel_operator = 'CONTAINS' then
    p_out_rel_operator  :=  ' LIKE ';
    p_prefix            :=   '''' || '%' ;
    p_suffix            :=  '%' || '''';

  Elsif p_in_rel_operator = 'BEGINS WITH' then -- STARTS WITH
    p_out_rel_operator  := ' LIKE ';
    p_prefix            :=  '''';
    p_suffix            :=  '%' || '''';

  Elsif p_in_rel_operator = 'ENDS WITH' then
    p_out_rel_operator  := ' LIKE ';
    p_prefix            :=  '''' || '%' ;
    p_suffix            :=  '''';

  Elsif p_in_rel_operator = 'EQUALS' then
    p_out_rel_operator  := ' = ';
    p_prefix            :=  '''' ;
    p_suffix            :=  '''';

  Elsif p_in_rel_operator = 'NOT EQUALS' then
    p_out_rel_operator  := ' <> ';
    p_prefix            :=  '''' ;
    p_suffix            :=  '''';

  Else
    p_out_rel_operator  := ' = ';
    p_prefix            :=  '''' ;
    p_suffix            :=  '''';


  End if;

EXCEPTION

WHEN OTHERS THEN
	p_out_rel_operator    := NULL;
   p_prefix              := NULL;
   p_suffix              := NULL;

End derive_rel_operator;

End ghr_mass_awards_elig;


/
