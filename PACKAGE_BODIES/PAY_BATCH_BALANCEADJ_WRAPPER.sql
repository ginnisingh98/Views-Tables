--------------------------------------------------------
--  DDL for Package Body PAY_BATCH_BALANCEADJ_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BATCH_BALANCEADJ_WRAPPER" AS
/* $Header: paybbawebadi.pkb 120.16.12010000.2 2010/01/07 06:32:36 sivanara ship $ */

value_found    EXCEPTION;

FUNCTION get_costing_info
(
   l_concat_segments in varchar2,
   l_segment1   in varchar2 default null,
   l_segment2   in varchar2 default null,
   l_segment3   in varchar2 default null,
   l_segment4   in varchar2 default null,
   l_segment5   in varchar2 default null,
   l_segment6   in varchar2 default null,
   l_segment7   in varchar2 default null,
   l_segment8   in varchar2 default null,
   l_segment9   in varchar2 default null,
   l_segment10  in varchar2 default null,
   l_segment11  in varchar2 default null,
   l_segment12  in varchar2 default null,
   l_segment13  in varchar2 default null,
   l_segment14  in varchar2 default null,
   l_segment15  in varchar2 default null,
   l_segment16  in varchar2 default null,
   l_segment17  in varchar2 default null,
   l_segment18  in varchar2 default null,
   l_segment19  in varchar2 default null,
   l_segment20   in varchar2 default null,
   l_segment21   in varchar2 default null,
   l_segment22   in varchar2 default null,
   l_segment23   in varchar2 default null,
   l_segment24   in varchar2 default null,
   l_segment25   in varchar2 default null,
   l_segment26   in varchar2 default null,
   l_segment27   in varchar2 default null,
   l_segment28   in varchar2 default null,
   l_segment29   in varchar2 default null,
   l_segment30   in varchar2 default null
) return number is

l_ccid         number := -1;

Begin

    -- find the cost_allocation_keyflex_id

      l_ccid :=  hr_entry.maintain_cost_keyflex(
            p_cost_keyflex_structure     => g_flex_num,
            p_cost_allocation_keyflex_id => -1,
            p_concatenated_segments      => l_concat_segments,
            p_summary_flag               =>'N',
            p_start_date_active          => NULL,
            p_end_date_active            => NULL,
            p_segment1                   =>l_segment1,
            p_segment2                   =>l_segment2,
            p_segment3                   =>l_segment3,
            p_segment4                   =>l_segment4,
            p_segment5                   =>l_segment5,
            p_segment6                   =>l_segment6,
            p_segment7                   =>l_segment7,
            p_segment8                   =>l_segment8,
            p_segment9                   =>l_segment9,
            p_segment10                  =>l_segment10,
            p_segment11                  =>l_segment11,
            p_segment12                  =>l_segment12,
            p_segment13                  =>l_segment13,
            p_segment14                  =>l_segment14,
            p_segment15                  =>l_segment15,
            p_segment16                  =>l_segment16,
            p_segment17                  =>l_segment17,
            p_segment18                  =>l_segment18,
            p_segment19                  =>l_segment19,
            p_segment20                  =>l_segment20,
            p_segment21                  =>l_segment21,
            p_segment22                  =>l_segment22,
            p_segment23                  =>l_segment23,
            p_segment24                  =>l_segment24,
            p_segment25                  =>l_segment25,
            p_segment26                  =>l_segment26,
            p_segment27                  =>l_segment27,
            p_segment28                  =>l_segment28,
            p_segment29                  =>l_segment29,
            p_segment30                  =>l_segment30);

       hr_utility.trace('A4 CKF call p_cost_allocation_keyflex is : '|| l_ccid);

       return(l_ccid);

end get_costing_info;


PROCEDURE create_batch_header(p_batch_name        in varchar2,
                              p_business_group_id in number,
                              p_batch_reference   in varchar2 default null,
                              p_batch_source      in varchar2 default null,
                              p_batch_status      in varchar2 default 'U',
                              p_batch_id          out nocopy number ) is

l_bg_name      per_business_groups.name%TYPE;
l_batch_name   pay_balance_batch_headers.batch_name%TYPE := null;

l_new_header_id    number;

Begin

     hr_utility.trace('p_batch_name' || p_batch_name);
     hr_utility.trace('p_business_group_id' || p_business_group_id);
     hr_utility.trace('p_batch_reference' || p_batch_reference);
     hr_utility.trace('p_batch_source' || p_batch_source);
     hr_utility.trace('p_batch_status' || p_batch_status);
     hr_utility.trace('p_batch_id' || p_batch_id);

    -- hr_utility.trace_on(null,'webadi');
     select name into l_bg_name
     from per_business_groups
     where business_group_id = p_business_group_id;


     hr_utility.trace('l_batch_name, before selecting' || l_batch_name);
     select batch_name into l_batch_name
     from pay_balance_batch_headers
     where upper(batch_name) = upper(p_batch_name)
     and business_group_id = p_business_group_id;

     hr_utility.trace('l_batch_name, after selecting' || l_batch_name);

     if l_batch_name is not null then

        hr_utility.trace('l_batch_name, exception:' || l_batch_name);

        raise value_found;

     end if;

     EXCEPTION

      when value_found then

        hr_utility.trace('exception: value_found');

        hr_utility.trace('Please enter a unique name for Batch Name parameter');
        hr_utility.set_message('PAY','Please enter a unique name for Batch Name parameter');
       -- Bug: 5079557
        hr_utility.raise_error;

      --  return;

      when no_data_found then

        hr_utility.trace('exception: no data found');

         --select max(batch_id) into p_batch_id
         select pay_batch_headers_s.nextval  into p_batch_id
         from dual;

         -- create batch header

         insert into pay_balance_batch_headers
              (batch_id,
               batch_name,
               business_group_id,
               batch_status,
               batch_reference,
               batch_source,
               business_group_name,
               payroll_id,
               payroll_name,
               upload_date,
               batch_type)
         values (p_batch_id, --pay_balance_batch_headers_s.nextval,
                 p_batch_name,
                 p_business_group_id,
                 'U', -- Unprocessed
                 p_batch_reference,
                 p_batch_source,
                 l_bg_name,
                 null,
                 null,
                 sysdate,
                 'A');

end create_batch_header;


PROCEDURE update_batch_header(
                 p_batch_id          in number,
                 p_batch_name        in varchar2 default hr_api.g_varchar2,
                 p_batch_reference   in varchar2 default hr_api.g_varchar2,
                 p_batch_source      in varchar2 default hr_api.g_varchar2,
                 p_batch_status      in varchar2 default hr_api.g_varchar2) is

l_batch_status    pay_balance_batch_headers.batch_status%TYPE;
l_bg_name        per_business_groups.name%TYPE;
l_batch_name     pay_balance_batch_headers.batch_name%TYPE := null;


Begin

      --hr_utility.trace_on(null,'ram');
      -- Bug: 5171907
      hr_utility.trace('p_batch_id: ' || p_batch_id);
      hr_utility.trace('p_batch_name: ' || p_batch_name);
      hr_utility.trace('p_batch_reference: ' || p_batch_reference);
      hr_utility.trace('p_batch_source: ' || p_batch_source);
      hr_utility.trace('p_batch_status: ' || p_batch_status);

      -- Bug: 5226336

      SELECT batch_status, business_group_name
      INTO l_batch_status, l_bg_name
      FROM pay_balance_batch_headers
      WHERE batch_id = p_batch_id;

      hr_utility.trace('l_batch_status: ' || l_batch_status);
      hr_utility.trace('l_bg_name: ' || l_bg_name);

      SELECT batch_name
      INTO l_batch_name
      FROM pay_balance_batch_headers
      WHERE upper(batch_name) = upper(p_batch_name)
      AND business_group_name = l_bg_name;

      IF l_batch_name is not null THEN
	hr_utility.trace('l_batch_name, exception:' || l_batch_name);
	raise value_found;
      END IF;

      EXCEPTION

      WHEN value_found THEN

        hr_utility.trace('exception: value_found');
        hr_utility.trace('Please enter a unique name for Batch Name parameter');
        hr_utility.set_message('PAY','Please enter a unique name for Batch Name parameter');
        hr_utility.raise_error;

      WHEN others THEN
	BEGIN
		hr_utility.trace('exception: no data found');

		IF l_batch_status in ('L','T','C') THEN
			RAISE  value_found;
		ELSE
			BEGIN
				hr_utility.trace('updating  batch headers...');
				hr_utility.trace('p_batch_name: ' || p_batch_name);
				hr_utility.trace('p_batch_reference: ' || p_batch_reference);
				hr_utility.trace('p_batch_source: ' || p_batch_source);
				hr_utility.trace('p_batch_id: ' || p_batch_id);

				UPDATE pay_balance_batch_headers
				SET batch_name = p_batch_name,
				batch_reference = p_batch_reference,
				batch_source = p_batch_source
				WHERE batch_id = p_batch_id;

				hr_utility.trace('updating batch headers is done');

				EXCEPTION

				WHEN OTHERS THEN
					hr_utility.trace('Exception: unable to update pay_balance_batch_headers table.');
					hr_utility.raise_error;
			END;
		END IF;

		EXCEPTION

		WHEN value_found THEN
			hr_utility.trace('exception: value_found');
			hr_utility.raise_error;
	END;
end update_batch_header;


PROCEDURE update_batch_groups_lines(
          p_batch_id                in number,
          p_batch_name              in varchar2,
          p_batch_group_id          in number,   -- NEW
          p_batch_line_id           in number,   -- NEW
          p_effective_date          in date, -- effective date
          p_employee_id             in varchar2, -- Employee Name
          p_assignment_id           in varchar2, -- assignment_number
          p_element_name            in varchar2,
          p_element_type_id         in number,
          p_element_link_id         in number ,
          p_payroll_id              in number default null,
          p_business_group_id       in number,
          p_consolidation_set_id    in number default null,
          p_gre_id                  in number default null,
          p_prepay_flag             in varchar2 ,
          p_costing_flag            in varchar2 ,
          p_cost_allocation_keyflex in number default null,
          p_concatenated_segments   in varchar2 default null,
          segment1                in varchar2 default null,
          segment2                in varchar2 default null,
          segment3                in varchar2 default null,
          segment4                in varchar2 default null,
          segment5                in varchar2 default null,
          segment6                in varchar2 default null,
          segment7                in varchar2 default null,
          segment8                in varchar2 default null,
          segment9                in varchar2 default null,
          segment10               in varchar2 default null,
          segment11               in varchar2 default null,
          segment12               in varchar2 default null,
          segment13               in varchar2 default null,
          segment14               in varchar2 default null,
          segment15               in varchar2 default null,
          segment16               in varchar2 default null,
          segment17               in varchar2 default null,
          segment18               in varchar2 default null,
          segment19               in varchar2 default null,
          segment20               in varchar2 default null,
          segment21               in varchar2 default null,
          segment22               in varchar2 default null,
          segment23               in varchar2 default null,
          segment24               in varchar2 default null,
          segment25               in varchar2 default null,
          segment26               in varchar2 default null,
          segment27               in varchar2 default null,
          segment28               in varchar2 default null,
          segment29               in varchar2 default null,
          segment30               in varchar2 default null,
          p_ee_value1               in varchar2 default null,
          p_ee_value2               in varchar2 default null,
          p_ee_value3               in varchar2 default null,
          p_ee_value4               in varchar2 default null,
          p_ee_value5               in varchar2 default null,
          p_ee_value6               in varchar2 default null,
          p_ee_value7               in varchar2 default null,
          p_ee_value8               in varchar2 default null,
          p_ee_value9               in varchar2 default null,
          p_ee_value10              in varchar2 default null,
          p_ee_value11              in varchar2 default null,
          p_ee_value12              in varchar2 default null,
          p_ee_value13              in varchar2 default null,
          p_ee_value14              in varchar2 default null,
          p_ee_value15              in varchar2 default null,
          p_col1                    in number default null,
          p_col2                    in number default null,
          p_col3                    in number default null,
          p_col4                    in number default null,
          p_col5                    in number default null,
          p_col_val1                in varchar2 default null,
          p_col_val2                in varchar2 default null,
          p_col_val3                in varchar2 default null,
          p_col_val4                in varchar2 default null,
          p_col_val5                in varchar2 default null) IS

l_batch_group_status    pay_adjust_batch_groups.batch_group_status%TYPE;
l_batch_line_status     pay_adjust_batch_lines.batch_line_status%TYPE;

l_cakff_id              number;
l_batch_line_id         pay_adjust_batch_lines.batch_line_id%TYPE;

Begin


     --hr_utility.trace_on(null,'webadi');
     hr_utility.trace('p_batch_id  is : '|| p_batch_id );
     hr_utility.trace('p_batch_name  is : '|| p_batch_name );
     hr_utility.trace('p_batch_group_id  is : '|| p_batch_group_id );
     hr_utility.trace('p_batch_line_id  is : '|| p_batch_line_id );
     hr_utility.trace('p_effective_date  is : '|| p_effective_date );
     hr_utility.trace('p_employee_id is : '|| p_employee_id);
     hr_utility.trace('p_assignment_id  is : '|| p_assignment_id );
     hr_utility.trace('p_element_name  is : '|| p_element_name );
     hr_utility.trace('p_element_type_id  is : '||  p_element_type_id);
     hr_utility.trace('p_element_link_id  is : '|| p_element_link_id );
     hr_utility.trace('p_payroll_id  is : '|| p_payroll_id );
     hr_utility.trace('p_business_group_id  is : '|| p_business_group_id );
     hr_utility.trace('p_consolidation_set_id  is : '||  p_consolidation_set_id);
     hr_utility.trace('p_gre_id  is : '|| p_gre_id );
     hr_utility.trace('p_prepay_flag  is : '||p_prepay_flag  );
     hr_utility.trace('p_costing_flag  is : '|| p_costing_flag );
     hr_utility.trace('p_cost_allocation_keyflex is : '|| p_cost_allocation_keyflex );
     hr_utility.trace('p_concatenated_segments is : '|| p_concatenated_segments );
     hr_utility.trace('segment1  is : '|| segment1 );
     hr_utility.trace('segment2  is : '|| segment2 );
     hr_utility.trace('segment3  is : '|| segment3 );
     hr_utility.trace('segment4  is : '|| segment4 );
     hr_utility.trace('segment5  is : '|| segment5 );
     hr_utility.trace('segment6  is : '|| segment6 );
     hr_utility.trace('segment7  is : '|| segment7 );
     hr_utility.trace('segment8  is : '|| segment8 );
     hr_utility.trace('segment9  is : '|| segment9 );
     hr_utility.trace('segment10  is : '||segment10  );
     hr_utility.trace('segment11  is : '||segment11  );
     hr_utility.trace('segment12  is : '||segment12  );
     hr_utility.trace('segment13  is : '||segment13  );
     hr_utility.trace('segment14  is : '||segment14  );
     hr_utility.trace('segment15  is : '||segment15  );
     hr_utility.trace('segment16 is : '|| segment16);
     hr_utility.trace('segment17  is : '|| segment17 );
     hr_utility.trace('segment18  is : '|| segment18 );
     hr_utility.trace('segment19  is : '|| segment19 );
     hr_utility.trace('segment20  is : '|| segment20 );
     hr_utility.trace('segment21  is : '|| segment21 );
     hr_utility.trace('segment22  is : '|| segment22 );
     hr_utility.trace('segment23  is : '|| segment23 );
     hr_utility.trace('segment24  is : '|| segment24 );
     hr_utility.trace('segment25  is : '||segment25  );
     hr_utility.trace('segment26  is : '||segment26  );
     hr_utility.trace('segment27 cons is : '||segment27  );
     hr_utility.trace('segment28  is : '||segment28  );
     hr_utility.trace('segment29  is : '||segment29  );
     hr_utility.trace('segment30  is : '||segment30  );
     hr_utility.trace('p_ee_value1  is : '|| p_ee_value1 );
     hr_utility.trace('p_ee_value2  is : '|| p_ee_value2 );
     hr_utility.trace('p_ee_value3  is : '|| p_ee_value3 );
     hr_utility.trace('p_ee_value4  is : '|| p_ee_value4 );
     hr_utility.trace('p_ee_value5  is : '|| p_ee_value5 );
     hr_utility.trace('p_ee_value6  is : '|| p_ee_value6 );
     hr_utility.trace('p_ee_value7  is : '|| p_ee_value7 );
     hr_utility.trace('p_ee_value8  is : '|| p_ee_value8 );
     hr_utility.trace('p_ee_value9  is : '|| p_ee_value9 );
     hr_utility.trace('p_ee_value10  is : '||p_ee_value10  );
     hr_utility.trace('p_ee_value11  is : '||p_ee_value11  );
     hr_utility.trace('p_ee_value12  is : '||p_ee_value12  );
     hr_utility.trace('p_ee_value13  is : '||p_ee_value13  );
     hr_utility.trace('p_ee_value14  is : '||p_ee_value14  );
     hr_utility.trace('p_ee_value15  is : '||p_ee_value15  );
     hr_utility.trace('p_col1  is : '|| p_col1 );
     hr_utility.trace('p_col2  is : '|| p_col2 );
     hr_utility.trace('p_col3  is : '|| p_col3 );
     hr_utility.trace('p_col4  is : '|| p_col4 );
     hr_utility.trace('p_col5  is : '|| p_col5 );
     hr_utility.trace('p_col_val1  is : '|| p_col_val1 );
     hr_utility.trace('p_col_val2  is : '|| p_col_val2 );
     hr_utility.trace('p_col_val3  is : '|| p_col_val3 );
     hr_utility.trace('p_col_val4  is : '|| p_col_val4 );
     hr_utility.trace('p_col_val5  is : '|| p_col_val5 );

      select batch_group_status into l_batch_group_status
      from pay_adjust_batch_groups
      where batch_group_id = p_batch_group_id;

      if l_batch_group_status in ('L','T','C') then

         raise  value_found;

      else

         update pay_adjust_batch_groups
         set consolidation_set_id = p_consolidation_set_id,
             payroll_id           = p_payroll_id,
             effective_date       = p_effective_date,
             prepay_flag          = p_prepay_flag
         where batch_group_id = p_batch_group_id;

         /* here we can assume that the batch_line is also not in
            'L','T','C' status */

         if p_costing_flag = 'Y' then

             l_cakff_id := get_costing_info(p_concatenated_segments,
                   segment1,segment2,segment3,segment4,segment5,
                   segment6,segment7,segment8,segment9,segment10,
                   segment11,segment12,segment13,segment14,segment15,
                   segment16,segment17,segment18,segment19,segment20,
                   segment21,segment22,segment23,segment24,segment25,
                   segment26,segment27,segment28,segment29,segment30);

           end if;

           update pay_adjust_batch_lines
              set assignment_id = p_assignment_id,
                 tax_unit_id = p_gre_id,
                 entry_value1 = p_ee_value1,
                 entry_value2 = p_ee_value2,
                 entry_value3 = p_ee_value3,
                 entry_value4 = p_ee_value4,
                 entry_value5 = p_ee_value5,
                 entry_value6 = p_ee_value6,
                 entry_value7 = p_ee_value7,
                 entry_value8 = p_ee_value8,
                 entry_value9 = p_ee_value9,
                 entry_value10 = p_ee_value10,
                 entry_value11 = p_ee_value11,
                 entry_value12 = p_ee_value12,
                 entry_value13 = p_ee_value13,
                 entry_value14 = p_ee_value14,
                 entry_value15 = p_ee_value15,
                 balance_adj_cost_flag = p_costing_flag,
                 cost_allocation_keyflex_id = l_cakff_id
           where batch_line_id = l_batch_line_id;


      end if;


      exception when value_found then

        hr_utility.trace('Cannot update Batch Lines');
        return;

end update_batch_groups_lines;


PROCEDURE upload_data(
          p_batch_id                in number,
          p_batch_name              in varchar2,
          p_effective_date          in date,     -- effective date
          p_employee_id             in varchar2, -- Employee Name
          p_assignment_id           in varchar2, -- assignment_number
          p_element_name            in varchar2,
          p_element_type_id         in number,
          p_element_link_id         in number default null,
          p_payroll_id              in varchar2 default null, -- Payroll Name
          p_business_group_id       in number,
          p_consolidation_set_id    in number default null,
          p_gre_id                  in varchar2 default null, -- GRE Name
          p_prepay_flag             in varchar2,
          p_costing_flag            in varchar2,
          p_cost_allocation_keyflex in number default null,
          p_concatenated_segments   in varchar2 default null,
          segment1                in varchar2 default null,
          segment2                in varchar2 default null,
          segment3                in varchar2 default null,
          segment4                in varchar2 default null,
          segment5                in varchar2 default null,
          segment6                in varchar2 default null,
          segment7                in varchar2 default null,
          segment8                in varchar2 default null,
          segment9                in varchar2 default null,
          segment10               in varchar2 default null,
          segment11               in varchar2 default null,
          segment12               in varchar2 default null,
          segment13               in varchar2 default null,
          segment14               in varchar2 default null,
          segment15               in varchar2 default null,
          segment16               in varchar2 default null,
          segment17               in varchar2 default null,
          segment18               in varchar2 default null,
          segment19               in varchar2 default null,
          segment20               in varchar2 default null,
          segment21               in varchar2 default null,
          segment22               in varchar2 default null,
          segment23               in varchar2 default null,
          segment24               in varchar2 default null,
          segment25               in varchar2 default null,
          segment26               in varchar2 default null,
          segment27               in varchar2 default null,
          segment28               in varchar2 default null,
          segment29               in varchar2 default null,
          segment30               in varchar2 default null,
          p_ee_value1               in varchar2 default null,
          p_ee_value2               in varchar2 default null,
          p_ee_value3               in varchar2 default null,
          p_ee_value4               in varchar2 default null,
          p_ee_value5               in varchar2 default null,
          p_ee_value6               in varchar2 default null,
          p_ee_value7               in varchar2 default null,
          p_ee_value8               in varchar2 default null,
          p_ee_value9               in varchar2 default null,
          p_ee_value10              in varchar2 default null,
          p_ee_value11              in varchar2 default null,
          p_ee_value12              in varchar2 default null,
          p_ee_value13              in varchar2 default null,
          p_ee_value14              in varchar2 default null,
          p_ee_value15              in varchar2 default null,
          p_col1                    in number default null,
          p_col2                    in number default null,
          p_col3                    in number default null,
          p_col4                    in number default null,
          p_col5                    in number default null,
          p_col_val1                in varchar2 default null,
          p_col_val2                in varchar2 default null,
          p_col_val3                in varchar2 default null,
          p_col_val4                in varchar2 default null,
          p_col_val5                in varchar2 default null,
          p_batch_line_id           in number default null,
          p_batch_group_id          in number default null,
          p_batch_line_status       in varchar2 default null,
          p_mode                    in varchar2 default null) IS

   cursor csr_check_batch_group(ln_batch_id  number,
                                ln_consolidation_set_id number,
                                ln_payroll_id  number,
                                ln_effective_date date,
                                ln_prepay_flag varchar2) IS
    select batch_group_id, batch_group_status
      from pay_adjust_batch_groups
      where batch_id = ln_batch_id
       and consolidation_set_id = ln_consolidation_set_id
       and payroll_id = ln_payroll_id
       and effective_date = ln_effective_date
       and prepay_flag = ln_prepay_flag;

    cursor csr_check_batch_line(ln_batch_id number,
                                ln_batch_group_id number,
                                ln_assignment_id number,
				ln_element_type_id number) IS
    select batch_line_id, batch_line_status
       from pay_adjust_batch_lines
       where batch_id = ln_batch_id
        and batch_group_id = ln_batch_group_id
        and assignment_id = ln_assignment_id
        and element_type_id = ln_element_type_id;

 -- Bug: 5212904

   CURSOR csr_get_batch_line_details IS
   SELECT batch_line_status, batch_group_id, assignment_id
   FROM pay_adjust_batch_lines
   WHERE batch_line_id = p_batch_line_id
   AND batch_id = p_batch_id;

   CURSOR csr_get_batch_group_details(l_batch_group_id number) IS
   SELECT batch_group_status, consolidation_set_id,effective_date, prepay_flag
   FROM pay_adjust_batch_groups
   WHERE batch_group_id = l_batch_group_id;

 -- Modified for the bug: 5212923

   cursor c_get_input_value_id(cp_element_type_id number,
                               cp_eff_date date) is

          select input_value_id,name,rownum
	  from (select inv.input_value_id,inv.name name,rownum
	        from pay_input_values_f inv
		where inv.element_type_id= cp_element_type_id
		and SYSDATE between inv.effective_start_date
                                and inv.effective_end_date
		order by inv.display_sequence,inv.name);


  -- Modified the following query for the Bug: 5079557

    cursor c_get_payroll_id IS
       select  paf.payroll_id
       from per_assignments_f paf
       where paf.assignment_number = p_assignment_id
       and paf.business_group_id = p_business_group_id
       and p_effective_date between paf.effective_start_date and paf.effective_end_date;

    -- Get the Cost Allocation Keyflex num
       cursor c_get_caflexnum(cp_bg_id number) IS
       select cost_allocation_structure
       from   per_business_groups
       where  business_group_id = cp_bg_id;

    -- Get the GRE ID based on GRE Name
       cursor c_get_gre_id(cp_bg_id number,cp_gre_name varchar2) IS

       SELECT hout.organization_id
       FROM hr_organization_information hoi,
            hr_organization_units hou,
	    hr_all_organization_units_tl hout
       WHERE hoi.organization_id = hou.organization_id
       AND hou.organization_id = hout.organization_id
       AND hoi.ORG_INFORMATION_CONTEXT = 'CLASS'
       AND org_information1 = 'HR_LEGAL'
       AND hou.business_group_id = cp_bg_id
       AND hout.name = cp_gre_name
       AND hout.language = userenv('LANG');

    -- Get Consolidation Set ID if user did not enter it in the spreadsheet.
    -- Bug: 5079557

       cursor c_get_consolidation_set_id IS
       select pcs.consolidation_set_id
       from per_assignments_f paf, pay_payrolls_f ppf, pay_consolidation_sets pcs
       where paf.assignment_number = p_assignment_id
       and paf.business_group_id = p_business_group_id
       and sysdate between paf.effective_start_date and paf.effective_end_date
       and paf.payroll_id = ppf.payroll_id
       and sysdate between ppf.effective_start_date and ppf.effective_end_date
       and ppf.consolidation_set_id = pcs.consolidation_set_id;

    -- Get GRE if user did not enter it in the spreadsheet.
    -- Bug: 5079557

       cursor get_gre IS
       select segment1
       from per_all_assignments_f paf,
            hr_soft_coding_keyflex hsck
       where paf.business_group_id = p_business_group_id
       and sysdate between paf.effective_start_date and paf.effective_end_date
       and paf.assignment_number = p_assignment_id
       and hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id;

   -- Added the cursor to handle multiple GRE's for CA legislation.

      cursor get_element_type IS
      select element_information4 from pay_element_types_f
      where element_type_id = p_element_type_id
      and sysdate between effective_start_date and effective_end_date
      and business_group_id = p_business_group_id;


       cursor get_gre_ca IS
       select segment1, segment11, segment12,
              nvl(segment1,nvl(segment11,segment12))
       from per_all_assignments_f paf,
            hr_soft_coding_keyflex hsck
       where paf.business_group_id = p_business_group_id
       and sysdate between paf.effective_start_date and paf.effective_end_date
       and paf.assignment_number = p_assignment_id
       and hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id;

   -- Added to know the legislation code for a business group

      cursor get_legislation_code IS
      select legislation_code
      from per_business_groups
      where business_group_id = p_business_group_id;


    /* cursor to get the assignment_id */

    CURSOR csr_get_asg_id is
    select paf.assignment_id
    from per_all_assignments_f paf,
       per_all_people_f ppf
    where ltrim(ppf.full_name) = p_employee_id
    and ppf.person_id = paf.person_id
    and ppf.business_group_id = p_business_group_id
    and p_effective_date between ppf.effective_start_date and ppf.effective_end_date
    and paf.assignment_number = p_assignment_id
    and p_effective_date between paf.effective_start_date and paf.effective_end_date
    and paf.business_group_id =  p_business_group_id;

    CURSOR csr_get_eff_dates(l_assignment_id number) IS
    select effective_start_date, effective_end_date
    from per_all_assignments_f
    where assignment_id = l_assignment_id
    and business_group_id = p_business_group_id
    and p_effective_date between effective_start_date and effective_end_date;


i     number;

ln_assignment_id per_assignments_f.assignment_id%TYPE;
l_inp_id       pay_input_values_f.input_value_id%TYPE;
l_inp_name     pay_input_values_f.name%TYPE;
l_inp_ds       pay_input_values_f.display_sequence%TYPE;
p_concat_segments  varchar2(240) default null;

l_cakff_id     number;

l_segment1     varchar2(240) default null;
l_segment2     varchar2(240) default null;
l_segment3     varchar2(240) default null;
l_segment4     varchar2(240) default null;
l_segment5     varchar2(240) default null;
l_segment6     varchar2(240) default null;
l_segment7     varchar2(240) default null;
l_segment8     varchar2(240) default null;
l_segment9     varchar2(240) default null;
l_segment10    varchar2(240) default null;
l_segment11    varchar2(240) default null;
l_segment12    varchar2(240) default null;
l_segment13    varchar2(240) default null;
l_segment14    varchar2(240) default null;
l_segment15    varchar2(240) default null;
l_segment16    varchar2(240) default null;
l_segment17    varchar2(240) default null;
l_segment18    varchar2(240) default null;
l_segment19    varchar2(240) default null;
l_segment20    varchar2(240) default null;
l_segment21    varchar2(240) default null;
l_segment22    varchar2(240) default null;
l_segment23    varchar2(240) default null;
l_segment24    varchar2(240) default null;
l_segment25    varchar2(240) default null;
l_segment26    varchar2(240) default null;
l_segment27    varchar2(240) default null;
l_segment28    varchar2(240) default null;
l_segment29    varchar2(240) default null;
l_segment30    varchar2(240) default null;

l_batch_group_id      number;
l_batch_group_status  varchar2(10);

l_batch_line_id       number := p_batch_line_id;
l_batch_line_status   varchar2(10);

ln_payroll_id         number;
-- Bug: 5079557
l_consolidation_set_id number := p_consolidation_set_id;

ex_cannot_update_bg   EXCEPTION;
ex_cannot_update_bl   EXCEPTION;
ln_gre_id             number;
ln_rec_count          number;

lv_batch_group_exists varchar2(2);
lv_batch_line_exists varchar2(2);
l_internal_display_funct_val varchar2(60);
l_input_value_counter number := 0;
l_exception_message varchar2(100);
l_exception_id number;
l_effective_start_date date;
l_effective_end_date date;
l_default_jd varchar2(2);

l_costing_flag varchar2(1);
l_prepay_flag  varchar2(1);
l_old_prepay_flag  varchar2(1);

l_leg_code varchar2(2);
l_element_information_type varchar2(10);

ln_segment1     number;
ln_segment11    number;
ln_segment12    number;
ln_ca_gre       number;

-- Bug: 5212904 (Issue# 3)

l_batch_line_exists varchar2(2);
l_user_modified_batch_grp varchar2(2);
ln_old_assignment_id per_assignments_f.assignment_id%TYPE;
l_old_consolidation_set_id number;
l_old_effective_date date;
l_old_prepay_flag varchar2(1);
l_old_batch_group_status varchar2(10);
l_old_batch_group_id      number;

l_date_input date;

/* MAIN */

Begin

     --hr_utility.trace_on(null,'ram');
     hr_utility.trace('p_batch_id  is : '|| p_batch_id );
     hr_utility.trace('p_batch_name  is : '|| p_batch_name );
     hr_utility.trace('p_effective_date  is : '|| p_effective_date );
     hr_utility.trace('p_mode  is : '|| p_mode );
     hr_utility.trace('p_batch_group_id  is : '|| p_batch_group_id );
     hr_utility.trace('p_batch_line_id  is : '|| p_batch_line_id );
     hr_utility.trace('p_batch_line_status  is : '|| p_batch_line_status );
     hr_utility.trace('p_employee_id is : '|| p_employee_id);
     hr_utility.trace('p_assignment_id  is : '|| p_assignment_id );
     hr_utility.trace('p_element_name  is : '|| p_element_name );
     hr_utility.trace('p_element_type_id  is : '||  p_element_type_id);
     hr_utility.trace('p_element_link_id  is : '|| p_element_link_id );
     hr_utility.trace('p_payroll_id  is : '|| p_payroll_id );
     hr_utility.trace('p_business_group_id  is : '|| p_business_group_id );
     hr_utility.trace('p_consolidation_set_id  is : '||  p_consolidation_set_id);
     hr_utility.trace('p_gre_id  is : '|| p_gre_id );
     hr_utility.trace('p_prepay_flag  is : '||p_prepay_flag  );
     hr_utility.trace('p_costing_flag  is : '|| p_costing_flag );
     hr_utility.trace('p_cost_allocation_keyflex is : '|| p_cost_allocation_keyflex );
     hr_utility.trace('p_concatenated_segments is : '|| p_concatenated_segments );
     hr_utility.trace('segment1  is : '|| segment1 );
     hr_utility.trace('segment2  is : '|| segment2 );
     hr_utility.trace('segment3  is : '|| segment3 );
     hr_utility.trace('segment4  is : '|| segment4 );
     hr_utility.trace('segment5  is : '|| segment5 );
     hr_utility.trace('segment6  is : '|| segment6 );
     hr_utility.trace('segment7  is : '|| segment7 );
     hr_utility.trace('segment8  is : '|| segment8 );
     hr_utility.trace('segment9  is : '|| segment9 );
     hr_utility.trace('segment10  is : '||segment10  );
     hr_utility.trace('segment11  is : '||segment11  );
     hr_utility.trace('segment12  is : '||segment12  );
     hr_utility.trace('segment13  is : '||segment13  );
     hr_utility.trace('segment14  is : '||segment14  );
     hr_utility.trace('segment15  is : '||segment15  );
     hr_utility.trace('segment16 is : '|| segment16);
     hr_utility.trace('segment17  is : '|| segment17 );
     hr_utility.trace('segment18  is : '|| segment18 );
     hr_utility.trace('segment19  is : '|| segment19 );
     hr_utility.trace('segment20  is : '|| segment20 );
     hr_utility.trace('segment21  is : '|| segment21 );
     hr_utility.trace('segment22  is : '|| segment22 );
     hr_utility.trace('segment23  is : '|| segment23 );
     hr_utility.trace('segment24  is : '|| segment24 );
     hr_utility.trace('segment25  is : '||segment25  );
     hr_utility.trace('segment26  is : '||segment26  );
     hr_utility.trace('segment27  is : '||segment27  );
     hr_utility.trace('segment28  is : '||segment28  );
     hr_utility.trace('segment29  is : '||segment29  );
     hr_utility.trace('segment30  is : '||segment30  );
     hr_utility.trace('p_ee_value1  is : '|| p_ee_value1 );
     hr_utility.trace('p_ee_value2  is : '|| p_ee_value2 );
     hr_utility.trace('p_ee_value3  is : '|| p_ee_value3 );
     hr_utility.trace('p_ee_value4  is : '|| p_ee_value4 );
     hr_utility.trace('p_ee_value5  is : '|| p_ee_value5 );
     hr_utility.trace('p_ee_value6  is : '|| p_ee_value6 );
     hr_utility.trace('p_ee_value7  is : '|| p_ee_value7 );
     hr_utility.trace('p_ee_value8  is : '|| p_ee_value8 );
     hr_utility.trace('p_ee_value9  is : '|| p_ee_value9 );
     hr_utility.trace('p_ee_value10  is : '||p_ee_value10  );
     hr_utility.trace('p_ee_value11  is : '||p_ee_value11  );
     hr_utility.trace('p_ee_value12  is : '||p_ee_value12  );
     hr_utility.trace('p_ee_value13  is : '||p_ee_value13  );
     hr_utility.trace('p_ee_value14  is : '||p_ee_value14  );
     hr_utility.trace('p_ee_value15  is : '||p_ee_value15  );
     hr_utility.trace('p_col1  is : '|| p_col1 );
     hr_utility.trace('p_col2  is : '|| p_col2 );
     hr_utility.trace('p_col3  is : '|| p_col3 );
     hr_utility.trace('p_col4  is : '|| p_col4 );
     hr_utility.trace('p_col5  is : '|| p_col5 );
     hr_utility.trace('p_col_val1  is : '|| p_col_val1 );
     hr_utility.trace('p_col_val2  is : '|| p_col_val2 );
     hr_utility.trace('p_col_val3  is : '|| p_col_val3 );
     hr_utility.trace('p_col_val4  is : '|| p_col_val4 );
     hr_utility.trace('p_col_val5  is : '|| p_col_val5 );
     hr_utility.set_location('p_col_val5  is : '|| p_col_val5,10 );

     -- Bug: 5200900
     -- Storing input values in Global variables.

     g_ee_value1 := p_ee_value1;
     g_ee_value2 := p_ee_value2;
     g_ee_value3 := p_ee_value3;
     g_ee_value4 := p_ee_value4;
     g_ee_value5 := p_ee_value5;
     g_ee_value6 := p_ee_value6;
     g_ee_value7 := p_ee_value7;
     g_ee_value8 := p_ee_value8;
     g_ee_value9 := p_ee_value9;
     g_ee_value10 := p_ee_value10;
     g_ee_value11 := p_ee_value11;
     g_ee_value12 := p_ee_value12;
     g_ee_value13 := p_ee_value13;
     g_ee_value14 := p_ee_value14;
     g_ee_value15 := p_ee_value15;

    if p_costing_flag is null then
       hr_utility.trace('p_costing_flag is null satisfied');
       l_costing_flag := 'N';
    else
       l_costing_flag := p_costing_flag;
    end if;


    if p_prepay_flag is null then
       hr_utility.trace('p_prepay_flag is null satisfied');
       l_prepay_flag := 'N';
    else
       l_prepay_flag := p_prepay_flag;
    end if;

    if g_element_type_id is null then
       hr_utility.trace('g_element_type_id is null satisfied ');
       g_element_type_id := -1;
    end if;

    i := 0;
    ln_rec_count := 0;

    open c_get_payroll_id;
    fetch c_get_payroll_id into ln_payroll_id;
    close c_get_payroll_id;

    -- If payroll is not attached, raise an error.

    if ln_payroll_id is null then
       hr_utility.trace('ln_payroll_id is null satisfied');
       hr_utility.raise_error;
    end if;

    OPEN csr_get_asg_id;
    FETCH csr_get_asg_id into ln_assignment_id;
    IF csr_get_asg_id%NOTFOUND THEN
       hr_utility.raise_error;
    END IF;
    CLOSE csr_get_asg_id;
    hr_utility.trace('Assignment_id :'||to_char(ln_assignment_id));

    -- Fetch Consolidation Set Id if user did not enter it.

    if l_consolidation_set_id is null then
       open c_get_consolidation_set_id;
       fetch c_get_consolidation_set_id into l_consolidation_set_id;
       close c_get_consolidation_set_id;
    end if;

    -- Fetch Legislation code.

    open get_legislation_code;
    fetch get_legislation_code into l_leg_code;
    close get_legislation_code;

    -- Check the input value has lookup and

    -- Defaulting the Jurisdiction value if user did not enter it.

    IF l_leg_code = 'CA' THEN

	l_default_jd := pay_ca_emp_tax_inf.get_tax_detail_char
                               (ln_assignment_id,
	                        null,
				null,
				p_effective_date,
				'EMPPROV');

        hr_utility.trace('l_default_jd: ' || l_default_jd);

    END IF;

    -- Fetch GRE name if user did not enter it.
    -- Modified to handle multiple GREs for CA legislation.

    if p_gre_id is null then

       IF l_leg_code = 'CA' then

          hr_utility.trace('l_leg_code = CA is satisfied');
	  hr_utility.trace('Opening cursor: get_gre_ca ...');

          open get_gre_ca;
	  fetch get_gre_ca into ln_segment1, ln_segment11,
                                ln_segment12,ln_ca_gre;
          close get_gre_ca;

	  OPEN get_element_type;
	  FETCH get_element_type into l_element_information_type;

	  IF get_element_type%NOTFOUND THEN

             ln_gre_id :=  ln_ca_gre;

          ELSE

	     IF l_element_information_type = 'T4/RL1' THEN

	        hr_utility.trace('l_element_information_type = T4/RL1');
                ln_gre_id := ln_segment1;

	     ELSIF l_element_information_type = 'T4A/RL1' THEN

	        hr_utility.trace('l_element_information_type = T4A/RL1');
                ln_gre_id := ln_segment11;

	     ELSIF l_element_information_type = 'T4A/RL2' THEN

	        hr_utility.trace('l_element_information_type = T4A/RL2');
                ln_gre_id := ln_segment12;

	     END IF;

	     IF ln_gre_id is null THEN

                ln_gre_id :=  ln_ca_gre;

	     END IF;

          END IF;

      	  CLOSE get_element_type;

       else
          hr_utility.trace('l_leg_code != CA is satisfied');
          open get_gre;
          fetch get_gre into ln_gre_id;
          close get_gre;
       end if;

    else
       open c_get_gre_id(p_business_group_id,p_gre_id);
       fetch c_get_gre_id into ln_gre_id;
       close c_get_gre_id;
    end if;


    hr_utility.trace('GRE_Id :'||to_char(ln_gre_id));
    hr_utility.trace('Payroll Id : '||to_char(ln_payroll_id));
    hr_utility.trace('G_Element_type_Id : '||to_char(g_element_type_id));
    hr_utility.trace('G_ip_id1 : '||to_char(g_ip_id1));
    hr_utility.trace('G_ip_id2 : '||to_char(g_ip_id2));
    hr_utility.trace('G_ip_id3 : '||to_char(g_ip_id3));
    hr_utility.trace('G_ip_id4 : '||to_char(g_ip_id4));
    hr_utility.trace('G_ip_id5 : '||to_char(g_ip_id5));
    hr_utility.trace('G_ip_id6 : '||to_char(g_ip_id6));
    hr_utility.trace('G_ip_id7 : '||to_char(g_ip_id7));
    hr_utility.trace('G_ip_id8 : '||to_char(g_ip_id8));
    hr_utility.trace('G_ip_id9 : '||to_char(g_ip_id9));
    hr_utility.trace('G_ip_id10 : '||to_char(g_ip_id10));
    hr_utility.trace('G_ip_id11 : '||to_char(g_ip_id11));
    hr_utility.trace('G_ip_id12 : '||to_char(g_ip_id12));
    hr_utility.trace('G_ip_id13 : '||to_char(g_ip_id13));
    hr_utility.trace('G_ip_id14 : '||to_char(g_ip_id14));
    hr_utility.trace('G_ip_id15 : '||to_char(g_ip_id15));

-- for the element find the input value ids


     if g_element_type_id <> p_element_type_id then
       -- Bug : 5079557
       -- Get the Cost Allocation Keyflex num
       open c_get_caflexnum(p_business_group_id);
       fetch c_get_caflexnum into g_flex_num;
       close c_get_caflexnum;

       hr_utility.trace('g_element_type_id <> p_element_type_id satisfied ');
       g_element_type_id := p_element_type_id;

       open c_get_input_value_id(p_element_type_id,p_effective_date);
        loop
          fetch c_get_input_value_id into l_inp_id, l_inp_name,l_inp_ds;

          hr_utility.trace('Input_value_id  is : '|| to_char(l_inp_id));
          hr_utility.trace('Input value Name  is : '|| l_inp_name);
          hr_utility.trace('Input value sequence is : '|| to_char(l_inp_ds));

           exit when c_get_input_value_id%NOTFOUND;

           i := i + 1 ;
           if i =1 then

              g_ip_id1 := l_inp_id;

              if l_inp_name = 'Jurisdiction' then
                 g_display_sequence := l_inp_ds;
              end if;

           elsif i = 2 then

              g_ip_id2 := l_inp_id;

              if l_inp_name = 'Jurisdiction' then
                 g_display_sequence := l_inp_ds;
              end if;

           elsif i = 3 then

              g_ip_id3 := l_inp_id;

              if l_inp_name = 'Jurisdiction' then
                 g_display_sequence := l_inp_ds;
              end if;

           elsif i = 4 then

              g_ip_id4 := l_inp_id;

              if l_inp_name = 'Jurisdiction' then
                 g_display_sequence := l_inp_ds;
              end if;

           elsif i = 5 then

              g_ip_id5 := l_inp_id;

              if l_inp_name = 'Jurisdiction' then
                 g_display_sequence := l_inp_ds;
              end if;

           elsif i = 6 then

              g_ip_id6 := l_inp_id;

              if l_inp_name = 'Jurisdiction' then
                 g_display_sequence := l_inp_ds;
              end if;

           elsif i = 7 then

              g_ip_id7 := l_inp_id;

              if l_inp_name = 'Jurisdiction' then
                 g_display_sequence := l_inp_ds;
              end if;

           elsif i = 8 then

              g_ip_id8 := l_inp_id;

              if l_inp_name = 'Jurisdiction' then
                 g_display_sequence := l_inp_ds;
              end if;

           elsif i = 9 then

              g_ip_id9 := l_inp_id;

              if l_inp_name = 'Jurisdiction' then
                 g_display_sequence := l_inp_ds;
              end if;

           elsif i = 10 then

              g_ip_id10 := l_inp_id;

              if l_inp_name = 'Jurisdiction' then
                 g_display_sequence := l_inp_ds;
              end if;

           elsif i = 11 then

              g_ip_id11 := l_inp_id;

              if l_inp_name = 'Jurisdiction' then
                 g_display_sequence := l_inp_ds;
              end if;

           elsif i = 12 then

              g_ip_id12 := l_inp_id;

              if l_inp_name = 'Jurisdiction' then
                 g_display_sequence := l_inp_ds;
              end if;

           elsif i = 13 then

              g_ip_id13 := l_inp_id;

              if l_inp_name = 'Jurisdiction' then
                 g_display_sequence := l_inp_ds;
              end if;

           elsif i = 14 then

              g_ip_id14 := l_inp_id;

              if l_inp_name = 'Jurisdiction' then
                 g_display_sequence := l_inp_ds;
              end if;

           elsif i = 15 then

              g_ip_id15 := l_inp_id;

              if l_inp_name = 'Jurisdiction' then
                 g_display_sequence := l_inp_ds;
              end if;


           end if;
                   -- store in global variables to be used later

      end loop;
     close c_get_input_value_id;

         hr_utility.trace('Done with c_get_input_value_id cursor ');

   end if; -- g_element_type_id <> p_element_type_id


 if l_leg_code = 'CA' then
   CASE g_display_sequence

	WHEN 1 THEN  IF g_ee_value1 is null THEN
	                g_ee_value1 := l_default_jd;
		        hr_utility.trace('Modifed g_ee_value1: ' || g_ee_value1);
		     END IF;
	WHEN 2 THEN  IF g_ee_value2 is null THEN
	    		g_ee_value2 := l_default_jd;
			hr_utility.trace('Modifed l_ee_value2: ' || g_ee_value2);
		     END IF;
	WHEN 3 THEN  IF g_ee_value3 is null THEN
	                g_ee_value3 := l_default_jd;
		        hr_utility.trace('Modifed g_ee_value3: ' || g_ee_value3);
		     END IF;
	WHEN 4 THEN  IF g_ee_value4 is null THEN
	                g_ee_value4 := l_default_jd;
		        hr_utility.trace('Modifed g_ee_value4: ' || g_ee_value4);
		     END IF;
	WHEN 5 THEN  IF g_ee_value5 is null THEN
	                g_ee_value5 := l_default_jd;
		        hr_utility.trace('Modifed g_ee_value5: ' || g_ee_value5);
		     END IF;
	WHEN 6 THEN  IF g_ee_value6 is null THEN
	                g_ee_value6 := l_default_jd;
		        hr_utility.trace('Modifed g_ee_value6: ' || g_ee_value6);
		     END IF;
	WHEN 7 THEN  IF g_ee_value7 is null THEN
	                g_ee_value7 := l_default_jd;
		        hr_utility.trace('Modifed g_ee_value7: ' || g_ee_value7);
		     END IF;
	WHEN 8 THEN  IF g_ee_value8 is null THEN
	                g_ee_value8 := l_default_jd;
		        hr_utility.trace('Modifed g_ee_value8: ' || g_ee_value8);
		     END IF;
	WHEN 9 THEN  IF g_ee_value9 is null THEN
		        g_ee_value9 := l_default_jd;
			hr_utility.trace('Modifed g_ee_value9: ' || g_ee_value9);
		     END IF;
	WHEN 10 THEN  IF g_ee_value10 is null THEN
	                 g_ee_value10 := l_default_jd;
			 hr_utility.trace('Modifed g_ee_value10: ' || g_ee_value10);
		      END IF;
	WHEN 11 THEN  IF g_ee_value11 is null THEN
	                 g_ee_value11 := l_default_jd;
			 hr_utility.trace('Modifed g_ee_value11: ' || g_ee_value11);
		      END IF;
	WHEN 12 THEN  IF g_ee_value12 is null THEN
		         g_ee_value12 := l_default_jd;
			 hr_utility.trace('Modifed g_ee_value12: ' || g_ee_value12);
		      END IF;
	WHEN 13 THEN  IF g_ee_value13 is null THEN
		         g_ee_value13 := l_default_jd;
			 hr_utility.trace('Modifed g_ee_value13: ' || g_ee_value13);
		      END IF;
	WHEN 14 THEN  IF g_ee_value14 is null THEN
		         g_ee_value14 := l_default_jd;
			 hr_utility.trace('Modifed g_ee_value14: ' || g_ee_value14);
		      END IF;
	WHEN 15 THEN  IF g_ee_value15 is null THEN
		         g_ee_value15 := l_default_jd;
			 hr_utility.trace('Modifed g_ee_value15: ' || g_ee_value15);
		      END IF;
   END CASE;

 end if;

   -- Added for Bug: 5079530
   begin
	l_input_value_counter := 1;
	l_internal_display_funct_val := convert_internal_to_display(p_element_type_id, p_ee_value1, 1, sysdate, p_batch_id, 'P');
	l_input_value_counter := l_input_value_counter +1;
	l_internal_display_funct_val := convert_internal_to_display(p_element_type_id, p_ee_value2, 2, sysdate, p_batch_id, 'P');
	l_input_value_counter := l_input_value_counter +1;
	l_internal_display_funct_val := convert_internal_to_display(p_element_type_id, p_ee_value3, 3, sysdate, p_batch_id, 'P');
	l_input_value_counter := l_input_value_counter +1;
	l_internal_display_funct_val := convert_internal_to_display(p_element_type_id, p_ee_value4, 4, sysdate, p_batch_id, 'P');
	l_input_value_counter := l_input_value_counter +1;
	l_internal_display_funct_val := convert_internal_to_display(p_element_type_id, p_ee_value5, 5, sysdate, p_batch_id, 'P');
	l_input_value_counter := l_input_value_counter +1;
	l_internal_display_funct_val := convert_internal_to_display(p_element_type_id, p_ee_value6, 6, sysdate, p_batch_id, 'P');
	l_input_value_counter := l_input_value_counter +1;
	l_internal_display_funct_val := convert_internal_to_display(p_element_type_id, p_ee_value7, 7, sysdate, p_batch_id, 'P');
	l_input_value_counter := l_input_value_counter +1;
	l_internal_display_funct_val := convert_internal_to_display(p_element_type_id, p_ee_value8, 8, sysdate, p_batch_id, 'P');
	l_input_value_counter := l_input_value_counter +1;
	l_internal_display_funct_val := convert_internal_to_display(p_element_type_id, p_ee_value9, 9, sysdate, p_batch_id, 'P');
	l_input_value_counter := l_input_value_counter +1;
	l_internal_display_funct_val := convert_internal_to_display(p_element_type_id, p_ee_value10,10, sysdate, p_batch_id, 'P');
	l_input_value_counter := l_input_value_counter +1;
	l_internal_display_funct_val := convert_internal_to_display(p_element_type_id, p_ee_value11,11, sysdate, p_batch_id, 'P');
	l_input_value_counter := l_input_value_counter +1;
	l_internal_display_funct_val := convert_internal_to_display(p_element_type_id, p_ee_value12,12, sysdate, p_batch_id, 'P');
	l_input_value_counter := l_input_value_counter +1;
	l_internal_display_funct_val := convert_internal_to_display(p_element_type_id, p_ee_value13,13, sysdate, p_batch_id, 'P');
	l_input_value_counter := l_input_value_counter +1;
	l_internal_display_funct_val := convert_internal_to_display(p_element_type_id, p_ee_value14,14, sysdate, p_batch_id, 'P');
	l_input_value_counter := l_input_value_counter +1;
	l_internal_display_funct_val := convert_internal_to_display(p_element_type_id, p_ee_value15,15, sysdate, p_batch_id, 'P');

	exception

	  when others then
	     hr_utility.trace('#################################################');
	     hr_utility.trace('ERROR while uploading input values');
	     hr_utility.trace('Enter valide input values for element input types');
	     hr_utility.trace('#################################################');
	     --hr_utility.set_message('PAY','PAY_449776_INPUT_VALUE_FORMAT');
	     --hr_utility.set_message('PAY','PAY_6306_INPUT_VALUE_FORMAT');

	    case l_input_value_counter
	          when 1 then  l_exception_id := g_ip_id1;
		  when 2 then l_exception_id := g_ip_id2;
		  when 3 then l_exception_id := g_ip_id3;
		  when 4 then l_exception_id := g_ip_id4;
		  when 5 then l_exception_id := g_ip_id5;
		  when 6 then l_exception_id := g_ip_id6;
		  when 7 then l_exception_id := g_ip_id7;
		  when 8 then l_exception_id := g_ip_id8;
		  when 9 then l_exception_id := g_ip_id9;
		  when 10 then l_exception_id := g_ip_id10;
		  when 11 then l_exception_id := g_ip_id11;
		  when 12 then l_exception_id := g_ip_id12;
		  when 13 then l_exception_id := g_ip_id13;
		  when 14 then l_exception_id := g_ip_id14;
		  when 15 then l_exception_id := g_ip_id15;
	     end case;

	     hr_utility.trace('l_exception_id: '|| l_exception_id);

	     SELECT name INTO l_exception_message
	     FROM pay_input_values_f
	     WHERE element_type_id= p_element_type_id
	     AND p_effective_date between effective_start_date and effective_end_date
             AND input_value_id = l_exception_id
	     ORDER BY display_sequence, name;

	     hr_utility.trace('l_exception_message: '|| l_exception_message);

	     hr_utility.set_message('PAY',l_exception_message);

	     --hr_utility.set_message_token('COLUMN', l_exception_message);
	     hr_utility.trace('l_exception_message:'||l_exception_id);
	     hr_utility.raise_error;
   end;

   -- This moved to above condition.
   -- Bug: 5079557
/*
   -- Get the Cost Allocation Keyflex num
      open c_get_caflexnum(p_business_group_id);
      fetch c_get_caflexnum into g_flex_num;
      close c_get_caflexnum;
 **/

 -- Bug: 5212904

/*
   Check if batch_line_id already exists. Then fetch its batch_group_id.
   Check whether consolidation_set_id, effective_date, prepay flag,
   Employee name and assignment number have been modified.
*/
 IF l_batch_line_id IS NOT NULL THEN

	OPEN csr_get_batch_line_details;
	FETCH csr_get_batch_line_details INTO l_batch_line_status, l_old_batch_group_id, ln_old_assignment_id;
		IF csr_get_batch_line_details%NOTFOUND THEN
			l_batch_line_exists := 'N';
		ELSE
			l_batch_line_exists := 'Y';
		END IF;
	CLOSE csr_get_batch_line_details;

	hr_utility.trace('l_batch_line_exists: ' || l_batch_line_exists);

/* If we need to raise an error if user updates the above mentioned columns we can reuse the following code.

	IF l_batch_line_exists = 'Y' THEN
		IF ln_old_assignment_id != ln_assignment_id THEN
			hr_utility.trace('ln_old_assignment_id: ' || ln_old_assignment_id);
			hr_utility.trace('ln_assignment_id: ' || ln_assignment_id);
			hr_utility.trace('ERROR: Assignment Number can not be modified');
			hr_utility.raise_error;
	        ELSE
			OPEN csr_get_batch_group_details(l_old_batch_group_id);
			FETCH csr_get_batch_group_details INTO l_old_batch_group_status, l_old_consolidation_set_id, l_old_effective_date, l_old_prepay_flag;
			CLOSE csr_get_batch_group_details;

			IF l_old_consolidation_set_id != l_consolidation_set_id
			   OR l_old_effective_date != p_effective_date
			   OR l_old_prepay_flag != l_prepay_flag THEN
				l_user_modified_batch_grp := 'Y';
			END IF;
		END IF;
	END IF;
*/
   END IF;

/*
   Get the Pl/SQL table values and check see if a row exists in the
   table for the combination of
   - consolidation_set_id
   - payroll_id
   - effective_date
   - prepay flag
   - batch_id
*/




  hr_utility.trace('lv_batch_group_exists'|| lv_batch_group_exists);
  lv_batch_group_exists := 'N';

  hr_utility.trace('pay_batch_balanceadj_wrapper.gtr_batch_group_data.count'||pay_batch_balanceadj_wrapper.gtr_batch_group_data.count);
  hr_utility.trace('lv_batch_group_exists'|| lv_batch_group_exists);

  begin

      hr_utility.trace('p_batch_id-->'||p_batch_id);
      hr_utility.trace('l_consolidation_set_id-->' || l_consolidation_set_id);
      hr_utility.trace('ln_payroll_id -->' || ln_payroll_id);
      hr_utility.trace('p_effective_date -->' || p_effective_date);
      hr_utility.trace('l_prepay_flag -->' || l_prepay_flag);

      OPEN csr_check_batch_group(p_batch_id,l_consolidation_set_id,ln_payroll_id,p_effective_date,l_prepay_flag);
      FETCH csr_check_batch_group INTO l_batch_group_id, l_batch_group_status;
      IF csr_check_batch_group%NOTFOUND THEN
         lv_batch_group_exists := 'N';
      ELSE
         lv_batch_group_exists := 'Y';
      END IF;
      CLOSE csr_check_batch_group;

      if lv_batch_group_exists = 'N' then

        hr_utility.trace('No data found for pay_adjust_batch_groups ');
        select pay_adjust_batch_groups_s.nextval into l_batch_group_id
        from dual;

        insert into pay_adjust_batch_groups
               (batch_group_id,
                batch_id,
                batch_group_status,
                consolidation_set_id,
                payroll_id,
                effective_date,
                prepay_flag)
         values (l_batch_group_id,
                 p_batch_id,
                 'U',
                 l_consolidation_set_id,
                 ln_payroll_id,
                 p_effective_date,
                 l_prepay_flag);

         l_batch_group_status := 'U';
         hr_utility.trace('Done inserting into pay_adjust_batch_groups table');
         hr_utility.trace('New Batch Group id: '||to_char(l_batch_group_id));

      end if; /* lv_batch_group_exists = 'N' */

   end;


   /*
   If value is found then check if we can add in new lines else raise an erorr
   that the batch/group/line is closed for update/insert.

   cannot create new batch lines if the group status is
   'L' --> ??
   'T' --> Transferred
   'C' --> Completed
   */

   hr_utility.trace('l_batch_group_status : '||l_batch_group_status);

   if l_batch_group_status not in ('L','T','C') then

         /* check if batch line exists */
         hr_utility.trace('l_batch_group_status satisfied not in L, T, C ');

      begin

	 IF l_batch_line_id IS NULL THEN
		OPEN csr_check_batch_line(p_batch_id, l_batch_group_id, ln_assignment_id, p_element_type_id);
		FETCH csr_check_batch_line into l_batch_line_id, l_batch_line_status;
			IF csr_check_batch_line%NOTFOUND THEN
				l_batch_line_exists := 'N';
			ELSE
				l_batch_line_exists := 'Y';
			END IF;
		CLOSE csr_check_batch_line;
	 END IF;

         hr_utility.trace('l_batch_line_id : '|| l_batch_line_id);
         hr_utility.trace('l_batch_line_status : '||l_batch_line_status);


         IF l_batch_line_exists = 'Y' THEN

	       if l_batch_line_status in ('C','T') then

		    hr_utility.trace('l_batch_line_status is  C, T raise exception ');
		    raise ex_cannot_update_bl; -- cannot update a completed/ transferred line

		 else

		   if l_costing_flag = 'Y' then

			   hr_utility.trace('Costing Flag is set to Yes ');
		     l_cakff_id := get_costing_info(p_concatenated_segments,
			   segment1,segment2,segment3,segment4,segment5,
			   segment6,segment7,segment8,segment9,segment10,
			   segment11,segment12,segment13,segment14,segment15,
			   segment16,segment17,segment18,segment19,segment20,
			   segment21,segment22,segment23,segment24,segment25,
			   segment26,segment27,segment28,segment29,segment30);

			   hr_utility.trace('l_cakff_id :'||to_char(l_cakff_id));

		   end if;

		     hr_utility.trace('Update of pay_adjust_batch_lines ');

		     UPDATE pay_adjust_batch_lines
		     SET entry_value1 = g_ee_value1,
			 entry_value2 = g_ee_value2,
			 entry_value3 = g_ee_value3,
			 entry_value4 = g_ee_value4,
			 entry_value5 = g_ee_value5,
			 entry_value6 = g_ee_value6,
			 entry_value7 = g_ee_value7,
			 entry_value8 = g_ee_value8,
			 entry_value9 = g_ee_value9,
			 entry_value10 = g_ee_value10,
			 entry_value11 = g_ee_value11,
			 entry_value12 = g_ee_value12,
			 entry_value13 = g_ee_value13,
			 entry_value14 = g_ee_value14,
			 entry_value15 = g_ee_value15,
			 balance_adj_cost_flag = l_costing_flag,
			 cost_allocation_keyflex_id = l_cakff_id,
			 tax_unit_id = ln_gre_id,
			 batch_line_status = 'U',
			 batch_group_id = l_batch_group_id,
			 assignment_id = ln_assignment_id
		    WHERE batch_line_id = l_batch_line_id;

		 end if; /*End of If l_batch_line_status in ('C','T') */

        else
		hr_utility.trace('No data found for pay_adjust_batch_lines ');

		IF l_costing_flag = 'Y' THEN
			hr_utility.trace('Costing Flag is set to Yes ');
			l_cakff_id := get_costing_info(p_concatenated_segments,
			                               segment1,segment2,segment3,segment4,segment5,
						       segment6,segment7,segment8,segment9,segment10,
						       segment11,segment12,segment13,segment14,segment15,
						       segment16,segment17,segment18,segment19,segment20,
						       segment21,segment22,segment23,segment24,segment25,
						       segment26,segment27,segment28,segment29,segment30);
			hr_utility.trace('l_cakff_id :'||to_char(l_cakff_id));
		END IF;

		hr_utility.trace('inserting into pay_adjust_batch_lines table');
		insert into pay_adjust_batch_lines(batch_line_id,
		                                   batch_id,
						   batch_line_status,
						   batch_group_id,
						   batch_line_sequence,
						   assignment_id,
						   element_type_id,
						   input_value_id1,
						   input_value_id2,
						   input_value_id3,
						   input_value_id4,
						   input_value_id5,
						   input_value_id6,
						   input_value_id7,
						   input_value_id8,
						   input_value_id9,
						   input_value_id10,
						   input_value_id11,
						   input_value_id12,
						   input_value_id13,
						   input_value_id14,
						   input_value_id15,
						   entry_value1,
						   entry_value2,
						   entry_value3,
						   entry_value4,
						   entry_value5,
						   entry_value6,
						   entry_value7,
						   entry_value8,
						   entry_value9,
						   entry_value10,
						   entry_value11,
						   entry_value12,
						   entry_value13,
						   entry_value14,
						   entry_value15,
						   balance_adj_cost_flag,
						   cost_allocation_keyflex_id,
						   tax_unit_id)
						   values (pay_adjust_batch_lines_s.nextval,
						           p_batch_id,
							   'U',
							   l_batch_group_id,
							   1,
							   ln_assignment_id,
							   p_element_type_id,
							   g_ip_id1,
							   g_ip_id2,
							   g_ip_id3,
							   g_ip_id4,
							   g_ip_id5,
							   g_ip_id6,
							   g_ip_id7,
							   g_ip_id8,
							   g_ip_id9,
							   g_ip_id10,
							   g_ip_id11,
							   g_ip_id12,
							   g_ip_id13,
							   g_ip_id14,
							   g_ip_id15,
							   g_ee_value1,
							   g_ee_value2,
							   g_ee_value3,
							   g_ee_value4,
							   g_ee_value5,
							   g_ee_value6,
							   g_ee_value7,
							   g_ee_value8,
							   g_ee_value9,
							   g_ee_value10,
							   g_ee_value11,
							   g_ee_value12,
							   g_ee_value13,
							   g_ee_value14,
							   g_ee_value15,
							   l_costing_flag,
							   l_cakff_id,
							   ln_gre_id);

	END IF; /* End if lv_batch_line_exists = 'Y' */

      END; /* End of block started at l_batch_group_status not in ('L','T','C') */

   else /* l_batch_group_status */

      hr_utility.trace('raising exception l_batch_group_status : '||l_batch_group_status);
      raise ex_cannot_update_bg;

   end if; /* l_batch_group_status */

   exception

      when ex_cannot_update_bg then

        hr_utility.trace('Batch Group is either Transferred or Complete, cannot update the batch');

      when ex_cannot_update_bl then

        hr_utility.trace('Batch Line is either Transferred or Complete, cannot update the batch');


--hr_utility.trace_off;
end;

/*
   Function to be used to display input values in correct format
   for BBA Spreadsheet correct errros page. Used in Cotent queupry .
*/

function convert_internal_to_display
  (p_element_type_id               in varchar2,
   p_input_value                   in varchar2,
   p_input_value_number            in number,
   p_session_date                  in date,
   p_batch_id                      in number,
   p_calling_mode                  in varchar2
  ) return varchar2 is
--
   --
   l_bee_iv_upgrade  varchar2(1);
   --
   l_display_value   varchar2(60) ; -- := p_input_value;
   l_internal_value  varchar2(60) := p_input_value;
   l_dummy           varchar2(100);
   --
   l_uom_value       pay_input_values_f.UOM%TYPE;
   l_lookup_type     pay_input_values_f.LOOKUP_TYPE%TYPE;
   l_value_set_id    pay_input_values_f.VALUE_SET_ID%TYPE;
   l_currency_code   pay_element_types_f.input_currency_code%TYPE;
   l_count           number;
   l_found           number;
   l_rgeflg          varchar2(2);
--
   -- Bug: 5200900
   cursor csr_valid_lookup
          (p_lookup_type varchar2,
           p_meaning varchar2) IS
       SELECT HL.lookup_code
       FROM hr_lookups HL
       WHERE HL.lookup_type = p_lookup_type
       AND UPPER(HL.meaning) = UPPER(p_meaning);

   cursor csr_valid_lookup_code
          (p_lookup_type varchar2,
           p_lookup_code varchar2) IS
       SELECT HL.meaning
       FROM hr_lookups HL
       WHERE HL.lookup_type = p_lookup_type
       AND HL.lookup_code = p_lookup_code;
   --
   cursor csr_iv is
       select inv.UOM,
              inv.LOOKUP_TYPE,
              inv.VALUE_SET_ID,
              etp.input_currency_code
       from   pay_input_values_f  inv,
              pay_element_types_f etp
       where  inv.element_type_id   = p_element_type_id
       and    etp.element_type_id   = p_element_type_id
       and    p_session_date between inv.effective_start_date
                               and     inv.effective_end_date
       and    p_session_date between etp.effective_start_date
                               and     etp.effective_end_date
       order by inv.display_sequence,inv.name;

   CURSOR csr_input_value( p_element_type_id IN NUMBER
                          , p_input_value_number IN NUMBER
			  ) IS
    SELECT  piv.uom
          , piv.lookup_type
	  , piv.value_set_id
	  , pet.input_currency_code
    FROM    pay_input_values_f piv,
            pay_element_types_f  pet
   WHERE   piv.element_type_id = p_element_type_id
     AND   pet.element_type_id  = p_element_type_id
     AND   piv.input_value_id  = p_input_value_number
     AND   p_session_date BETWEEN piv.effective_start_date AND  piv.effective_end_date
     AND   p_session_date BETWEEN pet.effective_start_date AND  pet.effective_end_date
     ORDER BY piv.display_sequence,piv.name;
--
begin
    --hr_utility.trace_on(null,'RK');
    hr_utility.trace('  p_input_value  ->' || p_input_value);
    hr_utility.trace('     p_element_type_id   ->  ' || p_element_type_id   );
    hr_utility.trace('     p_input_value       ->  ' || p_input_value       );
    hr_utility.trace('     p_input_value_id -> ' || p_input_value_number);
    hr_utility.trace('     p_session_date       -> ' || p_session_date      );
    hr_utility.trace('     p_batch_id           -> ' || p_batch_id          );

--
   if p_input_value is null then
      return p_input_value;
   end if;
--
   l_count := 1;
   l_found := 0;

  for p_iv_rec in csr_iv loop
       --
       if l_count = p_input_value_number then
          l_uom_value       := p_iv_rec.uom;
          l_lookup_type     := p_iv_rec.LOOKUP_TYPE;
          l_value_set_id    := p_iv_rec.VALUE_SET_ID;
          l_currency_code   := p_iv_rec.input_currency_code;
          --
          l_found := 1;
          exit;
       end if;
       --
       l_count := l_count + 1;
       --
   end loop;
--
   if l_found = 0 then
      return p_input_value;
   end if;

 /*  OPEN csr_input_value(p_element_type_id, p_input_value_id);
   FETCH csr_input_value INTO l_uom_value, l_lookup_type, l_value_set_id, l_currency_code;
   IF csr_input_value%NOTFOUND THEN
      RETURN p_input_value;
   END IF; */



    hr_utility.trace('======================================================');
    hr_utility.trace('     p_input_value_id -> ' || p_input_value_number);
    hr_utility.trace('     l_uom_value   ->  ' || l_uom_value   );
    hr_utility.trace('     l_lookup_type       ->  ' || l_lookup_type       );
    hr_utility.trace('     l_value_set_id -> ' || l_value_set_id);
    hr_utility.trace('======================================================');

      --
      -- BBA now handles input value of date in canonical format.
      -- However the EE API expects the data in the DD-MON-YYYY format.
      -- The DD-MON-YYYY is the default format of the fnd_date.
      --
      hr_utility.trace('p_input_value, before D ->' || p_input_value);
      hr_utility.trace('l_display_value, before D ->' || l_display_value);
      if l_uom_value = 'D' then

         begin

		IF p_calling_mode = 'Q' THEN
			return p_input_value;
		END IF;

		l_display_value :=   fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_input_value));

		hr_utility.trace('after usind fnd_date package l_display_value: ' || l_display_value);
		hr_utility.trace('p_input_value in D ->' || p_input_value);
		hr_utility.trace('l_display_value in D ->' || l_display_value);

		exception

		when others then
		hr_utility.trace(' In Exception -> ' || l_display_value);
		hr_utility.set_message('PAY','PAY_6306_INPUT_VALUE_FORMAT');
		hr_utility.set_message_token('UNIT_OF_MEASURE', hr_general.decode_lookup ('UNITS', l_uom_value ));
		hr_utility.raise_error;
         end;

      else

	  begin

          hr_utility.trace('p_input_value in else ->' || p_input_value);
          hr_utility.trace('l_display_value in else ->' || l_display_value);
          l_display_value := p_input_value;

	  exception

            when others then
	    hr_utility.trace(' In Exception ->l_display_value := p_input_value; ' || l_display_value);
	    hr_utility.set_message('PAY','PAY_6306_INPUT_VALUE_FORMAT');
            hr_utility.set_message_token('UNIT_OF_MEASURE', hr_general.decode_lookup ('UNITS', l_uom_value ));
            hr_utility.raise_error;

	    end;

      end if;

      --
      if (l_lookup_type is not null and
          l_internal_value is not null) then
         --

	 -- Bug: 5200900

         IF p_calling_mode = 'Q' THEN
	    OPEN csr_valid_lookup_code(l_lookup_type, l_internal_value);
	    FETCH csr_valid_lookup_code into l_display_value;
	          IF csr_valid_lookup_code%FOUND THEN
		     return l_display_value;
		  END IF;
	    CLOSE csr_valid_lookup_code;
	 END IF;

         OPEN csr_valid_lookup(l_lookup_type, l_internal_value);
         FETCH csr_valid_lookup INTO l_display_value ;

         -- Bug: 5200900

	  IF csr_valid_lookup%NOTFOUND THEN

	    hr_utility.trace('ERROR: Invalid lookup Value');
	    hr_utility.raise_error();

	  ELSE

	    hr_utility.trace('Info: Valid lookup');

	    CASE p_input_value_number

		WHEN 1 THEN g_ee_value1 := l_display_value;
			    hr_utility.trace('Updated g_ee_value1 :' || g_ee_value1);
		WHEN 2 THEN g_ee_value2 := l_display_value;
			    hr_utility.trace('Updated g_ee_value2 :' || g_ee_value2);
		WHEN 3 THEN g_ee_value3 := l_display_value;
			    hr_utility.trace('Updated g_ee_value3 :' || g_ee_value3);
		WHEN 4 THEN g_ee_value4 := l_display_value;
			    hr_utility.trace('Updated g_ee_value4 :' || g_ee_value4);
		WHEN 5 THEN g_ee_value5 := l_display_value;
			    hr_utility.trace('Updated g_ee_value5 :' || g_ee_value5);
		WHEN 6 THEN g_ee_value6 := l_display_value;
			    hr_utility.trace('Updated g_ee_value6 :' || g_ee_value6);
		WHEN 7 THEN g_ee_value7 := l_display_value;
			    hr_utility.trace('Updated g_ee_value7 :' || g_ee_value7);
		WHEN 8 THEN g_ee_value8 := l_display_value;
			    hr_utility.trace('Updated g_ee_value8 :' || g_ee_value8);
		WHEN 9 THEN g_ee_value9 := l_display_value;
			    hr_utility.trace('Updated g_ee_value9 :' || g_ee_value9);
		WHEN 10 THEN g_ee_value10 := l_display_value;
			     hr_utility.trace('Updated g_ee_value10 :' || g_ee_value10);
		WHEN 11 THEN g_ee_value11 := l_display_value;
			     hr_utility.trace('Updated g_ee_value11 :' || g_ee_value11);
		WHEN 12 THEN g_ee_value12 := l_display_value;
			     hr_utility.trace('Updated g_ee_value12 :' || g_ee_value12);
		WHEN 13 THEN g_ee_value13 := l_display_value;
			     hr_utility.trace('Updated g_ee_value13 :' || g_ee_value13);
		WHEN 14 THEN g_ee_value14 := l_display_value;
			     hr_utility.trace('Updated g_ee_value14 :' || g_ee_value14);
		WHEN 15 THEN g_ee_value15 := l_display_value;
			     hr_utility.trace('Updated g_ee_value15 :' || g_ee_value15);
	    END CASE;

	  END IF;

         CLOSE csr_valid_lookup;

         --
      elsif (l_value_set_id is not null and
             l_internal_value is not null) then
         --
	 begin
         l_display_value := pay_input_values_pkg.decode_vset_value(
                              l_value_set_id, l_internal_value);

	 exception

            when others then
	    hr_utility.trace(' In Exception l_value_set_id is not null and-> ' || l_display_value);
	    hr_utility.set_message('PAY','PAY_6306_INPUT_VALUE_FORMAT');
            hr_utility.set_message_token('UNIT_OF_MEASURE', hr_general.decode_lookup ('UNITS', l_uom_value ));
            hr_utility.raise_error;

         end;

         --
      else
         --
	begin

	-- Bug: 5204994

	--   hr_chkfmt.changeformat(
	--    l_internal_value, /* the value to be formatted (out - display) */
	--    l_display_value,  /* the formatted value on output (out - canonical) */
	--    l_uom_value,      /* the format to check */
	--    l_currency_code );

        -- Replaced the above commented code with the following code for the bug# 5204994.

        hr_chkfmt.checkformat(l_internal_value,
	                      l_uom_value,
			      l_display_value,
			      null,
			      null,
			      'N',
			      l_rgeflg,
			      l_currency_code);

	 exception

            when others then
	    hr_utility.trace(' In Exception hr_chkfmt.changeformat(-> ' || l_display_value);
	    hr_utility.set_message('PAY','PAY_6306_INPUT_VALUE_FORMAT');
            hr_utility.set_message_token('UNIT_OF_MEASURE', hr_general.decode_lookup ('UNITS', l_uom_value ));
            hr_utility.raise_error;

         end;



	 --
      end if;
      --

   return l_display_value;
--
exception
   when others then
      hr_utility.set_message('PAY','PAY_6306_INPUT_VALUE_FORMAT');
      hr_utility.set_message_token('UNIT_OF_MEASURE', hr_general.decode_lookup ('UNITS', l_uom_value ));

hr_utility.raise_error;
--
end convert_internal_to_display;

end pay_batch_balanceadj_wrapper;

/
