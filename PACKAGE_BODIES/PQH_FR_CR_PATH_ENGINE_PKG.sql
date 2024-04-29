--------------------------------------------------------
--  DDL for Package Body PQH_FR_CR_PATH_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_CR_PATH_ENGINE_PKG" AS
/* $Header: pqcrpeng.pkb 120.1 2005/06/03 04:57 sankjain noship $ */

g_end_of_time     DATE := TO_DATE('31/12/4712','DD/MM/RRRR');
g_package varchar2(30) := 'PQH_FR_CR_PATH_ENGINE_PKG.';
g_business_group_id number;

function check_length_of_service (p_person_id in number,
                      p_business_group_id in number,
                      p_assignment_id in number,
                      p_length_of_service_type in varchar2,
                      p_effective_date in date,
                      p_req_years in number,
                       p_req_Months in number,
                      p_req_days in number) return varchar2 is

l_proc varchar2(60) := g_package||'check_length_of_service';

l_length_of_service number;

l_req_length_of_service number;

l_return_status varchar2(1);

begin
hr_utility.set_location('Entering into '||l_proc,5);

l_length_of_service := PQH_LENGTH_OF_SERVICE_PKG.get_length_of_service(
                                 p_bg_id               => p_business_group_id,
                                 p_person_id           => p_person_id,
                                 p_assignment_id       => p_assignment_id,
                                 p_los_type            => p_length_of_service_type,
                                 p_return_units        => 'M',
                                 p_determination_date  => p_effective_date );

l_req_length_of_service := pqh_corps_utility.los_in_months(p_los_years => p_req_years,
                                         p_los_months => p_req_Months,
                                         p_los_days   => p_req_days);

hr_utility.set_location('Required length of service in Months '||to_char(l_req_length_of_service),5);
hr_utility.set_location('Current length of service in Months '||to_char(l_length_of_service),5);

if l_length_of_service >= l_req_length_of_service then
   l_return_status := 'Y';
else
  l_return_status := 'N';
end if;
hr_utility.set_location('Leaving from '||l_proc,5);
return l_return_status;
end check_length_of_service;

procedure check_eligibility ( p_per_in_ler_id in number,
                             p_person_id in number,
                             p_effective_date in date,
                             p_business_group_id in number,
                             p_pgm_id in number default null,
                             p_pl_id in number default null,
                             p_oipl_id in number default null,
                             p_opt_id in number default null,
                             p_plip_id in number default null,
                             p_ptip_id in number default null,
                             p_pl_type_id in number default null,
                             p_par_pgm_id in number default null,
                             p_par_pl_id in number default null,
                             p_par_plip_id in number default null,
                             p_par_opt_id in number default null,
                             p_return_status out nocopy varchar2,
                             p_score_tab out nocopy ben_evaluate_elig_profiles.scoreTab
                            ) is

l_proc varchar2(60) := g_package||'check_eligibility';

l_return_status varchar2(1);
l_elig_return_status boolean;
l_comp_rec ben_derive_part_and_rate_facts.g_cache_structure;
l_comp_obj_tree_row  ben_manage_life_events.g_cache_proc_objects_rec;
l_empasg_row         per_all_assignments_f%ROWTYPE;
l_benasg_row         per_all_assignments_f%ROWTYPE;
l_pil_row            ben_per_in_ler%ROWTYPE;
l_oiplip_rec ben_derive_part_and_rate_facts.g_cache_structure;
l_score_tab  ben_evaluate_elig_profiles.scoreTab;

begin
hr_utility.set_location('Entering into '||l_proc,5);
hr_utility.set_location('Clearing Cache '||l_proc,5);
-- ben_cep_cache.clear_down_cache;

/* ben_manage_life_events.clear_init_benmngle_caches
    (p_business_group_id => p_business_group_id
    ,p_effective_date    => p_effective_date
    ,p_threads           => 1
    ,p_chunk_size        => 1
    ,p_max_errors        => 1
    ,p_benefit_action_id => Null
    ,p_thread_id         => 1
    );  */

hr_utility.set_location('Creating ben person objects '||l_proc,5);

hr_utility.set_location('Pgm Id '||p_pgm_id,5);
hr_utility.set_location('p_oipl_id '||p_oipl_id,5);
hr_utility.set_location('p_opt_id '||p_opt_id,5);
hr_utility.set_location('p_plip_id '||p_plip_id,5);
hr_utility.set_location('p_ptip_id'||p_ptip_id,5);
hr_utility.set_location('p_pl_type_id '||p_pl_type_id,5);
hr_utility.set_location('p_par_pgm_id '||p_par_pgm_id,5);
hr_utility.set_location('p_par_pl_id '||p_par_pl_id,5);
hr_utility.set_location('p_par_plip_id '||p_par_plip_id,5);
hr_utility.set_location('p_par_opt_id '||p_par_opt_id,5);

ben_person_object.get_object
    (p_person_id => p_person_id
    ,p_rec       => l_empasg_row
    );

ben_person_object.get_benass_object
    (p_person_id => p_person_id
    ,p_rec       => l_benasg_row
    );

ben_person_object.get_object
    (p_person_id => p_person_id
    ,p_per_in_ler_id =>p_per_in_ler_id
    ,p_rec       => l_pil_row
    );

hr_utility.set_location('Creating comp_obj_tree_row ',5);

  l_comp_obj_tree_row.pl_id  := p_pl_id;
  l_comp_obj_tree_row.pgm_id := p_pgm_id;
  l_comp_obj_tree_row.oipl_id := p_oipl_id;
  l_comp_obj_tree_row.ptip_id := p_ptip_id;
  l_comp_obj_tree_row.plip_id := p_plip_id;
  l_comp_obj_tree_row.pl_nip := 'N';
  l_comp_obj_tree_row.par_pgm_id := p_par_pgm_id;
  l_comp_obj_tree_row.par_plip_id := p_plip_id;
  l_comp_obj_tree_row.par_pl_id := p_par_pl_id;
  l_comp_obj_tree_row.par_plip_id := p_par_plip_id;
  l_comp_obj_tree_row.par_opt_id  := p_par_opt_id;
  l_comp_obj_tree_row.prtn_strt_dt := p_effective_date;


hr_utility.set_location('Creating derive rate factors data structure ',5);

hr_utility.set_location('Creating derive rate factors data structure ',5);
hr_utility.set_location('Values in Comp obj tree ',5);
hr_utility.set_location('Pgm Id '||l_comp_obj_tree_row.pgm_id,5);
hr_utility.set_location('p_oipl_id '||  l_comp_obj_tree_row.oipl_id,5);
--hr_utility.set_location('p_opt_id '||l_comp_obj_tree_row.oipl_id,5);
hr_utility.set_location('p_plip_id '||l_comp_obj_tree_row.plip_id,5);
hr_utility.set_location('p_ptip_id'||  l_comp_obj_tree_row.ptip_id,5);
--hr_utility.set_location('p_pl_type_id '||p_pl_type_id,5);
hr_utility.set_location('p_par_pgm_id '||l_comp_obj_tree_row.par_pgm_id ,5);
hr_utility.set_location('p_par_pl_id '||l_comp_obj_tree_row.par_pl_id,5);
hr_utility.set_location('p_par_plip_id '||l_comp_obj_tree_row.par_plip_id ,5);
hr_utility.set_location('p_par_opt_id '||  l_comp_obj_tree_row.par_opt_id,5);


ben_derive_part_and_rate_facts.cache_data_structures(
    p_comp_obj_tree_row => l_comp_obj_tree_row
   ,p_empasg_row        => l_empasg_row
   ,p_benasg_row        => l_benasg_row
   ,p_pil_row           => l_pil_row
   ,p_business_group_id => p_business_group_id
   ,p_effective_date    => p_effective_date
   ,p_person_id         => p_person_id
   ,p_pgm_id            => p_pgm_id
   ,p_pl_id             => p_pl_id
   ,p_plip_id           => p_plip_id
   ,p_ptip_id           => p_ptip_id
   ,p_oipl_id           => p_oipl_id
   ,p_comp_rec          => l_comp_rec
   ,p_oiplip_rec        => l_oiplip_rec);

   hr_utility.set_location('Checking Eligibiltiy ',5);

l_elig_return_status := ben_evaluate_elig_profiles.eligible
     (
      p_person_id          => p_person_id
     ,p_business_group_id  => p_business_group_id
     ,p_effective_date     => p_effective_date
     ,p_dpr_rec            => l_comp_rec
     ,p_pgm_id             => p_pgm_id
     ,p_ptip_id            => p_ptip_id
     ,p_plip_id            => p_plip_id
     ,p_pl_id              => p_pl_id
     ,p_oipl_id            => p_oipl_id
     ,p_pl_typ_id          => p_pl_type_id
     ,p_opt_id             => p_opt_id
     ,p_par_pgm_id         => p_par_pgm_id
     ,p_par_plip_id        => p_par_plip_id
     ,p_par_pl_id          => p_par_pl_id
     ,p_par_opt_id         => p_par_opt_id
     ,p_comp_obj_mode      => false
     ,p_lf_evt_ocrd_dt     => p_effective_date
     ,p_score_tab          => l_score_tab
     ) ;

if l_elig_return_status then

  p_return_status := 'Y';
  p_score_tab := l_score_tab;
else
  p_return_status := 'N';
end if;
hr_utility.set_location('Leaving from '||l_proc,5);
end check_eligibility;

procedure Create_Elictable_chc(
                               p_person_id in number,
                               p_per_in_ler_id in number,
                               p_business_group_id in number,
                               p_effective_date in date,
                               p_pgm_id in number default null,
                               p_pl_id in number default null,
                               p_oipl_id in number default null,
                               p_pl_type_id in number default null,
                               p_plip_id in number default null,
                               P_COMP_LVL_CD in varchar2,
                               P_Elig_Per_Elctbl_Chc_Id out nocopy number,
                               p_return_code out nocopy varchar2
                               ) is
l_proc varchar2(60) := g_package||'Create_Elictable_chc';


l_pgm_row ben_cobj_cache.g_pgm_inst_row;

Cursor pgm_info is
select * from ben_pgm_f pgm
where pgm_id = p_pgm_id
and p_effective_date between pgm.effective_start_date and pgm.effective_end_date;

pgm_info_rec pgm_info%rowtype;

l_enrt_cvg_strt_dt          date;
l_enrt_cvg_strt_dt_cd       varchar2(10);
l_enrt_cvg_strt_dt_rl       number;
l_rt_strt_dt                date;
l_rt_strt_dt_cd             varchar2(10);
l_rt_strt_dt_rl             number;
l_enrt_cvg_end_dt           date;
l_enrt_cvg_end_dt_cd        varchar2(10);
l_enrt_cvg_end_dt_rl        number;
l_rt_end_dt                 date;
l_rt_end_dt_cd              varchar2(10);
l_rt_end_dt_rl              number;
L_Elig_Per_Elctbl_Chc_Id    number;
l_LEE_RSN_ID                number;
l_posting_style             varchar2(1);
l_yr_perd_id                number;
L_OIPL_ELIG_PER_ELCTBL_CHC_ID number;
l_Elctbl_Ovn                number;
l_Oipl_Elctbl_Ovn           number;
l_request_id                number;


Begin
hr_utility.set_location('Entering into '||l_proc,5);

hr_utility.set_location('Creating pgm Row '||l_proc,5);
  open pgm_info;
  fetch pgm_info into pgm_info_rec;

   l_pgm_row.pgm_id                   := pgm_info_rec.pgm_id;
   l_pgm_row.effective_start_date     := pgm_info_rec.effective_start_date;
   l_pgm_row.effective_end_date       := pgm_info_rec.effective_end_date;
   l_pgm_row.enrt_cvg_strt_dt_cd      := pgm_info_rec.enrt_cvg_strt_dt_cd;
   l_pgm_row.enrt_cvg_strt_dt_rl      := pgm_info_rec.enrt_cvg_strt_dt_rl;
   l_pgm_row.enrt_cvg_end_dt_cd       := pgm_info_rec.enrt_cvg_end_dt_cd;
   l_pgm_row.enrt_cvg_end_dt_rl       := pgm_info_rec.enrt_cvg_end_dt_rl;
   l_pgm_row.rt_strt_dt_cd            := pgm_info_rec.rt_strt_dt_cd;
   l_pgm_row.rt_strt_dt_rl            := pgm_info_rec.rt_strt_dt_rl;
   l_pgm_row.rt_end_dt_cd             := pgm_info_rec.rt_end_dt_cd;
   l_pgm_row.rt_end_dt_rl             := pgm_info_rec.rt_end_dt_rl;
   l_pgm_row.elig_apls_flag           := pgm_info_rec.elig_apls_flag;
   l_pgm_row.prtn_elig_ovrid_alwd_flag := pgm_info_rec.prtn_elig_ovrid_alwd_flag;
   l_pgm_row.trk_inelig_per_flag       := pgm_info_rec.trk_inelig_per_flag;
   l_pgm_row.vrfy_fmly_mmbr_cd         := pgm_info_rec.vrfy_fmly_mmbr_cd;
   l_pgm_row.vrfy_fmly_mmbr_rl         := pgm_info_rec.vrfy_fmly_mmbr_rl;
   l_pgm_row.dpnt_dsgn_lvl_cd          := pgm_info_rec.dpnt_dsgn_lvl_cd;
   l_pgm_row.dpnt_dsgn_cd              := pgm_info_rec.dpnt_dsgn_cd;
   l_pgm_row.dpnt_cvg_strt_dt_cd       := pgm_info_rec.dpnt_cvg_strt_dt_cd;
   l_pgm_row.dpnt_cvg_strt_dt_rl       := pgm_info_rec.dpnt_cvg_strt_dt_rl;
   l_pgm_row.dpnt_cvg_end_dt_cd        := pgm_info_rec.dpnt_cvg_end_dt_cd;
   l_pgm_row.dpnt_cvg_end_dt_rl        := pgm_info_rec.dpnt_cvg_end_dt_rl;
   l_pgm_row.pgm_typ_cd                := pgm_info_rec.pgm_typ_cd;

  close pgm_info;


hr_utility.set_location('Geting P_Enrt_Cvg_Strt_Dt ',5);

select blr.LEE_RSN_ID,pil.request_id
into l_LEE_RSN_ID, l_request_id
from ben_lee_rsn_f blr,
ben_popl_enrt_typ_cycl_f popl,
ben_per_in_ler pil
where blr.business_group_id = p_business_group_id
and blr.popl_enrt_typ_cycl_id = popl.POPL_ENRT_TYP_CYCL_ID
and blr.ler_id = pil.ler_id
and pil.per_in_ler_id = p_per_in_ler_id
and popl.business_group_id = p_business_group_id
and popl.pgm_id = p_pgm_id
and p_effective_date between popl.effective_start_date and popl.effective_end_date
and p_effective_date between blr.effective_start_date and blr.effective_end_date;

ben_determine_date.rate_and_coverage_dates
  ( p_pgm_row             => l_pgm_row
  ,p_per_in_ler_id        => p_per_in_ler_id
  ,p_person_id            => p_person_id
  ,p_pgm_id               => p_pgm_id
  ,p_lee_rsn_id           => l_LEE_RSN_ID  /*  */
  ,p_which_dates_cd       =>   'C'
  ,p_business_group_id    => p_business_group_id
  ,p_effective_date       => p_effective_date
  ,p_lf_evt_ocrd_dt       => p_effective_date
  --
  ,p_enrt_cvg_strt_dt     => l_enrt_cvg_strt_dt
  ,p_enrt_cvg_strt_dt_cd  => l_enrt_cvg_strt_dt_cd
  ,p_enrt_cvg_strt_dt_rl  => l_enrt_cvg_strt_dt_rl
  ,p_rt_strt_dt           => l_rt_strt_dt
  ,p_rt_strt_dt_cd        => l_rt_strt_dt_cd
  ,p_rt_strt_dt_rl        => l_rt_strt_dt_rl
  ,p_enrt_cvg_end_dt      => l_enrt_cvg_end_dt
  ,p_enrt_cvg_end_dt_cd   => l_enrt_cvg_end_dt_cd
  ,p_enrt_cvg_end_dt_rl   => l_enrt_cvg_end_dt_rl
  ,p_rt_end_dt            => l_rt_end_dt
  ,p_rt_end_dt_cd         => l_rt_end_dt_cd
  ,p_rt_end_dt_rl         => l_rt_end_dt_rl
  );

hr_utility.set_location('Creating electable choice ',5);

select enrt_mthd_cd
into l_posting_style
from ben_pgm_f
where pgm_id = p_pgm_id
and p_effective_date between effective_start_date and effective_end_date;



if l_posting_style = 'A' then
   l_posting_style := 'Y';
   p_return_code := l_posting_style;
else
   l_posting_style := 'N';
   p_return_code := 'D';
end if;


Select Yr_Perd_id
into l_yr_perd_id
From Ben_Yr_Perd
Where P_Effective_Date Between Start_Date and End_Date
and rownum = 1;

-- and business_group_id = p_business_group_id;

if P_COMP_LVL_CD = 'PLAN' then

Ben_Elig_Per_Elc_Chc_Api.CREATE_PERF_ELIG_PER_ELC_CHC
(P_ELIG_PER_ELCTBL_CHC_ID       =>   L_Elig_Per_Elctbl_Chc_Id   /* OUT Parameter */
,P_ENRT_CVG_STRT_DT_CD          =>   l_enrt_cvg_strt_dt_cd
,P_DFLT_FLAG                    =>   'Y'                        /* Mark it as 'Y' if default */
,P_ELCTBL_FLAG                  =>   'Y'              /*   */
,P_PL_ID                        =>   p_pl_id                    /* Plan Id corresponding to Grade */
,P_PGM_ID                       =>   p_pgm_id                  /* Pgm Id of the Grade Ladder*/
,P_PLIP_ID                      =>   p_plip_id                 /* Plip Id of the Grade   */
,P_PGM_TYP_CD                   =>   'GSP'                      /* pass GSP   */
,P_PL_TYP_ID                    =>   p_pl_type_id                /* Pass Plan Type Id of type GSP */
,P_PER_IN_LER_ID                =>   p_per_in_ler_id            /* Person Life Event Reason Id  */
,P_YR_PERD_ID                   =>   l_yr_perd_id               /* Pass the result of the query */
,P_Enrt_Cvg_Strt_Dt             =>   l_enrt_cvg_strt_dt
,P_COMP_LVL_CD                  =>   'PLAN'
,P_LEE_RSN_ID                   =>   l_LEE_RSN_ID               /* select lee_rsn_f
                                                                    where pgm_id= <pgm_id> */
,P_AUTO_ENRT_FLAG               =>   l_posting_style                       /* 'Y' if Automatic Progression
                                                                    'N' if Manual Progression   */
,P_BUSINESS_GROUP_ID            =>   p_business_group_id                    /* Business Group Id  */
,P_ELIG_FLAG                    =>   'Y'                        /*  Y */
,P_OBJECT_VERSION_NUMBER        =>   l_Elctbl_Ovn               /*  out parameter  */
,P_EFFECTIVE_DATE               =>   p_effective_date
,p_request_id                   =>   l_request_id);

P_Elig_Per_Elctbl_Chc_Id  := L_Elig_Per_Elctbl_Chc_Id;
elsif P_COMP_LVL_CD = 'OIPL' then

Ben_Elig_Per_Elc_Chc_Api.CREATE_PERF_ELIG_PER_ELC_CHC
(P_ELIG_PER_ELCTBL_CHC_ID       =>   L_Elig_Per_Elctbl_Chc_Id   /* OUT Parameter */
,P_ENRT_CVG_STRT_DT_CD          =>   l_enrt_cvg_strt_dt_cd
,P_DFLT_FLAG                    =>   'N'                        /* Mark it as 'Y' if default */
,P_ELCTBL_FLAG                  =>   'N'              /*   */
,P_PL_ID                        =>   p_pl_id                    /* Plan Id corresponding to Grade */
,P_PGM_ID                       =>   p_pgm_id                  /* Pgm Id of the Grade Ladder*/
,P_PLIP_ID                      =>   p_plip_id                 /* Plip Id of the Grade   */
,P_PGM_TYP_CD                   =>   'GSP'                      /* pass GSP   */
,P_PL_TYP_ID                    =>   p_pl_type_id                /* Pass Plan Type Id of type GSP */
,P_PER_IN_LER_ID                =>   p_per_in_ler_id            /* Person Life Event Reason Id  */
,P_YR_PERD_ID                   =>   l_yr_perd_id               /* Pass the result of the query */
,P_Enrt_Cvg_Strt_Dt             =>   l_enrt_cvg_strt_dt
,P_COMP_LVL_CD                  =>   'PLAN'
,P_LEE_RSN_ID                   =>   l_LEE_RSN_ID               /* select lee_rsn_f
                                                                    where pgm_id= <pgm_id> */
,P_AUTO_ENRT_FLAG               =>   l_posting_style                       /* 'Y' if Automatic Progression
                                                                    'N' if Manual Progression   */
,P_BUSINESS_GROUP_ID            =>   p_business_group_id                    /* Business Group Id  */
,P_ELIG_FLAG                    =>   'N'                        /*  Y */
,P_OBJECT_VERSION_NUMBER        =>   l_Elctbl_Ovn               /*  out parameter  */
,P_EFFECTIVE_DATE               =>   p_effective_date
,p_request_id                   =>   l_request_id);

 Ben_Elig_Per_Elc_Chc_Api.CREATE_PERF_ELIG_PER_ELC_CHC
   (
    P_ELIG_PER_ELCTBL_CHC_ID       =>   L_Oipl_Elig_Per_Elctbl_Chc_Id
   ,P_ENRT_CVG_STRT_DT_CD          =>   l_enrt_cvg_strt_dt_cd
   ,P_DFLT_FLAG                    =>   'Y'
   ,P_ELCTBL_FLAG                  =>   'Y'
   ,P_PL_ID                        =>   p_pl_id                    /* Plan Id corresponding to Grade */
   ,P_PGM_ID                       =>   p_pgm_id                  /* Pgm Id of the Grade Ladder*/
   ,P_PLIP_ID                      =>   p_plip_id                 /* Plip Id of the Grade   */
   ,P_OIPL_ID                      =>   p_oipl_id
   ,P_PGM_TYP_CD                   =>   'GSP'
   ,P_PL_TYP_ID                    =>   p_pl_type_id
   ,P_Enrt_Cvg_Strt_Dt             =>   l_enrt_cvg_strt_dt
   ,P_YR_PERD_ID                   =>   l_yr_perd_id
   ,P_PER_IN_LER_ID                =>   p_per_in_ler_id
   ,P_COMP_LVL_CD                  =>   'OIPL'
   ,P_LEE_RSN_ID                   =>   l_LEE_RSN_ID
   ,P_AUTO_ENRT_FLAG               =>   l_posting_style
   ,P_BUSINESS_GROUP_ID            =>   p_business_group_id
   ,P_ELIG_FLAG                    =>   'Y'
   ,P_OBJECT_VERSION_NUMBER        =>   l_Oipl_Elctbl_Ovn
   ,P_EFFECTIVE_DATE               =>   p_effective_date
   ,p_request_id                   =>   l_request_id);

P_Elig_Per_Elctbl_Chc_Id  := L_Oipl_Elig_Per_Elctbl_Chc_Id;

end if;
hr_utility.set_location('Leaving from '||l_proc,5);


end Create_Elictable_chc;

 /*  procedure Create_Enrolment_rates(p_assignment_id in number,
                                 p_effective_date in date,
                                 p_electble_chc_id in number,
                                 p_business_group_id in number,
                                 p_pl_id in number default null,
                                 p_opt_id in number default null,
                                 p_comb_lvl_cd in varchar2
                                 ) is

l_proc varchar2(60) := g_package||'Create_Enrolment_rates';
l_Cur_Sal                     Ben_Enrt_Rt.Val%TYPE;
l_Rt_Typ_Cd                   Ben_Enrt_Rt.Rt_Typ_Cd%TYPE;
L_Acty_Base_rt_Id             Ben_Acty_Base_Rt.Acty_Base_rt_Id%TYPE;
l_Enrt_Rt_Ovn                 Ben_Elig_Per_Elctbl_Chc.Object_version_Number%TYPE;
l_Entr_Ann_Val_Flag           Ben_Acty_Base_rt_F.Entr_Ann_Val_Flag%TYPE;
L_Enrt_Rt_Id                  Ben_Enrt_Rt.Enrt_Rt_Id%TYPE;

Cursor Pl_Bas_rt(l_Pl_Id IN Number) Is
Select ACTY_BASE_RT_ID, Rt_Typ_cd, Entr_Ann_Val_Flag
From Ben_Acty_base_Rt_f
where Pl_id   = l_Pl_Id
and P_effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

Cursor Opt_Bas_Rt(l_Opt_Id IN Number) Is
Select ACTY_BASE_RT_ID, Rt_Typ_cd, Entr_Ann_Val_Flag
From Ben_Acty_Base_rt_f
where Opt_Id = L_Opt_id
and P_effective_Date
Between Effective_Start_Date
    and Effective_End_Date;

begin
hr_utility.set_location('Entering into '||l_proc,5);

if p_comb_lvl_cd = 'PLAN' then

   Open  Pl_Bas_rt(p_Pl_Id);
   Fetch Pl_Bas_rt into l_ACTY_BASE_RT_ID, l_Rt_Typ_cd, l_Entr_Ann_Val_Flag;
   Close Pl_Bas_rt;

elsif p_comb_lvl_cd = 'OIPL' then

  Open  Opt_Bas_rt(p_Opt_Id);
   Fetch Opt_Bas_Rt into l_ACTY_BASE_RT_ID, l_Rt_Typ_cd, l_Entr_Ann_Val_Flag;
   Close Opt_Bas_Rt;

end if;

  l_Cur_Sal := Pqh_gsp_utility.Get_Cur_Sal
                (P_Assignment_id   => P_Assignment_id
                ,P_Effective_Date  => P_Effective_date);

   ben_Enrollment_Rate_api.CREATE_PERF_ENROLLMENT_RATE
   (P_ENRT_RT_ID                   =>  L_Enrt_Rt_Id
   ,P_ACTY_TYP_CD                  =>  'GSPSA'
   ,P_TX_TYP_CD                    =>  'NOTAPPLICABLE'
   ,P_DFLT_FLAG                    =>  'Y'
   ,P_VAL                          =>  l_Cur_Sal
   ,P_RT_TYP_CD                    =>  l_Rt_Typ_Cd
   ,P_ELIG_PER_ELCTBL_CHC_ID       =>  p_electble_chc_id
   ,P_Entr_Ann_Val_Flag            =>  l_Entr_Ann_Val_Flag
   ,P_Business_Group_Id            =>  p_business_group_id
   ,P_ACTY_BASE_RT_ID              =>  L_Acty_Base_rt_Id
   ,P_OBJECT_VERSION_NUMBER        =>  l_Enrt_Rt_Ovn
   ,P_Effective_Date               =>  P_Effective_Date);

hr_utility.set_location('Leaving from '||l_proc,5);

end Create_Enrolment_rates; */

procedure Create_Enrolment_rates(p_effective_date in date,
                                 p_electble_chc_id in number,
                                 p_business_group_id in number,
                                 p_per_in_ler_id in number ,
                                 p_person_id in number
                                 ) is
l_proc varchar2(60) := g_package||'Create_Enrolment_rates';
begin
hr_utility.set_location('Entering into '||l_proc,5);
ben_env_object.init(p_business_group_id  => p_business_group_id,
                          p_effective_date     => p_effective_date,
                          p_thread_id          => 1,
                          p_chunk_size         => 1,
                          p_threads            => 1,
                          p_max_errors         => 1,
                          p_benefit_action_id  => null);

      ben_env_object.setenv(P_LF_EVT_OCRD_DT  => p_effective_date);

      ben_env_object.g_global_env_rec.mode_cd := 'G';

      Ben_determine_rates.Main
      (P_EFFECTIVE_DATE               => p_effective_date
      ,P_LF_EVT_OCRD_DT               => p_effective_date
      ,P_PERSON_ID                    => p_person_id
      ,P_PER_IN_LER_ID                => p_per_in_ler_id
      ,p_elig_per_elctbl_chc_id       => p_electble_chc_id);

hr_utility.set_location('Leaving from '||l_proc,5);
end Create_Enrolment_rates;

procedure Create_elig_per_scre( p_business_group_id in number,
                                p_per_in_ler_id in number,
                                p_person_id in number,
                                p_effective_date in date,
                                p_pgm_id in number default null,
                                p_pl_id in number default null,
                                p_plip_id in number default null,
                                p_ptip_id in number default null,
                                p_opt_id  in number default null,
                                p_score_tab in ben_evaluate_elig_profiles.scoreTab
                               ) is
l_number_of_rows number;
l_elig_per_id number;
l_effective_start_date date;
l_effective_end_date date;
l_elig_per_ovn_no number;
l_request_id number;
l_elig_per_opt_id number;
l_opt_effective_start_date date;
l_opt_effective_end_date date;
l_elig_per_opt_ovn_no number;
l_proc varchar2(60) := g_package||'Create_elig_per_scre';

begin
hr_utility.set_location('Entering into '||l_proc,5);
          l_number_of_rows := p_score_tab.COUNT;
          if l_number_of_rows > 0 then

          select pil.request_id
          into l_request_id
          from ben_lee_rsn_f blr,
               ben_popl_enrt_typ_cycl_f popl,
               ben_per_in_ler pil
          where blr.business_group_id = p_business_group_id
          and blr.popl_enrt_typ_cycl_id = popl.POPL_ENRT_TYP_CYCL_ID
          and blr.ler_id = pil.ler_id
          and pil.per_in_ler_id = p_per_in_ler_id
          and popl.business_group_id = p_business_group_id
          and popl.pgm_id = p_pgm_id
          and p_effective_date between popl.effective_start_date and popl.effective_end_date
          and p_effective_date between blr.effective_start_date and blr.effective_end_date;

             ben_Eligible_Person_api.create_perf_Eligible_Person
                  ( p_elig_per_id                   => l_elig_per_id
                   ,p_effective_start_date          => l_effective_start_date
                   ,p_effective_end_date            => l_effective_end_date
                   ,p_business_group_id              => p_business_group_id
                   ,p_pl_id                          => p_pl_id
                   ,p_pgm_id                         => p_pgm_id
                   ,p_plip_id                        => p_plip_id
                   ,p_ptip_id                        => p_ptip_id
                   ,p_person_id                      => p_person_id
                   ,p_per_in_ler_id                  => p_per_in_ler_id
                   ,p_object_version_number          => l_elig_per_ovn_no
                   ,p_effective_date                 => p_effective_date
                   ,p_prtn_ovridn_flag               => 'N'
                   ,p_request_id                     => l_request_id
                    );
               hr_utility.set_location('elig_per_id'||l_elig_per_id,5);
             hr_utility.set_location('p_opt_id'||p_opt_id,5);

       --    if p_opt_id is not null then
                  hr_utility.set_location('going to  create elig_per_opt record'||p_opt_id,5);
              ben_Elig_Person_option_api.create_perf_Elig_Person_option
                    ( p_elig_per_opt_id              => l_elig_per_opt_id
                     ,p_elig_per_id                  => l_elig_per_id
                     ,p_effective_start_date         => l_opt_effective_start_date
                     ,p_effective_end_date           => l_opt_effective_end_date
                     ,p_prtn_ovridn_flag             => 'N'
                     ,p_no_mx_prtn_ovrid_thru_flag   => 'N'
                     ,p_elig_flag                    => 'Y'
                     ,p_opt_id                       => p_opt_id
                     ,p_per_in_ler_id                => p_per_in_ler_id
                     ,p_business_group_id            => p_business_group_id
                     ,p_request_id                   => l_request_id
                     ,p_object_version_number        => l_elig_per_opt_ovn_no
                     ,p_effective_date               => p_effective_date
                    );
--             end if;

           hr_utility.set_location('l_elig_per_opt_id'||l_elig_per_opt_id,5);
          end if;
          FOR table_row IN 1 .. l_number_of_rows
          LOOP
              hr_utility.set_location('eligy_prfl_id'||p_score_tab(table_row).eligy_prfl_id,5);
              hr_utility.set_location('crit_tab_short_name'||p_score_tab(table_row).crit_tab_short_name,5);
              hr_utility.set_location('crit_tab_pk_id'||p_score_tab(table_row).crit_tab_pk_id,5);
              hr_utility.set_location('computed_score'||p_score_tab(table_row).computed_score,5);
              hr_utility.set_location('benefit_action_id'||p_score_tab(table_row).benefit_action_id,5);
              BEN_ELIG_SCRE_WTG_API.load_score_weight( p_score_tab => p_score_tab
                                                      ,p_elig_per_id => l_elig_per_id
                                                      ,p_elig_per_opt_id => l_elig_per_opt_id
                                                      ,p_effective_date => p_effective_date );
          END LOOP;
hr_utility.set_location('Leaving '||l_proc,5);
end  Create_elig_per_scre ;

procedure check_career_paths(p_per_in_ler_id in number,
                            p_person_id in number,
                            p_business_group_id in number,
                            p_cur_corp_id in number,
                            p_cur_grade_id in number,
                            p_cur_step_id in number,
                            p_effective_date in date,
                            p_assignment_id in number,
                            P_Elig_Per_Elctbl_Chc_Id out nocopy number,
                            p_return_code out nocopy varchar2,
                            p_return_status out nocopy varchar2
                            ) is


l_los_return_status varchar2(1);
l_elig_return_status varchar2(1);
l_person_id number;
l_assignment_id number;
l_effective_date date;
l_proc varchar2(60) := g_package||'get_career_paths';
l_cur_corp_id number;
l_cur_grade_id number;
l_cur_step_id number;
l_score_tab ben_evaluate_elig_profiles.scoreTab;


cursor career_paths is
select  ghn.Information9 to_corp_Id,
        ghn.Information23 to_grade_id,
        ghn.Information3 to_step_id,
        pl.pl_id to_pl_id,
        pgm.pgm_id to_pgm_id,
        plip.plip_id to_plip_id,
        pl.pl_typ_id to_pl_type_id,
        ptip.ptip_id to_ptip_id,
        ghn.Information10 length_of_service_type,
        ghn.Information11 req_years,
        ghn.Information12 req_Months,
        ghn.Information13 req_days
from PER_GEN_HIERARCHY_NODES ghn,
      ben_pl_f pl,
      pqh_corps_definitions corp,
      ben_pgm_f pgm,
      ben_plip_f plip,
      ben_ptip_f ptip
where ghn.Information4 =  l_cur_corp_id --cur_corp_id
--and ghn.Information30  =  l_cur_grade_id    -- cur_pgm_id
and ghn.Entity_id = l_cur_step_id  -- cur_step_id
and ghn.business_group_id = g_business_group_id
and ghn.node_type = 'CAREER_NODE'
and pl.mapping_table_name = 'PER_GRADES'
and pl.mapping_table_pk_id =  ghn.Information23
and l_effective_date between pl.effective_start_date and pl.effective_end_date
and corp.corps_definition_id = ghn.Information9
and pgm.pgm_id = corp.ben_pgm_id
and l_effective_date between pgm.effective_start_date and pgm.effective_end_date
and plip.pl_id = pl.pl_id
and plip.pgm_id = pgm.pgm_id
and l_effective_date between plip.effective_start_date and plip.effective_end_date
and ptip.pgm_id = pgm.pgm_id
and ptip.pl_typ_id = pl.pl_typ_id
and l_effective_date between ptip.effective_start_date and ptip.effective_end_date
;

career_path_rec career_paths%rowtype;

cursor step_info is
select
opt.opt_id to_opt_id,
oipl.oipl_id to_oipl_id
from
per_spinal_point_steps_f sps
,  ben_opt_f  opt
, ben_oipl_f oipl
where sps.step_id = career_path_rec.to_step_id
and opt.mapping_table_name = 'PER_SPINAL_POINTS'
and opt.mapping_table_pk_id = sps.spinal_point_id
and oipl.opt_id = opt.opt_id
and oipl.pl_id = career_path_rec.to_pl_id
and l_effective_date between sps.effective_start_date and sps.effective_end_date
and l_effective_date between opt.effective_start_date and opt.effective_end_date
and l_effective_date between oipl.effective_start_date and oipl.effective_end_date
;

step_info_rec step_info%rowtype;

begin
hr_utility.set_location('Entering into '||l_proc,5);

l_person_id := p_person_id;
l_assignment_id := p_assignment_id;
l_effective_date := p_effective_date;
l_cur_corp_id := p_cur_corp_id;
l_cur_grade_id := p_cur_grade_id;
l_cur_step_id := p_cur_step_id;


hr_utility.set_location('l_person_id  '||to_char(l_person_id),5);
hr_utility.set_location('l_assignment_id  '||to_char(l_assignment_id),5);
hr_utility.set_location('l_effective_date  '||to_char(l_effective_date),5);
hr_utility.set_location('l_cur_corp_id  '||to_char(l_cur_corp_id),5);
hr_utility.set_location('l_cur_grade_id  '||to_char(l_cur_grade_id),5);
hr_utility.set_location('l_cur_step_id  '||to_char(l_cur_step_id),5);
open career_paths;
loop
fetch career_paths into career_path_rec;
exit when career_paths%notfound;

l_los_return_status :=  check_length_of_service (
                      p_person_id              => l_person_id,
                      p_business_group_id      => p_business_group_id,
                      p_assignment_id          => l_assignment_id,
                      p_length_of_service_type => career_path_rec.length_of_service_type,
                      p_effective_date         => l_effective_date,
                      p_req_years              => career_path_rec.req_years,
                      p_req_Months             => career_path_rec.req_Months,
                      p_req_days               => career_path_rec.req_days);

if l_los_return_status = 'Y' then

       hr_utility.set_location('Checking eligibility for Corp ',5);
       check_eligibility (
                             p_per_in_ler_id     => p_per_in_ler_id,
                             p_person_id         => p_person_id,
                             p_effective_date    => p_effective_date,
                             p_business_group_id => p_business_group_id,
                             p_pgm_id            => career_path_rec.to_pgm_id,
                             p_par_pgm_id        => career_path_rec.to_pgm_id,
                             p_return_status     => l_elig_return_status,
                             p_score_tab         => l_score_tab
                             );
       if l_elig_return_status = 'Y' then
          hr_utility.set_location('Eligibility defined at Corp is satisfied ',5);
          Create_elig_per_scre( p_business_group_id => p_business_group_id,
                                p_per_in_ler_id     => p_per_in_ler_id,
                                p_person_id         => p_person_id,
                                p_effective_date    => p_effective_date,
                                p_pgm_id            => career_path_rec.to_pgm_id,
                                p_pl_id             => career_path_rec.to_pl_id,
                                p_plip_id           => career_path_rec.to_plip_id,
                                p_ptip_id           => career_path_rec.to_ptip_id,
                                p_score_tab         => l_score_tab
                               );
          hr_utility.set_location('Checking eligibility defined at grade in corp (plip) ',5);
          check_eligibility (
	                     p_per_in_ler_id     => p_per_in_ler_id,
                             p_person_id         => p_person_id,
                             p_effective_date    => p_effective_date,
                             p_business_group_id => p_business_group_id,
                             p_plip_id           => career_path_rec.to_plip_id,
                             p_par_pgm_id        => career_path_rec.to_pgm_id,
                             p_par_pl_id         => career_path_rec.to_pl_id,
                             p_par_plip_id       => career_path_rec.to_plip_id,
                             p_return_status     => l_elig_return_status,
                             p_score_tab         => l_score_tab
                             );
           if l_elig_return_status = 'Y' then
              hr_utility.set_location('Eligibility defined at Grade in Corp is satisfied ',5);
              Create_elig_per_scre( p_business_group_id => p_business_group_id,
                                p_per_in_ler_id     => p_per_in_ler_id,
                                p_person_id         => p_person_id,
                                p_effective_date    => p_effective_date,
                                p_pgm_id            => career_path_rec.to_pgm_id,
                                p_pl_id             => career_path_rec.to_pl_id,
                                p_plip_id           => career_path_rec.to_plip_id,
                                p_ptip_id           => career_path_rec.to_ptip_id,
                                p_score_tab         => l_score_tab
                               );
              hr_utility.set_location('Checking eligibility defined at grade ',5);
              check_eligibility (
	                     p_per_in_ler_id      => p_per_in_ler_id,
                             p_person_id          => p_person_id,
                             p_effective_date     => p_effective_date,
                             p_business_group_id => p_business_group_id,
                             p_pl_id              => career_path_rec.to_pl_id,
                             p_pl_type_id         => career_path_rec.to_pl_type_id,
                             p_par_pl_id          => career_path_rec.to_pl_id,
                             p_return_status     => l_elig_return_status,
                             p_score_tab         => l_score_tab
                             );
              if l_elig_return_status = 'Y' then
                 hr_utility.set_location('Eligibility defined at Grade is satisfied ',5);
                 Create_elig_per_scre( p_business_group_id => p_business_group_id,
                                p_per_in_ler_id     => p_per_in_ler_id,
                                p_person_id         => p_person_id,
                                p_effective_date    => p_effective_date,
                                p_pgm_id            => career_path_rec.to_pgm_id,
                                p_pl_id             => career_path_rec.to_pl_id,
                                p_plip_id           => career_path_rec.to_plip_id,
                                p_ptip_id           => career_path_rec.to_ptip_id,
                                p_score_tab         => l_score_tab
                               );
                 if career_path_rec.to_step_id is not null then
                   open step_info;
                   fetch step_info into step_info_rec;
                    hr_utility.set_location('Checking eligibility defined at step ',5);
                    check_eligibility(
                             p_per_in_ler_id     => p_per_in_ler_id,
                             p_person_id         => p_person_id,
                             p_effective_date    => p_effective_date,
                             p_business_group_id => p_business_group_id,
                             p_oipl_id           => step_info_rec.to_oipl_id,
                             p_par_opt_id        => step_info_rec.to_opt_id,
                             p_pl_type_id        => career_path_rec.to_pl_type_id,
                             p_par_pl_id         => career_path_rec.to_pl_id,
                             p_return_status     => l_elig_return_status,
                             p_score_tab         => l_score_tab
                             );
                    close step_info;
                    if l_elig_return_status = 'Y'  then
                        Create_elig_per_scre( p_business_group_id => p_business_group_id,
                                p_per_in_ler_id     => p_per_in_ler_id,
                                p_person_id         => p_person_id,
                                p_effective_date    => p_effective_date,
                                p_pgm_id            => career_path_rec.to_pgm_id,
                                p_pl_id             => career_path_rec.to_pl_id,
                                p_plip_id           => career_path_rec.to_plip_id,
                                p_ptip_id           => career_path_rec.to_ptip_id,
				p_opt_id            => step_info_rec.to_opt_id,
                                p_score_tab         => l_score_tab
                               );
                        Create_Elictable_chc(
                               p_person_id              => p_person_id,
                               p_per_in_ler_id          => p_per_in_ler_id,
                               p_business_group_id      => p_business_group_id,
                               p_effective_date         => p_effective_date,
                               p_pgm_id                 => career_path_rec.to_pgm_id,
                               p_pl_id                  => career_path_rec.to_pl_id,
                               p_oipl_id                => step_info_rec.to_oipl_id,
                               p_pl_type_id             => career_path_rec.to_pl_type_id,
                               p_plip_id                => career_path_rec.to_plip_id,
                               P_COMP_LVL_CD            => 'OIPL',
                               P_Elig_Per_Elctbl_Chc_Id => P_Elig_Per_Elctbl_Chc_Id,
                               p_return_code            => p_return_code
                              );


                           exit;
                    else
                        hr_utility.set_location('Eligibility defined at step is NOT satisfied ',5);
                      l_elig_return_status := 'N';
                    end if;
                  else
                      Create_Elictable_chc(
                               p_person_id              => p_person_id,
                               p_per_in_ler_id          => p_per_in_ler_id,
                               p_business_group_id      => p_business_group_id,
                               p_effective_date         => p_effective_date,
                               p_pgm_id                 => career_path_rec.to_pgm_id,
                               p_pl_id                  => career_path_rec.to_pl_id,
                               p_pl_type_id             => career_path_rec.to_pl_type_id,
                               p_plip_id                => career_path_rec.to_plip_id,
                               P_COMP_LVL_CD            => 'PLAN',
                               P_Elig_Per_Elctbl_Chc_Id => P_Elig_Per_Elctbl_Chc_Id,
                               p_return_code            => p_return_code
                              );

                         exit;
                  end if;
              else
                 hr_utility.set_location('Eligibility defined at grade is NOT satisfied ',5);
                l_elig_return_status := 'N';
              end if;
           else
               hr_utility.set_location('Eligibility defined at PLIP is NOT satisfied ',5);
              l_elig_return_status := 'N';
           end if;
        else
          hr_utility.set_location('Eligibility defined at Corp is NOT satisfied ',5);
          l_elig_return_status := 'N';
        end if;
else
  l_elig_return_status := 'N';
end if;

end loop;

if l_elig_return_status <> 'N' then

hr_utility.set_location('Creating Enrolment rates for the new electable choice ',5);

Create_Enrolment_rates(p_effective_date    => p_effective_date,
                       p_electble_chc_id   => P_Elig_Per_Elctbl_Chc_Id,
                       p_business_group_id => p_business_group_id,
                       p_per_in_ler_id     => p_per_in_ler_id ,
                       p_person_id         => p_person_id
                       );

end if;

p_return_status := l_elig_return_status;
hr_utility.set_location('Leaving from '||l_proc,5);

end check_career_paths ;

Procedure get_elctbl_chc_career_path (p_per_in_ler_id in number,
                                     p_effective_date in date,
                                     P_Elig_Per_Elctbl_Chc_Id out nocopy number,
                                     p_return_code out nocopy varchar2,
                                     p_return_status out nocopy varchar2)
is

cursor per_in_ler_info is
Select *
from ben_per_in_ler
where per_in_ler_id = p_per_in_ler_id;

l_pil_info_rec per_in_ler_info%rowtype;

cursor person_cur_asg_info is
select corp.corps_definition_id cur_corp_id,
       asg.grade_id cur_grade_id,
       asg.assignment_id assignment_id,
       spp.step_id cur_step_id,
       asg.grade_ladder_pgm_id cur_pgm_id,
       pl.pl_id cur_plan_id,
       oipl.oipl_id cur_oipl_id
from per_all_assignments_f asg,
     per_spinal_point_placements_f spp,
     per_spinal_point_steps_f sps,
     ben_opt_f  opt,
     ben_oipl_f oipl,
     ben_pl_f pl,
     pqh_corps_definitions corp
where asg.person_id = l_pil_info_rec.person_id
and asg.primary_flag = 'Y'
and asg.business_group_id = l_pil_info_rec.business_group_id
and asg.assignment_status_type_id = 1
and p_effective_date between asg.effective_start_date and asg.effective_end_date
and spp.assignment_id = asg.assignment_id
and p_effective_date between spp.effective_start_date and spp.effective_end_date
and sps.step_id = spp.step_id
and p_effective_date between sps.effective_start_date and sps.effective_end_date
and opt.mapping_table_name = 'PER_SPINAL_POINTS'
and opt.mapping_table_pk_id = sps.spinal_point_id
and p_effective_date between opt.effective_start_date and opt.effective_end_date
and pl.mapping_table_name = 'PER_GRADES'
and pl.mapping_table_pk_id =  asg.grade_id
and p_effective_date between pl.effective_start_date and pl.effective_end_date
and oipl.pl_id = pl.pl_id
and oipl.opt_id = opt.opt_id
and p_effective_date between oipl.effective_start_date and oipl.effective_end_date
and corp.ben_pgm_id = asg.grade_ladder_pgm_id;


l_person_info_rec person_cur_asg_info%rowtype;

l_proc varchar2(60) := g_package||'get_elctbl_chc_career_path';
l_person_id number;
l_lf_evt_ocrd_dt date;
l_return_status varchar2(1);


begin
-- hr_utility.trace_on(NULL,'SJSCR');

hr_utility.set_location('Entering into '||l_proc,5);

open per_in_ler_info;
fetch per_in_ler_info  into l_pil_info_rec;
close per_in_ler_info;

g_business_group_id := l_pil_info_rec.business_group_id;

open person_cur_asg_info;
loop
fetch person_cur_asg_info into l_person_info_rec;
exit when person_cur_asg_info%notfound;

hr_utility.set_location('In the person_cur_asg_info cur asg info loop  '||l_proc,5);

check_career_paths(p_per_in_ler_id            => p_per_in_ler_id,
                     p_person_id              => l_pil_info_rec.person_id,
                     p_business_group_id      => l_pil_info_rec.business_group_id,
                     p_cur_corp_id            => l_person_info_rec.cur_corp_id,
                     p_cur_grade_id           => l_person_info_rec.cur_grade_id,
                     p_cur_step_id            => l_person_info_rec.cur_step_id,
                     p_assignment_id          => l_person_info_rec.assignment_id,
                     p_effective_date         => p_effective_date,
                     P_Elig_Per_Elctbl_Chc_Id => P_Elig_Per_Elctbl_Chc_Id,
                     p_return_code            => p_return_code,
                     p_return_status          => p_return_status
                     );

end loop;

g_business_group_id := null;

hr_utility.set_location('Leaving from '||l_proc,5);


end  get_elctbl_chc_career_path;

END PQH_FR_CR_PATH_ENGINE_PKG;

/
