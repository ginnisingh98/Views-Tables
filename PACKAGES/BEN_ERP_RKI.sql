--------------------------------------------------------
--  DDL for Package BEN_ERP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ERP_RKI" AUTHID CURRENT_USER as
/* $Header: beerprhi.pkh 120.0 2005/05/28 02:53:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_enrt_perd_for_pl_id            in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_enrt_cvg_strt_dt_cd            in varchar2
 ,p_enrt_cvg_strt_dt_rl            in number
 ,p_enrt_cvg_end_dt_cd             in varchar2
 ,p_enrt_cvg_end_dt_rl             in number
 ,p_rt_strt_dt_cd                  in varchar2
 ,p_rt_strt_dt_rl                  in number
 ,p_rt_end_dt_cd                   in varchar2
 ,p_rt_end_dt_rl                   in number
 ,p_enrt_perd_id                   in number
 ,p_pl_id                          in number
 ,p_lee_rsn_id                     in number
 ,p_business_group_id              in number
 ,p_erp_attribute_category         in varchar2
 ,p_erp_attribute1                 in varchar2
 ,p_erp_attribute2                 in varchar2
 ,p_erp_attribute3                 in varchar2
 ,p_erp_attribute4                 in varchar2
 ,p_erp_attribute5                 in varchar2
 ,p_erp_attribute6                 in varchar2
 ,p_erp_attribute7                 in varchar2
 ,p_erp_attribute8                 in varchar2
 ,p_erp_attribute9                 in varchar2
 ,p_erp_attribute10                in varchar2
 ,p_erp_attribute11                in varchar2
 ,p_erp_attribute12                in varchar2
 ,p_erp_attribute13                in varchar2
 ,p_erp_attribute14                in varchar2
 ,p_erp_attribute15                in varchar2
 ,p_erp_attribute16                in varchar2
 ,p_erp_attribute17                in varchar2
 ,p_erp_attribute18                in varchar2
 ,p_erp_attribute19                in varchar2
 ,p_erp_attribute20                in varchar2
 ,p_erp_attribute21                in varchar2
 ,p_erp_attribute22                in varchar2
 ,p_erp_attribute23                in varchar2
 ,p_erp_attribute24                in varchar2
 ,p_erp_attribute25                in varchar2
 ,p_erp_attribute26                in varchar2
 ,p_erp_attribute27                in varchar2
 ,p_erp_attribute28                in varchar2
 ,p_erp_attribute29                in varchar2
 ,p_erp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_erp_rki;

 

/
