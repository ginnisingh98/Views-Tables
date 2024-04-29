--------------------------------------------------------
--  DDL for Package Body GHR_DS_JAN99_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_DS_JAN99_PKG" AS
/* $Header: ghdsconv.pkb 120.0.12010000.2 2009/05/26 10:34:23 utokachi noship $ */

PROCEDURE do_conversion(
          p_errbuf out NOCOPY varchar2
         ,p_retcode out NOCOPY number
         ,p_old_location_id    IN     hr_locations.location_id%TYPE
         ,p_new_location_id    IN     hr_locations.location_id%TYPE)
IS


l_old_duty_station_code        ghr_duty_stations_f.duty_station_code%TYPE;
l_new_duty_station_code        ghr_duty_stations_f.duty_station_code%TYPE;
l_old_locality_pay_area_id     ghr_duty_stations_f.locality_pay_area_id%TYPE;
l_new_locality_pay_area_id     ghr_duty_stations_f.locality_pay_area_id%TYPE;
l_duty_station_code            ghr_duty_stations_f.duty_station_code%TYPE;
l_person_id                    per_people_f.person_id%TYPE;
l_effective_start_date         per_assignments_f.effective_start_date%TYPE;
l_full_name                    per_people_f.full_name%TYPE;
l_national_identifier          per_people_f.national_identifier%TYPE;
l_assignment_id                per_assignments_f.assignment_id%TYPE;
l_location_id                  per_assignments_f.location_id%TYPE;
l_position_id                  per_assignments_f.position_id%TYPE;
l_pos_name                     per_positions.name%TYPE;
l_organization_id              per_assignments_f.organization_id%TYPE;
l_effective_date               date;
l_assign_effective_date        date;


l_count                        number := 0;

l_log_text                     varchar2(2000);

l_datetrack_update_mode        varchar2(30);
l_object_version_number        number;
l_special_ceiling_step_id      number;
l_start_date                   date;
l_end_date                     date;
l_people_group_id              number;
l_group_name                   varchar2(2000);
l_org_now_no_manager_warning   boolean;
l_other_manager_warning        boolean;
l_spp_delete_warning           boolean;
l_entries_changed_warning      varchar2(2000);
l_tax_district_changed_warning boolean;

l_position_definition_id       number;
l_name                         varchar2(2000);
l_valid_grades_changed_warning boolean;

l_entered_by                   hr_locations.entered_by%TYPE;
l_location_code                hr_locations.location_code%TYPE;

l_eed                          date;
l_esd                          date;
l_exists                       boolean := false;
l_out_eed                      date;
l_out_esd                      date;

same_loc_err                   exception;
ds422760045                    exception;
old_not_in_opm                 exception;
new_not_in_opm                 exception;
old_new_not_in_opm             exception;
pay_area_id_err                exception;


cursor cur_old_ds is
select b.duty_station_code   old_duty_station_code
from hr_location_extra_info a,
     ghr_duty_stations_f    b
where information_type = 'GHR_US_LOC_INFORMATION'
and   a.lei_information3 = b.duty_station_id
and   b.duty_station_code in
('040355019', '060920071', '181788003', '181789003', '195549095',
 '204891103', '211257115', '211758081', '211758187', '213397003',
 '220376047', '222431059', '240414031', '240931047', '241371003',
 '265260085', '296675179', '330043017', '343478025', '398961099',
 '421172125', '424275109', '424676109', '471348157',
 '484208013', '484209153', '485936303', '511566069', '530171061',
 '530533025', '541475079', '542325035', '542334035', '542857045',
 'UV0000000', 'CF0000000', 'CG0000000', 'PS0000000', 'TC0000000',
 'TC1000000', 'TC1030000', 'TC1040000', 'TC1050000', 'TC1200000',
 'TC1300000', 'TC1500000', 'WS0000000', '422760045')
and   a.location_id = p_old_location_id;

cursor cur_new_ds is
select b.duty_station_code       new_duty_station_code
from hr_location_extra_info a,
     ghr_duty_stations_f    b
where information_type = 'GHR_US_LOC_INFORMATION'
and   a.lei_information3 = b.duty_station_id
and   b.duty_station_code in
('040335019', '062922071', '181850003', '181850003', '195548095', '204840131',
 '211256115', '211757081', '211757187', '210019003', '221920121', '221130059',
 '240411031', '240110047', '241366003', '265260075', '296654179', '330029017',
 '343475025', '399230099', '421170125', '420000109', '420000109', '471338157',
 '480000013', '482400153', '484140303', '511565041', '530170061', '530529025',
 '541474079', '541348035', '541348035', '541541045',
 'UV0000000', 'CF0000000', 'CG0000000', 'PS0000000', 'AE0000000',
 'AE1000000', 'AE1030000', 'AE1040000', 'AE1050000', 'AE1200000',
 'AE1300000', 'AE1500000', 'WS0000000')
and  a.location_id = p_new_location_id;

cursor cur_old_locality_id   is
select nvl(locality_pay_area_id,0) locality_pay_area_id
from   ghr_duty_stations_f
where  duty_station_code = l_old_duty_station_code
and    nvl((l_effective_date - 1),sysdate)
       between effective_start_date and effective_end_date;

cursor cur_new_locality_id   is
select nvl(locality_pay_area_id,0) locality_pay_area_id
from   ghr_duty_stations_f
where  duty_station_code = l_new_duty_station_code
and    nvl(l_effective_date,sysdate)
       between effective_start_date and effective_end_date;

cursor cur_people is
select paf.person_id             person_id,
       paf.effective_start_date  effective_start_date,
       paf.assignment_id         assignment_id,
       paf.object_version_number object_version_number
from   per_assignments_f   paf,
       per_assignment_status_types ast
where  l_effective_date between paf.effective_start_date
                        and     paf.effective_end_date
and    paf.location_id           = p_old_location_id
and    ast.assignment_status_type_id = paf.assignment_status_type_id
and    ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN','TERM_ASSIGN')
union
select paf1.person_id             person_id,
       paf1.effective_start_date  effective_start_date,
       paf1.assignment_id         assignment_id,
       paf1.object_version_number object_version_number
from   per_assignments_f   paf1,
       per_assignment_status_types ast1
where  l_effective_date <= paf1.effective_start_date
and    paf1.location_id           = p_old_location_id
and    ast1.assignment_status_type_id = paf1.assignment_status_type_id
and    ast1.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN','TERM_ASSIGN')
order by 3,2;


 Cursor c_full_name is
   select ppf.full_name
   from   per_people_f ppf
   where  person_id = l_person_id
   and    l_effective_date
   between ppf.effective_start_date and ppf.effective_end_date;

 cursor     c_update_mode_a is
    select   asg.effective_start_date ,
             asg.effective_end_date
    from     per_assignments_f asg
    where    asg.assignment_id = l_assignment_id
    and      l_assign_effective_date
    between  asg.effective_start_date
    and      asg.effective_end_date;

   cursor     c_update_mode_a1 is
    select   asg.effective_start_date ,
             asg.effective_end_date
    from     per_assignments_f asg
    where    asg.assignment_id = l_assignment_id
    and      l_assign_effective_date  <  asg.effective_start_date;

cursor cur_position is
select pos1.position_id           position_id,
       pos1.name                  name,
       pos1.effective_start_date  effective_start_date,
       pos1.object_version_number object_version_number
from   hr_all_positions_f pos1
where  l_effective_date between pos1.effective_start_date
                        and     pos1.effective_end_date
and    pos1.location_id           = p_old_location_id
union
select pos2.position_id           position_id,
       pos2.name                  name,
       pos2.effective_start_date  effective_start_date,
       pos2.object_version_number object_version_number
from   hr_all_positions_f pos2
where  l_effective_date <= pos2.effective_start_date
and    pos2.location_id           = p_old_location_id
order by 1,3;

 cursor     c_pos_update_mode_a is
    select   pos.effective_start_date ,
             pos.effective_end_date
    from     hr_all_positions_f pos
    where    pos.position_id = l_position_id
    and      l_assign_effective_date
    between  pos.effective_start_date
    and      pos.effective_end_date;

   cursor     c_pos_update_mode_a1 is
    select   pos.effective_start_date ,
             pos.effective_end_date
    from     hr_all_positions_f pos
    where    pos.position_id = l_position_id
    and      l_assign_effective_date  <  pos.effective_start_date;

cursor cur_organizations is
select organization_id,name
from   hr_organization_units
where  location_id = p_old_location_id
for update of location_id;

---cursor cur_loc is
---select entered_by,location_code,object_version_number
---from   hr_locations
---where location_id = p_old_location_id
---for update of inactive_date;

BEGIN
    p_retcode  := 0;
    p_errbuf   := NULL;

-- Set the effective_date as
    l_effective_date   := to_date('1999/01/01','YYYY/MM/DD');
    l_old_duty_station_code := null;
    l_new_duty_station_code := null;

    ghr_mto_int.set_log_program_name('GHR_LOC_CONV_PKG');

-- Check Location id are same
    if p_old_location_id = p_new_location_id then raise same_loc_err; end if;

-- Fetch the Location Extra info old duty station code and validate
-- otherwise write in the log.

    for cur_old_ds_rec in cur_old_ds
    loop
     l_old_duty_station_code     := cur_old_ds_rec.old_duty_station_code;
    end loop;

-- Check old location id Extra info duty station is not pertaining to OPM Change
-- otherwise fetched old_location_id is null
    if l_old_duty_station_code is null then raise old_not_in_opm; end if;

-- Check old Location id Extra information is ds422760045
    if l_old_duty_station_code = '422760045' then raise ds422760045; end if;

-- Fetch the Location Extra info new duty station code and validate
-- otherwise write in the log.

    for cur_new_ds_rec in cur_new_ds
    loop
     l_new_duty_station_code     := cur_new_ds_rec.new_duty_station_code;
    end loop;

-- Check new location id Extra info duty station is not pertaining to OPM Change
-- otherwise fetched new_location_id is null
    if l_new_duty_station_code is null then raise new_not_in_opm; end if;

    if l_old_duty_station_code = '040355019' then l_duty_station_code := '040335019'; end if;
    if l_old_duty_station_code = '060920071' then l_duty_station_code := '062922071'; end if;
    if l_old_duty_station_code = '181788003' then l_duty_station_code := '181850003'; end if;
    if l_old_duty_station_code = '181789003' then l_duty_station_code := '181850003'; end if;
    if l_old_duty_station_code = '195549095' then l_duty_station_code := '195548095'; end if;
    if l_old_duty_station_code = '204891103' then l_duty_station_code := '204840131'; end if;
    if l_old_duty_station_code = '211257115' then l_duty_station_code := '211256115'; end if;
    if l_old_duty_station_code = '211758081' then l_duty_station_code := '211757081'; end if;
    if l_old_duty_station_code = '211758187' then l_duty_station_code := '211757187'; end if;
    if l_old_duty_station_code = '213397003' then l_duty_station_code := '210019003'; end if;
    if l_old_duty_station_code = '220376047' then l_duty_station_code := '221920121'; end if;
    if l_old_duty_station_code = '222431059' then l_duty_station_code := '221130059'; end if;
    if l_old_duty_station_code = '240414031' then l_duty_station_code := '240411031'; end if;
    if l_old_duty_station_code = '240931047' then l_duty_station_code := '240110047'; end if;
    if l_old_duty_station_code = '241371003' then l_duty_station_code := '241366003'; end if;
    if l_old_duty_station_code = '265260085' then l_duty_station_code := '265260075'; end if;
    if l_old_duty_station_code = '296675179' then l_duty_station_code := '296654179'; end if;
    if l_old_duty_station_code = '330043017' then l_duty_station_code := '330029017'; end if;
    if l_old_duty_station_code = '343478025' then l_duty_station_code := '343475025'; end if;
    if l_old_duty_station_code = '398961099' then l_duty_station_code := '399230099'; end if;
    if l_old_duty_station_code = '421172125' then l_duty_station_code := '421170125'; end if;
    if l_old_duty_station_code = '424275109' then l_duty_station_code := '420000109'; end if;
    if l_old_duty_station_code = '424676109' then l_duty_station_code := '420000109'; end if;
    if l_old_duty_station_code = '471348157' then l_duty_station_code := '471338157'; end if;
    if l_old_duty_station_code = '484208013' then l_duty_station_code := '480000013'; end if;
    if l_old_duty_station_code = '484209153' then l_duty_station_code := '482400153'; end if;
    if l_old_duty_station_code = '485936303' then l_duty_station_code := '484140303'; end if;
    if l_old_duty_station_code = '511566069' then l_duty_station_code := '511565041'; end if;
    if l_old_duty_station_code = '530171061' then l_duty_station_code := '530170061'; end if;
    if l_old_duty_station_code = '530533025' then l_duty_station_code := '530529025'; end if;
    if l_old_duty_station_code = '541475079' then l_duty_station_code := '541474079'; end if;
    if l_old_duty_station_code = '542325035' then l_duty_station_code := '541348035'; end if;
    if l_old_duty_station_code = '542334035' then l_duty_station_code := '541348035'; end if;
    if l_old_duty_station_code = '542857045' then l_duty_station_code := '541541045'; end if;

    if l_old_duty_station_code = 'UV0000000' then l_duty_station_code := 'UV0000000' ; end if;
    if l_old_duty_station_code = 'CF0000000' then l_duty_station_code := 'CF0000000' ; end if;
    if l_old_duty_station_code = 'CG0000000' then l_duty_station_code := 'CG0000000' ; end if;
    if l_old_duty_station_code = 'PS0000000' then l_duty_station_code := 'PS0000000' ; end if;
    if l_old_duty_station_code = 'TC0000000' then l_duty_station_code := 'AE0000000' ; end if;
    if l_old_duty_station_code = 'TC1000000' then l_duty_station_code := 'AE1000000' ; end if;
    if l_old_duty_station_code = 'TC1030000' then l_duty_station_code := 'AE1030000' ; end if;
    if l_old_duty_station_code = 'TC1040000' then l_duty_station_code := 'AE1040000' ; end if;
    if l_old_duty_station_code = 'TC1050000' then l_duty_station_code := 'AE1050000' ; end if;
    if l_old_duty_station_code = 'TC1200000' then l_duty_station_code := 'AE1200000' ; end if;
    if l_old_duty_station_code = 'TC1300000' then l_duty_station_code := 'AE1300000' ; end if;
    if l_old_duty_station_code = 'TC1500000' then l_duty_station_code := 'AE1500000' ; end if;
    if l_old_duty_station_code = 'WS0000000' then l_duty_station_code := 'WS0000000' ; end if;

-- Check old duty_station and new duty station combination as per OPM
    if l_duty_station_code <> l_new_duty_station_code then
       raise old_new_not_in_opm;  end if;

-- Fetch Locality pay areas id and then compare
    for cur_old_locality_id_rec in cur_old_locality_id
    loop
     l_old_locality_pay_area_id     := cur_old_locality_id_rec.locality_pay_area_id;
    end loop;
    for cur_new_locality_id_rec in cur_new_locality_id
    loop
     l_new_locality_pay_area_id     := cur_new_locality_id_rec.locality_pay_area_id;
    end loop;

    if nvl(l_new_locality_pay_area_id,0) <> nvl(l_old_locality_pay_area_id,0) then
       raise pay_area_id_err; end if;

-- Fetch all the employees and Update the location_id in Assignment, Position,
-- Organization.
  begin
   for cur_people_rec in cur_people
   loop
         l_person_id             := cur_people_rec.person_id;
         l_effective_start_date  := cur_people_rec.effective_start_date;
         l_assignment_id         := cur_people_rec.assignment_id;
         l_object_version_number := cur_people_rec.object_version_number;

      If l_effective_start_date >= l_effective_date then
             -- l_datetrack_update_mode := 'CORRECTION';
              l_assign_effective_date := l_effective_start_date;
      else
        --l_datetrack_update_mode := 'UPDATE';
        l_assign_effective_date := l_effective_date;
      end if;


      for update_mode in c_update_mode_a loop
        l_esd := update_mode.effective_start_date;
        l_eed := update_mode.effective_end_date;
      end loop;
      If l_esd = l_assign_effective_date then
         l_datetrack_update_mode := 'CORRECTION';
      Elsif l_esd < l_assign_effective_date and
            to_char(l_eed,'YYYY/MM/DD') = '4712/12/31' then
         l_datetrack_update_mode := 'UPDATE';
  --  to end date a row and then create a new row
      Elsif  l_esd <  l_assign_effective_date  then
        for update_mode1 in c_update_mode_a1 loop
          l_exists := true;
          exit;
        end loop;
        If l_exists then
          l_datetrack_update_mode := 'UPDATE_CHANGE_INSERT';
          l_exists := false;
        Else
          l_datetrack_update_mode := 'CORRECTION';
        End if;
      End if;
    --End if;
    hr_utility.set_location('UPDATE_MODE  :   ' || l_datetrack_update_mode,2);
      for c_full_name_rec in c_full_name loop
        l_full_name  :=  c_full_name_rec.full_name;
      end loop;
      l_log_text := 'In Assignments - Employee Name : ' || l_full_name || ' : '  ;
      l_log_text := l_log_text || ' Assignment Id : ' || to_char(l_assignment_id)  || ' - ';

     hr_utility.set_location('asg id  ' || l_assignment_id,1);
     hr_utility.set_location('ed      ' || l_effective_date,1);
     hr_utility.set_location('ead      ' || l_assign_effective_date,1);
     hr_utility.set_location('OVN     ' || l_object_version_number,1);

---- Update Assignment - New Location in Date track as of 01-JAN-1999
    ghr_session.set_session_var_for_core
      (p_effective_date   => l_assign_effective_date );
   begin
     hr_assignment_api.update_emp_asg_criteria
       (p_effective_date               => l_assign_effective_date
       ,p_datetrack_update_mode        => l_datetrack_update_mode
       ,p_assignment_id                => l_assignment_id
       ,p_object_version_number        => l_object_version_number
       ,p_location_id                  => p_new_location_id
       ,p_special_ceiling_step_id      => l_special_ceiling_step_id
       ,p_effective_start_date         => l_start_date
       ,p_effective_end_date           => l_end_date
       ,p_people_group_id              => l_people_group_id
       ,p_group_name                   => l_group_name
       ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
       ,p_other_manager_warning        => l_other_manager_warning
       ,p_spp_delete_warning           => l_spp_delete_warning
       ,p_entries_changed_warning      => l_entries_changed_warning
       ,p_tax_district_changed_warning => l_tax_district_changed_warning
        );
    l_count  := l_count  + 1;
    exception when others then
              ghr_mto_int.log_message
               (p_procedure => 'Error in Assignments'
               ,p_message   => l_log_text || ' Sql error : '|| sqlerrm(sqlcode)
               );
    end;
    begin
     ghr_history_api.post_update_process;
    exception when others then
              ghr_mto_int.log_message
               (p_procedure => 'Error in Assignments(History)'
               ,p_message   => l_log_text || ' Sql error : '|| sqlerrm(sqlcode)
               );
    end;
   end loop;

     if l_count <> 0 then
        ghr_mto_int.log_message
         (p_procedure => 'Success Completion Asg'
         ,p_message   => 'All Employees New Location changed in ' || to_char(l_count) || ' Assignments'
          );
     else
        ghr_mto_int.log_message
         (p_procedure => 'Success Completion Asg'
         ,p_message   => 'But No Employees for the given Old Location'
         );
     end if;
  end;

-- Initialize the Counter for positions.
   l_count := 0;
  begin
   for cur_position_rec in cur_position
   loop
       l_pos_name                := cur_position_rec.name;
       l_position_id             := cur_position_rec.position_id;
       l_effective_start_date    := cur_position_rec.effective_start_date;
       l_object_version_number   := cur_position_rec.object_version_number;

       l_log_text := 'In Positions - Position Name  ' || l_pos_name;

-- Update Position - New Location
-----
      If l_effective_start_date >= l_effective_date then
             -- l_datetrack_update_mode := 'CORRECTION';
              l_assign_effective_date := l_effective_start_date;
      else
        --l_datetrack_update_mode := 'UPDATE';
        l_assign_effective_date := l_effective_date;
      end if;


      for pos_update_mode in c_pos_update_mode_a loop
        l_esd := pos_update_mode.effective_start_date;
        l_eed := pos_update_mode.effective_end_date;
      end loop;
      If l_esd = l_assign_effective_date then
         l_datetrack_update_mode := 'CORRECTION';
      Elsif l_esd < l_assign_effective_date and
            to_char(l_eed,'YYYY/MM/DD') = '4712/12/31' then
         l_datetrack_update_mode := 'UPDATE';
  --  to end date a row and then create a new row
      Elsif  l_esd <  l_assign_effective_date  then
        for pos_update_mode1 in c_pos_update_mode_a1 loop
          l_exists := true;
          exit;
        end loop;
        If l_exists then
          l_datetrack_update_mode := 'UPDATE_CHANGE_INSERT';
          l_exists := false;
        Else
          l_datetrack_update_mode := 'CORRECTION';
        End if;
      End if;
    --End if;
    hr_utility.set_location('UPDATE_MODE Position  :   ' || l_datetrack_update_mode,2);
----
     hr_utility.set_location('pos id  ' || l_position_id,1);
     hr_utility.set_location('ed      ' || l_effective_date,1);
     hr_utility.set_location('esd     ' || l_effective_start_date,1);
     hr_utility.set_location('ead      ' || l_assign_effective_date,1);
     hr_utility.set_location('OVN     ' || l_object_version_number,1);

   begin
     ghr_session.set_session_var_for_core
    (p_effective_date   => l_effective_date );

     savepoint hrposupd;

     hr_position_api.update_position
       (p_position_id                  => l_position_id
       ,p_effective_start_date         => l_out_esd
       ,p_effective_end_date           => l_out_eed
       ,p_object_version_number        => l_object_version_number
       ,p_location_id                  => p_new_location_id
       ,p_position_definition_id       => l_position_definition_id
       ,p_name                         => l_name
       ,p_valid_grades_changed_warning => l_valid_grades_changed_warning
       ,p_effective_date               => l_assign_effective_date
       ,p_datetrack_mode               => l_datetrack_update_mode
        );

       ghr_history_api.post_update_process;
       l_count  := l_count  + 1;
   exception when others then
             rollback to hrposupd;
             ghr_mto_int.log_message
              (p_procedure => 'Error in Positions'
              ,p_message   => l_log_text || ' Sql error : '|| sqlerrm(sqlcode)
              );
   end;

   end loop;

   if l_count <> 0 then
      ghr_mto_int.log_message
       (p_procedure => 'Success Completion Pos'
       ,p_message   => 'New Location changed for ' || to_char(l_count) || ' of Positions'
        );
   else
      ghr_mto_int.log_message
       (p_procedure => 'Success Completion Pos'
       ,p_message   => 'But No Positions for the given Old Location'
       );
   end if;
  end;

-- Initialize the Counter for Organizations.
   l_count := 0;
 begin
   for cur_organizations_rec in cur_organizations
   loop
      l_organization_id     := cur_organizations_rec.organization_id;

---- Update Organization - New Location
   update hr_organization_units set location_id = p_new_location_id
   where current of cur_organizations;

   l_count  := l_count  + 1;

   end loop;

   if l_count <> 0 then
      ghr_mto_int.log_message
       (p_procedure => 'Success Completion Org'
       ,p_message   => 'New Location changed for ' || to_char(l_count) || ' of Organizations'
        );
   else
      ghr_mto_int.log_message
       (p_procedure => 'Success Completion  Org'
       ,p_message   => 'But No Organizations for the given Old Location'
       );
   end if;
 end;

--- Commented because do not inactivate the location Bug # 896345
--- begin
---   for cur_loc_rec in cur_loc
---   loop
---       l_entered_by            := cur_loc_rec.entered_by;
---       l_location_code         := cur_loc_rec.location_code;
---       l_object_version_number := cur_loc_rec.object_version_number;
---
---- Update Location as inactive as on 31-DEC-1998
---   update hr_locations set inactive_date = (l_effective_date - 1)
---   where current of cur_loc;
---
---   end loop;
--- end;

 commit;

EXCEPTION
   when same_loc_err then
     l_log_text := 'The New Location chosen is the same as the Old Location. ';
     l_log_text := l_log_text || 'Please verify that the New Location is correct.';
     l_log_text := l_log_text || ' Only OPM mandated changes can be run through the Duty Station Conversion. ';
            ghr_mto_int.log_message
             (p_procedure => 'Same Old and New Location Name'
             ,p_message   => l_log_text
              );
            commit;

   when ds422760045 then
l_log_text := ' An error has occurred while attempting to change Duty Station 422760045,';
l_log_text := l_log_text || ' Fairfield/Delaware/Pennsylvania.  You must complete a Request for ';
l_log_text := l_log_text || 'Personnel action to move all affected employees from this Duty Station ';
l_log_text := l_log_text || 'to a different Duty Station. You may obtain a listing of all employees ';
l_log_text := l_log_text || 'in this Duty Station by running the Location Occupancy Report.';
            ghr_mto_int.log_message
                (p_procedure         => 'DS 422760045'
               ,p_message           => l_log_text
               );
            commit;

   when old_not_in_opm then
   l_log_text := 'The Old Location chosen has an associated Duty Station that is not one of the OPM mandated Duty Stations. ';
   l_log_text := l_log_text || 'Please verify that the Old Location is correct. ';
   l_log_text := l_log_text || 'Only OPM mandated changes can be run through the Duty Station Conversion. ';
            ghr_mto_int.log_message
             (p_procedure => 'Old Location'
             ,p_message   => l_log_text
              );
            commit;

   when new_not_in_opm then
   l_log_text :=   'The New Location chosen has an associated Duty Station that is not one of the OPM mandated Duty Stations. ';
   l_log_text := l_log_text || 'Please verify that the New Location is correct. ';
   l_log_text := l_log_text || 'Only OPM mandated changes can be run through the  Duty Station Conversion. ';
            ghr_mto_int.log_message
             (p_procedure => 'New Location'
             ,p_message   => l_log_text
              );
            commit;

   when old_new_not_in_opm then
            ghr_mto_int.log_message
             (p_procedure => 'Old to New Combination'
             ,p_message   => 'Old Location Duty station is mapped to a wrong New Location Duty Station'
              );
            commit;

   when pay_area_id_err then
l_log_text :=  'This change in Locations results in a Change in Locality Pay Areas. ';
l_log_text := l_log_text || 'Therefore a Request for Personnel Action (RPA) must be completed for each ';
l_log_text := l_log_text || 'employee involved in this move. You may obtain a listing of all employees';
l_log_text := l_log_text || ' in this Location by running the Location Occupancy Report.';
l_log_text := l_log_text || ' Process a NOAC 895 to change the Locality Adjustment and Employee Location. ';
l_log_text := l_log_text || 'Use the Start Date the employee was first assigned to this location';
l_log_text := l_log_text || ', as of the effective date of the RPA. ';

            ghr_mto_int.log_message
               (p_procedure         => 'Locality Adjustment Different'
               ,p_message           => l_log_text
               );
            commit;
   when others then
            rollback;
            ghr_mto_int.log_message
             (p_procedure => 'Conversion Failure'
             ,p_message   => l_log_text || ' Sql error : '|| sqlerrm(sqlcode)
              );
            commit;
 END do_conversion;
END ghr_ds_jan99_pkg;

/
