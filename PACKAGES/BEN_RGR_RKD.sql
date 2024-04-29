--------------------------------------------------------
--  DDL for Package BEN_RGR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RGR_RKD" AUTHID CURRENT_USER as
/* $Header: bergrrhi.pkh 120.0.12010000.1 2008/07/29 13:01:46 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_popl_rptg_grp_id               in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_rptg_grp_id_o                  in number
 ,p_pgm_id_o                       in number
 ,p_pl_id_o                        in number
 ,p_ordr_num_o                     in number            --iRec
 ,p_rgr_attribute_category_o       in varchar2
 ,p_rgr_attribute1_o               in varchar2
 ,p_rgr_attribute2_o               in varchar2
 ,p_rgr_attribute3_o               in varchar2
 ,p_rgr_attribute4_o               in varchar2
 ,p_rgr_attribute5_o               in varchar2
 ,p_rgr_attribute6_o               in varchar2
 ,p_rgr_attribute7_o               in varchar2
 ,p_rgr_attribute8_o               in varchar2
 ,p_rgr_attribute9_o               in varchar2
 ,p_rgr_attribute10_o              in varchar2
 ,p_rgr_attribute11_o              in varchar2
 ,p_rgr_attribute12_o              in varchar2
 ,p_rgr_attribute13_o              in varchar2
 ,p_rgr_attribute14_o              in varchar2
 ,p_rgr_attribute15_o              in varchar2
 ,p_rgr_attribute16_o              in varchar2
 ,p_rgr_attribute17_o              in varchar2
 ,p_rgr_attribute18_o              in varchar2
 ,p_rgr_attribute19_o              in varchar2
 ,p_rgr_attribute20_o              in varchar2
 ,p_rgr_attribute21_o              in varchar2
 ,p_rgr_attribute22_o              in varchar2
 ,p_rgr_attribute23_o              in varchar2
 ,p_rgr_attribute24_o              in varchar2
 ,p_rgr_attribute25_o              in varchar2
 ,p_rgr_attribute26_o              in varchar2
 ,p_rgr_attribute27_o              in varchar2
 ,p_rgr_attribute28_o              in varchar2
 ,p_rgr_attribute29_o              in varchar2
 ,p_rgr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_rgr_rkd;

/
