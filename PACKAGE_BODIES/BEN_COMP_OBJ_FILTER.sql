--------------------------------------------------------
--  DDL for Package Body BEN_COMP_OBJ_FILTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COMP_OBJ_FILTER" as
/* $Header: bebmfilt.pkb 120.6.12010000.4 2010/02/09 05:24:56 krupani ship $ */
--
type g_procptip is record
  (ptip_id  number
  ,eligible boolean
  );
--
type g_procptip_set is table of g_procptip index by binary_integer;
--
-- Processed PTIP list
--
g_procptip_list g_procptip_set;
--
g_package varchar2(50) := 'ben_comp_obj_filter.';
g_hash_key number      := ben_hash_utility.get_hash_key;
g_hash_jump number     := ben_hash_utility.get_hash_jump;
--
function check_dupproc_ptip
  (p_ptip_id in     number
  )
return boolean
is
  --
  l_package    varchar2(80) := g_package||'.check_dupproc_ptip';
  --
  l_hv         pls_integer;
  --
begin
  --
--  hr_utility.set_location ('Entering ' || l_package,10);
  --
  -- Get the hashed value for the ptip
  --
  l_hv := mod(p_ptip_id,g_hash_key);
  --
  -- Check for list entry.  if none exists the NO_DATA_FOUND exception
  -- will fire.
  --
  if g_procptip_list(l_hv).ptip_id = p_ptip_id then
    --
    return true;
    --
  --
  -- A clash has been found
  --
  else
    --
    -- Loop through the hash using the jump routine to check further
    -- indexes if none exists at current index the NO_DATA_FOUND expection
    -- will fire
    --
    while g_procptip_list(l_hv).ptip_id <> p_ptip_id loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
  end if;
  --
--  hr_utility.set_location ('Leaving '||l_package,10);
  --
exception when NO_DATA_FOUND then
  --
  -- No value stored for the hashed value due to the error being raised.
  -- We are dealing with a unique PTIP. Add the PTIP to the list
  --
  g_procptip_list(l_hv).ptip_id := p_ptip_id;
  --
  -- Initialise the ptip eligible flag to false this will be set at
  -- the end of eligibility to the determined eligibility result.
  --
  g_procptip_list(l_hv).eligible := false;
  --
  return false;
  --
end check_dupproc_ptip;
--
procedure flush_dupproc_ptip_list

is
  --
  l_package    varchar2(80) := g_package||'.flush_dupproc_ptip_list';
  --
  l_dupptip    boolean;
  --
begin
  --
  g_procptip_list.delete;
  --
end flush_dupproc_ptip_list;
--
procedure set_dupproc_ptip_elig
  (p_ptip_id  in     number
  ,p_eligible in     boolean
  )
is
  --
  l_package    varchar2(80) := g_package||'.set_dupproc_ptip_elig';
  --
  l_hv         pls_integer;
  --
begin
  --
  hr_utility.set_location ('Entering ' || l_package,10);
  --
  -- Get the hashed value for the ptip
  --
  l_hv := ben_hash_utility.get_hashed_index(p_id => p_ptip_id);
  --
  -- Check for list entry.  if none exists the NO_DATA_FOUND exception
  -- will fire.
  --
  if g_procptip_list(l_hv).ptip_id = p_ptip_id then
    --
    g_procptip_list(l_hv).eligible := p_eligible;
    --
  --
  -- A clash has been found
  --
  else
    --
    -- Loop through the hash using the jump routine to check further
    -- indexes if none exists at current index the NO_DATA_FOUND expection
    -- will fire
    --
    while g_procptip_list(l_hv).ptip_id <> p_ptip_id loop
      --
      l_hv := ben_hash_utility.get_next_hash_index(p_hash_index => l_hv);
      --
    end loop;
    --
    g_procptip_list(l_hv).eligible := p_eligible;
    --
  end if;
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
exception when NO_DATA_FOUND then
  --
  -- No value stored for the hashed value due to the error being raised.
  -- We are dealing with a unique PTIP. Add the PTIP to the list
  --
  hr_Utility.set_location('hit no_data_found condition',10);
  g_procptip_list(l_hv).ptip_id := p_ptip_id;
  --
  -- Initialise the ptip eligible flag to false this will be set at
  -- the end of eligibility to the determined eligibility result.
  --
  g_procptip_list(l_hv).eligible := p_eligible;
  --
  return;
  --
end set_dupproc_ptip_elig;
--
function get_dupproc_ptip_elig
  (p_ptip_id in     number
  )
return boolean
is
  --
  l_package    varchar2(80) := g_package||'.get_dupproc_ptip_elig';
  --
  l_hv         pls_integer;
  --
begin
  --
  hr_utility.set_location ('Entering ' || l_package,10);
  --
  -- Get the hashed value for the ptip
  --
  l_hv := ben_hash_utility.get_hashed_index(p_id => p_ptip_id);
  --
  -- Check for list entry.  if none exists the NO_DATA_FOUND exception
  -- will fire.
  --
  if g_procptip_list(l_hv).ptip_id = p_ptip_id then
    --
    return g_procptip_list(l_hv).eligible;
    --
  --
  -- A clash has been found
  --
  else
    --
    -- Loop through the hash using the jump routine to check further
    -- indexes if none exists at current index the NO_DATA_FOUND expection
    -- will fire
    --
    while g_procptip_list(l_hv).ptip_id <> p_ptip_id loop
      --
      l_hv := ben_hash_utility.get_next_hash_index(p_hash_index => l_hv);
      --
    end loop;
    --
    return g_procptip_list(l_hv).eligible;
    --
  end if;
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
exception when NO_DATA_FOUND then
  --
  -- No value stored for the hashed value due to the error being raised.
  -- We are dealing with a unique PTIP. Add the PTIP to the list
  --
  hr_Utility.set_location('hit no_data_found condition',20);
  g_procptip_list(l_hv).ptip_id := p_ptip_id;
  --
  -- Initialise the ptip eligible flag to false this will be set at
  -- the end of eligibility to the determined eligibility result.
  --
  g_procptip_list(l_hv).eligible := false;
  --
  return false;
  --
end get_dupproc_ptip_elig;
--
procedure set_parent_elig_flags
  (p_comp_obj_tree_row in     ben_manage_life_events.g_cache_proc_objects_rec
  ,p_eligible          in     boolean
  ,p_treeele_num       in     pls_integer
  --
  ,p_par_elig_state    in out nocopy ben_comp_obj_filter.g_par_elig_state_rec
  )
is
  --
  l_package    varchar2(80) := g_package||'.set_parent_elig_flags';
  --
  l_hv         pls_integer;
  --
begin
  --
--  hr_utility.set_location ('Entering ' || l_package,10);
  --
  if p_eligible then
    --
    if p_comp_obj_tree_row.pgm_id is not null then
      --
      p_par_elig_state.elig_for_pgm_flag := 'Y';
      --
    elsif p_comp_obj_tree_row.ptip_id is not null then
      --
      -- Set the PTIP eligibility in the duplicate PTIP list
      --
      set_dupproc_ptip_elig
        (p_ptip_id  => p_comp_obj_tree_row.ptip_id
        ,p_eligible => TRUE
        );
      --
      p_par_elig_state.elig_for_ptip_flag  := 'Y';
      --
    elsif p_comp_obj_tree_row.plip_id is not null then
      --
      p_par_elig_state.elig_for_plip_flag  := 'Y';
      --
    elsif p_comp_obj_tree_row.pl_id is not null then
      --
      p_par_elig_state.elig_for_pl_flag  := 'Y';
      --
    end if;
    --
  elsif not p_eligible then
    --
    if p_comp_obj_tree_row.pgm_id is not null then
      --
      -- When in-eligible for the program cannot be eligible for
      -- sub comp objects
      --
      p_par_elig_state.elig_for_pgm_flag  := 'N';
      p_par_elig_state.elig_for_ptip_flag := 'N';
      p_par_elig_state.elig_for_plip_flag := 'N';
      p_par_elig_state.elig_for_pl_flag   := 'N';
      --
    elsif p_comp_obj_tree_row.ptip_id is not null then
      --
      -- Set the PTIP eligibility in the duplicate PTIP list
      --
      set_dupproc_ptip_elig
        (p_ptip_id  => p_comp_obj_tree_row.ptip_id
        ,p_eligible => FALSE
        );
      --
      -- When in-eligible for the ptip cannot be eligible for
      -- sub comp objects
      --
      p_par_elig_state.elig_for_ptip_flag := 'N';
      p_par_elig_state.elig_for_plip_flag := 'N';
      p_par_elig_state.elig_for_pl_flag   := 'N';
      --
    elsif p_comp_obj_tree_row.plip_id is not null then
      --
      -- When in-eligible for the ptip cannot be eligible for
      -- sub comp objects
      --
      p_par_elig_state.elig_for_plip_flag := 'N';
      p_par_elig_state.elig_for_pl_flag   := 'N';
      --
    elsif p_comp_obj_tree_row.pl_id is not null then
      --
      p_par_elig_state.elig_for_pl_flag := 'N';
      --
    end if;
    --
  end if;
  --
--  hr_utility.set_location ('Leaving '||l_package,10);
  --
end set_parent_elig_flags;
--
procedure set_bound_parent_elig_flags
  (p_comp_obj_tree_row in     ben_manage_life_events.g_cache_proc_objects_rec
  --
  ,p_par_elig_state    in out nocopy ben_comp_obj_filter.g_par_elig_state_rec
  )
is
  --
  l_package               varchar2(80) := g_package||'.set_bound_parent_elig_flags';
  --
begin
  --
--  hr_utility.set_location ('Entering ' || l_package,10);
  --
  if p_comp_obj_tree_row.pl_id is not null
    and p_comp_obj_tree_row.pl_nip = 'N'
  then
    --
    p_par_elig_state.elig_for_pl_flag := 'Y';
    --
  elsif p_comp_obj_tree_row.pl_id is not null
    and p_comp_obj_tree_row.pl_nip = 'Y'
  then
    --
    p_par_elig_state.elig_for_pgm_flag  := 'Y';
    p_par_elig_state.elig_for_ptip_flag := 'Y';
    p_par_elig_state.elig_for_plip_flag := 'Y';
    p_par_elig_state.elig_for_pl_flag   := 'Y';
    --
  elsif p_comp_obj_tree_row.plip_id is not null then
    --
    p_par_elig_state.elig_for_plip_flag := 'Y';
    p_par_elig_state.elig_for_pl_flag   := 'Y';
    --
  elsif p_comp_obj_tree_row.ptip_id is not null then
    --
  --  hr_utility.set_location ('BENMGLEINPEFPTIP: '||p_comp_obj_tree_row.ptip_id,20);
    --
    p_par_elig_state.elig_for_ptip_flag := 'Y';
    p_par_elig_state.elig_for_plip_flag := 'Y';
    p_par_elig_state.elig_for_pl_flag   := 'Y';
    --
  elsif p_comp_obj_tree_row.pgm_id is not null then
    --
    hr_utility.set_location ('BENMGLEINPEFPGM: '||p_comp_obj_tree_row.pgm_id,20);
    --
    p_par_elig_state.elig_for_pgm_flag  := 'Y';
    p_par_elig_state.elig_for_ptip_flag := 'Y';
    p_par_elig_state.elig_for_plip_flag := 'Y';
    p_par_elig_state.elig_for_pl_flag   := 'Y';
    --
  end if;
  --
--  hr_utility.set_location ('Leaving '||l_package,10);
  --
end set_bound_parent_elig_flags;
--
function check_prevelig_compobj
  (p_comp_obj_tree_row in     ben_manage_life_events.g_cache_proc_objects_rec
  ,p_business_group_id in     number
  ,p_person_id         in     number
  ,p_effective_date    in     date
  )
return boolean
is
  --
  l_package   varchar2(80) := g_package||'.check_prevelig_compobj';
  --
  l_inst_row  ben_derive_part_and_rate_facts.g_cache_structure;
  --
  l_prevelig   boolean;
  l_dummy_number   number;
  --
begin
  --
  l_prevelig := false;
  --
  if p_comp_obj_tree_row.pgm_id is not null then
    --
    l_prevelig := false;
    --
  elsif p_comp_obj_tree_row.ptip_id is not null then
    --
  --  hr_utility.set_location ('PTIP PILPEP ' || l_package,10);
    --
    ben_pep_cache.get_pilpep_dets
      (p_person_id         => p_person_id
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_pgm_id            => p_comp_obj_tree_row.par_pgm_id
      ,p_ptip_id           => p_comp_obj_tree_row.ptip_id
      ,p_inst_row          => l_inst_row
      ,p_date_sync         => true
      );
    --
    if nvl(l_inst_row.elig_flag,'N') = 'Y'
    then
      --
      l_prevelig := TRUE;
      --
    end if;
    --
  --  hr_utility.set_location ('Dn PTIP PILPEP ' || l_package,10);
    --
  elsif p_comp_obj_tree_row.plip_id is not null then
    --
  --  hr_utility.set_location ('PLIP PILPEP ' || l_package,10);
    --
    ben_pep_cache.get_pilpep_dets
      (p_person_id         => p_person_id
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_pgm_id            => p_comp_obj_tree_row.par_pgm_id
      ,p_plip_id           => p_comp_obj_tree_row.plip_id
      ,p_inst_row          => l_inst_row
      ,p_date_sync         => true
      );
    --
    if nvl(l_inst_row.elig_flag,'N') = 'Y'
    then
      --
      l_prevelig := TRUE;
      --
    end if;
    --
  --  hr_utility.set_location ('Dn PLIP PILPEP ' || l_package,10);
    --
  elsif p_comp_obj_tree_row.pl_id is not null
  then
    --
  --  hr_utility.set_location ('PL PILPEP ' || l_package,10);
    --
    ben_pep_cache.get_pilpep_dets
      (p_person_id         => p_person_id
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_pgm_id            => p_comp_obj_tree_row.par_pgm_id
      ,p_pl_id             => p_comp_obj_tree_row.pl_id
      ,p_inst_row          => l_inst_row
      ,p_date_sync         => true
      );
    --
    if nvl(l_inst_row.elig_flag,'N') = 'Y'
    then
      --
      l_prevelig := TRUE;
      --
    end if;
    --
  --  hr_utility.set_location ('Dn PL PILPEP ' || l_package,10);
    --
  elsif p_comp_obj_tree_row.oipl_id is not null then
    --
  --  hr_utility.set_location ('OIPL PILPEP ' || l_package,10);
    -- Bug 8351660: passed the fonm date in the call to ben_pep_cache.get_pilepo_dets
    ben_pep_cache.get_pilepo_dets
      (p_person_id         => p_person_id
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,p_effective_date)
      ,p_pgm_id            => p_comp_obj_tree_row.par_pgm_id
      ,p_pl_id             => p_comp_obj_tree_row.par_pl_id
      ,p_opt_id            => p_comp_obj_tree_row.par_opt_id
      ,p_inst_row      => l_inst_row
      );
    --
    if nvl(l_inst_row.elig_flag,'N') = 'Y'
    then
      --
      l_prevelig := TRUE;
      --
    end if;
    --
  --  hr_utility.set_location ('Dn OIPL PILPEP ' || l_package,10);
    --
  end if;
  --
  return l_prevelig;
  --
end check_prevelig_compobj;
--
function check_selection_rule
    (p_person_selection_rule_id in number,
     p_person_id                in number,
     p_business_group_id        in number,
     p_effective_date           in date) return boolean is
  --
  l_outputs       ff_exec.outputs_t;
  l_assignment_id number;
  l_package varchar2(80) := g_package||'.check_selection_rule';
  --
begin
  --
  if p_person_selection_rule_id is null then
    --
    return true;
    --
  else
    --
    l_assignment_id := benutils.get_assignment_id
                         (p_person_id         => p_person_id,
                          p_business_group_id => p_business_group_id,
                          p_effective_date    => p_effective_date);
    --
    l_outputs := benutils.formula
      (p_formula_id     => p_person_selection_rule_id,
       p_effective_date => p_effective_date,
       p_business_group_id => p_business_group_id,
       p_assignment_id  => l_assignment_id,
       p_param1         => 'BEN_IV_PERSON_ID',         -- Bug 5331889
       p_param1_value   => to_char(p_person_id));
    --
    if l_outputs(l_outputs.first).value = 'Y' then
      --
      return true;
      --
    elsif l_outputs(l_outputs.first).value = 'N' then
      --
      return false;
      --
    elsif l_outputs(l_outputs.first).value <> 'N' then
      --
      fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
      fnd_message.set_token('RL','person_selection_rule_id');
      fnd_message.set_token('PROC',l_package);
      raise ben_manage_life_events.g_record_error;
      --
    end if;
    --
  end if;
end check_selection_rule;
--
procedure filter_comp_objects
  (p_comp_obj_tree         in     ben_manage_life_events.g_cache_proc_object_table
  ,p_mode                  in     varchar
  ,p_person_id             in     number
  ,p_effective_date        in     date
  ,p_maxtreeele_num        in     pls_integer
  --
  ,p_par_elig_state        in out nocopy ben_comp_obj_filter.g_par_elig_state_rec
  ,p_treeele_num           in out nocopy pls_integer
  --
  ,p_treeloop                 out nocopy boolean
  ,p_ler_id                in     number default null
  ,p_lf_evt_ocrd_dt        in     date default null
  -- ,p_popl_enrt_typ_cycl_id in     number default null
  ,p_business_group_id     in     number default null
  )
is
  --
  l_package  varchar2(80) := g_package||'filter_comp_objects';
  --
  l_comp_obj_tree            ben_manage_life_events.g_cache_proc_object_table;
  l_comp_obj_tree_row        ben_manage_life_events.g_cache_proc_objects_rec;
  l_par_elig_state           ben_comp_obj_filter.g_par_elig_state_rec;
  --
  l_boundary                 boolean;
  l_treeloop                 boolean;
  --
  l_pgm_id                   number;
  l_ptip_id                  number;
  l_plip_id                  number;
  l_pl_id                    number;
  l_oipl_id                  number;
  l_pl_nip                   varchar2(30);
  --
  l_treeele_num              pls_integer;
  --
  l_failed_rule              boolean;
  --
  cursor c_lee_rsn_rl_pgm is
  select formula_id
  FROM     ben_lee_rsn_f leer,
           ben_popl_enrt_typ_cycl_f petc,
           ben_lee_rsn_rl_f lrr
  WHERE    leer.ler_id = p_ler_id
  AND      p_effective_date BETWEEN leer.effective_start_date
              AND leer.effective_end_date
  AND      leer.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
  AND      petc.pgm_id = l_pgm_id
  AND      petc.enrt_typ_cycl_cd = 'L'
  AND      p_effective_date BETWEEN petc.effective_start_date
              AND petc.effective_end_date
  and      p_effective_date between
              lrr.effective_start_date and lrr.effective_end_date
  and      lrr.lee_rsn_id=leer.lee_rsn_id
  and      lrr.business_group_id=leer.business_group_id
  order by ordr_to_aply_num;
  --
  -- bug - 4644355 - changed pgm_id to pl_id below
  --
  cursor c_lee_rsn_rl_plnip is
  select formula_id
  FROM     ben_lee_rsn_f leer,
           ben_popl_enrt_typ_cycl_f petc,
           ben_lee_rsn_rl_f lrr
  WHERE    leer.ler_id = p_ler_id
  AND      p_effective_date BETWEEN leer.effective_start_date
              AND leer.effective_end_date
  AND      leer.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
  AND      petc.pl_id = l_pl_id
  AND      petc.enrt_typ_cycl_cd = 'L'
  AND      p_effective_date BETWEEN petc.effective_start_date
              AND petc.effective_end_date
  and      p_effective_date between
              lrr.effective_start_date and lrr.effective_end_date
  and      lrr.lee_rsn_id=leer.lee_rsn_id
  and      lrr.business_group_id=leer.business_group_id
  order by ordr_to_aply_num;
  --
  cursor c_schedd_enrt_rl_pgm is
  select formula_id
  from ben_schedd_enrt_rl_f lrr,
       ben_popl_enrt_typ_cycl_f pet,
       ben_enrt_perd enp
  where  pet.pgm_id = l_pgm_id
   and   p_effective_date
           between pet.effective_start_date
           and     pet.effective_end_date
   and   pet.popl_enrt_typ_cycl_id =
         enp.popl_enrt_typ_cycl_id
   -- PB : 5422 :
   and    enp.asnd_lf_evt_dt  = p_lf_evt_ocrd_dt
   /* 5422 : PB :and   enp.strt_dt = (select enp1.strt_dt
                        from   ben_enrt_perd enp1
                        where  enp1.enrt_perd_id
                               = p_popl_enrt_typ_cycl_id) */
   and   enp.business_group_id   =
         pet.business_group_id
   and   p_effective_date between
           lrr.effective_start_date and lrr.effective_end_date
   and   lrr.enrt_perd_id=enp.enrt_perd_id
   and   lrr.business_group_id=enp.business_group_id
  order by ordr_to_aply_num;
  --
  cursor c_schedd_enrt_rl_plnip is
  select formula_id
  from ben_schedd_enrt_rl_f lrr,
       ben_popl_enrt_typ_cycl_f pet,
       ben_enrt_perd enp
  -- CWB changes
  where  pet.pl_id = l_pl_id
   and   p_effective_date
           between pet.effective_start_date
           and     pet.effective_end_date
   and   pet.popl_enrt_typ_cycl_id =
         enp.popl_enrt_typ_cycl_id
   -- PB : 5422 :
   and    enp.asnd_lf_evt_dt  = p_lf_evt_ocrd_dt
   /* and   enp.strt_dt = (select enp1.strt_dt
                        from   ben_enrt_perd enp1
                        where  enp1.enrt_perd_id
                               = p_popl_enrt_typ_cycl_id) */
   and   enp.business_group_id   =
         pet.business_group_id
   and   p_effective_date between
           lrr.effective_start_date and lrr.effective_end_date
   and   lrr.enrt_perd_id=enp.enrt_perd_id
   and   lrr.business_group_id=enp.business_group_id
  order by ordr_to_aply_num;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  l_par_elig_state := p_par_elig_state;
  l_treeele_num    := p_treeele_num;
  --
  l_boundary       := FALSE;
  --
  -- Comp object navigation loop. Only loop if a boundary is hit
  --
  loop
    hr_utility.set_location ('St CO Tree Loop  '||l_package,10);
    --
    -- Set comp object tree row record
    --
    l_comp_obj_tree_row := p_comp_obj_tree(l_treeele_num);
    --
    l_pgm_id    := p_comp_obj_tree(l_treeele_num).pgm_id;
    l_ptip_id   := p_comp_obj_tree(l_treeele_num).ptip_id;
    l_plip_id   := p_comp_obj_tree(l_treeele_num).plip_id;
    l_pl_id     := p_comp_obj_tree(l_treeele_num).pl_id;
    l_oipl_id   := p_comp_obj_tree(l_treeele_num).oipl_id;
    l_pl_nip    := p_comp_obj_tree(l_treeele_num).pl_nip;
    --
    -- Initialise parent eligibility flags
    --
    if l_pgm_id is not null then
      hr_utility.set_location ('PGM Chk  '||l_package,10);
      --
      l_failed_rule:=false;
      -- PB : 5422 : if p_popl_enrt_typ_cycl_id is not null then
      if p_lf_evt_ocrd_dt is not null then
        for l_person_selection in c_schedd_enrt_rl_pgm loop
          if l_person_selection.formula_id is not null then
            if check_selection_rule
              (p_person_selection_rule_id =>l_person_selection.formula_id,
               p_person_id                =>p_person_id,
               p_business_group_id        =>p_business_group_id,
               p_effective_date           =>p_effective_date) then
              hr_utility.set_location('Rule passed for pgm',15);
            else
              l_failed_rule:=true;
              exit;
            end if;
          end if;
        end loop;
      elsif p_ler_id is not null then
        for l_person_selection in c_lee_rsn_rl_pgm loop
          if l_person_selection.formula_id is not null then
            if check_selection_rule
              (p_person_selection_rule_id =>l_person_selection.formula_id,
               p_person_id                =>p_person_id,
               p_business_group_id        =>p_business_group_id,
               p_effective_date           =>p_effective_date) then
              hr_utility.set_location('Rule passed for pgm',15);
            else
              hr_utility.set_location('Rule failed for pgm',15);
              l_failed_rule:=true;
              exit;
            end if;
          end if;
        end loop;
      end if;
      if l_failed_rule then
        loop
          l_treeele_num:=l_treeele_num+1;
          if l_treeele_num>p_maxtreeele_num then
            l_treeloop := FALSE;
            exit;
          end if;
          --
          -- Check for a program or plan not in program boundary
          --
          if p_comp_obj_tree(l_treeele_num).pgm_id is not null
            or p_comp_obj_tree(l_treeele_num).pl_nip = 'Y' then
            --
            -- At next program or plan not in program
            -- return to outer loop to see if this one is OK
            --
            l_boundary := TRUE;
            exit;
            --
          end if;
        end loop;
      else
        hr_utility.set_location ('BENMGLEINPEFPGM: '||l_pgm_id,20);
        --
        -- Set parent eligibility flag info
        --
        l_par_elig_state.elig_for_pgm_flag  := 'Y';
        l_par_elig_state.elig_for_ptip_flag := 'Y';
        l_par_elig_state.elig_for_plip_flag := 'Y';
        l_par_elig_state.elig_for_pl_flag   := 'Y';
        --
        l_boundary := FALSE;
      end if;
      --
    elsif l_ptip_id is not null then
--      hr_utility.set_location ('PTIP Chk  '||l_package,10);
      --
      l_boundary := FALSE;
      --
--      hr_utility.set_location ('BENMGLEINPEFPTIP: '||l_ptip_id,20);
      --
      -- Check that the PTIP has not been processed. When the PTIP
      -- has already been processed navigate to the next comp object.
      -- PTIPs can be duplicated in the comp object list when there
      -- are two PLIPs within an individual program with the same plan
      -- type.
      --
      if check_dupproc_ptip
          (p_ptip_id => l_ptip_id
          )
      then
        --
        -- Set parent eligibility flags based on the processed PTIP
        -- eligible state.
        --
        set_parent_elig_flags
          (p_comp_obj_tree_row => l_comp_obj_tree_row
          ,p_eligible          => get_dupproc_ptip_elig
                                    (p_ptip_id => l_ptip_id
                                    )
          ,p_treeele_num       => l_treeele_num
          --
          ,p_par_elig_state    => l_par_elig_state
          );
        --
        l_treeele_num := l_treeele_num+1;
        --
      --
      -- Check parent comp object eligibility
      -- When the program is in-eligible then do not process any sub comp objects
      -- navigate to the next ptip.
      --
      elsif l_par_elig_state.elig_for_pgm_flag = 'N'
        and p_comp_obj_tree(l_treeele_num).trk_inelig_per_flag = 'N'
        and p_mode <> 'T'
      then
        --
        loop
          --
          -- Check for a program or plan not in program boundary
          --
          if p_comp_obj_tree(l_treeele_num).pgm_id is not null
            or p_comp_obj_tree(l_treeele_num).pl_nip = 'Y'
          then
            --
            -- Reset parent eligibility flags based on boundary crossed
            --
            set_bound_parent_elig_flags
              (p_comp_obj_tree_row => p_comp_obj_tree(l_treeele_num)
              --
              ,p_par_elig_state    => l_par_elig_state
              );
            --
            l_boundary := TRUE;
            exit;
            --
          --
          -- Check for a PTIP in the same program
          -- with track in-eligibility set
          --
          elsif p_comp_obj_tree(l_treeele_num).ptip_id is not null
            and p_comp_obj_tree(l_treeele_num).trk_inelig_per_flag = 'Y'
          then
            --
            -- Check for a duplicate ptip being processed
            --
            if check_dupproc_ptip
                (p_ptip_id => p_comp_obj_tree(l_treeele_num).ptip_id
                )
            then
              --
              -- Set parent eligibility flags based on the processed PTIP
              -- eligible state.
              --
              set_parent_elig_flags
                (p_comp_obj_tree_row => l_comp_obj_tree_row
                ,p_eligible          => get_dupproc_ptip_elig
                                          (p_ptip_id => p_comp_obj_tree(l_treeele_num).ptip_id
                                          )
                ,p_treeele_num       => l_treeele_num
                --
                ,p_par_elig_state    => l_par_elig_state
                );
              --
              l_treeele_num := l_treeele_num+1;
              --
            else
              --
              exit;
              --
            end if;
          --
          -- Check if the last row of the comp object list has been reached
          -- otherwise navigate to the next row
          --
          elsif l_treeele_num = p_maxtreeele_num then
            --
            l_treeloop := FALSE;
            exit;
            --
          elsif check_prevelig_compobj
                  (p_comp_obj_tree_row => p_comp_obj_tree(l_treeele_num)
                  ,p_business_group_id => p_business_group_id
                  ,p_person_id         => p_person_id
                  ,p_effective_date    => p_effective_date
                  )
          then
            --
            -- Check if the person was previously eligible for the comp object
            --
            -- BUG 5062.
            --
            if p_comp_obj_tree(l_treeele_num).ptip_id is not null then
              --
              -- We have filter from a PTIP to a PTIP so we need to
              -- make sure the PTIP has been cached
              --
              if check_dupproc_ptip
                  (p_ptip_id => l_ptip_id) then
                --
                null;
                --
              end if;
              --
            end if;
            -- bug # 5929587
            -- At this point, the parent ptip is not eligible. So, the elig_for_ptip_flag should be set to N,
            -- if the current comp object is a child of ptip, before exiting

            if p_comp_obj_tree(l_treeele_num).plip_id is not null or
             	p_comp_obj_tree(l_treeele_num).pl_id   is not null or
              	p_comp_obj_tree(l_treeele_num).oipl_id is not null then

             	hr_utility.set_location ('Setting elig_for_ptip_flag to N before exiting ',70);
            	l_par_elig_state.elig_for_ptip_flag := 'N';

            end if;
            -- bug # 5929587
            --
            exit;
            --
          else
            --
            l_treeele_num := l_treeele_num+1;
            --
          end if;
          --
        end loop;
        --
      elsif l_par_elig_state.elig_for_pgm_flag = 'Y' then
        --
        -- Reset parent eligibility flags
        --
        l_par_elig_state.elig_for_ptip_flag := 'Y';
        l_par_elig_state.elig_for_plip_flag := 'Y';
        l_par_elig_state.elig_for_pl_flag   := 'Y';
        --
      end if;
      --
    elsif l_plip_id is not null then
--      hr_utility.set_location ('PLIP Chk  '||l_package,10);
      --
      l_boundary := FALSE;
      --
      -- Check parent comp object eligibility
      -- When the ptip is in-eligible then do not process any sub comp objects
      -- navigate to the next plip.
      --
      if l_par_elig_state.elig_for_ptip_flag = 'N'
        and p_comp_obj_tree(l_treeele_num).trk_inelig_per_flag = 'N'
        and p_mode <> 'T'
      then
        --
        loop
          --
          -- Check for a program or plan not in program boundary
          --
          if p_comp_obj_tree(l_treeele_num).pgm_id is not null
            or p_comp_obj_tree(l_treeele_num).pl_nip = 'Y'
            or p_comp_obj_tree(l_treeele_num).ptip_id is not null
          then
            --
            -- Reset parent eligibility flags based on boundary crossed
            --
            set_bound_parent_elig_flags
              (p_comp_obj_tree_row => p_comp_obj_tree(l_treeele_num)
              --
              ,p_par_elig_state    => l_par_elig_state
              );
            --
            l_boundary := TRUE;
            exit;
            --
          --
          -- Check for a plip with track in-eligibility set
          --
          elsif p_comp_obj_tree(l_treeele_num).plip_id is not null
            and p_comp_obj_tree(l_treeele_num).trk_inelig_per_flag = 'Y'
          then
            --
            exit;
          --
          -- Check if the last row of the comp object list has been reached
          -- otherwise navigate to the next row
          --
          elsif l_treeele_num = p_maxtreeele_num then
            --
            l_treeloop := FALSE;
            exit;
            --
          elsif check_prevelig_compobj
                  (p_comp_obj_tree_row => p_comp_obj_tree(l_treeele_num)
                  ,p_business_group_id => p_business_group_id
                  ,p_person_id         => p_person_id
                  ,p_effective_date    => p_effective_date
                  )
          then
            --
            -- Check if the person was previously eligible for the comp object
            --

            -- bug # 5929587
            -- At this point, the parent plip is not eligible. So, the elig_for_plip_flag should be set to N,
            -- if at point of exit, the comp object is a child of plip
            if p_comp_obj_tree(l_treeele_num).pl_id is not null or
              	p_comp_obj_tree(l_treeele_num).oipl_id is not null then

              	hr_utility.set_location ('Setting elig_for_plip_flag to N before exiting ',70);
            	l_par_elig_state.elig_for_plip_flag := 'N';

            end if;
            -- bug # 5929587

            exit;
            --
          else
            --
            l_treeele_num := l_treeele_num+1;
            --
          end if;
          --
        end loop;
        --
      elsif l_par_elig_state.elig_for_ptip_flag = 'Y' then
        --
        -- Reset parent eligibility flags
        --
        l_par_elig_state.elig_for_plip_flag := 'Y';
        l_par_elig_state.elig_for_pl_flag   := 'Y';
        --
      end if;
      --
    elsif l_pl_id is not null then
--      hr_utility.set_location ('PLN Chk  '||l_package,10);
      --
      l_boundary := FALSE;
      --
      if l_pl_nip = 'Y' then
        --
        l_failed_rule:=false;
       --PB :5422 :  if p_popl_enrt_typ_cycl_id is not null then
        if p_lf_evt_ocrd_dt is not null then
          for l_person_selection in c_schedd_enrt_rl_plnip loop
            if l_person_selection.formula_id is not null then
              if check_selection_rule
                (p_person_selection_rule_id =>l_person_selection.formula_id,
                 p_person_id                =>p_person_id,
                 p_business_group_id        =>p_business_group_id,
                 p_effective_date           =>p_effective_date) then
                hr_utility.set_location('Rule passed for pgm',15);
              else
                l_failed_rule:=true;
                exit;
              end if;
            end if;
          end loop;
        elsif p_ler_id is not null then
          for l_person_selection in c_lee_rsn_rl_plnip loop
            if l_person_selection.formula_id is not null then
              if check_selection_rule
                (p_person_selection_rule_id =>l_person_selection.formula_id,
                 p_person_id                =>p_person_id,
                 p_business_group_id        =>p_business_group_id,
                 p_effective_date           =>p_effective_date) then
                hr_utility.set_location('Rule passed for pgm',15);
              else
                hr_utility.set_location('Rule failed for pgm',15);
                l_failed_rule:=true;
                exit;
              end if;
            end if;
          end loop;
        end if;
        if l_failed_rule then
          loop
            l_treeele_num:=l_treeele_num+1;
            if l_treeele_num>p_maxtreeele_num then
              l_treeloop := FALSE;
              exit;
            end if;
            --
            -- Check for a program or plan not in program boundary
            --
            if p_comp_obj_tree(l_treeele_num).pgm_id is not null
              or p_comp_obj_tree(l_treeele_num).pl_nip = 'Y' then
              --
              -- At next program or plan not in program
              -- return to outer loop to see if this one is OK
              --
              l_boundary := TRUE;
              exit;
              --
            end if;
          end loop;
        else
          l_par_elig_state.elig_for_pgm_flag  := 'Y';
          l_par_elig_state.elig_for_ptip_flag := 'Y';
          l_par_elig_state.elig_for_plip_flag := 'Y';
        end if;
        --
      else
        --
        -- Check parent comp object eligibility
        -- When the plip is in-eligible then do not process any sub comp objects
        -- navigate to the next pln.
        --
        if l_par_elig_state.elig_for_plip_flag = 'N'
          and p_comp_obj_tree(l_treeele_num).trk_inelig_per_flag = 'N'
          and p_mode <> 'T'
        then
          --
          loop
            --
            -- Check for a boundary
            --
            if p_comp_obj_tree(l_treeele_num).pgm_id is not null
              or p_comp_obj_tree(l_treeele_num).pl_nip = 'Y'
              or p_comp_obj_tree(l_treeele_num).ptip_id is not null
              or p_comp_obj_tree(l_treeele_num).plip_id is not null
            then
              --
              -- Reset parent eligibility flags based on boundary crossed
              --
              set_bound_parent_elig_flags
                (p_comp_obj_tree_row => p_comp_obj_tree(l_treeele_num)
                --
                ,p_par_elig_state    => l_par_elig_state
                );
              --
              l_boundary := TRUE;
              exit;
              --
            --
            -- Check for a pln with track in-eligibility set
            --
            elsif p_comp_obj_tree(l_treeele_num).pl_id is not null
              and p_comp_obj_tree(l_treeele_num).trk_inelig_per_flag = 'Y'
            then
              --
              exit;
            --
            -- Check if the last row of the comp object list has been reached
            -- otherwise navigate to the next row
            --
            elsif l_treeele_num = p_maxtreeele_num then
             --
              --l_treeloop := FALSE;--4522811

	           l_boundary := FALSE; --4522811
              exit;
              --
            elsif check_prevelig_compobj
                    (p_comp_obj_tree_row => p_comp_obj_tree(l_treeele_num)
                    ,p_business_group_id => p_business_group_id
                    ,p_person_id         => p_person_id
                    ,p_effective_date    => p_effective_date
                    )
            then
              --
              -- Check if the person was previously eligible for the comp object
              --

              -- bug # 5929587
              -- At this point, the parent pl is not eligible. So, the elig_for_pl_flag should be set to N,
              -- if at point of exit, the comp object is a child of pl

              if p_comp_obj_tree(l_treeele_num).oipl_id is not null then
                hr_utility.set_location ('Setting elig_for_pl_flag to N before exiting ',70);
                l_par_elig_state.elig_for_pl_flag := 'N';
              end if;
              -- bug # 5929587

              exit;
              --
            else
              --
              l_treeele_num := l_treeele_num+1;
              --
            end if;
            --
          end loop;
          --
        elsif l_par_elig_state.elig_for_plip_flag = 'Y' then
          --
          -- Reset parent eligibility flags
          --
          l_par_elig_state.elig_for_pl_flag   := 'Y';
          --
        end if;
        --
      end if;
      --
    elsif l_oipl_id is not null then
--      hr_utility.set_location ('OIPL Chk  '||l_package,10);
      --
      l_boundary := FALSE;
      --
      -- Check parent comp object eligibility
      -- When the pln is in-eligible then do not process any oipls
      -- navigate to the next pln.
      --
      if l_par_elig_state.elig_for_pl_flag = 'N'
        and p_comp_obj_tree(l_treeele_num).trk_inelig_per_flag = 'N'
        and p_mode <> 'T'
      then
        --
        loop
          --
          -- Check for a program or plan not in program boundary
          --
          if p_comp_obj_tree(l_treeele_num).pgm_id is not null
            or p_comp_obj_tree(l_treeele_num).pl_nip = 'Y'
            or p_comp_obj_tree(l_treeele_num).ptip_id is not null
            or p_comp_obj_tree(l_treeele_num).plip_id is not null
            or p_comp_obj_tree(l_treeele_num).pl_id is not null
          then
            --
            -- Reset parent eligibility flags based on boundary crossed
            --
            set_bound_parent_elig_flags
              (p_comp_obj_tree_row => p_comp_obj_tree(l_treeele_num)
              --
              ,p_par_elig_state    => l_par_elig_state
              );
            --
            l_boundary := TRUE;
            exit;
            --
          --
          -- Check for a oipl with track in-eligibility set
          --
          elsif p_comp_obj_tree(l_treeele_num).oipl_id is not null
            and p_comp_obj_tree(l_treeele_num).trk_inelig_per_flag = 'Y'
          then
            --
            exit;
          --
          -- Check if the last row of the comp object list has been reached
          -- otherwise navigate to the next row
          --
          elsif l_treeele_num = p_maxtreeele_num then
            --
            --l_treeloop := FALSE;
	         l_boundary := FALSE; --4522811

            exit;
            --
          elsif check_prevelig_compobj
                  (p_comp_obj_tree_row => p_comp_obj_tree(l_treeele_num)
                  ,p_business_group_id => p_business_group_id
                  ,p_person_id         => p_person_id
                  ,p_effective_date    => p_effective_date
                  )
          then
            --
            -- Check if the person was previously eligible for the comp object
            --
            exit;
            --
          else
            --
            l_treeele_num := l_treeele_num+1;
            --
          end if;
          --
        end loop;
        --
      end if;
      --
    end if;
    --
    -- Exit the boundary loop if the boundary was not crossed
    --
    if not l_boundary then
      --
      exit;
      --
    end if;
    --
  end loop; -- boundary loop
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
  p_par_elig_state := l_par_elig_state;
  p_treeele_num    := l_treeele_num;
  p_treeloop       := l_treeloop;
  --
end filter_comp_objects;
--
end ben_comp_obj_filter;

/
