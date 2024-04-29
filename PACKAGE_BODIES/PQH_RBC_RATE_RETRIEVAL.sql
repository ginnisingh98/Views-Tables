--------------------------------------------------------
--  DDL for Package Body PQH_RBC_RATE_RETRIEVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RBC_RATE_RETRIEVAL" as
/* $Header: pqrbcpkg.pkb 120.10.12010000.1 2008/07/28 13:06:28 appldev ship $ */
--
g_package  varchar2(33) := 'pqh_rbc_rate_retrieval.';  -- Global package name
--
g_person_id number(15):= null;
g_assignment_id number(15):= null;
g_element_type_id number(15):= null;
g_business_group_id number(15):= null;
g_criteria_rate_defn_id number(15):= null;
--
g_asg_rec  per_all_assignments_f%ROWTYPE;
g_per_rec  per_all_people_f%ROWTYPE;
g_empty_tab        ff_exec.outputs_t; -- donot populate. Only to be used a default value
--
--
Type tc_criteria is record(
short_code                        ben_eligy_criteria.short_code%type,
crit_col1_datatype                ben_eligy_criteria.crit_col1_datatype%type,
time_entry_access_table_name1     ben_eligy_criteria.time_entry_access_table_name1%type,
time_entry_access_col_name1       ben_eligy_criteria.time_entry_access_col_name1%type,
crit_col2_datatype                ben_eligy_criteria.crit_col2_datatype%type,
time_entry_access_table_name2     ben_eligy_criteria.time_entry_access_table_name2%type,
time_entry_access_col_name2       ben_eligy_criteria.time_entry_access_col_name2%type);
--
Type tc_criteria_tbl is table of tc_criteria index by binary_integer;
--
--
--
-------------------------< exec_pref_rate_formula >----------------------------------
--
-- Function to execute  the preferential rate formula for a person, and return the rate.
-- Preferential rate formula's return 4 outputs in the following order: Minimum rate,
-- Mid-Value Rate, Maximum rate and Default Rate.
-- Inputs values are Person_id, criteria_rate_defn_id.
--
function exec_pref_rate_formula
                (p_formula_id            in number,
                 p_effective_date        in date,
                 p_param1                in varchar2 ,
                 p_param1_value          in varchar2 ,
                 p_param2                in varchar2 ,
                 p_param2_value          in varchar2 ,
                 p_param3                in varchar2 default null,
                 p_param3_value          in varchar2 default null,
                 p_param4                in varchar2 default null,
                 p_param4_value          in varchar2 default null,
                 p_param5                in varchar2 default null,
                 p_param5_value          in varchar2 default null,
                 p_param6                in varchar2 default null,
                 p_param6_value          in varchar2 default null,
                 p_param7                in varchar2 default null,
                 p_param7_value          in varchar2 default null,
                 p_param8                in varchar2 default null,
                 p_param8_value          in varchar2 default null,
                 p_param9                in varchar2 default null,
                 p_param9_value          in varchar2 default null,
                 p_param10               in varchar2 default null,
                 p_param10_value         in varchar2 default null,
                 p_param_tab             in ff_exec.outputs_t default g_empty_tab
)
return ff_exec.outputs_t is
  --
  l_proc  varchar2(80) := 'exec_pref_rate_formula';
  l_inputs    ff_exec.inputs_t;
  l_outputs   ff_exec.outputs_t;
  j int;
  l_param_tab_count number;
  --
  l_organization_id per_all_assignments_f.organization_id%type;
  l_payroll_id per_all_assignments_f.payroll_id%type;
  l_jurisdiction_code varchar2(150);
   --
  cursor csr_asg_details(p_asg_id in number) is
  Select organization_id, payroll_id
    From per_all_assignments_f
   Where assignment_id = p_asg_id
     and p_effective_date between effective_start_date and effective_end_date;
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  ff_exec.init_formula
       (p_formula_id     => p_formula_id,
        p_effective_date => p_effective_date,
        p_inputs         => l_inputs,
        p_outputs        => l_outputs);
  --
  hr_utility.set_location ('After Init Formula '||l_proc,10);
  --
  l_param_tab_count := p_param_tab.count;
  --
  -- Account for case where formula has no contexts or inputs
  --
  for l_count in nvl(l_inputs.first,0)..nvl(l_inputs.last,-1) loop
    --
    hr_utility.set_location ('Current Context'||l_inputs(l_count).name,10);
    --
    if l_inputs(l_count).name = 'BUSINESS_GROUP_ID' then
      --
      l_inputs(l_count).value := nvl(g_business_group_id, -1);
      --
    elsif l_inputs(l_count).name = 'PAYROLL_ID' then
      --
      l_inputs(l_count).value :=  nvl(l_payroll_id,-1);
      --
      --
    elsif l_inputs(l_count).name = 'ASSIGNMENT_ID' then
      --
      l_inputs(l_count).value := nvl(g_assignment_id, -1);
      --
      --
    elsif l_inputs(l_count).name = 'ORGANIZATION_ID' then
      --
      l_inputs(l_count).value :=  nvl(l_organization_id, -1);
      --
    elsif l_inputs(l_count).name = 'JURISDICTION_CODE' then
      --
      l_inputs(l_count).value :=  nvl(l_jurisdiction_code, 'xx');
      --
      --
    elsif l_inputs(l_count).name = 'DATE_EARNED' then
      --
      -- Note that you must pass the date as a string, that is because
      -- of the canonical date change of 11.5
      --
      -- hr_utility.set_location ('Date Earned '||to_char(p_effective_date),10);
      -- Still the fast formula does't accept the full canonical form.
      -- l_inputs(l_count).value := fnd_date.date_to_canonical(p_effective_date);
      l_inputs(l_count).value := to_char(p_effective_date, 'YYYY/MM/DD');
      --
    elsif l_param_tab_count >0 then

         for j in 1..l_param_tab_count
         loop
            if l_inputs(l_count).name = p_param_tab(j).name then
               l_inputs(l_count).value := p_param_tab(j).value;
            end if;
         end loop;
    elsif l_inputs(l_count).name = p_param1 then
      --
      l_inputs(l_count).value := p_param1_value;
      --
    elsif l_inputs(l_count).name = p_param2 then
      --
      l_inputs(l_count).value := p_param2_value;
      --
    elsif l_inputs(l_count).name = p_param3 then
      --
      l_inputs(l_count).value := p_param3_value;
      --
    elsif l_inputs(l_count).name = p_param4 then
      --
      l_inputs(l_count).value := p_param4_value;
      --
    elsif l_inputs(l_count).name = p_param5 then
      --
      l_inputs(l_count).value := p_param5_value;
      --
    elsif l_inputs(l_count).name = p_param6 then
      --
      l_inputs(l_count).value := p_param6_value;
      --
    elsif l_inputs(l_count).name = p_param7 then
      --
      l_inputs(l_count).value := p_param7_value;
      --
    elsif l_inputs(l_count).name = p_param8 then
      --
      l_inputs(l_count).value := p_param8_value;
      --
    elsif l_inputs(l_count).name = p_param9 then
      --
      l_inputs(l_count).value := p_param9_value;
      --
    elsif l_inputs(l_count).name = p_param10 then
      --
      l_inputs(l_count).value := p_param10_value;
    end if;
    --
  end loop;
  --
  -- We have loaded the input record. Now run the formula.
  --
  ff_exec.run_formula(p_inputs  => l_inputs,
                      p_outputs => l_outputs,
                      p_use_dbi_cache => false); -- bug# 2430017
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
  return l_outputs;
  --
end exec_pref_rate_formula;

-------------------------< apply_pref_rate_code >----------------------------------
--
-- Function to return the preferential rate for a person, for a given rate type.
--
Procedure apply_pref_rate_code
(p_crit_rt_defn_id        IN        number,
 p_eligible_rates         IN        ben_evaluate_rate_matrix.rate_tab,
 p_effective_date         IN        date,
 p_preferential_rate_cd   IN        varchar2,
 p_preferential_rate_rl   IN        varchar2,
 p_preferential_min_rt   OUT nocopy number,
 p_preferential_mid_rt   OUT nocopy number,
 p_preferential_max_rt   OUT nocopy number,
 p_preferential_rt       OUT nocopy number,
 p_rate_factors          OUT nocopy g_rbc_factor_tbl,
 p_rate_factor_cnt       OUT nocopy number)
is
--
l_proc           varchar2(72) := g_package||'apply_pref_rate_code';
--
l_rt_counter     number:= 0;
l_rl_rt_counter  number:= 0;
l_rate           number := 0;
rec_no           number;
l_cnt            number:= 0;
l_outputs        ff_exec.outputs_t;
l_param_tab      ff_exec.outputs_t;
l_rate_matrix_rate_id pqh_rate_matrix_rates_f.rate_matrix_rate_id%type;
--
-- Declare local procedure
--
   Procedure populate_param_tab
   (p_name in varchar2,
    p_value in varchar2) is
    --
    l_next_index number;
    --
  begin
    --
    l_next_index := nvl(l_param_tab.count,0) + 1;
    l_param_tab(l_next_index).name := p_name;
    l_param_tab(l_next_index).value := p_value;
    --
  end;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_rt_counter := p_eligible_rates.count;
  hr_utility.set_location('Total Eligible Rates:'||to_char(l_rt_counter), 6);
  --
  p_rate_factor_cnt := 0;
  --
  If p_preferential_rate_cd = 'HIGHEST' then
     l_rate := p_eligible_rates(1).rate_value;
     p_preferential_rt := p_eligible_rates(1).rate_value;
     p_preferential_min_rt  := p_eligible_rates(1).min_rate_value;
     p_preferential_mid_rt  := p_eligible_rates(1).mid_rate_value;
     p_preferential_max_rt  := p_eligible_rates(1).max_rate_value;
     l_rate_matrix_rate_id  := p_eligible_rates(1).rate_matrix_rate_id;
     --
     For rec_no in 1..l_rt_counter loop
         If p_eligible_rates(rec_no).rate_value > l_rate then
            l_rate := p_eligible_rates(rec_no).rate_value;
            p_preferential_rt := p_eligible_rates(rec_no).rate_value;
            p_preferential_min_rt  := p_eligible_rates(rec_no).min_rate_value;
            p_preferential_mid_rt  := p_eligible_rates(rec_no).mid_rate_value;
            p_preferential_max_rt  := p_eligible_rates(rec_no).max_rate_value;
            l_rate_matrix_rate_id  := p_eligible_rates(rec_no).rate_matrix_rate_id;
         End if;
     End loop;
     --
     -- PAYROLL EVENT CHANGE
     --
     p_rate_factors(1).rate_matrix_rate_id :=  l_rate_matrix_rate_id;
     p_rate_factors(1).default_rate :=  l_rate;
     p_rate_factor_cnt := 1;
     --
     hr_utility.set_location('Highest Rate:'||to_char(l_rate), 6);
  Elsif p_preferential_rate_cd = 'LOWEST' then
     l_rate := p_eligible_rates(1).rate_value;
     p_preferential_rt := p_eligible_rates(1).rate_value;
     p_preferential_min_rt  := p_eligible_rates(1).min_rate_value;
     p_preferential_mid_rt  := p_eligible_rates(1).mid_rate_value;
     p_preferential_max_rt  := p_eligible_rates(1).max_rate_value;
     l_rate_matrix_rate_id  := p_eligible_rates(1).rate_matrix_rate_id;
     --
     For rec_no in 1..l_rt_counter loop
         If p_eligible_rates(rec_no).rate_value < l_rate then
            l_rate := p_eligible_rates(rec_no).rate_value;
            p_preferential_rt := p_eligible_rates(rec_no).rate_value;
            p_preferential_min_rt  := p_eligible_rates(rec_no).min_rate_value;
            p_preferential_mid_rt  := p_eligible_rates(rec_no).mid_rate_value;
            p_preferential_max_rt  := p_eligible_rates(rec_no).max_rate_value;
            l_rate_matrix_rate_id  := p_eligible_rates(rec_no).rate_matrix_rate_id;
         End if;
     End loop;
     --
     -- PAYROLL EVENT CHANGE
     --
     p_rate_factors(1).rate_matrix_rate_id :=  l_rate_matrix_rate_id;
     p_rate_factors(1).default_rate :=  l_rate;
     p_rate_factor_cnt := 1;
     --
     hr_utility.set_location('Lowest Rate:'||to_char(l_rate), 7);
  Elsif p_preferential_rate_cd = 'AVERAGE' then
     For rec_no in 1..l_rt_counter loop
            p_preferential_rt := p_preferential_rt + p_eligible_rates(rec_no).rate_value;
            p_preferential_min_rt  := p_preferential_min_rt + p_eligible_rates(rec_no).min_rate_value;
            p_preferential_mid_rt  := p_preferential_mid_rt + p_eligible_rates(rec_no).mid_rate_value;
            p_preferential_max_rt  := p_preferential_max_rt + p_eligible_rates(rec_no).max_rate_value;
            --
            -- PAYROLL EVENT CHANGE
            --
            p_rate_factors(rec_no).rate_matrix_rate_id := p_eligible_rates(rec_no).rate_matrix_rate_id;
            p_rate_factors(rec_no).default_rate := p_eligible_rates(rec_no).rate_value;
     End loop;
     p_preferential_rt := p_preferential_rt / l_rt_counter;
     p_preferential_min_rt  := p_preferential_min_rt / l_rt_counter;
     p_preferential_mid_rt  := p_preferential_mid_rt / l_rt_counter;
     p_preferential_max_rt  := p_preferential_max_rt / l_rt_counter;
     l_rate := p_preferential_rt;
     --
     p_rate_factor_cnt := l_rt_counter;
     --
     hr_utility.set_location('Average Rate:'||to_char(l_rate), 8);
  Elsif p_preferential_rate_cd = 'RULE' then
     hr_utility.set_location('Calling fast formula', 9);
     --
     -- Setting fast formula inputs. We are reading only the first 5 eligible rates.
     --
     l_rl_rt_counter := l_rt_counter;
     If l_rt_counter > 5 then
        l_rl_rt_counter := 5;
     End if;
     --
     For rec_no in 1..l_rl_rt_counter loop
         populate_param_tab('RATE_MATRIX_RATE_ID'||rec_no,p_eligible_rates(rec_no).rate_matrix_rate_id);
         populate_param_tab('MIN_'||rec_no,p_eligible_rates(rec_no).min_rate_value);
         populate_param_tab('MID_'||rec_no,p_eligible_rates(rec_no).mid_rate_value);
         populate_param_tab('MAX_'||rec_no,p_eligible_rates(rec_no).max_rate_value);
         populate_param_tab('DFLT_'||rec_no,p_eligible_rates(rec_no).rate_value);

     End loop;
     --
     /**
     For rec_no in 1..l_param_tab.count loop
         hr_utility.set_location('Name = '|| l_param_tab(rec_no).name,280);
         hr_utility.set_location('Value = '|| l_param_tab(rec_no).value,280);
     end loop;
     **/
     --
     l_outputs := exec_pref_rate_formula
                (p_formula_id            => p_preferential_rate_rl,
                 p_effective_date        => p_effective_date,
                 p_param1                => 'PQH_RBC_PERSON_ID',
                 p_param1_value          => to_char(nvl(g_person_id, -1)),
                 p_param2                => 'PQH_RBC_CRIT_RATE_DEFN_ID',
                 p_param2_value          => to_char(nvl(g_criteria_rate_defn_id, -1) ),
                 p_param_tab             => l_param_tab );

     for l_count in nvl(l_outputs.first,0)..nvl(l_outputs.last,-1) loop
       --
       hr_utility.set_location ('Current Context'||l_outputs(l_count).name,10);
       --
       if l_outputs(l_count).name = 'MIN' then
          --
          p_preferential_min_rt := l_outputs(l_count).value;
       elsif l_outputs(l_count).name = 'MID' then
          --
          p_preferential_mid_rt  := l_outputs(l_count).value;
       elsif l_outputs(l_count).name = 'MAX' then
          --
          p_preferential_max_rt  := l_outputs(l_count).value;
       elsif l_outputs(l_count).name = 'DFLT' then
          --
          p_preferential_rt  := l_outputs(l_count).value;
          --
        End if;
     End loop;
     --
  Else
     hr_utility.set_location('Invalid Preferential Rate Code:', 10);
     p_preferential_rt := 0;
     p_preferential_min_rt  := 0;
     p_preferential_mid_rt  := 0;
     p_preferential_max_rt  := 0;
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
End;
-------------------------< calculate_preferential_rate >----------------------------------
--
-- Function to return the preferential rate for a person, for a given rate type.
--
Procedure calculate_preferential_rate
(p_crit_rt_defn_id        IN        number,
 p_eligible_rates         IN        ben_evaluate_rate_matrix.rate_tab,
 p_effective_date         IN        date,
 p_rate_factors          OUT nocopy g_rbc_factor_tbl,
 p_rate_factor_cnt       OUT nocopy number,
 p_preferential_min_rt   OUT nocopy number,
 p_preferential_mid_rt   OUT nocopy number,
 p_preferential_max_rt   OUT nocopy number,
 p_preferential_rt       OUT nocopy number)
is
--
l_rt_counter     number:= 0;
l_temp_rate_tab  ben_evaluate_rate_matrix.rate_tab;
l_highest_level  pqh_rate_matrix_nodes.level_number%type;
rec_no           number;
l_cnt            number:= 0;
l_pref_rate_cd   pqh_criteria_rate_defn.preferential_rate_cd%type;
l_pref_rate_rule pqh_criteria_rate_defn.preferential_rate_rule%type;
l_proc           varchar2(72) := g_package||'calculate_preferential_rate';
--
Cursor csr_rate_type is
 Select preferential_rate_cd, preferential_rate_rule
   from pqh_criteria_rate_defn
  Where criteria_rate_defn_id = p_crit_rt_defn_id;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_rt_counter := p_eligible_rates.count;
  hr_utility.set_location('Total Eligible Rates:'||to_char(l_rt_counter), 6);
  --
  If l_rt_counter = 0 then
     -- No matching rates found.
     p_preferential_rt := 0;
     p_preferential_min_rt  := 0;
     p_preferential_mid_rt  := 0;
     p_preferential_max_rt  := 0;
  Elsif l_rt_counter = 1 then
     -- Just one matching rate found.
     p_preferential_rt := p_eligible_rates(l_rt_counter).rate_value;
     p_preferential_min_rt  := p_eligible_rates(l_rt_counter).min_rate_value;
     p_preferential_mid_rt  := p_eligible_rates(l_rt_counter).mid_rate_value;
     p_preferential_max_rt  := p_eligible_rates(l_rt_counter).max_rate_value;
     -- PAYROLL EVENT CHANGE
     p_rate_factors(l_rt_counter).rate_matrix_rate_id :=  p_eligible_rates(l_rt_counter).rate_matrix_rate_id;
     p_rate_factors(l_rt_counter).default_rate :=  p_eligible_rates(l_rt_counter).rate_value;
     p_rate_factor_cnt := l_rt_counter;
     --
  Else
     -- Multiple eligible rates found.
     -- Loop through the eligible rates table and find the rates with highest priority
     -- 1) Find highest level
     l_highest_level := p_eligible_rates(1).level_number;
     --
     For rec_no in 1..l_rt_counter loop
         If p_eligible_rates(rec_no).level_number > l_highest_level then
            l_highest_level := p_eligible_rates(rec_no).level_number;
         End if;
     End loop;
     hr_utility.set_location('Highest level number:'||to_char(l_highest_level), 6);
     --
     -- 2) Copy rates at the highest level into temporary table.
     --
     l_cnt := 0;
     For rec_no in 1..l_rt_counter loop
         If p_eligible_rates(rec_no).level_number = l_highest_level then
            l_cnt := l_cnt + 1;
            l_temp_rate_tab(l_cnt).rate_matrix_rate_id := p_eligible_rates(rec_no).rate_matrix_rate_id;
            l_temp_rate_tab(l_cnt).min_rate_value := p_eligible_rates(rec_no).min_rate_value;
            l_temp_rate_tab(l_cnt).mid_rate_value := p_eligible_rates(rec_no).mid_rate_value;
            l_temp_rate_tab(l_cnt).max_rate_value := p_eligible_rates(rec_no).max_rate_value;
            l_temp_rate_tab(l_cnt).rate_value := p_eligible_rates(rec_no).rate_value;
            l_temp_rate_tab(l_cnt).level_number := p_eligible_rates(rec_no).level_number;
         End if;
     End loop;
     hr_utility.set_location('Rates at highest level number:'||to_char(l_cnt), 6);
     --
     If l_cnt = 1 then
        -- Only one eligible rate found at the highest level.
        p_preferential_rt := l_temp_rate_tab(l_cnt).rate_value;
        p_preferential_mid_rt := l_temp_rate_tab(l_cnt).mid_rate_value;
        p_preferential_min_rt := l_temp_rate_tab(l_cnt).min_rate_value;
        p_preferential_max_rt := l_temp_rate_tab(l_cnt).max_rate_value;
        --
        -- PAYROLL EVENT CHANGE
        --
        p_rate_factors(l_cnt).rate_matrix_rate_id :=  l_temp_rate_tab(l_cnt).rate_matrix_rate_id;
        p_rate_factors(l_cnt).default_rate :=  l_temp_rate_tab(l_cnt).rate_value;
        p_rate_factor_cnt := l_cnt;
        --
     Else
        -- Multiple eligible rates found at highest level.
        -- Apply preferential rate code or preferential rate rule.
        l_pref_rate_cd := 'HIGHEST';
        Open csr_rate_type;
        Fetch csr_rate_type into l_pref_rate_cd, l_pref_rate_rule;
        Close csr_rate_type;
        --
        apply_pref_rate_code
        (p_crit_rt_defn_id        => p_crit_rt_defn_id,
         p_eligible_rates         => l_temp_rate_tab,
         p_effective_date         => p_effective_date,
         p_preferential_rate_cd   => l_pref_rate_cd,
         p_preferential_rate_rl   => l_pref_rate_rule,
         p_preferential_min_rt    => p_preferential_min_rt,
         p_preferential_mid_rt    => p_preferential_mid_rt,
         p_preferential_max_rt    => p_preferential_max_rt,
         p_preferential_rt        => p_preferential_rt,
         p_rate_factors           => p_rate_factors,
         p_rate_factor_cnt        => p_rate_factor_cnt);
     End if;
     --
  End if;
  --
  hr_utility.set_location('Eligible Rate:'||to_char(p_preferential_rt), 6);
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End;
--
-------------------------< determine_crit_rate_defn_rt >----------------------------------
--
-- Function to return the rate for a given rate type. It calls the BEN procedure to get the
-- eligible rates for a given criteria set, marks the preferential rate and applies any
-- calculation method needed.
--
Procedure determine_crit_rate_defn_rt
(p_crit_rt_defn_id        IN        number,
 p_person_id              IN        number default null,
 p_assignment_id          IN        number default null,
 p_business_group_id      IN        number,
 p_effective_date         IN        date,
 p_rate_factors          OUT nocopy g_rbc_factor_tbl,
 p_rate_factor_cnt       OUT nocopy number,
 p_min_rate              OUT nocopy number,
 p_mid_rate              OUT nocopy number,
 p_max_rate              OUT nocopy number,
 p_rate                  OUT nocopy number)
is
--
l_elig_rates       ben_evaluate_rate_matrix.rate_tab;
l_pref_rate        pqh_rate_matrix_rates_f.rate_value%type;
l_min_rate         pqh_rate_matrix_rates_f.min_rate_value%type;
l_mid_rate         pqh_rate_matrix_rates_f.mid_rate_value%type;
l_max_rate         pqh_rate_matrix_rates_f.max_rate_value%type;
--
l_rate_factors     g_rbc_factor_tbl;
l_rate_factor_cnt  number := 0;

--
l_proc  varchar2(72) := g_package||'determine_crit_rate_defn_rt';
--
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 -- Find the eligible rates for the current rate type.
 --
 ben_env_object.init
       (p_business_group_id => p_business_group_id,
       p_effective_date    => p_effective_date,
       p_thread_id         => null,
       p_chunk_size        => null,
       p_threads           => null,
       p_max_errors        => null,
       p_benefit_action_id => null);
 --
 ben_evaluate_rate_matrix.determine_rate
 (p_person_id             => p_person_id,
  p_assignment_id         => p_assignment_id,
  p_criteria_rate_defn_id => p_crit_rt_defn_id,
  p_effective_date        => p_effective_date,
  p_business_group_id     => p_business_group_id,
  p_rate_tab              => l_elig_rates);

 --
 -- Find the preferential rate;
 --
 l_pref_rate := 0;
 --
 calculate_preferential_rate
 (p_crit_rt_defn_id   =>   p_crit_rt_defn_id,
  p_eligible_rates    =>   l_elig_rates,
  p_effective_date    =>   p_effective_date,
  p_preferential_rt   =>   l_pref_rate,
  p_preferential_min_rt   =>   l_min_rate,
  p_preferential_mid_rt   =>   l_mid_rate,
  p_preferential_max_rt   =>   l_max_rate,
  p_rate_factors          =>   p_rate_factors,
  p_rate_factor_cnt       =>   p_rate_factor_cnt);
 --
  p_rate := l_pref_rate;
  p_min_rate := l_min_rate;
  p_mid_rate := l_mid_rate;
  p_max_rate := l_max_rate;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End;
--
--
-------------------------< exec_rate_calc_formula >----------------------------------
--
-- Function to execute the rate calculation formula.The formula's return 4 outputs in the following
-- order: Minimum rate, Mid-Value Rate, Maximum rate and Default Rate.
-- Inputs values are Person_id, criteria_rate_defn_id.
--
function exec_rate_calc_formula
                (p_formula_id            in number,
                 p_effective_date        in date,
                 p_param1                in varchar2 ,
                 p_param1_value          in varchar2 ,
                 p_param2                in varchar2 ,
                 p_param2_value          in varchar2 ,
                 p_param3                in varchar2 default null,
                 p_param3_value          in varchar2 default null,
                 p_param4                in varchar2 default null,
                 p_param4_value          in varchar2 default null,
                 p_param5                in varchar2 default null,
                 p_param5_value          in varchar2 default null,
                 p_param6                in varchar2 default null,
                 p_param6_value          in varchar2 default null,
                 p_param7                in varchar2 default null,
                 p_param7_value          in varchar2 default null,
                 p_param8                in varchar2 default null,
                 p_param8_value          in varchar2 default null,
                 p_param9                in varchar2 default null,
                 p_param9_value          in varchar2 default null,
                 p_param10               in varchar2 default null,
                 p_param10_value         in varchar2 default null,
                 p_param_tab             in ff_exec.outputs_t default g_empty_tab
)
return ff_exec.outputs_t is
  --
  l_proc  varchar2(80) := 'exec_rate_calc_formula';
  l_inputs    ff_exec.inputs_t;
  l_outputs   ff_exec.outputs_t;
  j int;
  l_param_tab_count number;
  --
  l_organization_id per_all_assignments_f.organization_id%type;
  l_payroll_id per_all_assignments_f.payroll_id%type;
  l_jurisdiction_code varchar2(150);
   --
  cursor csr_asg_details(p_asg_id in number) is
  Select organization_id, payroll_id
    From per_all_assignments_f
   Where assignment_id = p_asg_id
     and p_effective_date between effective_start_date and effective_end_date;
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  ff_exec.init_formula
       (p_formula_id     => p_formula_id,
        p_effective_date => p_effective_date,
        p_inputs         => l_inputs,
        p_outputs        => l_outputs);
  --
  hr_utility.set_location ('After Init Formula '||l_proc,10);
  --
  l_param_tab_count := p_param_tab.count;
  --
  -- Account for case where formula has no contexts or inputs
  --
  for l_count in nvl(l_inputs.first,0)..nvl(l_inputs.last,-1) loop
    --
    hr_utility.set_location ('Current Context'||l_inputs(l_count).name,10);
    --
    if l_inputs(l_count).name = 'BUSINESS_GROUP_ID' then
      --
      l_inputs(l_count).value := nvl(g_business_group_id, -1);
      --
    elsif l_inputs(l_count).name = 'PAYROLL_ID' then
      --
      l_inputs(l_count).value :=  nvl(l_payroll_id,-1);
      --
      --
    elsif l_inputs(l_count).name = 'ASSIGNMENT_ID' then
      --
      l_inputs(l_count).value := nvl(g_assignment_id, -1);
      --
      --
    elsif l_inputs(l_count).name = 'ORGANIZATION_ID' then
      --
      l_inputs(l_count).value :=  nvl(l_organization_id, -1);
      --
    elsif l_inputs(l_count).name = 'JURISDICTION_CODE' then
      --
      l_inputs(l_count).value :=  nvl(l_jurisdiction_code, 'xx');
      --
      --
    elsif l_inputs(l_count).name = 'DATE_EARNED' then
      --
      -- Note that you must pass the date as a string, that is because
      -- of the canonical date change of 11.5
      --
      -- hr_utility.set_location ('Date Earned '||to_char(p_effective_date),10);
      -- Still the fast formula does't accept the full canonical form.
      -- l_inputs(l_count).value := fnd_date.date_to_canonical(p_effective_date);
      l_inputs(l_count).value := to_char(p_effective_date, 'YYYY/MM/DD');
      --
    elsif l_param_tab_count >0 then

         for j in 1..l_param_tab_count
         loop
            if l_inputs(l_count).name = p_param_tab(j).name then
               l_inputs(l_count).value := p_param_tab(j).value;
            end if;
         end loop;
    elsif l_inputs(l_count).name = p_param1 then
      --
      l_inputs(l_count).value := p_param1_value;
      --
    elsif l_inputs(l_count).name = p_param2 then
      --
      l_inputs(l_count).value := p_param2_value;
      --
    elsif l_inputs(l_count).name = p_param3 then
      --
      l_inputs(l_count).value := p_param3_value;
      --
    elsif l_inputs(l_count).name = p_param4 then
      --
      l_inputs(l_count).value := p_param4_value;
      --
    elsif l_inputs(l_count).name = p_param5 then
      --
      l_inputs(l_count).value := p_param5_value;
      --
    elsif l_inputs(l_count).name = p_param6 then
      --
      l_inputs(l_count).value := p_param6_value;
      --
    elsif l_inputs(l_count).name = p_param7 then
      --
      l_inputs(l_count).value := p_param7_value;
      --
    elsif l_inputs(l_count).name = p_param8 then
      --
      l_inputs(l_count).value := p_param8_value;
      --
    elsif l_inputs(l_count).name = p_param9 then
      --
      l_inputs(l_count).value := p_param9_value;
      --
    elsif l_inputs(l_count).name = p_param10 then
      --
      l_inputs(l_count).value := p_param10_value;
    end if;
    --
  end loop;
  --
  -- We have loaded the input record. Now run the formula.
  --
  ff_exec.run_formula(p_inputs  => l_inputs,
                      p_outputs => l_outputs,
                      p_use_dbi_cache => false); -- bug# 2430017
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
  return l_outputs;
  --
end exec_rate_calc_formula;


-------------------------< calculate_crit_rate_defn_rt >----------------------------------
--
-- Function to return the rate for a given rate type. It calls the BEN procedure to get the
-- eligible rates for a given criteria set, marks the preferential rate and applies any
-- calculation method needed.
--
Procedure calculate_crit_rate_defn_rt
(p_crit_rt_defn_id        IN        number,
 p_person_id              IN        number default null,
 p_assignment_id          IN        number default null,
 p_business_group_id      IN        number,
 p_effective_date         IN        date,
 p_rate_factors          OUT nocopy g_rbc_factor_tbl,
 p_rate_factor_cnt       OUT nocopy number,
 p_min_rate              OUT nocopy number,
 p_mid_rate              OUT nocopy number,
 p_max_rate              OUT nocopy number,
 p_rate                  OUT nocopy number)
is
--
l_parent_rates     ben_evaluate_rate_matrix.rate_tab;
--
l_ref_period_cd    pqh_criteria_rate_defn.reference_period_cd%type;
l_rate_calc_cd     pqh_criteria_rate_defn.rate_calc_cd%type;
l_rate_calc_rule   pqh_criteria_rate_defn.rate_calc_rule%type;
l_rounding_cd      pqh_criteria_rate_defn.rounding_cd%type;
l_rounding_rule    pqh_criteria_rate_defn.rounding_rule%type;
l_uom              pqh_criteria_rate_defn.uom%type;
l_currency_code    pqh_criteria_rate_defn.currency_code%type;
l_reference_period_cd pqh_criteria_rate_defn.reference_period_cd%type;
--
l_dflt_rate        pqh_rate_matrix_rates_f.rate_value%type := 0;
l_min_rate         pqh_rate_matrix_rates_f.min_rate_value%type := 0;
l_mid_rate         pqh_rate_matrix_rates_f.mid_rate_value%type := 0;
l_max_rate         pqh_rate_matrix_rates_f.max_rate_value%type := 0;
--
l_t_dflt_rate      pqh_rate_matrix_rates_f.rate_value%type := 0;
l_t_min_rate       pqh_rate_matrix_rates_f.min_rate_value%type := 0;
l_t_mid_rate       pqh_rate_matrix_rates_f.mid_rate_value%type := 0;
l_t_max_rate       pqh_rate_matrix_rates_f.max_rate_value%type := 0;
l_t_rate_calc_cd     pqh_criteria_rate_defn.rate_calc_cd%type;
l_t_rate_calc_rule   pqh_criteria_rate_defn.rate_calc_rule%type;
l_t_rounding_cd      pqh_criteria_rate_defn.rounding_cd%type;
l_t_rounding_rule    pqh_criteria_rate_defn.rounding_rule%type;
l_t_ref_period_cd  pqh_criteria_rate_defn.reference_period_cd%type;
l_t_uom            pqh_criteria_rate_defn.uom%type;
l_t_currency_code  pqh_criteria_rate_defn.currency_code%type;
l_t_reference_period_cd pqh_criteria_rate_defn.reference_period_cd%type;
--
l_cnt              number := 0;
l_t_cnt            number := 0;
--
l_freq_conv    number := 0;
l_curr_conv    number := 0;
l_rt_freq_ann  number := 0;
l_ref_freq_ann number := 0;
--
l_rate_factors      g_rbc_factor_tbl;
l_rate_factor_cnt   number := 0;
l_dummy_rt_fact_cnt number := 0;
--
Cursor csr_parent_rates is
 Select parent_criteria_rate_defn_id
   From pqh_criteria_rate_factors
  Where criteria_rate_defn_id = p_crit_rt_defn_id
    and business_group_id = p_business_group_id;
--
Cursor csr_crd_details(p_crit_rt_defn_id in number) is
 Select rate_calc_cd, rate_calc_rule,rounding_cd,rounding_rule,uom,currency_code,reference_period_cd
   from pqh_criteria_rate_defn
  Where criteria_rate_defn_id = p_crit_rt_defn_id
    and business_group_id = p_business_group_id;
--
l_proc  varchar2(72) := g_package||'calculate_crit_rate_defn_rt';
l_outputs        ff_exec.outputs_t;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
 -- Get the calculation method for the rate type. For Norway, the calc method is flat amt.
 --
 Open csr_crd_details(p_crit_rt_defn_id);
 Fetch csr_crd_details into l_rate_calc_cd, l_rate_calc_rule, l_rounding_cd, l_rounding_rule, l_uom,l_currency_code,l_ref_period_cd;
 Close csr_crd_details;
 --
 -- Find the current rate value.
 --
-- p_rate_factors     := null;
 p_rate_factor_cnt  := 0;
-- l_rate_factors     := null;
 l_rate_factor_cnt  := 0;
 l_dummy_rt_fact_cnt:= 0;
 --
 If l_rate_calc_cd = 'AMOUNT' OR
    l_rate_calc_cd = 'PERCENT' OR
    l_rate_calc_cd = 'ADD_TO' then
    --
   determine_crit_rate_defn_rt
  (p_crit_rt_defn_id   =>   p_crit_rt_defn_id,
   p_person_id         =>   p_person_id,
   p_assignment_id     =>   p_assignment_id,
   p_business_group_id =>   p_business_group_id,
   p_effective_date    =>   p_effective_date,
   p_rate_factors      =>   l_rate_factors,
   p_rate_factor_cnt   =>   l_rate_factor_cnt,
   p_rate              =>   l_dflt_rate,
   p_min_rate          =>   l_min_rate,
   p_mid_rate          =>   l_mid_rate,
   p_max_rate          =>   l_max_rate);
   --
   For rec_no in 1..l_rate_factor_cnt loop
       p_rate_factors(rec_no).rate_matrix_rate_id := l_rate_factors(rec_no).rate_matrix_rate_id;
       p_rate_factors(rec_no).default_rate := l_rate_factors(rec_no).default_rate;
   End loop;
   l_dummy_rt_fact_cnt := l_rate_factor_cnt;
   p_rate_factor_cnt := l_dummy_rt_fact_cnt;
   --
 End if;
 --
 -- Find Rate Value for parents
 --
 If l_rate_calc_cd = 'SUM' OR
    l_rate_calc_cd = 'PERCENT' OR
    l_rate_calc_cd = 'ADD_TO' then
 --
 -- If current rate type depends on other rate types, find the rate for the parent rate types.
 --
 For parent_crd_rec in  csr_parent_rates loop
 --
   l_cnt := l_cnt + 1;
 --
  l_t_dflt_rate := 0;
  l_t_min_rate := 0;
  l_t_mid_rate := 0;
  l_t_max_rate := 0;
  l_t_ref_period_cd  := null;
  l_t_uom            := null;
  l_t_currency_code  := null;
  l_t_reference_period_cd := null;

  --
--  l_rate_factors     := null;
  l_rate_factor_cnt  := 0;
  --
   determine_crit_rate_defn_rt
  (p_crit_rt_defn_id   =>   parent_crd_rec.parent_criteria_rate_defn_id,
   p_person_id         =>   p_person_id,
   p_assignment_id     =>   p_assignment_id,
   p_business_group_id =>   p_business_group_id,
   p_effective_date    =>   p_effective_date,
   p_rate_factors      =>   l_rate_factors,
   p_rate_factor_cnt   =>   l_rate_factor_cnt,
   p_rate              =>   l_t_dflt_rate,
   p_min_rate          =>   l_t_min_rate,
   p_mid_rate          =>   l_t_mid_rate,
   p_max_rate          =>   l_t_max_rate);
  --
   For rec_no in 1..l_rate_factor_cnt loop
       l_dummy_rt_fact_cnt := l_dummy_rt_fact_cnt + 1;
       p_rate_factors(l_dummy_rt_fact_cnt).rate_matrix_rate_id := l_rate_factors(rec_no).rate_matrix_rate_id;
       p_rate_factors(l_dummy_rt_fact_cnt).default_rate := l_rate_factors(rec_no).default_rate;
   End loop;
   p_rate_factor_cnt := l_dummy_rt_fact_cnt;
   --
   --
  -- Convert at this point
  --
  Open csr_crd_details(parent_crd_rec.parent_criteria_rate_defn_id);
  Fetch csr_crd_details into l_t_rate_calc_cd, l_t_rate_calc_rule, l_t_rounding_cd, l_t_rounding_rule, l_t_uom,l_t_currency_code,l_t_ref_period_cd;
  Close csr_crd_details;
  --
  If l_uom = 'M' and l_t_uom = 'M' then
         -- get the conv factor between frequencies
         if l_t_ref_period_cd <> l_ref_period_cd then
            l_rt_freq_ann := PQH_RBC_STAGE.get_annual_factor(l_t_ref_period_cd);
            l_ref_freq_ann := PQH_RBC_STAGE.get_annual_factor(l_ref_period_cd);
            l_freq_conv := l_rt_freq_ann/l_ref_freq_ann;
         else
            l_freq_conv := 1;
         end if;
         hr_utility.set_location('freq conv fctr is '||l_freq_conv,46);
         if l_t_currency_code <> l_currency_code then
          -- get the conv factor between currencies from gl_daily_rates
             begin
                select conversion_rate
                into l_curr_conv
                from gl_daily_rates
                where from_currency = l_t_currency_code
                and to_currency = l_currency_code
                and conversion_date = (select max(conversion_date)
                                       from gl_daily_rates
                                       where from_currency = l_t_currency_code
                                       and to_currency = l_currency_code
                                       and conversion_date <= p_effective_date);
             exception
                when no_data_found then
                   hr_utility.set_location('rates not exist',25);
                   l_curr_conv := 1;
                when others then
                   hr_utility.set_location('daily rates pull error',25);
                   raise;
             end;
          else
             l_curr_conv := 1;
          end if;
          hr_utility.set_location('curr conv factr is'||l_curr_conv,28);
          l_t_min_rate := (l_freq_conv * nvl(l_t_min_rate,0)*l_curr_conv);
          l_t_mid_rate := (l_freq_conv * nvl(l_t_mid_rate,0)*l_curr_conv);
          l_t_max_rate := (l_freq_conv * nvl(l_t_max_rate,0)*l_curr_conv);
          l_t_dflt_rate := (l_freq_conv * nvl(l_t_dflt_rate,0)*l_curr_conv);
          --
  Else
   hr_utility.set_location('This should not be happening', 5);
  End if;
  --
  l_parent_rates(l_cnt).min_rate_value := l_t_min_rate;
  l_parent_rates(l_cnt).mid_rate_value := l_t_mid_rate;
  l_parent_rates(l_cnt).max_rate_value := l_t_max_rate;
  l_parent_rates(l_cnt).rate_value := l_t_dflt_rate;
  --
 End loop;
 End if;
 --
 -- Apply Calculation method and find the final rate for the given rate type.
 --
 hr_utility.set_location('No ofParent Rates:'||to_char(l_cnt), 10);
 If l_rate_calc_cd = 'PERCENT' then
    If l_cnt > 0 then
       hr_utility.set_location('Percent', 10);
       l_dflt_rate := (l_dflt_rate/100) * l_parent_rates(1).rate_value;
       l_min_rate := (l_min_rate/100) * l_parent_rates(1).min_rate_value;
       l_mid_rate := (l_mid_rate/100) * l_parent_rates(1).mid_rate_value;
       l_max_rate := (l_max_rate/100) * l_parent_rates(1).max_rate_value;
    End if;
 Elsif l_rate_calc_cd = 'ADD_TO' OR l_rate_calc_cd = 'SUM' then
    If l_cnt > 0 then
       hr_utility.set_location('Sum or Add_To', 10);
       For l_t_cnt in 1..l_cnt  loop
           l_min_rate := l_min_rate + l_parent_rates(l_t_cnt).min_rate_value ;
           l_mid_rate := l_mid_rate + l_parent_rates(l_t_cnt).mid_rate_value ;
           l_max_rate := l_max_rate + l_parent_rates(l_t_cnt).max_rate_value ;
           l_dflt_rate := l_dflt_rate + l_parent_rates(l_t_cnt).rate_value ;
       End loop;
    End if;
Elsif l_rate_calc_cd = 'RULE' then
  -- Use Calculation Rule.
  hr_utility.set_location('Rule', 10);
  l_outputs := exec_rate_calc_formula
               (p_formula_id            => l_rate_calc_rule,
                p_effective_date        => p_effective_date,
                p_param1                => 'PQH_RBC_PERSON_ID',
                p_param1_value          => to_char(nvl(p_person_id, -1)),
                p_param2                => 'PQH_RBC_CRIT_RATE_DEFN_ID',
                p_param2_value          => to_char(nvl(p_crit_rt_defn_id, -1) ));

  for l_count in nvl(l_outputs.first,0)..nvl(l_outputs.last,-1) loop
       --
       hr_utility.set_location ('Current Context'||l_outputs(l_count).name,10);
       --
       if l_outputs(l_count).name = 'MIN' then
          --
          l_min_rate := l_outputs(l_count).value;
       elsif l_outputs(l_count).name = 'MID' then
          --
          l_mid_rate  := l_outputs(l_count).value;
       elsif l_outputs(l_count).name = 'MAX' then
          --
          l_max_rate  := l_outputs(l_count).value;
       elsif l_outputs(l_count).name = 'DFLT' then
          --
          l_dflt_rate  := l_outputs(l_count).value;
          --
        End if;
        --
     End loop;
     --
Elsif l_rate_calc_cd = 'AMOUNT' then
  hr_utility.set_location('Amount', 10);
  null;
Else
  hr_utility.set_message(8302,'PQH_RBC_INVALID_RT_CALC_METHOD');
  hr_utility.raise_error;
End if;
 --
 -- Apply Rounding.
 --
If l_rounding_cd <> 'NONE' then
   --
   hr_utility.set_location('Perform Rounding', 10);
   --
   p_min_rate := benutils.do_rounding
                    (p_rounding_cd    => l_rounding_cd,
                     p_rounding_rl    => l_rounding_rule ,
                     p_assignment_id  => p_assignment_id,
                     p_value          => l_min_rate,
                     p_effective_date => p_effective_date);
   --
   p_mid_rate := benutils.do_rounding
                    (p_rounding_cd    => l_rounding_cd,
                     p_rounding_rl    => l_rounding_rule ,
                     p_assignment_id  => p_assignment_id,
                     p_value          => l_mid_rate,
                     p_effective_date => p_effective_date);
   --
   p_max_rate := benutils.do_rounding
                    (p_rounding_cd    => l_rounding_cd,
                     p_rounding_rl    => l_rounding_rule ,
                     p_assignment_id  => p_assignment_id,
                     p_value          => l_max_rate,
                     p_effective_date => p_effective_date);
   --
   p_rate := benutils.do_rounding
                    (p_rounding_cd    => l_rounding_cd,
                     p_rounding_rl    => l_rounding_rule ,
                     p_assignment_id  => p_assignment_id,
                     p_value          => l_dflt_rate,
                     p_effective_date => p_effective_date);
   --
 Else
   --
   hr_utility.set_location('No Rounding', 10);
   --
   p_min_rate := l_min_rate;
   p_mid_rate := l_mid_rate;
   p_max_rate := l_max_rate;
   p_rate := l_dflt_rate;
 End if;
 --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
----------------------------------------------------------------------------------------------------
--
Procedure popl_crit_list_in_ovrrd_tbl
(p_criteria_list          IN        pqh_popl_criteria_ovrrd.g_crit_ovrrd_val_tbl ,
 p_business_group_id      IN        number,
 p_effective_date         IN        date) is
--
l_proc  varchar2(72) := g_package||'popl_crit_list_in_ovrrd_tbl';
l_crit_val_rec            pqh_popl_criteria_ovrrd.g_crit_ovrrd_val_rec;
cnt                       number(15) := 0;
--
Begin
--
hr_utility.set_location('Entering:'||l_proc, 5);
--
-- If the override list is already populated , populate the global override table for BEN to read.
--

   pqh_popl_criteria_ovrrd.init_criteria_override_tbl;

   For cnt in 1.. p_criteria_list.count loop
       l_crit_val_rec.criteria_short_code := p_criteria_list(cnt).criteria_short_code;
       l_crit_val_rec.number_value1 := p_criteria_list(cnt).number_value1;
       l_crit_val_rec.number_value2 := p_criteria_list(cnt).number_value2;
--       l_crit_val_rec.number_value3 := p_criteria_list(cnt).number_value3;
--       l_crit_val_rec.number_value4 := p_criteria_list(cnt).number_value4;

       l_crit_val_rec.char_value1 := p_criteria_list(cnt).char_value1;
       l_crit_val_rec.char_value2 := p_criteria_list(cnt).char_value2;
--       l_crit_val_rec.char_value3 := p_criteria_list(cnt).char_value3;
--       l_crit_val_rec.char_value4 := p_criteria_list(cnt).char_value4;

       l_crit_val_rec.date_value1 := p_criteria_list(cnt).date_value1;
       l_crit_val_rec.date_value2 := p_criteria_list(cnt).date_value2;
--       l_crit_val_rec.date_value3 := p_criteria_list(cnt).date_value3;
--       l_crit_val_rec.date_value4 := p_criteria_list(cnt).date_value4;

       pqh_popl_criteria_ovrrd.insert_criteria_override(p_crit_ovrrd_val_rec => l_crit_val_rec);

   End loop;
 --
--
hr_utility.set_location('Leaving:'||l_proc, 10);
--
End;
----------------------------------------------------------------------------------------------------
--
Procedure populate_person_override_val
(p_person_id              IN        number,
 p_assignment_id          IN        number,
 p_element_entry_id       IN        number,
 p_business_group_id      IN        number,
 p_effective_date         IN        date) is
--
-- Cursor to select only those eligibility criteria where time card override is not null.
--
 Cursor csr_timecard_ovrrd_exists is
  Select *
    from ben_eligy_criteria
   Where (time_entry_access_table_name1 is not null or time_entry_access_table_name2 is not null)
     and business_group_id = p_business_group_id;
--
l_proc  varchar2(72) := g_package||'populate_person_override_val';
--
l_sql_stmt           varchar2(2000);
l_tc_ovrrd_col       varchar2(100);
l_crit_dtls_tbl      tc_criteria_tbl;
--
l_temp_cnt           number := 0;
l_crit_cnt           number := 0;
l_val_cnt            number := 0;
l_crit_val_rec       pqh_popl_criteria_ovrrd.g_crit_ovrrd_val_rec;
--
l_dummy_value1       varchar2(30);
l_dummy_value2       varchar2(30);
l_cost_allocation_keyflex_id pay_cost_allocation_keyflex.cost_allocation_keyflex_id%type;
--
Cursor csr_input_values is
select a.input_value_id, a.screen_entry_value, b.display_sequence
 from pay_element_entry_values_f a, pay_input_values_f b
Where a.element_entry_id = p_element_entry_id
  and a.input_value_id = b.input_value_id
order by display_sequence;
--
Cursor csr_kflx (p_cost_allocation_keyflex_id in number) is
Select *
  From pay_cost_allocation_keyflex
 Where cost_allocation_keyflex_id = p_cost_allocation_keyflex_id;
--
Begin
--
hr_utility.set_location('Entering:'||l_proc, 5);
--
-- Check if there are any criteria in business group that has timecard override info specified.
-- and fetch its details
--
For csr_tc_rec in csr_timecard_ovrrd_exists loop
    --
    l_crit_cnt := l_crit_cnt + 1;
    l_crit_dtls_tbl(l_crit_cnt).short_code := csr_tc_rec.short_code;
    l_crit_dtls_tbl(l_crit_cnt).crit_col1_datatype := csr_tc_rec.crit_col1_datatype;
    l_crit_dtls_tbl(l_crit_cnt).time_entry_access_table_name1 := csr_tc_rec.time_entry_access_table_name1;
    l_crit_dtls_tbl(l_crit_cnt).time_entry_access_col_name1 := csr_tc_rec.time_entry_access_col_name1;
    l_crit_dtls_tbl(l_crit_cnt).crit_col2_datatype := csr_tc_rec.crit_col2_datatype;
    l_crit_dtls_tbl(l_crit_cnt).time_entry_access_table_name2 := csr_tc_rec.time_entry_access_table_name2;
    l_crit_dtls_tbl(l_crit_cnt).time_entry_access_col_name2 := csr_tc_rec.time_entry_access_col_name2;
    --
    hr_utility.set_location('time_entry_access_col_name1:'||l_crit_dtls_tbl(l_crit_cnt).time_entry_access_col_name1, 20);
    hr_utility.set_location('time_entry_access_col_name2:'||l_crit_dtls_tbl(l_crit_cnt).time_entry_access_col_name2, 20);
    --
End loop;
--
If l_crit_cnt > 0 then
  --
  -- Browse through each criteria, find the override value and populate
  --
  -- 1. Popluate input values
  l_val_cnt := 0;
  For ip_val_rec in csr_input_values loop
     l_val_cnt := l_val_cnt + 1;
     l_tc_ovrrd_col := 'VALUE_'||to_char(l_val_cnt);
     g_entry_val_tbl(l_val_cnt).column_name := l_tc_ovrrd_col;
     g_entry_val_tbl(l_val_cnt).col_value := ip_val_rec.screen_entry_value;
  End loop;

  If l_val_cnt < 15 then
     l_temp_cnt := l_val_cnt + 1;
     For l_temp_cnt2 in l_temp_cnt..15 loop
         --
        l_val_cnt := l_val_cnt + 1;
        l_tc_ovrrd_col := 'VALUE_'||to_char(l_val_cnt);
        g_entry_val_tbl(l_val_cnt).column_name := l_tc_ovrrd_col;
        g_entry_val_tbl(l_val_cnt).col_value := null;
        --
     End loop;
  End if;
  --

  For l_temp_cnt in 1..20 loop
     --
     l_val_cnt := l_val_cnt + 1;
     l_tc_ovrrd_col := 'ATTRIBUTE'||to_char(l_temp_cnt);
     g_entry_val_tbl(l_val_cnt).column_name := l_tc_ovrrd_col;
     l_sql_stmt := 'Begin ';
     l_sql_stmt := l_sql_stmt || 'pqh_rbc_rate_retrieval.g_entry_val_tbl('||to_char(l_val_cnt)||').col_value := pqh_rbc_rate_retrieval.g_entry_rec.'||l_tc_ovrrd_col||';';
     l_sql_stmt := l_sql_stmt || 'End;';
     EXECUTE IMMEDIATE l_sql_stmt;
     --
     hr_utility.set_location(l_sql_stmt,100);
     hr_utility.set_location('Value is:'||g_entry_val_tbl(l_val_cnt).col_value,100);
     --
  End loop;
  --
  For l_temp_cnt in 1..30 loop
     --
     l_val_cnt := l_val_cnt + 1;
     l_tc_ovrrd_col := 'ENTRY_INFORMATION'||to_char(l_temp_cnt);
     g_entry_val_tbl(l_val_cnt).column_name := l_tc_ovrrd_col;
     l_sql_stmt := 'Begin ';
     l_sql_stmt := l_sql_stmt || 'pqh_rbc_rate_retrieval.g_entry_val_tbl('||to_char(l_val_cnt)||').col_value := pqh_rbc_rate_retrieval.g_entry_rec.'||l_tc_ovrrd_col||';';
     l_sql_stmt := l_sql_stmt || 'End;';
     EXECUTE IMMEDIATE l_sql_stmt;
     --
     hr_utility.set_location(l_sql_stmt,90);
     hr_utility.set_location('Value is:'||g_entry_val_tbl(l_val_cnt).col_value,91);
     --
  End loop;
  --
  -- Add Cost allocation flexfield segments.
  --
    l_cost_allocation_keyflex_id := pqh_rbc_rate_retrieval.g_entry_rec.cost_allocation_keyflex_id;
  --
  If l_cost_allocation_keyflex_id is not null then
     Open csr_kflx(l_cost_allocation_keyflex_id);
     Fetch csr_kflx into g_ckf_rec;
     Close csr_kflx;
     --
     For l_temp_cnt in 1..30 loop
         --
         l_val_cnt := l_val_cnt + 1;
         l_tc_ovrrd_col := 'SEGMENT'||to_char(l_temp_cnt);
         g_entry_val_tbl(l_val_cnt).column_name := l_tc_ovrrd_col;
         l_sql_stmt := 'Begin ';
         l_sql_stmt := l_sql_stmt || 'pqh_rbc_rate_retrieval.g_entry_val_tbl('||to_char(l_val_cnt)||').col_value := pqh_rbc_rate_retrieval.g_ckf_rec.'||l_tc_ovrrd_col||';';
         l_sql_stmt := l_sql_stmt || 'End;';
         EXECUTE IMMEDIATE l_sql_stmt;
         --
         hr_utility.set_location(l_sql_stmt,90);
         hr_utility.set_location('Value is:'||g_entry_val_tbl(l_val_cnt).col_value,91);
         --
     End loop;
     --
  End if;
  --
  pqh_popl_criteria_ovrrd.init_criteria_override_tbl;

  For l_temp_cnt in 1..l_crit_cnt loop
      --
      -- Assign the criteria short code.
      l_crit_val_rec.criteria_short_code := l_crit_dtls_tbl(l_temp_cnt).short_code;
      --
      l_dummy_value1 := null;
      l_dummy_value2 := null;
      For l_temp_cnt2 in 1..l_val_cnt loop
               -- Find the value;
               hr_utility.set_location('Comparing:'||l_crit_dtls_tbl(l_temp_cnt).time_entry_access_col_name1||','||g_entry_val_tbl(l_temp_cnt2).column_name,91);
               If l_crit_dtls_tbl(l_temp_cnt).time_entry_access_col_name1  = g_entry_val_tbl(l_temp_cnt2).column_name then
                   l_dummy_value1 := g_entry_val_tbl(l_temp_cnt2).col_value;
               End if;
               If l_crit_dtls_tbl(l_temp_cnt).time_entry_access_col_name2  = g_entry_val_tbl(l_temp_cnt2).column_name then
                   l_dummy_value2 := g_entry_val_tbl(l_temp_cnt2).col_value;
               End if;
               --
      End loop;
      hr_utility.set_location('Criteria Short Code is:'|| l_crit_val_rec.criteria_short_code,100);
      hr_utility.set_location('Override Value1 is:'||l_dummy_value1,101);
      hr_utility.set_location('Override Value2 is:'||l_dummy_value2,102);
      --
      l_crit_val_rec.number_value1 := null;
      l_crit_val_rec.number_value2 := null;
      l_crit_val_rec.char_value1 := null;
      l_crit_val_rec.char_value2 := null;
      l_crit_val_rec.date_value1 := null;
      l_crit_val_rec.date_value2 := null;
      --
      hr_utility.set_location('Initialise override rec ',103);
      --
      If l_crit_dtls_tbl(l_temp_cnt).crit_col1_datatype = 'N' then
         hr_utility.set_location('Copy to number ',103);
         l_crit_val_rec.number_value1 := l_dummy_value1;
         l_crit_val_rec.number_value2 := l_dummy_value2;
      elsif l_crit_dtls_tbl(l_temp_cnt).crit_col1_datatype = 'C' then
         hr_utility.set_location('Copy to char ',103);
         l_crit_val_rec.char_value1 := l_dummy_value1;
         l_crit_val_rec.char_value2 := l_dummy_value2;
      elsif l_crit_dtls_tbl(l_temp_cnt).crit_col1_datatype = 'D' then
         hr_utility.set_location('Copy to date ',103);
         l_crit_val_rec.date_value1 := to_date(l_dummy_value1,'yyyymmdd');
         l_crit_val_rec.date_value2 := to_date(l_dummy_value2,'yyyymmdd');
      End if;
      --
      If l_dummy_value1 is not null or l_dummy_value2 is not null then
         --
         pqh_popl_criteria_ovrrd.insert_criteria_override(p_crit_ovrrd_val_rec => l_crit_val_rec);
         --
      End if;
      --
   End loop;
End if; --If l_crit_cnt > 0
hr_utility.set_location('Leaving:'||l_proc, 10);
--
End;
--
-------------------------< determine_rbc_rate >----------------------------------
-- Function to return the rate for a given element type /criteria rate definition.
-- This is the main function to  be called by other applications to retrieve the RBC rate
-- for a person. No timecard override data will be used in computing the rate.
--
Procedure determine_rbc_rate
(p_element_entry_id       IN        number,
 p_element_type_id        IN        number default null,
 p_business_group_id      IN        number,
 p_effective_date         IN        date,
 p_rate_factors          OUT nocopy g_rbc_factor_tbl,
 p_rate_factor_cnt       OUT nocopy number,
 p_min_rate              OUT nocopy number,
 p_mid_rate              OUT nocopy number,
 p_max_rate              OUT nocopy number,
 p_rate                  OUT nocopy number) is
--
Cursor csr_entry_details is
Select *
  From pay_element_entries_f
 Where element_entry_id = p_element_entry_id
   and p_effective_date between effective_start_date and effective_end_date;
--
cursor csr_linked_crd (p_element_type_id in number)is
Select criteria_rate_defn_id
  from pqh_criteria_rate_elements
 Where element_type_id = p_element_type_id;
--
Cursor csr_per_details (p_per_id in number)is
 Select *
   From per_all_people_f
  Where person_id = p_per_id
    and p_effective_date between effective_start_date and effective_end_date;
  --
Cursor csr_asg_details (p_assignment_id in number) is
select *
  from per_all_assignments_f
 Where assignment_id = p_assignment_id
   and p_effective_date between effective_start_date and effective_end_date;
--
l_crit_rt_defn_id    pqh_criteria_rate_defn.criteria_rate_defn_id%type;
l_assignment_id      per_all_assignments_f.assignment_id%type;
l_person_id          per_all_people_f.person_id%type;
l_proc               varchar2(72) := g_package||'determine_rbc_rate';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  g_person_id := null;
  g_assignment_id := null;
  g_element_type_id := null;
  g_business_group_id := null;
  g_criteria_rate_defn_id := null;
  --
  Open csr_entry_details;
  Fetch csr_entry_details into g_entry_rec;
  Close csr_entry_details;
  --
  If p_element_type_id  is not null then
    g_element_type_id := p_element_type_id;
  else
    g_element_type_id := g_entry_rec.element_type_id;
  End if;
  --
  Open csr_linked_crd (g_element_type_id);
  Fetch csr_linked_crd into l_crit_rt_defn_id;
  If csr_linked_crd%notfound then
     hr_utility.set_message(8302,'PQH_RBC_ELE_NOT_LNKD_RT_TYP');
     hr_utility.raise_error;
  Else
     g_criteria_rate_defn_id := l_crit_rt_defn_id;
  End if;
  Close csr_linked_crd;
  --
  l_assignment_id := g_entry_rec.assignment_id;
  --
  -- Find the assignment and cache its details
  --
  Open csr_asg_details(l_assignment_id);
  Fetch csr_asg_details into g_asg_rec;
  If csr_asg_details%notfound then
     hr_utility.set_message(8302,'PQH_RBC_INVALID_ASG_ID');
     hr_utility.raise_error;
  Else
     g_assignment_id := g_asg_rec.assignment_id;
  End if;
  Close csr_asg_details;
  --
  -- find person's details and cache the information.
  --
  l_person_id := g_asg_rec.person_id;
  Open csr_per_details(l_person_id);
  Fetch csr_per_details into g_per_rec;
  If csr_per_details%notfound then
     hr_utility.set_message(8302,'PQH_RBC_INVALID_PERSON_ID');
     hr_utility.raise_error;
  Else
     g_person_id := l_person_id;
  End if;
  Close csr_per_details;
  --
  g_business_group_id := p_business_group_id;
  --
  -- Populate timecard override
  --
  populate_person_override_val
  (p_person_id         =>   l_person_id,
   p_assignment_id     =>   l_assignment_id,
   p_element_entry_id  =>   p_element_entry_id,
   p_business_group_id =>   p_business_group_id,
   p_effective_date    =>   p_effective_date);
  --
  -- Loop through the rate matrices in the business group and call function to get rate for a
  -- given rate matrix, person, rate type and effective date.
  --
  calculate_crit_rate_defn_rt(
   p_crit_rt_defn_id   =>   l_crit_rt_defn_id,
   p_person_id         =>   l_person_id,
   p_assignment_id     =>   l_assignment_id,
   p_business_group_id =>   p_business_group_id,
   p_effective_date    =>   p_effective_date,
   p_rate_factors      =>   p_rate_factors,
   p_rate_factor_cnt   =>   p_rate_factor_cnt,
   p_rate              =>   p_rate,
   p_min_rate          =>   p_min_rate,
   p_mid_rate          =>   p_mid_rate,
   p_max_rate          =>   p_max_rate);
   --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End;
--
-------------------------< determine_rbc_rate >----------------------------------
-- Function to return the rate for a given element type /criteria rate definition.
-- This is the main function to  be called by other applications to retrieve the RBC rate
-- for a person. No timecard override data will be used in computing the rate.
--
Procedure determine_rbc_rate
(p_element_type_id        IN        number default null,
 p_crit_rt_defn_id        IN        number default null,
 p_person_id              IN        number default null,
 p_assignment_id          IN        number default null,
 p_business_group_id      IN        number,
 p_effective_date         IN        date,
 p_rate_factors          OUT nocopy g_rbc_factor_tbl,
 p_rate_factor_cnt       OUT nocopy number,
 p_min_rate              OUT nocopy number,
 p_mid_rate              OUT nocopy number,
 p_max_rate              OUT nocopy number,
 p_rate                  OUT nocopy number) is
--
--
cursor csr_linked_crd is
Select criteria_rate_defn_id
  from pqh_criteria_rate_elements
 Where element_type_id = p_element_type_id;
--
Cursor csr_per_details (p_per_id in number)is
 Select *
   From per_all_people_f
  Where person_id = p_per_id
    and p_effective_date between effective_start_date and effective_end_date;
  --
Cursor csr_primary_asg_details is
select *
  from per_all_assignments_f
 Where person_id = p_person_id
   and primary_flag = 'Y'
   and p_effective_date between effective_start_date and effective_end_date;
--
Cursor csr_asg_details is
select *
  from per_all_assignments_f
 Where assignment_id = p_assignment_id
   and p_effective_date between effective_start_date and effective_end_date;
--
l_crit_rt_defn_id    pqh_criteria_rate_defn.criteria_rate_defn_id%type;
l_criteria_list      pqh_popl_criteria_ovrrd.g_crit_ovrrd_val_tbl;
l_assignment_id      per_all_assignments_f.assignment_id%type;
l_person_id          per_all_people_f.person_id%type;
l_proc               varchar2(72) := g_package||'determine_rbc_rate';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  g_person_id := null;
  g_assignment_id := null;
  g_element_type_id := null;
  g_business_group_id := null;
  g_criteria_rate_defn_id := null;

  -- At least element type or rate type must be passed, but not both.
  --
  If p_element_type_id is NULL and p_crit_rt_defn_id is NULL then
     --
     hr_utility.set_message(8302,'PQH_RBC_NO_ELE_AND_RT_TYP');
     hr_utility.raise_error;
     --
  Elsif p_element_type_id IS NOT NULL  and p_crit_rt_defn_id IS NULL then
     --
     -- If element type is passed, get the rate type linked to the element.
     --
     Open csr_linked_crd;
     Fetch csr_linked_crd into l_crit_rt_defn_id;
     If csr_linked_crd%notfound then
        hr_utility.set_message(8302,'PQH_RBC_ELE_NOT_LNKD_RT_TYP');
        hr_utility.raise_error;
     Else
        g_criteria_rate_defn_id := l_crit_rt_defn_id;
     End if;
     Close csr_linked_crd;
     --
     g_element_type_id := p_element_type_id;

  Elsif p_crit_rt_defn_id IS NOT NULL then
     --
     -- Rate type is passed directly.
     --
     l_crit_rt_defn_id := p_crit_rt_defn_id;
     --
     g_criteria_rate_defn_id := p_crit_rt_defn_id;

  End if;
  --
  -- 1) At least person id or assignment id or criteria list must be passed
  -- 2) If person id and assignment id is passed or just assignment id is passed,
  -- rate is evaluated for the passed assignment.
  -- 3)If person id is passed , but assignment assignment id is not passed, then
  -- Evaluate rate for primary assignment.
  --
    If p_person_id is NULL and p_assignment_id is NULL then
     --
     hr_utility.set_message(8302,'PQH_RBC_NO_PER_AND_ASG');
     hr_utility.raise_error;
     --
  Elsif p_person_id IS NOT NULL  and p_assignment_id IS NULL then
     --
     -- Find the primary assignment and cache its details
     --
     Open csr_primary_asg_details;
     Fetch csr_primary_asg_details into g_asg_rec;
     If csr_primary_asg_details%notfound then
        hr_utility.set_message(8302,'PQH_RBC_NO_PRIM_ASG');
        hr_utility.raise_error;
     Else
        g_assignment_id := g_asg_rec.assignment_id;
        l_assignment_id := g_asg_rec.assignment_id;
     End if;
     Close csr_primary_asg_details;
     --
     -- find person's details and cache the information.
     --
     Open csr_per_details(p_person_id);
     Fetch csr_per_details into g_per_rec;
     If csr_per_details%notfound then
        hr_utility.set_message(8302,'PQH_RBC_INVALID_PERSON_ID');
        hr_utility.raise_error;
     Else
        g_person_id := p_person_id;
        l_person_id := p_person_id;
     End if;
     Close csr_per_details;

  Elsif p_assignment_id IS NOT NULL then
     --
     -- assignment_id is passed directly. Cache assignment details.
     --
     Open csr_asg_details;
     Fetch csr_asg_details into g_asg_rec;
     If csr_asg_details%notfound then
        hr_utility.set_message(8302,'PQH_RBC_INVALID_ASG_ID');
        hr_utility.raise_error;
     Else
        g_assignment_id := g_asg_rec.assignment_id;
        l_assignment_id := g_asg_rec.assignment_id;
     End if;
     Close csr_asg_details;
     --
     -- Find the person and cache person's details
     --
     Open csr_per_details(g_asg_rec.person_id);
     Fetch csr_per_details into g_per_rec;
     If csr_per_details%notfound then
        hr_utility.set_message(8302,'PQH_RBC_INVALID_PERSON_ID');
        hr_utility.raise_error;
     Else
        g_person_id := g_per_rec.person_id;
        l_person_id := g_per_rec.person_id;
     End if;
     Close csr_per_details;

  End if;
  --
  g_business_group_id := p_business_group_id;
  --
  -- No need to get timecard override.
  -- Loop through the rate matrices in the business group and call function to get rate for a
  -- given rate matrix, person, rate type and effective date.
  --
  calculate_crit_rate_defn_rt(
   p_crit_rt_defn_id   =>   l_crit_rt_defn_id,
   p_person_id         =>   l_person_id,
   p_assignment_id     =>   l_assignment_id,
   p_business_group_id =>   p_business_group_id,
   p_effective_date    =>   p_effective_date,
   p_rate_factors      =>   p_rate_factors,
   p_rate_factor_cnt   =>   p_rate_factor_cnt,
   p_rate              =>   p_rate,
   p_min_rate          =>   p_min_rate,
   p_mid_rate          =>   p_mid_rate,
   p_max_rate          =>   p_max_rate);
   --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End;
--
-------------------------< determine_rbc_rate >----------------------------------
--
-- Overloaded function to return the rate for a given element type. This is the main function to
-- be called by other applications to retrieve the RBC rate for a criteria list.
--
Procedure determine_rbc_rate
(p_element_type_id        IN        number default null,
 p_crit_rt_defn_id        IN        number default null,
 p_business_group_id      IN        number,
 p_criteria_list          IN        pqh_popl_criteria_ovrrd.g_crit_ovrrd_val_tbl,
 p_effective_date         IN        date,
 p_rate_factors          OUT nocopy g_rbc_factor_tbl,
 p_rate_factor_cnt       OUT nocopy number,
 p_min_rate              OUT nocopy number,
 p_mid_rate              OUT nocopy number,
 p_max_rate              OUT nocopy number,
 p_rate                  OUT nocopy number) is
--
l_crit_rt_defn_id    pqh_criteria_rate_defn.criteria_rate_defn_id%type;
l_criteria_list      pqh_popl_criteria_ovrrd.g_crit_ovrrd_val_tbl;
--
cursor csr_linked_crd is
Select criteria_rate_defn_id
  from pqh_criteria_rate_elements
 Where element_type_id = p_element_type_id;
--
l_proc  varchar2(72) := g_package||'determine_rbc_rate';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  g_person_id := null;
  g_assignment_id := null;
  g_element_type_id := null;
  g_business_group_id := null;
  g_criteria_rate_defn_id := null;

  -- At least element type or rate type must be passed, but not both.
  --
  If p_element_type_id is NULL and p_crit_rt_defn_id is NULL then
     --
     hr_utility.set_message(8302,'PQH_RBC_NO_ELE_AND_RT_TYP');
     hr_utility.raise_error;
     --
  Elsif p_element_type_id IS NOT NULL  and p_crit_rt_defn_id IS NULL then
     --
     -- If element type is passed, get the rate type linked to the element.
     --
     Open csr_linked_crd;
     Fetch csr_linked_crd into l_crit_rt_defn_id;
     If csr_linked_crd%notfound then
        hr_utility.set_message(8302,'PQH_RBC_ELE_NOT_LNKD_RT_TYP');
        hr_utility.raise_error;
     Else
        g_criteria_rate_defn_id := l_crit_rt_defn_id;
     End if;
     Close csr_linked_crd;
     --
     g_element_type_id := p_element_type_id;
  Elsif p_crit_rt_defn_id IS NOT NULL then
     --
     -- Rate type is passed directly.
     --
     l_crit_rt_defn_id := p_crit_rt_defn_id;
     --
     g_criteria_rate_defn_id := p_crit_rt_defn_id;
  End if;
  --
  g_business_group_id := p_business_group_id;
  --
  -- Populate the global criteria value override structure either from the passed criteria list.
  --
  popl_crit_list_in_ovrrd_tbl
  (p_criteria_list     =>   p_criteria_list,
   p_business_group_id =>   p_business_group_id,
   p_effective_date    =>   p_effective_date);
  --
  -- Loop through the rate matrices in the business group and call function to get rate for a
  -- given rate matrix, set of criteria, rate type and effective date.
  --
  calculate_crit_rate_defn_rt
  (p_crit_rt_defn_id   =>   p_crit_rt_defn_id,
   p_person_id         =>   null,
   p_assignment_id     =>   null,
   p_business_group_id =>   p_business_group_id,
   p_effective_date    =>   p_effective_date,
   p_rate_factors      =>   p_rate_factors,
   p_rate_factor_cnt   =>   p_rate_factor_cnt,
   p_rate              =>   p_rate,
   p_min_rate          =>   p_min_rate,
   p_mid_rate          =>   p_mid_rate,
   p_max_rate          =>   p_max_rate);
  --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End;
--
----------------------------------------------------------------------------------------------------
-- The following are functions that return a person's default rate only.
--
Function get_persons_rbc_rate
(p_element_type_id        IN        number default null,
 p_crit_rt_defn_id        IN        number default null,
 p_person_id              IN        number default null,
 p_assignment_id          IN        number default null,
 p_business_group_id      IN        number,
 p_effective_date         IN        date)
return  number is
--
l_rate   pqh_rate_matrix_rates_f.rate_value%type := 0;
l_min_rate   pqh_rate_matrix_rates_f.min_rate_value%type := 0;
l_mid_rate   pqh_rate_matrix_rates_f.mid_rate_value%type := 0;
l_max_rate   pqh_rate_matrix_rates_f.max_rate_value%type := 0;
--
l_rate_factors     g_rbc_factor_tbl;
l_rate_factor_cnt  number := 0;
--
l_proc  varchar2(72) := g_package||'get_persons_rbc_rate';
--
Begin
 --
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
 determine_rbc_rate(
 p_element_type_id => p_element_type_id,
 p_crit_rt_defn_id => p_crit_rt_defn_id,
 p_person_id       => p_person_id,
 p_assignment_id   => p_assignment_id,
 p_business_group_id => p_business_group_id,
 p_effective_date  => p_effective_date,
 p_rate_factors    => l_rate_factors,
 p_rate_factor_cnt => l_rate_factor_cnt,
 p_rate            => l_rate,
 p_min_rate        => l_min_rate,
 p_mid_rate        => l_mid_rate,
 p_max_rate        => l_max_rate);
 --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
 Return l_rate;
 --
End get_persons_rbc_rate;
--------------------------------------------------------------------------------------------------
--
Function get_persons_rbc_rate
(p_element_type_id        IN        number default null,
 p_crit_rt_defn_id        IN        number default null,
 p_business_group_id      IN        number,
 p_criteria_list          IN        pqh_popl_criteria_ovrrd.g_crit_ovrrd_val_tbl,
 p_effective_date         IN        date)
return  number is
--
l_rate   pqh_rate_matrix_rates_f.rate_value%type := 0;
l_min_rate   pqh_rate_matrix_rates_f.min_rate_value%type := 0;
l_mid_rate   pqh_rate_matrix_rates_f.mid_rate_value%type := 0;
l_max_rate   pqh_rate_matrix_rates_f.max_rate_value%type := 0;
--
l_rate_factors     g_rbc_factor_tbl;
l_rate_factor_cnt  number := 0;
--
l_proc  varchar2(72) := g_package||'get_persons_rbc_rate';
--
Begin
 --
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
 determine_rbc_rate(
 p_element_type_id => p_element_type_id,
 p_crit_rt_defn_id => p_crit_rt_defn_id,
 p_business_group_id => p_business_group_id,
 p_criteria_list   => p_criteria_list,
 p_effective_date  => p_effective_date,
 p_rate_factors    => l_rate_factors,
 p_rate_factor_cnt => l_rate_factor_cnt,
 p_rate            => l_rate,
 p_min_rate        => l_min_rate,
 p_mid_rate        => l_mid_rate,
 p_max_rate        => l_max_rate);
 --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
 Return l_rate;
 --
End get_persons_rbc_rate;
--
--------------------------------------------------------------------------------------------------
--
Function get_ele_entry_rbc_rate
(p_element_entry_id       IN        number,
 p_business_group_id      IN        number,
 p_effective_date         IN        date)
return  number is
--
l_rate   pqh_rate_matrix_rates_f.rate_value%type := 0;
l_min_rate   pqh_rate_matrix_rates_f.min_rate_value%type := 0;
l_mid_rate   pqh_rate_matrix_rates_f.mid_rate_value%type := 0;
l_max_rate   pqh_rate_matrix_rates_f.max_rate_value%type := 0;
--
l_rate_factors     g_rbc_factor_tbl;
l_rate_factor_cnt  number := 0;
--
l_proc  varchar2(72) := g_package||'get_ele_entry_rbc_rate';
--
Begin
 --
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
 determine_rbc_rate(
 p_element_entry_id => p_element_entry_id,
 p_element_type_id  => null,
 p_business_group_id => p_business_group_id,
 p_effective_date  => p_effective_date,
 p_rate_factors    => l_rate_factors,
 p_rate_factor_cnt => l_rate_factor_cnt,
 p_rate            => l_rate,
 p_min_rate        => l_min_rate,
 p_mid_rate        => l_mid_rate,
 p_max_rate        => l_max_rate);
 --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
 Return l_rate;
 --
End get_ele_entry_rbc_rate;
--
Function get_ele_entry_rbc_rate
(p_element_entry_id       IN        number,
 p_business_group_id      IN        number,
 p_effective_date         IN        date,
 p_element_type_id        IN        number)
return  number is
--
l_rate   pqh_rate_matrix_rates_f.rate_value%type := 0;
l_min_rate   pqh_rate_matrix_rates_f.min_rate_value%type := 0;
l_mid_rate   pqh_rate_matrix_rates_f.mid_rate_value%type := 0;
l_max_rate   pqh_rate_matrix_rates_f.max_rate_value%type := 0;
--
l_rate_factors     g_rbc_factor_tbl;
l_rate_factor_cnt  number := 0;
--
l_proc  varchar2(72) := g_package||'get_ele_entry_rbc_rate';
--
Begin
 --
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
 determine_rbc_rate(
 p_element_entry_id => p_element_entry_id,
 p_element_type_id  => p_element_type_id,
 p_business_group_id => p_business_group_id,
 p_effective_date  => p_effective_date,
 p_rate_factors    => l_rate_factors,
 p_rate_factor_cnt => l_rate_factor_cnt,
 p_rate            => l_rate,
 p_min_rate        => l_min_rate,
 p_mid_rate        => l_mid_rate,
 p_max_rate        => l_max_rate);
 --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
 Return l_rate;
 --
End get_ele_entry_rbc_rate;
--
End pqh_rbc_rate_retrieval;

/
