--------------------------------------------------------
--  DDL for Package BEN_DCL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DCL_RKD" AUTHID CURRENT_USER as
/* $Header: bedclrhi.pkh 120.0 2005/05/28 01:32:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_dpnt_cvrd_othr_pl_rt_id      in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_cvg_det_dt_cd_o                in varchar2
 ,p_business_group_id_o            in number
 ,p_vrbl_rt_prfl_id_o                in number
 ,p_pl_id_o                        in number
 ,p_dcl_attribute_category_o       in varchar2
 ,p_dcl_attribute1_o               in varchar2
 ,p_dcl_attribute2_o               in varchar2
 ,p_dcl_attribute3_o               in varchar2
 ,p_dcl_attribute4_o               in varchar2
 ,p_dcl_attribute5_o               in varchar2
 ,p_dcl_attribute6_o               in varchar2
 ,p_dcl_attribute7_o               in varchar2
 ,p_dcl_attribute8_o               in varchar2
 ,p_dcl_attribute9_o               in varchar2
 ,p_dcl_attribute10_o              in varchar2
 ,p_dcl_attribute11_o              in varchar2
 ,p_dcl_attribute12_o              in varchar2
 ,p_dcl_attribute13_o              in varchar2
 ,p_dcl_attribute14_o              in varchar2
 ,p_dcl_attribute15_o              in varchar2
 ,p_dcl_attribute16_o              in varchar2
 ,p_dcl_attribute17_o              in varchar2
 ,p_dcl_attribute18_o              in varchar2
 ,p_dcl_attribute19_o              in varchar2
 ,p_dcl_attribute20_o              in varchar2
 ,p_dcl_attribute21_o              in varchar2
 ,p_dcl_attribute22_o              in varchar2
 ,p_dcl_attribute23_o              in varchar2
 ,p_dcl_attribute24_o              in varchar2
 ,p_dcl_attribute25_o              in varchar2
 ,p_dcl_attribute26_o              in varchar2
 ,p_dcl_attribute27_o              in varchar2
 ,p_dcl_attribute28_o              in varchar2
 ,p_dcl_attribute29_o              in varchar2
 ,p_dcl_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_dcl_rkd;

 

/
