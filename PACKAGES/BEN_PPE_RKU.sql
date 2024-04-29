--------------------------------------------------------
--  DDL for Package BEN_PPE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PPE_RKU" AUTHID CURRENT_USER as
/* $Header: bepperhi.pkh 120.0 2005/05/28 10:57:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_prtt_prem_id                   in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_std_prem_uom                   in varchar2
 ,p_std_prem_val                   in number
 ,p_actl_prem_id                   in number
 ,p_prtt_enrt_rslt_id              in number
 ,p_per_in_ler_id              in number
 ,p_business_group_id              in number
 ,p_ppe_attribute_category         in varchar2
 ,p_ppe_attribute1                 in varchar2
 ,p_ppe_attribute2                 in varchar2
 ,p_ppe_attribute3                 in varchar2
 ,p_ppe_attribute4                 in varchar2
 ,p_ppe_attribute5                 in varchar2
 ,p_ppe_attribute6                 in varchar2
 ,p_ppe_attribute7                 in varchar2
 ,p_ppe_attribute8                 in varchar2
 ,p_ppe_attribute9                 in varchar2
 ,p_ppe_attribute10                in varchar2
 ,p_ppe_attribute11                in varchar2
 ,p_ppe_attribute12                in varchar2
 ,p_ppe_attribute13                in varchar2
 ,p_ppe_attribute14                in varchar2
 ,p_ppe_attribute15                in varchar2
 ,p_ppe_attribute16                in varchar2
 ,p_ppe_attribute17                in varchar2
 ,p_ppe_attribute18                in varchar2
 ,p_ppe_attribute19                in varchar2
 ,p_ppe_attribute20                in varchar2
 ,p_ppe_attribute21                in varchar2
 ,p_ppe_attribute22                in varchar2
 ,p_ppe_attribute23                in varchar2
 ,p_ppe_attribute24                in varchar2
 ,p_ppe_attribute25                in varchar2
 ,p_ppe_attribute26                in varchar2
 ,p_ppe_attribute27                in varchar2
 ,p_ppe_attribute28                in varchar2
 ,p_ppe_attribute29                in varchar2
 ,p_ppe_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_request_id                     in number
 ,p_program_application_id         in number
 ,p_program_id                     in number
 ,p_program_update_date            in date
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_std_prem_uom_o                 in varchar2
 ,p_std_prem_val_o                 in number
 ,p_actl_prem_id_o                 in number
 ,p_prtt_enrt_rslt_id_o            in number
 ,p_per_in_ler_id_o            in number
 ,p_business_group_id_o            in number
 ,p_ppe_attribute_category_o       in varchar2
 ,p_ppe_attribute1_o               in varchar2
 ,p_ppe_attribute2_o               in varchar2
 ,p_ppe_attribute3_o               in varchar2
 ,p_ppe_attribute4_o               in varchar2
 ,p_ppe_attribute5_o               in varchar2
 ,p_ppe_attribute6_o               in varchar2
 ,p_ppe_attribute7_o               in varchar2
 ,p_ppe_attribute8_o               in varchar2
 ,p_ppe_attribute9_o               in varchar2
 ,p_ppe_attribute10_o              in varchar2
 ,p_ppe_attribute11_o              in varchar2
 ,p_ppe_attribute12_o              in varchar2
 ,p_ppe_attribute13_o              in varchar2
 ,p_ppe_attribute14_o              in varchar2
 ,p_ppe_attribute15_o              in varchar2
 ,p_ppe_attribute16_o              in varchar2
 ,p_ppe_attribute17_o              in varchar2
 ,p_ppe_attribute18_o              in varchar2
 ,p_ppe_attribute19_o              in varchar2
 ,p_ppe_attribute20_o              in varchar2
 ,p_ppe_attribute21_o              in varchar2
 ,p_ppe_attribute22_o              in varchar2
 ,p_ppe_attribute23_o              in varchar2
 ,p_ppe_attribute24_o              in varchar2
 ,p_ppe_attribute25_o              in varchar2
 ,p_ppe_attribute26_o              in varchar2
 ,p_ppe_attribute27_o              in varchar2
 ,p_ppe_attribute28_o              in varchar2
 ,p_ppe_attribute29_o              in varchar2
 ,p_ppe_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
  );
--
end ben_ppe_rku;

 

/
