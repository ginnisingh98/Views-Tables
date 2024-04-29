--------------------------------------------------------
--  DDL for Package Body PAY_US_EMP_DT_TAX_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_EMP_DT_TAX_RULES" as
/* $Header: pyusdtw4.pkb 120.19.12010000.1 2008/07/27 23:49:44 appldev ship $ */

  /* Name        : maintain_element_entry
     Purpose     : This procedure can be used to create as well as update the vertex
                   element entry for an assignment. It calls the element entries api
                   to insert and update the element entry record.
     Parameters  :
                  p_assignment_id     -> The assignment for which the vertex elemnt entry is to be
                                         created/modified.
                  p_effective_start_date -> The start date of the element entry.
                  p_effective_end_date   -> The end date of the element entry.
                  p_session_date         -> This will be helpful for the various update modes.
                  p_jurisdiction_code    -> The jurisdiction code for which the elemnt entry is to
                                            created/updated.
                  p_percentage_time      -> Time in the jurisdiction.
                  p_mode                 -> If can have the following values :
                                            'INSERT'
                                            'CORRECTION',
                                            'UPDATE',
                                            'UPDATE_CHANGE_INSERT',
                                            'UPDATE_OVERRIDE',
                                            'ZAP'
                                            'INSERT_OLD'
    Note : Since the change in location might lead us to scenarios where we might
           want to do various kinds of updates, all kinds of update modes have been
           added.
  */

  procedure maintain_element_entry (p_assignment_id        in number,
                                    p_effective_start_date in date,
                                    p_effective_end_date   in date,
                                    p_session_date         in date,
                                    p_jurisdiction_code    in varchar2,
                                    p_percentage_time      in number,
                                    p_mode                 in varchar2) is

   l_inp_value_id_table   hr_entry.number_table;
   l_scr_value_table      hr_entry.varchar2_table;

   l_element_type_id      number       :=0;
   l_inp_name             varchar2(80) :=null;
   l_inp_val_id           number       :=0;
   i                      number       := 1;
   l_element_link_id      number       :=0;
   l_element_entry_id     number       :=0;
   l_effective_start_date date;
   l_effective_end_date   date;
   l_mode                 varchar2(30);
   l_delete_flag          varchar2(1) := 'N';
   l_percent              number;
   l_end_of_time          date := to_date('31/12/4712','dd/mm/yyyy');
   l_payroll_installed    boolean := FALSE;

   /* Cursor to get the vertex element type */

   cursor csr_tax_element is
       select pet.element_type_id,
              piv.input_value_id,
              piv.name
       from   PAY_INPUT_VALUES_F  piv,
              PAY_ELEMENT_TYPES_F pet
       where  p_session_date between piv.effective_start_date
                             and piv.effective_end_date
       and    pet.element_type_id       = piv.element_type_id
       and    p_session_date between pet.effective_start_date
                             and pet.effective_end_date
       and    pet.element_name          = 'VERTEX';

   /* Cursor to get the element entry for the jurisdiction */

   cursor csr_ele_entry (p_element_link number, p_inp_val number)is
       select pee.element_entry_id
       from   PAY_ELEMENT_ENTRY_VALUES_F pev,
              PAY_ELEMENT_ENTRIES_F pee
       where    pev.screen_entry_value   = p_jurisdiction_code
       and    pev.input_value_id + 0   = p_inp_val
       and    p_session_date between pev.effective_start_date
                             and pev.effective_end_date
       and    pev.element_entry_id     = pee.element_entry_id
       and    p_session_date between pee.effective_start_date
                             and pee.effective_end_date
       and    pee.element_link_id      = p_element_link
       and    pee.assignment_id        = p_assignment_id;

   /* Cursor to get the current percentage of the element entry */

   cursor csr_get_curr_percnt (p_ele_entry_id number, p_inp_val number)is
       select pev.screen_entry_value
       from   PAY_ELEMENT_ENTRY_VALUES_F pev
       where  pev.screen_entry_value is not null
       and    pev.input_value_id + 0  = p_inp_val
       and    p_session_date between pev.effective_start_date
                             and pev.effective_end_date
       and  pev.element_entry_id     = p_ele_entry_id;


   begin

    l_payroll_installed := hr_utility.chk_product_install(p_product =>'Oracle Payroll',
                                                               p_legislation => 'US');
    if l_payroll_installed then

       hr_utility.set_location('pay_us_emp_dt_tax_rules.maintain_element_entry'
                               ,1);

       open  csr_tax_element;

       loop

          fetch csr_tax_element into l_element_type_id,
                                     l_inp_val_id,
                                     l_inp_name;

          exit when csr_tax_element%NOTFOUND;

          if upper(l_inp_name) = 'PAY VALUE'
          then
               l_inp_value_id_table(1) := l_inp_val_id;
          elsif upper(l_inp_name) = 'JURISDICTION'
          then
               l_inp_value_id_table(2) := l_inp_val_id;
          elsif upper(l_inp_name) = 'PERCENTAGE'
          then
               l_inp_value_id_table(3) := l_inp_val_id;
          end if;
       end loop;

       close csr_tax_element;

       hr_utility.set_location('pay_us_emp_dt_tax_rules.maintain_element_entry'
                               ,2);

       /* Check that all of the input value id for vertex, exists */

       for i in 1..3 loop

           if l_inp_value_id_table(i) = null or
              l_inp_value_id_table(i) = 0
           then
               fnd_message.set_name('PAY', 'HR_13140_TAX_ELEMENT_ERROR');
               fnd_message.set_token('1','VERTEX');
               fnd_message.raise_error;
           end if;

       end loop;

       hr_utility.set_location('pay_us_emp_dt_tax_rules.maintain_element_entry'
                                ,3);

       /* Get element link */
       l_element_link_id := hr_entry_api.get_link(
                                 P_assignment_id   => p_assignment_id,
                                 P_element_type_id => l_element_type_id,
                                 P_session_date    => p_effective_start_date);

       if l_element_link_id is null or l_element_link_id = 0
       then
           fnd_message.set_name('PAY', 'HR_13140_TAX_ELEMENT_ERROR');
           fnd_message.set_token('1','VERTEX');
           fnd_message.raise_error;
       end if;

       hr_utility.set_location('pay_us_emp_dt_tax_rules.maintain_element_entry'
                                ,4);

       /* Store screen entry value in the table */

       l_scr_value_table(1)     := null;
       l_scr_value_table(2)     := p_jurisdiction_code;
       l_scr_value_table(3)     := nvl(fnd_number.number_to_canonical(p_percentage_time),'0');

       /* assign the parameters to local variables because the element entry procedures
          expect them to be in out parameters */

       l_effective_start_date   := p_effective_start_date;
       l_effective_end_date     := p_effective_end_date;
       l_mode                   := p_mode;

       if p_mode = 'INSERT' then

             /* Create the vertex element entry */

             hr_utility.set_location('pay_us_emp_dt_tax_rules.maintain_element_entry' ,5);

             hr_entry_api.insert_element_entry( P_effective_start_date     => l_effective_start_date,
                                                P_effective_end_date       => l_effective_end_date,
                                                P_element_entry_id         => l_element_entry_id,
                                                P_assignment_id            => p_assignment_id,
                                                P_element_link_id          => l_element_link_id,
                                                P_creator_type             => 'UT',
                                                P_entry_type               => 'E',
                                                P_num_entry_values         => 3,
                                                P_input_value_id_tbl       => l_inp_value_id_table,
                                                P_entry_value_tbl          => l_scr_value_table);

              hr_utility.set_location('pay_us_emp_dt_tax_rules.maintain_element_entry' ,6);

    elsif p_mode in ('CORRECTION','UPDATE', 'UPDATE_CHANGE_INSERT','UPDATE_OVERRIDE','ZAP','DELETE_NEXT_CHANGE','FUTURE_CHANGE','INSERT_OLD') then

             /* Get the element entry of the vertex element entry that is to be updated
                or deleted */

             hr_utility.set_location('pay_us_emp_dt_tax_rules.maintain_element_entry' ,7);


              open csr_ele_entry(l_element_link_id, l_inp_value_id_table(2));

              fetch csr_ele_entry into l_element_entry_id;

              /* Added the delete flag for the upgrade. Currently, there
                 may be state tax records which might not have a vertex
                 element entry */

              if csr_ele_entry%NOTFOUND then
                if p_mode in('ZAP','DELETE_NEXT_CHANGE','FUTURE_CHANGE') then

                    l_delete_flag := 'N';
                else

                    close csr_ele_entry;
                    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                    fnd_message.set_token('PROCEDURE',
                     'pay_us_emp_dt_tax_rules.maintain_element_entry');
                    fnd_message.set_token('STEP','1');
                    fnd_message.raise_error;

                end if;

              else /* found the element entry id */

                  l_delete_flag := 'Y';

              end if;

              close csr_ele_entry;

              if p_mode = 'INSERT_OLD' then

                 open csr_get_curr_percnt(l_element_entry_id, l_inp_value_id_table(3));

                 fetch csr_get_curr_percnt into l_scr_value_table(3);

                 if csr_get_curr_percnt%NOTFOUND then

                    close csr_get_curr_percnt;
                    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                    fnd_message.set_token('PROCEDURE',
                        'pay_us_emp_dt_tax_rules.maintain_element_entry');
                    fnd_message.set_token('STEP','2');
                    fnd_message.raise_error;

                  end if;

                  close csr_get_curr_percnt;

                  if p_effective_end_date = l_end_of_time then

                     l_mode := 'UPDATE';

                  else

                     l_mode := 'UPDATE_CHANGE_INSERT';

                  end if;

              end if;

              if p_mode in ('ZAP','DELETE_NEXT_CHANGE','FUTURE_CHANGE')
                 and l_delete_flag = 'Y' then

                 hr_entry_api.delete_element_entry(
                    p_dt_delete_mode           => l_mode,
                    p_session_date             => p_session_date,
                    p_element_entry_id         => l_element_entry_id);

              elsif p_mode in ('CORRECTION','UPDATE', 'UPDATE_CHANGE_INSERT','UPDATE_OVERRIDE','INSERT_OLD') then

                 hr_entry_api.update_element_entry(
                    p_dt_update_mode           => l_mode,
                    p_session_date             => p_session_date,
                    p_element_entry_id         => l_element_entry_id,
                    p_num_entry_values         => 3,
                    p_input_value_id_tbl       => l_inp_value_id_table,
                    p_entry_value_tbl          => l_scr_value_table);

              end if;

           end if;

    end if;

  end maintain_element_entry;


  /* Name        : maintain_wc_ele_entry
     Purpose     : This procedure can be used to create as well as update the worker's
                   compensation element entry for an assignment. It calls the element
                   entries api to insert and update the element entry record.
     Parameters  :
                  p_assignment_id     -> The assignment for which the vertex elemnt entry is to be
                                         created/modified.
                  p_effective_start_date -> The start date of the element entry.
                  p_effective_end_date   -> The end date of the element entry.
                  p_session_date         -> This will be helpful for changing the wc element
                                            entry for change in the federal record.
                  p_jurisdiction_code    -> The jurisdiction code for which the elemnt entry is to
                                            created/updated.
                  p_mode                 -> If can have the following values :
                                            'INSERT'
                                            'CORRECTION',
                                            'UPDATE',
                                            'UPDATE_CHANGE_INSERT',
                                            'UPDATE_OVERRIDE',
                                            'ZAP'
    Note : For every change in federal record, we will be changing the worker's comp element entry.
  */

  procedure maintain_wc_ele_entry (p_assignment_id        in number,
                                   p_effective_start_date in date,
                                   p_effective_end_date   in date,
                                   p_session_date         in date,
                                   p_jurisdiction_code    in varchar2,
                                   p_mode                 in varchar2) is

   l_inp_value_id_table   hr_entry.number_table;
   l_scr_value_table      hr_entry.varchar2_table;

   l_element_type_id      number       :=0;
   l_inp_name             varchar2(80) :=null;
   l_inp_val_id           number       :=0;
   l_element_link_id      number       :=0;
   l_element_entry_id     number       :=0;
   l_effective_start_date date         := null;
   l_effective_end_date   date         := null;
   l_mode                 varchar2(30);
   l_delete_flag          varchar2(1);
   l_payroll_installed    boolean := FALSE;

   /* Cursor to get the worker's compensation element type */

   cursor csr_wc_tax_element is
       select pet.element_type_id,
              piv.input_value_id,
              piv.name
       from   PAY_INPUT_VALUES_F  piv,
              PAY_ELEMENT_TYPES_F pet
       where    p_session_date between piv.effective_start_date
              and piv.effective_end_date
       and    pet.element_type_id       = piv.element_type_id
       and    p_session_date between pet.effective_start_date
              and pet.effective_end_date
       and    pet.element_name   = 'Workers Compensation'; -- Bug 3354060 FTS on PAY_ELEMENT_TYPES_F was removed. Done by removing
                                                           -- 'upper' from pet.element_name and 'WORKERS COMPENSATION' was changed to
                                                           -- 'Workers Compensation'


   /* Cursor to get the worker's compensation element entry */

   cursor csr_wc_ele_entry (p_element_link number)is
       select pee.element_entry_id
       from   PAY_ELEMENT_ENTRIES_F pee
       where  p_session_date between pee.effective_start_date
              and pee.effective_end_date
       and    pee.element_link_id       = p_element_link
       and    pee.assignment_id         = p_assignment_id;

   begin

    l_payroll_installed := hr_utility.chk_product_install(p_product =>'Oracle Payroll',
                                                               p_legislation => 'US');
    if l_payroll_installed then

       hr_utility.set_location('pay_us_emp_dt_tax_rules.maintain_wc_ele_entry'
                               ,1);

       open  csr_wc_tax_element;

       loop

          fetch csr_wc_tax_element into l_element_type_id,
                                        l_inp_val_id,
                                        l_inp_name;

          exit when csr_wc_tax_element%NOTFOUND;

          if upper(l_inp_name) = 'PAY VALUE' then

               l_inp_value_id_table(1) := l_inp_val_id;

          elsif upper(l_inp_name) = 'JURISDICTION' then

               l_inp_value_id_table(2) := l_inp_val_id;

          end if;

       end loop;

       close csr_wc_tax_element;

       hr_utility.set_location('pay_us_emp_dt_tax_rules.maintain_wc_ele_entry'
                               ,2);

       /* Check that all of the input value id for vertex, exists */

       for i in 1..2 loop

           if l_inp_value_id_table(i) = null or
              l_inp_value_id_table(i) = 0 then

               fnd_message.set_name('PAY', 'HR_7713_TAX_ELEMENT_ERROR');
               fnd_message.raise_error;

           end if;

       end loop;

       hr_utility.set_location('pay_us_emp_dt_tax_rules.maintain_wc_ele_entry'
                                ,3);

       /* Get element link */
       l_element_link_id := hr_entry_api.get_link(
                                 P_assignment_id   => p_assignment_id,
                                 P_element_type_id => l_element_type_id,
                                 P_session_date    => p_effective_start_date);

       if l_element_link_id is null or l_element_link_id = 0
       then

           fnd_message.set_name('PAY', 'HR_7713_TAX_ELEMENT_ERROR');
           fnd_message.raise_error;

       end if;

       hr_utility.set_location('pay_us_emp_dt_tax_rules.maintain_wc_ele_entry'
                                ,4);

       /* Store screen entry value in the table */

       l_scr_value_table(1)     := null;
       l_scr_value_table(2)     := p_jurisdiction_code;

       /* assign the parameters to local variables because the element entry procedures
          expect them to be in out parameters */

       l_effective_start_date   := p_effective_start_date;
       l_effective_end_date     := p_effective_end_date;
       l_mode                   := p_mode;

       if p_mode = 'INSERT'
       then

           /* Insert the worker's compensation element entry */

           hr_utility.set_location(
                'pay_us_emp_dt_tax_rules.maintain_wc_ele_entry' ,5);
           hr_entry_api.insert_element_entry(
                P_effective_start_date     => l_effective_start_date,
                P_effective_end_date       => l_effective_end_date,
                P_element_entry_id         => l_element_entry_id,
                P_assignment_id            => p_assignment_id,
                P_element_link_id          => l_element_link_id,
                P_creator_type             => 'UT',
                P_entry_type               => 'E',
                P_num_entry_values         => 2,
                P_input_value_id_tbl       => l_inp_value_id_table,
                P_entry_value_tbl          => l_scr_value_table);

            hr_utility.set_location(
                 'pay_us_emp_dt_tax_rules.maintain_wc_ele_entry' ,8);

          elsif p_mode in ('CORRECTION', 'UPDATE', 'UPDATE_CHANGE_INSERT','UPDATE_OVERRIDE','ZAP')then

             /* Update the worker's compensation element entry */

              open csr_wc_ele_entry(l_element_link_id);

              fetch csr_wc_ele_entry into l_element_entry_id;

              if csr_wc_ele_entry%NOTFOUND then

                if p_mode in('ZAP','DELETE_NEXT_CHANGE','FUTURE_CHANGE') then

                    l_delete_flag := 'N';
                else

                  close csr_wc_ele_entry;
                  fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                  fnd_message.set_token('PROCEDURE',
                 'pay_us_emp_dt_tax_rules.maintain_wc_ele_entry');
                 fnd_message.set_token('STEP','8');
                  fnd_message.raise_error;

                end if;

              else /* found the wc element entry id */

                  l_delete_flag := 'Y';

              end if;

              close csr_wc_ele_entry;

              if p_mode = 'ZAP' and l_delete_flag = 'Y' then

                 /* All of the tax %age records will be created from the date on which the
                    default tax rules criteria was met till the end of time. So, we should
                    get records for the state, county and city for the same effective start
                    date */

                 hr_entry_api.delete_element_entry(
                    p_dt_delete_mode           => l_mode,
                    p_session_date             => p_session_date,
                    p_element_entry_id         => l_element_entry_id);

              elsif p_mode in ('CORRECTION','UPDATE', 'UPDATE_CHANGE_INSERT','UPDATE_OVERRIDE') then

                 hr_entry_api.update_element_entry(
                    p_dt_update_mode           => l_mode,
                    p_session_date             => p_session_date,
                    p_element_entry_id         => l_element_entry_id,
                    p_num_entry_values         => 2,
                    p_input_value_id_tbl       => l_inp_value_id_table,
                    p_entry_value_tbl          => l_scr_value_table);

              end if;

          end if;

     end if;

  end maintain_wc_ele_entry;


  /* Name         : create_tax_percentage
     Purpose      : This procedure will be called whenever a state tax rule or a county
                    tax rule or a city tax rule record gets created.
                    It gets all of the location changes that have taken place for the
                    assignment and then for each of location change, it creates an element
                    entry for the jurisdiction depending upon the kind of tax rule record
                    that is getting created.
     Parameters   :
                   p_assignment_id     -> The assignemnt for which the tax rule record and hence
                                          the percentage record is getting created.
                   p_state_code        -> If p_state_code is not null and p_county_code is null
                                          and p_city_code is null then the p_state_code specifies
                                          the state for which the tax %age record is being created.
                   p_county_code       -> If p_state_code is not null and p_county_code is not null
                                          and p_city_code is null then it specifies the county in the
                                          state of p_state_code, for which the tax percentage record
                                          is being created.
                   p_city_code         -> If p_state_code is not null and p_county_code is not null
                                          and p_city_code is not null then it specifies the city in
                                          the county of p_county_code for the state of p_state_code,
                                          for which the tax percentage record is being created.
                   p_time_in_state     -> If a state %age record is being created then it specifies
                                          the time in state.
                   p_time_in_county    -> If a county %age record is being created then it specifies
                                          the time in county.
                   p_time_in_city      -> If a city %age record is being created then it specifies
                                          the time in city.
  */

  procedure create_tax_percentage (p_assignment_id       in number,
                                   p_state_code          in varchar2,
                                   p_county_code         in varchar2,
                                   p_city_code           in varchar2,
                                   p_time_in_state       in number,
                                   p_time_in_county      in number,
                                   p_time_in_city        in number) is

  l_first_location_id    number(15) := 0;
  l_next_location_id     number(15) := 0;
  l_first_effective_date date := null;
  l_first_prev_date      date := null;
  l_next_effective_date  date := null;
  l_next_prev_date       date := null;
  l_jurisdiction_code    varchar2(11);
  l_default_date         date;
  l_time                 number;
  l_ctr                  number := 0;
  l_mode                 varchar2(30);

   /* Get Effective_start_Date of the federal record to set the effective date
      of the element entry. All of the element entries should be created from
      the date the deafulting tax rules criteria was met. Since the federal
      record is created from the date the defaulting criteria is met,
      taking the min(Federal effective start date) will give us the date on
      which the defaulting criteria was met and hence the effective start date
      of the element entry */

   cursor csr_get_eff_date is
       select min(effective_start_date)
       from   PAY_US_EMP_FED_TAX_RULES_F
       where  assignment_id = p_assignment_id;

  /* Since a change in location may have taken place before the default tax
     rules criteria is met, we will consider only those locations whose
     effective_end_date >= default tax rules date i.e. the federal tax rules
     date. Thus we will be breaking the percentage records only for those
     change in locations which have taken place after the default tax rules
    date.
           L1      L2     L3      L4      L2
    Asg |--------|------|-------|------|------

    Federal Tax       |----|---|----|---|---------------

    Note, in the above example the default tax rules criteria was satisfied
    after change in location to L2. So, we should not be considering L1.
    Also, since the same location may get assigned after some time period,
    we have no other alternative than to query up all the records after the
    default criteria date and then manual identify the change in locations
    by means of comparing the location id */

  cursor csr_get_locations (passignment number, pdefault_date date) is
    select paf1.location_id,
           paf1.effective_start_date,
           paf1.effective_start_date - 1
    from per_assignments_f paf1
    where paf1.assignment_id = passignment
    and paf1.effective_start_date >= pdefault_date
    order by 2;

  begin

    /* Form the jurisdiction code */

    if p_state_code is not null and p_county_code is null and
       p_city_code is null
    then

           l_jurisdiction_code := p_state_code || '-000-0000';
           l_time              := p_time_in_state;

    elsif p_state_code is not null and p_county_code is not null and
          p_city_code is null
    then

             l_jurisdiction_code := p_state_code || '-' || p_county_code ||
                                    '-0000';
             l_time              := p_time_in_county;

    elsif p_state_code is not null and p_county_code is not null and
          p_city_code is not null
    then

            l_jurisdiction_code := p_state_code || '-' || p_county_code ||
                                    '-' || p_city_code;
            l_time              := p_time_in_city;

    end if;

    /* Get effective Start date of the Federal Tax Rules record */

    open  csr_get_eff_date;

    fetch csr_get_eff_date into l_default_date;

    if l_default_date is null then

         close csr_get_eff_date;
         fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token('PROCEDURE',
                 'pay_us_emp_dt_tax_rules.create_tax_percentage');
         fnd_message.set_token('STEP','1');
         fnd_message.raise_error;

    end if;

    close csr_get_eff_date;

    /* Get all of the changes in location for the assignment */

    open csr_get_locations(p_assignment_id, l_default_date);

    fetch csr_get_locations into l_first_location_id, l_first_effective_date,
                                 l_first_prev_date;
    l_ctr := 1;

    /* The effective start date of the first location might be less than
       the date on which the default tax criteria was met. So, set the
       effective start date to the date on which the default tax rules
      criteria was satisfied */

    l_first_effective_date := l_default_date;

    /* Initialise the next location id, next effective date and
       next prev date  before doing the fetch */

    l_next_location_id     := null;
    l_next_effective_date  := null;
    l_next_prev_date       := null;

    loop

     exit when csr_get_locations%NOTFOUND;

     fetch csr_get_locations into l_next_location_id, l_next_effective_date,
                                   l_next_prev_date;

    if l_next_location_id <> l_first_location_id then

      if l_ctr = 1 then

         l_mode := 'INSERT';

      else

         l_mode := 'UPDATE';

      end if;

      /* Call maintain_element_entry for the first location */

      if l_ctr = 1 then

       maintain_element_entry(p_assignment_id        => p_assignment_id,
                              p_effective_start_date => l_first_effective_date,
                              p_effective_end_date   => to_date('31-12-4712','dd-mm-yyyy'),
                              p_session_date         => l_first_effective_date,
                              p_jurisdiction_code    => l_jurisdiction_code,
                              p_percentage_time      => l_time,
                              p_mode                 => 'INSERT');

      else


       maintain_element_entry(p_assignment_id        => p_assignment_id,
                              p_effective_start_date => l_first_effective_date,
                              p_effective_end_date   => to_date('31-12-4712','dd-mm-yyyy'),
                              p_session_date         => l_first_effective_date,
                              p_jurisdiction_code    => l_jurisdiction_code,
                              p_percentage_time      => l_time,
                              p_mode                 => 'UPDATE');
      end if;

      l_first_location_id    := l_next_location_id;
      l_first_effective_date := l_next_effective_date;
      l_first_prev_date      := l_next_prev_date;
      /* Initialise the next location id, next effective date and
         next prev date  before doing the fetch */
      l_next_location_id     := null;
      l_next_effective_date  := null;
      l_next_prev_date       := null;
      l_ctr := l_ctr + 1;

     end if;

    end loop;

    close csr_get_locations;

    /* Create the element entry for the last change in location . The last
       element entry record for the percentage time should be created till
       end of time. hence, 31-dec-4712. */

    if l_ctr = 1 then


      maintain_element_entry(p_assignment_id        => p_assignment_id,
                           p_effective_start_date => l_first_effective_date,
                           p_effective_end_date   => to_date('31-12-4712','dd-mm-yyyy'),
                           p_session_date         => l_first_effective_date,
                           p_jurisdiction_code    => l_jurisdiction_code,
                           p_percentage_time      => l_time,
                           p_mode                 => 'INSERT');
    else


       maintain_element_entry(p_assignment_id        => p_assignment_id,
                           p_effective_start_date => l_first_effective_date,
                           p_effective_end_date   => to_date('31-12-4712','dd-mm-yyyy'),
                           p_session_date         => l_first_effective_date,
                           p_jurisdiction_code    => l_jurisdiction_code,
                           p_percentage_time      => l_time,
                           p_mode                 => 'UPDATE');

    end if;



  end create_tax_percentage;


  /* Name        : insert_fed_tax_row
     Purpose     : To create the federal tax rule record. It also calls the
                   maintain_wc_ele_entry routine to create the worker's compensation
                   for the SUI state
  */

  procedure insert_fed_tax_row ( p_emp_fed_tax_rule_id in out nocopy number,
				                 p_effective_start_date in date,
                                  p_effective_end_date in date,
                                  p_assignment_id in number,
                                  p_sui_state_code in varchar2,
                                  p_sui_jurisdiction_code in varchar2,
                                  p_business_group_id in number,
                                  p_additional_wa_amount in number,
                                  p_filing_status_code in varchar2,
                                  p_fit_override_amount in number,
 				                  p_fit_override_rate in number,
                                  p_withholding_allowances in number,
                                  p_cumulative_taxation in varchar2,
                                  p_eic_filing_status_code in varchar2,
                                  p_fit_additional_tax in number,
                                  p_fit_exempt in varchar2,
                                  p_futa_tax_exempt in varchar2,
                                  p_medicare_tax_exempt in varchar2,
                                  p_ss_tax_exempt in varchar2,
                                  p_wage_exempt in varchar2,
                                  p_statutory_employee in varchar2,
                                  p_w2_filed_year in number,
                                  p_supp_tax_override_rate in number,
                                  p_excessive_wa_reject_date in date,
                                  p_attribute_category        in varchar2,
                                  p_attribute1                in varchar2,
                                  p_attribute2                in varchar2,
                                  p_attribute3                in varchar2,
                                  p_attribute4                in varchar2,
                                  p_attribute5                in varchar2,
                                  p_attribute6                in varchar2,
                                  p_attribute7                in varchar2,
                                  p_attribute8                in varchar2,
                                  p_attribute9                in varchar2,
                                  p_attribute10               in varchar2,
                                  p_attribute11               in varchar2,
                                  p_attribute12               in varchar2,
                                  p_attribute13               in varchar2,
                                  p_attribute14               in varchar2,
                                  p_attribute15               in varchar2,
                                  p_attribute16               in varchar2,
                                  p_attribute17               in varchar2,
                                  p_attribute18               in varchar2,
                                  p_attribute19               in varchar2,
                                  p_attribute20               in varchar2,
                                  p_attribute21               in varchar2,
                                  p_attribute22               in varchar2,
                                  p_attribute23               in varchar2,
                                  p_attribute24               in varchar2,
                                  p_attribute25               in varchar2,
                                  p_attribute26               in varchar2,
                                  p_attribute27               in varchar2,
                                  p_attribute28               in varchar2,
                                  p_attribute29               in varchar2,
                                  p_attribute30               in varchar2,
                                  p_fed_information_category  in varchar2,
                                  p_fed_information1          in varchar2,
                                  p_fed_information2          in varchar2,
                                  p_fed_information3          in varchar2,
                                  p_fed_information4          in varchar2,
                                  p_fed_information5          in varchar2,
                                  p_fed_information6          in varchar2,
                                  p_fed_information7          in varchar2,
                                  p_fed_information8          in varchar2,
                                  p_fed_information9          in varchar2,
                                  p_fed_information10         in varchar2,
                                  p_fed_information11         in varchar2,
                                  p_fed_information12         in varchar2,
                                  p_fed_information13         in varchar2,
                                  p_fed_information14         in varchar2,
                                  p_fed_information15         in varchar2,
                                  p_fed_information16         in varchar2,
                                  p_fed_information17         in varchar2,
                                  p_fed_information18         in varchar2,
                                  p_fed_information19         in varchar2,
                                  p_fed_information20         in varchar2,
                                  p_fed_information21         in varchar2,
                                  p_fed_information22         in varchar2,
                                  p_fed_information23         in varchar2,
                                  p_fed_information24         in varchar2,
                                  p_fed_information25         in varchar2,
                                  p_fed_information26         in varchar2,
                                  p_fed_information27         in varchar2,
                                  p_fed_information28         in varchar2,
                                  p_fed_information29         in varchar2,
                                  p_fed_information30         in varchar2,
                                  p_mode  in varchar2) is


  l_step   number;
  l_pos    number;

  l_new_date             date;
  cursor csr_fed_tax_rule_id is
  select PAY_US_EMP_FED_TAX_RULES_S.nextval
  from sys.DUAL;

  begin


     hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_fed_tax_row'||
                             ' - Opening cursor', 1);

     if p_mode = 'INSERT' then

       open csr_fed_tax_rule_id;

       hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_fed_tax_row'||
                             ' - Fetching cursor', 2);

       fetch csr_fed_tax_rule_id into p_emp_fed_tax_rule_id;

       hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_fed_tax_row'||
                             ' - Closing cursor', 3);

       close csr_fed_tax_rule_id;


       hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_fed_tax_row'||
                             ' - inserting row', 4);

     end if;

     l_step := 1;

     if p_mode = 'UPDATE' then

          select p_effective_start_date -1
          into l_new_date
          from DUAL;

          /* Update the Federal tax record as of the p_effective_start_date */

          l_step := 2;

          update PAY_US_EMP_FED_TAX_RULES_F
          set    effective_end_date = l_new_date
          where assignment_id        = p_assignment_id
          and   effective_end_date   = p_effective_end_date;

      end if;

     l_step := 3;

     insert into PAY_US_EMP_FED_TAX_RULES_F
     (emp_fed_tax_rule_id,
      effective_start_date,
      effective_end_date,
      assignment_id,
      sui_state_code,
      sui_jurisdiction_code,
      business_group_id,
      additional_wa_amount,
      filing_status_code,
      fit_override_amount,
      fit_override_rate,
      withholding_allowances,
      cumulative_taxation,
      eic_filing_status_code,
      fit_additional_tax,
      fit_exempt,
      futa_tax_exempt,
      medicare_tax_exempt,
      ss_tax_exempt,
      wage_exempt,
      statutory_employee,
      w2_filed_year,
      supp_tax_override_rate,
      excessive_wa_reject_date,
      object_version_number,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      attribute21,
      attribute22,
      attribute23,
      attribute24,
      attribute25,
      attribute26,
      attribute27,
      attribute28,
      attribute29,
      attribute30,
      fed_information_category,
      fed_information1,
      fed_information2,
      fed_information3,
      fed_information4,
      fed_information5,
      fed_information6,
      fed_information7,
      fed_information8,
      fed_information9,
      fed_information10,
      fed_information11,
      fed_information12,
      fed_information13,
      fed_information14,
      fed_information15,
      fed_information16,
      fed_information17,
      fed_information18,
      fed_information19,
      fed_information20,
      fed_information21,
      fed_information22,
      fed_information23,
      fed_information24,
      fed_information25,
      fed_information26,
      fed_information27,
      fed_information28,
      fed_information29,
      fed_information30)
     values
     (p_emp_fed_tax_rule_id,
      p_effective_start_date,
      p_effective_end_date,
      p_assignment_id,
      p_sui_state_code,
      p_sui_jurisdiction_code,
      p_business_group_id,
      p_additional_wa_amount,
      lpad(p_filing_status_code,2,'0'),
      p_fit_override_amount,
      p_fit_override_rate,
      p_withholding_allowances,
      p_cumulative_taxation,
      p_eic_filing_status_code,
      p_fit_additional_tax,
      p_fit_exempt,
      p_futa_tax_exempt,
      p_medicare_tax_exempt,
      p_ss_tax_exempt,
      p_wage_exempt,
      p_statutory_employee,
      p_w2_filed_year,
      p_supp_tax_override_rate,
      p_excessive_wa_reject_date,
      0,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute16,
      p_attribute17,
      p_attribute18,
      p_attribute19,
      p_attribute20,
      p_attribute21,
      p_attribute22,
      p_attribute23,
      p_attribute24,
      p_attribute25,
      p_attribute26,
      p_attribute27,
      p_attribute28,
      p_attribute29,
      p_attribute30,
      p_fed_information_category,
      p_fed_information1,
      p_fed_information2,
      p_fed_information3,
      p_fed_information4,
      p_fed_information5,
      p_fed_information6,
      p_fed_information7,
      p_fed_information8,
      p_fed_information9,
      p_fed_information10,
      p_fed_information11,
      p_fed_information12,
      p_fed_information13,
      p_fed_information14,
      p_fed_information15,
      p_fed_information16,
      p_fed_information17,
      p_fed_information18,
      p_fed_information19,
      p_fed_information20,
      p_fed_information21,
      p_fed_information22,
      p_fed_information23,
      p_fed_information24,
      p_fed_information25,
      p_fed_information26,
      p_fed_information27,
      p_fed_information28,
      p_fed_information29,
      p_fed_information30);


      /* create workers compensation element entry for the sui state in
         the federal record */

      hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_fed_tax_row'||
                             ' - inserting row', 5);
      l_step := 4;

      if  hr_utility.chk_product_install(p_product =>'Oracle Payroll',
                                         p_legislation => 'US') then

         maintain_wc_ele_entry (p_assignment_id      => p_assignment_id,
                           p_effective_start_date => p_effective_start_date,
                           p_effective_end_date   => p_effective_end_date,
                           p_session_date         => p_effective_start_date,
                           p_jurisdiction_code    => p_sui_jurisdiction_code,
                           p_mode                 => p_mode);
      end if;

      exception
      when others then
      l_pos := instr(substr(sqlerrm,1,60),'HR_7713_TAX_ELEMENT_ERROR');

      if l_pos = 0 then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE',
                       'pay_us_emp_dt_tax_rules.insert_fed_tax_row - '|| substr(sqlerrm,1,60));
        fnd_message.set_token('STEP',to_char(l_step));
        fnd_message.raise_error;

      else
         fnd_message.set_name('PAY', 'HR_7713_TAX_ELEMENT_ERROR');
         fnd_message.raise_error;
      end if;
  end insert_fed_tax_row;


  /* Name        : insert_state_tax_row
     Purpose     : To create the state tax rule record. It also calls the
                   create_tax_percentage routine to create the %age records
                   for the state, for every change in location of the assignment
  */

  procedure insert_state_tax_row ( p_row_id in out nocopy varchar2,
                                   p_emp_state_tax_rule_id in out nocopy number,
                                   p_effective_start_date in date,
                                   p_effective_end_date in date,
                                   p_assignment_id in number,
                                   p_state_code in varchar2,
                                   p_jurisdiction_code in varchar2,
                                   p_business_group_id in number,
                                   p_additional_wa_amount in number,
                                   p_filing_status_code in varchar2,
                                   p_remainder_percent in number,
                                   p_secondary_wa in number,
                                   p_sit_additional_tax in number,
                                   p_sit_override_amount in number,
                                   p_sit_override_rate in number,
                                   p_withholding_allowances in number,
                                   p_excessive_wa_reject_date in date,
                                   p_sdi_exempt in varchar2,
                                   p_sit_exempt in varchar2,
                                   p_sit_optional_calc_ind in varchar2,
                                   p_state_non_resident_cert in varchar2,
                                   p_sui_exempt in varchar2,
                                   p_wc_exempt in varchar2,
                                   p_wage_exempt in varchar2,
                                   p_sui_wage_base_override_amt in number,
                                   p_supp_tax_override_rate in number,
                                   p_time_in_state in number,
                                   p_attribute_category        in varchar2,
                                   p_attribute1                in varchar2,
                                   p_attribute2                in varchar2,
                                   p_attribute3                in varchar2,
                                   p_attribute4                in varchar2,
                                   p_attribute5                in varchar2,
                                   p_attribute6                in varchar2,
                                   p_attribute7                in varchar2,
                                   p_attribute8                in varchar2,
                                   p_attribute9                in varchar2,
                                   p_attribute10               in varchar2,
                                   p_attribute11               in varchar2,
                                   p_attribute12               in varchar2,
                                   p_attribute13               in varchar2,
                                   p_attribute14               in varchar2,
                                   p_attribute15               in varchar2,
                                   p_attribute16               in varchar2,
                                   p_attribute17               in varchar2,
                                   p_attribute18               in varchar2,
                                   p_attribute19               in varchar2,
                                   p_attribute20               in varchar2,
                                   p_attribute21               in varchar2,
                                   p_attribute22               in varchar2,
                                   p_attribute23               in varchar2,
                                   p_attribute24               in varchar2,
                                   p_attribute25               in varchar2,
                                   p_attribute26               in varchar2,
                                   p_attribute27               in varchar2,
                                   p_attribute28               in varchar2,
                                   p_attribute29               in varchar2,
                                   p_attribute30               in varchar2,
                                   p_sta_information_category  in varchar2,
                                   p_sta_information1          in varchar2,
                                   p_sta_information2          in varchar2,
                                   p_sta_information3          in varchar2,
                                   p_sta_information4          in varchar2,
                                   p_sta_information5          in varchar2,
                                   p_sta_information6          in varchar2,
                                   p_sta_information7          in varchar2,
                                   p_sta_information8          in varchar2,
                                   p_sta_information9          in varchar2,
                                   p_sta_information10         in varchar2,
                                   p_sta_information11         in varchar2,
                                   p_sta_information12         in varchar2,
                                   p_sta_information13         in varchar2,
                                   p_sta_information14         in varchar2,
                                   p_sta_information15         in varchar2,
                                   p_sta_information16         in varchar2,
                                   p_sta_information17         in varchar2,
                                   p_sta_information18         in varchar2,
                                   p_sta_information19         in varchar2,
                                   p_sta_information20         in varchar2,
                                   p_sta_information21         in varchar2,
                                   p_sta_information22         in varchar2,
                                   p_sta_information23         in varchar2,
                                   p_sta_information24         in varchar2,
                                   p_sta_information25         in varchar2,
                                   p_sta_information26         in varchar2,
                                   p_sta_information27         in varchar2,
                                   p_sta_information28         in varchar2,
                                   p_sta_information29         in varchar2,
                                   p_sta_information30         in varchar2
                                   ) is

  cursor csr_state_tax_rule_id is
    select PAY_US_EMP_STATE_TAX_RULES_S.nextval
    from sys.DUAL;

  cursor csr_get_row_id is
    select rowidtochar(rowid)
    from PAY_US_EMP_STATE_TAX_RULES_F str
    where str.emp_state_tax_rule_id = p_emp_state_tax_rule_id
    and   str.effective_start_date  = p_effective_start_date
    and   str.effective_end_date    = p_effective_end_date;

  begin


     hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_st_tax_row'||
                             ' - Opening cursor', 1);

     open csr_state_tax_rule_id;

     hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_st_tax_row'||
                             ' - Fetching cursor', 2);

     fetch csr_state_tax_rule_id into p_emp_state_tax_rule_id;

     hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_st_tax_row'||
                             ' - Closing cursor', 3);

     close csr_state_tax_rule_id;


     hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_st_tax_row'||
                             ' - inserting row', 4);

     insert into PAY_US_EMP_STATE_TAX_RULES_F
     (emp_state_tax_rule_id,
      effective_start_date,
      effective_end_date,
      assignment_id,
      state_code,
      jurisdiction_code,
      business_group_id,
      additional_wa_amount,
      filing_status_code,
      remainder_percent,
      secondary_wa,
      sit_additional_tax,
      sit_override_amount,
      sit_override_rate,
      withholding_allowances,
      excessive_wa_reject_date,
      sdi_exempt,
      sit_exempt,
      sit_optional_calc_ind,
      state_non_resident_cert,
      sui_exempt,
      wc_exempt,
      wage_exempt,
      sui_wage_base_override_amount,
      supp_tax_override_rate,
      object_version_number,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      attribute21,
      attribute22,
      attribute23,
      attribute24,
      attribute25,
      attribute26,
      attribute27,
      attribute28,
      attribute29,
      attribute30,
      sta_information_category,
      sta_information1,
      sta_information2,
      sta_information3,
      sta_information4,
      sta_information5,
      sta_information6,
      sta_information7,
      sta_information8,
      sta_information9,
      sta_information10,
      sta_information11,
      sta_information12,
      sta_information13,
      sta_information14,
      sta_information15,
      sta_information16,
      sta_information17,
      sta_information18,
      sta_information19,
      sta_information20,
      sta_information21,
      sta_information22,
      sta_information23,
      sta_information24,
      sta_information25,
      sta_information26,
      sta_information27,
      sta_information28,
      sta_information29,
      sta_information30)
     values
     (p_emp_state_tax_rule_id,
      p_effective_start_date,
      p_effective_end_date,
      p_assignment_id,
      p_state_code,
      p_jurisdiction_code,
      p_business_group_id,
      p_additional_wa_amount,
      lpad(p_filing_status_code,2,'0'),
      p_remainder_percent,
      p_secondary_wa,
      p_sit_additional_tax,
      p_sit_override_amount,
      p_sit_override_rate,
      p_withholding_allowances,
      p_excessive_wa_reject_date,
      p_sdi_exempt,
      p_sit_exempt,
      p_sit_optional_calc_ind,
      p_state_non_resident_cert,
      p_sui_exempt,
      p_wc_exempt,
      p_wage_exempt,
      p_sui_wage_base_override_amt,
      p_supp_tax_override_rate,
      0,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute16,
      p_attribute17,
      p_attribute18,
      p_attribute19,
      p_attribute20,
      p_attribute21,
      p_attribute22,
      p_attribute23,
      p_attribute24,
      p_attribute25,
      p_attribute26,
      p_attribute27,
      p_attribute28,
      p_attribute29,
      p_attribute30,
      p_sta_information_category,
      p_sta_information1,
      p_sta_information2,
      p_sta_information3,
      p_sta_information4,
      p_sta_information5,
      p_sta_information6,
      p_sta_information7,
      p_sta_information8,
      p_sta_information9,
      p_sta_information10,
      p_sta_information11,
      p_sta_information12,
      p_sta_information13,
      p_sta_information14,
      p_sta_information15,
      p_sta_information16,
      p_sta_information17,
      p_sta_information18,
      p_sta_information19,
      p_sta_information20,
      p_sta_information21,
      p_sta_information22,
      p_sta_information23,
      p_sta_information24,
      p_sta_information25,
      p_sta_information26,
      p_sta_information27,
      p_sta_information28,
      p_sta_information29,
      p_sta_information30);

     if sql%notfound then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE',
                        'pay_us_emp_dt_tax_rules.insert_state_tax_row');
        fnd_message.set_token('STEP','4');
        fnd_message.raise_error;
     end if;

     open csr_get_row_id;

     fetch csr_get_row_id into p_row_id;

     if csr_get_row_id%NOTFOUND then
        close csr_get_row_id;
        raise no_data_found;
     end if;

     close csr_get_row_id;

     hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_st_tax_row'||
                             ' - creating %age record ', 5);

     /* Get the changes in location of an assignment.
       For each change in location, create vertex element entry with
       time in state as 0% - if Payroll is installed */

     if hr_utility.chk_product_install(p_product     =>'Oracle Payroll',
                                       p_legislation => 'US') then

        create_tax_percentage (p_assignment_id => p_assignment_id,
                               p_state_code    => p_state_code,
                               p_county_code   => null,
                               p_city_code     => null,
                               p_time_in_state => nvl(p_time_in_state,0),
                               p_time_in_county => 0,
                               p_time_in_city   => 0);

        /* Insert row into the pay_us_asg_reporting table */

        pay_asg_geo_pkg.create_asg_geo_row(P_assignment_id => p_assignment_id,
                                           P_jurisdiction  =>  p_jurisdiction_code,
                                           P_tax_unit_id   =>  NULL );
      end if;

  end insert_state_tax_row;


  /* Name        : insert_county_tax_row
     Purpose     : To create the county tax rule record. It also calls the
                   create_tax_percentage routine to create the %age records
                   for the county, for every change in location of the assignment
  */
  procedure insert_county_tax_row ( p_row_id in out nocopy varchar2,
                                    p_emp_county_tax_rule_id in out nocopy number,
                                    p_effective_start_date in date,
                                    p_effective_end_date in date,
                                    p_assignment_id in number,
                                    p_state_code in varchar2,
                                    p_county_code in varchar2,
                                    p_business_group_id in number,
                                    p_additional_wa_rate in number,
                                    p_filing_status_code in varchar2,
                                    p_jurisdiction_code in varchar2,
                                    p_lit_additional_tax in number,
                                    p_lit_override_amount in number,
                                    p_lit_override_rate in number,
                                    p_withholding_allowances in number,
                                    p_lit_exempt in varchar2,
                                    p_sd_exempt in varchar2,
                                    p_ht_exempt in varchar2,
                                    p_wage_exempt in varchar2,
                                    p_school_district_code in varchar2,
                                    p_time_in_county in number,
                                    p_attribute_category        in varchar2,
                                    p_attribute1                in varchar2,
                                    p_attribute2                in varchar2,
                                    p_attribute3                in varchar2,
                                    p_attribute4                in varchar2,
                                    p_attribute5                in varchar2,
                                    p_attribute6                in varchar2,
                                    p_attribute7                in varchar2,
                                    p_attribute8                in varchar2,
                                    p_attribute9                in varchar2,
                                    p_attribute10               in varchar2,
                                    p_attribute11               in varchar2,
                                    p_attribute12               in varchar2,
                                    p_attribute13               in varchar2,
                                    p_attribute14               in varchar2,
                                    p_attribute15               in varchar2,
                                    p_attribute16               in varchar2,
                                    p_attribute17               in varchar2,
                                    p_attribute18               in varchar2,
                                    p_attribute19               in varchar2,
                                    p_attribute20               in varchar2,
                                    p_attribute21               in varchar2,
                                    p_attribute22               in varchar2,
                                    p_attribute23               in varchar2,
                                    p_attribute24               in varchar2,
                                    p_attribute25               in varchar2,
                                    p_attribute26               in varchar2,
                                    p_attribute27               in varchar2,
                                    p_attribute28               in varchar2,
                                    p_attribute29               in varchar2,
                                    p_attribute30               in varchar2,
                                    p_cnt_information_category  in varchar2,
                                    p_cnt_information1          in varchar2,
                                    p_cnt_information2          in varchar2,
                                    p_cnt_information3          in varchar2,
                                    p_cnt_information4          in varchar2,
                                    p_cnt_information5          in varchar2,
                                    p_cnt_information6          in varchar2,
                                    p_cnt_information7          in varchar2,
                                    p_cnt_information8          in varchar2,
                                    p_cnt_information9          in varchar2,
                                    p_cnt_information10         in varchar2,
                                    p_cnt_information11         in varchar2,
                                    p_cnt_information12         in varchar2,
                                    p_cnt_information13         in varchar2,
                                    p_cnt_information14         in varchar2,
                                    p_cnt_information15         in varchar2,
                                    p_cnt_information16         in varchar2,
                                    p_cnt_information17         in varchar2,
                                    p_cnt_information18         in varchar2,
                                    p_cnt_information19         in varchar2,
                                    p_cnt_information20         in varchar2,
                                    p_cnt_information21         in varchar2,
                                    p_cnt_information22         in varchar2,
                                    p_cnt_information23         in varchar2,
                                    p_cnt_information24         in varchar2,
                                    p_cnt_information25         in varchar2,
                                    p_cnt_information26         in varchar2,
                                    p_cnt_information27         in varchar2,
                                    p_cnt_information28         in varchar2,
                                    p_cnt_information29         in varchar2,
                                    p_cnt_information30         in varchar2) is

  cursor csr_county_tax_rule_id is
    select PAY_US_EMP_COUNTY_TAX_RULES_S.nextval
    from sys.DUAL;

  cursor csr_get_row_id is
    select rowidtochar(rowid)
    from PAY_US_EMP_COUNTY_TAX_RULES_F ctr
    where ctr.emp_county_tax_rule_id = p_emp_county_tax_rule_id
    and   ctr.effective_start_date  = p_effective_start_date
    and   ctr.effective_end_date    = p_effective_end_date;

  begin

    if p_school_district_code is not null
    then

       /* Check that the school district is assigned to only one county/city
          at a given point in time */

        pay_us_emp_dt_tax_val.check_school_district(
                              p_assignment => p_assignment_id,
                              p_start_date => p_effective_start_date,
                              p_end_date   => p_effective_end_date,
                              p_mode       => 'I',
                              p_rowid      => null);
    end if;

    hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_county_tax_row'||
                             ' - Opening cursor', 1);

     open csr_county_tax_rule_id;

    hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_county_tax_row'||
                             ' - Fetching cursor', 2);

     fetch csr_county_tax_rule_id into p_emp_county_tax_rule_id;

    hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_county_tax_row'||
                             ' - Closing cursor', 3);

     close csr_county_tax_rule_id;


    hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_county_tax_row'||
                             ' - inserting row', 4);


     insert into pay_us_emp_county_tax_rules_f
     (emp_county_tax_rule_id,
      effective_start_date,
      effective_end_date,
      assignment_id,
      state_code,
      county_code,
      business_group_id,
      additional_wa_rate,
      filing_status_code,
      jurisdiction_code,
      lit_additional_tax,
      lit_override_amount,
      lit_override_rate,
      withholding_allowances,
      lit_exempt,
      sd_exempt,
      ht_exempt,
      wage_exempt,
      school_district_code,
      object_version_number,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      attribute21,
      attribute22,
      attribute23,
      attribute24,
      attribute25,
      attribute26,
      attribute27,
      attribute28,
      attribute29,
      attribute30,
      cnt_information_category,
      cnt_information1,
      cnt_information2,
      cnt_information3,
      cnt_information4,
      cnt_information5,
      cnt_information6,
      cnt_information7,
      cnt_information8,
      cnt_information9,
      cnt_information10,
      cnt_information11,
      cnt_information12,
      cnt_information13,
      cnt_information14,
      cnt_information15,
      cnt_information16,
      cnt_information17,
      cnt_information18,
      cnt_information19,
      cnt_information20,
      cnt_information21,
      cnt_information22,
      cnt_information23,
      cnt_information24,
      cnt_information25,
      cnt_information26,
      cnt_information27,
      cnt_information28,
      cnt_information29,
      cnt_information30)
     values
     (p_emp_county_tax_rule_id,
      p_effective_start_date,
      p_effective_end_date,
      p_assignment_id,
      p_state_code,
      p_county_code,
      p_business_group_id,
      p_additional_wa_rate,
      lpad(p_filing_status_code,2,'0'),
      p_jurisdiction_code,
      p_lit_additional_tax,
      p_lit_override_amount,
      p_lit_override_rate,
      p_withholding_allowances,
      p_lit_exempt,
      p_sd_exempt,
      p_ht_exempt,
      p_wage_exempt,
      p_school_district_code,
      0,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute16,
      p_attribute17,
      p_attribute18,
      p_attribute19,
      p_attribute20,
      p_attribute21,
      p_attribute22,
      p_attribute23,
      p_attribute24,
      p_attribute25,
      p_attribute26,
      p_attribute27,
      p_attribute28,
      p_attribute29,
      p_attribute30,
      p_cnt_information_category,
      p_cnt_information1,
      p_cnt_information2,
      p_cnt_information3,
      p_cnt_information4,
      p_cnt_information5,
      p_cnt_information6,
      p_cnt_information7,
      p_cnt_information8,
      p_cnt_information9,
      p_cnt_information10,
      p_cnt_information11,
      p_cnt_information12,
      p_cnt_information13,
      p_cnt_information14,
      p_cnt_information15,
      p_cnt_information16,
      p_cnt_information17,
      p_cnt_information18,
      p_cnt_information19,
      p_cnt_information20,
      p_cnt_information21,
      p_cnt_information22,
      p_cnt_information23,
      p_cnt_information24,
      p_cnt_information25,
      p_cnt_information26,
      p_cnt_information27,
      p_cnt_information28,
      p_cnt_information29,
      p_cnt_information30);

     if sql%notfound then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE',
                        'pay_us_emp_dt_tax_rules.insert_county_tax_row');
        fnd_message.set_token('STEP','4');
        fnd_message.raise_error;
     end if;

     open csr_get_row_id;

     fetch csr_get_row_id into p_row_id;

     if csr_get_row_id%NOTFOUND then
        close csr_get_row_id;
        raise no_data_found;
     end if;

     close csr_get_row_id;

    hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_county_tax_row'||
                             ' - creating %age record ', 5);

     /* Get the changes in location of an assignment.
       For each change in location, create vertex element entry with
       time in county as 0% */

     if hr_utility.chk_product_install(p_product     =>'Oracle Payroll',
                                       p_legislation => 'US') then

        create_tax_percentage (p_assignment_id  => p_assignment_id,
                               p_state_code     => p_state_code,
                               p_county_code    => p_county_code,
                               p_city_code      => null,
                               p_time_in_state  => 0,
                               p_time_in_county => nvl(p_time_in_county,0),
                               p_time_in_city   => 0);

        /* Insert row into the pay_us_asg_reporting table */

        pay_asg_geo_pkg.create_asg_geo_row(P_assignment_id => p_assignment_id,
                                           P_jurisdiction  =>  p_jurisdiction_code,
                                           P_tax_unit_id   =>  NULL );

        if p_school_district_code is not null then
           pay_asg_geo_pkg.create_asg_geo_row(P_assignment_id => p_assignment_id,
                    P_jurisdiction => p_state_code || '-'|| p_school_district_code,
                    P_tax_unit_id   =>  NULL );
        end if;

     end if;

  end insert_county_tax_row;


  /* Name        : insert_city_tax_row
     Purpose     : To create the city tax rule record. It also calls the
                   create_tax_percentage routine to create the %age records
                   for the city, for every change in location of the assignment
  */

  procedure insert_city_tax_row ( p_row_id in out nocopy varchar2,
                                  p_emp_city_tax_rule_id in out nocopy number,
                                  p_effective_start_date in date,
                                  p_effective_end_date in date,
                                  p_assignment_id in number,
                                  p_state_code in varchar2,
                                  p_county_code in varchar2,
                                  p_city_code in varchar2,
                                  p_business_group_id in number,
                                  p_additional_wa_rate in number,
                                  p_filing_status_code in varchar2,
                                  p_jurisdiction_code in varchar2,
                                  p_lit_additional_tax in number,
                                  p_lit_override_amount in number,
                                  p_lit_override_rate in number,
                                  p_withholding_allowances in number,
                                  p_lit_exempt in varchar2,
                                  p_sd_exempt in varchar2,
                                  p_ht_exempt in varchar2,
                                  p_wage_exempt in varchar2,
                                  p_school_district_code in varchar2,
                                  p_time_in_city in number,
                                  p_attribute_category        in varchar2,
                                  p_attribute1                in varchar2,
                                  p_attribute2                in varchar2,
                                  p_attribute3                in varchar2,
                                  p_attribute4                in varchar2,
                                  p_attribute5                in varchar2,
                                  p_attribute6                in varchar2,
                                  p_attribute7                in varchar2,
                                  p_attribute8                in varchar2,
                                  p_attribute9                in varchar2,
                                  p_attribute10               in varchar2,
                                  p_attribute11               in varchar2,
                                  p_attribute12               in varchar2,
                                  p_attribute13               in varchar2,
                                  p_attribute14               in varchar2,
                                  p_attribute15               in varchar2,
                                  p_attribute16               in varchar2,
                                  p_attribute17               in varchar2,
                                  p_attribute18               in varchar2,
                                  p_attribute19               in varchar2,
                                  p_attribute20               in varchar2,
                                  p_attribute21               in varchar2,
                                  p_attribute22               in varchar2,
                                  p_attribute23               in varchar2,
                                  p_attribute24               in varchar2,
                                  p_attribute25               in varchar2,
                                  p_attribute26               in varchar2,
                                  p_attribute27               in varchar2,
                                  p_attribute28               in varchar2,
                                  p_attribute29               in varchar2,
                                  p_attribute30               in varchar2,
                                  p_cty_information_category  in varchar2,
                                  p_cty_information1          in varchar2,
                                  p_cty_information2          in varchar2,
                                  p_cty_information3          in varchar2,
                                  p_cty_information4          in varchar2,
                                  p_cty_information5          in varchar2,
                                  p_cty_information6          in varchar2,
                                  p_cty_information7          in varchar2,
                                  p_cty_information8          in varchar2,
                                  p_cty_information9          in varchar2,
                                  p_cty_information10         in varchar2,
                                  p_cty_information11         in varchar2,
                                  p_cty_information12         in varchar2,
                                  p_cty_information13         in varchar2,
                                  p_cty_information14         in varchar2,
                                  p_cty_information15         in varchar2,
                                  p_cty_information16         in varchar2,
                                  p_cty_information17         in varchar2,
                                  p_cty_information18         in varchar2,
                                  p_cty_information19         in varchar2,
                                  p_cty_information20         in varchar2,
                                  p_cty_information21         in varchar2,
                                  p_cty_information22         in varchar2,
                                  p_cty_information23         in varchar2,
                                  p_cty_information24         in varchar2,
                                  p_cty_information25         in varchar2,
                                  p_cty_information26         in varchar2,
                                  p_cty_information27         in varchar2,
                                  p_cty_information28         in varchar2,
                                  p_cty_information29         in varchar2,
                                  p_cty_information30         in varchar2) is

  cursor csr_city_tax_rule_id is
    select PAY_US_EMP_CITY_TAX_RULES_S.nextval
    from sys.DUAL;

  cursor csr_get_row_id is
    select rowidtochar(rowid)
    from PAY_US_EMP_CITY_TAX_RULES_F ctr
    where ctr.emp_city_tax_rule_id = p_emp_city_tax_rule_id
    and   ctr.effective_start_date  = p_effective_start_date
    and   ctr.effective_end_date    = p_effective_end_date;

  begin

     if p_school_district_code is not null
     then

       /* Check that the school district is assigned to only one county/city
          at a given point in time */

        pay_us_emp_dt_tax_val.check_school_district(
                              p_assignment => p_assignment_id,
                              p_start_date => p_effective_start_date,
                              p_end_date   => p_effective_end_date,
                              p_mode       => 'I',
                              p_rowid      => null);
     end if;

     hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_city_tax_row'||
                             ' - Opening cursor', 1);

     open csr_city_tax_rule_id;

     hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_city_tax_row'||
                             ' - Fetching cursor', 2);

     fetch csr_city_tax_rule_id into p_emp_city_tax_rule_id;

     hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_city_tax_row'||
                             ' - Closing cursor', 3);

     close csr_city_tax_rule_id;


     hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_city_tax_row'||
                             ' - inserting row', 4);

     insert into PAY_US_EMP_CITY_TAX_RULES_F
     (emp_city_tax_rule_id,
      effective_start_date,
      effective_end_date,
      assignment_id,
      state_code,
      county_code,
      city_code,
      business_group_id,
      additional_wa_rate,
      filing_status_code,
      jurisdiction_code,
      lit_additional_tax,
      lit_override_amount,
      lit_override_rate,
      withholding_allowances,
      lit_exempt,
      sd_exempt,
      ht_exempt,
      wage_exempt,
      school_district_code,
      object_version_number,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      attribute21,
      attribute22,
      attribute23,
      attribute24,
      attribute25,
      attribute26,
      attribute27,
      attribute28,
      attribute29,
      attribute30,
      cty_information_category,
      cty_information1,
      cty_information2,
      cty_information3,
      cty_information4,
      cty_information5,
      cty_information6,
      cty_information7,
      cty_information8,
      cty_information9,
      cty_information10,
      cty_information11,
      cty_information12,
      cty_information13,
      cty_information14,
      cty_information15,
      cty_information16,
      cty_information17,
      cty_information18,
      cty_information19,
      cty_information20,
      cty_information21,
      cty_information22,
      cty_information23,
      cty_information24,
      cty_information25,
      cty_information26,
      cty_information27,
      cty_information28,
      cty_information29,
      cty_information30)
     values
     (p_emp_city_tax_rule_id,
      p_effective_start_date,
      p_effective_end_date,
      p_assignment_id,
      p_state_code,
      p_county_code,
      p_city_code,
      p_business_group_id,
      p_additional_wa_rate,
      lpad(p_filing_status_code,2,'0'),
      p_jurisdiction_code,
      p_lit_additional_tax,
      p_lit_override_amount,
      p_lit_override_rate,
      p_withholding_allowances,
      p_lit_exempt,
      p_sd_exempt,
      p_ht_exempt,
      p_wage_exempt,
      p_school_district_code,
      0,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_attribute16,
      p_attribute17,
      p_attribute18,
      p_attribute19,
      p_attribute20,
      p_attribute21,
      p_attribute22,
      p_attribute23,
      p_attribute24,
      p_attribute25,
      p_attribute26,
      p_attribute27,
      p_attribute28,
      p_attribute29,
      p_attribute30,
      p_cty_information_category,
      p_cty_information1,
      p_cty_information2,
      p_cty_information3,
      p_cty_information4,
      p_cty_information5,
      p_cty_information6,
      p_cty_information7,
      p_cty_information8,
      p_cty_information9,
      p_cty_information10,
      p_cty_information11,
      p_cty_information12,
      p_cty_information13,
      p_cty_information14,
      p_cty_information15,
      p_cty_information16,
      p_cty_information17,
      p_cty_information18,
      p_cty_information19,
      p_cty_information20,
      p_cty_information21,
      p_cty_information22,
      p_cty_information23,
      p_cty_information24,
      p_cty_information25,
      p_cty_information26,
      p_cty_information27,
      p_cty_information28,
      p_cty_information29,
      p_cty_information30);

     if sql%notfound then

        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE',
                        'pay_us_emp_dt_tax_rules.insert_city_tax_row');
        fnd_message.set_token('STEP','4');
        fnd_message.raise_error;

     end if;

     open csr_get_row_id;

     fetch csr_get_row_id into p_row_id;

     if csr_get_row_id%NOTFOUND then
        close csr_get_row_id;
        raise no_data_found;
     end if;

     close csr_get_row_id;


      hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_city_tax_row'||
                             ' - creating %age record ', 5);

     /* Get the changes in location of an assignment.
       For each change in location, create vertex element entry with
       time in city as 0%
       Note: When this procedure will be called by the default_tax routine
       there will be only one location for which the record will be created
       thus resulting in only one city tax record with 100% - makes sense??
       In most of the cases the defaulting routine will create tax records
       from begin of time till end of time */

     if hr_utility.chk_product_install(p_product     =>'Oracle Payroll',
                                       p_legislation => 'US') then

        create_tax_percentage (p_assignment_id  => p_assignment_id,
                               p_state_code     => p_state_code,
                               p_county_code    => p_county_code,
                               p_city_code      => p_city_code,
                               p_time_in_state  => 0,
                               p_time_in_county => 0,
                               p_time_in_city   => nvl(p_time_in_city,0));

        /* Insert row into the pay_us_asg_reporting table */

        pay_asg_geo_pkg.create_asg_geo_row(P_assignment_id => p_assignment_id,
                                           P_jurisdiction  =>  p_jurisdiction_code,
                                           P_tax_unit_id   =>  NULL );

        if p_school_district_code is not null then
           pay_asg_geo_pkg.create_asg_geo_row(P_assignment_id => p_assignment_id,
                    P_jurisdiction => p_state_code || '-'|| p_school_district_code,
                    P_tax_unit_id   =>  NULL );
        end if;

     end if;

  end insert_city_tax_row;


  /* Name        : update_fed_tax_row
     Purpose     : To update the federal tax rule record. It also calls the
                   maintain_wc_ele_entry routine to update the worker's compensation
                   for the SUI state
  */

  procedure update_fed_tax_row ( p_row_id                    in varchar2,
                                  p_emp_fed_tax_rule_id      in number,
				                  p_effective_start_date     in date,
                                  p_effective_end_date       in date,
                                  p_assignment_id            in number,
                                  p_sui_state_code           in varchar2,
                                  p_sui_jurisdiction_code    in varchar2,
                                  p_business_group_id        in number,
                                  p_additional_wa_amount     in number,
                                  p_filing_status_code       in varchar2,
                                  p_fit_override_amount      in number,
 				                  p_fit_override_rate        in number,
                                  p_withholding_allowances   in number,
                                  p_cumulative_taxation      in varchar2,
                                  p_eic_filing_status_code   in varchar2,
                                  p_fit_additional_tax       in number,
                                  p_fit_exempt               in varchar2,
                                  p_futa_tax_exempt          in varchar2,
                                  p_medicare_tax_exempt      in varchar2,
                                  p_ss_tax_exempt            in varchar2,
                                  p_wage_exempt              in varchar2,
                                  p_statutory_employee       in varchar2,
                                  p_w2_filed_year            in number,
                                  p_supp_tax_override_rate   in number,
                                  p_excessive_wa_reject_date in date,
                                  p_session_date             in date,
                                  p_attribute_category        in varchar2,
                                  p_attribute1                in varchar2,
                                  p_attribute2                in varchar2,
                                  p_attribute3                in varchar2,
                                  p_attribute4                in varchar2,
                                  p_attribute5                in varchar2,
                                  p_attribute6                in varchar2,
                                  p_attribute7                in varchar2,
                                  p_attribute8                in varchar2,
                                  p_attribute9                in varchar2,
                                  p_attribute10               in varchar2,
                                  p_attribute11               in varchar2,
                                  p_attribute12               in varchar2,
                                  p_attribute13               in varchar2,
                                  p_attribute14               in varchar2,
                                  p_attribute15               in varchar2,
                                  p_attribute16               in varchar2,
                                  p_attribute17               in varchar2,
                                  p_attribute18               in varchar2,
                                  p_attribute19               in varchar2,
                                  p_attribute20               in varchar2,
                                  p_attribute21               in varchar2,
                                  p_attribute22               in varchar2,
                                  p_attribute23               in varchar2,
                                  p_attribute24               in varchar2,
                                  p_attribute25               in varchar2,
                                  p_attribute26               in varchar2,
                                  p_attribute27               in varchar2,
                                  p_attribute28               in varchar2,
                                  p_attribute29               in varchar2,
                                  p_attribute30               in varchar2,
                                  p_fed_information_category  in varchar2,
                                  p_fed_information1          in varchar2,
                                  p_fed_information2          in varchar2,
                                  p_fed_information3          in varchar2,
                                  p_fed_information4          in varchar2,
                                  p_fed_information5          in varchar2,
                                  p_fed_information6          in varchar2,
                                  p_fed_information7          in varchar2,
                                  p_fed_information8          in varchar2,
                                  p_fed_information9          in varchar2,
                                  p_fed_information10         in varchar2,
                                  p_fed_information11         in varchar2,
                                  p_fed_information12         in varchar2,
                                  p_fed_information13         in varchar2,
                                  p_fed_information14         in varchar2,
                                  p_fed_information15         in varchar2,
                                  p_fed_information16         in varchar2,
                                  p_fed_information17         in varchar2,
                                  p_fed_information18         in varchar2,
                                  p_fed_information19         in varchar2,
                                  p_fed_information20         in varchar2,
                                  p_fed_information21         in varchar2,
                                  p_fed_information22         in varchar2,
                                  p_fed_information23         in varchar2,
                                  p_fed_information24         in varchar2,
                                  p_fed_information25         in varchar2,
                                  p_fed_information26         in varchar2,
                                  p_fed_information27         in varchar2,
                                  p_fed_information28         in varchar2,
                                  p_fed_information29         in varchar2,
                                  p_fed_information30         in varchar2,
                                  p_mode                     in varchar2) is

  lv_warning          VARCHAR2(300);

  begin


     hr_utility.set_location('pay_us_emp_dt_tax_rules.update_fed_tax_row'||
                             ' - updating row', 1);
    ----added by  vaprakas Bug 5607135
    check_nra_status(p_assignment_id
                   , p_withholding_allowances
		   , p_filing_status_code
		   , p_fit_exempt
		   , p_effective_start_date
		   , p_effective_end_date
		   , lv_warning);

     update PAY_US_EMP_FED_TAX_RULES_F
     set emp_fed_tax_rule_id   = p_emp_fed_tax_rule_id,
      effective_start_date     = p_effective_start_date,
      effective_end_date       = p_effective_end_date,
      assignment_id            = p_assignment_id ,
      sui_state_code           = p_sui_state_code,
      sui_jurisdiction_code    = p_sui_jurisdiction_code,
      business_group_id        = p_business_group_id ,
      additional_wa_amount     = p_additional_wa_amount,
      filing_status_code       = lpad(p_filing_status_code,2,'0'),
      fit_override_amount      = p_fit_override_amount,
      fit_override_rate        = p_fit_override_rate,
      withholding_allowances   = p_withholding_allowances,
      cumulative_taxation      = p_cumulative_taxation,
      eic_filing_status_code   = p_eic_filing_status_code,
      fit_additional_tax       = p_fit_additional_tax,
      fit_exempt               = p_fit_exempt,
      futa_tax_exempt          = p_futa_tax_exempt,
      medicare_tax_exempt      = p_medicare_tax_exempt,
      ss_tax_exempt            = p_ss_tax_exempt,
      wage_exempt              = p_wage_exempt,
      statutory_employee       = p_statutory_employee,
      w2_filed_year            = p_w2_filed_year,
      supp_tax_override_rate   = p_supp_tax_override_rate,
      excessive_wa_reject_date = p_excessive_wa_reject_date,
      attribute_category       = p_attribute_category,
      attribute1               = p_attribute1,
      attribute2               = p_attribute2,
      attribute3               = p_attribute3,
      attribute4               = p_attribute4,
      attribute5               = p_attribute5,
      attribute6               = p_attribute6,
      attribute7               = p_attribute7,
      attribute8               = p_attribute8,
      attribute9               = p_attribute9,
      attribute10              = p_attribute10,
      attribute11              = p_attribute11,
      attribute12              = p_attribute12,
      attribute13              = p_attribute13,
      attribute14              = p_attribute14,
      attribute15              = p_attribute15,
      attribute16              = p_attribute16,
      attribute17              = p_attribute17,
      attribute18              = p_attribute18,
      attribute19              = p_attribute19,
      attribute20              = p_attribute20,
      attribute21              = p_attribute21,
      attribute22              = p_attribute22,
      attribute23              = p_attribute23,
      attribute24              = p_attribute24,
      attribute25              = p_attribute25,
      attribute26              = p_attribute26,
      attribute27              = p_attribute27,
      attribute28              = p_attribute28,
      attribute29              = p_attribute29,
      attribute30              = p_attribute30,
      fed_information_category = p_fed_information_category,
      fed_information1         = p_fed_information1,
      fed_information2         = p_fed_information2,
      fed_information3         = p_fed_information3,
      fed_information4         = p_fed_information4,
      fed_information5         = p_fed_information5,
      fed_information6         = p_fed_information6,
      fed_information7         = p_fed_information7,
      fed_information8         = p_fed_information8,
      fed_information9         = p_fed_information9,
      fed_information10        = p_fed_information10,
      fed_information11        = p_fed_information11,
      fed_information12        = p_fed_information12,
      fed_information13        = p_fed_information13,
      fed_information14        = p_fed_information14,
      fed_information15        = p_fed_information15,
      fed_information16        = p_fed_information16,
      fed_information17        = p_fed_information17,
      fed_information18        = p_fed_information18,
      fed_information19        = p_fed_information19,
      fed_information20        = p_fed_information20,
      fed_information21        = p_fed_information21,
      fed_information22        = p_fed_information22,
      fed_information23        = p_fed_information23,
      fed_information24        = p_fed_information24,
      fed_information25        = p_fed_information25,
      fed_information26        = p_fed_information26,
      fed_information27        = p_fed_information27,
      fed_information28        = p_fed_information28,
      fed_information29        = p_fed_information29,
      fed_information30        = p_fed_information30
      where rowid              = chartorowid(p_row_id);

      if sql%notfound then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE',
                       'pay_us_emp_dt_tax_rules.update_fed_tax');
        fnd_message.set_token('STEP','1');
        fnd_message.raise_error;
      end if;

      /* Update workers compensation element entry for the sui state in
         the federal record */

      maintain_wc_ele_entry (p_assignment_id        => p_assignment_id,
                             p_effective_start_date => p_effective_start_date,
                             p_effective_end_date   => p_effective_end_date,
                             p_session_date         => p_session_date,
                             p_jurisdiction_code    => p_sui_jurisdiction_code,
                             p_mode                 => p_mode);


  end update_fed_tax_row;

  /* Name        : update_state_tax_row
     Purpose     : To update the state tax rule record.
  */

  procedure update_state_tax_row ( p_row_id in varchar2,
                                   p_emp_state_tax_rule_id in number,
                                   p_effective_start_date in date,
                                   p_effective_end_date in date,
                                   p_assignment_id in number,
                                   p_state_code in varchar2,
                                   p_jurisdiction_code in varchar2,
                                   p_business_group_id in number,
                                   p_additional_wa_amount in number,
                                   p_filing_status_code in varchar2,
                                   p_remainder_percent in number,
                                   p_secondary_wa in number,
                                   p_sit_additional_tax in number,
                                   p_sit_override_amount in number,
                                   p_sit_override_rate in number,
                                   p_withholding_allowances in number,
                                   p_excessive_wa_reject_date in date,
                                   p_sdi_exempt in varchar2,
                                   p_sit_exempt in varchar2,
                                   p_sit_optional_calc_ind in varchar2,
                                   p_state_non_resident_cert in varchar2,
                                   p_sui_exempt in varchar2,
                                   p_wc_exempt in varchar2,
                                   p_wage_exempt in varchar2,
                                   p_sui_wage_base_override_amt in number,
                                   p_supp_tax_override_rate in number,
                                   p_attribute_category        in varchar2,
                                   p_attribute1                in varchar2,
                                   p_attribute2                in varchar2,
                                   p_attribute3                in varchar2,
                                   p_attribute4                in varchar2,
                                   p_attribute5                in varchar2,
                                   p_attribute6                in varchar2,
                                   p_attribute7                in varchar2,
                                   p_attribute8                in varchar2,
                                   p_attribute9                in varchar2,
                                   p_attribute10               in varchar2,
                                   p_attribute11               in varchar2,
                                   p_attribute12               in varchar2,
                                   p_attribute13               in varchar2,
                                   p_attribute14               in varchar2,
                                   p_attribute15               in varchar2,
                                   p_attribute16               in varchar2,
                                   p_attribute17               in varchar2,
                                   p_attribute18               in varchar2,
                                   p_attribute19               in varchar2,
                                   p_attribute20               in varchar2,
                                   p_attribute21               in varchar2,
                                   p_attribute22               in varchar2,
                                   p_attribute23               in varchar2,
                                   p_attribute24               in varchar2,
                                   p_attribute25               in varchar2,
                                   p_attribute26               in varchar2,
                                   p_attribute27               in varchar2,
                                   p_attribute28               in varchar2,
                                   p_attribute29               in varchar2,
                                   p_attribute30               in varchar2,
                                   p_sta_information_category  in varchar2,
                                   p_sta_information1          in varchar2,
                                   p_sta_information2          in varchar2,
                                   p_sta_information3          in varchar2,
                                   p_sta_information4          in varchar2,
                                   p_sta_information5          in varchar2,
                                   p_sta_information6          in varchar2,
                                   p_sta_information7          in varchar2,
                                   p_sta_information8          in varchar2,
                                   p_sta_information9          in varchar2,
                                   p_sta_information10         in varchar2,
                                   p_sta_information11         in varchar2,
                                   p_sta_information12         in varchar2,
                                   p_sta_information13         in varchar2,
                                   p_sta_information14         in varchar2,
                                   p_sta_information15         in varchar2,
                                   p_sta_information16         in varchar2,
                                   p_sta_information17         in varchar2,
                                   p_sta_information18         in varchar2,
                                   p_sta_information19         in varchar2,
                                   p_sta_information20         in varchar2,
                                   p_sta_information21         in varchar2,
                                   p_sta_information22         in varchar2,
                                   p_sta_information23         in varchar2,
                                   p_sta_information24         in varchar2,
                                   p_sta_information25         in varchar2,
                                   p_sta_information26         in varchar2,
                                   p_sta_information27         in varchar2,
                                   p_sta_information28         in varchar2,
                                   p_sta_information29         in varchar2,
                                   p_sta_information30         in varchar2) is
  begin

     hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_st_tax_row'||
                             ' - updating row', 1);

     update PAY_US_EMP_STATE_TAX_RULES_F
     set emp_state_tax_rule_id      = p_emp_state_tax_rule_id,
      effective_start_date          = p_effective_start_date,
      effective_end_date            = p_effective_end_date,
      assignment_id                 = p_assignment_id,
      state_code                    = p_state_code,
      jurisdiction_code             = p_jurisdiction_code,
      business_group_id             = p_business_group_id,
      additional_wa_amount          = p_additional_wa_amount,
      filing_status_code            = lpad(p_filing_status_code,2,'0'),
      remainder_percent             = p_remainder_percent,
      secondary_wa                  = p_secondary_wa,
      sit_additional_tax            = p_sit_additional_tax,
      sit_override_amount           = p_sit_override_amount,
      sit_override_rate             = p_sit_override_rate,
      withholding_allowances        = p_withholding_allowances,
      excessive_wa_reject_date      = p_excessive_wa_reject_date,
      sdi_exempt                    = p_sdi_exempt,
      sit_exempt                    = p_sit_exempt,
      sit_optional_calc_ind         = p_sit_optional_calc_ind,
      state_non_resident_cert       = p_state_non_resident_cert,
      sui_exempt                    = p_sui_exempt,
      wc_exempt                     = p_wc_exempt,
      wage_exempt                   = p_wage_exempt,
      sui_wage_base_override_amount = p_sui_wage_base_override_amt,
      supp_tax_override_rate        = p_supp_tax_override_rate,
      attribute_category       = p_attribute_category,
      attribute1               = p_attribute1,
      attribute2               = p_attribute2,
      attribute3               = p_attribute3,
      attribute4               = p_attribute4,
      attribute5               = p_attribute5,
      attribute6               = p_attribute6,
      attribute7               = p_attribute7,
      attribute8               = p_attribute8,
      attribute9               = p_attribute9,
      attribute10              = p_attribute10,
      attribute11              = p_attribute11,
      attribute12              = p_attribute12,
      attribute13              = p_attribute13,
      attribute14              = p_attribute14,
      attribute15              = p_attribute15,
      attribute16              = p_attribute16,
      attribute17              = p_attribute17,
      attribute18              = p_attribute18,
      attribute19              = p_attribute19,
      attribute20              = p_attribute20,
      attribute21              = p_attribute21,
      attribute22              = p_attribute22,
      attribute23              = p_attribute23,
      attribute24              = p_attribute24,
      attribute25              = p_attribute25,
      attribute26              = p_attribute26,
      attribute27              = p_attribute27,
      attribute28              = p_attribute28,
      attribute29              = p_attribute29,
      attribute30              = p_attribute30,
      sta_information_category = p_sta_information_category,
      sta_information1         = p_sta_information1,
      sta_information2         = p_sta_information2,
      sta_information3         = p_sta_information3,
      sta_information4         = p_sta_information4,
      sta_information5         = p_sta_information5,
      sta_information6         = p_sta_information6,
      sta_information7         = p_sta_information7,
      sta_information8         = p_sta_information8,
      sta_information9         = p_sta_information9,
      sta_information10        = p_sta_information10,
      sta_information11        = p_sta_information11,
      sta_information12        = p_sta_information12,
      sta_information13        = p_sta_information13,
      sta_information14        = p_sta_information14,
      sta_information15        = p_sta_information15,
      sta_information16        = p_sta_information16,
      sta_information17        = p_sta_information17,
      sta_information18        = p_sta_information18,
      sta_information19        = p_sta_information19,
      sta_information20        = p_sta_information20,
      sta_information21        = p_sta_information21,
      sta_information22        = p_sta_information22,
      sta_information23        = p_sta_information23,
      sta_information24        = p_sta_information24,
      sta_information25        = p_sta_information25,
      sta_information26        = p_sta_information26,
      sta_information27        = p_sta_information27,
      sta_information28        = p_sta_information28,
      sta_information29        = p_sta_information29,
      sta_information30        = p_sta_information30
      where rowid  = chartorowid(p_row_id);

     if sql%notfound then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE',
                        'pay_us_emp_dt_tax_rules.update_state_tax_row');
        fnd_message.set_token('STEP','1');
        fnd_message.raise_error;
     end if;

     hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_st_tax_row'||
                             ' - updated row', 2);

  end update_state_tax_row;


  /* Name        : update_county_tax_row
     Purpose     : To update the county tax rule record.
  */
  procedure update_county_tax_row ( p_row_id in varchar2,
                                    p_emp_county_tax_rule_id in number,
                                    p_effective_start_date in date,
                                    p_effective_end_date in date,
                                    p_assignment_id in number,
                                    p_state_code in varchar2,
                                    p_county_code in varchar2,
                                    p_business_group_id in number,
                                    p_additional_wa_rate in number,
                                    p_filing_status_code in varchar2,
                                    p_jurisdiction_code in varchar2,
                                    p_lit_additional_tax in number,
                                    p_lit_override_amount in number,
                                    p_lit_override_rate in number,
                                    p_withholding_allowances in number,
                                    p_lit_exempt in varchar2,
                                    p_sd_exempt in varchar2,
                                    p_ht_exempt in varchar2,
                                    p_wage_exempt in varchar2,
                                    p_school_district_code in varchar2,
                                    p_attribute_category        in varchar2,
                                    p_attribute1                in varchar2,
                                    p_attribute2                in varchar2,
                                    p_attribute3                in varchar2,
                                    p_attribute4                in varchar2,
                                    p_attribute5                in varchar2,
                                    p_attribute6                in varchar2,
                                    p_attribute7                in varchar2,
                                    p_attribute8                in varchar2,
                                    p_attribute9                in varchar2,
                                    p_attribute10               in varchar2,
                                    p_attribute11               in varchar2,
                                    p_attribute12               in varchar2,
                                    p_attribute13               in varchar2,
                                    p_attribute14               in varchar2,
                                    p_attribute15               in varchar2,
                                    p_attribute16               in varchar2,
                                    p_attribute17               in varchar2,
                                    p_attribute18               in varchar2,
                                    p_attribute19               in varchar2,
                                    p_attribute20               in varchar2,
                                    p_attribute21               in varchar2,
                                    p_attribute22               in varchar2,
                                    p_attribute23               in varchar2,
                                    p_attribute24               in varchar2,
                                    p_attribute25               in varchar2,
                                    p_attribute26               in varchar2,
                                    p_attribute27               in varchar2,
                                    p_attribute28               in varchar2,
                                    p_attribute29               in varchar2,
                                    p_attribute30               in varchar2,
                                    p_cnt_information_category  in varchar2,
                                    p_cnt_information1          in varchar2,
                                    p_cnt_information2          in varchar2,
                                    p_cnt_information3          in varchar2,
                                    p_cnt_information4          in varchar2,
                                    p_cnt_information5          in varchar2,
                                    p_cnt_information6          in varchar2,
                                    p_cnt_information7          in varchar2,
                                    p_cnt_information8          in varchar2,
                                    p_cnt_information9          in varchar2,
                                    p_cnt_information10         in varchar2,
                                    p_cnt_information11         in varchar2,
                                    p_cnt_information12         in varchar2,
                                    p_cnt_information13         in varchar2,
                                    p_cnt_information14         in varchar2,
                                    p_cnt_information15         in varchar2,
                                    p_cnt_information16         in varchar2,
                                    p_cnt_information17         in varchar2,
                                    p_cnt_information18         in varchar2,
                                    p_cnt_information19         in varchar2,
                                    p_cnt_information20         in varchar2,
                                    p_cnt_information21         in varchar2,
                                    p_cnt_information22         in varchar2,
                                    p_cnt_information23         in varchar2,
                                    p_cnt_information24         in varchar2,
                                    p_cnt_information25         in varchar2,
                                    p_cnt_information26         in varchar2,
                                    p_cnt_information27         in varchar2,
                                    p_cnt_information28         in varchar2,
                                    p_cnt_information29         in varchar2,
                                    p_cnt_information30         in varchar2) is

  begin

    if p_school_district_code is not null
    then

       hr_utility.set_location('pay_us_emp_dt_tax_rules.update_county_tax_row'||
                             ' - checking sd', 1);
       /* Check that the school district is assigned to only one county/city
          at a given point in time */

        pay_us_emp_dt_tax_val.check_school_district(
                              p_assignment => p_assignment_id,
                              p_start_date => p_effective_start_date,
                              p_end_date   => p_effective_end_date,
                              p_mode       => 'U',
                              p_rowid      => p_row_id);
    end if;

    hr_utility.set_location('pay_us_emp_dt_tax_rules.update_county_tax_row'||
                             ' - updating row', 2);

     update PAY_US_EMP_COUNTY_TAX_RULES_F
     set emp_county_tax_rule_id = p_emp_county_tax_rule_id,
      effective_start_date   = p_effective_start_date,
      effective_end_date     = p_effective_end_date,
      assignment_id          = p_assignment_id,
      state_code             = p_state_code,
      county_code            = p_county_code,
      business_group_id      = p_business_group_id,
      additional_wa_rate     = p_additional_wa_rate,
      filing_status_code     = lpad(p_filing_status_code,2,'0'),
      jurisdiction_code      = p_jurisdiction_code,
      lit_additional_tax     = p_lit_additional_tax,
      lit_override_amount    = p_lit_override_amount,
      lit_override_rate      = p_lit_override_rate,
      withholding_allowances = p_withholding_allowances,
      lit_exempt             = p_lit_exempt,
      sd_exempt              = p_sd_exempt,
      ht_exempt              = p_ht_exempt,
      wage_exempt            = p_wage_exempt,
      school_district_code   = p_school_district_code,
      attribute_category       = p_attribute_category,
      attribute1               = p_attribute1,
      attribute2               = p_attribute2,
      attribute3               = p_attribute3,
      attribute4               = p_attribute4,
      attribute5               = p_attribute5,
      attribute6               = p_attribute6,
      attribute7               = p_attribute7,
      attribute8               = p_attribute8,
      attribute9               = p_attribute9,
      attribute10              = p_attribute10,
      attribute11              = p_attribute11,
      attribute12              = p_attribute12,
      attribute13              = p_attribute13,
      attribute14              = p_attribute14,
      attribute15              = p_attribute15,
      attribute16              = p_attribute16,
      attribute17              = p_attribute17,
      attribute18              = p_attribute18,
      attribute19              = p_attribute19,
      attribute20              = p_attribute20,
      attribute21              = p_attribute21,
      attribute22              = p_attribute22,
      attribute23              = p_attribute23,
      attribute24              = p_attribute24,
      attribute25              = p_attribute25,
      attribute26              = p_attribute26,
      attribute27              = p_attribute27,
      attribute28              = p_attribute28,
      attribute29              = p_attribute29,
      attribute30              = p_attribute30,
      cnt_information_category = p_cnt_information_category,
      cnt_information1         = p_cnt_information1,
      cnt_information2         = p_cnt_information2,
      cnt_information3         = p_cnt_information3,
      cnt_information4         = p_cnt_information4,
      cnt_information5         = p_cnt_information5,
      cnt_information6         = p_cnt_information6,
      cnt_information7         = p_cnt_information7,
      cnt_information8         = p_cnt_information8,
      cnt_information9         = p_cnt_information9,
      cnt_information10        = p_cnt_information10,
      cnt_information11        = p_cnt_information11,
      cnt_information12        = p_cnt_information12,
      cnt_information13        = p_cnt_information13,
      cnt_information14        = p_cnt_information14,
      cnt_information15        = p_cnt_information15,
      cnt_information16        = p_cnt_information16,
      cnt_information17        = p_cnt_information17,
      cnt_information18        = p_cnt_information18,
      cnt_information19        = p_cnt_information19,
      cnt_information20        = p_cnt_information20,
      cnt_information21        = p_cnt_information21,
      cnt_information22        = p_cnt_information22,
      cnt_information23        = p_cnt_information23,
      cnt_information24        = p_cnt_information24,
      cnt_information25        = p_cnt_information25,
      cnt_information26        = p_cnt_information26,
      cnt_information27        = p_cnt_information27,
      cnt_information28        = p_cnt_information28,
      cnt_information29        = p_cnt_information29,
      cnt_information30        = p_cnt_information30
      where rowid  = chartorowid(p_row_id);

     if sql%notfound then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE',
                        'pay_us_emp_dt_tax_rules.update_county_tax_row');
        fnd_message.set_token('STEP','2');
        fnd_message.raise_error;
     end if;

     if p_school_district_code is not null then

        /* Insert row into the pay_us_asg_reporting table */

        hr_utility.set_location('pay_us_emp_dt_tax_rules.update_county_tax_row'||
                                  ' - asg_geo row', 3);

        pay_asg_geo_pkg.create_asg_geo_row(P_assignment_id => p_assignment_id,
                                           P_jurisdiction  => p_state_code || '-'||
                                                             p_school_district_code,
                                           P_tax_unit_id   =>  NULL );
     end if;

  end update_county_tax_row;


  /* Name        : update_city_tax_row
     Purpose     : To update the city tax rule record.
  */

  procedure update_city_tax_row ( p_row_id in varchar2,
                                  p_emp_city_tax_rule_id in number,
                                  p_effective_start_date in date,
                                  p_effective_end_date in date,
                                  p_assignment_id in number,
                                  p_state_code in varchar2,
                                  p_county_code in varchar2,
                                  p_city_code in varchar2,
                                  p_business_group_id in number,
                                  p_additional_wa_rate in number,
                                  p_filing_status_code in varchar2,
                                  p_jurisdiction_code in varchar2,
                                  p_lit_additional_tax in number,
                                  p_lit_override_amount in number,
                                  p_lit_override_rate in number,
                                  p_withholding_allowances in number,
                                  p_lit_exempt in varchar2,
                                  p_sd_exempt in varchar2,
                                  p_ht_exempt in varchar2,
                                  p_wage_exempt in varchar2,
                                  p_school_district_code in varchar2,
                                  p_attribute_category        in varchar2,
                                  p_attribute1                in varchar2,
                                  p_attribute2                in varchar2,
                                  p_attribute3                in varchar2,
                                  p_attribute4                in varchar2,
                                  p_attribute5                in varchar2,
                                  p_attribute6                in varchar2,
                                  p_attribute7                in varchar2,
                                  p_attribute8                in varchar2,
                                  p_attribute9                in varchar2,
                                  p_attribute10               in varchar2,
                                  p_attribute11               in varchar2,
                                  p_attribute12               in varchar2,
                                  p_attribute13               in varchar2,
                                  p_attribute14               in varchar2,
                                  p_attribute15               in varchar2,
                                  p_attribute16               in varchar2,
                                  p_attribute17               in varchar2,
                                  p_attribute18               in varchar2,
                                  p_attribute19               in varchar2,
                                  p_attribute20               in varchar2,
                                  p_attribute21               in varchar2,
                                  p_attribute22               in varchar2,
                                  p_attribute23               in varchar2,
                                  p_attribute24               in varchar2,
                                  p_attribute25               in varchar2,
                                  p_attribute26               in varchar2,
                                  p_attribute27               in varchar2,
                                  p_attribute28               in varchar2,
                                  p_attribute29               in varchar2,
                                  p_attribute30               in varchar2,
                                  p_cty_information_category  in varchar2,
                                  p_cty_information1          in varchar2,
                                  p_cty_information2          in varchar2,
                                  p_cty_information3          in varchar2,
                                  p_cty_information4          in varchar2,
                                  p_cty_information5          in varchar2,
                                  p_cty_information6          in varchar2,
                                  p_cty_information7          in varchar2,
                                  p_cty_information8          in varchar2,
                                  p_cty_information9          in varchar2,
                                  p_cty_information10         in varchar2,
                                  p_cty_information11         in varchar2,
                                  p_cty_information12         in varchar2,
                                  p_cty_information13         in varchar2,
                                  p_cty_information14         in varchar2,
                                  p_cty_information15         in varchar2,
                                  p_cty_information16         in varchar2,
                                  p_cty_information17         in varchar2,
                                  p_cty_information18         in varchar2,
                                  p_cty_information19         in varchar2,
                                  p_cty_information20         in varchar2,
                                  p_cty_information21         in varchar2,
                                  p_cty_information22         in varchar2,
                                  p_cty_information23         in varchar2,
                                  p_cty_information24         in varchar2,
                                  p_cty_information25         in varchar2,
                                  p_cty_information26         in varchar2,
                                  p_cty_information27         in varchar2,
                                  p_cty_information28         in varchar2,
                                  p_cty_information29         in varchar2,
                                  p_cty_information30         in varchar2) is
  begin

     if p_school_district_code is not null
     then

        hr_utility.set_location('pay_us_emp_dt_tax_rules.update_city_tax_row'||
                             ' - checking sd', 1);

       /* Check that the school district is assigned to only one county/city
          at a given point in time */

        pay_us_emp_dt_tax_val.check_school_district(
                              p_assignment => p_assignment_id,
                              p_start_date => p_effective_start_date,
                              p_end_date   => p_effective_end_date,
                              p_mode       => 'U',
                              p_rowid      => p_row_id);
     end if;

     hr_utility.set_location('pay_us_emp_dt_tax_rules.update_city_tax_row'||
                             ' - updating row', 2);

     update PAY_US_EMP_CITY_TAX_RULES_F
     set emp_city_tax_rule_id = p_emp_city_tax_rule_id,
      effective_start_date    = p_effective_start_date,
      effective_end_date      = p_effective_end_date,
      assignment_id           = p_assignment_id,
      state_code              = p_state_code,
      county_code             = p_county_code,
      city_code               = p_city_code,
      business_group_id       = p_business_group_id,
      additional_wa_rate      = p_additional_wa_rate,
      filing_status_code      = lpad(p_filing_status_code,2,'0'),
      jurisdiction_code       = p_jurisdiction_code,
      lit_additional_tax      = p_lit_additional_tax,
      lit_override_amount     = p_lit_override_amount,
      lit_override_rate       = p_lit_override_rate,
      withholding_allowances  = p_withholding_allowances,
      lit_exempt              = p_lit_exempt,
      sd_exempt               = p_sd_exempt,
      ht_exempt               = p_ht_exempt,
      wage_exempt             = p_wage_exempt,
      school_district_code    = p_school_district_code,
      attribute_category       = p_attribute_category,
      attribute1               = p_attribute1,
      attribute2               = p_attribute2,
      attribute3               = p_attribute3,
      attribute4               = p_attribute4,
      attribute5               = p_attribute5,
      attribute6               = p_attribute6,
      attribute7               = p_attribute7,
      attribute8               = p_attribute8,
      attribute9               = p_attribute9,
      attribute10              = p_attribute10,
      attribute11              = p_attribute11,
      attribute12              = p_attribute12,
      attribute13              = p_attribute13,
      attribute14              = p_attribute14,
      attribute15              = p_attribute15,
      attribute16              = p_attribute16,
      attribute17              = p_attribute17,
      attribute18              = p_attribute18,
      attribute19              = p_attribute19,
      attribute20              = p_attribute20,
      attribute21              = p_attribute21,
      attribute22              = p_attribute22,
      attribute23              = p_attribute23,
      attribute24              = p_attribute24,
      attribute25              = p_attribute25,
      attribute26              = p_attribute26,
      attribute27              = p_attribute27,
      attribute28              = p_attribute28,
      attribute29              = p_attribute29,
      attribute30              = p_attribute30,
      cty_information_category = p_cty_information_category,
      cty_information1         = p_cty_information1,
      cty_information2         = p_cty_information2,
      cty_information3         = p_cty_information3,
      cty_information4         = p_cty_information4,
      cty_information5         = p_cty_information5,
      cty_information6         = p_cty_information6,
      cty_information7         = p_cty_information7,
      cty_information8         = p_cty_information8,
      cty_information9         = p_cty_information9,
      cty_information10        = p_cty_information10,
      cty_information11        = p_cty_information11,
      cty_information12        = p_cty_information12,
      cty_information13        = p_cty_information13,
      cty_information14        = p_cty_information14,
      cty_information15        = p_cty_information15,
      cty_information16        = p_cty_information16,
      cty_information17        = p_cty_information17,
      cty_information18        = p_cty_information18,
      cty_information19        = p_cty_information19,
      cty_information20        = p_cty_information20,
      cty_information21        = p_cty_information21,
      cty_information22        = p_cty_information22,
      cty_information23        = p_cty_information23,
      cty_information24        = p_cty_information24,
      cty_information25        = p_cty_information25,
      cty_information26        = p_cty_information26,
      cty_information27        = p_cty_information27,
      cty_information28        = p_cty_information28,
      cty_information29        = p_cty_information29,
      cty_information30        = p_cty_information30
      where rowid  = chartorowid(p_row_id);

     if sql%notfound then

        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE',
                        'pay_us_emp_dt_tax_rules.update_city_tax_row');
        fnd_message.set_token('STEP','2');
        fnd_message.raise_error;

     end if;

     if p_school_district_code is not null then

        /* Insert row into the pay_us_asg_reporting table */

        hr_utility.set_location('pay_us_emp_dt_tax_rules.update_city_tax_row'||
                                  ' - asg_geo row', 3);

        pay_asg_geo_pkg.create_asg_geo_row(P_assignment_id => p_assignment_id,
                                           P_jurisdiction  => p_state_code || '-' ||
                                                             p_school_district_code,
                                           P_tax_unit_id   =>  NULL );
     end if;

  end update_city_tax_row;


  /* Name     : delete_tax_row
     Purpose  : This routine will be called by the W4 form to purge a tax rule record.
                Only purging(i.e. ZAP) of the tax record will be allowed. No other kind
                of delete will be allowed for the tax record. If a state record is purged,
                then all of the county and city records for that state, will also be purged.
                Similarly, is a county record is purged then all of the city records under
                that county, will also be purged.
                Along with the tax rule record, the tax %age records associated with that
                tax rules record, will also be purged i.e. delete cascade
    Parameters :
                p_assignment_id     -> The assignment whose tax record will be purged.
                p_state_code        -> State whose tax record will be purged
                p_county_code       -> County whose tax record will be purged
                p_city_code         -> City whose tax record will be purged
  */

  procedure delete_tax_row ( p_assignment_id in number,
                             p_state_code    in varchar2,
                             p_county_code   in varchar2,
                             p_city_code     in varchar2) is

  l_ret_code             number;
  l_ret_text             varchar2(240);
  l_jurisdiction_code    varchar2(11);
  l_effective_start_date date;
  l_payroll_installed    boolean := FALSE;

  /* Cursor to get the counties for the state */
  cursor csr_state_counties is
   select puc.jurisdiction_code
   from   PAY_US_EMP_COUNTY_TAX_RULES_F puc
   where  puc.assignment_id = p_assignment_id
   and    puc.state_code  = p_state_code;

  /* Cursor to get the cities for the state */
  cursor csr_state_cities is
   select puc.jurisdiction_code
   from   PAY_US_EMP_CITY_TAX_RULES_F puc
   where  puc.assignment_id = p_assignment_id
   and    puc.state_code  = p_state_code;

  /* Cursor to get the cities for the county */
  cursor csr_county_cities is
   select puc.jurisdiction_code
   from   PAY_US_EMP_CITY_TAX_RULES_F puc
   where  puc.assignment_id = p_assignment_id
   and    puc.state_code  = p_state_code
   and    puc.county_code = p_county_code;

   /* cursor to get the start date of the tax %age record.
      The min federal effective date is the date on which the
      default tax rules criteria was satisfied. */

   cursor csr_get_eff_date is
       select min(effective_start_date)
       from   PAY_US_EMP_FED_TAX_RULES_F
       where  assignment_id = p_assignment_id;

   begin

         /* Check if payroll has been installed or not */

         l_payroll_installed := hr_utility.chk_product_install(p_product =>'Oracle Payroll',
                                                               p_legislation => 'US');

       /* Now all validations done. Go ahead and delete the element entries.
          Once the element entries are deleted, delete the tax rules records */

       /* Get the start date of the tax percentage records */

       open csr_get_eff_date;

       fetch csr_get_eff_date into l_effective_start_date;

       if l_effective_start_date is null then
           fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
           fnd_message.set_token('PROCEDURE',
                      'pay_us_emp_dt_tax_rules.delete_tax_row');
           fnd_message.set_token('STEP','1');
           fnd_message.raise_error;
       end if;

       close csr_get_eff_date;

       /* Processing for deleteing the state tax rule record */

       if p_state_code is not null and p_county_code is null
          and p_city_code is null then

         /* Delete the element entries only if Payroll is installed */

          if l_payroll_installed then

            /* Get the cities for the state and call the maintain_element_entry routine
              to delete the city %age records for the cities in the state */

             open csr_state_cities;

             loop

               fetch csr_state_cities into l_jurisdiction_code;

               exit when csr_state_cities%NOTFOUND;

               /* Delete the %age tax record for the jurisdiction */

               maintain_element_entry(p_assignment_id        => p_assignment_id,
                                      p_effective_start_date => l_effective_start_date,
                                    p_effective_end_date   => to_date('31-12-4712','dd-mm-yyyy'),
                                      p_session_date         => l_effective_start_date,
                                      p_jurisdiction_code    => l_jurisdiction_code,
                                      p_percentage_time      => 0,
                                      p_mode                 => 'ZAP');


             end loop;

             close csr_state_cities;

             /* Get the counties for the state and call the maintain_element_entry routine
                to delete the county %age records for the cities in the state */

             open csr_state_counties;

             loop

                fetch csr_state_counties into l_jurisdiction_code;

                exit when csr_state_counties%NOTFOUND;

                /* Delete the %age tax record for the jurisdiction */

                maintain_element_entry(p_assignment_id       => p_assignment_id,
                                      p_effective_start_date => l_effective_start_date,
                                      p_effective_end_date   => to_date('31-12-4712','dd-mm-yyyy'),
                                      p_session_date         => l_effective_start_date,
                                      p_jurisdiction_code    => l_jurisdiction_code,
                                      p_percentage_time      => 0,
                                      p_mode                 => 'ZAP');

             end loop;

             close csr_state_counties;

             /* Delete the state %age records for the state */

                maintain_element_entry(p_assignment_id       => p_assignment_id,
                                      p_effective_start_date => l_effective_start_date,
                                      p_effective_end_date   => to_date('31-12-4712','dd-mm-yyyy'),
                                      p_session_date         => l_effective_start_date,
                                      p_jurisdiction_code    => p_state_code || '-000-0000',
                                      p_percentage_time      => 0,
                                      p_mode                 => 'ZAP');
         end if;

         /* Delete records from PAY_US_EMP_CITY_TAX_RULES_F */

         delete PAY_US_EMP_CITY_TAX_RULES_F
         where assignment_id = p_assignment_id
         and  state_code = p_state_code;

         /* Delete records from PAY_US_EMP_COUNTY_TAX_RULES_F */

         delete PAY_US_EMP_COUNTY_TAX_RULES_F
         where assignment_id = p_assignment_id
         and  state_code = p_state_code;

         /* Delete records from PAY_US_EMP_STATE_TAX_RULES_F */

         delete PAY_US_EMP_STATE_TAX_RULES_F
         where assignment_id = p_assignment_id
         and  state_code = p_state_code;

       elsif p_state_code is not null and p_county_code is not null
             and p_city_code is null then

         if l_payroll_installed then

             /* Get the cities for the county and call the maintain_element_entry routine
                to delete the city %age records for the cities in the county */

             open csr_county_cities;

             loop

                 fetch csr_county_cities into l_jurisdiction_code;

                 exit when csr_county_cities%NOTFOUND;

                 /* Delete the %age tax record for the jurisdiction */

                 maintain_element_entry(p_assignment_id      => p_assignment_id,
                                      p_effective_start_date => l_effective_start_date,
                                      p_effective_end_date   => to_date('31-12-4712','dd-mm-yyyy'),
                                      p_session_date         => l_effective_start_date,
                                      p_jurisdiction_code    => l_jurisdiction_code,
                                      p_percentage_time      => 0,
                                      p_mode                 => 'ZAP');

             end loop;

             close csr_county_cities;

             /* Delete the state %age records for the county */

             maintain_element_entry(p_assignment_id      => p_assignment_id,
                                      p_effective_start_date => l_effective_start_date,
                                      p_effective_end_date   => to_date('31-12-4712','dd-mm-yyyy'),
                                      p_session_date         => l_effective_start_date,
                                      p_jurisdiction_code    => p_state_code ||'-' ||
                                                                p_county_code ||'-0000',
                                      p_percentage_time      => 0,
                                      p_mode                 => 'ZAP');
          end if;

          /* Delete records from PAY_US_EMP_CITY_TAX_RULES_F */

          delete PAY_US_EMP_CITY_TAX_RULES_F
          where assignment_id = p_assignment_id
          and  state_code     = p_state_code
          and  county_code    = p_county_code;

          /* Delete records from PAY_US_EMP_COUNTY_TAX_RULES_F */

          delete PAY_US_EMP_COUNTY_TAX_RULES_F
          where assignment_id = p_assignment_id
          and  state_code     = p_state_code
          and  county_code    = p_county_code;

        elsif p_state_code is not null and p_county_code is not null
              and p_city_code is not null then

          if l_payroll_installed then

              /* Delete the state %age records for the city */

              maintain_element_entry(p_assignment_id      => p_assignment_id,
                                     p_effective_start_date => l_effective_start_date,
                                     p_effective_end_date   => to_date('31-12-4712','dd-mm-yyyy'),
                                     p_session_date         => l_effective_start_date,
                                     p_jurisdiction_code    => p_state_code ||'-' ||
                                                               p_county_code ||'-'|| p_city_code,
                                     p_percentage_time      => 0,
                                     p_mode                 => 'ZAP');

           end if;

           /* Delete records from PAY_US_EMP_CITY_TAX_RULES_F */

           delete PAY_US_EMP_CITY_TAX_RULES_F
           where assignment_id = p_assignment_id
           and  state_code     = p_state_code
           and  county_code    = p_county_code
           and  city_code      = p_city_code;

        end if;

   end delete_tax_row;


  /* Name        : lock_fed_tax_row
     Purpose     : To lock the federal tax rule record.
  */

  procedure lock_fed_tax_row ( p_row_id                    in varchar2,
                                  p_emp_fed_tax_rule_id      in number,
				                  p_effective_start_date     in date,
                                  p_effective_end_date       in date,
                                  p_assignment_id            in number,
                                  p_sui_state_code           in varchar2,
                                  p_sui_jurisdiction_code    in varchar2,
                                  p_business_group_id        in number,
                                  p_additional_wa_amount     in number,
                                  p_filing_status_code       in varchar2,
                                  p_fit_override_amount      in number,
 				                  p_fit_override_rate        in number,
                                  p_withholding_allowances   in number,
                                  p_cumulative_taxation      in varchar2,
                                  p_eic_filing_status_code   in varchar2,
                                  p_fit_additional_tax       in number,
                                  p_fit_exempt               in varchar2,
                                  p_futa_tax_exempt          in varchar2,
                                  p_medicare_tax_exempt      in varchar2,
                                  p_ss_tax_exempt            in varchar2,
                                  p_wage_exempt              in varchar2,
                                  p_statutory_employee       in varchar2,
                                  p_w2_filed_year            in number,
                                  p_supp_tax_override_rate   in number,
                                  p_excessive_wa_reject_date in date,
                                  p_attribute_category        in varchar2,
                                  p_attribute1                in varchar2,
                                  p_attribute2                in varchar2,
                                  p_attribute3                in varchar2,
                                  p_attribute4                in varchar2,
                                  p_attribute5                in varchar2,
                                  p_attribute6                in varchar2,
                                  p_attribute7                in varchar2,
                                  p_attribute8                in varchar2,
                                  p_attribute9                in varchar2,
                                  p_attribute10               in varchar2,
                                  p_attribute11               in varchar2,
                                  p_attribute12               in varchar2,
                                  p_attribute13               in varchar2,
                                  p_attribute14               in varchar2,
                                  p_attribute15               in varchar2,
                                  p_attribute16               in varchar2,
                                  p_attribute17               in varchar2,
                                  p_attribute18               in varchar2,
                                  p_attribute19               in varchar2,
                                  p_attribute20               in varchar2,
                                  p_attribute21               in varchar2,
                                  p_attribute22               in varchar2,
                                  p_attribute23               in varchar2,
                                  p_attribute24               in varchar2,
                                  p_attribute25               in varchar2,
                                  p_attribute26               in varchar2,
                                  p_attribute27               in varchar2,
                                  p_attribute28               in varchar2,
                                  p_attribute29               in varchar2,
                                  p_attribute30               in varchar2,
                                  p_fed_information_category  in varchar2,
                                  p_fed_information1          in varchar2,
                                  p_fed_information2          in varchar2,
                                  p_fed_information3          in varchar2,
                                  p_fed_information4          in varchar2,
                                  p_fed_information5          in varchar2,
                                  p_fed_information6          in varchar2,
                                  p_fed_information7          in varchar2,
                                  p_fed_information8          in varchar2,
                                  p_fed_information9          in varchar2,
                                  p_fed_information10         in varchar2,
                                  p_fed_information11         in varchar2,
                                  p_fed_information12         in varchar2,
                                  p_fed_information13         in varchar2,
                                  p_fed_information14         in varchar2,
                                  p_fed_information15         in varchar2,
                                  p_fed_information16         in varchar2,
                                  p_fed_information17         in varchar2,
                                  p_fed_information18         in varchar2,
                                  p_fed_information19         in varchar2,
                                  p_fed_information20         in varchar2,
                                  p_fed_information21         in varchar2,
                                  p_fed_information22         in varchar2,
                                  p_fed_information23         in varchar2,
                                  p_fed_information24         in varchar2,
                                  p_fed_information25         in varchar2,
                                  p_fed_information26         in varchar2,
                                  p_fed_information27         in varchar2,
                                  p_fed_information28         in varchar2,
                                  p_fed_information29         in varchar2,
                                  p_fed_information30         in varchar2  ) is

  cursor csr_asg_rec is
  select assignment_id
  from   PER_ASSIGNMENTS_F
  where  assignment_id = p_assignment_id
  and    p_effective_start_date between effective_start_date
         and effective_end_date
  for update of assignment_id nowait;

  cursor csr_fed_rec is
  select *
  from   PAY_US_EMP_FED_TAX_RULES_F
  where  rowid = chartorowid(p_row_id)
  for update of emp_fed_tax_rule_id nowait;

  fed_rec csr_fed_rec%rowtype;
  l_assignment_id  number(9);

  begin

     open csr_asg_rec;

     fetch csr_asg_rec into l_assignment_id;

     if csr_asg_rec%NOTFOUND then
        close  csr_asg_rec;
        fnd_message.set_name('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
        fnd_message.raise_error;
     end if;

     close csr_asg_rec;

     open csr_fed_rec;

     fetch csr_fed_rec into fed_rec;

     if csr_fed_rec%NOTFOUND then
        close  csr_fed_rec;
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE',
        'pay_us_emp_dt_tax_rules.lock_fed_tax_row');
        fnd_message.set_token('STEP', '1');
        fnd_message.raise_error;
     end if;

     close  csr_fed_rec;

      fed_rec.sui_state_code           := rtrim(fed_rec.sui_state_code);
      fed_rec.sui_jurisdiction_code    := rtrim(fed_rec.sui_jurisdiction_code);
      fed_rec.filing_status_code       := rtrim(fed_rec.filing_status_code);
      fed_rec.cumulative_taxation      := rtrim(fed_rec.cumulative_taxation);
      fed_rec.eic_filing_status_code   := rtrim(fed_rec.eic_filing_status_code);
      fed_rec.fit_exempt               := rtrim(fed_rec.fit_exempt);
      fed_rec.futa_tax_exempt          := rtrim(fed_rec.futa_tax_exempt);
      fed_rec.medicare_tax_exempt      := rtrim(fed_rec.medicare_tax_exempt);
      fed_rec.ss_tax_exempt            := rtrim(fed_rec.ss_tax_exempt);
      fed_rec.wage_exempt              := rtrim(fed_rec.wage_exempt);
      fed_rec.statutory_employee       := rtrim(fed_rec.statutory_employee);
      fed_rec.attribute_category   := rtrim(fed_rec.attribute_category);
      fed_rec.attribute1           := rtrim(fed_rec.attribute1);
      fed_rec.attribute2           := rtrim(fed_rec.attribute2);
      fed_rec.attribute3           := rtrim(fed_rec.attribute3);
      fed_rec.attribute4           := rtrim(fed_rec.attribute4);
      fed_rec.attribute5           := rtrim(fed_rec.attribute5);
      fed_rec.attribute6           := rtrim(fed_rec.attribute6);
      fed_rec.attribute7           := rtrim(fed_rec.attribute7);
      fed_rec.attribute8           := rtrim(fed_rec.attribute8);
      fed_rec.attribute9           := rtrim(fed_rec.attribute9);
      fed_rec.attribute10          := rtrim(fed_rec.attribute10);
      fed_rec.attribute11          := rtrim(fed_rec.attribute11);
      fed_rec.attribute12          := rtrim(fed_rec.attribute12);
      fed_rec.attribute13          := rtrim(fed_rec.attribute13);
      fed_rec.attribute14          := rtrim(fed_rec.attribute14);
      fed_rec.attribute15          := rtrim(fed_rec.attribute15);
      fed_rec.attribute16          := rtrim(fed_rec.attribute16);
      fed_rec.attribute17          := rtrim(fed_rec.attribute17);
      fed_rec.attribute18          := rtrim(fed_rec.attribute18);
      fed_rec.attribute19          := rtrim(fed_rec.attribute19);
      fed_rec.attribute20          := rtrim(fed_rec.attribute20);
      fed_rec.attribute21          := rtrim(fed_rec.attribute21);
      fed_rec.attribute22          := rtrim(fed_rec.attribute22);
      fed_rec.attribute23          := rtrim(fed_rec.attribute23);
      fed_rec.attribute24          := rtrim(fed_rec.attribute24);
      fed_rec.attribute25          := rtrim(fed_rec.attribute25);
      fed_rec.attribute26          := rtrim(fed_rec.attribute26);
      fed_rec.attribute27          := rtrim(fed_rec.attribute27);
      fed_rec.attribute28          := rtrim(fed_rec.attribute28);
      fed_rec.attribute29          := rtrim(fed_rec.attribute29);
      fed_rec.attribute30          := rtrim(fed_rec.attribute30);
      fed_rec.fed_information_category   := rtrim(fed_rec.fed_information_category);
      fed_rec.fed_information1     := rtrim(fed_rec.fed_information1);
      fed_rec.fed_information2     := rtrim(fed_rec.fed_information2);
      fed_rec.fed_information3     := rtrim(fed_rec.fed_information3);
      fed_rec.fed_information4     := rtrim(fed_rec.fed_information4);
      fed_rec.fed_information5     := rtrim(fed_rec.fed_information5);
      fed_rec.fed_information6     := rtrim(fed_rec.fed_information6);
      fed_rec.fed_information7     := rtrim(fed_rec.fed_information7);
      fed_rec.fed_information8     := rtrim(fed_rec.fed_information8);
      fed_rec.fed_information9     := rtrim(fed_rec.fed_information9);
      fed_rec.fed_information10    := rtrim(fed_rec.fed_information10);
      fed_rec.fed_information11    := rtrim(fed_rec.fed_information11);
      fed_rec.fed_information12    := rtrim(fed_rec.fed_information12);
      fed_rec.fed_information13    := rtrim(fed_rec.fed_information13);
      fed_rec.fed_information14    := rtrim(fed_rec.fed_information14);
      fed_rec.fed_information15    := rtrim(fed_rec.fed_information15);
      fed_rec.fed_information16    := rtrim(fed_rec.fed_information16);
      fed_rec.fed_information17    := rtrim(fed_rec.fed_information17);
      fed_rec.fed_information18    := rtrim(fed_rec.fed_information18);
      fed_rec.fed_information19    := rtrim(fed_rec.fed_information19);
      fed_rec.fed_information20    := rtrim(fed_rec.fed_information20);
      fed_rec.fed_information21    := rtrim(fed_rec.fed_information21);
      fed_rec.fed_information22    := rtrim(fed_rec.fed_information22);
      fed_rec.fed_information23    := rtrim(fed_rec.fed_information23);
      fed_rec.fed_information24    := rtrim(fed_rec.fed_information24);
      fed_rec.fed_information25    := rtrim(fed_rec.fed_information25);
      fed_rec.fed_information26    := rtrim(fed_rec.fed_information26);
      fed_rec.fed_information27    := rtrim(fed_rec.fed_information27);
      fed_rec.fed_information28    := rtrim(fed_rec.fed_information28);
      fed_rec.fed_information29    := rtrim(fed_rec.fed_information29);
      fed_rec.fed_information30    := rtrim(fed_rec.fed_information30);


        if ((fed_rec.emp_fed_tax_rule_id = p_emp_fed_tax_rule_id)
           or (fed_rec.emp_fed_tax_rule_id is null and
               p_emp_fed_tax_rule_id is null))
        and ((fed_rec.effective_start_date = p_effective_start_date)
           or (fed_rec.effective_start_date is null and
               p_effective_start_date is null))
        and ((fed_rec.effective_end_date = p_effective_end_date)
           or (fed_rec.effective_end_date is null and
               p_effective_end_date is null))
        and ((fed_rec.assignment_id = p_assignment_id)
           or (fed_rec.assignment_id is null and
               p_assignment_id is null))
        and ((fed_rec.sui_state_code = p_sui_state_code)
           or (fed_rec.sui_state_code is null and
               p_sui_state_code is null))
        and ((fed_rec.sui_jurisdiction_code = p_sui_jurisdiction_code)
           or (fed_rec.sui_jurisdiction_code is null and
               p_sui_jurisdiction_code is null))
        and ((fed_rec.business_group_id = p_business_group_id)
           or (fed_rec.business_group_id is null and
               p_business_group_id is null))
        and ((fed_rec.additional_wa_amount = p_additional_wa_amount)
           or (fed_rec.additional_wa_amount is null and
               p_additional_wa_amount is null))
        and ((fed_rec.filing_status_code = lpad(p_filing_status_code,2,'0'))
           or (fed_rec.filing_status_code is null and
               p_filing_status_code is null))
        and ((fed_rec.fit_override_amount = p_fit_override_amount)
           or (fed_rec.fit_override_amount is null and
               p_fit_override_amount is null))
        and ((fed_rec.fit_override_rate = p_fit_override_rate)
           or (fed_rec.fit_override_rate is null and
               p_fit_override_rate is null))
        and ((fed_rec.withholding_allowances = p_withholding_allowances)
           or (fed_rec.withholding_allowances is null and
               p_withholding_allowances is null))
        and ((fed_rec.cumulative_taxation = p_cumulative_taxation)
           or (fed_rec.cumulative_taxation is null and
               p_cumulative_taxation is null))
        and ((fed_rec.eic_filing_status_code = p_eic_filing_status_code)
           or (fed_rec.eic_filing_status_code is null and
               p_eic_filing_status_code is null))
        and ((fed_rec.fit_additional_tax = p_fit_additional_tax)
           or (fed_rec.fit_additional_tax is null and
               p_fit_additional_tax is null))
        and ((fed_rec.fit_exempt = p_fit_exempt)
           or (fed_rec.fit_exempt is null and
               p_fit_exempt is null))
        and ((fed_rec.futa_tax_exempt = p_futa_tax_exempt)
           or (fed_rec.futa_tax_exempt is null and
               p_futa_tax_exempt is null))
        and ((fed_rec.medicare_tax_exempt = p_medicare_tax_exempt)
           or (fed_rec.medicare_tax_exempt is null and
               p_medicare_tax_exempt is null))
        and ((fed_rec.ss_tax_exempt = p_ss_tax_exempt)
           or (fed_rec.ss_tax_exempt is null and
               p_ss_tax_exempt is null))
        and ((fed_rec.wage_exempt = p_wage_exempt)
           or (fed_rec.wage_exempt is null and
               p_wage_exempt is null))
        and ((fed_rec.statutory_employee = p_statutory_employee)
           or (fed_rec.statutory_employee is null and
               p_statutory_employee is null))
        and ((fed_rec.w2_filed_year = p_w2_filed_year)
           or (fed_rec.w2_filed_year is null and
               p_w2_filed_year is null))
        and ((fed_rec.supp_tax_override_rate = p_supp_tax_override_rate)
           or (fed_rec.supp_tax_override_rate is null and
               p_supp_tax_override_rate is null))
        and ((fed_rec.excessive_wa_reject_date = p_excessive_wa_reject_date)
           or (fed_rec.excessive_wa_reject_date is null and
               p_excessive_wa_reject_date is null))
        and ((fed_rec.attribute_category = p_attribute_category)
           or (fed_rec.attribute_category is null and
               p_attribute_category is null))
        and ((fed_rec.attribute1 = p_attribute1)
           or (fed_rec.attribute1 is null and
               p_attribute1 is null))
        and ((fed_rec.attribute2 = p_attribute2)
           or (fed_rec.attribute2 is null and
               p_attribute2 is null))
        and ((fed_rec.attribute3 = p_attribute3)
           or (fed_rec.attribute3 is null and
               p_attribute3 is null))
        and ((fed_rec.attribute4 = p_attribute4)
           or (fed_rec.attribute4 is null and
               p_attribute4 is null))
        and ((fed_rec.attribute5 = p_attribute5)
           or (fed_rec.attribute5 is null and
               p_attribute5 is null))
        and ((fed_rec.attribute6 = p_attribute6)
           or (fed_rec.attribute6 is null and
               p_attribute6 is null))
        and ((fed_rec.attribute7 = p_attribute7)
           or (fed_rec.attribute7 is null and
               p_attribute7 is null))
        and ((fed_rec.attribute8 = p_attribute8)
           or (fed_rec.attribute8 is null and
               p_attribute8 is null))
        and ((fed_rec.attribute9 = p_attribute9)
           or (fed_rec.attribute9 is null and
               p_attribute9 is null))
        and ((fed_rec.attribute10 = p_attribute10)
           or (fed_rec.attribute10 is null and
               p_attribute10 is null))
        and ((fed_rec.attribute11 = p_attribute11)
           or (fed_rec.attribute11 is null and
               p_attribute11 is null))
        and ((fed_rec.attribute12 = p_attribute12)
           or (fed_rec.attribute12 is null and
               p_attribute12 is null))
        and ((fed_rec.attribute13 = p_attribute13)
           or (fed_rec.attribute13 is null and
               p_attribute13 is null))
        and ((fed_rec.attribute14 = p_attribute14)
           or (fed_rec.attribute14 is null and
               p_attribute14 is null))
        and ((fed_rec.attribute15 = p_attribute15)
           or (fed_rec.attribute15 is null and
               p_attribute15 is null))
        and ((fed_rec.attribute16 = p_attribute16)
           or (fed_rec.attribute16 is null and
               p_attribute16 is null))
        and ((fed_rec.attribute17 = p_attribute17)
           or (fed_rec.attribute17 is null and
               p_attribute17 is null))
        and ((fed_rec.attribute18 = p_attribute18)
           or (fed_rec.attribute18 is null and
               p_attribute18 is null))
        and ((fed_rec.attribute19 = p_attribute19)
           or (fed_rec.attribute19 is null and
               p_attribute19 is null))
        and ((fed_rec.attribute20 = p_attribute20)
           or (fed_rec.attribute20 is null and
               p_attribute20 is null))
        and ((fed_rec.attribute21 = p_attribute21)
           or (fed_rec.attribute21 is null and
               p_attribute21 is null))
        and ((fed_rec.attribute22 = p_attribute22)
           or (fed_rec.attribute22 is null and
               p_attribute22 is null))
        and ((fed_rec.attribute23 = p_attribute23)
           or (fed_rec.attribute23 is null and
               p_attribute23 is null))
        and ((fed_rec.attribute24 = p_attribute24)
           or (fed_rec.attribute24 is null and
               p_attribute24 is null))
        and ((fed_rec.attribute25 = p_attribute25)
           or (fed_rec.attribute25 is null and
               p_attribute25 is null))
        and ((fed_rec.attribute26 = p_attribute26)
           or (fed_rec.attribute26 is null and
               p_attribute26 is null))
        and ((fed_rec.attribute27 = p_attribute27)
           or (fed_rec.attribute27 is null and
               p_attribute27 is null))
        and ((fed_rec.attribute28 = p_attribute28)
           or (fed_rec.attribute28 is null and
               p_attribute28 is null))
        and ((fed_rec.attribute29 = p_attribute29)
           or (fed_rec.attribute29 is null and
               p_attribute29 is null))
        and ((fed_rec.attribute30 = p_attribute30)
           or (fed_rec.attribute30 is null and
               p_attribute30 is null))
        and ((fed_rec.fed_information_category = p_fed_information_category)
           or (fed_rec.fed_information_category is null and
               p_fed_information_category is null))
        and ((fed_rec.fed_information1 = p_fed_information1)
           or (fed_rec.fed_information1 is null and
               p_fed_information1 is null))
        and ((fed_rec.fed_information2 = p_fed_information2)
           or (fed_rec.fed_information2 is null and
               p_fed_information2 is null))
        and ((fed_rec.fed_information3 = p_fed_information3)
           or (fed_rec.fed_information3 is null and
               p_fed_information3 is null))
        and ((fed_rec.fed_information4 = p_fed_information4)
           or (fed_rec.fed_information4 is null and
               p_fed_information4 is null))
        and ((fed_rec.fed_information5 = p_fed_information5)
           or (fed_rec.fed_information5 is null and
               p_fed_information5 is null))
        and ((fed_rec.fed_information6 = p_fed_information6)
           or (fed_rec.fed_information6 is null and
               p_fed_information6 is null))
        and ((fed_rec.fed_information7 = p_fed_information7)
           or (fed_rec.fed_information7 is null and
               p_fed_information7 is null))
        and ((fed_rec.fed_information8 = p_fed_information8)
           or (fed_rec.fed_information8 is null and
               p_fed_information8 is null))
        and ((fed_rec.fed_information9 = p_fed_information9)
           or (fed_rec.fed_information9 is null and
               p_fed_information9 is null))
        and ((fed_rec.fed_information10 = p_fed_information10)
           or (fed_rec.fed_information10 is null and
               p_fed_information10 is null))
        and ((fed_rec.fed_information11 = p_fed_information11)
           or (fed_rec.fed_information11 is null and
               p_fed_information11 is null))
        and ((fed_rec.fed_information12 = p_fed_information12)
           or (fed_rec.fed_information12 is null and
               p_fed_information12 is null))
        and ((fed_rec.fed_information13 = p_fed_information13)
           or (fed_rec.fed_information13 is null and
               p_fed_information13 is null))
        and ((fed_rec.fed_information14 = p_fed_information14)
           or (fed_rec.fed_information14 is null and
               p_fed_information14 is null))
        and ((fed_rec.fed_information15 = p_fed_information15)
           or (fed_rec.fed_information15 is null and
               p_fed_information15 is null))
        and ((fed_rec.fed_information16 = p_fed_information16)
           or (fed_rec.fed_information16 is null and
               p_fed_information16 is null))
        and ((fed_rec.fed_information17 = p_fed_information17)
           or (fed_rec.fed_information17 is null and
               p_fed_information17 is null))
        and ((fed_rec.fed_information18 = p_fed_information18)
           or (fed_rec.fed_information18 is null and
               p_fed_information18 is null))
        and ((fed_rec.fed_information19 = p_fed_information19)
           or (fed_rec.fed_information19 is null and
               p_fed_information19 is null))
        and ((fed_rec.fed_information20 = p_fed_information20)
           or (fed_rec.fed_information20 is null and
               p_fed_information20 is null))
        and ((fed_rec.fed_information21 = p_fed_information21)
           or (fed_rec.fed_information21 is null and
               p_fed_information21 is null))
        and ((fed_rec.fed_information22 = p_fed_information22)
           or (fed_rec.fed_information22 is null and
               p_fed_information22 is null))
        and ((fed_rec.fed_information23 = p_fed_information23)
           or (fed_rec.fed_information23 is null and
               p_fed_information23 is null))
        and ((fed_rec.fed_information24 = p_fed_information24)
           or (fed_rec.fed_information24 is null and
               p_fed_information24 is null))
        and ((fed_rec.fed_information25 = p_fed_information25)
           or (fed_rec.fed_information25 is null and
               p_fed_information25 is null))
        and ((fed_rec.fed_information26 = p_fed_information26)
           or (fed_rec.fed_information26 is null and
               p_fed_information26 is null))
        and ((fed_rec.fed_information27 = p_fed_information27)
           or (fed_rec.fed_information27 is null and
               p_fed_information27 is null))
        and ((fed_rec.fed_information28 = p_fed_information28)
           or (fed_rec.fed_information28 is null and
               p_fed_information28 is null))
        and ((fed_rec.fed_information29 = p_fed_information29)
           or (fed_rec.fed_information29 is null and
               p_fed_information29 is null))
        and ((fed_rec.fed_information30 = p_fed_information30)
           or (fed_rec.fed_information30 is null and
               p_fed_information30 is null))
     then

      return;

     else

        fnd_message.set_name('PAY', 'FORM_RECORD_CHANGED');
        fnd_message.raise_error;

     end if;

  end lock_fed_tax_row;



  /* Name        : lock_state_tax_row
     Purpose     : To lock the state tax rule record.
  */

  procedure lock_state_tax_row ( p_row_id in varchar2,
                                   p_emp_state_tax_rule_id in number,
                                   p_effective_start_date in date,
                                   p_effective_end_date in date,
                                   p_assignment_id in number,
                                   p_state_code in varchar2,
                                   p_jurisdiction_code in varchar2,
                                   p_business_group_id in number,
                                   p_additional_wa_amount in number,
                                   p_filing_status_code in varchar2,
                                   p_remainder_percent in number,
                                   p_secondary_wa in number,
                                   p_sit_additional_tax in number,
                                   p_sit_override_amount in number,
                                   p_sit_override_rate in number,
                                   p_withholding_allowances in number,
                                   p_excessive_wa_reject_date in date,
                                   p_sdi_exempt in varchar2,
                                   p_sit_exempt in varchar2,
                                   p_sit_optional_calc_ind in varchar2,
                                   p_state_non_resident_cert in varchar2,
                                   p_sui_exempt in varchar2,
                                   p_wc_exempt in varchar2,
                                   p_wage_exempt in varchar2,
                                   p_sui_wage_base_override_amt in number,
                                   p_supp_tax_override_rate in number,
                                   p_attribute_category        in varchar2,
                                   p_attribute1                in varchar2,
                                   p_attribute2                in varchar2,
                                   p_attribute3                in varchar2,
                                   p_attribute4                in varchar2,
                                   p_attribute5                in varchar2,
                                   p_attribute6                in varchar2,
                                   p_attribute7                in varchar2,
                                   p_attribute8                in varchar2,
                                   p_attribute9                in varchar2,
                                   p_attribute10               in varchar2,
                                   p_attribute11               in varchar2,
                                   p_attribute12               in varchar2,
                                   p_attribute13               in varchar2,
                                   p_attribute14               in varchar2,
                                   p_attribute15               in varchar2,
                                   p_attribute16               in varchar2,
                                   p_attribute17               in varchar2,
                                   p_attribute18               in varchar2,
                                   p_attribute19               in varchar2,
                                   p_attribute20               in varchar2,
                                   p_attribute21               in varchar2,
                                   p_attribute22               in varchar2,
                                   p_attribute23               in varchar2,
                                   p_attribute24               in varchar2,
                                   p_attribute25               in varchar2,
                                   p_attribute26               in varchar2,
                                   p_attribute27               in varchar2,
                                   p_attribute28               in varchar2,
                                   p_attribute29               in varchar2,
                                   p_attribute30               in varchar2,
                                   p_sta_information_category  in varchar2,
                                   p_sta_information1          in varchar2,
                                   p_sta_information2          in varchar2,
                                   p_sta_information3          in varchar2,
                                   p_sta_information4          in varchar2,
                                   p_sta_information5          in varchar2,
                                   p_sta_information6          in varchar2,
                                   p_sta_information7          in varchar2,
                                   p_sta_information8          in varchar2,
                                   p_sta_information9          in varchar2,
                                   p_sta_information10         in varchar2,
                                   p_sta_information11         in varchar2,
                                   p_sta_information12         in varchar2,
                                   p_sta_information13         in varchar2,
                                   p_sta_information14         in varchar2,
                                   p_sta_information15         in varchar2,
                                   p_sta_information16         in varchar2,
                                   p_sta_information17         in varchar2,
                                   p_sta_information18         in varchar2,
                                   p_sta_information19         in varchar2,
                                   p_sta_information20         in varchar2,
                                   p_sta_information21         in varchar2,
                                   p_sta_information22         in varchar2,
                                   p_sta_information23         in varchar2,
                                   p_sta_information24         in varchar2,
                                   p_sta_information25         in varchar2,
                                   p_sta_information26         in varchar2,
                                   p_sta_information27         in varchar2,
                                   p_sta_information28         in varchar2,
                                   p_sta_information29         in varchar2,
                                   p_sta_information30         in varchar2  ) is

  cursor csr_asg_rec is
  select assignment_id
  from   PER_ASSIGNMENTS_F
  where  assignment_id = p_assignment_id
  and    p_effective_start_date between effective_start_date
         and effective_end_date
  for update of assignment_id nowait;

  cursor csr_state_rec is
  select *
  from   PAY_US_EMP_STATE_TAX_RULES_F
  where  rowid = chartorowid(p_row_id)
  for update of emp_state_tax_rule_id nowait;

  state_rec   csr_state_rec%rowtype;
  l_assignment_id      number(9);

  begin

     open csr_asg_rec;

     fetch csr_asg_rec into l_assignment_id;

     if csr_asg_rec%NOTFOUND then
        close  csr_asg_rec;
        fnd_message.set_name('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
        fnd_message.raise_error;
     end if;

     close csr_asg_rec;

     open csr_state_rec;

     fetch csr_state_rec into state_rec;

     if csr_state_rec%NOTFOUND then
        close  csr_state_rec;
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE',
        'pay_us_emp_dt_tax_rules.lock_state_tax_row');
        fnd_message.set_token('STEP', '1');
        fnd_message.raise_error;
     end if;

     close  csr_state_rec;

      state_rec.state_code               := rtrim(state_rec.state_code);
      state_rec.jurisdiction_code        := rtrim(state_rec.jurisdiction_code);
      state_rec.filing_status_code       := rtrim(state_rec.filing_status_code);
      state_rec.sdi_exempt               := rtrim(state_rec.sdi_exempt);
      state_rec.sit_exempt               := rtrim(state_rec.sit_exempt);
      state_rec.sit_optional_calc_ind    := rtrim(state_rec.sit_optional_calc_ind);
      state_rec.state_non_resident_cert  := rtrim(state_rec.state_non_resident_cert);
      state_rec.sui_exempt               := rtrim(state_rec.sui_exempt);
      state_rec.wc_exempt                 := rtrim(state_rec.wc_exempt);
      state_rec.wage_exempt               := rtrim(state_rec.wage_exempt);
      state_rec.attribute_category   := rtrim(state_rec.attribute_category);
      state_rec.attribute1           := rtrim(state_rec.attribute1);
      state_rec.attribute2           := rtrim(state_rec.attribute2);
      state_rec.attribute3           := rtrim(state_rec.attribute3);
      state_rec.attribute4           := rtrim(state_rec.attribute4);
      state_rec.attribute5           := rtrim(state_rec.attribute5);
      state_rec.attribute6           := rtrim(state_rec.attribute6);
      state_rec.attribute7           := rtrim(state_rec.attribute7);
      state_rec.attribute8           := rtrim(state_rec.attribute8);
      state_rec.attribute9           := rtrim(state_rec.attribute9);
      state_rec.attribute10          := rtrim(state_rec.attribute10);
      state_rec.attribute11          := rtrim(state_rec.attribute11);
      state_rec.attribute12          := rtrim(state_rec.attribute12);
      state_rec.attribute13          := rtrim(state_rec.attribute13);
      state_rec.attribute14          := rtrim(state_rec.attribute14);
      state_rec.attribute15          := rtrim(state_rec.attribute15);
      state_rec.attribute16          := rtrim(state_rec.attribute16);
      state_rec.attribute17          := rtrim(state_rec.attribute17);
      state_rec.attribute18          := rtrim(state_rec.attribute18);
      state_rec.attribute19          := rtrim(state_rec.attribute19);
      state_rec.attribute20          := rtrim(state_rec.attribute20);
      state_rec.attribute21          := rtrim(state_rec.attribute21);
      state_rec.attribute22          := rtrim(state_rec.attribute22);
      state_rec.attribute23          := rtrim(state_rec.attribute23);
      state_rec.attribute24          := rtrim(state_rec.attribute24);
      state_rec.attribute25          := rtrim(state_rec.attribute25);
      state_rec.attribute26          := rtrim(state_rec.attribute26);
      state_rec.attribute27          := rtrim(state_rec.attribute27);
      state_rec.attribute28          := rtrim(state_rec.attribute28);
      state_rec.attribute29          := rtrim(state_rec.attribute29);
      state_rec.attribute30          := rtrim(state_rec.attribute30);
      state_rec.sta_information_category   := rtrim(state_rec.sta_information_category);
      state_rec.sta_information1     := rtrim(state_rec.sta_information1);
      state_rec.sta_information2     := rtrim(state_rec.sta_information2);
      state_rec.sta_information3     := rtrim(state_rec.sta_information3);
      state_rec.sta_information4     := rtrim(state_rec.sta_information4);
      state_rec.sta_information5     := rtrim(state_rec.sta_information5);
      state_rec.sta_information6     := rtrim(state_rec.sta_information6);
      state_rec.sta_information7     := rtrim(state_rec.sta_information7);
      state_rec.sta_information8     := rtrim(state_rec.sta_information8);
      state_rec.sta_information9     := rtrim(state_rec.sta_information9);
      state_rec.sta_information10    := rtrim(state_rec.sta_information10);
      state_rec.sta_information11    := rtrim(state_rec.sta_information11);
      state_rec.sta_information12    := rtrim(state_rec.sta_information12);
      state_rec.sta_information13    := rtrim(state_rec.sta_information13);
      state_rec.sta_information14    := rtrim(state_rec.sta_information14);
      state_rec.sta_information15    := rtrim(state_rec.sta_information15);
      state_rec.sta_information16    := rtrim(state_rec.sta_information16);
      state_rec.sta_information17    := rtrim(state_rec.sta_information17);
      state_rec.sta_information18    := rtrim(state_rec.sta_information18);
      state_rec.sta_information19    := rtrim(state_rec.sta_information19);
      state_rec.sta_information20    := rtrim(state_rec.sta_information20);
      state_rec.sta_information21    := rtrim(state_rec.sta_information21);
      state_rec.sta_information22    := rtrim(state_rec.sta_information22);
      state_rec.sta_information23    := rtrim(state_rec.sta_information23);
      state_rec.sta_information24    := rtrim(state_rec.sta_information24);
      state_rec.sta_information25    := rtrim(state_rec.sta_information25);
      state_rec.sta_information26    := rtrim(state_rec.sta_information26);
      state_rec.sta_information27    := rtrim(state_rec.sta_information27);
      state_rec.sta_information28    := rtrim(state_rec.sta_information28);
      state_rec.sta_information29    := rtrim(state_rec.sta_information29);
      state_rec.sta_information30    := rtrim(state_rec.sta_information30);

        if ((state_rec.emp_state_tax_rule_id = p_emp_state_tax_rule_id)
           or (state_rec.emp_state_tax_rule_id is null and
               p_emp_state_tax_rule_id is null))
        and ((state_rec.effective_start_date = p_effective_start_date)
           or (state_rec.effective_start_date is null and
               p_effective_start_date is null))
        and ((state_rec.effective_end_date = p_effective_end_date)
           or (state_rec.effective_end_date is null and
               p_effective_end_date is null))
        and ((state_rec.assignment_id = p_assignment_id)
           or (state_rec.assignment_id is null and
               p_assignment_id is null))
        and ((state_rec.state_code = p_state_code)
           or (state_rec.state_code is null and
               p_state_code is null))
        and ((state_rec.jurisdiction_code = p_jurisdiction_code)
           or (state_rec.jurisdiction_code is null and
               p_jurisdiction_code is null))
        and ((state_rec.business_group_id = p_business_group_id)
           or (state_rec.business_group_id is null and
               p_business_group_id is null))
        and ((state_rec.additional_wa_amount = p_additional_wa_amount)
           or (state_rec.additional_wa_amount is null and
               p_additional_wa_amount is null))
        and ((state_rec.filing_status_code = lpad(p_filing_status_code,2,'0'))
           or (state_rec.filing_status_code is null and
               p_filing_status_code is null))
        and ((state_rec.remainder_percent = p_remainder_percent)
           or (state_rec.remainder_percent is null and
               p_remainder_percent is null))
        and ((state_rec.secondary_wa = p_secondary_wa)
           or (state_rec.secondary_wa is null and
               p_secondary_wa is null))
        and ((state_rec.sit_additional_tax = p_sit_additional_tax)
           or (state_rec.sit_additional_tax is null and
               p_sit_additional_tax is null))
        and ((state_rec.sit_override_amount = p_sit_override_amount)
           or (state_rec.sit_override_amount is null and
               p_sit_override_amount is null))
        and ((state_rec.sit_override_rate = p_sit_override_rate)
           or (state_rec.sit_override_rate is null and
               p_sit_override_rate is null))
        and ((state_rec.withholding_allowances = p_withholding_allowances)
           or (state_rec.withholding_allowances is null and
               p_withholding_allowances is null))
        and ((state_rec.excessive_wa_reject_date = p_excessive_wa_reject_date)
           or (state_rec.excessive_wa_reject_date is null and
               p_excessive_wa_reject_date is null))
        and ((state_rec.sdi_exempt = p_sdi_exempt)
           or (state_rec.sdi_exempt is null and
               p_sdi_exempt is null))
        and ((state_rec.sit_exempt = p_sit_exempt)
           or (state_rec.sit_exempt is null and
               p_sit_exempt is null))
        and ((state_rec.sit_optional_calc_ind = p_sit_optional_calc_ind)
           or (state_rec.sit_optional_calc_ind is null and
               p_sit_optional_calc_ind is null))
        and ((state_rec.state_non_resident_cert = p_state_non_resident_cert)
           or (state_rec.state_non_resident_cert is null and
               p_state_non_resident_cert is null))
        and ((state_rec.sui_exempt = p_sui_exempt)
           or (state_rec.sui_exempt is null and
               p_sui_exempt is null))
        and ((state_rec.wc_exempt = p_wc_exempt)
           or (state_rec.wc_exempt is null and
               p_wc_exempt is null))
        and ((state_rec.wage_exempt = p_wage_exempt)
           or (state_rec.wage_exempt is null and
               p_wage_exempt is null))
        and ((state_rec.sui_wage_base_override_amount = p_sui_wage_base_override_amt)
           or (state_rec.sui_wage_base_override_amount is null and
               p_sui_wage_base_override_amt is null))
        and ((state_rec.supp_tax_override_rate = p_supp_tax_override_rate)
           or (state_rec.supp_tax_override_rate is null and
               p_supp_tax_override_rate is null))
        and ((state_rec.attribute_category = p_attribute_category)
           or (state_rec.attribute_category is null and
               p_attribute_category is null))
        and ((state_rec.attribute1 = p_attribute1)
           or (state_rec.attribute1 is null and
               p_attribute1 is null))
        and ((state_rec.attribute2 = p_attribute2)
           or (state_rec.attribute2 is null and
               p_attribute2 is null))
        and ((state_rec.attribute3 = p_attribute3)
           or (state_rec.attribute3 is null and
               p_attribute3 is null))
        and ((state_rec.attribute4 = p_attribute4)
           or (state_rec.attribute4 is null and
               p_attribute4 is null))
        and ((state_rec.attribute5 = p_attribute5)
           or (state_rec.attribute5 is null and
               p_attribute5 is null))
        and ((state_rec.attribute6 = p_attribute6)
           or (state_rec.attribute6 is null and
               p_attribute6 is null))
        and ((state_rec.attribute7 = p_attribute7)
           or (state_rec.attribute7 is null and
               p_attribute7 is null))
        and ((state_rec.attribute8 = p_attribute8)
           or (state_rec.attribute8 is null and
               p_attribute8 is null))
        and ((state_rec.attribute9 = p_attribute9)
           or (state_rec.attribute9 is null and
               p_attribute9 is null))
        and ((state_rec.attribute10 = p_attribute10)
           or (state_rec.attribute10 is null and
               p_attribute10 is null))
        and ((state_rec.attribute11 = p_attribute11)
           or (state_rec.attribute11 is null and
               p_attribute11 is null))
        and ((state_rec.attribute12 = p_attribute12)
           or (state_rec.attribute12 is null and
               p_attribute12 is null))
        and ((state_rec.attribute13 = p_attribute13)
           or (state_rec.attribute13 is null and
               p_attribute13 is null))
        and ((state_rec.attribute14 = p_attribute14)
           or (state_rec.attribute14 is null and
               p_attribute14 is null))
        and ((state_rec.attribute15 = p_attribute15)
           or (state_rec.attribute15 is null and
               p_attribute15 is null))
        and ((state_rec.attribute16 = p_attribute16)
           or (state_rec.attribute16 is null and
               p_attribute16 is null))
        and ((state_rec.attribute17 = p_attribute17)
           or (state_rec.attribute17 is null and
               p_attribute17 is null))
        and ((state_rec.attribute18 = p_attribute18)
           or (state_rec.attribute18 is null and
               p_attribute18 is null))
        and ((state_rec.attribute19 = p_attribute19)
           or (state_rec.attribute19 is null and
               p_attribute19 is null))
        and ((state_rec.attribute20 = p_attribute20)
           or (state_rec.attribute20 is null and
               p_attribute20 is null))
        and ((state_rec.attribute21 = p_attribute21)
           or (state_rec.attribute21 is null and
               p_attribute21 is null))
        and ((state_rec.attribute22 = p_attribute22)
           or (state_rec.attribute22 is null and
               p_attribute22 is null))
        and ((state_rec.attribute23 = p_attribute23)
           or (state_rec.attribute23 is null and
               p_attribute23 is null))
        and ((state_rec.attribute24 = p_attribute24)
           or (state_rec.attribute24 is null and
               p_attribute24 is null))
        and ((state_rec.attribute25 = p_attribute25)
           or (state_rec.attribute25 is null and
               p_attribute25 is null))
        and ((state_rec.attribute26 = p_attribute26)
           or (state_rec.attribute26 is null and
               p_attribute26 is null))
        and ((state_rec.attribute27 = p_attribute27)
           or (state_rec.attribute27 is null and
               p_attribute27 is null))
        and ((state_rec.attribute28 = p_attribute28)
           or (state_rec.attribute28 is null and
               p_attribute28 is null))
        and ((state_rec.attribute29 = p_attribute29)
           or (state_rec.attribute29 is null and
               p_attribute29 is null))
        and ((state_rec.attribute30 = p_attribute30)
           or (state_rec.attribute30 is null and
               p_attribute30 is null))
        and ((state_rec.sta_information_category = p_sta_information_category)
           or (state_rec.sta_information_category is null and
               p_sta_information_category is null))
        and ((state_rec.sta_information1 = p_sta_information1)
           or (state_rec.sta_information1 is null and
               p_sta_information1 is null))
        and ((state_rec.sta_information2 = p_sta_information2)
           or (state_rec.sta_information2 is null and
               p_sta_information2 is null))
        and ((state_rec.sta_information3 = p_sta_information3)
           or (state_rec.sta_information3 is null and
               p_sta_information3 is null))
        and ((state_rec.sta_information4 = p_sta_information4)
           or (state_rec.sta_information4 is null and
               p_sta_information4 is null))
        and ((state_rec.sta_information5 = p_sta_information5)
           or (state_rec.sta_information5 is null and
               p_sta_information5 is null))
        and ((state_rec.sta_information6 = p_sta_information6)
           or (state_rec.sta_information6 is null and
               p_sta_information6 is null))
        and ((state_rec.sta_information7 = p_sta_information7)
           or (state_rec.sta_information7 is null and
               p_sta_information7 is null))
        and ((state_rec.sta_information8 = p_sta_information8)
           or (state_rec.sta_information8 is null and
               p_sta_information8 is null))
        and ((state_rec.sta_information9 = p_sta_information9)
           or (state_rec.sta_information9 is null and
               p_sta_information9 is null))
        and ((state_rec.sta_information10 = p_sta_information10)
           or (state_rec.sta_information10 is null and
               p_sta_information10 is null))
        and ((state_rec.sta_information11 = p_sta_information11)
           or (state_rec.sta_information11 is null and
               p_sta_information11 is null))
        and ((state_rec.sta_information12 = p_sta_information12)
           or (state_rec.sta_information12 is null and
               p_sta_information12 is null))
        and ((state_rec.sta_information13 = p_sta_information13)
           or (state_rec.sta_information13 is null and
               p_sta_information13 is null))
        and ((state_rec.sta_information14 = p_sta_information14)
           or (state_rec.sta_information14 is null and
               p_sta_information14 is null))
        and ((state_rec.sta_information15 = p_sta_information15)
           or (state_rec.sta_information15 is null and
               p_sta_information15 is null))
        and ((state_rec.sta_information16 = p_sta_information16)
           or (state_rec.sta_information16 is null and
               p_sta_information16 is null))
        and ((state_rec.sta_information17 = p_sta_information17)
           or (state_rec.sta_information17 is null and
               p_sta_information17 is null))
        and ((state_rec.sta_information18 = p_sta_information18)
           or (state_rec.sta_information18 is null and
               p_sta_information18 is null))
        and ((state_rec.sta_information19 = p_sta_information19)
           or (state_rec.sta_information19 is null and
               p_sta_information19 is null))
        and ((state_rec.sta_information20 = p_sta_information20)
           or (state_rec.sta_information20 is null and
               p_sta_information20 is null))
        and ((state_rec.sta_information21 = p_sta_information21)
           or (state_rec.sta_information21 is null and
               p_sta_information21 is null))
        and ((state_rec.sta_information22 = p_sta_information22)
           or (state_rec.sta_information22 is null and
               p_sta_information22 is null))
        and ((state_rec.sta_information23 = p_sta_information23)
           or (state_rec.sta_information23 is null and
               p_sta_information23 is null))
        and ((state_rec.sta_information24 = p_sta_information24)
           or (state_rec.sta_information24 is null and
               p_sta_information24 is null))
        and ((state_rec.sta_information25 = p_sta_information25)
           or (state_rec.sta_information25 is null and
               p_sta_information25 is null))
        and ((state_rec.sta_information26 = p_sta_information26)
           or (state_rec.sta_information26 is null and
               p_sta_information26 is null))
        and ((state_rec.sta_information27 = p_sta_information27)
           or (state_rec.sta_information27 is null and
               p_sta_information27 is null))
        and ((state_rec.sta_information28 = p_sta_information28)
           or (state_rec.sta_information28 is null and
               p_sta_information28 is null))
        and ((state_rec.sta_information29 = p_sta_information29)
           or (state_rec.sta_information29 is null and
               p_sta_information29 is null))
        and ((state_rec.sta_information30 = p_sta_information30)
           or (state_rec.sta_information30 is null and
               p_sta_information30 is null))
     then

      return;

     else

        fnd_message.set_name('PAY', 'FORM_RECORD_CHANGED');
        fnd_message.raise_error;

  end if;

  end lock_state_tax_row;


  /* Name        : lock_county_tax_row
     Purpose     : To lock the county tax rule record.
  */

  procedure lock_county_tax_row ( p_row_id in varchar2,
                                    p_emp_county_tax_rule_id in number,
                                    p_effective_start_date in date,
                                    p_effective_end_date in date,
                                    p_assignment_id in number,
                                    p_state_code in varchar2,
                                    p_county_code in varchar2,
                                    p_business_group_id in number,
                                    p_additional_wa_rate in number,
                                    p_filing_status_code in varchar2,
                                    p_jurisdiction_code in varchar2,
                                    p_lit_additional_tax in number,
                                    p_lit_override_amount in number,
                                    p_lit_override_rate in number,
                                    p_withholding_allowances in number,
                                    p_lit_exempt in varchar2,
                                    p_sd_exempt in varchar2,
                                    p_ht_exempt in varchar2,
                                    p_wage_exempt in varchar2,
                                    p_school_district_code in varchar2,
                                    p_attribute_category        in varchar2,
                                    p_attribute1                in varchar2,
                                    p_attribute2                in varchar2,
                                    p_attribute3                in varchar2,
                                    p_attribute4                in varchar2,
                                    p_attribute5                in varchar2,
                                    p_attribute6                in varchar2,
                                    p_attribute7                in varchar2,
                                    p_attribute8                in varchar2,
                                    p_attribute9                in varchar2,
                                    p_attribute10               in varchar2,
                                    p_attribute11               in varchar2,
                                    p_attribute12               in varchar2,
                                    p_attribute13               in varchar2,
                                    p_attribute14               in varchar2,
                                    p_attribute15               in varchar2,
                                    p_attribute16               in varchar2,
                                    p_attribute17               in varchar2,
                                    p_attribute18               in varchar2,
                                    p_attribute19               in varchar2,
                                    p_attribute20               in varchar2,
                                    p_attribute21               in varchar2,
                                    p_attribute22               in varchar2,
                                    p_attribute23               in varchar2,
                                    p_attribute24               in varchar2,
                                    p_attribute25               in varchar2,
                                    p_attribute26               in varchar2,
                                    p_attribute27               in varchar2,
                                    p_attribute28               in varchar2,
                                    p_attribute29               in varchar2,
                                    p_attribute30               in varchar2,
                                    p_cnt_information_category  in varchar2,
                                    p_cnt_information1          in varchar2,
                                    p_cnt_information2          in varchar2,
                                    p_cnt_information3          in varchar2,
                                    p_cnt_information4          in varchar2,
                                    p_cnt_information5          in varchar2,
                                    p_cnt_information6          in varchar2,
                                    p_cnt_information7          in varchar2,
                                    p_cnt_information8          in varchar2,
                                    p_cnt_information9          in varchar2,
                                    p_cnt_information10         in varchar2,
                                    p_cnt_information11         in varchar2,
                                    p_cnt_information12         in varchar2,
                                    p_cnt_information13         in varchar2,
                                    p_cnt_information14         in varchar2,
                                    p_cnt_information15         in varchar2,
                                    p_cnt_information16         in varchar2,
                                    p_cnt_information17         in varchar2,
                                    p_cnt_information18         in varchar2,
                                    p_cnt_information19         in varchar2,
                                    p_cnt_information20         in varchar2,
                                    p_cnt_information21         in varchar2,
                                    p_cnt_information22         in varchar2,
                                    p_cnt_information23         in varchar2,
                                    p_cnt_information24         in varchar2,
                                    p_cnt_information25         in varchar2,
                                    p_cnt_information26         in varchar2,
                                    p_cnt_information27         in varchar2,
                                    p_cnt_information28         in varchar2,
                                    p_cnt_information29         in varchar2,
                                    p_cnt_information30         in varchar2  ) is

  cursor csr_asg_rec is
  select assignment_id
  from   PER_ASSIGNMENTS_F
  where  assignment_id = p_assignment_id
  and    p_effective_start_date between effective_start_date
         and effective_end_date
  for update of assignment_id nowait;


  cursor csr_county_rec is
  select *
  from   PAY_US_EMP_COUNTY_TAX_RULES_F
  where  rowid = chartorowid(p_row_id)
  for update of emp_county_tax_rule_id nowait;

  county_rec csr_county_rec%rowtype;
  l_assignment_id      number(9);

  begin

     open csr_asg_rec;

     fetch csr_asg_rec into l_assignment_id;

     if csr_asg_rec%NOTFOUND then
        close  csr_asg_rec;
        fnd_message.set_name('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
        fnd_message.raise_error;
     end if;

     close csr_asg_rec;

     open csr_county_rec;

     fetch csr_county_rec into county_rec;

     if csr_county_rec%NOTFOUND then
        close  csr_county_rec;
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE',
        'pay_us_emp_dt_tax_rules.lock_county_tax_row');
        fnd_message.set_token('STEP', '1');
        fnd_message.raise_error;
     end if;

     close  csr_county_rec;

      county_rec.state_code          := rtrim(county_rec.state_code);
      county_rec.county_code         := rtrim(county_rec.county_code);
      county_rec.filing_status_code  := rtrim(county_rec.filing_status_code);
      county_rec.jurisdiction_code   := rtrim(county_rec.jurisdiction_code);
      county_rec.lit_exempt          := rtrim(county_rec.lit_exempt);
      county_rec.sd_exempt            := rtrim(county_rec.sd_exempt);
      county_rec.ht_exempt           := rtrim(county_rec.ht_exempt);
      county_rec.wage_exempt         := rtrim(county_rec.wage_exempt);
      county_rec.school_district_code := rtrim(county_rec.school_district_code);
      county_rec.attribute_category   := rtrim(county_rec.attribute_category);
      county_rec.attribute1           := rtrim(county_rec.attribute1);
      county_rec.attribute2           := rtrim(county_rec.attribute2);
      county_rec.attribute3           := rtrim(county_rec.attribute3);
      county_rec.attribute4           := rtrim(county_rec.attribute4);
      county_rec.attribute5           := rtrim(county_rec.attribute5);
      county_rec.attribute6           := rtrim(county_rec.attribute6);
      county_rec.attribute7           := rtrim(county_rec.attribute7);
      county_rec.attribute8           := rtrim(county_rec.attribute8);
      county_rec.attribute9           := rtrim(county_rec.attribute9);
      county_rec.attribute10          := rtrim(county_rec.attribute10);
      county_rec.attribute11          := rtrim(county_rec.attribute11);
      county_rec.attribute12          := rtrim(county_rec.attribute12);
      county_rec.attribute13          := rtrim(county_rec.attribute13);
      county_rec.attribute14          := rtrim(county_rec.attribute14);
      county_rec.attribute15          := rtrim(county_rec.attribute15);
      county_rec.attribute16          := rtrim(county_rec.attribute16);
      county_rec.attribute17          := rtrim(county_rec.attribute17);
      county_rec.attribute18          := rtrim(county_rec.attribute18);
      county_rec.attribute19          := rtrim(county_rec.attribute19);
      county_rec.attribute20          := rtrim(county_rec.attribute20);
      county_rec.attribute21          := rtrim(county_rec.attribute21);
      county_rec.attribute22          := rtrim(county_rec.attribute22);
      county_rec.attribute23          := rtrim(county_rec.attribute23);
      county_rec.attribute24          := rtrim(county_rec.attribute24);
      county_rec.attribute25          := rtrim(county_rec.attribute25);
      county_rec.attribute26          := rtrim(county_rec.attribute26);
      county_rec.attribute27          := rtrim(county_rec.attribute27);
      county_rec.attribute28          := rtrim(county_rec.attribute28);
      county_rec.attribute29          := rtrim(county_rec.attribute29);
      county_rec.attribute30          := rtrim(county_rec.attribute30);
      county_rec.cnt_information_category   := rtrim(county_rec.cnt_information_category);
      county_rec.cnt_information1     := rtrim(county_rec.cnt_information1);
      county_rec.cnt_information2     := rtrim(county_rec.cnt_information2);
      county_rec.cnt_information3     := rtrim(county_rec.cnt_information3);
      county_rec.cnt_information4     := rtrim(county_rec.cnt_information4);
      county_rec.cnt_information5     := rtrim(county_rec.cnt_information5);
      county_rec.cnt_information6     := rtrim(county_rec.cnt_information6);
      county_rec.cnt_information7     := rtrim(county_rec.cnt_information7);
      county_rec.cnt_information8     := rtrim(county_rec.cnt_information8);
      county_rec.cnt_information9     := rtrim(county_rec.cnt_information9);
      county_rec.cnt_information10    := rtrim(county_rec.cnt_information10);
      county_rec.cnt_information11    := rtrim(county_rec.cnt_information11);
      county_rec.cnt_information12    := rtrim(county_rec.cnt_information12);
      county_rec.cnt_information13    := rtrim(county_rec.cnt_information13);
      county_rec.cnt_information14    := rtrim(county_rec.cnt_information14);
      county_rec.cnt_information15    := rtrim(county_rec.cnt_information15);
      county_rec.cnt_information16    := rtrim(county_rec.cnt_information16);
      county_rec.cnt_information17    := rtrim(county_rec.cnt_information17);
      county_rec.cnt_information18    := rtrim(county_rec.cnt_information18);
      county_rec.cnt_information19    := rtrim(county_rec.cnt_information19);
      county_rec.cnt_information20    := rtrim(county_rec.cnt_information20);
      county_rec.cnt_information21    := rtrim(county_rec.cnt_information21);
      county_rec.cnt_information22    := rtrim(county_rec.cnt_information22);
      county_rec.cnt_information23    := rtrim(county_rec.cnt_information23);
      county_rec.cnt_information24    := rtrim(county_rec.cnt_information24);
      county_rec.cnt_information25    := rtrim(county_rec.cnt_information25);
      county_rec.cnt_information26    := rtrim(county_rec.cnt_information26);
      county_rec.cnt_information27    := rtrim(county_rec.cnt_information27);
      county_rec.cnt_information28    := rtrim(county_rec.cnt_information28);
      county_rec.cnt_information29    := rtrim(county_rec.cnt_information29);
      county_rec.cnt_information30    := rtrim(county_rec.cnt_information30);


        if ((county_rec.emp_county_tax_rule_id = p_emp_county_tax_rule_id)
           or (county_rec.emp_county_tax_rule_id is null and
               p_emp_county_tax_rule_id is null))
        and ((county_rec.effective_start_date = p_effective_start_date)
           or (county_rec.effective_start_date is null and
               p_effective_start_date is null))
        and ((county_rec.effective_end_date = p_effective_end_date)
           or (county_rec.effective_end_date is null and
               p_effective_end_date is null))
        and ((county_rec.assignment_id = p_assignment_id)
           or (county_rec.assignment_id is null and
               p_assignment_id is null))
        and ((county_rec.state_code = p_state_code)
           or (county_rec.state_code is null and
               p_state_code is null))
        and ((county_rec.county_code = p_county_code)
           or (county_rec.county_code is null and
               p_county_code is null))
        and ((county_rec.business_group_id = p_business_group_id)
           or (county_rec.business_group_id is null and
               p_business_group_id is null))
        and ((county_rec.additional_wa_rate = p_additional_wa_rate)
           or (county_rec.additional_wa_rate is null and
               p_additional_wa_rate is null))
        and ((county_rec.filing_status_code = lpad(p_filing_status_code,2,'0'))
           or (county_rec.filing_status_code is null and
               p_filing_status_code is null))
        and ((county_rec.jurisdiction_code = p_jurisdiction_code)
           or (county_rec.jurisdiction_code is null and
               p_jurisdiction_code is null))
        and ((county_rec.lit_additional_tax = p_lit_additional_tax)
           or (county_rec.lit_additional_tax is null and
               p_lit_additional_tax is null))
        and ((county_rec.lit_override_amount = p_lit_override_amount)
           or (county_rec.lit_override_amount is null and
               p_lit_override_amount is null))
        and ((county_rec.lit_override_rate = p_lit_override_rate)
           or (county_rec.lit_override_rate is null and
               p_lit_override_rate is null))
        and ((county_rec.withholding_allowances = p_withholding_allowances)
           or (county_rec.withholding_allowances is null and
               p_withholding_allowances is null))
        and ((county_rec.lit_exempt = p_lit_exempt)
           or (county_rec.lit_exempt is null and
               p_lit_exempt is null))
        and ((county_rec.sd_exempt = p_sd_exempt)
           or (county_rec.sd_exempt is null and
               p_sd_exempt is null))
        and ((county_rec.ht_exempt = p_ht_exempt)
           or (county_rec.ht_exempt is null and
               p_ht_exempt is null))
        and ((county_rec.wage_exempt = p_wage_exempt)
           or (county_rec.wage_exempt is null and
               p_wage_exempt is null))
        and ((county_rec.school_district_code = p_school_district_code)
           or (county_rec.school_district_code is null and
               p_school_district_code is null))
        and ((county_rec.attribute_category = p_attribute_category)
           or (county_rec.attribute_category is null and
               p_attribute_category is null))
        and ((county_rec.attribute1 = p_attribute1)
           or (county_rec.attribute1 is null and
               p_attribute1 is null))
        and ((county_rec.attribute2 = p_attribute2)
           or (county_rec.attribute2 is null and
               p_attribute2 is null))
        and ((county_rec.attribute3 = p_attribute3)
           or (county_rec.attribute3 is null and
               p_attribute3 is null))
        and ((county_rec.attribute4 = p_attribute4)
           or (county_rec.attribute4 is null and
               p_attribute4 is null))
        and ((county_rec.attribute5 = p_attribute5)
           or (county_rec.attribute5 is null and
               p_attribute5 is null))
        and ((county_rec.attribute6 = p_attribute6)
           or (county_rec.attribute6 is null and
               p_attribute6 is null))
        and ((county_rec.attribute7 = p_attribute7)
           or (county_rec.attribute7 is null and
               p_attribute7 is null))
        and ((county_rec.attribute8 = p_attribute8)
           or (county_rec.attribute8 is null and
               p_attribute8 is null))
        and ((county_rec.attribute9 = p_attribute9)
           or (county_rec.attribute9 is null and
               p_attribute9 is null))
        and ((county_rec.attribute10 = p_attribute10)
           or (county_rec.attribute10 is null and
               p_attribute10 is null))
        and ((county_rec.attribute11 = p_attribute11)
           or (county_rec.attribute11 is null and
               p_attribute11 is null))
        and ((county_rec.attribute12 = p_attribute12)
           or (county_rec.attribute12 is null and
               p_attribute12 is null))
        and ((county_rec.attribute13 = p_attribute13)
           or (county_rec.attribute13 is null and
               p_attribute13 is null))
        and ((county_rec.attribute14 = p_attribute14)
           or (county_rec.attribute14 is null and
               p_attribute14 is null))
        and ((county_rec.attribute15 = p_attribute15)
           or (county_rec.attribute15 is null and
               p_attribute15 is null))
        and ((county_rec.attribute16 = p_attribute16)
           or (county_rec.attribute16 is null and
               p_attribute16 is null))
        and ((county_rec.attribute17 = p_attribute17)
           or (county_rec.attribute17 is null and
               p_attribute17 is null))
        and ((county_rec.attribute18 = p_attribute18)
           or (county_rec.attribute18 is null and
               p_attribute18 is null))
        and ((county_rec.attribute19 = p_attribute19)
           or (county_rec.attribute19 is null and
               p_attribute19 is null))
        and ((county_rec.attribute20 = p_attribute20)
           or (county_rec.attribute20 is null and
               p_attribute20 is null))
        and ((county_rec.attribute21 = p_attribute21)
           or (county_rec.attribute21 is null and
               p_attribute21 is null))
        and ((county_rec.attribute22 = p_attribute22)
           or (county_rec.attribute22 is null and
               p_attribute22 is null))
        and ((county_rec.attribute23 = p_attribute23)
           or (county_rec.attribute23 is null and
               p_attribute23 is null))
        and ((county_rec.attribute24 = p_attribute24)
           or (county_rec.attribute24 is null and
               p_attribute24 is null))
        and ((county_rec.attribute25 = p_attribute25)
           or (county_rec.attribute25 is null and
               p_attribute25 is null))
        and ((county_rec.attribute26 = p_attribute26)
           or (county_rec.attribute26 is null and
               p_attribute26 is null))
        and ((county_rec.attribute27 = p_attribute27)
           or (county_rec.attribute27 is null and
               p_attribute27 is null))
        and ((county_rec.attribute28 = p_attribute28)
           or (county_rec.attribute28 is null and
               p_attribute28 is null))
        and ((county_rec.attribute29 = p_attribute29)
           or (county_rec.attribute29 is null and
               p_attribute29 is null))
        and ((county_rec.attribute30 = p_attribute30)
           or (county_rec.attribute30 is null and
               p_attribute30 is null))
        and ((county_rec.cnt_information_category = p_cnt_information_category)
           or (county_rec.cnt_information_category is null and
               p_cnt_information_category is null))
        and ((county_rec.cnt_information1 = p_cnt_information1)
           or (county_rec.cnt_information1 is null and
               p_cnt_information1 is null))
        and ((county_rec.cnt_information2 = p_cnt_information2)
           or (county_rec.cnt_information2 is null and
               p_cnt_information2 is null))
        and ((county_rec.cnt_information3 = p_cnt_information3)
           or (county_rec.cnt_information3 is null and
               p_cnt_information3 is null))
        and ((county_rec.cnt_information4 = p_cnt_information4)
           or (county_rec.cnt_information4 is null and
               p_cnt_information4 is null))
        and ((county_rec.cnt_information5 = p_cnt_information5)
           or (county_rec.cnt_information5 is null and
               p_cnt_information5 is null))
        and ((county_rec.cnt_information6 = p_cnt_information6)
           or (county_rec.cnt_information6 is null and
               p_cnt_information6 is null))
        and ((county_rec.cnt_information7 = p_cnt_information7)
           or (county_rec.cnt_information7 is null and
               p_cnt_information7 is null))
        and ((county_rec.cnt_information8 = p_cnt_information8)
           or (county_rec.cnt_information8 is null and
               p_cnt_information8 is null))
        and ((county_rec.cnt_information9 = p_cnt_information9)
           or (county_rec.cnt_information9 is null and
               p_cnt_information9 is null))
        and ((county_rec.cnt_information10 = p_cnt_information10)
           or (county_rec.cnt_information10 is null and
               p_cnt_information10 is null))
        and ((county_rec.cnt_information11 = p_cnt_information11)
           or (county_rec.cnt_information11 is null and
               p_cnt_information11 is null))
        and ((county_rec.cnt_information12 = p_cnt_information12)
           or (county_rec.cnt_information12 is null and
               p_cnt_information12 is null))
        and ((county_rec.cnt_information13 = p_cnt_information13)
           or (county_rec.cnt_information13 is null and
               p_cnt_information13 is null))
        and ((county_rec.cnt_information14 = p_cnt_information14)
           or (county_rec.cnt_information14 is null and
               p_cnt_information14 is null))
        and ((county_rec.cnt_information15 = p_cnt_information15)
           or (county_rec.cnt_information15 is null and
               p_cnt_information15 is null))
        and ((county_rec.cnt_information16 = p_cnt_information16)
           or (county_rec.cnt_information16 is null and
               p_cnt_information16 is null))
        and ((county_rec.cnt_information17 = p_cnt_information17)
           or (county_rec.cnt_information17 is null and
               p_cnt_information17 is null))
        and ((county_rec.cnt_information18 = p_cnt_information18)
           or (county_rec.cnt_information18 is null and
               p_cnt_information18 is null))
        and ((county_rec.cnt_information19 = p_cnt_information19)
           or (county_rec.cnt_information19 is null and
               p_cnt_information19 is null))
        and ((county_rec.cnt_information20 = p_cnt_information20)
           or (county_rec.cnt_information20 is null and
               p_cnt_information20 is null))
        and ((county_rec.cnt_information21 = p_cnt_information21)
           or (county_rec.cnt_information21 is null and
               p_cnt_information21 is null))
        and ((county_rec.cnt_information22 = p_cnt_information22)
           or (county_rec.cnt_information22 is null and
               p_cnt_information22 is null))
        and ((county_rec.cnt_information23 = p_cnt_information23)
           or (county_rec.cnt_information23 is null and
               p_cnt_information23 is null))
        and ((county_rec.cnt_information24 = p_cnt_information24)
           or (county_rec.cnt_information24 is null and
               p_cnt_information24 is null))
        and ((county_rec.cnt_information25 = p_cnt_information25)
           or (county_rec.cnt_information25 is null and
               p_cnt_information25 is null))
        and ((county_rec.cnt_information26 = p_cnt_information26)
           or (county_rec.cnt_information26 is null and
               p_cnt_information26 is null))
        and ((county_rec.cnt_information27 = p_cnt_information27)
           or (county_rec.cnt_information27 is null and
               p_cnt_information27 is null))
        and ((county_rec.cnt_information28 = p_cnt_information28)
           or (county_rec.cnt_information28 is null and
               p_cnt_information28 is null))
        and ((county_rec.cnt_information29 = p_cnt_information29)
           or (county_rec.cnt_information29 is null and
               p_cnt_information29 is null))
        and ((county_rec.cnt_information30 = p_cnt_information30)
           or (county_rec.cnt_information30 is null and
               p_cnt_information30 is null))
     then

      return;

     else

        fnd_message.set_name('PAY', 'FORM_RECORD_CHANGED');
        fnd_message.raise_error;

     end if;

  end lock_county_tax_row;


  /* Name        : lock_city_tax_row
     Purpose     : To lock the city tax rule record.
  */

  procedure lock_city_tax_row ( p_row_id in varchar2,
                                  p_emp_city_tax_rule_id in number,
                                  p_effective_start_date in date,
                                  p_effective_end_date in date,
                                  p_assignment_id in number,
                                  p_state_code in varchar2,
                                  p_county_code in varchar2,
                                  p_city_code in varchar2,
                                  p_business_group_id in number,
                                  p_additional_wa_rate in number,
                                  p_filing_status_code in varchar2,
                                  p_jurisdiction_code in varchar2,
                                  p_lit_additional_tax in number,
                                  p_lit_override_amount in number,
                                  p_lit_override_rate in number,
                                  p_withholding_allowances in number,
                                  p_lit_exempt in varchar2,
                                  p_sd_exempt in varchar2,
                                  p_ht_exempt in varchar2,
                                  p_wage_exempt in varchar2,
                                  p_school_district_code in varchar2,
                                  p_attribute_category        in varchar2,
                                  p_attribute1                in varchar2,
                                  p_attribute2                in varchar2,
                                  p_attribute3                in varchar2,
                                  p_attribute4                in varchar2,
                                  p_attribute5                in varchar2,
                                  p_attribute6                in varchar2,
                                  p_attribute7                in varchar2,
                                  p_attribute8                in varchar2,
                                  p_attribute9                in varchar2,
                                  p_attribute10               in varchar2,
                                  p_attribute11               in varchar2,
                                  p_attribute12               in varchar2,
                                  p_attribute13               in varchar2,
                                  p_attribute14               in varchar2,
                                  p_attribute15               in varchar2,
                                  p_attribute16               in varchar2,
                                  p_attribute17               in varchar2,
                                  p_attribute18               in varchar2,
                                  p_attribute19               in varchar2,
                                  p_attribute20               in varchar2,
                                  p_attribute21               in varchar2,
                                  p_attribute22               in varchar2,
                                  p_attribute23               in varchar2,
                                  p_attribute24               in varchar2,
                                  p_attribute25               in varchar2,
                                  p_attribute26               in varchar2,
                                  p_attribute27               in varchar2,
                                  p_attribute28               in varchar2,
                                  p_attribute29               in varchar2,
                                  p_attribute30               in varchar2,
                                  p_cty_information_category  in varchar2,
                                  p_cty_information1          in varchar2,
                                  p_cty_information2          in varchar2,
                                  p_cty_information3          in varchar2,
                                  p_cty_information4          in varchar2,
                                  p_cty_information5          in varchar2,
                                  p_cty_information6          in varchar2,
                                  p_cty_information7          in varchar2,
                                  p_cty_information8          in varchar2,
                                  p_cty_information9          in varchar2,
                                  p_cty_information10         in varchar2,
                                  p_cty_information11         in varchar2,
                                  p_cty_information12         in varchar2,
                                  p_cty_information13         in varchar2,
                                  p_cty_information14         in varchar2,
                                  p_cty_information15         in varchar2,
                                  p_cty_information16         in varchar2,
                                  p_cty_information17         in varchar2,
                                  p_cty_information18         in varchar2,
                                  p_cty_information19         in varchar2,
                                  p_cty_information20         in varchar2,
                                  p_cty_information21         in varchar2,
                                  p_cty_information22         in varchar2,
                                  p_cty_information23         in varchar2,
                                  p_cty_information24         in varchar2,
                                  p_cty_information25         in varchar2,
                                  p_cty_information26         in varchar2,
                                  p_cty_information27         in varchar2,
                                  p_cty_information28         in varchar2,
                                  p_cty_information29         in varchar2,
                                  p_cty_information30         in varchar2  ) is


  cursor csr_asg_rec is
  select assignment_id
  from   PER_ASSIGNMENTS_F
  where  assignment_id = p_assignment_id
  and    p_effective_start_date between effective_start_date
         and effective_end_date
  for update of assignment_id nowait;


  cursor csr_city_rec is
  select *
  from   PAY_US_EMP_CITY_TAX_RULES_F
  where  rowid = chartorowid(p_row_id)
  for update of emp_city_tax_rule_id nowait;

  city_rec csr_city_rec%rowtype;
  l_assignment_id      number(9);

  begin

     open csr_asg_rec;

     fetch csr_asg_rec into l_assignment_id;

     if csr_asg_rec%NOTFOUND then
        close  csr_asg_rec;
        fnd_message.set_name('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
        fnd_message.raise_error;
     end if;

     close csr_asg_rec;

     open csr_city_rec;

     fetch csr_city_rec into city_rec;

     if csr_city_rec%NOTFOUND then
        close  csr_city_rec;
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE',
        'pay_us_emp_dt_tax_rules.lock_city_tax_row');
        fnd_message.set_token('STEP', '1');
        fnd_message.raise_error;
     end if;

     close  csr_city_rec;

      city_rec.state_code           := rtrim(city_rec.state_code);
      city_rec.county_code          := rtrim(city_rec.county_code);
      city_rec.city_code            := rtrim(city_rec.city_code);
      city_rec.filing_status_code   := rtrim(city_rec.filing_status_code);
      city_rec.jurisdiction_code    := rtrim(city_rec.jurisdiction_code);
      city_rec.lit_exempt           := rtrim(city_rec.lit_exempt);
      city_rec.sd_exempt            := rtrim(city_rec.sd_exempt);
      city_rec.ht_exempt            := rtrim(city_rec.ht_exempt);
      city_rec.wage_exempt          := rtrim(city_rec.wage_exempt);
      city_rec.school_district_code := rtrim(city_rec.school_district_code);
      city_rec.attribute_category   := rtrim(city_rec.attribute_category);
      city_rec.attribute1           := rtrim(city_rec.attribute1);
      city_rec.attribute2           := rtrim(city_rec.attribute2);
      city_rec.attribute3           := rtrim(city_rec.attribute3);
      city_rec.attribute4           := rtrim(city_rec.attribute4);
      city_rec.attribute5           := rtrim(city_rec.attribute5);
      city_rec.attribute6           := rtrim(city_rec.attribute6);
      city_rec.attribute7           := rtrim(city_rec.attribute7);
      city_rec.attribute8           := rtrim(city_rec.attribute8);
      city_rec.attribute9           := rtrim(city_rec.attribute9);
      city_rec.attribute10          := rtrim(city_rec.attribute10);
      city_rec.attribute11          := rtrim(city_rec.attribute11);
      city_rec.attribute12          := rtrim(city_rec.attribute12);
      city_rec.attribute13          := rtrim(city_rec.attribute13);
      city_rec.attribute14          := rtrim(city_rec.attribute14);
      city_rec.attribute15          := rtrim(city_rec.attribute15);
      city_rec.attribute16          := rtrim(city_rec.attribute16);
      city_rec.attribute17          := rtrim(city_rec.attribute17);
      city_rec.attribute18          := rtrim(city_rec.attribute18);
      city_rec.attribute19          := rtrim(city_rec.attribute19);
      city_rec.attribute20          := rtrim(city_rec.attribute20);
      city_rec.attribute21          := rtrim(city_rec.attribute21);
      city_rec.attribute22          := rtrim(city_rec.attribute22);
      city_rec.attribute23          := rtrim(city_rec.attribute23);
      city_rec.attribute24          := rtrim(city_rec.attribute24);
      city_rec.attribute25          := rtrim(city_rec.attribute25);
      city_rec.attribute26          := rtrim(city_rec.attribute26);
      city_rec.attribute27          := rtrim(city_rec.attribute27);
      city_rec.attribute28          := rtrim(city_rec.attribute28);
      city_rec.attribute29          := rtrim(city_rec.attribute29);
      city_rec.attribute30          := rtrim(city_rec.attribute30);
      city_rec.cty_information_category   := rtrim(city_rec.cty_information_category);
      city_rec.cty_information1     := rtrim(city_rec.cty_information1);
      city_rec.cty_information2     := rtrim(city_rec.cty_information2);
      city_rec.cty_information3     := rtrim(city_rec.cty_information3);
      city_rec.cty_information4     := rtrim(city_rec.cty_information4);
      city_rec.cty_information5     := rtrim(city_rec.cty_information5);
      city_rec.cty_information6     := rtrim(city_rec.cty_information6);
      city_rec.cty_information7     := rtrim(city_rec.cty_information7);
      city_rec.cty_information8     := rtrim(city_rec.cty_information8);
      city_rec.cty_information9     := rtrim(city_rec.cty_information9);
      city_rec.cty_information10    := rtrim(city_rec.cty_information10);
      city_rec.cty_information11    := rtrim(city_rec.cty_information11);
      city_rec.cty_information12    := rtrim(city_rec.cty_information12);
      city_rec.cty_information13    := rtrim(city_rec.cty_information13);
      city_rec.cty_information14    := rtrim(city_rec.cty_information14);
      city_rec.cty_information15    := rtrim(city_rec.cty_information15);
      city_rec.cty_information16    := rtrim(city_rec.cty_information16);
      city_rec.cty_information17    := rtrim(city_rec.cty_information17);
      city_rec.cty_information18    := rtrim(city_rec.cty_information18);
      city_rec.cty_information19    := rtrim(city_rec.cty_information19);
      city_rec.cty_information20    := rtrim(city_rec.cty_information20);
      city_rec.cty_information21    := rtrim(city_rec.cty_information21);
      city_rec.cty_information22    := rtrim(city_rec.cty_information22);
      city_rec.cty_information23    := rtrim(city_rec.cty_information23);
      city_rec.cty_information24    := rtrim(city_rec.cty_information24);
      city_rec.cty_information25    := rtrim(city_rec.cty_information25);
      city_rec.cty_information26    := rtrim(city_rec.cty_information26);
      city_rec.cty_information27    := rtrim(city_rec.cty_information27);
      city_rec.cty_information28    := rtrim(city_rec.cty_information28);
      city_rec.cty_information29    := rtrim(city_rec.cty_information29);
      city_rec.cty_information30    := rtrim(city_rec.cty_information30);

        if ((city_rec.emp_city_tax_rule_id = p_emp_city_tax_rule_id)
           or (city_rec.emp_city_tax_rule_id is null and
               p_emp_city_tax_rule_id is null))
        and ((city_rec.effective_start_date = p_effective_start_date)
           or (city_rec.effective_start_date is null and
               p_effective_start_date is null))
        and ((city_rec.effective_end_date = p_effective_end_date)
           or (city_rec.effective_end_date is null and
               p_effective_end_date is null))
        and ((city_rec.assignment_id = p_assignment_id)
           or (city_rec.assignment_id is null and
               p_assignment_id is null))
        and ((city_rec.state_code = p_state_code)
           or (city_rec.state_code is null and
               p_state_code is null))
        and ((city_rec.county_code = p_county_code)
           or (city_rec.county_code is null and
               p_county_code is null))
        and ((city_rec.city_code = p_city_code)
           or (city_rec.city_code is null and
               p_city_code is null))
        and ((city_rec.business_group_id = p_business_group_id)
           or (city_rec.business_group_id is null and
               p_business_group_id is null))
        and ((city_rec.additional_wa_rate = p_additional_wa_rate)
           or (city_rec.additional_wa_rate is null and
               p_additional_wa_rate is null))
        and ((city_rec.filing_status_code = lpad(p_filing_status_code,2,'0'))
           or (city_rec.filing_status_code is null and
               p_filing_status_code is null))
        and ((city_rec.jurisdiction_code = p_jurisdiction_code)
           or (city_rec.jurisdiction_code is null and
               p_jurisdiction_code is null))
        and ((city_rec.lit_additional_tax = p_lit_additional_tax)
           or (city_rec.lit_additional_tax is null and
               p_lit_additional_tax is null))
        and ((city_rec.lit_override_amount = p_lit_override_amount)
           or (city_rec.lit_override_amount is null and
               p_lit_override_amount is null))
        and ((city_rec.lit_override_rate = p_lit_override_rate)
           or (city_rec.lit_override_rate is null and
               p_lit_override_rate is null))
        and ((city_rec.withholding_allowances = p_withholding_allowances)
           or (city_rec.withholding_allowances is null and
               p_withholding_allowances is null))
        and ((city_rec.lit_exempt = p_lit_exempt)
           or (city_rec.lit_exempt is null and
               p_lit_exempt is null))
        and ((city_rec.sd_exempt = p_sd_exempt)
           or (city_rec.sd_exempt is null and
               p_sd_exempt is null))
        and ((city_rec.ht_exempt = p_ht_exempt)
           or (city_rec.ht_exempt is null and
               p_ht_exempt is null))
        and ((city_rec.wage_exempt = p_wage_exempt)
           or (city_rec.wage_exempt is null and
               p_wage_exempt is null))
        and ((city_rec.school_district_code = p_school_district_code)
           or (city_rec.school_district_code is null and
               p_school_district_code is null))
        and ((city_rec.attribute_category = p_attribute_category)
           or (city_rec.attribute_category is null and
               p_attribute_category is null))
        and ((city_rec.attribute1 = p_attribute1)
           or (city_rec.attribute1 is null and
               p_attribute1 is null))
        and ((city_rec.attribute2 = p_attribute2)
           or (city_rec.attribute2 is null and
               p_attribute2 is null))
        and ((city_rec.attribute3 = p_attribute3)
           or (city_rec.attribute3 is null and
               p_attribute3 is null))
        and ((city_rec.attribute4 = p_attribute4)
           or (city_rec.attribute4 is null and
               p_attribute4 is null))
        and ((city_rec.attribute5 = p_attribute5)
           or (city_rec.attribute5 is null and
               p_attribute5 is null))
        and ((city_rec.attribute6 = p_attribute6)
           or (city_rec.attribute6 is null and
               p_attribute6 is null))
        and ((city_rec.attribute7 = p_attribute7)
           or (city_rec.attribute7 is null and
               p_attribute7 is null))
        and ((city_rec.attribute8 = p_attribute8)
           or (city_rec.attribute8 is null and
               p_attribute8 is null))
        and ((city_rec.attribute9 = p_attribute9)
           or (city_rec.attribute9 is null and
               p_attribute9 is null))
        and ((city_rec.attribute10 = p_attribute10)
           or (city_rec.attribute10 is null and
               p_attribute10 is null))
        and ((city_rec.attribute11 = p_attribute11)
           or (city_rec.attribute11 is null and
               p_attribute11 is null))
        and ((city_rec.attribute12 = p_attribute12)
           or (city_rec.attribute12 is null and
               p_attribute12 is null))
        and ((city_rec.attribute13 = p_attribute13)
           or (city_rec.attribute13 is null and
               p_attribute13 is null))
        and ((city_rec.attribute14 = p_attribute14)
           or (city_rec.attribute14 is null and
               p_attribute14 is null))
        and ((city_rec.attribute15 = p_attribute15)
           or (city_rec.attribute15 is null and
               p_attribute15 is null))
        and ((city_rec.attribute16 = p_attribute16)
           or (city_rec.attribute16 is null and
               p_attribute16 is null))
        and ((city_rec.attribute17 = p_attribute17)
           or (city_rec.attribute17 is null and
               p_attribute17 is null))
        and ((city_rec.attribute18 = p_attribute18)
           or (city_rec.attribute18 is null and
               p_attribute18 is null))
        and ((city_rec.attribute19 = p_attribute19)
           or (city_rec.attribute19 is null and
               p_attribute19 is null))
        and ((city_rec.attribute20 = p_attribute20)
           or (city_rec.attribute20 is null and
               p_attribute20 is null))
        and ((city_rec.attribute21 = p_attribute21)
           or (city_rec.attribute21 is null and
               p_attribute21 is null))
        and ((city_rec.attribute22 = p_attribute22)
           or (city_rec.attribute22 is null and
               p_attribute22 is null))
        and ((city_rec.attribute23 = p_attribute23)
           or (city_rec.attribute23 is null and
               p_attribute23 is null))
        and ((city_rec.attribute24 = p_attribute24)
           or (city_rec.attribute24 is null and
               p_attribute24 is null))
        and ((city_rec.attribute25 = p_attribute25)
           or (city_rec.attribute25 is null and
               p_attribute25 is null))
        and ((city_rec.attribute26 = p_attribute26)
           or (city_rec.attribute26 is null and
               p_attribute26 is null))
        and ((city_rec.attribute27 = p_attribute27)
           or (city_rec.attribute27 is null and
               p_attribute27 is null))
        and ((city_rec.attribute28 = p_attribute28)
           or (city_rec.attribute28 is null and
               p_attribute28 is null))
        and ((city_rec.attribute29 = p_attribute29)
           or (city_rec.attribute29 is null and
               p_attribute29 is null))
        and ((city_rec.attribute30 = p_attribute30)
           or (city_rec.attribute30 is null and
               p_attribute30 is null))
        and ((city_rec.cty_information_category = p_cty_information_category)
           or (city_rec.cty_information_category is null and
               p_cty_information_category is null))
        and ((city_rec.cty_information1 = p_cty_information1)
           or (city_rec.cty_information1 is null and
               p_cty_information1 is null))
        and ((city_rec.cty_information2 = p_cty_information2)
           or (city_rec.cty_information2 is null and
               p_cty_information2 is null))
        and ((city_rec.cty_information3 = p_cty_information3)
           or (city_rec.cty_information3 is null and
               p_cty_information3 is null))
        and ((city_rec.cty_information4 = p_cty_information4)
           or (city_rec.cty_information4 is null and
               p_cty_information4 is null))
        and ((city_rec.cty_information5 = p_cty_information5)
           or (city_rec.cty_information5 is null and
               p_cty_information5 is null))
        and ((city_rec.cty_information6 = p_cty_information6)
           or (city_rec.cty_information6 is null and
               p_cty_information6 is null))
        and ((city_rec.cty_information7 = p_cty_information7)
           or (city_rec.cty_information7 is null and
               p_cty_information7 is null))
        and ((city_rec.cty_information8 = p_cty_information8)
           or (city_rec.cty_information8 is null and
               p_cty_information8 is null))
        and ((city_rec.cty_information9 = p_cty_information9)
           or (city_rec.cty_information9 is null and
               p_cty_information9 is null))
        and ((city_rec.cty_information10 = p_cty_information10)
           or (city_rec.cty_information10 is null and
               p_cty_information10 is null))
        and ((city_rec.cty_information11 = p_cty_information11)
           or (city_rec.cty_information11 is null and
               p_cty_information11 is null))
        and ((city_rec.cty_information12 = p_cty_information12)
           or (city_rec.cty_information12 is null and
               p_cty_information12 is null))
        and ((city_rec.cty_information13 = p_cty_information13)
           or (city_rec.cty_information13 is null and
               p_cty_information13 is null))
        and ((city_rec.cty_information14 = p_cty_information14)
           or (city_rec.cty_information14 is null and
               p_cty_information14 is null))
        and ((city_rec.cty_information15 = p_cty_information15)
           or (city_rec.cty_information15 is null and
               p_cty_information15 is null))
        and ((city_rec.cty_information16 = p_cty_information16)
           or (city_rec.cty_information16 is null and
               p_cty_information16 is null))
        and ((city_rec.cty_information17 = p_cty_information17)
           or (city_rec.cty_information17 is null and
               p_cty_information17 is null))
        and ((city_rec.cty_information18 = p_cty_information18)
           or (city_rec.cty_information18 is null and
               p_cty_information18 is null))
        and ((city_rec.cty_information19 = p_cty_information19)
           or (city_rec.cty_information19 is null and
               p_cty_information19 is null))
        and ((city_rec.cty_information20 = p_cty_information20)
           or (city_rec.cty_information20 is null and
               p_cty_information20 is null))
        and ((city_rec.cty_information21 = p_cty_information21)
           or (city_rec.cty_information21 is null and
               p_cty_information21 is null))
        and ((city_rec.cty_information22 = p_cty_information22)
           or (city_rec.cty_information22 is null and
               p_cty_information22 is null))
        and ((city_rec.cty_information23 = p_cty_information23)
           or (city_rec.cty_information23 is null and
               p_cty_information23 is null))
        and ((city_rec.cty_information24 = p_cty_information24)
           or (city_rec.cty_information24 is null and
               p_cty_information24 is null))
        and ((city_rec.cty_information25 = p_cty_information25)
           or (city_rec.cty_information25 is null and
               p_cty_information25 is null))
        and ((city_rec.cty_information26 = p_cty_information26)
           or (city_rec.cty_information26 is null and
               p_cty_information26 is null))
        and ((city_rec.cty_information27 = p_cty_information27)
           or (city_rec.cty_information27 is null and
               p_cty_information27 is null))
        and ((city_rec.cty_information28 = p_cty_information28)
           or (city_rec.cty_information28 is null and
               p_cty_information28 is null))
        and ((city_rec.cty_information29 = p_cty_information29)
           or (city_rec.cty_information29 is null and
               p_cty_information29 is null))
        and ((city_rec.cty_information30 = p_cty_information30)
           or (city_rec.cty_information30 is null and
               p_cty_information30 is null))
     then

      return;

     else

        fnd_message.set_name('PAY', 'FORM_RECORD_CHANGED');
        fnd_message.raise_error;

  end if;

  end lock_city_tax_row;


function insert_def_fed_rec(p_assignment_id         number,
                            p_effective_start_date  date,
                            p_effective_end_date    date,
                            p_sui_state_code        varchar2,
                            p_business_group_id     number)
return number is

l_filing_status_code     varchar2(2);
l_eic_fstatus_code       varchar2(2);
l_emp_fed_tax_rule_id   number;
l_mode                  varchar2(30);

/* Get the Filing Status */
/*cursor csr_filing_status is
       select lookup_code
       from   HR_LOOKUPS
       where  lookup_type    = 'US_FIT_FILING_STATUS'
       and    upper(meaning) = 'SINGLE';
       */

cursor csr_filing_status is
       select lookup_code
       from   FND_LOOKUP_VALUES
       where  lookup_type    = 'US_FIT_FILING_STATUS'
       and    upper(meaning) = 'SINGLE'
       and    language = 'US';

/* Get EIC Filing Status */
/*CURSOR csr_eic_fstatus is
       select lookup_code
       from   hr_lookups
       where  lookup_type    = 'US_EIC_FILING_STATUS'
       and    upper(meaning) = 'NO EIC';
       */

CURSOR csr_eic_fstatus is
       select lookup_code
       from   fnd_lookup_values
       where  lookup_type    = 'US_EIC_FILING_STATUS'
       and    upper(meaning) = 'NO EIC'
       and    language = 'US';

begin

      /* Get Filing Status */
      hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_def_fed_rec',1);
     --dbms_output.put_line('asg** '||to_char(p_assignment_id));
     --dbms_output.put_line('sd** '||to_char(p_effective_start_date));
     --dbms_output.put_line('ed** '||to_char(p_effective_end_date));
     --dbms_output.put_line('sui** '||p_sui_state_code);
     --dbms_output.put_line('bg** ' || to_char(p_business_group_id));
      hr_utility.trace('insert_def_fed_rec** ' || to_char(p_assignment_id));
      hr_utility.trace('insert_def_fed_rec** ' || to_char(p_effective_start_date));
      hr_utility.trace('insert_def_fed_rec** ' || to_char(p_effective_end_date));
      hr_utility.trace('insert_def_fed_rec** ' || p_sui_state_code);
      hr_utility.trace('insert_def_fed_rec** ' || to_char(p_business_group_id));

      open  csr_filing_status;

      fetch csr_filing_status into l_filing_status_code;

      if csr_filing_status%NOTFOUND then
         fnd_message.set_name('PAY','HR_6091_DEF_MISSING_LOOKUPS');
         fnd_message.set_token('LOOKUP_TYPE ','US_FIT_FILING_STATUS');
         fnd_message.raise_error;
      end if;

      close csr_filing_status;

      /* Get EIC Filing Status */
      hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_def_fed_rec',2);

      open  csr_eic_fstatus;

      fetch csr_eic_fstatus into l_eic_fstatus_code;

      if csr_eic_fstatus%NOTFOUND then

         fnd_message.set_name('PAY','HR_6091_DEF_MISSING_LOOKUPS');
         fnd_message.set_token('LOOKUP_TYPE ','US_EIC_FILING_STATUS');
         fnd_message.raise_error;

      end if;

      close csr_eic_fstatus;

      /* Insert Federal Tax Record */

     hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_def_fed_rec',3);

     l_mode := 'INSERT';

     insert_fed_tax_row(p_emp_fed_tax_rule_id  => l_emp_fed_tax_rule_id,
                     p_effective_start_date  => p_effective_start_date,
                     p_effective_end_date    => p_effective_end_date,
                     p_assignment_id         => p_assignment_id,
                     p_sui_state_code        => p_sui_state_code,
                     p_sui_jurisdiction_code => p_sui_state_code || '-000-0000',
                     p_business_group_id     => p_business_group_id,
                     p_additional_wa_amount  => 0,
                     p_filing_status_code    => lpad(l_filing_status_code,2,'0'),
                     p_fit_override_amount   => 0,
                     p_fit_override_rate     => 0,
                     p_withholding_allowances => 0,
                     p_cumulative_taxation   => 'N',
                     p_eic_filing_status_code => l_eic_fstatus_code,
                     p_fit_additional_tax    => 0,
                     p_fit_exempt            => 'N',
                     p_futa_tax_exempt       => 'N',
                     p_medicare_tax_exempt   => 'N',
                     p_ss_tax_exempt         => 'N',
                     p_wage_exempt           => 'N',
                     p_statutory_employee    => 'N',
                     p_w2_filed_year         => null,
                     p_supp_tax_override_rate => 0,
                     p_excessive_wa_reject_date => null,
                     p_attribute_category        => null,
                     p_attribute1                => null,
                     p_attribute2                => null,
                     p_attribute3                => null,
                     p_attribute4                => null,
                     p_attribute5                => null,
                     p_attribute6                => null,
                     p_attribute7                => null,
                     p_attribute8                => null,
                     p_attribute9                => null,
                     p_attribute10               => null,
                     p_attribute11               => null,
                     p_attribute12               => null,
                     p_attribute13               => null,
                     p_attribute14               => null,
                     p_attribute15               => null,
                     p_attribute16               => null,
                     p_attribute17               => null,
                     p_attribute18               => null,
                     p_attribute19               => null,
                     p_attribute20               => null,
                     p_attribute21               => null,
                     p_attribute22               => null,
                     p_attribute23               => null,
                     p_attribute24               => null,
                     p_attribute25               => null,
                     p_attribute26               => null,
                     p_attribute27               => null,
                     p_attribute28               => null,
                     p_attribute29               => null,
                     p_attribute30               => null,
                     p_fed_information_category  => null,
                     p_fed_information1          => null,
                     p_fed_information2          => null,
                     p_fed_information3          => null,
                     p_fed_information4          => null,
                     p_fed_information5          => null,
                     p_fed_information6          => null,
                     p_fed_information7          => null,
                     p_fed_information8          => null,
                     p_fed_information9          => null,
                     p_fed_information10         => null,
                     p_fed_information11         => null,
                     p_fed_information12         => null,
                     p_fed_information13         => null,
                     p_fed_information14         => null,
                     p_fed_information15         => null,
                     p_fed_information16         => null,
                     p_fed_information17         => null,
                     p_fed_information18         => null,
                     p_fed_information19         => null,
                     p_fed_information20         => null,
                     p_fed_information21         => null,
                     p_fed_information22         => null,
                     p_fed_information23         => null,
                     p_fed_information24         => null,
                     p_fed_information25         => null,
                     p_fed_information26         => null,
                     p_fed_information27         => null,
                     p_fed_information28         => null,
                     p_fed_information29         => null,
                     p_fed_information30         => null,
                     p_mode                   => 'INSERT');

hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_def_fed_rec',5);

return l_emp_fed_tax_rule_id;

end  insert_def_fed_rec;


/*  Insert state record   */


function insert_def_state_rec(p_assignment_id        number,
                              p_effective_start_date date,
                              p_effective_end_date   date,
                              p_state_code           varchar2,
                              p_business_group_id    number,
                              p_percent_time         number)
return number is

l_emp_state_tax_rule_id       number;
l_filing_status_code          varchar2(30);
l_def_pref                    varchar2(30);
ln_asg_tax_unit_id            number;
l_allowances                  number;
l_row_id                      varchar2(30);

/* This cursor gets the filing status and exemptions from the federal record
   if needed */

/*
cursor csr_filing_status(p_assignment number, p_state varchar2) is
       select hrl.lookup_code, peft.withholding_allowances
       from   HR_LOOKUPS hrl
       ,      PAY_US_EMP_FED_TAX_RULES_V peft
       where  hrl.lookup_type    = 'US_FS_'||p_state
       and    upper(hrl.meaning) = decode(
              upper(substr(peft.filing_status,1,7)),
                           'MARRIED',
                           'MARRIED',
                           upper(peft.filing_status))
       and    peft.assignment_id = p_assignment ;
*/
cursor csr_filing_status(p_assignment number, p_state varchar2) is
       select flv.lookup_code, peft.withholding_allowances
       from   FND_LOOKUP_VALUES flv
       ,      PAY_US_EMP_FED_TAX_RULES_V peft
       where  flv.lookup_type    = 'US_FS_'||p_state
       and    upper(flv.meaning) = decode(
              upper(substr(peft.filing_status,1,7)),
                           'MARRIED',
                           'MARRIED',
                           upper(peft.filing_status))
       and    peft.assignment_id = p_assignment
       and    language = 'US' ;


cursor csr_get_asg_gre (p_assignment number)is
       select hsck.segment1
        from hr_soft_coding_keyflex hsck,
             per_assignments_f paf
       where paf.assignment_id = p_assignment
         and p_effective_start_date between paf.effective_start_date
                                        and paf.effective_end_date
         and paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id;

cursor csr_fed_or_def (p_tax_unit_id in number, p_state varchar2)is
       select hoi.org_information12
         from pay_us_states pus,
              hr_organization_information hoi
       where hoi.organization_id = p_tax_unit_id
         and hoi.org_information_context = 'State Tax Rules'
         and pus.state_code = p_state
         and hoi.org_information1 = pus.state_abbrev;


cursor chk_state_exists is
select 'Y'
from dual
where exists (select null
              from pay_us_emp_state_tax_rules_f pst
              where pst.assignment_id = p_assignment_id
              and   state_code = p_state_code
              and business_group_id + 0 = p_business_group_id);

l_flag varchar2(1) := 'N';

begin

  hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',1);

  open chk_state_exists;
  fetch chk_state_exists into l_flag;
  if chk_state_exists%NOTFOUND then
     l_flag := 'N';
  end if;
  close chk_state_exists;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',91);
  if l_flag = 'N'then
     open csr_get_asg_gre(p_assignment_id);
     fetch csr_get_asg_gre into ln_asg_tax_unit_id;
     close csr_get_asg_gre;

     open csr_fed_or_def(ln_asg_tax_unit_id, p_state_code);
     fetch csr_fed_or_def into l_def_pref;

     hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',2);

     if csr_fed_or_def%NOTFOUND then
        l_filing_status_code := '01';
        l_allowances := 0;
     end if;
     close csr_fed_or_def;

     hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',3);


     /* Bug 864068 - Added check for Connecticut (p_state_code = 07) to default
        the filing status for new Connecticut State Tax records to '07' instead
        of '01'; while '01' is single for most states and withholds state tax at
        the highest rate, '01' for Connecticut is married, with combined income
        less than $100,500 which isn't the highest tax rate. '07' is a new
        Vertex code for 'No Tax Form on File' which ensures withholding at
        the highest rate.
      */

     if p_state_code = '07' then
        hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',4);
        l_filing_status_code := '07';
        l_allowances         := 0;
    elsif p_state_code = '22' then   -- Bug No 4325326
        hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',4.4);
        l_filing_status_code := '04';
        l_allowances         := 0;
     elsif l_def_pref = 'SINGLE_ZERO' or l_def_pref is null then
        hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',5);
        l_filing_status_code := '01';
        l_allowances         := 0;
     elsif l_def_pref = 'FED_DEF' then
       hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',6);
       open  csr_filing_status(p_assignment_id, p_state_code);
       fetch csr_filing_status into l_filing_status_code, l_allowances;
       if csr_filing_status%NOTFOUND then
          hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',7);
          l_filing_status_code := '01';
          l_allowances := 0;
       end if;
       close csr_filing_status;

     end if;

  /* Insert State Tax record  */

  hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',8);

  insert_state_tax_row ( p_row_id                  => l_row_id,
                         p_emp_state_tax_rule_id  => l_emp_state_tax_rule_id,
                         p_effective_start_date    => p_effective_start_date,
                         p_effective_end_date      => p_effective_end_date,
                         p_assignment_id           => p_assignment_id,
                         p_state_code              => p_state_code,
                         p_jurisdiction_code       => p_state_code ||'-000-0000',
                         p_business_group_id       => p_business_group_id,
                         p_additional_wa_amount    => 0,
                         p_filing_status_code      => lpad(l_filing_status_code,2,'0'),
                         p_remainder_percent       => 0,
                         p_secondary_wa            => 0,
                         p_sit_additional_tax      => 0,
                         p_sit_override_amount     => 0,
                         p_sit_override_rate       => 0,
                         p_withholding_allowances  => l_allowances,
                         p_excessive_wa_reject_date => null,
                         p_sdi_exempt              => 'N',
                         p_sit_exempt              => 'N',
                         p_sit_optional_calc_ind   => null,
                         p_state_non_resident_cert => 'N',
                         p_sui_exempt              => 'N',
                         p_wc_exempt               => null,
                         p_wage_exempt             => 'N',
                         p_sui_wage_base_override_amt => null,
                         p_supp_tax_override_rate  => 0,
                         p_time_in_state           => nvl(p_percent_time,0),
                         p_attribute_category        => null,
                         p_attribute1                => null,
                         p_attribute2                => null,
                         p_attribute3                => null,
                         p_attribute4                => null,
                         p_attribute5                => null,
                         p_attribute6                => null,
                         p_attribute7                => null,
                         p_attribute8                => null,
                         p_attribute9                => null,
                         p_attribute10               => null,
                         p_attribute11               => null,
                         p_attribute12               => null,
                         p_attribute13               => null,
                         p_attribute14               => null,
                         p_attribute15               => null,
                         p_attribute16               => null,
                         p_attribute17               => null,
                         p_attribute18               => null,
                         p_attribute19               => null,
                         p_attribute20               => null,
                         p_attribute21               => null,
                         p_attribute22               => null,
                         p_attribute23               => null,
                         p_attribute24               => null,
                         p_attribute25               => null,
                         p_attribute26               => null,
                         p_attribute27               => null,
                         p_attribute28               => null,
                         p_attribute29               => null,
                         p_attribute30               => null,
                         p_sta_information_category  => null,
                         p_sta_information1          => null,
                         p_sta_information2          => null,
                         p_sta_information3          => null,
                         p_sta_information4          => null,
                         p_sta_information5          => null,
                         p_sta_information6          => null,
                         p_sta_information7          => null,
                         p_sta_information8          => null,
                         p_sta_information9          => null,
                         p_sta_information10         => null,
                         p_sta_information11         => null,
                         p_sta_information12         => null,
                         p_sta_information13         => null,
                         p_sta_information14         => null,
                         p_sta_information15         => null,
                         p_sta_information16         => null,
                         p_sta_information17         => null,
                         p_sta_information18         => null,
                         p_sta_information19         => null,
                         p_sta_information20         => null,
                         p_sta_information21         => null,
                         p_sta_information22         => null,
                         p_sta_information23         => null,
                         p_sta_information24         => null,
                         p_sta_information25         => null,
                         p_sta_information26         => null,
                         p_sta_information27         => null,
                         p_sta_information28         => null,
                         p_sta_information29         => null,
                         p_sta_information30         => null     );

  hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',9);

end if;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',10);

return l_emp_state_tax_rule_id;

end  insert_def_state_rec;


function insert_def_county_rec(p_assignment_id        number,
                               p_effective_start_date date,
                               p_effective_end_date   date,
                               p_state_code           varchar2,
                               p_county_code          varchar2,
                               p_business_group_id    number,
                               p_percent_time         number)
return number is

l_filing_status_code       varchar2(2);
l_emp_county_tax_rule_id   number;
l_row_id                   varchar2(30);

/*
cursor csr_filing_status is
       select lookup_code
       from   HR_LOOKUPS
       where  lookup_type    = 'US_LIT_FILING_STATUS'
       and    upper(meaning) = 'SINGLE';
*/

cursor csr_filing_status is
       select lookup_code
       from   FND_LOOKUP_VALUES
       where  lookup_type    = 'US_LIT_FILING_STATUS'
       and    upper(meaning) = 'SINGLE'
       and    language = 'US';

cursor chk_county_exists is
select 'Y'
from dual
where exists (select null
              from pay_us_emp_county_tax_rules_f pst
              where pst.assignment_id = p_assignment_id
              and   state_code = p_state_code
              and   county_code = p_county_code
              and business_group_id + 0 = p_business_group_id);

l_flag varchar2(1) := 'N';

begin

  hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_def_county_rec',1);

  open chk_county_exists;
  fetch chk_county_exists into l_flag;
  if chk_county_exists%NOTFOUND then
     l_flag := 'N';
  end if;
  close chk_county_exists;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_def_county_rec',91);

if l_flag = 'N' then

  open  csr_filing_status;

  fetch csr_filing_status into l_filing_status_code;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_def_county_rec',2);

  if csr_filing_status%NOTFOUND then

     fnd_message.set_name('PAY','HR_6091_DEF_MISSING_LOOKUPS');
     fnd_message.set_token('LOOKUP_TYPE ','US_LIT_FILING_STATUS');
     fnd_message.raise_error;

  end if;

  close csr_filing_status;

  /* Insert County Tax record */

  hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_def_county_rec',3);


  insert_county_tax_row(p_row_id                  => l_row_id,
                        p_emp_county_tax_rule_id  => l_emp_county_tax_rule_id,
                        p_effective_start_date    => p_effective_start_date,
                        p_effective_end_date      => p_effective_end_date,
                        p_assignment_id           => p_assignment_id,
                        p_state_code              => p_state_code,
                        p_county_code             => p_county_code,
                        p_business_group_id       => p_business_group_id,
                        p_additional_wa_rate      => 0,
                        p_filing_status_code      => lpad(l_filing_status_code,2,'0'),
                        p_jurisdiction_code       => p_state_code || '-' ||
                                                     p_county_code ||'-0000',
                        p_lit_additional_tax      => 0,
                        p_lit_override_amount     => 0,
                        p_lit_override_rate       => 0,
                        p_withholding_allowances  => 0,
                        p_lit_exempt              => 'N',
                        p_sd_exempt               => null,
                        p_ht_exempt               => null,
                        p_wage_exempt             => 'N',
                        p_school_district_code    => null,
                        p_time_in_county          => nvl(p_percent_time,0),
                        p_attribute_category        => null,
                        p_attribute1                => null,
                        p_attribute2                => null,
                        p_attribute3                => null,
                        p_attribute4                => null,
                        p_attribute5                => null,
                        p_attribute6                => null,
                        p_attribute7                => null,
                        p_attribute8                => null,
                        p_attribute9                => null,
                        p_attribute10               => null,
                        p_attribute11               => null,
                        p_attribute12               => null,
                        p_attribute13               => null,
                        p_attribute14               => null,
                        p_attribute15               => null,
                        p_attribute16               => null,
                        p_attribute17               => null,
                        p_attribute18               => null,
                        p_attribute19               => null,
                        p_attribute20               => null,
                        p_attribute21               => null,
                        p_attribute22               => null,
                        p_attribute23               => null,
                        p_attribute24               => null,
                        p_attribute25               => null,
                        p_attribute26               => null,
                        p_attribute27               => null,
                        p_attribute28               => null,
                        p_attribute29               => null,
                        p_attribute30               => null,
                        p_cnt_information_category  => null,
                        p_cnt_information1          => null,
                        p_cnt_information2          => null,
                        p_cnt_information3          => null,
                        p_cnt_information4          => null,
                        p_cnt_information5          => null,
                        p_cnt_information6          => null,
                        p_cnt_information7          => null,
                        p_cnt_information8          => null,
                        p_cnt_information9          => null,
                        p_cnt_information10         => null,
                        p_cnt_information11         => null,
                        p_cnt_information12         => null,
                        p_cnt_information13         => null,
                        p_cnt_information14         => null,
                        p_cnt_information15         => null,
                        p_cnt_information16         => null,
                        p_cnt_information17         => null,
                        p_cnt_information18         => null,
                        p_cnt_information19         => null,
                        p_cnt_information20         => null,
                        p_cnt_information21         => null,
                        p_cnt_information22         => null,
                        p_cnt_information23         => null,
                        p_cnt_information24         => null,
                        p_cnt_information25         => null,
                        p_cnt_information26         => null,
                        p_cnt_information27         => null,
                        p_cnt_information28         => null,
                        p_cnt_information29         => null,
                        p_cnt_information30         => null    );

  hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_def_county_rec',4);
end if;
  hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_def_county_rec',5);

return l_emp_county_tax_rule_id;

end  insert_def_county_rec;


function insert_def_city_rec(p_assignment_id        number,
                               p_effective_start_date date,
                               p_effective_end_date   date,
                               p_state_code           varchar2,
                               p_county_code          varchar2,
                               p_city_code            varchar2,
                               p_business_group_id    number,
                               p_percent_time       number)
return number is

l_filing_status_code       varchar2(2);
l_emp_city_tax_rule_id   number;
l_row_id                   varchar2(30);

/*
cursor csr_filing_status is
       select lookup_code
       from   HR_LOOKUPS
       where  lookup_type    = 'US_LIT_FILING_STATUS'
       and    upper(meaning) = 'SINGLE';
*/

cursor csr_filing_status is
       select lookup_code
       from   FND_LOOKUP_VALUES
       where  lookup_type    = 'US_LIT_FILING_STATUS'
       and    upper(meaning) = 'SINGLE'
       and    language = 'US';

cursor chk_city_exists is
select 'Y'
from dual
where exists (select null
              from pay_us_emp_city_tax_rules_f pst
              where pst.assignment_id = p_assignment_id
              and   state_code = p_state_code
              and   county_code = p_county_code
              and   city_code = p_city_code
              and business_group_id + 0 = p_business_group_id);

l_flag varchar2(1) := 'N';


begin

  hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_def_city_rec',1);

  open chk_city_exists;
  fetch chk_city_exists into l_flag;
  if chk_city_exists%NOTFOUND then
     l_flag := 'N';
  end if;
  close chk_city_exists;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_def_city_rec',91);

  if l_flag = 'N' then

  open  csr_filing_status;

  fetch csr_filing_status into l_filing_status_code;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_def_city_rec',2);

  if csr_filing_status%NOTFOUND then

     fnd_message.set_name('PAY','HR_6091_DEF_MISSING_LOOKUPS');
     fnd_message.set_token('LOOKUP_TYPE ','US_LIT_FILING_STATUS');
     fnd_message.raise_error;

  end if;

  close csr_filing_status;

  /* Insert City Tax record */

  hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_def_city_rec',3);


  insert_city_tax_row(p_row_id                  => l_row_id,
                        p_emp_city_tax_rule_id  => l_emp_city_tax_rule_id,
                        p_effective_start_date    => p_effective_start_date,
                        p_effective_end_date      => p_effective_end_date,
                        p_assignment_id           => p_assignment_id,
                        p_state_code              => p_state_code,
                        p_county_code             => p_county_code,
                        p_city_code               => p_city_code,
                        p_business_group_id       => p_business_group_id,
                        p_additional_wa_rate      => 0,
                        p_filing_status_code      => lpad(l_filing_status_code,2,'0'),
                        p_jurisdiction_code       => p_state_code || '-' ||
                                           p_county_code ||'-' || p_city_code,
                        p_lit_additional_tax      => 0,
                        p_lit_override_amount     => 0,
                        p_lit_override_rate       => 0,
                        p_withholding_allowances  => 0,
                        p_lit_exempt              => 'N',
                        p_sd_exempt               => null,
                        p_ht_exempt               => null,
                        p_wage_exempt             => 'N',
                        p_school_district_code    => null,
                        p_time_in_city            => nvl(p_percent_time,0),
                        p_attribute_category        => null,
                        p_attribute1                => null,
                        p_attribute2                => null,
                        p_attribute3                => null,
                        p_attribute4                => null,
                        p_attribute5                => null,
                        p_attribute6                => null,
                        p_attribute7                => null,
                        p_attribute8                => null,
                        p_attribute9                => null,
                        p_attribute10               => null,
                        p_attribute11               => null,
                        p_attribute12               => null,
                        p_attribute13               => null,
                        p_attribute14               => null,
                        p_attribute15               => null,
                        p_attribute16               => null,
                        p_attribute17               => null,
                        p_attribute18               => null,
                        p_attribute19               => null,
                        p_attribute20               => null,
                        p_attribute21               => null,
                        p_attribute22               => null,
                        p_attribute23               => null,
                        p_attribute24               => null,
                        p_attribute25               => null,
                        p_attribute26               => null,
                        p_attribute27               => null,
                        p_attribute28               => null,
                        p_attribute29               => null,
                        p_attribute30               => null,
                        p_cty_information_category  => null,
                        p_cty_information1          => null,
                        p_cty_information2          => null,
                        p_cty_information3          => null,
                        p_cty_information4          => null,
                        p_cty_information5          => null,
                        p_cty_information6          => null,
                        p_cty_information7          => null,
                        p_cty_information8          => null,
                        p_cty_information9          => null,
                        p_cty_information10         => null,
                        p_cty_information11         => null,
                        p_cty_information12         => null,
                        p_cty_information13         => null,
                        p_cty_information14         => null,
                        p_cty_information15         => null,
                        p_cty_information16         => null,
                        p_cty_information17         => null,
                        p_cty_information18         => null,
                        p_cty_information19         => null,
                        p_cty_information20         => null,
                        p_cty_information21         => null,
                        p_cty_information22         => null,
                        p_cty_information23         => null,
                        p_cty_information24         => null,
                        p_cty_information25         => null,
                        p_cty_information26         => null,
                        p_cty_information27         => null,
                        p_cty_information28         => null,
                        p_cty_information29         => null,
                        p_cty_information30         => null     );

  hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_def_city_rec',4);
end if;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.insert_def_city_rec',5);

return l_emp_city_tax_rule_id;

end  insert_def_city_rec;


/*    Name          : zero_out_time
      Purpose       : Zero out time in state and localities
                      in preparation for setting the city of
                      the new work location to 100%
*/

procedure zero_out_time(p_assignment_id         in number,
                        p_effective_start_date  in date,
                        p_effective_end_date    in date) is

l_jurisdiction_code     varchar2(11);
l_eff_start_date        date;

/* Cursor to retrieve the jurisdictions for all existing
   VERTEX element entries */

cursor csr_get_jurisdiction is
select peev.screen_entry_value jurisdiction,
       peef.effective_start_date start_date
  from  PAY_ELEMENT_ENTRY_VALUES_F peev,
        PAY_ELEMENT_ENTRIES_F peef,
        PAY_INPUT_VALUES_F piv,
        PAY_ELEMENT_TYPES_F pet
  where pet.element_name = 'VERTEX'
    and pet.element_type_id = piv.element_type_id
    and piv.name = 'Jurisdiction'
    and piv.input_value_id = 0 + peev.input_value_id
    and peev.element_entry_id = peef.element_entry_id
    and peev.effective_start_date = peef.effective_start_date
    and peev.effective_end_date = peef.effective_end_date
    and p_assignment_id = peef.assignment_id
    and peef.effective_start_date = p_effective_start_date
    and peef.effective_end_date   = p_effective_end_date
    and peef.effective_start_date between pet.effective_start_date and pet.effective_end_date; -- Bug 3354060 added to remove MJC between
                                                                                               -- PAY_INPUT_VALUES_F  and
                                                                                               -- PAY_ELEMENT_ENTRIES_F

begin

    hr_utility.set_location('pay_us_emp_dt_tax_rules.zero_out_time',1);

    open csr_get_jurisdiction;

    /* Now loop through all VERTEX element entries
       and set them to zero. */

    loop

       fetch csr_get_jurisdiction into l_jurisdiction_code,
                                       l_eff_start_date;

       exit when csr_get_jurisdiction%NOTFOUND;

       /* For the jurisdiction, set the %age time in that
          jurisdiction to zero */

       maintain_element_entry(
         p_assignment_id        => p_assignment_id,
         p_effective_start_date => p_effective_start_date,
         p_effective_end_date   => p_effective_end_date,
         p_session_date         => l_eff_start_date,
         p_jurisdiction_code    => l_jurisdiction_code,
         p_percentage_time      => 0,
         p_mode                 => 'CORRECTION');

     end loop;

     close csr_get_jurisdiction;

     hr_utility.set_location('pay_us_emp_dt_tax_rules.zero_out_time',2);

end zero_out_time;

/* Name    : set_sui_wage_base_override
   Purpose : To update sui_wage_base_override_amount for the new work location,
             with respect to every change in location state. The procedure
             will also take care of the condition of changing GRE when work
             location state remains unchanged / changed as well Rehire condition.
*/

procedure set_sui_wage_base_override(p_assignment_id    in number,
                                     p_state_code       in varchar2 default null,
				                     p_session_date     in date)
is

l_sui_er_wg_lt_curr_state  pay_us_state_tax_info_f.sui_er_wage_limit%type ;
l_max_asg_eff_st_dt        date ;
l_max_pact_dt              date ;
l_tax_unit_id              number ;
l_defined_balance_id       pay_defined_balances.defined_balance_id%type ;
l_balance_value            number ;
l_oth_combined_balance     number ;
l_combined_balance_value   number ;
l_sui_wg_base              number ;
l_jurisdiction_code        varchar2(11) ;
l_count                    number := 0 ;
l_rehired                  varchar2(1) := 'N' ;
l_actual_balance_value     number ;
l_person_id                number ;

cursor c_all_states(p_assignment_id in number,
		            p_session_date in date) is
     select state_code
     from   pay_us_emp_state_tax_rules_f
     where  assignment_id = p_assignment_id ;

cursor c_tax_unit_id(p_assignment_id in number,
                     p_session_date  in date) is
     select to_number(segment1) tax_unit_id
     from   hr_soft_coding_keyflex a,
            per_assignments_f  b
     where  b.assignment_id = p_assignment_id
     and    b.soft_coding_keyflex_id = a.soft_coding_keyflex_id
     and    p_session_date between b.effective_start_date and b.effective_end_date ;

cursor c_defined_balance_id(p_dbi_name in varchar2) is
     select fnd_number.canonical_to_number(UE.creator_id)
     from  ff_user_entities  UE,
           ff_database_items DI
     where  DI.user_name            = p_dbi_name --'SUI_ER_TAXABLE_PER_JD_GRE_YTD'
       and  UE.user_entity_id       = DI.user_entity_id
       and  Ue.creator_type         = 'B'
       and  UE.legislation_code     = 'US' ;

cursor c_max_asg_eff_st_date(p_assignment_id in number) is
      select max(effective_start_date)
      from   per_assignments_f paf,
             per_assignment_status_types past
      where  paf.assignment_id = p_assignment_id
      and    paf.assignment_status_type_id = past.assignment_status_type_id
      and    past.per_system_status = 'ACTIVE_ASSIGN'
      and   ((past.business_group_id is null
             and past.legislation_code is null)
             OR (past.business_group_id is null
                and past.legislation_code = 'US')
             OR (past.legislation_code is null
                 and exists
                    (select 'x'
                     from  per_assignments_f paf_i
                     where paf_i.assignment_id = p_assignment_id
                     and   paf_i.business_group_id = past.business_group_id)
                 )
             )
      and    paf.payroll_id is not null ;

cursor c_sui_wage_limit(p_state_code in varchar2, p_effective_date in date) is
      select sui_er_wage_limit
      from pay_us_state_tax_info_f
      where p_effective_date between effective_start_date
                                  and effective_end_date
        and sta_information_category = 'State tax limit rate info'
        and state_code = p_state_code ;

 Cursor c_max_pact_dt(p_assignment_id in number,
                      p_session_date in date) is
    select max(effective_date)
	from pay_payroll_actions ppa,
	     pay_assignment_actions paa,
	     per_assignments_f paf
	where paf.assignment_id = p_assignment_id
	and   paf.assignment_id = paa.assignment_id
	and   paa.payroll_action_id = ppa.payroll_action_id
	and   ppa.action_type in ('R','Q','B','V','I')
	and   nvl(ppa.date_earned,ppa.effective_date) between trunc(p_session_date,'Y')
	                         and last_day(add_months(trunc(p_session_date,'Y'),11)) ;

 Cursor c_ckeck_rehire(p_assignment_id in number,
                       p_session_date in date) is
        select 'Y'
        from per_assignments_f paf_o,
             per_assignment_status_types past
        where paf_o.assignment_id = p_assignment_id
         and  paf_o.assignment_status_type_id = past.assignment_status_type_id
         and  past.per_system_status = 'ACTIVE_ASSIGN'
         and  ((past.business_group_id is null
                and past.legislation_code is null)
                OR (past.business_group_id is null
                    and past.legislation_code = 'US')
                OR (past.legislation_code is null
                    and exists
                        (select 'x'
                         from  per_assignments_f paf_a
                         where paf_a.assignment_id = p_assignment_id
                         and   paf_a.business_group_id = past.business_group_id)
                    )
               )

        and   exists
       (
        select distinct paf_i.assignment_id
        from per_assignments_f paf_i,
             per_assignments_f paf_term
        where paf_i.person_id = paf_o.person_id
        and   paf_i.person_id = paf_term.person_id
        and   paf_i.assignment_id > paf_term.assignment_id
        and   paf_i.effective_start_date >= paf_term.effective_end_date
        and  ( trunc(paf_i.effective_end_date,'Y') = trunc(p_session_date,'Y')
              or (trunc(paf_i.effective_start_date,'Y') = trunc(p_session_date,'Y')
                 and trunc(paf_i.effective_end_date,'Y') > trunc(p_session_date,'Y')))
       ) ;

 Cursor c_get_person_id(p_assignment_id in number) is
        select distinct paf.person_id
        from per_assignments_f paf
        where paf.assignment_id = p_assignment_id ;

 Cursor c_get_all_assignments(p_person_id in number,
                              p_session_date in date) is
        select distinct paf.assignment_id
        from per_assignments_f paf
        where paf.person_id = p_person_id
        and  ( trunc(paf.effective_end_date,'Y') = trunc(p_session_date,'Y')
              or (trunc(paf.effective_start_date,'Y') = trunc(p_session_date,'Y')
                 and trunc(paf.effective_end_date,'Y') > trunc(p_session_date,'Y'))) ;


type state_code_typ is table of varchar2(2) index by BINARY_INTEGER ;
state_code_tab state_code_typ ;
type balance_typ is table of number index by BINARY_INTEGER ;
balance_tab   balance_typ ;
begin
    --hr_utility.trace_on(null,'pyusdtw4') ;

    hr_utility.trace('Entering pay_us_emp_dt_tax_rules.set_sui_wage_base_override.') ;
    hr_utility.trace('p_assignment_id := ' || to_char(p_assignment_id)) ;
    hr_utility.trace('p_state_code := ' || p_state_code) ;
    hr_utility.trace('p_session_date := ' || to_char(p_session_date)) ;

    l_balance_value := 0 ;
    l_combined_balance_value := 0 ;
    l_sui_wg_base := 0 ;
    l_actual_balance_value := 0 ;
    l_oth_combined_balance := 0 ;

     hr_utility.trace('Getting Effective Start Date of Latest Active Assignment.') ;
     open c_max_asg_eff_st_date(p_assignment_id) ;
     fetch c_max_asg_eff_st_date into l_max_asg_eff_st_dt ;
     if c_max_asg_eff_st_date%notfound then
        close c_max_asg_eff_st_date ;
	    raise hr_utility.hr_error ;
     end if ;
     hr_utility.trace('Effective Start Date of Latest Active Assignment: '|| to_char(l_max_asg_eff_st_dt)) ;

     hr_utility.trace('Getting Effective Date of Latest Payroll Action ID.') ;
     open c_max_pact_dt(p_assignment_id, p_session_date) ;
     fetch c_max_pact_dt into l_max_pact_dt ;
     if c_max_pact_dt%notfound then
        close c_max_pact_dt ;
	 raise hr_utility.hr_error ;
     end if ;
     hr_utility.trace('Effective Date of Latest Payroll Action ID: '|| to_char(l_max_pact_dt)) ;

     hr_utility.trace('Getting Defined Balance ID for SUI_ER_TAXABLE_PER_JD_GRE_YTD.') ;
     open c_defined_balance_id('SUI_ER_TAXABLE_PER_JD_GRE_YTD') ;
     fetch c_defined_balance_id into l_defined_balance_id ;
     if c_defined_balance_id%notfound then
        close c_defined_balance_id ;
        raise hr_utility.hr_error ;
     end if ;
     hr_utility.trace('Defined Balance ID for SUI_ER_TAXABLE_PER_JD_GRE_YTD: '|| to_char(l_defined_balance_id)) ;

     hr_utility.trace('Getting Tax Unit ID.') ;
     open c_tax_unit_id(p_assignment_id, p_session_date ) ;
     fetch c_tax_unit_id into l_tax_unit_id ;
     if c_tax_unit_id%notfound then
        close c_tax_unit_id ;
    	raise hr_utility.hr_error ;
     end if ;
     hr_utility.trace('Tax Unit ID: '|| to_char(l_tax_unit_id)) ;

     hr_utility.trace('Getting Person ID.') ;
     open c_get_person_id(p_assignment_id) ;
     fetch c_get_person_id into l_person_id ;
     if c_get_person_id%notfound then
        close c_get_person_id ;
        raise hr_utility.hr_error ;
     end if ;
     hr_utility.trace('Person ID: '|| to_char(l_person_id)) ;

     hr_utility.trace('p_state_code := '||p_state_code) ;
     hr_utility.trace('p_assignment_id..Original := '||to_char(p_assignment_id)) ;

     hr_utility.trace('Getting Rehire Y or N Flag.') ;
     open c_ckeck_rehire(p_assignment_id, p_session_date) ;
     fetch c_ckeck_rehire into l_rehired ;
     if c_ckeck_rehire%notfound then
        l_rehired := 'N' ;
        close c_ckeck_rehire ;
     end if ;
     hr_utility.trace('Rehire Flag Value: '|| l_rehired) ;

   IF nvl(l_rehired,'N') = 'Y' THEN
     l_count := 1 ;
     /* For Rehired Condition, iterating through all the assignments for the concerned person
        either active for the current year or was effective from earlier and terminated within the current year */
     for i_get_all_assignments in c_get_all_assignments(l_person_id,p_session_date)
     loop
        hr_utility.trace('l_person_id := '||to_char(l_person_id)) ;
        /* For each of the above-mentioned assignment iterating through all the states the employee worked on
           and populating PL/SQL table with the SUI ER Taxable Balance value and corresponding State Code */
        for i_all_states in c_all_states(i_get_all_assignments.assignment_id,p_session_date)
        loop
        IF i_all_states.state_code <> '24'  THEN

         state_code_tab(l_count) := i_all_states.state_code ;
         l_jurisdiction_code := i_all_states.state_code || '-000-0000' ;

         hr_utility.trace('l_count := '||to_char(l_count)) ;
         hr_utility.trace('i_get_all_assignments.assignment_id:= '||to_char(i_get_all_assignments.assignment_id)) ;
         hr_utility.trace('l_tax_unit_id := '||to_char(l_tax_unit_id)) ;
         hr_utility.trace('l_jurisdiction_code := '||l_jurisdiction_code) ;

         pay_balance_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id) ;
         pay_balance_pkg.set_context('JURISDICTION_CODE',l_jurisdiction_code) ;

         l_balance_value := pay_balance_pkg.get_value(
                               l_defined_balance_id ,
                               p_assignment_id,
                               nvl(l_max_pact_dt,GREATEST(l_max_asg_eff_st_dt,trunc(p_session_date,'Y')))) ;

         balance_tab(l_count) := l_balance_value ;

         hr_utility.trace('l_balance_value := '||to_char(l_balance_value)) ;
         /* Summing up the balance value */
         l_combined_balance_value := l_combined_balance_value + l_balance_value ;

         hr_utility.trace('l_combined_balance_value := '||to_char(l_combined_balance_value)) ;

         l_count := l_count + 1 ;
        END IF ;
        end loop ;
      end loop ;
      /* Eliminating the Duplicate 'State Code - Balance Value' combination and
         calculating the correct Summed up Balance value */
      IF state_code_tab.count <> 0 THEN
      for i in state_code_tab.first .. state_code_tab.last
      loop
          for j in 1 .. i-1
          loop
           if state_code_tab(i) = state_code_tab(j) then
              l_combined_balance_value := l_combined_balance_value - balance_tab(i) ;
              exit ;
           end if ;
          end loop ;
       end loop ;
      END IF ;
       hr_utility.trace('l_combined_balance_value B4 Subtracting Actual := '||to_char(l_combined_balance_value)) ;
       /* Looping through the current States under the Current Active Assignment
          and doing a balance call wrt to current jurisdiction and calculating
          eligible SUI Wage Base Override for the State */
       for i_all_curr_states in c_all_states(p_assignment_id,p_session_date)
       loop
         IF i_all_curr_states.state_code <> '24' THEN

            l_jurisdiction_code := i_all_curr_states.state_code || '-000-0000' ;


            pay_balance_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id) ;
            pay_balance_pkg.set_context('JURISDICTION_CODE',l_jurisdiction_code) ;

            l_actual_balance_value := pay_balance_pkg.get_value(
                               l_defined_balance_id ,
                               p_assignment_id,
                               nvl(l_max_pact_dt,GREATEST(l_max_asg_eff_st_dt,trunc(p_session_date,'Y')))) ;

           l_oth_combined_balance := l_combined_balance_value - l_actual_balance_value ;

           hr_utility.trace('Actual States := '||i_all_curr_states.state_code) ;
           hr_utility.trace('l_actual_balance_value := '||to_char(l_actual_balance_value)) ;
           hr_utility.trace('l_oth_combined_balance A4 Subtracting Actual := '||to_char(l_oth_combined_balance)) ;

           open c_sui_wage_limit(i_all_curr_states.state_code, p_session_date) ;
           fetch c_sui_wage_limit into l_sui_er_wg_lt_curr_state ;
           close c_sui_wage_limit ;
           hr_utility.trace('SUI Wage Limit for the current State: '|| to_char(l_sui_er_wg_lt_curr_state)) ;

           IF l_oth_combined_balance < l_sui_er_wg_lt_curr_state THEN
              l_sui_wg_base := l_sui_er_wg_lt_curr_state - l_oth_combined_balance ;
           ELSIF l_oth_combined_balance >= l_sui_er_wg_lt_curr_state THEN
              l_sui_wg_base := 0 ;
           END IF ;
           hr_utility.trace('l_sui_wg_base := '||to_char(l_sui_wg_base)) ;

           IF l_oth_combined_balance > 0 OR l_actual_balance_value > 0 THEN
             update pay_us_emp_state_tax_rules_f
             set    sui_wage_base_override_amount = l_sui_wg_base
             where  assignment_id = p_assignment_id
             and    state_code = i_all_curr_states.state_code ;
           ELSE
	          update pay_us_emp_state_tax_rules_f
              set    sui_wage_base_override_amount = null
              where  assignment_id = p_assignment_id
              and    state_code = i_all_curr_states.state_code ;
           END IF ;
           hr_utility.trace('SUI Wage Base Updated...') ;
         END IF ;
      end loop ;
   ELSE -- Not Rehired Condition
       hr_utility.trace('Not Rehired Condition... ') ;
       l_count := 1 ;
       /* Iterating through all the states where the employee worked for the Current Assignment
          and populating PL/SQL table with the State Code and SUI ER Taxable Balance value */
       for i_all_states in c_all_states(p_assignment_id,p_session_date)
       loop
        IF i_all_states.state_code <> '24' THEN
         hr_utility.trace('l_count := '||to_char(l_count)) ;
         state_code_tab(l_count) := i_all_states.state_code ;
         l_jurisdiction_code := i_all_states.state_code || '-000-0000' ;

         hr_utility.trace('l_tax_unit_id := '||to_char(l_tax_unit_id)) ;
         hr_utility.trace('l_jurisdiction_code := '||l_jurisdiction_code) ;

         pay_balance_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id) ;
         pay_balance_pkg.set_context('JURISDICTION_CODE',l_jurisdiction_code) ;

         l_balance_value := pay_balance_pkg.get_value(
                               l_defined_balance_id ,
                               p_assignment_id,
                               nvl(l_max_pact_dt,GREATEST(l_max_asg_eff_st_dt,trunc(p_session_date,'Y')))) ;

         balance_tab(l_count) := l_balance_value ;
         hr_utility.trace('l_balance_value := '||to_char(l_balance_value)) ;
         /* Summing up the Total Balance Value */
         l_combined_balance_value := l_combined_balance_value + l_balance_value ;
         hr_utility.trace('l_combined_balance_value := '||to_char(l_combined_balance_value)) ;
         l_count := l_count + 1 ;

        END IF ;
       end loop ;
      /* Looping through the PL/SQL table to get the Eligible SUI Wage Base for each State
         and Updating the data */
      IF state_code_tab.count <> 0 THEN
       for i in state_code_tab.first .. state_code_tab.last
       loop
          l_oth_combined_balance := l_combined_balance_value - balance_tab(i) ;

          open c_sui_wage_limit(state_code_tab(i), p_session_date) ;
          fetch c_sui_wage_limit into l_sui_er_wg_lt_curr_state ;
          close c_sui_wage_limit ;
          hr_utility.trace('SUI Wage Limit for the current State: '|| to_char(l_sui_er_wg_lt_curr_state)) ;

          IF l_oth_combined_balance < l_sui_er_wg_lt_curr_state THEN
             l_sui_wg_base := l_sui_er_wg_lt_curr_state - l_oth_combined_balance ;
          ELSIF l_oth_combined_balance >= l_sui_er_wg_lt_curr_state THEN
             l_sui_wg_base := 0 ;
          END IF ;
          hr_utility.trace('State_code := '||state_code_tab(i)) ;
          hr_utility.trace('l_oth_combined_balance := '||to_char(l_oth_combined_balance)) ;
          hr_utility.trace('l_sui_wg_base := '||to_char(l_sui_wg_base)) ;

          IF l_oth_combined_balance > 0 OR l_combined_balance_value > 0 THEN
             update pay_us_emp_state_tax_rules_f
             set    sui_wage_base_override_amount = l_sui_wg_base
             where  assignment_id = p_assignment_id
             and    state_code = state_code_tab(i) ;
	      ELSE
	          update pay_us_emp_state_tax_rules_f
              set    sui_wage_base_override_amount = null
              where  assignment_id = p_assignment_id
              and    state_code = state_code_tab(i) ;
          END IF ;
          hr_utility.trace('SUI Wage Base Updated...') ;
       end loop ;
      END IF ;
 END IF ;
/* Exception for the State of Minnesota - No SUI Wage Transfer allowed */
 IF p_state_code = '24' THEN
    open c_sui_wage_limit(p_state_code, l_max_asg_eff_st_dt) ;
    fetch c_sui_wage_limit into l_sui_er_wg_lt_curr_state ;
    close c_sui_wage_limit ;

    update pay_us_emp_state_tax_rules_f
    set    sui_wage_base_override_amount = l_sui_er_wg_lt_curr_state
    where  assignment_id = p_assignment_id
    and    state_code = p_state_code  ;
 END IF ;

end set_sui_wage_base_override;


/* Name    : create_new_location_rec
   Purpose : To create record for the new work location, with respect
             to every change in location and set the city record for
             the time period between p_validation_start_date and
             p_validation_end_date to 100%
*/

procedure create_new_location_rec(p_assignment_id         in number,
                                  p_validation_start_date in date,
                                  p_validation_end_date   in date,
                                  p_session_date          in date,
                                  p_new_location_id       in number,
                                  p_res_state_code        in varchar2,
                                  p_res_county_code       in varchar2,
                                  p_res_city_code         in varchar2,
                                  p_business_group        in number,
                                  p_percent               in number) is

  l_state_code             varchar2(2);
  l_county_code            varchar2(3);
  l_city_code              varchar2(4);
  l_ovrd_state_code        varchar2(2);
  l_ovrd_county_code        varchar2(3);
  l_ovrd_city_code         varchar2(4);
  l_jurisdiction_code      varchar2(11);
  l_end_of_time            date := to_date('31/12/4712','DD/MM/YYYY');
  l_ret_code                            number := 0;
  l_ret_text                              varchar2(240) := null;
  l_emp_state_tax_rule_id    number;
  l_emp_county_tax_rule_id number;
  l_emp_city_tax_rule_id      number;
  l_default_date                     date;



  /* Cursor to get the state code, county code and the city code
     corresponding to a location id */
  /* lwthomps .. While we only want to create tax records for the
     primary cities, locations can corespond to vanity or secondary
     cities that share the same geocode.  For this reason I am removing
     the join to pay_us_city_names for primary = 'Y' (588982) */

  cursor csr_get_codes(p_location number) is
   select pus.state_code,
         puco.county_code,
         puci.city_code,
         pus1.state_code,
         puco1.county_code,
         puci1.city_code
   from  PAY_US_CITY_NAMES puci1,
         PAY_US_COUNTIES puco1,
         PAY_US_STATES pus1,
         PAY_US_CITY_NAMES puci,
         PAY_US_COUNTIES puco,
         PAY_US_STATES pus,
         HR_LOCATIONS hrl
  where  hrl.location_id  = p_location
  and    pus.state_abbrev = hrl.region_2
  and    puco.state_code  = pus.state_code
  and    puco.county_name = hrl.region_1
  and    puci.state_code  = puco.state_code
  and    puci.county_code = puco.county_code
  and    puci.city_name   = hrl.town_or_city
  and    pus1.state_abbrev = nvl(hrl.loc_information17,hrl.region_2)
  and    puco1.state_code  = pus1.state_code
  and    puco1.county_name = nvl(hrl.loc_information19,hrl.region_1)
  and    puci1.state_code  = puco1.state_code
  and    puci1.county_code = puco1.county_code
  and    puci1.city_name   = nvl(hrl.loc_information18,hrl.town_or_city);

  /* and    puci.primary_flag = 'Y';  */

  /* End changes by lwthomps (588982)*/

   cursor csr_get_eff_date is
       select min(effective_start_date)
       from   PAY_US_EMP_FED_TAX_RULES_F
       where  assignment_id = p_assignment_id;

 /* Added cursor csr_get_max_assign_end_dt
    for bug 2535501 to get the max(effective_end_date)
    of an assignment.  This will ensure that the end_date
    of the state, county and city tax_rules_f tables
    will have correct end dates when a new row is created.
*/

   cursor csr_get_max_assign_end_dt is
      select max(effective_end_date)
      from   per_assignments_f
      where  assignment_id = p_assignment_id;


l_max_assign_end_dt date := NULL;

begin


   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',1);
   if (p_new_location_id is null) and (p_res_state_code is not null
      and p_res_county_code is not null
      and p_res_city_code is not null )then

      /* called for residential address */
      l_state_code := p_res_state_code;
      l_county_code := p_res_county_code;
      l_city_code   := p_res_city_code;

   else   /* called for work location */

     /* Get the state code, county code and the city code for the
        new location */

   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',2);
     open csr_get_codes(p_new_location_id);
     fetch csr_get_codes into l_state_code, l_county_code,l_city_code,
                              l_ovrd_state_code, l_ovrd_county_code,
                              l_ovrd_city_code;
     if csr_get_codes%NOTFOUND then
       fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
       fnd_message.set_token('PROCEDURE',
                   'pay_us_emp_dt_tax_rules.create_new_loc_rec');
       fnd_message.set_token('STEP','2');
       fnd_message.raise_error;
      end if;
      close csr_get_codes;

    end if;

   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',3);
    /* Get the default date from the federal tax rules record */

       open csr_get_eff_date;

       fetch csr_get_eff_date into l_default_date;

       if l_default_date is null then
           fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
           fnd_message.set_token('PROCEDURE',
                      'pay_us_emp_dt_tax_rules.create_new_location_rec');
           fnd_message.set_token('STEP','1');
           fnd_message.raise_error;
       end if;

       close csr_get_eff_date;

    /* Create the new location records */


   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',4);
    l_ret_code := 0;
    l_ret_text := null;
    l_jurisdiction_code := l_state_code ||'-000-0000';

   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',5);
    pay_us_emp_dt_tax_val.check_jurisdiction_exists(p_assignment_id     => p_assignment_id,
                              p_jurisdiction_code => l_jurisdiction_code,
                              p_ret_code          => l_ret_code,
                              p_ret_text          => l_ret_text);
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',6);

/* Bug 2535501 */

   open csr_get_max_assign_end_dt;
   fetch csr_get_max_assign_end_dt into l_max_assign_end_dt;


   if csr_get_max_assign_end_dt%NOTFOUND then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE',
                   'pay_us_emp_dt_tax_rules.create_new_location_rec');
        fnd_message.set_token('STEP','3');
        fnd_message.raise_error;
    end if;

   close csr_get_max_assign_end_dt;

/* End Bug 2535501 */

    /* If state record does not exist then the county and city
       records also do not exist */

        /* Create the state tax rule record and then create %age record
           for state. The ins_def_state_rec routine will create the
           state tax rule record from  begin of time till end of time
           and also the state percentage record for every change in
           location */

     if l_ret_code = 1 then
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',7);
         l_emp_state_tax_rule_id :=
         insert_def_state_rec(p_assignment_id        => p_assignment_id,
                           p_effective_start_date => l_default_date,
                           p_effective_end_date   => l_max_assign_end_dt, -- Bug 2535501
--                           p_effective_end_date   => l_end_of_time,
                           p_state_code           => l_state_code,
                           p_business_group_id    => p_business_group,
                           p_percent_time         => 0);

         /* Create the county tax rule record and then create %age record
            for state. The ins_def_county_rec routine will create the
            county tax rule record from  begin of time till end of time
            and also the county percentage record for every change in
            location */
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',8);

         l_emp_county_tax_rule_id :=
         insert_def_county_rec(p_assignment_id        => p_assignment_id,
                           p_effective_start_date => l_default_date,
                           p_effective_end_date   => l_max_assign_end_dt, -- Bug 2535501
--                           p_effective_end_date   => l_end_of_time,
                           p_state_code           => l_state_code,
                           p_county_code          => l_county_code,
                           p_business_group_id    => p_business_group,
                           p_percent_time         => 0);

         /* Create the city tax rule record and then create %age record
            for state. The ins_def_city_rec routine will create the
            city tax rule record from  begin of time till end of time
            and also the city percentage record for every change in
            location */
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',9);

         l_emp_city_tax_rule_id :=
         insert_def_city_rec(p_assignment_id        => p_assignment_id,
                           p_effective_start_date => l_default_date,
                           p_effective_end_date   => l_max_assign_end_dt, -- Bug 2535501
--                           p_effective_end_date   => l_end_of_time,
                           p_state_code           => l_state_code,
                           p_county_code          => l_county_code,
                           p_city_code            => l_city_code,
                           p_business_group_id    => p_business_group,
                           p_percent_time         => 0);

   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',10);

     elsif l_ret_code = 0 then
         hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',101);
         /* State record exists. Now check if county record exists */
         -- Update SUI Wage Base Override Amount
         -- Update SUI WAGE BASE Overide amount if payroll is installed otherwise don't
	     -- call the procedure which does the update
         -- Turning Off SUI Wage Base Override Functionality due to Bug# 5486281
         /*
	     IF  hr_utility.chk_product_install(p_product =>'Oracle Payroll',
                                           p_legislation => 'US')
         then
                 hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',102);
                 if p_assignment_id is not null and p_session_date is not null
		         then
                      hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',103);
                      set_sui_wage_base_override(p_assignment_id,l_state_code,p_session_date) ;
                 end if ;
         end if;
       -- End Change
          */

        l_ret_code := 0;
        l_ret_text := null;
        l_jurisdiction_code := l_state_code ||'-' || l_county_code ||'-0000';

        hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',11);
        pay_us_emp_dt_tax_val.check_jurisdiction_exists(p_assignment_id     => p_assignment_id,
                                  p_jurisdiction_code => l_jurisdiction_code,
                                  p_ret_code          => l_ret_code,
                                  p_ret_text          => l_ret_text);
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',12);
        /* If county record does not exist then city will also not exist */
        if l_ret_code = 1 then

           /* Create the county tax rule record and then create %age record
           for state. The ins_def_county_rec routine will create the
           county tax rule record from  begin of time till end of time
           and also the county percentage record for every change in
           location */

   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',13);
           l_emp_county_tax_rule_id :=
           insert_def_county_rec(p_assignment_id        => p_assignment_id,
                          p_effective_start_date => l_default_date,
                           p_effective_end_date   => l_max_assign_end_dt, -- Bug 2535501
--                           p_effective_end_date   => l_end_of_time,
                          p_state_code           => l_state_code,
                          p_county_code          => l_county_code,
                          p_business_group_id    => p_business_group,
                          p_percent_time         => 0);

           /* Create the city tax rule record and then create %age record
           for state. The ins_def_city_rec routine will create the
           city tax rule record from  begin of time till end of time
           and also the city percentage record for every change in
           location */

   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',14);
           l_emp_city_tax_rule_id :=
           insert_def_city_rec(p_assignment_id        => p_assignment_id,
                          p_effective_start_date => l_default_date,
                           p_effective_end_date   => l_max_assign_end_dt, -- Bug 2535501
--                           p_effective_end_date   => l_end_of_time,
                          p_state_code           => l_state_code,
                          p_county_code          => l_county_code,
                          p_city_code            => l_city_code,
                          p_business_group_id    => p_business_group,
                          p_percent_time         => 0);
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',15);

        elsif l_ret_code = 0 then
          /* State and county records exist. Check if the city record exists */

          l_ret_code := 0;
          l_ret_text := null;
          l_jurisdiction_code := l_state_code ||'-' || l_county_code ||'-'||
                                 l_city_code;

   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',16);
          pay_us_emp_dt_tax_val.check_jurisdiction_exists(p_assignment_id     => p_assignment_id,
                                  p_jurisdiction_code => l_jurisdiction_code,
                                  p_ret_code          => l_ret_code,
                                  p_ret_text          => l_ret_text);
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',17);

          /* If city record does not exist then create one */

          if l_ret_code = 1 then

            /* Create the city tax rule record and then create %age record
               for state. The ins_def_city_rec routine will create the
               city tax rule record from  begin of time till end of time
               and also the city percentage record for every change in
               location */
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',18);

            l_emp_city_tax_rule_id :=
            insert_def_city_rec(p_assignment_id        => p_assignment_id,
                              p_effective_start_date => l_default_date,
                           p_effective_end_date   => l_max_assign_end_dt, -- Bug 2535501
--                           p_effective_end_date   => l_end_of_time,
                              p_state_code           => l_state_code,
                              p_county_code          => l_county_code,
                              p_city_code            => l_city_code,
                              p_business_group_id    => p_business_group,
                              p_percent_time         => 0);
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',19);

         end if;

        end if;

     end if;

    if l_ovrd_state_code <> l_state_code then

   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',20);
       l_emp_state_tax_rule_id :=
       insert_def_state_rec(p_assignment_id   => p_assignment_id,
                           p_effective_start_date => l_default_date,
                           p_effective_end_date   => l_end_of_time,
                           p_state_code           => l_ovrd_state_code,
                           p_business_group_id    => p_business_group,
                           p_percent_time         => 0);
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',21);

    end if;

    if (l_ovrd_state_code <> l_state_code
       or l_ovrd_county_code <> l_county_code) then
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',22);
         l_emp_county_tax_rule_id :=
         insert_def_county_rec(p_assignment_id        => p_assignment_id,
                           p_effective_start_date => l_default_date,
                           p_effective_end_date   => l_end_of_time,
                           p_state_code           => l_ovrd_state_code,
                           p_county_code          => l_ovrd_county_code,
                           p_business_group_id    => p_business_group,
                           p_percent_time         => 0);
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',23);
    end if;

    if (l_ovrd_state_code <> l_state_code
       or l_ovrd_county_code <> l_county_code
       or l_ovrd_city_code <> l_city_code) then
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',24);
            l_emp_city_tax_rule_id :=
            insert_def_city_rec(p_assignment_id        => p_assignment_id,
                              p_effective_start_date => l_default_date,
                              p_effective_end_date   => l_end_of_time,
                              p_state_code           => l_ovrd_state_code,
                              p_county_code          => l_ovrd_county_code,
                              p_city_code            => l_ovrd_city_code,
                              p_business_group_id    => p_business_group,
                              p_percent_time         => 0);
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',25);
     end if;

   /* if called for change in location then set the city to 100% */

   if p_new_location_id is not null and
      p_percent = 100 and
      (p_res_state_code is null
      and p_res_county_code is null and p_res_city_code is null) then

   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',26);
     /* Now update the city record and set it to 100% */

     if l_state_code = l_ovrd_state_code and l_county_code = l_ovrd_county_code
        and l_city_code = l_ovrd_city_code then
        l_jurisdiction_code := l_state_code ||'-' || l_county_code ||'-'|| l_city_code;
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',27);
     else
        l_jurisdiction_code := l_ovrd_state_code ||'-' || l_ovrd_county_code ||'-'||l_ovrd_city_code;
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',28);
     end if;

   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',29);
     maintain_element_entry (p_assignment_id       => p_assignment_id,
                             p_effective_start_date => p_validation_start_date,
                             p_effective_end_date   => p_validation_end_date,
                             p_session_date         => p_session_date,
                             p_jurisdiction_code    => l_jurisdiction_code,
                             p_percentage_time      => 100,
                             p_mode                 => 'CORRECTION');
   hr_utility.set_location('pay_us_emp_dt_tax_rules.create_new_location_rec',30);
    end if;

end create_new_location_rec;


/* Name          : del_updt_entries_for_dates
     Purpose     : This procedure can be used to change the effective start date
                   and/or effective end date of the element entries and the
                   pay_element_entry_values, for a jurisdiction of
                   an assignment. It can also be used to delete the element entries
                   for a given date range.
     Parameters  :
                 p_assignment_id     -> The assignment for which the vertex elemnt entries are
                                         to be modified for their start and/or end dates.
                  p_session_date      -> The start date of the element entry.
                  p_new_start_date    -> The new start date of the element entry.
                  p_new_end_date      -> The new end date of the element entry.
                  p_mode              -> 'U' -> for update
                                         'D' -> for Delete
                                         'F' -> FUTURE_CHANGE (for Delete)
                                         'N' -> DELETE_NEXT_CHANGE
*/

procedure del_updt_entries_for_dates (p_assignment_id        in number,
                                    p_jurisdiction_code    in varchar2,
                                    p_session_date         in date,
                                    p_new_start_date       in date,
                                    p_new_end_date         in date,
                                    p_mode                 in varchar2) is

   l_inp_value_id_table   hr_entry.number_table;
   l_scr_value_table      hr_entry.varchar2_table;

   l_element_type_id      number       :=0;
   l_inp_name             varchar2(80) :=null;
   l_inp_val_id           number       :=0;
   l_element_link_id      number       :=0;
   l_element_entry_id     number       :=0;
   l_effective_start_date date;
   l_effective_end_date   date;
   l_step                 number;
   l_mode                 varchar2(30);

   /* Cursor to get the vertex element type */

   cursor csr_tax_element is
       select pet.element_type_id,
              piv.input_value_id,
              piv.name
       from   PAY_INPUT_VALUES_F  piv,
              PAY_ELEMENT_TYPES_F pet
       where  p_session_date between piv.effective_start_date
                             and piv.effective_end_date
       and    pet.element_type_id       = piv.element_type_id
       and    p_session_date between pet.effective_start_date
                             and pet.effective_end_date
       and    pet.element_name          = 'VERTEX';

   /* Cursor to get the element entry for the jurisdiction */

   cursor csr_ele_entry (p_element_link number, p_inp_val number)is
       select pee.element_entry_id
       from   PAY_ELEMENT_ENTRY_VALUES_F pev,
              PAY_ELEMENT_ENTRIES_F pee
       where  pev.screen_entry_value   = p_jurisdiction_code
       and    pev.input_value_id + 0   = p_inp_val
       and    p_session_date between pev.effective_start_date
                             and pev.effective_end_date
       and    pev.element_entry_id     = pee.element_entry_id
       and    pee.element_link_id      = p_element_link
       and    p_session_date between pee.effective_start_date
                             and pee.effective_end_date
       and    pee.assignment_id        = p_assignment_id;

begin

       hr_utility.set_location('pay_emp_dt_tax_rules.del_updt_entries_for_dates' ,1);

       l_step := 1;
       open  csr_tax_element;

       loop

          fetch csr_tax_element into l_element_type_id,
                                     l_inp_val_id,
                                     l_inp_name;

          exit when csr_tax_element%NOTFOUND;

          if upper(l_inp_name) = 'PAY VALUE'
          then
               l_inp_value_id_table(1) := l_inp_val_id;
          elsif upper(l_inp_name) = 'JURISDICTION'
          then
               l_inp_value_id_table(2) := l_inp_val_id;
          elsif upper(l_inp_name) = 'PERCENTAGE'
          then
               l_inp_value_id_table(3) := l_inp_val_id;
          end if;
       end loop;

       close csr_tax_element;

       hr_utility.set_location('pay_us_emp_dt_tax_rules.del_updt_entries_for_dates'
                               ,2);

       /* Check that all of the input value id for vertex, exists */

       for i in 1..3 loop

           if l_inp_value_id_table(i) = null or
              l_inp_value_id_table(i) = 0
           then
               fnd_message.set_name('PAY', 'HR_13140_TAX_ELEMENT_ERROR');
               fnd_message.set_token('1','INPUT VALUE');
               fnd_message.raise_error;
           end if;

       end loop;

       hr_utility.set_location('pay_us_emp_dt_tax_rules.del_updt_entries_for_dates'
                                ,3);

       /* Get element link */
       l_step := 2;
       l_element_link_id := hr_entry_api.get_link(
                                 P_assignment_id   => p_assignment_id,
                                 P_element_type_id => l_element_type_id,
                                 P_session_date    => p_session_date);

       if l_element_link_id is null or l_element_link_id = 0
       then
           fnd_message.set_name('PAY', 'HR_13140_TAX_ELEMENT_ERROR');
           fnd_message.set_token('1','ELEMENT LINK');
           fnd_message.raise_error;
       end if;

       hr_utility.set_location('pay_us_emp_dt_tax_rules.del_updt_entries_for_dates'
                                ,4);

       /* Get the Element Entry Id */
       l_step := 3;
       open csr_ele_entry(l_element_link_id, l_inp_value_id_table(2));

       fetch csr_ele_entry into l_element_entry_id;

       if csr_ele_entry%NOTFOUND then

          close csr_ele_entry;
          fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
          fnd_message.set_token('PROCEDURE',
                       'pay_us_emp_dt_tax_rules.del_updt_entries_for_dates' ||
                       '- SQLCODE:'|| to_char(sqlcode));
          fnd_message.set_token('STEP',to_char(l_step));
          fnd_message.raise_error;

       end if;

       close csr_ele_entry;

       if p_mode = 'U' then

           /* Update Element Entries and Element Entry values as well */

           if p_new_start_date is not null
           then

               l_step := 4;
               update PAY_ELEMENT_ENTRIES_F
               set    effective_start_date = p_new_start_date
               where  element_entry_id = l_element_entry_id
               and    p_session_date between effective_start_date
                      and effective_end_date;

               l_step := 5;
               update PAY_ELEMENT_ENTRY_VALUES_F
               set    effective_start_date = p_new_start_date
               where  element_entry_id = l_element_entry_id
               and    p_session_date between effective_start_date
                      and effective_end_date;
           end if;

           if p_new_end_date is not null
           then

               l_step := 6;
               update PAY_ELEMENT_ENTRIES_F
               set    effective_end_date = p_new_end_date
               where  element_entry_id = l_element_entry_id
               and    p_session_date between effective_start_date
                      and effective_end_date;

               l_step := 7;
               update PAY_ELEMENT_ENTRY_VALUES_F
               set    effective_end_date = p_new_end_date
               where  element_entry_id = l_element_entry_id
               and    p_session_date between effective_start_date
                      and effective_end_date;
           end if;

        elsif p_mode = 'D' then

            /* Delete the element entries */

               l_step := 8;
               delete PAY_ELEMENT_ENTRY_VALUES_F
               where  element_entry_id = l_element_entry_id
               and    p_session_date between effective_start_date
                      and effective_end_date;

            /* Delete the element entry values */

               l_step := 9;
               delete PAY_ELEMENT_ENTRIES_F
               where  element_entry_id = l_element_entry_id
               and    p_session_date between effective_start_date
                      and effective_end_date;

        elsif p_mode = 'N' then /* Delete next change */

          l_mode := 'DELETE_NEXT_CHANGE';
          maintain_element_entry (p_assignment_id     => p_assignment_id,
                                 p_effective_start_date => p_session_date,
                                 p_effective_end_date   => null,
                                 p_session_date         => p_session_date,
                                 p_jurisdiction_code    => p_jurisdiction_code,
                                 p_percentage_time      => 0,
                                 p_mode                 => l_mode);


        elsif p_mode = 'F' then /* Delete future change */

          l_mode := 'FUTURE_CHANGE';
          maintain_element_entry (p_assignment_id     => p_assignment_id,
                                 p_effective_start_date => p_session_date,
                                 p_effective_end_date   => null,
                                 p_session_date         => p_session_date,
                                 p_jurisdiction_code    => p_jurisdiction_code,
                                 p_percentage_time      => 0,
                                 p_mode                 => l_mode);

         end if;

       exception
       when others then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE',
                       'pay_us_emp_dt_tax_rules.del_updt_entries_for_dates' ||
                       '- SQLCODE:'|| to_char(sqlcode));
        fnd_message.set_token('STEP',to_char(l_step));
        fnd_message.raise_error;

end del_updt_entries_for_dates;

/* Name      : upd_del_entries
   Purpose   : Since we have to update the element entries of all the
               jurisdictions, we can get the jurisdictions that are
               valid as of the session date. from the tax rules tables.
               Then for each of the jurisdiction, we will call the
               del_updt_entries_for_dates to change their effective dates.
               This rotuine will also be called to delete the element entries
               for a specific date range.
   Parameters : p_assignment_id -> The assignment id.
                p_session_date  -> The session date for which the element
                                    entries have to be updated/deleted.
                p_new_start_date -> The new effective start date to which
                                    the effective start date of the records
                                    needs to be changed.
                p_new_end_date   -> The new end date for the element entries
                                    effective as of the session date.
                p_mode          ->  'U' -> Update
                                    'D' -> Delete
                                    'F' -> FUTURE_CHANGE (for Delete)
                                    'N' -> DELETE_NEXT_CHANGE
*/

procedure upd_del_entries(p_assignment_id     in number,
                          p_session_date      in date,
                          p_new_start_date    in date,
                          p_new_end_date      in date,
                          p_mode              in varchar2) is

  l_state_code        varchar2(2);
  l_county_code       varchar2(3);
  l_city_code         varchar2(4);
  l_jurisdiction_code varchar2(11);

  cursor csr_get_states is
  select state_code
  from   PAY_US_EMP_STATE_TAX_RULES_F str
  where  str.assignment_id = p_assignment_id
  and    p_session_date between str.effective_start_date
         and str.effective_end_date;

  cursor csr_get_counties is
  select state_code,
         county_code
  from   PAY_US_EMP_COUNTY_TAX_RULES_F ctr
  where  ctr.assignment_id = p_assignment_id
  and    p_session_date between ctr.effective_start_date
         and ctr.effective_end_date;

  cursor csr_get_cities is
  select state_code,
         county_code,
         city_code
  from   PAY_US_EMP_CITY_TAX_RULES_F ctr
  where  ctr.assignment_id = p_assignment_id
  and    p_session_date between ctr.effective_start_date
         and ctr.effective_end_date;

  begin

       /* First let's handle the state records */

       open csr_get_states;

       loop

          fetch csr_get_states into l_state_code;

          exit when csr_get_states%NOTFOUND;

             /* Update the entries for their effective start and/or
                effective end date */

             l_jurisdiction_code := l_state_code || '-000-0000';
             del_updt_entries_for_dates (p_assignment_id    => p_assignment_id,
                                    p_jurisdiction_code => l_jurisdiction_code,
                                    p_session_date      => p_session_date,
                                    p_new_start_date    => p_new_start_date,
                                    p_new_end_date      => p_new_end_date,
                                    p_mode              => p_mode);
       end loop;

       close csr_get_states;

       /* Now grab the counties */

       open csr_get_counties;

       loop

          fetch csr_get_counties into l_state_code,l_county_code;

          exit when csr_get_counties%NOTFOUND;

          /* Update the entries for their effective start and/or
             effective end date */

          l_jurisdiction_code := l_state_code || '-' || l_county_code ||
                                  '-0000';

          del_updt_entries_for_dates (p_assignment_id    => p_assignment_id,
                                  p_jurisdiction_code => l_jurisdiction_code,
                                  p_session_date      => p_session_date,
                                  p_new_start_date    => p_new_start_date,
                                  p_new_end_date      => p_new_end_date,
                                  p_mode              => p_mode);

       end loop;

       close csr_get_counties;

       /* Cities time */

       open csr_get_cities;

       loop

          fetch csr_get_cities into l_state_code,l_county_code, l_city_code;

          exit when csr_get_cities%NOTFOUND;

          /* Update the entries for their effective start and/or
             effective end date */

          l_jurisdiction_code := l_state_code || '-' || l_county_code ||
                                  '-' || l_city_code;

          del_updt_entries_for_dates (p_assignment_id    => p_assignment_id,
                                  p_jurisdiction_code => l_jurisdiction_code,
                                  p_session_date      => p_session_date,
                                  p_new_start_date    => p_new_start_date,
                                  p_new_end_date      => p_new_end_date,
                                  p_mode              => p_mode);

       end loop;

       close csr_get_cities;

end upd_del_entries;



/*   Name        : del_updt_wc_entry_for_dates
     Purpose     : This procedure can be used to change the effective start date
                   and/or effective end date of the workers comp.element
                   entry and the pay_element_entry_value, for an assignment. It
                   can also be used to delete the workers comp. element entry
                   for a given date range.
     Parameters  :
                 p_assignment_id     -> The assignment for which the workers
                                        comp. element entry are to be modified
                                        for their start and/or end dates.
                  p_session_date     -> The start date of the element entry.
                  p_new_start_date   -> The new start date of the element entry.
                  p_new_end_date     -> The new end date of the element entry.
                  p_mode             -> 'U' -> for update
                                        'D' -> for Delete
*/

procedure del_updt_wc_entry_for_dates (p_assignment_id        in number,
                                         p_session_date         in date,
                                         p_new_start_date       in date,
                                         p_new_end_date         in date,
                                         p_mode                 in varchar2) is


   l_element_type_id      number       :=0;
   l_element_link_id      number       :=0;
   l_element_entry_id     number       :=0;
   l_effective_start_date date;
   l_effective_end_date   date;
   l_step                 number;

   /* Cursor to get the workers comp. element type */

   cursor csr_tax_element is
       select pet.element_type_id
       from   PAY_ELEMENT_TYPES_F pet
       where  pet.element_name = 'Workers Compensation'       -- Bug 3354060 FTS on PAY_ELEMENT_TYPES_F was removed. Done by removing
       and    p_session_date between pet.effective_start_date -- 'upper' from pet.element_name and 'WORKERS COMPENSATION' was changed to
                             and pet.effective_end_date;      -- 'Workers Compensation'

   /* Cursor to get the element entry for the jurisdiction */

   cursor csr_wc_ele_entry (p_element_link number)is
       select pee.element_entry_id
       from   PAY_ELEMENT_ENTRIES_F pee
       where  pee.assignment_id        = p_assignment_id
       and    p_session_date between pee.effective_start_date
                             and pee.effective_end_date
       and    pee.element_link_id      = p_element_link;

begin

       hr_utility.set_location('pay_emp_tax_dt_tax_rules.del_updt_wc_entry_for_dates' ,1);

       l_step := 1;
       open  csr_tax_element;

          fetch csr_tax_element into l_element_type_id;
          if csr_tax_element%NOTFOUND then
             fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
             fnd_message.set_token('PROCEDURE',
                     'pay_us_emp_dt_tax_rules.del_updt_wc_entry_for_dates');
             fnd_message.set_token('STEP',to_char(l_step));
             fnd_message.raise_error;
           end if;

       close csr_tax_element;

       hr_utility.set_location('pay_us_emp_dt_tax_rules.del_updt_wc_entry_for_dates' ,2);

       /* Get element link */
       l_step := 2;
       l_element_link_id := hr_entry_api.get_link(
                                 P_assignment_id   => p_assignment_id,
                                 P_element_type_id => l_element_type_id,
                                 P_session_date    => p_session_date);

       if l_element_link_id is null or l_element_link_id = 0
       then
           fnd_message.set_name('PAY', 'HR_13140_TAX_ELEMENT_ERROR');
           fnd_message.set_token('1','ELEMENT LINK');
           fnd_message.raise_error;
       end if;

       hr_utility.set_location('pay_us_emp_dt_tax_rules.del_updt_wc_entry_for_dates' ,3);

       /* Get the Element Entry Id */
       l_step := 3;
       open csr_wc_ele_entry(l_element_link_id);

       fetch csr_wc_ele_entry into l_element_entry_id;

       if csr_wc_ele_entry%NOTFOUND then

          close csr_wc_ele_entry;
          fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
          fnd_message.set_token('PROCEDURE',
                     'pay_us_emp_dt_tax_rules.del_updt_wc_entry_for_dates' ||
                       '- SQLCODE:'|| to_char(sqlcode));
         fnd_message.set_token('STEP',to_char(l_step));
         fnd_message.raise_error;

       end if;

       close csr_wc_ele_entry;

       if p_mode = 'U' then

           /* Update Element Entries and Element Entry values as well */

           if p_new_start_date is not null
           then

               l_step := 4;
               update PAY_ELEMENT_ENTRIES_F
               set    effective_start_date = p_new_start_date
               where  element_entry_id = l_element_entry_id
               and    p_session_date between effective_start_date
                      and effective_end_date;

               l_step := 5;
               update PAY_ELEMENT_ENTRY_VALUES_F
               set    effective_start_date = p_new_start_date
               where  element_entry_id = l_element_entry_id
               and    p_session_date between effective_start_date
                      and effective_end_date;

           end if;

           if p_new_end_date is not null
           then

               l_step := 6;
               update PAY_ELEMENT_ENTRIES_F
               set    effective_end_date = p_new_end_date
               where  element_entry_id = l_element_entry_id
               and    p_session_date between effective_start_date
                      and effective_end_date;

               l_step := 7;
               update PAY_ELEMENT_ENTRY_VALUES_F
               set    effective_end_date = p_new_end_date
               where  element_entry_id = l_element_entry_id
               and    p_session_date between effective_start_date
                      and effective_end_date;
           end if;

        elsif p_mode = 'D' then

            /* Delete the element entry */

               l_step := 8;
               delete PAY_ELEMENT_ENTRY_VALUES_F
               where  element_entry_id = l_element_entry_id
               and    p_session_date between effective_start_date
                      and effective_end_date;

            /* Delete the element entry values */

               l_step := 9;
               delete PAY_ELEMENT_ENTRIES_F
               where  element_entry_id = l_element_entry_id
               and    p_session_date between effective_start_date
                      and effective_end_date;
         end if;

       exception
       when others then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE',
                     'pay_us_emp_dt_tax_rules.del_updt_wc_entry_for_dates' ||
                       '- SQLCODE:'|| to_char(sqlcode));
        fnd_message.set_token('STEP',to_char(l_step));
        fnd_message.raise_error;

end del_updt_wc_entry_for_dates;



/*     Name     : change_entries
       Purpose  : To create or update the %age tax records for
                  all of the existing tax rules records, for a given date
                  range i.e. from the p_start_date till p_end_date.
                  When this procedure is called with the mode of 'INSERT_OLD'
                  the %age passed by this routine to the maintain_element_entry
                  routine will not be of any importance because the maintain_element_entry
                  routine will do an update insert with the existing %age
*/

procedure change_entries(p_assignment_id in number,
                             p_session_date  in date,
                             p_start_date    in date,
                             p_end_date      in date,
                             p_mode          in varchar2) is

  l_state_code     varchar2(2);
  l_county_code    varchar2(3);
  l_city_code      varchar2(4);
  l_jurisdiction_code varchar2(11);

  cursor csr_get_states is
  select state_code
  from   PAY_US_EMP_STATE_TAX_RULES_F str
  where  str.assignment_id = p_assignment_id
  and    p_session_date between
         str.effective_start_date and str.effective_end_date;

  cursor csr_get_counties is
  select state_code,
         county_code
  from   PAY_US_EMP_COUNTY_TAX_RULES_F ctr
  where  ctr.assignment_id = p_assignment_id
  and    p_session_date between
         ctr.effective_start_date and ctr.effective_end_date;

  cursor csr_get_cities is
  select state_code,
         county_code,
         city_code
  from   PAY_US_EMP_CITY_TAX_RULES_F ctr
  where  ctr.assignment_id = p_assignment_id
  and    p_session_date between
         ctr.effective_start_date and ctr.effective_end_date;

  begin

       /* First let's handle the state records */

       open csr_get_states;

       loop

          fetch csr_get_states into l_state_code;

          exit when csr_get_states%NOTFOUND;

          l_jurisdiction_code := l_state_code ||'-000-0000';

          /* change the tax %age record for the state */
          maintain_element_entry (p_assignment_id     => p_assignment_id,
                               p_effective_start_date => p_start_date,
                               p_effective_end_date   => p_end_date,
                               p_session_date         => p_session_date,
                               p_jurisdiction_code    => l_jurisdiction_code,
                               p_percentage_time      => 0,
                               p_mode                 => p_mode);

       end loop;

       close csr_get_states;

       /* Now grab the counties */

       open csr_get_counties;

       loop

          fetch csr_get_counties into l_state_code,l_county_code;

          exit when csr_get_counties%NOTFOUND;

          l_jurisdiction_code := l_state_code ||'-' ||
                                 l_county_code ||'-0000';

          /* change the tax %age record for the county  */

          maintain_element_entry (p_assignment_id     => p_assignment_id,
                                 p_effective_start_date => p_start_date,
                                 p_effective_end_date   => p_end_date,
                                 p_session_date         => p_session_date,
                                 p_jurisdiction_code    => l_jurisdiction_code,
                                 p_percentage_time      => 0,
                                 p_mode                 => p_mode);

       end loop;

       close csr_get_counties;

       /* Cities time */

       open csr_get_cities;

       loop

          fetch csr_get_cities into l_state_code,l_county_code, l_city_code;

          exit when csr_get_cities%NOTFOUND;

          l_jurisdiction_code := l_state_code ||'-' ||
                             l_county_code ||'-' || l_city_code;

          /* change the tax %age record for the city  */

          maintain_element_entry (p_assignment_id     => p_assignment_id,
                                 p_effective_start_date => p_start_date,
                                 p_effective_end_date   => p_end_date,
                                 p_session_date         => p_session_date,
                                 p_jurisdiction_code    => l_jurisdiction_code,
                                 p_percentage_time      => 0,
                                 p_mode                 => p_mode);

       end loop;

       close csr_get_cities;

end change_entries;


procedure pull_percentage (p_assignment_id        in number,
                           p_default_date         in date,
                           p_effective_start_date in date,
                           p_effective_end_date   in date,
                           p_session_date         in date,
                           p_new_location_id      in number,
                           p_business_group_id    in number) is

  l_ret_code              number;
  l_ret_text              varchar2(240);
  l_next_date             date;
  l_next_location         number;
  l_ovrd_loc              number;
  l_ovrd_percent          number := 0;
  l_percent               number := 100;
  l_validation_start_date date;
  l_validation_end_date   date;
  l_next_end_date         date;
  l_element_type_id       number;
  l_element_link_id       number;

  /* cursor to get the next location */

  cursor csr_get_next_location (p_next_eff_date date) is
  select paf.location_id, paf.effective_end_date
  from   PER_ASSIGNMENTS_F paf
  where  paf.assignment_id = p_assignment_id
         and p_next_eff_date between paf.effective_start_date
         and paf.effective_end_date;

   /* Get the Vertex element type */
   cursor csr_tax_element is
       select pet.element_type_id
       from   PAY_ELEMENT_TYPES_F pet
       where  pet.element_name          = 'VERTEX'
       and    p_session_date between pet.effective_start_date
                             and pet.effective_end_date;

  /* cursor to get the effective end date of the next element entry record */
  cursor csr_get_next_date (p_element_link number, p_date date)is
       select pee.effective_end_date
       from   PAY_ELEMENT_ENTRIES_F pee
       where  pee.assignment_id        = p_assignment_id
       and    p_date between pee.effective_start_date
                             and pee.effective_end_date
       and    pee.element_link_id      = p_element_link
       and rownum < 2;

    cursor csr_get_ovrd_loc(p_assignment number, p_session_dt date) is
    select nvl(hsck.segment18, paf.location_id)
    from   HR_SOFT_CODING_KEYFLEX hsck,
           PER_ASSIGNMENTS_F      paf
    where  paf.assignment_id = p_assignment
    and    p_session_dt between paf.effective_start_date
                     and paf.effective_end_date
    and    hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id;

  begin

          l_validation_start_date := p_effective_start_date;

          /* Get the location of the assignment as of the default date */
          open csr_get_next_location(p_default_date);
          fetch csr_get_next_location into l_next_location, l_next_end_date;
          if csr_get_next_location%NOTFOUND
          then
             close csr_get_next_location;
             fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
             fnd_message.set_token('PROCEDURE',
                   'pay_us_emp_dt_tax_rules.pull_percentage');
             fnd_message.set_token('STEP','1');
             fnd_message.raise_error;
            end if;

           close csr_get_next_location;

           if l_next_location <> p_new_location_id then

              l_validation_end_date := p_effective_end_date;


              /* Pull back the effective start date of the existing %age records to
                 the validation start date */
              upd_del_entries(p_assignment_id  => p_assignment_id,
                             p_session_date   => p_default_date,
                             p_new_start_date => l_validation_start_date,
                             p_new_end_date   => null,
                             p_mode           => 'U');

              /* Do an update insert for the existing %age records with the same %age */

              change_entries(p_assignment_id     => p_assignment_id,
                             p_session_date      => p_default_date,
                             p_start_date        => l_validation_start_date,
                             p_end_date          => l_next_end_date,
                             p_mode              => 'INSERT_OLD');

              /* Zero out the time for the existing %age records for l_validation_start_date and
                 p_effective_end_date */

              zero_out_time(p_assignment_id       => p_assignment_id,
                          p_effective_start_date  => l_validation_start_date,
                          p_effective_end_date    => l_validation_end_date);

              /* Create %age records for the new location, for
                 every change in location */

              l_ovrd_percent := 0;
              l_percent := 100;
              open csr_get_ovrd_loc(p_assignment_id, p_session_date);
              fetch csr_get_ovrd_loc into l_ovrd_loc;
              if csr_get_ovrd_loc%found then
                 if l_ovrd_loc <> p_new_location_id then
                    l_ovrd_percent := 100;
                    l_percent := 0;
                 end if;
              end if;
              close csr_get_ovrd_loc;

              create_new_location_rec(p_assignment_id  => p_assignment_id,
                          p_validation_start_date => l_validation_start_date,
                          p_validation_end_date   => l_validation_end_date,
                          p_session_date          => p_session_date,
                          p_new_location_id       => p_new_location_id,
                          p_res_state_code        => null,
                          p_res_county_code       => null,
                          p_res_city_code         => null,
                          p_business_group        => p_business_group_id,
                          p_percent               => l_percent);

                 if l_ovrd_percent = 100 then
                    create_new_location_rec(p_assignment_id  => p_assignment_id,
                          p_validation_start_date => l_validation_start_date,
                          p_validation_end_date   => l_validation_end_date,
                          p_session_date          => p_session_date,
                          p_new_location_id       => l_ovrd_loc,
                          p_res_state_code        => null,
                          p_res_county_code       => null,
                          p_res_city_code         => null,
                          p_business_group        => p_business_group_id,
                          p_percent               => l_ovrd_percent);
                 end if;

          else  /* next location = p_new_location_id */

            /* get the end date of the entries corresponding to the default
                date as the effective start date */


            open csr_tax_element;
            fetch csr_tax_element into l_element_type_id;
            if csr_tax_element%NOTFOUND then
                close csr_tax_element;
                fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                fnd_message.set_token('PROCEDURE',
                        'pay_us_emp_dt_tax_rules.pull_percentage');
                fnd_message.set_token('STEP','2');
                fnd_message.raise_error;
            end if;
            close csr_tax_element;

            /* Get element link */
            l_element_link_id := hr_entry_api.get_link(
                                 P_assignment_id   => p_assignment_id,
                                 P_element_type_id => l_element_type_id,
                                 P_session_date    => p_session_date);

            if l_element_link_id is null or l_element_link_id = 0
            then
                fnd_message.set_name('PAY', 'HR_13140_TAX_ELEMENT_ERROR');
                fnd_message.set_token('1','VERTEX');
                fnd_message.raise_error;
            end if;

            open csr_get_next_date(l_element_link_id, p_default_date);
            fetch csr_get_next_date into l_validation_end_date;
            if csr_get_next_date%NOTFOUND
            then
                close csr_get_next_date;
                fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                fnd_message.set_token('PROCEDURE',
                   'pay_us_emp_dt_tax_rules.pull_percentage');
                fnd_message.set_token('STEP','3');
                fnd_message.raise_error;
            end if;

            close csr_get_next_date;


            /* set the effective start date of the entries to the
              new effective start date i.e. the l_validation_start_date */

            upd_del_entries(p_assignment_id  => p_assignment_id,
                            p_session_date   => p_default_date,
                            p_new_start_date => l_validation_start_date,
                            p_new_end_date   => null,
                            p_mode           => 'U');

            /* inserting rec for all jurisdcitions for the new date
               range */
            zero_out_time(p_assignment_id         => p_assignment_id,
                          p_effective_start_date  => l_validation_start_date,
                          p_effective_end_date    => l_validation_end_date);

            /* Create the tax rules records and the %age records for the
               new location - if required and set the city %age to 100 */

              l_ovrd_percent := 0;
              l_percent := 100;
              open csr_get_ovrd_loc(p_assignment_id, p_session_date);
              fetch csr_get_ovrd_loc into l_ovrd_loc;
              if csr_get_ovrd_loc%found then
                 if l_ovrd_loc <> p_new_location_id then
                    l_ovrd_percent := 100;
                    l_percent := 0;
                 end if;
              end if;
              close csr_get_ovrd_loc;

            create_new_location_rec(p_assignment_id   => p_assignment_id,
                            p_validation_start_date => l_validation_start_date,
                            p_validation_end_date  => l_validation_end_date,
                            p_session_date         => p_session_date,
                            p_new_location_id      => p_new_location_id,
                            p_res_state_code       => null,
                            p_res_county_code      => null,
                            p_res_city_code        => null,
                            p_business_group       => p_business_group_id,
                            p_percent              => l_percent);
                 if l_ovrd_percent = 100 then
                    create_new_location_rec(p_assignment_id  => p_assignment_id,
                          p_validation_start_date => l_validation_start_date,
                          p_validation_end_date   => l_validation_end_date,
                          p_session_date          => p_session_date,
                          p_new_location_id       => l_ovrd_loc,
                          p_res_state_code        => null,
                          p_res_county_code       => null,
                          p_res_city_code         => null,
                          p_business_group        => p_business_group_id,
                          p_percent               => l_ovrd_percent);

                 end if;



         end if;

end pull_percentage;


/* Name    : correct_percentage
   Purpose : This is a nasty little procedure which is ideally
             supposed to handle the tax rows for a 'correction'
             to the assignment's location.
*/

procedure correct_percentage (p_assignment_id        in number,
                              p_effective_start_date in date,
                              p_effective_end_date   in date,
                              p_session_date         in date,
                              p_new_location_id      in number,
                              p_business_group_id    in number,
                              p_ret_code             in out nocopy number,
                              p_ret_text             in out nocopy varchar2) is


  l_default_date      date;
  l_end_of_time       date := to_date('31/12/4712','dd/mm/yyyy');
  l_ret_code          number;
  l_ret_text          varchar2(240);
  l_pef_start_date    date;
  l_pef_new_start_date    date;
  l_pef_end_date      date;
  l_pef_prev_date     date;
  l_pef_next_date     date;
  l_next_location     number;
  l_next_loc_end_date date;
  l_payroll_installed boolean := FALSE;
  l_termination_flag   boolean := FALSE;
  l_validation_start_date date;
  l_validation_end_date   date;
  l_element_type_id   number;
  l_element_link_id   number;
  l_ovrd_loc          number;
  l_ovrd_percent      number;
  l_percent      number;
  /* Cursor to get the date on which the defaulting tax criteria was
     satisfied */

  cursor csr_get_eff_date (passignment number) is
  select min(ftr.effective_start_date)
  from PAY_US_EMP_FED_TAX_RULES_F ftr
  where ftr.assignment_id = passignment;

  /* Cursor to get the changes in assignment which in turn will help us
     in identifying the change in locations that has taken place within
     a given date range */

  cursor csr_get_locations (passignment number, p_start_date date,
                            p_end_date date) is
    select paf1.location_id,
           paf1.effective_start_date,
           paf1.effective_start_date - 1
    from per_assignments_f paf1
    where paf1.assignment_id = passignment
    and paf1.effective_start_date >= p_start_date
    and paf1.effective_end_date <= p_end_date
    order by 2;


   /* Get the Vertex element type */
   cursor csr_tax_element is
       select pet.element_type_id
       from   PAY_ELEMENT_TYPES_F pet
       where  pet.element_name          = 'VERTEX'
       and    p_session_date between pet.effective_start_date
                             and pet.effective_end_date;

   /* Cursor to check for multiple date effective records of the vertex
      element entries */
   cursor csr_multiple_rec(p_def_date date, p_ele_link number) is
      select 'Y'
      from pay_element_entries_f pef
      where pef.assignment_id = p_assignment_id
      and   pef.element_link_id = p_ele_link
      and   pef.effective_start_date >= p_def_date
      and   exists (select null
                    from pay_element_entries_f pee
                    where pee.assignment_id = p_assignment_id
                    and   pee.element_entry_id = pef.element_entry_id
                    and   pee.effective_start_date >= p_def_date
                    and   pee.effective_start_date <> pef.effective_start_date);

   /* Cursor to get the effective dates of the vertex element entries */

   cursor csr_ele_entry (p_element_link number)is
       select pee.effective_start_date,
             pee.effective_end_date,
             pee.effective_start_date -1
       from   PAY_ELEMENT_ENTRIES_F pee
       where  pee.assignment_id        = p_assignment_id
       and    p_session_date between pee.effective_start_date
                             and pee.effective_end_date
       and    pee.element_link_id      = p_element_link
       and rownum < 2;

  /* cursor to get the next location */

  cursor csr_get_next_location (p_next_eff_date date) is
  select paf.location_id
  from   PER_ASSIGNMENTS_F paf
  where  paf.assignment_id = p_assignment_id and
         p_next_eff_date between paf.effective_start_date
         and paf.effective_end_date;



  /* cursor to get the effective end date of the next element entry record */
  cursor csr_get_next_date (p_element_link number, p_date date)is
       select pee.effective_end_date
       from   PAY_ELEMENT_ENTRIES_F pee
       where  pee.assignment_id        = p_assignment_id
       and    p_date between pee.effective_start_date
                             and pee.effective_end_date
       and    pee.element_link_id      = p_element_link
       and rownum < 2;

    cursor csr_get_ovrd_loc(p_assignment number, p_session_dt date) is
    select nvl(hsck.segment18, paf.location_id)
    from   HR_SOFT_CODING_KEYFLEX hsck,
           PER_ASSIGNMENTS_F      paf
    where  paf.assignment_id = p_assignment
    and    p_session_dt between paf.effective_start_date
                     and paf.effective_end_date
    and    hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id;

   procedure backward_processing(p_assignment           in number,
                                 p_eff_start_date       in date,
                                 p_validation_start_date in out nocopy date,
                                 p_new_location         in number,
                                 p_element_link         in number) is

   l_prev_location         number := 0;
   l_prev_processing       boolean := FALSE;
   l_eff_prev_date         date;
   l_validation_start_date date;

   /* cursor to get the previous location */

   cursor csr_get_prev_location (p_prev_eff_date date) is
   select paf.location_id
   from   PER_ASSIGNMENTS_F paf
   where  paf.assignment_id = p_assignment and
          p_prev_eff_date between paf.effective_start_date
          and paf.effective_end_date;

   /* cursor to get the effective start date of the previous element entry record */
   cursor csr_get_prev_date (p_element_link number, p_date date)is
       select pee.effective_start_date
       from   PAY_ELEMENT_ENTRIES_F pee
       where  pee.assignment_id        = p_assignment
       and    pee.element_link_id      = p_element_link
       and    p_date between pee.effective_start_date
                             and pee.effective_end_date
       and rownum < 2;

   begin

          l_validation_start_date := p_validation_start_date;

         /* Get the effective_end_date of the previous
            assignment record */
         select p_eff_start_date -1
         into   l_eff_prev_date
         from dual;

         /* get the previous location of the assignment */

         open csr_get_prev_location(l_eff_prev_date);
         fetch csr_get_prev_location into l_prev_location;
         if csr_get_prev_location%FOUND then
         l_prev_processing := TRUE;
         else
         l_prev_processing := FALSE;
         end if;

         close csr_get_prev_location;

         if l_prev_processing and l_prev_location = p_new_location then

            l_validation_start_date := null;

            /* get the effective start date of the previous set of %age records */

            open csr_get_prev_date(p_element_link,l_eff_prev_date);
            fetch csr_get_prev_date into l_validation_start_date;
            if csr_get_prev_date%NOTFOUND then
               close csr_get_prev_date;
               fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
               fnd_message.set_token('PROCEDURE',
                           'pay_us_emp_dt_tax_rules.backward_processing');
               fnd_message.set_token('STEP','1');
               fnd_message.raise_error;
             end if;

             /* deleting the previous set */

             upd_del_entries(p_assignment_id  => p_assignment_id,
                            p_session_date   => l_validation_start_date,
                            p_new_start_date => null,
                            p_new_end_date   => null,
                            p_mode           => 'D');

             /* Pull back the effective start date of the current set */

             upd_del_entries(p_assignment_id  => p_assignment_id,
                         p_session_date   => p_eff_start_date,
                         p_new_start_date => l_validation_start_date,
                         p_new_end_date   => null,
                         p_mode           => 'U');

              /* Assign the new validation start date */

              p_validation_start_date := l_validation_start_date;

          end if;

   end backward_processing;

  begin

  hr_utility.set_location('pay_us_emp_dt_tax_rules.correct_percentage',1);
    l_payroll_installed := hr_utility.chk_product_install(p_product => 'Oracle Payroll',
                                                          p_legislation => 'US');

    /* Get effective Start date of the Federal Tax Rules record */

  hr_utility.set_location('pay_us_emp_dt_tax_rules.correct_percentage',2);
    open  csr_get_eff_date(p_assignment_id);

    fetch csr_get_eff_date into l_default_date;

    if l_default_date is null then
         close csr_get_eff_date;
         fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token('PROCEDURE',
                 'pay_us_emp_dt_tax_rules.correct_percentage');
         fnd_message.set_token('STEP','1');
         fnd_message.raise_error;
    end if;

    close csr_get_eff_date;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.correct_percentage',3);
    open csr_tax_element;
    fetch csr_tax_element into l_element_type_id;
    if csr_tax_element%NOTFOUND then
       close csr_tax_element;
       fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
       fnd_message.set_token('PROCEDURE',
                 'pay_us_emp_dt_tax_rules.correct_percentage');
       fnd_message.set_token('STEP','2');
       fnd_message.raise_error;
    end if;
    close csr_tax_element;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.correct_percentage',4);
    /* Get element link */
    l_element_link_id := hr_entry_api.get_link(
                             P_assignment_id   => p_assignment_id,
                             P_element_type_id => l_element_type_id,
                             P_session_date    => p_session_date);

    if l_element_link_id is null or l_element_link_id = 0 then
        fnd_message.set_name('PAY', 'HR_13140_TAX_ELEMENT_ERROR');
        fnd_message.set_token('1','VERTEX');
        fnd_message.raise_error;
    end if;


    /* Let's handle the condition where there is just one set of
       %age records - from the default date till end of time or the
       termination date.

            | Session date
            v
         T1        L1
    Asg  |----------------------------------------
    SL1  |----------------------------------------
    COL1 |----------------------------------------
    CIL1 |----------------------------------------

            | Session date
            v
         T1   T2    L1
    Asg  |----------------------------------------
    SL1       |----------------------------------------
    COL1      |----------------------------------------
    CIL1      |----------------------------------------

    The assignment record has not been broken up and L1 is corrected
    to L2. In the first scenario the defaulting criteria had been met as of the
    assignment effective start date. So, the tax records were created from time
    T1 i.e. the effective start date of the assignment. However, in the second case
    the defaulting criteria was met as of the date T2. So the tax records were created
    as of date T2 */

    if (p_effective_start_date <= l_default_date and
        p_effective_end_date   = l_end_of_time) then
  hr_utility.set_location('pay_us_emp_dt_tax_rules.correct_percentage',5);

        if l_payroll_installed then
          /* Get all of the percentage records and set the percentage to zero */

  hr_utility.set_location('pay_us_emp_dt_tax_rules.correct_percentage',6);
          zero_out_time(p_assignment_id         => p_assignment_id,
                        p_effective_start_date  => p_effective_start_date,
                        p_effective_end_date    => p_effective_end_date);
        end if;

        /* Create the tax rules records and the %age records for the
           new location - if required and set the city %age to 100 */

  hr_utility.set_location('pay_us_emp_dt_tax_rules.correct_percentage',7);

        l_ovrd_percent := 0;
        l_percent := 100;
        open csr_get_ovrd_loc(p_assignment_id, p_session_date);
        fetch csr_get_ovrd_loc into l_ovrd_loc;
        if csr_get_ovrd_loc%found then
           if l_ovrd_loc <> p_new_location_id then
            l_ovrd_percent := 100;
            l_percent := 0;
           end if;
        end if;
        close csr_get_ovrd_loc;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.correct_percentage',8);
        create_new_location_rec(p_assignment_id    => p_assignment_id,
                             p_validation_start_date => p_effective_start_date,
                             p_validation_end_date   => p_effective_end_date,
                             p_session_date          => p_session_date,
                             p_new_location_id       => p_new_location_id,
                             p_res_state_code        => null,
                             p_res_county_code       => null,
                             p_res_city_code         => null,
                             p_business_group        => p_business_group_id,
                             p_percent               => l_percent);
  hr_utility.set_location('pay_us_emp_dt_tax_rules.correct_percentage',9);
        if l_ovrd_percent = 100 then
  hr_utility.set_location('pay_us_emp_dt_tax_rules.correct_percentage',10);
           create_new_location_rec(p_assignment_id  => p_assignment_id,
                          p_validation_start_date => p_effective_start_date,
                          p_validation_end_date   => p_effective_end_date,
                          p_session_date          => p_session_date,
                          p_new_location_id       => l_ovrd_loc,
                          p_res_state_code        => null,
                          p_res_county_code       => null,
                          p_res_city_code         => null,
                          p_business_group        => p_business_group_id,
                          p_percent               => l_ovrd_percent);
  hr_utility.set_location('pay_us_emp_dt_tax_rules.correct_percentage',11);
        end if;


    else /* multiple locations */

       /* Get the effective start date, effective end date and (effective start date - 1)
          of the %age record for the session date */

       open  csr_ele_entry(l_element_link_id);

       fetch csr_ele_entry into l_pef_start_date, l_pef_end_date,
                                l_pef_prev_date;

       if csr_ele_entry%NOTFOUND then
           close csr_ele_entry;
           fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
           fnd_message.set_token('PROCEDURE',
                   'pay_us_emp_dt_tax_rules.correct_percentage');
           fnd_message.set_token('STEP','2');
           fnd_message.raise_error;
       end if;

       close csr_ele_entry;

       /* Set the validation start date */

       if p_effective_start_date >= l_pef_start_date then
           l_validation_start_date := p_effective_start_date;
       else
           l_validation_start_date := l_pef_start_date;
       end if;

       /* Time to take care of the multiple assignment records scenario
          - assignment end date less than the element entries end date

                | Session Date
                V
             L1     L1
       Asg  |----|-------------------------------------------

       %age |------------------------------------------------

                | Session Date
                V
             L1     L1     L2         L2   L1      L3
       Asg  |----|-------|-----------|---|-------|-----------

       %age |------------|---------------|-------|-----------

                                 | Session Date
                                 V
             L1     L1     L2     L2   L2   L1      L3
       Asg  |----|-------|-----|------|--|-------|-----------

       %age |------------|---------------|-------|-----------

                            | Session Date
                            V
             L1     L1     L2     L2   L2   L1      L3
       Asg  |----|-------|-----|------|--|-------|-----------

       %age |------------|---------------|-------|-----------

                | Session Date
                V
             L1     L1     L2         L2   L1      L3
       Asg  |----|-------|-----------|---|-------|-----------

       %age    |---------|---------------|-------|-----------

       if the effective start date of the assignment record is less than
       or equal to the minimum of effective start date (i.e. the default date )
       of the vertex element entries then only the forward processing is required.
       However, if the effective start date of the assignment is equal to the
       effective start date of the element entries and the effective start date of the
       element entries is not the default date then the backward processing is also
       required .
       */


        if p_effective_end_date < l_pef_end_date then

          /* Forward processing */

          l_validation_end_date := p_effective_end_date;

          /* Get the effective start date of the next assignment record */
          select p_effective_end_date + 1
          into   l_pef_new_start_date
          from   sys.DUAL;

          /* Do an update insert for the same %age as of the l_pef_new_start_date */
          change_entries(p_assignment_id     => p_assignment_id,
                         p_session_date      => l_pef_new_start_date,
                         p_start_date        => l_pef_start_date,
                         p_end_date          => l_pef_end_date,
                         p_mode              => 'INSERT_OLD');

          if p_effective_start_date > l_pef_start_date then

             /*
                         | Session Date
                         V
                    L1   L1  L1   L2         L2   L1      L3
             Asg  |----|----|--|-----------|---|-------|-----------

             %age |------------|---------------|-------|-----------
             */

             /* Do an update insert for the same %age as of the l_validation_start_date */

             change_entries(p_assignment_id     => p_assignment_id,
                            p_session_date      => l_validation_start_date,
                            p_start_date        => l_pef_start_date,
                            p_end_date          => l_validation_end_date,
                            p_mode              => 'INSERT_OLD');

          elsif p_effective_start_date = l_pef_start_date and
                l_pef_start_date <> l_default_date then

                /*
                                     | Session Date
                                     V
                      L1     L1     L2     L2   L2   L1      L3
                Asg  |----|-------|-----|------|--|-------|-----------

                %age |------------|---------------|-------|-----------

                */

                /* Backward processing */

                backward_processing(p_assignment        => p_assignment_id,
                                 p_eff_start_date       => p_effective_start_date,
                                 p_validation_start_date => l_validation_start_date,
                                 p_new_location         => p_new_location_id,
                                 p_element_link         => l_element_link_id);
          end if;

          /* set the %age for all of the existing %age records to zero for the
             l_validation_start_date and l_validation_end_date */

          zero_out_time(p_assignment_id     => p_assignment_id,
                    p_effective_start_date  => l_validation_start_date,
                    p_effective_end_date    => l_validation_end_date);

          /* create %age records for the new location, for every change in location
             of an assignment */

          l_ovrd_percent := 0;
          l_percent := 100;
          open csr_get_ovrd_loc(p_assignment_id, p_session_date);
          fetch csr_get_ovrd_loc into l_ovrd_loc;
          if csr_get_ovrd_loc%found then
             if l_ovrd_loc <> p_new_location_id then
                l_ovrd_percent := 100;
                l_percent := 0;
              end if;
          end if;
          close csr_get_ovrd_loc;

          create_new_location_rec(p_assignment_id         => p_assignment_id,
                                  p_validation_start_date => l_validation_start_date,
                                  p_validation_end_date   => l_validation_end_date,
                                  p_session_date          => p_session_date,
                                  p_new_location_id       => p_new_location_id,
                                  p_res_state_code        => null,
                                  p_res_county_code       => null,
                                  p_res_city_code         => null,
                                  p_business_group        => p_business_group_id,
                                  p_percent               => l_percent);
        if l_ovrd_percent = 100 then
           create_new_location_rec(p_assignment_id  => p_assignment_id,
                          p_validation_start_date => l_validation_start_date,
                          p_validation_end_date   => l_validation_end_date,
                          p_session_date          => p_session_date,
                          p_new_location_id       => l_ovrd_loc,
                          p_res_state_code        => null,
                          p_res_county_code       => null,
                          p_res_city_code         => null,
                          p_business_group        => p_business_group_id,
                          p_percent               => l_ovrd_percent);
        end if;


          /* The effective end date of the location record is same as the
             effective end date of the corresponding %age record.

                      | Session Date
                      V
                L1     L1     L2         L2   L1      L3
          Asg  |----|-------|-----------|---|-------|-----------

          %age |------------|---------------|-------|-----------

                                                      | Session Date
                                                      V
                L1     L1     L2         L2   L1      L1
          Asg  |----|-------|-----------|---|-------|-----------

          %age |------------|---------------|-------------------


          */

        elsif p_effective_end_date = l_pef_end_date then

          l_validation_start_date := p_effective_start_date;
          l_validation_end_date := l_pef_end_date;

          if l_pef_end_date <> l_end_of_time then

             select l_validation_end_date + 1
             into l_pef_next_date
             from SYS.DUAL;

             /* Get the next location of the assignment */
             open csr_get_next_location(l_pef_next_date);
             fetch csr_get_next_location into l_next_location;
             if csr_get_next_location%NOTFOUND
             then
                l_termination_flag := TRUE;
             else
                l_termination_flag := FALSE;
             end if;
             close csr_get_next_location;

          end if;


          /* The effective end date of the location record is same as the
              effective end date of the corresponding %age record. However
              the assignment has been terminated or is till end of time.

                                                | Session Date
                                                V
                   L1     L1     L2         L2   L1
            Asg  |----|-------|-----------|---|-------|

            %age |------------|---------------|-------|

                                                  | Session Date
                                                  V
                   L1     L1     L2         L2    L1
            Asg  |----|-------|-----------|-----|-----|

            %age |------------|---------------|-------|

                                                | Session Date
                                                V
                   L1     L1     L2         L2   L1
            Asg  |----|-------|-----------|---|-------

            %age |------------|---------------|-------

                                                  | Session Date
                                                  V
                   L1     L1     L2         L2    L1
            Asg  |----|-------|-----------|-----|-----

            %age |------------|---------------|-------


            We can possibly have 2 scenarios of effective start date -
            p_effective start date = l_pef_effective_start_date or
            p_effective start date > l_pef_effective_start_date
            We can not have the scenario of
            p_effective start date < l_pef_effective_start_date under this
            condition. Only in the case of the first %age record , we might
            have this scenario when the tax %age records get created from a
            date later than the assignment's start date
           */

            if (l_termination_flag or l_pef_end_date = l_end_of_time) then

              if p_effective_start_date > l_pef_start_date then

                  if l_termination_flag then

                     /* Do an update insert as of the l_validation_start_date */

                     change_entries(p_assignment_id     => p_assignment_id,
                                    p_session_date      => l_validation_start_date,
                                    p_start_date        => l_pef_start_date,
                                    p_end_date          => l_pef_end_date,
                                    p_mode              => 'UPDATE_CHANGE_INSERT');

                  elsif l_pef_end_date = l_end_of_time then

                     /* Do an update as of the l_validation_start_date */

                     change_entries(p_assignment_id     => p_assignment_id,
                                    p_session_date      => l_validation_start_date,
                                    p_start_date        => l_pef_start_date,
                                    p_end_date          => l_pef_end_date,
                                    p_mode              => 'UPDATE');

                  end if;

                 /* zero out time for the current element entries for
                 l_validation_start_date and l_validation_end_date */

                 zero_out_time(p_assignment_id     => p_assignment_id,
                           p_effective_start_date  => l_validation_start_date,
                           p_effective_end_date    => l_validation_end_date);


                 /* Create %age records for the new location, for
                    every change in location */

                l_ovrd_percent := 0;
                l_percent := 100;
                open csr_get_ovrd_loc(p_assignment_id, p_session_date);
                fetch csr_get_ovrd_loc into l_ovrd_loc;
                if csr_get_ovrd_loc%found then
                   if l_ovrd_loc <> p_new_location_id then
                      l_ovrd_percent := 100;
                      l_percent := 0;
                    end if;
                end if;
                close csr_get_ovrd_loc;

                 create_new_location_rec(p_assignment_id  => p_assignment_id,
                          p_validation_start_date => l_validation_start_date,
                          p_validation_end_date   => l_validation_end_date,
                          p_session_date          => p_session_date,
                          p_new_location_id       => p_new_location_id,
                          p_res_state_code        => null,
                          p_res_county_code       => null,
                          p_res_city_code         => null,
                          p_business_group        => p_business_group_id,
                          p_percent               => l_percent);
                  if l_ovrd_percent = 100 then
                     create_new_location_rec(p_assignment_id  => p_assignment_id,
                          p_validation_start_date => l_validation_start_date,
                          p_validation_end_date   => l_validation_end_date,
                          p_session_date          => p_session_date,
                          p_new_location_id       => l_ovrd_loc,
                          p_res_state_code        => null,
                          p_res_county_code       => null,
                          p_res_city_code         => null,
                          p_business_group        => p_business_group_id,
                          p_percent               => l_ovrd_percent);
                  end if;

              elsif p_effective_start_date = l_pef_start_date then

                /* Backward processing */
                backward_processing(p_assignment        => p_assignment_id,
                                 p_eff_start_date       => p_effective_start_date,
                                 p_validation_start_date => l_validation_start_date,
                                 p_new_location         => p_new_location_id,
                                 p_element_link         => l_element_link_id);

                 /* zero out time for the date range between p_validation_start_date
                    and p_validation_end_date */

                 zero_out_time(p_assignment_id     => p_assignment_id,
                           p_effective_start_date  => l_validation_start_date,
                           p_effective_end_date    => l_validation_end_date);

                 /* Create the tax rules records and the %age records for the
                    new location - if required and set the city %age to 100 */

                l_ovrd_percent := 0;
                l_percent := 100;
                open csr_get_ovrd_loc(p_assignment_id, p_session_date);
                fetch csr_get_ovrd_loc into l_ovrd_loc;
                if csr_get_ovrd_loc%found then
                   if l_ovrd_loc <> p_new_location_id then
                      l_ovrd_percent := 100;
                      l_percent := 0;
                    end if;
                end if;
                close csr_get_ovrd_loc;

                 create_new_location_rec(p_assignment_id   => p_assignment_id,
                                 p_validation_start_date => l_validation_start_date,
                                 p_validation_end_date  => l_validation_end_date,
                                 p_session_date         => p_session_date,
                                 p_new_location_id      => p_new_location_id,
                                 p_res_state_code       => null,
                                 p_res_county_code      => null,
                                 p_res_city_code        => null,
                                 p_business_group       => p_business_group_id,
                                 p_percent              => l_percent);
                  if l_ovrd_percent = 100 then
                     create_new_location_rec(p_assignment_id  => p_assignment_id,
                          p_validation_start_date => l_validation_start_date,
                          p_validation_end_date   => l_validation_end_date,
                          p_session_date          => p_session_date,
                          p_new_location_id       => l_ovrd_loc,
                          p_res_state_code        => null,
                          p_res_county_code       => null,
                          p_res_city_code         => null,
                          p_business_group        => p_business_group_id,
                          p_percent               => l_ovrd_percent);
                  end if;


             end if;  /* check for the p_effective_start_date > or = to the
                         l_pef_start_date */

            else /* Not a terminated assignment */

              /* Processing for the condition when next location <> new location.

                          | Session Date
                          V
                          L1          L2         L2   L1      L3
                 Asg  |------------|-----------|---|-------|-----------

                 %age |------------|---------------|-------|-----------

                                                | Session Date
                                                V
                          L1          L2         L2   L1      L3
                 Asg  |------------|-----------|---|-------|-----------

                 %age |------------|---------------|-------|-----------

                                                | Session Date
                                                V
                          L1            L2            L1      L3
                 Asg  |------------|---------------|-------|-----------

                 %age |------------|---------------|-------|-----------

                            | Session Date
                            V
                          L1          L2         L2   L1      L3
                 Asg  |------------|-----------|---|-------|-----------

                 %age      |-------|---------------|-------|-----------

                 In the above examples if we correct location as of the session date
                 to L3 then new location <> next location.
               */

                l_validation_start_date := p_effective_start_date;
                l_validation_end_date := l_pef_end_date;

                if p_effective_start_date > l_pef_start_date then

                  /*
                                               | Session Date
                                               V
                            L1         L2     L2 (L5)   L3      L4
                   Asg  |------------|-------|-- ----|-------|-----------

                   %age |------------|---------------|-------|-----------


                                               | Session Date
                                               V
                            L1         L2     L2 (L3)   L3      L4
                   Asg  |------------|-------|-- ----|-------|-----------

                   %age |------------|---------------|-------|-----------

                   Note :  L2 (L5) means L2 changed to L5. Similarly
                           L2 (L3) means L2 changed to L3.
                   */

                   /* Do an update insert as of the l_validation_start_date */

                   change_entries(p_assignment_id     => p_assignment_id,
                                  p_session_date      => l_validation_start_date,
                                  p_start_date        => l_pef_start_date,
                                  p_end_date          => l_pef_end_date,
                                  p_mode              => 'UPDATE_CHANGE_INSERT');

                   /* next location = p_new_location_id */

                   if l_next_location = p_new_location_id then

                      /* Processing for the condition when next location = new location.

                                                      | Session Date
                                                      V
                                L1          L2         L2   L1      L3
                       Asg  |------------|-----------|---|-------|-----------

                       %age |------------|---------------|-------|-----------

                      In the above example if we correct L2 as of the session date
                      to L1 then new location = next location.  */


                      /* Get the end date of the next %age records */
                      open csr_get_next_date(l_element_link_id,l_pef_next_date);
                      fetch csr_get_next_date into l_next_loc_end_date;
                      if csr_get_next_date%NOTFOUND then
                         close csr_get_next_date;
                         fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                         fnd_message.set_token('PROCEDURE',
                         'pay_us_emp_dt_tax_rules.correct_percentage');
                         fnd_message.set_token('STEP','4');
                         fnd_message.raise_error;
                      end if;

                      close csr_get_next_date;

                      /* set the validation end date to the end date of the next
                         set of %age records */

                      l_validation_end_date   := l_next_loc_end_date;

                      /* deleting the current set */

                      upd_del_entries(p_assignment_id  => p_assignment_id,
                                      p_session_date   => l_validation_start_date,
                                      p_new_start_date => null,
                                      p_new_end_date   => null,
                                      p_mode           => 'D');

                      /* Pull  the next set to the p_validation start date */

                      upd_del_entries(p_assignment_id  => p_assignment_id,
                                      p_session_date   => l_pef_next_date,
                                      p_new_start_date => l_validation_start_date,
                                      p_new_end_date   => null,
                                      p_mode           => 'U');

                      /* call zero_out_time for p_validation_start_date and
                         p_validation_end_date */

                      zero_out_time(p_assignment_id     => p_assignment_id,
                                p_effective_start_date  => l_validation_start_date,
                                p_effective_end_date    => l_validation_end_date);

                   end if;

                   /* Create the tax rules records and the %age records for the
                      new location - if required and set the city %age to 100 */

                l_ovrd_percent := 0;
                l_percent := 100;
                open csr_get_ovrd_loc(p_assignment_id, p_session_date);
                fetch csr_get_ovrd_loc into l_ovrd_loc;
                if csr_get_ovrd_loc%found then
                   if l_ovrd_loc <> p_new_location_id then
                      l_ovrd_percent := 100;
                      l_percent := 0;
                    end if;
                end if;
                close csr_get_ovrd_loc;


                   create_new_location_rec(p_assignment_id   => p_assignment_id,
                                     p_validation_start_date => l_validation_start_date,
                                      p_validation_end_date  => l_validation_end_date,
                                      p_session_date         => p_session_date,
                                      p_new_location_id      => p_new_location_id,
                                      p_res_state_code       => null,
                                      p_res_county_code      => null,
                                      p_res_city_code        => null,
                                      p_business_group       => p_business_group_id,
                                      p_percent              => l_percent);
                  if l_ovrd_percent = 100 then
                     create_new_location_rec(p_assignment_id  => p_assignment_id,
                          p_validation_start_date => l_validation_start_date,
                          p_validation_end_date   => l_validation_end_date,
                          p_session_date          => p_session_date,
                          p_new_location_id       => l_ovrd_loc,
                          p_res_state_code        => null,
                          p_res_county_code       => null,
                          p_res_city_code         => null,
                          p_business_group        => p_business_group_id,
                          p_percent               => l_ovrd_percent);
                  end if;

                elsif p_effective_start_date = l_pef_start_date then


                   /*
                                               | Session Date
                                               V
                            L1          L2 (L5)          L3      L4
                   Asg  |------------|---------------|-------|-----------

                   %age |------------|---------------|-------|-----------

                                               | Session Date
                                               V
                            L1          L2 (L1)          L3      L4
                   Asg  |------------|---------------|-------|-----------

                   %age |------------|---------------|-------|-----------

                                                | Session Date
                                                V
                             L1          L2 (L1)          L1      L4
                   Asg  |------------|---------------|-------|-----------

                   %age |------------|---------------|-------|-----------


                   Note :  L2 (L5) means L2 changed to L5. Similarly
                           L2 (L1) means L2 changed to L1.
                   */

                   /* Backward processing */
                   backward_processing(p_assignment        => p_assignment_id,
                                    p_eff_start_date       => p_effective_start_date,
                                    p_validation_start_date => l_validation_start_date,
                                    p_new_location         => p_new_location_id,
                                    p_element_link         => l_element_link_id);

                   /* next location = p_new_location_id */

                   if l_next_location = p_new_location_id then

                      /* Processing for the condition when next location = new location.

                                                  | Session Date
                                                  V
                                L1          L2 (L1)            L1      L3
                       Asg  |------------|---------------|-------|-----------

                       %age |------------|---------------|-------|-----------

                                                  | Session Date
                                                  V
                                L1          L2 (L3)          L3      L4
                       Asg  |------------|---------------|-------|-----------

                       %age |------------|---------------|-------|-----------

                      In the above example if we correct L2 as of the session date
                      to L1 then new location = next location.  */


                      /* Get the end date of the next %age records */
                      open csr_get_next_date(l_element_link_id,l_pef_next_date);
                      fetch csr_get_next_date into l_next_loc_end_date;
                      if csr_get_next_date%NOTFOUND then
                         close csr_get_next_date;
                         fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                         fnd_message.set_token('PROCEDURE',
                         'pay_us_emp_dt_tax_rules.correct_percentage');
                         fnd_message.set_token('STEP','4');
                         fnd_message.raise_error;
                      end if;

                      close csr_get_next_date;

                      /* set the validation end date to the end date of the next
                         set of %age records */

                      l_validation_end_date   := l_next_loc_end_date;

                      /* deleting the current set */

                      upd_del_entries(p_assignment_id  => p_assignment_id,
                                      p_session_date   => l_validation_start_date,
                                      p_new_start_date => null,
                                      p_new_end_date   => null,
                                      p_mode           => 'D');

                      /* Pull  the next set to the p_validation start date */

                      upd_del_entries(p_assignment_id  => p_assignment_id,
                                      p_session_date   => l_pef_next_date,
                                      p_new_start_date => l_validation_start_date,
                                      p_new_end_date   => null,
                                      p_mode           => 'U');

                  end if;

                  /* zero out time for the date range between p_validation_start_date
                     and p_validation_end_date */

                  zero_out_time(p_assignment_id     => p_assignment_id,
                            p_effective_start_date  => l_validation_start_date,
                            p_effective_end_date    => l_validation_end_date);

                  /* Create the tax rules records and the %age records for the
                     new location - if required and set the city %age to 100 */

                l_ovrd_percent := 0;
                l_percent := 100;
                open csr_get_ovrd_loc(p_assignment_id, p_session_date);
                fetch csr_get_ovrd_loc into l_ovrd_loc;
                if csr_get_ovrd_loc%found then
                   if l_ovrd_loc <> p_new_location_id then
                      l_ovrd_percent := 100;
                      l_percent := 0;
                    end if;
                end if;
                close csr_get_ovrd_loc;

                  create_new_location_rec(p_assignment_id   => p_assignment_id,
                                    p_validation_start_date => l_validation_start_date,
                                     p_validation_end_date  => l_validation_end_date,
                                     p_session_date         => p_session_date,
                                     p_new_location_id      => p_new_location_id,
                                     p_res_state_code       => null,
                                     p_res_county_code      => null,
                                     p_res_city_code        => null,
                                     p_business_group       => p_business_group_id,
                                      p_percent              => l_percent);
                  if l_ovrd_percent = 100 then
                     create_new_location_rec(p_assignment_id  => p_assignment_id,
                          p_validation_start_date => l_validation_start_date,
                          p_validation_end_date   => l_validation_end_date,
                          p_session_date          => p_session_date,
                          p_new_location_id       => l_ovrd_loc,
                          p_res_state_code        => null,
                          p_res_county_code       => null,
                          p_res_city_code         => null,
                          p_business_group        => p_business_group_id,
                          p_percent               => l_ovrd_percent);
                  end if;


               end if;

        end if; /* terminated /unterminated assignment */

       end if; /* same/different effective end date */

    end if; /* Single and multiple locations */

end correct_percentage;

procedure update_percentage (p_assignment_id        in number,
                             p_effective_start_date in date,
                             p_effective_end_date   in date,
                             p_session_date         in date,
                             p_new_location_id      in number,
                             p_business_group_id    in number,
                             p_mode                 in varchar2,
                             p_ret_code             in out nocopy number,
                             p_ret_text             in out nocopy varchar2) is

 l_validation_start_date    date := null;
 l_validation_end_date      date := null;
 l_prev_end_date            date := null;
 l_next_location            number;
 l_pef_start_date           date;
 l_pef_end_date             date;
 l_pef_next_date            date;
 l_termination_flag         boolean:= FALSE;
 l_element_type_id          number;
 l_element_link_id          number;
 l_new_session_date         date;
 l_ovrd_loc              number;
 l_ovrd_percent          number := 0;
 l_percent               number := 100;


   /* Get the Vertex element type */
   cursor csr_tax_element is
       select pet.element_type_id
       from   PAY_ELEMENT_TYPES_F pet
       where  pet.element_name          = 'VERTEX'
       and    p_session_date between pet.effective_start_date
                             and pet.effective_end_date;

  /* Cursor to get the effective dates of the %age record for the
     session date */

  cursor csr_get_dates(p_element_link number, p_session_dt date) is
  select pef.effective_start_date,
         pef.effective_end_date,
         pef.effective_end_date + 1
  from   PAY_ELEMENT_ENTRIES_F pef
  where  pef.assignment_id = p_assignment_id
  and    p_session_dt between pef.effective_start_date
         and pef.effective_end_date
  and    pef.element_link_id      = p_element_link
  and    rownum < 2;

  /* cursor to get the next location */

  cursor csr_get_next_location (p_next_eff_date date) is
  select paf.location_id
  from   PER_ASSIGNMENTS_F paf
  where  paf.assignment_id = p_assignment_id and
         p_next_eff_date between paf.effective_start_date
         and paf.effective_end_date;

  /* cursor to get the effective end date of the next element entry record */
  cursor csr_get_next_date (p_element_link number, p_date date)is
       select pee.effective_end_date
       from   PAY_ELEMENT_ENTRIES_F pee
       where  pee.assignment_id        = p_assignment_id
       and    p_date between pee.effective_start_date
                             and pee.effective_end_date
       and    pee.element_link_id      = p_element_link
       and rownum < 2;

    cursor csr_get_ovrd_loc(p_assignment number, p_session_dt date) is
    select nvl(hsck.segment18, paf.location_id)
    from   HR_SOFT_CODING_KEYFLEX hsck,
           PER_ASSIGNMENTS_F      paf
    where  paf.assignment_id = p_assignment
    and    p_session_dt between paf.effective_start_date
                     and paf.effective_end_date
    and    hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id;



begin

    /* Check for Update

                        | Session date
                        V
    |-------------------------------------

    */

    if p_mode in ('UPDATE','UPDATE_OVERRIDE') then

       l_validation_start_date := p_session_date;
       l_validation_end_date       := to_date('31/12/4712','dd/mm/yyyy');

       /* Do an update for the element entries for all of the
          existing jurisdictions of the assignment */

       change_entries(p_assignment_id     => p_assignment_id,
                      p_session_date      => p_session_date,
                      p_start_date        => p_effective_start_date,
                      p_end_date          => p_effective_end_date,
                      p_mode              => p_mode);

       /* Create the tax rules records and the %age records for the
          new location - if required and set the city %age to 100 */

       l_ovrd_percent := 0;
       l_percent := 100;
       open csr_get_ovrd_loc(p_assignment_id, p_session_date);
       fetch csr_get_ovrd_loc into l_ovrd_loc;
       if csr_get_ovrd_loc%found then
          if l_ovrd_loc <> p_new_location_id then
             l_ovrd_percent := 100;
             l_percent := 0;
          end if;
       end if;
       close csr_get_ovrd_loc;

       create_new_location_rec(p_assignment_id   => p_assignment_id,
                         p_validation_start_date => l_validation_start_date,
                          p_validation_end_date  => l_validation_end_date,
                          p_session_date         => p_session_date,
                          p_new_location_id      => p_new_location_id,
                          p_res_state_code       => null,
                          p_res_county_code      => null,
                          p_res_city_code        => null,
                          p_business_group       => p_business_group_id,
                          p_percent              => l_percent);
       if l_ovrd_percent = 100 then
          create_new_location_rec(p_assignment_id  => p_assignment_id,
                          p_validation_start_date => l_validation_start_date,
                          p_validation_end_date   => l_validation_end_date,
                          p_session_date          => p_session_date,
                          p_new_location_id       => l_ovrd_loc,
                          p_res_state_code        => null,
                          p_res_county_code       => null,
                          p_res_city_code         => null,
                          p_business_group        => p_business_group_id,
                          p_percent               => l_ovrd_percent);
       end if;


     elsif p_mode = 'UPDATE_CHANGE_INSERT' then

       open csr_tax_element;

       fetch csr_tax_element into l_element_type_id;

       if csr_tax_element%NOTFOUND then

           close csr_tax_element;
           fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
           fnd_message.set_token('PROCEDURE',
                   'pay_us_emp_dt_tax_rules.update_percentage');
           fnd_message.set_token('STEP','1');
           fnd_message.raise_error;

       end if;

       close csr_tax_element;

       /* Get element link */

       l_element_link_id := hr_entry_api.get_link(
                                 P_assignment_id   => p_assignment_id,
                                 P_element_type_id => l_element_type_id,
                                 P_session_date    => p_session_date);

       if l_element_link_id is null or l_element_link_id = 0 then

           fnd_message.set_name('PAY', 'HR_13140_TAX_ELEMENT_ERROR');
           fnd_message.set_token('1','VERTEX');
           fnd_message.raise_error;

       end if;

       /* Get the effective start date, effective end date and (effective end date + 1)
        of the %age record for the session date */

       open  csr_get_dates(l_element_link_id, p_session_date);

       fetch csr_get_dates into l_pef_start_date, l_pef_end_date, l_pef_next_date;

       if csr_get_dates%NOTFOUND then

           close csr_get_dates;
           fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
           fnd_message.set_token('PROCEDURE',
                   'pay_us_emp_dt_tax_rules.update_percentage');
           fnd_message.set_token('STEP','2');
           fnd_message.raise_error;

       end if;

       close csr_get_dates;

       if p_effective_end_date <> l_pef_end_date then

         l_validation_start_date := p_session_date;
         l_validation_end_date   := p_effective_end_date;


         /* First do an update insert with the existing value of the
            existing jurisdictions as of the p_effective_end_date + 1 */

         select p_effective_end_date + 1
         into l_new_session_date
         from DUAL;

         change_entries(p_assignment_id     => p_assignment_id,
                        p_session_date      => l_new_session_date,
                        p_start_date        => l_pef_start_date,
                        p_end_date          => l_pef_end_date,
                        p_mode              => 'INSERT_OLD');


         /* Again do an update insert  for the element entries for all of the
            existing jurisdictions of the assignment, as of the session date */

         change_entries(p_assignment_id     => p_assignment_id,
                        p_session_date      => p_session_date,
                        p_start_date        => l_pef_start_date,
                        p_end_date          => l_validation_end_date,
                        p_mode              => 'UPDATE_CHANGE_INSERT');

         /* Create the tax rules records and the %age records for the
            new location - if required and set the city %age to 100 */

       l_ovrd_percent := 0;
       l_percent := 100;
       open csr_get_ovrd_loc(p_assignment_id, p_session_date);
       fetch csr_get_ovrd_loc into l_ovrd_loc;
       if csr_get_ovrd_loc%found then
          if l_ovrd_loc <> p_new_location_id then
             l_ovrd_percent := 100;
             l_percent := 0;
          end if;
       end if;
       close csr_get_ovrd_loc;


         create_new_location_rec(p_assignment_id   => p_assignment_id,
                         p_validation_start_date => l_validation_start_date,
                          p_validation_end_date  => l_validation_end_date,
                          p_session_date         => p_session_date,
                          p_new_location_id      => p_new_location_id,
                          p_res_state_code       => null,
                          p_res_county_code      => null,
                          p_res_city_code        => null,
                          p_business_group       => p_business_group_id,
                          p_percent              => l_percent);
       if l_ovrd_percent = 100 then
          create_new_location_rec(p_assignment_id  => p_assignment_id,
                          p_validation_start_date => l_validation_start_date,
                          p_validation_end_date   => l_validation_end_date,
                          p_session_date          => p_session_date,
                          p_new_location_id       => l_ovrd_loc,
                          p_res_state_code        => null,
                          p_res_county_code       => null,
                          p_res_city_code         => null,
                          p_business_group        => p_business_group_id,
                          p_percent               => l_ovrd_percent);
       end if;



        else /* the end dates of the assignment record and the %age rec.
                are the same */

           l_validation_start_date := p_session_date;
           l_validation_end_date := l_pef_end_date;

           /* Get the next location of the assignment */

           open csr_get_next_location(l_pef_next_date);

           fetch csr_get_next_location into l_next_location;

           if csr_get_next_location%NOTFOUND then

               l_termination_flag := TRUE;

            else

               l_termination_flag := FALSE;

            end if;

            close csr_get_next_location;

            if l_termination_flag = FALSE and l_next_location = p_new_location_id then

                /* get the effective end date of the next set of %age records */

                open csr_get_next_date(l_element_link_id, l_pef_next_date);

                fetch csr_get_next_date into l_validation_end_date;

                if csr_get_next_date%NOTFOUND then

                   close csr_get_next_date;
                   fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                   fnd_message.set_token('PROCEDURE',
                       'pay_us_emp_dt_tax_rules.update_percentage');
                   fnd_message.set_token('STEP','2');
                   fnd_message.raise_error;

                end if;

                /* Pull forward the records as of the session date to
                   l_validation_start_date -1 */

                select l_validation_start_date - 1
                into l_prev_end_date
                from SYS.DUAL;

                upd_del_entries(p_assignment_id     => p_assignment_id,
                                p_session_date      => p_session_date,
                                p_new_start_date    => null,
                                p_new_end_date      => l_prev_end_date,
                                p_mode              => 'U');

                /* Pull back the records as of the session date to
                   p_session_date +1 */

                upd_del_entries(p_assignment_id     => p_assignment_id,
                                p_session_date      => l_pef_next_date,
                                p_new_start_date    => l_validation_start_date,
                                p_new_end_date      => null,
                                p_mode              => 'U');

           else  /* If termination flag is true or termination flag is false and
                    change in location has taken place */

               change_entries(p_assignment_id     => p_assignment_id,
                              p_session_date      => p_session_date,
                              p_start_date        => l_pef_start_date,
                              p_end_date          => l_pef_end_date,
                              p_mode              => 'UPDATE_CHANGE_INSERT');

               /* zero out the time for the new date range */

               zero_out_time(p_assignment_id     => p_assignment_id,
                         p_effective_start_date  => l_validation_start_date,
                         p_effective_end_date    => l_validation_end_date);


               /* Create the tax rules records and the %age records for the
                  new location - if required and set the city %age to 100 */

              l_ovrd_percent := 0;
              l_percent := 100;
              open csr_get_ovrd_loc(p_assignment_id, p_session_date);
              fetch csr_get_ovrd_loc into l_ovrd_loc;
              if csr_get_ovrd_loc%found then
                 if l_ovrd_loc <> p_new_location_id then
                    l_ovrd_percent := 100;
                    l_percent := 0;
                 end if;
              end if;
              close csr_get_ovrd_loc;

               create_new_location_rec(p_assignment_id   => p_assignment_id,
                          p_validation_start_date => l_validation_start_date,
                           p_validation_end_date  => l_validation_end_date,
                           p_session_date         => p_session_date,
                           p_new_location_id      => p_new_location_id,
                           p_res_state_code       => null,
                           p_res_county_code      => null,
                           p_res_city_code        => null,
                           p_business_group       => p_business_group_id,
                          p_percent              => l_percent);
       if l_ovrd_percent = 100 then
          create_new_location_rec(p_assignment_id  => p_assignment_id,
                          p_validation_start_date => l_validation_start_date,
                          p_validation_end_date   => l_validation_end_date,
                          p_session_date          => p_session_date,
                          p_new_location_id       => l_ovrd_loc,
                          p_res_state_code        => null,
                          p_res_county_code       => null,
                          p_res_city_code         => null,
                          p_business_group        => p_business_group_id,
                          p_percent               => l_ovrd_percent);
       end if;



           end if; /* Termination Flag is false or true */

      end if;

end if;

end update_percentage;


/* Name    : correct_wc_entry
   Purpose : This will handle the workers comp element entry
             for a 'correction' to the assignment's location.
*/

procedure correct_wc_entry (p_assignment_id        in number,
                                 p_effective_start_date in date,
                                 p_effective_end_date   in date,
                                 p_session_date         in date,
                                 p_new_location_id      in number,
                                 p_ret_code             in out nocopy number,
                                 p_ret_text             in out nocopy varchar2) is

cursor csr_get_loc_state is
       select pus.state_code
       from   PAY_US_STATES       pus,
              HR_LOCATIONS        hrl
       where  hrl.location_id   = p_new_location_id
       and    pus.state_abbrev  = nvl(hrl.loc_information17,hrl.region_2);

cursor csr_get_fed_rows is
   select pef.effective_start_date, pef.effective_end_date,
          pef.sui_jurisdiction_code
   from   PAY_US_EMP_FED_TAX_RULES_F pef
   where  pef.assignment_id = p_assignment_id
   and    p_effective_start_date <= pef.effective_end_date
   and    p_effective_end_date >= pef.effective_start_date;

cursor csr_get_fed_details (p_start_date date, p_end_date date) is
   select * from pay_us_emp_fed_tax_rules_f
   where  assignment_id = p_assignment_id
   and    effective_start_date = p_start_date
   and    effective_end_date   = p_end_date;

cursor csr_lck_fed_row (p_start_date date, p_end_date date)is
   select rowid
   from PAY_US_EMP_FED_TAX_RULES_F
   where assignment_id        = p_assignment_id
   and   effective_start_date = p_start_date
   and   effective_end_date   = p_end_date
   for update nowait;

l_eff_start_date       date;
l_eff_end_date         date;
l_row_id               rowid;
l_work_state_code      varchar2(2);
l_new_date             date;
l_jurisdiction_code    varchar2(11);
l_step                 number;
l_fed_rec              PAY_US_EMP_FED_TAX_RULES_F%rowtype;

begin

     l_step := 1;
    /* Get the state code of the new work location */
    open csr_get_loc_state;
    fetch csr_get_loc_state into l_work_state_code;
    if csr_get_loc_state%NOTFOUND then
       close csr_get_loc_state;
       fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
       fnd_message.set_token('PROCEDURE',
       'pay_us_emp_dt_tax_rules.correct_wc_entry');
       fnd_message.set_token('STEP',to_char(l_step));
       fnd_message.raise_error;
    end if;
    close csr_get_loc_state;

    l_step := 2;
    open csr_get_fed_rows;
    loop

        l_step := 3;
        fetch csr_get_fed_rows into l_eff_start_date, l_eff_end_date,
        l_jurisdiction_code;
        exit when csr_get_fed_rows%NOTFOUND;
        if l_eff_start_date >= p_effective_start_date and
           l_eff_end_date <= p_effective_end_date then
           l_step := 4;
	   /* Lock the federal record before updating */
	   open csr_lck_fed_row(l_eff_start_date, l_eff_end_date);
           l_step := 5;
	   fetch csr_lck_fed_row into l_row_id;
	   if csr_lck_fed_row%NOTFOUND then
              close csr_lck_fed_row;
              fnd_message.set_name('FND','FORM_UNABLE_TO_RESERVE_RECORD');
              fnd_message.raise_error;
           end if;
           close csr_lck_fed_row;

           /* Update the federal tax record for the SUI state */
           l_step := 6;
           update PAY_US_EMP_FED_TAX_RULES_F
           set    sui_state_code = l_work_state_code,
                  sui_jurisdiction_code = l_work_state_code ||'-000-0000'
           where  rowid = l_row_id;

           /* correct the jurisdiction for the Workers Compensation
              element entry */
           l_step := 7;

           maintain_wc_ele_entry (p_assignment_id        => p_assignment_id,
                                   p_effective_start_date => l_eff_start_date,
                                   p_effective_end_date   => l_eff_end_date,
                                   p_session_date         => l_eff_start_date,
                                   p_jurisdiction_code    => l_work_state_code ||'-000-0000',
                                   p_mode                 => 'CORRECTION');

         elsif l_eff_start_date < p_effective_start_date and
               l_eff_end_date <= p_effective_end_date then

               l_step := 8;
               select p_effective_start_date -1
               into l_new_date
               from DUAL;

               l_step := 9;
               open csr_get_fed_details(l_eff_start_date, l_eff_end_date);
               fetch csr_get_fed_details into l_fed_rec;
               if csr_get_fed_details%NOTFOUND then
                  close csr_get_fed_details;
                  fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                  fnd_message.set_token('PROCEDURE',
                  'pay_us_emp_dt_tax_rules.correct_wc_entry');
                 fnd_message.set_token('STEP',to_char(l_step));
                 fnd_message.raise_error;
               end if;
               close csr_get_fed_details;

               /* Update the Federal tax record as of the p_effective_start_date */

               l_step := 10;
               update PAY_US_EMP_FED_TAX_RULES_F
               set    effective_end_date = l_new_date
               where assignment_id        = p_assignment_id
               and   effective_start_date = l_eff_start_date
               and   effective_end_date   = l_eff_end_date;

               l_step := 11;
               insert into PAY_US_EMP_FED_TAX_RULES_F
               (emp_fed_tax_rule_id,
                effective_start_date,
                effective_end_date,
                assignment_id,
                sui_state_code,
                sui_jurisdiction_code,
                business_group_id,
                additional_wa_amount,
                filing_status_code,
                fit_override_amount,
                fit_override_rate,
                withholding_allowances,
                cumulative_taxation,
                eic_filing_status_code,
                fit_additional_tax,
                fit_exempt,
                futa_tax_exempt,
                medicare_tax_exempt,
                ss_tax_exempt,
                wage_exempt,
                statutory_employee,
                w2_filed_year,
                supp_tax_override_rate,
                excessive_wa_reject_date,
                object_version_number,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute16,
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                attribute26,
                attribute27,
                attribute28,
                attribute29,
                attribute30,
                fed_information_category,
                fed_information1,
                fed_information2,
                fed_information3,
                fed_information4,
                fed_information5,
                fed_information6,
                fed_information7,
                fed_information8,
                fed_information9,
                fed_information10,
                fed_information11,
                fed_information12,
                fed_information13,
                fed_information14,
                fed_information15,
                fed_information16,
                fed_information17,
                fed_information18,
                fed_information19,
                fed_information20,
                fed_information21,
                fed_information22,
                fed_information23,
                fed_information24,
                fed_information25,
                fed_information26,
                fed_information27,
                fed_information28,
                fed_information29,
                fed_information30
                )

               values
               (l_fed_rec.emp_fed_tax_rule_id,
                p_effective_start_date,
                l_fed_rec.effective_end_date,
                l_fed_rec.assignment_id,
                l_work_state_code,
                l_work_state_code || '-000-0000',
                l_fed_rec.business_group_id,
                l_fed_rec.additional_wa_amount,
                lpad(l_fed_rec.filing_status_code,2,'0'),
                l_fed_rec.fit_override_amount,
                l_fed_rec.fit_override_rate,
                l_fed_rec.withholding_allowances,
                l_fed_rec.cumulative_taxation,
                l_fed_rec.eic_filing_status_code,
                l_fed_rec.fit_additional_tax,
                l_fed_rec.fit_exempt,
                l_fed_rec.futa_tax_exempt,
                l_fed_rec.medicare_tax_exempt,
                l_fed_rec.ss_tax_exempt,
                l_fed_rec.wage_exempt,
                l_fed_rec.statutory_employee,
                l_fed_rec.w2_filed_year,
                l_fed_rec.supp_tax_override_rate,
                l_fed_rec.excessive_wa_reject_date,
                0,
                l_fed_rec.attribute_category,
                l_fed_rec.attribute1,
                l_fed_rec.attribute2,
                l_fed_rec.attribute3,
                l_fed_rec.attribute4,
                l_fed_rec.attribute5,
                l_fed_rec.attribute6,
                l_fed_rec.attribute7,
                l_fed_rec.attribute8,
                l_fed_rec.attribute9,
                l_fed_rec.attribute10,
                l_fed_rec.attribute11,
                l_fed_rec.attribute12,
                l_fed_rec.attribute13,
                l_fed_rec.attribute14,
                l_fed_rec.attribute15,
                l_fed_rec.attribute16,
                l_fed_rec.attribute17,
                l_fed_rec.attribute18,
                l_fed_rec.attribute19,
                l_fed_rec.attribute20,
                l_fed_rec.attribute21,
                l_fed_rec.attribute22,
                l_fed_rec.attribute23,
                l_fed_rec.attribute24,
                l_fed_rec.attribute25,
                l_fed_rec.attribute26,
                l_fed_rec.attribute27,
                l_fed_rec.attribute28,
                l_fed_rec.attribute29,
                l_fed_rec.attribute30,
                l_fed_rec.fed_information_category,
                l_fed_rec.fed_information1,
                l_fed_rec.fed_information2,
                l_fed_rec.fed_information3,
                l_fed_rec.fed_information4,
                l_fed_rec.fed_information5,
                l_fed_rec.fed_information6,
                l_fed_rec.fed_information7,
                l_fed_rec.fed_information8,
                l_fed_rec.fed_information9,
                l_fed_rec.fed_information10,
                l_fed_rec.fed_information11,
                l_fed_rec.fed_information12,
                l_fed_rec.fed_information13,
                l_fed_rec.fed_information14,
                l_fed_rec.fed_information15,
                l_fed_rec.fed_information16,
                l_fed_rec.fed_information17,
                l_fed_rec.fed_information18,
                l_fed_rec.fed_information19,
                l_fed_rec.fed_information20,
                l_fed_rec.fed_information21,
                l_fed_rec.fed_information22,
                l_fed_rec.fed_information23,
                l_fed_rec.fed_information24,
                l_fed_rec.fed_information25,
                l_fed_rec.fed_information26,
                l_fed_rec.fed_information27,
                l_fed_rec.fed_information28,
                l_fed_rec.fed_information29,
                l_fed_rec.fed_information30
                );

               if l_eff_end_date = to_date('31/12/4712','dd/mm/yyyy') then
                  /* Update the workers compensation for the new jurisdiction as of the
                     p_effective_start_date */
                  l_step := 12;
                  maintain_wc_ele_entry (p_assignment_id        => p_assignment_id,
                                         p_effective_start_date => l_eff_start_date,
                                         p_effective_end_date   => l_eff_end_date,
                                         p_session_date         => p_effective_start_date,
                                         p_jurisdiction_code    => l_work_state_code ||'-000-0000',
                                         p_mode                 => 'UPDATE');
                else
                  /* Update Insert the workers compensation for the new jurisdiction as of the
                     p_effective_start_date */
                  l_step := 13;
                  maintain_wc_ele_entry (p_assignment_id        => p_assignment_id,
                                         p_effective_start_date => l_eff_start_date ,
                                         p_effective_end_date   => l_eff_end_date,
                                         p_session_date         => p_effective_start_date,
                                         p_jurisdiction_code    => l_work_state_code ||'-000-0000',
                                         p_mode                 => 'UPDATE_CHANGE_INSERT');
                end if;

         elsif l_eff_start_date >= p_effective_start_date and
               l_eff_end_date > p_effective_end_date then

               l_step := 14;
               select p_effective_end_date +1
               into l_new_date
               from DUAL;

               open csr_get_fed_details(l_eff_start_date, l_eff_end_date);
               fetch csr_get_fed_details into l_fed_rec;
               if csr_get_fed_details%NOTFOUND then
                  close csr_get_fed_details;
                  fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                  fnd_message.set_token('PROCEDURE',
                  'pay_us_emp_dt_tax_rules.correct_wc_entry');
                 fnd_message.set_token('STEP',to_char(l_step));
                 fnd_message.raise_error;
               end if;
               close csr_get_fed_details;

               /* Update the Federal tax record as of the p_effective_start_date */
               l_step := 15;
              /*
               insert into PAY_US_EMP_FED_TAX_RULES_F
               select * from pay_us_emp_fed_tax_rules_f
               where  assignment_id = p_assignment_id
               and    effective_start_date = l_eff_start_date
               and    effective_end_date   = l_eff_end_date;
              */

               l_step := 16;
               update PAY_US_EMP_FED_TAX_RULES_F
               set    effective_end_date = p_effective_end_date,
                      sui_state_code     = l_work_state_code,
                      sui_jurisdiction_code = l_work_state_code || '-000-0000'
               where assignment_id        = p_assignment_id
               and   effective_start_date = l_eff_start_date
               and   effective_end_date   = l_eff_end_date
               and   rownum < 2;

               l_step := 17;
               insert into PAY_US_EMP_FED_TAX_RULES_F
               (emp_fed_tax_rule_id,
                effective_start_date,
                effective_end_date,
                assignment_id,
                sui_state_code,
                sui_jurisdiction_code,
                business_group_id,
                additional_wa_amount,
                filing_status_code,
                fit_override_amount,
                fit_override_rate,
                withholding_allowances,
                cumulative_taxation,
                eic_filing_status_code,
                fit_additional_tax,
                fit_exempt,
                futa_tax_exempt,
                medicare_tax_exempt,
                ss_tax_exempt,
                wage_exempt,
                statutory_employee,
                w2_filed_year,
                supp_tax_override_rate,
                excessive_wa_reject_date,
                object_version_number,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute16,
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                attribute26,
                attribute27,
                attribute28,
                attribute29,
                attribute30,
                fed_information_category,
                fed_information1,
                fed_information2,
                fed_information3,
                fed_information4,
                fed_information5,
                fed_information6,
                fed_information7,
                fed_information8,
                fed_information9,
                fed_information10,
                fed_information11,
                fed_information12,
                fed_information13,
                fed_information14,
                fed_information15,
                fed_information16,
                fed_information17,
                fed_information18,
                fed_information19,
                fed_information20,
                fed_information21,
                fed_information22,
                fed_information23,
                fed_information24,
                fed_information25,
                fed_information26,
                fed_information27,
                fed_information28,
                fed_information29,
                fed_information30
                )
               values
               (l_fed_rec.emp_fed_tax_rule_id,
                l_new_date,
                l_fed_rec.effective_end_date,
                l_fed_rec.assignment_id,
                l_fed_rec.sui_state_code,
                l_fed_rec.sui_jurisdiction_code,
                l_fed_rec.business_group_id,
                l_fed_rec.additional_wa_amount,
                lpad(l_fed_rec.filing_status_code,2,'0'),
                l_fed_rec.fit_override_amount,
                l_fed_rec.fit_override_rate,
                l_fed_rec.withholding_allowances,
                l_fed_rec.cumulative_taxation,
                l_fed_rec.eic_filing_status_code,
                l_fed_rec.fit_additional_tax,
                l_fed_rec.fit_exempt,
                l_fed_rec.futa_tax_exempt,
                l_fed_rec.medicare_tax_exempt,
                l_fed_rec.ss_tax_exempt,
                l_fed_rec.wage_exempt,
                l_fed_rec.statutory_employee,
                l_fed_rec.w2_filed_year,
                l_fed_rec.supp_tax_override_rate,
                l_fed_rec.excessive_wa_reject_date,
                0,
                l_fed_rec.attribute_category,
                l_fed_rec.attribute1,
                l_fed_rec.attribute2,
                l_fed_rec.attribute3,
                l_fed_rec.attribute4,
                l_fed_rec.attribute5,
                l_fed_rec.attribute6,
                l_fed_rec.attribute7,
                l_fed_rec.attribute8,
                l_fed_rec.attribute9,
                l_fed_rec.attribute10,
                l_fed_rec.attribute11,
                l_fed_rec.attribute12,
                l_fed_rec.attribute13,
                l_fed_rec.attribute14,
                l_fed_rec.attribute15,
                l_fed_rec.attribute16,
                l_fed_rec.attribute17,
                l_fed_rec.attribute18,
                l_fed_rec.attribute19,
                l_fed_rec.attribute20,
                l_fed_rec.attribute21,
                l_fed_rec.attribute22,
                l_fed_rec.attribute23,
                l_fed_rec.attribute24,
                l_fed_rec.attribute25,
                l_fed_rec.attribute26,
                l_fed_rec.attribute27,
                l_fed_rec.attribute28,
                l_fed_rec.attribute29,
                l_fed_rec.attribute30,
                l_fed_rec.fed_information_category,
                l_fed_rec.fed_information1,
                l_fed_rec.fed_information2,
                l_fed_rec.fed_information3,
                l_fed_rec.fed_information4,
                l_fed_rec.fed_information5,
                l_fed_rec.fed_information6,
                l_fed_rec.fed_information7,
                l_fed_rec.fed_information8,
                l_fed_rec.fed_information9,
                l_fed_rec.fed_information10,
                l_fed_rec.fed_information11,
                l_fed_rec.fed_information12,
                l_fed_rec.fed_information13,
                l_fed_rec.fed_information14,
                l_fed_rec.fed_information15,
                l_fed_rec.fed_information16,
                l_fed_rec.fed_information17,
                l_fed_rec.fed_information18,
                l_fed_rec.fed_information19,
                l_fed_rec.fed_information20,
                l_fed_rec.fed_information21,
                l_fed_rec.fed_information22,
                l_fed_rec.fed_information23,
                l_fed_rec.fed_information24,
                l_fed_rec.fed_information25,
                l_fed_rec.fed_information26,
                l_fed_rec.fed_information27,
                l_fed_rec.fed_information28,
                l_fed_rec.fed_information29,
                l_fed_rec.fed_information30
                );

               l_step := 18;
               maintain_wc_ele_entry (p_assignment_id        => p_assignment_id,
                                      p_effective_start_date => l_eff_start_date,
                                      p_effective_end_date   => l_eff_end_date,
                                      p_session_date         => l_eff_start_date,
                                      p_jurisdiction_code    => l_work_state_code || '-000-0000',
                                      p_mode                 => 'CORRECTION');


               if l_eff_end_date = to_date('31/12/4712','dd/mm/yyyy') then
                  /* Update the workers compensation for the old jurisdiction as of the
                     l_new_date */
                  l_step := 19;
                  maintain_wc_ele_entry (p_assignment_id        => p_assignment_id,
                                         p_effective_start_date => l_eff_start_date,
                                         p_effective_end_date   => l_eff_end_date,
                                         p_session_date         => l_new_date,
                                         p_jurisdiction_code    => l_jurisdiction_code,
                                         p_mode                 => 'UPDATE');
                else
                  /* Update Insert the workers compensation for the old jurisdiction as of the
                     l_new_date */
                  l_step := 20;
                  maintain_wc_ele_entry (p_assignment_id        => p_assignment_id,
                                         p_effective_start_date => l_eff_start_date,
                                         p_effective_end_date   => l_eff_end_date,
                                         p_session_date         => l_new_date,
                                         p_jurisdiction_code    => l_jurisdiction_code,
                                         p_mode                 => 'UPDATE_CHANGE_INSERT');
                end if;

         elsif l_eff_start_date < p_effective_start_date and
               l_eff_end_date > p_effective_end_date then

               l_step := 21;
               select p_effective_end_date +1
               into l_new_date
               from DUAL;

               open csr_get_fed_details(l_eff_start_date, l_eff_end_date);
               fetch csr_get_fed_details into l_fed_rec;
               if csr_get_fed_details%NOTFOUND then
                  close csr_get_fed_details;
                  fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                  fnd_message.set_token('PROCEDURE',
                  'pay_us_emp_dt_tax_rules.correct_wc_entry');
                  fnd_message.set_token('STEP',to_char(l_step));
                  fnd_message.raise_error;
               end if;
               close csr_get_fed_details;

               /* Update the Federal tax record as of the p_effective_end_date + 1 */

               l_step := 23;
               update PAY_US_EMP_FED_TAX_RULES_F
               set    effective_end_date = p_effective_end_date
               where assignment_id        = p_assignment_id
               and   effective_start_date = l_eff_start_date
               and   effective_end_date   = l_eff_end_date;

               l_step := 24;
               insert into PAY_US_EMP_FED_TAX_RULES_F
               (emp_fed_tax_rule_id,
                effective_start_date,
                effective_end_date,
                assignment_id,
                sui_state_code,
                sui_jurisdiction_code,
                business_group_id,
                additional_wa_amount,
                filing_status_code,
                fit_override_amount,
                fit_override_rate,
                withholding_allowances,
                cumulative_taxation,
                eic_filing_status_code,
                fit_additional_tax,
                fit_exempt,
                futa_tax_exempt,
                medicare_tax_exempt,
                ss_tax_exempt,
                wage_exempt,
                statutory_employee,
                w2_filed_year,
                supp_tax_override_rate,
                excessive_wa_reject_date,
                object_version_number,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute16,
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                attribute26,
                attribute27,
                attribute28,
                attribute29,
                attribute30,
                fed_information_category,
                fed_information1,
                fed_information2,
                fed_information3,
                fed_information4,
                fed_information5,
                fed_information6,
                fed_information7,
                fed_information8,
                fed_information9,
                fed_information10,
                fed_information11,
                fed_information12,
                fed_information13,
                fed_information14,
                fed_information15,
                fed_information16,
                fed_information17,
                fed_information18,
                fed_information19,
                fed_information20,
                fed_information21,
                fed_information22,
                fed_information23,
                fed_information24,
                fed_information25,
                fed_information26,
                fed_information27,
                fed_information28,
                fed_information29,
                fed_information30  )
               values
               (l_fed_rec.emp_fed_tax_rule_id,
                l_new_date,
                l_fed_rec.effective_end_date,
                l_fed_rec.assignment_id,
                l_fed_rec.sui_state_code,
                l_fed_rec.sui_jurisdiction_code,
                l_fed_rec.business_group_id,
                l_fed_rec.additional_wa_amount,
                lpad(l_fed_rec.filing_status_code,2,'0'),
                l_fed_rec.fit_override_amount,
                l_fed_rec.fit_override_rate,
                l_fed_rec.withholding_allowances,
                l_fed_rec.cumulative_taxation,
                l_fed_rec.eic_filing_status_code,
                l_fed_rec.fit_additional_tax,
                l_fed_rec.fit_exempt,
                l_fed_rec.futa_tax_exempt,
                l_fed_rec.medicare_tax_exempt,
                l_fed_rec.ss_tax_exempt,
                l_fed_rec.wage_exempt,
                l_fed_rec.statutory_employee,
                l_fed_rec.w2_filed_year,
                l_fed_rec.supp_tax_override_rate,
                l_fed_rec.excessive_wa_reject_date,
                0,
                l_fed_rec.attribute_category,
                l_fed_rec.attribute1,
                l_fed_rec.attribute2,
                l_fed_rec.attribute3,
                l_fed_rec.attribute4,
                l_fed_rec.attribute5,
                l_fed_rec.attribute6,
                l_fed_rec.attribute7,
                l_fed_rec.attribute8,
                l_fed_rec.attribute9,
                l_fed_rec.attribute10,
                l_fed_rec.attribute11,
                l_fed_rec.attribute12,
                l_fed_rec.attribute13,
                l_fed_rec.attribute14,
                l_fed_rec.attribute15,
                l_fed_rec.attribute16,
                l_fed_rec.attribute17,
                l_fed_rec.attribute18,
                l_fed_rec.attribute19,
                l_fed_rec.attribute20,
                l_fed_rec.attribute21,
                l_fed_rec.attribute22,
                l_fed_rec.attribute23,
                l_fed_rec.attribute24,
                l_fed_rec.attribute25,
                l_fed_rec.attribute26,
                l_fed_rec.attribute27,
                l_fed_rec.attribute28,
                l_fed_rec.attribute29,
                l_fed_rec.attribute30,
                l_fed_rec.fed_information_category,
                l_fed_rec.fed_information1,
                l_fed_rec.fed_information2,
                l_fed_rec.fed_information3,
                l_fed_rec.fed_information4,
                l_fed_rec.fed_information5,
                l_fed_rec.fed_information6,
                l_fed_rec.fed_information7,
                l_fed_rec.fed_information8,
                l_fed_rec.fed_information9,
                l_fed_rec.fed_information10,
                l_fed_rec.fed_information11,
                l_fed_rec.fed_information12,
                l_fed_rec.fed_information13,
                l_fed_rec.fed_information14,
                l_fed_rec.fed_information15,
                l_fed_rec.fed_information16,
                l_fed_rec.fed_information17,
                l_fed_rec.fed_information18,
                l_fed_rec.fed_information19,
                l_fed_rec.fed_information20,
                l_fed_rec.fed_information21,
                l_fed_rec.fed_information22,
                l_fed_rec.fed_information23,
                l_fed_rec.fed_information24,
                l_fed_rec.fed_information25,
                l_fed_rec.fed_information26,
                l_fed_rec.fed_information27,
                l_fed_rec.fed_information28,
                l_fed_rec.fed_information29,
                l_fed_rec.fed_information30
                );

               if l_eff_end_date = to_date('31/12/4712','dd/mm/yyyy') then
                  /* Update the workers compensation for the old jurisdiction as of the
                     l_new_date */

                  l_step := 26;
                  maintain_wc_ele_entry (p_assignment_id        => p_assignment_id,
                                         p_effective_start_date => l_eff_start_date,
                                         p_effective_end_date   => l_eff_end_date,
                                         p_session_date         => l_new_date,
                                         p_jurisdiction_code    => l_jurisdiction_code,
                                         p_mode                 => 'UPDATE');
                else
                  /* Update Insert the workers compensation for the old jurisdiction as of the
                     l_new_date */
                  l_step := 27;
                  maintain_wc_ele_entry (p_assignment_id        => p_assignment_id,
                                         p_effective_start_date => l_eff_start_date,
                                         p_effective_end_date   => l_eff_end_date,
                                         p_session_date         => l_new_date,
                                         p_jurisdiction_code    => l_jurisdiction_code,
                                         p_mode                 => 'UPDATE_CHANGE_INSERT');
                end if;


               l_step := 28;
               select p_effective_start_date -1
               into l_new_date
               from DUAL;

              /*  We do not ned to get the federal record again since we haev already got
                  it above.

               open csr_get_fed_details(l_eff_start_date, p_effective_end_date);
               fetch csr_get_fed_details into l_fed_rec;
               if csr_get_fed_details%NOTFOUND then
                  close csr_get_fed_details;
                  fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                  fnd_message.set_token('PROCEDURE',
                  'pay_us_emp_dt_tax_rules.correct_wc_entry');
                  fnd_message.set_token('STEP',to_char(l_step));
                  fnd_message.raise_error;
               end if;
               close csr_get_fed_details;
               */

               /* Update the Federal tax record as of the p_effective_start_date */

               l_step := 30;
               update PAY_US_EMP_FED_TAX_RULES_F
               set    effective_end_date = l_new_date
               where assignment_id        = p_assignment_id
               and   effective_start_date = l_eff_start_date
               and   effective_end_date   = p_effective_end_date;

               l_step := 31;
               insert into PAY_US_EMP_FED_TAX_RULES_F
               (emp_fed_tax_rule_id,
                effective_start_date,
                effective_end_date,
                assignment_id,
                sui_state_code,
                sui_jurisdiction_code,
                business_group_id,
                additional_wa_amount,
                filing_status_code,
                fit_override_amount,
                fit_override_rate,
                withholding_allowances,
                cumulative_taxation,
                eic_filing_status_code,
                fit_additional_tax,
                fit_exempt,
                futa_tax_exempt,
                medicare_tax_exempt,
                ss_tax_exempt,
                wage_exempt,
                statutory_employee,
                w2_filed_year,
                supp_tax_override_rate,
                excessive_wa_reject_date,
                object_version_number,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute16,
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                attribute26,
                attribute27,
                attribute28,
                attribute29,
                attribute30,
                fed_information_category,
                fed_information1,
                fed_information2,
                fed_information3,
                fed_information4,
                fed_information5,
                fed_information6,
                fed_information7,
                fed_information8,
                fed_information9,
                fed_information10,
                fed_information11,
                fed_information12,
                fed_information13,
                fed_information14,
                fed_information15,
                fed_information16,
                fed_information17,
                fed_information18,
                fed_information19,
                fed_information20,
                fed_information21,
                fed_information22,
                fed_information23,
                fed_information24,
                fed_information25,
                fed_information26,
                fed_information27,
                fed_information28,
                fed_information29,
                fed_information30   )
               values
               (l_fed_rec.emp_fed_tax_rule_id,
                p_effective_start_date,
                p_effective_end_date,
                l_fed_rec.assignment_id,
                l_work_state_code,
                l_work_state_code || '-000-0000',
                l_fed_rec.business_group_id,
                l_fed_rec.additional_wa_amount,
                lpad(l_fed_rec.filing_status_code,2,'0'),
                l_fed_rec.fit_override_amount,
                l_fed_rec.fit_override_rate,
                l_fed_rec.withholding_allowances,
                l_fed_rec.cumulative_taxation,
                l_fed_rec.eic_filing_status_code,
                l_fed_rec.fit_additional_tax,
                l_fed_rec.fit_exempt,
                l_fed_rec.futa_tax_exempt,
                l_fed_rec.medicare_tax_exempt,
                l_fed_rec.ss_tax_exempt,
                l_fed_rec.wage_exempt,
                l_fed_rec.statutory_employee,
                l_fed_rec.w2_filed_year,
                l_fed_rec.supp_tax_override_rate,
                l_fed_rec.excessive_wa_reject_date,
                0,
                l_fed_rec.attribute_category,
                l_fed_rec.attribute1,
                l_fed_rec.attribute2,
                l_fed_rec.attribute3,
                l_fed_rec.attribute4,
                l_fed_rec.attribute5,
                l_fed_rec.attribute6,
                l_fed_rec.attribute7,
                l_fed_rec.attribute8,
                l_fed_rec.attribute9,
                l_fed_rec.attribute10,
                l_fed_rec.attribute11,
                l_fed_rec.attribute12,
                l_fed_rec.attribute13,
                l_fed_rec.attribute14,
                l_fed_rec.attribute15,
                l_fed_rec.attribute16,
                l_fed_rec.attribute17,
                l_fed_rec.attribute18,
                l_fed_rec.attribute19,
                l_fed_rec.attribute20,
                l_fed_rec.attribute21,
                l_fed_rec.attribute22,
                l_fed_rec.attribute23,
                l_fed_rec.attribute24,
                l_fed_rec.attribute25,
                l_fed_rec.attribute26,
                l_fed_rec.attribute27,
                l_fed_rec.attribute28,
                l_fed_rec.attribute29,
                l_fed_rec.attribute30,
                l_fed_rec.fed_information_category,
                l_fed_rec.fed_information1,
                l_fed_rec.fed_information2,
                l_fed_rec.fed_information3,
                l_fed_rec.fed_information4,
                l_fed_rec.fed_information5,
                l_fed_rec.fed_information6,
                l_fed_rec.fed_information7,
                l_fed_rec.fed_information8,
                l_fed_rec.fed_information9,
                l_fed_rec.fed_information10,
                l_fed_rec.fed_information11,
                l_fed_rec.fed_information12,
                l_fed_rec.fed_information13,
                l_fed_rec.fed_information14,
                l_fed_rec.fed_information15,
                l_fed_rec.fed_information16,
                l_fed_rec.fed_information17,
                l_fed_rec.fed_information18,
                l_fed_rec.fed_information19,
                l_fed_rec.fed_information20,
                l_fed_rec.fed_information21,
                l_fed_rec.fed_information22,
                l_fed_rec.fed_information23,
                l_fed_rec.fed_information24,
                l_fed_rec.fed_information25,
                l_fed_rec.fed_information26,
                l_fed_rec.fed_information27,
                l_fed_rec.fed_information28,
                l_fed_rec.fed_information29,
                l_fed_rec.fed_information30
                );


               /* Update Insert the workers compensation for the new jurisdiction as of the
                  p_effective_start_date */
               l_step := 32;
               maintain_wc_ele_entry (p_assignment_id        => p_assignment_id,
                                      p_effective_start_date => l_eff_start_date,
                                      p_effective_end_date   => p_effective_end_date,
                                      p_session_date         => p_effective_start_date,
                                      p_jurisdiction_code    => l_work_state_code ||'-000-0000',
                                      p_mode                 => 'UPDATE_CHANGE_INSERT');

        end if;
     end loop;
    close csr_get_fed_rows;

    exception
    when others then
       fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
       fnd_message.set_token('PROCEDURE',
       'pay_us_emp_dt_tax_rules.correct_wc_entry');
       fnd_message.set_token('STEP',to_char(l_step));
       fnd_message.raise_error;
end correct_wc_entry;


procedure change_wc_entry (p_assignment_id        in number,
                                p_effective_start_date in date,
                                p_effective_end_date   in date,
                                p_session_date         in date,
                                p_new_location_id      in number,
                                p_mode                 in varchar2,
                                p_ret_code             in out nocopy number,
                                p_ret_text             in out nocopy varchar2) is
l_validation_start_date    date;
l_validation_end_date      date;
l_end_of_time              date := to_date('31/12/4712','dd/mm/yyyy');
l_ret_code                 number := 0;
l_ret_text                 varchar2(2000);

begin

    if p_mode = 'CORRECTION' then
       l_validation_start_date := p_effective_start_date;
       l_validation_end_date   := p_effective_end_date;
    elsif p_mode = 'UPDATE' then
       l_validation_start_date := p_session_date;
       l_validation_end_date   := l_end_of_time;
    elsif p_mode = 'UPDATE_CHANGE_INSERT' then
       l_validation_start_date := p_session_date;
       l_validation_end_date   := p_effective_end_date;
    elsif p_mode = 'UPDATE_OVERRIDE' then
       l_validation_start_date := p_session_date;
       l_validation_end_date   := l_end_of_time;
    end if;

    hr_utility.set_location('pay_us_emp_dt_tax_rules.change_wc_entry',1);
    correct_wc_entry (p_assignment_id        => p_assignment_id,
                           p_effective_start_date => l_validation_start_date,
                           p_effective_end_date   => l_validation_end_date,
                           p_session_date         => p_session_date,
                           p_new_location_id      => p_new_location_id,
                           p_ret_code             => l_ret_code,
                           p_ret_text             => l_ret_text);
    hr_utility.set_location('pay_us_emp_dt_tax_rules.change_wc_entry',2);

end change_wc_entry;

procedure pull_tax_records( p_assignment_id   in number,
                           p_new_start_date  in date,
                           p_default_date    in date) is
       l_ef_date DATE;
       l_proc VARCHAR2(50) := 'pay_us_emp_dt_tax_rules.pull_tax_records';

begin
       hr_utility.set_location('Entering: ' || l_proc, 5);
       /* dscully - modified to handle case where tax record changes
	  have occured between old hire date and new hire date */

       if p_new_start_date < p_default_date then
		l_ef_date := p_default_date;
       elsif p_new_start_date > p_default_date then
		l_ef_date := p_new_start_date;
       else -- do nothing
	  return;
       end if;

       /* First update the tax rules records */

       update PAY_US_EMP_FED_TAX_RULES_F
       set    effective_start_date = p_new_start_date
       where  assignment_id = p_assignment_id
       and    l_ef_date between effective_start_date and effective_end_date;

       if sql%notfound then
          fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
          fnd_message.set_token('PROCEDURE',l_proc);
          fnd_message.set_token('STEP','2');
          fnd_message.raise_error;
       end if;

       update PAY_US_EMP_STATE_TAX_RULES_F
       set    effective_start_date = p_new_start_date
       where  assignment_id = p_assignment_id
       and    l_ef_date between effective_start_date and effective_end_date;

       if sql%notfound then
          fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
          fnd_message.set_token('PROCEDURE',l_proc);
          fnd_message.set_token('STEP','3');
          fnd_message.raise_error;
       end if;

       update PAY_US_EMP_COUNTY_TAX_RULES_F
       set    effective_start_date = p_new_start_date
       where  assignment_id = p_assignment_id
       and    l_ef_date between effective_start_date and effective_end_date;

       if sql%notfound then
          fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
          fnd_message.set_token('PROCEDURE',l_proc);
          fnd_message.set_token('STEP','4');
          fnd_message.raise_error;
       end if;

       update PAY_US_EMP_CITY_TAX_RULES_F
       set    effective_start_date = p_new_start_date
       where  assignment_id = p_assignment_id
       and    l_ef_date between effective_start_date and effective_end_date;

       if sql%notfound then
          fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
          fnd_message.set_token('PROCEDURE',l_proc);
          fnd_message.set_token('STEP','5');
          fnd_message.raise_error;
       end if;

       /* Next delete any orphaned rows */
       if p_new_start_date > p_default_date then
	       hr_utility.set_location(l_proc, 10);
	       delete PAY_US_EMP_FED_TAX_RULES_F
	       where  assignment_id = p_assignment_id
	       and    p_new_start_date >  effective_start_date;

	       delete PAY_US_EMP_STATE_TAX_RULES_F
	       where  assignment_id = p_assignment_id
	       and    p_new_start_date >  effective_start_date;

	       delete PAY_US_EMP_COUNTY_TAX_RULES_F
	       where  assignment_id = p_assignment_id
	       and    p_new_start_date >  effective_start_date;

	       delete PAY_US_EMP_CITY_TAX_RULES_F
	       where  assignment_id = p_assignment_id
	       and    p_new_start_date >  effective_start_date;

	end if;

       hr_utility.set_location('Leaving: ' || l_proc, 20);

end pull_tax_records;

procedure check_hiring_date( p_assignment_id   in number,
                             p_default_date    in date,
                             p_s_start_date    in date) is


l_payroll_installed boolean  := FALSE;

begin

    /* If the hiring date has been changed and pulled back, for the
       assignment then pull back the start date of all of the tax
       rules records, workers compensation and the vertex element
       entries */


   /* Rmonge 27-jul-2001 */
   /* Added an verification for tax records maintenance and payroll     */
   /* installation. This is to make sure that                           */
   /* the HR only customers do not run into an error when this code is  */


   l_payroll_installed :=
   hr_utility.chk_product_install(p_product =>'Oracle Payroll',
                                  p_legislation => 'US');



    if hr_general.chk_maintain_tax_records = 'Y' then

         if p_s_start_date < p_default_date then

            pull_tax_records(p_assignment_id     => p_assignment_id,
                             p_new_start_date    => p_s_start_date,
                        p_default_date      => p_default_date);


         if l_payroll_installed then


       /* Now time to update the workers comp element entry */

             del_updt_wc_entry_for_dates (p_assignment_id  => p_assignment_id,
                                    p_session_date         => p_default_date,
                                    p_new_start_date       => p_s_start_date,
                                    p_new_end_date         => null,
                                    p_mode                 => 'U');


       /* Finally update the vertex element entries and close the
          chapter */

             upd_del_entries(p_assignment_id  => p_assignment_id,
                             p_session_date   => p_default_date,
                             p_new_start_date => p_s_start_date,
                             p_new_end_date   => null,
                             p_mode           => 'U');

    /* If the hiring date has been pulled forward then the person api
       pulls forward the element entries but does not pull forward the
       tax rules record. So, we will pull them forward */

      end if;  /* payroll installed */

    elsif p_s_start_date > p_default_date then

       pull_tax_records(p_assignment_id     => p_assignment_id,
                        p_new_start_date    => p_s_start_date,
                        p_default_date      => p_default_date);

    end if; /* start date */

end if;  /* check maintain tax records */

end check_hiring_date;

procedure default_tax ( p_assignment_id          in number,
                        p_effective_start_date   in date,
                        p_effective_end_date     in date,
                        p_business_group_id      in number,
                        p_ret_code               in number,
                        p_ret_text               in varchar2) is

l_res_state_code        varchar2(2);
l_res_county_code       varchar2(3);
l_res_city_code         varchar2(4);
l_add_state_code        varchar2(2);
l_add_county_code       varchar2(3);
l_add_city_code         varchar2(4);
l_work_state_code       varchar2(2);
l_work_county_code      varchar2(3);
l_work_city_code        varchar2(4);
l_work1_state_code       varchar2(2);
l_work1_county_code      varchar2(3);
l_work1_city_code        varchar2(4);
l_work2_state_code       varchar2(2);
l_work2_county_code      varchar2(3);
l_work2_city_code        varchar2(4);
l_work3_state_code       varchar2(2);
l_work3_county_code      varchar2(3);
l_work3_city_code        varchar2(4);
l_sui_state_code        varchar2(2);
l_loc_city              varchar2(11);
l_fed_tax_rule_id       number;
l_state_tax_rule_id     number;
l_county_tax_rule_id    number;
l_city_tax_rule_id      number;
l_work_state_name       varchar2(35) := null;
l_work_county_name      varchar2(35) := null;
l_work_city_name       varchar2(35) := null;
l_work1_state_name       varchar2(35) := null;
l_work1_county_name      varchar2(35) := null;
l_work1_city_name       varchar2(35) := null;
l_work2_state_name       varchar2(35) := null;
l_work2_county_name      varchar2(35) := null;
l_work2_city_name       varchar2(35) := null;
l_work3_state_name       varchar2(35) := null;
l_work3_county_name      varchar2(35) := null;
l_work3_city_name       varchar2(35) := null;
l_res_state_name        varchar2(35) := null;
l_res_county_name       varchar2(35) := null;
l_res_city_name         varchar2(35) := null;
l_percent               number;

cursor csr_chk_addr_ovrd is
  select pus.state_code,
         puc.county_code,
         pcn.city_code
  from   pay_us_city_names pcn,
         pay_us_counties puc,
         pay_us_states pus,
         per_addresses pa,
         per_assignments_f paf
  where  paf.assignment_id         = p_assignment_id
  and    p_effective_start_date between paf.effective_start_date and
                                paf.effective_end_date
  and    pa.person_id              = paf.person_id
  and    pa.primary_flag           = 'Y'
  and    p_effective_start_date between pa.date_from and
                                     nvl(pa.date_to,to_date('12/31/4712','MM/DD/YYYY'))
  and    pa.add_information17 is not null
  and    pa.add_information19 is not null
  and    pa.add_information18 is not null
  and pa.add_information17 = pus.state_abbrev
  and puc.state_code = pus.state_code
  and puc.county_name = pa.add_information19
  and pcn.state_code = puc.state_code
  and pcn.county_code = puc.county_code
  and pcn.city_name = add_information18;

begin

     /* Get the resident and the work state, county and city codes */

  hr_utility.set_location('pay_us_emp_dt_tax_rules.default_tax',1);
     pay_us_emp_dt_tax_val.get_orig_res_codes (p_assignment_id         => p_assignment_id,

                    p_session_date          => p_effective_start_date,
                    p_res_state_code        => l_res_state_code,
                    p_res_county_code       => l_res_county_code,
                    p_res_city_code         => l_res_city_code,
                    p_res_state_name        => l_res_state_name,
                    p_res_county_name       => l_res_county_name,
                    p_res_city_name         => l_res_city_name);

  hr_utility.set_location('pay_us_emp_dt_tax_rules.default_tax',2);
      if l_res_state_code is null then
          fnd_message.set_name('PER', 'PER_52985_ADD_NO_STATE_SET');
          fnd_message.raise_error;
      end if;

      if l_res_county_code is null then
          fnd_message.set_name('PER', 'PER_52984_ADD_NO_COUNTY_SET');
          fnd_message.raise_error;
      end if;

      if l_res_city_code is null then
          fnd_message.set_name('PER', 'PER_52986_ADD_NO_CITY_SET');
          fnd_message.raise_error;
      end if;

      /* Check to see if the address has an override or not . If there is
         an override for the address then get the non override address for
         the assignment and assign it to the additional state, county
         and city codes */

  hr_utility.set_location('pay_us_emp_dt_tax_rules.default_tax',3);
      open csr_chk_addr_ovrd;
      fetch csr_chk_addr_ovrd into l_add_state_code,
                                   l_add_county_code,
                                   l_add_city_code;
      if csr_chk_addr_ovrd%NOTFOUND then
         l_add_state_code := null;
         l_add_county_code := null;
         l_add_city_code := null;
      end if;
      close csr_chk_addr_ovrd;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.default_tax',4);
     pay_us_emp_dt_tax_val.get_all_work_codes (p_assignment_id         => p_assignment_id,
                     p_session_date          => p_effective_start_date,
                     p_work_state_code       => l_work_state_code,
                     p_work_county_code      => l_work_county_code,
                     p_work_city_code        => l_work_city_code,
                     p_work_state_name       => l_work_state_name,
                     p_work_county_name      => l_work_county_name,
                     p_work_city_name        => l_work_city_name,
                     p_work1_state_code      => l_work1_state_code,
                     p_work1_county_code     => l_work1_county_code,
                     p_work1_city_code       => l_work1_city_code,
                     p_work1_state_name      => l_work1_state_name,
                     p_work1_county_name     => l_work1_county_name,
                     p_work1_city_name       => l_work1_city_name,
                     p_work2_state_code      => l_work2_state_code,
                     p_work2_county_code     => l_work2_county_code,
                     p_work2_city_code       => l_work2_city_code,
                     p_work2_state_name      => l_work2_state_name,
                     p_work2_county_name     => l_work2_county_name,
                     p_work2_city_name       => l_work2_city_name,
                     p_work3_state_code      => l_work3_state_code,
                     p_work3_county_code     => l_work3_county_code,
                     p_work3_city_code       => l_work3_city_code,
                     p_work3_state_name      => l_work3_state_name,
                     p_work3_county_name     => l_work3_county_name,
                     p_work3_city_name       => l_work3_city_name,
                     p_sui_state_code        => l_sui_state_code,
                     p_loc_city              => l_loc_city
                                                                );

      if l_work_state_code is null or l_work_county_code is null
         or l_work_city_code is null then
          fnd_message.set_name('PAY', 'PY_51133_TXADJ_INVALID_CITY');
          fnd_message.raise_error;
      end if;

     /* Insert the default Federal tax Record */

     l_fed_tax_rule_id :=
       insert_def_fed_rec(p_assignment_id        => p_assignment_id,
                          p_effective_start_date => p_effective_start_date,
                          p_effective_end_date   => p_effective_end_date,
                          p_sui_state_code       => l_sui_state_code,
                          p_business_group_id    => p_business_group_id);
     /* Insert the default State tax record */
     /* Create state record for works and if needed resident state rec also */
     l_state_tax_rule_id :=
     insert_def_state_rec(p_assignment_id        => p_assignment_id,
                          p_effective_start_date => p_effective_start_date,
                          p_effective_end_date   => p_effective_end_date,
                          p_state_code           => l_work_state_code,
                          p_business_group_id    => p_business_group_id,
                          p_percent_time         => 0);
     if l_work1_state_code is not null then
     l_state_tax_rule_id :=
     insert_def_state_rec(p_assignment_id        => p_assignment_id,
                          p_effective_start_date => p_effective_start_date,
                          p_effective_end_date   => p_effective_end_date,
                          p_state_code           => l_work1_state_code,
                          p_business_group_id    => p_business_group_id,
                          p_percent_time         => 0);
     end if;
     if l_work2_state_code is not null then
     l_state_tax_rule_id :=
     insert_def_state_rec(p_assignment_id        => p_assignment_id,
                          p_effective_start_date => p_effective_start_date,
                          p_effective_end_date   => p_effective_end_date,
                          p_state_code           => l_work2_state_code,
                          p_business_group_id    => p_business_group_id,
                          p_percent_time         => 0);
     end if;
     if l_work3_state_code is not null then
     l_state_tax_rule_id :=
     insert_def_state_rec(p_assignment_id        => p_assignment_id,
                          p_effective_start_date => p_effective_start_date,
                          p_effective_end_date   => p_effective_end_date,
                          p_state_code           => l_work3_state_code,
                          p_business_group_id    => p_business_group_id,
                          p_percent_time         => 0);
     end if;
     if nvl(l_work_state_code,l_res_state_code) <> l_res_state_code
        or nvl(l_work1_state_code,l_res_state_code) <> l_res_state_code
        or nvl(l_work2_state_code, l_res_state_code) <> l_res_state_code
        or nvl(l_work3_state_code, l_res_state_code) <> l_res_state_code then
       l_state_tax_rule_id :=
       insert_def_state_rec(p_assignment_id        => p_assignment_id,
                            p_effective_start_date => p_effective_start_date,
                            p_effective_end_date   => p_effective_end_date,
                            p_state_code           => l_res_state_code,
                            p_business_group_id    => p_business_group_id,
                            p_percent_time         => 0);

     end if;

     /* Now check for the override state */
     if l_add_state_code is not null
        and l_res_state_code <> l_add_state_code then
       l_state_tax_rule_id :=
       insert_def_state_rec(p_assignment_id        => p_assignment_id,
                            p_effective_start_date => p_effective_start_date,
                            p_effective_end_date   => p_effective_end_date,
                            p_state_code           => l_add_state_code,
                            p_business_group_id    => p_business_group_id,
                            p_percent_time         => 0);

     end if;
     /* Insert the default county tax record */
     l_county_tax_rule_id :=
     insert_def_county_rec(p_assignment_id      => p_assignment_id,
                           p_effective_start_date => p_effective_start_date,
                           p_effective_end_date   => p_effective_end_date,
                           p_state_code           => l_work_state_code,
                           p_county_code          => l_work_county_code,
                           p_business_group_id    => p_business_group_id,
                           p_percent_time         => 0);
     if l_work1_county_code is not null then
     l_county_tax_rule_id :=
     insert_def_county_rec(p_assignment_id      => p_assignment_id,
                           p_effective_start_date => p_effective_start_date,
                           p_effective_end_date   => p_effective_end_date,
                           p_state_code           => l_work1_state_code,
                           p_county_code          => l_work1_county_code,
                           p_business_group_id    => p_business_group_id,
                           p_percent_time         => 0);
     end if;
     if l_work2_county_code is not null then
     l_county_tax_rule_id :=
     insert_def_county_rec(p_assignment_id      => p_assignment_id,
                           p_effective_start_date => p_effective_start_date,
                           p_effective_end_date   => p_effective_end_date,
                           p_state_code           => l_work2_state_code,
                           p_county_code          => l_work2_county_code,
                           p_business_group_id    => p_business_group_id,
                           p_percent_time         => 0);
     end if;
     if l_work3_county_code is not null then
     l_county_tax_rule_id :=
     insert_def_county_rec(p_assignment_id      => p_assignment_id,
                           p_effective_start_date => p_effective_start_date,
                           p_effective_end_date   => p_effective_end_date,
                           p_state_code           => l_work3_state_code,
                           p_county_code          => l_work3_county_code,
                           p_business_group_id    => p_business_group_id,
                           p_percent_time         => 0);
     end if;
     if (l_work_state_code <> l_res_state_code or
         l_work_county_code <> l_res_county_code) then
        l_county_tax_rule_id :=

        insert_def_county_rec(p_assignment_id      => p_assignment_id,
                              p_effective_start_date => p_effective_start_date,
                              p_effective_end_date   => p_effective_end_date,
                              p_state_code           => l_res_state_code,
                              p_county_code          => l_res_county_code,
                              p_business_group_id    => p_business_group_id,
                              p_percent_time         => 0);
     end if;
     /* Check for the override county */
     if l_add_county_code is not null then
        l_county_tax_rule_id :=

        insert_def_county_rec(p_assignment_id      => p_assignment_id,
                              p_effective_start_date => p_effective_start_date,
                              p_effective_end_date   => p_effective_end_date,
                              p_state_code           => l_add_state_code,
                              p_county_code          => l_add_county_code,
                              p_business_group_id    => p_business_group_id,
                              p_percent_time         => 0);
     end if;

     /* Insert the default city tax record */
     if l_loc_city = l_work_state_code ||'-'||l_work_county_code ||'-'||l_work_city_code
     then
        l_percent := 100;
     else
        l_percent := 0;
     end if;

     l_city_tax_rule_id :=
     insert_def_city_rec(p_assignment_id      => p_assignment_id,
                         p_effective_start_date => p_effective_start_date,
                         p_effective_end_date   => p_effective_end_date,
                         p_state_code           => l_work_state_code,
                         p_county_code          => l_work_county_code,
                         p_city_code            => l_work_city_code,
                         p_business_group_id    => p_business_group_id,
                         p_percent_time         => l_percent);

     if l_work1_city_code is not null then
        if l_loc_city = l_work1_state_code ||'-'||l_work1_county_code ||'-'||l_work1_city_code
        then
           l_percent := 100;
        else
           l_percent := 0;
        end if;

        l_city_tax_rule_id :=
        insert_def_city_rec(p_assignment_id      => p_assignment_id,
                         p_effective_start_date => p_effective_start_date,
                         p_effective_end_date   => p_effective_end_date,
                         p_state_code           => l_work1_state_code,
                         p_county_code          => l_work1_county_code,
                         p_city_code            => l_work1_city_code,
                         p_business_group_id    => p_business_group_id,
                         p_percent_time         => l_percent);
     end if;

     if l_work2_city_code is not null then
        if l_loc_city = l_work2_state_code ||'-'||l_work2_county_code ||'-'||l_work2_city_code
        then
           l_percent := 100;
        else
           l_percent := 0;
        end if;

        l_city_tax_rule_id :=
        insert_def_city_rec(p_assignment_id      => p_assignment_id,
                         p_effective_start_date => p_effective_start_date,
                         p_effective_end_date   => p_effective_end_date,
                         p_state_code           => l_work2_state_code,
                         p_county_code          => l_work2_county_code,
                         p_city_code            => l_work2_city_code,
                         p_business_group_id    => p_business_group_id,
                         p_percent_time         => l_percent);
     end if;

     if l_work3_city_code is not null then
        if l_loc_city = l_work3_state_code ||'-'||l_work3_county_code ||'-'||l_work3_city_code
        then
           l_percent := 100;
        else
           l_percent := 0;
        end if;

        l_city_tax_rule_id :=
        insert_def_city_rec(p_assignment_id      => p_assignment_id,
                         p_effective_start_date => p_effective_start_date,
                         p_effective_end_date   => p_effective_end_date,
                         p_state_code           => l_work3_state_code,
                         p_county_code          => l_work3_county_code,
                         p_city_code            => l_work3_city_code,
                         p_business_group_id    => p_business_group_id,
                         p_percent_time         => l_percent);
     end if;

     if (l_work_state_code  <> l_res_state_code or
         l_work_county_code <> l_res_county_code or
         l_work_city_code   <> l_res_city_code) then
         l_city_tax_rule_id :=
         insert_def_city_rec(p_assignment_id      => p_assignment_id,
                             p_effective_start_date => p_effective_start_date,
                             p_effective_end_date   => p_effective_end_date,
                             p_state_code           => l_res_state_code,
                             p_county_code          => l_res_county_code,
                             p_city_code            => l_res_city_code,
                             p_business_group_id    => p_business_group_id,
                             p_percent_time         => 0);
      end if;
     /* Check for override city */
     if l_add_city_code is not null then
         l_city_tax_rule_id :=
         insert_def_city_rec(p_assignment_id      => p_assignment_id,
                             p_effective_start_date => p_effective_start_date,
                             p_effective_end_date   => p_effective_end_date,
                             p_state_code           => l_add_state_code,
                             p_county_code          => l_add_county_code,
                             p_city_code            => l_add_city_code,
                             p_business_group_id    => p_business_group_id,
                             p_percent_time         => 0);
      end if;
end default_tax;

procedure check_defaulting(p_assignment_id        in number,
                           p_effective_start_date in date,
                           p_business_group_id    in number,
                           p_from_form            in varchar2,
                           p_fed_exists           in out nocopy varchar2,
                           p_ret_code             in out nocopy number,
                           p_ret_text             in out nocopy varchar2 ) is


  /* Cursor to check if a federal record exists or not */
  cursor csr_chk_federal is
  select 'Y'
  from   DUAL
  where  exists ( select null
                  from   PAY_US_EMP_FED_TAX_RULES_F ftr
                  where  ftr.assignment_id = p_assignment_id);

  /* Cursor to get the max effective end date of the assignment */

  cursor csr_asg_end_date is
     select max(effective_end_date)
     from   PER_ASSIGNMENTS_F paf
     where  paf.assignment_id = p_assignment_id;

  l_effective_end_date     date;

begin

    /* Check to see if the defaulting of tax records has already taken place
       or not */

    open csr_chk_federal;

    fetch csr_chk_federal into p_fed_exists;

    if csr_chk_federal%NOTFOUND then

       p_fed_exists := 'N';

    else

       p_fed_exists := 'Y';

    end if;

    close csr_chk_federal;

    if p_fed_exists = 'N'
       and p_from_form in ('Assignment', 'Tax Rules','Address') then
       /* Check to see if future dated change in locations has taken
          place or not */

       if pay_us_emp_dt_tax_val.check_locations(p_assignment_id => p_assignment_id,
                              p_effective_start_date => p_effective_start_date,
                              p_business_group_id    => p_business_group_id)
       then

          /* message('Future dated location changes exist for which the
             defaulting criteria might not be satisfied.') */

          fnd_message.set_name('PAY', 'PAY_52299_TAX_FUT_LOC');
          fnd_message.raise_error;

       end if;

       /* Get the max effective end date of the assignment.
          This is done to take care of the terminated assignment
          so that the tax records do not get created for the time
          when the assignment is not valid. */

       open csr_asg_end_date;

       fetch csr_asg_end_date into l_effective_end_date;

       if l_effective_end_date is null then

         close csr_asg_end_date;
         fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token('PROCEDURE',
         'pay_us_emp_dt_tax_rules.check_defaulting');
         fnd_message.set_token('STEP','1');
         fnd_message.raise_error;

      end if;

      close csr_asg_end_date;

      /* Call the defaulting tax routine */

      default_tax ( p_assignment_id          => p_assignment_id,
                    p_effective_start_date   => p_effective_start_date,
                    p_effective_end_date     => l_effective_end_date,
                    p_business_group_id      => p_business_group_id,
                    p_ret_code               => p_ret_code,
                    p_ret_text               => p_ret_text);

   end if;

end check_defaulting;


procedure default_tax_with_validation(p_assignment_id        in number,
                                      p_person_id            in number,
                                      p_effective_start_date in date,
                                      p_effective_end_date   in date,
                                      p_session_date         in date,
                                      p_business_group_id    in number,
                                      p_from_form            in varchar2,
                                      p_mode                 in varchar2,
                                      p_location_id          in number,
                                      p_return_code          in out nocopy number,
                                      p_return_text          in out nocopy varchar2) is


l_code                  number;
l_time                  number;
l_assignment_id         number;
l_res_state_code        varchar2(2);
l_res_county_code       varchar2(3);
l_res_city_code         varchar2(4);
l_res_state_name        varchar2(35);
l_res_county_name       varchar2(35);
l_res_city_name         varchar2(35);
l_effective_end_date    date;
l_ret_code              number;
l_ret_text              varchar2(240);
l_default_date          date;
l_next_date             date;
l_payroll_installed     boolean := FALSE;
l_validation_start_date date;
l_fed_exists            varchar2(1) := 'N';
l_location_found        boolean := FALSE;
l_end_date              date;
l_next_start_date       date;
l_ovrd_loc              number;





  /* Cursor to get the assignment if called from
    the address form. */
/* rmonge  fix bug 3429449 */

  cursor csr_addr_get_assignment(p_person number) is
   select paf.assignment_id, min(paf.effective_start_date)
     from   per_addresses          pa,
            hr_soft_coding_keyflex hsck,
            per_assignments_f      paf
     where paf.person_id         = p_person
     and   paf.assignment_type   = 'E'
     and   paf.soft_coding_keyflex_id is not null
     and   paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
     and   paf.location_id       is not null
     and   paf.payroll_id        is not null
     and   paf.pay_basis_id      is not null
     and   pa.person_id           = paf.person_id
    --  and   pa.primary_flag        = 'Y'
     and (paf.effective_start_date between
        pa.date_from and nvl(pa.date_to,to_date('12/31/4712','MM/DD/YYYY'))
     or pa.date_from between paf.effective_start_date and paf.effective_end_date)
group by assignment_id;



/* old cursor */
/*
  cursor csr_addr_get_assignment(p_person number) is
     select paf.assignment_id, min(paf.effective_start_date)
     from   per_addresses          pa,
            hr_soft_coding_keyflex hsck,
            per_assignments_f      paf
     where paf.person_id         = p_person
     and   paf.assignment_type   = 'E'
     and   paf.soft_coding_keyflex_id is not null
     and   paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
     and   paf.location_id       is not null
     and   paf.payroll_id        is not null
     and   paf.pay_basis_id      is not null
     and   pa.person_id           = paf.person_id
     and   pa.primary_flag        = 'Y'
--     and  (paf.effective_end_date = to_date('12/31/4712','MM/DD/YYYY')

--Added for bug 2535501 June 10, 2003 except for the group by
-- p_effective_start_date is the p_date_from in the Address table
     and  paf.effective_end_date >= p_effective_start_date

 group by assignment_id ;
*/

/* added a check for paf.effective_end_date for bug 1640913 */

  cursor csr_get_assignment(p_person number) is
     select paf.assignment_id, min(paf.effective_start_date)
     from   per_addresses          pa,
            hr_soft_coding_keyflex hsck,
            per_assignments_f      paf
     where paf.person_id      = p_person
     and   paf.assignment_type = 'E'
     and   paf.soft_coding_keyflex_id is not null
     and   paf.effective_end_date = to_date('12/31/4712','MM/DD/YYYY')
     and   paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
     and   paf.location_id is not null
     and   paf.payroll_id is not null
     and   paf.pay_basis_id is not null
     and   pa.person_id        = paf.person_id
     and   pa.primary_flag     = 'Y'
     group by assignment_id ;

  /* Cursor to check if the default tax rules criteria is
     met for the assignment. keep in mind the assignment
     does not necessarily have to be a primary assignment */

  cursor csr_chk_assignment(p_assignment number, p_session_date date) is
         select 1
         from   per_addresses          pa,
                per_people_f           ppf,
                hr_soft_coding_keyflex hsck,
                per_assignments_f      paf
         where  paf.assignment_id = p_assignment
         and    p_session_date between paf.effective_start_date
                and paf.effective_end_date
         and    paf.soft_coding_keyflex_id is not null
         and    paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
         and    paf.location_id is not null
         and    paf.payroll_id is not null
         and    paf.pay_basis_id is not null
         and    ppf.person_id    = paf.person_id
         and    pa.person_id     = ppf.person_id
         and    pa.primary_flag     = 'Y';

  /* Get the minimum effective start date of the assignment for which
     the defaulting criteria has been satisfied */

  cursor csr_get_min_eff_date(p_assignment number) is
         select min(paf.effective_start_date)
         from   per_addresses          pa,
                per_people_f           ppf,
                hr_soft_coding_keyflex hsck,
                per_assignments_f      paf
         where  paf.assignment_id = p_assignment
         and    paf.soft_coding_keyflex_id is not null
         and    paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
         and    paf.location_id is not null
         and    paf.payroll_id is not null
         and    paf.pay_basis_id is not null
         and    ppf.person_id    = paf.person_id
         and    pa.person_id     = ppf.person_id
         and    pa.primary_flag     = 'Y';

  cursor csr_get_default_date (p_assignment number) is
         select min(effective_start_date)
         from   PAY_US_EMP_FED_TAX_RULES_F pef
         where  pef.assignment_id = p_assignment;

  cursor csr_get_end_date (p_assignment number,p_default_date date) is
         select effective_end_date
         from   PAY_US_EMP_FED_TAX_RULES_F pef
         where  pef.assignment_id = p_assignment
         and    pef.effective_start_date = p_default_date;

cursor csr_chk_addr_ovrd(p_assignment number) is
 select  pus.state_code,
         puc.county_code,
         pcn.city_code
  from   pay_us_city_names pcn,
         pay_us_counties puc,
         pay_us_states pus,
         per_addresses pa,
         per_assignments_f paf
  where  paf.assignment_id         = p_assignment
  and    p_effective_start_date between paf.effective_start_date and
                                paf.effective_end_date
  and    pa.person_id              = paf.person_id
  and    pa.primary_flag           = 'Y'
  and    p_effective_start_date between pa.date_from and
                                     nvl(pa.date_to,to_date('12/31/4712','MM/DD/YYYY'))
  and    pa.add_information17 is not null
  and    pa.add_information19 is not null
  and    pa.add_information18 is not null
  and pa.add_information17 = pus.state_abbrev
  and puc.state_code = pus.state_code
  and puc.county_name = pa.add_information19
  and pcn.state_code = puc.state_code
  and pcn.county_code = puc.county_code
  and pcn.city_name = add_information18;

/* rmonge fix for 3429449 */
/* adding new cursor to handle the call to csr_chk_addr_ovrd in the case of a  */
/* new Assignment with tax override . I need to pass p_effective_start_date */
/* the original cursor does not allow me to pass it */

cursor csr_chk_addr_ovrd_2(p_assignment number,p_effective_start_date date ) is
 select  pus.state_code,
         puc.county_code,
         pcn.city_code
  from   pay_us_city_names pcn,
         pay_us_counties puc,
         pay_us_states pus,
         per_addresses pa,
         per_assignments_f paf
  where  paf.assignment_id         = p_assignment
  and    p_effective_start_date between paf.effective_start_date and
                                paf.effective_end_date
  and    pa.person_id              = paf.person_id
  and    pa.primary_flag           = 'Y'
  and    p_effective_start_date between pa.date_from and
                                     nvl(pa.date_to,to_date('12/31/4712','MM/DD/YYYY'))
  and    pa.add_information17 is not null
  and    pa.add_information19 is not null
  and    pa.add_information18 is not null
  and pa.add_information17 = pus.state_abbrev
  and puc.state_code = pus.state_code
  and puc.county_name = pa.add_information19
  and pcn.state_code = puc.state_code
  and pcn.county_code = puc.county_code
  and pcn.city_name = add_information18;

/* rmonge end of changes */

/* begin modifications - dscully 21-JUN-2000 */
/* removed nvl to default return to location id */
/* instead, if cursor is NOTFOUND, we use location id */
cursor csr_get_ovrd_loc(p_assignment number, p_session_dt date) is
 select hsck.segment18
 from   HR_SOFT_CODING_KEYFLEX hsck,
        PER_ASSIGNMENTS_F      paf
 where  paf.assignment_id = p_assignment
 and    p_session_dt between paf.effective_start_date
                     and paf.effective_end_date
 and    hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
 and    hsck.segment18 is not null;

/* end modifications - dscully 21-JUN-2000 */

/* begin modifications - dscully 20-jul-2000 */
/* added cursors and vars for location maintenance in non payroll installs */

cursor csr_max_loc_date(p_assignment_id NUMBER, p_loc_id NUMBER
		       ,p_ef_date DATE) is
	select	min(paf.effective_start_date) - 1
	  from	per_assignments_f paf
	 where  paf.assignment_id = p_assignment_id
	   and	paf.effective_start_date > p_ef_date
	   and	paf.location_id <> p_loc_id;

cursor csr_min_loc_date(p_assignment_id NUMBER, p_loc_id NUMBER
		       ,p_ef_date DATE) is
	select 	max(paf.effective_end_date) + 1
	  from 	per_assignments_f paf
	 where 	paf.assignment_id = p_assignment_id
	   and	paf.effective_end_date < p_ef_date
	   and 	paf.location_id <> p_loc_id;

cursor csr_fed_tax_loc(p_assignment_id NUMBER, p_min_date DATE
		      ,p_max_date DATE) is
	select	*
	  from	pay_us_emp_fed_tax_rules_f ftr
	 where	ftr.assignment_id = p_assignment_id
	   and	ftr.effective_start_date <= p_max_date
	   and	ftr.effective_end_date >= p_min_date;

cursor csr_loc_state_code(p_location_id NUMBER) is
	select 	pus.state_code
	  from 	pay_us_states pus,
		hr_locations hl
	 where	hl.location_id = p_location_id
	   and	pus.state_abbrev = nvl(loc_information17,region_2);

/* end modifications - dscully 20-jul-2000*/

l_loc_min_date date;
l_loc_max_date date;
l_loc_state_code pay_us_states.state_code%TYPE;


l_add_state_code   varchar2(2);
l_add_county_code varchar2(3);
l_add_city_code   varchar2(4);
l_loc_id          hr_locations.location_id%TYPE;

begin

  -- hr_utility.trace_on(null,'AMITA');
  hr_utility.set_location('pay_us_emp_dt_tax_rules.validate_default',1);

  hr_utility.trace('validate_default-asg ** ' || to_char(p_assignment_id));
  hr_utility.trace('validate_default-person id ** ' || to_char(p_person_id));
  hr_utility.trace('validate_default-eff start dt ** ' || to_char(p_effective_start_date,'dd-mon-yyyy'));
  hr_utility.trace('validate_defaulteff end dt ** ' || to_char(p_effective_end_date,'dd-mon-yyyy'));
  hr_utility.trace('validate_default - session dt ** ' || to_char(p_session_date,'dd-mon-yyyy'));
  hr_utility.trace('validate_default- bg ** ' || to_char(p_business_group_id));
  hr_utility.trace('validate_default - form name ** ' || p_from_form);
  hr_utility.trace('validate_default - mode ** ' || p_mode);
  hr_utility.trace('validate_default - location id ** ' || to_char(p_location_id));
  --dbms_output.put_line('asg** '||to_char(p_assignment_id));
  --dbms_output.put_line('asg** '||to_char(p_person_id));
  --dbms_output.put_line('sd** '||to_char(p_effective_start_date));
  --dbms_output.put_line('ed** '||to_char(p_effective_end_date));
  --dbms_output.put_line('sd** '||to_char(p_session_date));
  --dbms_output.put_line('bg** ' || to_char(p_business_group_id));
  --dbms_output.put_line('bg** ' || p_from_form);
  --dbms_output.put_line('bg** ' || p_mode);
  --dbms_output.put_line('bg** ' || to_char(p_location_id));

  /* First check if geocode has been installed or not. If no geocodes
     installed then return because there is nothing to be done by this
     defaulting procedure */

  if hr_general.chk_maintain_tax_records = 'N' then
     return;
  end if;

  /* Check if payroll has been installed or not */

  l_payroll_installed := hr_utility.chk_product_install(p_product =>'Oracle Payroll',                                                                           p_legislation => 'US');

  /* Set up the validation start date */

  if p_from_form = 'Assignment' then

        if (p_mode = 'CORRECTION' or p_mode is null) then
           l_validation_start_date := p_effective_start_date;
        else
            l_validation_start_date := p_session_date;
        end if;

  end if;

  if p_from_form = 'Address' then

      hr_utility.set_location('pay_us_emp_dt_tax_rules.validate_default',2);

     /* Get all of the assignments */

     open csr_addr_get_assignment(p_person_id);


     loop

        fetch csr_addr_get_assignment into l_assignment_id, l_validation_start_date;



        exit when csr_addr_get_assignment%NOTFOUND;

        hr_utility.set_location('pay_us_emp_dt_tax_rules.validate_default',3);

        /* Check whether the defaulting of tax rules has been done or not.
           If not then do the defaulting of tax rules else return 'Y' in
           l_fed_exists to indicate that the defaulting of tax rules has
           already taken place. */

        check_defaulting(p_assignment_id        => l_assignment_id,
                         p_effective_start_date => l_validation_start_date,
                         p_business_group_id    => p_business_group_id,
                         p_from_form            => 'Address',
                         p_fed_exists           => l_fed_exists,
                         p_ret_code             => p_return_code,
                         p_ret_text             => p_return_text);

        if l_fed_exists = 'Y' then

           /* The following logic will take care of the affect of change in
              resident address to the tax rules records and the tax %age
             records.
             Get the state code, county code and the city code for the resident
             address */

           pay_us_emp_dt_tax_val.get_orig_res_codes (p_assignment_id    => l_assignment_id,
                          p_session_date     => p_effective_start_date,
                          p_res_state_code   => l_res_state_code,
                          p_res_county_code  => l_res_county_code,
                          p_res_city_code    => l_res_city_code,
                          p_res_state_name   => l_res_state_name,
                          p_res_county_name  => l_res_county_name,
                          p_res_city_name    => l_res_city_name);

           open csr_chk_addr_ovrd_2(l_assignment_id,greatest(p_effective_start_date,l_validation_start_date ));
           fetch csr_chk_addr_ovrd_2 into l_add_state_code,
                                        l_add_county_code,
                                        l_add_city_code;


           if csr_chk_addr_ovrd_2%NOTFOUND then
              l_add_state_code := null;
              l_add_county_code := null;
              l_add_city_code := null;

           end if;
           close csr_chk_addr_ovrd_2;

           /* create the state, county and tax records for the resident address,
              if they do not already exist. The following routine will first
              check for the existence of the record. Only if the record does
              not exist, it will create one along with its corresponding %age
              record */


           if l_res_state_code is not null and l_res_county_code is not null
           and l_res_city_code is not null then

               create_new_location_rec(p_assignment_id        => l_assignment_id,
                                   p_validation_start_date => null,
                                   p_validation_end_date   => null,
                                   p_session_date          => null,
                                   p_new_location_id       => null,
                                   p_res_state_code        => l_res_state_code,
                                   p_res_county_code       => l_res_county_code,
                                   p_res_city_code         => l_res_city_code,
                                   p_business_group        => p_business_group_id,
                                   p_percent               => 0);
           end if;

           if l_add_state_code is not null and l_add_county_code is not null
           and l_add_city_code is not null then

               create_new_location_rec(p_assignment_id        => l_assignment_id,
                                   p_validation_start_date => null,
                                   p_validation_end_date   => null,
                                   p_session_date          => null,
                                   p_new_location_id       => null,
                                   p_res_state_code        => l_add_state_code,
                                   p_res_county_code       => l_add_county_code,
                                   p_res_city_code         => l_add_city_code,
                                   p_business_group        => p_business_group_id,
                                   p_percent               => 0);
           end if;


       end if;

     end loop;

     close csr_addr_get_assignment;

  end if; /* End of address form specific */


  /* The person package will call this routine if and only if the
     hiring date is pulled back */

  if p_from_form = 'Person' then

    /* Get all of the employee assignments for the person */

    open csr_get_assignment(p_person_id);

    loop
       fetch csr_get_assignment into l_assignment_id, l_validation_start_date;

       exit when csr_get_assignment%NOTFOUND;

       hr_utility.set_location('pay_us_emp_dt_tax_rules.validate_default',3);

       /* Check whether the defaulting of tax rules has been done or not.
          If not then do the defaulting of tax rules else return 'Y' in
          l_fed_exists to indicate that the defaulting of tax rules has
          already taken place. */


       check_defaulting(p_assignment_id        => l_assignment_id,
                        p_effective_start_date => l_validation_start_date,
                        p_business_group_id    => p_business_group_id,
                        p_from_form            => 'Person',
                        p_fed_exists           => l_fed_exists,
                        p_ret_code             => p_return_code,
                        p_ret_text             => p_return_text);

        /* If the defaulting has take place i.e. tax records exist then pull
           back the tax rules as well as the tax %age records */

        if l_fed_exists = 'Y' then

          /* Get the default date */

          open csr_get_default_date(l_assignment_id);

          fetch csr_get_default_date into l_default_date;

          if l_default_date is null then

             close csr_get_default_date;
             fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
             fnd_message.set_token('PROCEDURE',
             'pay_us_emp_dt_tax_rules.default_tax_with_validation');
             fnd_message.set_token('STEP','1');
             fnd_message.raise_error;

          end if;

         close csr_get_default_date;

         /* Now check for pull back of the hiring date */

         check_hiring_date(p_assignment_id  => l_assignment_id,
                           p_default_date   => l_default_date,
                           p_s_start_date   => p_effective_start_date);

      end if;

    end loop;

    close csr_get_assignment;

  end if;  /* End of Person form processing */

  if p_from_form = 'Assignment' or p_from_form = 'Tax Rules' then

     hr_utility.set_location('pay_us_emp_dt_tax_rules.validate_default',5);

     if p_from_form = 'Tax Rules' then

        /* Get the min effective start date of the assignment for which the
           defaulting criteria has been met */

        open csr_get_min_eff_date(p_assignment_id);

        fetch csr_get_min_eff_date into l_validation_start_date;

        if l_validation_start_date is null then

           hr_utility.set_location('pay_us_emp_dt_tax_rules.validate_default',6);

           p_return_code := 1;
           p_return_text := 'Default rules not satisfied';
           close csr_get_min_eff_date;
           return;

        end if;

        close csr_get_min_eff_date;

     elsif p_from_form = 'Assignment' then

        open csr_chk_assignment(p_assignment_id, l_validation_start_date);

        fetch csr_chk_assignment into l_code;

        if csr_chk_assignment%NOTFOUND then

           hr_utility.set_location('pay_us_emp_dt_tax_rules.validate_default',7);

           p_return_code := 1;
           p_return_text := 'Default rules not satisfied';
           close csr_chk_assignment;
           return;

        end if;

        close csr_chk_assignment;

     end if;

     /* Assign the assignment id to the l_assignment_id so that the same
        variable can be used for all of the forms, to call the default_tax
        routine */

     l_assignment_id := p_assignment_id;

     /* Check whether the defaulting of tax rules has been done or not.
        If not then do the defaulting of tax rules else return 'Y' in
        l_fed_exists to indicate that the defaulting of tax rules has
        already taken place. */

     check_defaulting(p_assignment_id        => p_assignment_id,
                      p_effective_start_date => l_validation_start_date,
                      p_business_group_id    => p_business_group_id,
                      p_from_form            => p_from_form,
                      p_fed_exists           => l_fed_exists,
                      p_ret_code             => p_return_code,
                      p_ret_text             => p_return_text);

     /* We will commit only if this routine has been called by the 'Tax Rules
        screen' and the defaulting of tax rules has gone through fine. We
        cannot commit in the Tax Rules screen because this routine gets
        called in the when new form instance trigger and if we commit after
        that the date tracked modes come up. So, commit if and only if called
        by the Tax Rules i.e. the W4 screen */

     if l_fed_exists = 'N' and
        p_from_form = 'Tax Rules' and p_return_code = 0 then

         commit;

     end if;


     if l_fed_exists = 'Y' then

        /* Get the default date */

        open csr_get_default_date(p_assignment_id);

        fetch csr_get_default_date into l_default_date;

        if csr_get_default_date%NOTFOUND then

           close csr_get_default_date;
           fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
           fnd_message.set_token('PROCEDURE',
           'pay_us_emp_dt_tax_rules.default_tax_with_validation');
           fnd_message.set_token('STEP','2');
           fnd_message.raise_error;

        end if;

        close csr_get_default_date;

     end if;

  end if; /* This marks the end of processing when called by the 'Tax Rules */

  hr_utility.set_location('pay_us_emp_dt_tax_rules.validate_default',8);


  /* begin modifications - dscully 21-JUN-2000 */
  /* added default creation of tax records for taxation location */

  if p_from_form = 'Assignment' then

     l_assignment_id := p_assignment_id;

     /* check to see if there is an override location at the asg. level .
        If there is then set the override as p_location_id */
     l_loc_id := p_location_id;
     open csr_get_ovrd_loc(l_assignment_id, p_session_date);
     fetch csr_get_ovrd_loc into l_ovrd_loc;
     if csr_get_ovrd_loc%found then
           l_loc_id := l_ovrd_loc;
     end if;
     close csr_get_ovrd_loc;

     /* if a taxation location is set on the assignment create a default tax record */
     if l_ovrd_loc is not null then

	/* this procedure checks to make sure record does not yet exist */
	/* the date params are null because they only matter when setting non-zero
	   percentages */

	create_new_location_rec(p_assignment_id => p_assignment_id,
                                  p_validation_start_date => null,
                                  p_validation_end_date   => null,
                                  p_session_date          => null,
                                  p_new_location_id       => l_ovrd_loc,
                                  p_res_state_code        => null,
                                  p_res_county_code       => null,
                                  p_res_city_code         => null,
                                  p_business_group        => p_business_group_id,
                                  p_percent               => 0); /* if l_ovrd_loc is not null */

-- Added to take care SUI Wage Base Override enh
-- Turning Off SUI Wage Base Override Functionality due to Bug# 5486281
     /*
     else
         -- Start of SUI Wage Base Override Change
	     --
         -- Update SUI WAGE BASE Overide amount you have payroll installed otherwise don't
	     -- call the procedure which does the update


         IF  hr_utility.chk_product_install(p_product =>'Oracle Payroll',
                                            p_legislation => 'US')
         then
                  if p_assignment_id is not null and p_session_date is not null
        		  then
                       set_sui_wage_base_override(p_assignment_id,
		                                          null,
									              p_session_date) ;
                  end if ;
         end if;
	      --
          -- End of SUI Wage Base Override Change
	      --
      */
     end if; /* if l_ovrd_loc is not null */

     /* if the location changed do a bunch of element entry manipulation */

     if (p_location_id is not null) then

     if (l_payroll_installed) then
      /* end modifications - dscully 21-JUN-2000 */
      /* begin modifications - dscully 19-JUL-2000 */
      /* added code to handle location changes for non-payroll customers */

      if p_mode = 'CORRECTION' then

        /*

                     | Session date
                     v
              L1    L2     L3            L4            L4
        Asg |-----|-----|-------------|--------------|------
        Fed             |-------------|---------------------
        %age            |-------------|---------------------
        */

        if p_effective_end_date < l_default_date then

           select p_effective_end_date + 1
           into   l_next_date
           from   SYS.DUAL;

           if l_next_date < l_default_date then

             /* There are some more assignment records without the
                tax records. So, error it out */

              fnd_message.set_name('PAY', 'PAY_52292_TAX_DEF_CRT');
              fnd_message.raise_error;

           else

              /* First update the tax rules records */

              pull_tax_records(p_assignment_id     => l_assignment_id,
                               p_new_start_date    => p_effective_start_date,
                               p_default_date      => l_default_date);

              /* set the effective start date of the wc entry to the
                 new effective start date i.e. the p_effective_start_date */

              del_updt_wc_entry_for_dates (p_assignment_id   => l_assignment_id,
                                      p_session_date         => l_default_date,
                                      p_new_start_date       => p_effective_start_date,
                                      p_new_end_date         => null,
                                      p_mode                 => 'U');

               pull_percentage(p_assignment_id        => l_assignment_id,
                               p_default_date         => l_default_date,
                               p_effective_start_date => p_effective_start_date,
                               p_effective_end_date   => p_effective_end_date,
                               p_session_date         => p_session_date,
                               p_new_location_id      => p_location_id,
                               p_business_group_id    => p_business_group_id);
             end if;
        else

          /* Correct the federal tax record and the worker's comp element entry for
             the new SUI Jurisdiction code and SUI state */

          change_wc_entry (p_assignment_id        => l_assignment_id,
                           p_effective_start_date => p_effective_start_date,
                           p_effective_end_date   => p_effective_end_date,
                           p_session_date         => p_session_date,
                           p_new_location_id      => l_loc_id,
                           p_mode                 => p_mode,
                           p_ret_code             => l_ret_code,
                           p_ret_text             => l_ret_text);

          /* Change the tax %age records for a correction in the
             location of the assignment */

          correct_percentage (p_assignment_id        => l_assignment_id,
                              p_effective_start_date => p_effective_start_date,
                              p_effective_end_date   => p_effective_end_date,
                              p_session_date         => p_session_date,
                              p_new_location_id      => p_location_id,
                              p_business_group_id    => p_business_group_id,
                              p_ret_code             => l_ret_code,
                              p_ret_text             => l_ret_text);

        end if;

      elsif p_mode in ('UPDATE','UPDATE_OVERRIDE','UPDATE_CHANGE_INSERT') then

          /* Update the federal tax record and the worker's comp element entry for
             the new SUI Jurisdiction code and SUI state */

          change_wc_entry (p_assignment_id        => l_assignment_id,
                           p_effective_start_date => p_effective_start_date,
                           p_effective_end_date   => p_effective_end_date,
                           p_session_date         => p_session_date,
                           p_new_location_id      => l_loc_id,
                           p_mode                 => p_mode,
                           p_ret_code             => l_ret_code,
                           p_ret_text             => l_ret_text);

         /* Change the %age records for the type of update in the
            location of the assignment */

         update_percentage (p_assignment_id        => l_assignment_id,
                            p_effective_start_date => p_effective_start_date,
                            p_effective_end_date   => p_effective_end_date,
                            p_session_date         => p_session_date,
                            p_new_location_id      => p_location_id,
                            p_business_group_id    => p_business_group_id,
                            p_mode                 => p_mode,
                            p_ret_code             => l_ret_code,
                            p_ret_text             => l_ret_text);

      elsif p_mode = 'DELETE_NEXT_CHANGE' then

         /* In case of DELETE_NEXT_CHANGE, if the next location is different from
            the current location then the assignment screen will error it out.
            If the next location is same as the current location then :

                                  | Session Date
                             L1   v               L1
            Asg.      |--------------------|-------------------------
            Tax Rules                      |-------------------------
            Tax %age                       |-------------------------

            In this scenario, the assignment routine deletes the tax %age records
            but does not delete the tax rules records. So, our tax routine will have
            to delete the tax rules records.

                             | Session Date
                      T1     v  T2        T3       T4      T5
                          L1         L1       L1      L1       L1
            Asg.      |---------|---------|--------|-------|---------
            Tax Rules           |------------------------------------
            Tax %age            |------------------------------------

            Here, the tax rules and the tax %age records will have to be pulled forward to
            time T3.

                                       | Session Date
                          L1        L1 v     L1      L2       L3
            Asg.      |---------|---------|--------|-------|---------
            Tax Rules           |------------------------------------
            Tax %age            |------------------|-------|---------

            In the above scenario, the assignment routine will only delete the next
            assignment record and will not do anything to the tax %age records, which
            is fine and that's how it should be.

                                                        | Session Date
                          L1        L1       L1      L3 v     L3
            Asg.      |---------|---------|--------|-------|---------
            Tax Rules           |------------------------------------
            Tax %age            |------------------|-----------------

            Here also, we do not need to do anything as the %age records do not get affected
            by the deletion of the assignment record.  */

            open csr_get_end_date(p_assignment_id,l_default_date);

            fetch csr_get_end_date into l_end_date;

            if csr_get_end_date%NOTFOUND then

               close csr_get_end_date;
               fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
               fnd_message.set_token('PROCEDURE',
               'pay_us_emp_dt_tax_rules.default_tax_with_validation');
               fnd_message.set_token('STEP','3');
               fnd_message.raise_error;

            end if;

            close csr_get_end_date;


            if (l_end_date   = to_date('31-12-4712','dd-mm-yyyy')) and
            not pay_us_emp_dt_tax_val.check_locations(p_assignment_id => p_assignment_id,
                                           p_effective_start_date => p_session_date,
                                           p_business_group_id    => p_business_group_id)
            then

                /* Delete records from PAY_US_EMP_CITY_TAX_RULES_F */

                delete PAY_US_EMP_CITY_TAX_RULES_F
                where assignment_id = p_assignment_id
                and business_group_id = p_business_group_id;

                /* Delete records from PAY_US_EMP_COUNTY_TAX_RULES_F */

                delete PAY_US_EMP_COUNTY_TAX_RULES_F
                where assignment_id = p_assignment_id
                and business_group_id = p_business_group_id;

                /* Delete records from PAY_US_EMP_STATE_TAX_RULES_F */

                delete PAY_US_EMP_STATE_TAX_RULES_F
                where assignment_id = p_assignment_id
                and business_group_id = p_business_group_id;

                /* Delete records from PAY_US_EMP_FED_TAX_RULES_F */

                delete PAY_US_EMP_FED_TAX_RULES_F
                where assignment_id = p_assignment_id
                and business_group_id = p_business_group_id;

            else

                 select l_default_date + 1
                 into l_next_start_date
                 from DUAL;

                 pull_tax_records(p_assignment_id     => p_assignment_id,
                                  p_new_start_date    => l_next_start_date,
                                  p_default_date      => l_default_date);
            end if;

      elsif p_mode = 'FUTURE_CHANGE' then

         /* Delete the next set of %age records */
            upd_del_entries(p_assignment_id  => l_assignment_id,
                            p_session_date   => p_session_date,
                            p_new_start_date => null,
                            p_new_end_date   => null,
                            p_mode           => 'F');

      end if; /* for correction/update/delete */

    /* begin modifications - dscully 20-jul-2000 */
    /* added hr only location code */

    else -- payroll is not installed

     /* This is being added for customers with the NA Address Patch but not payroll */
     /* In a perfect world, we would wrap the element entry code in the location maintenance */
     /* with if_payroll_installed checks.  However, since this is payroll, that would make too */
     /* much sense.  Because of the amount of ugliness and QA involved in retesting it in a */
     /* payroll context, we are just tacking on this code instead. */

     /* Because there are no element entries, we determine changes in location by looking at */
     /* the assignment record itself(which might be a better way of doing it!). */

     /* first lets make sure the record exists */

     hr_utility.set_location('pay_us_emp_dt_tax_rules.validate_default',100);

     create_new_location_rec(p_assignment_id => p_assignment_id,
                                  p_validation_start_date => null,
                                  p_validation_end_date   => null,
                                  p_session_date          => null,
                                  p_new_location_id       => p_location_id,
                                  p_res_state_code        => null,
                                  p_res_county_code       => null,
                                  p_res_city_code         => null,
                                  p_business_group        => p_business_group_id,
                                  p_percent               => 0);


     /* next we get the begin and end dates for the new location being effective
        along with the state code of the jurisdiction */

     hr_utility.set_location('pay_us_emp_dt_tax_rules.validate_default',105);

     open csr_max_loc_date(p_assignment_id,p_location_id,l_validation_start_date);
     fetch csr_max_loc_date into l_loc_max_date;
     close csr_max_loc_date;

     if l_loc_max_date is null then
	l_loc_max_date := hr_api.g_eot;
     end if;

     --

     hr_utility.set_location('pay_us_emp_dt_tax_rules.validate_default',110);

     open csr_min_loc_date(p_assignment_id,p_location_id,l_validation_start_date);
     fetch csr_min_loc_date into l_loc_min_date;
     close csr_min_loc_date;

     if l_loc_min_date is null then
	l_loc_min_date := hr_api.g_sot;
     end if;

     --
     hr_utility.set_location('pay_us_emp_dt_tax_rules.validate_default',115);

     open csr_loc_state_code(p_location_id);
     fetch csr_loc_state_code into l_loc_state_code;

     if csr_loc_state_code%NOTFOUND then
             close csr_loc_state_code;
             fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
             fnd_message.set_token('PROCEDURE',
             'pay_us_emp_dt_tax_rules.default_tax_with_validation');
             fnd_message.set_token('STEP','10');
             fnd_message.raise_error;
     end if;

     close csr_loc_state_code;

     --

     /* we update all records that partially fall within that date range */

     for tax_rec in csr_fed_tax_loc(p_assignment_id,l_loc_min_date,l_loc_max_date) loop

	if tax_rec.effective_start_date < l_loc_min_date then

	/* we go from:
		ASG --------------|-------L1-----------------
		TAX ----------|------------------------------
	   to:
		ASG --------------|-------L1-----------------
		TAX ----------|---|--------------------------
	*/
  	        hr_utility.set_location('pay_us_emp_dt_tax_rules.validate_default',120);

		/* insert the middle record */
		insert_fed_tax_row(
     			tax_rec.emp_fed_tax_rule_id,
      			l_loc_min_date,
      			tax_rec.effective_end_date,
      			tax_rec.assignment_id,
      			l_loc_state_code,
      			l_loc_state_code || '-000-0000',
      			tax_rec.business_group_id,
      			tax_rec.additional_wa_amount,
      			tax_rec.filing_status_code,
      			tax_rec.fit_override_amount,
      			tax_rec.fit_override_rate,
      			tax_rec.withholding_allowances,
      			tax_rec.cumulative_taxation,
      			tax_rec.eic_filing_status_code,
      			tax_rec.fit_additional_tax,
      			tax_rec.fit_exempt,
      			tax_rec.futa_tax_exempt,
      			tax_rec.medicare_tax_exempt,
      			tax_rec.ss_tax_exempt,
      			tax_rec.wage_exempt,
      			tax_rec.statutory_employee,
      			tax_rec.w2_filed_year,
      			tax_rec.supp_tax_override_rate,
      			tax_rec.excessive_wa_reject_date,
                tax_rec.attribute_category,
                tax_rec.attribute1,
                tax_rec.attribute2,
                tax_rec.attribute3,
                tax_rec.attribute4,
                tax_rec.attribute5,
                tax_rec.attribute6,
                tax_rec.attribute7,
                tax_rec.attribute8,
                tax_rec.attribute9,
                tax_rec.attribute10,
                tax_rec.attribute11,
                tax_rec.attribute12,
                tax_rec.attribute13,
                tax_rec.attribute14,
                tax_rec.attribute15,
                tax_rec.attribute16,
                tax_rec.attribute17,
                tax_rec.attribute18,
                tax_rec.attribute19,
                tax_rec.attribute20,
                tax_rec.attribute21,
                tax_rec.attribute22,
                tax_rec.attribute23,
                tax_rec.attribute24,
                tax_rec.attribute25,
                tax_rec.attribute26,
                tax_rec.attribute27,
                tax_rec.attribute28,
                tax_rec.attribute29,
                tax_rec.attribute30,
                tax_rec.fed_information_category,
                tax_rec.fed_information1,
                tax_rec.fed_information2,
                tax_rec.fed_information3,
                tax_rec.fed_information4,
                tax_rec.fed_information5,
                tax_rec.fed_information6,
                tax_rec.fed_information7,
                tax_rec.fed_information8,
                tax_rec.fed_information9,
                tax_rec.fed_information10,
                tax_rec.fed_information11,
                tax_rec.fed_information12,
                tax_rec.fed_information13,
                tax_rec.fed_information14,
                tax_rec.fed_information15,
                tax_rec.fed_information16,
                tax_rec.fed_information17,
                tax_rec.fed_information18,
                tax_rec.fed_information19,
                tax_rec.fed_information20,
                tax_rec.fed_information21,
                tax_rec.fed_information22,
                tax_rec.fed_information23,
                tax_rec.fed_information24,
                tax_rec.fed_information25,
                tax_rec.fed_information26,
                tax_rec.fed_information27,
                tax_rec.fed_information28,
                tax_rec.fed_information29,
                tax_rec.fed_information30,
			'UPDATE');
	else

	/* here we simply update the sui codes */

  		hr_utility.set_location('pay_us_emp_dt_tax_rules.validate_default',125);

		update pay_us_emp_fed_tax_rules_f
		   set sui_state_code = l_loc_state_code,
		       sui_jurisdiction_code = l_loc_state_code || '-000-0000'
 		 where emp_fed_tax_rule_id = tax_rec.emp_fed_tax_rule_id
		   and effective_start_date = tax_rec.effective_start_date;

	end if;

	if tax_rec.effective_end_date > l_loc_max_date then
	/* we go from the case:
		ASG -------L1-----------------|--------------
		TAX --------------------------------|--------
	   to
		ASG -------L1-----------------|--------------
		TAX --------------------------|-----|--------
	*/

  		hr_utility.set_location('pay_us_emp_dt_tax_rules.validate_default',130);

		insert_fed_tax_row(
	     		tax_rec.emp_fed_tax_rule_id,
      			l_loc_max_date + 1,
      			tax_rec.effective_end_date,
      			tax_rec.assignment_id,
      			tax_rec.sui_state_code,
      			tax_rec.sui_jurisdiction_code,
      			tax_rec.business_group_id,
      			tax_rec.additional_wa_amount,
      			tax_rec.filing_status_code,
      			tax_rec.fit_override_amount,
      			tax_rec.fit_override_rate,
      			tax_rec.withholding_allowances,
      			tax_rec.cumulative_taxation,
      			tax_rec.eic_filing_status_code,
      			tax_rec.fit_additional_tax,
      			tax_rec.fit_exempt,
      			tax_rec.futa_tax_exempt,
      			tax_rec.medicare_tax_exempt,
      			tax_rec.ss_tax_exempt,
      			tax_rec.wage_exempt,
      			tax_rec.statutory_employee,
      			tax_rec.w2_filed_year,
      			tax_rec.supp_tax_override_rate,
      			tax_rec.excessive_wa_reject_date,
                tax_rec.attribute_category,
                tax_rec.attribute1,
                tax_rec.attribute2,
                tax_rec.attribute3,
                tax_rec.attribute4,
                tax_rec.attribute5,
                tax_rec.attribute6,
                tax_rec.attribute7,
                tax_rec.attribute8,
                tax_rec.attribute9,
                tax_rec.attribute10,
                tax_rec.attribute11,
                tax_rec.attribute12,
                tax_rec.attribute13,
                tax_rec.attribute14,
                tax_rec.attribute15,
                tax_rec.attribute16,
                tax_rec.attribute17,
                tax_rec.attribute18,
                tax_rec.attribute19,
                tax_rec.attribute20,
                tax_rec.attribute21,
                tax_rec.attribute22,
                tax_rec.attribute23,
                tax_rec.attribute24,
                tax_rec.attribute25,
                tax_rec.attribute26,
                tax_rec.attribute27,
                tax_rec.attribute28,
                tax_rec.attribute29,
                tax_rec.attribute30,
                tax_rec.fed_information_category,
                tax_rec.fed_information1,
                tax_rec.fed_information2,
                tax_rec.fed_information3,
                tax_rec.fed_information4,
                tax_rec.fed_information5,
                tax_rec.fed_information6,
                tax_rec.fed_information7,
                tax_rec.fed_information8,
                tax_rec.fed_information9,
                tax_rec.fed_information10,
                tax_rec.fed_information11,
                tax_rec.fed_information12,
                tax_rec.fed_information13,
                tax_rec.fed_information14,
                tax_rec.fed_information15,
                tax_rec.fed_information16,
                tax_rec.fed_information17,
                tax_rec.fed_information18,
                tax_rec.fed_information19,
                tax_rec.fed_information20,
                tax_rec.fed_information21,
                tax_rec.fed_information22,
                tax_rec.fed_information23,
                tax_rec.fed_information24,
                tax_rec.fed_information25,
                tax_rec.fed_information26,
                tax_rec.fed_information27,
                tax_rec.fed_information28,
                tax_rec.fed_information29,
                tax_rec.fed_information30,
			'UPDATE');
	end if;
     end loop;

     /* end modifications - dscully 20-jul-2000 */
     hr_utility.set_location('pay_us_emp_dt_tax_rules.validate_default',140);
    end if; /* for payroll installed/not installed */
    end if; /* for location id is not null */

  end if; /* call from assignment form */



end; /*default_tax_with_validation */
  /* Name        : check_nra_status
     Purpose     : To check whether the employee is a Non Resident Alien.
                   Internal revenue doesnot allow NRA to claim W4 allowances >1
     Added by vaprakas 12/5/2006 bug 5607135

  */
procedure check_nra_status(p_assignment_id          in number,
                           p_withholding_allowances in number,
                           p_filing_status_code     in varchar2,
                           p_fit_exempt             in varchar2,
                           p_effective_start_date   in date,
                           p_effective_end_date     in date,
			   p_returned_warning       OUT NOCOPY VARCHAR2)
is
l_information_type           per_people_extra_info.information_type%TYPE;
l_pei_information_category   per_people_extra_info.pei_information_category%TYPE;
l_pei_information5           per_people_extra_info.pei_information5%TYPE;
l_pei_information9           per_people_extra_info.pei_information9%TYPE;

l_student_flag               varchar2(3);
l_student                    per_people_extra_info.pei_information1%TYPE;
l_business_apprentice        per_people_extra_info.pei_information2%TYPE;
l_warning                    VARCHAR2(300);


cursor csr_chk_student_status
            is
            select pei_information1,pei_information2
            from per_people_extra_info where person_id=(select distinct person_id from per_all_assignments_f
                                                    where assignment_id=p_assignment_id
                                                    and primary_flag='Y')
                          and information_type like 'PER_US_ADDITIONAL_DETAILS'
                          and pei_information_category like 'PER_US_ADDITIONAL_DETAILS'
			  and (pei_information1 = 'Y'
                or pei_information2 = 'Y');

cursor csr_chk_nra_status
is
select information_type,pei_information_category,pei_information5,pei_information9
from per_people_extra_info where person_id=(select distinct person_id from per_all_assignments_f
                                                    where assignment_id=p_assignment_id
                                                    and primary_flag='Y')
                           and information_type like 'PER_US_ADDITIONAL_DETAILS'
                           and pei_information_category like 'PER_US_ADDITIONAL_DETAILS'
                           and pei_information5 like 'N'
                           and pei_information9 not in ('US');
begin
   l_student_flag :='No';

   open csr_chk_student_status;
   fetch csr_chk_student_status into l_student,l_business_apprentice;
   if csr_chk_student_status%FOUND
	then l_student_flag :='Yes';
   end if;
   close csr_chk_student_status;

    open csr_chk_nra_status;
    fetch csr_chk_nra_status into
    l_information_type,l_pei_information_category,l_pei_information5,l_pei_information9;
        if csr_chk_nra_status%FOUND
          then
          if p_withholding_allowances > 1 and not
                   (l_pei_information9 in ('CA','MX','KS') or (l_student_flag ='Yes' and l_pei_information9 = 'IN'))
			then
	    l_warning := 'PAY_US_CHK_NRA_W4_ALLOWANCES';
            fnd_message.set_name('PAY', 'PAY_US_CHK_NRA_W4_ALLOWANCES');
            fnd_message.raise_error;
          end if;
          if p_filing_status_code <> '01'
            then
	    l_warning := 'PAY_US_CHK_NRA_FILING_STATUS';
            fnd_message.set_name('PAY', 'PAY_US_CHK_NRA_FILING_STATUS');
	    fnd_message.raise_error;
          end if;
          if (p_fit_exempt = 'Y')
            then
	    l_warning := 'PAY_US_CHK_NRA_FIT_EXEMPTIONS';
        /**    fnd_message.set_name('PAY', 'PAY_US_CHK_NRA_FIT_EXEMPTIONS');
	    fnd_message.raise_error; **/
          end if;
       end if;
    close csr_chk_nra_status;
    p_returned_warning := l_warning;
end check_nra_status;


end pay_us_emp_dt_tax_rules;


/
