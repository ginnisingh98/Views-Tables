--------------------------------------------------------
--  DDL for Package BEN_REG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_REG_RKD" AUTHID CURRENT_USER as
/* $Header: beregrhi.pkh 120.0.12010000.1 2008/07/29 13:01:25 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_regn_id                        in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_organization_id_o              in number
 ,p_business_group_id_o            in number
 ,p_sttry_citn_name_o              in varchar2
 ,p_reg_attribute_category_o       in varchar2
 ,p_reg_attribute1_o               in varchar2
 ,p_reg_attribute2_o               in varchar2
 ,p_reg_attribute3_o               in varchar2
 ,p_reg_attribute4_o               in varchar2
 ,p_reg_attribute5_o               in varchar2
 ,p_reg_attribute6_o               in varchar2
 ,p_reg_attribute7_o               in varchar2
 ,p_reg_attribute8_o               in varchar2
 ,p_reg_attribute9_o               in varchar2
 ,p_reg_attribute10_o              in varchar2
 ,p_reg_attribute11_o              in varchar2
 ,p_reg_attribute12_o              in varchar2
 ,p_reg_attribute13_o              in varchar2
 ,p_reg_attribute14_o              in varchar2
 ,p_reg_attribute15_o              in varchar2
 ,p_reg_attribute16_o              in varchar2
 ,p_reg_attribute17_o              in varchar2
 ,p_reg_attribute18_o              in varchar2
 ,p_reg_attribute19_o              in varchar2
 ,p_reg_attribute20_o              in varchar2
 ,p_reg_attribute21_o              in varchar2
 ,p_reg_attribute22_o              in varchar2
 ,p_reg_attribute23_o              in varchar2
 ,p_reg_attribute24_o              in varchar2
 ,p_reg_attribute25_o              in varchar2
 ,p_reg_attribute26_o              in varchar2
 ,p_reg_attribute27_o              in varchar2
 ,p_reg_attribute28_o              in varchar2
 ,p_reg_attribute29_o              in varchar2
 ,p_reg_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_reg_rkd;

/
