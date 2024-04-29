--------------------------------------------------------
--  DDL for Package BEN_EGD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EGD_RKU" AUTHID CURRENT_USER as
/* $Header: beegdrhi.pkh 120.0.12000000.1 2007/01/19 04:51:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_dpnt_id                   in number
 ,p_create_dt                      in date
 ,p_elig_strt_dt                   in date
 ,p_elig_thru_dt                   in date
 ,p_ovrdn_flag                     in varchar2
 ,p_ovrdn_thru_dt                  in date
 ,p_inelg_rsn_cd                   in varchar2
 ,p_dpnt_inelig_flag               in varchar2
 ,p_elig_per_elctbl_chc_id         in number
 ,p_per_in_ler_id                  in number
 ,p_elig_per_id                    in number
 ,p_elig_per_opt_id                in number
 ,p_elig_cvrd_dpnt_id              in number
 ,p_dpnt_person_id                 in number
 ,p_business_group_id              in number
 ,p_egd_attribute_category         in varchar2
 ,p_egd_attribute1                 in varchar2
 ,p_egd_attribute2                 in varchar2
 ,p_egd_attribute3                 in varchar2
 ,p_egd_attribute4                 in varchar2
 ,p_egd_attribute5                 in varchar2
 ,p_egd_attribute6                 in varchar2
 ,p_egd_attribute7                 in varchar2
 ,p_egd_attribute8                 in varchar2
 ,p_egd_attribute9                 in varchar2
 ,p_egd_attribute10                in varchar2
 ,p_egd_attribute11                in varchar2
 ,p_egd_attribute12                in varchar2
 ,p_egd_attribute13                in varchar2
 ,p_egd_attribute14                in varchar2
 ,p_egd_attribute15                in varchar2
 ,p_egd_attribute16                in varchar2
 ,p_egd_attribute17                in varchar2
 ,p_egd_attribute18                in varchar2
 ,p_egd_attribute19                in varchar2
 ,p_egd_attribute20                in varchar2
 ,p_egd_attribute21                in varchar2
 ,p_egd_attribute22                in varchar2
 ,p_egd_attribute23                in varchar2
 ,p_egd_attribute24                in varchar2
 ,p_egd_attribute25                in varchar2
 ,p_egd_attribute26                in varchar2
 ,p_egd_attribute27                in varchar2
 ,p_egd_attribute28                in varchar2
 ,p_egd_attribute29                in varchar2
 ,p_egd_attribute30                in varchar2
 ,p_request_id                     in number
 ,p_program_application_id         in number
 ,p_program_id                     in number
 ,p_program_update_date            in date
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_create_dt_o                    in date
 ,p_elig_strt_dt_o                 in date
 ,p_elig_thru_dt_o                 in date
 ,p_ovrdn_flag_o                   in varchar2
 ,p_ovrdn_thru_dt_o                in date
 ,p_inelg_rsn_cd_o                 in varchar2
 ,p_dpnt_inelig_flag_o             in varchar2
 ,p_elig_per_elctbl_chc_id_o       in number
 ,p_per_in_ler_id_o                in number
 ,p_elig_per_id_o                  in number
 ,p_elig_per_opt_id_o              in number
 ,p_elig_cvrd_dpnt_id_o            in number
 ,p_dpnt_person_id_o               in number
 ,p_business_group_id_o            in number
 ,p_egd_attribute_category_o       in varchar2
 ,p_egd_attribute1_o               in varchar2
 ,p_egd_attribute2_o               in varchar2
 ,p_egd_attribute3_o               in varchar2
 ,p_egd_attribute4_o               in varchar2
 ,p_egd_attribute5_o               in varchar2
 ,p_egd_attribute6_o               in varchar2
 ,p_egd_attribute7_o               in varchar2
 ,p_egd_attribute8_o               in varchar2
 ,p_egd_attribute9_o               in varchar2
 ,p_egd_attribute10_o              in varchar2
 ,p_egd_attribute11_o              in varchar2
 ,p_egd_attribute12_o              in varchar2
 ,p_egd_attribute13_o              in varchar2
 ,p_egd_attribute14_o              in varchar2
 ,p_egd_attribute15_o              in varchar2
 ,p_egd_attribute16_o              in varchar2
 ,p_egd_attribute17_o              in varchar2
 ,p_egd_attribute18_o              in varchar2
 ,p_egd_attribute19_o              in varchar2
 ,p_egd_attribute20_o              in varchar2
 ,p_egd_attribute21_o              in varchar2
 ,p_egd_attribute22_o              in varchar2
 ,p_egd_attribute23_o              in varchar2
 ,p_egd_attribute24_o              in varchar2
 ,p_egd_attribute25_o              in varchar2
 ,p_egd_attribute26_o              in varchar2
 ,p_egd_attribute27_o              in varchar2
 ,p_egd_attribute28_o              in varchar2
 ,p_egd_attribute29_o              in varchar2
 ,p_egd_attribute30_o              in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
  );
--
end ben_egd_rku;

 

/
