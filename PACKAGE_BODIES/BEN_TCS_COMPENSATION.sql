--------------------------------------------------------
--  DDL for Package Body BEN_TCS_COMPENSATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_TCS_COMPENSATION" as
/* $Header: betcscmp.pkb 120.12.12010000.11 2010/02/03 11:37:57 vkodedal ship $ */
g_period_table period_table;
g_status varchar2(3) ;
g_package varchar2(30) := 'BEN_TCS_COMPENSATION';

PROCEDURE WRITE (p_string IN VARCHAR2)
IS
BEGIN
      ben_batch_utils.WRITE (p_string);
END WRITE ;

procedure delete_rows is
l_proc varchar2(60) := g_package||'delete_rows';
begin
hr_utility.set_location('Entering into '||l_proc,10);
g_period_table.delete;
 hr_utility.set_location('Leaving '||l_proc,10);
end delete_rows;

Procedure Insert_period( p_period_start_date in date,
                         p_period_end_date in date
                        ) is

l_number_of_rows number;
l_flag varchar2(1);
l_next_row number;
l_proc varchar2(60) := g_package||'Insert_period';
Begin
hr_utility.set_location('Entering into '||l_proc,10);

     l_next_row := NVL(g_period_table.LAST, 0) + 1;
     g_period_table(l_next_row).start_date := p_period_start_date;
     g_period_table(l_next_row).end_date := p_period_end_date;

 hr_utility.set_location('Leaving '||l_proc,10);
end Insert_period;

procedure get_salary_basis_details ( p_input_value_id in number,
                                     p_effective_date in date,
                                     p_period_start_date in date,
                                     p_assignment_id in number,
                                     p_pay_basis_id out nocopy number,
                                     p_rate_basis out nocopy varchar2,
                                     p_PAY_ANN_FACTOR out nocopy number,
                                     p_name out nocopy varchar2
                                    ) is

l_proc varchar2(1000) := g_package||'get_salary_basis_details';

cursor csr_salary_basis_details is
   select pay.pay_basis_id,
         pay_basis,
         PAY_ANNUALIZATION_FACTOR,
         name
   from   per_pay_bases pay,
         per_all_assignments_f asg
  where pay.input_value_id = p_input_value_id
  and   pay.business_group_id = asg.business_group_id
  and   pay.pay_basis_id = asg.pay_basis_id
  and   asg.assignment_id = p_assignment_id
  and   p_period_start_date <= asg.effective_end_date
  and   p_effective_date >= asg.effective_start_date;

  l_salary_rec   csr_salary_basis_details%ROWTYPE;

begin
  hr_utility.set_location('Entering: '||l_proc,30);

  open csr_salary_basis_details;
  fetch csr_salary_basis_details into l_salary_rec;
  if csr_salary_basis_details%notfound then
     g_status := '1B';
      hr_utility.set_location('No Salary basis linked to input value id passed ', 40);
  end if;
  close csr_salary_basis_details;
   p_pay_basis_id := l_salary_rec.pay_basis_id;
   p_rate_basis := l_salary_rec.pay_basis;
   p_PAY_ANN_FACTOR :=l_salary_rec.PAY_ANNUALIZATION_FACTOR;
   p_name :=l_salary_rec.name ;

  hr_utility.set_location('Leaving: '||l_proc,30);
  exception
    when no_data_found then
        g_status := '1B';
      hr_utility.set_location('No Salary basis linked to input value id passed ', 40);
end get_salary_basis_details;


procedure element_entry(p_assignment_id   in number,
                        p_element_type_id in number,
                        p_input_value_id  in number,
                        p_perd_st_dt      in date,
                        p_perd_en_dt      in date,
                        p_summary         out nocopy period_table,
                        p_actual_uom      in varchar2,
                        p_lookup_type     in varchar2,
                        p_value_set_id    in varchar2  ,
                        p_actual_currency_code in varchar2 ) is
         cursor csr_elmnt_entry is
          select ee.effective_start_date ee_esd,
                 ee.effective_end_date ee_eed,
                 ee.CREATOR_TYPE creator_type,
                 eev.screen_entry_value eev_amt,
                 eev.ELEMENT_ENTRY_VALUE_ID eev_id
          from pay_element_entries_f ee,
               pay_element_entry_values_f eev
          where ee.assignment_id = p_assignment_id
          and ee.element_type_id = p_element_type_id
          and ee.effective_start_date < p_perd_en_dt
          and ee.effective_end_date > p_perd_st_dt
          and ee.element_entry_id = eev.element_entry_id
          and eev.input_value_id = p_input_value_id
          and eev.effective_start_date = ee.effective_start_date
          and eev.effective_end_date = ee.effective_end_date
          and eev.screen_entry_value is not null
          order by ee.effective_start_date;

   i integer;
   l_proc varchar2(60) := g_package||'element_entry';
begin
   hr_utility.set_location('Entering'||l_proc,10);
   hr_utility.set_location('Elmnt_id'||p_element_type_id,10);
   hr_utility.set_location('iv_id'||p_input_value_id,10);
   i := 0;
    for elmnt_entry_row in csr_elmnt_entry loop
       i := i + 1;
       hr_utility.set_location('ee being recorded :'||elmnt_entry_row.eev_amt,10);

      p_summary(i).start_date := elmnt_entry_row.ee_esd;
      p_summary(i).end_date := elmnt_entry_row.ee_eed;
      if  p_value_set_id is null and p_lookup_type is null then
           p_summary(i).value := elmnt_entry_row.eev_amt;
         /*  p_summary(i).value :=    hr_chkfmt.changeformat(
									elmnt_entry_row.eev_amt,
                                    p_actual_uom,
                                    p_actual_currency_code);*/
      elsif p_lookup_type is not null then
           p_summary(i).value :=  	hr_general.decode_lookup(
									p_lookup_type,
                                    elmnt_entry_row.eev_amt) ;
     elsif p_value_set_id is not null then
          p_summary(i).value := pay_input_values_pkg.decode_vset_value(
				p_value_set_id,
				elmnt_entry_row.eev_amt);
      end if ;
      p_summary(i).creator_type := elmnt_entry_row.creator_type;
      p_summary(i).output_key := elmnt_entry_row.eev_id;

   end loop;
   hr_utility.set_location('p summary count '||p_summary.count,45);
   hr_utility.set_location('# of entries'||to_char(i),20);
   hr_utility.set_location('Leaving'||l_proc,10);
end element_entry;

procedure bnfts_entries (p_person_id in number,
                        p_perd_st_dt in date,
                        p_perd_en_dt   in date,
                        p_input_value_id  in number,
                        p_comp_typ_cd in varchar2,
                        p_currency_cd in varchar2,
                        p_uom in varchar2,
                        p_bnfts_table out nocopy period_table) is

cursor bnfts_rows is
select pbb.effective_start_date,
       pbb.effective_end_date,
       pbb.per_bnfts_bal_id,
       pbb.val,
       bb.uom,
       bb.nnmntry_uom
from ben_bnfts_bal_f bb,
     ben_per_bnfts_bal_f pbb
where bb.bnfts_bal_id = p_input_value_id
and   pbb.bnfts_bal_id = bb.bnfts_bal_id
and   pbb.person_id = p_person_id
and   pbb.effective_start_date between p_perd_st_dt and p_perd_en_dt
and   bb.effective_start_date <   p_perd_en_dt
and   bb.effective_end_date >     p_perd_st_dt
and   pbb.val is not null;
l_proc varchar2(1000) := g_package||'bnfts_entries';
i integer := 0;
Begin
hr_utility.set_location('Entering '||l_proc,20);
    for bnfts_rec in bnfts_rows loop
        i := i + 1;
       p_bnfts_table(i).start_date := bnfts_rec.effective_start_date;
       p_bnfts_table(i).end_date := bnfts_rec.effective_end_date;
       p_bnfts_table(i).value := fnd_number.number_to_canonical(bnfts_rec.val) ;
       p_bnfts_table(i).output_key := bnfts_rec.per_bnfts_bal_id;

       if p_comp_typ_cd = 'MNTRY' then
           p_bnfts_table(i).currency_cd := nvl(p_currency_cd,bnfts_rec.uom);
       elsif p_comp_typ_cd = 'NNMNTRY' then
            p_bnfts_table(i).uom := nvl(p_uom,bnfts_rec.nnmntry_uom);
       end if;
        p_bnfts_table(i).actual_uom := bnfts_rec.nnmntry_uom;
  end loop;
exception
   when others then
    g_status := '3';

 hr_utility.set_location('Leaving '||l_proc,20);
end bnfts_entries;

procedure rule_entries (p_assignment_id in number,
                        p_perd_start_date in date,
                        p_perd_end_date   in date,
                        p_date_earned     in date,
                        p_input_value_id  in number,
                        p_comp_typ_cd in varchar2,
                        p_currency_cd in varchar2,
                        p_uom in varchar2,
                        p_rule_table out nocopy period_table) is

 l_inputs                 ff_exec.inputs_t;
 l_outputs                ff_exec.outputs_t;
 -- vkodedal modified the length of varchar Bug# 6992595
 l_comp_dates             varchar2(2000);
 l_comp_values            varchar2(2000);
  --
 l_proc                    varchar2(100) := g_package || 'get_commitment_from_formula';
  --
 l_input_count             number;
 i_dt number := 1;
 j_dt number;
 i_vl number := 1;
 j_vl number;
 -- vkodedal modified the length of varchar Bug# 6992595
 l_date varchar2(2000);
 l_value varchar2(2000);

 k number := 1;
 z number := 1;
 ---- vkodedal new variables to store additional dates and values 14-May-2008 Bug# 6992595
 l_comp_dates1             varchar2(1000);
 l_comp_values1            varchar2(1000);
 l_comp_dates2             varchar2(1000);
 l_comp_values2            varchar2(1000);
 l_comp_dates3             varchar2(1000);
 l_comp_values3            varchar2(1000);

begin
 hr_utility.set_location ('Entering: '||l_proc,05);
  --
  -- Initialise the formula .
  --


  ff_exec.init_formula
       (p_formula_id     => p_input_value_id,
        p_effective_date => p_date_earned,
        p_inputs         => l_inputs,
        p_outputs        => l_outputs);

   hr_utility.set_location ('Set Context '||l_proc,10);
   hr_utility.set_location ('Set Context :'||l_inputs.first|| ' : ' || l_inputs.last,10);
  --
  for l_count in nvl(l_inputs.first,0)..nvl(l_inputs.last,-1) loop
    --
   if l_inputs(l_count).name = 'ASSIGNMENT_ID' then
      --
      l_inputs(l_count).value := p_assignment_id;
      --
      --
    elsif l_inputs(l_count).name = 'PERIOD_START_DATE' then
      --
     l_inputs(l_count).value := fnd_date.date_to_canonical(p_perd_start_date);

    elsif l_inputs(l_count).name = 'PERIOD_END_DATE' then
      --
      l_inputs(l_count).value := fnd_date.date_to_canonical(p_perd_end_date);
      --
    elsif l_inputs(l_count).name = 'DATE_EARNED' then

     l_inputs(l_count).value := fnd_date.date_to_canonical(p_date_earned);
     --
    end if;
    --
  end loop;

   hr_utility.set_location ('Run formula: '||l_proc,15);
  --
  -- We have loaded the input record . Now run the formula.
  --
  ff_exec.run_formula(p_inputs  => l_inputs,
                      p_outputs => l_outputs);

  hr_utility.set_location ('After Run formula: '||l_outputs.first || ' : ' ||l_outputs.last ,15);
  --
  --
  -- Loop through the returned table and make sure that the returned
  -- values have been found
-- vkodedal Bug 6992595 added variables and modified condition
  --
  for l_count in l_outputs.first..l_outputs.last loop
  --
  --
  hr_utility.set_location ('After Run formula:'||l_outputs(l_count).name ,15);
  --
  if l_outputs(l_count).name = 'COMPENSATION_DATES' then
    --
       l_comp_dates := l_outputs(l_count).value;
    --
  Elsif l_outputs(l_count).name = 'COMPENSATION_DATES1' then
      --
       l_comp_dates1 := l_outputs(l_count).value;
    --
  Elsif l_outputs(l_count).name = 'COMPENSATION_DATES2' then
      --
       l_comp_dates2 := l_outputs(l_count).value;
    --
  Elsif l_outputs(l_count).name = 'COMPENSATION_DATES3' then
      --
       l_comp_dates3 := l_outputs(l_count).value;
      --
  Elsif  l_outputs(l_count).name = 'VALUES' then
      --
       l_comp_values := l_outputs(l_count).value;
      --
  Elsif  l_outputs(l_count).name = 'VALUES1' then
      --
       l_comp_values1 := l_outputs(l_count).value;
      --
  Elsif  l_outputs(l_count).name = 'VALUES2' then
      --
       l_comp_values2 := l_outputs(l_count).value;
      --
  Elsif  l_outputs(l_count).name = 'VALUES3' then
      --
       l_comp_values3 := l_outputs(l_count).value;
      --
  end if;
  --
  end loop;
  -- vkodedal Bug 6992595 -- new changes
  if(length(l_comp_dates1) > 0 and length(l_comp_values1) > 0 ) then
  l_comp_dates :=l_comp_dates||';'||l_comp_dates1;
  l_comp_values :=l_comp_values||';'||l_comp_values1;
  hr_utility.set_location ('Dates from Additional variable 1 appended.',17);
  end if;

  if(length(l_comp_dates2) > 0 and length(l_comp_values2) > 0 ) then
  l_comp_dates :=l_comp_dates||';'||l_comp_dates2;
  l_comp_values :=l_comp_values||';'||l_comp_values2;
  hr_utility.set_location ('Dates from Additional variable 2 appended.',18);
  end if;

  if(length(l_comp_dates3) > 0 and length(l_comp_values3) > 0 ) then
  l_comp_dates :=l_comp_dates||';'||l_comp_dates3;
  l_comp_values :=l_comp_values||';'||l_comp_values3;
  hr_utility.set_location ('Dates from Additional variable 3 appended.',19);
  end if;
 ---------------------end of new changes
   if(length(l_comp_dates) > 0 and length(l_comp_values) > 0 ) then
   loop
   j_dt := instr(l_comp_dates,';',1,k);
   j_vl := instr(l_comp_values,';',1,k);
   l_date := substr(l_comp_dates,i_dt,j_dt-i_dt);
   l_value :=  substr(l_comp_values,i_vl,j_vl-i_vl);
   if j_dt <> 0 then
      i_dt := j_dt+1;
   else
      if i_dt < length(l_comp_dates) then
        l_date := substr(l_comp_dates,i_dt);
      end if;
      i_dt := length(l_comp_dates) + 1;
   end if;
    if j_vl <> 0 then
      i_vl := j_vl+1;
   else    --Bug#8451436 vkodedal 29-Apr-2009 added =
      if i_vl <= length(l_comp_values) then
        l_value := substr(l_comp_values,i_vl);
      end if;
      i_vl := length(l_comp_values) +1;
   end if;
   if z > 1 then
     p_rule_table(z-1).end_date :=to_date(l_date,'yyyy/mm/dd')-1;
   end if;

   IF ( to_date(l_date,'yyyy/mm/dd') >=  p_perd_start_date and to_date(l_date,'yyyy/mm/dd')<=  p_perd_end_date ) THEN
   p_rule_table(z).start_date :=to_date(l_date,'yyyy/mm/dd');
  -- p_bnfts_table(i).end_date := bnfts_rec.effective_end_date;
   p_rule_table(z).value := l_value;
   p_rule_table(z).output_key := z;
   if p_comp_typ_cd = 'MNTRY' then
      p_rule_table(z).currency_cd := p_currency_cd;
   elsif p_comp_typ_cd = 'NNMNTRY' then
            p_rule_table(z).uom := p_uom;
   end if;
      z := z +1;
   END IF;
   hr_utility.set_location('value of l_date '||l_date, 30);
   hr_utility.set_location('value of j_dt '||j_dt, 30);
   hr_utility.set_location('new value of i_dt '||i_dt, 30);
   hr_utility.set_location('value of l_value '||l_value, 30);
   hr_utility.set_location('value of j_vl '||j_vl, 30);
   hr_utility.set_location('new value of i_vl '||i_vl, 30);

  /* write('value of l_date '||l_date);
   write('value of j_dt '||j_dt);
   write('new value of i_dt '||i_dt);
   write('value of l_value '||l_value);
   write('value of j_vl '||j_vl);
   write('new value of i_vl '||i_vl); */
   k := k+1;
   /*WRITE (i_dt);
   WRITE(length(l_comp_dates));*/
   exit when i_vl > length(l_comp_values);
   exit when i_dt > length(l_comp_dates);
 end loop;
 end if ;
 hr_utility.set_location('Leaving '||l_proc,20);
exception
    when others then
    g_status := '5';
    WRITE('error in date format:'  || sqlerrm);
    hr_utility.set_location('exception '||sqlerrm,20);
end rule_entries;

procedure thrd_pty_entries (p_assignment_id in number,
                        p_perd_start_date in date,
                        p_perd_end_date   in date,
                        p_input_value_id  in number,
                        p_comp_typ_cd in varchar2,
                        p_currency_cd in varchar2,
                        p_uom in varchar2,
                        p_thrd_pty_table out nocopy period_table) is
cursor thrd_pty_rows is
-- 08-Apr-2008 vkodedal       6945274 - currency issue -3rd party payroll
-- get the currency from element when it's not available from balance types table
select pr.processing_date period_start_date,
       pr.processing_date period_end_date,
       ba.run_amount amount ,
       bt.uom,
       bt.currency,
       ba.balance_amount_id,
       pe.input_currency_code,
       pi.uom input_value_uom,
       bt.displayed_name
from
      per_bf_balance_types bt,
      per_bf_processed_assignments pa,
      per_bf_balance_amounts ba,
      per_bf_payroll_runs pr,
      pay_element_types_f pe,
	  pay_input_values_f pi
where
     pa.assignment_id = p_assignment_id
and  pa.payroll_run_id = pr.payroll_run_id
and  bt.input_value_id = p_input_value_id
and  ba.balance_type_id = bt.balance_type_id
and  ba.processed_assignment_id = pa.processed_assignment_id
and  pr.processing_date between p_perd_start_date and p_perd_end_date
and  ba.run_amount is not null
and  pi.input_value_id = bt.input_value_id(+)
and  pe.element_type_id = pi.element_type_id(+)
and  trunc(sysdate) between pe.EFFECTIVE_START_DATE(+) and pe.EFFECTIVE_END_DATE(+)
and  trunc(sysdate) between pi.EFFECTIVE_START_DATE(+) and pi.EFFECTIVE_END_DATE(+);

  i integer := 1;
  l_proc varchar2(1000) := g_package||'thrd_pty_entries';
begin
   hr_utility.set_location('entering '||l_proc,10);
   hr_utility.set_location('inside cost entries with iv'||p_input_value_id,10);
   hr_utility.set_location('asg id'||p_assignment_id,11);
   hr_utility.set_location('date range is '||to_char(p_perd_start_date,'dd/mm/yyyy')||' - '||to_char(p_perd_end_date,'dd/mm/yyyy'),12);
   for thrd_pty_rec in thrd_pty_rows loop
       p_thrd_pty_table(i).start_date := thrd_pty_rec.period_start_date;
       p_thrd_pty_table(i).end_date := thrd_pty_rec.period_end_date;
       p_thrd_pty_table(i).value := fnd_number.number_to_canonical(thrd_pty_rec.amount);

       if p_comp_typ_cd = 'MNTRY' then
            --- vkodedal 6945274 - currency issue -3rd party payroll
            ---p_thrd_pty_table(i).currency_cd := nvl(p_currency_cd,thrd_pty_rec.currency);
             p_thrd_pty_table(i).currency_cd := nvl(p_currency_cd,nvl(thrd_pty_rec.currency,thrd_pty_rec.input_currency_code));
             hr_utility.set_location('Back feed : '||thrd_pty_rec.displayed_name||': Currency '||p_thrd_pty_table(i).currency_cd,15);

       elsif p_comp_typ_cd = 'NNMNTRY' then
            p_thrd_pty_table(i).uom := nvl(p_uom,nvl(thrd_pty_rec.uom,thrd_pty_rec.input_value_uom));
            hr_utility.set_location('UOM '||p_thrd_pty_table(i).uom,16);
       end if;
       p_thrd_pty_table(i).output_key := thrd_pty_rec.balance_amount_id;
            p_thrd_pty_table(i).actual_uom := thrd_pty_rec.uom;
       i := i + 1;
   end loop;
      hr_utility.set_location('# of entries'||i,30);
      hr_utility.set_location('Leaving '||l_proc,10);
exception
   when others then
    g_status := '4';
end thrd_pty_entries;

procedure cost_entries (p_assignment_id in number,
                        p_perd_start_date in date,
                        p_perd_end_date   in date,
                        p_input_value_id  in number,
                        p_comp_typ_cd in varchar2,
                        p_currency_cd in varchar2,
                        p_uom in varchar2,
                        p_cost_table out nocopy period_table) is

---vkodedal 25-Jun-2009 query modified to fix performance issue bug#8438036
cursor cost_rows is
SELECT ppa.effective_date,
       ppa.effective_date date_earned,
       paa.assignment_id,
       pivf.element_type_id,
       pc.input_value_id,
       pc.debit_or_credit,
       pec.costing_debit_or_credit,
       pc.costed_value,
       petf.output_currency_code,
       pc.cost_id
  FROM
       pay_assignment_actions paa,
       pay_payroll_actions ppa,
       pay_costs pc,
       pay_run_results prr,
       pay_input_values_f pivf,
       pay_element_types_f petf,
       pay_element_classifications pec
 WHERE  paa.payroll_action_id = ppa.payroll_action_id
   AND paa.assignment_action_id = pc.assignment_action_id
   --and paa.assignment_action_id = prr.assignment_action_id
   and prr.RUN_RESULT_ID = pc.run_result_id
   AND NVL (pc.distributed_input_value_id, pc.input_value_id) =
                                                           pivf.input_value_id
   AND pivf.input_value_id = p_input_value_id
   AND petf.element_type_id = pivf.element_type_id
   AND ppa.action_type IN ('C', 'S')
   AND pc.balance_or_cost = 'C'
   AND pec.classification_id = petf.classification_id
   AND ppa.effective_date BETWEEN pivf.effective_start_date
                               AND pivf.effective_end_date
   AND ppa.effective_date BETWEEN petf.effective_start_date
                               AND petf.effective_end_date
   AND paa.assignment_id = p_assignment_id
   AND ppa.effective_date BETWEEN p_perd_start_date AND p_perd_end_date
   AND pc.costed_value IS NOT NULL;

  i integer := 0;
  l_amt number;
  l_proc varchar2(1000) := g_package||' cost_entries';
begin
     hr_utility.set_location('entering '||l_proc,10);
  hr_utility.set_location('inside cost entries with iv'||p_input_value_id,10);
   hr_utility.set_location('asg id'||p_assignment_id,11);
   hr_utility.set_location('date range is '||to_char(p_perd_start_date,'dd/mm/yyyy')||' - '||to_char(p_perd_end_date,'dd/mm/yyyy'),12);
   for cost_rec in cost_rows loop
       i := i + 1;
       p_cost_table(i).start_date := cost_rec.effective_date;
       p_cost_table(i).end_date := cost_rec.effective_date;
       if ( cost_rec.debit_or_credit = 'D'  AND cost_rec.costing_debit_or_credit = 'C' ) OR
       (  cost_rec.debit_or_credit = 'C'  AND cost_rec.costing_debit_or_credit = 'D') then
          l_amt := -1 * cost_rec.costed_value;
       else
          l_amt := cost_rec.costed_value;
       end if;
       p_cost_table(i).value := fnd_number.number_to_canonical(l_amt);
       if p_comp_typ_cd = 'MNTRY' then
           p_cost_table(i).currency_cd := nvl(p_currency_cd,cost_rec.output_currency_code);
       elsif p_comp_typ_cd = 'NNMNTRY' then
            p_cost_table(i).uom := p_uom;
       end if;

       p_cost_table(i).output_key  := cost_rec.cost_id;

   end loop;
  hr_utility.set_location('# of entries'||i,30);
   hr_utility.set_location('Leaving '||l_proc,10);
exception
   when others then
    g_status := '2';
end cost_entries;
----------------------------------------------------------------------
--vkodedal 7012521 Run Results ER
procedure run_results  (p_assignment_id in number,
                        p_perd_start_date in date,
                        p_perd_end_date   in date,
                        p_input_value_id  in number,
                        p_comp_typ_cd in varchar2,
                        p_currency_cd in varchar2,
                        p_uom in varchar2,
                        p_result_table out nocopy period_table) is
cursor  run_results is
SELECT   ppa.effective_date
        ,prrv.RESULT_VALUE
        ,paaf.assignment_id
        ,piv.element_type_id
        ,prrv.input_value_id
        ,prr.run_result_id
        ,pet.output_currency_code
  FROM per_all_assignments_f paaf,
       pay_run_results prr,
       Pay_run_result_values prrv,
       pay_assignment_actions paa,
       pay_payroll_actions ppa,
       pay_input_values_f piv,
       pay_element_types_f pet
 WHERE paaf.assignment_id        = paa.assignment_id
   AND prr.assignment_action_id = paa.assignment_action_id
   AND prr.run_result_id=prrv.run_result_id
   AND paa.PAYROLL_ACTION_ID=ppa.PAYROLL_ACTION_ID
   And piv.input_value_id = p_input_value_id
   and piv.input_value_id=prrv.input_value_id
   And pet.element_type_id = piv.element_type_id
   AND ppa.action_type          IN ('Q', 'R')
   AND ppa.effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
   AND ppa.effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date
   AND ppa.effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
   AND paaf.assignment_id = p_assignment_id
   AND ppa.effective_date BETWEEN p_perd_start_date AND p_perd_end_date;
  i integer := 0;
  l_proc varchar2(1000) := g_package||' run_results';
begin
    hr_utility.set_location('entering '||l_proc,10);
    hr_utility.set_location('inside run results with iv'||p_input_value_id,10);
    hr_utility.set_location('asg id'||p_assignment_id,11);
    hr_utility.set_location('date range is '||to_char(p_perd_start_date,'dd/mm/yyyy')||' - '||to_char(p_perd_end_date,'dd/mm/yyyy'),12);
     for run_rec in run_results loop
       i := i + 1;
       p_result_table(i).start_date := run_rec.effective_date;
       p_result_table(i).end_date := run_rec.effective_date;
       p_result_table(i).value := fnd_number.number_to_canonical(run_rec.result_value);
       if p_comp_typ_cd = 'MNTRY' then
           p_result_table(i).currency_cd := nvl(p_currency_cd,run_rec.output_currency_code);
       elsif p_comp_typ_cd = 'NNMNTRY' then
            p_result_table(i).uom := p_uom;
       end if;

       p_result_table(i).output_key  := run_rec.run_result_id;

   end loop;
  hr_utility.set_location('# of entries'||i,30);
   hr_utility.set_location('Leaving '||l_proc,10);
exception
   when others then
    g_status := '7';
end run_results;
--------------------------------------------------------
procedure get_assignment_details( p_person_id  in   number,
                                  p_effective_date in date,
                                  p_assignment_id in number,
                                  p_payroll_id    out nocopy number,
                                  p_salary_basis_id    out nocopy number
                                 ) is

cursor csr_assignment_details is
Select * from per_all_assignments_f
where person_id = p_person_id
and p_effective_date between effective_start_date and effective_end_date
and assignment_id = p_assignment_id ;

l_assignment_rec csr_assignment_details%rowtype;
l_proc varchar2(60) := g_package||'get_person_details';
Begin
 hr_utility.set_location('Entering'||l_proc,10);

  open csr_assignment_details;
  fetch csr_assignment_details into l_assignment_rec;
  if csr_assignment_details%notfound then
      hr_utility.set_location('invalid Person id  passed',10);

  end if;
  close csr_assignment_details;

  p_payroll_id := l_assignment_rec.payroll_id;
  p_salary_basis_id:= l_assignment_rec.pay_basis_id;
  hr_utility.set_location('Leaving'||l_proc,10);
end get_assignment_details;


procedure get_element_details(p_item_key       in number,
                              p_effective_date in date,
                              p_comp_type_cd   in varchar2,
                              p_element_type_id   out nocopy number,
                              p_processing_type   out nocopy varchar2,
                              p_input_currency_code in out nocopy varchar2,
                              p_uom in out nocopy varchar2,
                              p_actual_uom out nocopy varchar2,
                              p_lookup_type out nocopy varchar2,
                              p_value_set_id  out nocopy varchar2 ,
                              p_actual_currency_code out nocopy varchar2,
                              p_period_start_date in date ) is

cursor csr_element_details is
select inv.input_value_id input_value_id,
       elm.element_type_id element_type_id,
       elm.processing_type processing_type,
       elm.INPUT_CURRENCY_CODE inp_cur_code,
       inv.uom  uom , inv.lookup_type ,inv.value_set_id
from  pay_input_values_f inv, pay_element_types_f elm
where elm.element_type_id =  inv.element_type_id
and   inv.input_value_id = p_item_key
and inv.effective_start_date <= p_effective_date
and inv.effective_end_date >=  p_period_start_date
and elm.effective_start_date  <= p_effective_date
and elm.effective_end_date >= p_period_start_date ;
--and  p_effective_date between inv.effective_start_date and inv.effective_end_date
--and  p_effective_date between elm.effective_start_date and elm.effective_end_date;

l_element_rec csr_element_details%rowtype;
l_proc varchar2(60) := g_package||'get_element_details';
Begin

hr_utility.set_location('Entering'||l_proc,10);
hr_utility.set_location('date'||p_effective_date,1900);
hr_utility.set_location('item'||p_item_key,190);

open csr_element_details;
fetch csr_element_details into l_element_rec;
if csr_element_details%notfound then
  g_status := '1A';
    hr_utility.set_location('Wrong input_value_id passed for Element Entry ', 40);
end if;
close csr_element_details;

p_element_type_id := l_element_rec.element_type_id;
p_processing_type := l_element_rec.processing_type;
p_lookup_type     := l_element_rec.lookup_type;
p_value_set_id    := l_element_rec.value_set_id ;
p_actual_currency_code := l_element_rec.inp_cur_code;

if (p_comp_type_cd = 'MNTRY' and p_input_currency_code is null) then
p_input_currency_code := l_element_rec.inp_cur_code;
elsif (p_comp_type_cd = 'NNMNTRY' and p_uom is null) then
p_uom                  := l_element_rec.uom;
end if;

p_actual_uom := l_element_rec.uom;

hr_utility.set_location('p_actual_uom'||p_actual_uom,10);

hr_utility.set_location('Leaving'||l_proc,10);
end get_element_details;

procedure get_pay_periods( p_perd_st_dt in date,
                           p_perd_en_dt in date,
                           p_frequency  in varchar2
                          ) is
period_start_date date;
period_end_Date date;
flag varchar2(1) := 'Y' ;
l_proc varchar2(60) := g_package||'get_pay_periods';
begin
hr_utility.set_location('Entering'||l_proc,10);
 period_start_date := p_perd_st_dt;
 period_end_date := p_perd_en_dt;
 hr_utility.set_location('freq_cd'||p_frequency,10);
 if p_frequency = 'ANN' then
   while  flag = 'Y'
   loop
     if months_between(p_perd_en_dt,period_start_date) < 12 then
        flag := 'N';
        Insert_period ( p_period_start_date => period_start_date,
                       p_period_end_date  => p_perd_en_dt
                       );
     else
        period_end_date := add_months(period_start_date,12) - 1;
        Insert_period ( p_period_start_date => period_start_date,
                       p_period_end_date  => period_end_date
                       );
        period_start_date := period_end_date + 1;
     end if;
   end loop;
 elsif p_frequency = 'MON' then
   while  flag = 'Y'
   loop
     if months_between(p_perd_en_dt,period_start_date) < 1 then
        flag := 'N';
        Insert_period ( p_period_start_date => period_start_date,
                       p_period_end_date  => p_perd_en_dt
                       );
     else
        period_end_date := add_months(period_start_date,1) - 1;
        Insert_period ( p_period_start_date => period_start_date,
                       p_period_end_date  => period_end_date
                       );
        period_start_date := period_end_date + 1;
     end if;
   end loop;
 elsif p_frequency = 'DA' then
   while  flag = 'Y'
   loop
     if ((p_perd_en_dt - period_start_date) < 1) then
        flag := 'N';
        Insert_period ( p_period_start_date => period_start_date,
                       p_period_end_date  => p_perd_en_dt
                       );
     else
        period_end_date := period_start_date;
        Insert_period ( p_period_start_date => period_start_date,
                       p_period_end_date  => period_end_date
                       );
        period_start_date := period_end_date + 1;
     end if;
   end loop;
 end if;
hr_utility.set_location('Leaving'||l_proc,10);
end get_pay_periods;


procedure get_payroll_periods(p_assignment_id in number,
                              p_perd_st_dt in date,
                              p_perd_en_dt in date,
                              p_value in varchar2,
                              p_output_key in number,
                              p_currency_cd in varchar2,
                              p_uom in varchar2,
                              p_creator_type in varchar2,
                              p_actual_uom    in varchar2,
                              p_salary_basis   in varchar2 default 'N'
                             ) is

cursor csr_asg_payroll is
select distinct asg.payroll_id,
       asg.effective_start_date,
       asg.effective_end_date,
       number_per_fiscal_year,
       status.pay_system_status
from per_all_assignments_f asg,
pay_payrolls_f pay ,per_time_period_types period,PER_ASSIGNMENT_STATUS_TYPES status
where assignment_id = p_assignment_id
--vkodedal = is added to fix payroll period issue 07-Sep-07
and   asg.effective_start_date <= p_perd_en_dt
and   asg.effective_end_date   >= p_perd_st_dt
and   asg.payroll_id is not null
and   pay.payroll_id  = asg.payroll_id
and   pay.effective_end_date  = (select max(effective_end_date) from pay_payrolls_f where payroll_id  =
asg.payroll_id )
and period.period_type = pay.period_type
AND  nvl(status.business_group_id,asg.business_group_id)  = asg.business_group_id
        AND  status.active_flag = 'Y'
        AND  asg.ASSIGNMENT_STATUS_TYPE_ID = status.ASSIGNMENT_STATUS_TYPE_ID
		--vkodedal 20-Nov-2009 Bug#9082203
        AND  status.per_system_status IN ('ACTIVE_ASSIGN', 'ACTIVE_CWK', 'SUSP_ASSIGN')
		--AND  status.pay_system_status = 'P'
        --vkodedal 21-Apr-2009 Bug#8446898
order by  effective_start_date;

cursor csr_payroll_periods (p_pay_id number, p_psd date, p_ped date )is
Select * from PER_TIME_PERIODS_V
where payroll_id = p_pay_id
and not(start_date > p_ped)
and not(end_date < p_psd )
--vkodedal 03-Feb-2010 Bug#8446898
order by end_date;

l_payroll_periods csr_payroll_periods%rowtype;
l_asg_payroll csr_asg_payroll%rowtype;
l_start_date date;
l_end_date date;
l_next_row number;
l_proc varchar2(60) := g_package||'get_payroll_periods';
l_asg_pay varchar2(1) := 'N';
l_value varchar2(240);
begin
hr_utility.set_location('Entering'||l_proc,10);
hr_utility.set_location(l_proc||'  '||p_perd_st_dt,10);
hr_utility.set_location(l_proc||' '||p_perd_en_dt,10);
hr_utility.set_location(l_proc||' '||p_value,10);
hr_utility.set_location('Entering'||l_proc,10);
open csr_asg_payroll;
loop
  fetch csr_asg_payroll into l_asg_payroll;
  exit when csr_asg_payroll%notfound;
  l_asg_pay := 'Y';
----26-Nov-2009 vkodedal ignore if Pay Status is D Bug#9082203
if l_asg_payroll.pay_system_status  = 'P' then

  if l_asg_payroll.effective_start_date < p_perd_st_dt then
     l_start_date := p_perd_st_dt;
  else
     l_start_date := l_asg_payroll.effective_start_date;
  end if;

  if l_asg_payroll.effective_end_date > p_perd_en_dt then
     l_end_date := p_perd_en_dt;
  else
     l_end_date := l_asg_payroll.effective_end_date;
  end if;
  if (p_salary_basis = 'Y' ) then

     l_value  := fnd_number.number_to_canonical(fnd_number.canonical_to_number(p_value)/l_asg_payroll.number_per_fiscal_year );
   else
   l_value := p_value;
   end if;
   hr_utility.set_location('l_start_date  '||l_start_date, 57);
   hr_utility.set_location('l_end_date  '||l_end_date, 57);
   hr_utility.set_location('payroll_id  '||l_asg_payroll.payroll_id, 57);
   open csr_payroll_periods(l_asg_payroll.payroll_id, l_start_date, l_end_date);
   loop
      fetch csr_payroll_periods into l_payroll_periods;
      exit when csr_payroll_periods%notfound;
      if l_payroll_periods.end_date <= p_perd_en_dt then
      if( NVL(g_period_table.LAST, 0) > 0  and   l_payroll_periods.end_date =  g_period_table(NVL(g_period_table.LAST, 0)).end_date) then
         hr_utility.set_location('Entry already created for this period '||l_payroll_periods.end_date ,10);
       else
    --  if l_payroll_periods.end_date <= l_end_date then
       hr_utility.set_location('into the if statment '||p_value,10);
      l_next_row := NVL(g_period_table.LAST, 0) + 1;
      g_period_table(l_next_row).start_date := l_payroll_periods.start_date;
      g_period_table(l_next_row).end_date   := l_payroll_periods.end_date;
      g_period_table(l_next_row).value := l_value;
      g_period_table(l_next_row).currency_cd := p_currency_cd;
      g_period_table(l_next_row).uom := p_uom;
      g_period_table(l_next_row).output_key := p_output_key;
      g_period_table(l_next_row).creator_type := p_creator_type;
      g_period_table(l_next_row).actual_uom := p_actual_uom;
     end if;
      end if;

   end loop;
close csr_payroll_periods;

end if; --end of pay status ='P'
end loop;

 if l_asg_pay = 'N' then
    g_status := '1C';
   hr_utility.set_location('No payroll attached to the assignment',10);
 end if;

close csr_asg_payroll;
hr_utility.set_location('Leaving'||l_proc,10);
end get_payroll_periods;


procedure pay_details (p_elm_table in period_table,
                       p_source_key in number,
                       p_assignment_id in number,
                       p_effective_date in date,
                       p_perd_st_dt in date,
                       p_perd_en_dt  in date,
                       p_currency_cd  in varchar2,
                       p_uom         in varchar2,
                       p_actual_uom in varchar2
                       ) is

l_number_of_rows number;
l_perd_amount number;
l_elm_rows number;
l_proc varchar2(60) := g_package||'pay_details';
l_esd date;
l_eed date;
l_pay_basis_id number;
l_rate_basis varchar2(2000);
l_pay_ann_factor number;
l_name varchar2(2000);
l_no_of_periods number;
l_value number;
l_next_row number;
l_salary_basis varchar2(1);

Begin
hr_utility.set_location('Entering'||l_proc,10);
 l_number_of_rows := p_elm_table.count;
 for ee_row in 1..l_number_of_rows
 loop
    if p_elm_table(ee_row).end_date > p_perd_en_dt then
                   l_eed := p_perd_en_dt;
    else
                   l_eed := p_elm_table(ee_row).end_date;
    end if;

    if p_elm_table(ee_row).start_date < p_perd_st_dt then
                  l_esd := p_perd_st_dt;
    else
                  l_esd := p_elm_table(ee_row).start_date;
    end if;

    hr_utility.set_location('value'||p_elm_table(ee_row).value, 40);
    hr_utility.set_location('stend1'||l_eed, 40);
    hr_utility.set_location('start1'||l_esd, 40);
    if  p_elm_table(ee_row).creator_type = 'SP' then
      /* Get the pay basis id, pay annulization factor and rate basis  from
         per pay bases depending on input_value_id */
         hr_utility.set_location('Creator for element_entry is salary proposal', 40);
          get_salary_basis_details ( p_input_value_id => p_source_key,
                                     p_effective_date => p_effective_date,
                                     p_period_start_date => p_perd_st_dt ,
                                     p_assignment_id  => p_assignment_id,
                                     p_pay_basis_id   => l_pay_basis_id,
                                     p_rate_basis     => l_rate_basis,
                                     p_PAY_ANN_FACTOR => l_pay_ann_factor,
                                     p_name           => l_name
                                    );

         if g_status = '0' then
          if l_pay_ann_factor is not null then
               hr_utility.set_location('Annulization factor is not null', 30);
               l_salary_basis  := 'Y';
               if l_pay_ann_factor <= 0 then
                  l_pay_ann_factor := 1;
               end if;
                IF l_rate_basis = 'HOURLY' THEN
                --Bug 7537970 - pass element entry start date not period start date to get fte factor
                         l_pay_ann_factor := l_pay_ann_factor *PER_SALADMIN_UTILITY.get_fte_factor(p_assignment_id,l_esd);
                END If;
                l_value := l_pay_ann_factor * fnd_number.canonical_to_number(p_elm_table(ee_row).value);
         else
            l_value  := p_elm_table(ee_row).value;
            l_salary_basis := 'N';
        end if ;
           hr_utility.set_location('Annulization factor is null', 30);
              get_payroll_periods(p_assignment_id => p_assignment_id,
                                  p_perd_st_dt    => l_esd,
                                  p_perd_en_dt    => l_eed,
                                  p_value         => fnd_number.number_to_canonical(l_value),
                                  p_output_key    => p_elm_table(ee_row).output_key,
                                  p_currency_cd   => p_currency_cd,
                                  p_uom           => p_uom,
                                  p_creator_type  => p_elm_table(ee_row).creator_type,
                                  p_actual_uom    =>  p_actual_uom,
                                  p_salary_basis  => l_salary_basis
                                );

        --  end if;
         end if;

    else
              get_payroll_periods(p_assignment_id => p_assignment_id,
                                  p_perd_st_dt    => l_esd,
                                  p_perd_en_dt    => l_eed,
                                  p_value         => p_elm_table(ee_row).value,
                                  p_output_key    => p_elm_table(ee_row).output_key,
                                  p_currency_cd   => p_currency_cd,
                                  p_uom           => p_uom,
                                  p_creator_type  => p_elm_table(ee_row).creator_type,
                                  p_actual_uom    =>  p_actual_uom
                                );
    end if;

 end loop;

          hr_utility.set_location('Leaving'||l_proc,10);

End pay_details;

procedure populate_result_table(p_elm_table    in period_table,
                                p_currency_cd in varchar2,
                                p_uom         in varchar2,
                                p_actual_uom         in varchar2
                               ) is
l_number_of_rows number;
l_next_row number;
Begin
 l_number_of_rows := p_elm_table.count;
  hr_utility.set_location('number of rows in p_elm_table '||p_elm_table.count,46);
 for ee_row in 1..l_number_of_rows
 loop

  l_next_row := NVL(g_period_table.LAST, 0) + 1;
  g_period_table(l_next_row).start_date := p_elm_table(ee_row).start_date;
  g_period_table(l_next_row).end_date := p_elm_table(ee_row).end_date;
  g_period_table(l_next_row).value := p_elm_table(ee_row).value;
  g_period_table(l_next_row).currency_cd := p_currency_cd;
  g_period_table(l_next_row).uom := p_uom;
  g_period_table(l_next_row).actual_uom := p_actual_uom;
  g_period_table(l_next_row).output_key := p_elm_table(ee_row).output_key;
  g_period_table(l_next_row).creator_type := p_elm_table(ee_row).creator_type;

 end loop;
end populate_result_table;

procedure get_value_for_item(p_source_cd     in  varchar2,
                             p_source_key    in  varchar2,
                             p_perd_st_dt    in date,
                             p_perd_en_dt    in date,
                             p_person_id     in number,
                             p_assignment_id in number,
                             p_effective_date in date,
                             p_comp_typ_cd    in varchar2,
                             p_currency_cd    in varchar2,
                             p_uom           in varchar2,
                             p_result        out nocopy period_table,
                             p_status        out nocopy varchar2) is

  /* cursor csr_item is select * from ben_tcs_item
                      where item_id = p_comp_item_id; */
   -- l_item_rec csr_item%rowtype;

    l_element_id number;
    l_input_value_id number;
    l_proc_type varchar2(30);
    l_lookup_type varchar2(240);
    l_value_set_id varchar2(240);
    l_actual_currency_code varchar2(30);
    l_el_curr_cd pay_element_types_f.input_currency_code%type;
    l_summary period_table;
    l_uom pay_input_values_f.uom%type;
    l_proc varchar2(60) := g_package||'get_value_for_item';
    l_actual_uom pay_input_values_f.uom%type;

begin
hr_utility.set_location('Entering'||l_proc,10);
hr_utility.set_location('For Person '||p_person_id,499);
hr_utility.set_location('For Assignment id'||p_assignment_id,499);
hr_utility.set_location('For p_perd_en_dt '||p_perd_en_dt,499);

 g_status := '0';
 l_el_curr_cd := p_currency_cd;
 l_uom := p_uom;
 if p_source_cd = 'EE' then

      hr_utility.set_location('source is element entry',20);

            get_element_details(p_item_key            => p_source_key,
                                p_effective_date      => p_effective_date,
                                p_comp_type_cd        => p_comp_typ_cd,
                                p_element_type_id     => l_element_id,
                                p_processing_type     => l_proc_type,
                                p_input_currency_code => l_el_curr_cd,
                                p_uom                 => l_uom,
                                p_actual_uom          => l_actual_uom,
                                p_lookup_type         => l_lookup_type ,
                                p_value_set_id        => l_value_set_id ,
                                p_actual_currency_code=> l_actual_currency_code,
                                p_period_start_date   => p_perd_st_dt
                               );


     hr_utility.set_location('element processing type is '||l_proc_type,31);
     hr_utility.set_location('element uom is '||l_uom,31);
     hr_utility.set_location('element input currency code is '||l_el_curr_cd,31);

     IF (g_status = '1A' )THEN
       WRITE(' The Input Value is not valid as of the Period End Date');
       hr_utility.set_location('1a' ,99);
     END IF;


      if g_status = '0' then
         delete_rows;
         element_entry(p_assignment_id   => p_assignment_id,
                       p_element_type_id => l_element_id,
                       p_input_value_id  => p_source_key,
                       p_perd_st_dt      => p_perd_st_dt,
                       p_perd_en_dt      => p_perd_en_dt,
                       p_summary         => l_summary,
                       p_actual_uom      => l_actual_uom,
                       p_lookup_type     => l_lookup_type,
                       p_value_set_id    => l_value_set_id ,
                       p_actual_currency_code=> l_actual_currency_code );

         hr_utility.set_location('summary table count '||l_summary.count, 30);
         hr_utility.set_location('l_proc_type '||l_proc_type, 30);
         hr_utility.set_location('l_uom '||l_uom, 30);

         --commented for Bug#5098869
         --  if l_proc_type ='R' and l_uom is null  then
         -- added for for Bug#5098869

         if ( l_summary.count > 0) then
         if l_proc_type ='R' then
          hr_utility.set_location('Processing type is Recurring ', 30);
          hr_utility.set_location('st'||p_perd_st_dt ||'end'||p_perd_en_dt,40);

            pay_details  ( p_elm_table        => l_summary,
                           p_source_key     => p_source_key,
                           p_assignment_id  => p_assignment_id,
                           p_effective_date => p_effective_date,
                           p_perd_st_dt     => p_perd_st_dt,
                           p_perd_en_dt     => p_perd_en_dt,
                           p_currency_cd    => l_el_curr_cd,
                           p_uom            => l_uom,
                           p_actual_uom     => l_actual_uom
                          );
          elsif l_proc_type ='N' then

          hr_utility.set_location('Processing tye is N '||l_summary.count, 30);

             populate_result_table(p_elm_table => l_summary,
                                   p_currency_cd => l_el_curr_cd,
                                   p_uom         => l_uom,
                                   p_actual_uom  => l_actual_uom
                                   );
          end if;
          end if;

          if g_status = '0' then
               p_result := g_period_table;
          end if;

        end if;

  elsif p_source_cd = 'PAYCOSTG' then

        hr_utility.set_location('source is Payroll Costing',20);

      cost_entries (p_assignment_id => p_assignment_id,
                    p_perd_start_date => p_perd_st_dt,
                    p_perd_end_date   => p_perd_en_dt,
                    p_input_value_id  => p_source_key,
                    p_comp_typ_cd     => p_comp_typ_cd,
                    p_currency_cd     => p_currency_cd,
                    p_uom             => p_uom,
                    p_cost_table => p_result);

  elsif p_source_cd = 'BB' then

       hr_utility.set_location('source is Benefit balances',20);

      bnfts_entries(p_person_id  => p_person_id,
                    p_perd_st_dt => p_perd_st_dt,
                    p_perd_en_dt => p_perd_en_dt,
                    p_input_value_id  => p_source_key,
                    p_comp_typ_cd     => p_comp_typ_cd,
                    p_currency_cd     => p_currency_cd,
                    p_uom             => p_uom,
                    p_bnfts_table => p_result
                    );

  elsif p_source_cd = 'THRDPTYPAY' then

    hr_utility.set_location('source is Third Party payroll',20);

     thrd_pty_entries(p_assignment_id => p_assignment_id,
                      p_perd_start_date => p_perd_st_dt,
                      p_perd_end_date   => p_perd_en_dt,
                      p_input_value_id  => p_source_key,
                      p_comp_typ_cd     => p_comp_typ_cd,
                      p_currency_cd     => p_currency_cd,
                      p_uom             => p_uom,
                      p_thrd_pty_table => p_result);

   elsif p_source_cd = 'RULE' then

      hr_utility.set_location('source is Rule',20);

     rule_entries(p_assignment_id => p_assignment_id,
                      p_perd_start_date => p_perd_st_dt,
                      p_perd_end_date   => p_perd_en_dt,
                      p_date_earned     => p_effective_date,
                      p_input_value_id  => p_source_key,
                      p_comp_typ_cd     => p_comp_typ_cd,
                      p_currency_cd     => p_currency_cd,
                      p_uom             => p_uom,
                      p_rule_table => p_result);
     --VKODEDAL 7012521 RUN RESULT ER
----------------------------------------------------------------
  elsif p_source_cd = 'RR' then

        hr_utility.set_location('source is Run Results',20);

      run_results  (p_assignment_id => p_assignment_id,
                    p_perd_start_date => p_perd_st_dt,
                    p_perd_end_date   => p_perd_en_dt,
                    p_input_value_id  => p_source_key,
                    p_comp_typ_cd     => p_comp_typ_cd,
                    p_currency_cd     => p_currency_cd,
                    p_uom             => p_uom,
                    p_result_table => p_result);
-----------------------------------------------------------------------
    else
      hr_utility.set_location('Invalid Source Code '||p_source_cd, 200);
      g_status := '6';

  end if;

 IF ( g_status = '1A' ) THEN
    p_status := '0' ;
 ELSE
  p_status := g_status;
 END IF;

    hr_utility.set_location('Leaving'||l_proc,10);

end get_value_for_item;
end BEN_TCS_COMPENSATION;

/
