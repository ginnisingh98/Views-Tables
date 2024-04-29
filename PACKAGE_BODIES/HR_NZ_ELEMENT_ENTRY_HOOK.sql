--------------------------------------------------------
--  DDL for Package Body HR_NZ_ELEMENT_ENTRY_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NZ_ELEMENT_ENTRY_HOOK" as
  --  $Header: penzlhee.pkb 120.0.12010000.1 2008/07/28 05:03:54 appldev ship $
  --
  --  Copyright (C) 2000 Oracle Corporation
  --  All Rights Reserved
  --
  --  NZ HRMS element entry legislative hook package.
  --
  --  Change List
  --  ===========
  --
  --  Date        Author   Reference Description
  --  -----------+--------+---------+------------------------------------------
  --  25-SEP-2000 HNainani Bug#1412369 ABS_INFORMATION_CATEGORY not being
 --                                   correctly populated
  --  07 Feb 2000 JTurner  1098494   Now also populates the
  --                                 ABS_INFORMATION_CATEGORY column
  --  19 Jan 2000 JTurner  1098494   Now uses CREATOR_ID instead of SOURCE_ID
  --                                 to join element entries to absences
  --  18 JAN 2000 JTURNER  1098494   Created

  --  -------------------------------------------------------------------------
  --  populate_absence_dev_desc_flex procedure
  --
  --  This is a public procedure that is called from the PAY_ELEMENT_ENTRIES_F
  --  after insert and after update hooks.
  --  -------------------------------------------------------------------------

  procedure populate_absence_dev_desc_flex
  (p_effective_date                 in     date
  ,p_element_entry_id               in     number
  ,p_creator_type                   in     varchar2
 ,p_element_link_id                 in     number
  ,p_creator_id                     in     number) is

    l_procedure_name                varchar2(61) := 'hr_nz_element_entry_hook.populate_absence_dev_desc_flex' ;
    l_batch_id                      per_absence_attendances.batch_id%type ;
    l_seasonal_shutdown             pay_element_entry_values_f.screen_entry_value%type ;
    l_number_of_complete_weeks      pay_element_entry_values_f.screen_entry_value%type ;
   l_absence_category per_absence_attendance_types.absence_category%type;
   l_element_name pay_element_types_f.element_name%type;

    --  cursor to get the batch ID for the absence
    cursor c_absence (p_absence_attendance_id number) is
      select aa.batch_id
      from   per_absence_attendances aa
      where  aa.absence_attendance_id = p_absence_attendance_id ;

    --  cursor to get input value
    cursor c_input_value (p_element_entry_id  number
                         ,p_effective_date    date
                         ,p_input_name        varchar2) is
      select eev.screen_entry_value
      from   pay_input_values_f iv
      ,      pay_element_entry_values_f eev
      where  eev.element_entry_id = p_element_entry_id
      and    p_effective_date between eev.effective_start_date
                                  and eev.effective_end_date
      and    iv.input_value_id = eev.input_value_id
      and    iv.name = p_input_name
      and    p_effective_date between iv.effective_start_date
                                  and iv.effective_end_date ;


    cursor c_absence_category (p_element_link_id number,
                                p_effective_date date ,
                                p_element_entry_id number) is
             select paa.absence_category,
                    element_name
             from
             pay_element_entries_f pee
            , pay_element_links_f pef
            , pay_element_types_f pet
            , pay_input_values_F piv
            , per_absence_attendance_types paa
            where pee.element_link_id= pef.element_link_id
            and pef.element_type_id = pet.element_type_id
            and pet.element_type_id = piv.element_type_id
            and paa.input_value_id = piv.input_value_id
            and  pee.element_link_id = p_element_link_id
            and pee.element_entry_id = p_element_entry_id
            and p_effective_date between piv.effective_start_date
                                      and   piv.effective_end_date
           and p_Effective_date between pee.effective_start_date
                                      and pee.effective_end_date
            and p_Effective_date between pef.effectivE_start_date
                                        and pef.effective_end_date
           and p_effective_date between pet.effective_start_date
                                        and pet.effective_end_date;

  begin
    hr_utility.trace('In: ' || l_procedure_name) ;
    --  check to see if the element entry is for an absence
    if p_creator_type = 'A'
    then

      --  we've got an absence element entry so now check to see if the absence
      --  was created by batch element entry (BEE)

      open c_absence(p_creator_id) ;
      fetch c_absence
        into l_batch_id ;
      close c_absence ;

      if l_batch_id is not null
      then

         open c_absence_category(p_element_link_id,
                                 p_effective_date,
                                 p_element_entry_id);
          loop

           fetch c_absence_category
                into l_absence_category,l_element_name;
            exit when c_absence_category%notfound;


         /* Single element linked to more than one absence category */

            if c_absence_category%ROWCOUNT > 1
             then
               fnd_message.set_name('PAY', 'HR_AU_NZ_DUP_ELEMENT_FOUND');
               fnd_message.set_token('ELEMENT', l_element_name);
               fnd_message.raise_error;
           end if;
          end loop;

         close c_absence_category;

        --  we've got an absence created by BEE so get values for seasonal
        --  shutdown and number of complete weeks input values to put into
        --  corresponding segments of PER_ABS_DEVELOPER_DF descriptive
        --  flexfield.


          if l_absence_category='NZAL' then

        --  look for seasonal shutdown
        open c_input_value(p_element_entry_id
                          ,p_effective_date
                          ,'Seasonal Shutdown') ;

        fetch c_input_value
          into l_seasonal_shutdown ;

        if c_input_value%notfound
          or l_seasonal_shutdown is null
        then
          l_seasonal_shutdown := 'N' ;
        end if ;

        close c_input_value ;

        update per_absence_attendances
        set abs_information1 = l_seasonal_shutdown
        , abs_information_category = 'NZ_' || l_absence_category
        where  absence_attendance_id = p_creator_id ;


    elsif l_absence_category='NZSL'
   then
        --  look for number of complete weeks
        open c_input_value(p_element_entry_id
                          ,p_effective_date
                          ,'Number of Complete Weeks') ;

        fetch c_input_value
          into l_number_of_complete_weeks ;

        if c_input_value%notfound
          or l_number_of_complete_weeks is null
        then
          l_number_of_complete_weeks := '0' ;
        end if ;

        close c_input_value ;

        --  now update the DF segments
        update per_absence_attendances
        set    abs_information_category = 'NZ_' || l_absence_category
        ,      abs_information2 = l_number_of_complete_weeks
        where  absence_attendance_id = p_creator_id ;

     end if; -- Absence Category

      end if ;  --  l_batch_id is not null

    end if ;  --  p_creator_type = 'A'

    hr_utility.trace('Out: ' || l_procedure_name) ;
  end populate_absence_dev_desc_flex ;

end hr_nz_element_entry_hook ;

/
