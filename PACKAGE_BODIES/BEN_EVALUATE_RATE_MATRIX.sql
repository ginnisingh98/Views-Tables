--------------------------------------------------------
--  DDL for Package Body BEN_EVALUATE_RATE_MATRIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EVALUATE_RATE_MATRIX" as
/* $Header: benrtmtx.pkb 120.1 2005/12/23 01:30:41 mmudigon noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
-- Package Variables
--
TYPE node_tbl_typ  IS TABLE OF varchar2(1)  INDEX BY binary_integer;
g_node_tbl    node_tbl_typ  ;

g_debug boolean := hr_utility.debug_enabled;
g_package  varchar2(33) := 'ben_evaluate_rate_matrix.';
--
-- ----------------------------------------------------------------------------
-- |                     Procedure Definitions                                |
-- ----------------------------------------------------------------------------
--
-- Public procedure to determine rate given a person and rate type
--
procedure determine_rate
(p_person_id                number default null,
 p_assignment_id            number default null,
 p_criteria_rate_defn_id    number,
 p_effective_date           date,
 p_business_group_id        number,
 p_rate_tab                 out nocopy rate_tab) is

cursor c_pl is
select distinct pln.pl_id
  from ben_pl_f pln,
       pqh_rate_matrix_nodes rmn
 where p_effective_date between pln.effective_start_date
   and pln.effective_end_date
   and pln.business_group_id = p_business_group_id
   and pln.pl_id = rmn.pl_id
   and pln.pl_stat_cd = 'A';

cursor c_rate_matrix(p_pl_id  number) is
select level,
       rmn.rate_matrix_node_id,
       rmn.pl_id,
       rmn.node_name,
       rmn.parent_node_id,
       rmn.eligy_prfl_id,
       rmn.business_group_id,
       rmn.level_number
  from pqh_rate_matrix_nodes rmn
start with rmn.rate_matrix_node_id in
           (select rate_matrix_node_id
              from pqh_rate_matrix_nodes
             where business_group_id = p_business_group_id
               and pl_id = p_pl_id
               and parent_node_id is null)
connect by prior rmn.rate_matrix_node_id = rmn.parent_node_id;
l_rate_matrix_rec c_rate_matrix%rowtype;

cursor c_rt is
select rate_matrix_node_id,
       rate_matrix_rate_id,
       min_rate_value,
       max_rate_value,
       mid_rate_value,
       rate_value
  from pqh_rate_matrix_rates_f
 where rate_matrix_node_id = l_rate_matrix_rec.rate_matrix_node_id
   and p_effective_date between effective_start_date
   and effective_end_date
   and criteria_rate_defn_id = p_criteria_rate_defn_id;
l_rt_rec c_rt%rowtype;

l_rt_counter            number := 0;
l_pl_id                 number;
l_mtx_pl_id             number;
l_eligprof_tab          ben_evaluate_elig_profiles.proftab;
l_parent_eligible       varchar2(1);
l_node_eligible         varchar2(1);
l_proc                  varchar2(61) := g_package||'determine_rate';

begin

g_debug := hr_utility.debug_enabled;

if g_debug then
   hr_utility.set_location('Entering :'||l_proc,5);
   hr_utility.set_location('p_person_id '||p_person_id,5);
   hr_utility.set_location('p_assignment_id '||p_assignment_id,5);
   hr_utility.set_location('p_criteria_rate_defn_id '||p_criteria_rate_defn_id,5);
   hr_utility.set_location('p_effective_date '||p_effective_date,5);
end if;

hr_api.mandatory_arg_error(p_api_name       => l_proc,
                           p_argument       => 'effective_date',
                           p_argument_value => p_effective_date);

hr_api.mandatory_arg_error(p_api_name       => l_proc,
                           p_argument       => 'business_group_id',
                           p_argument_value => p_business_group_id);

hr_api.mandatory_arg_error(p_api_name       => l_proc,
                           p_argument       => 'criteria_rate_defn_id',
                           p_argument_value => p_criteria_rate_defn_id);

ben_per_asg_elig.clear_down_cache;

open c_pl;
loop
  fetch c_pl into l_mtx_pl_id;
  if c_pl%notfound then
     exit;
  end if;

  hr_utility.set_location('l_mtx_pl_id '||l_mtx_pl_id,5);

  open c_rate_matrix(l_mtx_pl_id);
  loop
     fetch c_rate_matrix into l_rate_matrix_rec;
     if c_rate_matrix%notfound then
        exit;
     end if;

     if g_debug then
        hr_utility.set_location(lpad('+',(l_rate_matrix_rec.level-1),'+')||l_rate_matrix_rec.node_name,10);
        hr_utility.set_location('elp id '||l_rate_matrix_rec.eligy_prfl_id,10);
        hr_utility.set_location('pl id '||l_rate_matrix_rec.pl_id,10);
        hr_utility.set_location('bg id '||l_rate_matrix_rec.business_group_id,10);
     end if;

     l_parent_eligible := 'N';
     l_node_eligible := 'N';

     if l_rate_matrix_rec.level = 1 then
        g_node_tbl.delete;
        l_pl_id := l_rate_matrix_rec.pl_id;
        l_node_eligible :=  ben_per_asg_elig.elp_eligible(p_person_id,p_assignment_id,l_rate_matrix_rec.eligy_prfl_id,p_effective_date,l_mtx_pl_id,l_rate_matrix_rec.pl_id,p_business_group_id);
     else
        if g_node_tbl.exists(l_rate_matrix_rec.parent_node_id) then
           l_parent_eligible := g_node_tbl(l_rate_matrix_rec.parent_node_id);
           if l_parent_eligible = 'Y' then
              l_node_eligible :=  ben_per_asg_elig.elp_eligible(p_person_id,p_assignment_id,l_rate_matrix_rec.eligy_prfl_id,p_effective_date,l_mtx_pl_id,l_rate_matrix_rec.pl_id,p_business_group_id);
           else
              l_node_eligible :=  'N';
           end if;
        else
              l_node_eligible :=  'N';
        end if;
     end if;

     g_node_tbl(l_rate_matrix_rec.rate_matrix_node_id) := l_node_eligible ;

     if l_node_eligible = 'Y' then

        l_rt_rec := null;
        open c_rt;
        fetch c_rt into l_rt_rec;
        close c_rt;

        if l_rt_rec.rate_matrix_node_id is not null and
           l_pl_id is not null then
           l_rt_counter := p_rate_tab.count +1;
           p_rate_tab(l_rt_counter).pl_id := l_pl_id;
           p_rate_tab(l_rt_counter).rate_matrix_node_id := l_rt_rec.rate_matrix_node_id;
           p_rate_tab(l_rt_counter).rate_matrix_rate_id := l_rt_rec.rate_matrix_rate_id;
           p_rate_tab(l_rt_counter).min_rate_value := l_rt_rec.min_rate_value;
           p_rate_tab(l_rt_counter).max_rate_value := l_rt_rec.max_rate_value;
           p_rate_tab(l_rt_counter).mid_rate_value := l_rt_rec.mid_rate_value;
           p_rate_tab(l_rt_counter).rate_value := l_rt_rec.rate_value;
           p_rate_tab(l_rt_counter).level_number := l_rate_matrix_rec.level_number;
        end if;
     end if;

  end loop;
  close c_rate_matrix;

end loop;
close c_pl;

if g_debug then
   hr_utility.set_location('Leaving :'||l_proc,5);
end if;

end determine_rate;

end ben_evaluate_rate_matrix;

/
