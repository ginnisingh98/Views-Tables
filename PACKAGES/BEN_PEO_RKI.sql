--------------------------------------------------------
--  DDL for Package BEN_PEO_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PEO_RKI" AUTHID CURRENT_USER as
/* $Header: bepeorhi.pkh 120.0 2005/05/28 10:38:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
   p_elig_to_prte_rsn_id            in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_business_group_id              in number
  ,p_ler_id                         in number
  ,p_oipl_id                        in number
  ,p_pgm_id                         in number
  ,p_pl_id                          in number
  ,p_ptip_id                        in number
  ,p_plip_id                        in number
  ,p_ignr_prtn_ovrid_flag           in varchar2
  ,p_elig_inelig_cd                 in varchar2
  ,p_prtn_eff_strt_dt_cd            in varchar2
  ,p_prtn_eff_strt_dt_rl            in number
  ,p_prtn_eff_end_dt_cd             in varchar2
  ,p_prtn_eff_end_dt_rl             in number
  ,p_wait_perd_dt_to_use_cd         in varchar2
  ,p_wait_perd_dt_to_use_rl         in number
  ,p_wait_perd_val                  in number
  ,p_wait_perd_uom                  in varchar2
  ,p_wait_perd_rl                   in number
  ,p_mx_poe_det_dt_cd               in varchar2
  ,p_mx_poe_det_dt_rl               in number
  ,p_mx_poe_val                     in number
  ,p_mx_poe_uom                     in varchar2
  ,p_mx_poe_rl                      in number
  ,p_mx_poe_apls_cd                 in varchar2
  ,p_prtn_ovridbl_flag              in varchar2
  ,p_vrfy_fmly_mmbr_cd              in varchar2
  ,p_vrfy_fmly_mmbr_rl              in number
  ,p_peo_attribute_category         in varchar2
  ,p_peo_attribute1                 in varchar2
  ,p_peo_attribute2                 in varchar2
  ,p_peo_attribute3                 in varchar2
  ,p_peo_attribute4                 in varchar2
  ,p_peo_attribute5                 in varchar2
  ,p_peo_attribute6                 in varchar2
  ,p_peo_attribute7                 in varchar2
  ,p_peo_attribute8                 in varchar2
  ,p_peo_attribute9                 in varchar2
  ,p_peo_attribute10                in varchar2
  ,p_peo_attribute11                in varchar2
  ,p_peo_attribute12                in varchar2
  ,p_peo_attribute13                in varchar2
  ,p_peo_attribute14                in varchar2
  ,p_peo_attribute15                in varchar2
  ,p_peo_attribute16                in varchar2
  ,p_peo_attribute17                in varchar2
  ,p_peo_attribute18                in varchar2
  ,p_peo_attribute19                in varchar2
  ,p_peo_attribute20                in varchar2
  ,p_peo_attribute21                in varchar2
  ,p_peo_attribute22                in varchar2
  ,p_peo_attribute23                in varchar2
  ,p_peo_attribute24                in varchar2
  ,p_peo_attribute25                in varchar2
  ,p_peo_attribute26                in varchar2
  ,p_peo_attribute27                in varchar2
  ,p_peo_attribute28                in varchar2
  ,p_peo_attribute29                in varchar2
  ,p_peo_attribute30                in varchar2
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  ,p_validation_start_date          in date
  ,p_validation_end_date            in date
  );
end ben_peo_rki;

 

/
