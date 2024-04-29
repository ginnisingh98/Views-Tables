--------------------------------------------------------
--  DDL for Package BEN_DSQ_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DSQ_RKD" AUTHID CURRENT_USER as
/* $Header: bedsqrhi.pkh 120.0 2005/05/28 01:41:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ded_sched_py_freq_id           in number
 ,p_py_freq_cd_o                   in varchar2
 ,p_dflt_flag_o                    in varchar2
 ,p_acty_rt_ded_sched_id_o         in number
 ,p_business_group_id_o            in number
 ,p_dsq_attribute_category_o       in varchar2
 ,p_dsq_attribute1_o               in varchar2
 ,p_dsq_attribute2_o               in varchar2
 ,p_dsq_attribute3_o               in varchar2
 ,p_dsq_attribute4_o               in varchar2
 ,p_dsq_attribute5_o               in varchar2
 ,p_dsq_attribute6_o               in varchar2
 ,p_dsq_attribute7_o               in varchar2
 ,p_dsq_attribute8_o               in varchar2
 ,p_dsq_attribute9_o               in varchar2
 ,p_dsq_attribute10_o              in varchar2
 ,p_dsq_attribute11_o              in varchar2
 ,p_dsq_attribute12_o              in varchar2
 ,p_dsq_attribute13_o              in varchar2
 ,p_dsq_attribute14_o              in varchar2
 ,p_dsq_attribute15_o              in varchar2
 ,p_dsq_attribute16_o              in varchar2
 ,p_dsq_attribute17_o              in varchar2
 ,p_dsq_attribute18_o              in varchar2
 ,p_dsq_attribute19_o              in varchar2
 ,p_dsq_attribute20_o              in varchar2
 ,p_dsq_attribute21_o              in varchar2
 ,p_dsq_attribute22_o              in varchar2
 ,p_dsq_attribute23_o              in varchar2
 ,p_dsq_attribute24_o              in varchar2
 ,p_dsq_attribute25_o              in varchar2
 ,p_dsq_attribute26_o              in varchar2
 ,p_dsq_attribute27_o              in varchar2
 ,p_dsq_attribute28_o              in varchar2
 ,p_dsq_attribute29_o              in varchar2
 ,p_dsq_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_dsq_rkd;

 

/
