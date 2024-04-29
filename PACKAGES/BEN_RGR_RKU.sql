--------------------------------------------------------
--  DDL for Package BEN_RGR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RGR_RKU" AUTHID CURRENT_USER as
/* $Header: bergrrhi.pkh 120.0.12010000.1 2008/07/29 13:01:46 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_popl_rptg_grp_id               in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_rptg_grp_id                    in number
 ,p_pgm_id                         in number
 ,p_pl_id                          in number
 ,p_ordr_num                       in number                     --iRec
 ,p_rgr_attribute_category         in varchar2
 ,p_rgr_attribute1                 in varchar2
 ,p_rgr_attribute2                 in varchar2
 ,p_rgr_attribute3                 in varchar2
 ,p_rgr_attribute4                 in varchar2
 ,p_rgr_attribute5                 in varchar2
 ,p_rgr_attribute6                 in varchar2
 ,p_rgr_attribute7                 in varchar2
 ,p_rgr_attribute8                 in varchar2
 ,p_rgr_attribute9                 in varchar2
 ,p_rgr_attribute10                in varchar2
 ,p_rgr_attribute11                in varchar2
 ,p_rgr_attribute12                in varchar2
 ,p_rgr_attribute13                in varchar2
 ,p_rgr_attribute14                in varchar2
 ,p_rgr_attribute15                in varchar2
 ,p_rgr_attribute16                in varchar2
 ,p_rgr_attribute17                in varchar2
 ,p_rgr_attribute18                in varchar2
 ,p_rgr_attribute19                in varchar2
 ,p_rgr_attribute20                in varchar2
 ,p_rgr_attribute21                in varchar2
 ,p_rgr_attribute22                in varchar2
 ,p_rgr_attribute23                in varchar2
 ,p_rgr_attribute24                in varchar2
 ,p_rgr_attribute25                in varchar2
 ,p_rgr_attribute26                in varchar2
 ,p_rgr_attribute27                in varchar2
 ,p_rgr_attribute28                in varchar2
 ,p_rgr_attribute29                in varchar2
 ,p_rgr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_rptg_grp_id_o                  in number
 ,p_pgm_id_o                       in number
 ,p_pl_id_o                        in number
 ,p_ordr_num_o                     in number                   --iRec
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
end ben_rgr_rku;

/
