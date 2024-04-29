--------------------------------------------------------
--  DDL for Package BEN_DDR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DDR_RKD" AUTHID CURRENT_USER as
/* $Header: beddrrhi.pkh 120.0 2005/05/28 01:35:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_dsgn_rqmt_id                   in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_mn_dpnts_rqd_num_o             in number
 ,p_mx_dpnts_alwd_num_o            in number
 ,p_no_mn_num_dfnd_flag_o          in varchar2
 ,p_no_mx_num_dfnd_flag_o          in varchar2
 ,p_cvr_all_elig_flag_o            in varchar2
 ,p_oipl_id_o                      in number
 ,p_pl_id_o                        in number
 ,p_opt_id_o                       in number
 ,p_grp_rlshp_cd_o                 in varchar2
 ,p_dsgn_typ_cd_o                  in varchar2
 ,p_business_group_id_o            in number
 ,p_ddr_attribute_category_o       in varchar2
 ,p_ddr_attribute1_o               in varchar2
 ,p_ddr_attribute2_o               in varchar2
 ,p_ddr_attribute3_o               in varchar2
 ,p_ddr_attribute4_o               in varchar2
 ,p_ddr_attribute5_o               in varchar2
 ,p_ddr_attribute6_o               in varchar2
 ,p_ddr_attribute7_o               in varchar2
 ,p_ddr_attribute8_o               in varchar2
 ,p_ddr_attribute9_o               in varchar2
 ,p_ddr_attribute10_o              in varchar2
 ,p_ddr_attribute11_o              in varchar2
 ,p_ddr_attribute12_o              in varchar2
 ,p_ddr_attribute13_o              in varchar2
 ,p_ddr_attribute14_o              in varchar2
 ,p_ddr_attribute15_o              in varchar2
 ,p_ddr_attribute16_o              in varchar2
 ,p_ddr_attribute17_o              in varchar2
 ,p_ddr_attribute18_o              in varchar2
 ,p_ddr_attribute19_o              in varchar2
 ,p_ddr_attribute20_o              in varchar2
 ,p_ddr_attribute21_o              in varchar2
 ,p_ddr_attribute22_o              in varchar2
 ,p_ddr_attribute23_o              in varchar2
 ,p_ddr_attribute24_o              in varchar2
 ,p_ddr_attribute25_o              in varchar2
 ,p_ddr_attribute26_o              in varchar2
 ,p_ddr_attribute27_o              in varchar2
 ,p_ddr_attribute28_o              in varchar2
 ,p_ddr_attribute29_o              in varchar2
 ,p_ddr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_ddr_rkd;

 

/
