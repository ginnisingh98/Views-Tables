--------------------------------------------------------
--  DDL for Package BEN_CCT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CCT_RKD" AUTHID CURRENT_USER as
/* $Header: becctrhi.pkh 120.0 2005/05/28 00:59:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_cm_typ_id                      in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_desc_txt_o                     in varchar2
 ,p_cm_typ_rl_o                    in number
 ,p_cm_usg_cd_o                    in varchar2
 ,p_whnvr_trgrd_flag_o             in varchar2
 ,p_shrt_name_o                    in varchar2
 ,p_pc_kit_cd_o                    in varchar2
 ,p_trk_mlg_flag_o                 in varchar2
 ,p_mx_num_avlbl_val_o             in number
 ,p_to_be_sent_dt_cd_o             in varchar2
 ,p_to_be_sent_dt_rl_o             in number
 ,p_inspn_rqd_flag_o               in varchar2
 ,p_inspn_rqd_rl_o                 in number
 ,p_rcpent_cd_o                    in varchar2
 ,p_parnt_cm_typ_id_o              in number
 ,p_business_group_id_o            in number
 ,p_cct_attribute_category_o       in varchar2
 ,p_cct_attribute1_o               in varchar2
 ,p_cct_attribute10_o              in varchar2
 ,p_cct_attribute11_o              in varchar2
 ,p_cct_attribute12_o              in varchar2
 ,p_cct_attribute13_o              in varchar2
 ,p_cct_attribute14_o              in varchar2
 ,p_cct_attribute15_o              in varchar2
 ,p_cct_attribute16_o              in varchar2
 ,p_cct_attribute17_o              in varchar2
 ,p_cct_attribute18_o              in varchar2
 ,p_cct_attribute19_o              in varchar2
 ,p_cct_attribute2_o               in varchar2
 ,p_cct_attribute20_o              in varchar2
 ,p_cct_attribute21_o              in varchar2
 ,p_cct_attribute22_o              in varchar2
 ,p_cct_attribute23_o              in varchar2
 ,p_cct_attribute24_o              in varchar2
 ,p_cct_attribute25_o              in varchar2
 ,p_cct_attribute26_o              in varchar2
 ,p_cct_attribute27_o              in varchar2
 ,p_cct_attribute28_o              in varchar2
 ,p_cct_attribute29_o              in varchar2
 ,p_cct_attribute3_o               in varchar2
 ,p_cct_attribute30_o              in varchar2
 ,p_cct_attribute4_o               in varchar2
 ,p_cct_attribute5_o               in varchar2
 ,p_cct_attribute6_o               in varchar2
 ,p_cct_attribute7_o               in varchar2
 ,p_cct_attribute8_o               in varchar2
 ,p_cct_attribute9_o               in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_cct_rkd;

 

/
