--------------------------------------------------------
--  DDL for Package Body HR_DYNSQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DYNSQL" as
/* $Header: pydynsql.pkb 120.30.12010000.7 2009/05/04 10:56:54 phattarg ship $ */
   -- cache for get_tax_unit
   g_cached      boolean := FALSE;
   g_tax_unit    pay_legislation_rules.rule_mode%type;
   g_local_unit  pay_legislation_rules.rule_mode%type;
   -- Define PL/SQL Table type.
   type char60_table is table of VARCHAR2(60)
              index by binary_integer;
--
   rrsel     varchar(1000); -- select list for range row select.
   retasactsel varchar(1000); -- select list for Retropay assignment action insert.
   retpgasactsel varchar(1000); -- select list for Retropay assignment action insert.
   ordrrsel  varchar(1000); -- select list for range row select with ORDERED hint.
   prrsel    varchar(100);  -- select list for Purge range row select.
   brrsel    varchar(1000); -- select list for range row select for BEE.
   asactsel  varchar(1000); -- select list for assignment action insert.
   orgsel    varchar(1000); -- select list for range rows for Organisations.
   runasactsel varchar(1000); -- select list for Run assignment action insert.
   puractsel varchar(1000); -- select list for Purge assignment action insert.
   allasg    varchar(1000); -- from and where clause for all assignments.
   beeasg    varchar(1000); -- sql for all assignments for BEE.
   beeactsel varchar(1000); -- select list for assignment action insert.
   revallasg varchar(3000); -- select list for reversal asg action insert.
   purallasg varchar(1000); -- Purge range row from and where clause.
   allretasg varchar(1000); -- from and where clause for all retropay
                            -- assignments.
   allrcsasg varchar(3000); -- from and where clause for all retrocosting
                            -- assignments
   alladvasg varchar(3000); -- from and where clause for all advance
                            -- assignments
   alladeasg varchar(3000); -- from and where clause for all advance
                            -- pay by element assignments.
   revaa     varchar(3000); -- check for existenace of valid reversal assmnt
                            -- actions
                            -- assignments.
   rspcinc   varchar(1500); -- from and where clause for specific inclusions in
                            -- range creation stage.
   spcinc    varchar(1500); -- from and where clause for specific inclusions in
                            -- action creation stage.
   purspcinc varchar(1000); -- Purge specific inclusions.
   revspcinc varchar(1500); -- Reversal specific inclusions
   spcretinc varchar(1000); -- from and where clause for specific retropay
                            -- inclusions.
   adeincspc varchar(3000); -- from and where clause for specific advance
                            -- pay by element inclusions.
   spcrcsinc varchar(3000); -- from and where clause for specific retrocosting
                            -- inclusions.
   range     varchar(1000); -- restrict to particular range of person_id.
   poprange  varchar(1000); -- use of person_id in range table.
   nopoprange varchar(1000); -- range used by process
   grppoprange  varchar(1000); -- use of person_id in range table.
   grpnopoprange varchar(1000); -- range used by process
   resact    varchar(1500); -- from and where clause for resricted actions.
   nonact    varchar(1500); -- from and where clause for unresricted actions.
   pruresact varchar(1500); -- from and where clause for resricted actions.
   prunonact varchar(1500); -- from and where clause for unresricted actions.
   ecsresact varchar(1500); -- from and where clause for resricted actions
                            -- for estimate costing process.
   ecsnonact varchar(1500); -- from and where clause for unresricted actions
                            -- for estimate costing process.
   excspc    varchar(1000); -- exclude assignments.
   intind    varchar(1000); -- interlock rules for time independent
                            -- legislation.
   intretgrpdep varchar(1000); -- interlock rules for retropay time dependent
   intretind varchar(1000); -- interlock rules for retropay time independent
                            -- legislation.
   intdep    varchar(1000); -- interlock rules for time dependent legislation.
   intbaldep varchar(1000); -- interlock rules for bal adj time dependent legislation.
   intretdep varchar(1000); -- interlock rules for retropay time dependent legislation.
   intgrpdep varchar(1000); -- interlock rules for group dependent legislation.
   intgrpdepbal varchar(1000); -- interlock rules for bal adj group dependent legislation.
   intgrpdepret varchar(1000); -- interlock rules for retropay group dependent legislation.
   intdepaset varchar(1000); -- interlock rules for time dependent legislation.
   intbaldepaset varchar(1000); -- interlock rules for bal adj time dependent legislation.
   intretdepaset varchar(1000); -- interlock rules for retropay time dependent legislation.
   intpur    varchar(2500); -- interlock rules for Purge.
   intbal   varchar(1500); -- interlock rules for balance adjustment.
   orderby   varchar(1000); -- order by clause.
   borderby  varchar(1000); -- order by clause for BEE.
   actorderby varchar(1000); -- action order by clause.
   fupdate   varchar(1000); -- for update clause.
   retdefasg varchar(1000); -- from and where clause for all retropay
                            -- by element asg (with retro definition id)
   retdefasgpg varchar(2000); -- from and where clause for all retropay
                              -- by element using process groups
   orgfrom     varchar(2000); -- From clause for payment organisations
   orgorderby  varchar(1000); -- Order by for the organisation list
   orgbind     varchar(1000); -- Sets the direct bind variable
--
   c_eot constant date := to_date('31/12/4712','DD/MM/YYYY');
   max_dynsql_len constant number := 4000;
--
   ----------------------------- update_recurring_ee --------------------------
   /*
      NAME
         update_recurring_ee
      NOTES
         This function performs the actual database work of updating
         a REE's input value as a result of an Update Formula Result Rule.
   */
   procedure update_recurring_ee
   (
      p_element_entry_id     in out nocopy number,
      p_error_code           in out nocopy number,
      p_assignment_action_id in     number,
      p_assignment_id        in     number,
      p_effective_date       in     date,
      p_element_type_id      in     number,
      p_input_value_id       in     number,
      p_updated_value        in     varchar2
   ) is
      -- Setup entry values cursor.
      cursor get_entry_values (p_update_ee_id in number,
                               p_date         in date) is
            select input_value_id, screen_entry_value
            from pay_element_entry_values_f eev
            where  eev.element_entry_id     = p_update_ee_id
            and    p_date between eev.effective_start_date
                                and eev.effective_end_date;
--
      -- Need a row variable for get_entry_values as we are now doing
      -- explicit fetches.
      r_entry_value get_entry_values%ROWTYPE;
--
      cursor upd_entry_values (p_update_ee_id in number,
                               p_date         in date) is
         select eev.element_entry_value_id,
                eev.input_value_id,
                eev.element_entry_id,
                eev.screen_entry_value
         from   pay_element_entry_values_f eev
         where  eev.element_entry_id = p_update_ee_id
         and    (p_date - 1) between
                eev.effective_start_date and eev.effective_end_date;
--
      cursor entry_record_exists(p_update_ee_id in number,
                                 p_effective_end_date in date) is
        select effective_end_date
          from pay_element_entries_f
         where element_entry_id = p_update_ee_id
           and effective_start_date = p_effective_date
           and effective_end_date = p_effective_end_date;
--
      cursor entry_value_exists(p_update_ee_id in number,
                                p_input_value_id in number,
                                p_effective_end_date in date) is
        select effective_end_date,screen_entry_value
          from pay_element_entry_values_f
         where element_entry_id = p_update_ee_id
           and input_value_id = p_input_value_id
           and effective_start_date = p_effective_date
           and effective_end_date = p_effective_end_date;
--
      c_indent   constant varchar2(30) := 'pydynsql.update_recurring_ee';
      update_ee_id   number;
      upd_act_id     number; -- updating_action_id.
      ee_effstart    date;
   -- bug 6655722
   -- max_effend     date;
      val_date       date;
      asgno          per_all_assignments_f.assignment_number%type;
      link_id        number;
      lookup_type    hr_lookups.lookup_type%type;
      -- Bugfix 2827092
      --value_set_id   pay_input_values_f.value_set_id%type;
      uom            pay_input_values_f.uom%type;
      input_curr     pay_element_types_f.input_currency_code%type;
      screen_value   pay_element_entry_values_f.screen_entry_value%type;
      db_value       pay_element_entry_values_f.screen_entry_value%type;
      old_value      pay_element_entry_values_f.screen_entry_value%type;
      scr_upd_value  pay_element_entry_values_f.screen_entry_value%type;
      entry_val_list char60_table;
      l_all_entry_values_null varchar2(30);
      l_effective_end_date date;   -- bug 6655722
      l_screen_entry_value pay_element_entrY_values_f.screen_entry_value%type;
      ovn number(9);
   begin
      -- Select details about the element entry we are to update.
      -- If p_element_entry_id is not null, the entry is restricted
      -- to the one specified (for multiple recurring entries).
      -- Otherwise, there should only be one normal entry for
      -- the combination of assignment and element type.
      -- Note that we implicitly assume that the assignment is on a
      -- payroll, in the joins to element link, hence no reference
      -- to link_to_all_payrolls_flag.
      begin
         hr_utility.set_location(c_indent,10);
         -- Bugfix 2827092 following lines temporarily removed from below
         -- piv.value_set_id,
         -- value_set_id,
         select pee.element_entry_id,
                pee.updating_action_id,
                pee.effective_start_date,
                asg.assignment_number,
                pel.element_link_id,
                piv.lookup_type,
                piv.uom,
                pet.input_currency_code
         into   update_ee_id,
                upd_act_id,
                ee_effstart,
                asgno,
                link_id,
                lookup_type,
                uom,
                input_curr
         from   pay_element_entries_f pee,
                pay_element_links_f   pel,
                pay_element_types_f   pet,
                pay_input_values_f    piv,
                per_all_assignments_f asg
         where  asg.assignment_id = p_assignment_id
         and    p_effective_date between
                asg.effective_start_date and asg.effective_end_date
         and    pel.element_type_id = p_element_type_id
         and   (pel.payroll_id      = asg.payroll_id
                or pel.payroll_id is null)
         and    p_effective_date between
                pel.effective_start_date and pel.effective_end_date
         and    pee.element_link_id = pel.element_link_id
         and    pee.assignment_id   = asg.assignment_id
         and    pee.entry_type      = 'E'
         and    p_effective_date between
                pee.effective_start_date and pee.effective_end_date
         and   (pee.element_entry_id = p_element_entry_id
             or p_element_entry_id is null)
         and    pet.element_type_id = pel.element_type_id
         and    p_effective_date between
                pet.effective_start_date and pet.effective_end_date
         and    piv.input_value_id  = p_input_value_id
         and    p_effective_date between
                piv.effective_start_date and piv.effective_end_date;
      exception
         when no_data_found then
         -- Have failed to find an entry to update.
         -- This most likely means that the entry does not exist
         -- at the date of the run. In (most unusual) circumstances,
         -- it may mean we have serious data corruption.
         -- Return an error code to allow output of message
	 -- BUG 7272321 : Commented out raising of error(7328)
	 -- Description: This element entry is present at the Date-Earned(because it was picked up for processing)
	 -- but is not present at the date of run(may be it was end-dated between these dates).
	 -- In this case no need of UPDATE for this element entry. we can skip UPDATE operation.
         --p_error_code := 7328;
         return;
      end;
--
      -- Perform certain required validation checks and convert
      -- the external format to the internal one.
      -- Convert value from internal to extrenal format in preperation
      -- for hr_entry_api.
      hr_entry_api.set_formula_contexts (p_assignment_id, p_effective_date);
      screen_value := hr_chkfmt.changeformat(p_updated_value, uom, input_curr);
      -- Have temporarily removed the following lines from the call
      -- to hr_entry_api.validate_entry_value to avoid a huge patching issue
      -- with 11.5 c-code chain (where would have to pull in all other dependant
      -- code on value set validation).
      -- this line can be introduced in Next base release
      -- Bugfix 2827092
      --p_value_set_id        => value_set_id,
      hr_entry_api.validate_entry_value
            (p_element_link_id     => link_id,
             p_input_value_id      => p_input_value_id,
             p_session_date        => p_effective_date,
             p_screen_format       => screen_value,
             p_db_format           => db_value,
             p_lookup_type         => lookup_type,
             p_uom                 => uom,
             p_input_currency_code => input_curr);
--
      -- We must explicitly check for a correction.
      -- This is only allowed if the current assignment action
      -- is the same as the previous updating action. Otherwise,
      -- We raise an error.
      if(ee_effstart = p_effective_date) then
         -- We are attempting a correction. Check if it is legal.
         if(upd_act_id = p_assignment_action_id) then
            -- It is legal. Set the validation date to be
            -- previous day. This ensures the date effective
            -- stuff below will work correctly.
            val_date := (p_effective_date - 1);
         else
            hr_utility.set_location(c_indent,18);
            -- Check if update really required
            -- ie changing entry value
            select eev.screen_entry_value
            into old_value
            from pay_element_entry_values eev
            where eev.element_entry_id = update_ee_id
            and   eev.input_value_id   = p_input_value_id
            and   p_effective_date between
                  eev.effective_start_date and eev.effective_end_date;
            --
            if (nvl(old_value,'X') <> nvl(db_value,'X')) then
               -- Return error code to allow output of message
               p_error_code := 7053;
               return;
            else
               return;
            end if;
         end if;
      else
         -- Not correction - validation date is effective date.
         val_date := p_effective_date;
      end if;
--
      hr_utility.set_location(c_indent,20);

      /* bug 6655722
      select max(pee.effective_end_date)
      into   max_effend
      from   pay_element_entries_f pee
      where  pee.element_entry_id = update_ee_id;
      */
--
      begin
         -- Set the Continuous Calc override flag, so that the trigger points
         -- are not fired.
         pay_continuous_calc.g_override_cc := TRUE;
--

         hr_utility.set_location(c_indent,30);

	 --bug 6655722
	 -- Ok, we have the information - now we need to perform
         -- the date track update (UPDATE_CHANGE_INSERT).
         -- Obtain the effective_end_date of the record we are going
	 -- to update. The new record being created should have the same
	 -- end date.

	 SELECT effective_end_date
	 INTO l_effective_end_date
	 FROM pay_element_entries_f
	 WHERE element_entry_id = update_ee_id
	 AND p_effective_date BETWEEN effective_start_date AND effective_end_date;
	 --
	 /*
         delete from pay_element_entries_f pee
         where  pee.element_entry_id     = update_ee_id
         and    pee.effective_start_date > val_date;
	 */
--
         --
         -- Enhancement 3478848
         -- We need to derive the l_all_entry_values_null flag. First we
         -- initialise l_all_entry_values_null to 'Y', then when any non-null
         -- entry values are encountered, this value is reset to null, thereby
         -- ensuring that the value 'Y' persists only when ALL entry values
         -- are null.
         --
         l_all_entry_values_null := 'Y';
         --
         -- Now we populate the PL/SQL entry values table with the values of
         -- the entries as of the effective date BUT use the derived db_value
         -- for the entry value for p_input_value_id.
         --
         open get_entry_values(update_ee_id, p_effective_date);
         --
         loop
           --
           fetch get_entry_values into r_entry_value;
           --
           if get_entry_values%NOTFOUND and get_entry_values%ROWCOUNT = 0 then
             --
             -- No entry values found, therefore we need to set the
             -- l_all_entry_values_null flag to null.
             --
             l_all_entry_values_null := null;
             --
           end if;
           --
           exit when get_entry_values%NOTFOUND;
           --
           if r_entry_value.input_value_id = p_input_value_id then
             entry_val_list(r_entry_value.input_value_id) := db_value;
           else
             entry_val_list(r_entry_value.input_value_id) :=
               r_entry_value.screen_entry_value;
           end if;
           --
           hr_utility.trace('IV='||r_entry_value.input_value_id);
           hr_utility.trace('VAL='||r_entry_value.screen_entry_value);
           hr_utility.trace('TAB='||entry_val_list(r_entry_value.input_value_id));
           hr_utility.trace('DATE='||val_date);
           --
           if entry_val_list(r_entry_value.input_value_id) is not null then
             --
             -- A non-null entry value has been encountered, therefore set the
             -- l_all_entry_values_null flag to null.
             --
             l_all_entry_values_null := null;
             --
           end if;
           --
         end loop;
         --
         close get_entry_values;

  -- Bug 7194700
  -- Check if a record exists in PAY_ELEMENT_ENTRIES_F with the same effective_start_date
  -- and effective_end_date. Proceed with the Update and Insert DMLs only if no such
  -- record is there.

     OPEN entry_record_exists(update_ee_id,l_effective_end_date);
     FETCH entry_record_exists INTO l_effective_end_date;

     IF entry_record_exists%NOTFOUND THEN
     --
	 -- Now, update the effective_end_date of existing entry.
         -- Note : using val_date.
         hr_utility.set_location(c_indent,40);
         update pay_element_entries_f pee
         set    pee.effective_end_date = (p_effective_date - 1)
         where  pee.element_entry_id   = update_ee_id
         and    val_date between
                pee.effective_start_date and pee.effective_end_date;
--
         -- Finally (for entry), we wish to insert the new
         -- entry record.
         hr_utility.set_location(c_indent,50);
         --
         -- Bugfix 3110853
         -- Derive the OVN before inserting
         --
         ovn := dt_api.get_object_version_number (
                      'PAY_ELEMENT_ENTRIES_F',
                      'ELEMENT_ENTRY_ID',
                      update_ee_id
                    );
         --
         insert into pay_element_entries_f (
                element_entry_id,
                effective_start_date,
                effective_end_date,
                cost_allocation_keyflex_id,
                assignment_id,
                updating_action_id,
                updating_action_type,
                element_link_id,
                element_type_id,
                original_entry_id,
                creator_type,
                entry_type,
                comment_id,
                creator_id,
                reason,
                target_entry_id,
                subpriority,
                personal_payment_method_id,
                all_entry_values_null,
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
                entry_information_category,
                entry_information1,
                entry_information2,
                entry_information3,
                entry_information4,
                entry_information5,
                entry_information6,
                entry_information7,
                entry_information8,
                entry_information9,
                entry_information10,
                entry_information11,
                entry_information12,
                entry_information13,
                entry_information14,
                entry_information15,
                entry_information16,
                entry_information17,
                entry_information18,
                entry_information19,
                entry_information20,
                entry_information21,
                entry_information22,
                entry_information23,
                entry_information24,
                entry_information25,
                entry_information26,
                entry_information27,
                entry_information28,
                entry_information29,
                entry_information30,
                object_version_number,
                last_update_date,
                last_updated_by,
                last_update_login,
                created_by,
                creation_date)
         select pee.element_entry_id,
                p_effective_date,
                l_effective_end_date,
                pee.cost_allocation_keyflex_id,
                pee.assignment_id,
                p_assignment_action_id,
                'U',
                pee.element_link_id,
                pee.element_type_id,
                pee.original_entry_id,
                pee.creator_type,
                pee.entry_type,
                pee.comment_id,
                pee.creator_id,
                pee.reason,
                pee.target_entry_id,
                pee.subpriority,
                pee.personal_payment_method_id,
                l_all_entry_values_null,
                pee.attribute_category,
                pee.attribute1,
                pee.attribute2,
                pee.attribute3,
                pee.attribute4,
                pee.attribute5,
                pee.attribute6,
                pee.attribute7,
                pee.attribute8,
                pee.attribute9,
                pee.attribute10,
                pee.attribute11,
                pee.attribute12,
                pee.attribute13,
                pee.attribute14,
                pee.attribute15,
                pee.attribute16,
                pee.attribute17,
                pee.attribute18,
                pee.attribute19,
                pee.attribute20,
                entry_information_category,
                entry_information1,
                entry_information2,
                entry_information3,
                entry_information4,
                entry_information5,
                entry_information6,
                entry_information7,
                entry_information8,
                entry_information9,
                entry_information10,
                entry_information11,
                entry_information12,
                entry_information13,
                entry_information14,
                entry_information15,
                entry_information16,
                entry_information17,
                entry_information18,
                entry_information19,
                entry_information20,
                entry_information21,
                entry_information22,
                entry_information23,
                entry_information24,
                entry_information25,
                entry_information26,
                entry_information27,
                entry_information28,
                entry_information29,
                entry_information30,
                ovn,
                trunc(sysdate),
                0,
                0,
                pee.created_by,
                pee.creation_date
         from   pay_element_entries_f pee
         where  pee.element_entry_id = update_ee_id
         and    (p_effective_date - 1) between
                pee.effective_start_date and pee.effective_end_date;
     --
     END if;
     CLOSE entry_record_exists;
--
         -- Now populate the PL/SQL entry values table with the values
         -- of the entries as of the effective date.
         -- Enhancement 3478848
         -- Removed this, fetch now performed prior to inserting the element
         -- entry row, above.
         /*
         for entry_value in get_entry_values(update_ee_id, p_effective_date) loop
            entry_val_list(entry_value.input_value_id) :=
                                   entry_value.screen_entry_value;
            hr_utility.trace('IV='||entry_value.input_value_id);
            hr_utility.trace('VAL='||entry_value.screen_entry_value);
            hr_utility.trace('TAB='||entry_val_list(entry_value.input_value_id));
            hr_utility.trace('DATE='||val_date);
         end loop;
         */


  -- Bug 7194700
  -- Check if a record exists in PAY_ELEMENT_ENTRY_VALUES_F with the same effective_start_date
  -- and effective_end_date. Proceed with the Update and Insert DMLs only if no such
  -- record is there.
  --

     OPEN entry_value_exists(update_ee_id,p_input_value_id,l_effective_end_date);
     FETCH entry_value_exists INTO l_effective_end_date, l_screen_entry_value;

     IF entry_value_exists%NOTFOUND THEN
     --
         -- We now wish to perform the update on the entry values.
         -- This is a similar process to the entry stuff.

         hr_utility.set_location(c_indent,60);

	 /* bug 6655772
         delete from pay_element_entry_values_f eev
         where  eev.element_entry_id     = update_ee_id
         and    eev.effective_start_date > val_date;
	 */
--
         -- Fix the end date of the entry values.
         -- Note : using val_date.
         hr_utility.set_location(c_indent,70);
         update pay_element_entry_values_f eev
         set    eev.effective_end_date = (p_effective_date - 1)
         where  eev.element_entry_id   = update_ee_id
         and    val_date between
                eev.effective_start_date and eev.effective_end_date;
--
         -- Now we insert the new entry values row.
         -- We set the new entry value as required.
         -- Note : using val_date.
         hr_utility.set_location(c_indent,80);
         for update_values in upd_entry_values(update_ee_id, p_effective_date) loop
             -- Enhancement 3478848
             -- Removed this, this check is now performed when the entry
             -- values are initially fetched, above.
             /*
             if update_values.input_value_id = p_input_value_id then
                scr_upd_value := db_value;
             else
                scr_upd_value := entry_val_list(update_values.input_value_id);
             end if;
             */
--
             insert into pay_element_entry_values (
                     element_entry_value_id,
                     effective_start_date,
                     effective_end_date,
                     input_value_id,
                     element_entry_id,
                     screen_entry_value)
             values (update_values.element_entry_value_id,
                     p_effective_date,
                     l_effective_end_date,
                     update_values.input_value_id,
                     update_values.element_entry_id,
                     -- Enhancement 3478848
                     -- entry_val_list now contains the correct entry values
                     decode(trim(entry_val_list(update_values.input_value_id)), NULL, NULL, entry_val_list(update_values.input_value_id)));   -- bug 8482621
                     -- scr_upd_value);
         end loop;
     --
     ELSIF (l_screen_entry_value is null
           or l_screen_entry_value <> entry_val_list(p_input_value_id)) THEN      -- bug 7314920
     --
       update pay_element_entry_values_f eev
         set    screen_entry_value = decode(trim(entry_val_list(p_input_value_id)), NULL, NULL, entry_val_list(p_input_value_id))    -- bug 7340357
         where  eev.element_entry_id   = update_ee_id
         and input_value_id = p_input_value_id
         and    p_effective_date between eev.effective_start_date and eev.effective_end_date;
     --
     END if;
     --
     CLOSE entry_value_exists;

/*
         insert into pay_element_entry_values (
                element_entry_value_id,
                effective_start_date,
                effective_end_date,
                input_value_id,
                element_entry_id,
                screen_entry_value)
         select eev.element_entry_value_id,
                p_effective_date,
                max_effend,
                eev.input_value_id,
                eev.element_entry_id,
                decode(eev.input_value_id, p_input_value_id,
                       db_value,           eev.screen_entry_value)
         from   pay_element_entry_values_f eev
         where  eev.element_entry_id = update_ee_id
         and    (p_effective_date - 1) between
                eev.effective_start_date and eev.effective_end_date;
*/
         pay_continuous_calc.g_override_cc := FALSE;
--
      exception
         when others then
            pay_continuous_calc.g_override_cc := FALSE;
            raise;
      end;
--
      -- Return element_entry_id that we updated.
      hr_utility.set_location(c_indent,90);
      p_element_entry_id := update_ee_id;
   end update_recurring_ee;
--
   ----------------------------- stop_recurring_ee --------------------------
   /*
      NAME
         stop_recurring_ee
      NOTES
         This function performs the actual database work of date effectively
         deleting a REE as a result of a Stop Formula Result Rule.
   */
   procedure stop_recurring_ee
   (
      p_element_entry_id in     number,
      p_error_code       in out nocopy number,
      p_assignment_id    in     number,
      p_effective_date   in     date,
      p_element_type_id  in     number,
      p_assignment_action_id in number,
      p_date_earned      in     date
   ) is
      c_indent   constant varchar2(30) := 'pydynsql.stop_recurring_ee';
      stop_ee_id         number;
      link_id            number;
      stop_ee_start_date date;
      v_error_flag       varchar2(1);
   begin
      -- Select details about the element entry we are to stop.
      -- If p_element_entry_id is not null, the entry is restricted
      -- to the one specified (for multiple recurring entries).
      -- Otherwise, there should only be one normal entry for
      -- the combination of assignment and element type.
      -- Note that we implicitly assume that the assignment is on a
      -- payroll, in the joins to element link, hence no reference
      -- to link_to_all_payrolls_flag.
      begin
         hr_utility.set_location(c_indent,10);
         select pee.element_entry_id,
                pel.element_link_id,
                pee.effective_start_date
         into   stop_ee_id, link_id, stop_ee_start_date
         from   pay_element_entries_f pee,
                pay_element_links_f   pel,
                per_all_assignments_f asg
         where  asg.assignment_id = p_assignment_id
         and    p_date_earned between
                asg.effective_start_date and asg.effective_end_date
         and    pel.element_type_id = p_element_type_id
         and   (pel.payroll_id      = asg.payroll_id
                or pel.payroll_id is null)
         and    p_date_earned between
                pel.effective_start_date and pel.effective_end_date
         and    pee.element_link_id = pel.element_link_id
         and    pee.assignment_id   = asg.assignment_id
         and    pee.entry_type      = 'E'
         and   (pee.element_entry_id = p_element_entry_id
             or p_element_entry_id is null)
         and    p_date_earned between
                pee.effective_start_date and pee.effective_end_date;
      exception
         when no_data_found then
         -- No entry could be found to stop.
         -- This most likely means that no entry existed at effective date.
         -- Likely cause is that entry has already been stopped.
         -- Return error code to allow output of error message.
         p_error_code := 7329;
         return;
      end;
--
      -- Check we are not attempting to orphan any adjustments.
      -- Note the joins to assignment_id and element_link_id are
      -- necessary to activate the index.
      -- Also note, must join with stop_ee_id, not p_element_entry_id.
      begin
         select 'Y'
         into   v_error_flag
         from   sys.dual
         where  exists (
                select null
                from   pay_element_entries_f pee
                where  pee.assignment_id   = p_assignment_id
                and    pee.element_link_id = link_id
                and    pee.target_entry_id = stop_ee_id
                and    pee.effective_start_date <= c_eot
                and    pee.effective_end_date   >= (p_date_earned + 1));
      exception
         when no_data_found then null;
      end;
--
     if v_error_flag = 'Y' then
       hr_utility.set_message(801, 'HR_6304_ELE_ENTRY_DT_DEL_ADJ');
       hr_utility.raise_error;
     end if;
--
--   Check the start date of the date effective element entry, if the date
--   is greater than the date_earned then error, since the entry is stopped
--   as of date earned.
--
     if stop_ee_start_date > p_date_earned then
       hr_utility.set_message(801, 'HR_51338_HRPROC_STOP_EE_DATE');
       hr_utility.raise_error;
     end if;
--
      -- Ok, perform date track delete (DELETE).
      -- This means we delete any future entries and values
      -- then set the effective_end_dates as appropriate.
      begin
        -- Set the Continuous Calc override flag, so that the trigger points
        -- are not fired.
        pay_continuous_calc.g_override_cc := TRUE;
--
        delete from pay_element_entries_f pee
        where  pee.element_entry_id     = stop_ee_id
        and    pee.effective_start_date > p_date_earned;
--
        update pay_element_entries_f pee
        set    pee.effective_end_date = p_date_earned,
               pee.prev_upd_action_id = DECODE(pee.updating_action_type, 'U', pee.updating_action_id),
               pee.updating_action_id = p_assignment_action_id,
               pee.updating_action_type = 'S'
        where  pee.element_entry_id   = stop_ee_id
        and    p_date_earned between
               pee.effective_start_date and pee.effective_end_date;
--
        delete from pay_element_entry_values_f eev
        where  eev.element_entry_id     = stop_ee_id
        and    eev.effective_start_date > p_date_earned;
--
        update pay_element_entry_values_f eev
        set    eev.effective_end_date = p_date_earned
        where  eev.element_entry_id   = stop_ee_id
        and    p_date_earned between
               eev.effective_start_date and eev.effective_end_date;
--
        pay_continuous_calc.g_override_cc := FALSE;
--
      exception
        when others then
          pay_continuous_calc.g_override_cc := FALSE;
          raise;
      end;
   end stop_recurring_ee;
--
   --------------------------------- setinfo ----------------------------------
   /*
      NAME
         setinfo - get information from an assignment set.
      DESCRIPTION
         Returns information about the assignment set supplied:
         if there are any specific includes or excludes; the
         formula_id of any criteria formula; whether or not a
         payroll_id is on the set.
--
         Also uses 'everyone' to indicate if we are starting
         from the full set or empty set.
      NOTES
         Called for both Rollback and QuickPaint cases.
   */
   procedure setinfo
   (
      asetid   in            number,  -- assignment_set_id.
      everyone in out nocopy boolean, -- everyone in set or not.
      include  in out nocopy boolean, -- any specific inclusions.
      exclude  in out nocopy boolean, -- any specific exclusions.
      formula  in out nocopy number,  -- has a formula been specified.
      payroll  in out nocopy boolean  -- has a payroll_id been specified.
   ) is
      payid  number; -- payroll_id.
      dummy  number; -- dummy cos selects need something to select into.
   begin
      -- start by selecting the information about payroll and formula.
      hr_utility.set_location('hr_dynsql.setinfo',5);
      select has.payroll_id,
             nvl(has.formula_id,0)
      into   payid,
             formula
      from   hr_assignment_sets has
      where  has.assignment_set_id = asetid;
--
      payroll := (payid is not null);
--
      -- Now check for specific inclusions being specified.
      hr_utility.set_location('hr_dynsql.setinfo',10);
      include := TRUE;
      begin
         select null
         into   dummy
         from   sys.dual
         where  exists (
                select null
                from   hr_assignment_set_amendments amd
                where  amd.assignment_set_id  = asetid
                and    amd.include_or_exclude = 'I');
      exception
         when no_data_found then include := FALSE;
      end;
--
      -- Now check for specific exclusions.
      exclude := TRUE;
      hr_utility.set_location('hr_dynsql.setinfo',15);
      begin
         select null
         into   dummy
         from   sys.dual
         where  exists (
                select null
                from   hr_assignment_set_amendments amd
                where  amd.assignment_set_id  = asetid
                and    amd.include_or_exclude = 'E');
      exception
         when no_data_found then exclude := FALSE;
      end;
--
      -- Having got the flags that tell us about the
      -- specific inclusions and so on, set the
      -- 'everyone' flag, based on standard
      -- assignment set rules.
      everyone := TRUE; -- start by assuming that we need everyone.
--
      -- Only case where we start with empty set is
      -- when we have specific inclusions only.
      if(formula = 0 and include) then
         everyone := FALSE;
      end if;
--
      -- In the case where we have a formula specified
      -- we need to turn the include flag off, because
      -- the restriction is processed later.
      if(formula <> 0) then
         include := FALSE;
      end if;
   end setinfo;
--
   --------------------------- person_sequence_locked --------------------------
   /*
      NAME
         person_sequence_locked - Person Sequence Locked
      DESCRIPTION
         This function is used to determine if a person has sequence locks
         given a date.
      NOTES
         <none>
   */
   function person_sequence_locked (p_period_service_id in number,
                                    p_effective_date    in date)
   return varchar2
   is
--
     cursor dp (p_per_of_serv in number) is
     select distinct paf.assignment_id
       from per_all_assignments_f      paf
      where paf.period_of_service_id = p_per_of_serv;
--
     cursor csr_locker (p_asg_id in number,
                        p_eff_date in date)
     is
     select 1 res
       from sys.dual
      where exists (
                     select null
                     from   pay_action_classifications acl,
                            pay_assignment_actions     ac2,
                            pay_payroll_actions        pa2
                     where  ac2.assignment_id        = p_asg_id
                     and    pa2.payroll_action_id    = ac2.payroll_action_id
                     and    acl.classification_name  = 'SEQUENCED'
                     and    pa2.action_type          = acl.action_type
                     and    (pa2.effective_date > p_eff_date
                         or (ac2.action_status not in ('C', 'S')
                     and    pa2.effective_date <= p_eff_date)));
--
   l_locked varchar2(3);
--
   begin
--
     l_locked := 'N';
--
     for asgrec in dp(p_period_service_id) loop
       for resrec in csr_locker(asgrec.assignment_id,
                                p_effective_date) loop
         l_locked := 'Y';
       end loop;
     end loop;
--
     return l_locked;
--
   end person_sequence_locked;
--
   --------------------------- bal_person_sequence_locked --------------------------
   /*
      NAME
         bal_person_sequence_locked - Person Sequence Locked for balance adjustments
      DESCRIPTION
         This function is used to determine if a person has any
         unsuccesful actions (regardless of date).
      NOTES
         <none>
   */
   function bal_person_sequence_locked (p_period_service_id in number,
                                        p_effective_date    in date)
   return varchar2
   is
--
     cursor dp (p_per_of_serv in number) is
     select distinct paf.assignment_id
       from per_all_assignments_f      paf
      where paf.period_of_service_id = p_per_of_serv;
--
     cursor csr_locker (p_asg_id in number,
                        p_eff_date in date)
     is
     select 1 res
       from sys.dual
      where exists (
                     select null
                     from   pay_action_classifications acl,
                            pay_assignment_actions     ac2,
                            pay_payroll_actions        pa2
                     where  ac2.assignment_id        = p_asg_id
                     and    pa2.payroll_action_id    = ac2.payroll_action_id
                     and    acl.classification_name  = 'SEQUENCED'
                     and    pa2.action_type          = acl.action_type
                     and    ac2.action_status not in ('C', 'S'));
--
   l_locked varchar2(3);
--
   begin
--
     l_locked := 'N';
--
     for asgrec in dp(p_period_service_id) loop
       for resrec in csr_locker(asgrec.assignment_id,
                                p_effective_date) loop
         l_locked := 'Y';
       end loop;
     end loop;
--
     return l_locked;
--
   end bal_person_sequence_locked;
--
   --------------------------- ret_person_sequence_locked ----------------------
   /*
      NAME
         ret_person_sequence_locked - Retropay Person Sequence Locked
      DESCRIPTION
         This function is used to determine if a person has sequence locks
         given a date.
      NOTES
         <none>
   */
   function ret_person_sequence_locked (p_period_service_id in number,
                                    p_effective_date    in date)
   return varchar2
   is
--
     cursor dp (p_per_of_serv in number) is
     select distinct paf.assignment_id
       from per_all_assignments_f      paf
      where paf.period_of_service_id = p_per_of_serv;
--
     cursor csr_locker (p_asg_id in number,
                        p_eff_date in date)
     is
     select 1 res
       from sys.dual
      where exists (
                     select null
                     from   pay_action_classifications acl,
                            pay_assignment_actions     ac2,
                            pay_payroll_actions        pa2
                     where  ac2.assignment_id        = p_asg_id
                     and    pa2.payroll_action_id    = ac2.payroll_action_id
                     and    acl.classification_name  = 'SEQUENCED'
                     and    pa2.action_type          = acl.action_type
                     and    ((pa2.effective_date > p_eff_date
                              and ac2.action_status in ('C', 'S'))
                         or (ac2.action_status not in ('C', 'S')
                     and    pa2.effective_date <= p_eff_date)));
--
   l_locked varchar2(3);
--
   begin
--
     l_locked := 'N';
--
     for asgrec in dp(p_period_service_id) loop
       for resrec in csr_locker(asgrec.assignment_id,
                                p_effective_date) loop
         l_locked := 'Y';
       end loop;
     end loop;
--
     return l_locked;
--
   end ret_person_sequence_locked;
--
   function process_group_seq_locked (p_asg_id in number,
                                      p_effective_date    in date,
                                      p_future_actions    in varchar2 default 'N')
   return varchar2
   is
--
     /* Look for all the assignments on the same group */
     cursor dp (p_asg_id in number) is
     select distinct pog_grp.source_id
       from pay_object_groups pog_act,
            pay_object_groups pog_grp
      where pog_act.source_id = p_asg_id
        and pog_act.source_type = 'PAF'
        and pog_act.parent_object_group_id = pog_grp.parent_object_group_id -- the personlevel group
        and pog_grp.source_type = 'PAF';
--
     cursor csr_locker (p_asg_id in number,
                        p_eff_date in date)
     is
     select 1 res
       from sys.dual
      where exists (
                     select null
                     from   pay_action_classifications acl,
                            pay_assignment_actions     ac2,
                            pay_payroll_actions        pa2
                     where  ac2.assignment_id        = p_asg_id
                     and    pa2.payroll_action_id    = ac2.payroll_action_id
                     and    acl.classification_name  = 'SEQUENCED'
                     and    pa2.action_type          = acl.action_type
                     and    (pa2.effective_date > p_eff_date
                         or (ac2.action_status not in ('C', 'S')
                     and    pa2.effective_date <= p_eff_date)));
--
    cursor csr_ba_locker (p_asg_id in number,
                          p_eff_date in date)
     is
     select 1 res
       from sys.dual
      where exists (
                     select null
                     from   pay_action_classifications acl,
                            pay_assignment_actions     ac2,
                            pay_payroll_actions        pa2
                     where  ac2.assignment_id        = p_asg_id
                     and    pa2.payroll_action_id    = ac2.payroll_action_id
                     and    acl.classification_name  = 'SEQUENCED'
                     and    pa2.action_type          = acl.action_type
                     and    ac2.action_status not in ('C', 'S'));
--
     cursor csr_locker_fut (p_asg_id in number,
                            p_eff_date in date)
     is
     select 1 res
       from sys.dual
      where exists (
                     select null
                     from   pay_action_classifications acl,
                            pay_assignment_actions     ac2,
                            pay_payroll_actions        pa2
                     where  ac2.assignment_id        = p_asg_id
                     and    pa2.payroll_action_id    = ac2.payroll_action_id
                     and    acl.classification_name  = 'SEQUENCED'
                     and    pa2.action_type          = acl.action_type
                     and    ((pa2.effective_date > p_eff_date
                              and ac2.action_status in ('C', 'S'))
                         or (ac2.action_status not in ('C', 'S')
                             and pa2.effective_date <= p_eff_date)));
--
   l_locked varchar2(3);
--
   begin
--
     l_locked := 'N';
--
     for asgrec in dp(p_asg_id) loop
       if (p_future_actions = 'N') then
         for resrec in csr_locker(asgrec.source_id,
                                  p_effective_date) loop
           l_locked := 'Y';
         end loop;
       elsif (p_future_actions = 'B') then
         for resrec in csr_ba_locker(asgrec.source_id,
                                  p_effective_date) loop
           l_locked := 'Y';
         end loop;
       else
         for resfutrec in csr_locker_fut(asgrec.source_id,
                                  p_effective_date) loop
           l_locked := 'Y';
         end loop;
       end if;
     end loop;
--
     return l_locked;
--
   end process_group_seq_locked;
--
   ---------------------------------- rbsql -----------------------------------
   /*
      NAME
         rbsql - RollBack SQL.
      DESCRIPTION
         Has two functions. Firstly, dynamically builds an sql statement
         for rollback by assignment set. Secondly, it passes back info
         about the assignment set that has been specified.
      NOTES
         <none>
   */
   procedure rbsql
   (
      asetid  in            number,   -- assignment_set_id.
      spcinc     out nocopy number,   -- are there specific inclusions?
      spcexc     out nocopy number,   -- are there specific exclusions?
      formula in out nocopy number,   -- what is the formula_id?
      sqlstr  in out nocopy varchar2, -- returned dynamic sql string.
      len        out nocopy number,   -- length of sql string.
      chkno   in            number default null
   ) is
      include  boolean;
      exclude  boolean;
      payroll  boolean;
      everyone boolean;
   begin
      --
      -- We start by obtaining information about the assignment set.
      setinfo(asetid,everyone,include,exclude,formula,payroll);
--
      -- For specific include and exclude parameters, we have
      -- to convert from boolean to numeric so we can pass
      -- the values back to the calling 'C' program.
      if(include) then
         spcinc := 1;
      else
         spcinc := 0;
      end if;
--
      if(exclude) then
         spcexc := 1;
      else
         spcexc := 0;
      end if;
--
      -- now build the sql, based on the information.
      /* Modified both the queries(include,everyone) for performance issue Bug: 6689854 */
     if(everyone) then
         sqlstr := '
         select '|| case chkno when null then '' else '/*+ use_nl(pac pop has pay_asg act)
                                                           index(pac PAY_PAYROLL_ACTIONS_PK)
                                                           rowid(pop)
                                                           index(has HR_ASSIGNMENT_SETS_PK)
                                                           index(pay_asg PER_ASSIGNMENTS_F_N12)
                                                           index(act PAY_ASSIGNMENT_ACTIONS_N51) */ ' end ||' act.assignment_id,
                act.assignment_action_id
         from   hr_assignment_sets     has,
                pay_population_ranges  pop,
                per_all_assignments_f  pay_asg,
                pay_payroll_actions    pac,
                pay_assignment_actions act
         where  pac.payroll_action_id   = :pactid
         and    act.payroll_action_id   = pac.payroll_action_id
         and    act.source_action_id is null
         and    pay_asg.assignment_id       = act.assignment_id
         and    ((pac.action_type = ''BEE''
                 and pay_asg.effective_start_date = (select max(asg2.effective_start_date)
                                           from per_all_assignments_f asg2
                                           where asg2.assignment_id =
                                                    pay_asg.assignment_id))
                 or
                 (pac.action_type <> ''BEE''
                  and pac.effective_date between
                    pay_asg.effective_start_date and pay_asg.effective_end_date))
         and    pop.rowid               = :chunk_rowid
         and    has.assignment_set_id   = :asetid';
      end if;
--
      -- Specific inclusion.
      if(include) then
         sqlstr := '
         select '|| case chkno when null then '' else '/*+ use_nl(pac pop amd act pay_asg)
                                                           index(pac PAY_PAYROLL_ACTIONS_PK)
                                                           rowid(pop)
                                                           index(amd HR_ASSIGNMENT_SET_AMENDMEN_FK2)
                                                           index(act PAY_ASSIGNMENT_ACTIONS_N51)
                                                           index(pay_asg PER_ASSIGNMENTS_F_PK) */ ' end ||' act.assignment_id,
                act.assignment_action_id
         from   pay_payroll_actions          pac,
                pay_population_ranges        pop,
                hr_assignment_set_amendments amd,
                per_all_assignments_f        pay_asg,
                pay_assignment_actions       act
         where  pac.payroll_action_id   = :pactid
         and    act.payroll_action_id   = pac.payroll_action_id
         and    act.source_action_id is null
         and    pay_asg.assignment_id       = act.assignment_id
         and    ((pac.action_type = ''BEE''
                 and pay_asg.effective_start_date = (select max(asg2.effective_start_date)
                                           from per_all_assignments_f asg2
                                           where asg2.assignment_id =
                                                    pay_asg.assignment_id))
                 or
                 (pac.action_type <> ''BEE''
                  and pac.effective_date between
                    pay_asg.effective_start_date and pay_asg.effective_end_date))
         and    pop.rowid               = :chunk_rowid
         and    amd.assignment_set_id   = :asetid
         and    amd.include_or_exclude  = ''I''
         and    pay_asg.assignment_id       = amd.assignment_id';
      end if;
--
      if(exclude) then
         sqlstr := sqlstr || '
         and    not exists (
                select null
                from   hr_assignment_set_amendments exc
                where  exc.assignment_set_id  = has.assignment_set_id
                and    exc.include_or_exclude = ''E''
                and    act.assignment_id      = exc.assignment_id)';
      end if;
--
      if (chkno is null) then
         sqlstr := sqlstr || '
         and    pay_asg.person_id between
                pop.starting_person_id and pop.ending_person_id';
      else
         sqlstr := sqlstr || '
         and    pay_asg.person_id = pop.person_id';
      end if;
--
      -- Concatenate the order by statement.
      sqlstr := sqlstr || '
      order by act.action_sequence desc';
--
      -- return length to allow null termination.
      len := length(sqlstr);
   end rbsql;
--
   ---------------------------------- bkpsql ----------------------------------
   /*
      NAME
         bkpsql - build dynamic sql for BackPay.
      DESCRIPTION
         Builds dynamic sql statement for assignment set
         processing.
      NOTES
         <none>
   */
   procedure bkpsql
   (
      asetid in            number,   -- assignment_set_id.
      sqlstr in out nocopy varchar2, -- returned string.
      len       out nocopy number    -- length of returned string.
   ) is
      include   boolean;
      exclude   boolean;
      formula   number;
      payroll   boolean;
      everyone  boolean; -- if true, means all assignments.
   begin
      -- Get information about the assignment set.
      setinfo(asetid,everyone,include,exclude,formula,payroll);
--
      -- Use information to build sql statements.
      if(everyone) then
         sqlstr := '
         select pay_asg.assignment_id
         from   per_all_assignments_f  pay_asg,
                hr_assignment_sets has
         where  has.assignment_set_id = :v_asg_set
         and    pay_asg.payroll_id        = has.payroll_id
         and    fnd_date.canonical_to_date(:v_effective_date) between
                pay_asg.effective_start_date and pay_asg.effective_end_date';
      end if;
--
      if(include) then
         sqlstr := '
         select pay_asg.assignment_id
         from   per_all_assignments_f        pay_asg,
                hr_assignment_sets           has,
                hr_assignment_set_amendments amd
         where  has.assignment_set_id = :asetid
         and    amd.assignment_set_id = has.assignment_set_id
         and    pay_asg.payroll_id + 0    = has.payroll_id
         and    pay_asg.assignment_id     = amd.assignment_id
         and    amd.include_or_exclude = ''I''
         and    fnd_date.canonical_to_date(:v_effective_date) between
                pay_asg.effective_start_date and pay_asg.effective_end_date';
      end if;
--
      if(exclude) then
         sqlstr := '
         select pay_asg.assignment_id
         from   per_all_assignments_f  pay_asg,
                hr_assignment_sets has
         where  has.assignment_set_id = :asetid
         and    pay_asg.payroll_id    = has.payroll_id
         and    fnd_date.canonical_to_date(:v_effective_date) between
                pay_asg.effective_start_date and pay_asg.effective_end_date
         and    not exists (
                select null
                from   hr_assignment_set_amendments amd
                where  amd.assignment_set_id  = has.assignment_set_id
                and    pay_asg.assignment_id  = amd.assignment_id
                and    amd.include_or_exclude = ''E'')';
      end if;
--
      -- return length to allow null termination.
      len := length(sqlstr);
--
   end bkpsql;
--
  ---------------------------------- cbsql -----------------------------------
   /*
      NAME
         cbsql - Create Batches  SQL.
      DESCRIPTION
         Has two functions. Firstly, dynamically builds an sql statement
         for creating batch  by assignment set. Secondly, it passes back info
         about the assignment set that has been specified.
      NOTES
         <none>
   */
   procedure cbsql
   (
      asetid  in            number default 0,    -- assignment_set_id.
      elsetid in            number default null, -- element set id.
      spcinc     out nocopy number,   -- are there specific inclusions?
      spcexc     out nocopy number,   -- are there specific exclusions?
      formula in out nocopy number,   -- what is the formula_id?
      sqlstr  in out nocopy varchar2, -- returned dynamic sql string.
      len        out nocopy number    -- length of sql string.
   ) is
      include  boolean;
      exclude  boolean;
      payroll  boolean;
      everyone boolean;
   begin
      --
      -- We start by obtaining information about the assignment set.
    if(asetid <> 0) then
       setinfo(asetid,everyone,include,exclude,formula,payroll);
--
       -- For specific include and exclude parameters, we have
       -- to convert from boolean to numeric so we can pass
       -- the values back to the calling 'C' program.
       if(include) then
          spcinc := 1;
       else
          spcinc := 0;
       end if;
--
       if(exclude) then
          spcexc := 1;
       else
          spcexc := 0;
       end if;
--
       -- now build the sql, based on the information.
       if(everyone) then
          if (elsetid is not null) then
          --
          sqlstr := '
          select pay_asg.assignment_id, pay_asg.assignment_number,
          pay_asg.payroll_id, pesm.element_type_id, petf.element_name
          from per_all_assignments_f pay_asg,
               hr_assignment_sets has,
               PAY_ELEMENT_SET_MEMBERS pesm,
               pay_element_types_f petf
          where pay_asg.business_group_id = :p_bgid
                and has.assignment_set_id = :pasetid
                and pay_asg.assignment_type = ''E''
                and fnd_date.canonical_to_date(:p_effective_date)
                between pay_asg.effective_start_date
                and pay_asg.effective_end_date
                and pesm.element_set_id = :p_elesetid
                and petf.element_type_id = pesm.element_type_id
                and fnd_date.canonical_to_date(:p_effective_date) between
                    petf.effective_start_date and petf.effective_end_date
                and ((petf.business_group_id is null and petf.legislation_code is null) or
                     (petf.business_group_id is null and petf.legislation_code = :p_legcode) or
                     (petf.business_group_id = :p_bgid))
                and (exists
                     (select null
                      from pay_restriction_values psv
                      where psv.restriction_code = ''ELEMENT_TYPE''
                      and psv.customized_restriction_id = :p_restrictid
                      and (psv.value = ''BOTH'' or psv.value = petf.processing_type))
                 or not exists
                     (select null
                      from pay_restriction_values psv
                      where psv.restriction_code = ''ELEMENT_TYPE''
                      and psv.customized_restriction_id = :p_restrictid))';
          --
          else
          --
          sqlstr := '
          select pay_asg.assignment_id, pay_asg.assignment_number,
          pay_asg.payroll_id,petf.element_type_id, petf.element_name
          from per_all_assignments_f pay_asg,
               hr_assignment_sets has,
               pay_element_types_f petf
          where pay_asg.business_group_id = :p_bgid
                and has.assignment_set_id = :pasetid
                and pay_asg.assignment_type = ''E''
                and fnd_date.canonical_to_date(:p_effective_date)
                between petf.effective_start_date
                and petf.effective_end_date
                and petf.element_type_id = :p_element_id
                and fnd_date.canonical_to_date(:p_effective_date)
                between pay_asg.effective_start_date
                and pay_asg.effective_end_date';
          --
          end if;
       end if;
       if(include) then
          if (elsetid is not null) then
          --
          sqlstr := '
          select pay_asg.assignment_id, pay_asg.assignment_number,
          pay_asg.payroll_id, pesm.element_type_id, petf.element_name
          from   per_all_assignments_f        pay_asg,
                 hr_assignment_sets           has,
                 hr_assignment_set_amendments amd,
                 PAY_ELEMENT_SET_MEMBERS pesm,
                 pay_element_types_f petf
          where  pay_asg.business_group_id = :p_bgid
          and    has.assignment_set_id = :pasetid
          and    amd.assignment_set_id = has.assignment_set_id
          and    pay_asg.assignment_id     = amd.assignment_id
          and    pay_asg.assignment_type = ''E''
          and    amd.include_or_exclude = ''I''
          and    fnd_date.canonical_to_date(:p_effective_date) between
                 pay_asg.effective_start_date and pay_asg.effective_end_date
          and    pesm.element_set_id = :p_elesetid
          and    petf.element_type_id = pesm.element_type_id
          and    fnd_date.canonical_to_date(:p_effective_date) between
                 petf.effective_start_date and petf.effective_end_date
          and    ((petf.business_group_id is null and petf.legislation_code is null) or
                  (petf.business_group_id is null and petf.legislation_code = :p_legcode) or
                  (petf.business_group_id = :p_bgid))
          and    (exists
                  (select null
                   from pay_restriction_values psv
                   where psv.restriction_code = ''ELEMENT_TYPE''
                   and psv.customized_restriction_id = :p_restrictid
                   and (psv.value = ''BOTH'' or psv.value = petf.processing_type))
              or not exists
                  (select null
                   from pay_restriction_values psv
                   where psv.restriction_code = ''ELEMENT_TYPE''
                   and psv.customized_restriction_id = :p_restrictid))';
          --
          else
          --
          sqlstr := '
          select pay_asg.assignment_id, pay_asg.assignment_number,
          pay_asg.payroll_id,petf.element_type_id, petf.element_name
          from   per_all_assignments_f        pay_asg,
                 hr_assignment_sets           has,
                 hr_assignment_set_amendments amd,
                 pay_element_types_f          petf
          where  pay_asg.business_group_id = :p_bgid
          and    has.assignment_set_id = :pasetid
          and    amd.assignment_set_id = has.assignment_set_id
          and    pay_asg.assignment_id     = amd.assignment_id
          and    pay_asg.assignment_type = ''E''
          and    amd.include_or_exclude = ''I''
          and    fnd_date.canonical_to_date(:p_effective_date)
                 between petf.effective_start_date
          and    petf.effective_end_date
          and    petf.element_type_id = :p_element_id
          and    fnd_date.canonical_to_date(:p_effective_date) between
                 pay_asg.effective_start_date and pay_asg.effective_end_date';
          --
          end if;
       end if;
       if(exclude) then
          if (elsetid is not null) then
          --
          sqlstr := '
          select pay_asg.assignment_id, pay_asg.assignment_number,
          pay_asg.payroll_id, pesm.element_type_id, petf.element_name
          from   per_all_assignments_f  pay_asg,
                 hr_assignment_sets has,
                 PAY_ELEMENT_SET_MEMBERS pesm,
                 pay_element_types_f petf
          where  pay_asg.business_group_id = :p_bgid
          and    has.assignment_set_id = :pasetid
          and    pay_asg.assignment_type = ''E''
          and    fnd_date.canonical_to_date(:p_effective_date) between
                 pay_asg.effective_start_date and pay_asg.effective_end_date
          and    not exists (
                 select null
                 from   hr_assignment_set_amendments amd
                 where  amd.assignment_set_id  = has.assignment_set_id
                 and    pay_asg.assignment_id      = amd.assignment_id
                 and    amd.include_or_exclude = ''E'')
          and    pesm.element_set_id = :p_elesetid
          and    petf.element_type_id = pesm.element_type_id
          and    fnd_date.canonical_to_date(:p_effective_date) between
                 petf.effective_start_date and petf.effective_end_date
          and    ((petf.business_group_id is null and petf.legislation_code is null) or
                  (petf.business_group_id is null and petf.legislation_code = :p_legcode) or
                  (petf.business_group_id = :p_bgid))
          and    (exists
                  (select null
                   from pay_restriction_values psv
                   where psv.restriction_code = ''ELEMENT_TYPE''
                   and psv.customized_restriction_id = :p_restrictid
                   and (psv.value = ''BOTH'' or psv.value = petf.processing_type))
              or not exists
                  (select null
                   from pay_restriction_values psv
                   where psv.restriction_code = ''ELEMENT_TYPE''
                   and psv.customized_restriction_id = :p_restrictid))';
          --
          else
          --
          sqlstr := '
          select pay_asg.assignment_id, pay_asg.assignment_number,
          pay_asg.payroll_id,petf.element_type_id, petf.element_name
          from   per_all_assignments_f pay_asg,
                 hr_assignment_sets has,
                 pay_element_types_f petf
          where  pay_asg.business_group_id = :p_bgid
          and    has.assignment_set_id = :pasetid
          and    pay_asg.assignment_type = ''E''
          and    fnd_date.canonical_to_date(:p_effective_date)
                 between petf.effective_start_date
          and    petf.effective_end_date
          and    petf.element_type_id = :p_element_id
          and    fnd_date.canonical_to_date(:p_effective_date) between
                 pay_asg.effective_start_date and pay_asg.effective_end_date
          and    not exists (
                 select null
                 from   hr_assignment_set_amendments amd
                 where  amd.assignment_set_id  = has.assignment_set_id
                 and    pay_asg.assignment_id      = amd.assignment_id
                 and    amd.include_or_exclude = ''E'')';
          --
          end if;
       end if;
--
      -- Add payroll restricted clause
       if(payroll) then
          sqlstr := sqlstr || '
          and pay_asg.payroll_id + 0 = has.payroll_id';
       end if;
    else
       -- if asetid is not specified, then
       -- select everyone on the business group.

          if (elsetid is not null) then
          --
          sqlstr := '
          select pay_asg.assignment_id, pay_asg.assignment_number,
          pay_asg.payroll_id, pesm.element_type_id, petf.element_name
          from per_all_assignments_f pay_asg,
               PAY_ELEMENT_SET_MEMBERS pesm,
               pay_element_types_f petf
          where pay_asg.business_group_id = :p_bgid
          and pay_asg.assignment_type = ''E''
          and fnd_date.canonical_to_date(:p_effective_date) between
              pay_asg.effective_start_date and pay_asg.effective_end_date
          and pesm.element_set_id = :p_elesetid
          and petf.element_type_id = pesm.element_type_id
          and fnd_date.canonical_to_date(:p_effective_date) between
              petf.effective_start_date and petf.effective_end_date
          and ((petf.business_group_id is null and petf.legislation_code is null) or
               (petf.business_group_id is null and petf.legislation_code = :p_legcode) or
               (petf.business_group_id = :p_bgid))
          and (exists
               (select null
                from pay_restriction_values psv
                where psv.restriction_code = ''ELEMENT_TYPE''
                and psv.customized_restriction_id = :p_restrictid
                and (psv.value = ''BOTH'' or psv.value = petf.processing_type))
           or not exists
               (select null
                from pay_restriction_values psv
                where psv.restriction_code = ''ELEMENT_TYPE''
                and psv.customized_restriction_id = :p_restrictid))';
          --
          else
          --
          sqlstr := '
          select pay_asg.assignment_id, pay_asg.assignment_number,
          pay_asg.payroll_id,petf.element_type_id, petf.element_name
          from per_all_assignments_f pay_asg,
               pay_element_types_f petf
          where pay_asg.business_group_id = :p_bgid
          and pay_asg.assignment_type = ''E''
          and fnd_date.canonical_to_date(:p_effective_date)
              between petf.effective_start_date
          and petf.effective_end_date
          and petf.element_type_id = :p_element_id
          and fnd_date.canonical_to_date(:p_effective_date) between
          pay_asg.effective_start_date and pay_asg.effective_end_date';
          --
          end if;

          formula := 0;
          spcinc :=  0;
          spcexc :=  0;
    end if;
         -- return length to allow null termination.
        len := length(sqlstr);
--
 end cbsql;

   ---------------------------------- qptsql ----------------------------------
   /*
      NAME
         qptsql - build dynamic sql for QuickPaint.
      DESCRIPTION
         Builds dynamic sql strings for QuickPaint.
         It decides which sql is required from
         the assignment_set_id passed in.
      NOTES
         <none>
   */
   procedure qptsql
   (
      asetid in     number,   -- assignment_set_id.
      sqlstr in out nocopy varchar2, -- returned string.
      len       out nocopy number    -- length of returned string.
   ) is
      include   boolean;
      exclude   boolean;
      formula   number;
      payroll   boolean;
      everyone  boolean; -- if true, means all assignments.
   begin
      -- get information about assignment set.
      setinfo(asetid,everyone,include,exclude,formula,payroll);
--
      -- now build the sql, based on the information.
      if(everyone and (not include)) then
         sqlstr := '
         select pay_asg.assignment_id,
                pay_asg.payroll_id
         from   per_all_assignments_f      pay_asg,
                hr_assignment_sets         has,
                per_quickpaint_invocations inv
         where  inv.qp_invocation_id  = :qp_invocation_id
         and    has.assignment_set_id = inv.invocation_context
         and    pay_asg.business_group_id = has.business_group_id
         and    inv.effective_date between
                pay_asg.effective_start_date and pay_asg.effective_end_date';
      end if;
--
      -- Specific inclusion.
      if(include) then
         sqlstr := '
         select pay_asg.assignment_id,
                pay_asg.payroll_id
         from   per_all_assignments_f        pay_asg,
                hr_assignment_sets           has,
                hr_assignment_set_amendments amd,
                per_quickpaint_invocations   inv
         where  inv.qp_invocation_id   = :qp_invocation_id
         and    has.assignment_set_id  = inv.invocation_context
         and    amd.assignment_set_id  = has.assignment_set_id
         and    amd.include_or_exclude = ''I''
         and    pay_asg.assignment_id      = amd.assignment_id
         and    pay_asg.business_group_id + 0  = has.business_group_id + 0
         and    inv.effective_date between
                pay_asg.effective_start_date and pay_asg.effective_end_date';
      end if;
--
      if(payroll) then
         sqlstr := sqlstr || '
         and    pay_asg.payroll_id = has.payroll_id';
      end if;
--
      if(exclude) then
         sqlstr := sqlstr || '
         and    not exists (
                select null
                from   hr_assignment_set_amendments amd
                where  amd.assignment_set_id  = has.assignment_set_id
                and    amd.include_or_exclude = ''E''
                and    pay_asg.assignment_id      = amd.assignment_id)';
      end if;
--
      -- return length to allow null termination.
      len := length(sqlstr);
   end qptsql;
--
   ------------------------------ archive_range -------------------------------
   /*
      NAME
         archive_range - calls legislative range code.
      DESCRIPTION
         This checks the type of report that is running and then calls the
         appropreate code that defines the select statement for the
         population ranges.
      NOTES
   */
   procedure archive_range(pactid in            number,
                           sqlstr in out nocopy varchar2
                          )
   is
   sql_cur number;
   ignore number;
   range_proc varchar2(60);
   statem varchar2(256);
   begin
       pay_proc_environment_pkg.pactid := pactid;

       select range_code
         into range_proc
         from pay_report_format_mappings_f prfm,
              pay_payroll_actions          ppa
        where ppa.payroll_action_id = pactid
          and ppa.report_type = prfm.report_type
          and ppa.report_qualifier = prfm.report_qualifier
          and ppa.report_category = prfm.report_category
          and ppa.effective_date between prfm.effective_start_date
                                     and prfm.effective_end_date;
--
      /* Range code should always be set */
      if (range_proc is null) then
         hr_utility.set_message(801, 'PAY_34958_ARCRGE_MUST_EXIST');
         hr_utility.raise_error;
      end if;
--
      statem := 'BEGIN '||range_proc||'(:pactid, :sqlstr); END;';
--
      sql_cur := dbms_sql.open_cursor;
      dbms_sql.parse(sql_cur,
                     statem,
                     dbms_sql.v7);
      dbms_sql.bind_variable(sql_cur, ':pactid', pactid);
      dbms_sql.bind_variable(sql_cur, ':sqlstr', sqlstr, max_dynsql_len);
      ignore := dbms_sql.execute(sql_cur);
      dbms_sql.variable_value(sql_cur, ':sqlstr', sqlstr);
      dbms_sql.close_cursor(sql_cur);
--
      return;
--
   exception
      when others then
         if (dbms_sql.is_open(sql_cur)) then
           dbms_sql.close_cursor(sql_cur);
         end if;
         raise;
   end archive_range;
--
   ------------------------------ get_local_unit -------------------------------
   /*
      NAME
         get_local_unit  - this is used to retrieve the local unit id if valid.
      DESCRIPTION
         This is used to identify the local unit when processing run results.
      NOTES
   */
 function get_local_unit
 (
  p_assignment_id  number
 ,p_effective_date date
 ) return number is
   --
   -- Holds the tax unit an assignment belongs to.
   --
   l_local_unit_id     number;
   l_legislation       per_business_groups_perf.legislation_code%type;
   l_business_group_id per_business_groups_perf.business_group_id%type;
   plsql_state         varchar2(2000);  -- used with dynamic pl/sql
   sql_cursor          integer;
   l_rows              integer;
   l_found             boolean;
   l_dummy             number;
   --
 begin
--
   l_local_unit_id := NULL;
--
   if g_cached = FALSE then

      select /*+ INDEX(paf PER_ASSIGNMENTS_F_PK)*/
             pbg.legislation_code
      into l_legislation
      from per_all_assignments_f    paf,
           per_business_groups_perf pbg
      where paf.assignment_id = p_assignment_id
        and p_effective_date between paf.effective_start_date
                                 and paf.effective_end_date
        and paf.business_group_id = pbg.business_group_id;
--
      pay_core_utils.get_legislation_rule('LOCAL_UNIT_CONTEXT',
                           l_legislation,
                           g_local_unit,
                           l_found
                          );
--
      if (l_found = FALSE) then
         g_local_unit := 'N';
      end if;
--
      pay_core_utils.get_legislation_rule('TAX_UNIT',
                           l_legislation,
                           g_tax_unit,
                           l_found
                          );
--
      if (l_found = FALSE) then
         g_tax_unit := 'N';
      end if;

      g_cached := TRUE;
   end if;
--
   --
   -- Get the local unit the assignment belongs to.
   --
   if (g_local_unit = 'Y') then
--
      -- Dynamically get the tax unit.
--
      select /*+ INDEX(paf PER_ASSIGNMENTS_F_PK)*/
             pbg.legislation_code,
             pbg.business_group_id
        into l_legislation,
             l_business_group_id
        from per_all_assignments_f    paf,
             per_business_groups_perf pbg
        where paf.assignment_id = p_assignment_id
          and p_effective_date between paf.effective_start_date
                                   and paf.effective_end_date
          and paf.business_group_id = pbg.business_group_id;
--
      plsql_state := 'begin pay_'||l_legislation||'_rules.get_main_local_unit_id(
p_assignment_id =>:p_assignment_id,
p_effective_date => :p_effective_date,
p_local_unit_id    => :l_local_unit_id); end;';
--
      sql_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(sql_cursor, plsql_state, dbms_sql.v7);
      dbms_sql.bind_variable(sql_cursor, 'p_assignment_id', p_assignment_id);
      dbms_sql.bind_variable(sql_cursor, 'p_effective_date', p_effective_date);
      dbms_sql.bind_variable(sql_cursor, 'l_local_unit_id', l_local_unit_id);
      l_rows := dbms_sql.execute(sql_cursor);
      if (l_rows = 1) then
        dbms_sql.variable_value(sql_cursor, 'l_local_unit_id',
                                l_local_unit_id);
        dbms_sql.close_cursor(sql_cursor);
--
     else
        l_local_unit_id := null;
        dbms_sql.close_cursor(sql_cursor);
     end if;
   end if;

--
   /* Before we leave, just check that the Local Unit is valid */
   if (l_local_unit_id is not null) then
--
      -- If we are here then business group and legislation
      -- code should be known.
      select 1
        into l_dummy
        from dual
       where exists (
           select ''
             from hr_organization_units       hou,
                  hr_organization_information houi
            where hou.organization_id = houi.organization_id
              and hou.organization_id = l_local_unit_id
              and houi.org_information_context = 'CLASS'
              and houi.org_information1        =
                            upper(l_legislation||'_LOCAL_UNIT')
              and hou.business_group_id = l_business_group_id
           );
--
   end if;
--
   --
   -- Return the tax unit.
   --
   return (l_local_unit_id);
   --
 end get_local_unit;

   ------------------------------ get_tax_unit -------------------------------
   /*
      NAME
         get_tax_unit  - this is used to retrieve the tax unit id if valid.
      DESCRIPTION
         This is used by the assignment action creation code to find the
         value of the tax unit id.
      NOTES
   */
 function get_tax_unit
 (
  p_assignment_id  number
 ,p_effective_date date
 ) return number is
   --
   -- Retrieves the legal company an assignment belongs to at a given date.
   --
   cursor csr_tax_unit
     (
      p_assignment_id  number
     ,p_effective_date date
     ) is
     select to_number(SCL.segment1) tax_unit_id
     from   per_all_assignments_f  ASG
           ,hr_soft_coding_keyflex SCL
     where  ASG.assignment_id          = p_assignment_id
       and  SCL.soft_coding_keyflex_id = ASG.soft_coding_keyflex_id
       and  p_effective_date between ASG.effective_start_date
                                 and ASG.effective_end_date;
   --
   -- Retrieves the establishment id an assignment belongs to at a given date.
   --
   cursor csr_est_id
     (
      p_assignment_id  number
     ,p_effective_date date
     ) is
     select establishment_id
     from   per_all_assignments_f  ASG
     where  ASG.assignment_id          = p_assignment_id
       and  p_effective_date between ASG.effective_start_date
                                 and ASG.effective_end_date;
   --
   -- Holds the tax unit an assignment belongs to.
   --
   l_tax_unit_id number;
   l_legislation per_business_groups_perf.legislation_code%type;
   plsql_state         varchar2(2000);  -- used with dynamic pl/sql
   sql_cursor           integer;
   l_rows               integer;
   l_found             boolean;
   --
 begin
--
   l_tax_unit_id := NULL;
--
   if g_cached = FALSE then

      select /*+ INDEX(paf PER_ASSIGNMENTS_F_PK)*/
             pbg.legislation_code
      into l_legislation
      from per_all_assignments_f    paf,
           per_business_groups_perf pbg
      where paf.assignment_id = p_assignment_id
        and p_effective_date between paf.effective_start_date
                                 and paf.effective_end_date
        and paf.business_group_id = pbg.business_group_id;
--
--
      pay_core_utils.get_legislation_rule('LOCAL_UNIT_CONTEXT',
                           l_legislation,
                           g_local_unit,
                           l_found
                          );
--
      if (l_found = FALSE) then
         g_local_unit := 'N';
      end if;
--
      pay_core_utils.get_legislation_rule('TAX_UNIT',
                           l_legislation,
                           g_tax_unit,
                           l_found
                          );
--
      if (l_found = FALSE) then
         g_tax_unit := 'N';
      end if;

      g_cached := TRUE;
   end if;
--
   --
   -- Get the legal company the assignment belongs to.
   --
   if (g_tax_unit = 'Y') then
      open  csr_tax_unit(p_assignment_id
                        ,p_effective_date);
      fetch csr_tax_unit into l_tax_unit_id;
      close csr_tax_unit;
   elsif (g_tax_unit = 'E') then
      open  csr_est_id(p_assignment_id
                        ,p_effective_date);
      fetch csr_est_id into l_tax_unit_id;
      close csr_est_id;
   elsif (g_tax_unit = 'D') then
--
      -- Dynamically get the tax unit.
--
      select /*+ INDEX(paf PER_ASSIGNMENTS_F_PK)*/
             pbg.legislation_code
        into l_legislation
        from per_all_assignments_f    paf,
             per_business_groups_perf pbg
        where paf.assignment_id = p_assignment_id
          and p_effective_date between paf.effective_start_date
                                   and paf.effective_end_date
          and paf.business_group_id = pbg.business_group_id;
--
      plsql_state := 'begin pay_'||l_legislation||'_rules.get_main_tax_unit_id(
p_assignment_id =>:p_assignment_id,
p_effective_date => :p_effective_date,
p_tax_unit_id    => :l_tax_unit_id); end;';
--
      sql_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(sql_cursor, plsql_state, dbms_sql.v7);
      dbms_sql.bind_variable(sql_cursor, 'p_assignment_id', p_assignment_id);
      dbms_sql.bind_variable(sql_cursor, 'p_effective_date', p_effective_date);
      dbms_sql.bind_variable(sql_cursor, 'l_tax_unit_id', l_tax_unit_id);
      l_rows := dbms_sql.execute(sql_cursor);
      if (l_rows = 1) then
        dbms_sql.variable_value(sql_cursor, 'l_tax_unit_id',
                                l_tax_unit_id);
        dbms_sql.close_cursor(sql_cursor);
--
     else
        l_tax_unit_id := null;
        dbms_sql.close_cursor(sql_cursor);
     end if;

   end if;
--
   --
   -- Return the tax unit.
   --
   return (l_tax_unit_id);
   --
 end get_tax_unit;
--
   ---------------------------------- pyrsql ----------------------------------
   /*
      NAME
         pyrsql - build dynamic sql.
      DESCRIPTION
         builds an SQL statement from a 'kit of parts'.
         It concatenates various parts together depending on
         what is required, which is dependent on factors such
         as what sort of statement we require, whether we are
         dealing with time dependent/independent legislation
         and so on.
      NOTES
         It is useful to remember what the value of
         the 'interlock' flag means. If 'Y', it means
         the sql statement does NOT add a part to exclude
         assignments failing the interlock rules, if 'N'
         it DOES.
         The procedure passes back the length of the resultant
         string, so it can be successfully null terminated by
         the calling program.
   */
   procedure pyrsql
   (
      sqlid      in            number,
      timedepflg in            varchar2,
      interlock  in            varchar2,
      sqlstr     in out nocopy varchar2,
      len           out nocopy number,
      action     in            varchar2 default 'R',
      pactid     in     number default null,
      chkno      in     number default null
   ) is
      PY_ALLASG constant number := 1;
      PY_SPCINC constant number := 2;
      PY_SPCEXC constant number := 3;
      PY_RUNRGE constant number := 4;
      PY_RESRGE constant number := 5;
      PY_NONRGE constant number := 6;
      PY_PURRGE constant number := 7;    -- Purge.
      PY_RETRGE constant number := 8;    -- RetroPay By Element
      PY_RETASG constant number := 9;
      PYG_AT_RET constant varchar2(1) := 'O';
      PYG_AT_ARC constant varchar2(1) := 'X';
      PYG_AT_RUN constant varchar2(1) := 'R';
      PYG_AT_ADV constant varchar2(1) := 'F';
      PYG_AT_RTA constant varchar2(1) := 'G';
      PYG_AT_RTE constant varchar2(1) := 'L';
      PYG_AT_RCS constant varchar2(1) := 'S';
      PYG_AT_PUR constant varchar2(1) := 'Z';  -- Purge.
      PYG_AT_ADE constant varchar2(1) := 'W';
      PYG_AT_BEE constant varchar2(3) := 'BEE';  -- BEE Process
      PYG_AT_ECS constant varchar2(3) := 'EC';  -- Estimate Costing  Process
      PYG_AT_BAL constant varchar2(1) := 'B';
      PYG_AT_CHQ constant varchar2(1) := 'H'; -- ChequeWriter
      PYG_AT_MAG constant varchar2(1) := 'M'; -- Magnetic Payment
      PYG_AT_PST constant varchar2(2) := 'PP'; -- Postal Payment
      PYG_AT_PRU constant varchar2(3) := 'PRU'; -- Payroll Roll Up
      PYG_AT_CSH constant varchar2(1) := 'A'; -- Cash Payment
      PYG_AT_REV constant varchar2(1) := 'V'; -- Reversal

      l_ret_timedepflg varchar2(1);
      l_asg_set_id number;
      l_inc_or_excl HR_ASSIGNMENT_SET_AMENDMENTS.INCLUDE_OR_EXCLUDE%TYPE;
   begin
      --
      pay_proc_logging.PY_ENTRY('hr_dynsql.pyrsql');
      --
--
      hr_utility.trace('sqlid      = '||sqlid);
      hr_utility.trace('timedepflg = '||timedepflg);
      hr_utility.trace('interlock  = '||interlock);
      hr_utility.trace('action     = '||action);
      hr_utility.trace('pactid     = '||pactid);
      hr_utility.trace('chkno      = '||chkno);

      if (chkno is null) then
         range := nopoprange;
      else
         range := poprange;
      end if;
      -- go through each of the sql sub strings and see if
      -- they are needed.
      if (action = PYG_AT_RET OR
          action = PYG_AT_RTA OR
          action = PYG_AT_RTE ) then
         --
         -- Force Time Independent for Retropay (if not Group Dependent)
         --
         if (timedepflg = 'N') then
            l_ret_timedepflg := 'Y';
         else
            l_ret_timedepflg := timedepflg;
         end if;
         if (sqlid = PY_ALLASG) then
            sqlstr := retasactsel || allretasg || range;
            if (interlock = 'N') then
               if(l_ret_timedepflg = 'Y') then
                  sqlstr := sqlstr || intretind; -- time independent leg.
               elsif (l_ret_timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdepret; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intretdep; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || fupdate;
         elsif (sqlid = PY_SPCINC) then
            sqlstr := retasactsel || spcretinc || range;
            if (interlock = 'N') then
               if(l_ret_timedepflg = 'Y') then
                  sqlstr := sqlstr || intretind; -- time independent leg.
               elsif (l_ret_timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdepret; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intretdepaset; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || fupdate;
         elsif (sqlid = PY_SPCEXC) then
            sqlstr := retasactsel || allretasg || range || excspc;
            if (interlock = 'N') then
               if(l_ret_timedepflg = 'Y') then
                  sqlstr := sqlstr || intretind; -- time independent leg.
               elsif (l_ret_timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdepret; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intretdep; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || fupdate;
         elsif (sqlid = PY_RUNRGE) then
            sqlstr := rrsel || allretasg || orderby;
         elsif (sqlid = PY_RETRGE) then
            sqlstr := ordrrsel || retdefasg || orderby;
         elsif (sqlid = PY_RETASG) then
            --
            -- If time dependant flag is G then the system is
            -- setup do do multi asg processing.
            --
            if (l_ret_timedepflg = 'G') then
               -- get group range
               if (chkno is null) then
                  range := grpnopoprange;
               else
                  range := grppoprange;
               end if;
               sqlstr := retpgasactsel || retdefasgpg || range || intretgrpdep;
            else
               sqlstr := retasactsel || retdefasg || range || intretind;
            end if;
         end if;
      elsif (action = PYG_AT_ADV) then
         if (sqlid = PY_ALLASG) then
            sqlstr := asactsel || alladvasg ||range||intretind;
         elsif (sqlid = PY_RUNRGE) then
            sqlstr := rrsel || allretasg || orderby;
         end if;
      elsif (action = PYG_AT_ADE) then
         if (sqlid = PY_ALLASG) then
            sqlstr := asactsel || alladeasg || range|| intind;
         elsif (sqlid = PY_SPCINC) then
            sqlstr := asactsel || adeincspc || range || intind;
            sqlstr := sqlstr || fupdate;
         elsif (sqlid = PY_SPCEXC) then
            sqlstr := asactsel || alladeasg || range || excspc || intind;
            sqlstr := sqlstr || fupdate;
         elsif (sqlid = PY_RUNRGE) then
            sqlstr := rrsel || alladeasg || orderby;
         else
            sqlstr := null; -- should not reach this!!
         end if;
         hr_utility.trace('sqlstr: ' ||sqlstr);
      elsif (action = PYG_AT_RCS) then
         if (sqlid = PY_ALLASG) then
            sqlstr := asactsel || allrcsasg || range;
            if (interlock = 'N') then
               if(timedepflg = 'Y') then
                  sqlstr := sqlstr || intind; -- time independent leg.
               elsif (timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdep; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intdep; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || fupdate;
         elsif (sqlid = PY_SPCINC) then
            sqlstr := asactsel || spcrcsinc || range;
            if (interlock = 'N') then
               if (timedepflg = 'Y') then
                  sqlstr := sqlstr || intind; -- time independent leg.
               elsif (timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdep; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intdepaset; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || fupdate;
         elsif (sqlid = PY_SPCEXC) then
            sqlstr := asactsel || allrcsasg || range || excspc;
            if(interlock = 'N') then
               if(timedepflg = 'Y') then
                  sqlstr := sqlstr || intind; -- time independent leg.
               elsif (timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdep; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intdep; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || fupdate;
         elsif (sqlid = PY_RESRGE) then
            sqlstr := ordrrsel || resact || orderby;
         elsif (sqlid = PY_NONRGE) then
            sqlstr := ordrrsel || nonact || orderby;
         else
            sqlstr := null; -- should not reach this!!
         end if;
      elsif (action = PYG_AT_ARC) then
         /* Must be getting a population range for the archiver */
         archive_range(pactid, sqlstr);
      elsif (action = PYG_AT_BEE) then
         if (sqlid = PY_ALLASG) then
            sqlstr := beeactsel || beeasg || range;
         elsif (sqlid = PY_RUNRGE) then
            sqlstr := brrsel || beeasg || borderby;
         else
            sqlstr := null; -- should not reach this!!
         end if;
      elsif (action = PYG_AT_PUR) then
         -- Set up strings for Purge.
         if (sqlid = PY_PURRGE) then
            sqlstr := prrsel || purallasg || orderby;
         elsif (sqlid = PY_ALLASG) then
            sqlstr := puractsel || purallasg || range || intpur;
         elsif (sqlid = PY_SPCINC) then
            sqlstr := puractsel || purspcinc || range || intpur;
         elsif (sqlid = PY_SPCEXC) then
            sqlstr := puractsel || purallasg || range || intpur || excspc;
         else
            sqlstr := null; -- should not reach this!!
         end if;

      elsif (action = PYG_AT_BAL) then
         if (sqlid = PY_ALLASG) then
            sqlstr := runasactsel || allasg || range;
            if (interlock = 'N') then
               if(timedepflg = 'Y') then
                  sqlstr := sqlstr || intbal; -- time independent leg.
               elsif (timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdepbal; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intbaldep; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || actorderby || fupdate;
         elsif (sqlid = PY_SPCINC) then
            sqlstr := runasactsel || spcinc || range;
            if (interlock = 'N') then
               if(timedepflg = 'Y') then
                  sqlstr := sqlstr || intbal; -- time independent leg.
               elsif (timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdepbal; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intbaldepaset; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || actorderby || fupdate;
         elsif (sqlid = PY_SPCEXC) then
            sqlstr := runasactsel || allasg || range || excspc;
            if (interlock = 'N') then
               if(timedepflg = 'Y') then
                  sqlstr := sqlstr || intbal; -- time independent leg.
               elsif (timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdepbal; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intbaldep; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || actorderby || fupdate;
         elsif (sqlid = PY_RUNRGE) then
            sqlstr := rrsel || allasg || orderby;
         else
            sqlstr := null; -- should not reach this!!
         end if;

      elsif (action = PYG_AT_REV) then
         if (sqlid = PY_ALLASG) then
            sqlstr := runasactsel || revallasg || range || revaa;
            if (interlock = 'N') then
               if(timedepflg = 'Y') then
                  sqlstr := sqlstr || intbal; -- time independent leg.
               elsif (timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdepbal; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intbaldep; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || actorderby || fupdate;
         elsif (sqlid = PY_SPCINC) then
            sqlstr := runasactsel || revspcinc || range || revaa;
            if (interlock = 'N') then
               if(timedepflg = 'Y') then
                  sqlstr := sqlstr || intbal; -- time independent leg.
               elsif (timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdepbal; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intbaldepaset; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || actorderby || fupdate;
         elsif (sqlid = PY_SPCEXC) then
            sqlstr := runasactsel || revallasg || range || revaa || excspc;
            if (interlock = 'N') then
               if(timedepflg = 'Y') then
                  sqlstr := sqlstr || intbal; -- time independent leg.
               elsif (timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdepbal; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intbaldep; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || actorderby || fupdate;
         elsif (sqlid = PY_RUNRGE) then
            sqlstr := rrsel || revallasg || orderby;
         else
            sqlstr := null; -- should not reach this!!
         end if;

      elsif (action = PYG_AT_RUN ) then
         if (sqlid = PY_ALLASG) then
            sqlstr := runasactsel || allasg || range;
            if (interlock = 'N') then
               if(timedepflg = 'Y') then
                  sqlstr := sqlstr || intind; -- time independent leg.
               elsif (timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdep; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intdep; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || actorderby || fupdate;
         elsif (sqlid = PY_SPCINC) then
            sqlstr := runasactsel || spcinc || range;
            if (interlock = 'N') then
               if (timedepflg = 'Y') then
                  sqlstr := sqlstr || intind; -- time independent leg.
               elsif (timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdep; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intdepaset; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || actorderby || fupdate;
         elsif (sqlid = PY_SPCEXC) then
            sqlstr := runasactsel || allasg || range || excspc;
            if(interlock = 'N') then
               if(timedepflg = 'Y') then
                  sqlstr := sqlstr || intind; -- time independent leg.
               elsif (timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdep; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intdep; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || actorderby || fupdate;
         elsif (sqlid = PY_RUNRGE) then
           --
           -- Determine if the payroll action is being run for an assignment
           -- set.  If not formula-based assignment set use the following to
           -- limit the rows inserted into PAY_POPULATION_RANGES:
           -- use spcinc if Include set
           -- use excspc if Exclude set
           --
           BEGIN
             --
             -- Get Assignment Set ID from the Payroll Action being
             -- Processed - confirming its NOT formula-based.
             --
             select pac.assignment_set_id
              into l_asg_set_id
              from pay_payroll_actions pac,
                   hr_assignment_sets has
             where pac.payroll_action_id = pactid
               and has.assignment_set_id = pac.assignment_set_id
               and has.formula_id is null;
             --
             -- Find out if an include or exclude assignment set
             --
             select include_or_exclude
               into l_inc_or_excl
               from hr_assignment_set_amendments
               where assignment_set_id = l_asg_set_id
                 and rownum = 1;
           EXCEPTION
             When OTHERS Then
               --
               -- For any error, force it to default to original processing.
               --
               l_inc_or_excl := 'N';
           END;

            --
           -- If it is an INCLUDE assignment set use the spcinc query,
           -- if it is an EXCLUDE then use allasg and excspc,
           -- otherwise just use allasg.
           --
           if (l_inc_or_excl = 'I') then
             sqlstr := rrsel || rspcinc || orderby;
           elsif (l_inc_or_excl = 'E') then
             sqlstr := rrsel || allasg || excspc || orderby;
           else
             sqlstr := rrsel || allasg || orderby;
           end if;
         elsif (sqlid = PY_RESRGE) then
            sqlstr := ordrrsel || resact || orderby;
         elsif (sqlid = PY_NONRGE) then
            sqlstr := ordrrsel || nonact || orderby;
         else
            sqlstr := null; -- should not reach this!!
         end if;
      elsif (action = PYG_AT_ECS) then
         if (sqlid = PY_RESRGE) then
            sqlstr := ordrrsel || ecsresact || orderby;
         elsif (sqlid = PY_NONRGE) then
            sqlstr := ordrrsel || ecsnonact || orderby;
         else
            sqlstr := null; -- should not reach this!!
         end if;
      elsif (action = PYG_AT_CHQ or
             action = PYG_AT_MAG or
             action = PYG_AT_PST or
             action = PYG_AT_CSH
            ) then
         pay_proc_environment_pkg.pactid := pactid;
         if (sqlid = PY_RESRGE) then
            sqlstr := ordrrsel || resact ||
                      ' union all ' || orgsel || orgfrom ||
                      orgorderby;
         elsif (sqlid = PY_NONRGE) then
            sqlstr := ordrrsel || nonact ||
                      ' union all ' || orgsel || orgfrom ||
                      orgorderby;
         else
            sqlstr := null; -- should not reach this!!
         end if;
      elsif (action = PYG_AT_PRU) then
--
         if (sqlid = PY_RESRGE) then
            sqlstr := ordrrsel || pruresact || orderby;
         elsif (sqlid = PY_NONRGE) then
            sqlstr := ordrrsel || prunonact || orderby;
         else
            sqlstr := null; -- should not reach this!!
         end if;
--
      else
         if (sqlid = PY_ALLASG) then
            sqlstr := asactsel || allasg || range;
            if (interlock = 'N') then
               if(timedepflg = 'Y') then
                  sqlstr := sqlstr || intind; -- time independent leg.
               elsif (timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdep; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intdep; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || fupdate;
         elsif (sqlid = PY_SPCINC) then
            sqlstr := asactsel || spcinc || range;
            if (interlock = 'N') then
               if (timedepflg = 'Y') then
                  sqlstr := sqlstr || intind; -- time independent leg.
               elsif (timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdep; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intdepaset; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || fupdate;
         elsif (sqlid = PY_SPCEXC) then
            sqlstr := asactsel || allasg || range || excspc;
            if(interlock = 'N') then
               if(timedepflg = 'Y') then
                  sqlstr := sqlstr || intind; -- time independent leg.
               elsif (timedepflg = 'G') then
                  sqlstr := sqlstr || intgrpdep; -- time dependent on group leg.
               else
                  sqlstr := sqlstr || intdep; -- time dependent leg.
               end if;
            end if;
            sqlstr := sqlstr || fupdate;
         elsif (sqlid = PY_RUNRGE) then
            sqlstr := rrsel || allasg || orderby;
         elsif (sqlid = PY_RESRGE) then
            sqlstr := ordrrsel || resact || orderby;
         elsif (sqlid = PY_NONRGE) then
            sqlstr := ordrrsel || nonact || orderby;
         else
            sqlstr := null; -- should not reach this!!
         end if;
      end if;
      len := length(sqlstr); -- return the length of the string.
--
      pay_proc_logging.PY_EXIT('hr_dynsql.pyrsql');
--
   end pyrsql;
--
   ---------------------------- adv_override_check ----------------------------
   /*
      NAME
         adv_override_check
      DESCRIPTION
         Check whether the advance override input value exists
         for the element entry at the given start and end date.
      NOTES
         <none>
   */
  function adv_override_check
  (
   p_eeid number,
   p_start_date date,
   p_end_date date
  ) return varchar2 is
   --
   cursor csr_adv_override
     (
      l_eeid number,
      l_start_date date,
      l_end_date date
     ) is
     select 'Y'
     from   dual
     where  (NOT EXISTS
                (select null
                     from pay_element_entry_values_f ev3,
                          pay_input_values_f iv3
                    where TRANSLATE(UPPER(iv3.name), ' ', '_') =
                          (select TRANSLATE(UPPER(hrl1.meaning), ' ', '_')
                                        from hr_lookups hrl1
                                        WHERE  hrl1.lookup_type = 'NAME_TRANSLATIONS'
                                        AND    hrl1.lookup_code = 'ADV_OVERRIDE')
                      and l_eeid = ev3.element_entry_id
                      and ev3.input_value_id   = iv3.input_value_id
                      and ((ev3.effective_start_date between l_start_date and l_end_date )
                           or (ev3.effective_start_date < l_start_date
                               and ev3.effective_end_date > l_start_date ))
                      and ((iv3.effective_start_date between l_start_date and l_end_date )
                           or (iv3.effective_start_date < l_start_date
                               and iv3.effective_end_date > l_start_date )))
              OR  EXISTS
                  (select null
                     from pay_element_entry_values_f ev4,
                          pay_input_values_f iv4
                    where TRANSLATE(UPPER(iv4.name), ' ', '_') =
                            (select TRANSLATE(UPPER(hrl2.meaning), ' ', '_')
                                        from hr_lookups hrl2
                                        WHERE  hrl2.lookup_type = 'NAME_TRANSLATIONS'
                                        AND    hrl2.lookup_code = 'ADV_OVERRIDE')
                      and l_eeid = ev4.element_entry_id
                      and ev4.input_value_id   = iv4.input_value_id
                      and ev4.screen_entry_value <> 'Y'
                      and ((ev4.effective_start_date between l_start_date and l_end_date )
                           or (ev4.effective_start_date < l_start_date
                               and ev4.effective_end_date > l_start_date ))
                      and ((iv4.effective_start_date between l_start_date and l_end_date )
                           or (iv4.effective_start_date < l_start_date
                               and iv4.effective_end_date >l_start_date ))));
   --
   l_check varchar2(1);
   --
 begin
--
--
   open  csr_adv_override(p_eeid,p_start_date,p_end_date);
   fetch csr_adv_override into l_check;
   --
   if csr_adv_override%notfound then
      l_check := 'N';
   end if;
   --
   close csr_adv_override;
   --
   return (l_check);
   --
 end adv_override_check;
--
begin
--
   -- Select for range row population.
   rrsel := 'select distinct pay_pos.person_id, null, null';
   ordrrsel := 'select /*+ ORDERED USE_NL(pay_asg) */ distinct pay_pos.person_id, null, null';
   prrsel := 'select distinct pay_pos.person_id, null, null'; -- For purge.
   brrsel := 'select distinct pay_asg.person_id, null, null'; -- For BEE.
   orgsel := 'select distinct null, hou.organization_id, ''HOU''';
--
   -- select list for insertion into assignment actions table.
   -- Now needs the dummy value for secondary_status.
   retpgasactsel := '
select
       pay_assignment_actions_s.nextval,
       null,
       pay_pac.payroll_action_id,
       ''U'',
       :chunk_number,
       pay_assignment_actions_s.nextval,
       1,
       null,
       ''U'',
       pay_pos.object_group_id';
--
   retasactsel := '
select /*+ INDEX(pay_pos PER_PERIODS_OF_SERVICE_PK)*/
       pay_assignment_actions_s.nextval,
       pay_asg.assignment_id,
       pay_pac.payroll_action_id,
       ''U'',
       :chunk_number,
       pay_assignment_actions_s.nextval,
       1,
       hr_dynsql.get_tax_unit(pay_asg.assignment_id,
                              pay_pac.effective_date),
       ''U'',
       pay_asg.assignment_id';
--
   asactsel := '
select /*+ INDEX(pay_pos PER_PERIODS_OF_SERVICE_PK)
           INDEX(pay_asg PER_ASSIGNMENTS_F_N12) */
       pay_assignment_actions_s.nextval,
       pay_asg.assignment_id,
       pay_pac.payroll_action_id,
       ''U'',
       :chunk_number,
       pay_assignment_actions_s.nextval,
       1,
       hr_dynsql.get_tax_unit(pay_asg.assignment_id,
                              pay_pac.effective_date),
       ''U'',
       null';
--
   -- run select list for insertion into assignment actions table.
   -- NOTE: the assignment_action_id and action_sequence values have
   -- to be set later because we need to use order by here and that
   -- doesn't work with a sequence.
   runasactsel := '
select /*+ INDEX(pay_pos PER_PERIODS_OF_SERVICE_PK)
           INDEX(pay_asg PER_ASSIGNMENTS_F_N12) */
       1,
       pay_asg.assignment_id,
       pay_pac.payroll_action_id,
       ''U'',
       :chunk_number,
       1,
       1,
       hr_dynsql.get_tax_unit(pay_asg.assignment_id,
                              pay_pac.effective_date),
       ''U'',
       null';
--
   -- purge select list for insertion into assignment actions table.
   -- NOTE: the assignment_action_id and action_sequence values have
   -- to be set later because we need to use distinct here and that
   -- doesn't work with a sequence.
   -- The final value of 'U' is for secondary status.
   puractsel := '
select /*+ INDEX(pay_pos PER_PERIODS_OF_SERVICE_PK)*/
       distinct 1,
       pay_asg.assignment_id,
       pay_pac.payroll_action_id,
       ''U'',
       :chunk_number,
       1,
       1,
       null,
       ''U'',
       null';
--
   -- BEE sql query for all assignments.
   beeactsel := '
select distinct 1,
       pay_btl.assignment_id,
       pay_pac.payroll_action_id,
       ''U'',
       :chunk_number,
       1,
       1,
       null,
       ''U'',
       null';
   --
   beeasg := '
  from pay_payroll_actions pay_pac,
       pay_batch_lines pay_btl,
       per_all_assignments_f pay_asg
 where pay_pac.payroll_action_id = :payroll_action_id
   and pay_pac.batch_id = pay_btl.batch_id
   and pay_btl.assignment_id = pay_asg.assignment_id
   and pay_btl.effective_date between pay_asg.effective_start_date
                                  and pay_asg.effective_end_date';
--
   -- From and where clause for all assignments.
   -- Meant for insertion into assignment actions table.
   -- Note, assignments must be effective
   -- at both date paid and date earned.
   allasg := '
 from   per_periods_of_service pay_pos,
        per_all_assignments_f  pay_asg,
        per_all_assignments_f  pay_as2,
        pay_payroll_actions    pay_pac
 where  pay_pac.payroll_action_id    = :payroll_action_id
 and    pay_asg.payroll_id           = pay_pac.payroll_id
 and    pay_pac.effective_date between
        pay_asg.effective_start_date and pay_asg.effective_end_date
 and    pay_as2.assignment_id        = pay_asg.assignment_id
 and    pay_pac.date_earned between
        pay_as2.effective_start_date and pay_as2.effective_end_date
 and    pay_pos.period_of_service_id = pay_asg.period_of_service_id
 and    pay_as2.period_of_service_id = pay_asg.period_of_service_id';
--
  -- Reversal range row select
   revallasg := '
 from   per_periods_of_service pay_pos,
        per_all_assignments_f  pay_asg,
        per_all_assignments_f  pay_as2,
        pay_payroll_actions    pay_pac,
        pay_assignment_actions pay_paa2,
        pay_payroll_actions    pay_pac2
 where  pay_pac.payroll_action_id    = :payroll_action_id
 and    pay_asg.payroll_id           = pay_pac.payroll_id
 and    pay_pac.effective_date between
        pay_asg.effective_start_date and pay_asg.effective_end_date
 and    pay_as2.assignment_id        = pay_asg.assignment_id
 and    pay_pac.date_earned between
        pay_as2.effective_start_date and pay_as2.effective_end_date
 and    pay_pos.period_of_service_id = pay_asg.period_of_service_id
 and    pay_as2.period_of_service_id = pay_asg.period_of_service_id
 and    pay_paa2.assignment_id = pay_asg.assignment_id
 and    pay_pac2.payroll_action_id = pay_paa2.payroll_action_id
 and    pay_pac2.payroll_action_id = pay_pac.target_payroll_action_id
 and    pay_pac2.action_type in (''R'', ''Q'')
 and    pay_pac2.effective_date <= pay_pac.effective_date';
--
 -- Purge range row select.
   purallasg := '
 from   per_periods_of_service pay_pos,
        per_all_assignments_f  pay_asg,
        pay_payroll_actions    pay_pac
 where  pay_pac.payroll_action_id     = :pactid
 and    pay_asg.business_group_id + 0 = pay_pac.business_group_id
 and    pay_asg.payroll_id is not null
 and    pay_asg.effective_start_date <= pay_pac.effective_date
 and    pay_pos.period_of_service_id  = pay_asg.period_of_service_id';
--
 -- Retropay assignments
   allretasg := '
 from   per_periods_of_service pay_pos,
        per_all_assignments_f  pay_asg,
        pay_payroll_actions    pay_pac
 where  pay_pac.payroll_action_id    = :payroll_action_id
 and    pay_asg.payroll_id           = pay_pac.payroll_id
 and    pay_pac.effective_date between
        pay_asg.effective_start_date and pay_asg.effective_end_date
 and    pay_pos.period_of_service_id = pay_asg.period_of_service_id';
--
   -- RetroCost assignments
   allrcsasg := '
 from   per_periods_of_service     pay_pos,
        per_all_assignments_f      pay_asg,
        pay_payroll_actions        pay_pac
 where  pay_pac.payroll_action_id    = :pactid
 and   (pay_asg.payroll_id = pay_pac.payroll_id or pay_pac.payroll_id is null)
 and    pay_pac.effective_date between
        pay_asg.effective_start_date and pay_asg.effective_end_date
 and    pay_pos.period_of_service_id = pay_asg.period_of_service_id
 and exists (select null
 from   pay_action_classifications pay_pcl,
        pay_assignment_actions     pay_act,
        per_all_assignments_f      pay_asg2,
        pay_payroll_actions        pay_pac2
 where  pay_pac2.consolidation_set_id +0 = pay_pac.consolidation_set_id
 and    pay_pac2.effective_date between
        pay_pac.start_date and pay_pac.effective_date
 and    pay_act.payroll_action_id    = pay_pac2.payroll_action_id
 and    pay_act.action_status        = ''C''
 and    pay_pcl.classification_name  = ''COSTED''
 and    pay_pac2.action_type         = pay_pcl.action_type
 and    pay_asg.assignment_id        = pay_act.assignment_id
 and    pay_asg2.assignment_id       = pay_act.assignment_id
 and    pay_pac2.effective_date between
        pay_asg2.effective_start_date and pay_asg2.effective_end_date
 and    pay_asg2.payroll_id + 0      = pay_asg.payroll_id + 0
   and    not exists (
    select null
    from   pay_assignment_actions     pay_ac2
    where  pay_ac2.assignment_id       = pay_asg.assignment_id
    and    pay_pac.payroll_action_id   = pay_ac2.payroll_action_id))';
--
 -- Advancepay assignments: criteria : An existance of
 -- Pay Advance element in current earnings period.
-- WARNING : this statment gets us very close to the 4000 character
-- limit of overall statement returned ... SO CARE MUST BE TAKEN
-- IN ANY CHANGES BEING MADE.
alladvasg := '
from per_periods_of_service pay_pos,
per_all_assignments_f pay_asg,
pay_payroll_actions pay_pac
where pay_pac.payroll_action_id = :payroll_action_id
and pay_asg.payroll_id + 0 = pay_pac.payroll_id
and pay_pac.effective_date between
pay_asg.effective_start_date and pay_asg.effective_end_date
and pay_pos.period_of_service_id = pay_asg.period_of_service_id
and exists (select null from
pay_element_entries_f p_pee,
pay_element_entry_values_f p_pev,
pay_element_entry_values_f p_pev2,
pay_input_values_f p_piv,
pay_input_values_f p_piv2
where p_pee.assignment_id = pay_asg.assignment_id
and pay_pac.effective_date between p_pee.effective_start_date
and p_pee.effective_end_date
and p_pee.element_type_id =
(select to_number(p_plr.rule_mode)
from pay_legislation_rules p_plr,
per_business_groups_perf p_pbg
where p_pbg.business_group_id = pay_pac.business_group_id
and p_pbg.legislation_code = p_plr.legislation_code
and TRANSLATE(upper(p_plr.rule_type),''-'',''_'' )=
''PAY_ADVANCE_INDICATOR'')
and p_pee.element_entry_id = p_pev.element_entry_id
and p_pee.element_entry_id = p_pev2.element_entry_id
and p_pev.input_value_id = p_piv.input_value_id
and p_piv2.input_value_id = p_pev2.input_value_id
and p_piv.input_value_id = (select to_number(p_plr.rule_mode)
from pay_legislation_rules p_plr, per_business_groups_perf p_pbg
where p_pbg.business_group_id = pay_pac.business_group_id
and   p_pbg.legislation_code  = p_plr.legislation_code
and TRANSLATE(upper(p_plr.rule_type),''-'',''_'') = ''PAI_START_DATE'')
and p_piv2.input_value_id = (select to_number(p_plr.rule_mode)
from pay_legislation_rules p_plr, per_business_groups_perf p_pbg
where p_pbg.business_group_id = pay_pac.business_group_id
and   p_pbg.legislation_code  = p_plr.legislation_code
and TRANSLATE(upper(p_plr.rule_type), ''-'',''_'') = ''PAI_END_DATE'')
and not exists (select null
from pay_element_entries_f p_pe2
where p_pe2.assignment_id = pay_asg.assignment_id
and p_pe2.element_type_id =
(select to_number(p_plr2.rule_mode)
from pay_legislation_rules p_plr2, per_business_groups_perf p_pbg2
where p_pbg2.business_group_id = pay_pac.business_group_id
and p_pbg2.legislation_code = p_plr2.legislation_code
and TRANSLATE(upper(p_plr2.rule_type), ''-'', ''_'') = ''ADV_DEDUCTION'')
and p_pe2.effective_start_date between
fnd_date.canonical_to_date(p_pev.screen_entry_value)
and fnd_date.canonical_to_date(p_pev2.screen_entry_value)))';
--
-- Advance Pay by Element
--
-- WARNING : this statment gets us very close to the 4000 character
-- limit of overall statement returned ... SO CARE MUST BE TAKEN
-- IN ANY CHANGES BEING MADE.
alladeasg := '
from per_periods_of_service pay_pos,
      per_all_assignments_f pay_asg,
      pay_payroll_actions pay_pac
where pay_pac.payroll_action_id = :pactid
  and pay_asg.payroll_id = pay_pac.payroll_id
  and pay_pac.effective_date between
             pay_asg.effective_start_date and pay_asg.effective_end_date
  and pay_pos.period_of_service_id = pay_asg.period_of_service_id
  and exists
(select null
   from pay_element_entries_f pay_pee,
        pay_element_types_f pay_pet,
       pay_element_entry_values_f pay_pev,
       pay_element_entry_values_f pay_pev2,
       pay_input_values_f pay_piv,
       pay_input_values_f pay_piv2
 where pay_pee.assignment_id = pay_asg.assignment_id
   and pay_pee.element_type_id = pay_pet.element_type_id
   and pay_pet.advance_indicator = ''Y''
   and pay_pee.element_entry_id = pay_pev.element_entry_id
   and pay_pee.element_entry_id = pay_pev2.element_entry_id
   and pay_pev.input_value_id = pay_piv.input_value_id
   and pay_piv2.input_value_id = pay_pev2.input_value_id
   and hr_dynsql.adv_override_check(pay_pee.element_entry_id,pay_pac.effective_date,pay_pac.end_date) = ''Y''
   and TRANSLATE(UPPER(pay_piv.name), '' '', ''_'') =
       (select TRANSLATE(UPPER(pay_hrl3.meaning), '' '', ''_'')
        from hr_lookups pay_hrl3
        WHERE  pay_hrl3.lookup_type = ''NAME_TRANSLATIONS''
        AND    pay_hrl3.lookup_code = ''START_DATE'')
   and TRANSLATE(UPPER(pay_piv2.name), '' '', ''_'') =
       (select TRANSLATE(UPPER(pay_hrl4.meaning), '' '', ''_'')
        from hr_lookups pay_hrl4
        WHERE  pay_hrl4.lookup_type = ''NAME_TRANSLATIONS''
        AND    pay_hrl4.lookup_code = ''END_DATE'')
   and (pay_pev.screen_entry_value between
          fnd_date.date_to_canonical(pay_pac.effective_date) and
          fnd_date.date_to_canonical(pay_pac.end_date)
        OR (pay_pev.screen_entry_value < fnd_date.date_to_canonical(pay_pac.effective_date) and
            pay_pev2.screen_entry_value > fnd_date.date_to_canonical(pay_pac.effective_date)))
   )' ;
  --
  -- Advance Pay specific inclusions
-- WARNING : this statment gets us very close to the 4000 character
-- limit of overall statement returned ... SO CARE MUST BE TAKEN
-- IN ANY CHANGES BEING MADE.
   adeincspc := '
from per_periods_of_service pay_pos,
      per_all_assignments_f pay_asg,
      pay_payroll_actions pay_pac,
      hr_assignment_set_amendments pay_inc
where pay_pac.payroll_action_id = :pactid
  and pay_asg.payroll_id = pay_pac.payroll_id
  and pay_inc.assignment_set_id    = pay_pac.assignment_set_id + decode(pay_pos.period_of_service_id, null, 0, 0)
  and pay_inc.assignment_id        = pay_asg.assignment_id + decode(pay_pos.period_of_service_id, null, 0, 0)
  and pay_pac.effective_date between
             pay_asg.effective_start_date and pay_asg.effective_end_date
  and pay_inc.include_or_exclude   = ''I''
  and pay_pos.period_of_service_id = pay_asg.period_of_service_id
  and exists
(select null
   from pay_element_entries_f pay_pee,
        pay_element_types_f pay_pet,
       pay_element_entry_values_f pay_pev,
       pay_element_entry_values_f pay_pev2,
       pay_input_values_f pay_piv,
       pay_input_values_f pay_piv2
 where pay_pee.assignment_id = pay_asg.assignment_id
   and pay_pee.element_type_id = pay_pet.element_type_id
   and pay_pet.advance_indicator = ''Y''
   and pay_pee.element_entry_id = pay_pev.element_entry_id
   and pay_pee.element_entry_id = pay_pev2.element_entry_id
   and pay_pev.input_value_id = pay_piv.input_value_id
   and pay_piv2.input_value_id = pay_pev2.input_value_id
   and hr_dynsql.adv_override_check(pay_pee.element_entry_id,pay_pac.effective_date,pay_pac.end_date) = ''Y''
   and TRANSLATE(UPPER(pay_piv.name), '' '', ''_'') =
       (select TRANSLATE(UPPER(pay_hrl3.meaning), '' '', ''_'')
        from hr_lookups pay_hrl3
        WHERE  pay_hrl3.lookup_type = ''NAME_TRANSLATIONS''
        AND    pay_hrl3.lookup_code = ''START_DATE'')
   and TRANSLATE(UPPER(pay_piv2.name), '' '', ''_'') =
       (select TRANSLATE(UPPER(pay_hrl4.meaning), '' '', ''_'')
        from hr_lookups pay_hrl4
        WHERE  pay_hrl4.lookup_type = ''NAME_TRANSLATIONS''
        AND    pay_hrl4.lookup_code = ''END_DATE'')
   and (pay_pev.screen_entry_value between
          fnd_date.date_to_canonical(pay_pac.effective_date) and
          fnd_date.date_to_canonical(pay_pac.end_date)
        OR (pay_pev.screen_entry_value < fnd_date.date_to_canonical(pay_pac.effective_date) and
            pay_pev2.screen_entry_value > fnd_date.date_to_canonical(pay_pac.effective_date)))
       )' ;
--
   -- Specific inclusions in range creation assignment action phase
   rspcinc := '
 from   per_periods_of_service       pay_pos,
        per_all_assignments_f        pay_asg,
        per_all_assignments_f        pay_as2,
        hr_assignment_set_amendments pay_inc,
        pay_payroll_actions          pay_pac
 where  pay_pac.payroll_action_id    = :payroll_action_id
 and    pay_pac.assignment_set_id    = pay_inc.assignment_set_id
 and    pay_asg.assignment_id        = pay_inc.assignment_id
 and    pay_asg.payroll_id           = pay_pac.payroll_id
 and    pay_pac.effective_date between
        pay_asg.effective_start_date and pay_asg.effective_end_date
 and    pay_as2.assignment_id        = pay_asg.assignment_id
 and    pay_pac.date_earned between
        pay_as2.effective_start_date and pay_as2.effective_end_date
 and    pay_inc.include_or_exclude   = ''I''
 and    pay_pos.period_of_service_id = pay_asg.period_of_service_id
 and    pay_as2.period_of_service_id = pay_asg.period_of_service_id';
--
   -- Specific inclusions in assignment action phase
   spcinc := '
 from   per_periods_of_service       pay_pos,
        per_all_assignments_f        pay_asg,
        per_all_assignments_f        pay_as2,
        hr_assignment_set_amendments pay_inc,
        pay_payroll_actions          pay_pac
 where  pay_pac.payroll_action_id    = :payroll_action_id
 and    pay_inc.assignment_set_id    = pay_pac.assignment_set_id + decode(pay_pos.period_of_service_id, null, 0, 0)
 and    pay_inc.assignment_id        = pay_asg.assignment_id + decode(pay_pos.period_of_service_id, null, 0, 0)
 and    pay_asg.payroll_id           = pay_pac.payroll_id
 and    pay_pac.effective_date between
        pay_asg.effective_start_date and pay_asg.effective_end_date
 and    pay_as2.assignment_id        = pay_asg.assignment_id
 and    pay_pac.date_earned between
        pay_as2.effective_start_date and pay_as2.effective_end_date
 and    pay_inc.include_or_exclude   = ''I''
 and    pay_pos.period_of_service_id = pay_asg.period_of_service_id
 and    pay_as2.period_of_service_id = pay_asg.period_of_service_id';
--
   revspcinc := '
 from   per_periods_of_service       pay_pos,
        per_all_assignments_f        pay_asg,
        per_all_assignments_f        pay_as2,
        hr_assignment_set_amendments pay_inc,
        pay_payroll_actions          pay_pac,
        pay_assignment_actions       pay_paa2,
        pay_payroll_actions          pay_pac2
 where  pay_pac.payroll_action_id    = :payroll_action_id
 and    pay_inc.assignment_set_id    = pay_pac.assignment_set_id + decode(pay_pos.period_of_service_id, null, 0, 0)
 and    pay_inc.assignment_id        = pay_asg.assignment_id + decode(pay_pos.period_of_service_id, null, 0, 0)
 and    pay_asg.payroll_id           = pay_pac.payroll_id
 and    pay_pac.effective_date between
        pay_asg.effective_start_date and pay_asg.effective_end_date
 and    pay_as2.assignment_id        = pay_asg.assignment_id
 and    pay_pac.date_earned between
        pay_as2.effective_start_date and pay_as2.effective_end_date
 and    pay_inc.include_or_exclude   = ''I''
 and    pay_pos.period_of_service_id = pay_asg.period_of_service_id
 and    pay_as2.period_of_service_id = pay_asg.period_of_service_id
 and    pay_paa2.assignment_id = pay_asg.assignment_id
 and    pay_pac2.payroll_action_id = pay_paa2.payroll_action_id
 and    pay_pac2.payroll_action_id = pay_pac.target_payroll_action_id
 and    pay_pac2.action_type in (''R'', ''Q'')
 and    pay_pac2.effective_date <= pay_pac.effective_date';
--
   -- Purge Specific inclusions.
   purspcinc := '
 from   per_periods_of_service       pay_pos,
        per_all_assignments_f        pay_asg,
        hr_assignment_set_amendments pay_inc,
        pay_payroll_actions          pay_pac
 where  pay_pac.payroll_action_id    = :payroll_action_id
 and    pay_inc.assignment_set_id    = pay_pac.assignment_set_id
 and    pay_inc.assignment_id        = pay_asg.assignment_id
 and    pay_asg.payroll_id           is not null
 and    pay_asg.effective_start_date <= pay_pac.effective_date
 and    pay_inc.include_or_exclude   = ''I''
 and    pay_pos.period_of_service_id = pay_asg.period_of_service_id + decode(pay_inc.assignment_id, null, 0, 0)';
--
   -- Retropay inclusions
   spcretinc := '
 from   per_periods_of_service       pay_pos,
        per_all_assignments_f        pay_asg,
        hr_assignment_set_amendments pay_inc,
        pay_payroll_actions          pay_pac
 where  pay_pac.payroll_action_id    = :payroll_action_id
 and    pay_inc.assignment_set_id    = pay_pac.assignment_set_id + decode(pay_pos.period_of_service_id, null, 0, 0)
 and    pay_inc.assignment_id        = pay_asg.assignment_id + decode(pay_pos.period_of_service_id, null, 0, 0)
 and    pay_asg.payroll_id + 0       = pay_pac.payroll_id
 and    pay_pac.effective_date between
        pay_asg.effective_start_date and pay_asg.effective_end_date
 and    pay_inc.include_or_exclude   = ''I''
 and    pay_pos.period_of_service_id = pay_asg.period_of_service_id';
--
   -- RetroCosting inclusions
   spcrcsinc := '
 from   per_periods_of_service     pay_pos,
        hr_assignment_set_amendments pay_inc,
        per_all_assignments_f      pay_asg,
        per_all_assignments_f      pay_as2,
        pay_payroll_actions        pay_pac
 where  pay_pac.payroll_action_id    = :pactid
 and   (pay_asg.payroll_id = pay_pac.payroll_id or pay_pac.payroll_id is null)
 and    pay_pac.effective_date between
        pay_asg.effective_start_date and pay_asg.effective_end_date
 and    pay_inc.assignment_set_id    = pay_pac.assignment_set_id + decode(pay_pos.period_of_service_id, null, 0, 0)
 and    pay_inc.assignment_id        = pay_asg.assignment_id + decode(pay_pos.period_of_service_id, null, 0, 0)
 and    pay_inc.include_or_exclude   = ''I''
 and    pay_pos.period_of_service_id = pay_asg.period_of_service_id
 and    pay_as2.rowid                = pay_asg.rowid
 and exists (select null
 from   pay_action_classifications pay_pcl,
        pay_assignment_actions     pay_act,
        per_all_assignments_f      pay_asg2,
        pay_payroll_actions        pay_pac2
 where  pay_pac2.consolidation_set_id +0 = pay_pac.consolidation_set_id
 and    pay_pac2.effective_date between
        pay_pac.start_date and pay_pac.effective_date
 and    pay_act.payroll_action_id    = pay_pac2.payroll_action_id
 and    pay_act.action_status        = ''C''
 and    pay_pcl.classification_name  = ''COSTED''
 and    pay_pac2.action_type         = pay_pcl.action_type
 and    pay_asg.assignment_id        = pay_act.assignment_id
 and    pay_asg2.assignment_id       = pay_act.assignment_id
 and    pay_pac2.effective_date between
        pay_asg2.effective_start_date and pay_asg2.effective_end_date
 and    pay_asg2.payroll_id + 0      = pay_asg.payroll_id + 0
   and    not exists (
    select null
    from   pay_assignment_actions     pay_ac2
    where  pay_ac2.assignment_id       = pay_asg.assignment_id
    and    pay_pac.payroll_action_id   = pay_ac2.payroll_action_id))';
--
   -- Restrict by particular range of person_id.
   nopoprange := '
 and    pay_asg.person_id between
        :start_person_id and :end_person_id';
   -- Use of person_id in range table
   poprange := '
 and    pay_asg.person_id in (
   select pay_pop.person_id
   from pay_population_ranges  pay_pop
   where pay_pop.payroll_action_id = pay_pac.payroll_action_id
   and   pay_pop.chunk_number      = :chunk)';
--
  -- Ranges For Groups
  -- (use pay_pos instead of pay_asg because don't have pay_asg)
   -- Restrict by particular range of person_id.
   grpnopoprange := '
 and    pay_pos.source_id between
        :start_person_id and :end_person_id';
   -- Use of person_id in range table
   grppoprange := '
 and    pay_pos.source_id in (
   select pay_pop.person_id
   from pay_population_ranges  pay_pop
   where pay_pop.payroll_action_id = pay_pac.payroll_action_id
   and   pay_pop.chunk_number      = :chunk)';
--
   -- Estimate Costing Restricted payroll action range row
   -- where clause. i.e. restricted by payroll_id.
   -- nb have to join to per_time_periods at pa.start_date
   ecsresact := '
 from   pay_payroll_actions    pay_pa1,
        per_time_periods       pay_ptp,
        pay_payroll_actions    pay_pa2,
        pay_assignment_actions pay_act,
        per_all_assignments_f  pay_asg,
        per_periods_of_service pay_pos
 where  pay_pa1.payroll_action_id    = :payroll_action_id
 and    pay_ptp.payroll_id           = pay_pa1.payroll_id
 and    pay_pa1.start_date between
        pay_ptp.start_date and pay_ptp.end_date
 and    pay_pa2.consolidation_set_id = pay_pa1.consolidation_set_id
 and    pay_pa2.payroll_id           = pay_pa1.payroll_id
 and    pay_pa2.effective_date between
        pay_ptp.start_date and pay_ptp.end_date
 and    pay_act.payroll_action_id    = pay_pa2.payroll_action_id
 and    pay_asg.assignment_id        = pay_act.assignment_id
 and    pay_pa1.effective_date between
        pay_asg.effective_start_date and pay_asg.effective_end_date
 and    pay_pos.period_of_service_id = pay_asg.period_of_service_id';
--
   -- Estimate Costing Unrestricted payroll action range row
   -- where clause. i.e. not restricted by payroll_id.
   -- nb have to join to per_time_periods at pa.start_date
   ecsnonact := '
 from   pay_payroll_actions    pay_pa1,
        pay_all_payrolls_f     pay_pay,
        per_time_periods       pay_ptp,
        pay_payroll_actions    pay_pa2,
        pay_assignment_actions pay_act,
        per_all_assignments_f  pay_asg,
        per_periods_of_service pay_pos
 where  pay_pa1.payroll_action_id    = :payroll_action_id
 and    pay_pay.consolidation_set_id = pay_pa1.consolidation_set_id
 and    pay_pa1.effective_date between
        pay_pay.effective_start_date and pay_pay.effective_end_date
 and    pay_ptp.payroll_id           =  pay_pay.payroll_id
 and    pay_pa1.start_date between
        pay_ptp.start_date and pay_ptp.end_date
 and    pay_pa2.consolidation_set_id = pay_pa1.consolidation_set_id
 and    pay_pa2.effective_date between
        pay_ptp.start_date and pay_ptp.end_date
 and    pay_act.payroll_action_id    = pay_pa2.payroll_action_id
 and    pay_asg.assignment_id        = pay_act.assignment_id
 and    pay_pa1.effective_date between
        pay_asg.effective_start_date and pay_asg.effective_end_date
 and    pay_pos.period_of_service_id = pay_asg.period_of_service_id';
--
   -- Restricted payroll action range row where clause.
   -- i.e. restricted by payroll_id.
   resact := '
 from   pay_payroll_actions    pay_pa1,
        pay_payroll_actions    pay_pa2,
        pay_assignment_actions pay_act,
        per_all_assignments_f  pay_asg,
        per_periods_of_service pay_pos
 where  pay_pa1.payroll_action_id    = :payroll_action_id
 and    pay_pa2.consolidation_set_id = pay_pa1.consolidation_set_id
 and    pay_pa2.payroll_id           = pay_pa1.payroll_id
 and    pay_pa2.effective_date between
        pay_pa1.start_date and pay_pa1.effective_date
 and    pay_act.payroll_action_id    = pay_pa2.payroll_action_id
 and    pay_asg.assignment_id        = pay_act.assignment_id
 and    pay_pa1.effective_date between
        pay_asg.effective_start_date and pay_asg.effective_end_date
 and    pay_pos.period_of_service_id = pay_asg.period_of_service_id';
--
   -- Unrestricted payroll action range row where clause.
   -- i.e. not restricted by payroll_id.
   nonact := '
 from   pay_payroll_actions    pay_pa1,
        pay_payroll_actions    pay_pa2,
        pay_assignment_actions pay_act,
        per_all_assignments_f  pay_asg,
        per_periods_of_service pay_pos
 where  pay_pa1.payroll_action_id    = :payroll_action_id
 and    pay_pa2.consolidation_set_id = pay_pa1.consolidation_set_id
 and    pay_pa2.effective_date between
        pay_pa1.start_date and pay_pa1.effective_date
 and    pay_act.payroll_action_id    = pay_pa2.payroll_action_id
 and    pay_asg.assignment_id        = pay_act.assignment_id
 and    pay_pa1.effective_date between
        pay_asg.effective_start_date and pay_asg.effective_end_date
 and    pay_pos.period_of_service_id = pay_asg.period_of_service_id';
--
   -- Restricted payroll action range row where clause.
   -- i.e. restricted by payroll_id.
   pruresact := '
 from   pay_payroll_actions    pay_pa1,
        pay_payroll_actions    pay_pa2,
        pay_assignment_actions pay_act,
        per_all_assignments_f  pay_asg,
        per_periods_of_service pay_pos
 where  pay_pa1.payroll_action_id    = :payroll_action_id
 and    pay_pa2.consolidation_set_id = pay_pa1.consolidation_set_id
 and    pay_pa2.payroll_id           = pay_pa1.payroll_id
 and    pay_pa2.effective_date between
        pay_pa1.start_date and pay_pa1.effective_date
 and    pay_act.payroll_action_id    = pay_pa2.payroll_action_id
 and    pay_asg.assignment_id        = pay_act.assignment_id
 and    pay_pa2.effective_date between
        pay_asg.effective_start_date and pay_asg.effective_end_date
 and    pay_pos.period_of_service_id = pay_asg.period_of_service_id';
--
   -- Unrestricted payroll action range row where clause.
   -- i.e. not restricted by payroll_id.
   prunonact := '
 from   pay_payroll_actions    pay_pa1,
        pay_payroll_actions    pay_pa2,
        pay_assignment_actions pay_act,
        per_all_assignments_f  pay_asg,
        per_periods_of_service pay_pos
 where  pay_pa1.payroll_action_id    = :payroll_action_id
 and    pay_pa2.consolidation_set_id = pay_pa1.consolidation_set_id
 and    pay_pa2.effective_date between
        pay_pa1.start_date and pay_pa1.effective_date
 and    pay_act.payroll_action_id    = pay_pa2.payroll_action_id
 and    pay_asg.assignment_id        = pay_act.assignment_id
 and    pay_pa2.effective_date between
        pay_asg.effective_start_date and pay_asg.effective_end_date
 and    pay_pos.period_of_service_id = pay_asg.period_of_service_id';
--
   -- not exists to exclude specific assignments.
   excspc := '
 and not exists (
   select null
   from   hr_assignment_set_amendments pay_exc
   where  pay_exc.assignment_set_id  = pay_pac.assignment_set_id
   and    pay_exc.assignment_id      = pay_asg.assignment_id
   and    pay_exc.include_or_exclude = ''E'')';
--
   -- and not exists clause to exclude people failing interlock rules.
   -- this one is for time independent legislation.
   intind := '
   and    not exists (
    select /*+ INDEX (pay_pa2 pay_payroll_actions_pk) */ null
    from   pay_action_classifications pay_acl,
           pay_payroll_actions        pay_pa2,
           pay_assignment_actions     pay_ac2
    where  pay_ac2.assignment_id       = pay_asg.assignment_id
    and    pay_pa2.payroll_action_id   = pay_ac2.payroll_action_id
    and    pay_acl.classification_name = ''SEQUENCED''
    and    pay_pa2.action_type         = pay_acl.action_type
    and   (pay_pa2.effective_date > pay_pac.effective_date
       or (pay_ac2.action_status not in (''C'', ''S'')
    and    pay_pa2.effective_date <= pay_pac.effective_date)))';
--
   intbal := '
   and    not exists (
    select /*+ INDEX (pay_pa2 pay_payroll_actions_pk) */ null
    from   pay_action_classifications pay_acl,
           pay_payroll_actions        pay_pa2,
           pay_assignment_actions     pay_ac2
    where  pay_ac2.assignment_id       = pay_asg.assignment_id
    and    pay_pa2.payroll_action_id   = pay_ac2.payroll_action_id
    and    pay_acl.classification_name = ''SEQUENCED''
    and    pay_pa2.action_type         = pay_acl.action_type
    and    pay_ac2.action_status not in (''C'', ''S''))';

   -- and not exists clause to exclude people failing interlock rules.
   -- this one is for time dependent legislation.
   intdep := '
   and hr_dynsql.person_sequence_locked(pay_pos.period_of_service_id
                           + decode(pay_pos.person_id, null, 0, 0),
                                        pay_pac.effective_date) = ''N''';
--
   intdepaset := '
   and hr_dynsql.person_sequence_locked(pay_pos.period_of_service_id
                           + decode(pay_inc.last_update_login, null, 0, 0)
                           + decode(pay_as2.position_id, null, 0, 0),
                                        pay_pac.effective_date) = ''N''';
--
   intbaldep := '
   and hr_dynsql.bal_person_sequence_locked(pay_pos.period_of_service_id
                           + decode(pay_pos.person_id, null, 0, 0),
                                        pay_pac.effective_date) = ''N''';
--
   intbaldepaset := '
   and hr_dynsql.bal_person_sequence_locked(pay_pos.period_of_service_id
                           + decode(pay_inc.include_or_exclude, null, 0, 0),
                                        pay_pac.effective_date) = ''N''';
--
   intretdep := '
   and hr_dynsql.ret_person_sequence_locked(pay_pos.period_of_service_id
                           + decode(pay_pos.person_id, null, 0, 0),
                                        pay_pac.effective_date) = ''N''';
--
   intretdepaset := '
   and hr_dynsql.ret_person_sequence_locked(pay_pos.period_of_service_id
                           + decode(pay_inc.include_or_exclude, null, 0, 0),
                                        pay_pac.effective_date) = ''N''';
--
   intgrpdep := '
   and hr_dynsql.process_group_seq_locked(pay_asg.assignment_id,
                                        pay_pac.effective_date) = ''N''';
--
   intgrpdepbal := '
   and hr_dynsql.process_group_seq_locked(pay_asg.assignment_id,
                                        pay_pac.effective_date,
                                        ''B'') = ''N''';
--
   intgrpdepret := '
   and hr_dynsql.process_group_seq_locked(pay_asg.assignment_id,
                                        pay_pac.effective_date,
                                        ''Y'') = ''N''';
--
   intretgrpdep := '
   and not exists (select ''''
                     from pay_object_groups      pay_pog_asg2
                    where pay_pog_asg2.parent_object_group_id = pay_pos.object_group_id
                      and pay_pog_asg2.source_type = ''PAF''
                      and hr_dynsql.process_group_seq_locked(pay_pog_asg2.source_id,
                                                             pay_pac.effective_date,
                                                             ''Y'') <> ''N''
                   )';
--
    -- and not exists clause to prevent creation of purge actions if
    -- either a purge already exists in the future or the previous
    -- purge hasn't been completed.
    -- Also reject any assignments that do not have at least one
    -- assignment action existing on or before the purge date
    -- and on or after the last purge date.
    -- If skip flag is set by the action parameter, terminated
    -- assignments are excluded. (Bug 4726174)
--
    intpur := '
and   not exists (
      select null
      from   pay_assignment_actions pay_ac2,
             pay_payroll_actions    pay_pa2
      where  pay_ac2.assignment_id     = pay_asg.assignment_id +decode(pay_pos.period_of_service_id,0,0,0)
      and    pay_pa2.payroll_action_id = pay_ac2.payroll_action_id
      and    pay_pa2.action_type       = ''Z''
      and   (pay_ac2.secondary_status <> ''C''
         or (pay_pa2.effective_date >= pay_pac.effective_date)))
and   exists (
      select null
      from   pay_assignment_actions pay_ac4,
             pay_payroll_actions    pay_pa4
      where  pay_ac4.assignment_id     = pay_asg.assignment_id +decode(pay_pos.period_of_service_id,0,0,0)
      and    pay_pa4.payroll_action_id = pay_ac4.payroll_action_id
      and    pay_pa4.effective_date   <= pay_pac.effective_date
      and    pay_pa4.action_type      <> ''Z''
      and    pay_pa4.effective_date   >=
               (select nvl(max(pay_pa42.effective_date)
                          ,hr_general.start_of_time)
                from   pay_assignment_actions pay_ac42,
                       pay_payroll_actions    pay_pa42
                where  pay_ac42.assignment_id = pay_asg.assignment_id +decode(pay_pos.period_of_service_id,0,0,0)
                and    pay_pa42.payroll_action_id = pay_ac42.payroll_action_id
                and    pay_pa42.action_type = ''Z''
                and    pay_ac42.secondary_status = ''C''
               ))
and (not exists
       (select null from pay_action_parameters
        where parameter_name = ''PURGE_SKIP_TERM_ASG''
        and   parameter_value = ''Y'')
     or (pay_pac.effective_date between
         pay_asg.effective_start_date and pay_asg.effective_end_date
         and exists
          (select null
           from   per_time_periods      pay_tp5
           where  pay_tp5.payroll_id = pay_asg.payroll_id
           and    pay_pac.effective_date between
                  pay_tp5.start_date and pay_tp5.end_date)))';
--
-- Retropay sequence
   intretind := '
   and    not exists (
    select /*+ INDEX (pay_pa2 pay_payroll_actions_pk) */
           null
    from   pay_action_classifications pay_acl,
           pay_payroll_actions        pay_pa2,
           pay_assignment_actions     pay_ac2
    where  pay_ac2.assignment_id       = pay_asg.assignment_id
    and    pay_pa2.payroll_action_id   = pay_ac2.payroll_action_id
    and    pay_acl.classification_name = ''SEQUENCED''
    and    pay_pa2.action_type         = pay_acl.action_type
    and   ((pay_pa2.effective_date > pay_pac.effective_date
            and pay_ac2.action_status in (''C'', ''S''))
       or (pay_ac2.action_status not in (''C'', ''S'')
    and    pay_pa2.effective_date <= pay_pac.effective_date)))';
--
 -- Retropay by Element assignments with retro definition
   retdefasg := '
 from   pay_payroll_actions    pay_pac,
        per_all_assignments_f  pay_asg,
        pay_retro_assignments  pay_ret_asg,
        per_periods_of_service pay_pos
 where  pay_pac.payroll_action_id    = :payroll_action_id
 and    pay_asg.payroll_id           = pay_pac.payroll_id
 and    pay_asg.period_of_service_id = pay_pos.period_of_service_id
 and    pay_ret_asg.retro_assignment_action_id IS NULL
 and    pay_ret_asg.superseding_retro_asg_id IS NULL                 --  7364151
 and    pay_ret_asg.assignment_id = pay_asg.assignment_id
                     + decode(pay_asg.assignment_number, null, 0, 0)
 and    pay_ret_asg.approval_status <> ''D''
 and    pay_pac.effective_date between
        pay_asg.effective_start_date and pay_asg.effective_end_date';
--
   retdefasgpg := '
 from
        pay_payroll_actions    pay_pac,
        pay_object_groups      pay_pos
 where  pay_pac.payroll_action_id    = :payroll_action_id
 and    pay_pos.source_type      = ''PPF''
 and    exists (select ''''
                  from pay_retro_assignments  pay_ret_asg,
                       per_all_assignments_f  pay_asg2,
                       pay_object_groups      pay_pog_asg2
                 where pay_pog_asg2.parent_object_group_id = pay_pos.object_group_id
                   and pay_pog_asg2.source_type = ''PAF''
                   and pay_asg2.assignment_id = pay_pog_asg2.source_id
                   and pay_asg2.payroll_id + 0 = pay_pac.payroll_id
                   and pay_ret_asg.assignment_id = pay_asg2.assignment_id
                   and pay_ret_asg.retro_assignment_action_id IS NULL
		   and pay_ret_asg.superseding_retro_asg_id IS NULL                 --  7364151
                   and pay_ret_asg.approval_status <> ''D''
                   and pay_pac.effective_date between pay_asg2.effective_start_date
                                                  and pay_asg2.effective_end_date
               )';
--
 -- Reversal amendments
 -- check for existence of a process that can be reversed as of reversal
 -- run date and that the action has not been previously reversed
 revaa :=
  '
   and not exists
   (select 1
    from pay_assignment_actions aa9
    where aa9.source_action_id =  pay_paa2.assignment_action_id)
   /* check havent done reversal before */
   and not exists
      (select 1
       from  pay_action_interlocks int,
             pay_assignment_actions aa9,
             pay_payroll_actions pay_ppa2
       where int.locked_action_id = pay_paa2.assignment_action_id
        and   aa9.assignment_action_id = int.locking_action_id
        and   pay_ppa2.payroll_action_id = aa9.payroll_action_id
        and   pay_ppa2.action_type = ''V'')';

   orgfrom := '
 from
        pay_payroll_actions         pay_pac,
        hr_organization_units       hou,
        hr_organization_information hoi
 where  pay_pac.payroll_action_id    = pay_proc_environment_pkg.get_pactid()
 and    hou.business_group_id        = pay_pac.business_group_id
 and    hoi.organization_id          = hou.organization_id
 and    hoi.org_information_context = ''CLASS''
 and    hoi.org_information1 = ''HR_PAYEE''';
--
   orgbind := '
and pay_pac.payroll_action_id    = :payroll_action_id';
--
   -- order by clause.
   orderby := '
   order by pay_pos.person_id';
--
   orgorderby := '
   order by 1, 3 , 2';
--
   -- order by clause for BEE.
   borderby := '
   order by pay_asg.person_id';
--
   -- Run order by
   actorderby := '
   order by pay_asg.person_id, decode(pay_asg.primary_flag, ''Y'', 1, 2), pay_asg.assignment_id';
--   actorderby := '
--   order by pay_asg.person_id';
--
   -- for update clause to lock assignment and period of service.
   fupdate := '
   for update of pay_asg.assignment_id, pay_pos.period_of_service_id';
--
end hr_dynsql;

/
