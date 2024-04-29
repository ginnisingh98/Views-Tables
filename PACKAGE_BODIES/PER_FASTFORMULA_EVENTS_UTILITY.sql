--------------------------------------------------------
--  DDL for Package Body PER_FASTFORMULA_EVENTS_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FASTFORMULA_EVENTS_UTILITY" as
/* $Header: perffevt.pkb 120.1 2005/06/06 04:36:38 ssmukher noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< per_fastformula_event >-------------------------|
-- ----------------------------------------------------------------------------
--
   function per_fastformula_event(p_event_type        in varchar2,
                                  p_formula_type      in varchar2,
                                  p_business_group_id in number,
                                  p_person_id         in number,
                                  p_start_date        in date,
                                  p_end_date          in date)
   return number is
   --
   l_inputs    ff_exec.inputs_t;
   l_outputs   ff_exec.outputs_t;
   l_number number := 0;
   l_formula_id number := 0;
   l_formula_type_id number := 0;
   l_start_date date := null;
   --
   -- cursors used for promotion event
   --
   cursor csr_get_emp_asgs is
      select paaf.effective_start_date,
             paaf.assignment_id
        from per_all_assignments_f paaf,
             per_assignment_status_types past
       where paaf.person_id = p_person_id
         and paaf.assignment_type = 'E'
          -- bug 2975652 only want to count active assignments
         and paaf.assignment_status_type_id = past.assignment_status_type_id
         and past.per_system_status = 'ACTIVE_ASSIGN'
         and paaf.effective_start_date
             between p_start_date
             and     p_end_date
             order by paaf.effective_start_date;
   --
   l_csr_get_emp_asgs_rec csr_get_emp_asgs%rowtype;
   l_counter number := 0;
   --
   begin
   --
   hr_utility.set_location('In',10);
   --
   /* seeded formula promotion template is commented out and always returns 0
   return 0 here - no need to call formula */
   if p_event_type = 'PROMOTION_TEMPLATE'
   then
      l_counter := 0;
   else
   -- select formula id for event type (fast formula name)
   -- check formula exists at the start date entered.
   --
   l_formula_id := get_formula_id (p_event_type,
                                   p_formula_type,
                                   p_business_group_id,
                                   p_start_date);
   if l_formula_id = 0  -- if there is no fast formula : bug 3540677
   then
      return 0;
   else
   --
   ff_exec.init_formula
    (p_formula_id     => l_formula_id,
     p_effective_date => p_start_date,
     p_inputs         => l_inputs,
     p_outputs        => l_outputs);
   --
   if p_event_type = 'PROMOTION'
   then
      l_counter := 0;
      --
      open csr_get_emp_asgs;
      --
         loop
         --
            hr_utility.set_location('In Loop',10);
            --
            fetch csr_get_emp_asgs into l_csr_get_emp_asgs_rec;
            hr_utility.set_location('fetching into l_csr_get_emp_asgs_rec',15);
            if csr_get_emp_asgs%rowcount < 1
            then
               l_counter := 0;
               fnd_message.set_name('PER','PER_289770_PERSON_NOT_FOUND');
               fnd_message.set_token
               ('PROC','per_fastformula_events_utility.per_fastformula_event');
               hr_utility.set_location
               ('person not found or no updates to assignment record between '||
                'dates ',18);
               -- fnd_message.raise_error;
            end if;
            exit when csr_get_emp_asgs%notfound;
            --
            l_number := 0;
            /*
            dt_fndate.change_ses_date
               (p_ses_date => l_csr_get_emp_asgs_rec.effective_start_date
               ,p_commit   => l_number);
            hr_utility.set_location('l_number '||TO_CHAR(l_number),20);
            */
            hr_utility.set_location('ses date '
            ||l_csr_get_emp_asgs_rec.effective_start_date,22);
            --
            for l_count in nvl(l_inputs.first,0)..nvl(l_inputs.last,-1)
            loop
               if l_inputs(l_count).name = 'ASSIGNMENT_ID'
               then
                  --
                  l_inputs(l_count).value :=
                  l_csr_get_emp_asgs_rec.assignment_id;
                  hr_utility.set_location('asg_id  '||
                  l_csr_get_emp_asgs_rec.assignment_id,25);
                  --
               elsif l_inputs(l_count).name = 'DATE_EARNED'
               then
                  l_inputs(l_count).value :=
                  to_char(trunc(l_csr_get_emp_asgs_rec.effective_start_date),
                  'YYYY/MM/DD');
                  hr_utility.set_location('date_earned '
                  ||l_csr_get_emp_asgs_rec.effective_start_date,30);
               end if;
               --
            end loop;
            --
            ff_exec.run_formula(p_inputs  => l_inputs,
                                p_outputs => l_outputs);
            --
            if l_outputs(1).value <> 0
            then
               l_counter := l_counter + l_outputs(1).value;
               hr_utility.set_location('promotions returned: '||l_counter,35);
            end if;
            hr_utility.set_location('Out Loop',40);
         end loop;
      --
      close csr_get_emp_asgs;
      --
   end if;
   end if; -- if formula_id = 0 ie if there is no fast formula : bug 3540677
   end if; -- if promotion template
   --
   return l_counter;
   --
   end  per_fastformula_event;
--
-- ----------------------------------------------------------------------------
-- |------------------------< per_fastformula_event >-------------------------|
-- ----------------------------------------------------------------------------
--
--  overloaded module to run for one date
--
   function per_fastformula_event(p_event_type        in varchar2,
                                  p_formula_type      in varchar2,
                                  p_business_group_id in number,
                                  p_person_id         in number,
                                  p_effective_date    in date)
   return number is
   --
   l_inputs    ff_exec.inputs_t;
   l_outputs   ff_exec.outputs_t;
   l_number number := 0;
   l_formula_id number := 0;
   --
   -- cursors used for promotion event
   --
   cursor csr_get_emp_asgs_snapshot is
      select effective_start_date,
             assignment_id
        from per_all_assignments_f
       where person_id = p_person_id
         and assignment_type = 'E'
         and p_effective_date
             between effective_start_date
             and     effective_end_date
             order by effective_start_date;
   --
   l_csr_get_emp_asgs_snapshot csr_get_emp_asgs_snapshot%rowtype;
   l_counter number := 0;
   --
   begin
   --
   hr_utility.set_location('In',10);
   if p_event_type = 'PROMOTION_TEMPLATE'
   then
      l_counter := 0;
   else
   --
   -- select formula id for event type (fast formula name)
   -- check formula exists at the start date entered.
   --
   l_formula_id := get_formula_id (p_event_type,
                                   p_formula_type,
                                   p_business_group_id,
                                   p_effective_date);
   if l_formula_id = 0 -- if there is no fast formula : bug 3540677
   then
      return 0;
   else
   --
   ff_exec.init_formula
    (p_formula_id     => l_formula_id,
     p_effective_date => p_effective_date,
     p_inputs         => l_inputs,
     p_outputs        => l_outputs);
   --
   if p_event_type = 'PROMOTION'
   then
      --
      open csr_get_emp_asgs_snapshot;
      --
         loop
         --
            hr_utility.set_location('In Loop',10);
            --
            fetch csr_get_emp_asgs_snapshot into
            l_csr_get_emp_asgs_snapshot;
            hr_utility.set_location('fetching into l_csr_get_emp_asgs_rec',15);
            if csr_get_emp_asgs_snapshot%rowcount < 1
            then
               l_counter := 0;
               fnd_message.set_name('PER','PER_289770_PERSON_NOT_FOUND');
               fnd_message.set_token
               ('PROC','per_fastformula_events_utility.per_fastformula_event');
               -- fnd_message.raise_error;
            end if;
            exit when csr_get_emp_asgs_snapshot%notfound;
            --
            l_number := 0;
            /*
            dt_fndate.change_ses_date
               (p_ses_date =>
                l_csr_get_emp_asgs_snapshot.effective_start_date
               ,p_commit   => l_number);
            hr_utility.set_location('l_number '||TO_CHAR(l_number),20);
            */
            hr_utility.set_location('ses date '
            ||l_csr_get_emp_asgs_snapshot.effective_start_date,20);
            --
            for l_count in nvl(l_inputs.first,0)..nvl(l_inputs.last,-1)
            loop
               if l_inputs(l_count).name = 'ASSIGNMENT_ID'
               then
                  --
                  l_inputs(l_count).value :=
                  l_csr_get_emp_asgs_snapshot.assignment_id;
                  hr_utility.set_location('asg_id  '||
                  l_csr_get_emp_asgs_snapshot.assignment_id,25);
                  --
               elsif l_inputs(l_count).name = 'DATE_EARNED'
               then
                  l_inputs(l_count).value :=
                  to_char(trunc
                  (l_csr_get_emp_asgs_snapshot.effective_start_date),
                  'YYYY/MM/DD');
                  hr_utility.set_location('date_earned '
                  ||l_csr_get_emp_asgs_snapshot.effective_start_date,30);
               end if;
               --
            end loop;
            --
            ff_exec.run_formula(p_inputs  => l_inputs,
                                p_outputs => l_outputs);
            --
            if l_outputs(1).value <> 0
            then
               l_counter := l_counter + l_outputs(1).value;
               hr_utility.set_location('promotions returned: '||l_counter,35);
            end if;
            hr_utility.set_location('Out Loop',40);
         end loop;
      --
      close csr_get_emp_asgs_snapshot;
      --
   end if;
   end if; -- if no fast formula ie if formula_id = 0 - bug 3540677
   end if; -- if event type = promotion_template
   --
   return l_counter;
   --
   end  per_fastformula_event;
--


-- ----------------------------------------------------------------------------
-- | --------------- Added by ssmukher for Employment Equity report  ---------|
-----------------------< Overloaded function for fetching the dates -----------
-- |------------------------< per_fastformula_event >-------------------------|
-- ----------------------------------------------------------------------------
--
   function per_fastformula_event(p_event_type        in varchar2,
                                  p_formula_type      in varchar2,
                                  p_business_group_id in number,
                                  p_person_id         in number,
                                  p_start_date        in date,
                                  p_end_date          in date,
                                  p_date_tab          out nocopy  date_tab) -- Added by ssmukher
   return number is
   --
   l_inputs    ff_exec.inputs_t;
   l_outputs   ff_exec.outputs_t;
   l_formula_id number ;
   l_formula_type_id number;
   l_start_date date ;
   l_cnt  number; /* Added by ssmukher for employment equity report */
   --
   -- cursors used for promotion event
   --
   cursor csr_get_emp_asgs is
      select paaf.effective_start_date,
             paaf.assignment_id
        from per_all_assignments_f paaf,
             per_assignment_status_types past
       where paaf.person_id = p_person_id
         and paaf.assignment_type = 'E'
          -- bug 2975652 only want to count active assignments
         and paaf.assignment_status_type_id = past.assignment_status_type_id
         and past.per_system_status = 'ACTIVE_ASSIGN'
         and paaf.effective_start_date
             between p_start_date
             and     p_end_date
             order by paaf.effective_start_date;
   --
   l_csr_get_emp_asgs_rec csr_get_emp_asgs%rowtype;
   l_counter number ;
   --
   begin
     l_formula_id := 0;
     l_start_date := null;
     l_formula_type_id := 0;
     l_counter := 0;
   --
   --hr_utility.trace_on(null,'EQUPIPE');
   hr_utility.set_location('In',10);
/* Deleting the PL/SQL table contents Added by ssmukher */
   p_date_tab.delete;
   --
   /* seeded formula promotion template is commented out and always returns 0
   return 0 here - no need to call formula */
   if p_event_type = 'PROMOTION_TEMPLATE'
   then
      l_counter := 0;
   else
   -- select formula id for event type (fast formula name)
   -- check formula exists at the start date entered.
   --
   l_formula_id := get_formula_id (p_event_type,
                                   p_formula_type,
                                   p_business_group_id,
                                   p_start_date);
   if l_formula_id = 0  -- if there is no fast formula : bug 3540677
   then
      return 0;
   else
   --
   ff_exec.init_formula
    (p_formula_id     => l_formula_id,
     p_effective_date => p_start_date,
     p_inputs         => l_inputs,
     p_outputs        => l_outputs);
   --
   if p_event_type = 'PROMOTION'
   then
      l_counter := 0;
/* Added by ssmukher for Employment Equity report */
      l_cnt := 0;
      --
      open csr_get_emp_asgs;
      --
         loop
         --
            hr_utility.set_location('In Loop',10);
            --
            fetch csr_get_emp_asgs into l_csr_get_emp_asgs_rec;
            hr_utility.set_location('fetching into l_csr_get_emp_asgs_rec',15);
            if csr_get_emp_asgs%rowcount < 1
            then
               l_counter := 0;
               fnd_message.set_name('PER','PER_289770_PERSON_NOT_FOUND');
               fnd_message.set_token
               ('PROC','per_fastformula_events_utility.per_fastformula_event');
               hr_utility.set_location
               ('person not found or no updates to assignment record between '||
                'dates ',18);
               -- fnd_message.raise_error;
            end if;
            exit when csr_get_emp_asgs%notfound;
            --
            hr_utility.set_location('ses date '
            ||l_csr_get_emp_asgs_rec.effective_start_date,22);
            --
            for l_count in nvl(l_inputs.first,0)..nvl(l_inputs.last,-1)
            loop
               if l_inputs(l_count).name = 'ASSIGNMENT_ID'
               then
                  --
                  l_inputs(l_count).value :=
                  l_csr_get_emp_asgs_rec.assignment_id;
                  hr_utility.set_location('asg_id  '||
                  l_csr_get_emp_asgs_rec.assignment_id,25);
                  --
               elsif l_inputs(l_count).name = 'DATE_EARNED'
               then
                  l_inputs(l_count).value :=
                  to_char(trunc(l_csr_get_emp_asgs_rec.effective_start_date),
                  'YYYY/MM/DD');
                  hr_utility.set_location('date_earned '
                  ||l_csr_get_emp_asgs_rec.effective_start_date,30);
               end if;
               --
            end loop;
            --
            ff_exec.run_formula(p_inputs  => l_inputs,
                                p_outputs => l_outputs);
            --
            if l_outputs(1).value <> 0
            then
               l_counter := l_counter + l_outputs(1).value;
               hr_utility.set_location('promotions returned: '||l_counter,35);
               /* Added by ssmukher for Employment Equity report */
               l_cnt := l_cnt + 1;
               p_date_tab(l_cnt) := l_csr_get_emp_asgs_rec.effective_start_date;
            end if;
            hr_utility.set_location('Out Loop',40);
         end loop;
      --
      close csr_get_emp_asgs;
      --
   end if;
   end if; -- if formula_id = 0 ie if there is no fast formula : bug 3540677
   end if; -- if promotion template
   --
   return l_counter;
   --
   end  per_fastformula_event;
-- ----------------------------------------------------------------------------
-- |----------------------------< get_formula_id >----------------------------|
-- ----------------------------------------------------------------------------
--
   function get_formula_id (p_event_type        in varchar2,
                            p_formula_type      in varchar2,
                            p_business_group_id in number,
                            p_effective_date    in date)
   return number
   is
   l_formula_id number := 0;
   --
   cursor csr_get_bg_formula_id is
      select fff.formula_id
        from ff_formulas_f fff
             ,ff_formula_types fft
       where fff.formula_name = p_event_type
         and fff.formula_type_id = fft.formula_type_id
         and fft.formula_type_name = p_formula_type
         and fff.business_group_id = p_business_group_id
         and p_effective_date
             between fff.effective_start_date
             and     fff.effective_end_date;
   --
   cursor csr_get_global_formula_id is
      select fff.formula_id
        from ff_formulas_f fff
             ,ff_formula_types fft
       where fff.formula_name = 'PROMOTION_TEMPLATE'
         and fff.formula_type_id = fft.formula_type_id
         and fft.formula_type_name = p_formula_type
         and fff.business_group_id is null
         and p_effective_date
             between fff.effective_start_date
             and     fff.effective_end_date;
   --
   l_csr_formula_id number := 0;
   --
   begin
   --
   open csr_get_bg_formula_id;
   loop
      fetch csr_get_bg_formula_id into
      l_csr_formula_id;
      exit when csr_get_bg_formula_id%found;
      if csr_get_bg_formula_id%notfound
      then
         fnd_message.set_name('PER','PER_289772_FORMULA_NOT_FOUND');
         fnd_message.set_token
         --
         ('PROC','per_fastformula_events_utility.get_formula_id');
         hr_utility.set_location('no formula for this business group '
         ||p_business_group_id,44);
         --
         l_csr_formula_id := 0;  -- bug 3540677
         return 0;
         --
         -- fnd_message.raise_error;  Bug 3540677  do not raise error if no
         -- fast formula
         --
         -- below commented out as currently PROMOTION_TEMPLATE
         -- is commented out, cannot be altered and always returns 0
         -- therefore below never needs to be processed
         -- however it will be needed if promotion_template is ever
         -- delivered uncommented
/*         open csr_get_global_formula_id;
         loop
            fetch csr_get_global_formula_id into
            l_csr_formula_id;
            if csr_get_global_formula_id%rowcount < 1
            then
               return 0;
               hr_utility.set_location
               ('you might be stuck here if promo_template has no text '
               ||l_formula_id,44);
               fnd_message.set_name('PER','PER_289772_FORMULA_NOT_FOUND');
               fnd_message.set_token
               ('PROC','per_fastformula_events_utility.get_formula_id');
               fnd_message.raise_error;
               hr_utility.set_location('l_formula_id '||l_formula_id,45);
               hr_utility.set_location('p_business_group_id '
               ||p_business_group_id,46);
            end if;
            exit when csr_get_global_formula_id%notfound;
         end loop;
         close csr_get_global_formula_id;  */
      end if;
   end loop;
   close csr_get_bg_formula_id;
   l_formula_id := l_csr_formula_id;
   --
   return l_formula_id;
   end get_formula_id;
   --
end per_fastformula_events_utility;

/
