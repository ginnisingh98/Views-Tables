--------------------------------------------------------
--  DDL for Package BEN_PGR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PGR_RKD" AUTHID CURRENT_USER as
/* $Header: bepgrrhi.pkh 120.0.12010000.1 2008/07/29 12:49:35 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ppl_grp_rt_id                  in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_people_group_id_o              in number
 ,p_business_group_id_o            in number
 ,p_pgr_attribute_category_o       in varchar2
 ,p_pgr_attribute1_o               in varchar2
 ,p_pgr_attribute2_o               in varchar2
 ,p_pgr_attribute3_o               in varchar2
 ,p_pgr_attribute4_o               in varchar2
 ,p_pgr_attribute5_o               in varchar2
 ,p_pgr_attribute6_o               in varchar2
 ,p_pgr_attribute7_o               in varchar2
 ,p_pgr_attribute8_o               in varchar2
 ,p_pgr_attribute9_o               in varchar2
 ,p_pgr_attribute10_o              in varchar2
 ,p_pgr_attribute11_o              in varchar2
 ,p_pgr_attribute12_o              in varchar2
 ,p_pgr_attribute13_o              in varchar2
 ,p_pgr_attribute14_o              in varchar2
 ,p_pgr_attribute15_o              in varchar2
 ,p_pgr_attribute16_o              in varchar2
 ,p_pgr_attribute17_o              in varchar2
 ,p_pgr_attribute18_o              in varchar2
 ,p_pgr_attribute19_o              in varchar2
 ,p_pgr_attribute20_o              in varchar2
 ,p_pgr_attribute21_o              in varchar2
 ,p_pgr_attribute22_o              in varchar2
 ,p_pgr_attribute23_o              in varchar2
 ,p_pgr_attribute24_o              in varchar2
 ,p_pgr_attribute25_o              in varchar2
 ,p_pgr_attribute26_o              in varchar2
 ,p_pgr_attribute27_o              in varchar2
 ,p_pgr_attribute28_o              in varchar2
 ,p_pgr_attribute29_o              in varchar2
 ,p_pgr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_pgr_rkd;

/
