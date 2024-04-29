--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_DESIGN_DELETE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_DESIGN_DELETE_API" as
/* $Header: bepdwdel.pkb 120.1 2005/06/14 02:41 sparimi noship $ */
g_package  varchar2(30) :='BEN_PLAN_DESIGN_DELETE_API';

procedure call_delete_api
( p_process_validate in Number
 ,p_pk_id in Number
 ,p_table_alias in varchar2
 ,p_effective_date in Date
 ,p_effective_start_date out nocopy Date
 ,p_effective_end_date out nocopy Date
 ,p_object_version_number in out nocopy Number
 ,p_datetrack_mode  in varchar2
 ,p_parent_entity_name     in varchar2
 ,p_entity_name     in varchar2
 ,p_delete_failed out nocopy varchar2
)as

  -- we need to keep this false as even for validating we are to validate the whole submit process together.
  -- therefore we will not commit if the p_process_validate is true.
  p_validate boolean := false;
  l_encoded_message varchar2(2000);
  l_proc varchar2(72) := g_package||'call_delete_api';
begin
hr_utility.set_location('Entering: '||l_proc || ' for ' || p_table_alias || ' p_pk_id: ' ||p_pk_id ,20);
-- set the validate mode
if(p_process_validate = 1) then
    p_validate:=true;
end if ;

if p_table_alias = 'EAT' then
  ben_ACTION_TYPE_api.delete_ACTION_TYPE
 (p_validate                       => p_validate
 ,p_actn_typ_id                    => p_pk_id
 ,p_object_version_number          => p_object_version_number
 ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'SVA'	then
   BEN_SERVICE_AREA_API.delete_SERVICE_AREA
  (p_validate                       => p_validate
  ,p_svc_area_id                    => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'BNB'	then
   BEN_BENEFITS_BALANCE_API.delete_benefits_balance
  (p_validate                       => p_validate
  ,p_bnfts_bal_id                   => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CLF'	then
   BEN_CMBN_AGE_LOS_FCTR_API.delete_cmbn_age_los_fctr
  (p_validate                       => p_validate
  ,p_cmbn_age_los_fctr_id           => p_pk_id
  ,p_object_version_number          => p_object_version_number
  );
elsif p_table_alias = 		'HWF'	then
   BEN_HRS_WKD_IN_PERD_FCTR_API.delete_hrs_wkd_in_perd_fctr
  (p_validate                       => p_validate
  ,p_hrs_wkd_in_perd_fctr_id        => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'AGF'	then
   BEN_AGE_FACTOR_API.delete_age_factor
  (p_validate                       => p_validate
  ,p_age_fctr_id                    => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'LSF'	then
  BEN_LOS_FACTORS_API.delete_LOS_FACTORS
  (p_validate                       => p_validate
  ,p_los_fctr_id                    => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'PFF'	then
   BEN_PERCENT_FT_FACTORS_API.delete_percent_ft_factors
  (p_validate                       => p_validate
  ,p_pct_fl_tm_fctr_id              => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'CLA'	then
  BEN_CMBN_AGE_LOS_FCTR_API.delete_cmbn_age_los_fctr
  (p_validate                       => p_validate
  ,p_cmbn_age_los_fctr_id           => p_pk_id
  ,p_object_version_number          => p_object_version_number
  );
elsif p_table_alias = 		'PTP'	then
  BEN_PLAN_TYPE_API.delete_PLAN_TYPE
  (p_validate                       => p_validate
  ,p_pl_typ_id                      => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PLN'	then
   BEN_PLAN_API.delete_Plan
  (p_validate                       => p_validate
  ,p_pl_id                          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'BNR'	then
  BEN_REPORTING_GROUP_API.delete_Reporting_Group
  (p_validate                       => p_validate
  ,p_rptg_grp_id                    => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'REG'	then
  BEN_REGULATIONS_API.delete_Regulations
  (p_validate                       => p_validate
  ,p_regn_id                        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'OPT'	then
   BEN_OPTION_DEFINITION_API.delete_option_definition
  (p_validate                       => p_validate
  ,p_opt_id                         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PON'	then
   BEN_PLAN_TYPE_OPTION_TYPE_API.delete_plan_type_option_type
  (p_validate                       => p_validate
  ,p_pl_typ_opt_typ_id              => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'RZR'	then
   BEN_POSTAL_ZIP_RANGE_API.delete_postal_zip_range
  (p_validate                       => p_validate
  ,p_pstl_zip_rng_id                => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'RCL'	then
   BEN_RLTD_PER_CHG_CS_LER_API.delete_Rltd_Per_Chg_Cs_Ler
  (p_validate                       => p_validate
  ,p_rltd_per_chg_cs_ler_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PGM'	then
   BEN_PROGRAM_API.delete_Program
  (p_validate                       => p_validate
  ,p_pgm_id                         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CPL'	then
   BEN_CMBN_PLIP_API.delete_CMBN_PLIP
  (p_validate                       => p_validate
  ,p_cmbn_plip_id                   => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CBP'	then
   BEN_CMBN_PTIP_API.delete_CMBN_PTIP
  (p_validate                       => p_validate
  ,p_cmbn_ptip_id                   => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CPT'	then
   BEN_CMBN_PTIP_OPT_API.delete_CMBN_PTIP_OPT
  (p_validate                       => p_validate
  ,p_cmbn_ptip_opt_id               => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LER'	then
   BEN_LIFE_EVENT_REASON_API.delete_Life_Event_Reason
  (p_validate                       => p_validate
  ,p_ler_id                         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ELP'	then
   BEN_ELIGY_PROFILE_API.delete_ELIGY_PROFILE
  (p_validate                       => p_validate
  ,p_eligy_prfl_id                  => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'DCE'	then
   BEN_DPNT_CVG_ELIG_PRFL_API.delete_DPNT_CVG_ELIG_PRFL
  (p_validate                       => p_validate
  ,p_dpnt_cvg_eligy_prfl_id         => p_pk_id
  ,p_effective_end_date             => p_effective_end_date
  ,p_effective_start_date           => p_effective_start_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'GOS'	then
   BEN_GOOD_SVC_TYPE_API.delete_GOOD_SVC_TYPE
  (p_validate                       => p_validate
  ,p_gd_or_svc_typ_id               => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'BNG'	then
  BEN_BENEFITS_GROUP_API.delete_Benefits_Group
  (p_validate                       => p_validate
  ,p_benfts_grp_id                  => p_pk_id
  ,p_object_version_number          => p_object_version_number
  );
elsif p_table_alias = 		'PSL'	then
   BEN_PERSON_CHANGE_CS_LER_API.delete_Person_Change_Cs_Ler
  (p_validate                       => p_validate
  ,p_per_info_chg_cs_ler_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LPL'	then
   BEN_LER_PER_INFO_CS_LER_API.delete_Ler_Per_Info_Cs_Ler
  (p_validate                       => p_validate
  ,p_ler_per_info_cs_ler_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CCT'	then
  BEN_COMP_COMM_TYPES_API.delete_comp_comm_types
  (p_validate                       => p_validate
  ,p_cm_typ_id                      => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PDL'	then
  BEN_PERIOD_LIMIT_API.delete_period_limit
  (p_validate                       => p_validate
  ,p_ptd_lmt_id                     => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'YRP'	then
  BEN_PGM_OR_PL_YR_PERD_API.delete_pgm_or_pl_yr_perd
  (p_validate                       => p_validate
  ,p_yr_perd_id                     => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'WYP'	then
  BEN_WITHIN_YEAR_PERD_API.delete_WITHIN_YEAR_PERD
  (p_validate                       => p_validate
  ,p_wthn_yr_perd_id                => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'SAZ'	then
  BEN_SVC_AREA_PSTL_ZIP_RNG_API.delete_SVC_AREA_PSTL_ZIP_RNG
  (p_validate                       => p_validate
  ,p_svc_area_pstl_zip_rng_id       => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'COP'	then
  BEN_OPTION_IN_PLAN_API.delete_Option_in_Plan
  (p_validate                       => p_validate
  ,p_oipl_id                        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'DDR'	then
  BEN_DESIGN_RQMT_API.delete_design_rqmt
  (p_validate                       => p_validate
  ,p_dsgn_rqmt_id                   => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'DRR'	then
  BEN_DSGN_RQMT_RLSHP_TYP_API.delete_DSGN_RQMT_RLSHP_TYP
  (p_validate                       => p_validate
  ,p_dsgn_rqmt_rlshp_typ_id         => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'CPY'	then
  BEN_POPL_YR_PERD_API.delete_POPL_YR_PERD
  (p_validate                       => p_validate
  ,p_popl_yr_perd_id                => p_pk_id
  ,p_object_version_number          => p_object_version_number
  );
elsif p_table_alias = 		'CWG'	then
  BEN_CWB_WKSHT_GRP_API.delete_cwb_wksht_grp
  (p_validate                       => p_validate
  ,p_cwb_wksht_grp_id               => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'PAT'	then
  BEN_POPL_ACTION_TYPE_API.delete_POPL_ACTION_TYPE
  (p_validate                       => p_validate
  ,p_popl_actn_typ_id               => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PET'	then
  BEN_POPL_ENRT_TYP_CYCL_API.delete_Popl_Enrt_Typ_Cycl
  (p_validate                       => p_validate
  ,p_popl_enrt_typ_cycl_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ENP'	then
  BEN_ENROLLMENT_PERIOD_API.delete_Enrollment_Period
  (p_validate                       => p_validate
  ,p_enrt_perd_id                   => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'LEN'	then
  BEN_LIFE_EVENT_ENROLL_RSN_API.delete_Life_Event_Enroll_Rsn
  (p_validate                       => p_validate
  ,p_lee_rsn_id                     => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LOP'	then
  BEN_LER_CHG_OIPL_ENRT_API.delete_Ler_Chg_Oipl_Enrt
  (p_validate                       => p_validate
  ,p_ler_chg_oipl_enrt_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ERP'	then
  BEN_ENRT_PERD_FOR_PL_API.delete_enrt_perd_for_pl
  (p_validate                       => p_validate
  ,p_enrt_perd_for_pl_id            => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'SER'	then
  BEN_SCHEDD_ENROLLMENT_RL_API.delete_Schedd_Enrollment_Rl
  (p_validate                       => p_validate
  ,p_schedd_enrt_rl_id              => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ECF'	then
  BEN_ENRT_CTFN_API.delete_Enrt_Ctfn
  (p_validate                       => p_validate
  ,p_enrt_ctfn_id                   => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CPO'	then
  BEN_POPL_ORG_API.delete_POPL_ORG
  (p_validate                       => p_validate
  ,p_popl_org_id                    => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CPR'	then
  BEN_POPL_ORG_ROLE_API.delete_POPL_ORG_ROLE
  (p_validate                       => p_validate
  ,p_popl_org_role_id               => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'RGR'	then
  BEN_POPL_RPTG_GRP_API.delete_POPL_RPTG_GRP
  (p_validate                       => p_validate
  ,p_popl_rptg_grp_id               => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PRG'	then
  BEN_PLAN_REGULATION_API.delete_Plan_regulation
  (p_validate                       => p_validate
  ,p_pl_regn_id                     => p_pk_id
  ,p_effective_end_date             => p_effective_end_date
  ,p_effective_start_date           => p_effective_start_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ACP'	then
  BEN_ACRS_PTIP_CVG_API.delete_acrs_ptip_cvg
  (p_validate                       => p_validate
  ,p_acrs_ptip_cvg_id               => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CTP'	then
  BEN_PLAN_TYPE_IN_PROGRAM_API.delete_Plan_Type_In_Program
  (p_validate                       => p_validate
  ,p_ptip_id                        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ADE'	then
  BEN_APLD_DPNT_CVG_PRFL_API.delete_Apld_Dpnt_Cvg_Prfl
  (p_validate                       => p_validate
  ,p_apld_dpnt_cvg_elig_prfl_id     => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LDC'	then
  BEN_LER_CHG_DEPENDENT_CVG_API.delete_Ler_Chg_Dependent_Cvg
  (p_validate                       => p_validate
  ,p_ler_chg_dpnt_cvg_id            => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LCC'	then
  BEN_LER_CHG_DPNT_CVG_CTF_API.delete_Ler_Chg_Dpnt_Cvg_Ctf
  (p_validate                       => p_validate
  ,p_ler_chg_dpnt_cvg_ctfn_id       => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'WPT'	then
  BEN_WV_PRTN_RSN_PTIP_API.delete_WV_PRTN_RSN_PTIP
  (p_validate                       => p_validate
  ,p_wv_prtn_rsn_ptip_id            => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'WCT'	then
  BEN_WV_PRTN_RSN_CTFN_PTIP_API.delete_wv_prtn_rsn_ctfn_ptip
  (p_validate                       => p_validate
  ,p_wv_prtn_rsn_ctfn_ptip_id       => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LCT'	then
  BEN_LER_CHG_PTIP_ENRT_API.delete_ler_chg_ptip_enrt
  (p_validate                       => p_validate
  ,p_ler_chg_ptip_enrt_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PYD'	then
  BEN_PTIP_DPNT_CVG_CTFN_API.delete_Ptip_Dpnt_Cvg_Ctfn
  (p_validate                       => p_validate
  ,p_ptip_dpnt_cvg_ctfn_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CPP'	then
  BEN_PLAN_IN_PROGRAM_API.delete_Plan_in_Program
  (p_validate                       => p_validate
  ,p_plip_id                        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );

-- this is deleted by delete oipl call
--elsif p_table_alias = 		'OPP'	then
--  BEN_OPTION_IN_PLAN_IN_PGM_API.delete_option_in_plan_in_pgm
--  (p_validate                       => p_validate
--  ,p_oiplip_id                      => p_pk_id
--  ,p_effective_start_date           => p_effective_start_date
--  ,p_effective_end_date             => p_effective_end_date
--  ,p_object_version_number          => p_object_version_number
--  ,p_effective_date                 => p_effective_date
--  ,p_datetrack_mode                 => p_datetrack_mode
--  );
--
elsif p_table_alias = 		'BPP'	then
  BEN_BENEFIT_PRVDR_POOL_API.delete_Benefit_Prvdr_Pool
  (p_validate                       => p_validate
  ,p_bnft_prvdr_pool_id             => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LBR'	then
  BEN_LER_BNFT_RSTRN_API.delete_LER_BNFT_RSTRN
  (p_validate                       => p_validate
  ,p_ler_bnft_rstrn_id              => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LPR1' 	then
  BEN_LER_CHG_PLAN_ENRT_API.delete_ler_chg_plan_enrt
  (p_validate                       => p_validate
  ,p_ler_chg_plip_enrt_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'VGS'	then
  BEN_PLAN_GOODS_SERVICES_API.delete_Plan_goods_services
  (p_validate                       => p_validate
  ,p_pl_gd_or_svc_id                => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PCT'	then
  BEN_PLAN_GOODS_SERV_CERT_API.delete_plan_goods_serv_cert
  (p_validate                       => p_validate
  ,p_pl_gd_r_svc_ctfn_id            => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'VRP'	then
  BEN_VALD_RLSHP_FOR_REIMB_API.delete_Vald_Rlshp_For_Reimb
  (p_validate                       => p_validate
  ,p_vald_rlshp_for_reimb_id        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'WPN'	then
  BEN_WV_PRTN_REASON_PL_API.delete_WV_PRTN_REASON_PL
  (p_validate                       => p_validate
  ,p_wv_prtn_rsn_pl_id              => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'WCN'	then
  BEN_WV_PRTN_RSN_CTFN_PL_API.delete_WV_PRTN_RSN_CTFN_PL
  (p_validate                       => p_validate
  ,p_wv_prtn_rsn_ctfn_pl_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'BRC'	then
  BEN_BNFT_RSTRN_CTFN_API.delete_BNFT_RSTRN_CTFN
  (p_validate                       => p_validate
  ,p_bnft_rstrn_ctfn_id             => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LBC'	then
  BEN_LER_BNFT_RSTRN_CTFN_API.delete_LER_BNFT_RSTRN_CTFN
  (p_validate                       => p_validate
  ,p_ler_bnft_rstrn_ctfn_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LRE'	then
  BEN_LER_RQRS_ENRT_CTFN_API.delete_ler_rqrs_enrt_ctfn
  (p_validate                       => p_validate
  ,p_ler_rqrs_enrt_ctfn_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LNC'	then
  BEN_LER_ENRT_CTFN_API.delete_ler_enrt_ctfn
  (p_validate                       => p_validate
  ,p_ler_enrt_ctfn_id               => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LPE'	then
  BEN_LER_CHG_PL_NIP_ENRT_API.delete_Ler_Chg_Pl_Nip_Enrt
  (p_validate                       => p_validate
  ,p_ler_chg_pl_nip_enrt_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PND'	then
  BEN_PLAN_DPNT_CVG_CTFN_API.delete_Plan_Dpnt_Cvg_Ctfn
  (p_validate                       => p_validate
  ,p_pl_dpnt_cvg_ctfn_id            => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PEO'	then
  BEN_ELIG_TO_PRTE_REASON_API.delete_ELIG_TO_PRTE_REASON
  (p_validate                       => p_validate
  ,p_elig_to_prte_rsn_id            => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EPA'	then
  BEN_PARTICIPATION_ELIG_API.delete_Participation_Elig
  (p_validate                       => p_validate
  ,p_prtn_elig_id                   => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CEP'	then
  BEN_PRTN_ELIG_PRFL_API.delete_PRTN_ELIG_PRFL
  (p_validate                       => p_validate
  ,p_prtn_elig_prfl_id              => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CER'	then
  BEN_ELIGIBILITY_RULE_API.delete_ELIGIBILITY_RULE
  (p_validate                       => p_validate
  ,p_prtn_eligy_rl_id               => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PCX'	then
  BEN_PLAN_BENEFICIARY_CTFN_API.delete_Plan_Beneficiary_Ctfn
  (p_validate                       => p_validate
  ,p_pl_bnf_ctfn_id                 => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PCP'	then
  BEN_PL_PRMRY_CARE_PRVDR_API.delete_pl_prmry_care_prvdr
  (p_validate                       => p_validate
  ,p_pl_pcp_id                      => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'PTY'	then
  BEN_PL_CARE_PRVDR_TYP_API.delete_pl_care_prvdr_typ
  (p_validate                       => p_validate
  ,p_pl_pcp_typ_id                  => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'PRB'	then
  BEN_PLAN_REGULATORY_BODY_API.delete_Plan_Regulatory_body
  (p_validate                       => p_validate
  ,p_pl_regy_bod_id                 => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PRP'	then
  BEN_REGULATORY_PURPOSE_API.delete_regulatory_purpose
  (p_validate                       => p_validate
  ,p_pl_regy_prps_id                => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LGE'	then
  BEN_LER_CHG_PGM_ENRT_API.delete_Ler_Chg_Pgm_Enrt
  (p_validate                       => p_validate
  ,p_ler_chg_pgm_enrt_id            => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PGC'	then
  BEN_PROGRAM_DPNT_CVG_CTFN_API.delete_Program_Dpnt_Cvg_Ctfn
  (p_validate                       => p_validate
  ,p_pgm_dpnt_cvg_ctfn_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EAN'	then
  BEN_ELIG_ASNT_SET_PRTE_API.delete_ELIG_ASNT_SET_PRTE
  (p_validate                       => p_validate
  ,p_elig_asnt_set_prte_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CGP'	then
  BEN_CNTNG_PRTN_ELIG_PRFL_API.delete_CNTNG_PRTN_ELIG_PRFL
  (p_validate                       => p_validate
  ,p_cntng_prtn_elig_prfl_id        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EAP'	then
  BEN_ELIG_AGE_PRTE_API.delete_ELIG_AGE_PRTE
  (p_validate                       => p_validate
  ,p_elig_age_prte_id               => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EBN'	then
  BEN_ELIG_BENFTS_GRP_PRTE_API.delete_ELIG_BENFTS_GRP_PRTE
  (p_validate                       => p_validate
  ,p_elig_benfts_grp_prte_id        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EBU'	then
  BEN_ELIG_BRGNG_UNIT_PRTE_API.delete_ELIG_BRGNG_UNIT_PRTE
  (p_validate                       => p_validate
  ,p_elig_brgng_unit_prte_id        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ECL'	then
  BEN_ELIG_COMP_LVL_PRTE_API.delete_ELIG_COMP_LVL_PRTE
  (p_validate                       => p_validate
  ,p_elig_comp_lvl_prte_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ECP'	then
  BEN_ELIG_CMBN_AGE_LOS_API.delete_ELIG_CMBN_AGE_LOS
  (p_validate                       => p_validate
  ,p_elig_cmbn_age_los_prte_id      => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 'ECV' then
  BEN_ELIGY_CRIT_VALUES_API.delete_eligy_crit_values
  (p_validate                       => p_validate
  ,p_eligy_crit_values_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ECY'	then
  BEN_ELIG_COMPTNCY_PRTE_API.delete_ELIG_COMPTNCY_PRTE
  (p_validate                       => p_validate
  ,p_ELIG_COMPTNCY_PRTE_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ERL'	then
  BEN_ELIGY_PROFILE_RULE_API.delete_ELIGY_PROFILE_RULE
  (p_validate                       => p_validate
  ,p_eligy_prfl_rl_id               => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EHW'	then
  BEN_ELIG_HRS_WKD_PRTE_API.delete_ELIG_HRS_WKD_PRTE
  (p_validate                       => p_validate
  ,p_elig_hrs_wkd_prte_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EJP'	then
  BEN_ELIGY_JOB_PRTE_API.delete_ELIGY_JOB_PRTE
  (p_validate                       => p_validate
  ,p_elig_job_prte_id               => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ELU'	then
  BEN_ELIG_LBR_MMBR_PRTE_API.delete_ELIG_LBR_MMBR_PRTE
  (p_validate                       => p_validate
  ,p_elig_lbr_mmbr_prte_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ELN'	then
  BEN_ELIG_LGL_ENTY_PRTE_API.delete_ELIG_LGL_ENTY_PRTE
  (p_validate                       => p_validate
  ,p_elig_lgl_enty_prte_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ELR'	then
  BEN_ELIG_LOA_RSN_PRTE_API.delete_ELIG_LOA_RSN_PRTE
  (p_validate                       => p_validate
  ,p_elig_loa_rsn_prte_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ELS'	then
  BEN_ELIG_LOS_PRTE_API.delete_ELIG_LOS_PRTE
  (p_validate                       => p_validate
  ,p_elig_los_prte_id               => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ELV'	then
  BEN_ELIG_LVG_RSN_PRTE_API.delete_ELIG_LVG_RSN_PRTE
  (p_validate                       => p_validate
  ,p_elig_lvg_rsn_prte_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EMP'	then
  BEN_ELIG_MRTL_STS_PRTE_API.delete_elig_mrtl_sts_prte
  (p_validate                       => p_validate
  ,p_elig_mrtl_sts_prte_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ENO'	then
  BEN_ELIG_NO_OTHR_CVG_PRTE_API.delete_ELIG_NO_OTHR_CVG_PRTE
  (p_validate                       => p_validate
  ,p_elig_no_othr_cvg_prte_id       => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EOM'	then
  BEN_ELIG_OPTD_MDCR_PRTE_API.delete_ELIG_OPTD_MDCR_PRTE
  (p_validate                       => p_validate
  ,p_elig_optd_mdcr_prte_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EOU'	then
  BEN_ELIG_ORG_UNIT_PRTE_API.delete_ELIG_ORG_UNIT_PRTE
  (p_validate                       => p_validate
  ,p_elig_org_unit_prte_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EPF'	then
  BEN_ELIG_PCT_FL_TM_PRTE_API.delete_ELIG_PCT_FL_TM_PRTE
  (p_validate                       => p_validate
  ,p_elig_pct_fl_tm_prte_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EPT'	then
  BEN_ELIG_PER_TYP_PRTE_API.delete_ELIG_PER_TYP_PRTE
  (p_validate                       => p_validate
  ,p_elig_per_typ_prte_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EPB'	then
  BEN_ELIG_PY_BSS_PRTE_API.delete_ELIG_PY_BSS_PRTE
  (p_validate                       => p_validate
  ,p_elig_py_bss_prte_id            => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EPN'	then
  BEN_ELIG_PRBTN_PERD_PRTE_API.delete_ELIG_PRBTN_PERD_PRTE
  (p_validate                       => p_validate
  ,p_ELIG_PRBTN_PERD_PRTE_id        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EPS'	then
  BEN_ELIG_PSTN_PRTE_API.delete_ELIG_PSTN_PRTE
  (p_validate                       => p_validate
  ,p_ELIG_PSTN_PRTE_id              => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EPY'	then
  BEN_ELIG_PYRL_PRTE_API.delete_ELIG_PYRL_PRTE
  (p_validate                       => p_validate
  ,p_elig_pyrl_prte_id              => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EPZ'	then
  BEN_ELIG_PSTL_CD_RNG_PRTE_API.delete_ELIG_PSTL_CD_RNG_PRTE
  (p_validate                       => p_validate
  ,p_elig_pstl_cd_r_rng_prte_id     => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EQT'	then
  BEN_ELIG_QUAL_TITL_PRTE_API.delete_elig_qual_titl_prte
  (p_validate                       => p_validate
  ,p_elig_qual_titl_prte_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ESA'	then
  BEN_ELIG_SVC_AREA_PRTE_API.delete_elig_svc_area_prte
  (p_validate                       => p_validate
  ,p_elig_svc_area_prte_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ESH'	then
  BEN_ELIG_SCHEDD_HRS_PRTE_API.delete_ELIG_SCHEDD_HRS_PRTE
  (p_validate                       => p_validate
  ,p_elig_schedd_hrs_prte_id        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ESP'	then
  BEN_ELIG_SP_CLNG_PRG_PRTE_API.delete_elig_sp_clng_prg_prte
  (p_validate                       => p_validate
  ,p_elig_sp_clng_prg_prte_id       => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EST'	then
  BEN_ELIG_SUPPL_ROLE_PRTE_API.delete_elig_suppl_role_prte
  (p_validate                       => p_validate
  ,p_elig_suppl_role_prte_id        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EWL'	then
  BEN_ELIG_WK_LOC_PRTE_API.delete_ELIG_WK_LOC_PRTE
  (p_validate                       => p_validate
  ,p_elig_wk_loc_prte_id            => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ECT'	then
  BEN_ELIG_DSBLTY_CTG_PRTE_API.delete_ELIG_dsblty_ctg_PRTE
  (p_validate                       => p_validate
  ,p_elig_dsblty_ctg_prte_id        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EDD'	then
  BEN_ELIG_DSBLTY_DGR_PRTE_API.delete_ELIG_dsblty_dgr_PRTE
  (p_validate                       => p_validate
  ,p_elig_dsblty_dgr_prte_id        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EDR'	then
  BEN_ELIG_DSBLTY_RSN_PRTE_API.delete_elig_dsblty_rsn_prte
  (p_validate                       => p_validate
  ,p_elig_dsblty_rsn_prte_id        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EES'	then
  BEN_ELIG_EE_STAT_PRTE_API.delete_ELIG_EE_STAT_PRTE
  (p_validate                       => p_validate
  ,p_elig_ee_stat_prte_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EFP'	then
  BEN_ELIG_FL_TM_PT_TM_PRTE_API.delete_ELIG_FL_TM_PT_TM_PRTE
  (p_validate                       => p_validate
  ,p_elig_fl_tm_pt_tm_prte_id       => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EGR'	then
  BEN_ELIG_GRD_PRTE_API.delete_ELIG_GRD_PRTE
  (p_validate                       => p_validate
  ,p_elig_grd_prte_id               => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EHS'	then
  BEN_ELIG_HRLY_SLRD_PRTE_API.delete_ELIG_HRLY_SLRD_PRTE
  (p_validate                       => p_validate
  ,p_elig_hrly_slrd_prte_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ERG'	then
  BEN_ELIG_PERF_RTNG_PRTE_API.delete_ELIG_PERF_RTNG_PRTE
  (p_validate                       => p_validate
  ,p_ELIG_PERF_RTNG_PRTE_id                => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EQG'	then
  BEN_ELIG_QUA_IN_GR_PRTE_API.delete_ELIG_QUA_IN_GR_PRTE
  (p_validate                       => p_validate
  ,p_ELIG_QUA_IN_GR_PRTE_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EGN'	then
  BEN_ELIG_GNDR_PRTE_API.delete_elig_gndr_prte
  (p_validate                       => p_validate
  ,p_elig_gndr_prte_id              => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ETU'	then
  BEN_ELIG_TBCO_USE_PRTE_API.delete_ELIG_TBCO_USE_PRTE
  (p_validate                       => p_validate
  ,p_elig_tbco_use_prte_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EDB'	then
  BEN_ELIG_DSBLD_PRTE_API.delete_ELIG_DSBLD_PRTE
  (p_validate                       => p_validate
  ,p_elig_dsbld_prte_id             => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ETP'	then
  BEN_ELIG_TTL_PRTT_PRTE_API.delete_ELIG_TTL_PRTT_PRTE
  (p_validate                       => p_validate
  ,p_ELIG_TTL_PRTT_PRTE_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ETC'	then
  BEN_ELIG_TTL_CVG_VOL_PRTE_API.delete_elig_ttl_cvg_vol_prte
  (p_validate                       => p_validate
  ,p_elig_ttl_cvg_vol_prte_id       => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ECQ'	then
  BEN_ELIG_CBR_QUALD_BNF_API.delete_ELIG_CBR_QUALD_BNF
  (p_validate                       => p_validate
  ,p_elig_cbr_quald_bnf_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EDG'	then
  BEN_ELIG_DPNT_CVRD_O_PGM_API.delete_ELIG_DPNT_CVRD_O_PGM
  (p_validate                       => p_validate
  ,p_elig_dpnt_cvrd_othr_pgm_id     => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EDI'	then
  BEN_ELIG_DPNT_CVRD_PLIP_API.delete_ELIG_DPNT_CVRD_PLIP
  (p_validate                       => p_validate
  ,p_elig_dpnt_cvrd_plip_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EDP'	then
  BEN_ELIG_DPNT_CVD_OTHR_PL_API.delete_ELIG_DPNT_CVD_OTHR_PL
  (p_validate                       => p_validate
  ,p_elig_dpnt_cvrd_othr_pl_id      => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EDT'	then
  BEN_ELIG_DPNT_CVRD_O_PTIP_API.delete_ELIG_DPNT_CVRD_O_PTIP
  (p_validate                       => p_validate
  ,p_elig_dpnt_cvrd_othr_ptip_id    => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EOY'	then
  BEN_ELIG_OTHR_PTIP_PRTE_API.delete_ELIG_OTHR_PTIP_PRTE
  (p_validate                       => p_validate
  ,p_elig_othr_ptip_prte_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EPG'	then
  BEN_ELIG_PPL_GRP_PRTE_API.delete_ELIG_PPL_GRP_PRTE
  (p_validate                       => p_validate
  ,p_elig_ppl_grp_prte_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EPP'	then
  BEN_ELG_PRT_ANTHR_PL_PT_API.delete_ELG_PRT_ANTHR_PL_PT
  (p_validate                       => p_validate
  ,p_elig_prtt_anthr_pl_prte_id     => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ETD'	then
  BEN_ELIG_DPNT_OTHR_PTIP_API.delete_ELIG_DPNT_OTHR_PTIP
  (p_validate                       => p_validate
  ,p_elig_dpnt_othr_ptip_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EEI'	then
  BEN_ELIG_ENRLD_ANTHR_OIPL_API.delete_ELIG_ENRLD_ANTHR_OIPL
  (p_validate                       => p_validate
  ,p_elig_enrld_anthr_oipl_id       => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EEG'	then
  BEN_ELIG_ENRLD_ANTHR_PGM_API.delete_ELIG_ENRLD_ANTHR_PGM
  (p_validate                       => p_validate
  ,p_elig_enrld_anthr_pgm_id        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EAI'	then
  BEN_ELIG_ENRLD_ANTHR_PLIP_API.delete_ELIG_ENRLD_ANTHR_PLIP
  (p_validate                       => p_validate
  ,p_elig_enrld_anthr_plip_id       => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EEP'	then
  BEN_ELIG_ENRLD_ANTHR_PL_API.delete_ELIG_ENRLD_ANTHR_PL
  (p_validate                       => p_validate
  ,p_elig_enrld_anthr_pl_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EET'	then
  BEN_ELIG_ENRLD_ANTHR_PTIP_API.delete_ELIG_ENRLD_ANTHR_PTIP
  (p_validate                       => p_validate
  ,p_elig_enrld_anthr_ptip_id       => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EHC'	then
  BEN_ELIG_HLTH_CVG_PRTE_API.delete_ELIG_HLTH_CVG_PRTE
  (p_validate                       => p_validate
  ,p_ELIG_HLTH_CVG_PRTE_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EOP'	then
  BEN_ELIG_ANTHR_PL_PRTE_API.delete_ELIG_ANTHR_PL_PRTE
  (p_validate                       => p_validate
  ,p_ELIG_ANTHR_PL_PRTE_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CTU'	then
  BEN_CM_TYP_USG_API.delete_cm_typ_usg
  (p_validate                       => p_validate
  ,p_cm_typ_usg_id                  => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CTT'	then
  BEN_CM_TYP_TRGR_API.delete_cm_typ_trgr
  (p_validate                       => p_validate
  ,p_cm_typ_trgr_id                 => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CMT'	then
  BEN_COMM_DLVRY_MTHDS_API.delete_Comm_Dlvry_Mthds
  (p_validate                       => p_validate
  ,p_cm_dlvry_mthd_typ_id           => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'CMD'	then
  BEN_COMM_DLVRY_MEDIA_API.delete_Comm_Dlvry_Media
  (p_validate                       => p_validate
  ,p_cm_dlvry_med_typ_id            => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'CCM'	then
  BEN_CVG_AMT_CALC_API.delete_Cvg_Amt_Calc
  (p_validate                       => p_validate
  ,p_cvg_amt_calc_mthd_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'APR'	then
  BEN_ACTUAL_PREMIUM_API.delete_actual_premium
  (p_validate                       => p_validate
  ,p_actl_prem_id                   => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ABR'	then
  BEN_ACTY_BASE_RATE_API.delete_acty_base_rate
  (p_validate                       => p_validate
  ,p_acty_base_rt_id                => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EIV'	then
  BEN_EXTRA_INPUT_VALUE_API.delete_extra_input_value
  (p_validate                       => p_validate
  ,p_extra_input_value_id           => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'APF'	then
  BEN_ACTY_RT_PYMT_SCHED_API.delete_acty_rt_pymt_sched
  (p_validate                       => p_validate
  ,p_acty_rt_pymt_sched_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PSQ'	then
  BEN_PYMT_SCHED_PY_FREQ_API.delete_pymt_sched_py_freq
  (p_validate                       => p_validate
  ,p_pymt_sched_py_freq_id          => p_pk_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  );
elsif p_table_alias = 		'ABC'	then
  BEN_ACTY_BASE_RT_CTFN_API.delete_Acty_Base_Rt_Ctfn
  (p_validate                       => p_validate
  ,p_acty_base_rt_ctfn_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'MTR'	then
  BEN_MATCHING_RATES_API.delete_MATCHING_RATES
  (p_validate                       => p_validate
  ,p_mtchg_rt_id                    => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'APL1' 	then
  BEN_ACTY_RT_PTD_LMT_API.delete_ACTY_RT_PTD_LMT
  (p_validate                       => p_validate
  ,p_acty_rt_ptd_lmt_id             => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'VPF'	then
  BEN_VRBL_RATE_PROFILE_API.delete_vrbl_rate_profile
  (p_validate                       => p_validate
  ,p_vrbl_rt_prfl_id                => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'AVR'	then
  BEN_ACTY_VRBL_RATE_API.delete_acty_vrbl_rate
  (p_validate                       => p_validate
  ,p_acty_vrbl_rt_id                => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PMRPV'	then
  BEN_PRTL_MO_RT_PRTN_VAL_API.delete_Prtl_Mo_Rt_Prtn_Val
  (p_validate                       => p_validate
  ,p_prtl_mo_rt_prtn_val_id         => p_pk_id
  ,p_effective_end_date             => p_effective_end_date
  ,p_effective_start_date           => p_effective_start_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'BVR1' 	then
  BEN_BNFT_VRBL_RT_API.delete_bnft_vrbl_rt
  (p_validate                       => p_validate
  ,p_bnft_vrbl_rt_id                => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'BRR'	then
  BEN_BNFT_VRBL_RT_RL_API.delete_bnft_vrbl_rt_rl
  (p_validate                       => p_validate
  ,p_bnft_vrbl_rt_rl_id             => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'APV'	then
  BEN_ACTUAL_PREMIUM_RATE_API.delete_actual_premium_rate
  (p_validate                       => p_validate
  ,p_actl_prem_vrbl_rt_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'AVA'	then
  BEN_ACTUAL_PREMIUM_RULE_API.delete_actual_premium_rule
  (p_validate                       => p_validate
  ,p_actl_prem_vrbl_rt_rl_id        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'DCR'	then
  BEN_DPNT_CVG_RQD_RLSHP_API.delete_DPNT_CVG_RQD_RLSHP
  (p_validate                       => p_validate
  ,p_dpnt_cvg_rqd_rlshp_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'DEC'	then
  BEN_DSGNTR_ENRLD_CVG_API.delete_DSGNTR_ENRLD_CVG
  (p_validate                       => p_validate
  ,p_dsgntr_enrld_cvg_id            => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EAC'	then
  BEN_ELIG_AGE_CVG_API.delete_ELIG_AGE_CVG
  (p_validate                       => p_validate
  ,p_elig_age_cvg_id                => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EDC'	then
  BEN_ELIG_DSBLD_STAT_CVG_API.delete_ELIG_DSBLD_STAT_CVG
  (p_validate                       => p_validate
  ,p_elig_dsbld_stat_cvg_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EMC'	then
  BEN_ELIG_MLTRY_STAT_CVG_API.delete_Elig_Mltry_Stat_Cvg
  (p_validate                       => p_validate
  ,p_elig_mltry_stat_cvg_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EMS'	then
  BEN_ELIG_MRTL_STAT_CVG_API.delete_Elig_Mrtl_Stat_Cvg
  (p_validate                       => p_validate
  ,p_elig_mrtl_stat_cvg_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EPL'	then
  BEN_ELIG_PSTL_CD_CVG_API.delete_ELIG_PSTL_CD_CVG
  (p_validate                       => p_validate
  ,p_elig_pstl_cd_r_rng_cvg_id      => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ESC'	then
  BEN_ELIG_STDNT_STAT_CVG_API.delete_ELIG_STDNT_STAT_CVG
  (p_validate                       => p_validate
  ,p_elig_stdnt_stat_cvg_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'VEP'	then
  BEN_VRBL_RT_ELIG_PRFL_API.delete_vrbl_rt_elig_prfl
  (p_validate                       => p_validate
  ,p_vrbl_rt_elig_prfl_id           => p_pk_id
  ,p_vrbl_rt_prfl_id                => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ABP'	then
  BEN_APLCN_TO_BENEFIT_POOL_API.delete_Aplcn_To_Benefit_Pool
  (p_validate                       => p_validate
  ,p_aplcn_to_bnft_pool_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'BPR1' 	then
  BEN_BNFT_POOL_RLOVR_RQMT_API.delete_Bnft_Pool_Rlovr_Rqmt
  (p_validate                       => p_validate
  ,p_bnft_pool_rlovr_rqmt_id        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'DPC'	then
  BEN_DPNT_CVD_ANTHR_PL_CVG_API.delete_DPNT_CVD_ANTHR_PL_CVG
  (p_validate                       => p_validate
  ,p_dpnt_cvrd_anthr_pl_cvg_id      => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CTY'	then
  BEN_COMPTNCY_RT_API.delete_comptncy_rt
  (p_validate                       => p_validate
  ,p_comptncy_rt_id                 => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'JRT'	then
  BEN_JOB_RT_API.delete_JOB_RT
  (p_validate                       => p_validate
  ,p_job_rt_id                      => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'HSR'	then
  BEN_HRLY_SALARY_RATE_API.delete_HRLY_SALARY_RATE
  (p_validate                       => p_validate
  ,p_hrly_slrd_rt_id                => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'GRR'	then
  BEN_GRADE_RATE_API.delete_GRADE_RATE
  (p_validate                       => p_validate
  ,p_grade_rt_id                    => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'FTR'	then
  BEN_FULL_PRT_TIME_RATE_API.delete_FULL_PRT_TIME_RATE
  (p_validate                       => p_validate
  ,p_fl_tm_pt_tm_rt_id              => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'BUR'	then
  BEN_BARGAINING_UNIT_RT_API.delete_BARGAINING_UNIT_RT
  (p_validate                       => p_validate
  ,p_brgng_unit_rt_id               => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ESR'	then
  BEN_EMPLOYEE_STATUS_RT_API.delete_EMPLOYEE_STATUS_RT
  (p_validate                       => p_validate
  ,p_ee_stat_rt_id                  => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ASR'	then
  BEN_ASSIGNMENT_SET_RATE_API.delete_ASSIGNMENT_SET_RATE
  (p_validate                       => p_validate
  ,p_asnt_set_rt_id                 => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'TUR'	then
  BEN_TOBACCO_USE_RATE_API.delete_TOBACCO_USE_RATE
  (p_validate                       => p_validate
  ,p_tbco_use_rt_id                 => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'SAR'	then
  BEN_SERVICE_AREA_RATE_API.delete_service_area_rate
  (p_validate                       => p_validate
  ,p_svc_area_rt_id                 => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'QTR'	then
  BEN_QUAL_TITL_RT_API.delete_qual_titl_rt
  (p_validate                       => p_validate
  ,p_qual_titl_rt_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PZR'	then
  BEN_POSTAL_ZIP_RATE_API.delete_POSTAL_ZIP_RATE
  (p_validate                       => p_validate
  ,p_pstl_zip_rt_id                 => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PTR'	then
  BEN_PERSON_TYPE_RATE_API.delete_PERSON_TYPE_RATE
  (p_validate                       => p_validate
  ,p_per_typ_rt_id                  => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'GNR'	then
  BEN_GENDER_RATE_API.delete_GENDER_RATE
  (p_validate                       => p_validate
  ,p_gndr_rt_id                     => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'DBR'	then
  BEN_DSBLD_RT_API.delete_DSBLD_RT
  (p_validate                       => p_validate
  ,p_dsbld_rt_id                    => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LMM'	then
  BEN_LABOR_MEMBER_RATE_API.delete_LABOR_MEMBER_RATE
  (p_validate                       => p_validate
  ,p_lbr_mmbr_rt_id                 => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LAR'	then
  BEN_LOA_REASON_RATE_API.delete_LOA_REASON_RATE
  (p_validate                       => p_validate
  ,p_loa_rsn_rt_id                  => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'OUR'	then
  BEN_ORG_UNIT_RATE_API.delete_ORG_UNIT_RATE
  (p_validate                       => p_validate
  ,p_org_unit_rt_id                 => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LER1' 	then
  BEN_LEGAL_ENTITY_RATE_API.delete_LEGAL_ENTITY_RATE
  (p_validate                       => p_validate
  ,p_lgl_enty_rt_id                 => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PR_' 	then
  BEN_PAYROLL_RATE_API.delete_PAYROLL_RATE
  (p_validate                       => p_validate
  ,p_pyrl_rt_id                     => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PBR'	then
  BEN_PAY_BASIS_RATE_API.delete_PAY_BASIS_RATE
  (p_validate                       => p_validate
  ,p_py_bss_rt_id                   => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'BRG'	then
  BEN_BENEFIT_GRP_RATE_API.delete_BENEFIT_GRP_RATE
  (p_validate                       => p_validate
  ,p_benfts_grp_rt_id               => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CMR'	then
  BEN_CMBN_AGE_LOS_RT_API.delete_CMBN_AGE_LOS_RT
  (p_validate                       => p_validate
  ,p_cmbn_age_los_rt_id             => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'VMR'	then
  BEN_VRBL_MATCHING_RATE_API.delete_VRBL_MATCHING_RATE
  (p_validate                       => p_validate
  ,p_vrbl_mtchg_rt_id               => p_pk_id
  ,p_effective_end_date             => p_effective_end_date
  ,p_effective_start_date           => p_effective_start_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'NOC'	then
  BEN_NO_OTHR_CVG_RT_API.delete_NO_OTHR_CVG_RT
  (p_validate                       => p_validate
  ,p_no_othr_cvg_rt_id       => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'OMR'	then
  BEN_OPTD_MDCR_RT_API.delete_OPTD_MDCR_RT
  (p_validate                       => p_validate
  ,p_OPTD_MDCR_RT_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'TTP'	then
  BEN_TTL_PRTT_RT_API.delete_ttl_prtt_rt
  (p_validate                       => p_validate
  ,p_ttl_prtt_rt_id                 => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'TCV'	then
  BEN_TTL_CVG_VOL_RT_API.delete_ttl_cvg_vol_rt
  (p_validate                       => p_validate
  ,p_ttl_cvg_vol_rt_id              => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'VPR'	then
  BEN_VRBL_RT_PRFL_RULE_API.delete_VRBL_RT_PRFL_RULE
  (p_validate                       => p_validate
  ,p_vrbl_rt_prfl_rl_id             => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PRT'	then
  BEN_POE_RT_API.delete_POE_RT
  (p_validate                       => p_validate
  ,p_poe_rt_id                      => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CPN'	then
  BEN_CNTNG_PRTN_PRFL_RT_API.delete_cntng_prtn_prfl_rt
  (p_validate                       => p_validate
  ,p_cntng_prtn_prfl_rt_id        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PST'	then
  BEN_PSTN_RT_API.delete_PSTN_RT
  (p_validate                       => p_validate
  ,p_PSTN_RT_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'WLR'	then
  BEN_WORK_LOC_RATE_API.delete_WORK_LOC_RATE
  (p_validate                       => p_validate
  ,p_wk_loc_rt_id                   => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PFR'	then
  BEN_PCT_FULL_TIME_RATE_API.delete_PCT_FULL_TIME_RATE
  (p_validate                       => p_validate
  ,p_pct_fl_tm_rt_id                => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'HWR'	then
  BEN_HRS_WKD_IN_PERIOD_RT_API.delete_HRS_WKD_IN_PERIOD_RT
  (p_validate                       => p_validate
  ,p_hrs_wkd_in_perd_rt_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CLR'	then
  BEN_COMP_LEVEL_RATE_API.delete_COMP_LEVEL_RATE
  (p_validate                       => p_validate
  ,p_comp_lvl_rt_id                 => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LSR'	then
  BEN_LENGTH_OF_SVC_RATE_API.delete_LENGTH_OF_SVC_RATE
  (p_validate                       => p_validate
  ,p_los_rt_id                      => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'LRN'	then
  BEN_LVG_RSN_RT_API.delete_lvg_rsn_rt
  (p_validate                       => p_validate
  ,p_lvg_rsn_rt_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ART'	then
  BEN_AGE_RATES_API.delete_age_rates
  (p_validate                       => p_validate
  ,p_age_rt_id                      => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'SHR'	then
  BEN_SCHEDD_HRS_RATE_API.delete_SCHEDD_HRS_RATE
  (p_validate                       => p_validate
  ,p_schedd_hrs_rt_id               => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'QIG'	then
  BEN_QUA_IN_GR_RT_API.delete_QUA_IN_GR_RT
  (p_validate                       => p_validate
  ,p_qua_in_gr_rt_id                      => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PRR'	then
  BEN_PERF_RTNG_RT_API.delete_perf_rtng_rt
  (p_validate                       => p_validate
  ,p_perf_rtng_rt_id                => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'CQR'	then
  BEN_CBR_QUALD_BNF_RT_API.delete_cbr_quald_bnf_rt
  (p_validate                       => p_validate
  ,p_cbr_quald_bnf_rt_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PAP'	then
  BEN_PRTT_ANTHR_PL_RT_API.delete_PRTT_ANTHR_PL_RT
  (p_validate                       => p_validate
  ,p_prtt_anthr_pl_rt_id     => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'OPR'	then
  BEN_OTHR_PTIP_RT_API.delete_OTHR_PTIP_RT
  (p_validate                       => p_validate
  ,p_othr_ptip_rt_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ENT'	then
  BEN_ENRLD_ANTHR_PTIP_RT_API.delete_ENRLD_ANTHR_PTIP_RT
  (p_validate                       => p_validate
  ,p_enrld_anthr_ptip_rt_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'ENL'	then
  BEN_ENRLD_ANTHR_PL_RT_API.delete_ENRLD_ANTHR_PL_RT
  (p_validate                       => p_validate
  ,p_enrld_anthr_pl_rt_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EAR'	then
   BEN_ENRLD_ANTHR_PLIP_RT_API.delete_ENRLD_ANTHR_PLIP_RT
  (p_validate                       => p_validate
  ,p_enrld_anthr_plip_rt_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EAO'	then
  BEN_ENRLD_ANTHR_OIPL_RT_API.delete_ENRLD_ANTHR_OIPL_RT
  (p_validate                       => p_validate
  ,p_enrld_anthr_oipl_rt_id         => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'DOT'	then
  BEN_DPNT_OTHR_PTIP_RT_API.delete_DPNT_OTHR_PTIP_RT
  (p_validate                       => p_validate
  ,p_dpnt_othr_ptip_rt_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'DOP'	then
  BEN_DPNT_CVRD_OTHR_PGM_RT_API.delete_DPNT_CVRD_OTHR_PGM_RT
  (p_validate                       => p_validate
  ,p_dpnt_cvrd_othr_pgm_rt_id       => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'DCP'	then
  BEN_DPNT_CVRD_PLIP_RT_API.delete_DPNT_CVRD_PLIP_RT
  (p_validate                       => p_validate
  ,p_dpnt_cvrd_plip_rt_id           => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'DCO'	then
  BEN_DPNT_CVD_O_PTIP_RT_API.delete_DPNT_CVD_O_PTIP_RT
  (p_validate                       => p_validate
  ,p_dpnt_cvrd_othr_ptip_rt_id      => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'DCL'	then
  BEN_DPNT_CVRD_OTHR_PL_RT_API.delete_DPNT_CVRD_OTHR_PL_RT
  (p_validate                       => p_validate
  ,p_dpnt_cvrd_othr_pl_rt_id        => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'EPM'	then
  BEN_ENRLD_ANTHR_PGM_RT_API.delete_ENRLD_ANTHR_PGM_RT
  (p_validate                       => p_validate
  ,p_enrld_anthr_pgm_rt_id          => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
elsif p_table_alias = 		'PGR'	then
  BEN_PEOPLE_GROUP_RATE_API.delete_PEOPLE_GROUP_RATE
  (p_validate                       => p_validate
  ,p_ppl_grp_rt_id                  => p_pk_id
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  ,p_object_version_number          => p_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_datetrack_mode                 => p_datetrack_mode
  );
end if;
  hr_utility.set_location('Leaving: '||l_proc || ' for ' || p_table_alias || ' p_pk_id: ' ||p_pk_id ,20);
exception
   when OTHERS THEN
     hr_utility.set_location('Delete failed for: '|| p_table_alias || ' primary key: '||p_pk_id ,30);
     --NOTIFY
      p_delete_failed := 'Y';
      l_encoded_message := fnd_message.get;
      if(p_parent_entity_name is null or p_parent_entity_name = p_entity_name) then
      fnd_message.set_name('BEN', 'BEN_94154_PDW_DELETE_FAILED');
      fnd_message.set_token('NAME', p_entity_name );
      fnd_message.set_token('MESSAGE', l_encoded_message);
      fnd_message.raise_error;
      else
      fnd_message.set_name('BEN', 'BEN_94160_PDW_DELETE_FAILED');
      fnd_message.set_token('NAME', p_parent_entity_name );
      fnd_message.set_token('CHILD', p_entity_name );
      fnd_message.set_token('MESSAGE',l_encoded_message);
      fnd_message.raise_error;
      end if;
end call_delete_api;

-- p_validate 0 means false

procedure call_delete_apis
( p_process_validate in Number default 0
 ,p_copy_entity_txn_id in Number
 ,p_delete_failed out nocopy varchar2
) is

cursor c_copy_entity_txn is
  select  cet.src_effective_date  effective_date
  from    pqh_copy_entity_txns cet
  where   cet.copy_entity_txn_id = p_copy_entity_txn_id;


cursor c_deleted_rows(p_effective_date date) is
  select table_alias, datetrack_mode p_datetrack_mode, information1 p_pk_id, information2 p_effective_start_date, information3 p_effective_end_date,information5 entity_name, information265 p_object_version_number from ben_copy_entity_results
  where copy_entity_txn_id = p_copy_entity_txn_id
  and dml_operation = 'DELETE'
  and p_effective_date between nvl(information2,p_effective_date) and nvl(information3,p_effective_date)
  group by order_in_hierarchy,table_alias,order_in_group,information1,datetrack_mode,information2,information3,information5, information265
  order by order_in_hierarchy desc, order_in_group desc ;

  l_effective_date pqh_copy_entity_txns.src_effective_date%type;
  l_date_to_use pqh_copy_entity_txns.src_effective_date%type;
  l_proc varchar2(72) := g_package||'call_delete_apis';
  l_datetrack_mode ben_copy_entity_results.datetrack_mode%type;

begin
  hr_utility.set_location('Entering: '||l_proc,10);
 open  c_copy_entity_txn;
    fetch c_copy_entity_txn into l_effective_date;
 close c_copy_entity_txn;

 for l_deleted_rows in c_deleted_rows(l_effective_date)  loop
  -- if we are tryin to delete on the day entity was created, it needs to be purged
    if(l_effective_date = l_deleted_rows.p_effective_start_date) then
       l_datetrack_mode := hr_api.g_zap;
       l_date_to_use := l_effective_date;
      else
    -- for plan design wizard we want to end date deleted rows a day before
       l_datetrack_mode := l_deleted_rows.p_datetrack_mode;
       l_date_to_use := l_effective_date -1;
    end if;

     call_delete_api
     ( p_process_validate       => p_process_validate
     , p_pk_id                  => l_deleted_rows.p_pk_id
     , p_table_alias            => l_deleted_rows.table_alias
     , p_effective_date         => l_date_to_use
     , p_effective_start_date   => l_deleted_rows.p_effective_start_date
     , p_effective_end_date     => l_deleted_rows.p_effective_end_date
     , p_object_version_number  => l_deleted_rows.p_object_version_number
     , p_datetrack_mode         => l_datetrack_mode
     , p_parent_entity_name     => null
     , p_entity_name            => l_deleted_rows.entity_name
     , p_delete_failed          => p_delete_failed
     );

  end loop;
  hr_utility.set_location('Leaving: '||l_proc,20);
end call_delete_apis;


procedure call_delete_apis_for_hierarchy
( p_process_validate in Number default 0
 ,p_copy_entity_txn_id in Number
 ,p_parent_entity_result_id in varchar2
 ,p_delete_failed out nocopy varchar2
) is
cursor c_copy_entity_txn is
  select  cet.src_effective_date  effective_date
  from    pqh_copy_entity_txns cet
  where   cet.copy_entity_txn_id = p_copy_entity_txn_id;

-- we need to call delete api for all the dependents and the parent row itself.
cursor c_deleted_rows(p_effective_date date) is
  select table_alias, datetrack_mode p_datetrack_mode, information1 p_pk_id, information2 p_effective_start_date, information3 p_effective_end_date,information5 entity_name, information265 p_object_version_number from ben_copy_entity_results
  where( copy_entity_txn_id = p_copy_entity_txn_id
  and pd_parent_entity_result_id = p_parent_entity_result_id
  and dml_operation = 'DELETE'
  and p_effective_date between nvl(information2,p_effective_date) and nvl(information3,p_effective_date))
  or
  copy_entity_result_id = p_parent_entity_result_id
  group by order_in_hierarchy,table_alias,order_in_group,information1,datetrack_mode,information2,information3,information5, information265
  order by order_in_hierarchy desc, order_in_group desc ;

cursor c_parent_entity_name is
  select information5 parent_entity_name from ben_copy_entity_results
  where copy_entity_result_id = p_parent_entity_result_id;

  l_effective_date pqh_copy_entity_txns.src_effective_date%type;
  l_date_to_use pqh_copy_entity_txns.src_effective_date%type;
  l_proc varchar2(72) := g_package||'call_delete_apis_for_hierarchy';
  l_datetrack_mode ben_copy_entity_results.datetrack_mode%type;
  l_parent_entity_name ben_copy_entity_results.information5%type;
begin
  hr_utility.set_location('Entering: '||l_proc,10);
 open  c_copy_entity_txn;
    fetch c_copy_entity_txn into l_effective_date;
 close c_copy_entity_txn;
 open c_parent_entity_name;
    fetch c_parent_entity_name into l_parent_entity_name;
 close c_parent_entity_name;


 for l_deleted_rows in c_deleted_rows(l_effective_date)  loop
  -- if we are tryin to delete on the day entity was created, it needs to be purged
    if( l_effective_date = l_deleted_rows.p_effective_start_date) then
       l_datetrack_mode := hr_api.g_zap;
       l_date_to_use := l_effective_date;
      else
    -- for plan design wizard we want to end date deleted rows a day before
       l_datetrack_mode := l_deleted_rows.p_datetrack_mode;
       l_date_to_use := l_effective_date -1;
    end if;

     call_delete_api
     ( p_process_validate       => p_process_validate
     , p_pk_id                  => l_deleted_rows.p_pk_id
     , p_table_alias            => l_deleted_rows.table_alias
     , p_effective_date         => l_date_to_use
     , p_effective_start_date   => l_deleted_rows.p_effective_start_date
     , p_effective_end_date     => l_deleted_rows.p_effective_end_date
     , p_object_version_number  => l_deleted_rows.p_object_version_number
     , p_datetrack_mode         => l_datetrack_mode
     , p_parent_entity_name     => l_parent_entity_name
     , p_entity_name            => l_deleted_rows.entity_name
     , p_delete_failed          => p_delete_failed
     );

  end loop;
  hr_utility.set_location('Leaving: '||l_proc,20);
end call_delete_apis_for_hierarchy;

end ben_plan_design_delete_api;


/
