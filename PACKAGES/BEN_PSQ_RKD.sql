--------------------------------------------------------
--  DDL for Package BEN_PSQ_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PSQ_RKD" AUTHID CURRENT_USER as
/* $Header: bepsqrhi.pkh 120.0 2005/05/28 11:20:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_pymt_sched_py_freq_id          in number
 ,p_py_freq_cd_o                   in varchar2
 ,p_dflt_flag_o                    in varchar2
 ,p_business_group_id_o            in number
 ,p_acty_rt_pymt_sched_id_o        in number
 ,p_psq_attribute_category_o       in varchar2
 ,p_psq_attribute1_o               in varchar2
 ,p_psq_attribute2_o               in varchar2
 ,p_psq_attribute3_o               in varchar2
 ,p_psq_attribute4_o               in varchar2
 ,p_psq_attribute5_o               in varchar2
 ,p_psq_attribute6_o               in varchar2
 ,p_psq_attribute7_o               in varchar2
 ,p_psq_attribute8_o               in varchar2
 ,p_psq_attribute9_o               in varchar2
 ,p_psq_attribute10_o              in varchar2
 ,p_psq_attribute11_o              in varchar2
 ,p_psq_attribute12_o              in varchar2
 ,p_psq_attribute13_o              in varchar2
 ,p_psq_attribute14_o              in varchar2
 ,p_psq_attribute15_o              in varchar2
 ,p_psq_attribute16_o              in varchar2
 ,p_psq_attribute17_o              in varchar2
 ,p_psq_attribute18_o              in varchar2
 ,p_psq_attribute19_o              in varchar2
 ,p_psq_attribute20_o              in varchar2
 ,p_psq_attribute21_o              in varchar2
 ,p_psq_attribute22_o              in varchar2
 ,p_psq_attribute23_o              in varchar2
 ,p_psq_attribute24_o              in varchar2
 ,p_psq_attribute25_o              in varchar2
 ,p_psq_attribute26_o              in varchar2
 ,p_psq_attribute27_o              in varchar2
 ,p_psq_attribute28_o              in varchar2
 ,p_psq_attribute29_o              in varchar2
 ,p_psq_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_psq_rkd;

 

/
