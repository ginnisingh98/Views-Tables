--------------------------------------------------------
--  DDL for Package Body PAY_RUN_RESULT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RUN_RESULT_PKG" as
/* $Header: pycorrrp.pkb 120.4.12010000.1 2008/07/27 22:23:27 appldev ship $ */
--
/*
   Name
      get_result_value
   Description

      This function is used to retrieve the run result value in
      a sparse matrix solution.
*/
function get_result_value(p_run_result_id     in number,
                          p_input_value_id    in number,
                          p_iv_name           in varchar2,
                          p_jurisdiction_code in varchar2,
                          p_business_group_id in number
                         ) return varchar2
is
--
l_result_value     pay_run_result_values.result_value%type;
l_legislation_code per_business_groups.legislation_code%type;
l_inp_val_name     pay_input_values_f.name%type;
l_found            boolean;
--
begin
  begin
--
    select result_value
      into l_result_value
      from pay_run_result_values
     where run_result_id = p_run_result_id
       and input_value_id = p_input_value_id;
--
    return l_result_value;
--
  exception
--
    when no_data_found then
--
      /* No Data Found then the value is either null or we
         need to return the jurisdiction code
      */
      if (p_jurisdiction_code is null) then
        return null;
      else
--
         select legislation_code
           into l_legislation_code
           from per_business_groups
          where business_group_id = p_business_group_id;
--
         pay_core_utils.get_leg_context_iv_name('JURISDICTION_CODE',
                                 l_legislation_code,
                                 l_inp_val_name,
                                 l_found
                                );
--
         if (l_found = FALSE) then
           l_inp_val_name := 'Jurisdiction';
         end if;
--
         if (l_inp_val_name = p_iv_name) then
           return p_jurisdiction_code;
         else
           return null;
         end if;
--
      end if;
--
  end;
end get_result_value;
--
/*
   Name
      create_run_result
   Description

      This procedure creates the run result for an element entry.
*/
procedure create_run_result(p_element_entry_id  in            number,
                            p_session_date      in            date,
                            p_business_group_id in            number,
                            p_jc_name           in            varchar2,
                            p_rr_sparse         in            boolean,
                            p_rr_sparse_jc      in            boolean,
                            p_asg_action_id     in            number default null,
                            p_run_result_id        out nocopy number
                           )
is
--
   cursor get_b_eevs(p_element_entry_id number,
                     p_session_date     date ) is
   select peev.input_value_id,
          piv.uom,
          peev.screen_entry_value value,
          peev.element_entry_value_id
   from   pay_input_values_f piv,
          pay_element_entry_values_f peev
   where  peev.element_entry_id = p_element_entry_id
   and    piv.input_value_id = peev.input_value_id
   and    p_session_date between peev.effective_start_date
                             and peev.effective_end_date
   and    p_session_date between piv.effective_start_date
                             and piv.effective_end_date;
--
l_jurisdiction_code    pay_run_results.jurisdiction_code%type;
l_assignment_id        per_assignments_f.assignment_id%type;
l_element_type_id      pay_element_types_f.element_type_id%type;
l_entry_type           pay_element_entries_f.entry_type%type;
l_input_currency_code  pay_element_types_f.input_currency_code%type;
l_output_currency_code pay_element_types_f.output_currency_code%type;
l_run_result_id        pay_run_results.run_result_id%type;
l_amount               pay_run_result_values.result_value%type;
l_rr_status            pay_run_results.status%type;
l_jurisdiction_eev_id  pay_element_entry_values_f.element_entry_value_id%type;
l_original_entry_id    number;
l_rr_source_id         number;
l_currency_type        varchar2(30);
l_rr_sparse            varchar2(10);
l_local_unit_id        number;
save_value             boolean;
l_time_definition_type pay_element_types_f.time_definition_type%type;
l_time_definition_id   pay_run_results.time_definition_id%type;
l_s_time_definition_id pay_run_results.time_definition_id%type;
l_time_def_start_date  per_time_periods.start_date%type;
l_time_def_end_date  per_time_periods.end_date%type;
begin
--
   /* Make sure the entry exists first
   */
   begin
--
     select ee.assignment_id,
            et.element_type_id,
            ee.entry_type,
            ee.original_entry_id,
            et.input_currency_code,
            et.output_currency_code,
            pay_run_results_s.nextval,
            hr_dynsql.get_local_unit(ee.assignment_id,
                                     p_session_date),
            et.time_definition_type,
            et.time_definition_id
     into   l_assignment_id,
            l_element_type_id,
            l_entry_type,
            l_original_entry_id,
            l_input_currency_code,
            l_output_currency_code,
            l_run_result_id,
            l_local_unit_id,
            l_time_definition_type,
            l_s_time_definition_id
     from   pay_element_entries_f ee,
            pay_element_types_f et
     where  ee.element_entry_id = p_element_entry_id
       and  et.element_type_id  = ee.element_type_id
       and  p_session_date between ee.effective_start_date
                               and ee.effective_end_date
       and  p_session_date between et.effective_start_date
                               and et.effective_end_date;
--
   exception
     when NO_DATA_FOUND then
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                        'pay_run_result_pkg.create_run_result');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
   end;
--
   if (p_asg_action_id is null) then
      l_rr_status := 'U';
   else
      l_rr_status := 'P';
   end if;

   -- First get the Jurisdiction if one exists.
   begin
     select eev.screen_entry_value,
            eev.element_entry_value_id
       into l_jurisdiction_code,
            l_jurisdiction_eev_id
       from pay_element_entry_values_f eev,
            pay_input_values_f         piv,
            pay_element_entries_f      pee
       where pee.element_entry_id = p_element_entry_id
       and   eev.element_entry_id = pee.element_entry_id
       and   eev.input_value_id   = piv.input_value_id
       and   piv.name             = p_jc_name
       and   p_session_date between pee.effective_start_date
                                and pee.effective_end_date
       and   p_session_date between eev.effective_start_date
                                and eev.effective_end_date
       and   p_session_date between piv.effective_start_date
                                and piv.effective_end_date;
   exception
        when no_data_found then
           l_jurisdiction_code := null;
           l_jurisdiction_eev_id := -1;
   end;

   --
   -- Set the run result source_id.
   --
   l_rr_source_id := p_element_entry_id;
   --
   -- #3482270. original entry support for adjustments.
   --
   if l_entry_type = 'B' then
      l_rr_source_id := nvl(l_original_entry_id, p_element_entry_id);
   end if;

   --
   -- #4482023. Time Definition has to be stamped on run results
   -- for Balance Adjustment and Balance Initializations.
   --

   if l_entry_type = 'B' then

      if l_time_definition_type = 'G' then

           pay_core_utils.get_time_definition
                ( p_element_entry   => p_element_entry_id,
                  p_asg_act_id      => p_asg_action_id,
                  p_time_def_id     => l_time_definition_id );

      elsif l_time_definition_type = 'S' then

           l_time_definition_id := l_s_time_definition_id;

      end if;

      if l_time_definition_id is not null then

        --
        -- #5066120. Set start and end dates to effective date of
        -- the Balance Adjustment / Balance Initialization.
        l_time_def_start_date := p_session_date;
        l_time_def_end_date := p_session_date;

      end if;

   end if;


   begin
--
     insert into pay_run_results
     (run_result_id,
      element_type_id,
      assignment_action_id,
      entry_type,
      source_id,
      source_type,
      status,
      jurisdiction_code,
      element_entry_id,
      local_unit_id,
      time_definition_id,
      start_date,
      end_date)
     values
     (l_run_result_id,
      l_element_type_id,
      p_asg_action_id,
      l_entry_type,
      l_rr_source_id,
      'E',
      l_rr_status,
      l_jurisdiction_code,
      p_element_entry_id,
      l_local_unit_id,
      l_time_definition_id,
      l_time_def_start_date,
      l_time_def_end_date);
--
   exception
     when NO_DATA_FOUND then
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                                    'pay_run_result_pkg.create_run_result');
       hr_utility.set_message_token('STEP','2');
       hr_utility.raise_error;
   end;

--
   if (l_entry_type = 'B' and
       l_input_currency_code <> l_output_currency_code) then
--
     -- insert run results values converting all money uom's to the output
     -- currency value.
--
     l_currency_type:=hr_currency_pkg.get_rate_type
                                       (p_business_group_id,
                                        p_session_date,
                                        'P');
     if (l_currency_type is NULL)
     then
       hr_utility.set_message(801,'HR_52349_NO_RATE_TYPE');
       hr_utility.raise_error;
     end if;
   end if;
--
   begin

     for peev in get_b_eevs(p_element_entry_id, p_session_date) loop

        if (peev.uom='M'
            and (l_entry_type = 'B' and
                 l_input_currency_code <> l_output_currency_code))
        then
         begin
         l_amount:=fnd_number.number_to_canonical(
               hr_currency_pkg.convert_amount(l_input_currency_code,
                                              l_output_currency_code,
                                              p_session_date,
                                              peev.value,
                                              l_currency_type));
         exception
          when gl_currency_api.NO_RATE then
            hr_utility.set_message(801,'HR_6405_PAYM_NO_EXCHANGE_RATE');
            hr_utility.set_message_token('RATE1', l_input_currency_code);
            hr_utility.set_message_token('RATE2', l_output_currency_code);
            hr_utility.raise_error;
          when gl_currency_api.INVALID_CURRENCY then
            hr_utility.set_message(801,'HR_52350_INVALID_CURRENCY');
            hr_utility.set_message_token('RATE1', l_input_currency_code);
            hr_utility.set_message_token('RATE2', l_output_currency_code);
            hr_utility.raise_error;
          end;
         else
             l_amount:=peev.value;
         end if;

         /* Work out whether we need to create
            the result
         */
         save_value := TRUE;
         if ( p_rr_sparse = TRUE) then
            if (l_jurisdiction_eev_id = peev.element_entry_value_id) then
              if (p_rr_sparse_jc = TRUE) then
                   save_value := FALSE;
              end if;
            else
              if (l_amount is null) then
                save_value := FALSE;
              end if;
            end if;
         end if;
--
         if (save_value = TRUE) then
--
          insert into pay_run_result_values
          (input_value_id,
           run_result_id,
           result_value,
           formula_result_flag)
          values
          (peev.input_value_id,
           l_run_result_id,
           l_amount,
           'N');
--
         end if;
       end loop;
--
   exception
     when no_data_found then
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                                 'pay_run_result_pkg.create_run_result');
       hr_utility.set_message_token('STEP','3');
       hr_utility.raise_error;
   end;

--
   p_run_result_id := l_run_result_id;
--
end create_run_result;
--
/*
   Name
      create_run_result
   Description

      This procedure creates the run result for an element type.
*/
procedure create_indirect_rr(p_element_type_id  in            number,
                             p_run_result_id    in            number,
                            p_session_date      in            date,
                            p_business_group_id in            number,
                            p_jc_name           in            varchar2,
                            p_rr_sparse         in            boolean,
                            p_rr_sparse_jc      in            boolean,
                            p_asg_action_id     in            number default null,
                            p_ind_run_result_id    out nocopy number
                           )
is
--
cursor get_iv (p_et_id number,
               p_effdate date)
is
select piv.input_value_id,
       piv.name
  from pay_input_values_f piv
 where piv.element_type_id = p_et_id
   and p_effdate between piv.effective_start_date
                     and piv.effective_end_date;
--
l_entry_type           pay_element_entries_f.entry_type%type;
l_run_result_id        pay_run_results.run_result_id%type;
l_entry_id             pay_run_results.source_id%type;
l_rr_status            pay_run_results.status%type;
l_local_unit_id        number;
save_value             boolean;
l_time_definition_id   pay_run_results.time_definition_id%type;
l_start_date           pay_run_results.start_date%type;
l_end_date             pay_run_results.end_date%type;
--
begin
   begin
--
     select prr.entry_type,
            prr.source_id,
            pay_run_results_s.nextval,
            local_unit_id,
            time_definition_id,
            start_date,
            end_date
       into l_entry_type,
            l_entry_id,
            l_run_result_id,
            l_local_unit_id,
            l_time_definition_id,
            l_start_date,
            l_end_date
       from pay_run_results prr
      where prr.run_result_id = p_run_result_id;
--
   exception
     when NO_DATA_FOUND then
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                        'pay_run_result_pkg.create_indirect_rr');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
   end;
--
   if (p_asg_action_id is null) then
      l_rr_status := 'U';
   else
      l_rr_status := 'P';
   end if;
--
   --
   -- #4482023. Time Definition has to be stamped on indirect run results
   -- when the parent results has the time definition.
   --

     insert into pay_run_results
     (run_result_id,
      element_type_id,
      assignment_action_id,
      entry_type,
      source_id,
      source_type,
      status,
      jurisdiction_code,
      element_entry_id,
      local_unit_id,
      time_definition_id,
      start_date,
      end_date)
     values
     (l_run_result_id,
      p_element_type_id,
      p_asg_action_id,
      l_entry_type,
      l_entry_id,
      'I',
      l_rr_status,
      null,
      null,
      l_local_unit_id,
      l_time_definition_id,
      l_start_date,
      l_end_date);
--
   for ivrec in get_iv(p_element_type_id,
                       p_session_date) loop
--
       /* Work out whether we need to create
          the result
       */
       save_value := TRUE;
       if ( p_rr_sparse = TRUE) then
          if (p_jc_name = ivrec.name) then
            if (p_rr_sparse_jc = TRUE) then
                 save_value := FALSE;
            end if;
          else
            save_value := FALSE;
          end if;
       end if;
--
       if (save_value = TRUE) then
--
        insert into pay_run_result_values
        (input_value_id,
         run_result_id,
         result_value,
         formula_result_flag)
        values
        (ivrec.input_value_id,
         l_run_result_id,
         null,
         'N');
       end if;
--
   end loop;
--
   p_ind_run_result_id := l_run_result_id;
--
end create_indirect_rr;
--
/*
   Name
      maintain_rr_value
   Description

      This procedure creates the run result value.
*/
procedure maintain_rr_value(p_run_result_id       in            number,
                                  p_session_date        in            date,
                                  p_input_value_id      in            number,
                                  p_value               in            varchar2,
                                  p_formula_result_flag in            varchar2,
                                  p_jc_name             in            varchar2,
                                  p_rr_sparse           in            boolean,
                                  p_rr_sparse_jc        in            boolean,
                                  p_mode                in            varchar2
                                )
is
--
l_iv_name pay_input_values_f.name%type;
save_value boolean;
--
begin
--
   select name
     into l_iv_name
     from pay_input_values_f
    where input_value_id = p_input_value_id
      and p_session_date between effective_start_date
                             and effective_end_date;
--
   /* Set the jurisdiction value on the RR if needed */
   if (l_iv_name = p_jc_name) then
--
     update pay_run_results
        set jurisdiction_code = p_value
      where run_result_id = p_run_result_id;
--
   end if;
--
   /* Work out whether we need to create
      the result
   */
   save_value := TRUE;
   if ( p_rr_sparse = TRUE) then
      if (l_iv_name = p_jc_name) then
        if (p_rr_sparse_jc = TRUE) then
             save_value := FALSE;
        end if;
      else
        if (p_value is null) then
          save_value := FALSE;
        end if;
      end if;
   end if;
--
   if (save_value = TRUE) then
--
    declare
      l_dummy number;
    begin
--
      select 1
        into l_dummy
        from pay_run_result_values
       where run_result_id = p_run_result_id
         and input_value_id = p_input_value_id;
--
      update pay_run_result_values
         set result_value = p_value,
             formula_result_flag = p_formula_result_flag
       where run_result_id = p_run_result_id
         and input_value_id = p_input_value_id;
--
    exception
       when no_data_found then
--
         insert into pay_run_result_values
         (input_value_id,
          run_result_id,
          result_value,
          formula_result_flag)
        values
         (p_input_value_id,
          p_run_result_id,
          p_value,
          p_formula_result_flag);
--
    end;

   end if;
--
end maintain_rr_value;
--
function create_run_result_direct
                         (p_element_type_id      in number,
                          p_assignment_action_id in number,
                          p_entry_type           in varchar2,
                          p_source_id            in number,
                          p_source_type          in varchar2,
                          p_status               in varchar2,
                          p_local_unit_id        in number,
                          p_start_date           in date,
                          p_end_date             in date,
                          p_element_entry_id     in number,
                          p_time_def_id          in number
                         )
return number
is
l_run_result_id number;
begin
--
     select pay_run_results_s.nextval
       into l_run_result_id
       from dual;
--
     insert into pay_run_results
     (run_result_id,
      element_type_id,
      assignment_action_id,
      entry_type,
      source_id,
      source_type,
      status,
      jurisdiction_code,
      element_entry_id,
      local_unit_id,
      time_definition_id,
      start_date,
      end_date)
     values
     (l_run_result_id,
      p_element_type_id,
      p_assignment_action_id,
      p_entry_type,
      p_source_id,
      p_source_type,
      p_status,
      null,
      p_element_entry_id,
      null,
      p_time_def_id,
      p_start_date,
      p_end_date);
--
     return l_run_result_id;
--
end create_run_result_direct;
--
end pay_run_result_pkg;

/
