--------------------------------------------------------
--  DDL for Package Body BEN_EVALUATE_RATE_PROFILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EVALUATE_RATE_PROFILES" as
/* $Header: benrtprf.pkb 120.5.12010000.4 2008/08/05 14:54:27 ubhat ship $ */
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--    Global exception handler
--
g_criteria_failed exception;
g_package        varchar2(80) := 'ben_evaluate_rate_profiles';
--
-- ---------------------------------------------------------------
--    People Group
-- ---------------------------------------------------------------
--
procedure check_people_group
  (p_vrbl_rt_prfl_id      in number
  ,p_business_group_id    in number
  ,p_effective_date       in date
  ,p_lf_evt_ocrd_dt       in date
  ,p_people_group_id      in varchar2) is
  --
  l_inst_set ben_rt_prfl_cache.g_pg_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  l_seg_ok     boolean := true;
  --
  l_const   varchar2(50) := hr_api.g_varchar2;
  --
   cursor c_ppl_grp is
   select ppg.people_group_id , ppg.segment1 ,ppg.segment2 ,ppg.segment3 ,ppg.segment4 ,
          ppg.segment5  , ppg.segment6  ,ppg.segment7  ,ppg.segment8  ,ppg.segment9 , ppg.segment10 ,
          ppg.segment11 , ppg.segment12 ,ppg.segment13 ,ppg.segment14 ,ppg.segment15 ,
          ppg.segment16 , ppg.segment17 ,ppg.segment18 ,ppg.segment19 ,ppg.segment20 ,
          ppg.segment21 , ppg.segment22 ,ppg.segment23 ,ppg.segment24 ,ppg.segment25 ,
          ppg.segment26 , ppg.segment27 ,ppg.segment28 ,ppg.segment29 ,ppg.segment30
   from pay_people_groups ppg
   where ppg.people_group_id =  p_people_group_id ;

   --
   l_ppl_grp_rec  c_ppl_grp%ROWTYPE ;
   l_match        boolean ;
--
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
--
-- case 1 : id's of profile and ppl grp match, indicating perfect match.
--
      l_ok := l_inst_set(i).people_group_id = p_people_group_id;
      --
      if l_ok is null or p_people_group_id is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise g_criteria_failed;
        l_seg_ok := false;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        l_ok := true ;
        -- exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
--
-- case 2 : id's do not match so search for a match.
--

       open c_ppl_grp ;
       fetch c_ppl_grp into l_ppl_grp_rec ;
       close c_ppl_grp ;

	-- Bug 3241479 If there are multiple segments enabled
	-- we need to return false even if one condition fails.
	-- appending l_seg_ok to all the conditions.

	-- To enter we are first setting the l_seg_ok to true.

       -- Start of Bug 3241479
       l_seg_ok := true;
	  if l_seg_ok and l_inst_set(i).segment1 is not null then
       	  if l_inst_set(i).segment1 <> nvl(l_ppl_grp_rec.segment1,l_const)  then
             l_seg_ok := false ;
          else
             l_seg_ok := true;
          end if;
       end if ;

       if  l_seg_ok and l_inst_set(i).segment2 is not null then
          if l_inst_set(i).segment2 <> nvl(l_ppl_grp_rec.segment2,l_const) then
	       l_seg_ok := false ;
	  else
	       l_seg_ok := true;
          end if;
       end if ;


       if  l_seg_ok and l_inst_set(i).segment3 is not null then
	  if l_inst_set(i).segment3 <> nvl(l_ppl_grp_rec.segment3,l_const) then
             l_seg_ok := false ;
          else
             l_seg_ok := true;
          end if;
       end if ;


       if  l_seg_ok and l_inst_set(i).segment4 is not null then
       	  if l_inst_set(i).segment4 <> nvl(l_ppl_grp_rec.segment4,l_const) then
             l_seg_ok := false ;
          else
             l_seg_ok := true;
          end if;
       end if ;

       if  l_seg_ok and l_inst_set(i).segment5 is not null then
          if l_inst_set(i).segment5 <> nvl(l_ppl_grp_rec.segment5,l_const) then
	       l_seg_ok := false ;
	  else
	       l_seg_ok := true;
          end if;
       end if ;


       if  l_seg_ok and l_inst_set(i).segment6 is not null then
	  if l_inst_set(i).segment6 <> nvl(l_ppl_grp_rec.segment6,l_const) then
             l_seg_ok := false ;
          else
             l_seg_ok := true;
          end if;
       end if ;

       if  l_seg_ok and l_inst_set(i).segment7 is not null then
       	  if l_inst_set(i).segment7 <> nvl(l_ppl_grp_rec.segment7,l_const) then
             l_seg_ok := false ;
          else
             l_seg_ok := true;
          end if;
       end if ;

       if  l_seg_ok and l_inst_set(i).segment8 is not null then
          if l_inst_set(i).segment8 <> nvl(l_ppl_grp_rec.segment8,l_const) then
	       l_seg_ok := false ;
	  else
	       l_seg_ok := true;
          end if;
       end if ;


       if  l_seg_ok and l_inst_set(i).segment9 is not null then
	  if l_inst_set(i).segment9 <> nvl(l_ppl_grp_rec.segment9,l_const) then
             l_seg_ok := false ;
          else
             l_seg_ok := true;
          end if;
       end if ;

       if  l_seg_ok and l_inst_set(i).segment10 is not null then
	 if l_inst_set(i).segment10 <> nvl(l_ppl_grp_rec.segment10,l_const) then
	    l_seg_ok := false ;
	 else
	    l_seg_ok := true;
	 end if;
       end if ;

       if  l_seg_ok and l_inst_set(i).segment11 is not null then
           if l_inst_set(i).segment11 <> nvl(l_ppl_grp_rec.segment11,l_const) then
       	       l_seg_ok := false ;
       	   else
       	       l_seg_ok := true;
           end if;
       end if ;


       if  l_seg_ok and l_inst_set(i).segment12 is not null then
       	  if l_inst_set(i).segment12 <> nvl(l_ppl_grp_rec.segment12,l_const) then
               l_seg_ok := false ;
          else
               l_seg_ok := true;
          end if;
       end if ;


       if  l_seg_ok and l_inst_set(i).segment13 is not null then
       	  if l_inst_set(i).segment13 <> nvl(l_ppl_grp_rec.segment13,l_const) then
             l_seg_ok := false ;
          else
             l_seg_ok := true;
          end if;
       end if ;

       if  l_seg_ok and l_inst_set(i).segment14 is not null then
          if l_inst_set(i).segment14 <> nvl(l_ppl_grp_rec.segment14,l_const) then
	       l_seg_ok := false ;
	  else
	       l_seg_ok := true;
          end if;
       end if ;


       if  l_seg_ok and l_inst_set(i).segment15 is not null then
	  if l_inst_set(i).segment15 <> nvl(l_ppl_grp_rec.segment15,l_const) then
             l_seg_ok := false ;
          else
             l_seg_ok := true;
          end if;
       end if ;


       if  l_seg_ok and l_inst_set(i).segment16 is not null then
       	  if l_inst_set(i).segment16 <> nvl(l_ppl_grp_rec.segment16,l_const) then
             l_seg_ok := false ;
          else
             l_seg_ok := true;
          end if;
       end if ;

       if  l_seg_ok and l_inst_set(i).segment17 is not null then
          if l_inst_set(i).segment17 <> nvl(l_ppl_grp_rec.segment17,l_const) then
	       l_seg_ok := false ;
	  else
	       l_seg_ok := true;
          end if;
       end if ;


       if l_seg_ok and l_inst_set(i).segment18 is not null then
	  if l_inst_set(i).segment18 <> nvl(l_ppl_grp_rec.segment18,l_const) then
             l_seg_ok := false ;
          else
             l_seg_ok := true;
          end if;
       end if ;

       if l_seg_ok and  l_inst_set(i).segment19 is not null then
       	  if l_inst_set(i).segment19 <> nvl(l_ppl_grp_rec.segment19,l_const) then
             l_seg_ok := false ;
          else
             l_seg_ok := true;
          end if;
       end if ;

       if l_seg_ok and  l_inst_set(i).segment20 is not null then
          if l_inst_set(i).segment20 <> nvl(l_ppl_grp_rec.segment20,l_const) then
	       l_seg_ok := false ;
	  else
	       l_seg_ok := true;
          end if;
       end if ;


       if l_seg_ok and  l_inst_set(i).segment21 is not null then
	  if l_inst_set(i).segment21 <> nvl(l_ppl_grp_rec.segment21,l_const) then
             l_seg_ok := false ;
          else
             l_seg_ok := true;
          end if;
       end if ;

       if l_seg_ok and l_inst_set(i).segment22 is not null then
	 if l_inst_set(i).segment22 <> nvl(l_ppl_grp_rec.segment22,l_const) then
	    l_seg_ok := false ;
	 else
	    l_seg_ok := true;
	 end if;
       end if ;

       if l_seg_ok and l_inst_set(i).segment23 is not null then
           if l_inst_set(i).segment23 <> nvl(l_ppl_grp_rec.segment23,l_const) then
       	       l_seg_ok := false ;
       	   else
       	       l_seg_ok := true;
           end if;
       end if ;


       if l_seg_ok and l_inst_set(i).segment24 is not null then
       	  if l_inst_set(i).segment24 <> nvl(l_ppl_grp_rec.segment24,l_const) then
               l_seg_ok := false ;
          else
               l_seg_ok := true;
          end if;
       end if ;


       if l_seg_ok and l_inst_set(i).segment25 is not null then
	  if l_inst_set(i).segment25 <> nvl(l_ppl_grp_rec.segment25,l_const) then
             l_seg_ok := false ;
          else
             l_seg_ok := true;
          end if;
       end if ;

       if l_seg_ok and l_inst_set(i).segment26 is not null then
       	  if l_inst_set(i).segment26 <> nvl(l_ppl_grp_rec.segment26,l_const) then
             l_seg_ok := false ;
          else
             l_seg_ok := true;
          end if;
       end if ;

       if l_seg_ok and l_inst_set(i).segment27 is not null then
          if l_inst_set(i).segment27 <> nvl(l_ppl_grp_rec.segment27,l_const) then
	       l_seg_ok := false ;
	  else
	       l_seg_ok := true;
          end if;
       end if ;


       if l_seg_ok and l_inst_set(i).segment28 is not null then
	  if l_inst_set(i).segment28 <> nvl(l_ppl_grp_rec.segment28,l_const) then
             l_seg_ok := false ;
          else
             l_seg_ok := true;
          end if;
       end if ;

       if l_seg_ok and l_inst_set(i).segment29 is not null then
	 if l_inst_set(i).segment29 <> nvl(l_ppl_grp_rec.segment29,l_const) then
	    l_seg_ok := false ;
	 else
	    l_seg_ok := true;
	 end if;
       end if ;

       if l_seg_ok and l_inst_set(i).segment30 is not null then
           if l_inst_set(i).segment30 <> nvl(l_ppl_grp_rec.segment30,l_const) then
       	       l_seg_ok := false ;
       	   else
       	       l_seg_ok := true;
           end if;
       end if ;

       -- End of bug 3241479

       if l_inst_set(i).excld_flag = 'Y' and l_seg_ok and not l_ok then
       	   l_ok := false ;
       	   l_seg_ok := false;
           exit;
       elsif l_inst_set(i).excld_flag = 'Y' and l_seg_ok and l_ok then
       	   l_ok := false ;
       	   l_seg_ok := false;
           exit;
       elsif l_seg_ok and l_inst_set(i).excld_flag = 'N' then
       	   exit;
       end if;
       --

    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok and not l_seg_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
end check_people_group;
--
-- ---------------------------------------------------------------
--    Formula
-- ---------------------------------------------------------------
--
procedure check_rules
  (p_vrbl_rt_prfl_id      in number
  ,p_business_group_id    in number
  ,p_effective_date       in date
  ,p_lf_evt_ocrd_dt       in date
  ,p_assignment_id        in number
  ,p_organization_id      in number
  ,p_pgm_id               in number
  ,p_pl_id                in number
  ,p_pl_typ_id            in number
  ,p_opt_id               in number
  ,p_ler_id               in number
  ,p_acty_base_rt_id      in number default null
  ,p_elig_per_elctbl_chc_id      in number default null
  ,p_jurisdiction_code    in varchar2)
is
  --
  l_outputs           ff_exec.outputs_t;
  l_inst_set ben_rt_prfl_cache.g_rl_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  l_ben_vapro_rul_cond varchar2(30) := 'A' ;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
     --- get the  profile setup it can be either AND or OR # 2508757
     l_ben_vapro_rul_cond :=     fnd_profile.value('BEN_VAPRO_RL_COND');

     hr_utility.set_location(' l_ben_vapro_rul_cond ' || l_ben_vapro_rul_cond, 757 );
    --
    for i in l_inst_set.first..l_inst_set.last loop
       --
        hr_utility.set_location(' p_vrbl_rt_prfl_id ' || p_vrbl_rt_prfl_id, 757 );
       l_outputs := benutils.formula
                     (p_formula_id        => l_inst_set(i).formula_id
                     ,p_effective_date    => nvl(p_lf_evt_ocrd_dt
                                                ,p_effective_date)
                     ,p_business_group_id => p_business_group_id
                     ,p_assignment_id     => p_assignment_id
                     ,p_organization_id   => p_organization_id
                     ,p_pgm_id            => p_pgm_id
                     ,p_pl_id             => p_pl_id
                     ,p_pl_typ_id         => p_pl_typ_id
                     ,p_opt_id            => p_opt_id
                     ,p_ler_id            => p_ler_id
                     ,p_acty_base_rt_id   => p_acty_base_rt_id
                     ,p_elig_per_elctbl_chc_id   => p_elig_per_elctbl_chc_id
                     ,p_jurisdiction_code => p_jurisdiction_code
                     ,p_param1             => 'BEN_VPF_I_VRBL_RT_PRFL_ID'
                     ,p_param1_value       => to_char(nvl(p_vrbl_rt_prfl_id, -1))
                     -- FONM
                     ,p_param2             => 'BEN_IV_RT_STRT_DT'
                     ,p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt)
                     ,p_param3             => 'BEN_IV_CVG_STRT_DT'
                     ,p_param3_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt)
                     );
       -- if the profile is AND and one of the rule fails  #2508757
       if nvl(l_ben_vapro_rul_cond,'A')  = 'A' then

          hr_utility.set_location(' result  ' || l_outputs(l_outputs.first).value, 758 );
          if l_outputs(l_outputs.first).value <> 'Y' then
             raise g_criteria_failed;
          End if ;
       Else
          -- if the profile is OR and  one of the rule pass then exit
          hr_utility.set_location(' result  ' || l_outputs(l_outputs.first).value, 759 );
         if l_outputs(l_outputs.first).value = 'Y' then
            --
            exit;
            --
         end if;
       End if ;
      --
    end loop;
    -- if the profile is OR and  exit with value 'N' raise the error
    if  nvl(l_ben_vapro_rul_cond,'A')  = 'O' and l_outputs(l_outputs.first).value <> 'Y' then
        hr_utility.set_location(' error on OR and N ', 757 );
        raise g_criteria_failed;
    end if ;
    --
  end if;
  --
end check_rules;
--
-- ---------------------------------------------------------------
--    Tobacco check
-- ---------------------------------------------------------------
--
procedure check_tobacco
  (p_vrbl_rt_prfl_id      in number
  ,p_business_group_id    in number
  ,p_effective_date       in date
  ,p_lf_evt_ocrd_dt       in date
  ,p_tobacco              in varchar2) is
  --
  l_inst_set ben_rt_prfl_cache.g_tbco_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_ok := l_inst_set(i).uses_tbco_flag = nvl(p_tobacco,'-1');
      --
      --Removing the code for the bug : 6525934.
     /* if l_ok is null or p_tobacco is null then
      --
        l_ok := false;
      --
      end if; */
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_ok := true ;
        --exit ;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise ben_evaluate_rate_profiles.g_profile_failed;
        l_ok := false;
        exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise ben_evaluate_rate_profiles.g_profile_failed;
    --
  end if;
  --
end check_tobacco;
--
-- ---------------------------------------------------------------
--    Gender check
-- ---------------------------------------------------------------
--
procedure check_gender
  (p_vrbl_rt_prfl_id      in number
  ,p_business_group_id    in number
  ,p_effective_date       in date
  ,p_lf_evt_ocrd_dt       in date
  ,p_sex                  in varchar2) is
  --
  l_inst_set ben_rt_prfl_cache.g_gndr_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      hr_utility.set_location(' l_inst_set(i).gndr_cd '||l_inst_set(i).gndr_cd , 12);
      hr_utility.set_location('  l_inst_set(i).excld_flag '|| l_inst_set(i).excld_flag ,12);
      --
      l_ok := l_inst_set(i).gndr_cd = p_sex;
      --
      if l_ok is null or p_sex is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise ben_evaluate_rate_profiles.g_profile_failed;
        l_ok := false ;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_ok := true ;
        --exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise ben_evaluate_rate_profiles.g_profile_failed;
    --
  end if;
  --
end check_gender;
--
-- ---------------------------------------------------------------
--    Disabled Code check
-- ---------------------------------------------------------------
--

procedure check_dsbld_cd
  (p_vrbl_rt_prfl_id      in number
  ,p_business_group_id    in number
  ,p_effective_date       in date
  ,p_lf_evt_ocrd_dt       in date
  ,p_dsbld_cd             in varchar2) is
  --
  l_inst_set ben_rt_prfl_cache.g_dsbld_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_ok := l_inst_set(i).dsbld_cd = p_dsbld_cd;
      --
      if l_ok is null or p_dsbld_cd is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise ben_evaluate_rate_profiles.g_profile_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_rows_found := true;
        l_ok := true ;
        --exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise ben_evaluate_rate_profiles.g_profile_failed;
    --
  end if;
  --
end check_dsbld_cd;
--
-- ---------------------------------------------------------------
--    Bargaining Unit check
-- ---------------------------------------------------------------
--
procedure check_brgng_unit
  (p_vrbl_rt_prfl_id       in number
  ,p_business_group_id     in number
  ,p_effective_date        in date
  ,p_lf_evt_ocrd_dt        in date
  ,p_bargaining_unit_code  in varchar2) is
  --
  l_inst_set ben_rt_prfl_cache.g_brgng_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
        l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_ok := l_inst_set(i).brgng_unit_cd = p_bargaining_unit_code;
      --
      if l_ok is null or p_bargaining_unit_code is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise g_criteria_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_ok := true ;
        -- exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
end check_brgng_unit;
--
-- ---------------------------------------------------------------
--  Benefits group check.
-- ---------------------------------------------------------------
--
procedure check_benefits_grp
  (p_vrbl_rt_prfl_id   in number
  ,p_person_id         in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_benefit_group_id  in number) is
  --
  l_inst_set ben_rt_prfl_cache.g_bnfgrp_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_ok := l_inst_set(i).benfts_grp_id = p_benefit_group_id;
      --
      if l_ok is null or p_benefit_group_id is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise ben_evaluate_rate_profiles.g_profile_failed;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_rows_found := true;
        l_ok := true ;
        -- exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise ben_evaluate_rate_profiles.g_profile_failed;
    --
  end if;
  --
end check_benefits_grp;
--
-- --------------------------------------------------
--  Employee status check.
-- --------------------------------------------------
--
procedure check_ee_stat
  (p_vrbl_rt_prfl_id           in number
  ,p_person_id                 in number
  ,p_business_group_id         in number
  ,p_effective_date            in date
  ,p_lf_evt_ocrd_dt            in date
  ,p_assignment_status_type_id in number) is
  --
  l_inst_set ben_rt_prfl_cache.g_eestat_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_ok := l_inst_set(i).assignment_status_type_id = p_assignment_status_type_id;
      --
      if l_ok is null or p_assignment_status_type_id is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise g_criteria_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_rows_found := true;
        l_ok := true ;
        --exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
end check_ee_stat;
--
-- ---------------------------------------------------------------
--  Full time/part time check.
-- ---------------------------------------------------------------
--
procedure check_fl_tm_pt
  (p_vrbl_rt_prfl_id     in number
  ,p_person_id           in number
  ,p_business_group_id   in number
  ,p_effective_date      in date
  ,p_lf_evt_ocrd_dt      in date
  ,p_employment_category in varchar2) is
  --
  l_inst_set ben_rt_prfl_cache.g_ftpt_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_ok := l_inst_set(i).fl_tm_pt_tm_cd = p_employment_category;
      --
      if l_ok is null or p_employment_category is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise g_criteria_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_rows_found := true;
        l_ok := true ;
        -- exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
end check_fl_tm_pt;
--
-- ------------------------------------------------------
--  Grade check
-- ------------------------------------------------------
--
procedure check_grade
  (p_vrbl_rt_prfl_id   in number
  ,p_person_id         in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_grade_id          in number) is
  --
  l_inst_set ben_rt_prfl_cache.g_grd_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_ok := l_inst_set(i).grade_id = p_grade_id;
      --
      if l_ok is null or p_grade_id is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise g_criteria_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_ok := true ;
        --exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
end check_grade;
--
-- -----------------------------------------------------------------
--  Percent fulltime check.
-- -----------------------------------------------------------------
--
procedure check_pct_fltm
  (p_vrbl_rt_prfl_id         in number
  ,p_person_id               in number
  ,p_business_group_id       in number
  ,p_effective_date          in date
  ,p_lf_evt_ocrd_dt          in date
  ,p_opt_id                  in number default null
  ,p_plip_id                 in number default null
  ,p_pl_id                   in number default null
  ,p_pgm_id                  in number default null) is
  --
  l_ok                 boolean := false;
  l_opt_id             number(15);
  l_rt_pct_fl_tm_val   ben_elig_per_f.rt_pct_fl_tm_val%type := null;

  cursor c_pct_ft is
    select bep.rt_pct_fl_tm_val
    from   ben_elig_per_f bep,
           ben_per_in_ler pil
    where  bep.person_id = p_person_id
    and nvl(bep.pgm_id,-1) = nvl(p_pgm_id,-1)
    and nvl(bep.pl_id,-1) = nvl(p_pl_id,-1)
    and    p_effective_date
           between bep.effective_start_date
           and     bep.effective_end_date
    and pil.per_in_ler_id(+)=bep.per_in_ler_id
    and pil.business_group_id(+)=bep.business_group_id+0
    and (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
     or pil.per_in_ler_stat_cd is null                  -- outer join condition
    );

  cursor c_pct_ft_opt  is
  select epo.rt_pct_fl_tm_val
    from ben_elig_per_f bep, ben_elig_per_opt_f epo,
         ben_per_in_ler pil
   where bep.person_id = p_person_id
     and bep.elig_per_id = epo.elig_per_id
     and epo.opt_id = p_opt_id
     and nvl(bep.pgm_id,-1) = nvl(p_pgm_id,-1)
     and nvl(bep.pl_id,-1) = nvl(p_pl_id,-1)
     and p_effective_date between epo.effective_start_date
                              and epo.effective_end_date
     and p_effective_date between bep.effective_start_date
                              and bep.effective_end_date
     and pil.per_in_ler_id(+)=bep.per_in_ler_id
     and pil.business_group_id(+)=bep.business_group_id
     and (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
      or  pil.per_in_ler_stat_cd is null);                -- outer join condition

  cursor c_pct_ft_plip  is
  select epo.rt_pct_fl_tm_val
    from ben_elig_per_f bep, ben_elig_per_opt_f epo,
         ben_per_in_ler pil
   where bep.person_id = p_person_id
     and bep.elig_per_id = epo.elig_per_id
     and epo.opt_id = p_opt_id
     and nvl(bep.pgm_id,-1) = nvl(p_pgm_id,-1)
     and nvl(bep.plip_id,-1) = nvl(p_plip_id,-1)
     and p_effective_date between epo.effective_start_date
                              and epo.effective_end_date
     and p_effective_date between bep.effective_start_date
                              and bep.effective_end_date
     and pil.per_in_ler_id(+)=bep.per_in_ler_id
     and pil.business_group_id(+)=bep.business_group_id
     and (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
      or  pil.per_in_ler_stat_cd is null);                -- outer join condition

  l_inst_set ben_rt_prfl_cache.g_pctft_inst_tbl;
  l_inst_count number;
  l_rows_found boolean := false;
  l_mx_pct_val    number ;
  --
begin
  hr_utility.set_location ('Entering check_pct_fltm',01);
  hr_utility.set_location ('opt' || p_opt_id  ,01);
  hr_utility.set_location ('plip'|| p_plip_id  ,01);
  hr_utility.set_location ('pl'  || p_pl_id   ,01);
  hr_utility.set_location ('pgm' || p_pgm_id ,01);
  --

  if p_opt_id is not null then
    -- Look for oiplip first.  oiplip elig_per_opt rows hang off plip elig_per
    -- records.
    if p_plip_id is not null then
      open c_pct_ft_plip;
      fetch c_pct_ft_plip into l_rt_pct_fl_tm_val;
      hr_utility.set_location ('oiplip '||to_char(l_rt_pct_fl_tm_val),01);
      close c_pct_ft_plip;
    end if;

    -- If there is no oiplip, check for oipl
    if l_rt_pct_fl_tm_val is null then
      open c_pct_ft_opt;
      fetch c_pct_ft_opt into l_rt_pct_fl_tm_val;
      hr_utility.set_location ('oipl '||to_char(l_rt_pct_fl_tm_val),01);
      close c_pct_ft_opt;
    end if;
  else
     -- just look for pl elig per record.
     open c_pct_ft;
     fetch c_pct_ft into l_rt_pct_fl_tm_val;
     hr_utility.set_location ('pl '||to_char(l_rt_pct_fl_tm_val),01);
     close c_pct_ft;
  end if;

  -- Get the rate profile data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      --
      --- if there is fraction compare in differtn way
      -- Bug 2101937 fixes
      l_mx_pct_val := l_inst_set(i).mx_pct_val ;
      --
      if ( l_inst_set(i).mx_pct_val <> trunc(l_inst_set(i).mx_pct_val)  OR
           l_inst_set(i).mn_pct_val <> trunc(l_inst_set(i).mn_pct_val) ) then
        -- Decimal Case
        l_mx_pct_val := l_inst_set(i).mx_pct_val + 0.000000001 ;
        --
      else
        --
        l_mx_pct_val := l_inst_set(i).mx_pct_val + 1 ;
        --
      end if;
      --
      hr_utility.set_location('if' , 610) ;
      --
      l_ok := ((l_rt_pct_fl_tm_val >=
                 l_inst_set(i).mn_pct_val
                 and  l_rt_pct_fl_tm_val < l_mx_pct_val )
               or
               (l_inst_set(i).no_mn_pct_val_flag = 'Y' and
                l_rt_pct_fl_tm_val < l_mx_pct_val )
               or
               (l_rt_pct_fl_tm_val >= l_inst_set(i).mn_pct_val and
                l_inst_set(i).no_mx_pct_val_flag = 'Y'));

      if l_ok Then
         hr_utility.set_location('success ' ,610);
      end if ;
      --
      if l_ok is null or l_rt_pct_fl_tm_val is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise ben_evaluate_rate_profiles.g_profile_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_ok := true ;
        --exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise ben_evaluate_rate_profiles.g_profile_failed;
    --
  end if;
  --
end check_pct_fltm;
--
-- ------------------------------
-- Assignment set
-- ------------------------------
--

procedure check_asnt_set
        (p_VRBL_RT_PRFL_ID   in number,
         p_business_group_id in number,
         p_person_id         in number,
         p_lf_evt_ocrd_dt    in date,
         p_effective_date    in date) is
  --
  l_proc          varchar2(100):=g_package||'check_asnt_set';
  l_inst_dets     ben_rt_asnt_cache.g_rt_asnt_inst_tbl;
  l_inst_count    number;
  l_insttorrw_num binary_integer;
  l_ok            boolean := false;
  l_rows_found    boolean := false;
  l_ass_rec       per_all_assignments_f%rowtype;
  l_outputs       ff_exec.outputs_t;
  l_include_flag  varchar2(80);
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting eligibility profile compensation level by eligibility profile
  --
  ben_rt_asnt_cache.get_rt_asnt_cache
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_VRBL_RT_PRFL_ID   => p_VRBL_RT_PRFL_ID
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_inst_set          => l_inst_dets
    ,p_inst_count        => l_inst_count);
  --
   hr_utility.set_location('Int COunt'||l_inst_count,11);
  if l_inst_count > 0 then
    --
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_ass_rec);
    --
    for l_count in l_inst_dets.first .. l_inst_dets.last loop
      --
      -- Error if someone hasn't built the formula as this will
      -- cause an error. In this case kill the run.
      --
      hr_utility.set_location('COunt'||l_count,11);
      if l_inst_dets(l_count).formula_id is null then
        --
        fnd_message.set_name('BEN','BEN_92460_ASS_SET_FORMULA');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('VARIABLE_RT_PRFL_ID',to_char(p_VRBL_RT_PRFL_ID));
        fnd_message.raise_error;
        --
      end if;
      --
      hr_utility.set_location('Bef Formula',11);
      l_outputs := benutils.formula
                      (p_formula_id     => l_inst_dets(l_count).formula_id,
                       p_assignment_id  => l_ass_rec.assignment_id,
                       p_effective_date => nvl(p_lf_evt_ocrd_dt, p_effective_date), -- FONM
                       p_param1             => 'BEN_IV_RT_STRT_DT',
                       p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
                       p_param2             => 'BEN_IV_CVG_STRT_DT',
                       p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt));
      --
      begin
        --
        if l_outputs(l_outputs.first).name = 'INCLUDE_FLAG' then
          --
          hr_utility.set_location('Incl Flag ',11);
          l_include_flag := l_outputs(l_outputs.first).value;
          --
        else
          --
          -- Account for cases where formula returns an unknown
          -- variable name
          --
          fnd_message.set_name('BEN','BEN_92310_FORMULA_RET_PARAM_');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('FORMULA',l_inst_dets(l_count).formula_id);
          fnd_message.set_token('PARAMETER',l_outputs(l_outputs.first).name);
          fnd_message.raise_error;
          --
        end if;
        --
        -- Code for type casting errors from formula return variables
        --
      exception
        --
        when others then
          --
          fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('FORMULA',l_inst_dets(l_count).formula_id);
          fnd_message.set_token('PARAMETER',l_outputs(l_outputs.first).name);
          fnd_message.raise_error;
          --
      end;
      --
      hr_utility.set_location('Include Flag '||l_include_flag,10);
      --
      l_ok := nvl((l_include_flag = 'Y'),FALSE);
      --if l_ok is null then
      --  l_ok:=false;
      --end if;
      --
      if l_ok and l_inst_dets(l_count).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_dets(l_count).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_dets(l_count).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := true;
        -- exit;
        --
      elsif l_inst_dets(l_count).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    fnd_message.set_name('BEN','BEN_92459_ASS_SET_PRFL_FAIL');
    hr_utility.set_location('Criteria Failed: '||l_proc,20);
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_asnt_set;
-- --------------------------------------------------------------------
--  Hours worked in a period check.
-- --------------------------------------------------------------------
--
procedure check_hrs_wkd
  (p_vrbl_rt_prfl_id        in number
  ,p_person_id              in number
  ,p_business_group_id      in number
  ,p_effective_date         in date
  ,p_lf_evt_ocrd_dt         in date
  ,p_opt_id                 in number default null
  ,p_plip_id                in number default null
  ,p_pl_id                  in number default null
  ,p_pgm_id                 in number default null) is
  --
  l_ok                 boolean := false;
  l_opt_id             number(15);
  l_rt_hrs_wkd_val     ben_elig_per_f.rt_hrs_wkd_val%type;


  cursor c_hrs_wkd  is
  select bep.rt_hrs_wkd_val
    from ben_elig_per_f bep,
         ben_per_in_ler pil
   where bep.person_id = p_person_id
     and nvl(bep.pgm_id,-1) = nvl(p_pgm_id,-1)
     and nvl(bep.pl_id,-1) = nvl(p_pl_id,-1)
     and p_effective_date between bep.effective_start_date
                              and bep.effective_end_date
     and pil.per_in_ler_id(+)=bep.per_in_ler_id
     and pil.business_group_id(+)=bep.business_group_id
     and (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
      or  pil.per_in_ler_stat_cd is null);                -- outer join condition

  cursor c_hrs_wkd_opt  is
  select epo.rt_hrs_wkd_val
    from ben_elig_per_f bep, ben_elig_per_opt_f epo,
         ben_per_in_ler pil
   where bep.person_id = p_person_id
     and bep.elig_per_id = epo.elig_per_id
     and epo.opt_id = p_opt_id
     and nvl(bep.pgm_id,-1) = nvl(p_pgm_id,-1)
     and nvl(bep.pl_id,-1) = nvl(p_pl_id,-1)
     and p_effective_date between epo.effective_start_date
                              and epo.effective_end_date
     and p_effective_date between bep.effective_start_date
                              and bep.effective_end_date
     and pil.per_in_ler_id(+)=bep.per_in_ler_id
     and pil.business_group_id(+)=bep.business_group_id
     and (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
      or  pil.per_in_ler_stat_cd is null);                -- outer join condition

  cursor c_hrs_wkd_plip  is
  select epo.rt_hrs_wkd_val
    from ben_elig_per_f bep, ben_elig_per_opt_f epo,
         ben_per_in_ler pil
   where bep.person_id = p_person_id
     and bep.elig_per_id = epo.elig_per_id
     and epo.opt_id = p_opt_id
     and nvl(bep.pgm_id,-1) = nvl(p_pgm_id,-1)
     and nvl(bep.plip_id,-1) = nvl(p_plip_id,-1)
     and p_effective_date between epo.effective_start_date
                              and epo.effective_end_date
     and p_effective_date between bep.effective_start_date
                              and bep.effective_end_date
     and pil.per_in_ler_id(+)=bep.per_in_ler_id
     and pil.business_group_id(+)=bep.business_group_id
     and (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
      or  pil.per_in_ler_stat_cd is null);                -- outer join condition

  l_inst_set ben_rt_prfl_cache.g_hrswkd_inst_tbl;
  l_inst_count number;
  l_rows_found boolean := false;
  l_mx_hrs_num number ;

begin
  hr_utility.set_location ('Entering check_hrs_wkd',01);
  if p_opt_id is not null then
    -- Look for oiplip first.  oiplip elig_per_opt rows hang off plip elig_per
    -- records.
    if p_plip_id is not null then
      open c_hrs_wkd_plip;
      fetch c_hrs_wkd_plip into l_rt_hrs_wkd_val;
      hr_utility.set_location ('oiplip '||to_char(l_rt_hrs_wkd_val),01);
      close c_hrs_wkd_plip;
    end if;

    -- If there is no oiplip, check for oipl
    if l_rt_hrs_wkd_val is null then
      open c_hrs_wkd_opt;
      fetch c_hrs_wkd_opt into l_rt_hrs_wkd_val;
      hr_utility.set_location ('oipl '||to_char(l_rt_hrs_wkd_val),01);
      close c_hrs_wkd_opt;
    end if;
  else
     -- just look for pl elig per record.
     open c_hrs_wkd;
     fetch c_hrs_wkd into l_rt_hrs_wkd_val;
      hr_utility.set_location ('pl '||to_char(l_rt_hrs_wkd_val),01);
     close c_hrs_wkd;
  end if;


  --
  -- Get the rate profile data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);

  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      hr_utility.set_location ('hrx criteria'||l_rt_hrs_wkd_val  || ' min:'||
      to_char(l_inst_set(i).mn_hrs_num)||' mx:'||to_char(l_inst_set(i).mx_hrs_num),610.2);
      --
      -- Bug 2101937 fixes
      l_mx_hrs_num := l_inst_set(i).mx_hrs_num ;
      --
      if ( l_inst_set(i).mx_hrs_num <> trunc(l_inst_set(i).mx_hrs_num)  OR
           l_inst_set(i).mn_hrs_num <> trunc(l_inst_set(i).mn_hrs_num) ) then
        -- Decimal Case
        l_mx_hrs_num := l_inst_set(i).mx_hrs_num + 0.000000001 ;
        --
      else
        --
        l_mx_hrs_num := l_inst_set(i).mx_hrs_num + 1 ;
        --
      end if;
      --

      l_ok := ((l_rt_hrs_wkd_val >=  l_inst_set(i).mn_hrs_num
                and l_rt_hrs_wkd_val <  l_mx_hrs_num )
                or
               (l_inst_set(i).no_mn_hrs_wkd_flag = 'Y' and
                l_rt_hrs_wkd_val <  l_mx_hrs_num )
                or
               (l_rt_hrs_wkd_val >= l_inst_set(i).mn_hrs_num and
                l_inst_set(i).no_mx_hrs_wkd_flag = 'Y'));
      --
      if l_ok is null or l_rt_hrs_wkd_val is null then
        l_ok := false;
      end if;

      if l_ok and l_inst_set(i).excld_flag = 'N' then
        exit;
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise ben_evaluate_rate_profiles.g_profile_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_ok := true ;
        --exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        l_rows_found := true;
      end if;

    end loop;

  end if;

  if l_rows_found and not l_ok then
    raise ben_evaluate_rate_profiles.g_profile_failed;
  end if;

end check_hrs_wkd;
--
-- ----------------------------------------------------------
--  Labor union membership check.
-- ----------------------------------------------------------
procedure check_lbr_union
  (p_vrbl_rt_prfl_id          in number
  ,p_person_id                in number
  ,p_business_group_id        in number
  ,p_effective_date           in date
  ,p_lf_evt_ocrd_dt           in date
  ,p_labour_union_member_flag in varchar2) is
  --
  l_inst_set ben_rt_prfl_cache.g_lbrmmbr_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_ok := l_inst_set(i).lbr_mmbr_flag = p_labour_union_member_flag;
      --
      if l_ok is null or p_labour_union_member_flag is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise g_criteria_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_ok := true ;
        --exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
end check_lbr_union;
--
-- -----------------------------------------------
--  Legal entity check.
-- -----------------------------------------------
--
procedure check_lgl_enty
  (p_vrbl_rt_prfl_id   in number
  ,p_person_id         in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_gre_id            in varchar2) is
  --
  l_inst_set ben_rt_prfl_cache.g_lglenty_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_ok := l_inst_set(i).organization_id = p_gre_id;
      --
      if l_ok is null or p_gre_id is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise g_criteria_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_ok := true ;
        -- exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
end check_lgl_enty;
--
-- ---------------------------------------------------
--  Leave of absence check.
-- ---------------------------------------------------
--
procedure check_loa_rsn
  (p_vrbl_rt_prfl_id   in number
  ,p_person_id         in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date) is
  --
  l_inst_set       ben_rt_prfl_cache.g_loa_inst_tbl;
  l_inst_count     number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  l_effective_date date;
  l_dummy          varchar2(1);
  --
  -- FONM : No need to modify
  --
  cursor c_get_absence_type(p_absence_attendance_type_id in number,
                            p_abs_attendance_reason_id   in number) is
    select null
    from   per_absence_attendances abs
    where  abs.person_id = p_person_id
    and    abs.absence_attendance_type_id = p_absence_attendance_type_id
    and    nvl(abs.abs_attendance_reason_id,-1) =
           nvl(p_abs_attendance_reason_id,nvl(abs.abs_attendance_reason_id,-1))
    and    l_effective_date
           between nvl(abs.date_start,l_effective_date) and
                   nvl(abs.date_end,l_effective_date)
    and    abs.business_group_id  = p_business_group_id;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- FONM
    if ben_manage_life_events.fonm = 'Y' then
       --
       l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                               nvl(p_lf_evt_ocrd_dt, p_effective_date)));
    else
       --
       l_effective_date := nvl(p_lf_evt_ocrd_dt, p_effective_date);
       --
    end if;
    --
    l_rows_found:=true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      open c_get_absence_type(l_inst_set(i).absence_attendance_type_id,
                              l_inst_set(i).abs_attendance_reason_id);
        --
        fetch c_get_absence_type into l_dummy;
        --
        if c_get_absence_type%found then
          --
          hr_utility.set_location ('c_get_absence_type found',88);
          --
          if l_inst_set(i).excld_flag = 'N' then
            --
            l_ok:=true;
            exit;
            --
          elsif l_inst_set(i).excld_flag = 'Y' then
            --
            close c_get_absence_type;
            -- raise g_criteria_failed;
            l_ok:= false ;
            exit ;
            --
          end if;
          --
        else
          --
          hr_utility.set_location ('c_get_absence_type not found',88);
          --
          if l_inst_set(i).excld_flag = 'N' then
            --
            l_rows_found:=true;
            --
          elsif l_inst_set(i).excld_flag = 'Y' then
            -- Bug 2100564
            l_ok := true ;
            -- exit ;
            --
          end if;
          --
        end if;
        --
      close c_get_absence_type;
      --
    end loop;
    --
    if l_rows_found and not l_ok then
      --
      raise g_criteria_failed;
      --
    end if;
    --
  end if;
  --
end check_loa_rsn;
--
-- ---------------------------------------------------------
--  Organization unit check.
-- ---------------------------------------------------------
--
procedure check_org_unit
  (p_vrbl_rt_prfl_id   in number
  ,p_person_id         in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_org_id            in number) is
  --
  l_inst_set ben_rt_prfl_cache.g_org_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_ok := l_inst_set(i).organization_id = p_org_id;
      --
      if l_ok is null or p_org_id is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise g_criteria_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_ok := true ;
        -- exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
end check_org_unit;
--
-- -----------------------------------------------------------
-- Person type check.
-- -----------------------------------------------------------
--
procedure check_per_typ
  (p_vrbl_rt_prfl_id   in number
  ,p_person_id         in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_person_type       in ben_person_object.
                          g_cache_typ_table) is
  --
  l_inst_set ben_rt_prfl_cache.g_pertyp_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
  -- Get the data from the cache.
  --
  hr_utility.set_location('p_vrbl_rt_prfl_id -> '||p_vrbl_rt_prfl_id,11);

  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    <<outer>>
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_rows_found := true;
      --
      for l_count in p_person_type.first..p_person_type.last loop
        --
        hr_utility.set_location(l_inst_set(i).person_type_id,10);
        --
        -- To support user creatd person type use person_type_id instead of per_typ_cd
        --
        /*l_ok := l_inst_set(i).per_typ_cd =
                p_person_type(l_count).system_person_type;*/
        l_ok := l_inst_set(i).person_type_id =
                p_person_type(l_count).person_type_id;
        --
        -- To support user creatd person type use person_type_id instead of per_typ_cd
        --
        /*if l_ok is null or p_person_type(l_count).system_person_type is null then */
        if l_ok is null or p_person_type(l_count).person_type_id is null then
        --
          l_ok := false;
        --
        end if;
        --
        if l_ok and l_inst_set(i).excld_flag = 'N' then
          --
          exit outer;
          --
        elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
          --
          l_rows_found := true;
          l_ok := false;
          exit outer;
          --
        elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
          -- Bug 2100564
          l_rows_found := true;
          l_ok := true ;
          -- exit outer;
          --
        elsif l_inst_set(i).excld_flag = 'N' then
          --
          l_rows_found := true;
          --
        end if;
        --
      end loop;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise ben_evaluate_rate_profiles.g_profile_failed;
    --
  end if;
  --
end check_per_typ;
--
-- ---------------------------------------------------------------
--  Zip code range check.
-- ---------------------------------------------------------------
--
PROCEDURE check_zip_code_rng
  (p_vrbl_rt_prfl_id   IN NUMBER
  ,p_person_id         IN NUMBER
  ,p_business_group_id IN NUMBER
  ,p_effective_date    IN DATE
  ,p_lf_evt_ocrd_dt    IN DATE
  ,p_postal_code       IN VARCHAR2) IS
  --
  --
  -- FONM
  --
     CURSOR get_elig_zip(p_vrbl_rt_prfl_id IN NUMBER
                        ,cv_effective_date  IN DATE) IS
      SELECT epz.pstl_zip_rng_id,epz.excld_flag
      FROM   ben_pstl_zip_rt_f epz
      WHERE epz.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
      AND   cv_effective_date -- FONM NVL(p_lf_evt_ocrd_dt, p_effective_date)
      BETWEEN epz.effective_start_date
      AND     epz.effective_end_date;
  --
  CURSOR get_zip_ranges(p_pstl_zip_rng_id IN NUMBER
                       ,p_postal_code IN VARCHAR2
                       ,cv_effective_date in date) IS
  SELECT zip.from_value, zip.to_value
  FROM   ben_pstl_zip_rng_f zip
  WHERE zip.pstl_zip_rng_id = p_pstl_zip_rng_id
  AND   LENGTH(p_postal_code) >= LENGTH(zip.from_value)
  AND   (SUBSTR( nvl(p_postal_code,'-1'),1,LENGTH(zip.from_value))
  BETWEEN zip.from_value AND NVL(zip.to_value,p_postal_code)
  OR     NVL(p_postal_code,'-1') = zip.from_value
  OR     nvl(p_postal_code,'-1') = zip.to_value)
  AND    cv_effective_date
  BETWEEN zip.effective_start_date
  AND zip.effective_end_date;

  l_rows_found BOOLEAN := FALSE;
  l_pstl_zip_rng_id   NUMBER(15);
  l_excld_flag        VARCHAR2(1);
  l_from_value        VARCHAR2(10);
  l_to_value          VARCHAR2(10);
  --
  -- FONM
  l_fonm_cvg_strt_dt   date;
  --
BEGIN
  --
  -- Get the data from the cache.
  hr_utility.set_location('entering chck_zip_code', 10);
  --
  -- FONM
  if ben_manage_life_events.fonm = 'Y' then
     --
     l_fonm_cvg_strt_dt := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                               ben_manage_life_events.g_fonm_cvg_strt_dt);
     --
  end if;
 --
 -- FONM
 --
 OPEN get_elig_zip(p_vrbl_rt_prfl_id,nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt, p_effective_date)));
   <<range_loop>>
   LOOP
     FETCH get_elig_zip into l_pstl_zip_rng_id,l_excld_flag;
     EXIT WHEN get_elig_zip%NOTFOUND;
     l_rows_found := FALSE;
     OPEN get_zip_ranges(l_pstl_zip_rng_id,p_postal_code,
                         nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt, p_effective_date)));
       <<zip_loop>>
       LOOP
         FETCH get_zip_ranges INTO l_from_value,l_to_value;
         EXIT WHEN get_zip_ranges%NOTFOUND;
         --
         hr_utility.set_location('person zip '||p_postal_code ,2219.3);
         hr_utility.set_location('from zip '||l_from_value ,2219.3);
         hr_utility.set_location('to zip '||l_to_value ,2219.3);
         --
         l_rows_found := TRUE;
         EXIT;
         --
       END LOOP zip_loop;
       --
       IF (p_postal_code is null)
       OR (l_rows_found   AND l_excld_flag = 'N')
       THEN
         --
         close get_zip_ranges;
         l_rows_found := TRUE;
         exit;
         --
       ELSIF ( not l_rows_found  AND l_excld_flag = 'Y' ) THEN
         --
         l_rows_found := TRUE;
         --
       ELSIF ( l_rows_found AND l_excld_flag = 'Y') THEN
         --
         l_rows_found := FALSE ;
         close get_zip_ranges;
         exit;
         --
       END IF;
       --
       CLOSE get_zip_ranges;
       --
     END LOOP range_loop;
     --
     CLOSE get_elig_zip;
     --
     if not l_rows_found then
       --
       RAISE ben_evaluate_rate_profiles.g_profile_failed;
       --
     end if;
     --
     hr_utility.set_location('leaving chck_zip_code', 10);
     --
END check_zip_code_rng;
--
-- --------------------------------------------------------
--  Payroll check.
-- --------------------------------------------------------
--
procedure check_pyrl
  (p_vrbl_rt_prfl_id   in number
  ,p_person_id         in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_payroll_id        in number) is
  --
  l_inst_set ben_rt_prfl_cache.g_pyrl_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_ok := p_payroll_id = l_inst_set(i).payroll_id;
      --
      if l_ok is null or p_payroll_id is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise g_criteria_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_ok := true ;
        -- exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
end check_pyrl;
--
-- ----------------------------------------------------------
--  Pay basis check.
-- ----------------------------------------------------------
--
procedure check_py_bss
  (p_vrbl_rt_prfl_id   in number
  ,p_person_id         in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_pay_basis_id      in number) is
  --
  l_inst_set ben_rt_prfl_cache.g_py_bss_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_ok := p_pay_basis_id = l_inst_set(i).pay_basis_id;
      --
      if l_ok is null or p_pay_basis_id is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise g_criteria_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_ok := true ;
        --exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
end check_py_bss;
--
-- ---------------------------------------------------------
--  Scheduled hours check.
-- ---------------------------------------------------------
--
procedure check_sched_hrs
  (p_vrbl_rt_prfl_id   in number
  ,p_person_id         in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_normal_hrs        in number
  ,p_frequency         in varchar2
  ,p_per_in_ler_id     in number
  ,p_assignment_id     in number
  ,p_organization_id   in number
  ,p_pgm_id            in number
  ,p_pl_id             in number
  ,p_pl_typ_id         in number
  ,p_opt_id            in number
  ,p_oipl_id           in number
  ,p_ler_id            in number
  ,p_jurisdiction_code in varchar2
 ) is
  --
  l_inst_set ben_rt_prfl_cache.g_scdhrs_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;

  l_min_hours	       ben_schedd_hrs_rt_f.hrs_num%type;
  l_max_hours	       ben_schedd_hrs_rt_f.max_hrs_num%type;
  l_freq_cd	       ben_schedd_hrs_rt_f.freq_cd%type;
  l_person_freq_cd     ben_schedd_hrs_rt_f.freq_cd%type;
  l_person_hours       number;
  l_det_dt	       date;
  l_output             ff_exec.outputs_t;
  l_pl_rec             ben_pl_f%rowtype;
  l_pgm_rec            ben_pgm_f%rowtype;
  l_package            varchar2(80) := g_package||'.check_sched_hrs';
  --
  cursor c_scheduled_hours
    (c_effective_date    date,
     c_person_id         number,
     c_freq_cd           varchar2,
     c_business_group_id number)  is
  select sum(normal_hours)
  from   per_all_assignments_f
  where  person_id = c_person_id
  and    c_effective_date between effective_start_date and effective_end_date
  and    frequency = c_freq_cd
  and    business_group_id = c_business_group_id;

  cursor c_asg_scheduled_hours
    (c_effective_date    date,
     c_assignment_id 	 number,
     c_business_group_id number)  is
  select normal_hours, frequency
  from   per_all_assignments_f
  where  assignment_id = c_assignment_id
  and    c_effective_date between effective_start_date and effective_end_date
  and    business_group_id = c_business_group_id;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      -- If there is a rule evaluate the rule
      if l_inst_set(i).schedd_hrs_rl is not null then
      	 l_output := benutils.formula
	                 (p_formula_id        => l_inst_set(i).schedd_hrs_rl
		         ,p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date)
		         ,p_business_group_id => p_business_group_id
		         ,p_assignment_id     => p_assignment_id
		         ,p_organization_id   => p_organization_id
		         ,p_pgm_id            => p_pgm_id
		         ,p_pl_id             => p_pl_id
		         ,p_pl_typ_id         => p_pl_typ_id
		         ,p_opt_id            => p_opt_id
		         ,p_ler_id            => p_ler_id
		         ,p_jurisdiction_code => p_jurisdiction_code -- FONM
                         ,p_param1             => 'BEN_IV_RT_STRT_DT'
                         ,p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt)
                         ,p_param2             => 'BEN_IV_CVG_STRT_DT'
                         ,p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt));

      	 --
         for l_count in l_output.first..l_output.last loop
           --
           declare
           	invalid_param exception;
           begin
             --
             if l_output(l_count).name = 'MIN_HOURS' then
                 --
                 l_min_hours := to_number(l_output(l_count).value);
                 --
             elsif l_output(l_count).name = 'MAX_HOURS' then
                 --
                 l_max_hours := to_number(l_output(l_count).value);
                 --
             elsif l_output(l_count).name = 'FREQUENCY' then
                 --
                 l_freq_cd := l_output(l_count).value;
                 --
             else
               --
               -- Account for cases where formula returns an unknown
               -- variable name
               --
               fnd_message.set_name('BEN','BEN_92310_FORMULA_RET_PARAM_');
               fnd_message.set_token('PROC',l_package);
               fnd_message.set_token('FORMULA', l_inst_set(i).schedd_hrs_rl);
               fnd_message.set_token('PARAMETER',l_output(l_count).name);

               -- Handling this particular exception seperately.
               raise invalid_param;
               --
             end if;
             --
             -- Code for type casting errors from formula return variables
             --
           exception
             --
             -- Code appended for bug# 2620550
	     when invalid_param then
             	fnd_message.raise_error;
             when others then
               --
               fnd_message.set_name('BEN','BEN_92311_FORMULA_VAL_PARAM');
               fnd_message.set_token('PROC',l_package);
               fnd_message.set_token('FORMULA', l_inst_set(i).schedd_hrs_rl);
               fnd_message.set_token('PARAMETER',l_output(l_count).name);
               fnd_message.raise_error;
             --
	   end;
      	 end loop;
      	 --
      	 if l_min_hours is null and l_max_hours is null then
 	       fnd_message.set_name('BEN','BEN_92310_FORMULA_RET_PARAM_');
               fnd_message.set_token('PROC',l_package);
               fnd_message.set_token('FORMULA', l_inst_set(i).schedd_hrs_rl);
               fnd_message.set_token('PARAMETER','MIN_HOURS');
               fnd_message.raise_error;
         end if;

      	 if l_freq_cd is null then
 	       fnd_message.set_name('BEN','BEN_92310_FORMULA_RET_PARAM_');
               fnd_message.set_token('PROC',l_package);
               fnd_message.set_token('FORMULA', l_inst_set(i).schedd_hrs_rl);
               fnd_message.set_token('PARAMETER','FREQUENCY');
               fnd_message.raise_error;
      	 end if;
      else
      	   l_min_hours := l_inst_set(i).hrs_num;
      	   l_max_hours := l_inst_set(i).max_hrs_num;
           l_freq_cd   := l_inst_set(i).freq_cd;
      end if;
      -- Get the determination date from determination_cd
      if l_inst_set(i).determination_cd is not null or l_inst_set(i).determination_rl is not null then
         ben_determine_date.main
          (p_date_cd           => l_inst_set(i).determination_cd,
           p_per_in_ler_id     => p_per_in_ler_id,
           p_person_id         => p_person_id,
           p_pgm_id            => p_pgm_id,
           p_pl_id             => p_pl_id,
           p_oipl_id           => p_oipl_id,
           p_business_group_id => p_business_group_id,
           p_formula_id        => l_inst_set(i).determination_rl,
           p_effective_date    => p_effective_date,
           p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
           p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
           p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
           p_returned_date     => l_det_dt );
      end if;


     --


      --
      if l_det_dt is null then
           -- FONM
           l_det_dt  := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                          nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                              nvl(p_lf_evt_ocrd_dt,p_effective_date)));
      end if;

      -- get Scheduled hour details from the assignment records
      if p_pl_id is not null then
           ben_comp_object.get_object(p_pl_id => p_pl_id
                                ,p_rec   => l_pl_rec);
      end if;

      if p_pgm_id is not null then
       	   ben_comp_object.get_object(p_pgm_id => p_pgm_id
                                ,p_rec    => l_pgm_rec);
      end if;
      --
      if l_pl_rec.use_all_asnts_for_rt_flag = 'Y' or l_pgm_rec.uses_all_asmts_for_rts_flag = 'Y' then
      	   open c_scheduled_hours
                (l_det_dt,p_person_id,
                 l_freq_cd, p_business_group_id);
           fetch c_scheduled_hours into l_person_hours;
           close c_scheduled_hours;

           l_person_freq_cd := l_freq_cd;
      else
      	    open c_asg_scheduled_hours
	                   (l_det_dt,p_assignment_id,
	                    p_business_group_id);
	    fetch c_asg_scheduled_hours into l_person_hours, l_person_freq_cd;
            close c_asg_scheduled_hours;
      end if;

      -- Applying the rounding code
      if (l_inst_set(i).rounding_cd is not null or l_inst_set(i).rounding_rl is not null)
        and l_person_hours is not null then
            l_person_hours := benutils.do_rounding
                        (p_rounding_cd     => l_inst_set(i).rounding_cd,
                         p_rounding_rl     => l_inst_set(i).rounding_rl,
                         p_value           => l_person_hours,
                         p_effective_date  => nvl(p_lf_evt_ocrd_dt,p_effective_date));
      end if;

      -- Evaluate
      if l_min_hours is not null and l_max_hours is null then
      	    l_ok := (l_person_hours >= l_min_hours) and l_person_freq_cd = l_freq_cd;
      elsif l_min_hours is null and l_max_hours is not null  then
      	    l_ok := l_person_hours <= l_max_hours and l_person_freq_cd = l_freq_cd;
      else
            l_ok := l_person_hours between l_min_hours and l_max_hours
                     and l_person_freq_cd = l_freq_cd;
      end if;

      --
      if l_ok is null or p_normal_hrs is null or p_frequency is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise g_criteria_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_ok := true ;
        -- exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
end check_sched_hrs;
--
-- --------------------------------------------------------------
--  Work location check.
-- --------------------------------------------------------------
--
procedure check_wk_location
  (p_vrbl_rt_prfl_id   in number
  ,p_person_id         in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_location_id       in number) is
  --
  l_inst_set ben_rt_prfl_cache.g_wkloc_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    -- Data found. Loop through to see if excld flag is on or off.
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_ok := p_location_id = l_inst_set(i).location_id;
      --
      if l_ok is null or p_location_id is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise g_criteria_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_rows_found := true;
        l_ok := true ;
        -- exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
end check_wk_location;
--
-- ---------------------------------------------------------------
--  Service area check.
-- ---------------------------------------------------------------
--

PROCEDURE check_service_area
  (p_vrbl_rt_prfl_id   IN NUMBER
  ,p_person_id         IN NUMBER
  ,p_business_group_id IN NUMBER
  ,p_effective_date    IN DATE
  ,p_lf_evt_ocrd_dt    IN DATE
  ,p_postal_code       IN VARCHAR2) IS
  --
--
-- FONM
--
CURSOR get_elig_svc (p_vrbl_rt_prfl_id IN NUMBER
                    ,cv_effective_date IN DATE) IS
   SELECT sar.svc_area_id,  sar.excld_flag
   FROM   ben_svc_area_rt_f sar
   WHERE  sar.vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
   AND    cv_effective_date -- FONM NVL(p_lf_evt_ocrd_dt, p_effective_date)
   BETWEEN sar.effective_start_date
   AND     sar.effective_end_date;
--
/* NOT USED
CURSOR get_zip_ranges(p_svc_area_id IN NUMBER
                     ,p_postal_code in VARCHAR2
                     ,cv_effective_date in date) IS
SELECT zip.from_value, zip.to_value
FROM  ben_pstl_zip_rng_f zip
WHERE zip.pstl_zip_rng_id IN (
	SELECT pstl_zip_rng_id
	FROM   ben_svc_area_pstl_zip_rng_f rng
	WHERE  rng.SVC_AREA_ID = p_svc_area_id
	AND    cv_effective_date BETWEEN rng.effective_start_date
	AND rng.effective_end_date)
AND    LENGTH(p_postal_code) >= LENGTH(zip.from_value)
AND    (SUBSTR( NVL(p_postal_code,'-1'),1,LENGTH(zip.from_value))
BETWEEN zip.from_value and NVL(zip.to_value,p_postal_code)
OR     NVL(p_postal_code,'-1') = zip.from_value
OR     NVL(p_postal_code,'-1') = zip.to_value)
AND    cv_effective_date BETWEEN zip.effective_start_date
AND    zip.effective_end_date;
*/

  l_rows_found       BOOLEAN := false;
  l_svc_area_id      NUMBER(15);
  l_excld_flag       VARCHAR2(1);
  l_from_value       VARCHAR2(10);
  l_to_value         VARCHAR2(10);
  l_ok               BOOLEAN := false;
  --
  -- FONM
  l_fonm_cvg_strt_dt   date;
  --
BEGIN
  --
  -- FONM
  --
  if ben_manage_life_events.fonm = 'Y' then
     --
     l_fonm_cvg_strt_dt := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                               ben_manage_life_events.g_fonm_cvg_strt_dt);
     --
  end if;
  --
  -- Get the data from the cache.
  --
  -- Getting eligibility profile service area range by eligibility profile
  --
  OPEN get_elig_svc(p_vrbl_rt_prfl_id,
       nvl(l_fonm_cvg_strt_dt, nvl(p_lf_evt_ocrd_dt,p_effective_date)));
  <<range_loop>>
  LOOP
    FETCH get_elig_svc INTO l_svc_area_id,l_excld_flag;
    EXIT WHEN get_elig_svc%NOTFOUND;
    l_rows_found := FALSE;
    --
    ben_saz_cache.SAZRZR_Exists                 -- 9999 FONM
      (p_svc_area_id => l_svc_area_id
      ,p_zip_code    => p_postal_code
      ,p_eff_date    => p_effective_date -- FONM why not lf_evt_ocrd_dt passed?
      --
      ,p_exists      => l_rows_found
      );
    --
    IF (l_rows_found AND l_excld_flag = 'N') THEN
       --
       l_rows_found := TRUE;
       l_ok := true;
       exit;
       --
    ELSIF ( NOT l_rows_found AND l_excld_flag = 'Y' ) then
       --
       l_rows_found := TRUE;
       l_ok := true;
       --
    ELSIF ( l_rows_found AND l_excld_flag = 'Y' ) then
       -- close get_elig_svc ;
       fnd_message.set_name('BEN','BEN_92225_SVC_AREA_PRFL_FAIL');
       -- raise g_criteria_failed;
       l_rows_found :=FALSE ;
       l_ok := false ;
       exit ;
    END IF;
  --
  END LOOP range_loop;
  CLOSE get_elig_svc;
  --
  if (NOT l_rows_found)  and (not l_ok)  then
     --
     RAISE ben_evaluate_rate_profiles.g_profile_failed;
     --
  End if;
  --
  --
END check_service_area;
--
-- ---------------------------------------------------------------
--    Hourly/Salary Code check
-- ---------------------------------------------------------------
--
procedure check_hourly_salary
  (p_vrbl_rt_prfl_id      in number
  ,p_business_group_id    in number
  ,p_effective_date       in date
  ,p_lf_evt_ocrd_dt       in date
  ,p_hrly_slry            in varchar2) is
  --
  l_inst_set ben_rt_prfl_cache.g_hrlyslrd_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_ok := p_hrly_slry = l_inst_set(i).hrly_slrd_cd;
      --
      if l_ok is null or p_hrly_slry is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise g_criteria_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_rows_found := true;
        l_ok := true ;
        -- exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
end check_hourly_salary;
--
-- ----------------------------------------------------
--  Age check.
-- ----------------------------------------------------
--
procedure check_age
  (p_vrbl_rt_prfl_id        in number
  ,p_person_id              in number
  ,p_per_dob                in date
  ,p_business_group_id      in number
  ,p_effective_date         in date
  ,p_lf_evt_ocrd_dt         in date
  ,p_elig_per_elctbl_chc_id in number
  ,p_pl_id                  in number default null
  ,p_pgm_id                 in number default null
  ,p_oipl_id                in number default null
  ,p_plip_id                in number default null
  ,p_opt_id                 in number default null
  ,p_per_in_ler_id          in number default null
  ,p_currepe_row            in ben_determine_rates.g_curr_epe_rec)
is
  --
  l_proc            varchar2(80) := g_package||'.check_age';
  --
  l_pl_id           number;
  l_pgm_id          number;
  l_per_in_ler_id   number;
  l_oipl_id         number;
  l_per_age         number;
  l_dummy_date      date;
  l_prtn_ovridn_flag  varchar2(30);
  l_prtn_ovridn_thru_dt date;
  l_epo_row           ben_derive_part_and_rate_facts.g_cache_structure;
  l_effective_date   date ;
  --

  --
  --    Grab needed parameters for passing into determin_age procedure.
  --
  cursor c_age_param is
    select epe.pl_id, epe.pgm_id, epe.oipl_id, epe.per_in_ler_id
    from   ben_elig_per_elctbl_chc epe
    where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
  --
  l_inst_set ben_rt_prfl_cache.g_age_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --RCHASE
  l_dob date:=p_per_dob;
  l_mx_age_num number ;
  --
begin
  --
  --- fonm2
  l_effective_date  := nvl(  p_lf_evt_ocrd_dt,  p_effective_date ) ;
  if ben_manage_life_events.fonm = 'Y' then
     --
      l_effective_date  :=  nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                l_effective_date));
     --
  end if;


  --hr_utility.set_location(l_proc||' Entering ',10);
  if p_elig_per_elctbl_chc_id is not null then
    --
    open c_age_param;
      --
      fetch c_age_param into l_pl_id, l_pgm_id, l_oipl_id, l_per_in_ler_id;
      --
    close c_age_param;
     --
  else
    --
    l_pl_id   := p_pl_id;
    l_pgm_id  := p_pgm_id;
    l_oipl_id := p_oipl_id;
    l_per_in_ler_id := p_per_in_ler_id;
    --
  end if;
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --hr_utility.set_location(l_proc||' Dn GRP Cac ',10);
  --
  if l_inst_count > 0 then
    --
    -- plan in program is overriden, capture the data from cache by passing plip_id
    if p_opt_id is null and p_pgm_id is not null then
       ben_pep_cache.get_pilpep_dets(
            p_person_id         => p_person_id,
            p_business_group_id => p_business_group_id,
            p_effective_date    => l_effective_date,
            p_pgm_id            => p_pgm_id,
            p_plip_id           => p_plip_id,
            p_inst_row          => l_epo_row);
            l_prtn_ovridn_flag    := l_epo_row.prtn_ovridn_flag;
            l_prtn_ovridn_thru_dt := l_epo_row.prtn_ovridn_thru_dt;
            l_per_age             := l_epo_row.rt_age_val;
    elsif p_opt_id is not null and p_pgm_id is not null then
            ben_pep_cache.get_pilepo_dets(
            p_person_id         => p_person_id,
            p_business_group_id => p_business_group_id,
            p_effective_date    => l_effective_date,
            p_pgm_id            => p_pgm_id,
            p_plip_id           => p_plip_id,
            p_opt_id            => p_opt_id,
            p_inst_row          => l_epo_row);
            l_prtn_ovridn_flag    := l_epo_row.prtn_ovridn_flag;
            l_prtn_ovridn_thru_dt := l_epo_row.prtn_ovridn_thru_dt;
            l_per_age             := l_epo_row.rt_age_val;
    else
          hr_utility.set_location('Plan not in Program',10);
           l_prtn_ovridn_flag    := p_currepe_row.prtn_ovridn_flag;
           l_prtn_ovridn_thru_dt := p_currepe_row.prtn_ovridn_thru_dt;
           l_per_age             := p_currepe_row.rt_age_val;
    end if;

    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      if l_inst_set(i).age_fctr_id is null then
        --
        fnd_message.set_name('BEN','BEN_91520_BERP_AGE_FCTR_ID');
        fnd_message.set_token('L_PROC',l_proc);
        fnd_message.set_token('PERSON_ID',to_char(p_person_id));
        fnd_message.set_token('VRBL_RT_PRFL_ID',to_char(p_vrbl_rt_prfl_id));
        fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
        fnd_message.set_token('PL_ID',to_char(p_pl_id));
        fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
        fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
        fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
        fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID',to_char(p_elig_per_elctbl_chc_id));
        fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
        fnd_message.raise_error;
        --
      end if;
      --
      --RCHASE - v115.57 wrap l_prtn_ovridn_flag with NVL,
      --         possible NULL return instead of expected TRUE or FALSE
      if not (nvl(l_prtn_ovridn_flag,'N') = 'Y' and
               nvl(l_prtn_ovridn_thru_dt,hr_api.g_eot) > p_effective_date)
          then
    --
        ben_derive_factors.determine_age
        (p_person_id            => p_person_id
        --RCHASE changed p_per_dob to l_dob
        ,p_per_dob              => l_dob
        ,p_age_fctr_id          => l_inst_set(i).age_fctr_id
        ,p_pgm_id               => l_pgm_id
        ,p_pl_id                => l_pl_id
        ,p_oipl_id              => l_oipl_id
        ,p_per_in_ler_id        => l_per_in_ler_id
        ,p_effective_date       => p_effective_date
        ,p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt
        --fonm
        ,p_fonm_cvg_strt_dt     => ben_manage_life_events.g_fonm_cvg_strt_dt
        ,p_fonm_rt_strt_dt      => ben_manage_life_events.g_fonm_rt_strt_dt
        ,p_business_group_id    => p_business_group_id
        ,p_perform_rounding_flg => TRUE
        ,p_value                => l_per_age
        ,p_change_date          => l_dummy_date);
      --
      end if;
      hr_utility.set_location(' age ' || l_per_age , 610.2);
      hr_utility.set_location(' mn age ' || l_inst_set(i).mn_age_num  , 610.2);
      --
      l_mx_age_num := l_inst_set(i).mx_age_num ;
      --
      if ( l_inst_set(i).mx_age_num <> trunc(l_inst_set(i).mx_age_num)  OR
           l_inst_set(i).mn_age_num <> trunc(l_inst_set(i).mn_age_num) ) then
        -- Decimal Case
        l_mx_age_num := l_inst_set(i).mx_age_num + 0.000000001 ;
        --
      else
        --
        l_mx_age_num := l_inst_set(i).mx_age_num + 1 ;
        --
      end if;
      --
      hr_utility.set_location(' l_mx_age_num '||l_mx_age_num , 610.10);
      --
      l_ok := (l_per_age >= l_inst_set(i).mn_age_num and
              l_per_age < l_mx_age_num )
             or
             (l_inst_set(i).no_mn_age_flag = 'Y' and
              l_per_age < l_mx_age_num )
             or
             (l_inst_set(i).no_mx_age_flag = 'Y' and
              l_per_age >= l_inst_set(i).mn_age_num);
      --
      if l_ok is null or l_per_age is null then
      --
        --hr_utility.set_location(' Step 1' ,99);
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        --hr_utility.set_location(' Step 2' ,99);
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        --hr_utility.set_location(' Step 3' ,99);
        -- raise ben_evaluate_rate_profiles.g_profile_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_ok := true ;
        -- exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        --hr_utility.set_location(' Step 4' ,99);
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    --hr_utility.set_location(' Step 5 ' ,99);
    raise ben_evaluate_rate_profiles.g_profile_failed;
    --
  end if;
  --
end check_age;
--
-- -----------------------------------------------------------
--  Comp level check.
-- -----------------------------------------------------------
--
procedure check_comp_level
  (p_vrbl_rt_prfl_id        in number
  ,p_person_id              in number
  ,p_business_group_id      in number
  ,p_effective_date         in date
  ,p_lf_evt_ocrd_dt         in date
  ,p_elig_per_elctbl_chc_id in number
  ,p_pl_id                  in number default null
  ,p_pgm_id                 in number default null
  ,p_oipl_id                in number default null
  ,p_per_in_ler_id          in number default null)
is
  --
  l_pl_id              number;
  l_pgm_id             number;
  l_per_in_ler_id      number;
  l_oipl_id            number;
  l_compensation_value number;
  l_mx_comp_val        number;
  l_effective_date     date ;
  --
  --    Grab needed parameters for passing into determin_age procedure.
  --
  cursor c_comp_param is
    select epe.pl_id, epe.pgm_id, epe.oipl_id, epe.per_in_ler_id
    from   ben_elig_per_elctbl_chc epe
    where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
  --
  l_proc            varchar2(80) := g_package||'.check_comp_level';
  l_inst_set ben_rt_prfl_cache.g_complvl_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
   --- fonm2
  l_effective_date  := nvl(  p_lf_evt_ocrd_dt,  p_effective_date ) ;
  if ben_manage_life_events.fonm = 'Y' then
     --
      l_effective_date  :=  nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                l_effective_date));
     --
  end if;

  if p_elig_per_elctbl_chc_id is not null then
    --
    open c_comp_param;
      --
      fetch c_comp_param into l_pl_id, l_pgm_id, l_oipl_id, l_per_in_ler_id;
      --
    close c_comp_param;
    --
  else
    --
    l_pl_id         := p_pl_id;
    l_pgm_id        := p_pgm_id;
    l_oipl_id       := p_oipl_id;
    l_per_in_ler_id := p_per_in_ler_id;
    --
  end if;
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      if l_inst_set(i).comp_lvl_fctr_id is null then
        --
        fnd_message.set_name('BEN','BEN_91526_BERP_CMP_LVL_FCTR_ID');
        fnd_message.set_token('L_PROC',l_proc);
        fnd_message.set_token('PERSON_ID',to_char(p_person_id));
        fnd_message.set_token('VRBL_RT_PRFL_ID',to_char(p_vrbl_rt_prfl_id));
        fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
        fnd_message.set_token('PL_ID',to_char(p_pl_id));
        fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
        fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
        fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
        fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID',to_char(p_elig_per_elctbl_chc_id));
        fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
        fnd_message.raise_error;
        --
      end if;
      --
      ben_derive_factors.determine_compensation
            (p_comp_lvl_fctr_id     => l_inst_set(i).comp_lvl_fctr_id
            ,p_person_id            => p_person_id
            ,p_pgm_id               => l_pgm_id
            ,p_pl_id                => l_pl_id
            ,p_oipl_id              => l_oipl_id
            ,p_per_in_ler_id        => l_per_in_ler_id
            ,p_business_group_id    => p_business_group_id
            ,p_perform_rounding_flg => true
            ,p_effective_date       => p_effective_date
            ,p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt

            ,p_fonm_cvg_strt_dt     => ben_manage_life_events.g_fonm_cvg_strt_dt
            ,p_fonm_rt_strt_dt      => ben_manage_life_events.g_fonm_rt_strt_dt
            ,p_value                => l_compensation_value);

      hr_utility.set_location( ' compen ' || l_compensation_value , 610.2) ;
      hr_utility.set_location( ' mn compen ' ||  l_inst_set(i).mn_comp_val   , 610.2) ;
      --
      -- Bug 2101937 fixes
      l_mx_comp_val := l_inst_set(i).mx_comp_val ;
      --
      if ( l_inst_set(i).mx_comp_val <> trunc(l_inst_set(i).mx_comp_val)  OR
           l_inst_set(i).mn_comp_val <> trunc(l_inst_set(i).mn_comp_val) ) then
        -- Decimal Case
        l_mx_comp_val := l_inst_set(i).mx_comp_val + 0.000000001 ;
        --
      else
        --
        l_mx_comp_val := l_inst_set(i).mx_comp_val + 1 ;
        --
      end if;
      --
      hr_utility.set_location('if' , 610) ;
      --
      l_ok := (nvl(l_compensation_value,-1) >= l_inst_set(i).mn_comp_val and
               nvl(l_compensation_value,9999999) < l_mx_comp_val )
              or
              (l_inst_set(i).no_mn_comp_flag = 'Y' and
               nvl(l_compensation_value,9999999) < l_mx_comp_val )
              or
              (l_inst_set(i).no_mx_comp_flag = 'Y' and
               nvl(l_compensation_value,-1) >= l_inst_set(i).mn_comp_val);


      --
      if l_ok is null or l_compensation_value is null then
      --
        l_ok := false;
      --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise ben_evaluate_rate_profiles.g_profile_failed;
        l_ok := false;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_ok := true ;
        -- exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise ben_evaluate_rate_profiles.g_profile_failed;
    --
  end if;
  --
end check_comp_level;
--
-- -----------------------------------------------------------
--     LOS check.
-- -----------------------------------------------------------
--
procedure check_los
  (p_vrbl_rt_prfl_id        in number
  ,p_person_id              in number
  ,p_business_group_id      in number
  ,p_effective_date         in date
  ,p_lf_evt_ocrd_dt         in date
  ,p_elig_per_elctbl_chc_id in number
  ,p_pl_id                  in number default null
  ,p_pgm_id                 in number default null
  ,p_oipl_id                in number default null
  ,p_plip_id                in number default null
  ,p_opt_id                 in number default null
  ,p_per_in_ler_id          in number default null
  ,p_currepe_row            in ben_determine_rates.g_curr_epe_rec)
is
  --
  l_rows_found        boolean := false;
  l_pl_id             number;
  l_oipl_id           number;
  l_pgm_id            number;
  l_plip_id           number;
  l_per_los           number;
  l_per_in_ler_id     number;
  l_dummy_date        date;
  l_prtn_ovridn_flag  varchar2(30);
  l_prtn_ovridn_thru_dt date;
  l_epo_row           ben_derive_part_and_rate_facts.g_cache_structure;
  l_effective_date   date ;
  --
  --  Grab needed parameters for accessing LOS_VAL.
  --
  cursor c_elect is
    select epe.pl_id, epe.pgm_id, epe.oipl_id, epe.per_in_ler_id
    from   ben_elig_per_elctbl_chc epe
    where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
  --
  l_inst_set ben_rt_prfl_cache.g_los_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_mx_los_num number ;
  --
begin
  --
  -- retrieve electble choice data needed
  --

    --- fonm2
  l_effective_date  := nvl(  p_lf_evt_ocrd_dt,  p_effective_date ) ;
  if ben_manage_life_events.fonm = 'Y' then
     --
      l_effective_date  :=  nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                l_effective_date));
     --
  end if;



  if p_elig_per_elctbl_chc_id is not null then
     --
     open c_elect;
       --
       fetch c_elect into l_pl_id,
                          l_pgm_id,
                          l_oipl_id,
                          l_per_in_ler_id;
       --
     close c_elect;
     --
  else
     --
     l_pl_id         := p_pl_id;
     l_pgm_id        := p_pgm_id;
     l_oipl_id       := p_oipl_id;
     l_per_in_ler_id := p_per_in_ler_id;
     --
  end if;
  --
  -- Get the data from the cache.
  --
  hr_utility.set_location('p_vrbl_rt_prfl_id rate level '||p_vrbl_rt_prfl_id,10);
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  hr_utility.set_location('l_per_los rate level '||l_per_los,10);
  hr_utility.set_location('l_inst_count '||l_inst_count,10);
  --
  if l_inst_count > 0 then
    --
    -- plan in program is overriden, capture the data from cache by passing plip_id
    if p_opt_id is null and p_pgm_id is not null then
       ben_pep_cache.get_pilpep_dets(
            p_person_id         => p_person_id,
            p_business_group_id => p_business_group_id,
            p_effective_date    => l_effective_date,
            p_pgm_id            => p_pgm_id,
            p_plip_id           => p_plip_id,
            p_inst_row          => l_epo_row);
            l_prtn_ovridn_flag    := l_epo_row.prtn_ovridn_flag;
            l_prtn_ovridn_thru_dt := l_epo_row.prtn_ovridn_thru_dt;
            l_per_los             := l_epo_row.rt_los_val;
    elsif p_opt_id is not null and p_pgm_id is not null then
            ben_pep_cache.get_pilepo_dets(
            p_person_id         => p_person_id,
            p_business_group_id => p_business_group_id,
            p_effective_date    => l_effective_date,
            p_pgm_id            => p_pgm_id,
            p_plip_id           => p_plip_id,
            p_opt_id            => p_opt_id,
            p_inst_row          => l_epo_row);
            l_prtn_ovridn_flag    := l_epo_row.prtn_ovridn_flag;
            l_prtn_ovridn_thru_dt := l_epo_row.prtn_ovridn_thru_dt;
            l_per_los             := l_epo_row.rt_los_val;
    else
          hr_utility.set_location('Plan not in Program',10);
           l_prtn_ovridn_flag    := p_currepe_row.prtn_ovridn_flag;
           l_prtn_ovridn_thru_dt := p_currepe_row.prtn_ovridn_thru_dt;
           l_per_los             := p_currepe_row.rt_los_val;
    end if;

    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
     -- if the variable rate is overriden then don't call determine_los
     --RCHASE - v115.57 wrap l_prtn_ovridn_flag with NVL,
     --         possible NULL return instead of expected TRUE or FALSE
     if not (nvl(l_prtn_ovridn_flag,'N') = 'Y' and
               nvl(l_prtn_ovridn_thru_dt,hr_api.g_eot) > p_effective_date)
          then
    --
      ben_derive_factors.determine_los
         (p_person_id            => p_person_id
         ,p_los_fctr_id          => l_inst_set(i).los_fctr_id
         ,p_per_in_ler_id        => l_per_in_ler_id
         ,p_pgm_id               => l_pgm_id
         ,p_pl_id                => l_pl_id
         ,p_oipl_id              => l_oipl_id
         ,p_effective_date       => p_effective_date
         ,p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt
         --fonm
         ,p_fonm_cvg_strt_dt     => ben_manage_life_events.g_fonm_cvg_strt_dt
         ,p_fonm_rt_strt_dt      => ben_manage_life_events.g_fonm_rt_strt_dt
         ,p_business_group_id    => p_business_group_id
         ,p_perform_rounding_flg => TRUE
         ,p_value                => l_per_los
         ,p_start_date           => l_dummy_date);
      --
      end if;
      hr_utility.set_location( ' los ' || l_per_los , 610.2);
      -- Bug 2101937 fixes
      l_mx_los_num := l_inst_set(i).mx_los_num ;
      --
      if ( l_inst_set(i).mx_los_num <> trunc(l_inst_set(i).mx_los_num)  OR
           l_inst_set(i).mn_los_num <> trunc(l_inst_set(i).mn_los_num) ) then
        -- Decimal Case
        l_mx_los_num := l_inst_set(i).mx_los_num + 0.000000001 ;
        --
      else
        --
        l_mx_los_num := l_inst_set(i).mx_los_num + 1 ;
        --
      end if;
      --
      l_ok := (nvl(l_per_los,-1) >= l_inst_set(i).mn_los_num and
               nvl(l_per_los,999999) < l_mx_los_num )
             or
             (l_inst_set(i).no_mn_los_num_apls_flag = 'Y' and
              nvl(l_per_los,999999) < l_mx_los_num )

             or
             (l_inst_set(i).no_mx_los_num_apls_flag = 'Y' and
              nvl(l_per_los,-1) >= l_inst_set(i).mn_los_num);
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        l_rows_found := true;
        l_ok := false;
        exit;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_rows_found := true;
        l_ok := true ;
        -- exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise ben_evaluate_rate_profiles.g_profile_failed;
    --
  end if;
  --
end check_los;
--
-- --------------------------------------------------------------------
--  Combination age/los check.
-- --------------------------------------------------------------------
--
procedure check_age_los
  (p_vrbl_rt_prfl_id         in number
  ,p_person_id               in number
  ,p_business_group_id       in number
  ,p_effective_date          in date
  ,p_lf_evt_ocrd_dt          in date
  ,p_elig_per_elctbl_chc_id  in number
  ,p_pl_id                   in number default null
  ,p_pgm_id                  in number default null
  ,p_oipl_id                 in number default null
  ,p_plip_id                in number default null
  ,p_opt_id                 in number default null
  ,p_per_in_ler_id           in number default null
  ,p_currepe_row            in ben_determine_rates.g_curr_epe_rec)
is
  --
  l_pl_id              number;
  l_pgm_id             number;
  l_per_in_ler_id      number;
  l_oipl_id            number;
  l_cmbn_age_n_los_val number;
  l_dummy_date         date;
  l_prtn_ovridn_flag  varchar2(30);
  l_prtn_ovridn_thru_dt date;
  l_epo_row           ben_derive_part_and_rate_facts.g_cache_structure;
  l_effective_date    date ;
  --


  --
  --    Grab needed parameters for accessing CMBN_AGE_N_LOS_VAL .
  --
  cursor c_elect is
    select epe.pl_id, epe.pgm_id, epe.oipl_id, epe.per_in_ler_id
    from   ben_elig_per_elctbl_chc epe
    where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
  --
  l_inst_set ben_rt_prfl_cache.g_age_los_inst_tbl;
  l_inst_count number;
  l_ok boolean := false;
  l_rows_found boolean := false;
  --
begin
  --
      --- fonm2
  l_effective_date  := nvl(  p_lf_evt_ocrd_dt,  p_effective_date ) ;
  if ben_manage_life_events.fonm = 'Y' then
     --
      l_effective_date  :=  nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                l_effective_date));
     --
  end if;


  -- retrieve electble choice data needed
  --
  if p_elig_per_elctbl_chc_id is not null then
    --
    open c_elect;
      --
      fetch c_elect into l_pl_id,
                         l_pgm_id,
                         l_oipl_id,
                         l_per_in_ler_id;
      --
    close c_elect;
    --
  else
    --
    l_pl_id := p_pl_id;
    l_pgm_id := p_pgm_id;
    l_oipl_id := p_oipl_id;
    l_per_in_ler_id := p_per_in_ler_id;
    --
  end if;
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
     -- plan in program is overriden, capture the data from cache by passing plip_id
    if p_opt_id is null and p_pgm_id is not null then
       ben_pep_cache.get_pilpep_dets(
            p_person_id         => p_person_id,
            p_business_group_id => p_business_group_id,
            p_effective_date    => l_effective_date,
            p_pgm_id            => p_pgm_id,
            p_plip_id           => p_plip_id,
            p_inst_row          => l_epo_row);
            l_prtn_ovridn_flag    := l_epo_row.prtn_ovridn_flag;
            l_prtn_ovridn_thru_dt := l_epo_row.prtn_ovridn_thru_dt;
            l_cmbn_age_n_los_val  := l_epo_row.rt_cmbn_age_n_los_val;
    elsif p_opt_id is not null and p_pgm_id is not null then
            ben_pep_cache.get_pilepo_dets(
            p_person_id         => p_person_id,
            p_business_group_id => p_business_group_id,
            p_effective_date    => l_effective_date,
            p_pgm_id            => p_pgm_id,
            p_plip_id           => p_plip_id,
            p_opt_id            => p_opt_id,
            p_inst_row          => l_epo_row);
            l_prtn_ovridn_flag    := l_epo_row.prtn_ovridn_flag;
            l_prtn_ovridn_thru_dt := l_epo_row.prtn_ovridn_thru_dt;
            l_cmbn_age_n_los_val  := l_epo_row.rt_cmbn_age_n_los_val;
    else
          hr_utility.set_location('Plan not in Program',10);
           l_prtn_ovridn_flag    := p_currepe_row.prtn_ovridn_flag;
           l_prtn_ovridn_thru_dt := p_currepe_row.prtn_ovridn_thru_dt;
           l_cmbn_age_n_los_val  := p_currepe_row.rt_cmbn_age_n_los_val;
    end if;

    -- Data found. Loop through to see if excld flag is on or off.
    --
    l_rows_found := true;
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
       -- if the variable rate is overriden then don't call determine_los
     --RCHASE - v115.57 wrap l_prtn_ovridn_flag with NVL,
     --         possible NULL return instead of expected TRUE or FALSE
     if not (nvl(l_prtn_ovridn_flag,'N') = 'Y' and
               nvl(l_prtn_ovridn_thru_dt,hr_api.g_eot) > p_effective_date)
          then
        --BBULUSU - changed determine_los to determine_comb_age_los below
        ben_derive_factors.determine_comb_age_los
         (p_person_id            => p_person_id
         ,p_cmbn_age_los_fctr_id => l_inst_set(i).cmbn_age_los_fctr_id
         ,p_per_in_ler_id        => l_per_in_ler_id
         ,p_pgm_id               => l_pgm_id
         ,p_pl_id                => l_pl_id
         ,p_oipl_id              => l_oipl_id
         ,p_effective_date       => p_effective_date
         ,p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt
         -- fonm
         ,p_fonm_cvg_strt_dt     => ben_manage_life_events.g_fonm_cvg_strt_dt
         ,p_fonm_rt_strt_dt      => ben_manage_life_events.g_fonm_rt_strt_dt
         ,p_business_group_id    => p_business_group_id
         ,p_value                => l_cmbn_age_n_los_val);
      --
      end if;
      l_ok := nvl(l_cmbn_age_n_los_val,-1)
                between nvl(l_inst_set(i).cmbnd_min_val,0)
                    and nvl(l_inst_set(i).cmbnd_max_val,99999999);
      --
      if l_ok is null then
        --
        l_ok := false ;
        --
      end if;
      --
      if l_ok and l_inst_set(i).excld_flag = 'N' then
        --
        exit;
        --
      elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
        --
        -- raise ben_evaluate_rate_profiles.g_profile_failed;
        l_ok :=  false ;
        exit ;
        --
      elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
        -- Bug 2100564
        l_ok := true ;
        --exit ;
        --
      elsif l_inst_set(i).excld_flag = 'N' then
        --
        l_rows_found := true;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise ben_evaluate_rate_profiles.g_profile_failed;
    --
  end if;
  --
end check_age_los;
--
-- ---------------------------------------------------------------
--    Period of enrollment
--   Note:  This profile is only for COBRA. It will be changed later
--          for general use.
-- ---------------------------------------------------------------
--
procedure check_period_of_enrollment
  (p_vrbl_rt_prfl_id      in number
  ,p_business_group_id    in number
  ,p_effective_date       in date
  ,p_lf_evt_ocrd_dt       in date
  ,p_person_id            in number
  ,p_pgm_id               in number default null
  ,p_pl_typ_id            in number default null
  ,p_ler_id               in number default null) is
  --
  l_inst_set            ben_rt_prfl_cache.g_poe_inst_tbl;
  l_init_lf_evt_ocrd_dt date;
  l_inst_count          number;
  l_strt_dt             date;
  l_end_dt              date;
  l_exists              varchar2(1);
  l_dsbld               boolean := false;
  l_mn_poe_num          ben_poe_rt_f.mn_poe_num%type;
  --
  cursor c_get_quald_bnf is
    select cqb.*, crp.per_in_ler_id
    from ben_cbr_quald_bnf cqb
        ,ben_cbr_per_in_ler crp
        ,ben_per_in_ler pil
    where cqb.quald_bnf_person_id = p_person_id
    and cqb.quald_bnf_flag = 'Y'
    and nvl(p_lf_evt_ocrd_dt,p_effective_date)
    between cqb.cbr_elig_perd_strt_dt and
            cqb.cbr_elig_perd_end_dt
    and cqb.business_group_id = p_business_group_id
    and cqb.cbr_quald_bnf_id = crp.cbr_quald_bnf_id
    and cqb.pgm_id = nvl(p_pgm_id,cqb.pgm_id)
    and nvl(cqb.pl_typ_id,nvl(p_pl_typ_id,-1)) = nvl(p_pl_typ_id,-1)
    and crp.per_in_ler_id = pil.per_in_ler_id
    and crp.business_group_id = cqb.business_group_id
    and pil.business_group_id = crp.business_group_id
    and crp.init_evt_flag = 'Y'
    and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_get_all_quald_bnf(p_cvrd_emp_person_id in number) is
    select cqb.*
    from ben_cbr_quald_bnf cqb
        ,ben_cbr_per_in_ler crp
        ,ben_per_in_ler pil
    where cqb.cvrd_emp_person_id = p_cvrd_emp_person_id
    and cqb.quald_bnf_flag = 'Y'
    and nvl(p_lf_evt_ocrd_dt,p_effective_date)
    between cqb.cbr_elig_perd_strt_dt and
            cqb.cbr_elig_perd_end_dt
    and cqb.business_group_id = p_business_group_id
    and cqb.cbr_quald_bnf_id = crp.cbr_quald_bnf_id
    and cqb.pgm_id = nvl(p_pgm_id,cqb.pgm_id)
    and nvl(cqb.pl_typ_id,nvl(p_pl_typ_id,-1)) = nvl(p_pl_typ_id,-1)
    and crp.per_in_ler_id = pil.per_in_ler_id
    and crp.business_group_id = cqb.business_group_id
    and pil.business_group_id = crp.business_group_id
    and crp.init_evt_flag = 'Y'
    and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_get_dsblity_evt(p_cbr_quald_bnf_id number) is
    select null
    from ben_cbr_per_in_ler crp
       , ben_ler_f ler
       , ben_per_in_ler pil
    where crp.cbr_quald_bnf_id = p_cbr_quald_bnf_id
    and crp.per_in_ler_id = pil.per_in_ler_id
    and pil.ler_id = ler.ler_id
    and ler.typ_cd = 'DSBLTY'
    and ler.qualg_evt_flag = 'Y'
    and nvl(p_lf_evt_ocrd_dt,p_effective_date)
    between ler.effective_start_date and
            ler.effective_end_date
    and ler.business_group_id = p_business_group_id
    and ler.business_group_id = pil.business_group_id
    and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    and crp.cnt_num = (select max(cnt_num)
                         from ben_cbr_per_in_ler crp2
                              ,ben_per_in_ler pil2
                         where crp2.cbr_quald_bnf_id = p_cbr_quald_bnf_id
                         and crp2.per_in_ler_id =  pil2.per_in_ler_id
                         and pil2.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
                         and crp2.business_group_id = p_business_group_id
                         and crp2.business_group_id = pil2.business_group_id);
    cursor c_ler is
      select null
      from
        ben_ler_f ler
      where
             ler.ler_id = p_ler_id
         and ler.QUALG_EVT_FLAG = 'Y'
         and p_effective_date between
             ler.effective_start_date and ler.effective_end_date
         and ler.business_group_id = p_business_group_id ;
   --
   l_ler_rec   c_ler%rowtype;

  --
  l_cqb_rec   c_get_quald_bnf%rowtype;
  l_cqb2_rec   c_get_all_quald_bnf%rowtype;
begin
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);
  --
  hr_utility.set_location ('l_inst_count:'||l_inst_count,10);
  if l_inst_count > 0 then
    --
    -- Data found. Loop through to see if excld flag is on or off.
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      --  This profile is only applicable to COBRA qualified
      --  beneficiary.
      --
      open c_get_quald_bnf;
      fetch c_get_quald_bnf into l_cqb_rec;
      if c_get_quald_bnf%notfound then
        hr_utility.set_location ('did not find quald bnf:',10);
        close c_get_quald_bnf;
          --
          -- Bug 1566944 Check for new terminations with qualifying event
          --     New a termination life event is processes, system can't find
          --     any rows for the person in ben_cbr_quald_bnf. So we are checking the
          --     Cobra qualifying event flag for the life event.

             --
             open c_ler;
             fetch c_ler into l_ler_rec ;
              if c_ler%notfound then
                hr_utility.set_location ('not a new qualifying termination event:',10);
                close c_ler;
                raise ben_evaluate_rate_profiles.g_profile_failed;
              else
                close c_ler;
                --  Calculate the start date.
                --
                if l_inst_set(i).no_mn_poe_flag = 'N' then
                --
                --  We need to get the first day of the period of enrollment.
                --
                   if l_inst_set(i).mn_poe_num > 1 then
                      l_mn_poe_num := l_inst_set(i).mn_poe_num - 1;
                   end if;
                   --
                   l_strt_dt := (benutils.derive_date
                         (p_date      => nvl(p_lf_evt_ocrd_dt,p_effective_date) -- l_cqb_rec.cbr_elig_perd_strt_dt
                         ,p_uom       => l_inst_set(i).poe_nnmntry_uom
                         ,p_min       => null
                         ,p_max       => l_mn_poe_num
                         ,p_value     => null
                         )) + 1;
                else
                      l_strt_dt := hr_api.g_sot;
                end if;
                --
                hr_utility.set_location ('l_strt_dt '||l_strt_dt, 199);
                --  Calculate the end date.
                --
                if l_inst_set(i).no_mx_poe_flag = 'N' then
                   l_end_dt := benutils.derive_date
                        (p_date      =>  nvl(p_lf_evt_ocrd_dt,p_effective_date) -- l_cqb_rec.cbr_elig_perd_strt_dt
                        ,p_uom       => l_inst_set(i).poe_nnmntry_uom
                        ,p_min       => null
                        ,p_max       => l_inst_set(i).mx_poe_num
                        ,p_value     => null
                        );
                else
                   l_end_dt := hr_api.g_eot;
                end if;
                --
                hr_utility.set_location ('l_end_dt '||l_end_dt , 199);
                --
                if nvl(p_lf_evt_ocrd_dt, p_effective_date) not between
                    l_strt_dt and l_end_dt then
                    raise ben_evaluate_rate_profiles.g_profile_failed;
                end if;
                --
                goto l_ler ;
                --
              end if ;


        raise ben_evaluate_rate_profiles.g_profile_failed;
      else
        close c_get_quald_bnf;
        --
        --  Calculate the start date.
        --
        if l_inst_set(i).no_mn_poe_flag = 'N' then
          --
          --  We need to get the first day of the period of enrollment.
          --
          if l_inst_set(i).mn_poe_num > 1 then
             l_mn_poe_num := l_inst_set(i).mn_poe_num - 1;
          end if;
          --
          l_strt_dt := (benutils.derive_date
                         (p_date      => l_cqb_rec.cbr_elig_perd_strt_dt
                         ,p_uom       => l_inst_set(i).poe_nnmntry_uom
                         ,p_min       => null
                         ,p_max       => l_mn_poe_num
                         ,p_value     => null
                         ));
          hr_utility.set_location ('l_strt_dt '||l_strt_dt, 200);
        else
          l_strt_dt := hr_api.g_sot;
        end if;
        --
        --  Calculate the end date.
        --
        if l_inst_set(i).no_mx_poe_flag = 'N' then
          l_end_dt := benutils.derive_date
                        (p_date      => l_cqb_rec.cbr_elig_perd_strt_dt
                        ,p_uom       => l_inst_set(i).poe_nnmntry_uom
                        ,p_min       => null
                        ,p_max       => l_inst_set(i).mx_poe_num
                        ,p_value     => null
                        );
        else
          l_end_dt := hr_api.g_eot;
        end if;
        --
        --  Disability rates applies if:
        --  1) if the last qualifying event that the person experienced
        --  is disability.  He/she has not experience another event within
        --  the 18 month period that entitles them to a longer eligibility
        --  period.
        --
        --  2) If the person was disabled at the time of
        --  the qualifying event.
        --  Disability rates does not apply if the disabled person
        --  is no longer covered. All other qualified beneficiary cannot
        --  be charge more than the 102%
        --
        if l_inst_set(i).cbr_dsblty_apls_flag = 'Y' then
          --
          --  Check if one of the qualified beneficiaries
          --  is disabled.
          --
          l_dsbld := false;
          --
          for l_cqb2_rec in c_get_all_quald_bnf(l_cqb_rec.cvrd_emp_person_id)
          loop
            if ben_cobra_requirements.chk_dsbld
                 (p_person_id         => l_cqb2_rec.quald_bnf_person_id
                 ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
                 ,p_effective_date    => p_effective_date
                 ,p_business_group_id => p_business_group_id) = true then
              --
              --  Check if person was disabled at the time of the qualifying
              --  event.
              --
              l_init_lf_evt_ocrd_dt
                := ben_cobra_requirements.get_lf_evt_ocrd_dt
                     (p_per_in_ler_id     => l_cqb_rec.per_in_ler_id
                     ,p_business_group_id => p_business_group_id
                     );
              if ben_cobra_requirements.chk_dsbld
                (p_person_id         => l_cqb2_rec.quald_bnf_person_id
                ,p_lf_evt_ocrd_dt    => l_init_lf_evt_ocrd_dt
                ,p_effective_date    => p_effective_date
                ,p_business_group_id => p_business_group_id) = false then
                --
                --  Check if person was disabled within the first 60
                --  days of the qualifying event.
                --
                open c_get_dsblity_evt(l_cqb_rec.cbr_quald_bnf_id);
                fetch c_get_dsblity_evt into l_exists;
                if c_get_dsblity_evt%notfound then
                  close c_get_dsblity_evt;
                  --
                else
                  hr_utility.set_location ('disability rate applies 60 :',10);
                  close c_get_dsblity_evt;
                  l_dsbld := true;
                  exit;
                end if;
              else
                hr_utility.set_location ('disability rate applies tom :',10);
                l_dsbld := true;
                exit;
              end if;
            end if;
          end loop;
          --
          if l_dsbld = false then
            raise ben_evaluate_rate_profiles.g_profile_failed;
          end if;
        end if;
        --
        if nvl(p_lf_evt_ocrd_dt, p_effective_date) not between
          l_strt_dt and l_end_dt then
          raise ben_evaluate_rate_profiles.g_profile_failed;
        end if;
      end if; -- qualified beneficiary
      --
      <<l_ler>>
      null;
    end loop;
    --
  end if;
  --
end check_period_of_enrollment;
--
-- ---------------------------------------------------------------
--    ttl_prtt check
-- ---------------------------------------------------------------
--
procedure check_ttl_prtt
  (p_vrbl_rt_prfl_id      in number
  ,p_business_group_id    in number
  ,p_effective_date       in date
  ,p_lf_evt_ocrd_dt       in date
  ,p_ttl_prtt             in number default null)
is
  --
  l_proc          varchar2(80) := g_package||'.check_ttl_prtt';
  l_inst_set      ben_rt_prfl_cache.g_ttl_prtt_inst_tbl;
  l_inst_count    number;
  l_profile_match varchar2(1);
  --
begin
  hr_utility.set_location ('check_ttl_prtt:'||to_char(p_ttl_prtt),10);

  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);


  l_profile_match := 'N';
  if l_inst_count > 0 then
    if p_ttl_prtt is null then
        -- there are variable profile criteria for total number of participants
        -- attached, but the process did not pass in a the number of prtts.
        fnd_message.set_name('BEN','BEN_92244_TTL_PRTT_REQUIRED');
        fnd_message.set_token('L_PROC',l_proc);
        fnd_message.set_token('VRBL_RT_PRFL_ID',to_char(p_vrbl_rt_prfl_id));
        fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
        fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
        fnd_message.raise_error;
    end if;
    --
    -- Data found. Loop through to see we match the total number of prtts.
    --
    for i in l_inst_set.first..l_inst_set.last loop
      hr_utility.set_location ('p_ttl:'||to_char(p_ttl_prtt)||
      ' min:'||to_char(l_inst_set(i).mn_prtt_num)||' max:'||
      to_char(l_inst_set(i).mx_prtt_num),33);

      if p_ttl_prtt between nvl(l_inst_set(i).mn_prtt_num,0)
         and  nvl(l_inst_set(i).mx_prtt_num,999999999999999) then
        -- we match one of the ranges, exit with success.
        l_profile_match := 'Y';
        exit;
      end if;
    end loop;

    if l_profile_match = 'N' then
      raise ben_evaluate_rate_profiles.g_profile_failed;
    end if;

  end if;
end check_ttl_prtt;

-- --------------------------------------------------
--  JOB RATE.
-- --------------------------------------------------
procedure check_job(p_vrbl_rt_prfl_id   in number,
                    p_business_group_id in number,
                    p_effective_date    in date,
                    p_lf_evt_ocrd_dt    in date,
                    p_job_id            in number) is
  --
  l_proc       	varchar2(100) := g_package||'check_job';
  l_inst_set 	ben_rt_prfl_cache.g_job_inst_tbl;
  l_inst_count 	number;
  l_ok 		boolean := false;
  l_rows_found 	boolean := false;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);

  --
  if l_inst_count > 0 then
      --
      -- Data found. Loop through to see if excld flag is on or off.
      --
      l_rows_found := true;
      --
      for i in l_inst_set.first..l_inst_set.last loop
        --
        l_ok := l_inst_set(i).job_id = p_job_id;
        --
        if l_ok is null or p_job_id is null then
        --
          l_ok := false;
        --
        end if;
        --
        if l_ok and l_inst_set(i).excld_flag = 'N' then
          --
          exit;
          --
        elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
          --
          -- raise g_criteria_failed;
          l_ok := false;
          exit ;
          --
        elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
          --
          l_ok := true ;
          --
        elsif l_inst_set(i).excld_flag = 'N' then
          --
          l_rows_found := true;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    if l_rows_found and not l_ok then
      --
      raise g_criteria_failed;
      --
    end if;
    --
end check_job;


-- --------------------------------------------------
--  OPTED FOR MEDICARE.
-- --------------------------------------------------
procedure check_optd_mdcr(p_vrbl_rt_prfl_id    in number,
                    		p_business_group_id in number,
                    		p_effective_date    in date,
	                        p_lf_evt_ocrd_dt    in date,
                    		p_person_id         in number) is
  --
  l_proc       	varchar2(100) := g_package||'check_optd_for_medicare';
  l_inst_set 	ben_rt_prfl_cache.g_optd_mdcr_inst_tbl;
  l_inst_count 	number;
  l_ok 		boolean := false;
  l_rows_found 	boolean := false;
  l_rec		per_all_people_f%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);

  --
  if l_inst_count > 0 then
      ben_person_object.get_object(p_person_id => p_person_id,
                                   p_rec       => l_rec);
      --
      for l_num in l_inst_set.first .. l_inst_set.last loop
      --
      	   l_rows_found := true;
      	   l_ok := nvl((nvl(l_rec.per_information10,'N') =
           l_inst_set(l_num).optd_mdcr_flag),FALSE);
      --
      --  There is only one row so there is no need to do further checking.
      --
      end loop;
  end if;
  --
  if l_rows_found and not l_ok then
      --
      raise g_criteria_failed;
      --
  end if;
  --
end check_optd_mdcr;

-- --------------------------------------------------
--  LEAVING REASON
-- --------------------------------------------------
procedure check_lvg_rsn(p_vrbl_rt_prfl_id    in number,
                    	p_business_group_id  in number,
                    	p_effective_date     in date,
                    	p_lf_evt_ocrd_dt     in date,
                    	p_person_id          in number) is
  --
  l_proc       	varchar2(100) := g_package||'check_lvg_rsn';
  l_inst_set 	ben_rt_prfl_cache.g_lvg_rsn_inst_tbl;
  l_inst_count 	number;
  l_ok 		boolean := false;
  l_rows_found 	boolean := false;
  l_rec		per_periods_of_service%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);

  --
  if l_inst_count > 0 then
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_rec);
      --
      for i in l_inst_set.first..l_inst_set.last loop
      --
	      l_rows_found := true;
	      l_ok := nvl((nvl(l_rec.leaving_reason,'-1') =
		      l_inst_set(i).lvg_rsn_cd),FALSE);
	      --
	      if l_ok = true then
		if l_inst_set(i).excld_flag = 'Y' then
		  --
		  l_ok := false;
		  exit ;
		  --
		else
		  --
		  exit;
		  --
		end if;
	      elsif l_inst_set(i).excld_flag = 'Y' then
		--
		l_ok := true;
		-- exit;
		--
	      end if;
      --
    end loop;
  end if;
  --
  if l_rows_found and not l_ok then
      --
      raise g_criteria_failed;
      --
  end if;
  --
end check_lvg_rsn;


-- --------------------------------------------------
--  COBRA QUALIFIED BENEFICIARY
-- --------------------------------------------------
procedure check_cbr_quald_bnf(p_vrbl_rt_prfl_id    in number,
                    	     p_business_group_id  in number,
                    	     p_effective_date     in date,
                    	     p_person_id          in number,
                    	     p_lf_evt_ocrd_dt     in date) is
  --
  l_proc       	varchar2(100) := g_package||'check_cbr_quald_bnf';
  l_inst_set 	ben_rt_prfl_cache.g_cbr_qual_bnf_inst_tbl;
  l_inst_count 	number;
  l_ok 		boolean := false;
  l_rows_found 	boolean := false;
  l_rec		per_all_people_f%rowtype;
  l_quald_bnf_flag   ben_cbr_quald_bnf.quald_bnf_flag%type;
  --
  cursor c1(p_person_id      in number
            ,p_lf_evt_ocrd_dt in date
            ,p_pgm_id         in number
            ,p_ptip_id        in number) is
  select cqb.quald_bnf_flag
  from   ben_cbr_quald_bnf  cqb
        ,ben_cbr_per_in_ler crp
        ,ben_per_in_ler     pil
  where cqb.quald_bnf_person_id = p_person_id
  and cqb.pgm_id = nvl(p_pgm_id,cqb.pgm_id)
  and nvl(cqb.ptip_id,-1) = nvl(p_ptip_id, -1)
  and p_lf_evt_ocrd_dt
  between nvl(cqb.cbr_elig_perd_strt_dt , p_lf_evt_ocrd_dt)
  and     nvl(cqb.cbr_elig_perd_end_dt , p_lf_evt_ocrd_dt)
  and cqb.business_group_id  = p_business_group_id
  and cqb.cbr_quald_bnf_id = crp.cbr_quald_bnf_id
  and crp.per_in_ler_id = pil.per_in_ler_id
  and crp.business_group_id = cqb.business_group_id
  and crp.init_evt_flag = 'Y'
  and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');

begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);

  --
  if l_inst_count > 0 then
      ben_person_object.get_object(p_person_id => p_person_id,
                                   p_rec       => l_rec);
      --
      for i in l_inst_set.first..l_inst_set.last loop
      --
	      l_rows_found := true;
	      -- FONM
	      open c1(p_person_id
		     ,nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                       nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                         nvl(p_lf_evt_ocrd_dt,p_effective_date)))
		     ,l_inst_set(i).pgm_id
		     ,l_inst_set(i).ptip_id);
	      fetch c1 into l_quald_bnf_flag;
	      if c1%found then
		l_ok := nvl((nvl(l_quald_bnf_flag,'-1') = l_inst_set(i).quald_bnf_flag),FALSE);
	      else
		l_ok := nvl((l_inst_set(i).quald_bnf_flag = 'N'),FALSE);
	      end if;
	      close c1;

	      if l_ok then
		exit;
	      end if;
	      --
      end loop;
  end if;
  --
  if l_rows_found and not l_ok then
      --
      raise g_criteria_failed;
      --
  end if;
  --
end check_cbr_quald_bnf;


-- --------------------------------------------------
--  DEPENDENT COVERED OTHER PLAN
-- --------------------------------------------------
procedure check_dpnt_cvrd_othr_pl(p_vrbl_rt_prfl_id    in number,
                    	     p_business_group_id  in number,
                    	     p_effective_date     in date,
                    	     p_person_id          in number ,
                    	     p_lf_evt_ocrd_dt     in date) is
  --
  l_proc       	varchar2(100) := g_package||'check_dpnt_cvrd_othr_pl';
  l_inst_set 	ben_rt_prfl_cache.g_dpnt_cvrd_othr_pl_inst_tbl;
  l_inst_count 	number;
  l_ok 		boolean := false;
  l_rows_found 	boolean := false;

  l_date_to_use      date;
  l_dummy            varchar2(1);
  --
  cursor c1(p_pl_id in number) is
    select null
    from   ben_elig_cvrd_dpnt_f pdp,
           ben_prtt_enrt_rslt_f pen
    where  pen.business_group_id  = p_business_group_id
    and    pen.pl_id = p_pl_id
    and    pdp.dpnt_person_id = p_person_id
    and    l_date_to_use
           between pen.enrt_cvg_strt_dt
           and     pen.enrt_cvg_thru_dt
    and    pen.enrt_cvg_thru_dt <= pen.effective_end_date
    and    pdp.business_group_id  = pen.business_group_id
    and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
    --and    pen.prtt_enrt_rslt_stat_cd not in ('BCKDT', 'VOIDD')
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    l_date_to_use
           between pdp.cvg_strt_dt
           and     pdp.cvg_thru_dt
    and    pdp.effective_end_date = hr_api.g_eot;

begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);

  --
  if l_inst_count > 0 then
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_rows_found := true;
      --
      --
      -- Apply the date logic to the life event occurred date.
      --
      ben_determine_date.main
        (p_date_cd        => l_inst_set(i).cvg_det_dt_cd,
         p_effective_date => p_effective_date,
         p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
         p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
         p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
         p_returned_date  => l_date_to_use);
      --
      open c1(l_inst_set(i).pl_id);
      fetch c1 into l_dummy;
      --
      if c1%found then
        --
        close c1;
        --
        if l_inst_set(i).excld_flag = 'N' then
          l_ok := true;
          exit;
        end if;
        --
        if l_inst_set(i).excld_flag = 'Y' then
          l_ok := false;
          exit;
        end if;
        --
      else
        --
        close c1;
        if l_inst_set(i).excld_flag = 'Y' then
          l_ok := true;
          -- exit;
        end if;
      end if;
      --
    end loop;
  end if;
  --
  if l_rows_found and not l_ok then
      --
      raise g_criteria_failed;
      --
  end if;
  --
end check_dpnt_cvrd_othr_pl;


-- --------------------------------------------------
--  DEPENDENT COVERED OTHER PLAN IN PROGRAM
-- --------------------------------------------------
procedure check_dpnt_cvrd_othr_plip (p_vrbl_rt_prfl_id    in number,
                    	     p_business_group_id  in number,
                    	     p_effective_date     in date,
                    	     p_person_id          in number ,
                    	     p_lf_evt_ocrd_dt     in date) is
  --
  l_proc       	varchar2(100) := g_package||'check_dpnt_cvrd_othr_plip';
  l_inst_set 	ben_rt_prfl_cache.g_dpnt_cvrd_othr_plip_inst_tbl;
  l_inst_count 	number;
  l_ok 		boolean := false;
  l_rows_found 	boolean := false;

  l_date_to_use      date;
  l_dummy            varchar2(1);
  --
  cursor c1(p_plip_id in number) is
    select null
    from   ben_prtt_enrt_rslt_f pen
          ,ben_elig_cvrd_dpnt_f pdp
          ,ben_plip_f           cpp
    where  pen.prtt_enrt_rslt_id = pdp.prtt_enrt_rslt_id
    --and    pen.prtt_enrt_rslt_stat_cd not in ('BCKDT', 'VOIDD')
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pdp.dpnt_person_id = p_person_id
    and    pen.pgm_id = cpp.pgm_id
    and    pen.pl_id  = cpp.pl_id
    and    cpp.plip_id = p_plip_id
    and    l_date_to_use
           between cpp.effective_start_date
           and     cpp.effective_end_date
    and    cpp.business_group_id = pen.business_group_id
    and    l_date_to_use
           between pen.enrt_cvg_strt_dt
           and     pen.enrt_cvg_thru_dt
    and    pen.business_group_id  = p_business_group_id
    and    pen.enrt_cvg_thru_dt <= pen.effective_end_date
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pdp.business_group_id = pen.business_group_id
    and    l_date_to_use
           between pdp.cvg_strt_dt
           and     pdp.cvg_thru_dt
    and    pdp.effective_end_date = hr_api.g_eot;
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);

  --
  if l_inst_count > 0 then
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_rows_found := true;
      --
      --
      -- Apply the date logic to the life event occurred date.
      --
      ben_determine_date.main
        (p_date_cd        => l_inst_set(i).enrl_det_dt_cd,
         p_effective_date => p_effective_date,
         p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
         p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
         p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
         p_returned_date  => l_date_to_use);
      --
      open c1(l_inst_set(i).plip_id);
      fetch c1 into l_dummy;
      --
      if c1%found then
        --
        close c1;
        --
        if l_inst_set(i).excld_flag = 'N' then
          l_ok := true;
          exit;
        end if;
        --
        if l_inst_set(i).excld_flag = 'Y' then
          l_ok := false;
          exit;
        end if;
        --
      else
        --
        close c1;
        if l_inst_set(i).excld_flag = 'Y' then
          l_ok := true;
          -- exit;
        end if;
      end if;
      --
    end loop;
  end if;
  --
  if l_rows_found and not l_ok then
      --
      raise g_criteria_failed;
      --
  end if;
  --
end check_dpnt_cvrd_othr_plip;


-- --------------------------------------------------
--  DEPENDENT COVERED OTHER PLAN TYPE IN PROGRAM
-- --------------------------------------------------
procedure check_dpnt_cvrd_othr_ptip(p_vrbl_rt_prfl_id    in number,
					 p_business_group_id in number,
					 p_effective_date    in date,
				         p_person_id         in number,
                                         p_lf_evt_ocrd_dt    in date) is
  --
  l_proc       	varchar2(100) := g_package||'check_dpnt_cvrd_othr_ptip';
  l_inst_set 	ben_rt_prfl_cache.g_dpnt_cvrd_othr_ptip_inst_tbl;
  l_inst_count 	number;
  l_ok 		boolean := false;
  l_rows_found 	boolean := false;

  l_continue    boolean := true;
  l_found_ptip  boolean := false;
  l_date_to_use date;
  l_dummy       varchar2(1);
  --
  cursor c1(p_ptip_id in number) is
    select pen.pl_id
    from   ben_prtt_enrt_rslt_f pen
          ,ben_elig_cvrd_dpnt_f pdp
    where  pen.prtt_enrt_rslt_id = pdp.prtt_enrt_rslt_id
    --and    pen.prtt_enrt_rslt_stat_cd not in ('BCKDT', 'VOIDD')
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pdp.dpnt_person_id = p_person_id
    and    pen.ptip_id = p_ptip_id
    and    l_date_to_use
           between pen.enrt_cvg_strt_dt
           and     pen.enrt_cvg_thru_dt
    and    pen.business_group_id  = p_business_group_id
    and    pen.enrt_cvg_thru_dt <= pen.effective_end_date
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pdp.business_group_id = pen.business_group_id
    and    l_date_to_use
           between pdp.cvg_strt_dt
           and     pdp.cvg_thru_dt
    and    pdp.effective_end_date = hr_api.g_eot;
  --
  cursor c2(p_pl_id in number) is
    select null
    from   ben_pl_regn_f prg
          ,ben_regn_f reg
    where  prg.pl_id = p_pl_id
    and    prg.regn_id = reg.regn_id
    and    reg.sttry_citn_name = 'COBRA'
    and    prg.business_group_id = p_business_group_id
    and    l_date_to_use
           between prg.effective_start_date
           and     prg.effective_end_date
    and    prg.business_group_id = reg.business_group_id
    and    l_date_to_use
           between reg.effective_start_date
           and     reg.effective_end_date;

begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);

  --
  if l_inst_count > 0 then
    <<prfl>>
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_rows_found := true;
      --
      --
      -- Apply the date logic to the life event occurred date.
      --
      ben_determine_date.main
        (p_date_cd        => l_inst_set(i).enrl_det_dt_cd,
         p_effective_date => p_effective_date,
         p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
         p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
         p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
         p_returned_date  => l_date_to_use);
      --
      <<dpnt>>
      for l_pdp_rec in c1(l_inst_set(i).ptip_id) loop
              --
              --  Check if the dependent have to be covered in the ptip where
              --  there are plans subject to cobra.
              --
              l_continue := true;
              --
              if l_inst_set(i).only_pls_subj_cobra_flag = 'Y' then
		    open c2(l_pdp_rec.pl_id);
		    fetch c2 into l_dummy;
		    if c2%notfound then
		        l_continue := false;
		    end if;
		    close c2;
              end if;
              --
              if l_continue then
                  l_found_ptip := true;
                  --
                  if l_inst_set(i).excld_flag = 'N' then
                     l_ok := true;
                     exit prfl;
                  end if;
                  --
                  if l_inst_set(i).excld_flag = 'Y' then
                     l_ok := false;
                     exit prfl;
                  end if;
                  --
              end if;
              --
      end loop dpnt;
      --
      if (l_found_ptip = false
         and l_inst_set(i).excld_flag = 'Y') then
        l_ok := true;
        exit;
      end if;
      --
    end loop prfl;
  end if;
  --
  if l_rows_found and not l_ok then
      --
      raise g_criteria_failed;
      --
  end if;
  --
end check_dpnt_cvrd_othr_ptip;


-- --------------------------------------------------
--  DEPENDENT COVERED OTHER PROGRAM
-- --------------------------------------------------
procedure check_dpnt_cvrd_othr_pgm(p_vrbl_rt_prfl_id    in number,
					 p_business_group_id in number,
					 p_effective_date    in date,
					 p_person_id         in number,
                                         p_lf_evt_ocrd_dt    in date) is
  --
  l_proc       	varchar2(100) := g_package||'check_dpnt_cvrd_othr_pgm';
  l_inst_set 	ben_rt_prfl_cache.g_dpnt_cvrd_othr_pgm_inst_tbl;
  l_inst_count 	number;
  l_ok 		boolean := false;
  l_rows_found 	boolean := false;

  l_date_to_use date;
  l_dummy       varchar2(1);
  --
  cursor c1(p_pgm_id in number) is
      select null
      from   ben_elig_cvrd_dpnt_f pdp,
             ben_prtt_enrt_rslt_f pen
      where  pen.business_group_id  = p_business_group_id
      and    pen.pgm_id = p_pgm_id
      and    pdp.dpnt_person_id = p_person_id
      and    l_date_to_use
             between pen.enrt_cvg_strt_dt
             and     pen.enrt_cvg_thru_dt
      and    pen.enrt_cvg_thru_dt <= pen.effective_end_date
      and    pdp.business_group_id  = pen.business_group_id
      and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      --and    pen.prtt_enrt_rslt_stat_cd not in ('BCKDT', 'VOIDD')
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    l_date_to_use
             between pdp.cvg_strt_dt
             and     pdp.cvg_thru_dt
      and    pdp.effective_end_date = hr_api.g_eot;


begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);

  --
  if l_inst_count > 0 then
     for i in l_inst_set.first..l_inst_set.last loop
      --
      l_rows_found := true;
      --
      --
      -- Apply the date logic to the life event occurred date.
      --
      ben_determine_date.main
        (p_date_cd        => l_inst_set(i).enrl_det_dt_cd,
         p_effective_date => p_effective_date,
         p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
         p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
         p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
         p_returned_date  => l_date_to_use);
      --
      open c1(l_inst_set(i).pgm_id);
      fetch c1 into l_dummy;
      --
      if c1%found then
        --
        close c1;
        --
        if l_inst_set(i).excld_flag = 'N' then
          l_ok := true;
          exit;
        end if;
        --
        if l_inst_set(i).excld_flag = 'Y' then
          l_ok := false;
          exit;
        end if;
        --
      else
        --
        close c1;
        if l_inst_set(i).excld_flag = 'Y' then
          l_ok := true;
          --exit ;
        end if;
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
      --
      raise g_criteria_failed;
      --
  end if;
  --
end check_dpnt_cvrd_othr_pgm;


-- --------------------------------------------------
--  ELIGIBLE FOR ANOTHER PLAN
-- --------------------------------------------------
procedure check_prtt_anthr_pl(p_vrbl_rt_prfl_id    in number,
				   p_business_group_id in number,
                                   p_person_id         in number,
                                   -- FONM overloaded eff date is fine.
                                   p_effective_date    in date,
                                   p_lf_evt_ocrd_dt    in date) is
  --
  l_proc       	varchar2(100) := g_package||'check_prtt_anthr_pl';
  l_inst_set 	ben_rt_prfl_cache.g_prtt_anthr_pl_inst_tbl;
  l_inst_count 	number;
  l_ok 		boolean := false;
  l_rows_found 	boolean := false;

  l_dummy                 varchar2(1);
  --
  cursor c1(p_pl_id in number) is
    select null
    from ben_elig_per_f epo,
         ben_per_in_ler pil
    where epo.person_id = p_person_id
    and epo.pl_id = p_pl_id
    and p_effective_date
    between epo.effective_start_date
    and     epo.effective_end_date
    and epo.business_group_id  = p_business_group_id
    and pil.per_in_ler_id(+)=epo.per_in_ler_id
   -- and pil.business_group_id(+)=epo.business_group_id
    and (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
        or pil.per_in_ler_stat_cd is null                  -- outer join condition
        );


begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);

  --
  if l_inst_count > 0 then
     for i in l_inst_set.first..l_inst_set.last loop
           --
           l_rows_found := true;
           --
           open c1(l_inst_set(i).pl_id);
           fetch c1 into l_dummy;
           if c1%found then
             --
             close c1;
             --
             if l_inst_set(i).excld_flag = 'N' then
               	l_ok := true;
               	exit;
             end if;
             --
             if l_inst_set(i).excld_flag = 'Y' then
               	l_ok := false;
               	exit;
             end if;
             --
           else
             --
             close c1;
             --
             if l_inst_set(i).excld_flag = 'Y' then
               l_ok := true;
               -- exit;
             end if;
           end if;
             --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
      --
      raise g_criteria_failed;
      --
  end if;
  --
end check_prtt_anthr_pl;

-- --------------------------------------------------
--  ELIGIBLE FOR ANOTHER PLAN TYPE IN PROGRAM
-- --------------------------------------------------
procedure check_othr_ptip
  (p_vrbl_rt_prfl_id   in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_person_id         in number
  ,p_per_in_ler_id     in number default null
  )
is
  --
  l_proc varchar2(100):='check_othr_ptip';
  --
  l_inst_set                    ben_rt_prfl_cache.g_othr_ptip_inst_tbl;
  l_inst_count                  number;
  i               		binary_integer;
  l_ok                          boolean := false;
  l_rows_found                  boolean := false;
  l_dummy                       varchar2(1);
  l_pl_rec                      ben_comp_object.g_cache_pl_rec_table;
  --
  l_cur_found                   boolean := false;
  --
  cursor pilc1
    (c_effective_date           date
    ,c_per_in_ler_id            number
    ,c_ptip_id                  number
    ,c_only_pls_subj_cobra_flag varchar2
    )
  is
   	select /*+ bendtlep.check_othr_ptip.pilc1 */
           null
    from   ben_pl_f pln,
           ben_plip_f cpp,
           ben_ptip_f ctp,
           ben_elig_per_f epo
    where  pln.pl_id = cpp.pl_id
    and    c_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date
    and    c_effective_date
           between cpp.effective_start_date
           and     cpp.effective_end_date
    and    cpp.pgm_id = ctp.pgm_id
    and    pln.pl_typ_id = ctp.pl_typ_id
    and    ctp.ptip_id   = c_ptip_id
    and    c_effective_date
           between ctp.effective_start_date
           and     ctp.effective_end_date
    and    epo.per_in_ler_id = c_per_in_ler_id
    and    epo.pgm_id = ctp.pgm_id
    and    epo.pl_id = pln.pl_id
    and    c_effective_date
           between epo.effective_start_date
           and     epo.effective_end_date
    and    epo.elig_flag = 'Y'
    and    ( c_only_pls_subj_cobra_flag = 'N'
     	     or exists  (select null
			 from   ben_pl_regn_f prg,
           			ben_regn_f reg
			 where  prg.pl_id = pln.pl_id
			 and    c_effective_date  between prg.effective_start_date
			 	and prg.effective_end_date
			 and    reg.regn_id = prg.regn_id
			 and    c_effective_date between reg.effective_start_date
			 	and reg.effective_end_date
    			 and    reg.sttry_citn_name = 'COBRA') ); -- 2443719
  --
  cursor c1
    (c_business_group_id        in number
    ,c_effective_date           in date
    ,c_person_id                in number
    ,c_ptip_id                  in number
    ,c_only_pls_subj_cobra_flag in varchar2
    )
  is
    select /*+ bendtlep.check_othr_ptip.c1 */
           null
    from   ben_pl_f pln,
           ben_plip_f cpp,
           ben_ptip_f ctp,
           ben_pl_regn_f prg,
           ben_regn_f reg,
           ben_elig_per_f epo,
           ben_per_in_ler pil
    where  pln.pl_id = cpp.pl_id
    and    pln.business_group_id  = c_business_group_id
    and    c_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date
    and    cpp.business_group_id  = pln.business_group_id
    and    c_effective_date
           between cpp.effective_start_date
           and     cpp.effective_end_date
    and    cpp.pgm_id = ctp.pgm_id
    and    pln.pl_typ_id = ctp.pl_typ_id
    and    ctp.ptip_id   = c_ptip_id
    and    ctp.business_group_id = pln.business_group_id
    and    c_effective_date
           between ctp.effective_start_date
           and     ctp.effective_end_date
    and    epo.person_id = c_person_id
    and    epo.pgm_id = ctp.pgm_id
    and    epo.pl_id = pln.pl_id
    and    epo.business_group_id  = c_business_group_id
    and    p_effective_date
           between epo.effective_start_date
           and     epo.effective_end_date
    and    epo.elig_flag = 'Y'
    and    ( c_only_pls_subj_cobra_flag = 'N'  -- cobra regulation needed only when the flag is set
             or exists  (select null
    			 from   ben_pl_regn_f prg,
               			ben_regn_f reg
    			 where  prg.pl_id = pln.pl_id
    			 and    c_effective_date  between prg.effective_start_date
    			 	and prg.effective_end_date
    			 and    prg.business_group_id  = pln.business_group_id
    			 and    reg.regn_id = prg.regn_id
    			 and    c_effective_date between reg.effective_start_date
    			 	and reg.effective_end_date
    			 and    reg.sttry_citn_name = 'COBRA') ) -- 2443719
    and pil.per_in_ler_id(+)=epo.per_in_ler_id
    --and pil.business_group_id(+)=epo.business_group_id
    and (   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') -- found row condition
          or pil.per_in_ler_stat_cd is null                  -- outer join condition
    ) ;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting variable profile compensation level by variable profile
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
     p_business_group_id => p_business_group_id,
     p_vrbl_rt_prfl_id     => p_vrbl_rt_prfl_id,
     p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
     p_inst_set          => l_inst_set,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this variable rate profile id
    -- 2) Look only at profiles for this PTIP_ID
    -- 3) if program is not null then, get all the ptip and check if
    --
    -- 4) Derive set of plans for the pgm that the ptip refers to
    -- 5) Set must be derived based on whether the plans are subject
    --    to COBRA or not.
    -- 6) If person eligible for any of the plans and exclude flag = 'Y'
    --    then no problem.
    -- 7) If person eligible for any of the plans and exclude flag = 'N'
    --    then fail criteria.
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_rows_found := true;
      --
      if p_per_in_ler_id is not null then
        --
        open pilc1
          (c_effective_date           => nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                                          nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                           nvl(p_lf_evt_ocrd_dt,p_effective_date)))
          ,c_per_in_ler_id            => p_per_in_ler_id
          ,c_ptip_id                  => l_inst_set(i).ptip_id
          ,c_only_pls_subj_cobra_flag => l_inst_set(i).only_pls_subj_cobra_flag
          );
        fetch pilc1 into l_dummy;
        if pilc1%found then
          --
          l_cur_found := TRUE;
          --
        else
          --
          l_cur_found := FALSE;
          --
        end if;
        close pilc1;
        --
      else
        --
        open c1
          (c_business_group_id        => p_business_group_id
          ,c_effective_date           => nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                                          nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,                                           nvl(p_lf_evt_ocrd_dt,p_effective_date)))
          ,c_person_id                => p_person_id
          ,c_ptip_id                  => l_inst_set(i).ptip_id
          ,c_only_pls_subj_cobra_flag => l_inst_set(i).only_pls_subj_cobra_flag
          );
        fetch c1 into l_dummy;
        if c1%found then
          --
          l_cur_found := TRUE;
          --
        else
          --
          l_cur_found := FALSE;
          --
        end if;
        close c1;
      end if;
      --
      if l_cur_found then
        --
        if l_inst_set(i).excld_flag = 'N' then
          --
          l_ok := true;
          exit;
          --
        end if;
        --
        if l_inst_set(i).excld_flag = 'Y' then
          --
          l_ok := false;
          exit;
          --
        end if;
        --
      else
        --
        if l_inst_set(i).excld_flag = 'Y' then
          --
          l_ok := true;
          --
        end if;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_othr_ptip ;

--
-- --------------------------------------------------------------------------
--  ENROLLED IN ANOTHER PLAN
-- --------------------------------------------------------------------------
--
procedure check_enrld_anthr_pl(p_vrbl_rt_prfl_id   in number,
                               p_business_group_id in number,
                               p_pl_id             in number,
                               p_person_id         in number,
                               p_effective_date    in date,
                               p_lf_evt_ocrd_dt    in date) is
  --
  l_proc             varchar2(100):=g_package||'check_enrld_anthr_pl';
  l_inst_set         ben_rt_prfl_cache.g_enrld_anthr_pl_inst_tbl;
  l_inst_count       number;
  i    		     binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_found_plan       boolean := false;
  l_date_to_use      date;
  l_dummy            varchar2(1);
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);

  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
     p_business_group_id => p_business_group_id,
     p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id,
     p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
     p_inst_set          => l_inst_set,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this variable profile profile id
    -- 2) If the plan id is the same then check if the person was covered
    --    the day before the life event.
    --
    <<prfl>>
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_rows_found := true;
      --
      -- 9999 FONM : how is this cache rebuilt.
      <<rslt>>
      for l_count in nvl(ben_manage_life_events.g_cache_person_prtn.first,0)..
                     nvl(ben_manage_life_events.g_cache_person_prtn.last,-1) loop
        if ben_manage_life_events.g_cache_person_prtn(l_count).pl_id =
           l_inst_set(i).pl_id then
          --
          -- Apply the date logic to the life event occurred date.
          --
          ben_determine_date.main
            (p_date_cd        => l_inst_set(i).enrl_det_dt_cd,
             p_effective_date => p_effective_date,
             p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
             p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
             p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
             p_returned_date  => l_date_to_use);
          --

          if (l_date_to_use
             between ben_manage_life_events.g_cache_person_prtn(l_count).enrt_cvg_strt_dt
             and ben_manage_life_events.g_cache_person_prtn(l_count).enrt_cvg_thru_dt) then
             l_found_plan := true;
            --
            if l_inst_set(i).excld_flag = 'N'then
              --
              l_ok := true;
              exit prfl;
              --
            end if;
            --
            if l_inst_set(i).excld_flag = 'Y'then
              --
              l_ok := false;
              exit prfl;
              --
            end if;
            --
          end if;
          --
        end if;
      end loop rslt;
      --
      --  If person is not enrolled in plan and exclude flag = 'Y',
      --  person is eligible.
      --
      if (l_found_plan = false
         and l_inst_set(i).excld_flag = 'Y') then
        l_ok := true;
        exit;
      end if;
      --
    end loop prfl;
    --
  end if;
  --
  if l_rows_found and not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_enrld_anthr_pl;
--
-- --------------------------------------------------------------------------
--  ENROLLED IN ANOTHER OPTION IN PLAN.
-- --------------------------------------------------------------------------
--
procedure check_enrld_anthr_oipl(p_vrbl_rt_prfl_id     in number,
                                      p_business_group_id in number,
                                      p_oipl_id           in number,
                                      p_person_id         in number,
                                      p_effective_date    in date,
                                      p_lf_evt_ocrd_dt    in date) is
  --
  l_proc             varchar2(100):=g_package||'check_enrld_anthr_oipl';
  l_inst_set         ben_rt_prfl_cache.g_enrld_anthr_oipl_inst_tbl;
  l_inst_count       number;
  i    		     binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_found_oipl       boolean := false;
  l_date_to_use      date;
  l_dummy            varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_prtt_enrt_rslt_f pen
    where  pen.business_group_id  = p_business_group_id
    and    pen.oipl_id = p_oipl_id
    and    pen.person_id = p_person_id
    and    l_date_to_use
           between pen.enrt_cvg_strt_dt
           and     pen.enrt_cvg_thru_dt
    and    pen.enrt_cvg_thru_dt <= pen.effective_end_date
    and    pen.prtt_enrt_rslt_stat_cd is null;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting variable rate profile compensation level by variable profile
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
     p_business_group_id => p_business_group_id,
     p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id,
     p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
     p_inst_set          => l_inst_set,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this variable profile id
    -- 2) If the plan id is the same then check if the person was covered
    --    the day before the life event.
    --
    <<prfl>>
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_rows_found := true;
      --
      -- 9999 FONM : how is this cache rebuilt.
      <<rslt>>
      for l_count in nvl(ben_manage_life_events.g_cache_person_prtn.first,0)..
                     nvl(ben_manage_life_events.g_cache_person_prtn.last,-1) loop
        if ben_manage_life_events.
           g_cache_person_prtn(l_count).oipl_id =
             l_inst_set(i).oipl_id then
          --
          -- Apply the date logic to the life event occurred date.
          --
          ben_determine_date.main
            (p_date_cd        => l_inst_set(i).enrl_det_dt_cd,
             p_effective_date => p_effective_date,
             p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
             p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
             p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
             p_returned_date  => l_date_to_use);
          --
          if (l_date_to_use
             between ben_manage_life_events.g_cache_person_prtn(l_count).enrt_cvg_strt_dt
             and ben_manage_life_events.g_cache_person_prtn(l_count).enrt_cvg_thru_dt) then
            --
            l_found_oipl := true;
            --
            if l_inst_set(i).excld_flag = 'N'then
              --
              l_ok := true;
              exit prfl;
              --
            end if;
            --
            if l_inst_set(i).excld_flag = 'Y'then
              --
              l_ok := false;
              exit prfl;
              --
            end if;
            --
          end if;
          --
        end if;
        --
      end loop rslt;
          --
      if (l_found_oipl = false
          and l_inst_set(i).excld_flag = 'Y') then
        --
        l_ok := true;
        exit;
          --
      end if;
      --
    end loop prfl;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_enrld_anthr_oipl;


--
-- --------------------------------------------------------------------------
--  ENROLLED OTHER PLAN TYPE IN PROGRAM.
-- --------------------------------------------------------------------------
--
procedure check_enrld_anthr_ptip(p_vrbl_rt_prfl_id     in number,
                                      p_business_group_id in number,
                                      p_effective_date    in date,
                                      p_lf_evt_ocrd_dt    in date) is
  --
  l_proc varchar2(100):=g_package||'check_enrld_anthr_ptip';
  --
  l_inst_set                    ben_rt_prfl_cache.g_enrld_anthr_ptip_inst_tbl;
  l_inst_count                  number;
  i               		binary_integer;
  l_ok                          boolean := false;
  l_rows_found                  boolean := false;
  l_found_ptip                  boolean := false;
  l_continue                    boolean := true;
  l_date_to_use                 date;
  l_dummy                       varchar2(1);
  l_pl_rec                      ben_comp_object.g_cache_pl_rec_table;
  --
  cursor c1(p_pl_id in number) is
    select null
    from   ben_pl_f pln,
           ben_pl_regn_f prg,
           ben_regn_f reg
    where  pln.pl_id = p_pl_id
    and    pln.business_group_id  = p_business_group_id
    and    l_date_to_use
           between pln.effective_start_date
           and     pln.effective_end_date
    and    pln.pl_id = prg.pl_id
    and    prg.business_group_id  = pln.business_group_id
    and    l_date_to_use
           between prg.effective_start_date
           and     prg.effective_end_date
    and    prg.regn_id = reg.regn_id
    and    reg.business_group_id  = prg.business_group_id
    and    l_date_to_use
           between reg.effective_start_date
           and     reg.effective_end_date
    and    reg.sttry_citn_name = 'COBRA';

  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting variable rate profile compensation level
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
     p_business_group_id => p_business_group_id,
     p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id,
     p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
     p_inst_set          => l_inst_set,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this variable profile id
    -- 2) Look only at profiles for this PTIP_ID
    -- 3) Set must be derived based on whether the plans are subject
    --    to COBRA or not.
    -- 4) If person eligible for any of the plans and exclude flag = 'Y'
    --    then no problem.
    -- 5) If person eligible for any of the plans and exclude flag = 'N'
    --    then fail criteria.
    --
    hr_utility.set_location('Getting profiles',10);
    <<prfl>>
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_rows_found := true;
      --
      hr_utility.set_location('Getting results',10);
      <<rslt>>
      for l_count in nvl(ben_manage_life_events.g_cache_person_prtn.first,0)..
                     nvl(ben_manage_life_events.g_cache_person_prtn.last,-1) loop
        if ben_manage_life_events.
           g_cache_person_prtn(l_count).ptip_id =
             l_inst_set(i).ptip_id then
          --
          -- Apply the date logic to the life event occurred date.
          --
          ben_determine_date.main
            (p_date_cd        => l_inst_set(i).enrl_det_dt_cd,
             p_effective_date => p_effective_date,
             p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
             p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
             p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
             p_returned_date  => l_date_to_use);
          --
          --  If only check plans that are subject to COBRA.
          --
          l_continue := true;
          --
          hr_utility.set_location('Getting cobra plans',10);
          --
          if l_inst_set(i).only_pls_subj_cobra_flag = 'Y' then
            --
            open c1(ben_manage_life_events.g_cache_person_prtn(l_count).pl_id);
              --
              fetch c1 into l_dummy;
              --
              if c1%notfound then
                --
                hr_utility.set_location('Cobra plans not found',10);
                l_continue := false;
                --
              end if;
              --
            close c1;
            --
          end if;
          --
          if l_continue then
            --
            hr_utility.set_location('Cobra plans found',10);
            --
            if (l_date_to_use
               between ben_manage_life_events.
                       g_cache_person_prtn(l_count).enrt_cvg_strt_dt
               and ben_manage_life_events.
                   g_cache_person_prtn(l_count).enrt_cvg_thru_dt) then
              --
              l_found_ptip := true;
              --
              if l_inst_set(i).excld_flag = 'N' then
                --
                hr_utility.set_location('Exclude flags = N Cobra plans found',10);
                l_ok := true;
                exit prfl;
                --
              end if;
              --
              if l_inst_set(i).excld_flag = 'Y' then
                --
                hr_utility.set_location('Exclude flags = Y Cobra plans found',10);
                l_ok := false;
                exit prfl;
                --
              end if;
              --
            end if;
            --
          end if;
          --
        end if;
        --
      end loop rslt;
      --
      if l_found_ptip = false
         and l_inst_set(i).excld_flag = 'Y' then
        --
        l_ok := true;
        exit;
        --
      end if;
      --
    end loop prfl;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_enrld_anthr_ptip;


--
-- --------------------------------------------------------------------------
--  ENROLLED IN ANOTHER PLAN IN PROGRAM.
-- --------------------------------------------------------------------------
--
procedure check_enrld_anthr_plip(p_vrbl_rt_prfl_id     in number,
                                      p_business_group_id in number,
                                      p_person_id         in number,
                                      p_effective_date    in date,
                                      p_lf_evt_ocrd_dt    in date) is
  --
  l_proc             varchar2(100):=g_package||'check_enrld_anthr_plip';
  l_inst_set         ben_rt_prfl_cache.g_enrld_anthr_plip_inst_tbl;
  l_inst_count       number;
  i    		     binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_date_to_use      date;
  l_dummy            varchar2(1);
  --
  cursor c1(p_plip_id in number) is
    select null
    from   ben_prtt_enrt_rslt_f pen
          ,ben_plip_f           cpp
    where  pen.business_group_id  = p_business_group_id
    and    pen.pgm_id = cpp.pgm_id
    and    pen.pl_id  = cpp.pl_id
    and    cpp.plip_id = p_plip_id
    and    l_date_to_use
           between cpp.effective_start_date
           and     cpp.effective_end_date
    and    cpp.business_group_id = pen.business_group_id
    and    pen.person_id = p_person_id
    and    l_date_to_use
           between pen.enrt_cvg_strt_dt
           and     pen.enrt_cvg_thru_dt
    and    pen.enrt_cvg_thru_dt <= pen.effective_end_date
    and    pen.prtt_enrt_rslt_stat_cd is null;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting variable profile compensation level by variable profile
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
     p_business_group_id => p_business_group_id,
     p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id,
     p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
     p_inst_set          => l_inst_set,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this variable profile id
    -- 2) If the plan id is the same then check if the person was covered
    --    the day before the life event.
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_rows_found := true;
      --
      --
      -- Apply the date logic to the life event occurred date.
      --
      ben_determine_date.main
        (p_date_cd        => l_inst_set(i).enrl_det_dt_cd,
         p_effective_date => p_effective_date,
         p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
         p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
         p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
         p_returned_date  => l_date_to_use);
      --
      open c1(l_inst_set(i).plip_id);
      fetch c1 into l_dummy;
      --
      if c1%found then
        --
        close c1;
        --
        if l_inst_set(i).excld_flag = 'N' then
          l_ok := true;
          exit;
        end if;
        --
        if l_inst_set(i).excld_flag = 'Y' then
          l_ok := false;
          exit;
        end if;
        --
      else
        --
        close c1;
        if l_inst_set(i).excld_flag = 'Y' then
          l_ok := true;
          -- exit;
        end if;
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_enrld_anthr_plip;


--
-- --------------------------------------------------------------------------
--  ENROLLED IN ANOTHER PROGRAM.
-- --------------------------------------------------------------------------
--
procedure check_enrld_anthr_pgm
  (
   p_vrbl_rt_prfl_id   in number
  ,p_business_group_id in number
  ,p_pgm_id            in number
  ,p_person_id         in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date )
is
  --
  l_proc             varchar2(100):=g_package||'check_enrld_anthr_pgm';
  l_inst_set         ben_rt_prfl_cache.g_enrld_anthr_pgm_inst_tbl;
  l_inst_count       number;
  i    		     binary_integer;
  l_ok               boolean := false;
  l_rows_found       boolean := false;
  l_found_pgm        boolean := false;
  l_date_to_use      date;
  l_dummy            varchar2(1);
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  hr_utility.set_location('prfl_id: '||p_vrbl_rt_prfl_id, 10);
  --
  -- Getting variable profile compensation level
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
     p_business_group_id => p_business_group_id,
     p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id,
     p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
     p_inst_set          => l_inst_set,
     p_inst_count        => l_inst_count);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this variable profile id
    -- 2) If the plan id is the same then check if the person was covered
    --    the day before the life event.
    --
    <<prfl>>
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_rows_found := true;
      --
      <<rslt>>
      for l_count in nvl(ben_manage_life_events.g_cache_person_prtn.first,0)..
                     nvl(ben_manage_life_events.g_cache_person_prtn.last,-1) loop
        if ben_manage_life_events.g_cache_person_prtn(l_count).pgm_id =
             l_inst_set(i).pgm_id then
           l_found_pgm := true;
          --
          -- Apply the date logic to the life event occurred date.
          --
          ben_determine_date.main
            (p_date_cd        => l_inst_set(i).enrl_det_dt_cd,
             p_effective_date => p_effective_date,
             p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt,
             p_fonm_cvg_strt_dt  => ben_manage_life_events.g_fonm_cvg_strt_dt,
             p_fonm_rt_strt_dt  => ben_manage_life_events.g_fonm_rt_strt_dt,
             p_returned_date  => l_date_to_use);
          --
          if (l_date_to_use
             between ben_manage_life_events.g_cache_person_prtn(l_count).enrt_cvg_strt_dt
             and ben_manage_life_events.g_cache_person_prtn(l_count).enrt_cvg_thru_dt) then
            --
            if l_inst_set(i).excld_flag = 'N'then
              --
              l_ok := true;
              exit prfl;
              --
            end if;
            --
            if l_inst_set(i).excld_flag = 'Y'then
              --
              l_ok := false;
              exit prfl;
              --
            end if;
            --
          end if;
          --
        end if;
        --
      end loop rslt;
        --
        --  If person is not enrolled in the program and exclude flag = "Y"
        --  person is eligible.
        --
        if (l_found_pgm = false
            and l_inst_set(i).excld_flag = 'Y') then
          --
          l_ok := true;
          exit;
          --
        end if;

      --
    end loop prfl;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_enrld_anthr_pgm;

--
-- --------------------------------------------------------------------------
--  DEPENDENT OTHER PLAN TYPE IN PROGRAM
-- --------------------------------------------------------------------------
--
procedure check_dpnt_othr_ptip
  (p_vrbl_rt_prfl_id   in number
  ,p_business_group_id in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_person_id         in number
  ,p_per_in_ler_id     in number
  )
is
  --
  l_proc varchar2(100):=g_package||'check_dpnt_other_ptip';
  --
  l_inst_set                    ben_rt_prfl_cache.g_dpnt_othr_ptip_inst_tbl;
  l_inst_count                  number;
  i               		binary_integer;
  l_ok                          boolean := false;
  l_rows_found                  boolean := false;
  l_dummy                       varchar2(1);
  l_pl_rec                      ben_comp_object.g_cache_pl_rec_table;
  --
  cursor c1
    (c_ptip_id        in number
    ,c_bgp_id         in number
    ,c_eff_date       in date
    ,c_dpnt_person_id in number
    )
  is
    select null
    from   ben_pl_f pln,
           ben_plip_f cpp,
           ben_ptip_f ctp,
           ben_elig_per_f epo,
           ben_elig_dpnt  edp,
           ben_per_in_ler pil
    where  pln.pl_id = cpp.pl_id
    and    pln.business_group_id = c_bgp_id
    and    c_eff_date
      between pln.effective_start_date and pln.effective_end_date
    and    cpp.business_group_id  = pln.business_group_id
    and    c_eff_date
      between cpp.effective_start_date and cpp.effective_end_date
    and    cpp.pgm_id = ctp.pgm_id
    and    pln.pl_typ_id = ctp.pl_typ_id
    and    ctp.ptip_id   = c_ptip_id
    and    ctp.business_group_id = pln.business_group_id
    and    c_eff_date
      between ctp.effective_start_date and ctp.effective_end_date
    and    edp.dpnt_person_id = c_dpnt_person_id
    and    epo.pgm_id = ctp.pgm_id
    and    epo.pl_id = pln.pl_id
    and    epo.business_group_id  = c_bgp_id
    and    c_eff_date
      between epo.effective_start_date and epo.effective_end_date
    and    epo.elig_flag = 'Y'
    and    edp.dpnt_inelig_flag = 'N'
    and    edp.create_dt = (select max(edp2.create_dt)
                            from ben_elig_dpnt edp2
                                ,ben_per_in_ler pil2
                            where edp2.dpnt_person_id = edp.dpnt_person_id
                            and edp2.elig_per_id = epo.elig_per_id
                            and pil2.per_in_ler_id(+)=edp2.per_in_ler_id
                            and pil2.business_group_id(+)=edp2.business_group_id
                            and (pil2.per_in_ler_stat_cd
                                   not in ('VOIDD','BCKDT')
                                 or pil2.per_in_ler_stat_cd is null))
    and    epo.elig_per_id = edp.elig_per_id
    and    pil.per_in_ler_id(+)=edp.per_in_ler_id
    and    (pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     or    pil.per_in_ler_stat_cd is null
           )
    and    epo.per_in_ler_id = edp.per_in_ler_id
    and    c_eff_date
      between epo.effective_start_date and epo.effective_end_date;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Getting variable profile compensation level by variable profile
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
     p_business_group_id => p_business_group_id,
     p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id,
     p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
     p_inst_set          => l_inst_set,
     p_inst_count        => l_inst_count);


  --
  hr_utility.set_location('l_inst_count: '||l_inst_count, 10);
  --
  if l_inst_count > 0 then
    --
    -- Operation
    -- =========
    -- 1) Grab all profiles for this variable profile
    -- 2) Look only at profiles for this PTIP_ID
    -- 3) if program is not null then, get all the ptip and check if
    --
    -- 4) Derive set of plans for the pgm that the ptip refers to
    -- 5) If person eligible for any of the plans and exclude flag = 'Y'
    --    then no problem.
    -- 6) If person eligible for any of the plans and exclude flag = 'N'
    --    then fail criteria.
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_rows_found := true;
      --
      -- Removed the nvls to resolve execute waiting problems for
      --
      open c1
        (c_ptip_id        => l_inst_set(i).ptip_id
        ,c_bgp_id         => p_business_group_id
        ,c_eff_date       => nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                              nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                nvl(p_lf_evt_ocrd_dt,p_effective_date)))
        ,c_dpnt_person_id => p_person_id
        );
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        if l_inst_set(i).excld_flag = 'N' then
          --
          l_ok := true;
          exit;
          --
        end if;
        --
        if l_inst_set(i).excld_flag = 'Y' then
          --
          l_ok := false;
          exit;
          --
        end if;
        --
      else
        --
        close c1;
        if l_inst_set(i).excld_flag = 'Y' then
          --
          l_ok := true;
          -- exit ;
          --
        end if;
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and
    not l_ok then
    --
    raise g_criteria_failed;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,20);
  --
end check_dpnt_othr_ptip;


-- --------------------------------------------------
--  NO OTHER COVERAGE
-- --------------------------------------------------
procedure check_no_othr_cvg(p_vrbl_rt_prfl_id    in number,
				   p_business_group_id in number,
                                   p_person_id         in number,
                                   p_effective_date    in date,
                                   p_lf_evt_ocrd_dt    in date) is
  --
  l_proc       	varchar2(100) := g_package||'check_no_othr_cvg';
  l_inst_set 	ben_rt_prfl_cache.g_no_othr_cvg_inst_tbl;
  l_inst_count 	number;
  l_ok 		boolean := false;
  l_rows_found 	boolean := false;
  l_dummy       varchar2(1);
  l_rec         per_all_people_f%rowtype;
  --


begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);

  --
  if l_inst_count > 0 then
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_rec);
    --
    for i in l_inst_set.first..l_inst_set.last loop
      --
      l_rows_found := true;
      l_ok := nvl((nvl(l_rec.coord_ben_no_cvg_flag,'N') =
                  l_inst_set(i).coord_ben_no_cvg_flag),FALSE);
      --
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
      --
      raise g_criteria_failed;
      --
  end if;
  --
end check_no_othr_cvg;

-- --------------------------------------------------
--  POSITION
-- --------------------------------------------------
procedure check_pstn(p_vrbl_rt_prfl_id   in number,
		     p_business_group_id in number,
                     p_asg_position_id   in number,
                     p_effective_date	 in date,
                     p_lf_evt_ocrd_dt	 in date) is
  --
  l_proc       	varchar2(100) := g_package||'check_pstn';
  l_inst_set 	ben_rt_prfl_cache.g_pstn_inst_tbl;
  l_inst_count 	number;
  l_ok 		boolean := false;
  l_rows_found 	boolean := false;
  l_dummy       varchar2(1);
  l_rec         per_all_people_f%rowtype;
  --


begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);

  --
  if l_inst_count > 0 then

    for i in l_inst_set.first..l_inst_set.last loop
          --
          l_ok := nvl((nvl(p_asg_position_id,'-1') = l_inst_set(i).position_id),FALSE);
          --
          if l_ok and l_inst_set(i).excld_flag = 'N' then
            --
            exit;
            --
          elsif l_ok and l_inst_set(i).excld_flag = 'Y' then
            --
            l_rows_found := true;
            l_ok := false;
            exit;
            --
          elsif (not l_ok) and l_inst_set(i).excld_flag = 'Y' then
            --
            l_rows_found := true;
            l_ok := true;
            --
          elsif l_inst_set(i).excld_flag = 'N' then
            --
            l_rows_found := true;
            --
          end if;
          --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
      --
      raise g_criteria_failed;
      --
  end if;
  --
end check_pstn;

-- --------------------------------------------------
--  COMPETENCE
-- --------------------------------------------------
procedure check_comptncy(p_vrbl_rt_prfl_id   in number,
		     p_business_group_id in number,
                     p_person_id   	 in number,
                     p_effective_date	 date,
                     p_lf_evt_ocrd_dt	 date) is
  --
  l_proc       	varchar2(100) := g_package||'check_comptncy';
  l_inst_set 	ben_rt_prfl_cache.g_comptncy_inst_tbl;
  l_inst_count 	number;
  l_ok 		boolean := false;
  l_rows_found 	boolean := false;
  l_dummy       varchar2(1);
  --

  cursor c1(p_person_id number
  	    ,p_competence_id number
  	    ,p_rating_level_id number
  	    ,p_lf_evt_ocrd_dt	 date) is
  select null
  from   per_competence_elements pce
  where  pce.person_id = p_person_id
  and	 type = 'PERSONAL'
  and 	 pce.competence_id  = p_competence_id
  and    pce.proficiency_level_id = p_rating_level_id
  and    p_lf_evt_ocrd_dt between nvl(pce.effective_date_from, p_lf_evt_ocrd_dt)
  	 and nvl(pce.effective_date_to, p_lf_evt_ocrd_dt)
  and    pce.business_group_id = p_business_group_id ;

begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);

  --
  if l_inst_count > 0 then

    for i in l_inst_set.first..l_inst_set.last loop
 	      l_rows_found := true;
 	      --
 	      open c1(p_person_id
 	             ,l_inst_set(i).competence_id
 		     ,l_inst_set(i).rating_level_id
 		     ,nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                       nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                         nvl(p_lf_evt_ocrd_dt, p_effective_date))) );
 	      fetch c1 into l_dummy;
	      if c1%found then
		--
		close c1;
		--
		if l_inst_set(i).excld_flag = 'N' then
		  l_ok := true;
		  exit;
		end if;
		--
		if l_inst_set(i).excld_flag = 'Y' then
		  l_ok := false;
		  exit;
		end if;
		--
	      else
		--
		close c1;
		if l_inst_set(i).excld_flag = 'Y' then
		  l_ok := true;
		  -- exit;
		end if;
	      end if;
          --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
      --
      raise g_criteria_failed;
      --
  end if;
  --
end check_comptncy;



-- --------------------------------------------------
--  QUALIFICATION TITLE
-- --------------------------------------------------
procedure check_qual_titl(p_vrbl_rt_prfl_id   in number,
		     p_business_group_id in number,
                     p_person_id   	 in number,
                     p_effective_date	 date,
                     p_lf_evt_ocrd_dt	 date) is
  --
  l_proc       	varchar2(100) := g_package||'check_qual_titl';
  l_inst_set 	ben_rt_prfl_cache.g_qual_titl_inst_tbl;
  l_inst_count 	number;
  l_ok 		boolean := false;
  l_rows_found 	boolean := false;
  l_dummy       varchar2(1);
  --

  cursor c1(p_person_id number
  	    ,p_qualification_type_id number
  	    ,p_title 		     varchar2
  	    ,p_lf_evt_ocrd_dt	     date) is
  select null
  from   per_qualifications pqt
  where  pqt.person_id = p_person_id
  and 	 pqt.qualification_type_id  = p_qualification_type_id
  and    nvl(pqt.title,'NULL' ) = NVL(p_title , 'NULL')
  and    p_lf_evt_ocrd_dt between nvl(pqt.start_date , p_lf_evt_ocrd_dt)
  	 and nvl(pqt.end_date ,p_lf_evt_ocrd_dt)
  and    pqt.business_group_id = p_business_group_id ;

begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);

  --
  if l_inst_count > 0 then

    for i in l_inst_set.first..l_inst_set.last loop
 	      l_rows_found := true;
 	      --
 	      open c1(p_person_id
 	             ,l_inst_set(i).qualification_type_id
 		     ,l_inst_set(i).title
 		     ,nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                       nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                         nvl(p_lf_evt_ocrd_dt, p_effective_date))));
 	      fetch c1 into l_dummy;
	      if c1%found then
		--
		close c1;
		--
		if l_inst_set(i).excld_flag = 'N' then
		  l_ok := true;
		  exit;
		end if;
		--
		if l_inst_set(i).excld_flag = 'Y' then
		  l_ok := false;
		  exit;
		end if;
		--
	      else
		--
		close c1;
		if l_inst_set(i).excld_flag = 'Y' then
		  l_ok := true;
		  -- exit;
		end if;
	      end if;
          --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
      --
      raise g_criteria_failed;
      --
  end if;
  --
end check_qual_titl;


--
-- ---------------------------------------------------------------
--    ttl_cvg check
-- ---------------------------------------------------------------
--
procedure check_ttl_cvg
  (p_vrbl_rt_prfl_id      in number
  ,p_business_group_id    in number
  ,p_effective_date       in date
  ,p_lf_evt_ocrd_dt       in date
  ,p_ttl_cvg              in number default null)
is
  --
  l_proc          varchar2(80) := g_package||'.check_ttl_cvg';
  l_inst_set      ben_rt_prfl_cache.g_ttl_cvg_inst_tbl;
  l_inst_count    number;
  l_profile_match varchar2(1);
  --
begin
  hr_utility.set_location ('check_ttl_cvg:'||to_char(p_ttl_cvg),10);

  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);


  l_profile_match := 'N';
  if l_inst_count > 0 then
    if p_ttl_cvg is null then
        -- there are variable profile criteria for total coverage attached, but
        -- the process did not pass in a coverage volumn amount.
        fnd_message.set_name('BEN','BEN_92245_TTL_CVG_REQUIRED');
        fnd_message.set_token('L_PROC',l_proc);
        fnd_message.set_token('VRBL_RT_PRFL_ID',to_char(p_vrbl_rt_prfl_id));
        fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
        fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
        fnd_message.raise_error;
    end if;
    --
    -- Data found. Loop through to see we match the total amount of cvg.
    --
    for i in l_inst_set.first..l_inst_set.last loop
      hr_utility.set_location ('min:'||to_char(l_inst_set(i).mn_cvg_vol_amt)||
         ' max:'||to_char(l_inst_set(i).mx_cvg_vol_amt),14);
      if p_ttl_cvg between nvl(l_inst_set(i).mn_cvg_vol_amt,0)
         and nvl(l_inst_set(i).mx_cvg_vol_amt,999999999999999) then
        -- we match one of the ranges, exit with success.
        l_profile_match := 'Y';
        exit;
      end if;
    end loop;

    if l_profile_match = 'N' then
      raise ben_evaluate_rate_profiles.g_profile_failed;
    end if;

  end if;
end check_ttl_cvg;


-- --------------------------------------------------
--  Quartile in Grade
-- --------------------------------------------------
procedure check_qua_in_gr(p_vrbl_rt_prfl_id   in number,
		     p_business_group_id in number,
                     p_person_id   	 in number,
                     p_grade_id		 in number,
                     p_assignment_id     in number,
                     p_effective_date	 date,
                     p_lf_evt_ocrd_dt	 date,
                     p_pay_basis_id	 in number) is
  --
  l_proc       	varchar2(100) := g_package||'check_qua_in_gr';
  l_inst_set 	ben_rt_prfl_cache.g_qua_in_gr_inst_tbl;
  l_inst_count 	number;
  l_ok 		boolean := false;
  l_rows_found 	boolean := false;
  l_max_val	number;
  l_min_val	number;
  l_max_qualifier  number;
  l_min_qualifier  number;
  l_in_quartile    boolean;
  l_person_sal	   number := 0;
  l_ann_fctr       number := 0;   /* Bug 4031314 */
  l_ann_sal        number := 0;   /* Bug 4031314 */
  l_quar_grad       VARCHAR2 (30);    --    added for bug: 4558945

  --

  cursor c1(p_grade_id 		 number
  	    ,p_business_group_id number
  	    ,p_lf_evt_ocrd_dt	 date
  	    ,p_pay_basis_id 	 number) is
  select (maximum * grade_annualization_factor) maximum ,
  	 (minimum * grade_annualization_factor) minimum
  from 	 pay_grade_rules_f pgr,
  	 per_pay_bases ppb                 -- 2594204
  where  ppb.pay_basis_id = p_pay_basis_id
  and    ppb.business_group_id = p_business_group_id
  and	 pgr.rate_id = ppb.rate_id
  and    pgr.business_group_id = p_business_group_id
  and    pgr.grade_or_spinal_point_id  = p_grade_id
  and 	 p_lf_evt_ocrd_dt between nvl(pgr.effective_start_date, p_lf_evt_ocrd_dt)
  and 	 nvl(pgr.effective_end_date, p_lf_evt_ocrd_dt);

  /*
  Bug 4031314 : We need
                (1) Pay Annualization Factor of Salary Basis
                (2) Person's Approved Pay Proposal
                Splitting the following cursor :

  cursor c2(p_assignment_id 	 number
  	    ,p_business_group_id number
  	    ,p_lf_evt_ocrd_dt	 date
  	    ,p_pay_basis_id      number) is
  select ppp.proposed_salary_n * ppb.pay_annualization_factor annual_salary
  from   per_pay_bases  	ppb,
	 per_pay_proposals ppp
  where  ppb.pay_basis_id = p_pay_basis_id
  and    ppb.business_group_id = p_business_group_id
  and    ppp.assignment_id = p_assignment_id
  and    ppp.change_date <= p_lf_evt_ocrd_dt
  order by ppp.change_date desc ;
  */

  cursor c_salary ( p_assignment_id 	 number
  	           ,p_business_group_id  number
  	           ,p_lf_evt_ocrd_dt	 date
                   ) is
       select ppp.proposed_salary_n
         from per_pay_proposals ppp
        where ppp.assignment_id = p_assignment_id
          and ppp.business_group_id = p_business_group_id
          and ppp.approved = 'Y'
          and ppp.change_date <= p_lf_evt_ocrd_dt
     order by ppp.change_date desc;
  --
  cursor c_pay_bas_ann_fctr ( p_pay_basis_id number
                             ,p_business_group_id number
                            ) is
      select ppb.pay_annualization_factor
        from per_pay_bases ppb
       where ppb.pay_basis_id = p_pay_basis_id
         and ppb.business_group_id = ppb.business_group_id;
  --
  procedure get_quartile(p_min 	IN number default 0
  		     	,p_max 	IN number default 0
  		     	,p_code IN  varchar2
  		     	,p_min_qualifier OUT NOCOPY number
  		     	,p_max_qualifier OUT NOCOPY number
  		     )
  is
  l_divisor 		number := 4;
  l_addition_factor  	number;
  l_multiplication_factor number;
  BEGIN
  	IF p_code not in ('ABV' , 'BLW' , 'NA') then
  		l_multiplication_factor := to_number(p_code);
  		l_addition_factor := (p_max - p_min)/l_divisor;
  		p_min_qualifier := p_max - l_addition_factor * (l_multiplication_factor )  ;
  		p_max_qualifier := p_max - l_addition_factor * (l_multiplication_factor - 1 ) ;
  		if l_multiplication_factor <> 4 THEN
  			p_min_qualifier :=  p_min_qualifier + 1;
  		end if;
  	END IF;
  END;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);

  --
  if l_inst_count > 0 then
    open c1(p_grade_id
     	    ,p_business_group_id
     	    ,nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                       nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                         nvl(p_lf_evt_ocrd_dt, p_effective_date)))
     	    ,p_pay_basis_id);
    fetch c1 into l_max_val, l_min_val;
    close c1;
    /* Bug 4031314
    open c2(p_assignment_id
  	    ,p_business_group_id
  	    ,nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                       nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                         nvl(p_lf_evt_ocrd_dt, p_effective_date)))
  	    ,p_pay_basis_id) ;
    fetch c2 into l_person_sal;
    close c2;
    */
    open c_salary ( p_assignment_id     => p_assignment_id,
                    p_business_group_id => p_business_group_id,
                    p_lf_evt_ocrd_dt    => nvl( ben_manage_life_events.g_fonm_rt_strt_dt,
                                                    nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                                           nvl(p_lf_evt_ocrd_dt, p_effective_date
                                                              )
                                                        )
                                               )
                  );
      fetch c_salary into l_person_sal;
    close c_salary;
    --
    open c_pay_bas_ann_fctr ( p_pay_basis_id      => p_pay_basis_id,
                              p_business_group_id => p_business_group_id );
      fetch c_pay_bas_ann_fctr into l_ann_fctr;
    close c_pay_bas_ann_fctr;
    --
    l_ann_sal := l_person_sal * l_ann_fctr;
    --
      -- added for bug: 4558945
      l_quar_grad :=
      ben_cwb_person_info_pkg.get_grd_quartile (p_salary      => l_ann_sal,
						p_min         => NVL(l_min_val,0),
						p_max         => NVL(l_max_val,0),
                                                p_mid         => (NVL(l_min_val,0)+ NVL(l_max_val,0))/ 2
						);

    for i in l_inst_set.first..l_inst_set.last loop
        l_rows_found := true;
        --
	/*
	-- commented for bug: 4558945
	get_quartile(p_min  	    => nvl(l_min_val,0)
		   ,p_max 	    => nvl(l_max_val,0)
		   ,p_code 	    => l_inst_set(i).quar_in_grade_cd
		   ,p_min_qualifier => l_min_qualifier
		   ,p_max_qualifier => l_max_qualifier );

	--
	IF l_inst_set(i).quar_in_grade_cd  = 'ABV' THEN
	   l_in_quartile := l_ann_sal > nvl(l_max_val,0);
	ELSIF l_inst_set(i).quar_in_grade_cd  = 'BLW' THEN
	   l_in_quartile := l_ann_sal < nvl(l_min_val,0);
	ELSE
	   l_in_quartile := l_ann_sal between l_min_qualifier and l_max_qualifier;
	END IF;
	*/
	--

	-- if l_inst_set(i).excld_flag = 'N' and l_in_quartile then
	-- commented for bug: 4558945
        IF   l_inst_set (i).excld_flag = 'N' AND l_inst_set (i).quar_in_grade_cd = l_quar_grad then
	  l_ok := true;
	  exit;
	-- elsif l_inst_set(i).excld_flag = 'N' and not l_in_quartile then
	-- commented for bug: 4558945
	ELSIF     l_inst_set (i).excld_flag = 'N' AND l_inst_set (i).quar_in_grade_cd <> l_quar_grad then
	  l_ok := false;
	-- elsif l_inst_set(i).excld_flag = 'Y' and not l_in_quartile then
	-- commented for bug: 4558945
        ELSIF     l_inst_set (i).excld_flag = 'Y' AND l_inst_set (i).quar_in_grade_cd <> l_quar_grad then
	  l_ok := true;
	  -- exit;
	-- elsif l_inst_set(i).excld_flag = 'Y' and l_in_quartile then
	-- commented for bug: 4558945
         ELSIF     l_inst_set (i).excld_flag = 'Y' AND l_inst_set (i).quar_in_grade_cd = l_quar_grad then

	  l_ok := false;
	  exit;
	end if;
          --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
      --
      raise g_criteria_failed;
      --
  end if;
  --
end check_qua_in_gr;
--

-- --------------------------------------------------
--  Performance Rating
-- --------------------------------------------------
procedure check_perf_rtng(p_vrbl_rt_prfl_id   in number,
		     p_business_group_id in number,
                     p_assignment_id   	 in number,
                     p_person_id   	 in number,
                     p_effective_date	 date,
                     p_lf_evt_ocrd_dt	 date) is
  --
  l_proc       	varchar2(100) := g_package||'check_perf_rtng';
  l_inst_set 	ben_rt_prfl_cache.g_perf_rtng_inst_tbl;
  l_inst_count 	number;
  l_ok 		boolean := false;
  l_rows_found 	boolean := false;
  l_dummy       varchar2(1);
  l_performance_rating      varchar2(80);
  --
  CURSOR c1 (
     p_person_id            NUMBER,
     p_event_type           VARCHAR2,
     p_business_group_id    NUMBER,
     p_assignment_id        NUMBER,
     p_lf_evt_ocrd_dt       DATE
  )
  IS
     SELECT ppr.performance_rating
       FROM per_performance_reviews ppr, per_events pev
      WHERE pev.assignment_id = p_assignment_id
        AND pev.TYPE = p_event_type
        AND pev.business_group_id = p_business_group_id
        AND p_lf_evt_ocrd_dt BETWEEN NVL (date_start, p_lf_evt_ocrd_dt)
                                 AND NVL (date_end, p_lf_evt_ocrd_dt)
        AND ppr.event_id = pev.event_id
        AND ppr.person_id = p_person_id
     -- AND ppr.performance_rating = p_performance_rating
   ORDER BY pev.date_start desc, ppr.review_date desc;
  --
  /* Bug 4031314
   * If ELPRO criteria does not specify Performance Type then we would select
   * only those performance reviews which do have Performance (Interview) Type
   * as NULL i.e PPR.EVENT_ID IS NULL
   */
  CURSOR c2_without_events (
     p_person_id            NUMBER,
     p_effective_date       DATE
  )
  IS
     SELECT ppr.performance_rating
       FROM per_performance_reviews ppr
      WHERE ppr.person_id = p_person_id
     -- AND ppr.performance_rating = p_performance_rating
        AND ppr.review_date <= p_effective_date
        AND ppr.event_id IS NULL
   ORDER BY ppr.review_date desc;
  --

begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Get the data from the cache.
  --
  ben_rt_prfl_cache.get_rt_prfl_cache
    (p_vrbl_rt_prfl_id   => p_vrbl_rt_prfl_id
    ,p_effective_date    => p_effective_date
    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
    ,p_business_group_id => p_business_group_id
    ,p_inst_set          => l_inst_set
    ,p_inst_count        => l_inst_count);

  --
  if l_inst_count > 0 then

    for i in l_inst_set.first..l_inst_set.last
    loop
      --
      l_rows_found := true;
      --
      /* Bug 4031314
       * - When BEN_ELIG_PERF_RTNG_PRTE_F.EVENT_TYPE = '-1', then fetch performance reviews
       *   that have Performance (Interview) Type as NULL.
       * - When BEN_ELIG_PERF_RTNG_PRTE_F.EVENT_TYPE is not '-1', then fetch performanc reviews
       *   with Performance Type as defined in ELPRO criteria
       */
      if l_inst_set (i).event_type = '-1'
      then
        --
        OPEN c2_without_events (
                 p_person_id               => p_person_id,
                 p_effective_date          => NVL (ben_manage_life_events.g_fonm_rt_strt_dt,
                                                   NVL (ben_manage_life_events.g_fonm_cvg_strt_dt,
                                                        NVL (p_lf_evt_ocrd_dt,
                                                             p_effective_date
                                                            )
                                                       )
                                                  )
          );
          --
          fetch c2_without_events into l_performance_rating;
          --
          if c2_without_events%found and l_performance_rating = l_inst_set (i).perf_rtng_cd
          then
            --
            close c2_without_events;
            --
            if l_inst_set(i).excld_flag = 'N' then
              l_ok := true;
              exit;
            end if;
            --
            if l_inst_set(i).excld_flag = 'Y' then
              l_ok := false;
              exit;
            end if;
            --
          else
            --
            close c2_without_events;
            if l_inst_set(i).excld_flag = 'Y' then
              l_ok := true;
              -- exit;
            end if;
            --
          end if;
          --
        --
      else
        --
        OPEN c1 (p_person_id               => p_person_id,
                 p_event_type              => l_inst_set (i).event_type,
                 p_business_group_id       => p_business_group_id,
                 p_assignment_id           => p_assignment_id,
                 p_lf_evt_ocrd_dt          => NVL (ben_manage_life_events.g_fonm_rt_strt_dt,
                                                   NVL (ben_manage_life_events.g_fonm_cvg_strt_dt,
                                                        NVL (p_lf_evt_ocrd_dt,
                                                             p_effective_date
                                                            )
                                                       )
                                                  )
                );
          --
          fetch c1 into l_performance_rating;
          --
          if c1%found and l_performance_rating = l_inst_set (i).perf_rtng_cd
          then
            --
            close c1;
            --
            if l_inst_set(i).excld_flag = 'N' then
              l_ok := true;
              exit;
            end if;
            --
            if l_inst_set(i).excld_flag = 'Y' then
              l_ok := false;
              exit;
            end if;
            --
          else
            --
            close c1;
            if l_inst_set(i).excld_flag = 'Y' then
              l_ok := true;
              -- exit;
            end if;
            --
          end if;
          --
      end if;
      --
    end loop;
    --
  end if;
  --
  if l_rows_found and not l_ok then
      --
      raise g_criteria_failed;
      --
  end if;
  --
end check_perf_rtng;


-- ---------------------------------------------------------------------------
-- init_globals
-- ---------------------------------------------------------------------------
procedure init_globals is
begin
  ben_evaluate_rate_profiles.g_no_match_cnt         := 0 ;
  ben_evaluate_rate_profiles.g_no_match_cvg         := 0 ;
  ben_evaluate_rate_profiles.g_all_prfls.delete;

  ben_evaluate_rate_profiles.g_num_of_prfls_used := 0 ;
  ben_evaluate_rate_profiles.g_use_prfls.delete;

end init_globals;
-- ---------------------------------------------------------------------------
-- load_globals
-- ---------------------------------------------------------------------------
procedure load_globals
         (p_all_prfls               in boolean default false,
          p_use_prfls               in boolean default false,
          p_bnft_amt                in number  default null,
          p_vrbl_rt_prfl_id         in number,
          p_ordr_num                in number,
          p_asmt_to_use_cd             in varchar,
          p_rt_hrly_slrd_flag          in varchar,
          p_rt_pstl_cd_flag            in varchar,
          p_rt_lbr_mmbr_flag           in varchar,
          p_rt_lgl_enty_flag           in varchar,
          p_rt_benfts_grp_flag         in varchar,
          p_rt_wk_loc_flag             in varchar,
          p_rt_brgng_unit_flag         in varchar,
          p_rt_age_flag                in varchar,
          p_rt_los_flag                in varchar,
          p_rt_per_typ_flag            in varchar,
          p_rt_fl_tm_pt_tm_flag        in varchar,
          p_rt_ee_stat_flag            in varchar,
          p_rt_grd_flag                in varchar,
          p_rt_pct_fl_tm_flag          in varchar,
          p_rt_asnt_set_flag           in varchar,
          p_rt_hrs_wkd_flag            in varchar,
          p_rt_comp_lvl_flag           in varchar,
          p_rt_org_unit_flag           in varchar,
          p_rt_loa_rsn_flag            in varchar,
          p_rt_pyrl_flag               in varchar,
          p_rt_schedd_hrs_flag         in varchar,
          p_rt_py_bss_flag             in varchar,
          p_rt_prfl_rl_flag            in varchar,
          p_rt_cmbn_age_los_flag       in varchar,
          p_rt_prtt_pl_flag            in varchar,
          p_rt_svc_area_flag           in varchar,
          p_rt_ppl_grp_flag            in varchar,
          p_rt_dsbld_flag              in varchar,
          p_rt_hlth_cvg_flag           in varchar,
          p_rt_poe_flag                in varchar,
          p_rt_ttl_cvg_vol_flag        in varchar,
          p_rt_ttl_prtt_flag           in varchar,
          p_rt_gndr_flag               in varchar,
          p_rt_tbco_use_flag           in varchar,
          p_rt_cntng_prtn_prfl_flag     in varchar,
          p_rt_cbr_quald_bnf_flag	in varchar,
          p_rt_optd_mdcr_flag		in varchar,
          p_rt_lvg_rsn_flag 		in varchar,
          p_rt_pstn_flag 		in varchar,
          p_rt_comptncy_flag 		in varchar,
          p_rt_job_flag 		in varchar,
          p_rt_qual_titl_flag 		in varchar,
          p_rt_dpnt_cvrd_pl_flag	in varchar,
          p_rt_dpnt_cvrd_plip_flag	in varchar,
          p_rt_dpnt_cvrd_ptip_flag	in varchar,
          p_rt_dpnt_cvrd_pgm_flag	in varchar,
          p_rt_enrld_oipl_flag		in varchar,
          p_rt_enrld_pl_flag		in varchar,
          p_rt_enrld_plip_flag		in varchar,
          p_rt_enrld_ptip_flag		in varchar,
          p_rt_enrld_pgm_flag		in varchar,
          p_rt_prtt_anthr_pl_flag	in varchar,
          p_rt_othr_ptip_flag		in varchar,
          p_rt_no_othr_cvg_flag		in varchar,
          p_rt_dpnt_othr_ptip_flag	in varchar,
          p_rt_qua_in_gr_flag	  	in varchar,
          p_rt_perf_rtng_flag		in varchar,
          p_rt_elig_prfl_flag           in varchar2
          )  is

  l_package           varchar2(80) := g_package||'.load_globals';
  l_insert_record     varchar2(1);
  l_ctr               number;
begin
--  hr_utility.set_location ('Entering '||l_package,10);

  if p_all_prfls then
     -- load the 'all prfls' globals.  These globals use the actl_prem_vrbl_rt.ordr_num
     -- as it's index, because the second time we loop thru them, we need them in
     -- that order.

           l_insert_record := 'Y';
           if g_all_prfls.count > 0 then
             -- it's not the first, loop thru the table to see if we've already
             -- matched this profile for a person.
             l_ctr := g_all_prfls.first;
             loop
                 if g_all_prfls(l_ctr).vrbl_rt_prfl_id = p_vrbl_rt_prfl_id then
                    g_all_prfls(l_ctr).match_cnt := g_all_prfls(l_ctr).match_cnt+1;
                    g_all_prfls(l_ctr).match_cvg := g_all_prfls(l_ctr).match_cvg+p_bnft_amt;
                    l_insert_record := 'N';
                    hr_utility.set_location ('added to profile:'||
                               to_char(p_vrbl_rt_prfl_id)||
                               ' new num:'||to_char(g_all_prfls(l_ctr).match_cnt)||
                               ' new cvg:'||to_char(g_all_prfls(l_ctr).match_cvg),16);

                    exit;
                 end if;
                 if l_ctr = g_all_prfls.last then
                    exit;
                 else
                    l_ctr := g_all_prfls.next(l_ctr);
                 end if;
             end loop;
           end if;

           if l_insert_record = 'Y' then
                -- We didn't find a match in the table, add a row to table.
                -- increase the total number of profiles matched
                g_all_prfls(p_ordr_num).vrbl_rt_prfl_id :=
                             p_vrbl_rt_prfl_id;
                g_all_prfls(p_ordr_num).match_cnt       := 1;
                g_all_prfls(p_ordr_num).match_cvg := p_bnft_amt;
                hr_utility.set_location ('added new profile '||
                    to_char(p_vrbl_rt_prfl_id)||
                    ' cvg:'||to_char(p_bnft_amt)||
                    ' p_ordr_num:'||to_char(p_ordr_num),18);

                g_all_prfls(p_ordr_num).asmt_to_use_cd     := p_asmt_to_use_cd  ;
                g_all_prfls(p_ordr_num).rt_hrly_slrd_flag  := p_rt_hrly_slrd_flag  ;
                g_all_prfls(p_ordr_num).rt_pstl_cd_flag    := p_rt_pstl_cd_flag  ;
                g_all_prfls(p_ordr_num).rt_lbr_mmbr_flag   := p_rt_lbr_mmbr_flag  ;
                g_all_prfls(p_ordr_num).rt_lgl_enty_flag   := p_rt_lgl_enty_flag  ;
                g_all_prfls(p_ordr_num).rt_benfts_grp_flag := p_rt_benfts_grp_flag  ;
                g_all_prfls(p_ordr_num).rt_wk_loc_flag     := p_rt_wk_loc_flag  ;
                g_all_prfls(p_ordr_num).rt_brgng_unit_flag := p_rt_brgng_unit_flag  ;
                g_all_prfls(p_ordr_num).rt_age_flag        := p_rt_age_flag  ;
                g_all_prfls(p_ordr_num).rt_los_flag        := p_rt_los_flag  ;
                g_all_prfls(p_ordr_num).rt_per_typ_flag    := p_rt_per_typ_flag  ;
                g_all_prfls(p_ordr_num).rt_fl_tm_pt_tm_flag:= p_rt_fl_tm_pt_tm_flag  ;
                g_all_prfls(p_ordr_num).rt_ee_stat_flag    := p_rt_ee_stat_flag  ;
                g_all_prfls(p_ordr_num).rt_grd_flag        := p_rt_grd_flag  ;
                g_all_prfls(p_ordr_num).rt_pct_fl_tm_flag  := p_rt_pct_fl_tm_flag  ;
                g_all_prfls(p_ordr_num).rt_asnt_set_flag   := p_rt_asnt_set_flag  ;
                g_all_prfls(p_ordr_num).rt_hrs_wkd_flag    := p_rt_hrs_wkd_flag  ;
                g_all_prfls(p_ordr_num).rt_comp_lvl_flag   := p_rt_comp_lvl_flag  ;
                g_all_prfls(p_ordr_num).rt_org_unit_flag   := p_rt_org_unit_flag  ;
                g_all_prfls(p_ordr_num).rt_loa_rsn_flag    := p_rt_loa_rsn_flag  ;
                g_all_prfls(p_ordr_num).rt_pyrl_flag       := p_rt_pyrl_flag  ;
                g_all_prfls(p_ordr_num).rt_schedd_hrs_flag := p_rt_schedd_hrs_flag  ;
                g_all_prfls(p_ordr_num).rt_py_bss_flag     := p_rt_py_bss_flag  ;
                g_all_prfls(p_ordr_num).rt_prfl_rl_flag    := p_rt_prfl_rl_flag  ;
                g_all_prfls(p_ordr_num).rt_cmbn_age_los_flag := p_rt_cmbn_age_los_flag ;
                g_all_prfls(p_ordr_num).rt_prtt_pl_flag    := p_rt_prtt_pl_flag  ;
                g_all_prfls(p_ordr_num).rt_svc_area_flag   := p_rt_svc_area_flag  ;
                g_all_prfls(p_ordr_num).rt_ppl_grp_flag    := p_rt_ppl_grp_flag  ;
                g_all_prfls(p_ordr_num).rt_dsbld_flag      := p_rt_dsbld_flag  ;
                g_all_prfls(p_ordr_num).rt_hlth_cvg_flag   := p_rt_hlth_cvg_flag  ;
                g_all_prfls(p_ordr_num).rt_poe_flag        := p_rt_poe_flag  ;
                g_all_prfls(p_ordr_num).rt_ttl_cvg_vol_flag:= p_rt_ttl_cvg_vol_flag  ;
                g_all_prfls(p_ordr_num).rt_ttl_prtt_flag   := p_rt_ttl_prtt_flag  ;
                g_all_prfls(p_ordr_num).rt_gndr_flag       := p_rt_gndr_flag  ;
                g_all_prfls(p_ordr_num).rt_tbco_use_flag   := p_rt_tbco_use_flag ;
                g_all_prfls(p_ordr_num).rt_cntng_prtn_prfl_flag := p_rt_cntng_prtn_prfl_flag ;
		g_all_prfls(p_ordr_num).rt_cbr_quald_bnf_flag   := p_rt_cbr_quald_bnf_flag;
		g_all_prfls(p_ordr_num).rt_optd_mdcr_flag   	:= p_rt_optd_mdcr_flag;
		g_all_prfls(p_ordr_num).rt_lvg_rsn_flag    	:= p_rt_lvg_rsn_flag ;
		g_all_prfls(p_ordr_num).rt_pstn_flag    	:= p_rt_pstn_flag ;
		g_all_prfls(p_ordr_num).rt_comptncy_flag    	:= p_rt_comptncy_flag ;
		g_all_prfls(p_ordr_num).rt_job_flag    		:= p_rt_job_flag ;
		g_all_prfls(p_ordr_num).rt_qual_titl_flag    	:= p_rt_qual_titl_flag ;
		g_all_prfls(p_ordr_num).rt_dpnt_cvrd_pl_flag   	:= p_rt_dpnt_cvrd_pl_flag;
		g_all_prfls(p_ordr_num).rt_dpnt_cvrd_plip_flag  := p_rt_dpnt_cvrd_plip_flag;
		g_all_prfls(p_ordr_num).rt_dpnt_cvrd_ptip_flag  := p_rt_dpnt_cvrd_ptip_flag;
		g_all_prfls(p_ordr_num).rt_dpnt_cvrd_pgm_flag   := p_rt_dpnt_cvrd_pgm_flag;
		g_all_prfls(p_ordr_num).rt_enrld_oipl_flag   	:= p_rt_enrld_oipl_flag;
		g_all_prfls(p_ordr_num).rt_enrld_pl_flag   	:= p_rt_enrld_pl_flag;
		g_all_prfls(p_ordr_num).rt_enrld_plip_flag   	:= p_rt_enrld_plip_flag;
		g_all_prfls(p_ordr_num).rt_enrld_ptip_flag   	:= p_rt_enrld_ptip_flag;
		g_all_prfls(p_ordr_num).rt_enrld_pgm_flag   	:= p_rt_enrld_pgm_flag;
		g_all_prfls(p_ordr_num).rt_prtt_anthr_pl_flag   := p_rt_prtt_anthr_pl_flag;
		g_all_prfls(p_ordr_num).rt_othr_ptip_flag   	:= p_rt_othr_ptip_flag;
		g_all_prfls(p_ordr_num).rt_no_othr_cvg_flag   	:= p_rt_no_othr_cvg_flag;
		g_all_prfls(p_ordr_num).rt_dpnt_othr_ptip_flag  := p_rt_dpnt_othr_ptip_flag;
		g_all_prfls(p_ordr_num).rt_qua_in_gr_flag   	:= p_rt_qua_in_gr_flag;
		g_all_prfls(p_ordr_num).rt_perf_rtng_flag  	:= p_rt_perf_rtng_flag;
		g_all_prfls(p_ordr_num).rt_elig_prfl_flag  	:= p_rt_elig_prfl_flag;

           end if;
  else
    -- load the 'use prfls' globals.  These can use a regular count for
    -- index number and avoid gaps.
          l_insert_record := 'Y';
          if g_num_of_prfls_used <> 0 then
             -- it's not the first, loop thru the table to see if we've already
             -- matched this profile for a person.
             for y in 1..g_num_of_prfls_used loop
                 if g_use_prfls(y).vrbl_rt_prfl_id = p_vrbl_rt_prfl_id then
                    g_use_prfls(y).match_cnt := g_use_prfls(y).match_cnt+1;
                    g_use_prfls(y).match_cvg := g_use_prfls(y).match_cvg+p_bnft_amt;
                    l_insert_record := 'N';
                    hr_utility.set_location ('added to profile:'||
                               to_char(p_vrbl_rt_prfl_id)||
                               ' new num:'||to_char(g_use_prfls(y).match_cnt)||
                               ' new cvg:'||to_char(g_use_prfls(y).match_cvg),26);
                    exit;
                 end if;
             end loop;
          end if;
          if l_insert_record = 'Y' then
                -- We didn't find a match in the table, add a row to table.
                -- increase the total number of profiles matched
                g_num_of_prfls_used := g_num_of_prfls_used + 1;
                g_use_prfls(g_num_of_prfls_used).vrbl_rt_prfl_id :=
                             p_vrbl_rt_prfl_id;
                g_use_prfls(g_num_of_prfls_used).match_cnt       := 1;
                g_use_prfls(g_num_of_prfls_used).match_cvg := p_bnft_amt;
                hr_utility.set_location ('added new profile '||
                    to_char(p_vrbl_rt_prfl_id)||
                    ' cvg:'||to_char(p_bnft_amt),28);
          end if;
  end if;
--  hr_utility.set_location ('Leaving '||l_package,99);
end load_globals;
--
--
-- ---------------------------------------------------------------------------
-- Main
-- ---------------------------------------------------------------------------
 procedure main
   (p_currepe_row            in ben_determine_rates.g_curr_epe_rec
    := ben_determine_rates.g_def_curr_epe_rec
   ,p_per_row                   in per_all_people_F%rowtype
    := ben_determine_rates.g_def_curr_per_rec
   ,p_asg_row                   in per_all_assignments_f%rowtype
    := ben_determine_rates.g_def_curr_asg_rec
   ,p_ast_row                   in per_assignment_status_types%rowtype
    := ben_determine_rates.g_def_curr_ast_rec
   ,p_adr_row                   in per_addresses%rowtype
    := ben_determine_rates.g_def_curr_adr_rec
   ,p_person_id                 in number
   ,p_elig_per_elctbl_chc_id	in number
   ,p_acty_base_rt_id           in number  default null
   ,p_actl_prem_id              in number  default null
   ,p_cvg_amt_calc_mthd_id      in number  default null
   ,p_effective_date            in date
   ,p_lf_evt_ocrd_dt            in date    default null
   ,p_calc_only_rt_val_flag     in boolean default false
   ,p_pgm_id                    in number  default null
   ,p_pl_id                     in number  default null
   ,p_pl_typ_id                 in number  default null
   ,p_oipl_id                   in number  default null
   ,p_per_in_ler_id             in number  default null
   ,p_ler_id                    in number  default null
   ,p_business_group_id         in number  default null
   ,p_ttl_prtt                  in number  default null
   ,p_ttl_cvg                   in number  default null
   ,p_all_prfls                 in boolean default false
   ,p_use_globals               in boolean default false
   ,p_use_prfls                 in boolean default false
   ,p_bnft_amt                  in number  default null
   ,p_vrbl_rt_prfl_id           out nocopy number
   )
is
  --
  l_package               varchar2(80) := g_package||'.main';
  --
  cursor c_gre
    (c_soft_coding_keyflex_id number
    )
  is
  select sck.segment1 gre_id
    from hr_soft_coding_keyflex sck
   where sck.soft_coding_keyflex_id = c_soft_coding_keyflex_id;
  --
  cursor c_epe
  is
    select epe.pgm_id,
           epe.pl_id,
           epe.pl_typ_id,
           epe.oipl_id,
           epe.business_group_id,
           epe.plip_id,
           epe.ptip_id,
           epe.oiplip_id,
           pil.ler_id,
           pil.per_in_ler_id
      from ben_elig_per_elctbl_chc epe,
           ben_per_in_ler pil
     where epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
       and epe.per_in_ler_id = pil.per_in_ler_id;
  --
  l_epe c_epe%rowtype;
  --
  l_profile           ben_rtp_cache.g_cobcep_cache_rec;
  l_vrbl_rt_prfl_id   ben_vrbl_rt_prfl_f.vrbl_rt_prfl_id%type := NULL;
  l_oipl_rec          ben_oipl_f%rowtype;
  l_gre_id            number(15);
  l_person_type       varchar2(30);
  l_per_rec           per_all_people_f%rowtype;
  l_asg_rec           per_all_assignments_f%rowtype;
  l_adr_rec           per_addresses%rowtype;
  l_loc_rec           hr_locations_all%rowtype;
  l_jurisdiction_code varchar2(30);
  l_matched_vrbl_prfl varchar2(1) := 'N';
  l_all_ctr           number := 0;
  l_ttl_cvg           number;
  l_ttl_prtt          number;
  l_loop_count        number;
  l_typ_rec           ben_person_object.g_cache_typ_table;
  l_ast_rec           per_assignment_status_types%rowtype;
  l_appass_rec        ben_person_object.g_cache_ass_table;
  --
  l_effective_date    date;
  l_eligible          boolean;
  -- FONM
  l_fonm_cvg_strt_dt   date;
  l_score_tab         ben_evaluate_elig_profiles.scoreTab;
  l_inst_set          ben_rtp_cache.g_cobcep_odcache;
  --
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  hr_utility.set_location( 'elig per elect id ' || p_elig_per_elctbl_chc_id, 610.3);
  --Bug 5077452
  if fnd_global.conc_request_id = -1 then
    --
    ben_env_object.init(p_business_group_id  => p_business_group_id,
                      p_effective_date     => p_effective_date,
                      p_thread_id          => 1,
                      p_chunk_size         => 1,
                      p_threads            => 1,
                      p_max_errors         => 1,
                      p_benefit_action_id  => null);
    --
  end if;
  --
  -- FONM
  if ben_manage_life_events.fonm = 'Y' then
     --
     l_fonm_cvg_strt_dt := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                               ben_manage_life_events.g_fonm_cvg_strt_dt);
     --
  end if;
  --
  l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
  --
  if  p_all_prfls  then
   hr_utility.set_location('p_all_prfls -> true',11);
  else    hr_utility.set_location('p_all_prfls -> false',11); end if;
  if  p_use_globals  then
   hr_utility.set_location('p_use_globals -> true',11);
  else    hr_utility.set_location('p_use_globals -> false',11); end if;

  if p_person_id is NULL then
    fnd_message.set_name('BEN','BEN_91521_BERP_PERSON_ID');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
    fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
    fnd_message.set_token('PL_ID',to_char(p_pl_id));
    fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
    fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
    fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID',p_elig_per_elctbl_chc_id);
    fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
    fnd_message.raise_error;
  elsif p_effective_date is NULL then
    fnd_message.set_name('BEN','BEN_91522_BERP_EFF_DATE');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
    fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
    fnd_message.set_token('PL_ID',to_char(p_pl_id));
    fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
    fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
    fnd_message.set_token('ELIG_PER_ELCTBL_CHC_ID',p_elig_per_elctbl_chc_id);
    fnd_message.raise_error;
  elsif p_elig_per_elctbl_chc_id is NULL and
        p_calc_only_rt_val_flag = FALSE then
    fnd_message.set_name('BEN','BEN_91523_BERP_ELECTBL_CHC');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
    fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
    fnd_message.set_token('PL_ID',to_char(p_pl_id));
    fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
    fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
    fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
    fnd_message.raise_error;
  elsif (p_acty_base_rt_id is NULL and
         p_actl_prem_id is NULL and
         p_cvg_amt_calc_mthd_id is NULL) then
    fnd_message.set_name('BEN','BEN_91524_BERP_MISS_PRFL_ID');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
    fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
    fnd_message.set_token('PL_ID',to_char(p_pl_id));
    fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
    fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
    fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
    fnd_message.raise_error;
  elsif (p_acty_base_rt_id is not NULL and
         p_actl_prem_id is not NULL) or
        (p_acty_base_rt_id is not NULL and
         p_cvg_amt_calc_mthd_id is not NULL) or
        (p_actl_prem_id  is not NULL and
         p_cvg_amt_calc_mthd_id is not NULL) then
    fnd_message.set_name('BEN','BEN_91525_BERP_MULTI_PRFL_ID');
    fnd_message.set_token('PACKAGE',l_package);
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
    fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
    fnd_message.set_token('PL_ID',to_char(p_pl_id));
    fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
    fnd_message.set_token('LF_EVT_OCRD_DT',p_lf_evt_ocrd_dt);
    fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
    fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
    fnd_message.raise_error;
  end if;

  if p_per_row.person_id is null then
    --
    ben_person_object.get_object     --  FONM : 9999 do we need to rebuild the cache
      (p_person_id => p_person_id
      ,p_rec       => l_per_rec
      );
    --
  else
    --
    l_per_rec := p_per_row;
    --
  end if;

  -- fonm check the date of the person cache
  if not nvl(l_fonm_cvg_strt_dt,l_effective_date)
             between l_per_rec.effective_start_date and l_per_rec.effective_end_date then

          hr_utility.set_location('clearing cache' || nvl(l_fonm_cvg_strt_dt,l_effective_date) ,10);
          hr_utility.set_location('cache start  ' || l_per_rec.effective_start_date ,10);
          hr_utility.set_location('cache end  ' || l_per_rec.effective_end_date ,10);

          ben_use_cvg_rt_date.fonm_clear_down_cache;
          --
          ben_person_object.get_object(p_person_id => p_person_id,
                                       p_rec       => l_per_rec);

          hr_utility.set_location('nw cache start  ' || l_per_rec.effective_start_date ,10);
          hr_utility.set_location('nw cache end  ' || l_per_rec.effective_end_date ,10);
   end if ;



  if p_asg_row.assignment_id is null then
    --
    ben_person_object.get_object     --  FONM : 9999 do we need to rebuild the cache
      (p_person_id => p_person_id
      ,p_rec       => l_asg_rec );
    --
  else
    --
    l_asg_rec := p_asg_row;
    --
  end if;



  --

  if l_asg_rec.assignment_id is null then
    --
    ben_person_object.get_benass_object     --  FONM : 9999 do we need to rebuild the cache
      (p_person_id => p_person_id
      ,p_rec       => l_asg_rec );
    --
    -- If benefit assignment not found, get applicant assignment.
    --
    if l_asg_rec.assignment_id is null then
      --
      ben_person_object.get_object(p_person_id => p_person_id,     --  FONM : 9999 do we need to rebuild the cache
                                   p_rec       => l_appass_rec );
      --
    else
      --
      ben_person_object.get_object
     (p_assignment_status_type_id => l_asg_rec.assignment_status_type_id   --  FONM : 9999 do we need to rebuild the cache
        ,p_rec                       => l_ast_rec );
      --
    end if;
  --
  else
    --
    if p_ast_row.assignment_status_type_id is null then
      --
      ben_person_object.get_object     --  FONM : 9999 do we need to rebuild the cache
        (p_assignment_status_type_id => l_asg_rec.assignment_status_type_id
        ,p_rec                       => l_ast_rec
        );
      --
    else
      --
      l_ast_rec := p_ast_row;
      --
    end if;
    --
  end if;
  --
  -- Check if the address row is passed in
  --
  if p_adr_row.address_id is null then
    --
    ben_person_object.get_object     --  FONM : 9999 do we need to rebuild the cache
      (p_person_id => p_person_id
      ,p_rec       => l_adr_rec
      );
    --
  else
    --
    l_adr_rec := p_adr_row;
    --
  end if;
  --
  if l_asg_rec.location_id is not null then
    --
    ben_location_object.get_object     --  FONM : 9999 do we need to rebuild the cache
      (p_location_id => l_asg_rec.location_id
      ,p_rec         => l_loc_rec);
    --
--   if l_loc_rec.region_2 is not null then
      --
--    l_jurisdiction_code :=
--        pay_mag_utils.lookup_jurisdiction_code
--          (p_state => l_loc_rec.region_2);
      --
--   end if;
    --
  end if;
  --
  if p_calc_only_rt_val_flag then
    --
    l_epe.pgm_id            := p_pgm_id;
    l_epe.pl_id             := p_pl_id;
    l_epe.pl_typ_id         := p_pl_typ_id;
    l_epe.oipl_id           := p_oipl_id;
    l_epe.per_in_ler_id     := p_per_in_ler_id;
    l_epe.ler_id            := p_ler_id;
    l_epe.business_group_id := p_business_group_id;
  --
  -- Check if the context row is populated
  --
  elsif p_currepe_row.elig_per_elctbl_chc_id is not null
  then
    --
    hr_utility.set_location( ' else if  ',610);
    hr_utility.set_location( ' PLIP ID   '|| p_currepe_row.plip_id ,610);
    l_epe.pgm_id            := p_currepe_row.pgm_id;
    l_epe.pl_id             := p_currepe_row.pl_id;
    l_epe.pl_typ_id         := p_currepe_row.pl_typ_id;
    l_epe.oipl_id           := p_currepe_row.oipl_id;
    l_epe.oiplip_id         := p_currepe_row.oiplip_id; --9999
    l_epe.per_in_ler_id     := p_currepe_row.per_in_ler_id;
    l_epe.ler_id            := p_currepe_row.ler_id;
    l_epe.plip_id           := p_currepe_row.plip_id;
    l_epe.business_group_id := p_currepe_row.business_group_id;
    --
  else
    hr_utility.set_location( ' in cursor ',610) ;
    open c_epe;
    fetch c_epe into l_epe;
    close c_epe;
  end if;
  --
  hr_utility.set_location(' oipl id ' || l_epe.oipl_id , 610.3);
  hr_utility.set_location( ' PLIP ID   '|| l_epe.plip_id ,610);
  if l_epe.oipl_id is not null then
    ben_comp_object.get_object(p_oipl_id => l_epe.oipl_id
                              ,p_rec     => l_oipl_rec);
  end if;
  --
  if p_use_globals then
    l_all_ctr := g_all_prfls.first;
  end if;
  --
  -- Mallik: Removed the cursors and introduced the call to vapro cache
  --
  if not (p_actl_prem_id is not NULL and p_use_globals) then
     ben_rtp_cache.abravr_odgetdets
     (p_effective_date        =>  nvl(l_fonm_cvg_strt_dt,l_effective_date)
     ,p_acty_base_rt_id       => p_acty_base_rt_id
     ,p_cvg_amt_calc_mthd_id  => p_cvg_amt_calc_mthd_id
     ,p_actl_prem_id          => p_actl_prem_id
     ,p_inst_set              => l_inst_set
     );
  end if;

  hr_utility.set_location ('Prof loop '||l_package,10);
  for i in 1..l_inst_set.count
  loop
    --
    begin

      l_profile := l_inst_set(i);

      if p_actl_prem_id is not NULL then

        if p_use_globals then
          if l_all_ctr is null then
            exit;
          end if;

          --  load fields that process will use from globals instead of cursor:
          l_profile.vrbl_rt_prfl_id    := g_all_prfls(l_all_ctr).vrbl_rt_prfl_id;
          l_profile.asmt_to_use_cd     := g_all_prfls(l_all_ctr).asmt_to_use_cd  ;
          l_profile.rt_hrly_slrd_flag  := g_all_prfls(l_all_ctr).rt_hrly_slrd_flag  ;
          l_profile.rt_pstl_cd_flag    := g_all_prfls(l_all_ctr).rt_pstl_cd_flag  ;
          l_profile.rt_lbr_mmbr_flag   := g_all_prfls(l_all_ctr).rt_lbr_mmbr_flag  ;
          l_profile.rt_lgl_enty_flag   := g_all_prfls(l_all_ctr).rt_lgl_enty_flag  ;
          l_profile.rt_benfts_grp_flag := g_all_prfls(l_all_ctr).rt_benfts_grp_flag  ;
          l_profile.rt_wk_loc_flag     := g_all_prfls(l_all_ctr).rt_wk_loc_flag  ;
          l_profile.rt_brgng_unit_flag := g_all_prfls(l_all_ctr).rt_brgng_unit_flag  ;
          l_profile.rt_age_flag        := g_all_prfls(l_all_ctr).rt_age_flag  ;
          l_profile.rt_los_flag        := g_all_prfls(l_all_ctr).rt_los_flag  ;
          l_profile.rt_per_typ_flag    := g_all_prfls(l_all_ctr).rt_per_typ_flag  ;
          l_profile.rt_fl_tm_pt_tm_flag:= g_all_prfls(l_all_ctr).rt_fl_tm_pt_tm_flag  ;
          l_profile.rt_ee_stat_flag    := g_all_prfls(l_all_ctr).rt_ee_stat_flag  ;
          l_profile.rt_grd_flag        := g_all_prfls(l_all_ctr).rt_grd_flag  ;
          l_profile.rt_pct_fl_tm_flag  := g_all_prfls(l_all_ctr).rt_pct_fl_tm_flag  ;
          l_profile.rt_asnt_set_flag   := g_all_prfls(l_all_ctr).rt_asnt_set_flag  ;
          l_profile.rt_hrs_wkd_flag    := g_all_prfls(l_all_ctr).rt_hrs_wkd_flag  ;
          l_profile.rt_comp_lvl_flag   := g_all_prfls(l_all_ctr).rt_comp_lvl_flag  ;
          l_profile.rt_org_unit_flag   := g_all_prfls(l_all_ctr).rt_org_unit_flag  ;
          l_profile.rt_loa_rsn_flag    := g_all_prfls(l_all_ctr).rt_loa_rsn_flag  ;
          l_profile.rt_pyrl_flag       := g_all_prfls(l_all_ctr).rt_pyrl_flag  ;
          l_profile.rt_schedd_hrs_flag := g_all_prfls(l_all_ctr).rt_schedd_hrs_flag  ;
          l_profile.rt_py_bss_flag     := g_all_prfls(l_all_ctr).rt_py_bss_flag  ;
          l_profile.rt_prfl_rl_flag    := g_all_prfls(l_all_ctr).rt_prfl_rl_flag  ;
          l_profile.rt_cmbn_age_los_flag := g_all_prfls(l_all_ctr).rt_cmbn_age_los_flag ;
          l_profile.rt_prtt_pl_flag    := g_all_prfls(l_all_ctr).rt_prtt_pl_flag  ;
          l_profile.rt_svc_area_flag   := g_all_prfls(l_all_ctr).rt_svc_area_flag  ;
          l_profile.rt_ppl_grp_flag    := g_all_prfls(l_all_ctr).rt_ppl_grp_flag  ;
          l_profile.rt_dsbld_flag      := g_all_prfls(l_all_ctr).rt_dsbld_flag  ;
          l_profile.rt_hlth_cvg_flag   := g_all_prfls(l_all_ctr).rt_hlth_cvg_flag  ;
          l_profile.rt_poe_flag        := g_all_prfls(l_all_ctr).rt_poe_flag  ;
          l_profile.rt_ttl_cvg_vol_flag:= g_all_prfls(l_all_ctr).rt_ttl_cvg_vol_flag  ;
          l_profile.rt_ttl_prtt_flag   := g_all_prfls(l_all_ctr).rt_ttl_prtt_flag  ;
          l_profile.rt_gndr_flag       := g_all_prfls(l_all_ctr).rt_gndr_flag  ;
          l_profile.rt_tbco_use_flag   := g_all_prfls(l_all_ctr).rt_tbco_use_flag ;
          l_profile.rt_cntng_prtn_prfl_flag := g_all_prfls(l_all_ctr).rt_cntng_prtn_prfl_flag;
	  l_profile.rt_cbr_quald_bnf_flag  := g_all_prfls(l_all_ctr).rt_cbr_quald_bnf_flag;
	  l_profile.rt_optd_mdcr_flag      := g_all_prfls(l_all_ctr).rt_optd_mdcr_flag;
	  l_profile.rt_lvg_rsn_flag        := g_all_prfls(l_all_ctr).rt_lvg_rsn_flag;
	  l_profile.rt_pstn_flag           := g_all_prfls(l_all_ctr).rt_pstn_flag;
	  l_profile.rt_comptncy_flag       := g_all_prfls(l_all_ctr).rt_comptncy_flag;
	  l_profile.rt_job_flag            := g_all_prfls(l_all_ctr).rt_job_flag;
	  l_profile.rt_qual_titl_flag      := g_all_prfls(l_all_ctr).rt_qual_titl_flag;
	  l_profile.rt_dpnt_cvrd_pl_flag   := g_all_prfls(l_all_ctr).rt_dpnt_cvrd_pl_flag;
	  l_profile.rt_dpnt_cvrd_plip_flag := g_all_prfls(l_all_ctr).rt_dpnt_cvrd_plip_flag;
	  l_profile.rt_dpnt_cvrd_ptip_flag := g_all_prfls(l_all_ctr).rt_dpnt_cvrd_ptip_flag;
	  l_profile.rt_dpnt_cvrd_pgm_flag  := g_all_prfls(l_all_ctr).rt_dpnt_cvrd_pgm_flag;
	  l_profile.rt_enrld_oipl_flag     := g_all_prfls(l_all_ctr).rt_enrld_oipl_flag;
	  l_profile.rt_enrld_pl_flag       := g_all_prfls(l_all_ctr).rt_enrld_pl_flag;
	  l_profile.rt_enrld_plip_flag     := g_all_prfls(l_all_ctr).rt_enrld_plip_flag;
	  l_profile.rt_enrld_ptip_flag     := g_all_prfls(l_all_ctr).rt_enrld_ptip_flag;
	  l_profile.rt_enrld_pgm_flag      := g_all_prfls(l_all_ctr).rt_enrld_pgm_flag;
	  l_profile.rt_prtt_anthr_pl_flag  := g_all_prfls(l_all_ctr).rt_prtt_anthr_pl_flag;
	  l_profile.rt_othr_ptip_flag      := g_all_prfls(l_all_ctr).rt_othr_ptip_flag;
	  l_profile.rt_no_othr_cvg_flag    := g_all_prfls(l_all_ctr).rt_no_othr_cvg_flag;
          l_profile.rt_dpnt_othr_ptip_flag := g_all_prfls(l_all_ctr).rt_dpnt_othr_ptip_flag;
          l_profile.rt_qua_in_gr_flag      := g_all_prfls(l_all_ctr).rt_qua_in_gr_flag;
          l_profile.rt_perf_rtng_flag 	   := g_all_prfls(l_all_ctr).rt_perf_rtng_flag;
          l_profile.rt_elig_prfl_flag 	   := g_all_prfls(l_all_ctr).rt_elig_prfl_flag;

          --
          -- use total counts for all prtts in this plan or oipl that match
          -- this particular vrbl rate's criteria.
          --
          l_ttl_prtt := g_all_prfls(l_all_ctr).match_cnt;
          l_ttl_cvg  := g_all_prfls(l_all_ctr).match_cvg;
          -- get ready for next loop
          l_all_ctr := g_all_prfls.next(l_all_ctr);
          --
        else
          --
          -- use total counts for all prtts in this plan or oipl
          --
          l_ttl_prtt := p_ttl_prtt;
          l_ttl_cvg  := p_ttl_cvg;
          --
        end if;
        --
      end if;
      --
      ben_person_object.get_object(p_person_id => p_person_id, -- FONM 9999
                                   p_rec       => l_typ_rec);
      --
 hr_utility.set_location('l_profile.vrbl_rt_prfl_id -> '||l_profile.vrbl_rt_prfl_id,11);
 hr_utility.set_location('l_profile.rt_per_typ_flag -> '||l_profile.rt_per_typ_flag,11);
--
      if l_profile.rt_elig_prfl_flag = 'Y' then
         hr_utility.set_location('elig_for_profiles',10);

         l_eligible :=
         ben_evaluate_elig_profiles.eligible
        (p_vrbl_rt_prfl_id      => l_profile.vrbl_rt_prfl_id
        ,p_person_id            => p_person_id
        ,p_business_group_id    => p_business_group_id
        ,p_effective_date       => p_effective_date
        ,p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt
        ,p_per_in_ler_id        => p_per_in_ler_id
        ,p_ler_id               => p_ler_id
        ,p_pgm_id               => l_epe.pgm_id
        ,p_ptip_id              => l_epe.ptip_id
        ,p_plip_id              => nvl(p_currepe_row.plip_id,l_epe.plip_id)
        ,p_pl_id                => l_epe.pl_id
        ,p_oipl_id              => l_epe.oipl_id
        ,p_oiplip_id            => l_epe.oiplip_id
        ,p_pl_typ_id            => l_epe.pl_typ_id
        ,p_opt_id               => nvl(p_currepe_row.opt_id,l_oipl_rec.opt_id)
        ,p_par_pgm_id           => p_currepe_row.pgm_id
        ,p_par_plip_id          => p_currepe_row.plip_id
        ,p_par_pl_id            => p_currepe_row.pl_id
        ,p_par_opt_id           => p_currepe_row.opt_id
        ,p_currepe_row          => p_currepe_row
        ,p_ttl_prtt             => l_ttl_prtt
        ,p_ttl_cvg              => l_ttl_cvg
        ,p_all_prfls            => p_all_prfls
        ,p_score_tab            => l_score_tab
        ,p_eval_typ             => 'V'
        );
        --
        if not l_eligible then
           --
           raise g_profile_failed;
           --
        end if;
      end if;
      hr_utility.set_location ('Dn elig_for_profiles '||l_package,10);

      if l_profile.rt_per_typ_flag = 'Y' then
      hr_utility.set_location('check_per_typ',10);
      check_per_typ
        (p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
         p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_person_type       => l_typ_rec);
      end if;
      hr_utility.set_location ('Dn check_per_typ '||l_package,10);
      --
      -- Now we check these profiles using the required assignment type
      --
      l_loop_count := 1;
      --
      if l_profile.asmt_to_use_cd = 'EAO' then
        --
        -- Employee assignment only
        --
	l_asg_rec := NULL;          --Bug 6399423
        ben_person_object.get_object(p_person_id => p_person_id,
                                     p_rec       => l_asg_rec);
        --
      elsif l_profile.asmt_to_use_cd = 'BAO' then
        --
        -- Benefit assignment only
        --
	l_asg_rec := NULL;          --Bug 6399423
        ben_person_object.get_benass_object(p_person_id => p_person_id,
                                            p_rec       => l_asg_rec);
        --
      elsif l_profile.asmt_to_use_cd = 'ANY' then
        --
        -- First assignment only
        --
        ben_person_object.get_allass_object(p_person_id => p_person_id,
                                            p_rec       => l_appass_rec);
        --
        if not l_appass_rec.exists(1) then
          --
          -- Initialize first record so that one time test works
          --
          l_appass_rec(1).person_id := p_person_id;
          --
        end if;
        --
        l_asg_rec := l_appass_rec(1);
        l_loop_count := l_appass_rec.count;
        --
      elsif l_profile.asmt_to_use_cd = 'AAO' then
        --
        -- Applicant assignment only
        --
        ben_person_object.get_object(p_person_id => p_person_id,
                                     p_rec       => l_appass_rec);
        --
        if not l_appass_rec.exists(1) then
          --
          -- Initialize first record so that one time test works
          --
          l_appass_rec(1).person_id := p_person_id;
          --
        end if;
        --
        l_asg_rec := l_appass_rec(1);
        l_loop_count := l_appass_rec.count;
        --
      elsif l_profile.asmt_to_use_cd = 'ETB' then
        --
        -- Employee then Benefits assignment only
        --
        ben_person_object.get_object(p_person_id => p_person_id,
                                     p_rec       => l_asg_rec);
        --
        if l_asg_rec.assignment_id is null then
          --
          -- Get Benefits Assignment
          --
          ben_person_object.get_benass_object(p_person_id => p_person_id,
                                              p_rec       => l_asg_rec);
          --
        end if;
        --
      elsif l_profile.asmt_to_use_cd = 'BTE' then
        --
        -- Benefits then Employee assignment only
        --
        ben_person_object.get_benass_object(p_person_id => p_person_id,
                                            p_rec       => l_asg_rec);
        --
        if l_asg_rec.assignment_id is null then
          --
          -- Get Employee Assignment
          --
          ben_person_object.get_object(p_person_id => p_person_id,
                                       p_rec       => l_asg_rec);
          --
        end if;
        --
      elsif l_profile.asmt_to_use_cd = 'EBA' then
        --
        -- Employee then Benefits then Applicant assignment only
        --
        ben_person_object.get_object(p_person_id => p_person_id,
                                     p_rec       => l_asg_rec);
        --
        if l_asg_rec.assignment_id is null then
          --
          -- Get Benefits Assignment
          --
          ben_person_object.get_benass_object(p_person_id => p_person_id,
                                              p_rec       => l_asg_rec);
          --
          if l_asg_rec.assignment_id is null then
            --
            -- Applicant assignment only
            --
            ben_person_object.get_object(p_person_id => p_person_id,
                                         p_rec       => l_appass_rec);
            --
            if not l_appass_rec.exists(1) then
              --
              -- Initialize first record so that one time test works
              --
              l_appass_rec(1).person_id := p_person_id;
              --
            end if;
            --
            l_asg_rec := l_appass_rec(1);
            l_loop_count := l_appass_rec.count;
            --
          end if;
          --
        end if;
        --
      end if;
      --
-- Bug 6399423
      hr_utility.set_location ('l_asg_rec'|| l_asg_rec.assignment_id,534511234);
      --
      if (l_profile.asmt_to_use_cd <> 'ANY' and
                 l_asg_rec.assignment_id is null) then
               --
	 raise ben_evaluate_rate_profiles.g_profile_failed;
      end if;
      --
-- Bug 6399423
      hr_utility.set_location ('ASG Profs '||l_package,10);
      for l_count in 1..l_loop_count loop
        --
        begin
          --
          if l_loop_count > 1 then
            --
            -- Make sure that we pass in the correct assignment
            --
            l_asg_rec := l_appass_rec(l_count);
            --
          end if;
          --
          --          Employee Status
          --
          if l_profile.rt_ee_stat_flag = 'Y' then
          hr_utility.set_location('check_ee_stat',10);
          check_ee_stat
            (p_vrbl_rt_prfl_id           => l_profile.vrbl_rt_prfl_id,
             p_person_id                 => p_person_id,
             p_business_group_id         => p_business_group_id,
             p_effective_date            => p_effective_date,
             p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt,
             p_assignment_status_type_id => l_asg_rec.assignment_status_type_id);
          end if;
          --
          --          People Group
          --
          if l_profile.rt_ppl_grp_flag = 'Y' then
          hr_utility.set_location('check_people_group',10);
          check_people_group
            (p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => p_effective_date,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_people_group_id   => l_asg_rec.people_group_id);
          end if;
          --
          --          Hourly/Salary Code
          --
          if l_profile.rt_hrly_slrd_flag = 'Y' then
          hr_utility.set_location('check_hourly_salary',10);
          check_hourly_salary
            (p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => p_effective_date,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_hrly_slry         => l_asg_rec.hourly_salaried_code);
          end if;
          --
          --          Bargaining Unit
          --
          if l_profile.rt_brgng_unit_flag = 'Y' then
          hr_utility.set_location('check_brgng_unit',10);
          check_brgng_unit
            (p_vrbl_rt_prfl_id      => l_profile.vrbl_rt_prfl_id,
             p_business_group_id    => p_business_group_id,
             p_effective_date       => p_effective_date,
             p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt,
             p_bargaining_unit_code => l_asg_rec.bargaining_unit_code);
          end if;
          --
          --            Labor Union
          --
          if l_profile.rt_lbr_mmbr_flag = 'Y' then
          hr_utility.set_location('check_lbr_union',10);
          check_lbr_union
            (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
             p_person_id                => p_person_id,
             p_business_group_id        => p_business_group_id,
             p_effective_date           => p_effective_date,
             p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt,
             p_labour_union_member_flag => l_asg_rec.labour_union_member_flag);
          end if;
          --
          --          Full Time / Part Time
          --
          if l_profile.rt_fl_tm_pt_tm_flag = 'Y' then
          hr_utility.set_location('check_fl_tm_pt',10);
          check_fl_tm_pt
            (p_vrbl_rt_prfl_id     => l_profile.vrbl_rt_prfl_id,
             p_person_id           => p_person_id,
             p_business_group_id   => p_business_group_id,
             p_effective_date      => p_effective_date,
             p_lf_evt_ocrd_dt      => p_lf_evt_ocrd_dt,
             p_employment_category => l_asg_rec.employment_category);
          end if;
          --
          --          Work Location
          --
          if l_profile.rt_wk_loc_flag = 'Y' then
          hr_utility.set_location('check_wk_location',10);
          check_wk_location
            (p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => p_effective_date,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_location_id       => l_asg_rec.location_id);
          end if;
          --
          --          Organization
          --
          if l_profile.rt_org_unit_flag = 'Y' then
          hr_utility.set_location('check_org_unit',10);
          check_org_unit
            (p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => p_effective_date,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_org_id            => l_asg_rec.organization_id);
          end if;
          --
          --          LOA
          --
          if l_profile.rt_loa_rsn_flag = 'Y' then
          hr_utility.set_location('check_loa_rsn',10);
          check_loa_rsn
            (p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => p_effective_date,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt);
          end if;
          --
          --          Scheduled Hours
          --
          if l_profile.rt_schedd_hrs_flag = 'Y' then
          hr_utility.set_location('check_sched_hrs',10);
          check_sched_hrs
            (p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => p_effective_date,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_normal_hrs        => l_asg_rec.normal_hours,
             p_frequency         => l_asg_rec.frequency,
             p_per_in_ler_id     => l_epe.per_in_ler_id,
  	     p_assignment_id     => l_asg_rec.assignment_id,
  	     p_organization_id   => l_asg_rec.organization_id,
  	     p_pgm_id            => l_epe.pgm_id,
  	     p_pl_id             => l_epe.pl_id,
  	     p_pl_typ_id         => l_epe.pl_typ_id,
  	     p_opt_id            => l_oipl_rec.opt_id,
  	     p_oipl_id          => l_epe.oipl_id,
  	     p_ler_id            => l_epe.ler_id,
  	     p_jurisdiction_code => l_jurisdiction_code);
          end if;
          --
          --          Pay Basis
          --
          if l_profile.rt_py_bss_flag = 'Y' then
          hr_utility.set_location('check_py_bss',10);
          check_py_bss
            (p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => p_effective_date,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_pay_basis_id      => l_asg_rec.pay_basis_id);
          end if;
          --
          --          Grade
          --
          if l_profile.rt_grd_flag = 'Y' then
          hr_utility.set_location('check_grade',10);
          check_grade
            (p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => p_effective_date,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_grade_id          => l_asg_rec.grade_id);
          end if;
          --
          --          Legal Entity
          --
          if l_profile.rt_lgl_enty_flag = 'Y' then
          hr_utility.set_location('check_lgl_enty',10);
          open c_gre(l_asg_rec.soft_coding_keyflex_id);
            --
            fetch c_gre into l_gre_id;
            --
          close c_gre;
          --
          check_lgl_enty
            (p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => p_effective_date,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_gre_id            => l_gre_id);
          end if;
          --
          --          Payroll
          --
          if l_profile.rt_pyrl_flag = 'Y' then
          hr_utility.set_location('check_pyrl',10);
          check_pyrl
            (p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
             p_person_id         => p_person_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => p_effective_date,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_payroll_id        => l_asg_rec.payroll_id);
          end if;

          --
          -- Job
          --
          if l_profile.rt_job_flag = 'Y' then
          hr_utility.set_location('check_job',10);
          check_job
            (p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
             p_business_group_id => p_business_group_id,
             p_effective_date    => p_effective_date,
             p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
             p_job_id        	 => l_asg_rec.job_id);
          end if;

          --
	  -- Postion
	  --
	  if l_profile.rt_pstn_flag = 'Y' then
	  hr_utility.set_location('check_pstn',10);
	  check_pstn
	     (p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
	     p_business_group_id => p_business_group_id,
	     p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
	     p_effective_date	   => p_effective_date,
	     p_asg_position_id   => l_asg_rec.position_id);
          end if;

          --
	  --  Quartile in Grade
	  --
	  if l_profile.rt_qua_in_gr_flag = 'Y' then
	  hr_utility.set_location('check_qua_in_gr',10);
	  check_qua_in_gr(p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
	  		  p_business_group_id => p_business_group_id,
	                  p_person_id         => p_person_id,
	                  p_grade_id	      => l_asg_rec.grade_id,
	                  p_assignment_id     => l_asg_rec.assignment_id,
	                  p_effective_date    => p_effective_date,
                     	  p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
                     	  p_pay_basis_id      => l_asg_rec.pay_basis_id);
          end if;

          --
	  --  Performance Rating
	  --
	  if l_profile.rt_perf_rtng_flag = 'Y' then
	  hr_utility.set_location('check_perf_rtng',10);
	  check_perf_rtng(p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
	    		  p_business_group_id => p_business_group_id,
	                  p_assignment_id     => l_asg_rec.assignment_id,
	                  p_person_id         => p_person_id,
	                  p_effective_date    => p_effective_date,
	  		  p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt);
          end if;

          --
          -- Rules
          --
          if l_profile.rt_prfl_rl_flag = 'Y' then
          hr_utility.set_location('check_rules',10);
          check_rules
            (p_vrbl_rt_prfl_id     => l_profile.vrbl_rt_prfl_id,
             p_business_group_id   => p_business_group_id,
             p_effective_date      => p_effective_date,
             p_lf_evt_ocrd_dt      => p_lf_evt_ocrd_dt,
             p_assignment_id       => l_asg_rec.assignment_id,
             p_organization_id     => l_asg_rec.organization_id,
             p_pgm_id              => l_epe.pgm_id,
             p_pl_id               => l_epe.pl_id,
             p_pl_typ_id           => l_epe.pl_typ_id,
             p_opt_id              => l_oipl_rec.opt_id,
             p_ler_id              => l_epe.ler_id,
             p_elig_per_elctbl_chc_id =>  p_elig_per_elctbl_chc_id,
             p_acty_base_rt_id     => p_acty_base_rt_id,
          p_jurisdiction_code   => l_jurisdiction_code);
       end if;
       --
       --  all criteria passed for this profile thus far so exit this
       --  loop and check remaining criteria
       --
       exit;
       --
       exception
         --
         when g_criteria_failed then
           --
           -- Handle case where we want an error if we are dealing with
           -- the last assignment to be processed. If it is the last
           -- assignment then we want to error the profile.
           --
           if l_count = l_loop_count then
             --
             -- Raise error to main exception handler
             --
             raise ben_evaluate_rate_profiles.g_profile_failed;
             --
           end if;
           --
        end;
        --
      end loop;
      --
      -- now check remaining criteria
      --
      --
      --
      --          PCT Fulltime
      --
      hr_utility.set_location ('Person Profs '||l_package,10);
      if l_profile.rt_pct_fl_tm_flag = 'Y' then
      hr_utility.set_location('check_pct_fltm',10);
      check_pct_fltm
        (p_vrbl_rt_prfl_id        => l_profile.vrbl_rt_prfl_id,
         p_person_id              => p_person_id,
         p_business_group_id      => p_business_group_id,
         -- FONM : as lf_evt_ocrd_dt is not used, it's fine to overload the
         -- p_effective_date.
         p_effective_date         => nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                                      nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                       nvl(p_lf_evt_ocrd_dt, p_effective_date))),
         p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
         p_pgm_id                 => l_epe.pgm_id,
         p_pl_id                  => l_epe.pl_id,
         p_opt_id                 => l_oipl_rec.opt_id,
         p_plip_id                => l_epe.plip_id);
      end if;
      --
      --          Benefits Group
      --
      if l_profile.rt_benfts_grp_flag = 'Y' then
      hr_utility.set_location('check_benefits_group',10);
      check_benefits_grp
        (p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
         p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_benefit_group_id  => l_per_rec.benefit_group_id);
      end if;
      --
      --            Age
      --
      hr_utility.set_location ('DF Profs '||l_package,10);
      if l_profile.rt_age_flag = 'Y' then
      hr_utility.set_location('check_age',10);
      check_age
        (p_vrbl_rt_prfl_id        => l_profile.vrbl_rt_prfl_id
        ,p_per_dob                => l_per_rec.date_of_birth
        ,p_person_id              => p_person_id
        ,p_business_group_id      => p_business_group_id
        ,p_effective_date         =>  p_effective_date
        ,p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt    -- fonm taken care in procedure
        ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
        ,p_pl_id                  => l_epe.pl_id
        ,p_pgm_id                 => l_epe.pgm_id
        ,p_oipl_id                => l_epe.oipl_id
        ,p_per_in_ler_id          => l_epe.per_in_ler_id
        ,p_opt_id                 => p_currepe_row.opt_id
        ,p_plip_id                => p_currepe_row.plip_id
        ,p_currepe_row            => p_currepe_row
        );
      end if;
      --
      --          Tobacco
      --
      hr_utility.set_location ('Tobacco '||l_package,10);
      if l_profile.rt_tbco_use_flag = 'Y' then
      hr_utility.set_location('check_tobacco',10);
      check_tobacco
        (p_vrbl_rt_prfl_id      => l_profile.vrbl_rt_prfl_id,
         p_business_group_id    => p_business_group_id,
         p_effective_date       => p_effective_date,
         p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt,
	 --Handling NULL value for uses_tobacco_flag .Refer Bug : 6525934
         p_tobacco              => NVL(l_per_rec.uses_tobacco_flag,'N'));
      end if;
      --
      --            LOS
      --
      hr_utility.set_location ('LOS Prof '||l_package,10);
      if l_profile.rt_los_flag = 'Y' then
      hr_utility.set_location('check_los',10);
      check_los
        (p_vrbl_rt_prfl_id        => l_profile.vrbl_rt_prfl_id,
         p_person_id              => p_person_id,
         p_business_group_id      => p_business_group_id,
         p_effective_date         => p_effective_date,
         p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
         p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
         p_pgm_id                 => l_epe.pgm_id,
         p_oipl_id                => l_epe.oipl_id,
         p_opt_id                 => p_currepe_row.opt_id,
         p_plip_id                => p_currepe_row.plip_id,
         p_pl_id                  => l_epe.pl_id,
         p_currepe_row            => p_currepe_row);
      end if;
      --
      --    Assignment set
      if l_profile.rt_asnt_set_flag = 'Y' then
        hr_utility.set_location('Assn Set Flag',10);
        check_asnt_set
        (p_VRBL_RT_PRFL_ID   => l_profile.vrbl_rt_prfl_id,
         p_business_group_id => p_business_group_id,
         p_person_id         => p_person_id,
         p_lf_evt_ocrd_dt   =>  p_lf_evt_ocrd_dt,
         p_effective_date   =>  p_effective_date );
      end if;
      --          Hours worked
      --
      if l_profile.rt_hrs_wkd_flag = 'Y' then
      hr_utility.set_location('check_hrs_wkd',10);
      check_hrs_wkd
        (p_vrbl_rt_prfl_id        => l_profile.vrbl_rt_prfl_id,
         p_person_id              => p_person_id,
         p_business_group_id      => p_business_group_id,
         -- FONM : as lf_evt_ocrd_dt is not used, it's fine to overload the
         -- p_effective_date.
         p_effective_date         => nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                                      nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                       nvl(p_lf_evt_ocrd_dt, p_effective_date))),
         p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
         p_pgm_id                 => l_epe.pgm_id,
         p_pl_id                  => l_epe.pl_id,
         p_opt_id                 => l_oipl_rec.opt_id,
         p_plip_id                => l_epe.plip_id);
      end if;
      --
      --          Postal Code
      --
      if l_profile.rt_pstl_cd_flag = 'Y' then
      hr_utility.set_location('check_zip_code_rng',10);
      check_zip_code_rng
        (p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
         p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_postal_code       => l_adr_rec.postal_code);
      end if;
      --
      --            Service Area
      --
      if l_profile.rt_svc_area_flag = 'Y' then
      hr_utility.set_location('check_service_area',10);
      check_service_area
        (p_vrbl_rt_prfl_id   => l_profile.vrbl_rt_prfl_id,
         p_person_id         => p_person_id,
         p_business_group_id => p_business_group_id,
         p_effective_date    => p_effective_date,
         p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
         p_postal_code       => l_adr_rec.postal_code);
      end if;
      --
      --            Comp Level
      --
      hr_utility.set_location ('DF profs '||l_package,10);
      if l_profile.rt_comp_lvl_flag = 'Y' then
      hr_utility.set_location('check_comp_level',10);
      check_comp_level
        (p_vrbl_rt_prfl_id        => l_profile.vrbl_rt_prfl_id,
         p_person_id              => p_person_id,
         p_business_group_id      => p_business_group_id,
         p_effective_date         => p_effective_date,   --fonm taken care in the function
         p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
         p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
         p_pgm_id                 => l_epe.pgm_id,
         p_pl_id                  => l_epe.pl_id,
         p_oipl_id                => l_epe.oipl_id,
         p_per_in_ler_id          => l_epe.per_in_ler_id);
      end if;
      --
      --            Combine Age and LOS
      --
      if l_profile.rt_cmbn_age_los_flag = 'Y' then
      hr_utility.set_location('check_age_los',10);
      check_age_los
        (p_vrbl_rt_prfl_id        => l_profile.vrbl_rt_prfl_id,
         p_person_id              => p_person_id,
         p_business_group_id      => p_business_group_id,
         p_effective_date         => p_effective_date,
         p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
         p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
         p_pgm_id                 => l_epe.pgm_id,
         p_pl_id                  => l_epe.pl_id,
         p_opt_id                 => p_currepe_row.opt_id,
         p_plip_id                => p_currepe_row.plip_id,
         p_currepe_row            => p_currepe_row);
      end if;
      --
      --          Gender
      --
      if l_profile.rt_gndr_flag = 'Y' then
      hr_utility.set_location('check_gender',10);
      check_gender
        (p_vrbl_rt_prfl_id      => l_profile.vrbl_rt_prfl_id,
         p_business_group_id    => p_business_group_id,
         p_effective_date       => p_effective_date,
         p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt,
         p_sex                  => l_per_rec.sex);
      end if;
      --
      --   Check period of enrollment.  This is
      --   currently only for COBRA.
      --
      hr_utility.set_location ('COBRA profs '||l_package,10);
      if l_profile.rt_poe_flag = 'Y' then
      hr_utility.set_location('check_period_of_enrollment',10);
      check_period_of_enrollment
        (p_vrbl_rt_prfl_id      => l_profile.vrbl_rt_prfl_id,
         p_business_group_id    => p_business_group_id,
         p_effective_date       => p_effective_date,
         p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt,
         p_person_id            => p_person_id,
         p_pgm_id               => p_pgm_id,
         p_pl_typ_id            => p_pl_typ_id,
         p_ler_id               => p_ler_id );
      end if;
      --
      --   Disabled
      --
      if l_profile.rt_dsbld_flag = 'Y' then
      hr_utility.set_location('check_dsbld_cd' ||  l_per_rec.registered_disabled_flag,10);
      check_dsbld_cd
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         p_effective_date           => p_effective_date,
         p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt,
         p_dsbld_cd                 => l_per_rec.registered_disabled_flag);
      end if;

      --
      --   Opted for Medicare
      --
      if l_profile.rt_optd_mdcr_flag = 'Y' then
      hr_utility.set_location('check_optd_mdcr',10);
      check_optd_mdcr
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         p_effective_date           => p_effective_date,
         p_lf_evt_ocrd_dt    	    => p_lf_evt_ocrd_dt,
         p_person_id 	  	    => p_person_id );
      end if;

      --
      --   Leaving Reason
      --
      if l_profile.rt_lvg_rsn_flag = 'Y' then
      hr_utility.set_location('check_lvg_rsn',10);
      check_lvg_rsn
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         p_effective_date           => p_effective_date,
         p_lf_evt_ocrd_dt    	    => p_lf_evt_ocrd_dt,
         p_person_id 	  	    => p_person_id );
      end if;

      --
      --   Cobra Qualified Beneficiary
      --
      if l_profile.rt_cbr_quald_bnf_flag = 'Y' then
      hr_utility.set_location('check_cbr_quald_bnf',10);
      check_cbr_quald_bnf
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         p_effective_date           => p_effective_date,
         p_lf_evt_ocrd_dt    	    => p_lf_evt_ocrd_dt,
         p_person_id 	  	    => p_person_id );
      end if;

      --
      --   Competency
      --
      if l_profile.rt_comptncy_flag = 'Y' then
      hr_utility.set_location('check_comptncy',10);
      check_comptncy
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         p_person_id		    => p_person_id ,
         p_effective_date           => p_effective_date,
         p_lf_evt_ocrd_dt 	    => p_lf_evt_ocrd_dt );
      end if;

      --
      --   Qualification title
      --
      if l_profile.rt_qual_titl_flag = 'Y' then
      hr_utility.set_location('check_qual_titl',10);
      check_qual_titl
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         p_person_id		    => p_person_id ,
         p_effective_date           => p_effective_date,
         p_lf_evt_ocrd_dt 	    => p_lf_evt_ocrd_dt );
      end if;

      --
      --   Dependent Covered Other Plan
      --
      if l_profile.rt_dpnt_cvrd_pl_flag = 'Y' then
      hr_utility.set_location('check_dpnt_cvrd_othr_pl',10);
      check_dpnt_cvrd_othr_pl
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         p_effective_date           => p_effective_date,
         p_person_id 		    => p_person_id,
         p_lf_evt_ocrd_dt 	    => p_lf_evt_ocrd_dt );
      end if;


      --
      --   Dependent Covered Other Plan in Program
      --
      if l_profile.rt_dpnt_cvrd_plip_flag = 'Y' then
      hr_utility.set_location('check_dpnt_cvrd_othr_plip',10);
      check_dpnt_cvrd_othr_plip
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         p_effective_date           => p_effective_date,
         p_person_id 		    => p_person_id,
         p_lf_evt_ocrd_dt 	    => p_lf_evt_ocrd_dt );
      end if;

      --
      --   Dependent Covered Other Plan Type in Program
      --
      if l_profile.rt_dpnt_cvrd_ptip_flag = 'Y' then
      hr_utility.set_location('check_dpnt_cvrd_othr_ptip',10);
      check_dpnt_cvrd_othr_ptip
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         p_effective_date           => p_effective_date,
         p_person_id 		    => p_person_id,
         p_lf_evt_ocrd_dt 	    => p_lf_evt_ocrd_dt );
      end if;


      --
      --   Dependent Covered Other Program
      --
      if l_profile.rt_dpnt_cvrd_pgm_flag = 'Y' then
      hr_utility.set_location('check_dpnt_cvrd_othr_pgm',10);
      check_dpnt_cvrd_othr_pgm
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         p_effective_date           => p_effective_date,
         p_person_id 		    => p_person_id,
         p_lf_evt_ocrd_dt 	    => p_lf_evt_ocrd_dt );
      end if;



      --
      --   Eligible for Another Plan
      --
      if l_profile.rt_prtt_anthr_pl_flag = 'Y' then
      hr_utility.set_location('check_prtt_anthr_pl',10);
      check_prtt_anthr_pl
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         -- FONM : as lf_evt_ocrd_dt is not used, it's fine to overload the
         -- p_effective_date.
         p_effective_date         => nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                                      nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                       nvl(p_lf_evt_ocrd_dt, p_effective_date))),
         p_person_id 		    => p_person_id,
         p_lf_evt_ocrd_dt 	    => p_lf_evt_ocrd_dt );
      end if;



      --
      --   Eligible for Another Plan Type in Program
      --
      if l_profile.rt_othr_ptip_flag = 'Y' then
      hr_utility.set_location('check_othr_ptip',10);
      check_othr_ptip
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         -- FONM : do not overload as the lf_evt_ocrd_dt takes precedence over eff dt.
         p_effective_date           => p_effective_date,
         p_person_id 		    => p_person_id,
         p_lf_evt_ocrd_dt 	    => p_lf_evt_ocrd_dt );
      end if;


      --
      --   Enrolled in Another Plan
      --
      if l_profile.rt_enrld_pl_flag = 'Y' then
      hr_utility.set_location('check_enrld_anthr_pl',10);
      check_enrld_anthr_pl
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         -- FONM : do not overload eff date as determine_date is called.
         p_effective_date           => p_effective_date,
         p_person_id 		    => p_person_id,
         p_lf_evt_ocrd_dt 	    => p_lf_evt_ocrd_dt,
         p_pl_id		    => p_pl_id);
      end if;


      --
      --   Enrolled in Another Option In Plan
      --
      if l_profile.rt_enrld_oipl_flag = 'Y' then
      hr_utility.set_location('check_enrld_anthr_oipl',10);
      check_enrld_anthr_oipl
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         -- FONM : do not overload eff date as determine_date is called.
         p_effective_date           => p_effective_date,
         p_person_id 		    => p_person_id,
         p_lf_evt_ocrd_dt 	    => p_lf_evt_ocrd_dt,
         p_oipl_id		    => p_oipl_id);
      end if;


      --
      --   Enrolled in Another Plan in Program
      --
      if l_profile.rt_enrld_plip_flag = 'Y' then
      hr_utility.set_location('check_enrld_anthr_plip',10);
      check_enrld_anthr_plip
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         -- FONM : do not overload eff date as determine_date is called.
         p_effective_date           => p_effective_date,
         p_person_id 		    => p_person_id,
         p_lf_evt_ocrd_dt 	    => p_lf_evt_ocrd_dt);
      end if;


      --
      --   Enrolled in Another Plan Type in Program
      --
      if l_profile.rt_enrld_ptip_flag = 'Y' then
      hr_utility.set_location('check_enrld_anthr_ptip',10);
      check_enrld_anthr_ptip
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         -- FONM : do not overload eff date as determine_date is called.
         p_effective_date           => p_effective_date,
         p_lf_evt_ocrd_dt 	    => p_lf_evt_ocrd_dt);
      end if;

      --
      --   Enrolled in Another Program
      --
      if l_profile.rt_enrld_pgm_flag = 'Y' then
      hr_utility.set_location('check_enrld_anthr_pgm',10);
      check_enrld_anthr_pgm
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         p_pgm_id		    => p_pgm_id ,
         p_person_id 		    => p_person_id,
         -- FONM : do not overload eff date as determine_date is called.
         p_effective_date           => p_effective_date,
         p_lf_evt_ocrd_dt 	    => p_lf_evt_ocrd_dt );
      end if;

      --
      -- Dependent Other Plan Type in Program
      --
      if l_profile.rt_dpnt_othr_ptip_flag = 'Y' then
      hr_utility.set_location('check_dpnt_othr_ptip',10);
      check_dpnt_othr_ptip
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         -- FONM : as lf_evt_ocrd_dt is used, do not overload the
         -- p_effective_date.
         p_effective_date           => p_effective_date,
         p_person_id 		    => p_person_id,
         p_lf_evt_ocrd_dt 	    => p_lf_evt_ocrd_dt,
         p_per_in_ler_id	    => p_per_in_ler_id);
      end if;

      --
      -- No Other Coverage
      --
      if l_profile.rt_no_othr_cvg_flag = 'Y' then
      hr_utility.set_location('check_no_othr_cvg',10);
      check_no_othr_cvg
        (p_vrbl_rt_prfl_id          => l_profile.vrbl_rt_prfl_id,
         p_business_group_id        => p_business_group_id,
         p_person_id 		    => p_person_id,
         p_effective_date           => p_effective_date,
         p_lf_evt_ocrd_dt 	    => p_lf_evt_ocrd_dt);
      end if;

      --
      if not(p_all_prfls) then
        --
        -- when g_all_prfls is set, we want to determine all the profiles
        -- a person matches without considering the total-type criteria.
        -- then we'll call this procedure again, with those totals.
        -- When g_all_prfls is set, the totals passed in are the total
        -- number of people participating in the comp object that match
        -- the other criteria in the vrbl prfl.
        -- When it's not set, the totals are the total number
        -- of people participating in the comp object.
        --
        --          Total Number of Participants
        --
        hr_utility.set_location ('Total profs '||l_package,10);
        if l_profile.rt_ttl_prtt_flag = 'Y' then
        hr_utility.set_location('check_ttl_prtt',10);
        check_ttl_prtt
          (p_vrbl_rt_prfl_id      => l_profile.vrbl_rt_prfl_id,
           p_business_group_id    => p_business_group_id,
           p_effective_date       => p_effective_date,
           p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt,
           p_ttl_prtt             => l_ttl_prtt);
        end if;
        --
        --          Total Amount of Coverage
        --
        if l_profile.rt_ttl_cvg_vol_flag = 'Y' then
        hr_utility.set_location('check_ttl_cvg',10);
        check_ttl_cvg
          (p_vrbl_rt_prfl_id      => l_profile.vrbl_rt_prfl_id,
           p_business_group_id    => p_business_group_id,
           p_effective_date       => p_effective_date,
           p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt,
           p_ttl_cvg              => l_ttl_cvg);
        end if;
        --
      end if;
      --
      --           If we get this far then everything passed.
      --           Assign Variable Rate Id and get out -
      --           unless we want to find
      --           all the profiles a person matches.
      --
      l_vrbl_rt_prfl_id := l_profile.vrbl_rt_prfl_id;
      l_matched_vrbl_prfl  := 'Y';
      --
      hr_utility.set_location ('Load globals '||l_package,10);
      if p_all_prfls then
        --
        hr_utility.set_location ('p_all_prfls on ',20);
        --
        -- first time thru procedure where we are keeping track of all
        -- the profiles a person matches, without running the ttl-cvg
        -- and ttl-prtt's profiles.
        -- Using a table, keep track of the variable profiles matched and
        -- how many people matched the profiles.
        --
        load_globals (p_vrbl_rt_prfl_id => l_vrbl_rt_prfl_id
                     ,p_all_prfls       => true
                     ,p_use_prfls       => false
                     ,p_bnft_amt        => p_bnft_amt
                     ,p_ordr_num        => l_profile.ordr_num
                     ,p_asmt_to_use_cd     => l_profile.asmt_to_use_cd
                     ,p_rt_hrly_slrd_flag  => l_profile.rt_hrly_slrd_flag
                     ,p_rt_pstl_cd_flag    => l_profile.rt_pstl_cd_flag
                     ,p_rt_lbr_mmbr_flag   => l_profile.rt_lbr_mmbr_flag
                     ,p_rt_lgl_enty_flag   => l_profile.rt_lgl_enty_flag
                     ,p_rt_benfts_grp_flag => l_profile.rt_benfts_grp_flag
                     ,p_rt_wk_loc_flag     => l_profile.rt_wk_loc_flag
                     ,p_rt_brgng_unit_flag => l_profile.rt_brgng_unit_flag
                     ,p_rt_age_flag        => l_profile.rt_age_flag
                     ,p_rt_los_flag        => l_profile.rt_los_flag
                     ,p_rt_per_typ_flag    => l_profile.rt_per_typ_flag
                     ,p_rt_fl_tm_pt_tm_flag=> l_profile.rt_fl_tm_pt_tm_flag
                     ,p_rt_ee_stat_flag    => l_profile.rt_ee_stat_flag
                     ,p_rt_grd_flag        => l_profile.rt_grd_flag
                     ,p_rt_pct_fl_tm_flag  => l_profile.rt_pct_fl_tm_flag
                     ,p_rt_asnt_set_flag   => l_profile.rt_asnt_set_flag
                     ,p_rt_hrs_wkd_flag    => l_profile.rt_hrs_wkd_flag
                     ,p_rt_comp_lvl_flag   => l_profile.rt_comp_lvl_flag
                     ,p_rt_org_unit_flag   => l_profile.rt_org_unit_flag
                     ,p_rt_loa_rsn_flag    => l_profile.rt_loa_rsn_flag
                     ,p_rt_pyrl_flag       => l_profile.rt_pyrl_flag
                     ,p_rt_schedd_hrs_flag => l_profile.rt_schedd_hrs_flag
                     ,p_rt_py_bss_flag     => l_profile.rt_py_bss_flag
                     ,p_rt_prfl_rl_flag    => l_profile.rt_prfl_rl_flag
                     ,p_rt_cmbn_age_los_flag => l_profile.rt_cmbn_age_los_flag
                     ,p_rt_prtt_pl_flag    => l_profile.rt_prtt_pl_flag
                     ,p_rt_svc_area_flag   => l_profile.rt_svc_area_flag
                     ,p_rt_ppl_grp_flag    => l_profile.rt_ppl_grp_flag
                     ,p_rt_dsbld_flag      => l_profile.rt_dsbld_flag
                     ,p_rt_hlth_cvg_flag   => l_profile.rt_hlth_cvg_flag
                     ,p_rt_poe_flag        => l_profile.rt_poe_flag
                     ,p_rt_ttl_cvg_vol_flag=> l_profile.rt_ttl_cvg_vol_flag
                     ,p_rt_ttl_prtt_flag   => l_profile.rt_ttl_prtt_flag
                     ,p_rt_gndr_flag       => l_profile.rt_gndr_flag
                     ,p_rt_tbco_use_flag   => l_profile.rt_tbco_use_flag
                     ,p_rt_cntng_prtn_prfl_flag => l_profile.rt_cntng_prtn_prfl_flag
                     ,p_rt_cbr_quald_bnf_flag   => l_profile.rt_cbr_quald_bnf_flag
                     ,p_rt_optd_mdcr_flag	=> l_profile.rt_optd_mdcr_flag
                     ,p_rt_lvg_rsn_flag 	=> l_profile.rt_lvg_rsn_flag
                     ,p_rt_pstn_flag 	       	=> l_profile.rt_pstn_flag
                     ,p_rt_comptncy_flag 	=> l_profile.rt_comptncy_flag
                     ,p_rt_job_flag 		=> l_profile.rt_job_flag
                     ,p_rt_qual_titl_flag 	=> l_profile.rt_qual_titl_flag
                     ,p_rt_dpnt_cvrd_pl_flag	=> l_profile.rt_dpnt_cvrd_pl_flag
                     ,p_rt_dpnt_cvrd_plip_flag  => l_profile.rt_dpnt_cvrd_plip_flag
                     ,p_rt_dpnt_cvrd_ptip_flag  => l_profile.rt_dpnt_cvrd_ptip_flag
                     ,p_rt_dpnt_cvrd_pgm_flag   => l_profile.rt_dpnt_cvrd_pgm_flag
                     ,p_rt_enrld_oipl_flag	=> l_profile.rt_enrld_oipl_flag
                     ,p_rt_enrld_pl_flag	=> l_profile.rt_enrld_pl_flag
                     ,p_rt_enrld_plip_flag	=> l_profile.rt_enrld_plip_flag
                     ,p_rt_enrld_ptip_flag	=> l_profile.rt_enrld_ptip_flag
                     ,p_rt_enrld_pgm_flag	=> l_profile.rt_enrld_pgm_flag
                     ,p_rt_prtt_anthr_pl_flag   => l_profile.rt_prtt_anthr_pl_flag
                     ,p_rt_othr_ptip_flag	=> l_profile.rt_othr_ptip_flag
                     ,p_rt_no_othr_cvg_flag	=> l_profile.rt_no_othr_cvg_flag
                     ,p_rt_dpnt_othr_ptip_flag  => l_profile.rt_dpnt_othr_ptip_flag
                     ,p_rt_qua_in_gr_flag	=> l_profile.rt_qua_in_gr_flag
                     ,p_rt_perf_rtng_flag  	=> l_profile.rt_perf_rtng_flag
                     ,p_rt_elig_prfl_flag  	=> l_profile.rt_elig_prfl_flag
                     );
        --
      else
        -- Bug 1211317: changed to use new parm.
        if p_use_prfls then
          --
          hr_utility.set_location ('p_use_globals on ',21);
          --
          -- our second time thru this procedure where we are
          -- determining which profile a person matches with
          -- ttl_cvg and ttl_prtt taken into account.  Keep track
          -- of number of people that match the profiles.
          --
          load_globals (p_vrbl_rt_prfl_id => l_vrbl_rt_prfl_id
                       ,p_all_prfls       => false
                       ,p_use_prfls       => true
                       ,p_bnft_amt        => p_bnft_amt
                       ,p_ordr_num        => null
                     ,p_asmt_to_use_cd     => l_profile.asmt_to_use_cd
                     ,p_rt_hrly_slrd_flag  => l_profile.rt_hrly_slrd_flag
                     ,p_rt_pstl_cd_flag    => l_profile.rt_pstl_cd_flag
                     ,p_rt_lbr_mmbr_flag   => l_profile.rt_lbr_mmbr_flag
                     ,p_rt_lgl_enty_flag   => l_profile.rt_lgl_enty_flag
                     ,p_rt_benfts_grp_flag => l_profile.rt_benfts_grp_flag
                     ,p_rt_wk_loc_flag     => l_profile.rt_wk_loc_flag
                     ,p_rt_brgng_unit_flag => l_profile.rt_brgng_unit_flag
                     ,p_rt_age_flag        => l_profile.rt_age_flag
                     ,p_rt_los_flag        => l_profile.rt_los_flag
                     ,p_rt_per_typ_flag    => l_profile.rt_per_typ_flag
                     ,p_rt_fl_tm_pt_tm_flag=> l_profile.rt_fl_tm_pt_tm_flag
                     ,p_rt_ee_stat_flag    => l_profile.rt_ee_stat_flag
                     ,p_rt_grd_flag        => l_profile.rt_grd_flag
                     ,p_rt_pct_fl_tm_flag  => l_profile.rt_pct_fl_tm_flag
                     ,p_rt_asnt_set_flag   => l_profile.rt_asnt_set_flag
                     ,p_rt_hrs_wkd_flag    => l_profile.rt_hrs_wkd_flag
                     ,p_rt_comp_lvl_flag   => l_profile.rt_comp_lvl_flag
                     ,p_rt_org_unit_flag   => l_profile.rt_org_unit_flag
                     ,p_rt_loa_rsn_flag    => l_profile.rt_loa_rsn_flag
                     ,p_rt_pyrl_flag       => l_profile.rt_pyrl_flag
                     ,p_rt_schedd_hrs_flag => l_profile.rt_schedd_hrs_flag
                     ,p_rt_py_bss_flag     => l_profile.rt_py_bss_flag
                     ,p_rt_prfl_rl_flag    => l_profile.rt_prfl_rl_flag
                     ,p_rt_cmbn_age_los_flag => l_profile.rt_cmbn_age_los_flag
                     ,p_rt_prtt_pl_flag    => l_profile.rt_prtt_pl_flag
                     ,p_rt_svc_area_flag   => l_profile.rt_svc_area_flag
                     ,p_rt_ppl_grp_flag    => l_profile.rt_ppl_grp_flag
                     ,p_rt_dsbld_flag      => l_profile.rt_dsbld_flag
                     ,p_rt_hlth_cvg_flag   => l_profile.rt_hlth_cvg_flag
                     ,p_rt_poe_flag        => l_profile.rt_poe_flag
                     ,p_rt_ttl_cvg_vol_flag=> l_profile.rt_ttl_cvg_vol_flag
                     ,p_rt_ttl_prtt_flag   => l_profile.rt_ttl_prtt_flag
                     ,p_rt_gndr_flag       => l_profile.rt_gndr_flag
                     ,p_rt_tbco_use_flag   => l_profile.rt_tbco_use_flag
                     ,p_rt_cntng_prtn_prfl_flag => l_profile.rt_cntng_prtn_prfl_flag
                     ,p_rt_cbr_quald_bnf_flag   => l_profile.rt_cbr_quald_bnf_flag
                     ,p_rt_optd_mdcr_flag	=> l_profile.rt_optd_mdcr_flag
                     ,p_rt_lvg_rsn_flag 	=> l_profile.rt_lvg_rsn_flag
                     ,p_rt_pstn_flag 	       	=> l_profile.rt_pstn_flag
                     ,p_rt_comptncy_flag 	=> l_profile.rt_comptncy_flag
                     ,p_rt_job_flag 		=> l_profile.rt_job_flag
                     ,p_rt_qual_titl_flag 	=> l_profile.rt_qual_titl_flag
                     ,p_rt_dpnt_cvrd_pl_flag	=> l_profile.rt_dpnt_cvrd_pl_flag
                     ,p_rt_dpnt_cvrd_plip_flag  => l_profile.rt_dpnt_cvrd_plip_flag
                     ,p_rt_dpnt_cvrd_ptip_flag  => l_profile.rt_dpnt_cvrd_ptip_flag
                     ,p_rt_dpnt_cvrd_pgm_flag   => l_profile.rt_dpnt_cvrd_pgm_flag
                     ,p_rt_enrld_oipl_flag	=> l_profile.rt_enrld_oipl_flag
                     ,p_rt_enrld_pl_flag	=> l_profile.rt_enrld_pl_flag
                     ,p_rt_enrld_plip_flag	=> l_profile.rt_enrld_plip_flag
                     ,p_rt_enrld_ptip_flag	=> l_profile.rt_enrld_ptip_flag
                     ,p_rt_enrld_pgm_flag	=> l_profile.rt_enrld_pgm_flag
                     ,p_rt_prtt_anthr_pl_flag   => l_profile.rt_prtt_anthr_pl_flag
                     ,p_rt_othr_ptip_flag	=> l_profile.rt_othr_ptip_flag
                     ,p_rt_no_othr_cvg_flag	=> l_profile.rt_no_othr_cvg_flag
                     ,p_rt_dpnt_othr_ptip_flag  => l_profile.rt_dpnt_othr_ptip_flag
                     ,p_rt_qua_in_gr_flag	=> l_profile.rt_qua_in_gr_flag
                     ,p_rt_perf_rtng_flag 	=> l_profile.rt_perf_rtng_flag
                     ,p_rt_elig_prfl_flag       => l_profile.rt_elig_prfl_flag
                    );

          --
        end if;
        --
        exit;
        --
      end if;
      --
    exception
      --
      when ben_evaluate_rate_profiles.g_profile_failed then
        --
        --            If profile failed one of the criteria,
        --            go onto next profile.
        --
        hr_utility.set_location ('g_profile_failed '||l_package,10);
        NULL;
        --
      -- begin bug # 2436338
      when g_criteria_failed then
	--
	--            If profile failed one of the criteria,
	--            go onto next profile.
	--
	hr_utility.set_location ('g_profile_failed '||l_package,10);
	NULL;
        --
       -- end bug # 2436338
    end;
    --
  end loop;
  hr_utility.set_location ('Dn Prof loop '||l_package,10);
  --
  if l_matched_vrbl_prfl = 'N' then
    --
    if p_all_prfls or p_use_globals then
      --
      -- the person didn't match any variable profiles,
      -- add to no-match count.  This doesn't count people twice,
      -- because the second time thru we only loop thru those people
      -- who did match profiles the first time thru.
      --
      g_no_match_cnt := g_no_match_cnt + 1;
      g_no_match_cvg := g_no_match_cvg + p_bnft_amt;
      --
      hr_utility.set_location ('did not match profile :'||
                to_char(p_person_id)||' cnt:'||
                to_char(g_no_match_cnt),88);
      --
    end if;
    --
  end if;
  --
  p_vrbl_rt_prfl_id := l_vrbl_rt_prfl_id;
  --
  hr_utility.set_location ('Leaving '||l_package,99);
  --
end main;
--
end ben_evaluate_rate_profiles;

/
