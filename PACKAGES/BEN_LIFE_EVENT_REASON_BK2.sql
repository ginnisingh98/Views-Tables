--------------------------------------------------------
--  DDL for Package BEN_LIFE_EVENT_REASON_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LIFE_EVENT_REASON_BK2" AUTHID CURRENT_USER as
/* $Header: belerapi.pkh 120.1 2006/11/03 10:37:41 vborkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Life_Event_Reason_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Life_Event_Reason_b
  (
   p_ler_id                         in  number
  ,p_name                           in  varchar2
  ,p_business_group_id              in  number
  ,p_typ_cd                         in  varchar2
  ,p_lf_evt_oper_cd                 in  varchar2
  ,p_short_name                 in  varchar2
  ,p_short_code                 in  varchar2
  ,p_ptnl_ler_trtmt_cd              in  varchar2
  ,p_ck_rltd_per_elig_flag          in  varchar2
  ,p_ler_eval_rl                    in  number
  ,p_cm_aply_flag                   in  varchar2
  ,p_ovridg_le_flag                 in  varchar2
  ,p_qualg_evt_flag                 in  varchar2
  ,p_whn_to_prcs_cd                 in  varchar2
  ,p_desc_txt                       in  varchar2
  ,p_tmlns_eval_cd                  in  varchar2
  ,p_tmlns_perd_cd                  in  varchar2
  ,p_tmlns_dys_num                  in  number
  ,p_tmlns_perd_rl                  in  number
  ,p_ocrd_dt_det_cd                 in  varchar2
  ,p_ler_stat_cd                    in  varchar2
  ,p_slctbl_slf_svc_cd              in  varchar2
  ,p_ss_pcp_disp_cd                 in  varchar2
  ,p_ler_attribute_category         in  varchar2
  ,p_ler_attribute1                 in  varchar2
  ,p_ler_attribute2                 in  varchar2
  ,p_ler_attribute3                 in  varchar2
  ,p_ler_attribute4                 in  varchar2
  ,p_ler_attribute5                 in  varchar2
  ,p_ler_attribute6                 in  varchar2
  ,p_ler_attribute7                 in  varchar2
  ,p_ler_attribute8                 in  varchar2
  ,p_ler_attribute9                 in  varchar2
  ,p_ler_attribute10                in  varchar2
  ,p_ler_attribute11                in  varchar2
  ,p_ler_attribute12                in  varchar2
  ,p_ler_attribute13                in  varchar2
  ,p_ler_attribute14                in  varchar2
  ,p_ler_attribute15                in  varchar2
  ,p_ler_attribute16                in  varchar2
  ,p_ler_attribute17                in  varchar2
  ,p_ler_attribute18                in  varchar2
  ,p_ler_attribute19                in  varchar2
  ,p_ler_attribute20                in  varchar2
  ,p_ler_attribute21                in  varchar2
  ,p_ler_attribute22                in  varchar2
  ,p_ler_attribute23                in  varchar2
  ,p_ler_attribute24                in  varchar2
  ,p_ler_attribute25                in  varchar2
  ,p_ler_attribute26                in  varchar2
  ,p_ler_attribute27                in  varchar2
  ,p_ler_attribute28                in  varchar2
  ,p_ler_attribute29                in  varchar2
  ,p_ler_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Life_Event_Reason_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Life_Event_Reason_a
  (
   p_ler_id                         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_name                           in  varchar2
  ,p_business_group_id              in  number
  ,p_typ_cd                         in  varchar2
  ,p_lf_evt_oper_cd                 in  varchar2
  ,p_short_name                 in  varchar2
  ,p_short_code                 in  varchar2
  ,p_ptnl_ler_trtmt_cd              in  varchar2
  ,p_ck_rltd_per_elig_flag          in  varchar2
  ,p_ler_eval_rl                    in  number
  ,p_cm_aply_flag                   in  varchar2
  ,p_ovridg_le_flag                 in  varchar2
  ,p_qualg_evt_flag                 in  varchar2
  ,p_whn_to_prcs_cd                 in  varchar2
  ,p_desc_txt                       in  varchar2
  ,p_tmlns_eval_cd                  in  varchar2
  ,p_tmlns_perd_cd                  in  varchar2
  ,p_tmlns_dys_num                  in  number
  ,p_tmlns_perd_rl                  in  number
  ,p_ocrd_dt_det_cd                 in  varchar2
  ,p_ler_stat_cd                    in  varchar2
  ,p_slctbl_slf_svc_cd              in  varchar2
  ,p_ss_pcp_disp_cd                 in  varchar2
  ,p_ler_attribute_category         in  varchar2
  ,p_ler_attribute1                 in  varchar2
  ,p_ler_attribute2                 in  varchar2
  ,p_ler_attribute3                 in  varchar2
  ,p_ler_attribute4                 in  varchar2
  ,p_ler_attribute5                 in  varchar2
  ,p_ler_attribute6                 in  varchar2
  ,p_ler_attribute7                 in  varchar2
  ,p_ler_attribute8                 in  varchar2
  ,p_ler_attribute9                 in  varchar2
  ,p_ler_attribute10                in  varchar2
  ,p_ler_attribute11                in  varchar2
  ,p_ler_attribute12                in  varchar2
  ,p_ler_attribute13                in  varchar2
  ,p_ler_attribute14                in  varchar2
  ,p_ler_attribute15                in  varchar2
  ,p_ler_attribute16                in  varchar2
  ,p_ler_attribute17                in  varchar2
  ,p_ler_attribute18                in  varchar2
  ,p_ler_attribute19                in  varchar2
  ,p_ler_attribute20                in  varchar2
  ,p_ler_attribute21                in  varchar2
  ,p_ler_attribute22                in  varchar2
  ,p_ler_attribute23                in  varchar2
  ,p_ler_attribute24                in  varchar2
  ,p_ler_attribute25                in  varchar2
  ,p_ler_attribute26                in  varchar2
  ,p_ler_attribute27                in  varchar2
  ,p_ler_attribute28                in  varchar2
  ,p_ler_attribute29                in  varchar2
  ,p_ler_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_Life_Event_Reason_bk2;

/
