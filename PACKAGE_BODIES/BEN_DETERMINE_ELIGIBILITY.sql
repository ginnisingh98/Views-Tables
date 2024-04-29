--------------------------------------------------------
--  DDL for Package Body BEN_DETERMINE_ELIGIBILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DETERMINE_ELIGIBILITY" as
/* $Header: bendetel.pkb 120.5.12010000.3 2008/11/13 18:13:07 krupani ship $ */
--
-- -----------------------------------------------------------------------------
-- |-----------------------< determine_elig_prfls >----------------------------|
-- -----------------------------------------------------------------------------
--
-- This procedure is the main calling procedure.
-- It also determines all profiles or rules associated
-- with the comp object that is being passed through.
--
procedure determine_elig_prfls
  (p_comp_obj_tree_row         in out NOCOPY ben_manage_life_events.g_cache_proc_objects_rec
  ,p_par_elig_state            in out NOCOPY ben_comp_obj_filter.g_par_elig_state_rec
  ,p_per_row                   in out NOCOPY per_all_people_f%rowtype
  ,p_empasg_row                in out NOCOPY per_all_assignments_f%rowtype
  ,p_benasg_row                in out NOCOPY per_all_assignments_f%rowtype
  ,p_appasg_row                in out NOCOPY ben_person_object.g_cache_ass_table
  ,p_empasgast_row             in out NOCOPY per_assignment_status_types%rowtype
  ,p_benasgast_row             in out NOCOPY per_assignment_status_types%rowtype
  ,p_pil_row                   in out NOCOPY ben_per_in_ler%rowtype
  ,p_person_id                 in number
  ,p_business_group_id         in number
  ,p_effective_date            in date
  ,p_lf_evt_ocrd_dt            in date
  ,p_pl_id                     in number
  ,p_pgm_id                    in number
  ,p_oipl_id                   in number
  ,p_plip_id                   in number
  ,p_ptip_id                   in number
  ,p_ler_id                    in number
  ,p_comp_rec                  in out NOCOPY ben_derive_part_and_rate_facts.g_cache_structure
  ,p_oiplip_rec                in out NOCOPY ben_derive_part_and_rate_facts.g_cache_structure
  --
  ,p_eligible                     out nocopy boolean
  ,p_not_eligible                 out nocopy boolean
  --
  ,p_newly_elig                   out nocopy boolean
  ,p_newly_inelig                 out nocopy boolean
  ,p_first_elig                   out nocopy boolean
  ,p_first_inelig                 out nocopy boolean
  ,p_still_elig                   out nocopy boolean
  ,p_still_inelig                 out nocopy boolean
  )
is
  --
  l_proc                  varchar2(100):= 'ben_determine_eligibility.determine_elig_prfls';
  --
  l_eligprof_dets         ben_cep_cache.g_cobcep_odcache;
  l_tmpelp_dets           ben_cep_cache.g_cobcep_odcache := ben_cep_cache.g_cobcep_odcache();
/*
  l_eligprof_dets         ben_elp_cache.g_cobcep_cache;
  l_tmpelp_dets           ben_elp_cache.g_cobcep_cache;
*/
  --
  l_elptorrw_num          binary_integer;
  l_inst_count            number;
  l_elig_flag             boolean := false;
  l_elig_per_id           number;
  l_prtn_ovridn_thru_dt   date;
  l_effective_date        date;
  l_prtn_ovridn_flag      ben_elig_per_f.prtn_ovridn_flag%type;
  l_rl_count              number;
  l_match_one             boolean := false;
  l_match_one_rl          varchar2(15) := 'FALSE';
  l_outputs               ff_exec.outputs_t;
  l_ok_so_far             varchar2(1) := 'Y';
  l_mx_wtg_perd_prte_elig boolean := false;
  l_elig_apls_flag        varchar2(30);
  l_dpnt_elig_flag        varchar2(1) := 'Y';
  l_dependent_elig_flag   varchar2(1) := 'Y';
  l_dpnt_inelig_rsn_cd    ben_elig_dpnt.inelg_rsn_cd%type;
  l_per_in_ler_id         ben_per_in_ler.per_in_ler_id%type;
  l_per_cvrd_cd           ben_pl_f.per_cvrd_cd%type;
  l_elig_inelig_cd        ben_elig_to_prte_rsn_f.elig_inelig_cd%type;
  l_dpnt_pl_id            ben_pl_f.pl_id%type;
  l_exists                varchar2(30);
  --
  l_terminated    per_assignment_status_types.per_system_status%type;
  l_assignment_id per_all_assignments_f.assignment_id%type;
  l_found_profile varchar2(1) := 'N';
  l_pgm_rec       ben_cobj_cache.g_pgm_inst_row;
  l_pl_rec        ben_cobj_cache.g_pl_inst_row;
  l_pl2_rec       ben_pl_f%rowtype;
  l_pl3_rec       ben_pl_f%rowtype;
  l_ptip2_rec	  ben_ptip_f%rowtype;
  l_oipl_rec      ben_cobj_cache.g_oipl_inst_row;
  l_plip_rec      ben_cobj_cache.g_plip_inst_row;
  l_ptip_rec      ben_cobj_cache.g_ptip_inst_row;
  l_elig_to_prte_rsn_row ben_cobj_cache.g_etpr_inst_row;
  --
  -- Task 130 : Variables used for extracting vrfy_fmly_mmbr_cd
  -- Need to look at the heirarchy.
  --
  l_par_pgm_rec          ben_cobj_cache.g_pgm_inst_row;
  l_par_ptip_rec         ben_cobj_cache.g_ptip_inst_row;
  l_par_plip_rec         ben_cobj_cache.g_plip_inst_row;
  l_par_pl_rec           ben_cobj_cache.g_pl_inst_row;
  l_par_pgm_elig_rec     ben_cobj_cache.g_etpr_inst_row;
  l_par_ptip_elig_rec    ben_cobj_cache.g_etpr_inst_row;
  l_par_plip_elig_rec    ben_cobj_cache.g_etpr_inst_row;
  l_par_pl_elig_rec      ben_cobj_cache.g_etpr_inst_row;
  --
  l_inst_set      ben_elig_rl_cache.g_elig_rl_inst_tbl;
  l_elig_rl_cnt   number := 0;
  l_ctr_count     number := 0;
  l_jurisdiction_code     varchar2(30);
  --
  l_per_rec       per_all_people_f%rowtype;
  l_ass_rec       per_all_assignments_f%rowtype;
  l_loc_rec       hr_locations_all%rowtype;
  l_ctr_rec       per_contact_relationships%rowtype;
  l_hsc_rec       hr_soft_coding_keyflex%rowtype;
  l_org_rec       hr_all_organization_units%rowtype;
  l_loop_count    number;
  --
  l_elig_for_pgm_flag  varchar(30);
  l_elig_for_ptip_flag varchar(30);
  l_elig_for_plip_flag varchar(30);
  l_elig_for_pl_flag   varchar(30);
  l_cagrelig_cnt       pls_integer;
  --
  --FONM
  l_fonm_cvg_strt_dt DATE ;
  --END FONM
  cursor c_get_contacts is
    select ctr.*
    from   per_contact_relationships ctr,
           per_all_people_f ppf
    where  ctr.person_id = p_person_id
    and    ctr.personal_flag = 'Y'
    and    ctr.contact_person_id = ppf.person_id
    and    nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date))
           between ppf.effective_start_date
           and     ppf.effective_end_date
    and    nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date))
           between nvl(ctr.date_start,hr_api.g_sot)
           and     nvl(ctr.date_end,hr_api.g_eot)
    and    ctr.business_group_id = p_business_group_id;
  --
  cursor c_get_no_of_contacts is
    select count(ctr.person_id)
    from   per_contact_relationships ctr,
           per_all_people_f ppf
    where  ctr.person_id = p_person_id
    and    ctr.personal_flag = 'Y'
    and    ctr.contact_person_id = ppf.person_id
    and    nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date))
           between ppf.effective_start_date
           and     ppf.effective_end_date
    and    nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date))
           between nvl(ctr.date_start,hr_api.g_sot)
           and     nvl(ctr.date_end,hr_api.g_eot)
    and    ctr.business_group_id = p_business_group_id;


  -- bug # 2424041 begins
  cursor c_ptip_pl_typ(c_effective_date date) is
     select  pl_typ_id
     from    ben_ptip_f
     where   ptip_id = p_ptip_id
     and     c_effective_date
     between effective_start_date
     and     effective_end_date;
  --
  cursor c_plip_pl_typ(c_effective_date date) is
     select  pln.pl_typ_id
     from    ben_plip_f plip,
             ben_pl_f pln
     where   plip_id = p_plip_id
     and     c_effective_date
     between plip.effective_start_date and plip.effective_end_date
     and     pln.pl_id = plip.pl_id
     and     c_effective_date
     between pln.effective_start_date and pln.effective_end_date ;
  --
  cursor c_oipl_pl_typ(c_effective_date date) is
     select  pln.pl_typ_id
     from    ben_oipl_f oipl,
             ben_pl_f pln
     where   oipl_id = p_oipl_id
     and     c_effective_date
     between oipl.effective_start_date and oipl.effective_end_date
     and     pln.pl_id = oipl.pl_id
     and     c_effective_date
     between pln.effective_start_date and pln.effective_end_date ;
  --
  l_pl_typ_id	number;
  --
  -- bug 2424041 ends
  --
  l_typ_rec    ben_person_object.g_cache_typ_table;
  l_ast_rec    per_assignment_status_types%rowtype;
  l_appass_rec ben_person_object.g_cache_ass_table;
  --
  cursor c_ff_use_asg(cv_formula_id in number) is
     select 'Y'
     from ff_fdi_usages_f
     where FORMULA_ID = cv_formula_id
       and ITEM_NAME  = 'ASSIGNMENT_ID'
       and usage      = 'U';
  --
  l_ff_use_asg_id_flag varchar2(1);
  l_vrfy_fmly_mmbr_cd  varchar2(30);
  l_vrfy_fmly_mmbr_rl  number;
  l_pl_id              number;
  --
  -- l_env                ben_env_object.g_global_env_rec_type;
  l_env_rec              ben_env_object.g_global_env_rec_type;
  l_benmngle_parm_rec    benutils.g_batch_param_rec;
  --
  l_score_tab            ben_evaluate_elig_profiles.scoreTab;
  l_ctp_rec     ben_ptip_f%rowtype;
  l_pln_rec     ben_pl_f%rowtype;
begin
  --
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
    hr_utility.set_location('Entering :'||l_proc,10);
  end if;
  --
  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     --
  end if;
  --
  l_per_rec := p_per_row;
  --
  -- Set assignment information rows
  --
  -- Assumption for IREC is that only app assg row would be passed and we would pick
  -- up the right assignment
  if p_empasg_row.assignment_id is null then
    --
    l_ass_rec := p_benasg_row;
    --
    -- If benefit assignment not found, get applicant assignment.
    --
    if l_ass_rec.assignment_id is null then
      --
      l_appass_rec := p_appasg_row;
      --
    else
      --
      l_ast_rec := p_benasgast_row;
      --
    end if;
    --
  else
    --
    -- Bug : 1735996 : Assignment row is properly set.
    --                 Added the line below.
    --
    l_ass_rec := p_empasg_row;
    l_ast_rec := p_empasgast_row;
    --
  end if;
  --
  l_terminated    := l_ast_rec.per_system_status;
  l_assignment_id := l_ass_rec.assignment_id;
  --
  -- Get the environment record.
  --
  l_effective_date := nvl(p_lf_evt_ocrd_dt,p_effective_date);
  -- Set up cache structures depending on comp object passed in
  --
  if p_pgm_id is not null then
    --
    if g_debug then
      hr_utility.set_location('PGM_ID '||p_pgm_id,12);
    end if;
    --
    l_pgm_rec := ben_cobj_cache.g_pgm_currow;
    --
  elsif p_pl_id is not null then
    --
    if g_debug then
      hr_utility.set_location('PL_ID '||p_pl_id,14);
    end if;
    --
    l_pl_rec := ben_cobj_cache.g_pl_currow;
    --
  elsif p_oipl_id is not null then
    --
    if g_debug then
      hr_utility.set_location('OIPL_ID '||p_oipl_id,16);
    end if;
    --
    l_oipl_rec := ben_cobj_cache.g_oipl_currow;
    --
  elsif p_plip_id is not null then
    --
    if g_debug then
      hr_utility.set_location('PLIP_ID '||p_plip_id,18);
    end if;
    --
    l_plip_rec := ben_cobj_cache.g_plip_currow;
    --
  elsif p_ptip_id is not null then
    --
    if g_debug then
      hr_utility.set_location('PTIP_ID '||p_ptip_id,20);
    end if;
    --
    l_ptip_rec := ben_cobj_cache.g_ptip_currow;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location('l_pl_typ_id     : '|| l_pl_typ_id ,16871);
  end if;
  --
  -- Check parent eligibility
  --
  if g_debug then
    hr_utility.set_location(l_proc||' Parent elig ',10);
  end if;
  --
  if p_ptip_id is not null
    and p_par_elig_state.elig_for_pgm_flag = 'N'
  then
    --
    -- Person is not eligible for the program
    -- therefore person is not eligible for
    -- plan in program
    --
    -- The pl, ptip and plip eligibilty sets the elig_for_pl_flag
    --
    ben_manage_life_events.g_output_string :=
      ben_manage_life_events.g_output_string||
      'Elg: No '||
      'Rsn: Inelig Parent Pgm';
    --
    fnd_message.set_name('BEN','BEN_92219_INELIG_PGM');
    raise g_not_eligible;
    --
  elsif p_plip_id is not null
    and p_par_elig_state.elig_for_ptip_flag = 'N'
  then
    --
    -- Person is not eligible for the program
    -- therefore person is not eligible for
    -- plan in program
    --
    -- The pl, ptip and plip eligibilty sets the elig_for_pl_flag
    --
    ben_manage_life_events.g_output_string :=
      ben_manage_life_events.g_output_string||
      'Elg: No '||
      'Rsn: Inelig Parent Pgm';
    --
    fnd_message.set_name('BEN','BEN_92219_INELIG_PGM');
    raise g_not_eligible;
    --
  elsif p_pl_id is not null
    and p_par_elig_state.elig_for_plip_flag = 'N'
  then
    --
    -- Person is not eligible for the program
    -- therefore person is not eligible for
    -- plan in program
    --
    -- The pl, ptip and plip eligibilty sets the elig_for_pl_flag
    --
    ben_manage_life_events.g_output_string :=
      ben_manage_life_events.g_output_string||
      'Elg: No '||
      'Rsn: Inelig Parent Pgm';
    --
    fnd_message.set_name('BEN','BEN_92219_INELIG_PGM');
    raise g_not_eligible;
    --
  elsif p_oipl_id is not null
    and p_par_elig_state.elig_for_pl_flag = 'N'
  then
    --
    -- Person is not eligible for the plan
    -- therefore person not eligible for the
    -- option in plan
    --
    ben_manage_life_events.g_output_string :=
      ben_manage_life_events.g_output_string||
      'Elg: No '||
      'Rsn: Inelig Pln';
    --
    fnd_message.set_name('BEN','BEN_92221_INELIG_PLN');
    raise g_not_eligible;
    --
  end if;
  --
  -- Check if its worth doing the profile checking at all, this only occurs
  -- if the participation override allowed flag is on for the comp object and
  -- the elig per participation override flag is on and the effective date is
  -- less than (or equal to) the participation override thru date
  --
  if g_debug then
    hr_utility.set_location(l_proc||' Part Ovr ',10);
  end if;
  --
  if p_pgm_id is not null then
    --
    l_elig_apls_flag := l_pgm_rec.elig_apls_flag;
    --
    l_elig_to_prte_rsn_row := ben_cobj_cache.g_pgmetpr_currow;
    --
    l_elig_inelig_cd := l_elig_to_prte_rsn_row.elig_inelig_cd;
    --
    --if the participantion override flag is on then participation override thru date
    --should see the life event occurred date not the effective date

    --bug 7264617: changed condition to >= in order to include lf_evt_ocrd_dt in ovridn_thru_dt
    if l_pgm_rec.prtn_elig_ovrid_alwd_flag = 'Y' and
       p_comp_rec.prtn_ovridn_flag = 'Y' and
       nvl(p_comp_rec.prtn_ovridn_thru_dt,hr_api.g_eot) >= nvl(l_fonm_cvg_strt_dt,
                                                          nvl(p_lf_evt_ocrd_dt,p_effective_date)) and
       (nvl(l_elig_to_prte_rsn_row.ignr_prtn_ovrid_flag,'N') = 'N' or
        p_ler_id is null) then
      --
      -- Make person what they were before
      -- e.g. eligible stays eligible, ineligible stays ineligible.
      --
      if p_comp_rec.elig_flag = 'Y' then
        --
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string ||
          'Elg: Yes '||
          'Rsn: Prtn Ovrid';
        raise g_eligible;
        --
      elsif p_comp_rec.elig_flag = 'N' then
        --
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string ||
          'Elg: No  '||
          'Rsn: Prtn Ovrid';
        --
        fnd_message.set_name('BEN','BEN_92223_PRTN_OVERRIDE');
        raise g_not_eligible;
        --
      end if;
      --
    end if;
    --
  elsif p_pl_id is not null then
    --
    l_elig_apls_flag := l_pl_rec.elig_apls_flag;
    --
    l_elig_to_prte_rsn_row := ben_cobj_cache.g_pletpr_currow;
    --
    l_elig_inelig_cd := l_elig_to_prte_rsn_row.elig_inelig_cd;
    --
    --if the participantion override flag is on then participation override thru date
    --should see the life event occurred date not the effective date
    --
    --bug 7264617: changed condition to >= in order to include lf_evt_ocrd_dt in ovridn_thru_dt
    if l_pl_rec.prtn_elig_ovrid_alwd_flag = 'Y' and
       p_comp_rec.prtn_ovridn_flag = 'Y' and
       nvl(p_comp_rec.prtn_ovridn_thru_dt,hr_api.g_eot) >= nvl(l_fonm_cvg_strt_dt,
                                                          nvl(p_lf_evt_ocrd_dt,p_effective_date)) and
       (nvl(l_elig_to_prte_rsn_row.ignr_prtn_ovrid_flag,'N') = 'N' or
        p_ler_id is null) then
      --
      -- Make person what they were before
      -- e.g. eligible stays eligible, ineligible stays ineligible.
      --
      if p_comp_rec.elig_flag = 'Y' then
        --
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string||
          'Elg: Yes '||
          'Rsn: Prtn Ovrid';
        --
        raise g_eligible;
        --
      elsif p_comp_rec.elig_flag = 'N' then
        --
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string||
          'Elg: No  '||
          'Rsn: Prtn Ovrid';
        --
        fnd_message.set_name('BEN','BEN_92223_PRTN_OVERRIDE');
        raise g_not_eligible;
        --
      end if;
      --
    end if;
    --
  elsif p_plip_id is not null then
    --
    l_elig_apls_flag := 'Y';
    --
    l_elig_to_prte_rsn_row := ben_cobj_cache.g_plipetpr_currow;
    --
    l_elig_inelig_cd := l_elig_to_prte_rsn_row.elig_inelig_cd;
    --
    --if the participantion override flag is on then participation override thru date
    --should see the life event occurred date not the effective date
    --
    --bug 7264617: changed condition to >= in order to include lf_evt_ocrd_dt in ovridn_thru_dt
    if l_plip_rec.prtn_elig_ovrid_alwd_flag = 'Y' and
       p_comp_rec.prtn_ovridn_flag = 'Y' and
       nvl(p_comp_rec.prtn_ovridn_thru_dt,hr_api.g_eot) >= nvl(l_fonm_cvg_strt_dt,
                                                          nvl(p_lf_evt_ocrd_dt,p_effective_date)) and
       (nvl(l_elig_to_prte_rsn_row.ignr_prtn_ovrid_flag,'N') = 'N' or
        p_ler_id is null) then
      --
      -- Make person what they were before
      -- e.g. eligible stays eligible, ineligible stays ineligible.
      --
      if p_comp_rec.elig_flag = 'Y' then
        --
        raise g_eligible;
        --
      elsif p_comp_rec.elig_flag = 'N' then
        --
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string||
          'Elg: No  '||
          'Rsn: Prtn Ovrid';
        fnd_message.set_name('BEN','BEN_92223_PRTN_OVERRIDE');
        raise g_not_eligible;
        --
      end if;
      --
    end if;
    --
  elsif p_ptip_id is not null then
    --
    l_elig_apls_flag := 'Y';
    --
    l_elig_to_prte_rsn_row := ben_cobj_cache.g_ptipetpr_currow;
    --
    l_elig_inelig_cd := l_elig_to_prte_rsn_row.elig_inelig_cd;
    --
    --if the participantion override flag is on then participation override thru date
    --should see the life event occurred date not the effective date
    --
    --bug 7264617: changed condition to >= in order to include lf_evt_ocrd_dt in ovridn_thru_dt
    if l_ptip_rec.prtn_elig_ovrid_alwd_flag = 'Y' and
       p_comp_rec.prtn_ovridn_flag = 'Y' and
       nvl(p_comp_rec.prtn_ovridn_thru_dt,hr_api.g_eot) >= nvl(l_fonm_cvg_strt_dt,
                                                          nvl(p_lf_evt_ocrd_dt,p_effective_date)) and
       (nvl(l_elig_to_prte_rsn_row.ignr_prtn_ovrid_flag,'N') = 'N' or
        p_ler_id is null) then
      --
      -- Make person what they were before
      -- e.g. eligible stays eligible, ineligible stays ineligible.
      --
      if p_comp_rec.elig_flag = 'Y' then
        --
        raise g_eligible;
        --
      elsif p_comp_rec.elig_flag = 'N' then
        --
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string||
          'Elg: No  '||
          'Rsn: Prtn Ovrid';
        fnd_message.set_name('BEN','BEN_92223_PRTN_OVERRIDE');
        raise g_not_eligible;
        --
      end if;
      --
    end if;
    --
  elsif p_oipl_id is not null then
    --
    l_elig_apls_flag := l_oipl_rec.elig_apls_flag;
    --
    l_elig_to_prte_rsn_row := ben_cobj_cache.g_oipletpr_currow;
    --
    l_elig_inelig_cd := l_elig_to_prte_rsn_row.elig_inelig_cd;
    --
    --if the participantion override flag is on then participation override thru date
    --should see the life event occurred date not the effective date
    --
    --bug 7264617: changed condition to >= in order to include lf_evt_ocrd_dt in ovridn_thru_dt
    if l_oipl_rec.prtn_elig_ovrid_alwd_flag = 'Y' and
       p_comp_rec.prtn_ovridn_flag = 'Y' and
       nvl(p_comp_rec.prtn_ovridn_thru_dt,hr_api.g_eot) >= nvl(l_fonm_cvg_strt_dt,
                                                          nvl(p_lf_evt_ocrd_dt,p_effective_date)) and
       (nvl(l_elig_to_prte_rsn_row.ignr_prtn_ovrid_flag,'N') = 'N' or
        p_ler_id is null) then
      --
      -- Make person what they were before
      -- e.g. eligible stays eligible, ineligible stays ineligible.
      --
      if p_comp_rec.elig_flag = 'Y' then
        --
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string||
          'Elg: Yes '||
          'Rsn: Prtn Ovrid';
        raise g_eligible;
        --
      elsif p_comp_rec.elig_flag = 'N' then
        --
        ben_manage_life_events.g_output_string :=
          ben_manage_life_events.g_output_string||
          'Elg: No  '||
          'Rsn: Prtn Ovrid';
        fnd_message.set_name('BEN','BEN_92223_PRTN_OVERRIDE');
        raise g_not_eligible;
        --
      end if;
      --
    end if;
    --
  end if;
  --
  -- Check if program, plan or option has an eligibility profile
  if g_debug then
    hr_utility.set_location(l_proc||' Before profile loop',22);
  end if;
  --
  --  Check life event eligibility.  If a life event is specified  and
  --  elig_inelig_code =
  --    1.  ELIG  - person is eligible, no need to check other profiles.
  --    2.  INELIG - person is not eligible.
  --    3.  ETHREI - If person is eligible, also check other profiles.
  --
  if (p_ler_id is not null
      and l_elig_inelig_cd is not null) then
    --
    if l_elig_inelig_cd = 'ELIG' then
      raise g_eligible;
    elsif l_elig_inelig_cd = 'INELIG' then
      g_inelg_rsn_cd := 'EVT';
      fnd_message.set_name('BEN','BEN_92303_LIFE_EVENT_NOT_ELIG');
      raise g_not_eligible;
    end if;
    --
  end if;
  --
  --  Check for person's eligibility based upon contact/dependent data.
  --  (e.g. eligible for dependent only coverage in an HMO if dependent
  --  lives in service area and participant is full time).
  --  Only check for plan, plip and oipl.
  if g_debug then
    hr_utility.set_location('p_pl_id '||p_pl_id,24);
    hr_utility.set_location('p_oipl_id '||p_oipl_id,24);
    hr_utility.set_location('p_pgm_id '||p_comp_obj_tree_row.par_pgm_id,24);
  end if;
  --BUG 4055771
  ben_env_object.get(p_rec => l_env_rec);
  benutils.get_batch_parameters(p_benefit_action_id => l_env_rec.benefit_action_id
                                ,p_rec => l_benmngle_parm_rec);
  --
  -- BUG 4055771 l_env.mode_cd Never got initialized
  if g_debug then
    hr_utility.set_location(l_proc||' Family mem stuff ',10);
  end if;
  --
  if (p_pl_id is not null
      or p_oipl_id is not null) and NVL(l_benmngle_parm_rec.mode_cd,'X') not in ('I','D') -- BUG 4055771
                                                     -- l_env.mode_cd <>'I' -- IREC
  then
      --
      -- Task 130 : Get vrfy_fmly_mmbr_cd from levels pgm, ptip,
      -- plip, pl, oipl. If it is available at higher levels
      -- that will take precedence over lower levels.
      -- If vrfy_fmly_mmbr_cd is defined at ler level for
      -- a comp object that will take precedence.
      if g_debug then
        hr_utility.set_location('p_par_pgm_id '||p_comp_obj_tree_row.par_pgm_id,25);
        hr_utility.set_location('p_par_ptip_id '||p_comp_obj_tree_row.par_ptip_id,25);
        hr_utility.set_location('p_par_plip_id '||p_comp_obj_tree_row.par_plip_id,25);
        hr_utility.set_location('p_par_pl_id '||p_comp_obj_tree_row.par_pl_id,25);
        hr_utility.set_location('l_pl_name '||l_pl_rec.name,26);
      end if;
      --
      if p_comp_obj_tree_row.par_pgm_id is not null
      then
         --
         l_par_pgm_elig_rec := ben_cobj_cache.g_pgmetpr_currow;
         --
         if l_par_pgm_elig_rec.vrfy_fmly_mmbr_cd is not null then
            l_vrfy_fmly_mmbr_cd := l_par_pgm_elig_rec.vrfy_fmly_mmbr_cd;
            l_vrfy_fmly_mmbr_rl := l_par_pgm_elig_rec.vrfy_fmly_mmbr_rl;
         else
            l_par_pgm_rec := ben_cobj_cache.g_pgm_currow;
            l_vrfy_fmly_mmbr_cd := l_par_pgm_rec.vrfy_fmly_mmbr_cd;
            l_vrfy_fmly_mmbr_rl := l_par_pgm_rec.vrfy_fmly_mmbr_rl;
         end if;
         --
      end if;
      --
      if l_vrfy_fmly_mmbr_cd is null and
            p_comp_obj_tree_row.par_ptip_id is not null
      then
         --
         l_par_ptip_elig_rec := ben_cobj_cache.g_ptipetpr_currow;
         --
         if l_par_ptip_elig_rec.vrfy_fmly_mmbr_cd is not null then
            l_vrfy_fmly_mmbr_cd := l_par_ptip_elig_rec.vrfy_fmly_mmbr_cd;
            l_vrfy_fmly_mmbr_rl := l_par_ptip_elig_rec.vrfy_fmly_mmbr_rl;
         else
            l_par_ptip_rec := ben_cobj_cache.g_ptip_currow;
            l_vrfy_fmly_mmbr_cd := l_par_ptip_rec.vrfy_fmly_mmbr_cd;
            l_vrfy_fmly_mmbr_rl := l_par_ptip_rec.vrfy_fmly_mmbr_rl;
         end if;
         --
        if g_debug then
          hr_utility.set_location('l_ptip level '||l_vrfy_fmly_mmbr_cd,26);
        end if;
      end if;
      --
      if l_vrfy_fmly_mmbr_cd is null and
            p_comp_obj_tree_row.par_plip_id is not null
      then
         --
         l_par_plip_elig_rec := ben_cobj_cache.g_plipetpr_currow;
         --
         if l_par_plip_elig_rec.vrfy_fmly_mmbr_cd is not null then
            l_vrfy_fmly_mmbr_cd := l_par_plip_elig_rec.vrfy_fmly_mmbr_cd;
            l_vrfy_fmly_mmbr_rl := l_par_plip_elig_rec.vrfy_fmly_mmbr_rl;
         else
            --
            l_par_plip_rec := ben_cobj_cache.g_plip_currow;
            --
            l_vrfy_fmly_mmbr_cd := l_par_plip_rec.vrfy_fmly_mmbr_cd;
            l_vrfy_fmly_mmbr_rl := l_par_plip_rec.vrfy_fmly_mmbr_rl;
         end if;
   --      hr_utility.set_location('l_plip level '||l_vrfy_fmly_mmbr_cd,26);
         --
      end if;
      --
      if l_vrfy_fmly_mmbr_cd is null and
            p_comp_obj_tree_row.par_pl_id is not null
      then
         --
         -- BUG 3168805 l_par_pl_elig_rec := ben_cobj_cache.g_pgmetpr_currow;
         -- looks like typo, we should be looking at plan rec not pgm rec
         l_par_pl_elig_rec := ben_cobj_cache.g_pletpr_currow;
         --
         if l_par_pl_elig_rec.vrfy_fmly_mmbr_cd is not null then
            l_vrfy_fmly_mmbr_cd := l_par_pl_elig_rec.vrfy_fmly_mmbr_cd;
            l_vrfy_fmly_mmbr_rl := l_par_pl_elig_rec.vrfy_fmly_mmbr_rl;
         else
            --
            l_par_pl_rec := ben_cobj_cache.g_pl_currow;
            --
            l_vrfy_fmly_mmbr_cd := l_par_pl_rec.vrfy_fmly_mmbr_cd;
            l_vrfy_fmly_mmbr_rl := l_par_pl_rec.vrfy_fmly_mmbr_rl;
         end if;
         --
         if g_debug then
           hr_utility.set_location('l_pl level '||l_vrfy_fmly_mmbr_cd,26);
         end if;
      end if;
      --
      if p_pl_id is not null then
         --
         --  Get the person covered code from the plan cache.
         --
         l_per_cvrd_cd := l_pl_rec.per_cvrd_cd;
         --
         l_pl_id             := p_pl_id;
         l_dpnt_pl_id        := p_pl_id;
         --
      elsif p_oipl_id is not null then
         if g_debug then
           hr_utility.set_location(l_proc||' oipl NN ',28);
           hr_utility.set_location(' vrfy fmly mmbr cd from ben_elig_to_prte_rsn_f  '
                                   || l_elig_to_prte_rsn_row.vrfy_fmly_mmbr_cd  ,29);
         end if;
         --
         if l_vrfy_fmly_mmbr_cd is null then
            --
            l_vrfy_fmly_mmbr_cd := l_oipl_rec.vrfy_fmly_mmbr_cd;
            l_vrfy_fmly_mmbr_rl := l_oipl_rec.vrfy_fmly_mmbr_rl;
            --
            if l_elig_to_prte_rsn_row.vrfy_fmly_mmbr_cd is not null then
               l_vrfy_fmly_mmbr_cd := l_elig_to_prte_rsn_row.vrfy_fmly_mmbr_cd;
               l_vrfy_fmly_mmbr_rl := l_elig_to_prte_rsn_row.vrfy_fmly_mmbr_rl;
            end if;

         end if;

         l_pl_id  := l_oipl_rec.pl_id;
         --
         --  Check dependent eligibility.
         --
         if l_oipl_rec.per_cvrd_cd is null then
           ben_comp_object.get_object(p_pl_id => l_oipl_rec.pl_id,
                                      p_rec   => l_pl2_rec);
           l_per_cvrd_cd := l_pl2_rec.per_cvrd_cd;
         else
           l_per_cvrd_cd := l_oipl_rec.per_cvrd_cd;
         end if;
         --
         l_dpnt_pl_id := l_oipl_rec.pl_id;
         --
      end if;
      --
      --  Check verify family member code. CDR - Check
      --  Designation requirements.
      --
      if g_debug then
        hr_utility.set_location(l_proc||' Ver FM Code ',10);
        hr_utility.set_location(' l_vrfy_fmly_mmbr_cd ' || l_vrfy_fmly_mmbr_cd , 25 );
      end if;
      --
      if l_vrfy_fmly_mmbr_cd = 'CDR' then
          --
          --  Get contacts.
          --
            ben_determine_eligibility3.check_dsgn_rqmts
              (p_oipl_id           => p_oipl_id
              ,p_pl_id             => l_pl_id
              ,p_opt_id            => l_oipl_rec.opt_id
              ,p_person_id         => p_person_id
              ,p_business_group_id => p_business_group_id
              ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
              ,p_effective_date    => p_effective_date
              ,p_vrfy_fmm          => true
              ,p_dpnt_elig_flag    => l_dpnt_elig_flag);
          --
          if l_dpnt_elig_flag = 'N' then
            --
            g_inelg_rsn_cd := 'FMM';
            fnd_message.set_name('BEN','BEN_92321_FMM_INELIG');
            raise g_not_eligible;
            --
          end if;
          --
        elsif l_vrfy_fmly_mmbr_rl is not null  then
          --
          if l_ass_rec.location_id is not null then
            --
            ben_location_object.get_object
              (p_location_id => l_ass_rec.location_id
              ,p_rec         => l_loc_rec);
            --
          end if;
          --
          /*
          if l_loc_rec.region_2 is not null then
            --
            l_jurisdiction_code := pay_mag_utils.lookup_jurisdiction_code
                                    (l_loc_rec.region_2);
            --
          end if;
          */
          --
          if g_debug then
            hr_utility.set_location(l_proc||' formula ',30);
          end if;
          --
          l_outputs := benutils.formula
           (p_formula_id        => l_vrfy_fmly_mmbr_rl,
            p_effective_date    => l_effective_date,
            p_business_group_id => p_business_group_id,
            p_assignment_id     => l_ass_rec.assignment_id,
            p_organization_id   => l_ass_rec.organization_id,
            p_pgm_id            => p_comp_obj_tree_row.par_pgm_id,
            p_pl_id             => l_pl_id,
            p_pl_typ_id         => l_pl_rec.pl_typ_id,
            p_opt_id            => l_oipl_rec.opt_id,
            p_ler_id            => p_ler_id,
            p_param1            => 'PERSON_ID',
            p_param1_value      => to_char(p_person_id),
            p_param2             => 'BEN_IV_RT_STRT_DT',
            p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
            p_param3             => 'BEN_IV_CVG_STRT_DT',
            p_param3_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt),
            p_jurisdiction_code => l_jurisdiction_code);
          --
          if l_outputs(l_outputs.first).value = 'N'  then
            g_inelg_rsn_cd := 'FMM';
            fnd_message.set_name('BEN','BEN_92321_FMM_INELIG');
            raise g_not_eligible;
          end if;
          --
        end if;
        --
        if g_debug then
          hr_utility.set_location('l_per_cvrd_cd '||l_per_cvrd_cd,32);
          hr_utility.set_location(l_proc||' PCVRDCD',32);
        end if;
        --
        if l_per_cvrd_cd in ('PRTTDPNT', 'DPNTELIG') or
           l_vrfy_fmly_mmbr_cd = 'CDR' then
          --
          --  Get per_in_ler_id
          --
/*
          l_per_in_ler_id := benutils.get_per_in_ler_id
                             (p_person_id         => p_person_id
                             ,p_business_group_id => p_business_group_id
                             ,p_effective_date    => p_effective_date
                             );
*/
          -- added for unrestricted enhancement
          l_per_in_ler_id := p_pil_row.per_in_ler_id;
          --
          --  Clear PL/SQL table.
          --
          g_elig_dpnt_rec.delete;
          --
          --  Get all personal contacts for the person.
          --
          l_ctr_count := 0;
          --
          if g_debug then
            hr_utility.set_location(l_proc||' Contact loop ',10);
          end if;
          --
          for l_ctr_rec in c_get_contacts
          loop
            --
            --  Call dependent eligibility
            --
            if g_debug then
              hr_utility.set_location('BEDEP_MN :'||l_proc,34);
            end if;
            --
            ben_evaluate_dpnt_elg_profiles.main
            (p_contact_relationship_id => l_ctr_rec.contact_relationship_id
            ,p_contact_person_id       => l_ctr_rec.contact_person_id
            ,p_pgm_id                  => p_comp_obj_tree_row.par_pgm_id
            ,p_pl_id                   => l_dpnt_pl_id
            ,p_ptip_id                 => p_ptip_id
            ,p_oipl_id                 => p_oipl_id
            ,p_business_group_id       => p_business_group_id
            ,p_effective_date          => p_effective_date
            ,p_per_in_ler_id           => l_per_in_ler_id
            ,p_lf_evt_ocrd_dt          => l_effective_date
            ,p_dependent_eligible_flag => l_dependent_elig_flag
            ,p_dpnt_inelig_rsn_cd      => l_dpnt_inelig_rsn_cd
	    );
            if g_debug then
              hr_utility.set_location('Dn BEDEP_MN :'||l_proc,36);
            end if;
            --
            --   Load dependent data into a plsql table to check
            --   for designation requirements.
            --
            if l_dependent_elig_flag = 'Y' then
              -- at least one dpnt is elig, set flag.
              l_dpnt_elig_flag := 'Y';
              g_elig_dpnt_rec(l_ctr_count) := l_ctr_rec;
              l_ctr_count := l_ctr_count + 1;
            end if;
            --
          end loop;
          --
          --  If person have contact(s) that are eligible dependents,
          --  check if the eligible dependents meets the designation
          --  requirements.
          --
            ben_determine_eligibility3.check_dsgn_rqmts
              (p_oipl_id           => p_oipl_id
              ,p_pl_id             => l_pl_id
              ,p_opt_id            => l_oipl_rec.opt_id
              ,p_person_id         => p_person_id
              ,p_business_group_id => p_business_group_id
              ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
              ,p_effective_date    => p_effective_date
              ,p_vrfy_fmm          => false
              ,p_dpnt_elig_flag    => l_dpnt_elig_flag);
              --
              if l_dpnt_elig_flag = 'N' then
                if g_debug then
                  hr_utility.set_location('BEN_92255_DPNT_NOT_ELIG: from check_dsgn_rqmts',38);
                end if;
                g_inelg_rsn_cd := 'DLG';
                fnd_message.set_name('BEN','BEN_92255_DPNT_NOT_ELIG');
                raise g_not_eligible;
              end if;
            --
            --  By pass all participant processing if person covered code is
            --  'DPNTELIG'.
            --
            if l_per_cvrd_cd = 'DPNTELIG' then
              raise g_eligible;
            end if;
            --
        end if;
        --
  end if;
  --
  -- If the comp objects eligibility applies flag = 'N' then we don't need
  -- to bother checking eligibility profiles. That means that someone is
  -- instantly eligible, scary thing is though that the form needs to enforce
  -- this and we have data out there which doesn't enforce use of the flag.
  --
  if l_elig_apls_flag = 'Y' then
    --
    -- Get eligibility profile details for the business group, plan or
    -- program or option combination as of the process date
    if g_debug then
      hr_utility.set_location('PGM_ID '||p_pgm_id,44);
      hr_utility.set_location('PL_ID '||p_pl_id,44);
      hr_utility.set_location('OIPL_ID '||p_oipl_id,44);
      hr_utility.set_location('PLIP_ID '||p_plip_id,44);
      hr_utility.set_location('PTIP_ID '||p_ptip_id,44);
      hr_utility.set_location(l_proc||' Before Cache call',44);
	  hr_utility.set_location('p_pil_row.per_in_ler_id '||p_pil_row.per_in_ler_id,44);
    end if;
    --
    if not ben_evaluate_elig_profiles.eligible
       (p_person_id                 => p_person_id
       ,p_business_group_id         => p_business_group_id
       ,p_effective_date            => p_effective_date
       ,p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt
       ,p_dpr_rec                   => p_comp_rec
       ,p_per_in_ler_id             => p_pil_row.per_in_ler_id --l_per_in_ler_id  -- bug 7119125
       ,p_ler_id                    => p_ler_id
       ,p_pgm_id                    => p_pgm_id
       ,p_ptip_id                   => p_ptip_id
       ,p_plip_id                   => p_plip_id
       ,p_pl_id                     => p_pl_id
       ,p_oipl_id                   => p_oipl_id
       ,p_oiplip_id                 => null
       ,p_pl_typ_id                 => l_pl_rec.pl_typ_id
       ,p_opt_id                    => l_oipl_rec.opt_id
       ,p_par_pgm_id                => p_comp_obj_tree_row.par_pgm_id
       ,p_par_plip_id               => p_comp_obj_tree_row.par_plip_id
       ,p_par_pl_id                 => p_comp_obj_tree_row.par_pl_id
       ,p_par_opt_id                => p_comp_obj_tree_row.par_opt_id
       ,p_asg_status                => l_terminated
       ,p_score_tab                 => l_score_tab
       ) then
       raise g_not_eligible;
    end if;
    --
    --  determine further eligibility based upon the rules associated
    --  with participation eligibility
    --
    if g_debug then
      hr_utility.set_location('before rules: '||l_proc,72);
    end if;
    --
    ben_elig_rl_cache.get_elig_rl_cache
      (p_pgm_id            => p_pgm_id
      ,p_pl_id             => p_pl_id
      ,p_oipl_id           => p_oipl_id
      ,p_plip_id           => p_plip_id
      ,p_ptip_id           => p_ptip_id
      ,p_effective_date    => p_effective_date
      ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
      ,p_business_group_id => p_business_group_id
      ,p_inst_set          => l_inst_set
      ,p_inst_count        => l_elig_rl_cnt
      );
    if g_debug then
      hr_utility.set_location(l_proc||' done rules: ',74);
      hr_utility.set_location('Number of rules : ' || l_inst_set.count, 74);
    end if;
    --
    if l_elig_rl_cnt > 0 then
      --
      for i in l_inst_set.first .. l_inst_set.last loop
        --
        l_ok_so_far := 'N';
        --
        if l_assignment_id is null then
          --
          -- The person has no assingments and the rule requires assignment id
          -- If the rule is mandatory, the person is not eligible.
          -- If the rule is optional, then there is no need to check.
          --
          if l_inst_set(i).mndtry_flag = 'Y'
          then
             --
             -- Bug : 5059 : If the person have no assignment id, and formula
             -- uses data base items based on assignment id, then formula raises
             -- error like : A SQL SELECT statement, obtained from the application
             -- dictionary returned no rows. If assignement id is null and formula
             -- uses any DBI's which depend on it, make the person ineligible.
             --
             l_ff_use_asg_id_flag := 'N';
             open c_ff_use_asg(l_inst_set(i).formula_id);
             fetch c_ff_use_asg into l_ff_use_asg_id_flag;
             close c_ff_use_asg;
             --
             if l_ff_use_asg_id_flag = 'Y' then
                --
                raise g_not_eligible;
                --
             end if;
            --
          else
            --
            raise g_eligible;
            --
          end if;
          --
        end if;
        --
        if l_ass_rec.location_id is not null then
          --
          ben_location_object.get_object
            (p_location_id => l_ass_rec.location_id
            ,p_rec         => l_loc_rec);
          --
        end if;
        --
        l_ctp_rec := NULL;
        l_pln_rec := NULL;
        --
        if (p_ptip_id IS NOT NULL) THEN
            --  5482868 Find pl_typ_id for PTIP records
            if g_debug then
              hr_utility.set_location('Fetch pl_typ_id from cache p_ptip_id ' || p_ptip_id, 75);
            end if;
            --
            BEN_COMP_OBJECT.get_object(p_ptip_id => p_ptip_id, p_rec => l_ctp_rec);
        elsif (p_plip_id IS NOT NULL)
              and (p_comp_obj_tree_row.par_pl_id is not null) then
            --  5482868 Find pl_typ_id for PLIP records
            BEN_COMP_OBJECT.get_object(p_pl_id => p_comp_obj_tree_row.par_pl_id, p_rec => l_pln_rec);
            --
        elsif (l_oipl_rec.pl_id IS NOT NULL) then
            --  5482868 Find pl_typ_id for PLIP records
            BEN_COMP_OBJECT.get_object(p_pl_id => l_oipl_rec.pl_id, p_rec => l_pln_rec);
            --
        end if;
        --
        --
        l_outputs := benutils.formula
           (p_formula_id        => l_inst_set(i).formula_id,
            p_effective_date    => nvl(p_lf_evt_ocrd_dt,p_effective_date),
            p_business_group_id => p_business_group_id,
            p_assignment_id     => l_ass_rec.assignment_id,
            p_organization_id   => l_ass_rec.organization_id,
            p_pgm_id            => NVL(p_pgm_id, p_comp_obj_tree_row.par_pgm_id), -- 5482868 : pass parent_id
            p_pl_id             => NVL(p_pl_id, p_comp_obj_tree_row.par_pl_id), -- 5482868 : pass parent_id
            p_pl_typ_id         => NVL(l_pl_rec.pl_typ_id, NVL(l_ctp_rec.pl_typ_id, l_pln_rec.pl_typ_id)),
            p_opt_id            => l_oipl_rec.opt_id,
            p_ler_id            => p_ler_id,
            p_param1             => 'BEN_IV_RT_STRT_DT',
            p_param1_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
            p_param2             => 'BEN_IV_CVG_STRT_DT',
            p_param2_value       => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt),
            p_param3             => 'BEN_IV_PERSON_ID',            -- Bug 5331889
            p_param3_value       => to_char(p_person_id),
	        p_jurisdiction_code => l_jurisdiction_code);
        --
        if l_outputs(l_outputs.first).value = 'Y'  then
          --
          l_ok_so_far := 'Y';
          --
          if l_inst_set(i).mndtry_flag = 'N' then
            --
            -- If we are in a optional rule, that means we passed all
            -- the mandatory rules.
            --
            raise g_eligible;
            --
          end if;
          --
        elsif l_outputs(l_outputs.first).value = 'N' then
          --
          ben_manage_life_events.g_output_string :=
            ben_manage_life_events.g_output_string||
            'Elg: No '||
            'Rsn: Rule No Pass';
          --
          l_ok_so_far := 'N';
          --
          if l_inst_set(i).mndtry_flag = 'Y' then
            --
            -- you must pass all mandatory rules.
            --
            raise g_not_eligible;
            --
          end if;
          --
        else
          --
          fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
          fnd_message.set_token('RL','formula_id :'||l_inst_set(i).formula_id);
          fnd_message.set_token('PROC',l_proc);
          raise ben_manage_life_events.g_record_error;
          --
        end if;
        --
      end loop;  -- elig rules
      --
      -- If we are here, either:
      --    there were no rules or
      --    all mandatory rules passed
      --
      --    there were no optional rules
      --    or there are optional ones, mt_one flag is off and
      --    ALL optional rules failed.
    end if; -- inst count
    --
    if l_ok_so_far = 'N' then
      --
      raise g_not_eligible;
      --
    else
      --
      raise g_eligible;
      --
    end if;
    --
  else
    --
    raise g_eligible;
    --
  end if; -- elig_apls_flag
  if g_debug then
    hr_utility.set_location('Leaving: '||l_proc,99);
  end if;
  --
exception
  --
  when g_eligible then
    --
--    benutils.write(p_text => 'BENDETEL g_eligible ');
    if g_debug then
      hr_utility.set_location(l_proc||' Exc g_eligible ',800);
    end if;
    --
    -- Set out parameters
    --
    p_eligible := TRUE;
    --
    l_elig_flag := TRUE;
    --
    g_rec.person_id := p_person_id;
    g_rec.pgm_id := p_pgm_id;
    g_rec.pl_id := p_pl_id;
    g_rec.oipl_id := p_oipl_id;
    g_rec.elig_flag := 'Y';
    g_rec.inelig_text := null;
    g_rec.business_group_id := p_business_group_id;
    g_rec.effective_date := p_effective_date;
    --
    if g_debug then
      hr_utility.set_location(l_proc||' BU_WRITE g_eligible ',812);
    end if;
    --
    benutils.write(p_rec => g_rec);
    benutils.write(p_text => ben_manage_life_events.g_output_string);
    ben_manage_life_events.g_output_string       := null;
    --
    if g_debug then
      hr_utility.set_location(l_proc||' BDE_CPE g_eligible ',814);
      hr_utility.set_location('AGE VAL in CPE'||p_comp_rec.age_val,814);
    end if;
    --
   --
    ben_determine_eligibility2.check_prev_elig
      (p_comp_obj_tree_row       => p_comp_obj_tree_row
      --
      ,p_per_row                 => p_per_row
      ,p_empasg_row              => p_empasg_row
      ,p_benasg_row              => p_benasg_row
      ,p_pil_row                 => p_pil_row
      --
      ,p_elig_flag               => l_elig_flag
      ,p_person_id               => p_person_id
      ,p_business_group_id       => p_business_group_id
      ,p_effective_date          => p_effective_date
      ,p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt
      ,p_pl_id                   => p_pl_id
      ,p_pgm_id                  => p_pgm_id
      ,p_oipl_id                 => p_oipl_id
      ,p_plip_id                 => p_plip_id
      ,p_ptip_id                 => p_ptip_id
      ,p_ler_id                  => p_ler_id
      ,p_comp_rec                => p_comp_rec
      ,p_oiplip_rec              => p_oiplip_rec
      ,p_inelg_rsn_cd            => null
      --
      ,p_newly_elig             => p_newly_elig
      ,p_newly_inelig           => p_newly_inelig
      ,p_first_elig             => p_first_elig
      ,p_first_inelig           => p_first_inelig
      ,p_still_elig             => p_still_elig
      ,p_still_inelig           => p_still_inelig
      ,p_score_tab              => l_score_tab
      );
    --
   --
    if g_debug then
      hr_utility.set_location(l_proc||' Dn Exc g_eligible ',816);
    end if;
    --
  when g_not_eligible then
    --
--    benutils.write(p_text => 'BENDETEL g_not_eligible ');
    if g_debug then
      hr_utility.set_location(l_proc||' Exc g_not_eligible ',818);
    end if;
    --
    -- Set out parameters
    --
    p_not_eligible := TRUE;
    --
    l_elig_flag := FALSE;
    --
    g_rec.person_id := p_person_id;
    g_rec.pgm_id := p_pgm_id;
    g_rec.pl_id := p_pl_id;
    g_rec.oipl_id := p_oipl_id;
    g_rec.elig_flag := 'N';
    g_rec.inelig_text := fnd_message.get;
    g_rec.business_group_id := p_business_group_id;
    g_rec.effective_date := p_effective_date;
    --
    if g_debug then
      hr_utility.set_location(l_proc||' Dn BU_WRI g_not_eligible ',822);
    end if;
    --
    benutils.write(p_rec => g_rec);
    benutils.write(p_text => ben_manage_life_events.g_output_string);
    ben_manage_life_events.g_output_string       := null;
    --
    if g_debug then
      hr_utility.set_location(l_proc||' Dn BDE_CPE g_not_eligible ',824);
      hr_utility.set_location('g_inelg_rsn_cd  ' || g_inelg_rsn_cd ,824);
      hr_utility.set_location('ben_evaluate_elig_profiles.g_inelg_rsn_cd ' || ben_evaluate_elig_profiles.g_inelg_rsn_cd,824);
    end if;
    --
    ben_determine_eligibility2.check_prev_elig
      (p_comp_obj_tree_row       => p_comp_obj_tree_row
      --
      ,p_per_row                 => p_per_row
      ,p_empasg_row              => p_empasg_row
      ,p_benasg_row              => p_benasg_row
      ,p_pil_row                 => p_pil_row
      --
      ,p_elig_flag               => l_elig_flag
      ,p_person_id               => p_person_id
      ,p_business_group_id       => p_business_group_id
      ,p_effective_date          => p_effective_date
      ,p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt
      ,p_pl_id                   => p_pl_id
      ,p_pgm_id                  => p_pgm_id
      ,p_oipl_id                 => p_oipl_id
      ,p_plip_id                 => p_plip_id
      ,p_ptip_id                 => p_ptip_id
      ,p_ler_id                  => p_ler_id
      ,p_comp_rec                => p_comp_rec
      ,p_oiplip_rec              => p_oiplip_rec
      ,p_inelg_rsn_cd            => nvl(ben_evaluate_elig_profiles.g_inelg_rsn_cd, g_inelg_rsn_cd)
      --
      ,p_newly_elig             => p_newly_elig
      ,p_newly_inelig           => p_newly_inelig
      ,p_first_elig             => p_first_elig
      ,p_first_inelig           => p_first_inelig
      ,p_still_elig             => p_still_elig
      ,p_still_inelig           => p_still_inelig
      ,p_score_tab              => l_score_tab
      );
    --
   --
    if g_debug then
      hr_utility.set_location(l_proc||' Dn Exc g_not_eligible ',826);
    end if;
    --
end determine_elig_prfls;
--
end ben_determine_eligibility;

/
