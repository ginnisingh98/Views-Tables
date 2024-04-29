--------------------------------------------------------
--  DDL for Package Body HR_AU_ELEMENT_ENTRY_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AU_ELEMENT_ENTRY_HOOK" as
  --  $Header: peaushee.pkb 120.3 2006/04/02 22:00:09 strussel noship $
  --
  --  Copyright (C) 2000 Oracle Corporation
  --  All Rights Reserved
  --
  --  AU HRMS element entry legislative hook package.
  --
  --  Change List
  --

  --
  -- Date        Author   Reference Description
  --  -----------+--------+---------+------------------------------------------
  --  17 Jun 2001 RAGOVIND  1416342   Created
  --  04 Sep 2001 KAVERMA             Added update_element_entry_values Procedure
  --  27 Mar 2006 SRUSSELL  5115516   Added check for creator_type in
  --                                  update_element_entry_values.
  --  03 Apr 2006 SRUSSELL  5115516   Arcsd out and in to try to fix arcs
  --                                  version problem.
  --  -------------------------------------------------------------------------
  --  populate_absence_dev_desc_flex procedure

  --
  --  This is a public procedure that is called from the PAY_ELEMENT_ENTRIES_F
  --  after insert and after update hooks.
  --  -------------------------------------------------------------------------

  procedure insert_absence_dev_desc_flex
  (p_effective_date                 in     date
  ,p_element_entry_id               in     number
  ,p_creator_type                   in     varchar2
  ,p_element_link_id                in     number
  ,p_creator_id                     in     number) is


    l_procedure_name                varchar2(61) := 'hr_au_element_entry_hook.insert_absence_dev_desc_flex' ;
    l_batch_id                      per_absence_attendances.batch_id%type ;
    l_certificate_required          pay_element_entry_values_f.screen_entry_value%type ;
    l_certificate_received          pay_element_entry_values_f.screen_entry_value%type ;
    l_absence_category              per_absence_attendance_types.absence_category%type;
    l_element_name                  pay_element_types_f.element_name%type;

    --  cursor to get the batch ID for the absence

    cursor c_absence (p_absence_attendance_id number)
    is
      select aa.batch_id
      from   per_absence_attendances aa
      where  aa.absence_attendance_id = p_absence_attendance_id ;

    --  cursor to get input value

    cursor c_input_value (p_element_entry_id  number
                         ,p_effective_date    date
                         ,p_input_name        varchar2)
    is
      select eev.screen_entry_value
      from   pay_input_values_f iv
            ,pay_element_entry_values_f eev
      where  eev.element_entry_id     = p_element_entry_id
      and    p_effective_date   between eev.effective_start_date
                                and     eev.effective_end_date
      and    iv.input_value_id        = eev.input_value_id
      and    iv.name                  = p_input_name
      and    p_effective_date   between iv.effective_start_date
                                and     iv.effective_end_date;

    cursor c_absence_category ( p_element_link_id number,
                                p_effective_date date ,
                                p_element_entry_id number)
    is
      select paa.absence_category,
             element_name
      from   pay_element_entries_f pee
            ,pay_element_links_f pef
            ,pay_element_types_f pet
            ,pay_input_values_F piv
            ,per_absence_attendance_types paa
      where  pee.element_link_id       = pef.element_link_id
      and    pef.element_type_id       = pet.element_type_id
      and    pet.element_type_id       = piv.element_type_id
      and    paa.input_value_id        = piv.input_value_id
      and    pee.element_link_id       = p_element_link_id
      and    pee.element_entry_id      = p_element_entry_id
      and    p_effective_date    between piv.effective_start_date
                                 and     piv.effective_end_date
      and    p_Effective_date    between pef.effectivE_start_date
                                 and     pef.effective_end_date
      and    p_effective_date    between pet.effective_start_date
                                 and     pet.effective_end_date;

      -- commenting this check because the absence element entry is effective for
      -- that corresponding pay period
      /*and  p_Effective_date between pee.effective_start_date
                              and     pee.effective_end_date */


  begin

 hr_utility.trace('In: ' || l_procedure_name) ;

    -- tracing the values....
    hr_utility.trace('p_effective_date : '||p_effective_date);
    hr_utility.trace('p_element_entry_id :'||p_element_entry_id);
    hr_utility.trace('p_creator_type :'||p_creator_type);
    hr_utility.trace('p_element_link_id :'||p_element_link_id);
    hr_utility.trace('p_creator_id :'||p_creator_id);

    --  check to see if the element entry is for an absence

    if p_creator_type = 'A'
    then

      --  we've got an absence element entry so now check to see if the absence
      --  was created by batch element entry (BEE)

      open c_absence(p_creator_id) ;
      fetch   c_absence
         into l_batch_id ;
      close   c_absence ;

    hr_utility.trace('l_batch_id :'||l_batch_id);

      if l_batch_id is not null
      then

         open c_absence_category(p_element_link_id,
                                 p_effective_date,
                                 p_element_entry_id);
          loop

             fetch c_absence_category
                into l_absence_category
                    ,l_element_name;

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

    hr_utility.trace('l_absence_category :'||l_absence_category);
    hr_utility.trace('l_element_name :'||l_element_name);

        --  we've got an absence created by BEE so get values for Certificate Required,
        --  Certificate Received  input values to put into
        --  corresponding segments of PER_ABS_DEVELOPER_DF descriptive
        --  flexfield.

          if l_absence_category='AUSL' then

        --  look for Certificate Required
              open c_input_value(p_element_entry_id
                                ,p_effective_date
                                ,'Certificate Required') ;

              fetch c_input_value
                 into l_Certificate_required ;

    hr_utility.trace('l_Certificate_required  :'||l_Certificate_required);

              if c_input_value%notfound
                 or l_Certificate_required is null
              then
                    l_Certificate_required := 'N' ;
              end if ;

              close c_input_value ;

    hr_utility.trace('AFTER l_Certificate_required  :'||l_Certificate_required);

              update per_absence_attendances
              set    abs_information1 = l_Certificate_required
                    ,abs_information_category = 'AU_' || l_absence_category
              where  absence_attendance_id = p_creator_id ;

              --  look for Certificate Received
              open c_input_value(p_element_entry_id
                                ,p_effective_date
                                ,'Certificate Received') ;


              fetch c_input_value
                 into l_certificate_received ;

    hr_utility.trace('l_Certificate_received  :'||l_Certificate_received);

              if c_input_value%notfound
                 or l_certificate_received is null
              then
                    l_certificate_received := 'N' ;
              end if ;

              close c_input_value ;

     hr_utility.trace('l_Certificate_received  :'||l_Certificate_received);

              --  now update the Descriptive Flexfield segments

              update per_absence_attendances
              set    abs_information_category = 'AU_' || l_absence_category
                    ,abs_information2 = l_certificate_received
              where  absence_attendance_id = p_creator_id ;

              end if; -- Absence Category

      end if ;  --  l_batch_id is not null

    end if ;  --  p_creator_type = 'A'

    hr_utility.trace('Out: ' || l_procedure_name) ;
  end insert_absence_dev_desc_flex ;

  --  -------------------------------------------------------------------------
  --  populate update_element_entry_values procedure

  --
  --  This is a public procedure that is called from the PAY_ELEMENT_ENTRIES_F
  --  after insert and after update hooks.
  --  -------------------------------------------------------------------------


procedure update_element_entry_values
  (p_effective_date                 in     date
  ,p_element_entry_id               in     number
  ,p_creator_type                   in     varchar2
  ,p_creator_id                     in     number) is

    l_procedure_name                varchar2(61) := 'hr_au_element_entry_hook.update_element_entry_values' ;
    l_start_date                    pay_element_entry_values_f.screen_entry_value%type;
    l_end_date                      pay_element_entry_values_f.screen_entry_value%type;
    l_abs_information1              per_absence_attendances.abs_information1%type ;
    l_abs_information2              per_absence_attendances.abs_information2%type ;
    l_abs_information3              per_absence_attendances.abs_information3%type ;
    l_dff_context                   per_absence_attendances.abs_information_category%type ;
    l_element_entry_value_id        pay_element_entry_values_f.element_entry_value_id%type;

-- cursor to get DFF context value of Absence Information

   cursor c_get_dff_context(p_creator_id number)
   is
    select abs_information_category
    from per_absence_attendances
    where absence_attendance_id = p_creator_id;

-- cursor to get DFF segment values of Absence Information

   cursor c_get_dff_segment_value(p_creator_id       number)
   is
    select to_char(date_start,'YYYY/MM/DD HH24:MI:SS'),to_char(date_end,'YYYY/MM/DD HH24:MI:SS'),abs_information1, abs_information2, abs_information3
    from per_absence_attendances
    where absence_attendance_id = p_creator_id;

-- cursor to get element_entry_value_id for input values of Absence Element

  cursor get_element_entry_value_id(p_element_entry_id number
                                   ,p_input_name       varchar2)
  is
   select  peev.element_entry_value_id
   from pay_element_entry_values_f peev,pay_input_values_f piv
   where     peev.element_entry_id = p_element_entry_id
         and piv.name = p_input_name
         and peev.input_value_id = piv.input_value_id;

begin

     hr_utility.trace('In: ' || l_procedure_name) ;

    -- tracing the values....
    hr_utility.trace('p_effective_date : '||p_effective_date);
    hr_utility.trace('p_element_entry_id :'||p_element_entry_id);
    hr_utility.trace('p_creator_type :'||p_creator_type);
    hr_utility.trace('p_creator_id :'||p_creator_id);

  if p_creator_type = 'A'
  then

-- get context value
    open c_get_dff_context(p_creator_id);
    fetch c_get_dff_context into l_dff_context;
    close c_get_dff_context;

--proceed if context is AU Annual leave or AU Long Service Leave

    IF(l_dff_context = 'AU_AUAL' or l_dff_context = 'AU_AULSL') THEN

      open c_get_dff_segment_value(p_creator_id);
      fetch  c_get_dff_segment_value into l_start_date,l_end_date,l_abs_information1,l_abs_information2,l_abs_information3;
      close c_get_dff_segment_value;

      open get_element_entry_value_id(p_element_entry_id,'Start Date');
      fetch get_element_entry_value_id into l_element_entry_value_id;
      close get_element_entry_value_id;

      hr_utility.trace('Updating Start Date entry value as l_start_date :'||l_start_date);

      update pay_element_entry_values_f
      set screen_entry_value = l_start_date
      where element_entry_value_id = l_element_entry_value_id;

      open get_element_entry_value_id(p_element_entry_id,'End Date');
      fetch get_element_entry_value_id into l_element_entry_value_id;
      close get_element_entry_value_id;

      hr_utility.trace('Updating End Date entry value as l_end_date :'||l_end_date);

      update pay_element_entry_values_f
      set screen_entry_value = l_end_date
      where element_entry_value_id = l_element_entry_value_id;

      open get_element_entry_value_id(p_element_entry_id,'Pay Date');
      fetch get_element_entry_value_id into l_element_entry_value_id;
      close get_element_entry_value_id;

      hr_utility.trace('Updating Pay Date entry value as abs_information1 :'||l_abs_information1);

      update pay_element_entry_values_f
      set screen_entry_value = l_abs_information1
      where element_entry_value_id = l_element_entry_value_id;

      open get_element_entry_value_id(p_element_entry_id,'Advance Defer');
      fetch get_element_entry_value_id into l_element_entry_value_id;
      close get_element_entry_value_id;

      hr_utility.trace('Updating Start Advance Defer value as abs_information2 :'||l_abs_information2);

      update pay_element_entry_values_f
      set screen_entry_value = l_abs_information2
      where element_entry_value_id = l_element_entry_value_id;

      open get_element_entry_value_id(p_element_entry_id,'Advance Override');
      fetch get_element_entry_value_id into l_element_entry_value_id;
      close get_element_entry_value_id;

      hr_utility.trace('Updating Advance Override entry value as abs_information3 :'||l_abs_information3);

      update pay_element_entry_values_f
      set screen_entry_value = l_abs_information3
      where element_entry_value_id = l_element_entry_value_id;

    END IF;    -- l_dff_context.

  end if;    -- p_creator_type = 'A'.

end update_element_entry_values;

end hr_au_element_entry_hook ;

/
