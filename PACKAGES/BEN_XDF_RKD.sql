--------------------------------------------------------
--  DDL for Package BEN_XDF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XDF_RKD" AUTHID CURRENT_USER as
/* $Header: bexdfrhi.pkh 120.1 2005/12/05 15:53:53 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ext_dfn_id                     in number
 ,p_name_o                         in varchar2
 ,p_xml_tag_name_o                 in varchar2
 ,p_xdo_template_id_o              in number
 ,p_data_typ_cd_o                  in varchar2
 ,p_ext_typ_cd_o                   in varchar2
 ,p_output_name_o                  in varchar2
 ,p_output_type_o                  in varchar2
 ,p_apnd_rqst_id_flag_o            in varchar2
 ,p_prmy_sort_cd_o                 in varchar2
 ,p_scnd_sort_cd_o                 in varchar2
 ,p_strt_dt_o                      in varchar2
 ,p_end_dt_o                       in varchar2
 ,p_ext_crit_prfl_id_o             in number
 ,p_ext_file_id_o                  in number
 ,p_business_group_id_o            in number
 ,p_legislation_code_o             in varchar2
 ,p_xdf_attribute_category_o       in varchar2
 ,p_xdf_attribute1_o               in varchar2
 ,p_xdf_attribute2_o               in varchar2
 ,p_xdf_attribute3_o               in varchar2
 ,p_xdf_attribute4_o               in varchar2
 ,p_xdf_attribute5_o               in varchar2
 ,p_xdf_attribute6_o               in varchar2
 ,p_xdf_attribute7_o               in varchar2
 ,p_xdf_attribute8_o               in varchar2
 ,p_xdf_attribute9_o               in varchar2
 ,p_xdf_attribute10_o              in varchar2
 ,p_xdf_attribute11_o              in varchar2
 ,p_xdf_attribute12_o              in varchar2
 ,p_xdf_attribute13_o              in varchar2
 ,p_xdf_attribute14_o              in varchar2
 ,p_xdf_attribute15_o              in varchar2
 ,p_xdf_attribute16_o              in varchar2
 ,p_xdf_attribute17_o              in varchar2
 ,p_xdf_attribute18_o              in varchar2
 ,p_xdf_attribute19_o              in varchar2
 ,p_xdf_attribute20_o              in varchar2
 ,p_xdf_attribute21_o              in varchar2
 ,p_xdf_attribute22_o              in varchar2
 ,p_xdf_attribute23_o              in varchar2
 ,p_xdf_attribute24_o              in varchar2
 ,p_xdf_attribute25_o              in varchar2
 ,p_xdf_attribute26_o              in varchar2
 ,p_xdf_attribute27_o              in varchar2
 ,p_xdf_attribute28_o              in varchar2
 ,p_xdf_attribute29_o              in varchar2
 ,p_xdf_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_drctry_name_o                  in varchar2
 ,p_kickoff_wrt_prc_flag_o         in varchar2
 ,p_upd_cm_sent_dt_flag_o          in varchar2
 ,p_spcl_hndl_flag_o               in varchar2
 ,p_ext_global_flag_o              in varchar2
 ,p_cm_display_flag_o              in varchar2
 ,p_use_eff_dt_for_chgs_flag_o     in varchar2
 ,p_ext_post_prcs_rl_o             in number
  );
--
end ben_xdf_rkd;

 

/
