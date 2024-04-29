--------------------------------------------------------
--  DDL for Package BEN_MANAGE_UNRES_LIFE_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_MANAGE_UNRES_LIFE_EVENTS" AUTHID CURRENT_USER as
/* $Header: bebmures.pkh 120.2 2006/04/04 04:22:22 ssarkar noship $ */
--
type g_unrest_epe_inst_row is record
  (
   FONM_CVG_STRT_DT              BEN_ELIG_PER_ELCTBL_CHC.FONM_CVG_STRT_DT%TYPE
  ,PGM_ID                        BEN_ELIG_PER_ELCTBL_CHC.PGM_ID%TYPE
  ,PL_ID                         BEN_ELIG_PER_ELCTBL_CHC.PL_ID%TYPE
  ,PL_TYP_ID                     BEN_ELIG_PER_ELCTBL_CHC.PL_TYP_ID%TYPE
  ,PLIP_ID                       BEN_ELIG_PER_ELCTBL_CHC.PLIP_ID%TYPE
  ,PTIP_ID                       BEN_ELIG_PER_ELCTBL_CHC.PTIP_ID%TYPE
  ,ENRT_CVG_STRT_DT_CD           BEN_ELIG_PER_ELCTBL_CHC.ENRT_CVG_STRT_DT_CD%TYPE
  ,ENRT_CVG_STRT_DT_RL           BEN_ELIG_PER_ELCTBL_CHC.ENRT_CVG_STRT_DT_RL%TYPE
  ,PRTT_ENRT_RSLT_ID             BEN_ELIG_PER_ELCTBL_CHC.PRTT_ENRT_RSLT_ID%TYPE
  ,DPNT_CVG_STRT_DT_CD           BEN_ELIG_PER_ELCTBL_CHC.DPNT_CVG_STRT_DT_CD%TYPE
  ,DPNT_CVG_STRT_DT_RL           BEN_ELIG_PER_ELCTBL_CHC.DPNT_CVG_STRT_DT_RL%TYPE
  ,ENRT_CVG_STRT_DT              BEN_ELIG_PER_ELCTBL_CHC.ENRT_CVG_STRT_DT%TYPE
  ,DPNT_DSGN_CD                  BEN_ELIG_PER_ELCTBL_CHC.DPNT_DSGN_CD%TYPE
  ,LER_CHG_DPNT_CVG_CD           BEN_ELIG_PER_ELCTBL_CHC.LER_CHG_DPNT_CVG_CD%TYPE
  ,ERLST_DEENRT_DT               BEN_ELIG_PER_ELCTBL_CHC.ERLST_DEENRT_DT%TYPE
  ,PROCG_END_DT                  BEN_ELIG_PER_ELCTBL_CHC.PROCG_END_DT%TYPE
  ,CRYFWD_ELIG_DPNT_CD           BEN_ELIG_PER_ELCTBL_CHC.CRYFWD_ELIG_DPNT_CD%TYPE
  ,ELIG_FLAG                     BEN_ELIG_PER_ELCTBL_CHC.ELIG_FLAG%TYPE
  ,ELIG_OVRID_DT                 BEN_ELIG_PER_ELCTBL_CHC.ELIG_OVRID_DT%TYPE
  ,ELIG_OVRID_PERSON_ID          BEN_ELIG_PER_ELCTBL_CHC.ELIG_OVRID_PERSON_ID%TYPE
  ,INELIG_RSN_CD                 BEN_ELIG_PER_ELCTBL_CHC.INELIG_RSN_CD%TYPE
  ,MGR_OVRID_DT                  BEN_ELIG_PER_ELCTBL_CHC.MGR_OVRID_DT%TYPE
  ,MGR_OVRID_PERSON_ID           BEN_ELIG_PER_ELCTBL_CHC.MGR_OVRID_PERSON_ID%TYPE
  ,WS_MGR_ID                     BEN_ELIG_PER_ELCTBL_CHC.WS_MGR_ID%TYPE
  ,ASSIGNMENT_ID                 BEN_ELIG_PER_ELCTBL_CHC.ASSIGNMENT_ID%TYPE
  ,ROLL_CRS_FLAG                 BEN_ELIG_PER_ELCTBL_CHC.ROLL_CRS_FLAG%TYPE
  ,CRNTLY_ENRD_FLAG              BEN_ELIG_PER_ELCTBL_CHC.CRNTLY_ENRD_FLAG%TYPE
  ,DFLT_FLAG                     BEN_ELIG_PER_ELCTBL_CHC.DFLT_FLAG%TYPE
  ,ELCTBL_FLAG                   BEN_ELIG_PER_ELCTBL_CHC.ELCTBL_FLAG%TYPE
  ,MNDTRY_FLAG                   BEN_ELIG_PER_ELCTBL_CHC.MNDTRY_FLAG%TYPE
  ,ALWS_DPNT_DSGN_FLAG           BEN_ELIG_PER_ELCTBL_CHC.ALWS_DPNT_DSGN_FLAG%TYPE
  ,COMP_LVL_CD                   BEN_ELIG_PER_ELCTBL_CHC.COMP_LVL_CD%TYPE
  ,AUTO_ENRT_FLAG                BEN_ELIG_PER_ELCTBL_CHC.AUTO_ENRT_FLAG%TYPE
  ,CTFN_RQD_FLAG                 BEN_ELIG_PER_ELCTBL_CHC.CTFN_RQD_FLAG%TYPE
  ,PER_IN_LER_ID                 BEN_ELIG_PER_ELCTBL_CHC.PER_IN_LER_ID%TYPE
  ,YR_PERD_ID                    BEN_ELIG_PER_ELCTBL_CHC.YR_PERD_ID%TYPE
  ,OIPLIP_ID                     BEN_ELIG_PER_ELCTBL_CHC.OIPLIP_ID%TYPE
  ,PL_ORDR_NUM                   BEN_ELIG_PER_ELCTBL_CHC.PL_ORDR_NUM%TYPE
  ,PLIP_ORDR_NUM                 BEN_ELIG_PER_ELCTBL_CHC.PLIP_ORDR_NUM%TYPE
  ,PTIP_ORDR_NUM                 BEN_ELIG_PER_ELCTBL_CHC.PTIP_ORDR_NUM%TYPE
  ,OIPL_ORDR_NUM                 BEN_ELIG_PER_ELCTBL_CHC.OIPL_ORDR_NUM%TYPE
  ,MUST_ENRL_ANTHR_PL_ID         BEN_ELIG_PER_ELCTBL_CHC.MUST_ENRL_ANTHR_PL_ID%TYPE
  ,SPCL_RT_PL_ID                 BEN_ELIG_PER_ELCTBL_CHC.SPCL_RT_PL_ID%TYPE
  ,SPCL_RT_OIPL_ID               BEN_ELIG_PER_ELCTBL_CHC.SPCL_RT_OIPL_ID%TYPE
  ,BNFT_PRVDR_POOL_ID            BEN_ELIG_PER_ELCTBL_CHC.BNFT_PRVDR_POOL_ID%TYPE
  ,CMBN_PTIP_ID                  BEN_ELIG_PER_ELCTBL_CHC.CMBN_PTIP_ID%TYPE
  ,CMBN_PTIP_OPT_ID              BEN_ELIG_PER_ELCTBL_CHC.CMBN_PTIP_OPT_ID%TYPE
  ,CMBN_PLIP_ID                  BEN_ELIG_PER_ELCTBL_CHC.CMBN_PLIP_ID%TYPE
  ,OIPL_ID                       BEN_ELIG_PER_ELCTBL_CHC.OIPL_ID%TYPE
  ,APPROVAL_STATUS_CD            BEN_ELIG_PER_ELCTBL_CHC.APPROVAL_STATUS_CD%TYPE
  ,elig_per_elctbl_chc_id        number
  ,object_version_number         number
  ,mark_delete                   varchar2(1)
  );
--
type g_unrest_epe_inst_tbl is table of g_unrest_epe_inst_row
  index by binary_integer;
--
g_unrest_epe_instance       g_unrest_epe_inst_tbl;
--
type g_unrest_ecr_inst_row is record
(enrt_rt_id           number
,ELIG_PER_ELCTBL_CHC_ID        BEN_ENRT_RT.ELIG_PER_ELCTBL_CHC_ID%TYPE
,ENRT_BNFT_ID                  BEN_ENRT_RT.ENRT_BNFT_ID%TYPE
,OBJECT_VERSION_NUMBER         number
,ACTY_BASE_RT_ID               BEN_ENRT_RT.ACTY_BASE_RT_ID%TYPE
,mark_delete                   varchar2(1)
);
--
type g_unrest_ecr_inst_tbl is table of g_unrest_ecr_inst_row
  index by binary_integer;
--
g_unrest_ecr_instance       g_unrest_ecr_inst_tbl;
g_unrest_ecr_instance_row   g_unrest_ecr_inst_row;
--
--
type g_unrest_enb_inst_row is record
(enrt_bnft_id           number
,ELIG_PER_ELCTBL_CHC_ID        BEN_ENRT_RT.ELIG_PER_ELCTBL_CHC_ID%TYPE
,ORDR_NUM                      BEN_ENRT_BNFT.ORDR_NUM%TYPE
,OBJECT_VERSION_NUMBER         number
,mark_delete                   varchar2(1)
);
--
type g_unrest_enb_inst_tbl is table of g_unrest_enb_inst_row
  index by binary_integer;
--
g_unrest_enb_instance       g_unrest_enb_inst_tbl;
g_unrest_enb_instance_row   g_unrest_enb_inst_row;
--
type g_unrest_epr_inst_row is record
(enrt_prem_id           number
,ACTL_PREM_ID                  BEN_ENRT_PREM.ACTL_PREM_ID%TYPE
,ELIG_PER_ELCTBL_CHC_ID        BEN_ENRT_RT.ELIG_PER_ELCTBL_CHC_ID%TYPE
,ENRT_BNFT_ID                  number
,OBJECT_VERSION_NUMBER         BEN_ENRT_PREM.OBJECT_VERSION_NUMBER%TYPE
,mark_delete                   varchar2(1)
);
--
type g_unrest_epr_inst_tbl is table of g_unrest_epr_inst_row
  index by binary_integer;
--
g_unrest_epr_instance       g_unrest_epr_inst_tbl;
g_unrest_epr_instance_row   g_unrest_epr_inst_row;
--
type g_unrest_ecc_inst_row is record
(elctbl_chc_ctfn_id           number
,ENRT_CTFN_TYP_CD              BEN_ELCTBL_CHC_CTFN.ENRT_CTFN_TYP_CD%TYPE
,ELIG_PER_ELCTBL_CHC_ID        BEN_ENRT_RT.ELIG_PER_ELCTBL_CHC_ID%TYPE
,ENRT_BNFT_ID                  BEN_ELCTBL_CHC_CTFN.ENRT_BNFT_ID%TYPE
,OBJECT_VERSION_NUMBER         BEN_ENRT_PREM.OBJECT_VERSION_NUMBER%TYPE
,mark_delete                   varchar2(1)
);
--
type g_unrest_ecc_inst_tbl is table of g_unrest_ecc_inst_row
  index by binary_integer;
--
g_unrest_ecc_instance       g_unrest_ecc_inst_tbl;
g_unrest_ecc_instance_row   g_unrest_ecc_inst_row;
--
type g_unrest_egd_inst_row is record
(elig_dpnt_id           number
,ELIG_PER_ELCTBL_CHC_ID        BEN_ENRT_RT.ELIG_PER_ELCTBL_CHC_ID%TYPE
,PER_IN_LER_ID                 BEN_ELIG_DPNT.PER_IN_LER_ID%TYPE
,ELIG_PER_ID                   BEN_ELIG_DPNT.ELIG_PER_ID%TYPE
,ELIG_PER_OPT_ID               BEN_ELIG_DPNT.ELIG_PER_OPT_ID%TYPE
,ELIG_CVRD_DPNT_ID             BEN_ELIG_DPNT.ELIG_CVRD_DPNT_ID%TYPE
,DPNT_INELIG_FLAG              BEN_ELIG_DPNT.DPNT_INELIG_FLAG%TYPE
,OVRDN_FLAG                    BEN_ELIG_DPNT.OVRDN_FLAG%TYPE
,DPNT_PERSON_ID                BEN_ELIG_DPNT.DPNT_PERSON_ID%TYPE
,OBJECT_VERSION_NUMBER         BEN_ENRT_PREM.OBJECT_VERSION_NUMBER%TYPE
,mark_delete                   varchar2(1)
);
--
type g_unrest_egd_inst_tbl is table of g_unrest_egd_inst_row
  index by binary_integer;
--
g_unrest_egd_instance       g_unrest_egd_inst_tbl;
g_unrest_egd_instance_row  g_unrest_egd_inst_row;
--
procedure update_in_pend_flag
  (p_person_id         in     number
  ,p_per_in_ler_id     in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  );
--
procedure delete_elctbl_choice
  (p_person_id         in     number
  ,p_effective_date    in     date
  ,p_business_group_id in     number
  ,p_rec                  out nocopy benutils.g_active_life_event
  );
--
function epe_exists
  ( p_per_in_ler_id  number
   ,p_pgm_id        number default null
   ,p_pl_id         number default null
   ,p_oipl_id       number default null
   ,p_plip_id       number default null
   ,p_oiplip_id     number default null
   ,p_ptip_id       number default null
   ,p_bnft_prvdr_pool_id  number default null
   ,p_CMBN_PTIP_ID    number default null
   ,p_CMBN_PTIP_OPT_ID number default null
   ,p_CMBN_PLIP_ID     number default null
   ,p_comp_lvl_cd     varchar2 default null
   )  return number;

--
function enb_exists
 (p_ELIG_PER_ELCTBL_CHC_ID  number default null
 ,p_ORDR_NUM                number default null
 ) return number;
--
function ecr_exists
 (p_ELIG_PER_ELCTBL_CHC_ID  number default null
 ,p_enrt_bnft_id    number default null
 ,p_acty_base_rt_id    number
 ) return number;
--
function egd_exists
 (p_PER_IN_LER_ID  number
 ,p_ELIG_PER_ID    number
 ,p_ELIG_PER_OPT_ID  number default null
 ,p_DPNT_PERSON_ID   number
 ) return number;
--
function epr_exists
 (p_ELIG_PER_ELCTBL_CHC_ID  number default null
 ,p_enrt_bnft_id    number default null
 ,p_ACTL_PREM_ID    number
 ) return number;
--
function ecc_exists
( p_ELIG_PER_ELCTBL_CHC_ID  number default null
 ,p_enrt_bnft_id    number default null
 ,p_ENRT_CTFN_TYP_CD  varchar2
) return number;
--
procedure clear_cache;
-- Added during Bug fix - 4640014
procedure clear_epe_cache;
--
procedure update_elig_per_elctbl_choice
  (
   p_elig_per_elctbl_chc_id         in  number
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_rl            in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_pil_elctbl_chc_popl_id         in  number    default hr_api.g_number
  ,p_roll_crs_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_crntly_enrd_flag               in  varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_elctbl_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_mndtry_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_in_pndg_wkflow_flag            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_rl            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_alws_dpnt_dsgn_flag            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_ler_chg_dpnt_cvg_cd            in  varchar2  default hr_api.g_varchar2
  ,p_erlst_deenrt_dt                in  date      default hr_api.g_date
  ,p_procg_end_dt                   in  date      default hr_api.g_date
  ,p_comp_lvl_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_oiplip_id                      in  number    default hr_api.g_number
  ,p_cmbn_plip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_opt_id               in  number    default hr_api.g_number
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_spcl_rt_pl_id                  in  number    default hr_api.g_number
  ,p_spcl_rt_oipl_id                in  number    default hr_api.g_number
  ,p_must_enrl_anthr_pl_id          in  number    default hr_api.g_number
  ,p_int_elig_per_elctbl_chc_id     in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_bnft_prvdr_pool_id             in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_yr_perd_id                     in  number    default hr_api.g_number
  ,p_auto_enrt_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_ordr_num                    in  number    default hr_api.g_number
  ,p_plip_ordr_num                  in  number    default hr_api.g_number
  ,p_ptip_ordr_num                  in  number    default hr_api.g_number
  ,p_oipl_ordr_num                  in  number    default hr_api.g_number
  ,p_comments                       in  varchar2       default hr_api.g_varchar2
  ,p_elig_flag                      in  varchar2       default hr_api.g_varchar2
  ,p_elig_ovrid_dt                  in  date           default hr_api.g_date
  ,p_elig_ovrid_person_id           in  number         default hr_api.g_number
  ,p_inelig_rsn_cd                  in  varchar2       default hr_api.g_varchar2
  ,p_mgr_ovrid_dt                   in  date           default hr_api.g_date
  ,p_mgr_ovrid_person_id            in  number         default hr_api.g_number
  ,p_ws_mgr_id                      in  number         default hr_api.g_number
  ,p_approval_status_cd             in  varchar2  default hr_api.g_varchar2
  ,p_fonm_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_cryfwd_elig_dpnt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ,p_pgm_typ_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_end_dt               in  date      default hr_api.g_date
  ,p_enrt_perd_strt_dt              in  date      default hr_api.g_date
  ,p_dflt_enrt_dt                   in  varchar2  default hr_api.g_date --g_varchar2 --4051269
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_acty_ref_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_lee_rsn_id                     in  number    default hr_api.g_number
  ,p_enrt_perd_id                   in  number    default hr_api.g_number
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default hr_api.g_varchar2
   );
--
procedure update_enrt_bnft
 ( p_enrt_bnft_id                   in  number
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_val_has_bn_prortd_flag         in  varchar2  default hr_api.g_varchar2
  ,p_bndry_perd_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_val                            in  number    default hr_api.g_number
  ,p_nnmntry_uom                    in  varchar2  default hr_api.g_varchar2
  ,p_bnft_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_entr_val_at_enrt_flag          in  varchar2  default hr_api.g_varchar2
  ,p_mn_val                         in  number    default hr_api.g_number
  ,p_mx_val                         in  number    default hr_api.g_number
  ,p_incrmt_val                     in  number    default hr_api.g_number
  ,p_dflt_val                       in  number    default hr_api.g_number
  ,p_rt_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_cvg_mlt_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_crntly_enrld_flag              in  varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id         in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_enb_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_mx_wout_ctfn_val               in number     default hr_api.g_number
  ,p_mx_wo_ctfn_flag                in varchar2   default hr_api.g_varchar2
  ,p_effective_date                 in  date
  );
--
procedure update_enrt_rt
( p_enrt_rt_id                  in  NUMBER,
  p_ordr_num           	        in  number    default hr_api.g_number,
  p_acty_typ_cd                 in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_tx_typ_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ctfn_rqd_flag               in  VARCHAR2  DEFAULT 'N',
  p_dflt_flag                   in  VARCHAR2  DEFAULT 'N',
  p_dflt_pndg_ctfn_flag         in  VARCHAR2  DEFAULT 'N',
  p_dsply_on_enrt_flag          in  VARCHAR2  DEFAULT 'N',
  p_use_to_calc_net_flx_cr_flag in  VARCHAR2  DEFAULT 'N',
  p_entr_val_at_enrt_flag       in  VARCHAR2  DEFAULT 'N',
  p_asn_on_enrt_flag            in  VARCHAR2  DEFAULT 'N',
  p_rl_crs_only_flag            in  VARCHAR2  DEFAULT 'N',
  p_dflt_val                    in  NUMBER    DEFAULT hr_api.g_number,
  p_ann_val                     in  NUMBER    DEFAULT hr_api.g_number,
  p_ann_mn_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  p_ann_mx_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  p_val                         in  NUMBER    DEFAULT hr_api.g_number,
  p_nnmntry_uom                 in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_mx_elcn_val                 in  NUMBER    DEFAULT hr_api.g_number,
  p_mn_elcn_val                 in  NUMBER    DEFAULT hr_api.g_number,
  p_incrmt_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  p_cmcd_acty_ref_perd_cd       in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_cmcd_mn_elcn_val            in  NUMBER    DEFAULT hr_api.g_number,
  p_cmcd_mx_elcn_val            in  NUMBER    DEFAULT hr_api.g_number,
  p_cmcd_val                    in  NUMBER    DEFAULT hr_api.g_number,
  p_cmcd_dflt_val               in  NUMBER    DEFAULT hr_api.g_number,
  p_rt_usg_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ann_dflt_val                in  NUMBER    DEFAULT hr_api.g_number,
  p_bnft_rt_typ_cd              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_rt_mlt_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_dsply_mn_elcn_val           in  NUMBER    DEFAULT hr_api.g_number,
  p_dsply_mx_elcn_val           in  NUMBER    DEFAULT hr_api.g_number,
  p_entr_ann_val_flag           in  VARCHAR2,
  p_rt_strt_dt                  in  DATE      DEFAULT hr_api.g_date,
  p_rt_strt_dt_cd               in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_rt_strt_dt_rl               in  NUMBER    DEFAULT hr_api.g_number,
  p_rt_typ_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_elig_per_elctbl_chc_id      in  NUMBER    DEFAULT hr_api.g_number,
  p_acty_base_rt_id             in  NUMBER    DEFAULT hr_api.g_number,
  p_spcl_rt_enrt_rt_id          in  NUMBER    DEFAULT hr_api.g_number,
  p_enrt_bnft_id                in  NUMBER    DEFAULT hr_api.g_number,
  p_prtt_rt_val_id              in  NUMBER    DEFAULT hr_api.g_number,
  p_decr_bnft_prvdr_pool_id     in  NUMBER    DEFAULT hr_api.g_number,
  p_cvg_amt_calc_mthd_id        in  NUMBER    DEFAULT hr_api.g_number,
  p_actl_prem_id                in  NUMBER    DEFAULT hr_api.g_number,
  p_comp_lvl_fctr_id            in  NUMBER    DEFAULT hr_api.g_number,
  p_ptd_comp_lvl_fctr_id        in  NUMBER    DEFAULT hr_api.g_number,
  p_clm_comp_lvl_fctr_id        in  NUMBER    DEFAULT hr_api.g_number,
  p_business_group_id           in  NUMBER,
  p_perf_min_max_edit           in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_iss_val                     in  number    DEFAULT hr_api.g_number,
  p_val_last_upd_date           in  date      DEFAULT hr_api.g_date,
  p_val_last_upd_person_id      in  number    DEFAULT hr_api.g_number,
  p_pp_in_yr_used_num           in  number    default hr_api.g_number,
  p_ecr_attribute_category      in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute1              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute2              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute3              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute4              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute5              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute6              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute7              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute8              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute9              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute10             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute11             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute12             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute13             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute14             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute15             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute16             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute17             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute18             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute19             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute20             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute21             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute22             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute23             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute24             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute25             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute26             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute27             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute28             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute29             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_ecr_attribute30             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  p_request_id                  in  NUMBER    DEFAULT hr_api.g_number,
  p_program_application_id      in  NUMBER    DEFAULT hr_api.g_number,
  p_program_id                  in  NUMBER    DEFAULT hr_api.g_number,
  p_program_update_date         in  DATE      DEFAULT hr_api.g_date,
  p_effective_date              in  date
  );
--
procedure update_elig_dpnt
(  p_elig_dpnt_id                   in  number
  ,p_create_dt                      in  date      default hr_api.g_date
  ,p_elig_strt_dt                   in  date      default hr_api.g_date
  ,p_elig_thru_dt                   in  date      default hr_api.g_date
  ,p_ovrdn_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_ovrdn_thru_dt                  in  date      default hr_api.g_date
  ,p_inelg_rsn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_inelig_flag               in  varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id         in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_elig_per_id                    in  number    default hr_api.g_number
  ,p_elig_per_opt_id                in  number    default hr_api.g_number
  ,p_elig_cvrd_dpnt_id              in  number    default hr_api.g_number
  ,p_dpnt_person_id                 in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_egd_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
procedure update_enrt_prem
 ( p_enrt_prem_id                   in  number
  ,p_val                            in  number    default hr_api.g_number
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id         in  number    default hr_api.g_number
  ,p_enrt_bnft_id                   in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_epr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  );
--
procedure update_enrt_ctfn
(  p_elctbl_chc_ctfn_id             in  number
  ,p_enrt_ctfn_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id         in  number    default hr_api.g_number
  ,p_enrt_bnft_id                   in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ecc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ecc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_determine_cd              in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
PROCEDURE end_date_elig_per_rows (
   p_person_id        IN   NUMBER,
   p_per_in_ler_id    IN   NUMBER,
   p_effective_date   IN   DATE
);

end ben_manage_unres_life_events;

 

/
