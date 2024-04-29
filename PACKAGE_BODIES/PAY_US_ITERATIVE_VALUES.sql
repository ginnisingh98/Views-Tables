--------------------------------------------------------
--  DDL for Package Body PAY_US_ITERATIVE_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_ITERATIVE_VALUES" AS
/* $Header: pyusifun.pkb 120.0.12010000.2 2009/04/03 09:19:07 svannian ship $ */

PROCEDURE get_table_position (p_entry_id  in   number,
                              p_found     out nocopy boolean,
                              p_pos_index out nocopy number,
                              p_called_from    VARCHAR2 default null,
                              p_clear_asg      VARCHAR2 default null
                             ) is
p_count       number;
plsql_tab_entry_id     number;
start_cnt     number;
end_cnt       number;

begin

     hr_utility.trace('get_table_position');
     hr_utility.trace('EEID is : ' || to_char(p_entry_id));
     hr_utility.trace('p_called_from is : ' || p_called_from);

     p_found := FALSE;
     p_pos_index := 0;

     if p_called_from = 'STOPPER'  then
        p_count   := iter_stop.COUNT;
        start_cnt := iter_stop.FIRST;
        end_cnt   := iter_stop.LAST;
     elsif p_called_from = 'INS_FLAG' then
        p_count   := iter_ins.COUNT;
        start_cnt := iter_ins.FIRST;
        end_cnt   := iter_ins.LAST;
     elsif p_called_from = 'ITER_AMT' then
        p_count   := iter_amt.COUNT;
        start_cnt := iter_amt.FIRST;
        end_cnt   := iter_amt.LAST;
     elsif p_called_from = 'ITER_ELE' then
        p_count   := iter_ele_type.COUNT;
        start_cnt := iter_ele_type.FIRST;
        end_cnt   := iter_ele_type.LAST;
     else
        p_count   := iter_val.COUNT;
        start_cnt := iter_val.FIRST;
        end_cnt   := iter_val.LAST;
     end if;

     if p_count = 0 then

        p_found := FALSE;
        p_pos_index := 0;
        return;

     else

        hr_utility.trace('Value of COUNT is : ' || to_char(p_count));
        hr_utility.trace('Value of FIRST is : ' || to_char(start_cnt));
        hr_utility.trace('Value of LAST is : ' || to_char(end_cnt));
        hr_utility.trace('Value of p_clear_asg is : ' || p_clear_asg);

        for i in start_cnt .. end_cnt loop

          if p_clear_asg is null then

            if p_called_from = 'STOPPER'  then
               if iter_stop.EXISTS(i) then
                 hr_utility.trace('Iter Stop Value EXISTS');
                 plsql_tab_entry_id := iter_stop(i).entry_id;
               else
                 hr_utility.trace('Iter Stop Value Does Not EXISTS');
                 plsql_tab_entry_id := 0;
               end if;

            elsif p_called_from = 'INS_FLAG' then
                 if iter_ins.EXISTS(i) then
                   hr_utility.trace('Iter Ins Value EXISTS');
                   plsql_tab_entry_id := iter_ins(i).entry_id;
                 else
                   hr_utility.trace('Iter Ins Value Does Not EXISTS');
                   plsql_tab_entry_id := 0;
                 end if;

            elsif p_called_from = 'ITER_AMT' then
                 if iter_amt.EXISTS(i) then
                    hr_utility.trace('Iter Amt Value EXISTS');
                    plsql_tab_entry_id := iter_amt(i).entry_id;
                 else
                    hr_utility.trace('Iter Amt Value Does Not EXISTS');
                    plsql_tab_entry_id := 0;
                 end if;

            else
                 if iter_val.EXISTS(i) then
                    hr_utility.trace('Iter Val Value EXISTS');
                    plsql_tab_entry_id := iter_val(i).entry_id;
                 else
                    hr_utility.trace('Iter Val Value Does Not EXISTS');
                    plsql_tab_entry_id := 0;
                 end if;

            end if; /* p_called_from */

          else /* p_clear_asg is null */

            if p_called_from = 'STOPPER'  then
               if iter_stop.EXISTS(i) then
                 hr_utility.trace('Iter Stop Value EXISTS');
                 plsql_tab_entry_id := iter_stop(i).asg_id;
               else
                 hr_utility.trace('Iter Stop Value Does Not EXISTS');
                 plsql_tab_entry_id := 0;
               end if;

            elsif p_called_from = 'INS_FLAG' then
                 if iter_ins.EXISTS(i) then
                   hr_utility.trace('Iter Ins Value EXISTS');
                   plsql_tab_entry_id := iter_ins(i).asg_id;
                 else
                   hr_utility.trace('Iter Ins Value Does Not EXISTS');
                   plsql_tab_entry_id := 0;
                 end if;

            elsif p_called_from = 'ITER_AMT' then
                 if iter_amt.EXISTS(i) then
                    hr_utility.trace('Iter Amt Value EXISTS');
                    plsql_tab_entry_id := iter_amt(i).asg_id;
                 else
                    hr_utility.trace('Iter Amt Value Does Not EXISTS');
                    plsql_tab_entry_id := 0;
                 end if;

            elsif p_called_from = 'ITER_ELE' then
                 if iter_ele_type.EXISTS(i) then
                    hr_utility.trace('Iter Ele Value EXISTS');
                    plsql_tab_entry_id := iter_ele_type(i).asg_id;
                 else
                    hr_utility.trace('Iter Ele Value Does Not EXISTS');
                    plsql_tab_entry_id := 0;
                 end if;

            else
                 if iter_val.EXISTS(i) then
                    hr_utility.trace('Iter Val Value EXISTS');
                    plsql_tab_entry_id := iter_val(i).asg_id;
                 else
                    hr_utility.trace('Iter Val Value Does Not EXISTS');
                    plsql_tab_entry_id := 0;
                 end if;
            end if; /* p_called_from */

          end if; /* p_clear_asg is null */

            hr_utility.trace('PLSQL EEID is : ' || to_char(plsql_tab_entry_id));
            if ((p_entry_id = plsql_tab_entry_id) and (p_found = FALSE)) then

               p_found := TRUE;
               p_pos_index := i;
               return;

            end if;

        end loop;

     end if;

     hr_utility.trace('Value of p_pos_index is : ' || to_char(p_pos_index));
     return;

end; /* get_table_position */


FUNCTION get_stopper_flag ( p_entry_id      in     number)
RETURN VARCHAR2 IS

l_found_flag  boolean;
l_pos_no      number;

p_stopper_flag  varchar2(5);

BEGIN /* get_stopper_flag */

     hr_utility.trace('get_stopper_flag');

     get_table_position(p_entry_id,l_found_flag, l_pos_no,'STOPPER');

     if l_found_flag = FALSE then

        p_stopper_flag := 'N';
     else

        p_stopper_flag := 'Y';
     end if;

     hr_utility.trace('Value of p_stopper_flag is : '|| p_stopper_flag);
     return p_stopper_flag;

end; /* get_stopper_flag */

FUNCTION set_stopper_flag(p_entry_id      number,
                          p_asg_id        number,
                          p_stopper_flag  VARCHAR2)
RETURN NUMBER IS

l_pos_no    number;
l_found_flag     boolean;

BEGIN /* set_stopper_flag */

     hr_utility.trace('set_stopper_flag');

     get_table_position(p_entry_id,l_found_flag, l_pos_no,'STOPPER');

     hr_utility.trace('l_pos_no = '|| to_char(l_pos_no));

     if l_found_flag = FALSE then

        hr_utility.trace('Found Flag is FALSE ');
        l_pos_no := iter_stop.COUNT + 1;
        hr_utility.trace('increasing l_pos_no = '|| to_char(l_pos_no));

        iter_stop(l_pos_no).entry_id  := p_entry_id;
        iter_stop(l_pos_no).asg_id    := p_asg_id;
        iter_stop(l_pos_no).stop_flag := 'Y';

     end if;

     return 1;

end; /* set_stopper_flag */


FUNCTION get_iterative_value(
                          p_entry_id        in     number,
                          iteration_number  in     number,
                          max_deduction     out nocopy   number,
                          min_deduction     out nocopy   number,
                          p_desired_amt     out nocopy   number,
                          p_calc_method     out nocopy   varchar2,
                          p_to_within       out nocopy   number,
                          p_clr_add_amt     out nocopy   number,
                          p_clr_rep_amt     out nocopy   number )
RETURN NUMBER IS

new_deduction number;
p_count       number;

l_found_flag  boolean;
l_pos_no      number;

BEGIN /* get_iterative_value */

     hr_utility.trace('get_iterative_value');

     get_table_position(p_entry_id,l_found_flag, l_pos_no);

     if l_found_flag = FALSE then

        max_deduction := 0;
        min_deduction := 0;
        new_deduction := 0;
        p_desired_amt := 0;
        p_calc_method := 'Interpolation';
        p_to_within   := 1;
        p_clr_add_amt := 0;
        p_clr_rep_amt := 0;
     else

        max_deduction := iter_val(l_pos_no).max_dedn;
        min_deduction := iter_val(l_pos_no).min_dedn;
        new_deduction := iter_val(l_pos_no).new_dedn;
        p_desired_amt := iter_val(l_pos_no).des_amt;
        p_calc_method := iter_val(l_pos_no).calc_method;
        p_to_within   := iter_val(l_pos_no).to_within;
        p_clr_add_amt := iter_val(l_pos_no).clr_add_amt;
        p_clr_rep_amt := iter_val(l_pos_no).clr_rep_amt;

     end if;

     hr_utility.trace('Value of max is : ' || to_char(max_deduction));
     hr_utility.trace('Value of min is : ' || to_char(min_deduction));
     hr_utility.trace('Value of new is : ' || to_char(new_deduction));
     hr_utility.trace('Value of Desired Amt is : ' || to_char(p_desired_amt));
     hr_utility.trace('Value of Calc Method is : ' || p_calc_method);
     hr_utility.trace('Value of To Within is : ' || to_char(p_to_within));
     hr_utility.trace('Value of Clr Add Amt is : ' || to_char(p_clr_add_amt));
     hr_utility.trace('Value of Clr Rep Amt is : ' || to_char(p_clr_rep_amt));

     return new_deduction;

END; /* get_iterative_value */

FUNCTION set_iterative_value(
                          p_entry_id        number,
                          p_asg_id          number,
                          iteration_number  number,
                          max_deduction     number,
                          min_deduction     number,
                          new_deduction     number,
                          p_desired_amt     number,
                          p_calc_method     varchar2,
                          p_to_within       number,
                          p_clr_add_amt     number,
                          p_clr_rep_amt     number  )
RETURN NUMBER IS

l_pos_no    number;
l_found_flag     boolean;

BEGIN /* set_iterative_value */
     hr_utility.trace('set_iterative_value');

     get_table_position(p_entry_id,l_found_flag, l_pos_no);

     hr_utility.trace('l_pos_no is '|| to_char(l_pos_no));

     if l_found_flag = FALSE then
        l_pos_no := iter_val.COUNT  + 1;
        iter_val(l_pos_no).entry_id := p_entry_id;
        iter_val(l_pos_no).asg_id   := p_asg_id;
     end if;

        iter_val(l_pos_no).iter_no  := iteration_number;
        iter_val(l_pos_no).max_dedn := max_deduction;
        iter_val(l_pos_no).min_dedn := min_deduction;
        iter_val(l_pos_no).new_dedn := new_deduction;
        iter_val(l_pos_no).des_amt  := p_desired_amt;
        iter_val(l_pos_no).calc_method  := p_calc_method;
        iter_val(l_pos_no).to_within  := p_to_within;
        iter_val(l_pos_no).clr_add_amt  := p_clr_add_amt;
        iter_val(l_pos_no).clr_rep_amt  := p_clr_rep_amt;


     hr_utility.trace('Iter No is :' || to_char(iter_val(l_pos_no).iter_no));
     hr_utility.trace('Max is :' || to_char(iter_val(l_pos_no).max_dedn));
     hr_utility.trace('Min is :' || to_char(iter_val(l_pos_no).min_dedn));
     hr_utility.trace('New is :' || to_char(iter_val(l_pos_no).new_dedn));
     hr_utility.trace('Desired Amt is :' || to_char(iter_val(l_pos_no).des_amt));
     hr_utility.trace('Calc Method is :' || iter_val(l_pos_no).calc_method);
     hr_utility.trace('To Within is :' || to_char(iter_val(l_pos_no).to_within));
     hr_utility.trace('Clr Add Amt is :' || to_char(iter_val(l_pos_no).clr_add_amt));
     hr_utility.trace('Clr Rep Amt is :' || to_char(iter_val(l_pos_no).clr_rep_amt));

     return new_deduction;

END; /* set_iterative_value */

FUNCTION clear_iterative_value(p_entry_id        in  number)
RETURN NUMBER IS

p_count     number;
l_pos_no    number;
l_found_flag     boolean;

BEGIN /* clear_iterative_value */

     hr_utility.trace('In clear_iterative_value ');

     get_table_position(p_entry_id,l_found_flag, l_pos_no);

     hr_utility.trace('Position = ' || to_char(l_pos_no));

     if l_found_flag then
        hr_utility.trace('Found flag is true');
        iter_val.DELETE(l_pos_no) ;

     end if;

/* clear the iter_amt plsql table also. This is used by 401,403 and 457
   elements. */

     get_table_position(p_entry_id,l_found_flag, l_pos_no,'ITER_AMT');
     hr_utility.trace('Position = ' || to_char(l_pos_no));

     if l_found_flag then
        hr_utility.trace('Found flag is true');
        iter_amt.DELETE(l_pos_no) ;

     end if;

     return 1;

END; /* clear_iterative_value */

FUNCTION clear_on_asg(p_asg_id        in  number,
                      p_aaid          in  number)
RETURN NUMBER IS

p_count     number;
l_pos_no    number;
l_found_flag     boolean;

BEGIN /* clear_on_asg */

/* we need to check the assignment_action_id for a seperate check run.
   if the AAID is different then we clear the tables for the assignment.
   for seperate check runs the Assignment Id and element entry id would
   be same but AAID would be different.

   So if we get a different AAID we see if we have a record saved for that
   assignment id, if yes then delete it else do nothing. */

     hr_utility.trace('In clear_on_asg ');
     hr_utility.trace('g_aaid = ' || to_char(g_aaid));
     hr_utility.trace('p_aaid = ' || to_char(p_aaid));
     hr_utility.trace('p_asg_id = ' || to_char(p_asg_id));

     if ((g_aaid is null) OR
         (g_aaid <> p_aaid )) then

           iter_stop.DELETE ;
           iter_amt.DELETE ;
           iter_val.DELETE ;
           iter_ele_type.DELETE ;
           iter_ins.DELETE ;

        g_aaid := p_aaid;

     end if; /* g_aaid is null or <> p_aaid */

     return 1;

END; /* clear_on_asg */


FUNCTION get_iter_count(p_entry_id in  number  )
RETURN NUMBER IS

iter_count    number := 0;
p_flag        varchar2(5);
p_count       number ;

l_pos_no    number;
l_found_flag     boolean;

BEGIN /* get_iter_count */

     hr_utility.trace('In get_iter_count');

     get_table_position(p_entry_id,l_found_flag, l_pos_no);

     hr_utility.trace('Value of l_pos_no is : '||to_char(l_pos_no));

     if l_found_flag = FALSE then

        iter_count := l_pos_no ;
     else
        iter_count := iter_val(l_pos_no).iter_no;
     end if;

     hr_utility.trace('Value of iter count is : '||to_char(iter_count));
     return iter_count;

END; /* get_iter_count */

FUNCTION inc_iter_count(p_entry_id in  number)
RETURN NUMBER IS

p_count   number;

l_pos_no    number;
l_found_flag     boolean;

BEGIN /* inc_iter_count */

     hr_utility.trace('In inc_iter_count');

     get_table_position(p_entry_id,l_found_flag, l_pos_no);

     hr_utility.trace('l_pos_no is : '|| to_char(l_pos_no));
     if l_found_flag = FALSE then

        raise NO_DATA_FOUND;
     else

        iter_val(l_pos_no).iter_no := iter_val(l_pos_no).iter_no + 1;
     end if;

     return iter_val(l_pos_no).iter_no;

END; /* inc_iter_count */

FUNCTION Iterative_Arrearage (
                        p_eletype_id            IN NUMBER,
                        p_date_earned           IN DATE,
                        p_assignment_id         IN NUMBER ,
                        p_ele_entry_id          IN NUMBER,
                        p_partial_flag          IN VARCHAR2 ,
                        p_net_asg_run           IN NUMBER,
                        p_arrears_itd           IN NUMBER,
                        p_guaranteed_net        IN NUMBER,
                        p_dedn_amt              IN NUMBER,
                        p_amount                IN NUMBER,
                        p_iter_count            IN NUMBER,
                        p_to_arrears            IN OUT nocopy NUMBER,
                        p_not_taken             IN OUT nocopy NUMBER,
                        p_ins_flag              IN VARCHAR2)
RETURN NUMBER IS

l_dedn_amt              NUMBER(27,7);    -- local var
v_arrears_flag          VARCHAR2(1);


Begin

     hr_utility.trace('p_iter_count= '|| to_char(p_iter_count));
     hr_utility.trace('p_amount= '|| to_char(p_amount));
     hr_utility.trace('p_dedn_amt= '|| to_char(p_dedn_amt));
     hr_utility.trace('p_arrears_itd= '|| to_char(p_arrears_itd));
     hr_utility.trace('p_ins_flag= '|| p_ins_flag);

     /* call the arrearage function if this the first call from the
        formula */

     if p_iter_count <= 1  and p_ins_flag = 'N' then /* main */

        hr_utility.trace('Calling Arrearage');
        l_dedn_amt := hr_us_ff_udfs.Arrearage (
                        p_eletype_id       => p_eletype_id,
                        p_date_earned      => p_date_earned,
                        p_assignment_id    => p_assignment_id , /* 6970340 */
                        p_ele_entry_id     => p_ele_entry_id ,
                        p_partial_flag     => p_partial_flag,
                        p_net_asg_run      => p_net_asg_run,
                        p_arrears_itd      => p_arrears_itd,
                        p_guaranteed_net   => p_guaranteed_net,
                        p_dedn_amt         => p_dedn_amt,
                        p_to_arrears       => p_to_arrears,
                        p_not_taken        => p_not_taken  );

     else /* main */

       p_to_arrears := 0;
       p_not_taken  := 0;

-- Determine if Arrears = 'Y' for this dedn
-- Can do this by checking for "Clear Arrears" input value on base ele.
-- This input value is only created when Arrears is marked Yes on Deductions
-- screen.

       begin

            select  'Y'  into    v_arrears_flag
            from    pay_input_values_f ipv
            where   ipv.name  = 'Clear Arrears'
              and   p_date_earned  BETWEEN ipv.effective_start_date
                                       AND ipv.effective_end_date
              and   ipv.element_type_id  = p_eletype_id;

       exception

         WHEN NO_DATA_FOUND THEN
           hr_utility.set_location('Arrearage is NOT ON for this ele.', 99);
           v_arrears_flag := 'N';

         WHEN TOO_MANY_ROWS THEN
           hr_utility.set_location('Too many rows returned for Clear Arrears inpval.', 99);
           v_arrears_flag := 'N';

       end;

       hr_utility.trace('value of arrear flag : '|| v_arrears_flag);
       hr_utility.trace('Partial Flag= '|| p_partial_flag);

       IF v_arrears_flag = 'N' THEN

          if p_partial_flag = 'N' then

             p_to_arrears := 0;
             if p_dedn_amt <> p_amount then
                p_not_taken  := p_amount;
                l_dedn_amt   := 0;
             else
                p_not_taken := 0;
                l_dedn_amt  := p_amount;
             end if;

          else /* p_partial_flag =  Y  */

             p_to_arrears := 0;
             p_not_taken  := p_amount - p_dedn_amt;
             l_dedn_amt   := p_dedn_amt;
          end if;

       else /* clear_arrear = Y */

          if p_partial_flag = 'N' then

             if p_dedn_amt < p_amount then
                p_to_arrears := p_amount;
                p_not_taken  := p_amount;
                l_dedn_amt   := 0;
             else
                p_to_arrears := 0;
                p_not_taken  := 0;
                l_dedn_amt   := p_dedn_amt;
             end if;

          else /* p_partial_flag =  Y  */

             p_to_arrears := p_amount - p_dedn_amt;
             if p_dedn_amt > p_amount then
                p_not_taken := 0;
             else
                p_not_taken  := p_amount - p_dedn_amt;
             end if;
             l_dedn_amt   := p_dedn_amt;

          end if; /* p_partial_flag */
       end if;    /* clear_arrear = Y */

     end if; /* main */

     return l_dedn_amt;

END Iterative_Arrearage;

FUNCTION reduces_disposable_income (
                        p_assignment_id IN NUMBER,
                        p_date_earned   IN DATE,
                        p_element_type_id  IN NUMBER,
                        p_tax_type      IN pay_balance_types.tax_type%TYPE)
RETURN VARCHAR2 IS

cursor c_garn_ele_exists is

       select
             pet.element_name
             ,piv.name
             ,peev.screen_entry_value
       from pay_element_entries_f peef,
            pay_element_entry_values_f peev,
            pay_input_values_f piv,
            pay_element_links_f pel,
            pay_element_types_f pet,
            pay_element_classifications pec
       where peef.assignment_id = p_assignment_id
         and peef.creator_type <> 'UT'
         and p_date_earned between peef.effective_start_date
                               and peef.effective_end_date
         and peef.element_entry_id = peev.element_entry_id
         and p_date_earned between peev.effective_start_date
                               and peev.effective_end_date
         and peev.input_value_id = piv.input_value_id
         and piv.element_type_id = pet.element_type_id
         and piv.name = 'Jurisdiction'
         and p_date_earned between piv.effective_start_date
                               and piv.effective_end_date
         and peef.element_link_id = pel.element_link_id
         and p_date_earned between pel.effective_start_date
                               and pel.effective_end_date
         and pel.element_type_id = pet.element_type_id
         and p_date_earned between pet.effective_start_date
                               and pet.effective_end_date
         and pec.classification_id = pet.classification_id
         and pec.classification_name = 'Involuntary Deductions';

CURSOR csr_get_info is
       select taxability_rules_date_id
       from   pay_taxability_rules_dates
       where  p_date_earned between valid_date_from and
                                    valid_date_to
       and    legislation_code = 'US';


CURSOR csr_tax_rules_exists(
        p_juri_code         VARCHAR2,
        p_tax_cat           pay_taxability_rules.tax_category%TYPE,
        p_classification_id pay_element_classifications.classification_id%TYPE,
        p_tax_rules_date_id pay_taxability_rules.taxability_rules_date_id%TYPE
) is
       select 'Y'
       from   pay_taxability_rules
       where  jurisdiction_code        = p_juri_code
       and    tax_type                 = p_tax_type
       and    tax_category             = p_tax_cat
       and    classification_id        = p_classification_id
       and    taxability_rules_date_id = p_tax_rules_date_id
       and    legislation_code         = 'US'
       and    nvl(status,'VALID') <> 'D';


CURSOR csr_work_location is
       select ps.state_code
       from   hr_locations             hrl
            , hr_soft_coding_keyflex   hrsckf
            , per_all_assignments_f    paf
            , pay_us_states            ps
       where p_date_earned BETWEEN paf.effective_start_date
                               and paf.effective_end_date
         and paf.assignment_id = p_assignment_id
         and paf.soft_coding_keyflex_id = hrsckf.soft_coding_keyflex_id
         and nvl(hrsckf.segment18,paf.location_id) = hrl.location_id
         and ps.state_abbrev = nvl(hrl.loc_information17,hrl.region_2);

CURSOR c_get_tax_cat is
       select pet.element_information1, pet.classification_id
       from pay_element_types_f pet
       where pet.element_type_id = p_element_type_id
         and p_date_earned between pet.effective_start_date
                               and pet.effective_end_date;

l_cur_ele_tax_cat  pay_element_types_f.element_information1%TYPE;
l_fed    VARCHAR2(5);
l_state  VARCHAR2(5);

l_tax_rules_date_id    pay_taxability_rules_dates.taxability_rules_date_id%TYPE;
l_classification_id    pay_element_classifications.classification_id%TYPE;
l_element_name         pay_element_types_f.element_name%TYPE;
l_ip_val_name          pay_input_values_f.name%TYPE;
l_value                pay_element_entry_values_f.screen_entry_value%TYPE;

l_other  varchar2(5);

BEGIN

     hr_utility.trace('In reduces_disposable_income ');
     hr_utility.trace('Input assignment id is : '|| to_char(p_assignment_id));
     hr_utility.trace('Input Date earned is : '|| p_date_earned);
     hr_utility.trace('Input Tax Type is : '|| p_tax_type);

     open csr_get_info;
     fetch csr_get_info INTO l_tax_rules_date_id;
     close csr_get_info;

     hr_utility.trace('Tax Rule Date Id is : '|| to_char(l_tax_rules_date_id));

     open c_get_tax_cat;
     fetch c_get_tax_cat into l_cur_ele_tax_cat,l_classification_id;
     close c_get_tax_cat;

     l_other := 'N';

     open c_garn_ele_exists;
     loop
         fetch c_garn_ele_exists  into l_element_name,
                                       l_ip_val_name,l_value;

         exit  when c_garn_ele_exists%NOTFOUND;

         hr_utility.trace('Garnishment Element exists ');
         hr_utility.trace('Classification Id : '||to_char(l_classification_id));
         hr_utility.trace('Element Name is : '|| l_element_name);
         hr_utility.trace('Tax Category is : '|| l_cur_ele_tax_cat);
         hr_utility.trace('Input Value Name is : '|| l_ip_val_name);
         hr_utility.trace('Value is : '|| l_value);

         open csr_tax_rules_exists('00-000-0000',l_cur_ele_tax_cat,
                                   l_classification_id,l_tax_rules_date_id);
         fetch csr_tax_rules_exists into l_fed;
         close csr_tax_rules_exists;

         hr_utility.trace('Federal Taxability Rule is : '|| l_fed);

         if l_fed = 'Y' then
            -- Addded code check for DCIA as DCIA has Earning rules
            -- defined only at Federal level.
            if p_tax_type <> 'DCIA' then

               if l_value is null then
                  open csr_work_location;
                  fetch csr_work_location into l_value;
                  close csr_work_location;
                  hr_utility.trace('Work Location is : '|| l_value);
               end if; /* l_value is null */

               l_value := l_value || '-000-0000';

               open csr_tax_rules_exists(l_value,l_cur_ele_tax_cat,
                                         l_classification_id,l_tax_rules_date_id);
               fetch csr_tax_rules_exists into l_state;
               if csr_tax_rules_exists%FOUND then
                  l_other := l_state;
               else
                  l_other := 'N';
               end if;
               close csr_tax_rules_exists;

               hr_utility.trace('State Taxability Rule is : '|| l_state);
            else
               l_other := 'Y';
            end if; /* p_tax_type != 'DCIA' */

         end if; /* l_fed = 'Y' */

     end loop;
     close c_garn_ele_exists;

     return l_other;

END reduces_disposable_income;

FUNCTION partial_deduction_allowed (
                        p_element_type_id   IN NUMBER,
                        p_date_earned       IN DATE )
RETURN VARCHAR2 IS

cursor c_get_partial_info is

       select pet.element_information2
       from   pay_element_types_f    pet
       where  pet.element_type_id = p_element_type_id
       and    p_date_earned BETWEEN pet.effective_start_date
                                AND pet.effective_end_date;

l_partial_deduction    pay_element_types_f.element_information2%TYPE;

Begin
     hr_utility.trace('In partial_deduction_allowed function');
     hr_utility.trace('Element Type Id is : '|| to_char(p_element_type_id));

     open c_get_partial_info;
     fetch c_get_partial_info into l_partial_deduction;
     close c_get_partial_info;

     hr_utility.trace('l_partial_deduction is : '|| l_partial_deduction);
     if l_partial_deduction is null then
        return 'N';
     else
        return l_partial_deduction;
     end if;

END partial_deduction_allowed;

FUNCTION set_processing_element(p_asg_id   in  number,
                                p_ele_type in  varchar2)
RETURN NUMBER IS

p_found     boolean;
p_cnt       number;

BEGIN /* set_processing_element */
     hr_utility.trace('In set_processing_element');

     if iter_ele_type.COUNT = 0 then
       p_cnt := iter_ele_type.COUNT + 1;
       iter_ele_type(p_cnt).ele_type := p_ele_type;
       iter_ele_type(p_cnt).asg_id   := p_asg_id;
       return 2;
     end if;

     for i in iter_ele_type.FIRST .. iter_ele_type.LAST loop

        if (p_ele_type = iter_ele_type(i).ele_type  and (p_found = FALSE))then

           p_found := TRUE;
           return 1;
        end if;

    end loop;

    if not p_found then

       hr_utility.trace('Inserting ');
       p_cnt := iter_ele_type.COUNT + 1;
       iter_ele_type(p_cnt).ele_type := p_ele_type;
       iter_ele_type(p_cnt).asg_id   := p_asg_id;
    end if;

    return 1;

END; /* set_processing_element */

FUNCTION get_processing_element(p_ele_type IN  varchar2)
RETURN VARCHAR2 IS

p_found   boolean;
p_out_val varchar2(50);

BEGIN /* get_processing_element */

     hr_utility.trace('In get_processing_element');

     if iter_ele_type.COUNT = 0 then
        p_out_val := 'Not Found';
        return p_out_val;

     end if;

     for i in iter_ele_type.FIRST .. iter_ele_type.LAST loop

        if (p_ele_type = iter_ele_type(i).ele_type  and (p_found = FALSE))then

           p_found := TRUE;
           p_out_val := p_ele_type;
        end if;

    end loop;

    if not p_found then

       hr_utility.trace('Not Found');
       p_out_val := 'Not Found';
    end if;

   return p_out_val;

END; /* get_processing_element */

FUNCTION set_inserted_flag (p_entry_id in  number,
                            p_asg_id   in  number,
                            p_ins_flag in  varchar2 )
RETURN VARCHAR2 IS

l_pos_no    number;
l_found_flag     boolean;
cnt       number;

BEGIN /* set_inserted_flag */

     hr_utility.trace('In set_inserted_flag');

     get_table_position(p_entry_id,l_found_flag, l_pos_no,'INS_FLAG');

     hr_utility.trace('l_pos_no is '|| to_char(l_pos_no));

     if l_found_flag = FALSE then
       cnt := iter_ins.COUNT + 1;
       iter_ins(cnt).entry_id := p_entry_id;
       iter_ins(cnt).asg_id   := p_asg_id;
       iter_ins(cnt).ins_flag := p_ins_flag;
     end if;

       return p_ins_flag;

END; /* set_inserted_flag */


FUNCTION get_inserted_flag (p_entry_id in  number)
RETURN VARCHAR2 IS

l_found_flag   boolean;
l_pos_no       number;

p_ins_flag  varchar2(5);

BEGIN /* get_inserted_flag */

     hr_utility.trace('In get_inserted_flag');

     get_table_position(p_entry_id,l_found_flag, l_pos_no,'INS_FLAG');

     hr_utility.trace('l_pos_no is '|| to_char(l_pos_no));

     if l_found_flag = FALSE then
        p_ins_flag := 'N';
     else
        p_ins_flag := 'Y';
     end if;

     return p_ins_flag;

END; /* get_inserted_flag */


FUNCTION get_iter_amt (p_entry_id   in  number,
                       p_passed_amt in out nocopy number)
RETURN NUMBER IS

l_pos_no    number;
l_found_flag     boolean;

p_calc_amt  number;

BEGIN /* get_iter_amt */

     hr_utility.trace('In get_iter_amt');

     get_table_position(p_entry_id,l_found_flag, l_pos_no,'ITER_AMT');

     hr_utility.trace('Value of l_pos_no is : '||to_char(l_pos_no));

     if l_found_flag = FALSE then

        p_calc_amt   := 0;
        p_passed_amt := 0;
     else
        p_calc_amt   := iter_amt(l_pos_no).calc_amt;
        p_passed_amt := iter_amt(l_pos_no).passed_amt;
     end if;

   return p_calc_amt;

END; /* get_iter_amt */

FUNCTION set_iter_amt (p_entry_id   in number,
                       p_asg_id     in number,
                       p_calc_amt   in number,
                       p_passed_amt in number)
RETURN NUMBER IS

l_pos_no    number;
l_found_flag     boolean;

BEGIN /* set_iter_amt */

     hr_utility.trace('In set_iter_amt');
     get_table_position(p_entry_id,l_found_flag, l_pos_no,'ITER_AMT');

     hr_utility.trace('Value of l_pos_no is : '||to_char(l_pos_no));

     if l_found_flag = FALSE then

        l_pos_no := iter_amt.COUNT  + 1;
        iter_amt(l_pos_no).entry_id := p_entry_id ;
        iter_amt(l_pos_no).asg_id   := p_asg_id ;

     end if;

        iter_amt(l_pos_no).calc_amt := p_calc_amt ;
        iter_amt(l_pos_no).passed_amt := p_passed_amt;

   return 1;

END; /* set_iter_amt */

FUNCTION clear_iter_ins
RETURN NUMBER IS

l_count NUMBER;

BEGIN /* clear_iter_ins */
     hr_utility.trace('In clear_iter_ins ');

     l_count := iter_ins.count;
     if l_count > 0 then
        iter_ins.DELETE;
     end if;
  return 1;
END; /* clear_iter_ins */

END pay_us_iterative_values;


/
