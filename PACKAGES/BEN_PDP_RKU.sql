--------------------------------------------------------
--  DDL for Package BEN_PDP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PDP_RKU" AUTHID CURRENT_USER as
/* $Header: bepdprhi.pkh 120.3 2005/11/18 04:28:44 vborkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_cvrd_dpnt_id              in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_prtt_enrt_rslt_id              in number
 ,p_dpnt_person_id                 in number
 ,p_cvg_strt_dt                    in date
 ,p_cvg_thru_dt                    in date
 ,p_cvg_pndg_flag                  in varchar2
 ,p_pdp_attribute_category         in varchar2
 ,p_pdp_attribute1                 in varchar2
 ,p_pdp_attribute2                 in varchar2
 ,p_pdp_attribute3                 in varchar2
 ,p_pdp_attribute4                 in varchar2
 ,p_pdp_attribute5                 in varchar2
 ,p_pdp_attribute6                 in varchar2
 ,p_pdp_attribute7                 in varchar2
 ,p_pdp_attribute8                 in varchar2
 ,p_pdp_attribute9                 in varchar2
 ,p_pdp_attribute10                in varchar2
 ,p_pdp_attribute11                in varchar2
 ,p_pdp_attribute12                in varchar2
 ,p_pdp_attribute13                in varchar2
 ,p_pdp_attribute14                in varchar2
 ,p_pdp_attribute15                in varchar2
 ,p_pdp_attribute16                in varchar2
 ,p_pdp_attribute17                in varchar2
 ,p_pdp_attribute18                in varchar2
 ,p_pdp_attribute19                in varchar2
 ,p_pdp_attribute20                in varchar2
 ,p_pdp_attribute21                in varchar2
 ,p_pdp_attribute22                in varchar2
 ,p_pdp_attribute23                in varchar2
 ,p_pdp_attribute24                in varchar2
 ,p_pdp_attribute25                in varchar2
 ,p_pdp_attribute26                in varchar2
 ,p_pdp_attribute27                in varchar2
 ,p_pdp_attribute28                in varchar2
 ,p_pdp_attribute29                in varchar2
 ,p_pdp_attribute30                in varchar2
 ,p_request_id                     in number
 ,p_program_application_id         in number
 ,p_program_id                     in number
 ,p_program_update_date            in date
 ,p_object_version_number          in number
 ,p_ovrdn_flag                     in varchar2
 ,p_per_in_ler_id                  in number
 ,p_ovrdn_thru_dt                  in date
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_prtt_enrt_rslt_id_o            in number
 ,p_dpnt_person_id_o               in number
 ,p_cvg_strt_dt_o                  in date
 ,p_cvg_thru_dt_o                  in date
 ,p_cvg_pndg_flag_o                in varchar2
 ,p_pdp_attribute_category_o       in varchar2
 ,p_pdp_attribute1_o               in varchar2
 ,p_pdp_attribute2_o               in varchar2
 ,p_pdp_attribute3_o               in varchar2
 ,p_pdp_attribute4_o               in varchar2
 ,p_pdp_attribute5_o               in varchar2
 ,p_pdp_attribute6_o               in varchar2
 ,p_pdp_attribute7_o               in varchar2
 ,p_pdp_attribute8_o               in varchar2
 ,p_pdp_attribute9_o               in varchar2
 ,p_pdp_attribute10_o              in varchar2
 ,p_pdp_attribute11_o              in varchar2
 ,p_pdp_attribute12_o              in varchar2
 ,p_pdp_attribute13_o              in varchar2
 ,p_pdp_attribute14_o              in varchar2
 ,p_pdp_attribute15_o              in varchar2
 ,p_pdp_attribute16_o              in varchar2
 ,p_pdp_attribute17_o              in varchar2
 ,p_pdp_attribute18_o              in varchar2
 ,p_pdp_attribute19_o              in varchar2
 ,p_pdp_attribute20_o              in varchar2
 ,p_pdp_attribute21_o              in varchar2
 ,p_pdp_attribute22_o              in varchar2
 ,p_pdp_attribute23_o              in varchar2
 ,p_pdp_attribute24_o              in varchar2
 ,p_pdp_attribute25_o              in varchar2
 ,p_pdp_attribute26_o              in varchar2
 ,p_pdp_attribute27_o              in varchar2
 ,p_pdp_attribute28_o              in varchar2
 ,p_pdp_attribute29_o              in varchar2
 ,p_pdp_attribute30_o              in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
 ,p_ovrdn_flag_o                   in varchar2
 ,p_per_in_ler_id_o                in number
 ,p_ovrdn_thru_dt_o                in date
  );
--
end ben_pdp_rku;

 

/
