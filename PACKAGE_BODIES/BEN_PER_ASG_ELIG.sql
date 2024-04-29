--------------------------------------------------------
--  DDL for Package Body BEN_PER_ASG_ELIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PER_ASG_ELIG" as
/* $Header: benperel.pkb 120.1.12010000.3 2009/09/25 06:52:10 krupani ship $ */
--
g_proc varchar2(30) := 'ben_per_asg_elig';

procedure clear_down_cache(p_per_asg_cache_only boolean default false) is
 --
 --
begin
 --
 ben_person_object.clear_down_cache;
 ben_manage_life_events.g_output_string := null;
 if not p_per_asg_cache_only then
    ben_elp_cache.clear_down_cache;
    ben_elig_rl_cache.clear_down_cache;
 end if;
 --
end;
--
--Internal procedure to validate parameters and
--evaluate eligibility
--
procedure internal_eligible
  (p_person_id                      in out nocopy number
  ,p_assignment_id                  in     number
  ,p_assignment_type                in     varchar2
  ,p_elig_obj_id                    in     number
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_save_results                   in     boolean
  ,p_elig_flag                      out nocopy    varchar2
  ) is

l_proc varchar2(61) := g_proc||'.internal_eligible';

cursor c_chk_ebo is
select null
  from ben_elig_obj_f
 where elig_obj_id = p_elig_obj_id
   and p_effective_date between effective_start_date
   and effective_end_date;

cursor c_asg(c_assignment_id  number) is
select person_id
  from per_all_assignments_f asg
 where assignment_id = c_assignment_id
   and p_effective_date between effective_start_date
   and effective_end_date;

cursor c_elig_prof is
select elig_prfl_id,
       nvl(mndtry_flag,'N'),
       'Y',
       'N'
  from ben_elig_obj_elig_profl_f
 where elig_obj_id = p_elig_obj_id
   and p_effective_date between effective_start_date
   and effective_end_date
order by decode(mndtry_flag,'Y',1,2);

cursor c_asg_by_type is
select paf.assignment_id
  from per_all_assignments_f paf
 where paf.person_id = p_person_id
   and decode(substr(p_assignment_type,3,1),'P','Y',paf.primary_flag) = paf.primary_flag
   and decode(substr(p_assignment_type,1,1),'L',paf.assignment_type,substr(p_assignment_type,1,1)) = paf.assignment_type
   and paf.business_group_id  = p_business_group_id
   and p_effective_date between paf.effective_start_date
   and paf.effective_end_date
 order by paf.effective_start_date;

cursor c_elig_rslt(c_person_id      number,
                   c_assignment_id  number,
                   c_effective_date date) is
select elig_rslt_id,
       elig_flag,
       object_version_number,
       effective_start_date,
       effective_end_date
  from ben_elig_rslt_f
 where elig_obj_id = p_elig_obj_id
   and person_id = c_person_id
   and nvl(assignment_id,-1) = nvl(c_assignment_id,-1)
   and c_effective_date between effective_start_date
   and effective_end_date;
l_elig_rslt_rec c_elig_rslt%rowtype;

cursor c_chk_future_rslt(c_person_id      number,
                         c_assignment_id  number,
                         c_effective_date date) is
select min(effective_start_date)
  from ben_elig_rslt_f
 where elig_obj_id = p_elig_obj_id
   and person_id = c_person_id
   and nvl(assignment_id,-1) = nvl(c_assignment_id,-1)
   and effective_start_date > c_effective_date;

l_elig_rslt_id          number;
l_effective_start_date  date;
l_effective_end_date    date;
l_object_version_number number;
l_correction            boolean;
l_update                boolean;
l_update_override       boolean;
l_update_change_insert  boolean;
l_upd_mode              varchar2(30);
l_person_id             number;
l_dummy                 varchar2(1);
l_eligible              boolean;
l_elig_flag             varchar2(1);
l_loop_count            number;
l_min_strt_dt           date;
l_eligprof_tab          ben_evaluate_elig_profiles.proftab;
l_score_tab             ben_evaluate_elig_profiles.scoreTab;

type l_asg_tab_type is table of number
index by binary_integer;

l_asg_tab l_asg_tab_type;

begin

  if p_person_id is null and
     p_assignment_id is null then

     hr_utility.set_message(801, 'HR_7207_API_MANDATORY_ARG');
     hr_utility.set_message_token('API_NAME', l_proc);
     hr_utility.set_message_token('ARGUMENT', 'person_id,assignment_id');
     hr_utility.raise_error;

  end if;

  if p_person_id is null and
     p_assignment_type is not null then

     hr_utility.set_message(801, 'HR_7207_API_MANDATORY_ARG');
     hr_utility.set_message_token('API_NAME', l_proc);
     hr_utility.set_message_token('ARGUMENT', 'person_id');
     hr_utility.raise_error;

  end if;

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'elig_obj_id',
                             p_argument_value => p_elig_obj_id);

  if fnd_global.conc_request_id in (0,-1) then
     ben_env_object.init
     (p_business_group_id => p_business_group_id,
      p_thread_id => null,
      p_chunk_size => null,
      p_threads => null,
      p_max_errors => null,
      p_benefit_action_id => null,
      p_effective_date=> p_effective_date);
  end if;

  open c_chk_ebo;
  fetch c_chk_ebo into l_dummy;
  if c_chk_ebo%notfound then
     close c_chk_ebo;
     hr_utility.set_message(801, 'HR_7180_DT_NO_ROW_EXIST');
     hr_utility.set_message_token('TABLE_NAME', 'ben_elig_obj_f');
     hr_utility.set_message_token('SESSION_DATE', to_char(p_effective_date));
     hr_utility.raise_error;
  end if;
  close c_chk_ebo;

  open c_elig_prof;
  loop
       fetch c_elig_prof into
       l_eligprof_tab(l_eligprof_tab.count+1).eligy_prfl_id,
       l_eligprof_tab(l_eligprof_tab.count+1).mndtry_flag,
       l_eligprof_tab(l_eligprof_tab.count+1).compute_score_flag,
       l_eligprof_tab(l_eligprof_tab.count+1).trk_scr_for_inelg_flag;

       if c_elig_prof%notfound then
          exit;
       end if;

  end loop;
  close c_elig_prof;

  if p_assignment_type <> 'NAA' then
     --
     -- fetch all assignments of the given type
     --
     open c_asg_by_type;
     fetch c_asg_by_type bulk collect into l_asg_tab;
     close c_asg_by_type;
  elsif p_assignment_id is not null then
     l_asg_tab(1) := p_assignment_id;
  end if;

  if p_person_id is null then

     open c_asg(l_asg_tab(1));
     fetch c_asg into l_person_id;
     close c_asg;

     if l_person_id is null then
        hr_utility.set_location('person_id is null and no assignment found',10);
        hr_utility.set_message(801, 'HR_7180_DT_NO_ROW_EXIST');
        hr_utility.set_message_token('TABLE_NAME', 'per_all_assignments_f');
        hr_utility.set_message_token('SESSION_DATE', to_char(p_effective_date));
        hr_utility.raise_error;
     end if;
  else
     l_person_id := p_person_id;
  end if;

  l_loop_count := 0;
  if l_asg_tab.count = 0 then
     --
     -- if only p_person_id is passed in, loop once
     --
     if p_person_id is not null and
        (p_assignment_type is null or
         p_assignment_type = 'NAA') then
        l_loop_count := 1;
        l_asg_tab(l_loop_count) := null;
     end if;
  else
     l_loop_count := l_asg_tab.count;
  end if;

  for i in 1..l_loop_count
  loop

     hr_utility.set_location('Assignment id '||l_asg_tab(i),10);
     if l_eligprof_tab.count > 0 then

        ben_manage_life_events.g_output_string := null;

        l_eligible :=
        ben_evaluate_elig_profiles.eligible
        (p_person_id            => l_person_id,
         p_assignment_id        => l_asg_tab(i),
         p_business_group_id    => p_business_group_id,
         p_eval_typ             => 'E',
         p_comp_obj_mode        => false,
         p_eligprof_tab         => l_eligprof_tab,
         p_score_tab            => l_score_tab,
         p_effective_date       => p_effective_date);
     else
        l_eligible := true;
     end if;

     hr_utility.set_location('Score Tab '||l_score_tab.count,10);
     if l_eligible then
        l_elig_flag := 'Y';
     else
        l_elig_flag := 'N';
     end if;

     if p_save_results then

        open c_elig_rslt(l_person_id,
                         l_asg_tab(i),
                         p_effective_date);
        fetch c_elig_rslt into l_elig_rslt_rec;
        close c_elig_rslt;

        if l_elig_rslt_rec.elig_rslt_id is null then

           ben_elig_rslt_api.create_elig_rslt
           (p_elig_obj_id             =>  p_elig_obj_id,
            p_effective_date          =>  p_effective_date,
            p_business_group_id       =>  p_business_group_id,
            p_person_id               =>  l_person_id,
            p_assignment_id           =>  l_asg_tab(i),
            p_elig_flag               =>  l_elig_flag,
            p_elig_rslt_id            =>  l_elig_rslt_id,
            p_effective_start_date    =>  l_effective_start_date,
            p_effective_end_date      =>  l_effective_end_date,
            p_object_version_number   =>  l_object_version_number);

            --
            --if there is a future result, date track delete this result
            --
            l_min_strt_dt := null;
            open c_chk_future_rslt(l_person_id,
                                   l_asg_tab(i),
                                   p_effective_date);
            fetch c_chk_future_rslt into l_min_strt_dt;
            close c_chk_future_rslt;

            if l_min_strt_dt is not null then

               ben_elig_rslt_api.delete_elig_rslt
              (p_effective_date          =>  l_min_strt_dt-1,
               p_elig_rslt_id            =>  l_elig_rslt_id,
               p_datetrack_mode          =>  hr_api.g_delete,
               p_effective_start_date    =>  l_effective_start_date,
               p_effective_end_date      =>  l_effective_end_date,
               p_object_version_number   =>  l_object_version_number);

            end if;

        elsif l_elig_flag <> l_elig_rslt_rec.elig_flag then

           dt_api.find_dt_upd_modes
           (p_effective_date       => p_effective_date,
            p_base_table_name      => 'BEN_ELIG_RSLT_F',
            p_base_key_column      => 'elig_rslt_id',
            p_base_key_value       => l_elig_rslt_rec.elig_rslt_id,
            p_correction           => l_correction,
            p_update               => l_update,
            p_update_override      => l_update_override,
            p_update_change_insert => l_update_change_insert);

            if l_update then
               l_upd_mode := hr_api.g_update;
            elsif l_update_change_insert then
               l_upd_mode := hr_api.g_update_change_insert;
            else
               l_upd_mode :=  hr_api.g_correction;
            end if;

           ben_elig_rslt_api.update_elig_rslt
           (p_datetrack_mode          =>  l_upd_mode,
            p_elig_obj_id             =>  p_elig_obj_id,
            p_effective_date          =>  p_effective_date,
            p_business_group_id       =>  p_business_group_id,
            p_person_id               =>  l_person_id,
            p_assignment_id           =>  l_asg_tab(i),
            p_elig_flag               =>  l_elig_flag,
            p_elig_rslt_id            =>  l_elig_rslt_rec.elig_rslt_id,
            p_effective_start_date    =>  l_effective_start_date,
            p_effective_end_date      =>  l_effective_end_date,
            p_object_version_number   =>  l_elig_rslt_rec.object_version_number);
        end if;

     end if;

  end loop;

  if p_assignment_type is null then
     p_elig_flag := l_elig_flag;
     p_person_id := l_person_id;
  end if;

end internal_eligible;
--
-- This procedure is called in the batch mode
--
procedure eligible
  (p_person_id                      in     number
  ,p_assignment_type                in     varchar2
  ,p_elig_obj_id                    in     number
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_save_results                   in     boolean
  ) is

l_proc varchar2(61) := g_proc||'.eligible';

l_person_id             number := p_person_id;
l_elig_flag             varchar2(1);

begin

  internal_eligible
  (p_person_id            => l_person_id,
   p_assignment_id        => null,
   p_assignment_type      => p_assignment_type,
   p_elig_obj_id          => p_elig_obj_id,
   p_elig_flag            => l_elig_flag,
   p_business_group_id    => p_business_group_id,
   p_save_results         => p_save_results,
   p_effective_date       => p_effective_date);

end;
--
-- This function evaluates eligibility and stores the results
--
function eligible
  (p_person_id                      in     number   default null
  ,p_assignment_id                  in     number   default null
  ,p_elig_obj_id                    in     number
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_save_results                   in     boolean
  ) return boolean is

l_proc varchar2(61) := g_proc||'.eligible';

l_person_id             number := p_person_id;
l_eligible              boolean;
l_elig_flag             varchar2(1);

begin

  internal_eligible
  (p_person_id            => l_person_id,
   p_assignment_id        => p_assignment_id,
   p_assignment_type      => null,
   p_elig_obj_id          => p_elig_obj_id,
   p_elig_flag            => l_elig_flag,
   p_business_group_id    => p_business_group_id,
   p_save_results         => p_save_results,
   p_effective_date       => p_effective_date);

  l_eligible := (l_elig_flag = 'Y');


  return l_eligible;

end eligible;
--
-- This function is for called from sql statements
--
function eligible
  (p_person_id                      in     number   default null
  ,p_assignment_id                  in     number   default null
  ,p_elig_obj_id                    in     number   default null
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_allow_contingent_wrk           in     varchar2 default 'N'    -- Bug 8920881
  ) return varchar2 is
pragma autonomous_transaction;

l_proc varchar2(61) := g_proc||'.eligible';

l_person_id     number := p_person_id;
l_elig_flag     varchar2(1);

begin

  -- Bug 8920881

  if p_allow_contingent_wrk = 'Y' then
     ben_per_asg_elig.g_allow_contingent_wrk := 'Y';
  else
     ben_per_asg_elig.g_allow_contingent_wrk := 'N';
  end if;

  -- Bug 8920881

  internal_eligible
  (p_person_id            => l_person_id,
   p_assignment_id        => p_assignment_id,
   p_assignment_type      => null,
   p_save_results         => false,
   p_elig_obj_id          => p_elig_obj_id,
   p_elig_flag            => l_elig_flag,
   p_business_group_id    => p_business_group_id,
   p_effective_date       => p_effective_date);

  ben_per_asg_elig.g_allow_contingent_wrk := 'N';  -- Bug 8920881

  return l_elig_flag;

end eligible;

--
-- This function is for called from sql statements
--
function elp_eligible
  (p_person_id                      in     number   default null
  ,p_assignment_id                  in     number   default null
  ,p_eligy_prfl_id                  in     number
  ,p_effective_date                 in     date
  ,p_pl_id                          in     number
  ,p_node_pl_id                     in     number
  ,p_business_group_id              in     number
  ) return varchar2 is
pragma autonomous_transaction;

cursor c_asg(c_assignment_id  number) is
select person_id
  from per_all_assignments_f asg
 where assignment_id = c_assignment_id
   and p_effective_date between effective_start_date
   and effective_end_date;


cursor c_chk_elp is
select null
  from ben_eligy_prfl_f
 where eligy_prfl_id = p_eligy_prfl_id
   and business_group_id = p_business_group_id
   and stat_cd = 'A'
   and p_effective_date between effective_start_date
   and effective_end_date;

l_proc varchar2(61) := g_proc||'.eligible';
l_person_id             number;
l_dummy                 varchar2(1);
l_eligible              boolean;
l_elig_flag             varchar2(1);
l_eligprof_tab          ben_evaluate_elig_profiles.proftab;
l_score_tab             ben_evaluate_elig_profiles.scoreTab;

begin

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);

  hr_utility.set_location('entering elp_eligible',10);
  hr_utility.set_location('p_pl_id '||p_pl_id,10);
  hr_utility.set_location('p_node_pl_id '||p_node_pl_id,10);
  hr_utility.set_location('p_business_group_id '||p_business_group_id,10);
  hr_utility.set_location('p_eligy_prfl_id '||p_eligy_prfl_id,10);

  if p_pl_id <> p_node_pl_id then
     return 'N';
  end if;

  if p_eligy_prfl_id is null then
     return 'Y';
  end if;

  --
  -- check if elp is valid on p_effective_date. It is not possible to check
  -- this in the calling proc because of the connect by behavior
  --
  open c_chk_elp;
  fetch c_chk_elp into l_dummy;
  if c_chk_elp%notfound then
     close c_chk_elp;
     return 'N';
  end if;
  close c_chk_elp;

  if fnd_global.conc_request_id in (0,-1) then
     ben_env_object.init
     (p_business_group_id => p_business_group_id,
      p_thread_id => null,
      p_chunk_size => null,
      p_threads => null,
      p_max_errors => null,
      p_benefit_action_id => null,
      p_effective_date=> p_effective_date);
  end if;

  l_eligprof_tab(1).eligy_prfl_id := p_eligy_prfl_id;
  l_eligprof_tab(1).mndtry_flag := 'Y';

  if p_person_id is null then

     open c_asg(p_assignment_id);
     fetch c_asg into l_person_id;
     close c_asg;

  else
     l_person_id := p_person_id;
  end if;

  ben_manage_life_events.g_output_string := null;

  l_eligible :=
  ben_evaluate_elig_profiles.eligible
  (p_person_id            => l_person_id,
   p_assignment_id        => p_assignment_id,
   p_business_group_id    => p_business_group_id,
   p_eval_typ             => 'E',
   p_comp_obj_mode        => false,
   p_eligprof_tab         => l_eligprof_tab,
   p_score_tab            => l_score_tab,
   p_effective_date       => p_effective_date);

   if l_eligible then
      l_elig_flag := 'Y';
   else
      l_elig_flag := 'N';
   end if;

   return l_elig_flag;

end elp_eligible;

end ben_per_asg_elig;

/
