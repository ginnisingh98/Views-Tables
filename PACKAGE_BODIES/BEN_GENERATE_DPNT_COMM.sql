--------------------------------------------------------
--  DDL for Package Body BEN_GENERATE_DPNT_COMM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_GENERATE_DPNT_COMM" as
/* $Header: bencomde.pkb 120.0.12010000.6 2010/01/19 14:14:57 sagnanas ship $ */
  --
  g_package varchar2(30) := 'ben_generate_dpnt_comm.';
  --
  function rule_passes(p_rule_id        in number,
                       p_assignment_id  in number,
                       --RCHASE Bug Fix - must have person_id for dependent joins
                       p_rcpent_person_id in number,
                       --RCHASE end
                       p_per_cm_id      in number default null,
                       p_business_group_id      in number default null,
                       p_ler_id         in number default null,
                       p_effective_date in date) return boolean is
    --
    l_proc      varchar2(80) := g_package||'rule_passes';
    l_outputs   ff_exec.outputs_t;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('In Parameters',10);
    hr_utility.set_location('p_rule_id '||p_rule_id,10);
    hr_utility.set_location('p_assignment_id '||p_assignment_id,10);
    hr_utility.set_location('p_effective_date '||p_effective_date,10);
    --
    -- Steps
    -- 1. If no rule exists return true
    -- 2. If a rule exists, evaluate rule
    -- 3. If evaluated value = 'N' return false
    --    If evaluated rule = 'Y' return true
    --
    -- Step 1.
    --
    if p_rule_id is null then
      --
      hr_utility.set_location('Leaving: '||l_proc,10);
      return true;
      --
    else
      --
      -- Evaluate rule
      --
      -- Step 2.
      --
      l_outputs := benutils.formula
        (p_formula_id        => p_rule_id,
         p_effective_date    => p_effective_date,
         p_per_cm_id         => p_per_cm_id,
         p_ler_id            => p_ler_id,
         p_business_group_id => p_business_group_id,
         p_assignment_id     => p_assignment_id,
         --RCHASE Bug Fix - Formula requires person_id as input value
         --RCHASE           for individuals without assignments
         p_param1                =>'PERSON_ID',
         p_param1_value          =>to_char(p_rcpent_person_id)
         );
      --
      -- Step 3.
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
        fnd_message.set_token('RL','rule_id :'||p_rule_id);
        fnd_message.set_token('PROC',l_proc);
        raise ben_manage_life_events.g_record_error;
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
  end rule_passes;
  --
  procedure check_electable_choice_popl
      (p_per_in_ler_id     in number,
       p_rcpent_person_id  in number,
       p_rcpent_cd         in varchar2,
       p_business_group_id in number,
       p_assignment_id     in number,
       -- PB : 5422 :
       -- p_enrt_perd_id      in number,
       p_asnd_lf_evt_dt    in date,
       p_pgm_id            in number,
       p_pl_id             in number,
       p_pl_typ_id         in number,
       p_ler_id            in number,
       p_actn_typ_id       in number,
       p_per_cm_id         in number,
       p_cm_typ_id         in number,
       p_effective_date    in date,
       p_lf_evt_ocrd_dt    in date,
       p_whnvr_trgrd_flag  in varchar2,
       p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_electable_choice_popl';
    --
    cursor c_dpnt_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu,
             ben_per_in_ler pil,
             ben_elig_per_elctbl_chc epe
      where  pil.per_in_ler_id = p_per_in_ler_id
      and    pil.business_group_id = p_business_group_id
      and    ctu.business_group_id  = pil.business_group_id
             /* First join comp objects */
      and    epe.per_in_ler_id = pil.per_in_ler_id
      and    epe.elctbl_flag = 'Y'
      and    nvl(ctu.ler_id,pil.ler_id) = pil.ler_id
      and    nvl(ctu.pgm_id,nvl(epe.pgm_id,-1)) = nvl(epe.pgm_id,-1)
      and    nvl(ctu.pl_id,nvl(epe.pl_id,-1)) = nvl(epe.pl_id,-1)
      and    nvl(ctu.pl_typ_id, nvl(epe.pl_typ_id, -1)) = nvl(epe.pl_typ_id,-1)
             /* Now join in enrollment period */
      and    (-- PB : 5422 :
              -- p_enrt_perd_id is null or
              p_asnd_lf_evt_dt is null or
              ctu.enrt_perd_id is null or
              exists (
                select null
                from   ben_enrt_perd enp_c
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_c.asnd_lf_evt_dt  = p_asnd_lf_evt_dt
                     )
                /* PB : 5422 :
                select null
                from   ben_enrt_perd enp_c,
                       ben_enrt_perd enp_m
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_m.enrt_perd_id=p_enrt_perd_id and
                       enp_m.business_group_id=ctu.business_group_id and
                       enp_m.strt_dt=enp_c.strt_dt
                     ) */
             )
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists
               (select null
                from   ben_elig_dpnt egd1
                where  egd1.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                and    egd1.business_group_id = epe.business_group_id
                and    egd1.dpnt_person_id = p_rcpent_person_id
                and    egd1.per_in_ler_id = pil.per_in_ler_id
                and    egd1.elig_cvrd_dpnt_id is not null);
    --
    cursor c_dpnt_always is
      select null
      from   ben_elig_per_elctbl_chc epe,
             ben_per_in_ler pil
      where  pil.per_in_ler_id = p_per_in_ler_id
      and    pil.business_group_id = p_business_group_id
      and    epe.business_group_id  = pil.business_group_id
      and    epe.per_in_ler_id = pil.per_in_ler_id
      and    epe.elctbl_flag = 'Y'
      and    exists
               (select null
                from   ben_elig_dpnt egd1
                where  egd1.business_group_id = pil.business_group_id
                and    egd1.dpnt_person_id = p_rcpent_person_id
                and    egd1.per_in_ler_id = pil.per_in_ler_id
                and    egd1.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
                and    egd1.elig_cvrd_dpnt_id is not null);
    --
    cursor c_bnf_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu,
             ben_per_in_ler pil,
             ben_elig_per_elctbl_chc epe
      where  pil.per_in_ler_id = p_per_in_ler_id
      and    pil.business_group_id = p_business_group_id
      and    ctu.business_group_id  = pil.business_group_id
             /* First join comp objects */
      and    epe.per_in_ler_id = pil.per_in_ler_id
      and    epe.elctbl_flag = 'Y'
      and    nvl(ctu.ler_id,pil.ler_id) = pil.ler_id
      and    nvl(ctu.pgm_id,nvl(epe.pgm_id,-1)) = nvl(epe.pgm_id,-1)
      and    nvl(ctu.pl_id,nvl(epe.pl_id,-1)) = nvl(epe.pl_id,-1)
      and    nvl(ctu.pl_typ_id,nvl(epe.pl_typ_id,-1)) = nvl(epe.pl_typ_id, -1)
             /* Now join in enrollment period */
      and    (-- PB : 5422 :
              -- p_enrt_perd_id is null or
              p_asnd_lf_evt_dt is null or
              ctu.enrt_perd_id is null or
              exists (
                select null
                from   ben_enrt_perd enp_c
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_c.asnd_lf_evt_dt  = p_asnd_lf_evt_dt
                     )
                /* PB : 5422 :
                select null
                from   ben_enrt_perd enp_c,
                       ben_enrt_perd enp_m
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_m.enrt_perd_id=p_enrt_perd_id and
                       enp_m.business_group_id=ctu.business_group_id and
                       enp_m.strt_dt=enp_c.strt_dt
                     ) */
             )
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists
               (select null
                from   ben_prtt_enrt_rslt_f pen1,
                       ben_pl_bnf_f pbn1
                where  pen1.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
                and    pen1.prtt_enrt_rslt_id = pbn1.prtt_enrt_rslt_id
                and    pbn1.bnf_person_id = p_rcpent_person_id
                and    pen1.prtt_enrt_rslt_stat_cd is null
                and    pen1.business_group_id = epe.business_group_id
                and    pen1.business_group_id = pbn1.business_group_id
                and    p_effective_date
                       between pbn1.effective_start_date
                       and pbn1.effective_end_date
                and    p_effective_date
                       between pen1.effective_start_date
                       and pen1.effective_end_date);
    --
    cursor c_bnf_always is
      select null
      from   ben_elig_per_elctbl_chc epe,
             ben_per_in_ler pil
      where  pil.per_in_ler_id = p_per_in_ler_id
      and    pil.business_group_id = p_business_group_id
      and    epe.business_group_id  = pil.business_group_id
      and    epe.per_in_ler_id = pil.per_in_ler_id
      and    epe.elctbl_flag = 'Y'
      and    exists (select null
                     from   ben_prtt_enrt_rslt_f pen1,
                            ben_pl_bnf_f pbn1
                     where  pbn1.business_group_id = pil.business_group_id
                     and    pbn1.bnf_person_id = p_rcpent_person_id
                     and    pbn1.per_in_ler_id = pil.per_in_ler_id
                     and    pen1.prtt_enrt_rslt_stat_cd is null
                     and    p_effective_date = pbn1.effective_start_date
                     and    pen1.per_in_ler_id = pbn1.per_in_ler_id
                     and    pen1.business_group_id = pbn1.business_group_id
                     and    pen1.prtt_enrt_rslt_id = pbn1.prtt_enrt_rslt_id
                     and    p_effective_date = pen1.effective_start_date
                     and    epe.prtt_enrt_rslt_id = pen1.prtt_enrt_rslt_id);
    --
    -- Cursor fetch definition
    --
    l_usage          c_dpnt_usage%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('In Parameters',10);
    hr_utility.set_location('p_per_in_ler_id '||p_per_in_ler_id,10);
    hr_utility.set_location('p_rcpent_person_id '||p_rcpent_person_id,10);
    hr_utility.set_location('p_rcpent_cd '||p_rcpent_cd,10);
    hr_utility.set_location('p_business_group_id '||p_business_group_id,10);
    hr_utility.set_location('p_assignment_id '||p_assignment_id,10);
    -- hr_utility.set_location('p_enrt_perd_id '||p_enrt_perd_id,10);
    hr_utility.set_location('p_actn_typ_id '||p_actn_typ_id,10);
    hr_utility.set_location('p_per_cm_id '||p_per_cm_id,10);
    hr_utility.set_location('p_cm_typ_id '||p_cm_typ_id,10);
    hr_utility.set_location('p_pl_typ_id '||p_pl_typ_id,10);
    hr_utility.set_location('p_ler_id '||p_ler_id,10);
    hr_utility.set_location('p_whnvr_trgrd_flag '||p_whnvr_trgrd_flag,10);
    hr_utility.set_location('p_lf_evt_ocrd_dt '||p_lf_evt_ocrd_dt,10);
    hr_utility.set_location('p_effective_date '||p_effective_date,10);
    --
    -- Rules are as follows
    -- if p_proc_cd = 'RLTD_PER' then
    --   create record
    -- elsif p_proc_cd = 'DPNT' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- elsif p_proc_cd = 'BNF' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- end if
    --
    if p_rcpent_cd = 'RLTD_PER' then
      --
      l_created := true;
      --
    elsif p_rcpent_cd = 'BNF' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for BNF',10);
        open c_bnf_always;
          --
          fetch c_bnf_always into l_dummy;
          if c_bnf_always%found then
            --
            hr_utility.set_location('Communication Created for BNF',10);
            l_created := true;
            --
          end if;
          --
        close c_bnf_always;
        --
      else
        --
        -- We must create usages for the BNF
        --
        hr_utility.set_location('Communication usage test for BNF',10);
        --
        open c_bnf_usage;
          --
          loop
            --
            fetch c_bnf_usage into l_usage;
            exit when c_bnf_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage Created for BNF',10);
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_bnf_usage;
        --
      end if;
      --
    elsif p_rcpent_cd = 'DPNT' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for DPNT',10);
        --
        open c_dpnt_always;
          --
          fetch c_dpnt_always into l_dummy;
          if c_dpnt_always%found then
            --
            hr_utility.set_location('Communication created for DPNT',10);
            l_created := true;
            --
          end if;
          --
        close c_dpnt_always;
        --
      else
        --
        -- We must create usages for the DPNT
        --
        hr_utility.set_location('Communication usage test for DPNT',10);
        --
        open c_dpnt_usage;
          --
          loop
            --
            fetch c_dpnt_usage into l_usage;
            exit when c_dpnt_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage created for DPNT',10)
;
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_dpnt_usage;
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_electable_choice_popl;
  --
  procedure check_first_time_elig_inelig
      (p_person_id         in number,
       p_per_in_ler_id     in number,
       p_rcpent_person_id  in number,
       p_rcpent_cd         in varchar2,
       p_business_group_id in number,
       p_assignment_id     in number,
       -- PB : 5422 :
       -- p_enrt_perd_id      in number,
       p_asnd_lf_evt_dt    in date,
       p_actn_typ_id       in number,
       p_per_cm_id         in number,
       p_cm_typ_id         in number,
       p_ler_id            in number,
       p_effective_date    in date,
       p_lf_evt_ocrd_dt    in date,
       p_whnvr_trgrd_flag  in varchar2,
       p_eligible_flag     in varchar2,
       p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_first_time_elig_inelig';
    --
    cursor c_dpnt_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu,
             ben_elig_per_f pep,
             ben_enrt_perd enp,
             ben_popl_enrt_typ_cycl_f pet
      where  ctu.business_group_id  = p_business_group_id
             /* First join comp objects */
      and    pep.business_group_id  = ctu.business_group_id
      and    pep.person_id = p_person_id
      and    p_effective_date
             between pep.effective_start_date
             and     pep.effective_end_date
             /* Use nvl to handle nulls */
      and    nvl(ctu.ler_id,nvl(pep.ler_id,-1)) = nvl(pep.ler_id,-1)
      and    nvl(ctu.pgm_id,nvl(pep.pgm_id,-1)) = nvl(pep.pgm_id,-1)
      and    nvl(ctu.pl_id,nvl(pep.pl_id,-1)) = nvl(pep.pl_id,-1)
      /* PB : 5422 :
      and    (p_enrt_perd_id is null or
              nvl(ctu.enrt_perd_id,p_enrt_perd_id) = p_enrt_perd_id)
      */
      and    (p_asnd_lf_evt_dt is null or
              nvl(enp.asnd_lf_evt_dt, p_asnd_lf_evt_dt)  = p_asnd_lf_evt_dt)
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
             /* Now join in enrollment period */
      and    ctu.enrt_perd_id = enp.enrt_perd_id(+)
      and    nvl(enp.business_group_id,ctu.business_group_id)
             = ctu.business_group_id
             /* Join in enrollment type cycle */
      and    enp.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id (+)
      and    nvl(pet.business_group_id,ctu.business_group_id)
             = ctu.business_group_id
      and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
             between nvl(pet.effective_start_date,nvl(p_lf_evt_ocrd_dt,
                                                      p_effective_date))
             and     nvl(pet.effective_end_date,nvl(p_lf_evt_ocrd_dt,
                                                    p_effective_date))
             /* Use nvl here as only pgm pl can be populated */
      and    nvl(ctu.pl_id,-1) = nvl(pet.pl_id,nvl(ctu.pl_id,-1))
      and    nvl(ctu.pgm_id,-1) = nvl(pet.pgm_id,nvl(ctu.pgm_id,-1))
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
             /* Final test make sure elig/ineligible as of today */
         --
         -- Bugs : 1412882, part of bug 1412951
         --
      and    (pep.effective_start_date = p_effective_date or
              pep.effective_start_date = p_lf_evt_ocrd_dt)
      and    pep.elig_flag = p_eligible_flag
    ;
    --
    cursor c_rltd_per_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu,
             ben_elig_per_f pep,
             ben_enrt_perd enp,
             ben_popl_enrt_typ_cycl_f pet
      where  ctu.business_group_id  = p_business_group_id
             /* First join comp objects */
      and    pep.business_group_id  = ctu.business_group_id
      and    pep.person_id = p_person_id
      and    p_effective_date
             between pep.effective_start_date
             and     pep.effective_end_date
             /* Use nvl to handle nulls */
      and    nvl(ctu.ler_id,nvl(pep.ler_id,-1)) = nvl(pep.ler_id,-1)
      and    nvl(ctu.pgm_id,nvl(pep.pgm_id,-1)) = nvl(pep.pgm_id,-1)
      and    nvl(ctu.pl_id,nvl(pep.pl_id,-1)) = nvl(pep.pl_id,-1)
      /* PB : 5422 :
      and    (p_enrt_perd_id is null or
              nvl(ctu.enrt_perd_id,p_enrt_perd_id) = p_enrt_perd_id)
      */
      and    (p_asnd_lf_evt_dt is null or
              nvl(enp.asnd_lf_evt_dt, p_asnd_lf_evt_dt)  = p_asnd_lf_evt_dt)
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
             /* Now join in enrollment period */
      and    ctu.enrt_perd_id = enp.enrt_perd_id(+)
      and    nvl(enp.business_group_id,ctu.business_group_id)
             = ctu.business_group_id
             /* Join in enrollment type cycle */
      and    enp.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id (+)
      and    nvl(pet.business_group_id,ctu.business_group_id)
             = ctu.business_group_id
      and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
             between nvl(pet.effective_start_date,nvl(p_lf_evt_ocrd_dt,
                                                      p_effective_date))
             and     nvl(pet.effective_end_date,nvl(p_lf_evt_ocrd_dt,
                                                    p_effective_date))
             /* Use nvl here as only pgm pl can be populated */
      and    nvl(ctu.pl_id,-1) = nvl(pet.pl_id,nvl(ctu.pl_id,-1))
      and    nvl(ctu.pgm_id,-1) = nvl(pet.pgm_id,nvl(ctu.pgm_id,-1))
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
             /* Final test make sure elig/ineligible as of today */
         --
         -- Bugs : 1412882, part of bug 1412951
         --
      and    (pep.effective_start_date = p_effective_date or
              pep.effective_start_date = p_lf_evt_ocrd_dt)
      -- and    pep.effective_start_date = p_effective_date
      and    pep.elig_flag = p_eligible_flag
      and    exists (select null
                     from   ben_prtt_enrt_rslt_f pen,
                            ben_elig_cvrd_dpnt_f pdp
                     where  pen.business_group_id = p_business_group_id
                     and    pdp.business_group_id = pen.business_group_id
                     and    pdp.dpnt_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    p_effective_date = pdp.effective_start_date
                     and    pen.prtt_enrt_rslt_id = pdp.prtt_enrt_rslt_id
                     and    p_effective_date = pen.effective_start_date
                     and    nvl(pen.pgm_id,-1) = nvl(pep.pgm_id,-1)
                     and    nvl(pen.pl_id,-1) = nvl(pep.pl_id,-1)
                     and    pdp.per_in_ler_id = p_per_in_ler_id
                     and    pen.per_in_ler_id = pdp.per_in_ler_id);
    --
    cursor c_dpnt_always is
      select null
      from   ben_elig_per_f pep
      where  pep.business_group_id  = p_business_group_id
      and    pep.person_id = p_person_id
      and    p_effective_date
             between pep.effective_start_date
             and     pep.effective_end_date
             /* Final test make sure ineligible as of today */
         --
         -- Bugs : 1412882, part of bug 1412951
         --
      and    (pep.effective_start_date = p_effective_date or
              pep.effective_start_date = p_lf_evt_ocrd_dt)
      -- and    pep.effective_start_date = p_effective_date
      and    pep.elig_flag = p_eligible_flag
      and    exists (select null
                     from   ben_prtt_enrt_rslt_f pen,
                            ben_elig_cvrd_dpnt_f pdp
                     where  pen.business_group_id = p_business_group_id
                     and    pdp.business_group_id = pen.business_group_id
                     and    pdp.dpnt_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    p_effective_date = pdp.effective_start_date
                     and    pen.prtt_enrt_rslt_id = pdp.prtt_enrt_rslt_id
                     and    p_effective_date = pen.effective_start_date
                     and    pdp.per_in_ler_id = p_per_in_ler_id
                     and    pen.per_in_ler_id = pdp.per_in_ler_id);
    --
    cursor c_bnf_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu,
             ben_elig_per_f pep,
             ben_enrt_perd enp,
             ben_popl_enrt_typ_cycl_f pet
      where  ctu.business_group_id  = p_business_group_id
             /* First join comp objects */
      and    pep.business_group_id  = ctu.business_group_id
      and    pep.person_id = p_person_id
      and    p_effective_date
             between pep.effective_start_date
             and     pep.effective_end_date
             /* Use nvl to handle nulls */
      and    nvl(ctu.ler_id,nvl(pep.ler_id,-1)) = nvl(pep.ler_id,-1)
      and    nvl(ctu.pgm_id,nvl(pep.pgm_id,-1)) = nvl(pep.pgm_id,-1)
      and    nvl(ctu.pl_id,nvl(pep.pl_id,-1)) = nvl(pep.pl_id,-1)
      /* PB : 5422 :
      and    (p_enrt_perd_id is null or
              nvl(ctu.enrt_perd_id,p_enrt_perd_id) = p_enrt_perd_id)
      */
      and    (p_asnd_lf_evt_dt is null or
              nvl(enp.asnd_lf_evt_dt, p_asnd_lf_evt_dt)  = p_asnd_lf_evt_dt)
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
             /* Now join in enrollment period */
      and    ctu.enrt_perd_id = enp.enrt_perd_id(+)
      and    nvl(enp.business_group_id,ctu.business_group_id)
             = ctu.business_group_id
             /* Join in enrollment type cycle */
      and    enp.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id (+)
      and    nvl(pet.business_group_id,ctu.business_group_id)
             = ctu.business_group_id
      and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
             between nvl(pet.effective_start_date,nvl(p_lf_evt_ocrd_dt,
                                                      p_effective_date))
             and     nvl(pet.effective_end_date,nvl(p_lf_evt_ocrd_dt,
                                                    p_effective_date))
             /* Use nvl here as only pgm pl can be populated */
      and    nvl(ctu.pl_id,-1) = nvl(pet.pl_id,nvl(ctu.pl_id,-1))
      and    nvl(ctu.pgm_id,-1) = nvl(pet.pgm_id,nvl(ctu.pgm_id,-1))
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
             /* Final test make sure ineligible as of today */
         --
         -- Bugs : 1412882, part of bug 1412951
         --
      and    (pep.effective_start_date = p_effective_date or
              pep.effective_start_date = p_lf_evt_ocrd_dt)
      -- and    pep.effective_start_date = p_effective_date
      and    pep.elig_flag = p_eligible_flag
      and    exists (select null
                     from   ben_prtt_enrt_rslt_f pen,
                            ben_pl_bnf_f pbn
                     where  pen.business_group_id = p_business_group_id
                     and    pbn.business_group_id = pen.business_group_id
                     and    pbn.bnf_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    p_effective_date = pbn.effective_start_date
                     and    pen.prtt_enrt_rslt_id = pbn.prtt_enrt_rslt_id
                     and    p_effective_date = pen.effective_start_date
                     and    pbn.per_in_ler_id = p_per_in_ler_id
                     and    nvl(pen.pgm_id,-1) = nvl(pep.pgm_id,-1)
                     and    nvl(pen.pl_id,-1) = nvl(pep.pl_id,-1)
                     and    pen.per_in_ler_id = pbn.per_in_ler_id);
    --
    cursor c_bnf_always is
      select null
      from   ben_elig_per_f pep
      where  pep.business_group_id  = p_business_group_id
      and    pep.person_id = p_person_id
      and    p_effective_date
             between pep.effective_start_date
             and     pep.effective_end_date
             /* Final test make sure eligible as of today */
         --
         -- Bugs : 1412882, part of bug 1412951
         --
      and    (pep.effective_start_date = p_effective_date or
              pep.effective_start_date = p_lf_evt_ocrd_dt)
      -- and    pep.effective_start_date = p_effective_date
      and    pep.elig_flag = p_eligible_flag
      and    exists (select null
                     from   ben_prtt_enrt_rslt_f pen,
                            ben_pl_bnf_f pbn
                     where  pen.business_group_id = p_business_group_id
                     and    pbn.business_group_id = pen.business_group_id
                     and    pbn.bnf_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    p_effective_date = pbn.effective_start_date
                     and    pen.prtt_enrt_rslt_id = pbn.prtt_enrt_rslt_id
                     and    p_effective_date = pen.effective_start_date
                     and    pbn.per_in_ler_id = p_per_in_ler_id
                     and    pen.per_in_ler_id = pbn.per_in_ler_id);
    --
    -- Cursor fetch definition
    --
    l_usage          c_dpnt_usage%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('In Parameters',10);
    hr_utility.set_location('p_person_id '||p_person_id,10);
    hr_utility.set_location('p_rcpent_person_id '||p_rcpent_person_id,10);
    hr_utility.set_location('p_rcpent_cd '||p_rcpent_cd,10);
    hr_utility.set_location('p_business_group_id '||p_business_group_id,10);
    hr_utility.set_location('p_assignment_id '||p_assignment_id,10);
    -- hr_utility.set_location('p_enrt_perd_id '||p_enrt_perd_id,10);
    hr_utility.set_location('p_actn_typ_id '||p_actn_typ_id,10);
    hr_utility.set_location('p_per_cm_id '||p_per_cm_id,10);
    hr_utility.set_location('p_cm_typ_id '||p_cm_typ_id,10);
    hr_utility.set_location('p_ler_id '||p_ler_id,10);
    hr_utility.set_location('p_whnvr_trgrd_flag '||p_whnvr_trgrd_flag,10);
    hr_utility.set_location('p_lf_evt_ocrd_dt '||p_lf_evt_ocrd_dt,10);
    hr_utility.set_location('p_effective_date '||p_effective_date,10);
    --
    -- Rules are as follows
    -- if p_proc_cd = 'RLTD_PER' then
    --   create record IF USAGE EXISTS
    -- elsif p_proc_cd = 'DPNT' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- elsif p_proc_cd = 'BNF' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- end if
    --
    if p_rcpent_cd = 'RLTD_PER' then
      --
      --
      -- We must create usages for the RLTD_PER
      --
      hr_utility.set_location('Communication usage test for RLTD_PER',10);
      --
      open c_rltd_per_usage;
        --
        loop
          --
          fetch c_rltd_per_usage into l_usage;
          exit when c_rltd_per_usage%notfound;
          --
          if rule_passes
             (p_rule_id        => l_usage.cm_usg_rl,
              p_per_cm_id      => p_per_cm_id,
              p_assignment_id  => p_assignment_id,
              --RCHASE Bug Fix - must have person_id for dependent joins
              p_rcpent_person_id => p_rcpent_person_id,
              --RCHASE end
              p_business_group_id => p_business_group_id,
              p_ler_id            => p_ler_id,
              p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                      p_effective_date)) then
            --
            -- create usage
            --
            hr_utility.set_location('Communication usage created for RLTD_PER',
                                    10);
            --
            ben_generate_communications.pop_ben_per_cm_usg_f
              (p_per_cm_id            => p_per_cm_id,
               p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => p_effective_date,
               p_per_cm_usg_id        => l_per_cm_usg_id,
               p_usage_created        => l_usages_created);
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      close c_rltd_per_usage;
      --
    elsif p_rcpent_cd = 'BNF' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for BNF',10);
        open c_bnf_always;
          --
          fetch c_bnf_always into l_dummy;
          if c_bnf_always%found then
            --
            hr_utility.set_location('Communication Created for BNF',10);
            l_created := true;
            --
          end if;
          --
        close c_bnf_always;
        --
      else
        --
        -- We must create usages for the BNF
        --
        hr_utility.set_location('Communication usage test for BNF',10);
        --
        open c_bnf_usage;
          --
          loop
            --
            fetch c_bnf_usage into l_usage;
            exit when c_bnf_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage Created for BNF',10);
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_bnf_usage;
        --
      end if;
      --
    elsif p_rcpent_cd = 'DPNT' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for DPNT',10);
        --
        open c_dpnt_always;
          --
          fetch c_dpnt_always into l_dummy;
          if c_dpnt_always%found then
            --
            hr_utility.set_location('Communication created for DPNT',10);
            l_created := true;
            --
          end if;
          --
        close c_dpnt_always;
        --
      else
        --
        -- We must create usages for the DPNT
        --
        hr_utility.set_location('Communication usage test for DPNT',10);
        --
        open c_dpnt_usage;
          --
          loop
            --
            fetch c_dpnt_usage into l_usage;
            exit when c_dpnt_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage created for DPNT',10);
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_dpnt_usage;
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_first_time_elig_inelig;
  --
  procedure check_automatic_enrollment
    (p_rcpent_cd         in varchar2,
     p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_automatic_enrollment';
    l_usages_created boolean := false;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    -- Rules are as follows
    --
    -- If rcpent_cd = 'RLTD_PER' then
    --   always create record
    -- Else
    --   no record created
    --
    if p_rcpent_cd = 'RLTD_PER' then
      --
      l_usages_created := true;
      --
    end if;
    --
    p_usages_created := l_usages_created;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
  end check_automatic_enrollment;
  --
  procedure check_no_impact_on_benefits
    (p_rcpent_cd         in varchar2,
     p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_no_impact_on_benefits';
    l_usages_created boolean := false;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    -- Rules are as follows
    --
    -- If rcpent_cd = 'RLTD_PER' then
    --   always create record
    -- Else
    --   no record created
    --
    if p_rcpent_cd = 'RLTD_PER' then
      --
      l_usages_created := true;
      --
    end if;
    --
    p_usages_created := l_usages_created;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
  end check_no_impact_on_benefits;
  --
  procedure check_rate_change
    (p_per_in_ler_id     in number,
     p_rcpent_person_id  in number,
     p_rcpent_cd         in varchar2,
     p_business_group_id in number,
     p_assignment_id     in number,
     -- PB : 5422 :
     -- p_enrt_perd_id      in number,
     p_asnd_lf_evt_dt    in date,
     p_ler_id            in number,
     p_actn_typ_id       in number,
     p_per_cm_id         in number,
     p_cm_typ_id         in number,
     p_effective_date    in date,
     p_lf_evt_ocrd_dt    in date,
     p_whnvr_trgrd_flag  in varchar2,
     p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_rate_change';
    --
    cursor c_bnf_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu,
             ben_prtt_enrt_rslt_f pen,
             ben_enrt_perd enp,
             ben_popl_enrt_typ_cycl_f pet,
             ben_prtt_rt_val prv
      where  ctu.business_group_id  = p_business_group_id
             /* First join comp objects */
      and    prv.business_group_id  = ctu.business_group_id
      and    prv.per_in_ler_id = p_per_in_ler_id
      and    prv.elctns_made_dt = p_effective_date
      and    prv.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      and    prv.prtt_rt_val_stat_cd is null
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    pen.business_group_id = prv.business_group_id
      and    pen.per_in_ler_id <> prv.per_in_ler_id
      and    pen.ler_id = nvl(p_ler_id,pen.ler_id)
      and    p_effective_date
             between pen.effective_start_date
             and     pen.effective_end_date
             /* Use nvl here as only pgm or pl can be populated */
      and    nvl(ctu.ler_id,pen.ler_id) = pen.ler_id
      and    nvl(ctu.pgm_id,-1) = nvl(pen.pgm_id,-1)
      and    nvl(ctu.pl_id,pen.pl_id) = pen.pl_id
             /* Now join in enrollment period */
      /* PB : 5422 :
      and    (p_enrt_perd_id is null or
              nvl(ctu.enrt_perd_id,p_enrt_perd_id) = p_enrt_perd_id)
      */
      and    (p_asnd_lf_evt_dt is null or
              nvl(enp.asnd_lf_evt_dt, p_asnd_lf_evt_dt)  = p_asnd_lf_evt_dt)
      and    ctu.enrt_perd_id = enp.enrt_perd_id(+)
      and    nvl(enp.business_group_id,ctu.business_group_id)
             = ctu.business_group_id
             /* Join in enrollment type cycle */
      and    enp.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id (+)
      and    nvl(pet.business_group_id,ctu.business_group_id)
             = ctu.business_group_id
      and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
             between nvl(pet.effective_start_date,nvl(p_lf_evt_ocrd_dt,
                                                      p_effective_date))
             and     nvl(pet.effective_end_date,nvl(p_lf_evt_ocrd_dt,
                                                    p_effective_date))
             /* Use nvl here as only pgm pl can be populated */
      and    nvl(ctu.pl_id,-1) = nvl(pet.pl_id,nvl(ctu.pl_id,-1))
      and    nvl(ctu.pgm_id,-1) = nvl(pet.pgm_id,nvl(ctu.pgm_id,-1))
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists (select null
                     from   ben_pl_bnf_f pbn1,
                            ben_per_in_ler pil
                     where  pbn1.bnf_person_id = p_rcpent_person_id
                     and    pbn1.business_group_id = pen.business_group_id
                     and    pbn1.effective_start_date = p_effective_date
                     and    pbn1.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pil.per_in_ler_id=pbn1.per_in_ler_id
                     and    pil.business_group_id=pbn1.business_group_id
                     and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT'))
    ;
    --
    cursor c_bnf_always is
      select null
      from   ben_prtt_enrt_rslt_f pen,
             ben_prtt_rt_val prv
      where  prv.business_group_id  = p_business_group_id
      and    prv.per_in_ler_id = p_per_in_ler_id
      and    prv.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      and    prv.prtt_rt_val_stat_cd is null
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    prv.elctns_made_dt = p_effective_date
      and    pen.business_group_id = prv.business_group_id
      and    pen.per_in_ler_id <> prv.per_in_ler_id
      and    exists (select null
                     from   ben_pl_bnf_f pbn,
                            ben_per_in_ler pil
                     where  pbn.bnf_person_id = p_rcpent_person_id
                     and    pbn.business_group_id = pen.business_group_id
                     and    pbn.effective_start_date = p_effective_date
                     and    pbn.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pil.per_in_ler_id=pbn.per_in_ler_id
                     and    pil.business_group_id=pbn.business_group_id
                     and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT'))
    ;
    --
    cursor c_dpnt_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu,
             ben_prtt_enrt_rslt_f pen,
             ben_enrt_perd enp,
             ben_popl_enrt_typ_cycl_f pet,
             ben_prtt_rt_val prv
      where  ctu.business_group_id  = p_business_group_id
             /* First join comp objects */
      and    prv.business_group_id  = ctu.business_group_id
      and    prv.per_in_ler_id = p_per_in_ler_id
      and    prv.elctns_made_dt = p_effective_date
      and    prv.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      and    prv.prtt_rt_val_stat_cd is null
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    pen.business_group_id = prv.business_group_id
      and    pen.per_in_ler_id <> prv.per_in_ler_id
      and    pen.business_group_id  = ctu.business_group_id
      and    pen.ler_id = nvl(p_ler_id,pen.ler_id)
      and    p_effective_date
             between pen.effective_start_date
             and     pen.effective_end_date
             /* Use nvl here as only pgm or pl can be populated */
      and    nvl(ctu.ler_id,pen.ler_id) = pen.ler_id
      and    nvl(ctu.pgm_id,-1) = nvl(pen.pgm_id,-1)
      and    nvl(ctu.pl_id,-1) = nvl(pen.pl_id,-1)
             /* Now join in enrollment period */
      /* PB : 5422 :
      and    (p_enrt_perd_id is null or
              nvl(ctu.enrt_perd_id,p_enrt_perd_id) = p_enrt_perd_id)
      */
      and    (p_asnd_lf_evt_dt is null or
              nvl(enp.asnd_lf_evt_dt, p_asnd_lf_evt_dt)  = p_asnd_lf_evt_dt)
      and    ctu.enrt_perd_id = enp.enrt_perd_id(+)
      and    nvl(enp.business_group_id,ctu.business_group_id)
             = ctu.business_group_id
             /* Join in enrollment type cycle */
      and    enp.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id (+)
      and    nvl(pet.business_group_id,ctu.business_group_id)
             = ctu.business_group_id
      and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
             between nvl(pet.effective_start_date,nvl(p_lf_evt_ocrd_dt,
                                                      p_effective_date))
             and     nvl(pet.effective_end_date,nvl(p_lf_evt_ocrd_dt,
                                                    p_effective_date))
             /* Use nvl here as only pgm pl can be populated */
      and    nvl(ctu.pl_id,-1) = nvl(pet.pl_id,nvl(ctu.pl_id,-1))
      and    nvl(ctu.pgm_id,-1) = nvl(pet.pgm_id,nvl(ctu.pgm_id,-1))
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists (select null
                     from   ben_elig_cvrd_dpnt_f pdp,
                            ben_per_in_ler pil
                     where  pdp.dpnt_person_id = p_rcpent_person_id
                     and    pdp.business_group_id = pen.business_group_id
                     and    pdp.effective_start_date = p_effective_date
                     and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pil.per_in_ler_id=pdp.per_in_ler_id
                     and    pil.business_group_id=pdp.business_group_id
                     and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT'))
    ;
    --
    cursor c_dpnt_always is
      select null
      from   ben_prtt_enrt_rslt_f pen,
             ben_prtt_rt_val prv
      where  prv.business_group_id  = p_business_group_id
      and    prv.per_in_ler_id = p_per_in_ler_id
      and    prv.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      and    prv.prtt_rt_val_stat_cd is null
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    prv.elctns_made_dt = p_effective_date
      and    pen.business_group_id = prv.business_group_id
      and    pen.per_in_ler_id <> prv.per_in_ler_id
      and    exists (select null
                     from   ben_elig_cvrd_dpnt_f pdp,
                            ben_per_in_ler pil
                     where  pdp.dpnt_person_id = p_rcpent_person_id
                     and    pdp.business_group_id = pen.business_group_id
                     and    pdp.effective_start_date = p_effective_date
                     and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pil.per_in_ler_id=pdp.per_in_ler_id
                     and    pil.business_group_id=pdp.business_group_id
                     and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT'));
    --
    -- Cursor fetch definition
    --
    l_usage          c_dpnt_usage%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('In Parameters',10);
    hr_utility.set_location('p_per_in_ler_id '||p_per_in_ler_id,10);
    hr_utility.set_location('p_rcpent_person_id '||p_rcpent_person_id,10);
    hr_utility.set_location('p_rcpent_cd '||p_rcpent_cd,10);
    hr_utility.set_location('p_business_group_id '||p_business_group_id,10);
    hr_utility.set_location('p_assignment_id '||p_assignment_id,10);
    -- hr_utility.set_location('p_enrt_perd_id '||p_enrt_perd_id,10);
    hr_utility.set_location('p_actn_typ_id '||p_actn_typ_id,10);
    hr_utility.set_location('p_per_cm_id '||p_per_cm_id,10);
    hr_utility.set_location('p_cm_typ_id '||p_cm_typ_id,10);
    hr_utility.set_location('p_ler_id '||p_ler_id,10);
    hr_utility.set_location('p_whnvr_trgrd_flag '||p_whnvr_trgrd_flag,10);
    hr_utility.set_location('p_lf_evt_ocrd_dt '||p_lf_evt_ocrd_dt,10);
    hr_utility.set_location('p_effective_date '||p_effective_date,10);
    --
    -- Rules are as follows
    -- if p_proc_cd = 'RLTD_PER' then
    --   create record
    -- elsif p_proc_cd = 'DPNT' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- elsif p_proc_cd = 'BNF' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- end if
    --
    if p_rcpent_cd = 'RLTD_PER' then
      --
      l_created := true;
      --
    elsif p_rcpent_cd = 'BNF' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for BNF',10);
        open c_bnf_always;
          --
          fetch c_bnf_always into l_dummy;
          if c_bnf_always%found then
            --
            hr_utility.set_location('Communication Created for BNF',10);
            l_created := true;
            --
          end if;
          --
        close c_bnf_always;
        --
      else
        --
        -- We must create usages for the BNF
        --
        hr_utility.set_location('Communication usage test for BNF',10);
        --
        open c_bnf_usage;
          --
          loop
            --
            fetch c_bnf_usage into l_usage;
            exit when c_bnf_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage Created for BNF',10);
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_bnf_usage;
        --
      end if;
      --
    elsif p_rcpent_cd = 'DPNT' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for DPNT',10);
        --
        open c_dpnt_always;
          --
          fetch c_dpnt_always into l_dummy;
          if c_dpnt_always%found then
            --
            hr_utility.set_location('Communication created for DPNT',10);
            l_created := true;
            --
          end if;
          --
        close c_dpnt_always;
        --
      else
        --
        -- We must create usages for the DPNT
        --
        hr_utility.set_location('Communication usage test for DPNT',10);
        --
        open c_dpnt_usage;
          --
          loop
            --
            fetch c_dpnt_usage into l_usage;
            exit when c_dpnt_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage created for DPNT',10);
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_dpnt_usage;
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_rate_change;
  --
  procedure check_inelig_deenroll
    (p_per_in_ler_id     in number,
     p_rcpent_person_id  in number,
     p_rcpent_cd         in varchar2,
     p_business_group_id in number,
     p_assignment_id     in number,
     -- PB : 5422 :
     -- p_enrt_perd_id      in number,
     p_asnd_lf_evt_dt    in date,
     p_ler_id            in number,
     p_actn_typ_id       in number,
     p_per_cm_id         in number,
     p_cm_typ_id         in number,
     p_effective_date    in date,
     p_lf_evt_ocrd_dt    in date,
     p_whnvr_trgrd_flag  in varchar2,
     p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_inelig_deenroll';
    --
    cursor c_bnf_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu,
             ben_prtt_enrt_rslt_f pen,
             ben_enrt_perd enp,
             ben_popl_enrt_typ_cycl_f pet
      where  ctu.business_group_id  = p_business_group_id
      and    pen.prtt_enrt_rslt_stat_cd is null
             /* First join comp objects */
      and    pen.business_group_id  = ctu.business_group_id
      and    pen.per_in_ler_id = p_per_in_ler_id
      and    pen.ler_id = nvl(p_ler_id,pen.ler_id)
      and    p_effective_date
             between pen.effective_start_date
             and     pen.effective_end_date
             /* Use nvl here as only pgm or pl can be populated */
      and    nvl(ctu.ler_id,pen.ler_id) = pen.ler_id
      and    nvl(ctu.pgm_id,nvl(pen.pgm_id,-1)) = nvl(pen.pgm_id,-1)
      and    nvl(ctu.pl_id,pen.pl_id) = pen.pl_id
             /* Now join in enrollment period */
      /* PB : 5422 :
      and    (p_enrt_perd_id is null or
              nvl(ctu.enrt_perd_id,p_enrt_perd_id) = p_enrt_perd_id)
      */
      and    (p_asnd_lf_evt_dt is null or
              nvl(enp.asnd_lf_evt_dt, p_asnd_lf_evt_dt)  = p_asnd_lf_evt_dt)
      and    ctu.enrt_perd_id = enp.enrt_perd_id(+)
      and    nvl(enp.business_group_id,ctu.business_group_id)
             = ctu.business_group_id
             /* Join in enrollment type cycle */
      and    enp.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id (+)
      and    nvl(pet.business_group_id,ctu.business_group_id)
             = ctu.business_group_id
      and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
             between nvl(pet.effective_start_date,nvl(p_lf_evt_ocrd_dt,
                                                      p_effective_date))
             and     nvl(pet.effective_end_date,nvl(p_lf_evt_ocrd_dt,
                                                    p_effective_date))
             /* Use nvl here as only pgm pl can be populated */
      and    nvl(ctu.pl_id,-1) = nvl(pet.pl_id,nvl(ctu.pl_id,-1))
      and    nvl(ctu.pgm_id,-1) = nvl(pet.pgm_id,nvl(ctu.pgm_id,-1))
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    pen.enrt_cvg_thru_dt < hr_api.g_eot
      and    exists (select null
                     from   ben_pl_bnf_f pbn1,
                            ben_per_in_ler pil
                     where  pbn1.bnf_person_id = p_rcpent_person_id
                     and    pbn1.business_group_id = pen.business_group_id
                     and    pbn1.effective_start_date = p_effective_date
                     and    pbn1.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pil.per_in_ler_id=pbn1.per_in_ler_id
                     and    pil.business_group_id=pbn1.business_group_id
                     and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT'))
    ;
    --
    cursor c_bnf_always is
      select null
      from   ben_prtt_enrt_rslt_f pen
      where  pen.business_group_id  = p_business_group_id
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    pen.per_in_ler_id = p_per_in_ler_id
      and    pen.enrt_cvg_thru_dt < hr_api.g_eot
      and    exists (select null
                     from   ben_pl_bnf_f pbn,
                            ben_per_in_ler pil
                     where  pbn.bnf_person_id = p_rcpent_person_id
                     and    pbn.business_group_id = pen.business_group_id
                     and    pbn.effective_start_date = p_effective_date
                     and    pbn.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pil.per_in_ler_id=pbn.per_in_ler_id
                     and    pil.business_group_id=pbn.business_group_id
                     and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT'))
    ;
    --
    cursor c_dpnt_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu,
             ben_prtt_enrt_rslt_f pen,
             ben_enrt_perd enp,
             ben_popl_enrt_typ_cycl_f pet
      where  ctu.business_group_id  = p_business_group_id
      and    pen.prtt_enrt_rslt_stat_cd is null
             /* First join comp objects */
      and    pen.business_group_id  = ctu.business_group_id
      and    pen.per_in_ler_id = p_per_in_ler_id
      and    pen.ler_id = nvl(p_ler_id,pen.ler_id)
      and    p_effective_date
             between pen.effective_start_date
             and     pen.effective_end_date
             /* Use nvl here as only pgm or pl can be populated */
      and    nvl(ctu.ler_id,pen.ler_id) = pen.ler_id
      and    nvl(ctu.pgm_id,nvl(pen.pgm_id,-1)) = nvl(pen.pgm_id,-1)
      and    nvl(ctu.pl_id,pen.pl_id) = pen.pl_id
             /* Now join in enrollment period */
      /* PB : 5422 :
      and    (p_enrt_perd_id is null or
              nvl(ctu.enrt_perd_id,p_enrt_perd_id) = p_enrt_perd_id)
      */
      and    (p_asnd_lf_evt_dt is null or
              nvl(enp.asnd_lf_evt_dt, p_asnd_lf_evt_dt)  = p_asnd_lf_evt_dt)
      and    ctu.enrt_perd_id = enp.enrt_perd_id(+)
      and    nvl(enp.business_group_id,ctu.business_group_id)
             = ctu.business_group_id
             /* Join in enrollment type cycle */
      and    enp.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id (+)
      and    nvl(pet.business_group_id,ctu.business_group_id)
             = ctu.business_group_id
      and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
             between nvl(pet.effective_start_date,nvl(p_lf_evt_ocrd_dt,
                                                      p_effective_date))
             and     nvl(pet.effective_end_date,nvl(p_lf_evt_ocrd_dt,
                                                    p_effective_date))
             /* Use nvl here as only pgm pl can be populated */
      and    nvl(ctu.pl_id,-1) = nvl(pet.pl_id,nvl(ctu.pl_id,-1))
      and    nvl(ctu.pgm_id,-1) = nvl(pet.pgm_id,nvl(ctu.pgm_id,-1))
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    pen.enrt_cvg_thru_dt < hr_api.g_eot
      and    exists (select null
                     from   ben_elig_cvrd_dpnt_f pdp,
                            ben_per_in_ler pil
                     where  pdp.dpnt_person_id = p_rcpent_person_id
                     and    pdp.business_group_id = pen.business_group_id
                     and    pdp.effective_start_date = p_effective_date
                     and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pil.per_in_ler_id=pdp.per_in_ler_id
                     and    pil.business_group_id=pdp.business_group_id
                     and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT'));
    --
    cursor c_dpnt_always is
      select null
      from   ben_prtt_enrt_rslt_f pen
      where  pen.business_group_id  = p_business_group_id
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    pen.per_in_ler_id = p_per_in_ler_id
      and    pen.enrt_cvg_thru_dt < hr_api.g_eot
      and    exists (select null
                     from   ben_elig_cvrd_dpnt_f pdp,
                            ben_per_in_ler pil
                     where  pdp.dpnt_person_id = p_rcpent_person_id
                     and    pdp.business_group_id = pen.business_group_id
                     and    pdp.effective_start_date = p_effective_date
                     and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pil.per_in_ler_id=pdp.per_in_ler_id
                     and    pil.business_group_id=pdp.business_group_id
                     and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT'))
    ;
    --
    -- Cursor fetch definition
    --
    l_usage          c_dpnt_usage%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('In Parameters',10);
    hr_utility.set_location('p_per_in_ler_id '||p_per_in_ler_id,10);
    hr_utility.set_location('p_rcpent_person_id '||p_rcpent_person_id,10);
    hr_utility.set_location('p_rcpent_cd '||p_rcpent_cd,10);
    hr_utility.set_location('p_business_group_id '||p_business_group_id,10);
    hr_utility.set_location('p_assignment_id '||p_assignment_id,10);
    -- hr_utility.set_location('p_enrt_perd_id '||p_enrt_perd_id,10);
    hr_utility.set_location('p_actn_typ_id '||p_actn_typ_id,10);
    hr_utility.set_location('p_per_cm_id '||p_per_cm_id,10);
    hr_utility.set_location('p_cm_typ_id '||p_cm_typ_id,10);
    hr_utility.set_location('p_ler_id '||p_ler_id,10);
    hr_utility.set_location('p_whnvr_trgrd_flag '||p_whnvr_trgrd_flag,10);
    hr_utility.set_location('p_lf_evt_ocrd_dt '||p_lf_evt_ocrd_dt,10);
    hr_utility.set_location('p_effective_date '||p_effective_date,10);
    --
    -- Rules are as follows
    -- if p_proc_cd = 'RLTD_PER' then
    --   create record
    -- elsif p_proc_cd = 'DPNT' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- elsif p_proc_cd = 'BNF' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- end if
    --
    if p_rcpent_cd = 'RLTD_PER' then
      --
      l_created := true;
      --
    elsif p_rcpent_cd = 'BNF' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for BNF',10);
        open c_bnf_always;
          --
          fetch c_bnf_always into l_dummy;
          if c_bnf_always%found then
            --
            hr_utility.set_location('Communication Created for BNF',10);
            l_created := true;
            --
          end if;
          --
        close c_bnf_always;
        --
      else
        --
        -- We must create usages for the BNF
        --
        hr_utility.set_location('Communication usage test for BNF',10);
        --
        open c_bnf_usage;
          --
          loop
            --
            fetch c_bnf_usage into l_usage;
            exit when c_bnf_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage Created for BNF',10);
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_bnf_usage;
        --
      end if;
      --
    elsif p_rcpent_cd = 'DPNT' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for DPNT',10);
        --
        open c_dpnt_always;
          --
          fetch c_dpnt_always into l_dummy;
          if c_dpnt_always%found then
            --
            hr_utility.set_location('Communication created for DPNT',10);
            l_created := true;
            --
          end if;
          --
        close c_dpnt_always;
        --
      else
        --
        -- We must create usages for the DPNT
        --
        hr_utility.set_location('Communication usage test for DPNT',10);
        --
        open c_dpnt_usage;
          --
          loop
            --
            fetch c_dpnt_usage into l_usage;
            exit when c_dpnt_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage created for DPNT',10);
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_dpnt_usage;
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_inelig_deenroll;
  --
  procedure check_expl_dflt_enrollment
    (p_per_in_ler_id     in number,
     p_rcpent_person_id  in number,
     p_rcpent_cd         in varchar2,
     p_business_group_id in number,
     p_assignment_id     in number,
     -- PB : 5422 :
     -- p_enrt_perd_id      in number,
     p_asnd_lf_evt_dt    in date,
     p_ler_id            in number,
     p_per_cm_id         in number,
     p_cm_typ_id         in number,
     p_enrt_mthd_cd      in varchar2,
     p_effective_date    in date,
     p_lf_evt_ocrd_dt    in date,
     p_whnvr_trgrd_flag  in varchar2,
     p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_expl_dflt_enrollment';
    --
    cursor c_bnf_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu,
             ben_prtt_enrt_rslt_f pen,
             ben_pil_elctbl_chc_popl pel
      where  ctu.business_group_id  = p_business_group_id
      and    pen.prtt_enrt_rslt_stat_cd is null
             /* First join comp objects */
      and    pen.business_group_id  = ctu.business_group_id
      and    pen.per_in_ler_id = p_per_in_ler_id
      and    pen.per_in_ler_id = pel.per_in_ler_id
      and    pen.enrt_mthd_cd = p_enrt_mthd_cd
      and    p_effective_date
             between pen.effective_start_date
             and     pen.effective_end_date
      and    pel.business_group_id  = pen.business_group_id
      and    nvl(ctu.ler_id,pen.ler_id) = pen.ler_id
      and    nvl(ctu.pgm_id,nvl(pen.pgm_id,-1)) = nvl(pen.pgm_id,-1)
      and    nvl(ctu.pl_typ_id,nvl(pen.pl_typ_id,-1)) = nvl(pen.pl_typ_id,-1)
      and    nvl(ctu.pl_id,pen.pl_id) = pen.pl_id
             /* Now join in enrollment period */
      and    (   (ctu.enrt_perd_id = pel.enrt_perd_id
                  and ((nvl(ctu.pl_id,nvl(pel.pl_id,-1)) = nvl(pel.pl_id,-1)
                        and pel.pgm_id is null
                       ) or
                        nvl(ctu.pgm_id,nvl(pel.pgm_id,-1)) = nvl(pel.pgm_id,-1)
                      )
                 ) or
                 (ctu.enrt_perd_id is null)
             ) -- ???? 5422 : No need to join to ben_enrt_perd
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists (select null
                     from   ben_pl_bnf_f pbn
                     where  pbn.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pbn.bnf_person_id = p_rcpent_person_id
                     and    pbn.business_group_id = pel.business_group_id
                     and    p_effective_date
                            between pbn.effective_start_date
                            and pbn.effective_end_date);
    --
    cursor c_bnf_always is
      select null
      from   ben_prtt_enrt_rslt_f pen,
             ben_per_in_ler pil
      where  pil.per_in_ler_id = p_per_in_ler_id
      and    pil.business_group_id = p_business_group_id
      and    pen.business_group_id  = pil.business_group_id
      and    pen.per_in_ler_id = pil.per_in_ler_id
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    pen.enrt_mthd_cd = p_enrt_mthd_cd
      and    p_effective_date
             between pen.effective_start_date
             and     pen.effective_end_date
      and    exists (select null
                     from   ben_pl_bnf_f pbn
                     where  pbn.per_in_ler_id = pil.per_in_ler_id
                     and    pbn.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pbn.bnf_person_id = p_rcpent_person_id
                     and    pbn.business_group_id = pil.business_group_id
                     and    pbn.effective_start_date = p_effective_date);
    --
    cursor c_dpnt_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu,
             ben_prtt_enrt_rslt_f pen,
             ben_pil_elctbl_chc_popl pel
      where  ctu.business_group_id  = p_business_group_id
      and    pen.prtt_enrt_rslt_stat_cd is null
             /* First join comp objects */
      and    pen.business_group_id  = ctu.business_group_id
      and    pen.per_in_ler_id = p_per_in_ler_id
      and    pen.per_in_ler_id = pel.per_in_ler_id
      and    pen.enrt_mthd_cd = p_enrt_mthd_cd
      and    p_effective_date
             between pen.effective_start_date
             and     pen.effective_end_date
      and    pel.business_group_id  = pen.business_group_id
      and    nvl(ctu.ler_id,pen.ler_id) = pen.ler_id
      and    nvl(ctu.pgm_id,nvl(pen.pgm_id,-1)) = nvl(pen.pgm_id,-1)
      and    nvl(ctu.pl_id,pen.pl_id) = pen.pl_id
      and    nvl(ctu.pl_typ_id,nvl(pen.pl_typ_id,-1)) = nvl(pen.pl_typ_id,-1)
             /* Now join in enrollment period */
      and    ((ctu.enrt_perd_id = pel.enrt_perd_id
      and    ((nvl(ctu.pl_id,nvl(pel.pl_id,-1)) = nvl(pel.pl_id,-1)
                 and pel.pgm_id is null)
               or nvl(ctu.pgm_id,nvl(pel.pgm_id,-1)) = nvl(pel.pgm_id,-1)))
      or     (ctu.enrt_perd_id is null))
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists (select null
                     from   ben_elig_cvrd_dpnt_f pdp
                     where  pdp.per_in_ler_id = pel.per_in_ler_id
                     and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pdp.dpnt_person_id = p_rcpent_person_id
                     and    pdp.business_group_id = pel.business_group_id
                     and    pdp.effective_start_date = p_effective_date);
    --
    cursor c_dpnt_always is
      select null
      from   ben_prtt_enrt_rslt_f pen,
             ben_per_in_ler pil
      where  pil.per_in_ler_id = p_per_in_ler_id
      and    pil.business_group_id = p_business_group_id
      and    pen.business_group_id  = pil.business_group_id
      and    pen.per_in_ler_id = pil.per_in_ler_id
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    pen.enrt_mthd_cd = p_enrt_mthd_cd
      and    p_effective_date
             between pen.effective_start_date
             and     pen.effective_end_date
      and    exists (select null
                     from   ben_elig_cvrd_dpnt_f pdp
                     where  pdp.per_in_ler_id = pil.per_in_ler_id
                     and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pdp.dpnt_person_id = p_rcpent_person_id
                     and    pdp.business_group_id = pil.business_group_id
                     and    pdp.effective_start_date = p_effective_date);
    --
    l_usage          c_dpnt_usage%rowtype;
    --
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('In Parameters',10);
    hr_utility.set_location('p_per_in_ler_id '||p_per_in_ler_id,10);
    hr_utility.set_location('p_rcpent_person_id '||p_rcpent_person_id,10);
    hr_utility.set_location('p_rcpent_cd '||p_rcpent_cd,10);
    hr_utility.set_location('p_business_group_id '||p_business_group_id,10);
    hr_utility.set_location('p_assignment_id '||p_assignment_id,10);
    --    hr_utility.set_location('p_enrt_perd_id '||p_enrt_perd_id,10);
    hr_utility.set_location('p_per_cm_id '||p_per_cm_id,10);
    hr_utility.set_location('p_cm_typ_id '||p_cm_typ_id,10);
    hr_utility.set_location('p_ler_id '||p_ler_id,10);
    hr_utility.set_location('p_lf_evt_ocrd_dt '||p_lf_evt_ocrd_dt,10);
    hr_utility.set_location('p_effective_date '||p_effective_date,10);
    hr_utility.set_location('p_whnvr_trgrd_flag ' || p_whnvr_trgrd_flag, 10);
    --
    -- Rules are as follows
    -- if p_proc_cd = 'RLTD_PER' then
    --   create record
    -- elsif p_proc_cd = 'DPNT' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- elsif p_proc_cd = 'BNF' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- end if
    --
    if p_rcpent_cd = 'RLTD_PER' then
      --
      l_created := true;
      --
    elsif p_rcpent_cd = 'BNF' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for BNF',10);
        open c_bnf_always;
          --
          fetch c_bnf_always into l_dummy;
          if c_bnf_always%found then
            --
            hr_utility.set_location('Communication Created for BNF',10);
            l_created := true;
            --
          end if;
          --
        close c_bnf_always;
        --
      else
        --
        -- We must create usages for the BNF
        --
        hr_utility.set_location('Communication usage test for BNF',10);
        --
        open c_bnf_usage;
          --
          loop
            --
            fetch c_bnf_usage into l_usage;
            exit when c_bnf_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage Created for BNF',10);
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_bnf_usage;
        --
      end if;
      --
    elsif p_rcpent_cd = 'DPNT' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for DPNT',10);
        --
        open c_dpnt_always;
          --
          fetch c_dpnt_always into l_dummy;
          if c_dpnt_always%found then
            --
            hr_utility.set_location('Communication created for DPNT',10);
            l_created := true;
            --
          end if;
          --
        close c_dpnt_always;
        --
      else
        --
        -- We must create usages for the DPNT
        --
        hr_utility.set_location('Communication usage test for DPNT',10);
        --
        open c_dpnt_usage;
          --
          loop
            --
            fetch c_dpnt_usage into l_usage;
            exit when c_dpnt_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage created for DPNT',10)
;
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_dpnt_usage;
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_expl_dflt_enrollment;
  --
  procedure check_close_enrollment
    (p_per_in_ler_id     in number,
     p_rcpent_person_id  in number,
     p_rcpent_cd         in varchar2,
     p_business_group_id in number,
     p_assignment_id     in number,
     p_ler_id            in number,
     p_per_cm_id         in number,
     p_cm_typ_id         in number,
     p_effective_date    in date,
     p_lf_evt_ocrd_dt    in date,
     p_whnvr_trgrd_flag  in varchar2,
     p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_close_enrollment';
    --
    -- Cursor fetch definition
    --
    cursor c_dpnt_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu,
             ben_pil_elctbl_chc_popl pel
      where  ctu.business_group_id  = p_business_group_id
      and    pel.business_group_id  = ctu.business_group_id
      and    pel.per_in_ler_id = p_per_in_ler_id
             /* Use nvl here as only pgm or pl can be populated */
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
      and    nvl(ctu.pgm_id,nvl(pel.pgm_id,-1)) = nvl(pel.pgm_id,-1)
      and    nvl(ctu.pl_id,nvl(pel.pl_id,-1)) = nvl(pel.pl_id,-1)
      and    nvl(ctu.enrt_perd_id,nvl(pel.enrt_perd_id,-1))
             = nvl(pel.enrt_perd_id,-1)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists (select null
                     from   ben_elig_cvrd_dpnt_f pdp
                     where  pdp.dpnt_person_id = p_rcpent_person_id
                     and    pdp.business_group_id = pel.business_group_id
                     and    pdp.per_in_ler_id = pel.per_in_ler_id
                     and    p_effective_date between pdp.effective_start_date
                                                and pdp.effective_end_date);
    --
    cursor c_dpnt_always is
      select null
      from   ben_elig_per_elctbl_chc epe,
             ben_per_in_ler pil
      where  pil.per_in_ler_id = p_per_in_ler_id
      and    pil.business_group_id = p_business_group_id
      and    epe.business_group_id  = pil.business_group_id
      and    epe.per_in_ler_id = pil.per_in_ler_id
      and    exists (select null
                     from   ben_elig_cvrd_dpnt_f pdp
                     where  pdp.dpnt_person_id = p_rcpent_person_id
                     and    pdp.business_group_id = pil.business_group_id
                     and    pdp.per_in_ler_id = pil.per_in_ler_id
                     and    pdp.effective_start_date = p_effective_date);
    --
    cursor c_bnf_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu,
             ben_pil_elctbl_chc_popl pel
      where  ctu.business_group_id  = p_business_group_id
      and    pel.business_group_id  = ctu.business_group_id
      and    pel.per_in_ler_id = p_per_in_ler_id
             /* Use nvl here as only pgm or pl can be populated */
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
      and    nvl(ctu.pgm_id,nvl(pel.pgm_id,-1)) = nvl(pel.pgm_id,-1)
      and    nvl(ctu.pl_id,nvl(pel.pl_id,-1)) = nvl(pel.pl_id,-1)
      and    nvl(ctu.enrt_perd_id,nvl(pel.enrt_perd_id,-1))
             = nvl(pel.enrt_perd_id,-1)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists (select null
                     from   ben_pl_bnf_f pbn
                     where  pbn.bnf_person_id = p_rcpent_person_id
                     and    pbn.business_group_id = pel.business_group_id
                     and    pbn.per_in_ler_id = pel.per_in_ler_id
                     and    pbn.effective_start_date = p_effective_date);
    --
    cursor c_bnf_always is
      select null
      from   ben_elig_per_elctbl_chc epe,
             ben_per_in_ler pil
      where  pil.per_in_ler_id = p_per_in_ler_id
      and    pil.business_group_id = p_business_group_id
      and    epe.business_group_id  = pil.business_group_id
      and    epe.per_in_ler_id = pil.per_in_ler_id
      and    exists (select null
                     from   ben_pl_bnf_f pbn
                     where  pbn.bnf_person_id = p_rcpent_person_id
                     and    pbn.business_group_id = pil.business_group_id
                     and    pbn.per_in_ler_id = pil.per_in_ler_id
                     and    pbn.effective_start_date = p_effective_date);
    --
    l_usage          c_dpnt_usage%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('In Parameters',10);
    hr_utility.set_location('p_per_in_ler_id '||p_per_in_ler_id,10);
    hr_utility.set_location('p_business_group_id '||p_business_group_id,10);
    hr_utility.set_location('p_assignment_id '||p_assignment_id,10);
    hr_utility.set_location('p_per_cm_id '||p_per_cm_id,10);
    hr_utility.set_location('p_cm_typ_id '||p_cm_typ_id,10);
    hr_utility.set_location('p_ler_id '||p_ler_id,10);
    hr_utility.set_location('p_effective_date '||p_effective_date,10);
    hr_utility.set_location('p_whnvr_trgrd_flag ' || p_whnvr_trgrd_flag, 10);
    --
    -- Rules are as follows
    -- if p_proc_cd = 'RLTD_PER' then
    --   create record
    -- elsif p_proc_cd = 'DPNT' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- elsif p_proc_cd = 'BNF' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- end if
    --
    if p_rcpent_cd = 'RLTD_PER' then
      --
      l_created := true;
      --
    elsif p_rcpent_cd = 'BNF' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for BNF',10);
        open c_bnf_always;
          --
          fetch c_bnf_always into l_dummy;
          if c_bnf_always%found then
            --
            hr_utility.set_location('Communication Created for BNF',10);
            l_created := true;
            --
          end if;
          --
        close c_bnf_always;
        --
      else
        --
        -- We must create usages for the BNF
        --
        hr_utility.set_location('Communication usage test for BNF',10);
        --
        open c_bnf_usage;
          --
          loop
            --
            fetch c_bnf_usage into l_usage;
            exit when c_bnf_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage Created for BNF',10);
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_bnf_usage;
        --
      end if;
      --
    elsif p_rcpent_cd = 'DPNT' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for DPNT',10);
        --
        open c_dpnt_always;
          --
          fetch c_dpnt_always into l_dummy;
          if c_dpnt_always%found then
            --
            hr_utility.set_location('Communication created for DPNT',10);
            l_created := true;
            --
          end if;
          --
        close c_dpnt_always;
        --
      else
        --
        -- We must create usages for the DPNT
        --
        hr_utility.set_location('Communication usage test for DPNT',10);
        --
        open c_dpnt_usage;
          --
          loop
            --
            fetch c_dpnt_usage into l_usage;
            exit when c_dpnt_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage created for DPNT',10)
;
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_dpnt_usage;
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_close_enrollment;
  --
  procedure check_actn_item
    (p_per_in_ler_id     in number,
     p_rcpent_person_id  in number,
     p_rcpent_cd         in varchar2,
     p_business_group_id in number,
     p_assignment_id     in number,
     p_actn_typ_id       in number,
     p_pgm_id            in number,
     p_pl_id             in number,
     p_pl_typ_id         in number,
     p_ler_id            in number,
     p_per_cm_id         in number,
     p_cm_typ_id         in number,
     p_effective_date    in date,
     p_lf_evt_ocrd_dt    in date,
     p_whnvr_trgrd_flag  in varchar2,
     p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_actn_item';
    --
    cursor c_bnf_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id  = p_business_group_id
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      and    (p_actn_typ_id is null or
              nvl(ctu.actn_typ_id,p_actn_typ_id) = p_actn_typ_id)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists (select null
                     from   ben_pl_bnf_f pbn,
                            ben_prtt_enrt_rslt_f pen,
                            ben_prtt_enrt_actn_f pea
                     where  pbn.business_group_id = ctu.business_group_id
                     and    pbn.per_in_ler_id = p_per_in_ler_id
                     and    pbn.bnf_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    pbn.effective_start_date = p_effective_date
                     and    pbn.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pen.business_group_id = pbn.business_group_id
                     and    pea.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pea.pl_bnf_id = pbn.pl_bnf_id
                     and    p_effective_date
                            between pen.effective_start_date
                            and     pen.effective_end_date
                     and    p_effective_date between
                            pea.effective_start_date and pea.effective_end_date
                     and    pea.actn_typ_id =
                            nvl(ctu.actn_typ_id, pea.actn_typ_id)
                     and    nvl(pen.pgm_id,-1) =
                            nvl(ctu.pgm_id,nvl(pen.pgm_id,-1))
                     and    pen.pl_id =
                            nvl(ctu.pl_id,pen.pl_id));
    --
    cursor c_bnf_always is
      select null
      from   sys.dual
      where  exists (select null
                     from   ben_pl_bnf_f pbn,
                            ben_prtt_enrt_rslt_f pen,
                            ben_prtt_enrt_actn_f pea
                     where  pbn.business_group_id = p_business_group_id
                     and    pbn.per_in_ler_id = p_per_in_ler_id
                     and    pbn.bnf_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    pbn.effective_start_date = p_effective_date
                     and    pbn.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pen.business_group_id = pbn.business_group_id
                     and    pea.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pea.pl_bnf_id = pbn.pl_bnf_id
                     and    p_effective_date between
                            pea.effective_start_date and pea.effective_end_date
                     and    p_effective_date
                            between pen.effective_start_date
                            and     pen.effective_end_date
                     and    (p_actn_typ_id is null or
                             pea.actn_typ_id = p_actn_typ_id)
                     and    (p_pgm_id is null or
                             pen.pgm_id = p_pgm_id)
                     and    (p_pl_id is null or
                             pen.pl_id = p_pl_id));
    --
    cursor c_dpnt_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id  = p_business_group_id
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      and    (p_actn_typ_id is null or
              nvl(ctu.actn_typ_id,p_actn_typ_id) = p_actn_typ_id)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists (select null
                     from   ben_elig_cvrd_dpnt pdp,
                            ben_prtt_enrt_rslt_f pen,
                            ben_prtt_enrt_actn_f pea
                     where  pdp.business_group_id = ctu.business_group_id
                     and    pdp.per_in_ler_id = p_per_in_ler_id
                     and    pdp.dpnt_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    pdp.effective_start_date = p_effective_date
                     and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pen.business_group_id = pdp.business_group_id
                     and    pea.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pea.elig_cvrd_dpnt_id = pdp.elig_cvrd_dpnt_id
                     and    p_effective_date
                            between pen.effective_start_date
                            and     pen.effective_end_date
                     and    p_effective_date between
                            pea.effective_start_date and pea.effective_end_date
                     and    pea.actn_typ_id =
                            nvl(ctu.actn_typ_id, pea.actn_typ_id)
                     and    nvl(pen.pgm_id,-1) =
                            nvl(ctu.pgm_id,nvl(pen.pgm_id,-1))
                     and    pen.pl_id =
                            nvl(ctu.pl_id,pen.pl_id));
    --
    cursor c_dpnt_always is
      select null
      from   sys.dual
      where  exists (select null
                     from   ben_elig_cvrd_dpnt_f pdp,
                            ben_prtt_enrt_rslt_f pen,
                            ben_prtt_enrt_actn_f pea
                     where  pdp.business_group_id = p_business_group_id
                     and    pdp.per_in_ler_id = p_per_in_ler_id
                     and    pdp.dpnt_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    pdp.effective_start_date = p_effective_date
                     and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pen.business_group_id = pdp.business_group_id
                     and    pea.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pea.elig_cvrd_dpnt_id = pdp.elig_cvrd_dpnt_id
                     and    p_effective_date between
                            pea.effective_start_date and pea.effective_end_date
                     and    p_effective_date
                            between pen.effective_start_date
                            and     pen.effective_end_date
                     and    (p_actn_typ_id is null or
                             pea.actn_typ_id = p_actn_typ_id)
                     and    (p_pgm_id is null or
                             pen.pgm_id = p_pgm_id)
                     and    (p_pl_id is null or
                             pen.pl_id = p_pl_id));
    --
    -- Cursor fetch definition
    --
    l_usage          c_dpnt_usage%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('In Parameters',10);
    hr_utility.set_location('p_per_in_ler_id '||p_per_in_ler_id,10);
    hr_utility.set_location('p_business_group_id '||p_business_group_id,10);
    hr_utility.set_location('p_assignment_id '||p_assignment_id,10);
    hr_utility.set_location('p_actn_typ_id '||p_actn_typ_id,10);
    hr_utility.set_location('p_pgm_id '||p_pgm_id,10);
    hr_utility.set_location('p_pl_id '||p_pl_id,10);
    hr_utility.set_location('p_per_cm_id '||p_per_cm_id,10);
    hr_utility.set_location('p_cm_typ_id '||p_cm_typ_id,10);
    hr_utility.set_location('p_effective_date '||p_effective_date,10);
    hr_utility.set_location('p_whnvr_trgrd_flag ' || p_whnvr_trgrd_flag, 10);
    --
    -- Rules are as follows
    -- if p_proc_cd = 'RLTD_PER' then
    --   create record
    -- elsif p_proc_cd = 'DPNT' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- elsif p_proc_cd = 'BNF' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- end if
    --
    if p_rcpent_cd = 'RLTD_PER' then
      --
      l_created := true;
      --
    elsif p_rcpent_cd = 'BNF' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for BNF',10);
        open c_bnf_always;
          --
          fetch c_bnf_always into l_dummy;
          if c_bnf_always%found then
            --
            hr_utility.set_location('Communication Created for BNF',10);
            l_created := true;
            --
          end if;
          --
        close c_bnf_always;
        --
      else
        --
        -- We must create usages for the BNF
        --
        hr_utility.set_location('Communication usage test for BNF',10);
        --
        open c_bnf_usage;
          --
          loop
            --
            fetch c_bnf_usage into l_usage;
            exit when c_bnf_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage Created for BNF',10);
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_bnf_usage;
        --
      end if;
      --
    elsif p_rcpent_cd = 'DPNT' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for DPNT',10);
        --
        open c_dpnt_always;
          --
          fetch c_dpnt_always into l_dummy;
          if c_dpnt_always%found then
            --
            hr_utility.set_location('Communication created for DPNT',10);
            l_created := true;
            --
          end if;
          --
        close c_dpnt_always;
        --
      else
        --
        -- We must create usages for the DPNT
        --
        hr_utility.set_location('Communication usage test for DPNT',10);
        --
        open c_dpnt_usage;
          --
          loop
            --
            fetch c_dpnt_usage into l_usage;
            exit when c_dpnt_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage created for DPNT',10)
;
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_dpnt_usage;
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_actn_item;
  --
  procedure check_dpnt_end_enrt
    (p_per_in_ler_id     in number,
     p_rcpent_person_id  in number,
     p_rcpent_cd         in varchar2,
     p_business_group_id in number,
     p_assignment_id     in number,
     p_pgm_id            in number,
     p_pl_id             in number,
     p_pl_typ_id         in number,
     p_ler_id            in number,
     p_per_cm_id         in number,
     p_cm_typ_id         in number,
     p_effective_date    in date,
     p_lf_evt_ocrd_dt    in date,
     p_whnvr_trgrd_flag  in varchar2,
     p_usages_created    out nocopy boolean) is
    --
    cursor c_dpnt_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id  = p_business_group_id
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists (select null
                     from   ben_elig_cvrd_dpnt_f pdp,
                            ben_prtt_enrt_rslt_f pen
                     where  pdp.business_group_id = ctu.business_group_id
                     and    pdp.dpnt_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    pdp.effective_start_date = p_effective_date
                     and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pen.business_group_id = pdp.business_group_id
                     and    p_effective_date
                            between pen.effective_start_date
                            and     pen.effective_end_date
                     and    nvl(pen.pgm_id,-1) =
                            nvl(ctu.pgm_id,nvl(pen.pgm_id,-1))
                     and    pen.pl_id =
                            nvl(ctu.pl_id,pen.pl_id));
    --
    cursor c_dpnt_always is
      select null
      from   ben_elig_cvrd_dpnt_f pdp,
             ben_prtt_enrt_rslt_f pen
      where  pdp.business_group_id = p_business_group_id
      and    pdp.dpnt_person_id = p_rcpent_person_id
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    pdp.effective_start_date = p_effective_date
      and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      and    pen.business_group_id = pdp.business_group_id
      and    p_effective_date
             between pen.effective_start_date
             and     pen.effective_end_date;
    --
    l_usage          c_dpnt_usage%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
    l_proc varchar2(80) := g_package || '.check_dpnt_end_enrt';
    --
  begin
    --
    hr_utility.set_location('Entering : ' || l_proc, 10);
    --
    hr_utility.set_location('In Parameters',10);
    hr_utility.set_location('p_per_in_ler_id '||p_per_in_ler_id,10);
    hr_utility.set_location('p_rcpent_person_id '||p_rcpent_person_id,10);
    hr_utility.set_location('p_rcpent_cd '||p_rcpent_cd,10);
    hr_utility.set_location('p_business_group_id '||p_business_group_id,10);
    hr_utility.set_location('p_assignment_id '||p_assignment_id,10);
    hr_utility.set_location('p_pgm_id '||p_pgm_id,10);
    hr_utility.set_location('p_pl_id '||p_pl_id,10);
    hr_utility.set_location('p_per_cm_id '||p_per_cm_id,10);
    hr_utility.set_location('p_cm_typ_id '||p_cm_typ_id,10);
    hr_utility.set_location('p_effective_date '||p_effective_date,10);
    hr_utility.set_location('p_whnvr_trgrd_flag ' || p_whnvr_trgrd_flag, 10);
    --
    -- Rules are as follows
    -- if p_proc_cd = 'RLTD_PER' then
    --   dont create record
    -- elsif p_proc_cd = 'DPNT' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- elsif p_proc_cd = 'BNF' then
    --   dont create record
    -- end if
    --
    if p_rcpent_cd = 'RLTD_PER' then
      --
      l_created := false;
      --
    elsif p_rcpent_cd = 'BNF' then
      --
      l_created := false;
      --
    elsif p_rcpent_cd = 'DPNT' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for DPNT',10);
        --
        open c_dpnt_always;
          --
          fetch c_dpnt_always into l_dummy;
          if c_dpnt_always%found then
            --
            hr_utility.set_location('Communication created for DPNT',10);
            l_created := true;
            --
          end if;
          --
        close c_dpnt_always;
        --
      else
        --
        -- We must create usages for the DPNT
        --
        hr_utility.set_location('Communication usage test for DPNT',10);
        --
        open c_dpnt_usage;
          --
          loop
            --
            fetch c_dpnt_usage into l_usage;
            exit when c_dpnt_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage created for DPNT',10)
;
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_dpnt_usage;
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_dpnt_end_enrt;
  --
  procedure check_mass_mail
    (p_per_in_ler_id     in number,
     p_rcpent_person_id  in number,
     p_rcpent_cd         in varchar2,
     p_business_group_id in number,
     p_assignment_id     in number,
     p_pgm_id            in number,
     p_pl_id             in number,
     p_pl_typ_id         in number,
     p_ler_id            in number,
     p_per_cm_id         in number,
     p_cm_typ_id         in number,
     p_effective_date    in date,
     p_lf_evt_ocrd_dt    in date,
     p_whnvr_trgrd_flag  in varchar2,
     p_usages_created    out nocopy boolean) is
    --
    cursor c_dpnt_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id  = p_business_group_id
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists (select null
                     from   ben_elig_cvrd_dpnt_f pdp,
                            ben_prtt_enrt_rslt_f pen
                     where  pdp.business_group_id = ctu.business_group_id
                     and    pdp.per_in_ler_id = p_per_in_ler_id
                     and    pdp.dpnt_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    pdp.effective_start_date = p_effective_date
                     and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pen.business_group_id = pdp.business_group_id
                     and    p_effective_date
                            between pen.effective_start_date
                            and     pen.effective_end_date
                     and    nvl(pen.pgm_id,-1) =
                            nvl(ctu.pgm_id,nvl(pen.pgm_id,-1))
                     and    pen.pl_id =
                            nvl(ctu.pl_id,pen.pl_id));
    --
    cursor c_dpnt_always is
      select null
      from   sys.dual
      where  exists (select null
                     from   ben_elig_cvrd_dpnt_f pdp,
                            ben_prtt_enrt_rslt_f pen
                     where  pdp.business_group_id = p_business_group_id
                     and    pdp.per_in_ler_id = p_per_in_ler_id
                     and    pdp.dpnt_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    pdp.effective_start_date = p_effective_date
                     and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pen.business_group_id = pdp.business_group_id
                     and    p_effective_date
                            between pen.effective_start_date
                            and     pen.effective_end_date
                     and    (p_pgm_id is null or
                             pen.pgm_id = p_pgm_id)
                     and    (p_pl_id is null or
                             pen.pl_id = p_pl_id));
    --
    cursor c_bnf_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id  = p_business_group_id
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists (select null
                     from   ben_pl_bnf_f pbn,
                            ben_prtt_enrt_rslt_f pen
                     where  pbn.business_group_id = ctu.business_group_id
                     and    pbn.per_in_ler_id = p_per_in_ler_id
                     and    pbn.bnf_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    pbn.effective_start_date = p_effective_date
                     and    pbn.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pen.business_group_id = pbn.business_group_id
                     and    p_effective_date
                            between pen.effective_start_date
                            and     pen.effective_end_date
                     and    nvl(pen.pgm_id,-1) =
                            nvl(ctu.pgm_id,nvl(pen.pgm_id,-1))
                     and    pen.pl_id =
                            nvl(ctu.pl_id,pen.pl_id));
    --
    cursor c_bnf_always is
      select null
      from   sys.dual
      where  exists (select null
                     from   ben_pl_bnf_f pbn,
                            ben_prtt_enrt_rslt_f pen
                     where  pbn.business_group_id = p_business_group_id
                     and    pbn.per_in_ler_id = p_per_in_ler_id
                     and    pbn.bnf_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    pbn.effective_start_date = p_effective_date
                     and    pbn.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pen.business_group_id = pbn.business_group_id
                     and    p_effective_date
                            between pen.effective_start_date
                            and     pen.effective_end_date
                     and    (p_pgm_id is null or
                             pen.pgm_id = p_pgm_id)
                     and    (p_pl_id is null or
                             pen.pl_id = p_pl_id));
    --
    l_usage          c_dpnt_usage%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
    l_proc varchar2(80) := g_package || '.check_mass_mail';
    --
  begin
    --
    hr_utility.set_location('Entering : ' || l_proc, 10);
    --
    hr_utility.set_location('In Parameters',10);
    hr_utility.set_location('p_per_in_ler_id '||p_per_in_ler_id,10);
    hr_utility.set_location('p_rcpent_person_id '||p_rcpent_person_id,10);
    hr_utility.set_location('p_rcpent_cd '||p_rcpent_cd,10);
    hr_utility.set_location('p_business_group_id '||p_business_group_id,10);
    hr_utility.set_location('p_assignment_id '||p_assignment_id,10);
    hr_utility.set_location('p_pgm_id '||p_pgm_id,10);
    hr_utility.set_location('p_pl_id '||p_pl_id,10);
    hr_utility.set_location('p_per_cm_id '||p_per_cm_id,10);
    hr_utility.set_location('p_cm_typ_id '||p_cm_typ_id,10);
    hr_utility.set_location('p_effective_date '||p_effective_date,10);
    hr_utility.set_location('p_whnvr_trgrd_flag ' || p_whnvr_trgrd_flag, 10);
    --
    -- Rules are as follows
    -- if p_proc_cd = 'RLTD_PER' then
    --   create record
    -- elsif p_proc_cd = 'DPNT' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- elsif p_proc_cd = 'BNF' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- end if
    --
    if p_rcpent_cd = 'RLTD_PER' then
      --
      l_created := true;
      --
    elsif p_rcpent_cd = 'BNF' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for BNF',10);
        open c_bnf_always;
          --
          fetch c_bnf_always into l_dummy;
          if c_bnf_always%found then
            --
            hr_utility.set_location('Communication Created for BNF',10);
            l_created := true;
            --
          end if;
          --
        close c_bnf_always;
        --
      else
        --
        -- We must create usages for the BNF
        --
        hr_utility.set_location('Communication usage test for BNF',10);
        --
        open c_bnf_usage;
          --
          loop
            --
            fetch c_bnf_usage into l_usage;
            exit when c_bnf_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage Created for BNF',10);
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_bnf_usage;
        --
      end if;
      --
    elsif p_rcpent_cd = 'DPNT' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for DPNT',10);
        --
        open c_dpnt_always;
          --
          fetch c_dpnt_always into l_dummy;
          if c_dpnt_always%found then
            --
            hr_utility.set_location('Communication created for DPNT',10);
            l_created := true;
            --
          end if;
          --
        close c_dpnt_always;
        --
      else
        --
        -- We must create usages for the DPNT
        --
        hr_utility.set_location('Communication usage test for DPNT',10);
        --
        open c_dpnt_usage;
          --
          loop
            --
            fetch c_dpnt_usage into l_usage;
            exit when c_dpnt_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage created for DPNT',10)
;
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_dpnt_usage;
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_mass_mail;
  --
  procedure check_enrt_rmdr
    (p_per_in_ler_id     in number,
     p_rcpent_person_id  in number,
     p_rcpent_cd         in varchar2,
     p_business_group_id in number,
     p_assignment_id     in number,
     -- PB : 5422 :
     -- p_enrt_perd_id      in number,
     p_asnd_lf_evt_dt    in date,
     p_ler_id            in number,
     p_pl_id             in number,
     p_pl_typ_id         in number,
     p_pgm_id            in number,
     p_per_cm_id         in number,
     p_cm_typ_id         in number,
     p_enrt_mthd_cd      in varchar2,
     p_lf_evt_ocrd_dt    in date,
     p_effective_date    in date,
     p_whnvr_trgrd_flag  in varchar2,
     p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package || 'check_enrt_rmdr';
    --
    cursor c_dpnt_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu,
             ben_pil_elctbl_chc_popl pel
      where  ctu.business_group_id  = p_business_group_id
      and    pel.business_group_id  = ctu.business_group_id
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      /* PB : 5422 :
      and    (p_enrt_perd_id is null or
              nvl(ctu.enrt_perd_id,p_enrt_perd_id) = p_enrt_perd_id)
      */
      and    (p_asnd_lf_evt_dt is null or
              ctu.enrt_perd_id is null or
              ctu.enrt_perd_id =
                  ( select enp.enrt_perd_id
                    from ben_enrt_perd enp
                    where enp.asnd_lf_evt_dt = enp.asnd_lf_evt_dt
                      and enp.enrt_perd_id = pel.enrt_perd_id
                      and enp.business_group_id = p_business_group_id
                  )
             )
             /* Now join in enrollment period */
      and    pel.per_in_ler_id = p_per_in_ler_id
      and    nvl(ctu.enrt_perd_id,nvl(pel.enrt_perd_id,-1))
             = nvl(pel.enrt_perd_id, -1)
      and    nvl(ctu.pl_id,nvl(pel.pl_id,-1)) = nvl(pel.pl_id,-1)
      and    nvl(ctu.pgm_id,nvl(pel.pgm_id,-1)) = nvl(pel.pgm_id,-1)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists (select null
                     from   ben_elig_cvrd_dpnt_f pdp
                     where  pdp.business_group_id = pel.business_group_id
                     and    pdp.dpnt_person_id = p_rcpent_person_id
                     and    pdp.effective_start_date = p_effective_date
                     and    pdp.per_in_ler_id = pel.per_in_ler_id);
    --
    cursor c_dpnt_always is
      select null
      from   sys.dual
      where  exists (select null
                     from   ben_elig_cvrd_dpnt_f pdp
                     where  pdp.business_group_id = p_business_group_id
                     and    pdp.dpnt_person_id = p_rcpent_person_id
                     and    pdp.effective_start_date = p_effective_date
                     and    pdp.per_in_ler_id = p_per_in_ler_id);
    --
    cursor c_bnf_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu,
             ben_pil_elctbl_chc_popl pel
      where  ctu.business_group_id  = p_business_group_id
      and    pel.business_group_id  = ctu.business_group_id
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      /* PB : 5422 :
      and    (p_enrt_perd_id is null or
              nvl(ctu.enrt_perd_id,p_enrt_perd_id) = p_enrt_perd_id)
      */
      and    (p_asnd_lf_evt_dt is null or
              ctu.enrt_perd_id is null or
              ctu.enrt_perd_id =
                  ( select enp.enrt_perd_id
                    from ben_enrt_perd enp
                    where enp.asnd_lf_evt_dt = enp.asnd_lf_evt_dt
                      and enp.enrt_perd_id = pel.enrt_perd_id
                      and enp.business_group_id = p_business_group_id
                  )
             )
             /* Now join in enrollment period */
      and    pel.per_in_ler_id = p_per_in_ler_id
      and    nvl(ctu.enrt_perd_id,nvl(pel.enrt_perd_id,-1))
             = nvl(pel.enrt_perd_id, -1)
      and    nvl(ctu.pl_id,nvl(pel.pl_id,-1)) = nvl(pel.pl_id,-1)
      and    nvl(ctu.pgm_id,nvl(pel.pgm_id,-1)) = nvl(pel.pgm_id,-1)
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists (select null
                     from   ben_pl_bnf_f pbn
                     where  pbn.business_group_id = pel.business_group_id
                     and    pbn.bnf_person_id = p_rcpent_person_id
                     and    pbn.effective_start_date = p_effective_date
                     and    pbn.per_in_ler_id = pel.per_in_ler_id);
    --
    cursor c_bnf_always is
      select null
      from   sys.dual
      where  exists (select null
                     from   ben_pl_bnf_f pbn
                     where  pbn.business_group_id = p_business_group_id
                     and    pbn.bnf_person_id = p_rcpent_person_id
                     and    pbn.effective_start_date = p_effective_date
                     and    pbn.per_in_ler_id = p_per_in_ler_id);
    --
    -- Cursor fetch definition
    --
    l_usage          c_dpnt_usage%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('In Parameters',10);
    hr_utility.set_location('p_per_in_ler_id '||p_per_in_ler_id,10);
    hr_utility.set_location('p_rcpent_person_id '||p_rcpent_person_id,10);
    hr_utility.set_location('p_rcpent_cd '||p_rcpent_cd,10);
    hr_utility.set_location('p_business_group_id '||p_business_group_id,10);
    hr_utility.set_location('p_assignment_id '||p_assignment_id,10);
    --    hr_utility.set_location('p_enrt_perd_id '||p_enrt_perd_id,10);
    hr_utility.set_location('p_per_cm_id '||p_per_cm_id,10);
    hr_utility.set_location('p_cm_typ_id '||p_cm_typ_id,10);
    hr_utility.set_location('p_ler_id '||p_ler_id,10);
    hr_utility.set_location('p_effective_date '||p_effective_date,10);
    --
    -- Rules are as follows
    -- if p_proc_cd = 'RLTD_PER' then
    --   create record
    -- elsif p_proc_cd = 'DPNT' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- elsif p_proc_cd = 'BNF' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- end if
    --
    if p_rcpent_cd = 'RLTD_PER' then
      --
      l_created := true;
      --
    elsif p_rcpent_cd = 'BNF' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for BNF',10);
        open c_bnf_always;
          --
          fetch c_bnf_always into l_dummy;
          if c_bnf_always%found then
            --
            hr_utility.set_location('Communication Created for BNF',10);
            l_created := true;
            --
          end if;
          --
        close c_bnf_always;
        --
      else
        --
        -- We must create usages for the BNF
        --
        hr_utility.set_location('Communication usage test for BNF',10);
        --
        open c_bnf_usage;
          --
          loop
            --
            fetch c_bnf_usage into l_usage;
            exit when c_bnf_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage Created for BNF',10);
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_bnf_usage;
        --
      end if;
      --
    elsif p_rcpent_cd = 'DPNT' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for DPNT',10);
        --
        open c_dpnt_always;
          --
          fetch c_dpnt_always into l_dummy;
          if c_dpnt_always%found then
            --
            hr_utility.set_location('Communication created for DPNT',10);
            l_created := true;
            --
          end if;
          --
        close c_dpnt_always;
        --
      else
        --
        -- We must create usages for the DPNT
        --
        hr_utility.set_location('Communication usage test for DPNT',10);
        --
        open c_dpnt_usage;
          --
          loop
            --
            fetch c_dpnt_usage into l_usage;
            exit when c_dpnt_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage created for DPNT',10)
;
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_dpnt_usage;
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_enrt_rmdr;
  --
  procedure check_emrg_evt
    (p_per_in_ler_id     in number,
     p_rcpent_person_id  in number,
     p_rcpent_cd         in varchar2,
     p_business_group_id in number,
     p_assignment_id     in number,
     p_pgm_id            in number,
     p_pl_id             in number,
     p_pl_typ_id         in number,
     -- PB : 5422 :
     -- p_enrt_perd_id      in number,
     p_asnd_lf_evt_dt    in date,
     p_ler_id            in number,
     p_per_cm_id         in number,
     p_cm_typ_id         in number,
     p_enrt_mthd_cd      in varchar2,
     p_lf_evt_ocrd_dt    in date,
     p_effective_date    in date,
     p_whnvr_trgrd_flag  in varchar2,
     p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package || 'check_emrg_evt';
    --
    cursor c_dpnt_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id  = p_business_group_id
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      and    ben_generate_communications.g_comm_start_date between
             ctu.effective_start_date and ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists (select null
                     from   ben_elig_cvrd_dpnt_f pdp,
                            ben_prtt_enrt_rslt_f pen
                     where  pdp.business_group_id = ctu.business_group_id
                     and    pdp.per_in_ler_id = p_per_in_ler_id
                     and    pdp.dpnt_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    p_effective_date between
                            pdp.effective_start_date and pdp.effective_end_date
                     and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pen.business_group_id = pdp.business_group_id
                     and    p_effective_date
                            between pen.effective_start_date
                            and     pen.effective_end_date
                     and    nvl(pen.pgm_id,-1) =
                            nvl(ctu.pgm_id,nvl(pen.pgm_id,-1))
                     and    pen.pl_id =
                            nvl(ctu.pl_id,pen.pl_id));
    --
    cursor c_dpnt_always is
      select null
      from   sys.dual
      where  exists (select null
                     from   ben_elig_cvrd_dpnt_f pdp,
                            ben_prtt_enrt_rslt_f pen
                     where  pdp.business_group_id = p_business_group_id
                     and    pdp.per_in_ler_id = p_per_in_ler_id
                     and    pdp.dpnt_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    p_effective_date between
                            pdp.effective_start_date and pdp.effective_end_date
                     and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pen.business_group_id = pdp.business_group_id
                     and    p_effective_date
                            between pen.effective_start_date
                            and     pen.effective_end_date
                     and    (p_pgm_id is null or
                             pen.pgm_id = p_pgm_id)
                     and    (p_pl_id is null or
                             pen.pl_id = p_pl_id));
    --
    cursor c_bnf_usage is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id  = p_business_group_id
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      and    ben_generate_communications.g_comm_start_date between
             ctu.effective_start_date and ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL'
      and    exists (select null
                     from   ben_pl_bnf_f pbn,
                            ben_prtt_enrt_rslt_f pen
                     where  pbn.business_group_id = ctu.business_group_id
                     and    pbn.per_in_ler_id = p_per_in_ler_id
                     and    pbn.bnf_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    p_effective_date between
                            pbn.effective_start_date and pbn.effective_end_date
                     and    pbn.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pen.business_group_id = pbn.business_group_id
                     and    p_effective_date
                            between pen.effective_start_date
                            and     pen.effective_end_date
                     and    nvl(pen.pgm_id,-1) =
                            nvl(ctu.pgm_id,nvl(pen.pgm_id,-1))
                     and    pen.pl_id =
                            nvl(ctu.pl_id,pen.pl_id));
    --
    cursor c_bnf_always is
      select null
      from   sys.dual
      where  exists (select null
                     from   ben_pl_bnf_f pbn,
                            ben_prtt_enrt_rslt_f pen
                     where  pbn.business_group_id = p_business_group_id
                     and    pbn.per_in_ler_id = p_per_in_ler_id
                     and    pbn.bnf_person_id = p_rcpent_person_id
                     and    pen.prtt_enrt_rslt_stat_cd is null
                     and    p_effective_date between
                            pbn.effective_start_date and pbn.effective_end_date
                     and    pbn.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
                     and    pen.business_group_id = pbn.business_group_id
                     and    p_effective_date
                            between pen.effective_start_date
                            and     pen.effective_end_date
                     and    (p_pgm_id is null or
                             pen.pgm_id = p_pgm_id)
                     and    (p_pl_id is null or
                             pen.pl_id = p_pl_id));
    --
    -- Cursor fetch definition
    --
    l_usage          c_dpnt_usage%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    l_dummy          varchar2(1);
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('In Parameters',10);
    hr_utility.set_location('p_per_in_ler_id '||p_per_in_ler_id,10);
    hr_utility.set_location('p_rcpent_person_id '||p_rcpent_person_id,10);
    hr_utility.set_location('p_rcpent_cd '||p_rcpent_cd,10);
    hr_utility.set_location('p_business_group_id '||p_business_group_id,10);
    hr_utility.set_location('p_assignment_id '||p_assignment_id,10);
    -- hr_utility.set_location('p_enrt_perd_id '||p_enrt_perd_id,10);
    hr_utility.set_location('p_per_cm_id '||p_per_cm_id,10);
    hr_utility.set_location('p_cm_typ_id '||p_cm_typ_id,10);
    hr_utility.set_location('p_ler_id '||p_ler_id,10);
    hr_utility.set_location('p_effective_date '||p_effective_date,10);
    --
    -- Rules are as follows
    -- if p_proc_cd = 'RLTD_PER' then
    --   create record
    -- elsif p_proc_cd = 'DPNT' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- elsif p_proc_cd = 'BNF' then
    --   if p_whnvr_trgrd_flag = 'Y' then
    --     if any enrollment result has been made ineligible
    --       create record
    --     end if;
    --   else
    --     if a communication usage exists then
    --       create record
    --     end if
    -- end if
    --
    if p_rcpent_cd = 'RLTD_PER' then
      --
      l_created := true;
      --
    elsif p_rcpent_cd = 'BNF' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for BNF',10);
        open c_bnf_always;
          --
          fetch c_bnf_always into l_dummy;
          if c_bnf_always%found then
            --
            hr_utility.set_location('Communication Created for BNF',10);
            l_created := true;
            --
          end if;
          --
        close c_bnf_always;
        --
      else
        --
        -- We must create usages for the BNF
        --
        hr_utility.set_location('Communication usage test for BNF',10);
        --
        open c_bnf_usage;
          --
          loop
            --
            fetch c_bnf_usage into l_usage;
            exit when c_bnf_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage Created for BNF',10);
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_bnf_usage;
        --
      end if;
      --
    elsif p_rcpent_cd = 'DPNT' then
      --
      if p_whnvr_trgrd_flag = 'Y' then
        --
        hr_utility.set_location('Communication test for DPNT',10);
        --
        open c_dpnt_always;
          --
          fetch c_dpnt_always into l_dummy;
          if c_dpnt_always%found then
            --
            hr_utility.set_location('Communication created for DPNT',10);
            l_created := true;
            --
          end if;
          --
        close c_dpnt_always;
        --
      else
        --
        -- We must create usages for the DPNT
        --
        hr_utility.set_location('Communication usage test for DPNT',10);
        --
        open c_dpnt_usage;
          --
          loop
            --
            fetch c_dpnt_usage into l_usage;
            exit when c_dpnt_usage%notfound;
            --
            if rule_passes
               (p_rule_id        => l_usage.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_rcpent_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
              --
              -- create usage
              --
              hr_utility.set_location('Communication usage created for DPNT',10)
;
              --
              ben_generate_communications.pop_ben_per_cm_usg_f
                (p_per_cm_id            => p_per_cm_id,
                 p_cm_typ_usg_id        => l_usage.cm_typ_usg_id,
                 p_business_group_id    => p_business_group_id,
                 p_effective_date       => p_effective_date,
                 p_per_cm_usg_id        => l_per_cm_usg_id,
                 p_usage_created        => l_usages_created);
              --
              if l_usages_created then
                --
                -- Set boolean so we know that we created at least one usage
                --
                l_created := true;
                --
              end if;
              --
            end if;
            --
          end loop;
          --
        close c_dpnt_usage;
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_emrg_evt;
  --
  procedure check_hipaa_usages
      (p_per_in_ler_id     in number,
       p_person_id         in number,
       p_business_group_id in number,
       p_assignment_id     in number,
       p_pgm_id            in number,
       p_pl_id             in number,
       p_pl_typ_id         in number,
       p_ler_id            in number,
       -- PB : 5422 :
       p_asnd_lf_evt_dt    in date,
       -- p_enrt_perd_id      in number,
       p_per_cm_id         in number,
       p_cm_typ_id         in number,
       p_effective_date    in date,
       p_lf_evt_ocrd_dt    in date,
       p_whnvr_trgrd_flag  in varchar2,
       p_usages_created    out nocopy boolean) is
    --
    l_proc           varchar2(80) := g_package||'check_hipaa_usages';
    l_effective_date date;
    --
    cursor c1 is
      select ctu.cm_typ_usg_id,
             ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id   = p_business_group_id
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_pl_typ_id is null or
              nvl(ctu.pl_typ_id,p_pl_typ_id) = p_pl_typ_id)
      /* PB : 5422 :
      and    (p_enrt_perd_id is null or
              nvl(ctu.enrt_perd_id,p_enrt_perd_id) = p_enrt_perd_id)
      */
      and    (p_asnd_lf_evt_dt is null or
              ctu.enrt_perd_id is null or
              ctu.enrt_perd_id =
                  ( select enp.enrt_perd_id
                    from ben_enrt_perd enp,
                         ben_popl_enrt_typ_cycl_f pet
                    where enp.asnd_lf_evt_dt = enp.asnd_lf_evt_dt
                      and enp.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id
                      and (p_pl_id is null or
                           nvl(pet.pl_id,p_pl_id) = p_pl_id)
                      and (p_pgm_id is null or
                           nvl(pet.pgm_id,p_pgm_id) = p_pgm_id)
                      and pet.business_group_id  = enp.business_group_id
                      and enp.business_group_id = p_business_group_id
                      and p_effective_date between pet.effective_start_date
                                                  and pet.effective_end_date
                  )
             )
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.all_r_any_cd = 'ALL';
    --
    -- Cursor fetch definition
    --
    l_c1             c1%rowtype;
    --
    -- Local variables
    --
    l_usages_created boolean := false;
    l_created        boolean := false;
    --
    -- Output variables
    --
    l_per_cm_usg_id  number;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
    --
    if p_whnvr_trgrd_flag = 'N' then
      --
      open c1;
        --
        loop
          --
          fetch c1 into l_c1;
          exit when c1%notfound;
          --
          if rule_passes
               (p_rule_id        => l_c1.cm_usg_rl,
                p_per_cm_id      => p_per_cm_id,
                p_assignment_id  => p_assignment_id,
                --RCHASE Bug Fix - must have person_id for dependent joins
                p_rcpent_person_id => p_person_id,
                --RCHASE end
                p_business_group_id => p_business_group_id,
                p_ler_id            => p_ler_id,
                p_effective_date => nvl(p_lf_evt_ocrd_dt,
                                        p_effective_date)) then
            --
            -- create usage
            --
            ben_generate_communications.pop_ben_per_cm_usg_f
              (p_per_cm_id            => p_per_cm_id,
               p_cm_typ_usg_id        => l_c1.cm_typ_usg_id,
               p_business_group_id    => p_business_group_id,
               p_effective_date       => p_effective_date,
               p_per_cm_usg_id        => l_per_cm_usg_id,
               p_usage_created        => l_usages_created);
            --
            if l_usages_created then
              --
              -- Set boolean so we know that we created at least one usage
              --
              l_created := true;
              --
            end if;
            --
          end if;
          --
        end loop;
        --
      close c1;
      --
    else
      --
      l_created := true;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
    p_usages_created := l_created;
    --
  end check_hipaa_usages;
  --
  procedure check_hipaa_ctfn
      (p_per_in_ler_id     in number,
       p_person_id         in number,
       p_rcpent_person_id  in number,
       p_business_group_id in number,
       p_assignment_id     in number,
       p_pgm_id            in number,
       p_pl_id             in number,
       p_pl_typ_id         in number,
       -- PB : 5422 :
       -- p_enrt_perd_id      in number,
       p_asnd_lf_evt_dt    in date,
       p_ler_id            in number,
       p_per_cm_id         in number,
       p_cm_typ_id         in number,
       p_effective_date    in date,
       p_lf_evt_ocrd_dt    in date,
       p_whnvr_trgrd_flag  in varchar2,
       p_usages_created    out nocopy boolean,
       p_rsds_with_prtt    in varchar2,
       p_source            in varchar2) is
    --
    l_proc                 varchar2(80) := g_package||'check_hipaa_ctfn';
    l_epe_exists           varchar2(30) := 'N';
    l_crntly_enrd          varchar2(30) := 'N';
    l_prtt_crntly_enrd     varchar2(30) := 'N';
    l_created              boolean      := false;
    l_usages_created       boolean      := false;
    l_max_enrt_cvg_thru_dt date    := null;
    l_pgm_id               number  := p_pgm_id;
    l_pl_typ_id            number  := p_pl_typ_id;
    l_effective_date date;
    --
    l_per_rec              per_all_people_f%rowtype;
    l_prtt_per_rec         per_all_people_f%rowtype;
    --
    -- This cursor gets all the dependents that were de-enrolled
    -- due/during this life event and satisfies the HIPAA conditions
    -- and regulation.
    --
    cursor c_prev_enrt is
       select pen.pgm_id, pen.pl_typ_id, max(pen.enrt_cvg_thru_dt)
       from   ben_elig_cvrd_dpnt_f pdp,
              ben_prtt_enrt_rslt_f pen,
              ben_pl_f             pln,
              ben_pl_regn_f        plrg,
              ben_regn_f           regn,
              ben_oipl_f           cop,
              ben_opt_f            opt
       where  pdp.per_in_ler_id    = p_per_in_ler_id
       and    pdp.dpnt_person_id   = p_rcpent_person_id
       and    pdp.cvg_thru_dt      <> hr_api.g_eot
       and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
       and    pen.sspndd_flag = 'N'
       and    pen.prtt_enrt_rslt_stat_cd is null
       and    p_effective_date between
              pdp.effective_start_date and pdp.effective_end_date
       and    p_effective_date between
              pen.effective_start_date and pen.effective_end_date
       and    pen.pl_id = pln.pl_id
       and    pln.invk_dcln_prtn_pl_flag = 'N'
       and    p_effective_date between
              pln.effective_start_date and pln.effective_end_date
       and    plrg.pl_id = pln.pl_id
       and    plrg.regn_id = regn.regn_id
       and    regn.sttry_citn_name = 'HIPAA'
       and    p_effective_date between
              plrg.effective_start_date and plrg.effective_end_date
       and    p_effective_date between
              regn.effective_start_date and regn.effective_end_date
       and    pen.oipl_id = cop.oipl_id (+)
       and    p_effective_date between
              nvl(cop.effective_start_date, p_effective_date) and
              nvl(cop.effective_end_date, p_effective_date)
       and    nvl(cop.opt_id, -1) = opt.opt_id (+)
       and    nvl(opt.invk_wv_opt_flag, 'N') = 'N'
       and    p_effective_date between
              nvl(opt.effective_start_date, p_effective_date) and
              nvl(opt.effective_end_date, p_effective_date)
       group by pen.pgm_id, pen.pl_typ_id;
    --
    -- This cursor gets all the dependents that were de-enrolled
    -- due/during this run of "bendsgel" and satisfies the HIPAA conditions
    -- and regulation.
    --
    cursor c_bendsgel_prev_enrt is
       select max(pen.enrt_cvg_thru_dt)
       from   ben_elig_cvrd_dpnt_f pdp,
              ben_prtt_enrt_rslt_f pen,
              ben_pl_f             pln,
              ben_pl_regn_f        plrg,
              ben_regn_f           regn,
              ben_oipl_f           cop,
              ben_opt_f            opt
       where  pdp.effective_start_date  = p_effective_date
       and    pdp.dpnt_person_id   = p_rcpent_person_id
       and    pdp.request_id       = fnd_global.conc_request_id
       and    pdp.cvg_thru_dt      <> hr_api.g_eot
       and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
       and    pen.pgm_id            = p_pgm_id
       and    pen.pl_typ_id         = p_pl_typ_id
       and    pen.sspndd_flag = 'N'
       and    pen.prtt_enrt_rslt_stat_cd is null
       and    p_effective_date between
              pdp.effective_start_date and pdp.effective_end_date
       and    p_effective_date between
              pen.effective_start_date and pen.effective_end_date
       and    pen.pl_id = pln.pl_id
       and    pln.invk_dcln_prtn_pl_flag = 'N'
       and    p_effective_date between
              pln.effective_start_date and pln.effective_end_date
       and    plrg.pl_id = pln.pl_id
       and    plrg.regn_id = regn.regn_id
       and    regn.sttry_citn_name = 'HIPAA'
       and    p_effective_date between
              plrg.effective_start_date and plrg.effective_end_date
       and    p_effective_date between
              regn.effective_start_date and regn.effective_end_date
       and    pen.oipl_id = cop.oipl_id (+)
       and    p_effective_date between
              nvl(cop.effective_start_date, p_effective_date) and
              nvl(cop.effective_end_date, p_effective_date)
       and    nvl(cop.opt_id, -1) = opt.opt_id (+)
       and    nvl(opt.invk_wv_opt_flag, 'N') = 'N'
       and    p_effective_date between
              nvl(opt.effective_start_date, p_effective_date) and
              nvl(opt.effective_end_date, p_effective_date)
       group by pen.pgm_id, pen.pl_typ_id;
    --
    -- This cursor checks existence of any eligible dependents for that
    -- plan type with a started per in ler.
    --
    cursor c_epe is
       select 'Y'
       from   ben_elig_dpnt egd,
              ben_elig_per_elctbl_chc epe,
              ben_per_in_ler          pil,
              ben_pl_f             pln,
              ben_oipl_f           cop,
              ben_opt_f            opt
       where  epe.per_in_ler_id = p_per_in_ler_id
       and    nvl(epe.pgm_id,-1) = nvl(l_pgm_id,-1)
       and    epe.pl_typ_id     = l_pl_typ_id
       and    epe.elctbl_flag   = 'Y'
       and    epe.per_in_ler_id = pil.per_in_ler_id
       and    pil.per_in_ler_stat_cd = 'STRTD'
       and    epe.elig_per_elctbl_chc_id = egd.elig_per_elctbl_chc_id
       and    egd.dpnt_person_id = p_rcpent_person_id
       and    egd.dpnt_inelig_flag = 'N'
       and    epe.pl_id = pln.pl_id
       and    pln.invk_dcln_prtn_pl_flag = 'N'
       and    p_effective_date between
              pln.effective_start_date and pln.effective_end_date
       and    epe.oipl_id = cop.oipl_id (+)
       and    p_effective_date between
              nvl(cop.effective_start_date, p_effective_date) and
              nvl(cop.effective_end_date, p_effective_date)
       and    nvl(cop.opt_id, -1) = opt.opt_id (+)
       and    nvl(opt.invk_wv_opt_flag, 'N') = 'N'
       and    p_effective_date between
              nvl(opt.effective_start_date, p_effective_date) and
              nvl(opt.effective_end_date, p_effective_date);
    --
    -- The cursor checks whether the participant is stil covered in the
    -- plan type.
    --
    cursor c_prtt_crntly_enrd is
    select 'Y'
    from   ben_prtt_enrt_rslt_f pen
          ,ben_pl_f             pln
          ,ben_oipl_f           cop
          ,ben_opt_f            opt
          ,ben_pl_regn_f        plrg
          ,ben_regn_f           regn
    where pen.person_id = p_person_id
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.pl_typ_id = l_pl_typ_id
    and pen.sspndd_flag = 'N'
    and pen.enrt_cvg_thru_dt = hr_api.g_eot
    and pen.effective_end_date = hr_api.g_eot
    and p_effective_date between pen.effective_start_date
                             and pen.effective_end_date
    and pen.business_group_id = p_business_group_id
    and pen.pl_id = pln.pl_id
    and pln.invk_dcln_prtn_pl_flag = 'N'
    and p_effective_date between pln.effective_start_date
                             and pln.effective_end_date
    and pln.business_group_id = pen.business_group_id
    and pln.pl_id = plrg.pl_id
    and plrg.regn_id = regn.regn_id
    and regn.sttry_citn_name = 'HIPAA'
    and p_effective_date between plrg.effective_start_date
                             and plrg.effective_end_date
    and  p_effective_date between regn.effective_start_date
                              and regn.effective_end_date
    and pen.oipl_id = cop.oipl_id (+)
    and pen.business_group_id = cop.business_group_id (+)
    and p_effective_date between
        cop.effective_start_date (+)
        and cop.effective_end_date (+)
    and cop.opt_id = opt.opt_id (+)
    and nvl(opt.invk_wv_opt_flag,'N') = 'N'
    and cop.business_group_id = opt.business_group_id (+)
    and p_effective_date between
        opt.effective_start_date (+)
        and opt.effective_end_date (+);
    --
    -- The cursor checks whether the dependent is stil covered in the
    -- plan type.
    --
    cursor c_crntly_enrd is
       select 'Y'
       from   ben_elig_cvrd_dpnt_f pdp,
              ben_prtt_enrt_rslt_f pen,
              ben_pl_f             pln,
              ben_oipl_f           cop,
              ben_opt_f            opt,
	      ben_per_in_ler pil
       where  pdp.cvg_thru_dt      = hr_api.g_eot
       and    pdp.dpnt_person_id   = p_rcpent_person_id
       and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
    -- and    nvl(pen.pgm_id,-1)   = nvl(l_pgm_id,-1)     maagrawa(02/11/00)
       and    pen.pl_typ_id        = l_pl_typ_id
       and    pen.enrt_cvg_thru_dt = hr_api.g_eot
       and    pen.sspndd_flag = 'N'
       and    pen.prtt_enrt_rslt_stat_cd is null
        -- Bug 8271809  To check dependent is coverage is ended for the Current LifeEvent
       and    pdp.per_in_ler_id = pil.per_in_ler_id
       and    pil.per_in_ler_stat_cd NOT IN ( 'VOIDD', 'BCKDT')
       -- Bug 8271809
       and    p_effective_date between
              pdp.effective_start_date and pdp.effective_end_date
       and    p_effective_date between
              pen.effective_start_date and pen.effective_end_date
       and    pen.pl_id = pln.pl_id
       and    pln.invk_dcln_prtn_pl_flag = 'N'
       and    p_effective_date between
              pln.effective_start_date and pln.effective_end_date
       and    pen.oipl_id = cop.oipl_id (+)
       and    p_effective_date between
              nvl(cop.effective_start_date, p_effective_date) and
              nvl(cop.effective_end_date, p_effective_date)
       and    nvl(cop.opt_id, -1) = opt.opt_id (+)
       and    nvl(opt.invk_wv_opt_flag, 'N') = 'N'
       and    p_effective_date between
              nvl(opt.effective_start_date, p_effective_date) and
              nvl(opt.effective_end_date, p_effective_date);
    --


    -- This cursor checks existence of any electable choices for that
    -- plan type with a started per in ler for participant.
    --3585939
    cursor c_prtt_epe(v_pgm_id    in number,
                 v_pl_typ_id in number) is
       select 'Y'
       from   ben_elig_per_elctbl_chc epe,
              ben_per_in_ler          pil,
              ben_pl_f             pln,
              ben_oipl_f           cop,
              ben_opt_f            opt
       where  epe.per_in_ler_id = p_per_in_ler_id
       and    nvl(epe.pgm_id,-1) = nvl(v_pgm_id,-1)
       and    epe.pl_typ_id     = v_pl_typ_id
       and    epe.elctbl_flag   = 'Y'
       and    epe.per_in_ler_id = pil.per_in_ler_id
       and    pil.per_in_ler_stat_cd = 'STRTD'
       and    epe.pl_id = pln.pl_id
       and    pln.invk_dcln_prtn_pl_flag = 'N'
       and    p_effective_date between
              pln.effective_start_date and pln.effective_end_date
       and    epe.oipl_id = cop.oipl_id (+)
       and    p_effective_date between
              nvl(cop.effective_start_date, p_effective_date) and
              nvl(cop.effective_end_date, p_effective_date)
       and    nvl(cop.opt_id, -1) = opt.opt_id (+)
       and    nvl(opt.invk_wv_opt_flag, 'N') = 'N'
       and    p_effective_date between
              nvl(opt.effective_start_date, p_effective_date) and
              nvl(opt.effective_end_date, p_effective_date);

       l_prtt_epe_exists           varchar2(30) := 'N';
    --
    --HIPAA Enh
      cursor c_cm_typ_pl_typ is
      select ctu.pl_typ_id,
             ctu.cm_typ_usg_id,
	     ctu.cm_usg_rl
      from   ben_cm_typ_usg_f ctu
      where  ctu.business_group_id   = p_business_group_id
      and    (p_ler_id is null or
              nvl(ctu.ler_id,p_ler_id) = p_ler_id)
      and    (p_pgm_id is null or
              nvl(ctu.pgm_id,p_pgm_id) = p_pgm_id)
      and    (p_pl_id is null or
              nvl(ctu.pl_id,p_pl_id) = p_pl_id)
      and    (p_asnd_lf_evt_dt is null or
              ctu.enrt_perd_id is null or
              exists (
                select null
                from   ben_enrt_perd enp_c
                where  enp_c.enrt_perd_id=ctu.enrt_perd_id and
                       enp_c.business_group_id=ctu.business_group_id and
                       enp_c.asnd_lf_evt_dt  = p_asnd_lf_evt_dt
                     )
             )
      and    ctu.pl_typ_id is not null
      and    ben_generate_communications.g_comm_start_date
             between ctu.effective_start_date
             and     ctu.effective_end_date
      and    ctu.cm_typ_id = p_cm_typ_id
      and    ctu.pl_typ_id is not null
      and    ctu.all_r_any_cd = 'ALL';
    --HIPAA Enh
    --
    bck_up_pl_typ_id number;
  begin
    --
    -- We need to generate dpnt. HIPAA comm. when a person de-enrolls
    -- from a plan which has HIPAA regulation attached and when the
    -- dependent loses coverage.   The communication
    -- needs to be generated only if he de-enrolls from all plans within
    -- the plan type (within that program).
    -- First we check for all the comp. objects which are getting de-enrolled.
    -- Then we check for whether the dpnt. is currently enrolled in that
    -- plan type. If not, check for any enrollment opportunity available
    -- to enroll in that plan type. If there are no enrollment opportunity,
    -- then generate the neccessary HIPAA comm.
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('p_effective_date '||p_effective_date,20);
    hr_utility.set_location('p_effective_date '||p_per_in_ler_id,20);
    l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
    --
    ben_person_object.get_object(p_person_id => p_rcpent_person_id,
                                 p_rec       => l_per_rec);
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_prtt_per_rec);
    --
    -- If the contact is dead, no comm.
    --
    if l_per_rec.date_of_death is not null then
      --
      p_usages_created := false;
      return;
      --
    end if;
    --
    hr_utility.set_location('Before loop '||l_proc,20);
    --
    if p_source = 'bendsgel' then
      --
      open c_bendsgel_prev_enrt;
      hr_utility.set_location('Loop1 HIPAA ',20);
      --
    else
      --
      open c_prev_enrt;
      hr_utility.set_location('Loop2 HIPAA ',20);
      --
    end if;
    --
    loop
      --
      if p_source = 'bendsgel' then
        --
        fetch c_bendsgel_prev_enrt into l_max_enrt_cvg_thru_dt;
        --
        if c_bendsgel_prev_enrt%notfound then
          --
          close c_bendsgel_prev_enrt;
	  hr_utility.set_location('Loop3 HIPAA ',20);
          exit;
          --
        end if;
        --
      else
        --
        fetch c_prev_enrt into l_pgm_id, l_pl_typ_id, l_max_enrt_cvg_thru_dt;
        --
        if c_prev_enrt%notfound then
          --
          close c_prev_enrt;
	  hr_utility.set_location('Loop4 HIPAA ',20);
          exit;
          --
        end if;
        --
      end if;
      --
      hr_utility.set_location('In loop: '||l_proc,30);
      --
      -- When the participant is de-enrolled from a plan, the dependents
      -- also get de-enrolled. But in this case, we generate comm. for
      -- dpnt. only if they do not reside with the participant.
      -- Also send comm., when the prtt. is dead.
      --
      if l_max_enrt_cvg_thru_dt = hr_api.g_eot or
         p_rsds_with_prtt = 'N' or
         (p_rsds_with_prtt = 'Y'and l_max_enrt_cvg_thru_dt <> hr_api.g_eot) or
         l_prtt_per_rec.date_of_death is not null then
        --
        l_epe_exists  := 'N';
        l_crntly_enrd := 'N';
        l_prtt_crntly_enrd := 'N';
        hr_utility.set_location('p_rsds_with_prtt: '||p_rsds_with_prtt,40);
        --
        open  c_crntly_enrd;
        fetch c_crntly_enrd into l_crntly_enrd;
        close c_crntly_enrd;
        --
	--HIPAA Enh
        if l_crntly_enrd = 'N' then
           bck_up_pl_typ_id := l_pl_typ_id;
       	   for l_cm_typ_pl_typ in c_cm_typ_pl_typ loop
              if rule_passes
              (p_rule_id           => l_cm_typ_pl_typ.cm_usg_rl,
               p_per_cm_id         => p_per_cm_id,
               p_assignment_id     => p_assignment_id,
               p_rcpent_person_id  => p_rcpent_person_id,
               p_business_group_id => p_business_group_id,
               p_ler_id            => p_ler_id,
               p_effective_date    => l_effective_date) then
	          l_pl_typ_id := l_cm_typ_pl_typ.pl_typ_id;
       	          open  c_crntly_enrd;
                  fetch c_crntly_enrd into l_crntly_enrd;
	          close c_crntly_enrd;
	       end if;
	       exit when l_crntly_enrd = 'Y';
	   end loop;
        end if;
	l_pl_typ_id := bck_up_pl_typ_id;
        --HIPAA Enh
        --
        if l_crntly_enrd = 'N' then
          hr_utility.set_location('Not currently enrld: ',40);
          --
          --  If dependent resides with the participant, generate a
          --  communication only if the participant is still enrolled.
          --
          if (p_rsds_with_prtt = 'Y' and
             l_max_enrt_cvg_thru_dt <> hr_api.g_eot and
             l_prtt_per_rec.date_of_death is null) then
            --
            -- Check if the participant is still enrolled.
            --
            hr_utility.set_location('p_person_id: '||p_person_id,40);
            hr_utility.set_location('p_pl_typ_id: '||l_pl_typ_id,40);
            open c_prtt_crntly_enrd;
            fetch c_prtt_crntly_enrd into l_prtt_crntly_enrd;
            close c_prtt_crntly_enrd;

      	    --HIPAA Enh
            if l_prtt_crntly_enrd = 'N' then
               bck_up_pl_typ_id := l_pl_typ_id;
       	       for l_cm_typ_pl_typ in c_cm_typ_pl_typ loop
                  if rule_passes
		     (p_rule_id           => l_cm_typ_pl_typ.cm_usg_rl,
	              p_per_cm_id         => p_per_cm_id,
		      p_assignment_id     => p_assignment_id,
	              p_rcpent_person_id  => p_rcpent_person_id,
		      p_business_group_id => p_business_group_id,
		      p_ler_id            => p_ler_id,
	              p_effective_date    => l_effective_date) then
		         l_pl_typ_id := l_cm_typ_pl_typ.pl_typ_id;
                         open c_prtt_crntly_enrd;
    	                 fetch c_prtt_crntly_enrd into l_prtt_crntly_enrd;
	                 close c_prtt_crntly_enrd;
                  end if;
                  exit when l_prtt_crntly_enrd = 'Y';
	       end loop;
            end if;
	    l_pl_typ_id := bck_up_pl_typ_id;
            --HIPAA Enh
            --
            -- if the prtt is not currently enrolled then validate
            -- whether he has any electablity  3585939
            open  c_prtt_epe(l_pgm_id, l_pl_typ_id);
            fetch c_prtt_epe into l_prtt_epe_exists;
            close c_prtt_epe;

      	    --HIPAA Enh
            if l_prtt_epe_exists = 'N' then
               bck_up_pl_typ_id := l_pl_typ_id;
       	       for l_cm_typ_pl_typ in c_cm_typ_pl_typ loop
                  if rule_passes
		  (p_rule_id           => l_cm_typ_pl_typ.cm_usg_rl,
	           p_per_cm_id         => p_per_cm_id,
		   p_assignment_id     => p_assignment_id,
	           p_rcpent_person_id  => p_rcpent_person_id,
		   p_business_group_id => p_business_group_id,
		   p_ler_id            => p_ler_id,
	           p_effective_date    => l_effective_date) then
	              l_pl_typ_id := l_cm_typ_pl_typ.pl_typ_id;
	              open  c_prtt_epe(l_pgm_id, l_pl_typ_id);
	              fetch c_prtt_epe into l_prtt_epe_exists;
	              close c_prtt_epe;
                 end if;
                 exit when l_prtt_epe_exists = 'Y';
	       end loop;
            end if;
	    l_pl_typ_id := bck_up_pl_typ_id;
            --HIPAA Enh
            --

          end if;
          hr_utility.set_location('l_prtt_crntly_enrd: '||l_prtt_crntly_enrd,40);
          -- 3585939
          if ( (l_prtt_crntly_enrd = 'Y' or  l_prtt_epe_exists = 'Y')
              or
              l_max_enrt_cvg_thru_dt = hr_api.g_eot or
              p_rsds_with_prtt = 'N' or
              l_prtt_per_rec.date_of_death is not null) then
            --
            hr_utility.set_location('No Epe: '||l_proc,40);
            --
            open  c_epe;
            fetch c_epe into l_epe_exists;
            close c_epe;
            --
	    --HIPAA Enh
            if l_epe_exists = 'N' then
               bck_up_pl_typ_id := l_pl_typ_id;
       	       for l_cm_typ_pl_typ in c_cm_typ_pl_typ loop
                  if rule_passes
		  (p_rule_id           => l_cm_typ_pl_typ.cm_usg_rl,
	           p_per_cm_id         => p_per_cm_id,
		   p_assignment_id     => p_assignment_id,
	           p_rcpent_person_id  => p_rcpent_person_id,
		   p_business_group_id => p_business_group_id,
		   p_ler_id            => p_ler_id,
	           p_effective_date    => l_effective_date) then
	              l_pl_typ_id := l_cm_typ_pl_typ.pl_typ_id;
	              open  c_epe;
	              fetch c_epe into l_epe_exists;
	              close c_epe;
		   end if;
                   exit when l_epe_exists = 'Y';
	       end loop;
            end if;
	    l_pl_typ_id := bck_up_pl_typ_id;
            --HIPAA Enh
            --

            if l_epe_exists = 'N' then
              --
              hr_utility.set_location('No result: '||l_proc,50);
              --
              check_hipaa_usages
                (p_per_in_ler_id     => p_per_in_ler_id,
                 p_person_id         => p_rcpent_person_id,
                 p_business_group_id => p_business_group_id,
                 p_assignment_id     => p_assignment_id,
                 p_pgm_id            => l_pgm_id,
                 p_pl_id             => p_pl_id,
                 p_pl_typ_id         => l_pl_typ_id,
                 p_ler_id            => p_ler_id,
                 -- PB : 5422 :
                 p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
                 -- p_enrt_perd_id      => p_enrt_perd_id,
                 p_per_cm_id         => p_per_cm_id,
                 p_cm_typ_id         => p_cm_typ_id,
                 p_effective_date    => p_effective_date,
                 p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
                 p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
                 p_usages_created    => l_created);
              --
              if l_created then
                --
                l_usages_created := true;
                --
              end if;
              --
            end if;
            --
          end if;
          --
        end if;
        --
      end if;
      --
    end loop;
    --
    p_usages_created := l_usages_created;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
  end check_hipaa_ctfn;
  --
  procedure main
    (p_proc_cd           in varchar2,
     p_name              in varchar2,
     p_rcpent_cd         in varchar2,
     p_person_id         in number,
     p_per_in_ler_id     in number,
     p_business_group_id in number,
     p_assignment_id     in number,
     p_prtt_enrt_actn_id in number,
     -- PB : 5422 :
     -- p_enrt_perd_id      in number,
     p_asnd_lf_evt_dt    in date,
     p_enrt_mthd_cd      in varchar2,
     p_actn_typ_id       in number,
     p_per_cm_id         in number,
     p_cm_trgr_id        in number,
     p_pgm_id            in number,
     p_pl_id             in number,
     p_pl_typ_id         in number,
     p_cm_typ_id         in number,
     p_ler_id            in number,
     p_date_cd           in varchar2,
     p_inspn_rqd_flag    in varchar2,
     p_formula_id        in number,
     p_effective_date    in date,
     p_lf_evt_ocrd_dt    in date,
     p_rqstbl_untl_dt    in date,
     p_cm_dlvry_med_cd   in varchar2,
     p_cm_dlvry_mthd_cd  in varchar2,
     p_whnvr_trgrd_flag  in varchar2,
     p_source            in varchar2) is
    --
    l_proc           varchar2(80) := g_package||'main';
    l_usages_created boolean := false;
    l_per_cm_id      number;
    l_con_rec        ben_person_object.g_cache_con_table;
    l_pil_rec        ben_per_in_ler%rowtype;
    --
    -- Bug 6770385
    --
    CURSOR c_get_pil IS
     --
	SELECT   pil.*
	FROM	 ben_per_in_ler pil, ben_ler_f ler
	WHERE	 pil.person_id = p_person_id
	AND      pil.business_group_id = p_business_group_id
	AND	 pil.per_in_ler_stat_cd = 'STRTD'
	AND	 ler.ler_id =  pil.ler_id
	AND	 ler.ler_id = NVL (p_ler_id, pil.ler_id)
	AND      ler.typ_cd not in ('COMP', 'GSP', 'ABS')
        AND	 p_effective_date BETWEEN
			ler.effective_start_date AND ler.effective_end_date
	ORDER BY DECODE(ler.typ_cd,'SCHEDDU',1,2) desc ;
    --
    l_get_pil c_get_pil%ROWTYPE;
    --
-- Bug 6770385
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    -- hr_utility.set_location('In Parameters',10);
    -- hr_utility.set_location('-------------',10);
    -- hr_utility.set_location('p_proc_cd ='||p_proc_cd,10);
    -- hr_utility.set_location('p_rcpent_cd ='||p_rcpent_cd,10);
    -- hr_utility.set_location('p_person_id ='||p_person_id,10);
    -- hr_utility.set_location('p_per_in_ler_id ='||p_per_in_ler_id,10);
    -- hr_utility.set_location('p_business_group_id ='||p_business_group_id,10);
    -- hr_utility.set_location('p_assignment_id ='||p_assignment_id,10);
    -- hr_utility.set_location('p_prtt_enrt_actn_id ='||p_prtt_enrt_actn_id,10);
    -- hr_utility.set_location('p_enrt_perd_id ='||p_enrt_perd_id,10);
    -- hr_utility.set_location('p_enrt_mthd_cd ='||p_enrt_mthd_cd,10);
    -- hr_utility.set_location('p_actn_typ_id ='||p_actn_typ_id,10);
    -- hr_utility.set_location('p_per_cm_id ='||p_per_cm_id,10);
    -- hr_utility.set_location('p_cm_trgr_id ='||p_cm_trgr_id,10);
    -- hr_utility.set_location('p_pgm_id ='||p_pgm_id,10);
    -- hr_utility.set_location('p_pl_id ='||p_pl_id,10);
    -- hr_utility.set_location('p_cm_typ_id ='||p_cm_typ_id,10);
    -- hr_utility.set_location('p_ler_id ='||p_ler_id,10);
    -- hr_utility.set_location('p_date_cd ='||p_date_cd,10);
    -- hr_utility.set_location('p_inspn_rqd_flag ='||p_inspn_rqd_flag,10);
    -- hr_utility.set_location('p_formula_id ='||p_formula_id,10);
    -- hr_utility.set_location('p_effective_date ='||p_effective_date,10);
    -- hr_utility.set_location('p_lf_evt_ocrd_dt ='||p_lf_evt_ocrd_dt,10);
    -- hr_utility.set_location('p_cm_dlvry_med_cd ='||p_cm_dlvry_med_cd,10);
    -- hr_utility.set_location('p_cm_dlvry_mthd_cd ='||p_cm_dlvry_mthd_cd,10);
    -- hr_utility.set_location('p_whnvr_trgrd_flag ='||p_whnvr_trgrd_flag,10);
    -- Steps.
    -- 1) Populate the working tables that are required.
    -- 2) Loop through all contacts that are relevant
    -- 3) Test against desired procedure
    -- 4) If no usage is created then rollback the row.
    --
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_con_rec);
    --
    -- CWB Changes. -- 9999 it is better we get the per in ler based on ler_id
    --
    if p_per_in_ler_id is null then
    -- if p_ler_id is not null then
      --
  /*    ben_person_object.get_object(p_person_id => p_person_id,
                                   p_rec       => l_pil_rec); */
      --
 -- Bug 6770385
      open c_get_pil;
        fetch c_get_pil into l_get_pil;
      close c_get_pil;
 -- Bug 6770385
    end if;
    --
    if l_con_rec.exists(1) then
      --
      for l_count in l_con_rec.first..l_con_rec.last loop
        --
        -- If the rcpent_cd = 'RLTD_PER' then only deal with contacts who
        -- have the personal flag set, otherwise move onto the next
        -- person.
        --
        if (p_rcpent_cd = 'RLTD_PER' and
            l_con_rec(l_count).personal_flag = 'Y') or
           (p_rcpent_cd <> 'RLTD_PER')              or
           (p_proc_cd = 'HPADPNTLC')                then
          --
          savepoint dependent_records;
          --
          ben_generate_communications.pop_ben_per_cm_f
            (p_person_id            => l_con_rec(l_count).contact_person_id,
             p_ler_id               => p_ler_id,
             -- CWB Changes
--             p_per_in_ler_id        => nvl(p_per_in_ler_id, l_pil_rec.per_in_ler_id),
             p_per_in_ler_id        => nvl(p_per_in_ler_id, l_get_pil.per_in_ler_id),
             p_prtt_enrt_actn_id    => p_prtt_enrt_actn_id,
             p_bnf_person_id        => null,
             p_dpnt_person_id       => null,
             p_cm_typ_id            => p_cm_typ_id,
             p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt,
             p_rqstbl_untl_dt       => p_rqstbl_untl_dt,
             p_business_group_id    => p_business_group_id,
             p_effective_date       => p_effective_date,
             p_date_cd              => p_date_cd,
             p_formula_id           => p_formula_id,
             p_pgm_id               => p_pgm_id,
             p_pl_id                => p_pl_id,
             p_per_cm_id            => l_per_cm_id);
          --
          if p_proc_cd = 'MLEELIG' then
            --
            check_first_time_elig_inelig
              (p_person_id         => p_person_id,
               p_per_in_ler_id     => p_per_in_ler_id,
               p_rcpent_person_id  => l_con_rec(l_count).contact_person_id,
               p_rcpent_cd         => p_rcpent_cd,
               p_business_group_id => p_business_group_id,
               p_assignment_id     => p_assignment_id,
               -- PB : 5422 :
               p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
               -- p_enrt_perd_id      => p_enrt_perd_id,
               p_actn_typ_id       => p_actn_typ_id,
               p_per_cm_id         => l_per_cm_id,
               p_cm_typ_id         => p_cm_typ_id,
               p_ler_id            => p_ler_id,
               p_effective_date    => p_effective_date,
               p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
               p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
               p_eligible_flag     => 'Y',
               p_usages_created    => l_usages_created);
            --
          elsif p_proc_cd = 'MLEINELIG' then
            --
            check_first_time_elig_inelig
              (p_person_id         => p_person_id,
               p_per_in_ler_id     => p_per_in_ler_id,
               p_rcpent_person_id  => l_con_rec(l_count).contact_person_id,
               p_rcpent_cd         => p_rcpent_cd,
               p_business_group_id => p_business_group_id,
               p_assignment_id     => p_assignment_id,
               -- PB : 5422 :
               p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
               -- p_enrt_perd_id      => p_enrt_perd_id,
               p_actn_typ_id       => p_actn_typ_id,
               p_per_cm_id         => l_per_cm_id,
               p_cm_typ_id         => p_cm_typ_id,
               p_ler_id            => p_ler_id,
               p_effective_date    => p_effective_date,
               p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
               p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
               p_eligible_flag     => 'N',
               p_usages_created    => l_usages_created);
            --
          elsif p_proc_cd = 'MLEAUTOENRT' then
            --
            check_automatic_enrollment
              (p_rcpent_cd         => p_rcpent_cd,
               p_usages_created    => l_usages_created);
            --
          elsif p_proc_cd = 'MLENOIMP' then
            --
            check_no_impact_on_benefits
              (p_rcpent_cd         => p_rcpent_cd,
               p_usages_created    => l_usages_created);
            --
          elsif p_proc_cd = 'MLEPECP' then
            --
            check_electable_choice_popl
              (p_per_in_ler_id     => p_per_in_ler_id,
               p_rcpent_person_id  => l_con_rec(l_count).contact_person_id,
               p_rcpent_cd         => p_rcpent_cd,
               p_business_group_id => p_business_group_id,
               p_assignment_id     => p_assignment_id,
               -- PB : 5422 :
               p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
               -- p_enrt_perd_id      => p_enrt_perd_id,
               p_pgm_id            => p_pgm_id,
               p_pl_id             => p_pl_id,
               p_pl_typ_id         => p_pl_typ_id,
               p_actn_typ_id       => p_actn_typ_id,
               p_ler_id            => p_ler_id,
               p_per_cm_id         => l_per_cm_id,
               p_cm_typ_id         => p_cm_typ_id,
               p_effective_date    => p_effective_date,
               p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
               p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
               p_usages_created    => l_usages_created);
            --
          elsif p_proc_cd = 'MLEENDENRT' then
            --
            check_inelig_deenroll
              (p_per_in_ler_id     => p_per_in_ler_id,
               p_rcpent_person_id  => l_con_rec(l_count).contact_person_id,
               p_rcpent_cd         => p_rcpent_cd,
               p_business_group_id => p_business_group_id,
               p_assignment_id     => p_assignment_id,
               -- PB : 5422 :
               p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
               -- p_enrt_perd_id      => p_enrt_perd_id,
               p_ler_id            => p_ler_id,
               p_actn_typ_id       => p_actn_typ_id,
               p_per_cm_id         => l_per_cm_id,
               p_cm_typ_id         => p_cm_typ_id,
               p_effective_date    => p_effective_date,
               p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
               p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
               p_usages_created    => l_usages_created);
            --
          elsif p_proc_cd = 'MLERTCHG' then
            --
            check_inelig_deenroll
              (p_per_in_ler_id     => p_per_in_ler_id,
               p_rcpent_person_id  => l_con_rec(l_count).contact_person_id,
               p_rcpent_cd         => p_rcpent_cd,
               p_business_group_id => p_business_group_id,
               p_assignment_id     => p_assignment_id,
               -- PB : 5422 :
               p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
               -- p_enrt_perd_id      => p_enrt_perd_id,
               p_ler_id            => p_ler_id,
               p_actn_typ_id       => p_actn_typ_id,
               p_per_cm_id         => l_per_cm_id,
               p_cm_typ_id         => p_cm_typ_id,
               p_effective_date    => p_effective_date,
               p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
               p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
               p_usages_created    => l_usages_created);
            --
          elsif p_proc_cd in ('FORMENRT','WEBENRT','IVRENRT') then
            --
            check_expl_dflt_enrollment
              (p_per_in_ler_id     => p_per_in_ler_id,
               p_rcpent_person_id  => l_con_rec(l_count).contact_person_id,
               p_rcpent_cd         => p_rcpent_cd,
               p_business_group_id => p_business_group_id,
               p_assignment_id     => p_assignment_id,
               -- PB : 5422 :
               p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
               -- p_enrt_perd_id      => p_enrt_perd_id,
               p_ler_id            => p_ler_id,
               p_per_cm_id         => l_per_cm_id,
               p_cm_typ_id         => p_cm_typ_id,
               p_enrt_mthd_cd      => p_enrt_mthd_cd,
               p_effective_date    => p_effective_date,
               p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
               p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
               p_usages_created    => l_usages_created);
            --
          elsif p_proc_cd = 'CLSENRT' then
            --
            check_close_enrollment
              (p_per_in_ler_id     => p_per_in_ler_id,
               p_rcpent_person_id  => l_con_rec(l_count).contact_person_id,
               p_rcpent_cd         => p_rcpent_cd,
               p_business_group_id => p_business_group_id,
               p_assignment_id     => p_assignment_id,
               p_ler_id            => p_ler_id,
               p_per_cm_id         => l_per_cm_id,
               p_cm_typ_id         => p_cm_typ_id,
               p_effective_date    => p_effective_date,
               p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
               p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
               p_usages_created    => l_usages_created);
            --
          elsif p_proc_cd in ('ACTNCMPL', 'ACTNCREATED', 'MSSMLGAR') then
            --
            check_actn_item
              (p_per_in_ler_id     => p_per_in_ler_id,
               p_rcpent_person_id  => l_con_rec(l_count).contact_person_id,
               p_rcpent_cd         => p_rcpent_cd,
               p_business_group_id => p_business_group_id,
               p_assignment_id     => p_assignment_id,
               p_actn_typ_id       => p_actn_typ_id,
               p_pgm_id            => p_pgm_id,
               p_pl_id             => p_pl_id,
               p_pl_typ_id         => p_pl_typ_id,
               p_ler_id            => p_ler_id,
               p_per_cm_id         => l_per_cm_id,
               p_cm_typ_id         => p_cm_typ_id,
               p_effective_date    => p_effective_date,
               p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
               p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
               p_usages_created    => l_usages_created);
            --
          elsif p_proc_cd = 'MSSMLG' then
            --
            check_mass_mail
              (p_per_in_ler_id     => p_per_in_ler_id,
               p_rcpent_person_id  => l_con_rec(l_count).contact_person_id,
               p_rcpent_cd         => p_rcpent_cd,
               p_business_group_id => p_business_group_id,
               p_assignment_id     => p_assignment_id,
               p_pgm_id            => p_pgm_id,
               p_pl_id             => p_pl_id,
               p_pl_typ_id         => p_pl_typ_id,
               p_ler_id            => p_ler_id,
               p_per_cm_id         => l_per_cm_id,
               p_cm_typ_id         => p_cm_typ_id,
               p_effective_date    => p_effective_date,
               p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
               p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
               p_usages_created    => l_usages_created);
            --
          elsif p_proc_cd = 'DPNTENDENRT' then
            --
            check_dpnt_end_enrt
              (p_per_in_ler_id     => p_per_in_ler_id,
               p_rcpent_person_id  => l_con_rec(l_count).contact_person_id,
               p_rcpent_cd         => p_rcpent_cd,
               p_business_group_id => p_business_group_id,
               p_assignment_id     => p_assignment_id,
               p_pgm_id            => p_pgm_id,
               p_pl_id             => p_pl_id,
               p_pl_typ_id         => p_pl_typ_id,
               p_ler_id            => p_ler_id,
               p_per_cm_id         => l_per_cm_id,
               p_cm_typ_id         => p_cm_typ_id,
               p_effective_date    => p_effective_date,
               p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
               p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
               p_usages_created    => l_usages_created);
            --
          elsif p_proc_cd = 'MSSMLGER' then
            --
            check_enrt_rmdr
              (p_per_in_ler_id     => p_per_in_ler_id,
               p_rcpent_person_id  => l_con_rec(l_count).contact_person_id,
               p_rcpent_cd         => p_rcpent_cd,
               p_business_group_id => p_business_group_id,
               p_assignment_id     => p_assignment_id,
               -- PB : 5422 :
               p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
               -- p_enrt_perd_id      => p_enrt_perd_id,
               p_ler_id            => p_ler_id,
               p_pl_id             => p_pl_id,
               p_pl_typ_id         => p_pl_typ_id,
               p_pgm_id            => p_pgm_id,
               p_per_cm_id         => l_per_cm_id,
               p_cm_typ_id         => p_cm_typ_id,
               p_enrt_mthd_cd      => p_enrt_mthd_cd,
               p_effective_date    => p_effective_date,
               p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
               p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
               p_usages_created    => l_usages_created);
            --
          elsif p_proc_cd = 'MSSMLGEE' then
            --
            check_emrg_evt
              (p_per_in_ler_id     => p_per_in_ler_id,
               p_rcpent_person_id  => l_con_rec(l_count).contact_person_id,
               p_rcpent_cd         => p_rcpent_cd,
               p_business_group_id => p_business_group_id,
               p_assignment_id     => p_assignment_id,
               p_pgm_id            => p_pgm_id,
               p_pl_id             => p_pl_id,
               p_pl_typ_id         => p_pl_typ_id,
               -- PB : 5422 :
               p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
               -- p_enrt_perd_id      => p_enrt_perd_id,
               p_ler_id            => p_ler_id,
               p_per_cm_id         => l_per_cm_id,
               p_cm_typ_id         => p_cm_typ_id,
               p_enrt_mthd_cd      => p_enrt_mthd_cd,
               p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
               p_effective_date    => p_effective_date,
               p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
               p_usages_created    => l_usages_created);
            --
          elsif p_proc_cd = 'HPADPNTLC' then
            --
            check_hipaa_ctfn
              (p_per_in_ler_id     => p_per_in_ler_id,
               p_person_id         => p_person_id,
               p_rcpent_person_id  => l_con_rec(l_count).contact_person_id,
               p_business_group_id => p_business_group_id,
               p_assignment_id     => p_assignment_id,
               p_pgm_id            => p_pgm_id,
               p_pl_id             => p_pl_id,
               p_pl_typ_id         => p_pl_typ_id,
               -- PB : 5422 :
               p_asnd_lf_evt_dt    => p_asnd_lf_evt_dt,
               -- p_enrt_perd_id      => p_enrt_perd_id,
               p_ler_id            => p_ler_id,
               p_per_cm_id         => l_per_cm_id,
               p_cm_typ_id         => p_cm_typ_id,
               p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt,
               p_effective_date    => p_effective_date,
               p_whnvr_trgrd_flag  => p_whnvr_trgrd_flag,
               p_usages_created    => l_usages_created,
               p_rsds_with_prtt    => l_con_rec(l_count).rltd_per_rsds_w_dsgntr_flag,
               p_source            => p_source);
            --
          else
            --
            fnd_message.set_name('BEN','BEN_91342_UNKNOWN_CODE_1');
            fnd_message.set_token('PROC',l_proc);
            fnd_message.set_token('CODE1',p_proc_cd);
            raise ben_manage_life_events.g_record_error;
            --
          end if;
          --
          if not l_usages_created then
            --
            hr_utility.set_location('Rolling back transaction',10);
            rollback to dependent_records;
            --
          else
            --
            ben_generate_communications.populate_working_tables
              (p_person_id         => l_con_rec(l_count).contact_person_id,
               p_cm_typ_id         => p_cm_typ_id,
               p_business_group_id => p_business_group_id,
               p_effective_date    => p_effective_date,
               p_cm_trgr_id        => p_cm_trgr_id,
               p_inspn_rqd_flag    => p_inspn_rqd_flag,
               p_cm_dlvry_med_cd   => p_cm_dlvry_med_cd,
               p_cm_dlvry_mthd_cd  => p_cm_dlvry_mthd_cd,
               p_per_cm_id         => l_per_cm_id);
            --
            fnd_message.set_name('BEN','BEN_92090_CREATED_DPNT_COMM');
            fnd_message.set_token('COMMUNICATION',p_name);
            if fnd_global.conc_request_id <> -1 then
              benutils.write(fnd_message.get);
              benutils.write(ben_generate_communications.g_commu_rec);
              ben_generate_communications.g_comm_generated := true;
            end if;
            --
            hr_utility.set_location('Creating Communication for Dependent',10);
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
  end main;
  --
end ben_generate_dpnt_comm;
--

/
