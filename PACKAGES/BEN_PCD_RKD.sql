--------------------------------------------------------
--  DDL for Package BEN_PCD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PCD_RKD" AUTHID CURRENT_USER as
/* $Header: bepcdrhi.pkh 120.0 2005/05/28 10:10:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_per_cm_prvdd_id                in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_rqstd_flag_o                   in varchar2
 ,p_per_cm_prvdd_stat_cd_o         in varchar2
 ,p_cm_dlvry_med_cd_o              in varchar2
 ,p_cm_dlvry_mthd_cd_o             in varchar2
 ,p_sent_dt_o                      in date
 ,p_instnc_num_o                   in number
 ,p_to_be_sent_dt_o                in date
 ,p_dlvry_instn_txt_o              in varchar2
 ,p_inspn_rqd_flag_o               in varchar2
 ,p_resnd_rsn_cd_o                 in varchar2
 ,p_resnd_cmnt_txt_o               in varchar2
 ,p_per_cm_id_o                    in number
 ,p_address_id_o                   in number
 ,p_business_group_id_o            in number
 ,p_pcd_attribute_category_o       in varchar2
 ,p_pcd_attribute1_o               in varchar2
 ,p_pcd_attribute2_o               in varchar2
 ,p_pcd_attribute3_o               in varchar2
 ,p_pcd_attribute4_o               in varchar2
 ,p_pcd_attribute5_o               in varchar2
 ,p_pcd_attribute6_o               in varchar2
 ,p_pcd_attribute7_o               in varchar2
 ,p_pcd_attribute8_o               in varchar2
 ,p_pcd_attribute9_o               in varchar2
 ,p_pcd_attribute10_o              in varchar2
 ,p_pcd_attribute11_o              in varchar2
 ,p_pcd_attribute12_o              in varchar2
 ,p_pcd_attribute13_o              in varchar2
 ,p_pcd_attribute14_o              in varchar2
 ,p_pcd_attribute15_o              in varchar2
 ,p_pcd_attribute16_o              in varchar2
 ,p_pcd_attribute17_o              in varchar2
 ,p_pcd_attribute18_o              in varchar2
 ,p_pcd_attribute19_o              in varchar2
 ,p_pcd_attribute20_o              in varchar2
 ,p_pcd_attribute21_o              in varchar2
 ,p_pcd_attribute22_o              in varchar2
 ,p_pcd_attribute23_o              in varchar2
 ,p_pcd_attribute24_o              in varchar2
 ,p_pcd_attribute25_o              in varchar2
 ,p_pcd_attribute26_o              in varchar2
 ,p_pcd_attribute27_o              in varchar2
 ,p_pcd_attribute28_o              in varchar2
 ,p_pcd_attribute29_o              in varchar2
 ,p_pcd_attribute30_o              in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
  );
--
end ben_pcd_rkd;

 

/
