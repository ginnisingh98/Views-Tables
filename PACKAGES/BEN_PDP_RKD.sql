--------------------------------------------------------
--  DDL for Package BEN_PDP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PDP_RKD" AUTHID CURRENT_USER as
/* $Header: bepdprhi.pkh 120.3 2005/11/18 04:28:44 vborkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_cvrd_dpnt_id              in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
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
end ben_pdp_rkd;

 

/
