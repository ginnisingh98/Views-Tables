--------------------------------------------------------
--  DDL for Package BEN_PCM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PCM_RKD" AUTHID CURRENT_USER as
/* $Header: bepcmrhi.pkh 120.0 2005/05/28 10:12:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_per_cm_id                      in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_lf_evt_ocrd_dt_o               in date
 ,p_rqstbl_untl_dt_o               in date
 ,p_ler_id_o                       in number
 ,p_per_in_ler_id_o                       in number
 ,p_prtt_enrt_actn_id_o            in number
 ,p_person_id_o                    in number
 ,p_bnf_person_id_o                in number
 ,p_dpnt_person_id_o               in number
 ,p_cm_typ_id_o                    in number
 ,p_business_group_id_o            in number
 ,p_pcm_attribute_category_o       in varchar2
 ,p_pcm_attribute1_o               in varchar2
 ,p_pcm_attribute2_o               in varchar2
 ,p_pcm_attribute3_o               in varchar2
 ,p_pcm_attribute4_o               in varchar2
 ,p_pcm_attribute5_o               in varchar2
 ,p_pcm_attribute6_o               in varchar2
 ,p_pcm_attribute7_o               in varchar2
 ,p_pcm_attribute8_o               in varchar2
 ,p_pcm_attribute9_o               in varchar2
 ,p_pcm_attribute10_o              in varchar2
 ,p_pcm_attribute11_o              in varchar2
 ,p_pcm_attribute12_o              in varchar2
 ,p_pcm_attribute13_o              in varchar2
 ,p_pcm_attribute14_o              in varchar2
 ,p_pcm_attribute15_o              in varchar2
 ,p_pcm_attribute16_o              in varchar2
 ,p_pcm_attribute17_o              in varchar2
 ,p_pcm_attribute18_o              in varchar2
 ,p_pcm_attribute19_o              in varchar2
 ,p_pcm_attribute20_o              in varchar2
 ,p_pcm_attribute21_o              in varchar2
 ,p_pcm_attribute22_o              in varchar2
 ,p_pcm_attribute23_o              in varchar2
 ,p_pcm_attribute24_o              in varchar2
 ,p_pcm_attribute25_o              in varchar2
 ,p_pcm_attribute26_o              in varchar2
 ,p_pcm_attribute27_o              in varchar2
 ,p_pcm_attribute28_o              in varchar2
 ,p_pcm_attribute29_o              in varchar2
 ,p_pcm_attribute30_o              in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
  );
--
end ben_pcm_rkd;

 

/
