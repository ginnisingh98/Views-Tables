--------------------------------------------------------
--  DDL for Package Body PAY_ADHOC_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ADHOC_UTILS_PKG" AS
/* $Header: pyadcutl.pkb 120.3.12000000.1 2007/01/17 15:14:59 appldev noship $ */

g_package  constant varchar2(33) := '  pay_adhoc_utils_pkg.';
--
--
PROCEDURE  pupulate_input_name(p_element_entry_id number,
                                 p_start_date       date,
                                 p_end_date         date,
                                 p_ele_start_date   date,
                                 p_ele_end_date     date ) is
--
  CURSOR c_input_name_value(cp_element_entry_id number,
                            cp_start_date       date,
                            cp_end_date         date,
                            cp_ele_start_date   date,
                            cp_ele_end_date     date) is
      SELECT pivtl.name  Name,
             peev.screen_entry_value value ,
             piv.lookup_type lookup_type,
             piv.value_set_id ,
	     hr_bis.bis_decode_lookup('PROCESSING_TYPE',pet.PROCESSING_TYPE) Recurring,
             pettl.element_name element_name,
	     pectl.classification_name classification
      FROM   pay_element_entries_f      pee,
 	     pay_element_types_f        pet,
             pay_element_types_f_tl     pettl,
             pay_element_entry_values_f peev,
             pay_input_values_f         piv,
             pay_input_values_f_tl      pivtl  ,
             pay_element_classifications pec,
	     pay_element_classifications_tl pectl
      WHERE  pet.element_type_id = pee.element_type_id
      and    pet.element_type_id = pettl.element_type_id
      and    pettl.language = userenv('LANG')
      and    pec.classification_id = pectl.classification_id
      and    pectl.language = userenv('LANG')
      and    pet.classification_id = pec.classification_id
      AND    piv.input_value_id  = pivtl.input_value_id
      AND    pivtl.language = userenv('LANG')
      AND    peev.input_value_id  = piv.input_value_id
      AND    pet.element_type_id  = piv.element_type_id
      AND    pee.element_entry_id = peev.element_entry_id
      AND    pee.creator_type <> 'UT'
      AND    cp_start_date between pet.effective_start_date
                                   and pet.effective_end_date
      AND    cp_start_date between piv.effective_start_date
                               and piv.effective_end_date
      AND    pee.effective_start_date  = cp_ele_start_date
      AND    pee.effective_end_date    = cp_ele_end_date
      AND    peev.effective_start_date = cp_ele_start_date
      AND    peev.effective_end_date   = cp_ele_end_date
      AND    pee.element_entry_id      = cp_element_entry_id
      ORDER BY piv.display_sequence ;
--
v_input_name_value   c_input_name_value%rowtype;
v_index              number ;
--
BEGIN
--
   v_index := 1 ;
--
     FOR v_input_name_value IN c_input_name_value(p_element_entry_id,
                                                  p_start_date,
                                                  p_end_date,
                                                  p_ele_start_date,
                                                  p_ele_end_date)    LOOP
--
--
     hr_utility.set_location('v_index '||v_index,30);
--
     if v_index = 1 then
        g_input_name_value_tab(v_index).v_element_name := v_input_name_value.element_name;
        g_input_name_value_tab(v_index).v_classification := v_input_name_value.classification;
        g_input_name_value_tab(v_index). v_recurring := v_input_name_value.recurring;
     end if;
--
        g_input_name_value_tab(v_index).v_input_name := v_input_name_value.name;
--
        IF  v_input_name_value.lookup_type IS NOT NULL THEN
            g_input_name_value_tab(v_index).v_input_value := hr_bis.bis_decode_lookup
	                                 (v_input_name_value.lookup_type,v_input_name_value.value);
--
        ELSIF v_input_name_value.value_set_id IS NOT NULL THEN
	    g_input_name_value_tab(v_index).v_input_value := pay_input_values_pkg.decode_vset_value
                                        (v_input_name_value.value_set_id,v_input_name_value.value);
--
        ELSE
            g_input_name_value_tab(v_index).v_input_value := v_input_name_value.value;
--
        END IF;
--
	hr_utility.set_location('g_input_name_value_tab(v_index) '||
	                         g_input_name_value_tab(v_index).v_input_name,40);
	hr_utility.set_location('g_input_name_value_tab(v_index) '||
	                         g_input_name_value_tab(v_index).v_input_value,50);
        v_index := v_index + 1 ;
--
     END LOOP;
--
     FOR  x IN v_index..15 LOOP
       g_input_name_value_tab(x).v_input_name  := null;
       g_input_name_value_tab(x).v_input_value := null;
     END LOOP;
--
--
   g_element_entry_id     := p_element_entry_id ;
   g_effective_start_date := p_ele_start_date;
   g_effective_end_date   := p_ele_end_date  ;
--
--
EXCEPTION
       WHEN others THEN
             NULL;
--
END pupulate_input_name;
--
--
FUNCTION decode_OPM_territory ( p_territory_code varchar2,
                                p_business_group_id number )
RETURN VARCHAR2
IS
--
l_territory_short_name fnd_territories_vl.territory_short_name%type;
l_proc  constant varchar2(72) := g_package||'decode_OPM_territory';

cursor csr_territory is
   select  territory_short_name
     from  fnd_territories_vl
    where  territory_code  = nvl(p_territory_code, hr_api.return_legislation_code(p_business_group_id));
--
BEGIN
--
  hr_utility.set_location('Entering:'|| l_proc, 10);

     open  csr_territory;
     fetch csr_territory into l_territory_short_name;
     close csr_territory;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
  return l_territory_short_name;
--
END decode_OPM_territory;
--
FUNCTION decode_currency_code ( p_currency_code varchar2 )
RETURN VARCHAR2
IS
--
l_currency_name fnd_currencies_vl.name%type;
l_proc  constant varchar2(72) := g_package||'decode_currency_code';

cursor csr_currency is
   select name
     from fnd_currencies_vl
    where currency_code = p_currency_code;
--
BEGIN
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  if p_currency_code is not null then

     open csr_currency;
     fetch csr_currency into l_currency_name;
     close csr_currency;

  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
  return l_currency_name;
--
END decode_currency_code;
--
FUNCTION decode_event_group   ( p_event_group_id varchar2 )
RETURN VARCHAR2
IS
--
l_event_group_name  pay_event_groups.event_group_name%type;
l_proc  constant varchar2(72) := g_package||'decode_event_group';

cursor csr_event_group is
   select event_group_name
     from pay_event_groups
    where event_group_id = p_event_group_id;
--
BEGIN
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  if p_event_group_id is not null then

     open csr_event_group;
     fetch csr_event_group into l_event_group_name;
     close csr_event_group;

  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
  return l_event_group_name;
--
END decode_event_group;
--
FUNCTION get_element_link_status ( p_status  varchar2,
                                   p_link_start_date  date,
                                   p_link_end_date    date,
                                   p_effective_start_date date,
                                   p_effective_end_date   date,
                                   p_effective_date   date
                                  )
RETURN VARCHAR2
IS
--
l_active hr_lookups.meaning%type;
l_inactive hr_lookups.meaning%type;
l_proc  constant varchar2(72) := g_package||'get_element_link_status';
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
   l_active := hr_bis.bis_decode_lookup( 'ACTIVE_INACTIVE', 'A');
   l_inactive := hr_bis.bis_decode_lookup( 'ACTIVE_INACTIVE', 'I');

-- If status is null, both active and inactive records are displayed.
-- If the status is active then only active records as of the effective dates are displayed.
-- If the status is inactive then only inactive records as of the effective dates are displayed.
-- For Active records, row with effective date between effective start date
-- and effective end date is displayed.
-- For Inactive records, the first row is displayed since none of the rows have
-- effective date between effective start date and effective end date.

   if p_status is null then
      if p_effective_date between p_link_start_date and p_link_end_date then
         if p_effective_date between p_effective_start_date and p_effective_end_date then
            hr_utility.set_location(l_proc, 15);
            return 'ACTIVE';
         else
            hr_utility.set_location(l_proc, 20);
            return l_inactive;
         end if;
      else
         if p_effective_start_date = p_link_start_date then
            hr_utility.set_location(l_proc, 25);
            return 'ACTIVE';
         else
            hr_utility.set_location(l_proc, 30);
            return l_inactive;
         end if;
      end if;
   elsif p_status = l_active then
      if p_effective_date between p_effective_start_date and p_effective_end_date then
          hr_utility.set_location(l_proc, 35);
          return l_active;
      else
          hr_utility.set_location(l_proc, 40);
          return l_inactive;
      end if;
   elsif p_status = l_inactive then
      if p_effective_date not between p_link_start_date and p_link_end_date then
         if p_effective_start_date = p_link_start_date then
           hr_utility.set_location(l_proc, 45);
           return l_inactive;
         else
           hr_utility.set_location(l_proc, 50);
           return l_active;
         end if;
      else
         hr_utility.set_location(l_proc, 55);
         return l_active;
      end if;
   end if;

   hr_utility.set_location('Leaving:'|| l_proc, 60);
   return l_active;
--
END get_element_link_status;
--
FUNCTION decode_element_type ( p_element_type_id varchar2,
                               p_effective_date  date )
RETURN VARCHAR2
IS
--
l_proc  constant varchar2(72) := g_package||'decode_element_type';
l_element_name pay_element_types_f.element_name%type;

cursor csr_element is
   select pettl.element_name
     from pay_element_types_f pet,
          pay_element_types_f_tl pettl
    where pet.element_type_id = pettl.element_type_id
      and pettl.language = userenv('LANG')
      and pet.element_type_id = p_element_type_id
      and p_effective_date between pet.effective_start_date and pet.effective_end_date;
--
BEGIN
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  if p_element_type_id is not null then

     open csr_element;
     fetch csr_element into l_element_name;
     close csr_element;

  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
  return l_element_name;
--
END decode_element_type;
--
FUNCTION get_bank_details ( p_external_account_id in number )
RETURN VARCHAR2
IS
--
l_concat_string     varchar2(2000);
l_proc  constant varchar2(72) := g_package||'get_bank_details';

l_flex_num pay_external_accounts.id_flex_num%type;
l_segment1 pay_external_accounts.segment1%type;
l_segment2 pay_external_accounts.segment2%type;
l_segment3 pay_external_accounts.segment3%type;
l_segment4 pay_external_accounts.segment4%type;
l_segment5 pay_external_accounts.segment5%type;
l_segment6 pay_external_accounts.segment6%type;
l_segment7 pay_external_accounts.segment7%type;
l_segment8 pay_external_accounts.segment8%type;
l_segment9 pay_external_accounts.segment9%type;
l_segment10 pay_external_accounts.segment10%type;
l_segment11 pay_external_accounts.segment11%type;
l_segment12 pay_external_accounts.segment12%type;
l_segment13 pay_external_accounts.segment13%type;
l_segment14 pay_external_accounts.segment14%type;
l_segment15 pay_external_accounts.segment15%type;
l_segment16 pay_external_accounts.segment16%type;
l_segment17 pay_external_accounts.segment17%type;
l_segment18 pay_external_accounts.segment18%type;
l_segment19 pay_external_accounts.segment19%type;
l_segment20 pay_external_accounts.segment20%type;
l_segment21 pay_external_accounts.segment21%type;
l_segment22 pay_external_accounts.segment22%type;
l_segment23 pay_external_accounts.segment23%type;
l_segment24 pay_external_accounts.segment24%type;
l_segment25 pay_external_accounts.segment25%type;
l_segment26 pay_external_accounts.segment26%type;
l_segment27 pay_external_accounts.segment27%type;
l_segment28 pay_external_accounts.segment28%type;
l_segment29 pay_external_accounts.segment29%type;
l_segment30 pay_external_accounts.segment30%type;

cursor csr_flex_num is
   select exa.id_flex_num,
          exa.segment1,
          exa.segment2,
          exa.segment3,
          exa.segment4,
          exa.segment5,
          exa.segment6,
          exa.segment7,
          exa.segment8,
          exa.segment9,
          exa.segment10,
          exa.segment11,
          exa.segment12,
          exa.segment13,
          exa.segment14,
          exa.segment15,
          exa.segment16,
          exa.segment17,
          exa.segment18,
          exa.segment19,
          exa.segment20,
          exa.segment21,
          exa.segment22,
          exa.segment23,
          exa.segment24,
          exa.segment25,
          exa.segment26,
          exa.segment27,
          exa.segment28,
          exa.segment29,
          exa.segment30
   from   pay_external_accounts exa
   where  exa.external_account_id = p_external_account_id;
--
BEGIN
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  if p_external_account_id is not null then

     open  csr_flex_num;
     fetch csr_flex_num into l_flex_num,
                             l_segment1, l_segment2, l_segment3, l_segment4, l_segment5, l_segment6, l_segment7, l_segment8, l_segment9, l_segment10,
                             l_segment11, l_segment12, l_segment13, l_segment14, l_segment15, l_segment16, l_segment17, l_segment18, l_segment19, l_segment20,
                             l_segment21, l_segment22, l_segment23, l_segment24, l_segment25, l_segment26, l_segment27, l_segment28, l_segment29, l_segment30 ;
     close csr_flex_num;

     l_concat_string := PAY_ADHOC_UTILS_PKG.FLEX_CONCATENATED
                                          ( 'PAY', 'BANK', l_flex_num , 'SEGMENT', 30, 'KEY',
                                             l_segment1, l_segment2, l_segment3, l_segment4, l_segment5, l_segment6, l_segment7, l_segment8, l_segment9, l_segment10,
                                             l_segment11, l_segment12, l_segment13, l_segment14, l_segment15, l_segment16, l_segment17, l_segment18, l_segment19, l_segment20,
                                             l_segment21, l_segment22, l_segment23, l_segment24, l_segment25, l_segment26, l_segment27, l_segment28, l_segment29, l_segment30 );

  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
  return l_concat_string;
--
END get_bank_details;
--
FUNCTION flex_concatenated (app_short_name in varchar2,
                                      flex_name      in varchar2,
                                      flex_context_or_struct   in varchar2,
                                      column_name    in varchar2,
                                      no_of_columns  in varchar2 default null,
                                      flex_type      in varchar2, -- 'DESCRIPTIVE' or 'KEY'
                                      v1  in varchar2 default null,
                                      v2  in varchar2 default null,
                                      v3  in varchar2 default null,
                                      v4  in varchar2 default null,
                                      v5  in varchar2 default null,
                                      v6  in varchar2 default null,
                                      v7  in varchar2 default null,
                                      v8  in varchar2 default null,
                                      v9  in varchar2 default null,
                                      v10 in varchar2 default null,
                                      v11 in varchar2 default null,
                                      v12 in varchar2 default null,
                                      v13 in varchar2 default null,
                                      v14 in varchar2 default null,
                                      v15 in varchar2 default null,
                                      v16 in varchar2 default null,
                                      v17 in varchar2 default null,
                                      v18 in varchar2 default null,
                                      v19 in varchar2 default null,
                                      v20 in varchar2 default null,
                                      v21 in varchar2 default null,
                                      v22 in varchar2 default null,
                                      v23 in varchar2 default null,
                                      v24 in varchar2 default null,
                                      v25 in varchar2 default null,
                                      v26 in varchar2 default null,
                                      v27 in varchar2 default null,
                                      v28 in varchar2 default null,
                                      v29 in varchar2 default null,
                                      v30 in varchar2 default null
                                      ) return varchar2
is
   --
   l_proc  constant varchar2(72) := g_package||'flex_concatenated';
   l_delimiter         varchar2(1);
   l_disp_no           number;
   first_seg           boolean;
   l_concat_string     varchar2(2000);
   type segment_table is table of varchar2(60)
        index by binary_integer;
   segment             segment_table;
   --
   cursor get_seg_order is
     SELECT  REPLACE(fs.APPLICATION_COLUMN_NAME,column_name,'')
     FROM    FND_ID_FLEX_SEGMENTS fs,
             FND_APPLICATION fap
     WHERE   fs.id_flex_num = flex_context_or_struct
     and     fs.id_flex_code = flex_name
     and     fs.enabled_flag  = 'Y'
     and     fs.application_id = fap.application_id
     and     fap.APPLICATION_SHORT_NAME = app_short_name
     order by fs.SEGMENT_NUM;
   --
   procedure desc_flex_set_column_value(column_name   in varchar2,
                                        column_number in number,
                                        column_value  in varchar2,
                                        total_columns in number) is
   begin
     if column_number <= total_columns then
        fnd_flex_descval.set_column_value(column_name||column_number,column_value);
     end if;
   end desc_flex_set_column_value;
   --
begin
   hr_utility.set_location('Entering:'|| l_proc, 10);
   if flex_type = 'DESCRIPTIVE' then
     --
     fnd_flex_descval.set_context_value(flex_context_or_struct);
     desc_flex_set_column_value(column_name,1,v1,no_of_columns);
     desc_flex_set_column_value(column_name,2,v2,no_of_columns);
     desc_flex_set_column_value(column_name,3,v3,no_of_columns);
     desc_flex_set_column_value(column_name,4,v4,no_of_columns);
     desc_flex_set_column_value(column_name,5,v5,no_of_columns);
     desc_flex_set_column_value(column_name,6,v6,no_of_columns);
     desc_flex_set_column_value(column_name,7,v7,no_of_columns);
     desc_flex_set_column_value(column_name,8,v8,no_of_columns);
     desc_flex_set_column_value(column_name,9,v9,no_of_columns);
     desc_flex_set_column_value(column_name,10,v10,no_of_columns);
     desc_flex_set_column_value(column_name,11,v11,no_of_columns);
     desc_flex_set_column_value(column_name,12,v12,no_of_columns);
     desc_flex_set_column_value(column_name,13,v13,no_of_columns);
     desc_flex_set_column_value(column_name,14,v14,no_of_columns);
     desc_flex_set_column_value(column_name,15,v15,no_of_columns);
     desc_flex_set_column_value(column_name,16,v16,no_of_columns);
     desc_flex_set_column_value(column_name,17,v17,no_of_columns);
     desc_flex_set_column_value(column_name,18,v18,no_of_columns);
     desc_flex_set_column_value(column_name,19,v19,no_of_columns);
     desc_flex_set_column_value(column_name,20,v20,no_of_columns);
     desc_flex_set_column_value(column_name,21,v21,no_of_columns);
     desc_flex_set_column_value(column_name,22,v22,no_of_columns);
     desc_flex_set_column_value(column_name,23,v23,no_of_columns);
     desc_flex_set_column_value(column_name,24,v24,no_of_columns);
     desc_flex_set_column_value(column_name,25,v25,no_of_columns);
     desc_flex_set_column_value(column_name,26,v26,no_of_columns);
     desc_flex_set_column_value(column_name,27,v27,no_of_columns);
     desc_flex_set_column_value(column_name,28,v28,no_of_columns);
     desc_flex_set_column_value(column_name,29,v29,no_of_columns);
     desc_flex_set_column_value(column_name,30,v30,no_of_columns);
     --
     if fnd_flex_descval.validate_desccols(appl_short_name => app_short_name,
                                           desc_flex_name  => flex_name) then
        return (substrb(fnd_flex_descval.concatenated_values,length(flex_context_or_struct)+1));
     else
        return (FND_FLEX_DESCVAL.error_message);
     end if;
     --
   end if;
   --
   if flex_type = 'KEY' then
      --
      segment(1) := v1;
      segment(2) := v2;
      segment(3) := v3;
      segment(4) := v4;
      segment(5) := v5;
      segment(6) := v6;
      segment(7) := v7;
      segment(8) := v8;
      segment(9) := v9;
      segment(10) := v10;
      segment(11) := v11;
      segment(12) := v12;
      segment(13) := v13;
      segment(14) := v14;
      segment(15) := v15;
      segment(16) := v16;
      segment(17) := v17;
      segment(18) := v18;
      segment(19) := v19;
      segment(20) := v20;
      segment(21) := v21;
      segment(22) := v22;
      segment(23) := v23;
      segment(24) := v24;
      segment(25) := v25;
      segment(26) := v26;
      segment(27) := v27;
      segment(28) := v28;
      segment(29) := v29;
      segment(30) := v30;
      --
      l_delimiter := fnd_flex_ext.get_delimiter
                     (app_short_name
                     ,flex_name
                     ,flex_context_or_struct
                     );
      --
      first_seg := true;
      open get_seg_order;
      loop
          fetch get_seg_order into l_disp_no;
          exit when get_seg_order%NOTFOUND;

          if first_seg = false then
             l_concat_string := l_concat_string || l_delimiter;
          else
             first_seg := false;
          end if;

          if segment(l_disp_no) is not null then
             l_concat_string := l_concat_string || segment(l_disp_no);
          end if;
      end loop;
      close get_seg_order;
	  --
	  return l_concat_string;
	  --
   end if;
   --
   hr_utility.set_location('Leaving:'|| l_proc, 20);
   return null;
   --
end FLEX_CONCATENATED;
--
--
FUNCTION get_prev_salary(p_assignment_id NUMBER,
                         p_start_date    DATE,
			 p_end_date      DATE,
			 p_sal_type      VARCHAR2)  RETURN NUMBER IS
--
--
 CURSOR previous_pay(c_assignment_id NUMBER,
                     c_start_date    DATE,
		     c_end_date      DATE,
		     c_date          DATE) IS
        SELECT  pro.proposed_salary_n
        FROM    per_pay_proposals pro
	WHERE   pro.assignment_id = c_assignment_id
	AND     pro.change_date =(SELECT max(pro2.change_date)
	                          FROM   per_pay_proposals pro2
				  WHERE  pro2.assignment_id = c_assignment_id
				  AND    pro2.change_date < c_date)
        AND     pro.change_date < c_date ;
--
 ln_prev_sal  NUMBER;
 ld_date      DATE;
 --
 BEGIN
        IF  p_sal_type = 'STARTING' THEN

            ld_date :=  p_start_DATE;

            OPEN previous_pay(p_assignment_id,
                              p_start_date,
                              p_end_date,
                              ld_date);
            FETCH  previous_pay INTO   ln_prev_sal  ;
            CLOSE  previous_pay;
--
        ELSIF  p_sal_type = 'ENDING'  THEN
	       ld_date :=  p_end_date;

	      OPEN  previous_pay(p_assignment_id,
                                 p_start_date,
                                 p_end_date,
                                 ld_date);
              FETCH previous_pay INTO  ln_prev_sal ;
              CLOSE previous_pay;
--
        END IF;
--
      RETURN(ln_prev_sal);
END get_prev_salary;
--
--
FUNCTION get_prev_sal_change_date(p_assignment_id NUMBER,
	       		          p_end_date      DATE)  RETURN DATE IS
--
--
    CURSOR previous_pay_date(c_assignment_id   NUMBER,
	   	             c_period_end_date DATE)   IS
           SELECT max(pro.change_date)
           FROM   per_pay_proposals pro
	   WHERE  pro.assignment_id = c_assignment_id
	   AND    pro.change_date < c_period_end_date;
--
 ld_date      DATE;
--
 BEGIN

         OPEN previous_pay_date(p_assignment_id,
                                p_end_date);
         FETCH  previous_pay_date INTO ld_date  ;
         CLOSE  previous_pay_date;
--
      RETURN(ld_date);
--
EXCEPTION
         WHEN others THEN
	      RETURN(NULL);
END get_prev_sal_change_date;
--
--
FUNCTION get_multiple_sal_change_flag(p_assignment_id NUMBER,
                                      p_start_date    DATE,
                                      p_end_date      DATE) RETURN VARCHAR2 IS
--
  v_count       NUMBER ;
  multiple_flag VARCHAR2(1);
--
BEGIN
      SELECT count(*) INTO v_count
      FROM   per_pay_proposals
      WHERE  assignment_id = p_assignment_id
      AND    change_date between p_start_date and p_end_date;

      IF  v_count < 0 or v_count = 1 THEN
          multiple_flag := 'N' ;

      ELSIF v_count > 1 then
          multiple_flag := 'Y' ;
      END IF;

      RETURN(multiple_flag);
--
END get_multiple_sal_change_flag;
--
--
FUNCTION get_input_name(p_element_entry_id    number,
                         p_sequence            number,
                         p_inputname_or_value  varchar2,
                         p_start_date          date,
                         p_end_date            date,
                         p_ele_start_date      date,
                         p_ele_end_date        date ) return varchar2 is
BEGIN
    hr_utility.set_location('g_element_entry_id '||g_element_entry_id,10);
    hr_utility.set_location('p_element_entry_id '||p_element_entry_id,20);
--
    IF g_element_entry_id     =  p_element_entry_id AND
       g_effective_start_date = p_ele_start_date    AND
       g_effective_end_date   = p_ele_end_date      THEN
           NULL;
           hr_utility.set_location('p_element_entry_id if'||p_element_entry_id,30);
    ELSE
        pupulate_input_name(p_element_entry_id => p_element_entry_id,
                            p_start_date       => p_start_date,
                            p_end_date         => p_end_date,
                            p_ele_start_date   => p_ele_start_date,
                            p_ele_end_date     => p_ele_end_date);
	 hr_utility.set_location('p_element_entry_id else'||p_element_entry_id,40);
--
    END IF;
--
    IF    g_element_entry_id = p_element_entry_id AND
          p_inputname_or_value = 'NAME'           THEN
	  RETURN(g_input_name_value_tab(p_sequence).v_input_name);
    ELSIF
          g_element_entry_id = p_element_entry_id AND
	  p_inputname_or_value = 'VALUE'          THEN
	  RETURN(g_input_name_value_tab(p_sequence).v_input_value);
    ELSIF
          g_element_entry_id = p_element_entry_id AND
	  p_inputname_or_value = 'ELEMENT_NAME'   THEN
          RETURN(g_input_name_value_tab(p_sequence).v_element_name);
    ELSIF
          g_element_entry_id = p_element_entry_id AND
	  p_inputname_or_value = 'CLASSIFICATION'   THEN
          RETURN(g_input_name_value_tab(p_sequence).v_classification);
    ELSIF
          g_element_entry_id = p_element_entry_id AND
	  p_inputname_or_value = 'RECURRING'   THEN
          RETURN(g_input_name_value_tab(p_sequence).v_recurring);
   END IF;
--
EXCEPTION
      WHEN others THEN
           RETURN(null);
END get_input_name;
--
--
FUNCTION check_assignment_in_set(p_assignmentset_name VARCHAR2,
                                 p_assignment_id      NUMBER,
                                 p_business_group_id  NUMBER,
                                 p_payroll_id         NUMBER)
                                               RETURN VARCHAR2 IS
--
--Cursor to check the assignment exists in assignment set

  CURSOR  c_assignment_set(c_assignmentset_name VARCHAR2,
                           c_assignment_id      NUMBER,
                           c_business_group_id  NUMBER,
	                   c_payroll_id         NUMBER) IS

        SELECT 'Y'
          FROM hr_assignment_sets aset
         WHERE aset.assignment_set_name = c_assignmentset_name
           and nvl(aset.payroll_id,c_payroll_id) = c_payroll_id
	   and aset.business_group_id = c_business_group_id
           and (not exists
                   (select 1
                      from hr_assignment_set_amendments hasa
                     where hasa.assignment_set_id = aset.assignment_set_id
                       and hasa.include_or_exclude = 'I')
                or exists
                   (select 1
                      from hr_assignment_set_amendments hasa
                     where hasa.assignment_set_id = aset.assignment_set_id
                       and hasa.assignment_id = c_assignment_id
                       and hasa.include_or_exclude = 'I'))
           and not exists
                   (select 1
                      from hr_assignment_set_amendments hasa
                     where hasa.assignment_set_id = aset.assignment_set_id
                       and hasa.assignment_id = c_assignment_id
                       and hasa.include_or_exclude = 'E') ;
--
--
v_value           VARCHAR2(1);

BEGIN
--
  IF p_assignmentset_name IS NULL THEN
     	RETURN 'Y';
  END IF;
--
--
  OPEN c_assignment_set(p_assignmentset_name,p_assignment_id,
                        p_business_group_id,p_payroll_id);
  FETCH c_assignment_set INTO v_value;
  CLOSE c_assignment_set ;
--
  IF v_value ='Y' THEN
         RETURN 'Y';
  ELSE
        RETURN 'N';
  END IF;
--
EXCEPTION
     WHEN OTHERS THEN
          RETURN 'N';
END check_assignment_in_set;
--
--
FUNCTION check_balance_exists(p_defined_balance_id NUMBER,
                              p_business_group_id  NUMBER,
                              p_attribute_name     VARCHAR2)
                 RETURN VARCHAR2 IS
--
CURSOR check_balance_exists(c_defined_balance_id NUMBER,
                            c_business_group_id  NUMBER,
                            c_attribute_name     VARCHAR2) is
   SELECT pba.defined_balance_id
   FROM   pay_balance_attributes pba,
          pay_bal_attribute_definitions pbad
   WHERE  pba.attribute_id = pbad.attribute_id
   AND    pba.defined_balance_id = c_defined_balance_id
   AND    pbad.attribute_name = c_attribute_name
   AND    ((pba.business_group_id = c_business_group_id and pba.legislation_code is null) or
          (pba.legislation_code  = hr_bis.get_legislation_code and pba.business_group_id is null));

v_balance_exists      VARCHAR2(1);
v_defined_balance_id  NUMBER;

BEGIN

    v_balance_exists := 'Y' ;

      IF p_attribute_name is not null THEN
         OPEN  check_balance_exists(p_defined_balance_id,p_business_group_id,p_attribute_name);
         FETCH check_balance_exists into v_defined_balance_id;
            IF check_balance_exists%FOUND THEN
               v_balance_exists := 'Y' ;
            ELSE
               v_balance_exists := 'N' ;
            END IF;
         CLOSE check_balance_exists;
      END IF;

      RETURN (v_balance_exists);
END check_balance_exists;
--
--
FUNCTION get_bal_valid_load_date(p_attribute_name       varchar2,
                                 p_balance_name         varchar2,
                                 p_business_group_id    number,
                                 p_database_item_suffix varchar2,
                                 p_defined_balance_id number DEFAULT NULL)
				     	                      RETURN DATE IS

--To get the balance load date from single defined_balance_id
  CURSOR get_balance_date IS
           SELECT pbv.balance_load_date
	   FROM   pay_balance_validation pbv
           WHERE  pbv.business_group_id  = p_business_group_id
	   AND    pbv.defined_balance_id = p_defined_balance_id
	   AND    pbv.run_balance_status = 'V' ;

--To get the balance load date when Attribute Name is passed

  CURSOR get_attribute_bal_date(c_attribute_name       VARCHAR2,
                                c_business_group_id    NUMBER,
			        c_database_item_suffix VARCHAR2)  IS
           SELECT max(balance_load_date) balance_load_date
	   FROM   pay_balance_validation pbv,
         	  pay_balance_attributes pba,
                  pay_bal_attribute_definitions pbad,
		  pay_defined_balances    pdb,
		  pay_balance_dimensions  pbd
           WHERE  pbv.defined_balance_id = pdb.defined_balance_id
           AND    pdb.defined_balance_id = pba.defined_balance_id
           AND    pba.attribute_id = pbad.attribute_id
	   AND    pdb.balance_dimension_id = pbd.balance_dimension_id
	   AND    pbv.business_group_id  = c_business_group_id
	   AND    pbad.attribute_name    = c_attribute_name
	   AND    pbd.database_item_suffix = c_database_item_suffix
	   AND    pbv.run_balance_status = 'V' ;

ld_balance_load_date DATE;

BEGIN
      IF (p_balance_name IS NOT NULL AND p_attribute_name IS NOT NULL) OR
         (p_balance_name IS NOT NULL AND p_attribute_name IS NULL) THEN
--
--
         IF g_balance_name = p_balance_name THEN
             hr_utility.set_location(' g_balance_name if '||g_balance_name,10);
	     RETURN(g_balance_load_date);
         ELSE
             OPEN  get_balance_date ;
	     FETCH get_balance_date INTO ld_balance_load_date;
	     CLOSE get_balance_date;
--
             g_balance_load_date := ld_balance_load_date;
             g_balance_name      := p_balance_name;
             hr_utility.set_location(' g_balance_name else '||g_balance_name,20);
--
            RETURN(ld_balance_load_date);
        END IF;
--
      ELSIF p_balance_name IS NULL AND p_attribute_name IS NOT NULL THEN
--
        IF  g_attribute_name = p_attribute_name THEN
            hr_utility.set_location(' g_attribute_name if '||g_attribute_name,30);
            RETURN(g_balance_load_date);
        ELSE
            OPEN  get_attribute_bal_date(p_attribute_name,p_business_group_id,p_database_item_suffix) ;
	    FETCH get_attribute_bal_date INTO ld_balance_load_date;
	    CLOSE get_attribute_bal_date;
--
            g_balance_load_date := ld_balance_load_date;
            g_attribute_name  := p_attribute_name ;
            hr_utility.set_location(' g_attribute_name else '||g_attribute_name,40);
--
	    RETURN(ld_balance_load_date);
	 END IF;
      ELSE
          RETURN(null);
      END IF;
END get_bal_valid_load_date;
--
--
FUNCTION chk_post_r11i RETURN VARCHAR2 is
--
  cursor csr_r12_release is
  select 'Y'
    from FND_PRODUCT_INSTALLATIONS
   where APPLICATION_ID = 800
     and to_number(substr(PRODUCT_VERSION,1,2)) >= 12;
--
BEGIN
--
  if g_post_r11i is null then
     open csr_r12_release;
     fetch csr_r12_release into g_post_r11i;
     if csr_r12_release%notfound then
        g_post_r11i := 'N';
     end if;
     close csr_r12_release;
  end if;
--
  return g_post_r11i;
--
END chk_post_r11i;
--
--
FUNCTION get_element_name(p_element_entry_id number,
                          p_retro_run_date   date,
                          p_payroll_run_date date)
         RETURN VARCHAR2 IS
--
l_proc  constant varchar2(72) := g_package||'get_element_name';
l_element_name   pay_element_types_f.element_name%type;
--
cursor csr_element is
   select pettl.element_name
     from pay_element_types_f pet,
          pay_element_types_f_tl pettl,
          pay_element_entries_f  pee
    where pet.element_type_id = pettl.element_type_id
      and pettl.language = userenv('LANG')
      and pet.element_type_id = pee.element_type_id
      and pee.element_entry_id = p_element_entry_id
      and p_retro_run_date between pet.effective_start_date and pet.effective_end_date
      and p_payroll_run_date between pee.effective_start_date and pee.effective_end_date;
--
BEGIN
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
  if p_element_entry_id is not null then
     open csr_element;
     fetch csr_element into l_element_name;
     close csr_element;
  end if;
--
  hr_utility.set_location('Leaving:'|| l_proc, 20);
  return l_element_name;
--
END get_element_name ;
--
--
END PAY_ADHOC_UTILS_PKG;

/
