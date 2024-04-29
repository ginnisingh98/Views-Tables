--------------------------------------------------------
--  DDL for Package BEN_PRB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRB_RKD" AUTHID CURRENT_USER as
/* $Header: beprbrhi.pkh 120.0.12010000.1 2008/07/29 12:53:20 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_pl_regy_bod_id                 in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_pl_id_o                        in number
 ,p_rptg_grp_id_o                  in number
 ,p_organization_id_o              in number
 ,p_quald_dt_o                     in date
 ,p_quald_flag_o                   in varchar2
 ,p_regy_pl_name_o                 in varchar2
 ,p_aprvd_trmn_dt_o                in date
 ,p_prb_attribute_category_o       in varchar2
 ,p_prb_attribute1_o               in varchar2
 ,p_prb_attribute2_o               in varchar2
 ,p_prb_attribute3_o               in varchar2
 ,p_prb_attribute4_o               in varchar2
 ,p_prb_attribute5_o               in varchar2
 ,p_prb_attribute6_o               in varchar2
 ,p_prb_attribute7_o               in varchar2
 ,p_prb_attribute8_o               in varchar2
 ,p_prb_attribute9_o               in varchar2
 ,p_prb_attribute10_o              in varchar2
 ,p_prb_attribute11_o              in varchar2
 ,p_prb_attribute12_o              in varchar2
 ,p_prb_attribute13_o              in varchar2
 ,p_prb_attribute14_o              in varchar2
 ,p_prb_attribute15_o              in varchar2
 ,p_prb_attribute16_o              in varchar2
 ,p_prb_attribute17_o              in varchar2
 ,p_prb_attribute18_o              in varchar2
 ,p_prb_attribute19_o              in varchar2
 ,p_prb_attribute20_o              in varchar2
 ,p_prb_attribute21_o              in varchar2
 ,p_prb_attribute22_o              in varchar2
 ,p_prb_attribute23_o              in varchar2
 ,p_prb_attribute24_o              in varchar2
 ,p_prb_attribute25_o              in varchar2
 ,p_prb_attribute26_o              in varchar2
 ,p_prb_attribute27_o              in varchar2
 ,p_prb_attribute28_o              in varchar2
 ,p_prb_attribute29_o              in varchar2
 ,p_prb_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_prb_rkd;

/
