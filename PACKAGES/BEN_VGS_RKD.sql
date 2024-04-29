--------------------------------------------------------
--  DDL for Package BEN_VGS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VGS_RKD" AUTHID CURRENT_USER as
/* $Header: bevgsrhi.pkh 120.0.12010000.1 2008/07/29 13:06:58 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_pl_gd_or_svc_id                in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_pl_id_o                        in number
 ,p_gd_or_svc_typ_id_o             in number
 ,p_alw_rcrrg_clms_flag_o          in varchar2
 ,p_gd_or_svc_usg_cd_o             in varchar2
 ,p_vgs_attribute_category_o       in varchar2
 ,p_vgs_attribute1_o               in varchar2
 ,p_vgs_attribute2_o               in varchar2
 ,p_vgs_attribute3_o               in varchar2
 ,p_vgs_attribute4_o               in varchar2
 ,p_vgs_attribute5_o               in varchar2
 ,p_vgs_attribute6_o               in varchar2
 ,p_vgs_attribute7_o               in varchar2
 ,p_vgs_attribute8_o               in varchar2
 ,p_vgs_attribute9_o               in varchar2
 ,p_vgs_attribute10_o              in varchar2
 ,p_vgs_attribute11_o              in varchar2
 ,p_vgs_attribute12_o              in varchar2
 ,p_vgs_attribute13_o              in varchar2
 ,p_vgs_attribute14_o              in varchar2
 ,p_vgs_attribute15_o              in varchar2
 ,p_vgs_attribute16_o              in varchar2
 ,p_vgs_attribute17_o              in varchar2
 ,p_vgs_attribute18_o              in varchar2
 ,p_vgs_attribute19_o              in varchar2
 ,p_vgs_attribute20_o              in varchar2
 ,p_vgs_attribute21_o              in varchar2
 ,p_vgs_attribute22_o              in varchar2
 ,p_vgs_attribute23_o              in varchar2
 ,p_vgs_attribute24_o              in varchar2
 ,p_vgs_attribute25_o              in varchar2
 ,p_vgs_attribute26_o              in varchar2
 ,p_vgs_attribute27_o              in varchar2
 ,p_vgs_attribute28_o              in varchar2
 ,p_vgs_attribute29_o              in varchar2
 ,p_vgs_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_gd_svc_recd_basis_cd_o         in varchar2
 ,p_gd_svc_recd_basis_dt_o         in date
 ,p_gd_svc_recd_basis_mo_o         in number
  );
--
end ben_vgs_rkd;

/
