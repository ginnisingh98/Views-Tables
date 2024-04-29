--------------------------------------------------------
--  DDL for Package BEN_PCR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PCR_RKD" AUTHID CURRENT_USER as
/* $Header: bepcrrhi.pkh 120.0 2005/05/28 10:15:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_per_cm_trgr_id                 in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_cm_trgr_id_o                   in number
 ,p_per_cm_id_o                    in number
 ,p_business_group_id_o            in number
 ,p_pcr_attribute_category_o       in varchar2
 ,p_pcr_attribute1_o               in varchar2
 ,p_pcr_attribute2_o               in varchar2
 ,p_pcr_attribute3_o               in varchar2
 ,p_pcr_attribute4_o               in varchar2
 ,p_pcr_attribute5_o               in varchar2
 ,p_pcr_attribute6_o               in varchar2
 ,p_pcr_attribute7_o               in varchar2
 ,p_pcr_attribute8_o               in varchar2
 ,p_pcr_attribute9_o               in varchar2
 ,p_pcr_attribute10_o              in varchar2
 ,p_pcr_attribute11_o              in varchar2
 ,p_pcr_attribute12_o              in varchar2
 ,p_pcr_attribute13_o              in varchar2
 ,p_pcr_attribute14_o              in varchar2
 ,p_pcr_attribute15_o              in varchar2
 ,p_pcr_attribute16_o              in varchar2
 ,p_pcr_attribute17_o              in varchar2
 ,p_pcr_attribute18_o              in varchar2
 ,p_pcr_attribute19_o              in varchar2
 ,p_pcr_attribute20_o              in varchar2
 ,p_pcr_attribute21_o              in varchar2
 ,p_pcr_attribute22_o              in varchar2
 ,p_pcr_attribute23_o              in varchar2
 ,p_pcr_attribute24_o              in varchar2
 ,p_pcr_attribute25_o              in varchar2
 ,p_pcr_attribute26_o              in varchar2
 ,p_pcr_attribute27_o              in varchar2
 ,p_pcr_attribute28_o              in varchar2
 ,p_pcr_attribute29_o              in varchar2
 ,p_pcr_attribute30_o              in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
  );
--
end ben_pcr_rkd;

 

/
