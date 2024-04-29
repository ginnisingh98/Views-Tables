--------------------------------------------------------
--  DDL for Package Body BEN_EXT_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_PERSON" as
/* $Header: benxpers.pkb 120.38.12010000.6 2010/02/23 10:23:56 vkodedal ship $ */
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
--
g_package              varchar2(33) := '  ben_ext_person.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;

TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_varchar2_30 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_varchar2_600 IS TABLE OF VARCHAR2(600) INDEX BY BINARY_INTEGER;
TYPE t_date  IS TABLE OF date  INDEX BY BINARY_INTEGER;



Procedure get_pay_adv_crit_dates(p_ext_crit_prfl_id   in     number default null,
                                 p_ext_dfn_id         in     number,
                                 p_business_group_id  in     number,
                                 p_effective_date     in     date,
                                 p_eff_from_dt        out nocopy date,
                                 p_eff_to_dt          out nocopy date,
                                 p_act_from_dt        out nocopy date,
                                 p_act_to_dt          out nocopy date,
                                 p_date_mode          out nocopy varchar2
                                 ) is
--
  l_proc               varchar2(72);
  l_eff_from_dt     date;
  l_eff_to_dt       date;
  l_act_from_dt     date;
  l_act_to_dt       date;

 cursor c1 is
 select ecc.crit_typ_cd,
        ecc.oper_cd,
        ecc.val_1,
        ecc.val_2
 from ben_ext_crit_typ ect,
      ben_ext_crit_val ecv,
      ben_ext_crit_cmbn ecc
 where ect.crit_typ_cd = 'ADV'
 and ect.ext_crit_typ_id = ecv.ext_crit_typ_id
 and ect.ext_crit_prfl_id = p_ext_crit_prfl_id
 and ecv.ext_crit_val_id  = ecc.ext_crit_val_id
 and ecc.crit_typ_cd in ('CAD','CED')
 order by 1
 ;

 l_cad_exist  varchar2(1) ;
 l_ced_exist varchar2(1) ;
 l_from_date  date ;
 l_to_date    date ;
 l_date_mode  varchar2(1) ;


--
Begin
  if g_debug then
    l_proc := g_package||'get_pay_adv_crit_dates';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;

  l_cad_exist := 'N' ;
  l_ced_exist := 'N' ;

  for i in  c1
  Loop

     hr_utility.set_location('oper cd '||i.oper_cd, 5);
     hr_utility.set_location('crit_typ_cd cd '||i.crit_typ_cd, 5);

     l_from_date  := ben_ext_util.calc_ext_date
                                        (p_ext_date_cd => i.val_1,
                                         p_abs_date    => p_effective_date,
                                         p_ext_dfn_id => p_ext_dfn_id);
     if i.oper_cd = 'EQ' then
         l_to_date  := l_from_date ;
     else

         l_to_date  := ben_ext_util.calc_ext_date
                             (p_ext_date_cd => i.val_2,
                              p_abs_date    => p_effective_date,
                              p_ext_dfn_id => p_ext_dfn_id);

     End if ;

    if i.crit_typ_cd  = 'CAD' then
       l_cad_exist := 'Y' ;
       -- calc the cad from and to date
       -- get the lowest from date and highetst to date excluding eof and bof
      if l_from_date is not null and l_from_date <> hr_api.g_sot then
         if nvl(l_act_from_dt,hr_api.g_eot) > l_from_date then
            l_act_from_dt := l_from_date ;
         end if ;

      end if ;


      if l_to_date is not null and l_to_date <> hr_api.g_eot then
          if nvl(l_act_to_dt,hr_api.g_sot) < l_to_date then
            l_act_to_dt := l_to_date ;
         end if ;
      end if ;




    else
       l_ced_exist := 'Y' ;
       -- calc the cad from and to date
       -- get the lowest from date and highetst to date excluding eof and bof
       if l_from_date is not null and l_from_date <> hr_api.g_sot then
          if nvl(l_eff_from_dt,hr_api.g_eot) > l_from_date then
             l_eff_from_dt := l_from_date ;
          end if ;

       end if ;


       if l_to_date is not null and l_to_date <> hr_api.g_eot then
           if nvl(l_eff_to_dt,hr_api.g_sot) < l_to_date then
             l_eff_to_dt := l_to_date ;
          end if ;
       end if ;

    End if;

  End Loop ;

  --- if there is not date fix them as bot and eot
  --- if the dates are bot and eot return there is not point in
  --- executing the interpreter twice when one more is bot and eot
  if l_cad_exist = 'Y' then
     if l_act_from_dt is null then
        l_act_from_dt := hr_api.g_sot ;
     end if ;

     if l_act_to_dt is null then
        l_act_to_dt := hr_api.g_eot ;
     end if ;

     if  l_act_from_dt = hr_api.g_sot  and l_act_to_dt = hr_api.g_eot then
         p_act_from_dt := l_act_from_dt;
         p_act_to_dt   := l_act_to_dt  ;
         p_date_mode   := 'C' ;

         hr_utility.set_location('eff_from_dt  '|| p_eff_from_dt  , 15);
         hr_utility.set_location('eff_to_dt  '|| p_eff_to_dt  , 15);
         hr_utility.set_location('Exiting for C eot bot '||l_proc, 15);

         Return ;
     end if ;

     -- when no effective date exit
     if l_ced_exist = 'N'  then

         p_act_from_dt := l_act_from_dt;
         p_act_to_dt   := l_act_to_dt  ;
         p_date_mode   := 'C' ;

         hr_utility.set_location('eff_from_dt  '|| p_eff_from_dt  , 15);
         hr_utility.set_location('eff_to_dt  '|| p_eff_to_dt  , 15);
         hr_utility.set_location('Exiting for C no ced '||l_proc, 15);

         Return ;

     end if ;
  end if ;

  if l_ced_exist = 'Y' then

     if l_eff_from_dt is null then
        l_eff_from_dt := hr_api.g_sot ;
     end if ;

     if l_eff_to_dt is null then
        l_eff_to_dt := hr_api.g_eot ;
     end if ;

     if  l_eff_from_dt = hr_api.g_sot  and l_eff_to_dt = hr_api.g_eot then
         p_eff_from_dt := l_eff_from_dt;
         p_eff_to_dt   := l_eff_to_dt  ;
         p_date_mode   := 'E' ;

         hr_utility.set_location('eff_from_dt  '|| p_eff_from_dt  , 15);
         hr_utility.set_location('eff_to_dt  '|| p_eff_to_dt  , 15);
         hr_utility.set_location('Exiting for E eot bot '||l_proc, 15);

         Return ;
     end if ;

     -- when no actual date exit
     if l_cad_exist = 'N' then

         p_eff_from_dt := l_eff_from_dt;
         p_eff_to_dt   := l_eff_to_dt  ;
         p_date_mode   := 'E' ;

         hr_utility.set_location('eff_from_dt  '|| p_eff_from_dt  , 15);
         hr_utility.set_location('eff_to_dt  '|| p_eff_to_dt  , 15);
         hr_utility.set_location('Exiting for no cad   '||l_proc, 15);

         Return ;

      end if ;

  end if ;


  if l_cad_exist = 'Y' and l_ced_exist = 'Y' then

      p_act_from_dt := l_act_from_dt;
      p_act_to_dt   := l_act_to_dt  ;
      p_eff_from_dt := l_eff_from_dt;
      p_eff_to_dt   := l_eff_to_dt  ;
      p_date_mode   := 'B' ;

  End if ;


  hr_utility.set_location('act_from_dt  '|| p_act_from_dt  , 15);
  hr_utility.set_location('act_to_dt  '|| p_act_to_dt  , 15);
  hr_utility.set_location('eff_from_dt  '|| p_eff_from_dt  , 15);
  hr_utility.set_location('eff_to_dt  '|| p_eff_to_dt  , 15);

  hr_utility.set_location('node '|| p_date_mode , 15);
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;

End get_pay_adv_crit_dates ;

-- ----------------------------------------------------------------------------
-- |------< Check_assg_info >----------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Check_assg_info (p_person_id        in number,
                        p_effective_date   in date ,
                        p_assignment_type  in varchar2 ,
                        p_assignment_id    in out nocopy number ) is
--
  l_proc               varchar2(72);
--
  cursor c_asg is
  select   assignment_id
    from   per_all_assignments_f
    where  person_id = p_person_id
      and  p_effective_date between effective_start_date
                              and effective_end_date
      and  primary_flag = 'Y'
      and  (p_assignment_id is null or p_assignment_id = assignment_id )
      and  assignment_type = nvl(p_assignment_type,assignment_type) -- for any null will be sent
      order by effective_start_date desc ;                         -- for any take the latest



  cursor c_appl_asg is
  select   assignment_id
    from   per_all_assignments_f
    where  person_id = p_person_id
      and  p_effective_date between effective_start_date
                              and effective_end_date
      and  (p_assignment_id is null or p_assignment_id = assignment_id )
      and  assignment_type = nvl(p_assignment_type,assignment_type) -- for any null will be sent
      order by effective_start_date desc ;                         -- for any take the latest



begin
  if g_debug then
    l_proc := g_package||'Check_assg_info';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;

  open c_asg ;
  fetch c_Asg into p_assignment_id ;
  if c_asg%notfound then
     p_assignment_id  := null ;
  end if ;
  close c_Asg ;

  --- if the type is applicant assignement then dont validate the primary key
  ---
  if   p_assignment_id is null and p_assignment_type = 'A' then

       open c_appl_asg ;
       fetch c_appl_Asg into p_assignment_id ;
       if c_appl_asg%notfound then
          p_assignment_id  := null ;
       end if ;
       close c_appl_Asg ;


  end if ;

  if g_debug then
    hr_utility.set_location('assignment_id : ' || p_assignment_id , 99 );
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
end  Check_assg_info;


-- ----------------------------------------------------------------------------
-- |------< init_assignment_id >----------------------------------------------|
-- intialising the ass_id is taken from assignment_info , whether the assignment_info
-- called or not assignment_id is initalised
-- ----------------------------------------------------------------------------
--


Procedure init_assignment_id(p_person_id    in number,
                             p_effective_date in date ,
                             p_assignment_id  in number default null )is

--
  l_proc            varchar2(72);
  l_asg_to_use_cd   varchar2(10) ;
  l_assignment_id   number ;

--
Begin
  if g_debug then
     l_proc := g_package||'init_assignment_id';
     hr_utility.set_location('Entering'||l_proc, 5);
  end if;
  -- p_asg id param added to validate a particular id
  if p_assignment_id is not null then
     l_assignment_id := p_assignment_id ;
  end if ;

  --if the assignment  to use code is not defined then use
  -- empl, benefit,applicant order

  if g_debug then
    hr_utility.set_location('rqd  '|| ben_ext_evaluate_inclusion.g_asg_to_use_rqd, 99 );
  end if;
  if ben_ext_evaluate_inclusion.g_asg_to_use_rqd = 'Y' then
     l_asg_to_use_cd  := ben_ext_evaluate_inclusion.g_asg_to_use_list(1) ;
     if g_debug then
       hr_utility.set_location('order by user  '|| l_asg_to_use_cd, 99 );
     end if;
  end if ;

  if l_asg_to_use_cd is null then
     l_asg_to_use_cd := 'EBAC'  ;    -- hardcoded default
                                     -- Emp/BEN/Appl/Cont
  end if ;
  if g_debug then
    hr_utility.set_location(' ass cd ' ||  l_asg_to_use_cd, 99 );
  end if;

  ----determine the kind of assignment
  if l_asg_to_use_cd = 'EAO' then

        -- Employee assignment only
      Check_assg_info(p_person_id        => p_person_id,
                     p_effective_date   => p_effective_date ,
                     p_assignment_type  => 'E' ,
                     p_assignment_id    => l_assignment_id  ) ;
  elsif l_asg_to_use_cd = 'BAO' then
        -- Employee assignment only
       Check_assg_info(p_person_id        => p_person_id,
                     p_effective_date   => p_effective_date ,
                     p_assignment_type  => 'B' ,
                     p_assignment_id    => l_assignment_id  ) ;
  elsif l_asg_to_use_cd = 'ANY' then
         Check_assg_info(p_person_id => p_person_id,
             p_effective_date      => p_effective_date ,
             p_assignment_type     => null ,
             p_assignment_id       => l_assignment_id  ) ;

  elsif l_asg_to_use_cd = 'AAO' then
        -- Applicant assignment only
       Check_assg_info(p_person_id => p_person_id,
             p_effective_date      => p_effective_date ,
             p_assignment_type     => 'A' ,
             p_assignment_id       => l_assignment_id  ) ;
  elsif l_asg_to_use_cd = 'CAO' then
        -- Contngent assignment only
       Check_assg_info(p_person_id => p_person_id,
             p_effective_date      => p_effective_date ,
             p_assignment_type     => 'C' ,
             p_assignment_id       => l_assignment_id  ) ;
  elsif l_asg_to_use_cd =  'ETB' then
        -- Employee then Benefits assignment only
        Check_assg_info(p_person_id => p_person_id,
             p_effective_date      => p_effective_date ,
             p_assignment_type     => 'E' ,
             p_assignment_id       => l_assignment_id  ) ;
        if l_assignment_id is null then
           Check_assg_info(p_person_id => p_person_id,
             p_effective_date      => p_effective_date ,
             p_assignment_type     => 'B' ,
             p_assignment_id       => l_assignment_id  ) ;
        end if ;
  elsif l_asg_to_use_cd = 'BTE' then
 -- Benefits then Employee assignment only
       Check_assg_info(p_person_id => p_person_id,

            p_effective_date      => p_effective_date ,
             p_assignment_type     => 'B' ,
             p_assignment_id       => l_assignment_id  ) ;
        if l_assignment_id is null then
           Check_assg_info(p_person_id => p_person_id,
             p_effective_date      => p_effective_date ,
             p_assignment_type     => 'E' ,
             p_assignment_id       => l_assignment_id  ) ;
        end if ;

  elsif l_asg_to_use_cd = 'EBA' then
        -- Employee then Benefits then Applicant assignment only
        Check_assg_info(p_person_id => p_person_id,
             p_effective_date      => p_effective_date ,
             p_assignment_type     => 'E' ,
             p_assignment_id       => l_assignment_id  ) ;
        if l_assignment_id is null then
           Check_assg_info(p_person_id => p_person_id,
             p_effective_date      => p_effective_date ,
             p_assignment_type     => 'B' ,
             p_assignment_id       => l_assignment_id  ) ;
           if l_assignment_id is null then
               Check_assg_info(p_person_id => p_person_id,
               p_effective_date      => p_effective_date ,
               p_assignment_type     => 'A' ,
               p_assignment_id       => l_assignment_id  ) ;
           end if ;

        end if ;

   elsif l_asg_to_use_cd = 'EBAC' then
        -- Employee then Benefits then Applicant assignment only
        Check_assg_info(p_person_id => p_person_id,
             p_effective_date      => p_effective_date ,
             p_assignment_type     => 'E' ,
             p_assignment_id       => l_assignment_id  ) ;
        if l_assignment_id is null then
           Check_assg_info(p_person_id => p_person_id,
             p_effective_date      => p_effective_date ,
             p_assignment_type     => 'B' ,
             p_assignment_id       => l_assignment_id  ) ;
           if l_assignment_id is null then
               Check_assg_info(p_person_id => p_person_id,
               p_effective_date      => p_effective_date ,
               p_assignment_type     => 'A' ,
               p_assignment_id       => l_assignment_id  ) ;
               if l_assignment_id is null then
                  Check_assg_info(p_person_id => p_person_id,
                  p_effective_date      => p_effective_date ,
                  p_assignment_type     => 'C' ,
                  p_assignment_id       => l_assignment_id  ) ;
               end if ;
           end if ;


        end if ;


  end if ;
  ---intialise the global assignment_id
  g_assignment_id  := l_assignment_id ;

  if g_debug then
    hr_utility.set_location('assignment_id : ' || g_assignment_id , 99 );
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;

End init_assignment_id ;
--
--

--
-- ----------------------------------------------------------------------------
-- |------< get_person_info >----------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure get_person_info(p_person_id in number,
                          p_effective_date in date) is
--
  l_proc               varchar2(72);
--
cursor c_person_info is
    select
            p.last_name
          , p.date_of_birth
          , p.employee_number
          , p.first_name
          , p.full_name
          , p.marital_status
          , p.middle_names
          , p.national_identifier
          , p.registered_disabled_flag
          , p.sex
          , p.student_status
          , p.suffix
          , p.pre_name_adjunct
          , p.title
          , p.date_of_death
          , p.benefit_group_id
          , p.applicant_number
          , p.correspondence_language
          , p.email_address
          , p.known_as
          , p.mailstop
          , p.nationality
          , p.pre_name_adjunct
          , p.previous_last_name
          , p.original_date_of_hire
          , p.uses_tobacco_flag
          , p.office_number
          , p.date_employee_data_verified
          , p.last_update_date
          , p.last_updated_by
          , p.last_update_login
          , p.created_by
          , p.creation_date
          , p.attribute1
          , p.attribute2
          , p.attribute3
          , p.attribute4
          , p.attribute5
          , p.attribute6
          , p.attribute7
          , p.attribute8
          , p.attribute9
          , p.attribute10
          , p.person_type_id
          ,ppt.user_person_type
          ,p.per_information1
          ,p.per_information2
          ,p.per_information3
          ,p.per_information4
          ,p.per_information5
          ,p.per_information6
          ,p.per_information7
          ,p.per_information8
          ,p.per_information9
          ,p.per_information10
          ,p.per_information11
          ,p.per_information12
          ,p.per_information13
          ,p.per_information14
          ,p.per_information15
          ,p.per_information16
          ,p.per_information17
          ,p.per_information18
          ,p.per_information19
          ,p.per_information20
          ,p.per_information21
          ,p.per_information22
          ,p.per_information23
          ,p.per_information24
          ,p.per_information25
          ,p.per_information26
          ,p.per_information27
          ,p.per_information28
          ,p.per_information29
          ,p.per_information30
          ,p.business_group_id
    from per_all_people_f    p,
         per_person_types  ppt
    where
         p.person_id = p_person_id
     and p_effective_date between p.effective_start_date
                           and p.effective_end_date
     and p.business_group_id = ppt.business_group_id
     and p.person_type_id    = ppt.person_type_id
     ;
--
  cursor bus_c(p_id number)
  is
  select name
  from per_business_groups_perf
  where business_group_id  = p_id
 ;

  l_business_group_id     per_business_groups.business_group_id%type ;
  l_business_group_name   per_business_groups.name%type ;

Begin
--
  if g_debug then
    l_proc := g_package||'get_person_info';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
--
open c_person_info;
fetch c_person_info into
            g_last_name,
            g_date_of_birth,
            g_employee_number,
            g_first_name,
            g_full_name,
            g_marital_status,
            g_middle_names,
            g_national_identifier,
            g_registered_disabled_flag,
            g_sex,
            g_student_status,
            g_suffix,
            g_prefix,
            g_title,
            g_date_of_death,
            g_benefit_group_id,
            g_applicant_number,
            g_correspondence_language,
            g_email_address,
            g_known_as,
            g_mailstop,
            g_nationality,
            g_pre_name_adjunct,
            g_previous_last_name,
            g_original_date_of_hire,
            g_uses_tobacco_flag,
            g_office_number,
            g_data_verification_dt,
            g_last_update_date,
            g_last_updated_by,
            g_last_update_login,
            g_created_by,
            g_creation_date,
            g_per_attr_1,
            g_per_attr_2,
            g_per_attr_3,
            g_per_attr_4,
            g_per_attr_5,
            g_per_attr_6,
            g_per_attr_7,
            g_per_attr_8,
            g_per_attr_9,
            g_per_attr_10,
            g_person_type_id,
            g_person_types,
            g_per_information1,
            g_per_information2,
            g_per_information3,
            g_per_information4,
            g_per_information5,
            g_per_information6,
            g_per_information7,
            g_per_information8,
            g_per_information9,
            g_per_information10,
            g_per_information11,
            g_per_information12,
            g_per_information13,
            g_per_information14,
            g_per_information15,
            g_per_information16,
            g_per_information17,
            g_per_information18,
            g_per_information19,
            g_per_information20,
            g_per_information21,
            g_per_information22,
            g_per_information23,
            g_per_information24,
            g_per_information25,
            g_per_information26,
            g_per_information27,
            g_per_information28,
            g_per_information29,
            g_per_information30,
            l_business_group_id
            ;
      --
      if c_person_info%NOTFOUND THEN
        --
        -- invalid person id !!!
        -- should close cursor and raise error here
        --
        null;
        --
      end if;
      --
      close c_person_info;


      if ben_extract.g_bg_csr = 'Y' then
         open bus_c(l_business_group_id);
         fetch bus_c into l_business_group_name;
         close bus_c;
      end if ;


      if g_ext_global_flag  = 'Y'  then
         ben_ext_person.g_business_group_id := l_business_group_id ;
         ben_extract.g_business_group_name  := l_business_group_name ;
      end if ;
      hr_utility.set_location('Global BG ' || ben_ext_person.g_business_group_id|| ' / ' ||ben_extract.g_proc_business_group_id,99) ;

      ---initalize the assignment_id as soon the person information avaialble
      init_assignment_id(p_person_id    =>p_person_id ,
                      p_effective_date  =>p_effective_date );

    if g_debug then
      hr_utility.set_location('Tobacco Usage '||g_uses_tobacco_flag, 5);
      hr_utility.set_location('Exiting'||l_proc, 15);
    end if;
--
--
end get_person_info;


procedure get_pos_info (p_position_id  in number,
                        p_effective_date in date ) is

--
  l_proc               varchar2(72) := g_package||'get_pos_info';
--
begin
  if g_debug then
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;

   select
            pos.name,
            pos.attribute1,
            pos.attribute2,
            pos.attribute3,
            pos.attribute4,
            pos.attribute5,
            pos.attribute6,
            pos.attribute7,
            pos.attribute8,
            pos.attribute9,
            pos.attribute10
        into
            g_position,
            g_pos_flex_01,
            g_pos_flex_02,
            g_pos_flex_03,
            g_pos_flex_04,
            g_pos_flex_05,
            g_pos_flex_06,
            g_pos_flex_07,
            g_pos_flex_08,
            g_pos_flex_09,
            g_pos_flex_10
         from HR_ALL_POSITIONS_F pos
         where pos.position_id = p_position_id
           and  p_effective_date between pos.EFFECTIVE_START_DATE and pos.EFFECTIVE_END_DATE  ;

  if g_debug then
      hr_utility.set_location('Exiting'||l_proc, 15);
  end if;

end get_pos_info ;


procedure get_job_info (p_job_id  in number,
                        p_effective_date in date ) is

--
  l_proc               varchar2(72) := g_package||'get_job_info';
--
begin
  if g_debug then
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
  select
          j.name,
          j.attribute1,
          j.attribute2,
          j.attribute3,
          j.attribute4,
          j.attribute5,
          j.attribute6,
          j.attribute7,
          j.attribute8,
          j.attribute9,
          j.attribute10
    into
          g_job,
          g_job_flex_01,
          g_job_flex_02,
          g_job_flex_03,
          g_job_flex_04,
          g_job_flex_05,
          g_job_flex_06,
          g_job_flex_07,
          g_job_flex_08,
          g_job_flex_09,
          g_job_flex_10
         from per_jobs_vl j
         where j.job_id = p_job_id;

  if g_debug then
      hr_utility.set_location('Exiting'||l_proc, 15);
  end if;

end get_job_info ;



procedure get_payroll_info (p_payroll_id  in number,
                           p_effective_date in date ) is

--
  l_proc               varchar2(72) := g_package||'get_payroll_info';
--
begin
  if g_debug then
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;

    select
          pay.payroll_name,
          pay.period_type,
          pay.attribute1,
          pay.attribute2,
          pay.attribute3,
          pay.attribute4,
          pay.attribute5,
          pay.attribute6,
          pay.attribute7,
          pay.attribute8,
          pay.attribute9,
          pay.attribute10,
          tmpr.period_num,
          tmpr.start_date,
          tmpr.end_date,
          k.concatenated_segments,
          k.cost_allocation_keyflex_id,
          c.consolidation_set_name,
          c.consolidation_set_id
         into
          g_payroll,
          g_payroll_period_type,
          g_prl_flex_01,
          g_prl_flex_02,
          g_prl_flex_03,
          g_prl_flex_04,
          g_prl_flex_05,
          g_prl_flex_06,
          g_prl_flex_07,
          g_prl_flex_08,
          g_prl_flex_09,
          g_prl_flex_10,
          g_payroll_period_number,
          g_payroll_period_strtdt,
          g_payroll_period_enddt,
          g_payroll_costing,
          g_payroll_costing_id,
          g_payroll_consolidation_set,
          g_payroll_consolidation_set_id
         from  pay_payrolls_f pay,
            per_time_periods            tmpr,
            pay_cost_allocation_keyflex  k,
            pay_consolidation_sets       c
         where pay.payroll_id = p_payroll_id
          and p_effective_date between
            nvl(pay.effective_start_date, p_effective_date)
            and nvl(pay.effective_end_date, p_effective_date)
            and pay.payroll_id = tmpr.payroll_id
            and pay.period_type = tmpr.period_type
            and p_effective_date between nvl(tmpr.start_date, p_effective_date)
            and nvl(tmpr.end_date, p_effective_date)
            and pay.cost_allocation_keyflex_id = k.cost_allocation_keyflex_id (+)
            and pay.consolidation_set_id = c.consolidation_set_id;



  if g_debug then
      hr_utility.set_location('Exiting'||l_proc, 15);
  end if;

end get_payroll_info ;



procedure get_grade_info (p_grade_id  in number,
                        p_effective_date in date ) is

--
  l_proc               varchar2(72) := g_package||'get_grade_info';
--
begin
  if g_debug then
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;


    select
           g.name,
           g.attribute1,
           g.attribute2,
           g.attribute3,
           g.attribute4,
           g.attribute5,
           g.attribute6,
           g.attribute7,
           g.attribute8,
           g.attribute9,
           g.attribute10
        into
           g_employee_grade,
           g_grd_flex_01,
           g_grd_flex_02,
           g_grd_flex_03,
           g_grd_flex_04,
           g_grd_flex_05,
           g_grd_flex_06,
           g_grd_flex_07,
           g_grd_flex_08,
           g_grd_flex_09,
           g_grd_flex_10
        from per_grades_vl g
        where g.grade_id = p_grade_id;

  if g_debug then
      hr_utility.set_location('Exiting'||l_proc, 15);
  end if;

end get_grade_info ;

procedure get_org_loc_info (p_org_id   in number,
                           p_effective_date in date ) is

--
  l_proc               varchar2(72) := g_package||'get_org_loc_info';


  cursor c_org is
  select location_id
   from  hr_all_organization_units
   where organization_id = p_org_id ;

   l_location_id    Hr_locations_all.location_id%Type ;

  cursor c_loc_info (p_location_id number) is
  select l.address_line_1,
         l.address_line_2,
         l.address_line_3,
         l.town_or_city,
         l.country,
         l.postal_code,
         l.region_1,
         l.region_2,
         l.region_3,
         l.Telephone_number_1
   from hr_locations_all  l
   where l.location_id = p_location_id;

--
begin
  if g_debug then
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;

  open c_org ;
  fetch c_org into l_location_id ;
  close c_org ;
  if l_location_id is not null then

        open c_loc_info(l_location_id) ;
        fetch c_loc_info into
              g_org_location_addr1,
              g_org_location_addr2,
              g_org_location_addr3,
              g_org_location_city ,
              g_org_location_country,
              g_org_location_zip,
              g_org_location_region1 ,
              g_org_location_region2,
              g_org_location_region3 ,
              g_org_location_phone;

        close c_loc_info ;
   end if ;
  if g_debug then
      hr_utility.set_location('Exiting'||l_proc, 15);
  end if;

end get_org_loc_info ;







procedure get_loc_info (p_location_id  in number,
                        p_effective_date in date ) is

--
  l_proc               varchar2(72) := g_package||'get_loc_info';
--
begin
  if g_debug then
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;

     select
              l.location_code,
              l.address_line_1,
              l.address_line_2,
              l.address_line_3,
              l.town_or_city,
              l.country,
              l.postal_code,
              l.region_1,
              l.region_2,
              l.region_3,
              l.attribute1,
              l.attribute2,
              l.attribute3,
              l.attribute4,
              l.attribute5,
              l.attribute6,
              l.attribute7,
              l.attribute8,
              l.attribute9,
              l.attribute10
         into
              g_location_code,
              g_location_addr1,
              g_location_addr2,
              g_location_addr3,
              g_location_city ,
              g_location_country,
              g_location_zip,
              g_location_region1 ,
              g_location_region2,
              g_location_region3,
              g_alc_flex_01,
              g_alc_flex_02,
              g_alc_flex_03,
              g_alc_flex_04,
              g_alc_flex_05,
              g_alc_flex_06,
              g_alc_flex_07,
              g_alc_flex_08,
              g_alc_flex_09,
              g_alc_flex_10
         from hr_locations_all  l
         where l.location_id = p_location_id;


  if g_debug then
      hr_utility.set_location('Exiting'||l_proc, 15);
  end if;

end get_loc_info ;


--
--
-- ----------------------------------------------------------------------------
-- |------< get_assignment_info >----------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure get_assignment_info(p_person_id      in number,
                              p_assignment_id  in number,
                              p_effective_date in date  ,
                              p_ext_rslt_id    in number )is

--
  l_proc               varchar2(72) := g_package||'get_assignment_info';
--
cursor c_asg_info (p_assignment_id number ) is
   select
        a.bargaining_unit_code,
        a.grade_id,
        a.organization_id,
        a.location_id,
        a.assignment_status_type_id,
        a.title,
        a.position_id,
        a.job_id,
        a.payroll_id,
        a.people_group_id,
        a.pay_basis_id,
        a.hourly_salaried_code,
        a.labour_union_member_flag,
        a.manager_flag,
        a.employment_category,
        a.last_update_date ,
        a.last_updated_by ,
        a.last_update_login,
        a.created_by ,
        a.creation_date ,
        o.name,
        s.user_status,
        grp.group_name,
        b.name,
        b.attribute1,
        b.attribute2,
        b.attribute3,
        b.attribute4,
        b.attribute5,
        b.attribute6,
        b.attribute7,
        b.attribute8,
        b.attribute9,
        b.attribute10,
        a.ass_attribute1,
        a.ass_attribute2,
        a.ass_attribute3,
        a.ass_attribute4,
        a.ass_attribute5,
        a.ass_attribute6,
        a.ass_attribute7,
        a.ass_attribute8,
        a.ass_attribute9,
        a.ass_attribute10,
        a.normal_hours,
        a.frequency,
        a.time_normal_start,
        a.time_normal_finish,
        a.supervisor_id  ,
        a.assignment_type,
        b.pay_basis
   from per_all_assignments_f       a,
        hr_all_organization_units_vl o,
        per_assignment_status_types s,
        pay_people_groups           grp,
        per_pay_bases               b
   where
      a.person_id = p_person_id
      and p_effective_date between a.effective_start_date
                              and a.effective_end_date
      and a.assignment_id = p_assignment_id
      and a.organization_id = o.organization_id
      and a.assignment_status_type_id = s.assignment_status_type_id
      and a.people_group_id = grp.people_group_id (+)
      and a.pay_basis_id = b.pay_basis_id (+)
      ;

      l_asg_to_use_cd   varchar2(10) ;
      l_assignment_id   number ;
Begin
  --
  if g_debug then
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
  --
  open c_asg_info (p_assignment_id);
  fetch c_asg_info into
                         g_employee_barg_unit,
                         g_employee_grade_id,
                         g_employee_organization_id,
                         g_location_id,
                         g_employee_status_id,
                         g_asg_title,
                         g_position_id,
                         g_job_id,
                         g_payroll_id,
                         g_people_group_id,
                         g_pay_basis_id,
                         g_hourly_salaried_code,
                         g_labour_union_member_flag,
                         g_manager_flag,
                         g_employee_category,
                         g_asg_last_update_date,
                         g_asg_last_updated_by,
                         g_asg_last_update_login,
                         g_asg_created_by,
                         g_asg_creation_date,
                         g_employee_organization,
                         g_employee_status,
                         g_people_group,
                         g_pay_basis,
                         g_pbs_flex_01,
                         g_pbs_flex_02,
                         g_pbs_flex_03,
                         g_pbs_flex_04,
                         g_pbs_flex_05,
                         g_pbs_flex_06,
                         g_pbs_flex_07,
                         g_pbs_flex_08,
                         g_pbs_flex_09,
                         g_pbs_flex_10,
                         g_asg_attr_1,
                         g_asg_attr_2,
                         g_asg_attr_3,
                         g_asg_attr_4,
                         g_asg_attr_5,
                         g_asg_attr_6,
                         g_asg_attr_7,
                         g_asg_attr_8,
                         g_asg_attr_9,
                         g_asg_attr_10,
                         g_asg_normal_hours,
                         g_asg_frequency,
                         g_asg_time_normal_start,
                         g_asg_time_normal_finish,
                         g_asg_supervisor_id,
                         g_asg_type,
                         g_pay_basis_type
                         ;

   close c_asg_info;

   if g_debug then
      hr_utility.set_location('Payroll id '||g_payroll_id, 5);
   end if;

   begin
      if g_employee_grade_id is not null
      then
        if g_debug then
          hr_utility.set_location('asg Grade'||g_employee_grade_id, 5);
        end if;

         get_grade_info (p_grade_id     => g_employee_grade_id,
                       p_effective_date => p_effective_date );

     end if;

     if g_location_id is not null then
         if g_debug then
           hr_utility.set_location('asg Location'||g_location_id , 5);
         end if;
         get_loc_info (p_location_id     => g_location_id,
                       p_effective_date => p_effective_date );

      end if;

      if g_position_id is not null then
         if g_debug then
           hr_utility.set_location('Asg Position'||g_position_id, 5);
         end if;
         get_pos_info (p_position_id     => g_position_id,
                      p_effective_date  => p_effective_date ) ;
      end if;

      if g_job_id is not null then
         if g_debug then
           hr_utility.set_location('Asg Job'||g_job_id, 5);
         end if;
         get_job_info (p_job_id        => g_job_id,
                      p_effective_date => p_effective_date );
      end if;

      if g_payroll_id is not  null then
         if g_debug then
           hr_utility.set_location('asg pay'||g_payroll_id, 5);
         end if;

           get_payroll_info (p_payroll_id        => g_payroll_id,
                             p_effective_date => p_effective_date );
      end if;

      if g_employee_organization_id  is not  null then
         if g_debug then
           hr_utility.set_location('Emp org  '||g_employee_organization_id, 5);
         end if;

           get_org_loc_info (p_org_id         => g_employee_organization_id,
                            p_effective_date => p_effective_date );
      end if;


   Exception
      When NO_DATA_FOUND then
        if g_debug then
          hr_utility.set_location('NO_DATA_FOUND  IN ASG CHILD  ', 5) ;
        end if;
        g_err_num  :=  94102 ;
        g_err_name :=  'BEN_94102_EXT_ERROR_ON_ASG' ;


        Raise ;

   end;
   if g_debug then
     hr_utility.set_location('asg type '|| g_asg_type, 99 );
     hr_utility.set_location('Exiting'||l_proc, 15);
   end if;
--
--
end get_assignment_info;


--
-- ----------------------------------------------------------------------------
-- |------< get_School_info >------------------------------------------|
-- This procedure extract only the current school
-- ----------------------------------------------------------------------------
--
procedure  get_School_info(p_person_id in number  ,
                          p_effective_date in date ) is

--
  l_proc               varchar2(72);
--
  Cursor c_school
  is select
  est.name
  from PER_ESTABLISHMENTS EST ,
       PER_ESTABLISHMENT_ATTENDANCES esa
  where esa.person_id = p_person_id
    and est.ESTABLISHMENT_id = esa.ESTABLISHMENT_id
    and p_effective_date  between attended_start_date and nvl(attended_end_date,p_effective_date);



Begin
 if g_debug then
   l_proc := g_package||'get_School_info';
   hr_utility.set_location('Entering'||l_proc, 15);
 end if;
 open c_school ;
 fetch c_school into g_ESTABLISHMENT_name ;
 if c_school%notfound then
    g_ESTABLISHMENT_name := null ;
 end if ;
 close c_school ;

 if g_debug then
   hr_utility.set_location('Exiting'||l_proc, 15);
 end if;
end get_School_info;


--
-- ----------------------------------------------------------------------------
-- |------< get_base_annual_salary_info_info >------------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure  get_base_annual_salary_info(p_person_id in number  ,
                          p_effective_date in date ) is

--
  l_proc               varchar2(72);
--
  cursor c (l_person_id  number ) is select
     a.pay_annualization_factor,b.proposed_salary_n
     from per_pay_bases a,
          per_pay_proposals b,
          per_all_assignments_f c
      where
          c.person_id = l_person_id   and
          p_effective_date between c.effective_start_date and c.effective_end_date and
          c.assignment_id= g_assignment_id   and
          c.assignment_id = b.assignment_id  and
          c.pay_basis_id  = a.pay_basis_id
          and b.change_date =
          (select max(d.change_date)
             from  per_pay_proposals d
             where  d.assignment_id = c.assignment_id
                and d.change_date <=  p_effective_date
                and approved = 'Y' )
           ;

   lc    c%rowtype ;

begin
    if g_debug then
      l_proc := g_package||'get_base_annual_salary_info_info';
      hr_utility.set_location('Entering'||l_proc, 15);
    end if;

    open c (p_person_id ) ;
    fetch c into lc ;
    close c ;
    g_base_salary :=   lc.pay_annualization_factor * lc.proposed_salary_n ;
    if g_debug then
      hr_utility.set_location(' salary ' || g_base_salary , 936);
      hr_utility.set_location('Exiting'||l_proc, 15);
    end if;
end get_base_annual_salary_info;




--
-- ----------------------------------------------------------------------------
-- ------< get_person_flex_credit>-----------------------------------------
-- ----------------------------------------------------------------------------
--
Procedure  get_person_flex_credit(p_person_id   in number,
                          p_effective_date in date) is
--
  l_proc               varchar2(72);
--
--
  cursor flex_cred_info_c is
  select
        sum(bpl.prvdd_val)     credit_provided
      , sum(bpl.frftd_val)     credit_forfited
      , sum(bpl.used_val)      credit_used
  from ben_prtt_enrt_rslt_f    pen
      ,ben_per_in_ler          pil
      ,ben_bnft_prvdd_ldgr_f   bpl
      ,ben_pl_f                pl
  where
       pen.person_id = p_person_id
    and pen.prtt_enrt_rslt_id = bpl.prtt_enrt_rslt_id
    and p_effective_date between nvl(pen.effective_start_date, p_effective_date)
                             and nvl(pen.effective_end_date, p_effective_date)
    and p_effective_date between nvl(bpl.effective_start_date, p_effective_date)
                                and nvl(bpl.effective_end_date, p_effective_date)
    and pil.per_in_ler_id=bpl.per_in_ler_id
    and pil.business_group_id+0=bpl.business_group_id+0
    and pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
    and pen.pl_id = pl.pl_id
    and pl.invk_flx_cr_pl_flag = 'Y'
    and pl.imptd_incm_calc_cd is null
    and p_effective_date between nvl(pl.effective_start_date, p_effective_date)
                                and nvl(pl.effective_end_date, p_effective_date)
  ;

begin
   if g_debug then
     l_proc := g_package||'get_person_flex_credit';
     hr_utility.set_location('Entering'||l_proc, 15);
   end if;

      -- the fLex cedit calcualted in person level
      if g_debug then
        hr_utility.set_location('entering to open flex credit ' ,160);
      end if;
      open flex_cred_info_c;
      fetch flex_cred_info_c into ben_ext_person.g_flex_credit_provided
           ,ben_ext_person.g_flex_credit_forfited
          ,ben_ext_person.g_flex_credit_used;
      ben_ext_person.g_flex_credit_excess :=
         nvl(ben_ext_person.g_flex_credit_provided,0) -
         nvl(ben_ext_person.g_flex_credit_forfited,0) -
         nvl(ben_ext_person.g_flex_credit_used,0);
      close flex_cred_info_c;
      if g_debug then
        hr_utility.set_location('provided amount '||  ben_ext_person.g_flex_credit_provided ,160);
        hr_utility.set_location('used  amount '||  ben_ext_person.g_flex_credit_used ,160);
        hr_utility.set_location('Exiting'||l_proc, 15);
      end if;

end get_person_flex_credit;





--
-- ----------------------------------------------------------------------------
-- |------<  get_supervisor_info >------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure get_supervisor_info(p_supervisor_id  in number,
                          p_effective_date in date) is
--
  l_proc               varchar2(72);
--
  cursor c_sup_info is
     select
        full_name,
        employee_number
     from per_all_people_f
     where person_id = p_supervisor_id
         and p_effective_date between effective_start_date
         and effective_end_date ;
begin
   if g_debug then
     l_proc := g_package||'get_supervisor_info';
     hr_utility.set_location('Entering'||l_proc, 15);
   end if;

    open c_sup_info ;
    fetch c_sup_info  into
          g_sup_full_name ,
          g_sup_employee_number ;
    close c_sup_info ;

   if g_debug then
     hr_utility.set_location('Exiting'||l_proc, 15);
   end if;
end get_supervisor_info;


--
-- ----------------------------------------------------------------------------
-- |------< get_primary_address_info >------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure get_primary_address_info(p_person_id in number,
                          p_effective_date in date) is
--
  l_proc               varchar2(72);
--
cursor c_prmy_address is
    select
         a.address_line1
       , a.address_line2
       , a.address_line3
       , a.town_or_city
       , a.region_2
       -- if the address style is CA or CA GLB then get the state from region_1
       , decode(a.style ,'CA_GLB',a.region_1,'CA',a.region_1 , a.region_2) state_ansi
       , a.postal_code
       , a.country
       , a.region_1
       , a.region_3
       , a.date_from
       , a.last_update_date
       , a.last_updated_by
       , a.last_update_login
       , a.created_by
       , a.creation_date
    from per_addresses  a
    where
          a.person_id = p_person_id
      and p_effective_date between nvl(a.date_from, p_effective_date)
                              and nvl(a.date_to, p_effective_date)
      and a.primary_flag = 'Y'
      ;

-- related persons primary address
cursor c_rltd_prmy_address is
    select
         a.address_line1
       , a.address_line2
       , a.address_line3
       , a.town_or_city
       , decode(a.style ,'CA_GLB',a.region_1,'CA',a.region_1 , a.region_2) state_ansi
       , a.region_2
       , a.postal_code
       , a.country
       , a.region_1
       , a.region_3
       , a.date_from
    from per_addresses         a,
    per_contact_relationships      c,
    per_all_people_f               p
    where
        c.contact_person_id = p_person_id
    and c.person_id = p.person_id
    and a.person_id = p.person_id
    and a.primary_flag = 'Y'
    and c.rltd_per_rsds_w_dsgntr_flag = 'Y'
    and p_effective_date between nvl(p.effective_start_date, p_effective_date)
                            and nvl(p.effective_end_date, p_effective_date)
    and p_effective_date between nvl(a.date_from, p_effective_date)
                            and nvl(a.date_to, p_effective_date);

--
Begin
--
  if g_debug then
    l_proc := g_package||'get_primary_address_info';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
--
        open c_prmy_address;
        fetch c_prmy_address into
                       g_prim_address_line_1,
                       g_prim_address_line_2,
                       g_prim_address_line_3,
                       g_prim_city,
                       g_prim_state,
                       g_prim_state_ansi,
                       g_prim_postal_code,
                       g_prim_country,
                       g_prim_county,
                       g_prim_region_3,
                       g_prim_address_date,
                       g_addr_last_update_date,
                       g_addr_last_updated_by,
                       g_addr_last_update_login,
                       g_addr_created_by,
                       g_addr_creation_date
                       ;
        --
        if c_prmy_address%notfound then
          --
          -- when address is not found grab one on the related person that resides
          -- with them. This will get addresses for contacts.
          --
          open c_rltd_prmy_address;
         fetch c_rltd_prmy_address into
                       g_prim_address_line_1,
                       g_prim_address_line_2,
                       g_prim_address_line_3,
                       g_prim_city,
                       g_prim_state,
                       g_prim_state_ansi,
                       g_prim_postal_code,
                       g_prim_country,
                       g_prim_county,
                       g_prim_region_3,
                       g_prim_address_date
                       ;
          --
          close c_rltd_prmy_address;
        end if;
        close c_prmy_address;
        --
--
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
--
end get_primary_address_info;
--
-- ----------------------------------------------------------------------------
-- |------< get_mailing_address_info >------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure get_mailing_address_info(p_person_id in number,
                          p_effective_date in date) is
--
  l_proc               varchar2(72);
--
cursor c_mail_address is
    select
         a.address_line1
       , a.address_line2
       , a.address_line3
       , a.town_or_city
       , a.region_2
       , a.postal_code
       , a.country
       , a.region_1
       , a.region_3
       , a.date_from
    from per_addresses  a
    where
          a.person_id = p_person_id
      and p_effective_date between nvl(a.date_from, p_effective_date)
                              and nvl(a.date_to, p_effective_date)
      and a.primary_flag = 'N'
      and a.address_type = 'M'
      ;
--
Begin
--
  if g_debug then
    l_proc := g_package||'get_mailing_address_info';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
--
        open c_mail_address;
        fetch c_mail_address into
                         g_mail_address_line_1,
                         g_mail_address_line_2,
                         g_mail_address_line_3,
                         g_mail_city,
                         g_mail_state,
                         g_mail_postal_code,
                         g_mail_country,
                         g_mail_county,
                         g_mail_region_3,
                         g_mail_address_date
                         ;
        --
        close c_mail_address;
--
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
--
end get_mailing_address_info;
--
-- ----------------------------------------------------------------------------
-- |------< get_comm_address_info >------------------------------------------|
-- ----------------------------------------------------------------------------
--
-- NOTE: See misc/oab/extract/Address hierarchy logic.doc for more info.
--
Procedure get_comm_address_info(p_person_id in number,
                                p_address_id in number,
                                p_effective_date in date) is
--
  l_proc               varchar2(72);
--
cursor c_comm_address is
    select
         a.address_line1
       , a.address_line2
       , a.address_line3
       , a.town_or_city
       , a.region_2
       , a.postal_code
       , a.country
       , a.region_1
       , a.region_3
       , a.date_from
    from per_addresses  a
    where
          a.address_id = p_address_id;
--
    cursor c_prim_rltd_address  is
    select
         a.address_line1
       , a.address_line2
       , a.address_line3
       , a.town_or_city
       , a.region_2
       , a.postal_code
       , a.country
       , a.region_1
       , a.region_3
       , a.date_from
    from per_addresses  a,
         per_contact_relationships r
    where
          r.contact_person_id = p_person_id
      and r.person_id = a.person_id
      and a.town_or_city is not null
      and p_effective_date between nvl(a.date_from, p_effective_date)
                               and nvl(a.date_to, p_effective_date)
      and a.primary_flag = 'Y'
      and r.rltd_per_rsds_w_dsgntr_flag = 'Y'
      ;
   --
Begin
--
  if g_debug then
    l_proc := g_package||'get_comm_address_info';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
--
        --
        IF p_address_id is not null then
          open c_comm_address;
          fetch c_comm_address into
                         g_cm_addr_line1,
                         g_cm_addr_line2,
                         g_cm_addr_line3,
                         g_cm_city,
                         g_cm_state,
                         g_cm_postal_code,
                         g_cm_country,
                         g_cm_county,
                         g_cm_region_3,
                         g_cm_address_date
                         ;
          --
          close c_comm_address;

          --
        END IF;
        --
        -- If communication address was not found use mailing address.
        --
        IF g_cm_city is null and g_mail_city is not null then
          --
          g_cm_addr_line1   := g_mail_address_line_1;
          g_cm_addr_line2   := g_mail_address_line_2;
          g_cm_addr_line3   := g_mail_address_line_3;
          g_cm_city         := g_mail_city;
          g_cm_state        := g_mail_state;
          g_cm_postal_code  := g_mail_postal_code;
          g_cm_country      := g_mail_country;
          g_cm_county       := g_mail_county;
          g_cm_region_3     := g_mail_region_3;
          g_cm_address_date := g_mail_address_date;
        --
        END IF; --g_cm_city is null and g_mail_city is not null then
        --
        -- If communication address is still blank use primary address.
        --
        IF g_cm_city is null and  ( g_prim_city is not null or g_prim_state is not null ) then
          --
          g_cm_addr_line1   := g_prim_address_line_1;
          g_cm_addr_line2   := g_prim_address_line_2;
          g_cm_addr_line3   := g_prim_address_line_3;
          g_cm_city         := g_prim_city;
          g_cm_state        := g_prim_state;
          g_cm_postal_code  := g_prim_postal_code;
          g_cm_country      := g_prim_country;
          g_cm_county       := g_prim_county;
          g_cm_region_3     := g_prim_region_3;
          g_cm_address_date := g_prim_address_date;
        --
        END IF;  --g_cm_city is null and g_prim_city is not null then
--
        If (g_cm_city is null and g_cm_state is null) then
          open c_prim_rltd_address;
          fetch c_prim_rltd_address into
                         g_cm_addr_line1,
                         g_cm_addr_line2,
                         g_cm_addr_line3,
                         g_cm_city,
                         g_cm_state,
                         g_cm_postal_code,
                         g_cm_country,
                         g_cm_county,
                         g_cm_region_3,
                         g_cm_address_date
                         ;
          close c_prim_rltd_address;
          --
       End if;
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
--
end get_comm_address_info;
--
-- ----------------------------------------------------------------------------
-- |------< get_phone_info >----------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure get_phone_info(p_person_id in number,
                          p_effective_date in date) is
--
  l_proc               varchar2(72);
--
cursor c_phone is
   select
          h.phone_number  phone_home
        , w.phone_number  phone_work
        , f.phone_number  phone_fax
        , m.phone_number  phone_mobile
    from  per_all_people_f  p
        , per_phones        h
        , per_phones        w
        , per_phones        f
        , per_phones        m
   where  p.person_id = p_person_id
     and  p_effective_date between nvl(p.effective_start_date, p_effective_date)
                              and nvl(p.effective_end_date, p_effective_date)
     and  h.parent_id (+) = p.person_id
     and  w.parent_id (+) = p.person_id
     and  f.parent_id (+) = p.person_id
     and  m.parent_id (+) = p.person_id
     and  h.parent_table (+) = 'PER_ALL_PEOPLE_F'
     and  w.parent_table (+) = 'PER_ALL_PEOPLE_F'
     and  f.parent_table (+) = 'PER_ALL_PEOPLE_F'
     and  m.parent_table (+) = 'PER_ALL_PEOPLE_F'
     and  h.phone_type (+) = 'H1'
     and  w.phone_type (+) = 'W1'
     and  f.phone_type (+) = 'WF'
     and  m.phone_type (+) = 'M'
     and  p_effective_date between nvl(h.date_from(+), p_effective_date)
                              and nvl(h.date_to(+), p_effective_date)
     and  p_effective_date between nvl(w.date_from(+), p_effective_date)
                              and nvl(w.date_to(+), p_effective_date)
     and  p_effective_date between nvl(f.date_from(+), p_effective_date)
                              and nvl(f.date_to(+), p_effective_date)
     and  p_effective_date between nvl(m.date_from(+), p_effective_date)
                              and nvl(m.date_to(+), p_effective_date)
     ;



  cursor c_rltd_phone is
   select
          h.phone_number  phone_home
        , w.phone_number  phone_work
        , f.phone_number  phone_fax
        , m.phone_number  phone_mobile
    from  per_all_people_f  p
        , per_phones        h
        , per_phones        w
        , per_phones        f
        , per_phones        m
        ,per_contact_relationships r
   where  r.contact_person_id = p_person_id
      and r.rltd_per_rsds_w_dsgntr_flag = 'Y'
      and p.person_id = r.person_id
     and  p_effective_date between nvl(p.effective_start_date, p_effective_date)
                              and nvl(p.effective_end_date, p_effective_date)
     and  h.parent_id (+) = p.person_id
     and  w.parent_id (+) = p.person_id
     and  f.parent_id (+) = p.person_id
     and  m.parent_id (+) = p.person_id
     and  h.parent_table (+) = 'PER_ALL_PEOPLE_F'
     and  w.parent_table (+) = 'PER_ALL_PEOPLE_F'
     and  f.parent_table (+) = 'PER_ALL_PEOPLE_F'
     and  m.parent_table (+) = 'PER_ALL_PEOPLE_F'
     and  h.phone_type (+) = 'H1'
     and  w.phone_type (+) = 'W1'
     and  f.phone_type (+) = 'WF'
     and  m.phone_type (+) = 'M'
     and  p_effective_date between nvl(h.date_from(+), p_effective_date)
                              and nvl(h.date_to(+), p_effective_date)
     and  p_effective_date between nvl(w.date_from(+), p_effective_date)
                              and nvl(w.date_to(+), p_effective_date)
     and  p_effective_date between nvl(f.date_from(+), p_effective_date)
                              and nvl(f.date_to(+), p_effective_date)
     and  p_effective_date between nvl(m.date_from(+), p_effective_date)
                              and nvl(m.date_to(+), p_effective_date)
     ;
--
Begin
--
  if g_debug then
    l_proc := g_package||'get_phone_info';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
--
        open c_phone;
        fetch c_phone into
                       g_phone_home,
                       g_phone_work,
                       g_phone_fax,
                       g_phone_mobile
                       ;
           hr_utility.set_location(' looking phone ' || g_phone_home , 99 );
        if c_phone%notfound or
           (g_phone_home is null and  g_phone_work is null and g_phone_fax is null and g_phone_mobile is null)   then
           hr_utility.set_location(' looking for related phone ' || p_person_id , 99 );
          -- get related person information
          open c_rltd_phone;
          fetch c_rltd_phone into
                       g_phone_home,
                       g_phone_work,
                       g_phone_fax,
                       g_phone_mobile
                       ;
          close c_rltd_phone;
           hr_utility.set_location(' home related phone ' || g_phone_home , 99 );
        end if ;
        --
        close c_phone;
--
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
--
end get_phone_info;
--
-- ----------------------------------------------------------------------------
-- |------< get_period_of_svc_info >-------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure get_period_of_svc_info(p_person_id in number,
                          p_effective_date in date) is
--
  l_proc               varchar2(72);
--
cursor c_period_of_svc is
  select date_start
       , actual_termination_date
       , adjusted_svc_date
       , leaving_reason
       , last_update_date
       , last_updated_by
       , last_update_login
       , created_by
       , creation_date
       , attribute1
       , attribute2
       , attribute3
       , attribute4
       , attribute5
       , attribute6
       , attribute7
       , attribute8
       , attribute9
       , attribute10
   from per_periods_of_service  pps
  where pps.person_id = p_person_id
    and pps.date_start = (select max(pps1.date_start) -- this gets most recent
                            from per_periods_of_service pps1
                           where pps1.person_id = p_person_id
                             and pps1.date_start <= p_effective_date);

--
Begin
--
  if g_debug then
    l_proc := g_package||'get_period_of_svc_info';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
--
 open c_period_of_svc;
      fetch c_period_of_svc into
                        g_last_hire_date,
                        g_actual_term_date,
                        g_adjusted_svc_date,
                        g_term_reason,
                        g_pos_last_update_date,
                        g_pos_last_updated_by,
                        g_pos_last_update_login,
                        g_pos_created_by,
                        g_pos_creation_date,
                        g_prs_flex_01,
                        g_prs_flex_02,
                        g_prs_flex_03,
                        g_prs_flex_04,
                        g_prs_flex_05,
                        g_prs_flex_06,
                        g_prs_flex_07,
                        g_prs_flex_08,
                        g_prs_flex_09,
                        g_prs_flex_10
                        ;
      close c_period_of_svc;
--
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
--
end get_period_of_svc_info;
--
-- ----------------------------------------------------------------------------
-- |------< get_svc_area_info >----------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure get_svc_area_info(p_postal_code in varchar2,
                            p_effective_date in date) is
--
  l_proc               varchar2(72);
--
cursor c_prmy_svc_area is
    select svc.svc_area_id,
           svc.name
    from ben_svc_area_f                 svc
       , ben_svc_area_pstl_zip_rng_f    svps
       , ben_pstl_zip_rng_f             pszip
    where p_postal_code between nvl(pszip.from_value, p_postal_code)
                            and nvl(pszip.to_value, p_postal_code)
    and   pszip.pstl_zip_rng_id = svps.pstl_zip_rng_id
    and   svps.svc_area_id = svc.svc_area_id
    and   p_effective_date between nvl(svps.effective_start_date, p_effective_date)
                              and nvl(svps.effective_end_date, p_effective_date)
    and   p_effective_date between nvl(svc.effective_start_date, p_effective_date)
                              and nvl(svc.effective_end_date, p_effective_date)
    and   p_effective_date between nvl(pszip.effective_start_date, p_effective_date)
                              and nvl(pszip.effective_end_date, p_effective_date);
--
Begin
--
  if g_debug then
    l_proc := g_package||'get_svc_area_info';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
--
        open c_prmy_svc_area;
        fetch c_prmy_svc_area into ben_ext_person.g_prim_addr_sva_id,
                                ben_ext_person.g_prim_addr_service_area;
        close c_prmy_svc_area;
--
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
--
end get_svc_area_info;
--
-- ----------------------------------------------------------------------------
-- |------< get_started_ler_info >----------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure get_started_ler_info(p_person_id in number,
                          p_effective_date in date) is
--
  l_proc               varchar2(72);
--
   cursor c_started_ler is
    select /*+ leading(PLER) */
          pler.per_in_ler_id    per_in_ler_id
          , pler.lf_evt_ocrd_dt     lf_evt_ocrd_dt
          , pler.ntfn_dt        lf_evt_note_dt
          , ler.ler_id              ler_id
          , ler.name                ler_name
          , ler.ler_attribute1
          , ler.ler_attribute2
          , ler.ler_attribute3
          , ler.ler_attribute4
          , ler.ler_attribute5
          , ler.ler_attribute6
          , ler.ler_attribute7
          , ler.ler_attribute8
          , ler.ler_attribute9
          , ler.ler_attribute10
    from
        ben_per_in_ler      pler,
        ben_ler_f           ler
    where
        pler.person_id = p_person_id
        and pler.ler_id = ler.ler_id
        and pler.per_in_ler_stat_cd = 'STRTD'
        and p_effective_date between ler.effective_start_date and ler.effective_end_date
     ;
--
Begin
--
  if g_debug then
    l_proc := g_package||'get_started_ler_info';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
--
      open c_started_ler;
      fetch c_started_ler into
            g_per_in_ler_id,
            g_lf_evt_ocrd_dt,
            g_lf_evt_note_dt,
            g_ler_id,
            g_ler_name,
            g_ler_attr_1,
            g_ler_attr_2,
            g_ler_attr_3,
            g_ler_attr_4,
            g_ler_attr_5,
            g_ler_attr_6,
            g_ler_attr_7,
            g_ler_attr_8,
            g_ler_attr_9,
            g_ler_attr_10;
      close c_started_ler;
--
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
--
end get_started_ler_info;
--
-- ----------------------------------------------------------------------------
-- |------< get_bnfts_group_info >----------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure get_bnfts_group_info(p_benfts_grp_id in number) is
--
  l_proc               varchar2(72);
--
   cursor c_bnfts_group is
   select bgr.name
          , bgr.bng_attribute1
          , bgr.bng_attribute2
          , bgr.bng_attribute3
          , bgr.bng_attribute4
          , bgr.bng_attribute5
          , bgr.bng_attribute6
          , bgr.bng_attribute7
          , bgr.bng_attribute8
          , bgr.bng_attribute9
          , bgr.bng_attribute10
         from ben_benfts_grp    bgr
     where bgr.benfts_grp_id = p_benfts_grp_id;
--
Begin
--
  if g_debug then
    l_proc := g_package||'get_bnfts_group_info';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
--
      open c_bnfts_group;
      fetch c_bnfts_group into
            g_benefit_group,
            g_bng_flex_01,
            g_bng_flex_02,
            g_bng_flex_03,
            g_bng_flex_04,
            g_bng_flex_05,
            g_bng_flex_06,
            g_bng_flex_07,
            g_bng_flex_08,
            g_bng_flex_09,
            g_bng_flex_10;
      close c_bnfts_group;
--
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
--
end get_bnfts_group_info;
--
-- ----------------------------------------------------------------------------
-- |------< get_absence_info >----------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure get_absence_info(p_person_id in number,
                          p_effective_date in date) is
--
  l_proc               varchar2(72);
--
cursor c_absence is
   select  abs.abs_attendance_reason_id
         , abs.absence_attendance_type_id
         , abs.date_start
         , abs.date_end
         , abs.absence_days
         , abs.last_update_date
         , abs.last_updated_by
         , abs.last_update_login
         , abs.created_by
         , abs.creation_date
         , abs.attribute1
         , abs.attribute2
         , abs.attribute3
         , abs.attribute4
         , abs.attribute5
         , abs.attribute6
         , abs.attribute7
         , abs.attribute8
         , abs.attribute9
         , abs.attribute10
         from per_absence_attendances   abs
     where abs.person_id = p_person_id
         and p_effective_date between nvl(abs.date_start,p_effective_date)
         and nvl(abs.date_end, p_effective_date);

CURSOR abs_cat(p_absence_attendance_type_id NUMBER) IS
SELECT  abt.absence_category
,       abt.name abs_type
,       luk.meaning abs_category
FROM    per_absence_attendance_types abt
,       hr_lookups luk
WHERE   abt.absence_attendance_type_id = p_absence_attendance_type_id
AND     abt.absence_category           = luk.lookup_code
AND     luk.lookup_type                = 'ABSENCE_CATEGORY';

--

CURSOR abs_reason(p_abs_attendance_reason_id NUMBER) IS
SELECT lkp.meaning abs_reason ,
       abr.name  			-- Bug 2841958, getting the reason code
FROM   per_abs_attendance_reasons abr
,      hr_lookups lkp
WHERE  abr.abs_attendance_reason_id = p_abs_attendance_reason_id
AND    abr.name                     = lkp.lookup_code
AND    lkp.lookup_type              = 'ABSENCE_REASON';

--
Begin
--
  if g_debug then
    l_proc := g_package||'get_absence_info';
    hr_utility.set_location('Entering'||l_proc, 5);
    hr_utility.set_location('bug 4208'||p_person_id , 4208);
  end if;
--

 open c_absence;
      fetch c_absence into
            g_abs_reason
          , g_abs_type
          , g_abs_start_dt
          , g_abs_end_dt
          , g_abs_duration
          , g_abs_last_update_date
          , g_abs_last_updated_by
          , g_abs_last_update_login
          , g_abs_created_by
          , g_abs_creation_date
          , g_abs_flex_01
          , g_abs_flex_02
          , g_abs_flex_03
          , g_abs_flex_04
          , g_abs_flex_05
          , g_abs_flex_06
          , g_abs_flex_07
          , g_abs_flex_08
          , g_abs_flex_09
          , g_abs_flex_10;
      close c_absence;
--
      open abs_cat(g_abs_type);
      fetch abs_cat into g_abs_category,g_abs_type_name,g_abs_category_name;
      close abs_cat;
--
      open abs_reason(g_abs_reason);
      fetch abs_reason into g_abs_reason_name ,
      			    g_abs_reason_cd; -- Bug 2841958, extra column in cursor
      close abs_reason;
--
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
--
end get_absence_info;
--
-- ----------------------------------------------------------------------------
-- |------< get_cobra_info >----------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure get_cobra_info(p_person_id in number,
                          p_effective_date in date) is
--
  l_proc               varchar2(72);
--
   cursor cbra_info_c is
   select ler.ler_id     event_id,
          ler.name       event_name,
          cqb.cbr_elig_perd_strt_dt  strt_dt,
          cqb.cbr_elig_perd_end_dt   end_dt
          from ben_cbr_quald_bnf cqb,
          ben_cbr_per_in_ler cpl,
          ben_ler_f          ler,
          ben_per_in_ler     pil
   where
          cqb.quald_bnf_person_id = p_person_id
          and quald_bnf_flag = 'Y'
          and p_effective_date between nvl(cqb.cbr_elig_perd_strt_dt,p_effective_date)
              and nvl(cqb.cbr_elig_perd_end_dt,p_effective_date)
          and cqb.cbr_quald_bnf_id = cpl.cbr_quald_bnf_id
          and cpl.per_in_ler_id = pil.per_in_ler_id
          and pil.ler_id = ler.ler_id
          and p_effective_date between nvl(ler.effective_start_date,p_effective_date)
             and nvl(ler.effective_end_date ,p_effective_date)
          and pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
          ;

  cursor c_person_type is
  SELECT  'x'
   FROM   per_person_type_usages_f ptu ,
          per_person_types         ppt
   WHERE  ptu.person_id = p_person_id
     and  ptu.person_type_id = ppt.person_type_id
     and  ppt.system_person_type in ('SRVNG_FMLY_MMBR','SRVNG_SPS')
     AND  p_effective_date between ptu.effective_start_date and
          ptu.effective_end_date;

  l_dummy varchar2(1) ;
--
Begin
--
  if g_debug then
    l_proc := g_package||'get_cobra_info';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
--
       -- get cobra information
      --
      open cbra_info_c;
      fetch cbra_info_c into
            g_cbra_ler_id,
            g_cbra_ler_name,
            g_cbra_strt_dt,
            g_cbra_end_dt;
      if cbra_info_c%found then
            g_bnft_stat_cd := 'C';
      elsif cbra_info_c%notfound then

            g_bnft_stat_cd := 'A';
            ---- check whether the person is surviver of prtt
            open c_person_type ;
            fetch c_person_type into l_dummy  ;
            if c_person_type%found then
               g_bnft_stat_cd := 'S';
            end if ;
            close c_person_type ;

      end if;
      close cbra_info_c;
--
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
--
end get_cobra_info;
--
-- ----------------------------------------------------------------------------
-- |------< get_bnfts_bal_info >----------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure get_bnfts_bal_info(p_person_id in number,
                          p_effective_date in date) is
--
  l_proc               varchar2(72);
--
  cursor c_bnfts_bal (p_bnfts_bal_usg_cd varchar2) is
  select sum(val)
        from  ben_per_bnfts_bal_f   a,
              ben_bnfts_bal_f           b
        where a.person_id = p_person_id
        and   a.bnfts_bal_id = b.bnfts_bal_id
        and   b.bnfts_bal_usg_cd = p_bnfts_bal_usg_cd
        and   p_effective_date between nvl(a.effective_start_date,p_effective_date)
                               and nvl(a.effective_end_date,p_effective_date)
        and   p_effective_date between nvl(b.effective_start_date,p_effective_date)
                               and nvl(b.effective_end_date,p_effective_date );
--
Begin
--
  if g_debug then
    l_proc := g_package||'get_bnfts_bal_info';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
--
    -- Vacation
    --
      IF ben_extract.g_bb4_csr = 'Y' THEN
        open c_bnfts_bal('VAC');
        fetch c_bnfts_bal into
              g_benefit_bal_vacation;
        close c_bnfts_bal;
      END IF;
    --
    -- Sick Leave
    --
      IF ben_extract.g_bb3_csr = 'Y' THEN
        open c_bnfts_bal('SCK');
        fetch c_bnfts_bal into
              g_benefit_bal_sickleave;
        close c_bnfts_bal;
      END IF;
    --
    -- Pension
    --
      IF ben_extract.g_bb2_csr = 'Y' THEN
        open c_bnfts_bal('PENBEN');
        fetch c_bnfts_bal into
              g_benefit_bal_pension;
        close c_bnfts_bal;
      END IF;
    --
    -- Defined Contribution
    --
      IF ben_extract.g_bb1_csr = 'Y' THEN
        open c_bnfts_bal('DCBEN');
        fetch c_bnfts_bal into
              g_benefit_bal_dfncntrbn;
        close c_bnfts_bal;
      END IF;
    --
    -- Wellness
    --
      IF ben_extract.g_bb5_csr = 'Y' THEN
        open c_bnfts_bal('WLNS');
        fetch c_bnfts_bal into
              g_benefit_bal_wellness;
        close c_bnfts_bal;
      END IF;
    --
--
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
--
end get_bnfts_bal_info;

--- this procedure to avoid the duplication for each
--- extract type

Procedure  Extract_person_info(p_person_id          in number,
                               p_effective_date     in date, -- passed in from conc mgr
                               p_business_group_id  in number,
                               p_ext_rslt_id        in number
                            ) IS

   l_proc               varchar2(72);

begin

   g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||' Extract_person_info';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;


   get_person_info (p_person_id => p_person_id,
                    p_effective_date => g_person_ext_dt);
   --
   if g_debug then
     hr_utility.set_location('asg level ' || ben_extract.g_asg_csr,99);
   end if;
   if ben_extract.g_asg_csr = 'Y' then
     get_assignment_info (p_person_id      => p_person_id,
                          p_assignment_id  => g_assignment_id,
                          p_effective_date => g_person_ext_dt,
                          p_ext_rslt_id    => p_ext_rslt_id );
   end if;
   --
   -- get the primary address for communication too
   -- priamry address is used if the cmmunication not avaialable

   if ben_extract.g_addr_csr = 'Y' or ben_extract.g_asa_csr = 'Y' or ben_extract.g_cma_csr = 'Y'  then
     get_primary_address_info (p_person_id => p_person_id,
                               p_effective_date => g_person_ext_dt);
   end if;
   --
   if ben_extract.g_ma_csr = 'Y' then
     get_mailing_address_info (p_person_id => p_person_id,
                               p_effective_date => g_person_ext_dt);
   end if;
   ---
   if ben_extract.g_cma_csr = 'Y' then
       get_comm_address_info(p_person_id => p_person_id,
                             p_address_id => g_cm_address_id,
                             p_effective_date => g_person_ext_dt);
   end if;

   --
   if ben_extract.g_phn_csr = 'Y' then
     get_phone_info (p_person_id => p_person_id,
                     p_effective_date => g_person_ext_dt);
   end if;
   --
   if ben_extract.g_pos_csr = 'Y' then
     get_period_of_svc_info (p_person_id => p_person_id,
                             p_effective_date => g_person_ext_dt);
   end if;
   --
   if ben_extract.g_asa_csr = 'Y' then
     get_svc_area_info (p_postal_code => g_prim_postal_code,
                        p_effective_date => g_person_ext_dt);
   end if;
   --
   if ben_extract.g_ler_csr = 'Y' then
     get_started_ler_info (p_person_id => p_person_id,
                           p_effective_date => g_person_ext_dt);
   end if;
   --
   if ben_extract.g_bgr_csr = 'Y' then
     get_bnfts_group_info (p_benfts_grp_id  => g_benefit_group_id);
   end if;
   --
   if ben_extract.g_abs_csr = 'Y' then
     get_absence_info (p_person_id => p_person_id,
                       p_effective_date => g_person_ext_dt);
   end if;
   --
   if ben_extract.g_cbra_csr = 'Y' then
     get_cobra_info (p_person_id => p_person_id,
                       p_effective_date => g_person_ext_dt);
   end if;
   --
   if ben_extract.g_bb1_csr = 'Y' or ben_extract.g_bb2_csr = 'Y' or ben_extract.g_bb3_csr = 'Y'
     or ben_extract.g_bb4_csr = 'Y' or ben_extract.g_bb5_csr = 'Y' then
     get_bnfts_bal_info (p_person_id => p_person_id,
                         p_effective_date => g_person_ext_dt);
   end if;
   ---

   if ben_extract.g_sup_csr = 'Y' then
      -- supervisor  infor expect supervisor id so if it not intialised
      -- intialise again
      if nvl(ben_extract.g_asg_csr,'N') <> 'Y' then
          get_assignment_info (p_person_id => p_person_id,
                          p_assignment_id  => g_assignment_id,
                          p_effective_date => g_person_ext_dt,
                          p_ext_rslt_id    => p_ext_rslt_id );
      end if;

      get_supervisor_info (p_supervisor_id  => g_asg_supervisor_id ,
                          p_effective_date => g_person_ext_dt);
   end if;
   -- basic salary
   if ben_extract.g_bsl_csr  = 'Y' then
      get_base_annual_salary_info(p_person_id => p_person_id,
                          p_effective_date => g_person_ext_dt);
   end if;
   if ben_extract.g_shl_csr  = 'Y' then
      get_School_info(p_person_id => p_person_id,
                     p_effective_date => g_person_ext_dt);
   end if;

   --person level flex provided and used
   if ben_extract.g_flxcr_csr = 'Y' then
      get_person_flex_credit(p_person_id => p_person_id,
                          p_effective_date => g_person_ext_dt);
   end if ;


   --
 if g_debug then
   hr_utility.set_location('Exiting'||l_proc, 15);
 end if;
 --

End Extract_person_info ;



--
-- ----------------------------------------------------------------------------
-- |------< process_ext_person >----------------------------------------------|
-- ----------------------------------------------------------------------------
-- This procedure will determine the processing route based on the extract
-- definition for a given person.  It will call process_ext_levels to complete
-- all detail records for a given person.  It is an open issue whether or not it
-- needs to evaluate inclusion criteria here for Full Profile (Yes for now).
--
Procedure process_ext_person(
                             p_person_id          in number,
                             p_ext_dfn_id         in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_ext_crit_prfl_id   in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_effective_date     in date, -- passed in from conc mgr
                             p_business_group_id  in number,
                             p_penserv_mode       in varchar2  --vkodedal changes for penserver - 30-apr-2008
                            ) IS
--
  l_proc               varchar2(72);
--
  l_include            varchar2(1);
  l_dummy_start_date   date;
  l_dummy_end_date     date;
  l_chg_actl_strt_dt   date;
  l_chg_actl_end_dt    date;
  l_chg_eff_strt_dt    date;
  l_chg_eff_end_dt     date;
  l_to_be_sent_strt_dt  date;
  l_to_be_sent_end_dt  date;
  l_person_ext_dt date;
  l_benefits_ext_dt date;
--
cursor c_changes_only_extract
     (p_chg_actl_strt_dt in date,
      p_chg_actl_end_dt in date,
      p_chg_eff_strt_dt in date,
      p_chg_eff_end_dt in date)
is
   select   a.ext_chg_evt_log_id
          , a.chg_evt_cd
          , a.chg_eff_dt
          , trunc(a.chg_actl_dt)
          , a.last_update_login
          , a.prmtr_01
          , a.prmtr_02
          , a.prmtr_03
          , a.prmtr_04
          , a.prmtr_05
          , a.prmtr_06
          , a.old_val1
          , a.old_val2
          , a.old_val3
          , a.old_val4
          , a.old_val5
          , a.old_val6
          , a.new_val1
          , a.new_val2
          , a.new_val3
          , a.new_val4
          , a.new_val5
          , a.new_val6
          , 'BEN'  chg_evt_source
     from ben_ext_chg_evt_log  a
    where
      a.person_id = p_person_id
      and trunc(a.chg_actl_dt)  between nvl(p_chg_actl_strt_dt, hr_api.g_sot)
                                 and  nvl(p_chg_actl_end_dt, hr_api.g_eot)
      and a.chg_eff_dt between nvl(p_chg_eff_strt_dt, hr_api.g_sot)
                                 and  nvl(p_chg_eff_end_dt, hr_api.g_eot)
    order by a.chg_eff_dt;



   cursor c_chg_pay_evt is
   select xcv.val_1  event_group_id
   from  ben_ext_crit_typ xct
        ,ben_ext_crit_val xcv
   where xct.ext_crit_prfl_id  =  p_ext_crit_prfl_id
     and xct.ext_crit_typ_id   = xcv.ext_crit_typ_id
     and xct.CRIT_TYP_CD       = 'CPE'
   ;


   l_pay_proration_dates     pay_interpreter_pkg.t_proration_dates_table_type;
   l_pay_proration_changes   pay_interpreter_pkg.t_proration_type_table_type;
   l_pay_detail_tab          pay_interpreter_pkg.t_detailed_output_table_type;
   l_pay_pro_type_tab        pay_interpreter_pkg.t_proration_type_table_type;
   l_dated_table_id          pay_event_updates.dated_table_id%type ;
   l_pay_Assignment_id       number ;

   l_pay_detail_tot_tab      t_detailed_output_table;
   l_pay_tot_Srno           number ;
   l_pay_evt_srno           number ;
   l_g_c_found              varchar2(1) ;
  cursor c_pay_chg_tbl ( p_dated_table_id number) is
  select table_name
  from pay_dated_tables
  where dated_table_id = p_dated_table_id
  ;

--
/*
cursor c_communication_extract
     (p_to_be_sent_strt_dt in date,
      p_to_be_sent_end_dt in date)
   is
   select   e.name
          , e.cm_typ_id
          , e.shrt_name
          , e.pc_kit_cd
          , a.per_cm_id
          , a.per_in_ler_id
          , a.prtt_enrt_actn_id
          , nvl(b.effective_start_date,a.effective_start_date) effective_start_date
          , d.proc_cd
          , b.to_be_sent_dt
          , b.sent_dt
          , a.last_update_date
          , b.last_update_date
          , b.dlvry_instn_txt
          , b.inspn_rqd_flag
          , b.address_id
          , b.per_cm_prvdd_id
          , b.object_version_number
          , b.effective_start_date
          , c.effective_start_date
          , l.ler_id
          , l.name
          , p.per_in_ler_stat_cd
          , nvl(p.lf_evt_ocrd_dt,a.effective_start_date) lf_evt_ocrd_dt
          , nvl(p.ntfn_dt,a.effective_start_date) ntfn_dt
     from ben_per_cm_f          a,
          ben_per_cm_prvdd_f    b,
          ben_per_cm_trgr_f     c,
          ben_cm_trgr           d,
          ben_cm_typ_f          e,
          ben_per_in_ler        p,
          ben_ler_f             l
     where
          a.person_id = p_person_id
      and a.per_cm_id = b.per_cm_id
      and a.cm_typ_id = e.cm_typ_id
      and a.per_cm_id = c.per_cm_id(+)
      and c.cm_trgr_id = d.cm_trgr_id(+)
      and a.per_in_ler_id = p.per_in_ler_id(+)
      and p.ler_id = l.ler_id(+)
      and b.per_cm_prvdd_stat_cd = 'ACTIVE'  -- this should be inclusion criteria.
        -- the following line of code was put here for performance.
      and nvl(b.to_be_sent_dt,hr_api.g_sot) between nvl(p_to_be_sent_strt_dt, hr_api.g_sot)
                                 and  nvl(p_to_be_sent_end_dt, hr_api.g_eot)
      and p_effective_date between b.effective_start_date
                   and b.effective_end_date
      and b.effective_start_date between a.effective_start_date
                   and a.effective_end_date
      and b.effective_start_date
        between nvl(c.effective_start_date,b.effective_start_date)
          and nvl(c.effective_end_date,b.effective_start_date)
      and b.effective_start_date between e.effective_start_date
                   and e.effective_end_date
      and b.effective_start_date
        between nvl(l.effective_start_date,b.effective_start_date)
          and nvl(l.effective_end_date,b.effective_start_date)
      order by b.to_be_sent_dt , b.per_cm_prvdd_id;
 */


  l_per_cm_id_va               t_number ;
  l_per_in_ler_id_va           t_number ;
  l_prtt_enrt_actn_id_va       t_number ;
  l_effective_start_date_va    t_date ;
  l_per_cm_eff_start_date_va   t_date ;
  l_to_be_sent_dt_va           t_date ;
  l_sent_dt_va                 t_date ;
  l_per_cm_last_update_date_va t_date ;
  l_last_update_date_va        t_date ;
  l_dlvry_instn_txt_va         t_varchar2_600 ;
  l_inspn_rqd_flag_va          t_varchar2_30 ;
  l_address_id_va              t_number ;
  l_per_cm_prvdd_id_va         t_number ;
  l_object_version_number_va   t_number ;
  l_cm_typ_id_va               t_number ;


  cursor c_communication_extract
     (p_to_be_sent_strt_dt in date,
      p_to_be_sent_end_dt in date)
   is
   select a.per_cm_id
          , a.per_in_ler_id
          , a.prtt_enrt_actn_id
          , b.effective_start_date
          , a.effective_start_date  per_cm_eff_start_date
          , b.to_be_sent_dt
          , b.sent_dt
          , a.last_update_date    per_cm_last_update_date
          , b.last_update_date
          , b.dlvry_instn_txt
          , b.inspn_rqd_flag
          , b.address_id
          , b.per_cm_prvdd_id
          , b.object_version_number
          , a.cm_typ_id
     from ben_per_cm_f          a,
          ben_per_cm_prvdd_f    b
     where
          a.person_id = p_person_id
      and a.per_cm_id = b.per_cm_id
      and b.per_cm_prvdd_stat_cd = 'ACTIVE'  -- this should be inclusion criteria.
        -- the following line of code was put here for performance.
      and nvl(b.to_be_sent_dt,hr_api.g_sot) between nvl(p_to_be_sent_strt_dt, hr_api.g_sot)
                   and  nvl(p_to_be_sent_end_dt, hr_api.g_eot)
      and p_effective_date between b.effective_start_date
                   and b.effective_end_date
      and b.effective_start_date between a.effective_start_date
                   and a.effective_end_date
      order by b.to_be_sent_dt , b.per_cm_prvdd_id;


  cursor c_per_comm_trigger
     (p_per_cm_id  in  number,
      p_effective_date in date
     ) is
     select  c.effective_start_date ,
             c.cm_trgr_id
     from  ben_per_cm_trgr_f c
     where p_per_cm_id = c.per_cm_id
     and p_effective_date
        between c.effective_start_date and c.effective_end_date
     ;



   cursor c_comm_trgr (
          p_cm_trgr_id in number
          ) is
   select d.proc_cd
   from ben_cm_trgr  d
   where p_cm_trgr_id = d.cm_trgr_id ;


  cursor c_comm_typ (
         p_cm_typ_id in number  ,
         p_effective_date in date
         ) is
  select   e.name
          , e.shrt_name
          , e.pc_kit_cd
  from ben_cm_typ_f          e
  where p_cm_typ_id = e.cm_typ_id
    and p_effective_date between e.effective_start_date
        and e.effective_end_date ;


   cursor c_pil ( p_per_in_ler_id number ,
                  p_effective_date in date
                ) is
   select  l.ler_id
          ,l.name
          ,p.per_in_ler_stat_cd
          ,p.lf_evt_ocrd_dt
          ,p.ntfn_dt
   from ben_per_in_ler        p,
        ben_ler_f             l
    where p_per_in_ler_id = p.per_in_ler_id
      and p.ler_id = l.ler_id
      and p_effective_date
        between l.effective_start_date and l.effective_end_date
    ;

  l_cm_trgr_id     ben_per_cm_trgr_f.cm_trgr_id%type ;
  l_last_per_cm_prvdd_id number:=null;
  l_err_message fnd_new_messages.message_text%type ;
--
/* Start of Changes for WWBUG: 2008949: added cursor    */
 cursor c_chg_penid(p_element_entry_id number,
                     p_effective_date  date) is
  select ee.creator_id
  from pay_element_entries_f ee
  where ee.element_entry_id = p_element_entry_id
  and p_effective_date between ee.effective_start_date and ee.effective_end_date;
/* End of Changes for WWBUG: 2008949: added cursor  */
-- CWB

  cursor c_cwb_extract is
  select cpi.GROUP_PER_IN_LER_ID
        ,cpi.ASSIGNMENT_ID
        ,cpi.PERSON_ID
        ,cpi.SUPERVISOR_ID
        ,cpi.EFFECTIVE_DATE
        ,cpi.FULL_NAME
        ,cpi.BRIEF_NAME
        ,cpi.CUSTOM_NAME
        ,cpi.SUPERVISOR_FULL_NAME
        ,cpi.SUPERVISOR_BRIEF_NAME
        ,cpi.SUPERVISOR_CUSTOM_NAME
        ,cpi.LEGISLATION_CODE
        ,cpi.YEARS_EMPLOYED
        ,cpi.YEARS_IN_JOB
        ,cpi.YEARS_IN_POSITION
        ,cpi.YEARS_IN_GRADE
        ,cpi.EMPLOYEE_NUMBER
        ,cpi.START_DATE
        ,cpi.ORIGINAL_START_DATE
        ,cpi.ADJUSTED_SVC_DATE
        ,cpi.BASE_SALARY
        ,cpi.BASE_SALARY_CHANGE_DATE
        ,cpi.PAYROLL_NAME
        ,cpi.PERFORMANCE_RATING
        ,cpi.PERFORMANCE_RATING_TYPE
        ,cpi.PERFORMANCE_RATING_DATE
        ,cpi.BUSINESS_GROUP_ID
        ,cpi.ORGANIZATION_ID
        ,cpi.JOB_ID
        ,cpi.GRADE_ID
        ,cpi.POSITION_ID
        ,cpi.PEOPLE_GROUP_ID
        ,cpi.SOFT_CODING_KEYFLEX_ID
        ,cpi.LOCATION_ID
        ,cpi.PAY_RATE_ID
        ,cpi.ASSIGNMENT_STATUS_TYPE_ID
        ,cpi.FREQUENCY
        ,cpi.GRADE_ANNULIZATION_FACTOR
        ,cpi.PAY_ANNULIZATION_FACTOR
        ,cpi.GRD_MIN_VAL
        ,cpi.GRD_MAX_VAL
        ,cpi.GRD_MID_POINT
        ,cpi.GRD_QUARTILE
        ,cpi.GRD_COMPARATIO
        ,cpi.EMP_CATEGORY
        ,cpi.CHANGE_REASON
        ,cpi.NORMAL_HOURS
        ,cpi.EMAIL_ADDRESS
        ,cpi.BASE_SALARY_FREQUENCY
        ,cpi.NEW_ASSGN_OVN
        ,cpi.NEW_PERF_EVENT_ID
        ,cpi.NEW_PERF_REVIEW_ID
        ,cpi.POST_PROCESS_STAT_CD
        ,cpi.FEEDBACK_RATING
        ,cpi.OBJECT_VERSION_NUMBER
        ,cpi.CUSTOM_SEGMENT1
        ,cpi.CUSTOM_SEGMENT2
        ,cpi.CUSTOM_SEGMENT3
        ,cpi.CUSTOM_SEGMENT4
        ,cpi.CUSTOM_SEGMENT5
        ,cpi.CUSTOM_SEGMENT6
        ,cpi.CUSTOM_SEGMENT7
        ,cpi.CUSTOM_SEGMENT8
        ,cpi.CUSTOM_SEGMENT9
        ,cpi.CUSTOM_SEGMENT10
        ,cpi.CUSTOM_SEGMENT11
        ,cpi.CUSTOM_SEGMENT12
        ,cpi.CUSTOM_SEGMENT13
        ,cpi.CUSTOM_SEGMENT14
        ,cpi.CUSTOM_SEGMENT15
        ,cpi.PEOPLE_GROUP_NAME
        ,cpi.PEOPLE_GROUP_SEGMENT1
        ,cpi.PEOPLE_GROUP_SEGMENT2
        ,cpi.PEOPLE_GROUP_SEGMENT3
        ,cpi.PEOPLE_GROUP_SEGMENT4
        ,cpi.PEOPLE_GROUP_SEGMENT5
        ,cpi.PEOPLE_GROUP_SEGMENT6
        ,cpi.PEOPLE_GROUP_SEGMENT7
        ,cpi.PEOPLE_GROUP_SEGMENT8
        ,cpi.PEOPLE_GROUP_SEGMENT9
        ,cpi.PEOPLE_GROUP_SEGMENT10
        ,cpi.PEOPLE_GROUP_SEGMENT11
        ,cpi.ASS_ATTRIBUTE_CATEGORY
        ,cpi.ASS_ATTRIBUTE1
        ,cpi.ASS_ATTRIBUTE2
        ,cpi.ASS_ATTRIBUTE3
        ,cpi.ASS_ATTRIBUTE4
        ,cpi.ASS_ATTRIBUTE5
        ,cpi.ASS_ATTRIBUTE6
        ,cpi.ASS_ATTRIBUTE7
        ,cpi.ASS_ATTRIBUTE8
        ,cpi.ASS_ATTRIBUTE9
        ,cpi.ASS_ATTRIBUTE10
        ,cpi.ASS_ATTRIBUTE11
        ,cpi.ASS_ATTRIBUTE12
        ,cpi.ASS_ATTRIBUTE13
        ,cpi.ASS_ATTRIBUTE14
        ,cpi.ASS_ATTRIBUTE15
        ,cpi.ASS_ATTRIBUTE16
        ,cpi.ASS_ATTRIBUTE17
        ,cpi.ASS_ATTRIBUTE18
        ,cpi.ASS_ATTRIBUTE19
        ,cpi.ASS_ATTRIBUTE20
        ,cpi.ASS_ATTRIBUTE21
        ,cpi.ASS_ATTRIBUTE22
        ,cpi.ASS_ATTRIBUTE23
        ,cpi.ASS_ATTRIBUTE24
        ,cpi.ASS_ATTRIBUTE25
        ,cpi.ASS_ATTRIBUTE26
        ,cpi.ASS_ATTRIBUTE27
        ,cpi.ASS_ATTRIBUTE28
        ,cpi.ASS_ATTRIBUTE29
        ,cpi.ASS_ATTRIBUTE30
        ,cpi.CPI_ATTRIBUTE_CATEGORY
        ,cpi.CPI_ATTRIBUTE1
        ,cpi.CPI_ATTRIBUTE2
        ,cpi.CPI_ATTRIBUTE3
        ,cpi.CPI_ATTRIBUTE4
        ,cpi.CPI_ATTRIBUTE5
        ,cpi.CPI_ATTRIBUTE6
        ,cpi.CPI_ATTRIBUTE7
        ,cpi.CPI_ATTRIBUTE8
        ,cpi.CPI_ATTRIBUTE9
        ,cpi.CPI_ATTRIBUTE10
        ,cpi.CPI_ATTRIBUTE11
        ,cpi.CPI_ATTRIBUTE12
        ,cpi.CPI_ATTRIBUTE13
        ,cpi.CPI_ATTRIBUTE14
        ,cpi.CPI_ATTRIBUTE15
        ,cpi.CPI_ATTRIBUTE16
        ,cpi.CPI_ATTRIBUTE17
        ,cpi.CPI_ATTRIBUTE18
        ,cpi.CPI_ATTRIBUTE19
        ,cpi.CPI_ATTRIBUTE20
        ,cpi.CPI_ATTRIBUTE21
        ,cpi.CPI_ATTRIBUTE22
        ,cpi.CPI_ATTRIBUTE23
        ,cpi.CPI_ATTRIBUTE24
        ,cpi.CPI_ATTRIBUTE25
        ,cpi.CPI_ATTRIBUTE26
        ,cpi.CPI_ATTRIBUTE27
        ,cpi.CPI_ATTRIBUTE28
        ,cpi.CPI_ATTRIBUTE29
        ,cpi.CPI_ATTRIBUTE30
        ,cpi.LAST_UPDATE_DATE
        ,cpi.LAST_UPDATED_BY
        ,cpi.LAST_UPDATE_LOGIN
        ,cpi.CREATED_BY
        ,cpi.CREATION_DATE
        ,cpi.FEEDBACK_DATE
        ,pil.lf_evt_ocrd_dt
        ,pil.group_pl_id
        ,pil.PER_IN_LER_STAT_CD
        ,ler.name   LER_NAME
        ,pl.name    group_pl_name
        ,pl.PERF_REVW_STRT_DT
        ,pl.EMP_INTERVIEW_TYP_CD
        ,pl.ASG_UPDT_EFF_DATE
  from  ben_cwb_person_info  cpi ,
        ben_per_in_ler       pil ,
        ben_ler_f            ler ,
        ben_cwb_pl_dsgn      pl
 where  cpi.person_id     =  p_person_id
   and  cpi.group_per_in_ler_id  =  pil.per_in_ler_id
   and  pil.ler_id         =  ler.ler_id
   and  pil.group_pl_id    =  pl.pl_id
   and  pl.oipl_id         =  -1
   and  pil.lf_evt_ocrd_dt =  pl.lf_evt_ocrd_dt
   and  cpi.effective_date
        between ler.effective_start_date and ler.effective_end_date
   ;


 cursor c_bg_name(p_business_group_id number) is
 select name
 from   per_business_groups_perf  bg
 where  business_group_id = p_business_group_id ;

 cursor c_org_name(p_org_id  number) is
 select name
 from   hr_all_organization_units_vl  org
 where  org.organization_id  = p_org_id ;

 cursor c_pos (p_pos_id number) is
 select name
   from per_positions
  where position_id = p_pos_id
 ;

 cursor c_job(p_job_id number) is
 select name
   from per_jobs_vl
  where job_id = p_job_id
 ;

 cursor c_grade(p_grade_id number) is
 select name
   from per_grades_vl
  where grade_id  = p_grade_id
 ;

 cursor c_loc(p_loc_id number) is
 select location_code
 from   hr_locations_all
 where  location_id = p_loc_id
 ;

 cursor c_payr(p_rate_id number) is
 select name
 from   pay_rates
 where  rate_id  = p_rate_id
 ;

 cursor c_pln(p_pl_id  number , p_dt date ) is
 select name
 from   ben_cwb_pl_dsgn pl
 where  p_pl_id = pl.PL_ID
 and    pl.oipl_id = -1
 and    p_dt  =   pl.lf_evt_ocrd_dt
 ;


 cursor c_groups (p_grp_id   number) is
 select group_name
  from  pay_people_groups
  where PEOPLE_GROUP_ID  = p_grp_id
  ;

 cursor c_asg_status (p_asg_stat_id number) is
 select user_status
 from  PER_ASSIGNMENT_STATUS_TYPES
 where ASSIGNMENT_STATUS_TYPE_ID = p_asg_stat_id
 ;



 cursor c_hr_lkup(p_lkup_type varchar2,
                   p_lkup_code varchar2)  is
 select  meaning
 from    hr_lookups
 where   lookup_type = p_lkup_type
   and   lookup_code = p_lkup_code
;

 cursor  c_tran (p_trn_id number ,
                 p_trn_type varchar2) is
 select ATTRIBUTE3,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8
 from ben_transaction
 where TRANSACTION_ID = p_trn_id
   and TRANSACTION_TYPE = p_trn_type
  ;

 ---  to get all the primary assignment within the period

 cursor c_pay_p_asg (p_person_id number ,
                     p_from_date date   ,
                     p_to_date   date  ) is
 select   distinct assignment_id
   from   per_all_assignments_f
   where  person_id = p_person_id
     and  ( primary_flag = 'Y'  OR (ASSIGNMENT_TYPE ='A' and p_penserv_mode = 'N') ) -- vkodedal fix for 6798915, 9181637
     and  effective_start_date <= p_to_date and
          effective_end_date >= p_from_date
  ;

 -- to get th last date of the assignment to
 -- validate the assgnmnet against  type
 cursor c_pay_asg_date (p_Assignment_id number ) is
  select effective_start_date
    from  per_all_assignments_f
    where Assignment_id = p_Assignment_id
        and  ( primary_flag = 'Y'  OR (ASSIGNMENT_TYPE ='A' and p_penserv_mode = 'N') ) -- vkodedal fix for 6798915,9181637
    order by  effective_start_date desc ;
 l_pay_asg_eff_date   date ;
 l_tran  c_tran%rowtype ;
 l_eff_event_scount number ;
 l_eff_event_ecount number ;



Begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'process_ext_person';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;

 --
 -- Get general extract info
 --
 g_business_group_id      := p_business_group_id;
 g_effective_date         := p_effective_date;
 --
 g_person_id         := p_person_id;

 --
 SAVEPOINT cur_transaction;
 -- --------------------------------------------------
 -- Full Profile Extract
 -- --------------------------------------------------
 IF p_data_typ_cd = 'F' THEN
   --
   init_detail_globals;
   --
   ben_ext_util.get_ext_dates
          (p_ext_dfn_id    => p_ext_dfn_id,
           p_data_typ_cd   => p_data_typ_cd,
           p_effective_date  => p_effective_date,
           p_person_ext_dt => l_person_ext_dt,  --out
           p_benefits_ext_dt => l_benefits_ext_dt); -- out
   --
   g_person_ext_dt := l_person_ext_dt;
   g_benefits_ext_dt := l_benefits_ext_dt;
   --
   g_rcd_seq := 1;
   --
   g_trans_num := 1;


   Extract_person_info(p_person_id          =>  p_person_id,
                       p_effective_date     =>  p_effective_date,  -- passed in from conc mgr
                       p_business_group_id  =>  p_business_group_id,
                       p_ext_rslt_id        =>  p_ext_rslt_id
                      ) ;
   --
   l_include := 'Y';
   --
   if p_ext_crit_prfl_id is not null THEN
     --
     ben_ext_evaluate_inclusion.Evaluate_Person_Incl
                     (p_person_id       => p_person_id,
                      p_postal_code     => g_prim_postal_code,
                      p_org_id          => g_employee_organization_id,
                      p_loc_id          => g_location_id,
                      p_gre             => null,  -- this will be fetched in called program.
                      p_state           => g_prim_state,
                      p_bnft_grp        => g_benefit_group_id,
                      p_ee_status       => g_employee_status_id,
                      p_chg_evt_cd      => null,
                      p_effective_date  => g_person_ext_dt,
                      p_actl_date       => null,
                      p_include         => l_include);
     --
   end if;
   --
   if l_include = 'Y' then
     --
     if nvl(ben_extract.g_spcl_hndl_flag,'X') <> 'Y' then -- normal processing

         process_ext_levels(
                          p_person_id         => p_person_id,
                          p_ext_rslt_id       => p_ext_rslt_id,
                          p_ext_file_id       => p_ext_file_id,
                          p_data_typ_cd       => p_data_typ_cd,
                          p_ext_typ_cd        => p_ext_typ_cd,
                          p_business_group_id => p_business_group_id,
                          p_effective_date    => g_effective_date
                         );
     else -- special handling flag tells us that it is an ansi 834 extract.
            --
            ben_ext_ansi.main(
                          p_person_id         => p_person_id,
                          p_ext_rslt_id       => p_ext_rslt_id,
                          p_ext_file_id       => p_ext_file_id,
                          p_data_typ_cd       => p_data_typ_cd,
                          p_ext_typ_cd        => p_ext_typ_cd,
                          p_ext_crit_prfl_id  => p_ext_crit_prfl_id,
                          p_business_group_id => p_business_group_id,
                          p_effective_date    => g_benefits_ext_dt
                         );
     end if;
     --
   end if;   -- l_include = 'Y'
   --
 -- ==========================================
 -- Changes Only Extract
 -- ==========================================
 ELSIF p_data_typ_cd = 'C' THEN
   --
   g_trans_num := 1;
   --
      ben_ext_util.get_chg_dates
          (p_ext_dfn_id => ben_extract.g_ext_dfn_id, --in
           p_effective_date => g_effective_date, --in
           p_chg_actl_strt_dt => l_chg_actl_strt_dt, --out
           p_chg_actl_end_dt => l_chg_actl_end_dt, --out
           p_chg_eff_strt_dt => l_chg_eff_strt_dt, --out
           p_chg_eff_end_dt => l_chg_eff_end_dt); --out

   -- if the parameter passed from extract , then overide the criteria dates
   if ben_ext_thread.g_effective_start_date is not null then
      l_chg_eff_strt_dt := ben_ext_thread.g_effective_start_date ;
      l_chg_eff_end_dt  := ben_ext_thread.g_effective_end_date ;
   end if ;

   if ben_ext_thread.g_actual_start_date is not null then
      l_chg_actl_strt_dt := ben_ext_thread.g_actual_start_date ;
      l_chg_actl_end_dt  := ben_ext_thread.g_actual_end_date ;
   end if ;

   hr_utility.set_location( 'chg actl date ' ||  l_chg_actl_strt_dt || ' / ' ||  l_chg_actl_end_dt, 99 );
   hr_utility.set_location( 'chg eff date ' ||  l_chg_eff_strt_dt  || ' / ' ||  l_chg_eff_end_dt , 99 );
   --
   if ben_ext_thread.g_chg_ext_from_ben = 'Y' then
      hr_utility.set_location( ' extract chg evt log included '  , 99 );
       open c_changes_only_extract (l_chg_actl_strt_dt,
                                l_chg_actl_end_dt,
                                l_chg_eff_strt_dt,
                                l_chg_eff_end_dt);
       LOOP
         --
         init_detail_globals;
         --
         FETCH c_changes_only_extract into
         --
                g_ext_chg_evt_log_id,
                g_chg_evt_cd,
                g_chg_eff_dt,
                g_chg_actl_dt,
                g_chg_last_update_login,
                g_chg_prmtr_01,
                g_chg_prmtr_02,
                g_chg_prmtr_03,
                g_chg_prmtr_04,
                g_chg_prmtr_05,
                g_chg_prmtr_06,
                g_chg_old_val1,
                g_chg_old_val2,
                g_chg_old_val3,
                g_chg_old_val4,
                g_chg_old_val5,
                g_chg_old_val6,
                g_chg_new_val1,
                g_chg_new_val2,
                g_chg_new_val3,
                g_chg_new_val4,
                g_chg_new_val5,
                g_chg_new_val6,
                g_chg_evt_source
                ;
         --
         EXIT WHEN c_changes_only_extract%NOTFOUND;
         --
         --g_extract_date := g_chg_eff_dt;
         --
         ben_ext_util.get_ext_dates
              (p_ext_dfn_id    => p_ext_dfn_id,
               p_data_typ_cd   => p_data_typ_cd,
               p_effective_date  => g_effective_date,
               p_person_ext_dt => l_person_ext_dt,  --out
               p_benefits_ext_dt => l_benefits_ext_dt); -- out
         --
         g_person_ext_dt := l_person_ext_dt;
         g_benefits_ext_dt := l_benefits_ext_dt;
         --
         l_include := 'Y';
         --
         if p_ext_crit_prfl_id is not null THEN
           --
           ben_ext_evaluate_inclusion.evaluate_change_log_incl
                        (p_chg_evt_cd        => g_chg_evt_cd,
                         p_chg_evt_source    => g_chg_evt_source,
                         p_chg_eff_dt        => g_chg_eff_dt,
                         p_chg_actl_dt       => g_chg_actl_dt,
                         p_last_update_login => g_chg_last_update_login,
                         p_effective_date    => g_effective_date,
                         p_include           => l_include);
           --
         end if;  -- p_ext_crit_prfl_id is not null
         --
         if l_include = 'Y' then
           --

           Extract_person_info(p_person_id          =>  p_person_id,
                               p_effective_date     =>  p_effective_date,  -- passed in from conc mgr
                               p_business_group_id  =>  p_business_group_id,
                               p_ext_rslt_id        =>  p_ext_rslt_id
                               ) ;
           --
          if p_ext_crit_prfl_id is not null THEN
           --
             ben_ext_evaluate_inclusion.Evaluate_Person_Incl
                         (p_person_id       => p_person_id,
                          p_postal_code     => g_prim_postal_code,
                          p_org_id          => g_employee_organization_id,
                          p_loc_id          => g_location_id,
                          p_gre             => null,  -- this will be fetched in called program.
                          p_state           => g_prim_state,
                          p_bnft_grp        => g_benefit_group_id,
                          p_ee_status       => g_employee_status_id,
                          p_chg_evt_cd      => g_chg_evt_cd,
                          p_chg_evt_source  => g_chg_evt_source,
                          p_effective_date  => g_person_ext_dt,
                          --RCHASE
                          p_eff_date        => g_chg_eff_dt,
                          --End RCHASE
                          p_actl_date       => g_chg_actl_dt,
                          p_include         => l_include);
           --
           end if;  -- p_ext_crit_prfl_id is not null
           --
         end if; -- l_include = 'Y'
         --
         IF l_include = 'Y' THEN
           --
           --  Not really sure what this hard coding is all about, should be investigated. th.
           --
           if g_debug then
             hr_utility.set_location(' Change Event Code ' || g_chg_evt_cd , 99 );
           end if;
           --BBurns Bug 1745274.  Set context for AD and DD also on line below.
           /*
               CODE PRIOR TO WWBUG: 2008949
            if g_chg_evt_cd in ('AB', 'AD', 'DD', 'RB', 'TBAC', 'TBBC', 'UOBO', 'CCSD', 'CCED') then
           */
           /* Start of Changes for WWBUG: 2008949  added COECA  */
           if g_chg_evt_cd in ('AB', 'AD', 'DD', 'RB', 'TBAC',
                              'TBBC', 'UOBO', 'CCSD', 'CCED', 'COECA') then
           /* End of Changes for WWBUG: 2008949  added COECA  */
             --
             g_chg_pl_id        := g_chg_prmtr_01;
             g_chg_enrt_rslt_id := g_chg_prmtr_03;
             --
           elsif g_chg_evt_cd in ('DEE', 'AEE', 'UEE') then
             --
             g_chg_input_value_id := to_number(g_chg_prmtr_02);
             --
                 /* Start of Changes for WWBUG: 2008949:   addition */
             --
             g_chg_enrt_rslt_id := to_number(g_chg_prmtr_03);

             if g_chg_enrt_rslt_id is null
             then
                --
                --Fetch the prtt_enrt_rslt_id. This will be the only enrollment link
                --between the chg_evt_log and ben_prtt_enrt_rslt_id
                --
                open c_chg_penid(p_element_entry_id => to_number(g_chg_prmtr_01),
                                 p_effective_date   => g_chg_eff_dt);
                fetch c_chg_penid into g_chg_enrt_rslt_id;
                  if c_chg_penid%notfound
                  then
                       --we do not have a link between the chg_evt and an
                       --enrollment.
                       g_chg_enrt_rslt_id := null;
                  end if;
                close c_chg_penid;
             end if;
             /* End of Changes for WWBUG: 2008949:   addition   */
           end if;
           --
           -- get change log information
           --
           IF g_chg_evt_cd in ( 'CON', 'COUN') THEN
             --
            if g_chg_old_val5 is not null then
             g_previous_last_name   := g_chg_old_val5;  -- needs fixing.
             g_previous_first_name  := g_chg_old_val3;
             g_previous_middle_name := g_chg_old_val4;
             g_previous_suffix      := g_chg_old_val6;
            end if ;

             if g_debug then
               hr_utility.set_location(' l name  ' || g_previous_last_name , 99 );
               hr_utility.set_location(' f name  ' || g_previous_first_name , 99 );
               hr_utility.set_location(' m name  ' || g_previous_middle_name  , 99 );
             end if;

           ELSIF g_chg_evt_cd = 'CONS' THEN
              g_previous_prefix     := g_chg_old_val1 ;
             --
           ELSIF g_chg_evt_cd = 'COSS' THEN
             --
             g_previous_ssn   := g_chg_old_val1 ;
           ELSIF g_chg_evt_cd = 'COG' then
             g_previous_sex   :=  g_chg_old_val1 ;
             --
           ELSIF g_chg_evt_cd = 'CODB' THEN
             --
             g_previous_dob         := to_date(g_chg_old_val1 ,'MM/DD/YYYY');
             --
           END IF;
           --
           g_rcd_seq := 1;  -- what's this do?  th.
           --
           if nvl(ben_extract.g_spcl_hndl_flag,'X') <> 'Y' then -- normal processing
             --
             process_ext_levels(
                              p_person_id         => p_person_id,
                              p_ext_rslt_id       => p_ext_rslt_id,
                              p_ext_file_id       => p_ext_file_id,
                              p_data_typ_cd       => p_data_typ_cd,
                              p_ext_typ_cd        => p_ext_typ_cd,
                              p_business_group_id => p_business_group_id,
                              p_effective_date    => g_effective_date
                             );
           else -- special handling flag tells us that it is an ansi 834 extract.
             --
             ben_ext_ansi.main(
                              p_person_id         => p_person_id,
                              p_ext_rslt_id       => p_ext_rslt_id,
                              p_ext_file_id       => p_ext_file_id,
                              p_data_typ_cd       => p_data_typ_cd,
                              p_ext_typ_cd        => p_ext_typ_cd,
                              p_ext_crit_prfl_id  => p_ext_crit_prfl_id,
                              p_business_group_id => p_business_group_id,
                              p_effective_date    => g_benefits_ext_dt
                             );
           end if;
           --
           g_trans_num := g_trans_num + 1;
           --
         END IF;   -- l_include = 'Y'

         --
      END LOOP;  --changes

      --
      close c_changes_only_extract;
      --
  end if ;   --- for extract chg logs


  if ben_ext_thread.g_chg_ext_from_pay = 'Y' then
      hr_utility.set_location( ' PAY  event log included ' ,  99 );
      -- Loop thorough all the assignment id for a person
      -- within the extract period
      --- get the primary assg as of effective date
      init_assignment_id(p_person_id      =>  p_person_id ,
                           p_effective_date =>  p_effective_date) ;

      l_pay_tot_Srno  := 1 ;
      l_pay_evt_srno  := 1 ;

      --- determine the adv dates only one for a process

      If ben_ext_evaluate_inclusion.g_chg_actl_dt_incl_rqd = 'N' and
         ben_ext_evaluate_inclusion.g_chg_eff_dt_incl_rqd = 'N'  and
         ben_ext_evaluate_inclusion.g_cmbn_incl_rqd = 'Y'  then

         hr_utility.set_location('pay adv condition mode ' ||g_pay_adv_date_mode , 66 );
         if g_pay_adv_date_mode is null then
            hr_utility.set_location('pay adv condition exisit withoutot other criteria'  , 66 );
            get_pay_adv_crit_dates(
                      p_ext_crit_prfl_id   =>  p_ext_crit_prfl_id,
                      p_ext_dfn_id         =>  p_ext_dfn_id,
                      p_business_group_id  =>  p_business_group_id,
                      p_effective_date     =>  p_effective_date,
                      p_eff_from_dt        =>  g_pay_adv_eff_from_dt,
                      p_eff_to_dt          =>  g_pay_adv_eff_to_dt,
                      p_act_from_dt        =>  g_pay_adv_act_from_dt ,
                      p_act_to_dt          =>  g_pay_adv_act_to_dt,
                      p_date_mode          =>  g_pay_adv_date_mode
                  ) ;
         end if ;

      end if ;


      for pasg  in c_pay_p_asg(p_person_id , nvl(l_chg_eff_strt_dt,nvl(l_chg_actl_strt_dt,p_effective_date)),
                                             nvl(l_chg_eff_end_dt,nvl(l_chg_actl_end_dt,p_effective_date))
                               )
      Loop
         hr_utility.set_location(' pay assg id ' ||pasg.Assignment_id , 66 ) ;

         open c_pay_asg_date (pasg.Assignment_id) ;
         fetch c_pay_asg_date into  l_pay_asg_eff_date ;
         close c_pay_asg_date ;
         hr_utility.set_location(' pay assg date ' ||l_pay_asg_eff_date  , 66 ) ;
         hr_utility.set_location(' pay actual start  date ' ||l_chg_actl_strt_dt  , 66 ) ;

         -- determine the assignment before call the interpreter
         init_assignment_id(p_person_id     =>  p_person_id ,
                           p_effective_date =>  l_pay_asg_eff_date ,
                           p_Assignment_id  =>  pasg.Assignment_id ) ;


         l_pay_Assignment_id :=  g_assignment_id  ;
         if l_pay_Assignment_id is not null then


            -- this is a pqp idea to collect the unique column and group id
            -- pls dont change the logic  unless  agreed with pqp
            -- this loop collect all the change event result from PEI and colect in a table
            -- and also collect the unique table/column/event intto global table
            -- pqp need the global table, only used in formula
            for i in c_chg_pay_evt
            Loop
               l_pay_detail_tab.delete ;
               l_pay_proration_dates.delete ;
               l_pay_proration_changes.delete ;
               l_pay_pro_type_tab.delete ;


               If ben_ext_evaluate_inclusion.g_chg_actl_dt_incl_rqd = 'N' and
                  ben_ext_evaluate_inclusion.g_chg_eff_dt_incl_rqd = 'N'  and
                  ben_ext_evaluate_inclusion.g_cmbn_incl_rqd = 'Y'  then




                  Begin


                      if  g_pay_adv_date_mode = 'B' or g_pay_adv_date_mode = 'E' then
                          hr_utility.set_location('adv effective date mode '||g_pay_adv_eff_from_dt||'/'||
                                                  g_pay_adv_eff_to_dt,99) ;

                          l_eff_event_ecount := 0 ;
                          l_eff_event_scount := 0 ;
                          ben_ext_util.entries_affected
                                (p_assignment_id          =>  l_pay_Assignment_id
                                ,p_event_group_id         =>  i.event_group_id
                                ,p_mode                   =>  NULL -- 'DATE_PROCESSED' -- 'DATE_EARNED' --
                                ,p_start_date             =>  (g_pay_adv_eff_from_dt-1)
                                  -- since the PDI use the exclisive of the start and end
                                ,p_end_date               =>  (g_pay_adv_eff_to_dt)
                                ,p_business_group_id      =>  p_business_group_id
                                ,p_detailed_output        =>  l_pay_detail_tab
                                ,p_process_mode           =>  'ENTRY_EFFECTIVE_DATE'
                                ,p_penserv_mode           =>  p_penserv_mode   -- vkodedal - changes for penserver -30-apr-2008
                                );

                          hr_utility.set_location( 'number of result  ' ||l_pay_detail_tab.count, 99 ) ;

                          -- get the starting count of  total colection for comparison
                          l_eff_event_scount := l_pay_tot_Srno ;

                          if l_pay_detail_tab.count > 0 then
                             -- collect all the information onto a table for process for a person
                             FOR l_pay  IN l_pay_detail_tab.FIRST..l_pay_detail_tab.LAST
                             LOOP

                                hr_utility.set_location(' insertining tot '|| l_pay_tot_Srno|| ' / '
                                                    ||l_pay_detail_tab(l_pay).column_name,99) ;

                                l_pay_detail_tot_tab(l_pay_tot_Srno).dated_table_id
                                                     := l_pay_detail_tab(l_pay).dated_table_id ;
                                l_pay_detail_tot_tab(l_pay_tot_Srno).datetracked_event
                                                     := l_pay_detail_tab(l_pay).datetracked_event ;
                                l_pay_detail_tot_tab(l_pay_tot_Srno).update_type
                                                     := l_pay_detail_tab(l_pay).update_type ;
                                l_pay_detail_tot_tab(l_pay_tot_Srno).surrogate_key
                                                     := l_pay_detail_tab(l_pay).surrogate_key ;
                                l_pay_detail_tot_tab(l_pay_tot_Srno).column_name
                                                     := l_pay_detail_tab(l_pay).column_name ;
                                l_pay_detail_tot_tab(l_pay_tot_Srno).effective_date
                                                     := l_pay_detail_tab(l_pay).effective_date ;
                                l_pay_detail_tot_tab(l_pay_tot_Srno).old_value
                                                     := l_pay_detail_tab(l_pay).old_value ;
                                l_pay_detail_tot_tab(l_pay_tot_Srno).new_value
                                                     := l_pay_detail_tab(l_pay).new_value ;
                                l_pay_detail_tot_tab(l_pay_tot_Srno).change_values
                                                     := l_pay_detail_tab(l_pay).change_values ;
                                l_pay_detail_tot_tab(l_pay_tot_Srno).proration_type
                                                     := l_pay_detail_tab(l_pay).proration_type ;
                                l_pay_detail_tot_tab(l_pay_tot_Srno).change_mode
                                                     := l_pay_detail_tab(l_pay).change_mode ;
                                l_pay_detail_tot_tab(l_pay_tot_Srno).event_group_id   := i.event_group_id ;
                                l_pay_detail_tot_tab(l_pay_tot_Srno).actual_date
                                                     := l_pay_detail_tab(l_pay).creation_date    ;
                                l_pay_tot_Srno := l_pay_tot_Srno + 1  ;

                          End loop ;
                        end if ;

                      End if ;


                      if  g_pay_adv_date_mode = 'B' or g_pay_adv_date_mode = 'C' then
                           -- get the total count of srno for efficient comaprison
                           l_eff_event_ecount := l_pay_detail_tot_tab.count ;
                           l_pay_detail_tab.delete ;
                           hr_utility.set_location('adv actual date mode '||g_pay_adv_act_from_dt||' / ' ||
                                                    g_pay_adv_act_to_dt,99) ;
                           ben_ext_util.entries_affected
                                (p_assignment_id          =>  l_pay_Assignment_id
                                ,p_event_group_id         =>  i.event_group_id
                                ,p_mode                   =>  NULL -- 'DATE_PROCESSED' -- 'DATE_EARNED' --
                                ,p_start_date             =>  trunc(g_pay_adv_act_from_dt)
                                 -- since the PDI use the exclisive of the start and end
                                ,p_end_date               => (trunc(g_pay_adv_act_to_dt)+0.99999)
                                ,p_business_group_id      =>  p_business_group_id
                                ,p_detailed_output        =>  l_pay_detail_tab
                                ,p_process_mode           =>  'ENTRY_CREATION_DATE'
                                ,p_penserv_mode           =>   p_penserv_mode    --vkodedal changes for penserver - 30-apr-2008
                                );



                          hr_utility.set_location( 'number of result  ' ||l_pay_detail_tab.count, 99 ) ;

                          if l_pay_detail_tab.count > 0 then

                             -- collect all the information onto a table for process for a person
                             FOR l_pay  IN l_pay_detail_tab.FIRST..l_pay_detail_tab.LAST
                             LOOP


                               l_g_c_found := 'N' ;
                               -- Look for the duplication from actaul and effective
                               if g_pay_adv_date_mode = 'B' and (l_eff_event_ecount-l_eff_event_scount) >= 0  then
                                  --for l_g_c IN  1 .. l_pay_detail_tot_tab.count
                                  for l_g_c IN  l_eff_event_scount .. l_eff_event_ecount
                                  Loop
                                    if l_pay_detail_tot_tab(l_g_c).dated_table_id=l_pay_detail_tab(l_pay).dated_table_id
                                      and l_pay_detail_tot_tab(l_g_c).event_group_id = i.event_group_id
                                      and l_pay_detail_tot_tab(l_g_c).surrogate_key
                                                         = l_pay_detail_tab(l_pay).surrogate_key
                                      and l_pay_detail_tot_tab(l_g_c).update_type
                                                         = l_pay_detail_tab(l_pay).update_type
                                      and l_pay_detail_tot_tab(l_g_c).effective_date
                                                         = l_pay_detail_tab(l_pay).effective_date
                                      and l_pay_detail_tot_tab(l_g_c).actual_Date
                                                         = l_pay_detail_tab(l_pay).creation_date
                                      and nvl(l_pay_detail_tot_tab(l_g_c).column_name,'-1')
                                                         = nvl(l_pay_detail_tab(l_pay).column_name,'-1')
                                      and nvl(l_pay_detail_tot_tab(l_g_c).datetracked_event,'-1')
                                                         = nvl(l_pay_detail_tab(l_pay).datetracked_event,'-1')
                                      and nvl(l_pay_detail_tot_tab(l_g_c).proration_type,'-1')
                                                         = nvl(l_pay_detail_tab(l_pay).proration_type,'-1')
                                      and nvl(l_pay_detail_tot_tab(l_g_c).change_mode,'-1')
                                                         = nvl(l_pay_detail_tab(l_pay).change_mode,'-1')
                                      and nvl(l_pay_detail_tot_tab(l_g_c).change_values,'-1')
                                                         = nvl(l_pay_detail_tab(l_pay).change_values,'-1')
                                      and nvl(l_pay_detail_tot_tab(l_g_c).old_value,'-1')
                                                         = nvl(l_pay_detail_tab(l_pay).old_value,'-1')
                                      and nvl(l_pay_detail_tot_tab(l_g_c).new_value,'-1')
                                                         = nvl(l_pay_detail_tab(l_pay).new_value,'-1')
                                      then
                                      l_g_c_found := 'Y' ;
                                      exit ;
                                    end if ;
                                  End loop ;
                               End if ;


                               --- if the entry is unique then create
                               if l_g_c_found = 'N' then

                                   hr_utility.set_location(' insertining tot '|| l_pay_tot_Srno|| ' / '
                                                    ||l_pay_detail_tab(l_pay).column_name,99) ;

                                   l_pay_detail_tot_tab(l_pay_tot_Srno).dated_table_id
                                                     := l_pay_detail_tab(l_pay).dated_table_id ;
                                   l_pay_detail_tot_tab(l_pay_tot_Srno).datetracked_event
                                                     := l_pay_detail_tab(l_pay).datetracked_event ;
                                   l_pay_detail_tot_tab(l_pay_tot_Srno).update_type
                                                     := l_pay_detail_tab(l_pay).update_type ;
                                   l_pay_detail_tot_tab(l_pay_tot_Srno).surrogate_key
                                                     := l_pay_detail_tab(l_pay).surrogate_key ;
                                   l_pay_detail_tot_tab(l_pay_tot_Srno).column_name
                                                     := l_pay_detail_tab(l_pay).column_name ;
                                   l_pay_detail_tot_tab(l_pay_tot_Srno).effective_date
                                                     := l_pay_detail_tab(l_pay).effective_date ;
                                   l_pay_detail_tot_tab(l_pay_tot_Srno).old_value
                                                     := l_pay_detail_tab(l_pay).old_value ;
                                   l_pay_detail_tot_tab(l_pay_tot_Srno).new_value
                                                     := l_pay_detail_tab(l_pay).new_value ;
                                   l_pay_detail_tot_tab(l_pay_tot_Srno).change_values
                                                     := l_pay_detail_tab(l_pay).change_values ;
                                   l_pay_detail_tot_tab(l_pay_tot_Srno).proration_type
                                                     := l_pay_detail_tab(l_pay).proration_type ;
                                   l_pay_detail_tot_tab(l_pay_tot_Srno).change_mode
                                                     := l_pay_detail_tab(l_pay).change_mode ;
                                   l_pay_detail_tot_tab(l_pay_tot_Srno).event_group_id   := i.event_group_id ;
                                   l_pay_detail_tot_tab(l_pay_tot_Srno).actual_date
                                                       := l_pay_detail_tab(l_pay).creation_date    ;
                                   l_pay_tot_Srno := l_pay_tot_Srno + 1  ;
                               end if ;  -- unique entry
                         end loop ;

                      End if ;

                    end if;
                  Exception
                       WHEN hr_application_error THEN
                            -- the exception handled only when thge pqp raise the error with the msg
                            IF hr_utility.get_message = 'BEN_94629_NO_ASG_ACTION_ID' THEN
                               hr_utility.set_location( 'Current assignment has no Assignment Action id. ' ,-9999);
                               g_err_num  :=  94629 ;
                               g_err_name :=  'BEN_94629_NO_ASG_ACTION_ID' ;
                               g_elmt_name:=  null ;
                               raise detail_restart_error ;
                            else
                               hr_utility.set_location( 'unknow exception raised in pqp.',-9999);
                               raise; -- to re-raise the exception
                            end if ;

                  End ;

               Else


                  Begin

                    if l_chg_actl_strt_dt is not null   and  ben_ext_evaluate_inclusion.g_chg_actl_dt_incl_rqd = 'Y'  then
                          -- call the interpreter in actual date mode
                          -- as per my understanding from PQP - ram
                          -- since the actual date has the time stamp , the time stamp play the role in extracting info
                          -- so the from date is truncated and to date is  extended to the last second of the day

                          hr_utility.set_location('pay actual dt mode '||trunc(l_chg_actl_strt_dt)||' / '||
                                    (trunc(l_chg_actl_end_dt)+0.99999) , 66 );

                          ben_ext_util.entries_affected
                                (p_assignment_id          =>  l_pay_Assignment_id
                                ,p_event_group_id         =>  i.event_group_id
                                ,p_mode                   =>  NULL -- 'DATE_PROCESSED' -- 'DATE_EARNED' --
                                ,p_start_date             =>  trunc(l_chg_actl_strt_dt)
                                 -- since the PDI use the exclisive of the start and end
                                ,p_end_date               => (trunc(l_chg_actl_end_dt)+0.99999)
                                ,p_business_group_id      =>  p_business_group_id
                                ,p_detailed_output        =>  l_pay_detail_tab
                                ,p_process_mode           =>  'ENTRY_CREATION_DATE'
                                ,p_penserv_mode           =>   p_penserv_mode    --vkodedal changes for penserver - 30-apr-2008
                                );

                     else
                          -- call in payroll interpreter in effctive date mode
                          -- payroll exclude the from date data for proration purpose ,
                          --the interpreter developerd for proration
                          -- then used for reporting  so the functionality remains the same
                          -- we are passing -1 to make sure the from date data is included
                          hr_utility.set_location(' pay effectivedt mode ' ||(l_chg_eff_strt_dt-1) || ' / ' ||
                                                    l_chg_eff_end_dt  , 66 ) ;
                         ben_ext_util.entries_affected
                                (p_assignment_id          =>  l_pay_Assignment_id
                                ,p_event_group_id         =>  i.event_group_id
                                ,p_mode                   =>  NULL -- 'DATE_PROCESSED' -- 'DATE_EARNED' --
                                ,p_start_date             =>  (l_chg_eff_strt_dt-1)
                                  -- since the PDI use the exclisive of the start and end
                                ,p_end_date               =>  (l_chg_eff_end_dt)
                                ,p_business_group_id      =>  p_business_group_id
                                ,p_detailed_output        =>  l_pay_detail_tab
                                ,p_process_mode           =>  'ENTRY_EFFECTIVE_DATE'
                                ,p_penserv_mode           =>   p_penserv_mode    --vkodedal changes for penserver - 30-apr-2008
                                );
                      end if ;
                   Exception
                   WHEN hr_application_error THEN
                        -- the exception handled only when thge pqp raise the error with the msg
                        IF hr_utility.get_message = 'BEN_94629_NO_ASG_ACTION_ID' THEN
                           hr_utility.set_location( 'Current assignment has no Assignment Action id. ' ,-9999);
                           g_err_num  :=  94629 ;
                           g_err_name :=  'BEN_94629_NO_ASG_ACTION_ID' ;
                           g_elmt_name:=  null ;
                           raise detail_restart_error ;
                        else
                           hr_utility.set_location( 'unknow exception raised in ben_ext_util.entries_affected.',-9999);
                           raise; -- to re-raise the exception
                        end if ;
                   End ;

                   hr_utility.set_location( 'number of result  ' ||l_pay_detail_tab.count, 99 ) ;
                   if l_pay_detail_tab.count > 0 then

                      -- collect all the information onto a table for process for a person
                      FOR l_pay  IN l_pay_detail_tab.FIRST..l_pay_detail_tab.LAST
                      LOOP

                       hr_utility.set_location(' insertining tot '|| l_pay_tot_Srno|| ' / ' ||
                                                  l_pay_detail_tab(l_pay).column_name,99) ;

                          l_pay_detail_tot_tab(l_pay_tot_Srno).dated_table_id := l_pay_detail_tab(l_pay).dated_table_id ;
                          l_pay_detail_tot_tab(l_pay_tot_Srno).datetracked_event
                                                                :=l_pay_detail_tab(l_pay).datetracked_event ;
                          l_pay_detail_tot_tab(l_pay_tot_Srno).update_type    := l_pay_detail_tab(l_pay).update_type ;
                          l_pay_detail_tot_tab(l_pay_tot_Srno).surrogate_key  := l_pay_detail_tab(l_pay).surrogate_key ;
                          l_pay_detail_tot_tab(l_pay_tot_Srno).column_name    := l_pay_detail_tab(l_pay).column_name ;
                          l_pay_detail_tot_tab(l_pay_tot_Srno).effective_date := l_pay_detail_tab(l_pay).effective_date ;
                          l_pay_detail_tot_tab(l_pay_tot_Srno).old_value      := l_pay_detail_tab(l_pay).old_value ;
                          l_pay_detail_tot_tab(l_pay_tot_Srno).new_value      := l_pay_detail_tab(l_pay).new_value ;
                          l_pay_detail_tot_tab(l_pay_tot_Srno).change_values  := l_pay_detail_tab(l_pay).change_values ;
                          l_pay_detail_tot_tab(l_pay_tot_Srno).proration_type := l_pay_detail_tab(l_pay).proration_type ;
                          l_pay_detail_tot_tab(l_pay_tot_Srno).change_mode    := l_pay_detail_tab(l_pay).change_mode ;
                          l_pay_detail_tot_tab(l_pay_tot_Srno).event_group_id := i.event_group_id ;
                          l_pay_detail_tot_tab(l_pay_tot_Srno).actual_date    := l_pay_detail_tab(l_pay).creation_date;
                          l_pay_tot_Srno := l_pay_tot_Srno + 1  ;

                          --- find the unique column for  global colection for a person
                          l_g_c_found := 'N' ;
                          for l_g_c IN  1 .. g_pay_evt_group_tab.count
                          Loop
                             if  g_pay_evt_group_tab(l_g_c).dated_table_id = l_pay_detail_tab(l_pay).dated_table_id and
                                 g_pay_evt_group_tab(l_g_c).column_name    = l_pay_detail_tab(l_pay).column_name    and
                                 g_pay_evt_group_tab(l_g_c).event_group_id = i.event_group_id  then
                                 l_g_c_found := 'Y' ;
                                 exit ;
                             end if ;
                          End loop ;
                          -- if the value not already exist
                          if  l_g_c_found = 'N' then
                              hr_utility.set_location('insertining GL '||l_pay_evt_srno||' / '||
                                                       l_pay_detail_tab(l_pay).column_name,99) ;
                              g_pay_evt_group_tab(l_pay_evt_srno).dated_table_id:=l_pay_detail_tab(l_pay).dated_table_id ;
                              g_pay_evt_group_tab(l_pay_evt_srno).column_name := l_pay_detail_tab(l_pay).column_name    ;
                              g_pay_evt_group_tab(l_pay_evt_srno).event_group_id := i.event_group_id  ;
                              l_pay_evt_srno := l_pay_evt_srno + 1 ;
                          end if ;
                       End Loop ;
                   End if ;
                End If; --- adv criteria

            End Loop  ;
         End if ; -- asg id is not null
      end loop ;  -- multiple asg id
      --- sor the table value

      -- reintialise the global
      init_assignment_id(p_person_id      =>  p_person_id ,
                           p_effective_date =>  p_effective_date) ;


      ben_ext_payroll_balance.sort_payroll_events
            (p_pay_events_tab => l_pay_detail_tot_tab  ) ;

      -- process the collected  nformation  for a person
      hr_utility.set_location( 'number of sorted  result  ' ||g_pay_proc_evt_tab.count, 99 ) ;
      if g_pay_proc_evt_tab.count > 0 then
          FOR l_pay  IN 1 .. g_pay_proc_evt_tab.count
          LOOP
              init_detail_globals;

              hr_utility.set_location( ' column name   ' ||g_pay_proc_evt_tab(l_pay).column_name
                                                         ||' / '||g_pay_proc_evt_tab(l_pay).dated_table_id , 99 );

              l_dated_table_id      :=  g_pay_proc_evt_tab(l_pay).dated_table_id   ;
              g_chg_pay_column      :=  g_pay_proc_evt_tab(l_pay).column_name      ;
              g_chg_eff_dt          :=  g_pay_proc_evt_tab(l_pay).effective_date   ;
              g_chg_old_val1        :=  g_pay_proc_evt_tab(l_pay).old_value        ;
              g_chg_new_val1        :=  g_pay_proc_evt_tab(l_pay).new_value        ;
              g_chg_evt_cd          :=  g_pay_proc_evt_tab(l_pay).event_group_id   ;
              g_chg_pay_mode        :=  g_pay_proc_evt_tab(l_pay).change_mode      ;
              g_chg_update_type     :=  g_pay_proc_evt_tab(l_pay).update_type     ;
              g_chg_surrogate_key   :=  g_pay_proc_evt_tab(l_pay).surrogate_key   ;
              g_chg_next_event_date :=  g_pay_proc_evt_tab(l_pay).next_evt_start_date ;
              g_chg_actl_dt         :=  g_pay_proc_evt_tab(l_pay).actual_date  ;
              g_chg_pay_evt_index   :=  l_pay   ;

              hr_utility.set_location(' pay chg index '||g_chg_pay_evt_index,99) ;
              hr_utility.set_location('date and end date '||g_person_id||'-'||g_chg_eff_dt||'/'||
                                      g_chg_next_event_date,99) ;
              g_chg_evt_source := 'PAY' ;
              ben_ext_util.get_ext_dates
                         (p_ext_dfn_id    => p_ext_dfn_id,
                          p_data_typ_cd   => p_data_typ_cd,
                          p_effective_date  => g_effective_date,
                          p_person_ext_dt => l_person_ext_dt,  --out
                          p_benefits_ext_dt => l_benefits_ext_dt); -- out
                --
              g_person_ext_dt := l_person_ext_dt;
              g_benefits_ext_dt := l_benefits_ext_dt;

              --determine the table name from the id
              if l_dated_table_id is not null  then
                 open  c_pay_chg_tbl(l_dated_table_id) ;
                 fetch c_pay_chg_tbl into g_chg_pay_table  ;
                 close c_pay_chg_tbl ;
              end if ;

              l_include := 'Y';
              --
              if p_ext_crit_prfl_id is not null THEN
                --
                ben_ext_evaluate_inclusion.evaluate_change_log_incl
                        (p_chg_evt_cd        => g_chg_evt_cd,
                         p_chg_evt_source    => g_chg_evt_source,
                         p_chg_eff_dt        => trunc(g_chg_eff_dt),
                         p_chg_actl_dt       => trunc(g_chg_actl_dt) ,
                         p_last_update_login => null ,
                         p_effective_date    => g_effective_date,
                         p_include           => l_include);
                --
              end if;  -- p_ext_crit_prfl_id is not null
              --
              hr_utility.set_location( ' Inclusion  flag ' || l_include , 99 ) ;
              hr_utility.set_location( '  actual  ' || g_chg_actl_dt  , 99 ) ;
              hr_utility.set_location( '  efective   ' || g_chg_eff_dt  , 99 ) ;

              if l_include = 'Y' then
                 --

                 Extract_person_info(p_person_id          =>  p_person_id,
                               p_effective_date     =>  p_effective_date,  -- passed in from conc mgr
                               p_business_group_id  =>  p_business_group_id,
                               p_ext_rslt_id        =>  p_ext_rslt_id
                               ) ;
                 --
                 if p_ext_crit_prfl_id is not null THEN
                    --
                    ben_ext_evaluate_inclusion.Evaluate_Person_Incl
                              (p_person_id       => p_person_id,
                               p_postal_code     => g_prim_postal_code,
                               p_org_id          => g_employee_organization_id,
                               p_loc_id          => g_location_id,
                               p_gre             => null,  -- this will be fetched in called program.
                               p_state           => g_prim_state,
                               p_bnft_grp        => g_benefit_group_id,
                               p_ee_status       => g_employee_status_id,
                               p_chg_evt_cd      => g_chg_evt_cd,
                               p_chg_evt_source  => g_chg_evt_source,
                               p_effective_date  => g_person_ext_dt,
                               --RCHASE
                               p_eff_date        => trunc(g_chg_eff_dt),
                               --End RCHASE
                               p_actl_date       => trunc(g_chg_actl_dt),
                               p_include         => l_include);
                  --
                 end if;  -- p_ext_crit_prfl_id is not null
                  --
              end if; -- l_include = 'Y'
              --
              if l_include = 'Y' THEN
                 if g_debug then
                    hr_utility.set_location(' Change Event Code ' || g_chg_evt_cd , 99 );
                 end if;
                 g_rcd_seq := 1;
                 --
                 if nvl(ben_extract.g_spcl_hndl_flag,'X') <> 'Y' then -- normal processing
                    --
                    process_ext_levels(
                                   p_person_id         => p_person_id,
                                   p_ext_rslt_id       => p_ext_rslt_id,
                                   p_ext_file_id       => p_ext_file_id,
                                   p_data_typ_cd       => p_data_typ_cd,
                                   p_ext_typ_cd        => p_ext_typ_cd,
                                   p_business_group_id => p_business_group_id,
                                   p_effective_date    => g_effective_date
                                  );
                  else -- special handling flag tells us that it is an ansi 834 extract.
                     --
                     ben_ext_ansi.main(
                                   p_person_id         => p_person_id,
                                   p_ext_rslt_id       => p_ext_rslt_id,
                                   p_ext_file_id       => p_ext_file_id,
                                   p_data_typ_cd       => p_data_typ_cd,
                                   p_ext_typ_cd        => p_ext_typ_cd,
                                   p_ext_crit_prfl_id  => p_ext_crit_prfl_id,
                                   p_business_group_id => p_business_group_id,
                                   p_effective_date    => g_benefits_ext_dt
                                  );
                  end if;
                  --
                  g_trans_num := g_trans_num + 1;
                  --
              END IF;   -- l_include = 'Y'

          END LOOP;   -- collection loop
     End if ;    -- count total collection  return
     -- clear the table for next person
     l_pay_detail_tot_tab.delete ;
     g_pay_evt_group_tab.delete  ;

  end if ;    --- for pay eventi process

 -- ==========================================
 -- Communication Extract
 -- ==========================================
 --
 ELSIF p_data_typ_cd = 'CM' THEN
  --
  g_cm_flag   := 'Y';
  --
  g_trans_num := 1;
  --
  ben_ext_util.get_cm_dates
          (p_ext_dfn_id => ben_extract.g_ext_dfn_id, --in
           p_effective_date => g_effective_date, --in
           p_to_be_sent_strt_dt => l_to_be_sent_strt_dt, --out
           p_to_be_sent_end_dt => l_to_be_sent_end_dt); --out

  --- Communication cursor changed to three cursors and a bulk collect
  --- there is a remote possibility this may fetch  lesser row due to
  --- changes in external joints , 1 communication can have more trigger if it is manual
  --- since we generate 1 communication on extract row, we do not need to worry

  --
  open c_communication_extract (l_to_be_sent_strt_dt,
                                l_to_be_sent_end_dt);
  fetch c_communication_extract bulk collect into
        l_per_cm_id_va               ,
        l_per_in_ler_id_va           ,
        l_prtt_enrt_actn_id_va       ,
        l_effective_start_date_va    ,
        l_per_cm_eff_start_date_va   ,
        l_to_be_sent_dt_va           ,
        l_sent_dt_va                 ,
        l_per_cm_last_update_date_va ,
        l_last_update_date_va        ,
        l_dlvry_instn_txt_va         ,
        l_inspn_rqd_flag_va          ,
        l_address_id_va              ,
        l_per_cm_prvdd_id_va         ,
        l_object_version_number_va   ,
        l_cm_typ_id_va
   ;

  close c_communication_extract ;

  for i  IN  1  .. l_per_cm_id_va.count
  --
  LOOP
     --
     init_detail_globals;

     g_per_cm_id                :=  l_per_cm_id_va(i) ;
     g_cm_per_in_ler_id         :=  l_per_in_ler_id_va(i) ;
     g_cm_prtt_enrt_actn_id     :=  l_prtt_enrt_actn_id_va(i) ;
     g_cm_eff_dt                :=  nvl(l_effective_start_date_va(i),l_per_cm_eff_start_date_va(i) ) ;
     g_cm_to_be_sent_dt         :=  l_to_be_sent_dt_va(i) ;
     g_cm_sent_dt               :=  l_sent_dt_va(i) ;
     g_cm_last_update_date      :=  l_per_cm_last_update_date_va(i) ;
     g_cm_pvdd_last_update_date :=  l_last_update_date_va(i) ;
     g_cm_dlvry_instn_txt       :=  l_dlvry_instn_txt_va(i) ;
     g_cm_inspn_rqd_flag        :=  l_inspn_rqd_flag_va(i) ;
     g_cm_address_id            :=  l_address_id_va(i) ;
     g_per_cm_prvdd_id          :=  l_per_cm_prvdd_id_va(i) ;
     g_per_cm_object_version_number := l_object_version_number_va(i) ;
     g_cm_prvdd_eff_dt          :=  l_effective_start_date_va(i) ;
     g_cm_type_id               :=  l_cm_typ_id_va (i) ;



     --- get the trigger date from person commu trigger
     l_cm_trgr_id := null ;
     open c_per_comm_trigger (g_per_cm_id , p_effective_date) ;
     fetch c_per_comm_trigger into g_cm_trgr_proc_dt, l_cm_trgr_id ;
     close c_per_comm_trigger ;

     --- communication trigger setup information

     if l_cm_trgr_id is not null then
        open c_comm_trgr (l_cm_trgr_id) ;
        fetch c_comm_trgr into g_cm_trgr_proc_name ;
        close c_comm_trgr ;
     end if ;

     --- communication type information
     open c_comm_typ (l_cm_typ_id_va(i) , g_cm_eff_dt) ;
     fetch c_comm_typ into
          g_cm_type  ,
          g_cm_short_name ,
          g_cm_kit
     ;
     close c_comm_typ ;

     --- life event information

     if l_per_in_ler_id_va(i) is not null then
        open c_pil (l_per_in_ler_id_va(i) , g_cm_eff_dt ) ;
        fetch c_pil into  g_cm_lf_evt_id
                        ,g_cm_lf_evt
                        ,g_cm_lf_evt_stat
                        ,g_cm_lf_evt_ocrd_dt
                        ,g_cm_lf_evt_ntfn_dt
        ;
        close c_pil ;

        if g_cm_lf_evt_ocrd_dt is null and l_per_cm_eff_start_date_va(i) is not null then
           g_cm_lf_evt_ocrd_dt := l_per_cm_eff_start_date_va(i) ;
        end if ;

        if g_cm_lf_evt_ntfn_dt is null and l_per_cm_eff_start_date_va(i) is not null then
           g_cm_lf_evt_ntfn_dt := l_per_cm_eff_start_date_va(i) ;
        end if ;

     end if ;

     g_detail_extracted:=false;
     --
     --g_extract_date := g_cm_eff_dt;
     --
     ben_ext_util.get_ext_dates
          (p_ext_dfn_id    => p_ext_dfn_id,
           p_data_typ_cd   => p_data_typ_cd,
           p_effective_date  => g_effective_date,
           p_person_ext_dt => l_person_ext_dt,  --out
           p_benefits_ext_dt => l_benefits_ext_dt); -- out
     --
     g_person_ext_dt := l_person_ext_dt;
     g_benefits_ext_dt := l_benefits_ext_dt;
     --
     l_include := 'Y';
     --
     if p_ext_crit_prfl_id is not null THEN
       --
       ben_ext_evaluate_inclusion.evaluate_comm_incl
         (p_cm_typ_id        => g_cm_type_id,
          p_last_update_date => g_cm_last_update_date,
          p_pvdd_last_update_date => g_cm_pvdd_last_update_date,
          p_sent_dt          => g_cm_sent_dt,
          p_to_be_sent_dt    => g_cm_to_be_sent_dt,
          p_effective_date   => g_effective_date,
          p_include          => l_include);
       --
     end if;  -- p_ext_crit_prfl_id is not null
     --
     if l_include = 'Y' then
       --
        Extract_person_info(p_person_id          =>  p_person_id,
                           p_effective_date     =>  p_effective_date,  -- passed in from conc mgr
                           p_business_group_id  =>  p_business_group_id ,
                           p_ext_rslt_id        =>  p_ext_rslt_id
                           ) ;
       --
       --
       if p_ext_crit_prfl_id is not null THEN
       --
         ben_ext_evaluate_inclusion.Evaluate_Person_Incl
                     (p_person_id       => p_person_id,
                      p_postal_code     => g_prim_postal_code,
                      p_org_id          => g_employee_organization_id,
                      p_loc_id          => g_location_id,
                      p_gre             => null,  -- this will be fetched in called program.
                      p_state           => g_prim_state,
                      p_bnft_grp        => g_benefit_group_id,
                      p_ee_status       => g_employee_status_id,
                      p_chg_evt_cd      => null,
                      p_effective_date  => g_person_ext_dt,
                      p_actl_date       => null,
                      p_include         => l_include);
       --
       end if;  -- p_ext_crit_prfl_id is not null
       --
     end if; -- l_include = 'Y'
     --
     IF l_include = 'Y' THEN
       --
       g_rcd_seq := 1;
       --
       if nvl(ben_extract.g_spcl_hndl_flag,'X') <> 'Y' then -- normal processing
         --
         process_ext_levels(
                          p_person_id         => p_person_id,
                          p_ext_rslt_id       => p_ext_rslt_id,
                          p_ext_file_id       => p_ext_file_id,
                          p_data_typ_cd       => p_data_typ_cd,
                          p_ext_typ_cd        => p_ext_typ_cd,
                          p_business_group_id => p_business_group_id,
                          p_effective_date    => g_effective_date
                         );
       else -- special handling flag tells us that it is an ansi 834 extract.
         --
         ben_ext_ansi.main(
                          p_person_id         => p_person_id,
                          p_ext_rslt_id       => p_ext_rslt_id,
                          p_ext_file_id       => p_ext_file_id,
                          p_data_typ_cd       => p_data_typ_cd,
                          p_ext_typ_cd        => p_ext_typ_cd,
                          p_ext_crit_prfl_id  => p_ext_crit_prfl_id,
                          p_business_group_id => p_business_group_id,
                          p_effective_date    => g_benefits_ext_dt
                         );
       end if;
       --
       g_trans_num := g_trans_num + 1;
       --
     END IF;   -- l_include = 'Y'
--
   -- updating ben_per_cm_prvdd_f.sent_dt
   --
   if (ben_ext_person.g_cm_flag = 'Y' and
     ben_ext_person.g_upd_cm_sent_dt_flag = 'Y' and
     ben_ext_person.g_per_cm_prvdd_id is not null and
     g_detail_extracted) then
     if nvl(l_last_per_cm_prvdd_id,-1) <> ben_ext_person.g_per_cm_prvdd_id then
       ben_PER_CM_PRVDD_api.update_PER_CM_PRVDD
       (p_validate            => null,
        p_per_cm_prvdd_id     => ben_ext_person.g_per_cm_prvdd_id,
        p_effective_start_date=> l_dummy_start_date,
        p_effective_end_date  => l_dummy_end_date,
        p_sent_dt             => trunc(sysdate),
        p_object_version_number=>ben_ext_person.g_per_cm_object_version_number,
        p_effective_date      => ben_ext_person.g_cm_prvdd_eff_dt,
        p_datetrack_mode      => 'CORRECTION');
       l_last_per_cm_prvdd_id:=ben_ext_person.g_per_cm_prvdd_id;
     end if;
   end if;

   END LOOP;

   --fixed bug 7323551--invalid cursor
  -- close c_communication_extract;
  -- ==================================
  -- Comp work bench  CWB
  -- ================================
 ELSIF p_data_typ_cd = 'CW' THEN

     g_trans_num := 1;
   --
   init_detail_globals;
   --
   for l_cwb in  c_cwb_extract
   Loop
       g_CWB_EFFECTIVE_DATE          := l_cwb.effective_date  ;
       g_CWB_LE_DT                   := l_cwb.LF_EVT_OCRD_DT  ;
       hr_utility.set_location('cwb person ' || l_cwb.person_id , 99 ) ;
       ben_ext_util.get_ext_dates
          (p_ext_dfn_id      => p_ext_dfn_id,
           p_data_typ_cd     => p_data_typ_cd,
           p_effective_date  => g_effective_date,
           p_person_ext_dt   => l_person_ext_dt,  --out
           p_benefits_ext_dt => l_benefits_ext_dt); -- out
       --
       g_person_ext_dt := l_person_ext_dt;
       g_benefits_ext_dt := l_benefits_ext_dt;
       --
       l_include := 'Y';
       --
       if p_ext_crit_prfl_id is not null THEN
         --
         ben_ext_evaluate_inclusion.evaluate_cwb_incl
            (p_group_pl_id      =>  l_cwb.group_pl_id ,
             p_lf_evt_ocrd_dt   =>  g_CWB_LE_DT       ,
             p_include          =>  l_include         ,
             p_effective_date   =>  p_effective_date   )
            ;
         --
       end if;  -- p_ext_crit_prfl_id is not null
       --
       if l_include = 'Y' then
          -- change the busines  group of person
          g_business_group_id   := l_cwb.business_group_id ;

          Extract_person_info(p_person_id       =>  p_person_id,
                           p_effective_date     =>  p_effective_date,  -- passed in from conc mgr
                           p_business_group_id  =>  l_cwb.business_group_id,
                           p_ext_rslt_id        =>  p_ext_rslt_id
                           ) ;
          --
          --
            --
          if p_ext_crit_prfl_id is not null THEN
          --
            ben_ext_evaluate_inclusion.Evaluate_Person_Incl
                     (p_person_id       => p_person_id,
                      p_postal_code     => g_prim_postal_code,
                      p_org_id          => g_employee_organization_id,
                      p_loc_id          => g_location_id,
                      p_gre             => null,  -- this will be fetched in called program.
                      p_state           => g_prim_state,
                      p_bnft_grp        => g_benefit_group_id,
                      p_ee_status       => g_employee_status_id,
                      p_chg_evt_cd      => null,
                      p_effective_date  => g_person_ext_dt,
                      p_actl_date       => null,
                      p_include         => l_include);
          --
          end if;  -- p_ext_crit_prfl_id is not null
       end if ;

       if l_include = 'Y' then

          ---- Assign CWB  Variables
          g_cwb_per_group_per_in_ler_id      :=    l_cwb.group_per_in_ler_id ;
          g_cwb_per_group_pl_id              :=    l_cwb.group_pl_id  ;
          g_CWB_Person_FULL_NAME             :=    l_cwb.FULL_NAME ;
          g_CWB_Person_Custom_Name           :=    l_cwb.Custom_Name;
          g_CWB_Person_Brief_Name            :=    l_cwb.Brief_Name;
          g_CWB_Life_Event_Name              :=    l_cwb.Ler_name;
          g_CWB_Life_Event_Occurred_Date     :=    l_cwb.LF_EVT_OCRD_DT;
          g_CWB_Person_EMAIL_DDRESS          :=    l_cwb.EMAIL_ADDRESS;
          g_CWB_Person_EMPLOYEE_NUMBER       :=    l_cwb.EMPLOYEE_NUMBER;
          g_CWB_Person_BASE_SALARY           :=    l_cwb.BASE_SALARY;
          g_CWB_Person_CHANGE_REASON         :=    l_cwb.CHANGE_REASON;
          g_CWB_PEOPLE_GROUP_NAME            :=    l_cwb.PEOPLE_GROUP_name;
          g_CWB_PEOPLE_GROUP_SEGMENT1        :=    l_cwb.PEOPLE_GROUP_SEGMENT1;
          g_CWB_PEOPLE_GROUP_SEGMENT10       :=    l_cwb.PEOPLE_GROUP_SEGMENT10;
          g_CWB_PEOPLE_GROUP_SEGMENT11       :=    l_cwb.PEOPLE_GROUP_SEGMENT11;
          g_CWB_PEOPLE_GROUP_SEGMENT2        :=    l_cwb.PEOPLE_GROUP_SEGMENT2;
          g_CWB_PEOPLE_GROUP_SEGMENT3        :=    l_cwb.PEOPLE_GROUP_SEGMENT3;
          g_CWB_PEOPLE_GROUP_SEGMENT4        :=    l_cwb.PEOPLE_GROUP_SEGMENT4;
          g_CWB_PEOPLE_GROUP_SEGMENT5        :=    l_cwb.PEOPLE_GROUP_SEGMENT5;
          g_CWB_PEOPLE_GROUP_SEGMENT6        :=    l_cwb.PEOPLE_GROUP_SEGMENT6;
          g_CWB_PEOPLE_GROUP_SEGMENT7        :=    l_cwb.PEOPLE_GROUP_SEGMENT7;
          g_CWB_PEOPLE_GROUP_SEGMENT8        :=    l_cwb.PEOPLE_GROUP_SEGMENT8;
          g_CWB_PEOPLE_GROUP_SEGMENT9        :=    l_cwb.PEOPLE_GROUP_SEGMENT9;
          g_CWB_Person_BASE_SALARY_FREQ      :=    l_cwb.BASE_SALARY_FREQUENCY;
          g_CWB_Person_POST_PROCESS_Stat     :=    l_cwb.POST_PROCESS_Stat_cd;
          g_CWB_Person_START_DATE            :=    l_cwb.START_DATE;
          g_CWB_Person_ADJUSTED_SVC_DATE     :=    l_cwb.ADJUSTED_SVC_DATE;
          g_CWB_Person_Assg_ATTRIBUTE1       :=    l_cwb.Ass_ATTRIBUTE1;
          g_CWB_Person_Assg_ATTRIBUTE2       :=    l_cwb.Ass_ATTRIBUTE2;
          g_CWB_Person_Assg_ATTRIBUTE3       :=    l_cwb.Ass_ATTRIBUTE3;
          g_CWB_Person_Assg_ATTRIBUTE4       :=    l_cwb.Ass_ATTRIBUTE4;
          g_CWB_Person_Assg_ATTRIBUTE5       :=    l_cwb.Ass_ATTRIBUTE5;
          g_CWB_Person_Assg_ATTRIBUTE6       :=    l_cwb.Ass_ATTRIBUTE6;
          g_CWB_Person_Assg_ATTRIBUTE7       :=    l_cwb.Ass_ATTRIBUTE7;
          g_CWB_Person_Assg_ATTRIBUTE8       :=    l_cwb.Ass_ATTRIBUTE8;
          g_CWB_Person_Assg_ATTRIBUTE9       :=    l_cwb.Ass_ATTRIBUTE9;
          g_CWB_Person_Assg_ATTRIBUTE10      :=    l_cwb.Ass_ATTRIBUTE10;
          g_CWB_Person_Assg_ATTRIBUTE11      :=    l_cwb.Ass_ATTRIBUTE11;
          g_CWB_Person_Assg_ATTRIBUTE12      :=    l_cwb.Ass_ATTRIBUTE12;
          g_CWB_Person_Assg_ATTRIBUTE13      :=    l_cwb.Ass_ATTRIBUTE13;
          g_CWB_Person_Assg_ATTRIBUTE14      :=    l_cwb.Ass_ATTRIBUTE14;
          g_CWB_Person_Assg_ATTRIBUTE15      :=    l_cwb.Ass_ATTRIBUTE15;
          g_CWB_Person_Assg_ATTRIBUTE16      :=    l_cwb.Ass_ATTRIBUTE16;
          g_CWB_Person_Assg_ATTRIBUTE17      :=    l_cwb.Ass_ATTRIBUTE17;
          g_CWB_Person_Assg_ATTRIBUTE18      :=    l_cwb.Ass_ATTRIBUTE18;
          g_CWB_Person_Assg_ATTRIBUTE19      :=    l_cwb.Ass_ATTRIBUTE19;
          g_CWB_Person_Assg_ATTRIBUTE20      :=    l_cwb.Ass_ATTRIBUTE20;
          g_CWB_Person_Assg_ATTRIBUTE21      :=    l_cwb.Ass_ATTRIBUTE21;
          g_CWB_Person_Assg_ATTRIBUTE22      :=    l_cwb.Ass_ATTRIBUTE22;
          g_CWB_Person_Assg_ATTRIBUTE23      :=    l_cwb.Ass_ATTRIBUTE23;
          g_CWB_Person_Assg_ATTRIBUTE24      :=    l_cwb.Ass_ATTRIBUTE24;
          g_CWB_Person_Assg_ATTRIBUTE25      :=    l_cwb.Ass_ATTRIBUTE25;
          g_CWB_Person_Assg_ATTRIBUTE26      :=    l_cwb.Ass_ATTRIBUTE26;
          g_CWB_Person_Assg_ATTRIBUTE27      :=    l_cwb.Ass_ATTRIBUTE27;
          g_CWB_Person_Assg_ATTRIBUTE28      :=    l_cwb.Ass_ATTRIBUTE28;
          g_CWB_Person_Assg_ATTRIBUTE29      :=    l_cwb.Ass_ATTRIBUTE29;
          g_CWB_Person_Assg_ATTRIBUTE30      :=    l_cwb.Ass_ATTRIBUTE30;
          g_CWB_Person_Info_ATTRIBUTE1       :=    l_cwb.CPI_ATTRIBUTE1;
          g_CWB_Person_Info_ATTRIBUTE2       :=    l_cwb.CPI_ATTRIBUTE2;
          g_CWB_Person_Info_ATTRIBUTE3       :=    l_cwb.CPI_ATTRIBUTE3;
          g_CWB_Person_Info_ATTRIBUTE4       :=    l_cwb.CPI_ATTRIBUTE4;
          g_CWB_Person_Info_ATTRIBUTE5       :=    l_cwb.CPI_ATTRIBUTE5;
          g_CWB_Person_Info_ATTRIBUTE6       :=    l_cwb.CPI_ATTRIBUTE6;
          g_CWB_Person_Info_ATTRIBUTE7       :=    l_cwb.CPI_ATTRIBUTE7;
          g_CWB_Person_Info_ATTRIBUTE8       :=    l_cwb.CPI_ATTRIBUTE8;
          g_CWB_Person_Info_ATTRIBUTE9       :=    l_cwb.CPI_ATTRIBUTE9;
          g_CWB_Person_Info_ATTRIBUTE10      :=    l_cwb.CPI_ATTRIBUTE10;
          g_CWB_Person_Info_ATTRIBUTE11      :=    l_cwb.CPI_ATTRIBUTE11;
          g_CWB_Person_Info_ATTRIBUTE12      :=    l_cwb.CPI_ATTRIBUTE12;
          g_CWB_Person_Info_ATTRIBUTE13      :=    l_cwb.CPI_ATTRIBUTE13;
          g_CWB_Person_Info_ATTRIBUTE14      :=    l_cwb.CPI_ATTRIBUTE14;
          g_CWB_Person_Info_ATTRIBUTE15      :=    l_cwb.CPI_ATTRIBUTE15;
          g_CWB_Person_Info_ATTRIBUTE16      :=    l_cwb.CPI_ATTRIBUTE16;
          g_CWB_Person_Info_ATTRIBUTE17      :=    l_cwb.CPI_ATTRIBUTE17;
          g_CWB_Person_Info_ATTRIBUTE18      :=    l_cwb.CPI_ATTRIBUTE18;
          g_CWB_Person_Info_ATTRIBUTE19      :=    l_cwb.CPI_ATTRIBUTE19;
          g_CWB_Person_Info_ATTRIBUTE20      :=    l_cwb.CPI_ATTRIBUTE20;
          g_CWB_Person_Info_ATTRIBUTE21      :=    l_cwb.CPI_ATTRIBUTE21;
          g_CWB_Person_Info_ATTRIBUTE22      :=    l_cwb.CPI_ATTRIBUTE22;
          g_CWB_Person_Info_ATTRIBUTE23      :=    l_cwb.CPI_ATTRIBUTE23;
          g_CWB_Person_Info_ATTRIBUTE24      :=    l_cwb.CPI_ATTRIBUTE24;
          g_CWB_Person_Info_ATTRIBUTE25      :=    l_cwb.CPI_ATTRIBUTE25;
          g_CWB_Person_Info_ATTRIBUTE26      :=    l_cwb.CPI_ATTRIBUTE26;
          g_CWB_Person_Info_ATTRIBUTE27      :=    l_cwb.CPI_ATTRIBUTE27;
          g_CWB_Person_Info_ATTRIBUTE28      :=    l_cwb.CPI_ATTRIBUTE28;
          g_CWB_Person_Info_ATTRIBUTE29      :=    l_cwb.CPI_ATTRIBUTE29;
          g_CWB_Person_Info_ATTRIBUTE30      :=    l_cwb.CPI_ATTRIBUTE30;
          g_CWB_Person_CUSTOM_SEGMENT1       :=    l_cwb.CUSTOM_SEGMENT1;
          g_CWB_Person_CUSTOM_SEGMENT2       :=    l_cwb.CUSTOM_SEGMENT2;
          g_CWB_Person_CUSTOM_SEGMENT3       :=    l_cwb.CUSTOM_SEGMENT3;
          g_CWB_Person_CUSTOM_SEGMENT4       :=    l_cwb.CUSTOM_SEGMENT4;
          g_CWB_Person_CUSTOM_SEGMENT5       :=    l_cwb.CUSTOM_SEGMENT5;
          g_CWB_Person_CUSTOM_SEGMENT6       :=    l_cwb.CUSTOM_SEGMENT6;
          g_CWB_Person_CUSTOM_SEGMENT7       :=    l_cwb.CUSTOM_SEGMENT7;
          g_CWB_Person_CUSTOM_SEGMENT8       :=    l_cwb.CUSTOM_SEGMENT8;
          g_CWB_Person_CUSTOM_SEGMENT9       :=    l_cwb.CUSTOM_SEGMENT9;
          g_CWB_Person_CUSTOM_SEGMENT10      :=    l_cwb.CUSTOM_SEGMENT10;
          g_CWB_Person_CUSTOM_SEGMENT11      :=    l_cwb.CUSTOM_SEGMENT11;
          g_CWB_Person_CUSTOM_SEGMENT13      :=    l_cwb.CUSTOM_SEGMENT12;
          g_CWB_Person_CUSTOM_SEGMENT14      :=    l_cwb.CUSTOM_SEGMENT13;
          g_CWB_Person_CUSTOM_SEGMENT12      :=    l_cwb.CUSTOM_SEGMENT14;
          g_CWB_Person_CUSTOM_SEGMENT15      :=    l_cwb.CUSTOM_SEGMENT15;
          g_CWB_Person_FEEDBACK_RATING       :=    l_cwb.FEEDBACK_RATING;
          g_CWB_Person_FREQUENCY             :=    l_cwb.FREQUENCY;
          g_CWB_Person_Grade_MAX_VAL         :=    l_cwb.GRD_MAX_VAL;
          g_CWB_Person_Grade_MID_POINT       :=    l_cwb.GRD_MID_POINT;
          g_CWB_Person_Grade_MIN_VAL         :=    l_cwb.GRD_MIN_VAL;
          g_CWB_Person_GRADE_ANN_FACTOR      :=    l_cwb.GRADE_ANNULIZATION_FACTOR;
          g_CWB_Person_Grade_COMPARATIO      :=    l_cwb.Grd_COMPARATIO;
          g_CWB_Person_LEGISLATION           :=    l_cwb.LEGISLATION_CODE;
          g_CWB_Person_NORMAL_HOURS          :=    l_cwb.NORMAL_HOURS;
          g_CWB_Person_ORIG_START_DATE       :=    l_cwb.ORIGINAL_START_DATE;
          g_CWB_Person_PAY_ANNUL_FACTOR      :=    l_cwb.PAY_ANNULIZATION_FACTOR;
          g_CWB_Person_SUP_BRIEF_NAME        :=    l_cwb.SUPERVISOR_BRIEF_NAME;
          g_CWB_Person_SUP_CUSTOM_NAME       :=    l_cwb.SUPERVISOR_CUSTOM_NAME;
          g_CWB_Person_SUP_FULL_NAME         :=    l_cwb.SUPERVISOR_FULL_NAME;
          g_CWB_Person_YEARS_EMPLOYED        :=    l_cwb.YEARS_EMPLOYED;
          g_CWB_Person_YEARS_IN_GRADE        :=    l_cwb.YEARS_IN_GRADE;
          g_CWB_Person_YEARS_IN_POS          :=    l_cwb.YEARS_IN_POSITION;
          g_CWB_Person_YEARS_IN_JOB          :=    l_cwb.YEARS_IN_JOB;
          g_CWB_Person_PAYROLL_NAME          :=    l_cwb.payroll_name ;

          --- business group name
          open  c_bg_name(l_cwb.business_group_id )  ;
          fetch c_bg_name into g_CWB_Person_BG_Name ;
          close c_bg_name ;

          open c_org_name(l_cwb.organization_id) ;
          fetch c_org_name into g_CWB_Person_ORG_name ;
          close c_org_name ;

          open c_job(l_Cwb.job_id) ;
          fetch c_job into g_CWB_Person_JOB_name ;
          close c_job  ;

          open c_loc(l_Cwb.location_id) ;
          fetch c_loc into g_CWB_Person_location ;
          close c_loc  ;

          open c_pos(l_Cwb.position_id) ;
          fetch c_pos into g_CWB_Person_POSITION ;
          close c_pos  ;

          open c_grade(l_Cwb.grade_id) ;
          fetch c_grade into g_CWB_Person_GRADE_name ;
          close c_grade  ;

          open c_payr(l_Cwb.pay_rate_id) ;
          fetch c_payr into g_CWB_Person_PAY_RATE ;
          close c_payr  ;

          open c_asg_status(l_cwb.ASSIGNMENT_STATUS_TYPE_ID) ;
          fetch c_asg_status into g_CWB_Person_STATUS_TYPE ;
          close c_asg_status ;

          open c_hr_lkup('EMP_CAT', l_cwb.EMP_CATEGORY) ;
          fetch c_hr_lkup into  g_CWB_Person_EMPloyee_CATEGORY ;
          close c_hr_lkup ;

          open c_hr_lkup('BEN_CWB_QUAR_IN_GRD', l_cwb.GRD_QUARTILE) ;
          fetch c_hr_lkup into  g_CWB_Person_Grade_QUARTILE ;
          close c_hr_lkup ;

          open c_hr_lkup('BEN_PER_IN_LER_STAT', l_cwb.PER_IN_LER_STAT_CD) ;
          fetch c_hr_lkup into  g_CWB_Life_Event_status ;
          close c_hr_lkup ;

          open  c_pln (g_cwb_per_group_pl_id , g_CWB_Life_Event_Occurred_Date );
          fetch c_pln into g_cwb_group_plan_name ;
          close c_pln ;

          --- from transaction table
          -- performance rating
          open c_tran( l_cwb.ASSIGNMENT_ID,
                     'CWBPERF'||to_char(l_cwb.PERF_REVW_STRT_DT ,'RRRR/MM/DD')||nvl(l_cwb.EMP_INTERVIEW_TYP_CD,'')
                     ) ;
          fetch c_tran into l_tran ;
          close c_tran ;
          if l_tran.ATTRIBUTE3 is not null then
             open c_hr_lkup('PERFORMANCE_RATING', l_tran.ATTRIBUTE3) ;
             fetch c_hr_lkup into  g_CWB_new_Perf_rating ;
             close c_hr_lkup ;
          end if ;
          g_CWB_Person_PERF_RATING_DATE      :=   l_cwb.PERF_REVW_STRT_DT ;
          if l_cwb.EMP_INTERVIEW_TYP_CD is not null then
             open c_hr_lkup('EMP_INTERVIEW_TYPE', l_cwb.EMP_INTERVIEW_TYP_CD) ;
             fetch c_hr_lkup into  g_CWB_Persom_PERF_RATING_TYPE ;
             close c_hr_lkup ;
          end if ;

          l_tran := null ;
           open c_tran( l_cwb.ASSIGNMENT_ID,
                     'CWBASG'||to_char(l_cwb.ASG_UPDT_EFF_DATE ,'RRRR/MM/DD'))
                      ;
          fetch c_tran into l_tran ;
          close c_tran ;

          if l_tran.ATTRIBUTE3 is not null then
             open c_hr_lkup('EMP_ASSIGN_REASON', l_tran.ATTRIBUTE3) ;
             fetch c_hr_lkup into  g_cwb_nw_chg_reason ;
             close c_hr_lkup ;
          end if ;

          if l_tran.ATTRIBUTE5 is not null then
             open c_job(l_tran.ATTRIBUTE5) ;
             fetch c_job into  g_CWB_new_Job_name ;
             close c_job ;
          end if ;

          if l_tran.ATTRIBUTE6 is not null then
             open c_pos(l_tran.ATTRIBUTE6) ;
             fetch c_pos into  g_CWB_new_Postion_name ;
             close c_pos ;
          end if ;

          if l_tran.ATTRIBUTE7 is not null then
             open c_grade(l_tran.ATTRIBUTE7) ;
             fetch c_grade into  g_CWB_new_Grade_name ;
             close c_grade ;
          end if ;

         if l_tran.ATTRIBUTE8 is not null then
             open c_groups(l_tran.ATTRIBUTE8) ;
             fetch c_groups into  g_CWB_new_Group_name ;
             close c_groups ;
          end if ;



          /*
           g_CWB_new_Group_name                  := null ;
          */

          ----
          g_rcd_seq := 1;
          --
          if nvl(ben_extract.g_spcl_hndl_flag,'X') <> 'Y' then -- normal processing
            --
            process_ext_levels(
                          p_person_id         => p_person_id,
                          p_ext_rslt_id       => p_ext_rslt_id,
                          p_ext_file_id       => p_ext_file_id,
                          p_data_typ_cd       => p_data_typ_cd,
                          p_ext_typ_cd        => p_ext_typ_cd,
                          p_business_group_id => p_business_group_id,
                          p_effective_date    => g_effective_date
                         );
          else -- special handling flag tells us that it is an ansi 834 extract.
            --
            ben_ext_ansi.main(
                          p_person_id         => p_person_id,
                          p_ext_rslt_id       => p_ext_rslt_id,
                          p_ext_file_id       => p_ext_file_id,
                          p_data_typ_cd       => p_data_typ_cd,
                          p_ext_typ_cd        => p_ext_typ_cd,
                          p_ext_crit_prfl_id  => p_ext_crit_prfl_id,
                          p_business_group_id => p_business_group_id,
                          p_effective_date    => g_benefits_ext_dt
                         );
          end if;
          --
          g_trans_num := g_trans_num + 1;
          --
       END IF;   -- l_include = 'Y'

   end loop ;



 END IF;    -- extract type

 if g_debug then
   hr_utility.set_location('Exiting'||l_proc, 15);
 end if;
 --
 EXCEPTION
  --
  WHEN detail_error THEN
    --
    ROLLBACK TO cur_transaction;
    l_err_message := ben_ext_fmt.get_error_msg(g_err_num,g_err_name,g_elmt_name ) ;
    if g_debug then
      hr_utility.set_location('err msg ' || l_err_message, 99.98 );
    end if;
    write_error(
                p_err_num     => g_err_num,
                p_err_name    => l_err_message,
                p_typ_cd      => 'E',
                p_request_id  => ben_extract.g_request_id,
                p_ext_rslt_id => p_ext_rslt_id
               );

  When  detail_restart_error then

    ROLLBACK TO cur_transaction;
    l_err_message := ben_ext_fmt.get_error_msg(g_err_num,g_err_name,g_elmt_name ) ;
    if g_debug then
      hr_utility.set_location('err msg ' || l_err_message, 99.98 );
    end if;
    write_error(
                p_err_num     => g_err_num,
                p_err_name    => l_err_message,
                p_typ_cd      => 'E',
                p_request_id  => ben_extract.g_request_id,
                p_ext_rslt_id => p_ext_rslt_id
               );
     Raise ;

  WHEN required_error THEN
    --
    ROLLBACK TO cur_transaction;

  WHEN Others THEN   --- any unexpted error

    ROLLBACK TO cur_transaction;
    -- just error the person and go ahead with other person
    -- the  log will be created in extract pkg , for only  no data found log
    -- error
    if  g_err_num = 94102 then
        l_err_message := ben_ext_fmt.get_error_msg(g_err_num,g_err_name) ;
        write_error(
                p_err_num     => g_err_num,
                p_err_name    => l_err_message,
                p_typ_cd      => 'E',
                p_request_id  => ben_extract.g_request_id,
                p_ext_rslt_id => p_ext_rslt_id
               );
    end if ;

    Raise ;   -- raise the exception to benxcrit


--
End process_ext_person;
--
-- ----------------------------------------------------------------------------
-- |------< process_ext_levels >----------------------------------------------|
-- ----------------------------------------------------------------------------
-- This procedure will process extract levels and call ben_ext_fmt.process_ext_recs
-- for each record level according to the extract definition.
--
-- For simplicity and due to the time constraint it is assummed that a given person
-- can only be a participant or a dependent (not both) as well as the fact that a
-- person can not be a dependent of more that one particiant for a particular plan.
-- This will mater only when dependendents are processed as people.
-- This restriction will be addressed in the future release.
--
Procedure process_ext_levels(
                             p_person_id          in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date
                            ) IS
--
  l_proc               varchar2(72);
--
  l_dummy              varchar2(30);
  l_rec_lvl_cd         varchar2(30);
  l_cursor_cd          varchar2(30);
  l_comp_incl          varchar2(1) := 'Y';
  l_rollback           boolean;
--
--
cursor purged_rslt_c (l_pl_id number) is
  select
            pl.name                  pl_name,
        --    opt.opt_id               opt_id,
        --    opt.name                 opt_name,
        --    enrt.enrt_cvg_strt_dt    cvg_strt_dt,
        --    enrt.enrt_cvg_thru_dt    cvg_thru_dt,
        --    enrt.bnft_amt            bnft_amt,
        --    enrt.pgm_id              pgm_id,
        --    pgm.name                 pgm_name,
            pl.pl_typ_id             pl_typ_id,
            ptp.name                 pl_typ_name
      from ben_pl_f                 pl,
        --   ben_oipl_f               oipl,
        --   ben_opt_f                opt,
        --   ben_pgm_f                pgm,
           ben_pl_typ_f             ptp
      where
           pl.pl_id  = l_pl_id
       and g_effective_date between pl.effective_start_date
                                and pl.effective_end_date
       --
       and pl.pl_typ_id = ptp.pl_typ_id
       and g_effective_date between nvl(ptp.effective_start_date, g_effective_date)
                                and nvl(ptp.effective_end_date, g_effective_date)
       ;

--
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'process_ext_levels';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
  --
  -- Initialize rollback flag.
  --
  l_rollback:=FALSE;

    if g_debug then
      hr_utility.set_location('ben_extract.g_per_lvl ' || ben_extract.g_per_lvl ,99 );
    end if;
  --
  IF ben_extract.g_per_lvl = 'Y' THEN
    --
    --  Process Personal Level Detail Records
    --
    --
    if g_debug then
      hr_utility.set_location(' ben_ext_fmt.process_ext_recs',99 );
    end if;
    ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                 p_ext_file_id       => p_ext_file_id,
                                 p_data_typ_cd       => p_data_typ_cd,
                                 p_ext_typ_cd        => p_ext_typ_cd,
                                 p_rcd_typ_cd        => 'D',
                                 p_low_lvl_cd        => 'P',
                                 p_person_id         => p_person_id,
                                 p_chg_evt_cd        => g_chg_evt_cd,
                                 p_business_group_id => p_business_group_id,
                                 p_effective_date    => g_effective_date
                                 );

    --
    --
  END IF;
  --
  -- create enrollment, dependent and beneficiary level rows
  -- =======================================================
  --RCHASE
  --IF nvl(g_chg_evt_cd, '*') <> 'TBBC' then
    --
    -- extract enrollment levels
    --
    IF (ben_extract.g_enrt_lvl = 'Y' OR ben_extract.g_dpnt_lvl = 'Y' OR ben_extract.g_bnf_lvl = 'Y' OR
        ben_extract.g_actn_lvl = 'Y' or ben_extract.g_prem_lvl = 'Y' ) THEN
    --
            if g_debug then
              hr_utility.set_location(' ben_ext_enrt.main',99 );
            end if;
            ben_ext_enrt.main(
                             p_person_id          => p_person_id,
                             p_ext_rslt_id        => p_ext_rslt_id,
                             p_ext_file_id        => p_ext_file_id,
                             p_data_typ_cd        => p_data_typ_cd,
                             p_ext_typ_cd         => p_ext_typ_cd,
                             p_chg_evt_cd         => g_chg_evt_cd,
                             p_business_group_id  => p_business_group_id,
                             p_effective_date     => g_benefits_ext_dt);
    END IF;
    --
  --
  --RCHASE
  --ELSIF nvl(g_chg_evt_cd, '*') = 'TBBC' and ben_extract.g_enrt_lvl = 'Y' then
  --
  --  open purged_rslt_c(g_chg_pl_id);
    --
  --   fetch purged_rslt_c into
  --   g_enrt_pl_name,
  --   g_enrt_pl_typ_id,
  --   g_enrt_pl_typ_name;
    --
  --  ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
  --                               p_ext_file_id       => p_ext_file_id,
  --                               p_data_typ_cd       => p_data_typ_cd,
  --                               p_ext_typ_cd        => p_ext_typ_cd,
  --                               p_rcd_typ_cd        => 'D',
  --                               p_low_lvl_cd        => 'E',
  --                               p_person_id         => p_person_id,
  --                               p_chg_evt_cd        => g_chg_evt_cd,
  --                               p_business_group_id => p_business_group_id,
  --                               p_effective_date    => g_effective_date
  --                              );
  --
  --END IF;  -- part type
  --
  -- create eligibility extract rows
  -- =========================================
  if ben_extract.g_elig_lvl = 'Y' or ben_extract.g_eligdpnt_lvl = 'Y' then
    --
    ben_ext_elig.main(
                          p_person_id         => p_person_id,
                          p_ext_rslt_id       => p_ext_rslt_id,
                          p_ext_file_id       => p_ext_file_id,
                          p_data_typ_cd       => p_data_typ_cd,
                          p_ext_typ_cd        => p_ext_typ_cd,
                          p_chg_evt_cd        => g_chg_evt_cd,
                          p_business_group_id => p_business_group_id,
                          p_effective_date    => g_benefits_ext_dt
                         );
    --
    --
  end if;
  --
  -- create flex credit extract rows
  -- =========================================
  if ben_extract.g_flex_lvl = 'Y' then
    --
    ben_ext_flcr.main(
                          p_person_id         => p_person_id,
                          p_ext_rslt_id       => p_ext_rslt_id,
                          p_ext_file_id       => p_ext_file_id,
                          p_data_typ_cd       => p_data_typ_cd,
                          p_ext_typ_cd        => p_ext_typ_cd,
                          p_chg_evt_cd        => g_chg_evt_cd,
                          p_business_group_id => p_business_group_id,
                          p_effective_date    => g_benefits_ext_dt
                         );
    --
    --
  end if;
  --
  -- create payroll extract rows
  -- ================================
  if ben_extract.g_payroll_lvl = 'Y' then
    --
    ben_ext_payroll.main(
                          p_person_id         => p_person_id,
                          p_ext_rslt_id       => p_ext_rslt_id,
                          p_ext_file_id       => p_ext_file_id,
                          p_data_typ_cd       => p_data_typ_cd,
                          p_ext_typ_cd        => p_ext_typ_cd,
                          p_chg_evt_cd        => g_chg_evt_cd,
                          p_business_group_id => p_business_group_id,
                          p_effective_date    => g_person_ext_dt
                         );
    --
  end if;
  --
  -- create run result extract rows
  -- ================================
  if ben_extract.g_runrslt_lvl = 'Y' then
    --
    ben_ext_runrslt.main(
                          p_person_id         => p_person_id,
                          p_ext_rslt_id       => p_ext_rslt_id,
                          p_ext_file_id       => p_ext_file_id,
                          p_data_typ_cd       => p_data_typ_cd,
                          p_ext_typ_cd        => p_ext_typ_cd,
                          p_chg_evt_cd        => g_chg_evt_cd,
                          p_business_group_id => p_business_group_id,
                          p_effective_date    => g_person_ext_dt
                         );
    --
  end if;
  --
  -- create contact extract rows
  -- ================================
  if ben_extract.g_contact_lvl = 'Y' then
    --
    ben_ext_contact.main(
                          p_person_id         => p_person_id,
                          p_ext_rslt_id       => p_ext_rslt_id,
                          p_ext_file_id       => p_ext_file_id,
                          p_data_typ_cd       => p_data_typ_cd,
                          p_ext_typ_cd        => p_ext_typ_cd,
                          p_chg_evt_cd        => g_chg_evt_cd,
                          p_business_group_id => p_business_group_id,
                          p_effective_date    => g_person_ext_dt
                         );
    --
  end if;

  --- cwb
 if p_data_typ_cd = 'CW' THEN

    hr_utility.set_location( ' bdgt lvl ' || ben_extract.g_cwb_bdgt_lvl , 99 );

    if ben_extract.g_cwb_bdgt_lvl = 'Y' then
       ben_ext_cwb.extract_person_groups
                           ( p_person_id          => p_person_id,
                             p_per_in_ler_id      => g_cwb_per_group_per_in_ler_id,
                             p_ext_rslt_id        => p_ext_rslt_id,
                             p_ext_file_id        => p_ext_file_id,
                             p_data_typ_cd        => p_data_typ_cd,
                             p_ext_typ_cd         => p_ext_typ_cd,
                             p_business_group_id  => p_business_group_id,
                             p_effective_date     => g_person_ext_dt) ;
     end if ;

     if ben_extract.g_cwb_awrd_lvl = 'Y' then
          ben_ext_cwb.extract_person_rates
                           ( p_person_id          => p_person_id,
                             p_per_in_ler_id      => g_cwb_per_group_per_in_ler_id,
                             p_ext_rslt_id        => p_ext_rslt_id,
                             p_ext_file_id        => p_ext_file_id,
                             p_data_typ_cd        => p_data_typ_cd,
                             p_ext_typ_cd         => p_ext_typ_cd,
                             p_business_group_id  => p_business_group_id,
                             p_effective_date     => g_person_ext_dt) ;
     end if ;
end if ;


  --


  if ben_extract.g_otl_summ_lvl = 'Y' then

     hxc_ext_timecard.process_summary (
                         p_person_id          => p_person_id,
                         p_ext_rslt_id        => p_ext_rslt_id,
                         p_ext_file_id        => p_ext_file_id,
                         p_ext_crit_prfl_id   => NULL,
                         p_data_typ_cd        => p_data_typ_cd,
                         p_ext_typ_cd         => p_ext_typ_cd,
                         p_effective_date     => p_effective_date );

  end if;

  --
  /* this validation is done on low level , this is changed to do in record level
     this validation moved to benxfrmt.pkb
  FOR i in ben_extract.gtt_rcd_rqd_vals.first .. ben_extract.gtt_rcd_rqd_vals.last LOOP
  --
     IF NOT ben_extract.gtt_rcd_rqd_vals(i).rcd_found
     THEN
       l_rollback := TRUE;        -- raise required_error;
     ELSIF ben_extract.gtt_rcd_rqd_vals(1).low_lvl_cd <> 'NOREQDRCD'
     THEN
       ben_extract.gtt_rcd_rqd_vals(i).rcd_found := FALSE; -- reset the value
     END IF;
  --
  END LOOP;
  */


   -- validate the mandatory for low level in sequenc
   FOR i in ben_extract.gtt_rcd_rqd_vals_seq.first .. ben_extract.gtt_rcd_rqd_vals_seq.last LOOP
       --
      If NOT ben_extract.gtt_rcd_rqd_vals_seq(i).rcd_found THEN
          hr_utility.set_location('Mandatory failed '||ben_extract.gtt_rcd_rqd_vals_seq(i).low_lvl_cd || '  '||
                                                      ben_extract.gtt_rcd_rqd_vals_seq(i).seq_num , 15);
          l_rollback := TRUE;        -- raise required_error;
      end if ;
      if ben_extract.gtt_rcd_rqd_vals_seq(1).low_lvl_cd <> 'NOREQDRCD' then
         ben_extract.gtt_rcd_rqd_vals_seq(i).rcd_found := FALSE; -- reset the value
      end if ;
  END LOOP;
  --
  IF l_rollback
  THEN
    RAISE required_error;
  END IF;
  --
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
--
--
End process_ext_levels;
--
--
-- ----------------------------------------------------------------------------
-- |------< init_detail_globals >---------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure init_detail_globals IS
--
  l_proc               varchar2(72);
--
--
--
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'init_detail_globals';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
  --
  --
  --  personal (25)
  --
  g_chg_evt_cd               := null;
  g_chg_evt_source           := null;
  g_chg_actl_dt              := null;
  g_chg_eff_dt               := null;
  g_chg_pl_id                := null;
  g_chg_input_value_id       := null;
  g_chg_old_val1             := null;
  g_chg_old_val2             := null;
  g_chg_old_val3             := null;
  g_chg_old_val4             := null;
  g_chg_old_val5             := null;
  g_chg_old_val6             := null;
  g_chg_new_val1             := null;
  g_chg_new_val2             := null;
  g_chg_new_val3             := null;
  g_chg_new_val4             := null;
  g_chg_new_val5             := null;
  g_chg_new_val6             := null;
  g_chg_enrt_rslt_id         := null;
  g_chg_pl_id                := null;
  g_chg_pay_table            := null;
  g_chg_pay_column           := null;
  g_chg_pay_mode             := null;
  g_chg_update_type          := null;
  g_chg_surrogate_key        := null;
  g_chg_next_event_date      := null;
  g_chg_pay_evt_index        := null;
  --
  g_previous_last_name       := null;
  g_previous_first_name      := null;
  g_previous_middle_name     := null;
  g_previous_suffix          := null;
  g_previous_prefix          := null;
  g_previous_ssn             := null;
  g_previous_dob             := null;
  g_previous_sex             := null;
  --
  g_part_type                := null;
  g_per_rlshp_type           := null;
  g_part_ssn                 := null;
  --
  g_national_identifier      := null;
  g_last_name                := null;
  g_first_name               := null;
  g_middle_names             := null;
  g_full_name                := null;
  g_suffix                   := null;
  g_prefix                  := null;
  g_title                    := null;
  g_sex                      := null;
  g_date_of_birth            := null;
  g_data_verification_dt     := null;
  g_marital_status           := null;
  g_employee_category        := null;
  g_registered_disabled_flag := null;
  g_student_status           := null;
  g_date_of_death            := null;
  g_employee_number          := null;
  g_benefit_group_id         := null;
  g_benefit_group            := null;
  g_bng_flex_01          := null;
  g_bng_flex_02          := null;
  g_bng_flex_03          := null;
  g_bng_flex_04          := null;
  g_bng_flex_05          := null;
  g_bng_flex_06          := null;
  g_bng_flex_07          := null;
  g_bng_flex_08          := null;
  g_bng_flex_09          := null;
  g_bng_flex_10          := null;
  g_benefit_bal_vacation     := null;
  g_benefit_bal_sickleave    := null;
  g_benefit_bal_pension      := null;
  g_benefit_bal_dfncntrbn    := null;
  g_benefit_bal_wellness     := null;
  g_per_attr_1               := null;
  g_per_attr_2               := null;
  g_per_attr_3               := null;
  g_per_attr_4               := null;
  g_per_attr_5               := null;
  g_per_attr_6               := null;
  g_per_attr_7               := null;
  g_per_attr_8               := null;
  g_per_attr_9               := null;
  g_per_attr_10              := null;
  --
  g_applicant_number         := null;
  g_correspondence_language  := null;
  g_email_address            := null;
  g_known_as                 := null;
  g_mailstop                 := null;
  g_nationality              := null;
  g_pre_name_adjunct         := null;
  g_original_date_of_hire    := null;
  g_uses_tobacco_flag        := null;
  g_office_number            := null;
  --
  g_prim_address_line_1      := null;
  g_prim_address_line_2      := null;
  g_prim_address_line_3      := null;
  g_prim_city                := null;
  g_prim_state               := null;
  g_prim_state_ansi          := null;
  g_prim_postal_code         := null;
  g_prim_country             := null;
  g_prim_county              := null;
  g_prim_region_3            := null;
  g_prim_address_date        := null;
  g_prim_addr_service_area   := null;
  --
  g_mail_address_line_1      := null;
  g_mail_address_line_2      := null;
  g_mail_address_line_3      := null;
  g_mail_city                := null;
  g_mail_state               := null;
  g_mail_postal_code         := null;
  g_mail_country             := null;
  g_mail_county              := null;
  g_mail_region_3            := null;
  g_mail_address_date        := null;
  --
  g_phone_home               := null;
  g_phone_work               := null;
  g_phone_fax                := null;
  g_phone_mobile             := null;
  --
  g_last_hire_date           := null;
  g_actual_term_date         := null;
  g_adjusted_svc_date        := null;
  g_term_reason              := null;
  --
  g_employee_status          := null;
  g_employee_grade           := null;
  g_grd_flex_01          := null;
  g_grd_flex_02          := null;
  g_grd_flex_03          := null;
  g_grd_flex_04          := null;
  g_grd_flex_05          := null;
  g_grd_flex_06          := null;
  g_grd_flex_07          := null;
  g_grd_flex_08          := null;
  g_grd_flex_09          := null;
  g_grd_flex_10          := null;
  g_employee_barg_unit       := null;
  g_employee_organization    := null;
  g_employee_grade_id        := null;
  g_employee_organization_id := null;
  g_employee_status_id       := null;
  g_location_id              := null;
  g_location_code            := null;
  g_location_addr1           := null;
  g_location_addr2           := null;
  g_location_addr3           := null;
  g_location_city            := null;
  g_location_country         := null;
  g_location_zip             := null;
  g_location_region1         := null;
  g_location_region2         := null;
  g_location_region3         := null;
  -- org address
  g_org_location_addr1       := null ;
  g_org_location_addr2       := null ;
  g_org_location_addr3       := null ;
  g_org_location_city        := null ;
  g_org_location_country     := null ;
  g_org_location_zip         := null ;
  g_org_location_region1     := null ;
  g_org_location_region2     := null ;
  g_org_location_region3     := null ;
  --
  g_alc_flex_01          := null;
  g_alc_flex_02          := null;
  g_alc_flex_03          := null;
  g_alc_flex_04          := null;
  g_alc_flex_05          := null;
  g_alc_flex_06          := null;
  g_alc_flex_07          := null;
  g_alc_flex_08          := null;
  g_alc_flex_09          := null;
  g_alc_flex_10          := null;
  g_asg_title                := null;
  g_position_id              := null;
  g_job_id                   := null;
  g_payroll_id               := null;
  g_people_group_id          := null;
  g_pay_basis_id             := null;
  g_hourly_salaried_code     := null;
  g_labour_union_member_flag := null;
  g_manager_flag             := null;
  g_position                 := null;
  g_pos_flex_01          := null;
  g_pos_flex_02          := null;
  g_pos_flex_03          := null;
  g_pos_flex_04          := null;
  g_pos_flex_05          := null;
  g_pos_flex_06          := null;
  g_pos_flex_07          := null;
  g_pos_flex_08          := null;
  g_pos_flex_09          := null;
  g_pos_flex_10          := null;
  g_job                      := null;
  g_job_flex_01          := null;
  g_job_flex_02          := null;
  g_job_flex_03          := null;
  g_job_flex_04          := null;
  g_job_flex_05          := null;
  g_job_flex_06          := null;
  g_job_flex_07          := null;
  g_job_flex_08          := null;
  g_job_flex_09          := null;
  g_job_flex_10          := null;
  g_payroll                  := null;
  g_prl_flex_01          := null;
  g_prl_flex_02          := null;
  g_prl_flex_03          := null;
  g_prl_flex_04          := null;
  g_prl_flex_05          := null;
  g_prl_flex_06          := null;
  g_prl_flex_07          := null;
  g_prl_flex_08          := null;
  g_prl_flex_09          := null;
  g_prl_flex_10          := null;
  g_people_group             := null;
  g_pay_basis                := null;
  g_pbs_flex_01          := null;
  g_pbs_flex_02          := null;
  g_pbs_flex_03          := null;
  g_pbs_flex_04          := null;
  g_pbs_flex_05          := null;
  g_pbs_flex_06          := null;
  g_pbs_flex_07          := null;
  g_pbs_flex_08          := null;
  g_pbs_flex_09          := null;
  g_pbs_flex_10          := null;
  g_payroll_period_type      := null;
  g_payroll_period_number    := null;
  g_payroll_period_strtdt    := null;
  g_payroll_period_enddt     := null;
  g_payroll_costing          := null;
  g_payroll_costing_id       := null;
  g_payroll_consolidation_set := null;
  g_payroll_consolidation_set_id := null;
  g_asg_attr_1               := null;
  g_asg_attr_2               := null;
  g_asg_attr_3               := null;
  g_asg_attr_4               := null;
  g_asg_attr_5               := null;
  g_asg_attr_6               := null;
  g_asg_attr_7               := null;
  g_asg_attr_8               := null;
  g_asg_attr_9               := null;
  g_asg_attr_10              := null;
  --
  g_sup_full_name            := null ;
  g_sup_employee_number      := null ;
  g_asg_normal_hours         := null ;
  g_asg_frequency            := null ;
  g_asg_time_normal_start    := null ;
  g_asg_time_normal_finish   := null ;
  g_asg_supervisor_id        := null ;
  g_base_salary              := null ;
  g_asg_type                 := null ;
  --
  g_abs_reason_name          := null;
  g_abs_category_name        := null;
  g_abs_type_name            := null;
  g_abs_reason               := null;
  g_abs_category             := null;
  g_abs_type                 := null;
  g_abs_start_dt             := null;
  g_abs_end_dt               := null;
  g_abs_duration             := null;
  g_abs_last_update_date     := null;
  g_abs_last_updated_by      := null;
  g_abs_last_update_login    := null;
  g_abs_created_by           := null;
  g_abs_creation_date        := null;
  g_abs_reason_cd	     := null; -- Bug 2841958

  g_abs_flex_01              := null;
  g_abs_flex_02              := null;
  g_abs_flex_03              := null;
  g_abs_flex_04              := null;
  g_abs_flex_05              := null;
  g_abs_flex_06              := null;
  g_abs_flex_07              := null;
  g_abs_flex_08              := null;
  g_abs_flex_09              := null;
  g_abs_flex_10              := null;
  --
  g_prs_flex_01              := null;
  g_prs_flex_02              := null;
  g_prs_flex_03              := null;
  g_prs_flex_04              := null;
  g_prs_flex_05              := null;
  g_prs_flex_06              := null;
  g_prs_flex_07              := null;
  g_prs_flex_08              := null;
  g_prs_flex_09              := null;
  g_prs_flex_10              := null;
  --
  --  g_correspondence_language  := null;
  --  g_work_telephone           := null;
  --  g_nationality              := null;
  --  g_email_address            := null;
  --
  -- these globals are assigned value in this package, so initialized here
  g_enrt_pl_name             := null;
  g_enrt_pl_typ_id           := null;
  g_enrt_pl_typ_name         := null;
  /* Start of Changes for WWBUG: 1828349     added  */
  g_enrt_prtt_enrt_rslt_id   := null;
  /* End of Changes for WWBUG: 1828349     added    */
  --
  g_ee_pre_tax_cost          := null;
  g_ee_after_tax_cost        := null;
  g_ee_ttl_cost              := null;
  g_er_ttl_cost              := null;
  --
  g_per_in_ler_id            := null;
  g_ler_id                   := null;
  g_ler_name                 := null;
  g_lf_evt_ocrd_dt           := null;
  g_lf_evt_note_dt           := null;
  --
  g_cm_type              := null;
  g_cm_type_id           := null;
  g_cm_lf_evt_ocrd_dt    := null;
  g_cm_lf_evt            := null;
  g_cm_lf_evt_id         := null;
  g_cm_lf_evt_stat       := null;
  g_cm_lf_evt_ntfn_dt    := null;
  g_cm_trgr_proc_name    := null;
  g_cm_trgr_proc_dt      := null;
  g_cm_addr_line1        := null;
  g_cm_addr_line2        := null;
  g_cm_addr_line3        := null;
  g_cm_city              := null;
  g_cm_state             := null;
  g_cm_postal_code       := null;
  g_cm_country           := null;
  g_cm_county            := null;
  g_cm_region_3          := null;
  g_cm_dlvry_instn_txt   := null;
  g_cm_inspn_rqd_flag    := null;
  g_cm_to_be_sent_dt     := null;
  --
  g_per_cm_prvdd_id              := null;
  g_per_cm_object_version_number := null;
  --
  g_cbra_ler_id   := null;
  g_cbra_ler_name := null;
  g_cbra_strt_dt  := null;
  g_cbra_end_dt   := null;
  --
  g_flex_credit_provided    := null;
  g_flex_credit_forfited    := null;
  g_flex_credit_used        := null;
  g_flex_credit_excess      := null;
  --intializing other id
  g_assignment_id           := null ;
  g_dpnt_cvrd_dpnt_id       := null ;
  g_elig_dpnt_id            := null ;

  --- intialize cwb globals
  g_cwb_per_group_per_in_ler_id         := null ;
  g_cwb_per_group_pl_id                 := null ;
  g_CWB_Person_FULL_NAME	       	:= null ;
  g_CWB_Person_Custom_Name		:= null ;
  g_CWB_Life_Event_Name          	:= null ;
  g_CWB_Life_Event_Occurred_Date	:= null ;
  g_CWB_Person_EMAIL_DDRESS		:= null ;
  g_CWB_Person_EMPLOYEE_NUMBER		:= null ;
  g_CWB_Person_BASE_SALARY		:= null ;
  g_CWB_Person_Brief_Name		:= null ;
  g_CWB_Person_BG_Name	                := null ;
  g_CWB_Person_CHANGE_REASON		:= null ;
  g_CWB_PEOPLE_GROUP_NAME		:= null ;
  g_CWB_PEOPLE_GROUP_SEGMENT1		:= null ;
  g_CWB_PEOPLE_GROUP_SEGMENT10		:= null ;
  g_CWB_PEOPLE_GROUP_SEGMENT11		:= null ;
  g_CWB_PEOPLE_GROUP_SEGMENT2		:= null ;
  g_CWB_PEOPLE_GROUP_SEGMENT3		:= null ;
  g_CWB_PEOPLE_GROUP_SEGMENT4		:= null ;
  g_CWB_PEOPLE_GROUP_SEGMENT5		:= null ;
  g_CWB_PEOPLE_GROUP_SEGMENT6		:= null ;
  g_CWB_PEOPLE_GROUP_SEGMENT7		:= null ;
  g_CWB_PEOPLE_GROUP_SEGMENT8		:= null ;
  g_CWB_PEOPLE_GROUP_SEGMENT9		:= null ;
  g_CWB_Persom_PERF_RATING_TYPE  	:= null ;
  g_CWB_Person_PERF_RATING       	:= null ;
  g_CWB_Person_BASE_SALARY_FREQ  	:= null ;
  g_CWB_Person_EMPloyee_CATEGORY	:= null ;
  g_CWB_Person_Grade_COMPARATIO		:= null ;
  g_CWB_Person_POST_PROCESS_Stat 	:= null ;
  g_CWB_Person_START_DATE		:= null ;
  g_CWB_Person_ADJUSTED_SVC_DATE	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE1	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE10	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE11	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE12	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE13	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE14	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE15 := null ;
  g_CWB_Person_Assg_ATTRIBUTE16	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE17	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE18	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE19	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE2	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE20	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE21	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE22	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE23	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE24	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE25	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE26	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE28	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE29	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE3	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE30	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE4	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE5	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE6	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE7	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE8	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE9	:= null ;
  g_CWB_Person_Assg_ATTRIBUTE27	:= null ;
  g_CWB_Person_Info_ATTRIBUTE1	:= null ;
  g_CWB_Person_Info_ATTRIBUTE10	:= null ;
  g_CWB_Person_Info_ATTRIBUTE2	:= null ;
  g_CWB_Person_Info_ATTRIBUTE3	:= null ;
  g_CWB_Person_Info_ATTRIBUTE4	:= null ;
  g_CWB_Person_Info_ATTRIBUTE5	:= null ;
  g_CWB_Person_Info_ATTRIBUTE6	:= null ;
  g_CWB_Person_Info_ATTRIBUTE7	:= null ;
  g_CWB_Person_Info_ATTRIBUTE11	:= null ;
  g_CWB_Person_Info_ATTRIBUTE12	:= null ;
  g_CWB_Person_Info_ATTRIBUTE13	:= null ;
  g_CWB_Person_Info_ATTRIBUTE14	:= null ;
  g_CWB_Person_Info_ATTRIBUTE15	:= null ;
  g_CWB_Person_Info_ATTRIBUTE16	:= null ;
  g_CWB_Person_Info_ATTRIBUTE17	:= null ;
  g_CWB_Person_Info_ATTRIBUTE18	:= null ;
  g_CWB_Person_Info_ATTRIBUTE19	:= null ;
  g_CWB_Person_Info_ATTRIBUTE20	:= null ;
  g_CWB_Person_Info_ATTRIBUTE21	:= null ;
  g_CWB_Person_Info_ATTRIBUTE22	:= null ;
  g_CWB_Person_Info_ATTRIBUTE23	:= null ;
  g_CWB_Person_Info_ATTRIBUTE24	:= null ;
  g_CWB_Person_Info_ATTRIBUTE25	:= null ;
  g_CWB_Person_Info_ATTRIBUTE26	:= null ;
  g_CWB_Person_Info_ATTRIBUTE27	:= null ;
  g_CWB_Person_Info_ATTRIBUTE28	:= null ;
  g_CWB_Person_Info_ATTRIBUTE29	:= null ;
  g_CWB_Person_Info_ATTRIBUTE30	:= null ;
  g_CWB_Person_Info_ATTRIBUTE8	:= null ;
  g_CWB_Person_Info_ATTRIBUTE9	:= null ;
  g_CWB_Person_CUSTOM_SEGMENT1 		:= null ;
  g_CWB_Person_CUSTOM_SEGMENT10		:= null ;
  g_CWB_Person_CUSTOM_SEGMENT11		:= null ;
  g_CWB_Person_CUSTOM_SEGMENT13		:= null ;
  g_CWB_Person_CUSTOM_SEGMENT14		:= null ;
  g_CWB_Person_CUSTOM_SEGMENT2		:= null ;
  g_CWB_Person_CUSTOM_SEGMENT4		:= null ;
  g_CWB_Person_CUSTOM_SEGMENT5		:= null ;
  g_CWB_Person_CUSTOM_SEGMENT6		:= null ;
  g_CWB_Person_CUSTOM_SEGMENT7		:= null ;
  g_CWB_Person_CUSTOM_SEGMENT9		:= null ;
  g_CWB_Person_CUSTOM_SEGMENT12		:= null ;
  g_CWB_Person_CUSTOM_SEGMENT15		:= null ;
  g_CWB_Person_CUSTOM_SEGMENT8 		:= null ;
  g_CWB_Person_CUSTOM_SEGMENT3		:= null ;
  g_CWB_Person_FEEDBACK_RATING		:= null ;
  g_CWB_Person_FREQUENCY	        := null ;
  g_CWB_Person_Grade_MAX_VAL     	:= null ;
  g_CWB_Person_Grade_MID_POINT		:= null ;
  g_CWB_Person_Grade_MIN_VAL     	:= null ;
  g_CWB_Person_GRADE_name		:= null ;
  g_CWB_Person_Grade_QUARTILE		:= null ;
  g_CWB_Person_GRADE_ANN_FACTOR 	:= null ;
  g_CWB_Person_JOB_name			:= null ;
  g_CWB_Person_LEGISLATION 		:= null ;
  g_CWB_Person_LOCATION			:= null ;
  g_CWB_Person_NORMAL_HOURS		:= null ;
  g_CWB_Person_ORG_name	 	        := null ;
  g_CWB_Person_ORIG_START_DATE	        := null ;
  g_CWB_Person_PAY_RATE 	        := null ;
  g_CWB_Person_PAY_ANNUL_FACTOR	        := null ;
  g_CWB_Person_PAYROLL_NAME		:= null ;
  g_CWB_Person_PERF_RATING_DATE	        := null ;
  g_CWB_Person_POSITION	        	:= null ;
  g_CWB_Person_STATUS_TYPE		:= null ;
  g_CWB_Person_SUP_BRIEF_NAME	        := null ;
  g_CWB_Person_SUP_CUSTOM_NAME	        := null ;
  g_CWB_Person_SUP_FULL_NAME	        := null ;
  g_CWB_Person_YEARS_EMPLOYED		:= null ;
  g_CWB_Person_YEARS_IN_GRADE		:= null ;
  g_CWB_Person_YEARS_IN_POS		:= null ;
  g_CWB_Person_YEARS_IN_JOB		:= null ;
  g_cwb_nw_chg_reason                   := null ;
  g_CWB_new_Job_name                    := null ;
  g_CWB_new_Grade_name                  := null ;
  g_CWB_new_Group_name                  := null ;
  g_CWB_new_Postion_name                := null ;
  g_CWB_new_Perf_rating                 := null ;
  g_CWB_LE_Dt                           := null ;
  g_CWB_effective_date                  := null ;
  g_CWB_Life_Event_status               := null ;
  g_cwb_group_plan_name                 := null ;
  -- subheader
  g_group_elmt_value1                   := null ;
  g_group_elmt_value2                   := null ;
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
  --
End init_detail_globals;
--
-- ----------------------------------------------------------------------------
-- |------< write_error >---------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure write_error(p_err_num     in number,
                      p_err_name    in varchar2,
                      p_typ_cd      in varchar2,
                      p_request_id  in number,
                      p_ext_rslt_id in number) IS
--
  l_proc               varchar2(72);
  l_err_num            number(15);
--
cursor err_cnt_c is
  select count(*) from ben_ext_rslt_err
   where ext_rslt_id = p_ext_rslt_id --request_id = p_request_id
     and typ_cd <> 'W';
--
--
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'write_error';
    hr_utility.set_location('Entering'||l_proc, 5);
    hr_utility.set_location('error message ' || p_err_name,99.97);
  end if;
  --
  open err_cnt_c;
  fetch err_cnt_c into l_err_num;
  close err_cnt_c;
  --

  if l_err_num >= ben_ext_thread.g_max_errors_allowed then
    --
    ben_ext_thread.g_err_num := 91947;
    ben_ext_thread.g_err_name := 'BEN_91947_EXT_MX_ERR_NUM';
    raise ben_ext_thread.g_job_failure_error;
    --
  end if;
    --
  if g_business_group_id is not null then
    --
    ben_ext_util.write_err
         (p_err_num           => p_err_num,
          p_err_name          => p_err_name,   --error form will take care of it,
          p_typ_cd            => p_typ_cd,
          p_person_id         => g_person_id,
          p_request_id        => p_request_id,
          p_ext_rslt_id       => p_ext_rslt_id,
          p_business_group_id => g_business_group_id
         );
    --
    commit;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
  --
end write_error;
--
END ben_ext_person;

/
