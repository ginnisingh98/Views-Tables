--------------------------------------------------------
--  DDL for Package BEN_ABC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ABC_RKD" AUTHID CURRENT_USER as
/* $Header: beabcrhi.pkh 120.0.12010000.1 2008/07/29 10:46:43 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_acty_base_rt_ctfn_id                   in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_enrt_ctfn_typ_cd_o             in varchar2
 ,p_ctfn_rqd_when_rl_o             in number
 ,p_rqd_flag_o                     in varchar2
 ,p_acty_base_rt_id_o                        in number
 ,p_business_group_id_o            in number
 ,p_abc_attribute_category_o       in varchar2
 ,p_abc_attribute1_o               in varchar2
 ,p_abc_attribute2_o               in varchar2
 ,p_abc_attribute3_o               in varchar2
 ,p_abc_attribute4_o               in varchar2
 ,p_abc_attribute5_o               in varchar2
 ,p_abc_attribute6_o               in varchar2
 ,p_abc_attribute7_o               in varchar2
 ,p_abc_attribute8_o               in varchar2
 ,p_abc_attribute9_o               in varchar2
 ,p_abc_attribute10_o              in varchar2
 ,p_abc_attribute11_o              in varchar2
 ,p_abc_attribute12_o              in varchar2
 ,p_abc_attribute13_o              in varchar2
 ,p_abc_attribute14_o              in varchar2
 ,p_abc_attribute15_o              in varchar2
 ,p_abc_attribute16_o              in varchar2
 ,p_abc_attribute17_o              in varchar2
 ,p_abc_attribute18_o              in varchar2
 ,p_abc_attribute19_o              in varchar2
 ,p_abc_attribute20_o              in varchar2
 ,p_abc_attribute21_o              in varchar2
 ,p_abc_attribute22_o              in varchar2
 ,p_abc_attribute23_o              in varchar2
 ,p_abc_attribute24_o              in varchar2
 ,p_abc_attribute25_o              in varchar2
 ,p_abc_attribute26_o              in varchar2
 ,p_abc_attribute27_o              in varchar2
 ,p_abc_attribute28_o              in varchar2
 ,p_abc_attribute29_o              in varchar2
 ,p_abc_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_abc_rkd;

/
