--------------------------------------------------------
--  DDL for Package BEN_LIFE_EVENT_ENROLL_RSN_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LIFE_EVENT_ENROLL_RSN_BK1" AUTHID CURRENT_USER as
/* $Header: belenapi.pkh 120.1 2007/05/13 22:54:06 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Life_Event_Enroll_Rsn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Life_Event_Enroll_Rsn_b
  (
   p_business_group_id              in  number
  ,p_popl_enrt_typ_cycl_id          in  number
  ,p_ler_id                         in  number
  ,p_cls_enrt_dt_to_use_cd          in  varchar2
  ,p_dys_aftr_end_to_dflt_num       in  number
  ,p_enrt_cvg_end_dt_cd             in  varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2
  ,p_enrt_perd_strt_dt_cd           in  varchar2
  ,p_enrt_perd_strt_dt_rl           in  number
  ,p_enrt_perd_end_dt_cd            in  varchar2
  ,p_enrt_perd_end_dt_rl            in  number
  ,p_addl_procg_dys_num             in  number
  ,p_dys_no_enrl_not_elig_num       in  number
  ,p_dys_no_enrl_cant_enrl_num      in  number
  ,p_rt_end_dt_cd                   in  varchar2
  ,p_rt_end_dt_rl                   in  number
  ,p_rt_strt_dt_cd                  in  varchar2
  ,p_rt_strt_dt_rl                  in  number
  ,p_enrt_cvg_end_dt_rl             in  number
  ,p_enrt_cvg_strt_dt_rl            in  number
  ,p_len_attribute_category         in  varchar2
  ,p_len_attribute1                 in  varchar2
  ,p_len_attribute2                 in  varchar2
  ,p_len_attribute3                 in  varchar2
  ,p_len_attribute4                 in  varchar2
  ,p_len_attribute5                 in  varchar2
  ,p_len_attribute6                 in  varchar2
  ,p_len_attribute7                 in  varchar2
  ,p_len_attribute8                 in  varchar2
  ,p_len_attribute9                 in  varchar2
  ,p_len_attribute10                in  varchar2
  ,p_len_attribute11                in  varchar2
  ,p_len_attribute12                in  varchar2
  ,p_len_attribute13                in  varchar2
  ,p_len_attribute14                in  varchar2
  ,p_len_attribute15                in  varchar2
  ,p_len_attribute16                in  varchar2
  ,p_len_attribute17                in  varchar2
  ,p_len_attribute18                in  varchar2
  ,p_len_attribute19                in  varchar2
  ,p_len_attribute20                in  varchar2
  ,p_len_attribute21                in  varchar2
  ,p_len_attribute22                in  varchar2
  ,p_len_attribute23                in  varchar2
  ,p_len_attribute24                in  varchar2
  ,p_len_attribute25                in  varchar2
  ,p_len_attribute26                in  varchar2
  ,p_len_attribute27                in  varchar2
  ,p_len_attribute28                in  varchar2
  ,p_len_attribute29                in  varchar2
  ,p_len_attribute30                in  varchar2
  ,p_enrt_perd_det_ovrlp_bckdt_cd                in  varchar2
  ,p_effective_date                 in  date
  ,p_reinstate_cd			in varchar2
  ,p_reinstate_ovrdn_cd		in varchar2
  ,p_ENRT_PERD_STRT_DAYS	in number
  ,p_ENRT_PERD_END_DAYS	        in number
  ,p_defer_deenrol_flag         in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Life_Event_Enroll_Rsn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Life_Event_Enroll_Rsn_a
  (
   p_lee_rsn_id                     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_popl_enrt_typ_cycl_id          in  number
  ,p_ler_id                         in  number
  ,p_cls_enrt_dt_to_use_cd          in  varchar2
  ,p_dys_aftr_end_to_dflt_num       in  number
  ,p_enrt_cvg_end_dt_cd             in  varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2
  ,p_enrt_perd_strt_dt_cd           in  varchar2
  ,p_enrt_perd_strt_dt_rl           in  number
  ,p_enrt_perd_end_dt_cd            in  varchar2
  ,p_enrt_perd_end_dt_rl            in  number
  ,p_addl_procg_dys_num             in  number
  ,p_dys_no_enrl_not_elig_num       in  number
  ,p_dys_no_enrl_cant_enrl_num      in  number
  ,p_rt_end_dt_cd                   in  varchar2
  ,p_rt_end_dt_rl                   in  number
  ,p_rt_strt_dt_cd                  in  varchar2
  ,p_rt_strt_dt_rl                  in  number
  ,p_enrt_cvg_end_dt_rl             in  number
  ,p_enrt_cvg_strt_dt_rl            in  number
  ,p_len_attribute_category         in  varchar2
  ,p_len_attribute1                 in  varchar2
  ,p_len_attribute2                 in  varchar2
  ,p_len_attribute3                 in  varchar2
  ,p_len_attribute4                 in  varchar2
  ,p_len_attribute5                 in  varchar2
  ,p_len_attribute6                 in  varchar2
  ,p_len_attribute7                 in  varchar2
  ,p_len_attribute8                 in  varchar2
  ,p_len_attribute9                 in  varchar2
  ,p_len_attribute10                in  varchar2
  ,p_len_attribute11                in  varchar2
  ,p_len_attribute12                in  varchar2
  ,p_len_attribute13                in  varchar2
  ,p_len_attribute14                in  varchar2
  ,p_len_attribute15                in  varchar2
  ,p_len_attribute16                in  varchar2
  ,p_len_attribute17                in  varchar2
  ,p_len_attribute18                in  varchar2
  ,p_len_attribute19                in  varchar2
  ,p_len_attribute20                in  varchar2
  ,p_len_attribute21                in  varchar2
  ,p_len_attribute22                in  varchar2
  ,p_len_attribute23                in  varchar2
  ,p_len_attribute24                in  varchar2
  ,p_len_attribute25                in  varchar2
  ,p_len_attribute26                in  varchar2
  ,p_len_attribute27                in  varchar2
  ,p_len_attribute28                in  varchar2
  ,p_len_attribute29                in  varchar2
  ,p_len_attribute30                in  varchar2
  ,p_enrt_perd_det_ovrlp_bckdt_cd                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_reinstate_cd			in varchar2
  ,p_reinstate_ovrdn_cd		in varchar2
  ,p_ENRT_PERD_STRT_DAYS	in number
  ,p_ENRT_PERD_END_DAYS	        in number
  ,p_defer_deenrol_flag         in varchar2
  );
--
end ben_Life_Event_Enroll_Rsn_bk1;

/
