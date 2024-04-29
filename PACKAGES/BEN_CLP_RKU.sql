--------------------------------------------------------
--  DDL for Package BEN_CLP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CLP_RKU" AUTHID CURRENT_USER as
/* $Header: beclprhi.pkh 120.0 2005/05/28 01:05:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_clpse_lf_evt_id                in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_seq                            in number
 ,p_ler1_id                        in number
 ,p_bool1_cd                       in varchar2
 ,p_ler2_id                        in number
 ,p_bool2_cd                       in varchar2
 ,p_ler3_id                        in number
 ,p_bool3_cd                       in varchar2
 ,p_ler4_id                        in number
 ,p_bool4_cd                       in varchar2
 ,p_ler5_id                        in number
 ,p_bool5_cd                       in varchar2
 ,p_ler6_id                        in number
 ,p_bool6_cd                       in varchar2
 ,p_ler7_id                        in number
 ,p_bool7_cd                       in varchar2
 ,p_ler8_id                        in number
 ,p_bool8_cd                       in varchar2
 ,p_ler9_id                        in number
 ,p_bool9_cd                       in varchar2
 ,p_ler10_id                       in number
 ,p_eval_cd                        in varchar2
 ,p_eval_rl                        in number
 ,p_tlrnc_dys_num                  in number
 ,p_eval_ler_id                    in number
 ,p_eval_ler_det_cd                in varchar2
 ,p_eval_ler_det_rl                in number
 ,p_clp_attribute_category         in varchar2
 ,p_clp_attribute1                 in varchar2
 ,p_clp_attribute2                 in varchar2
 ,p_clp_attribute3                 in varchar2
 ,p_clp_attribute4                 in varchar2
 ,p_clp_attribute5                 in varchar2
 ,p_clp_attribute6                 in varchar2
 ,p_clp_attribute7                 in varchar2
 ,p_clp_attribute8                 in varchar2
 ,p_clp_attribute9                 in varchar2
 ,p_clp_attribute10                in varchar2
 ,p_clp_attribute11                in varchar2
 ,p_clp_attribute12                in varchar2
 ,p_clp_attribute13                in varchar2
 ,p_clp_attribute14                in varchar2
 ,p_clp_attribute15                in varchar2
 ,p_clp_attribute16                in varchar2
 ,p_clp_attribute17                in varchar2
 ,p_clp_attribute18                in varchar2
 ,p_clp_attribute19                in varchar2
 ,p_clp_attribute20                in varchar2
 ,p_clp_attribute21                in varchar2
 ,p_clp_attribute22                in varchar2
 ,p_clp_attribute23                in varchar2
 ,p_clp_attribute24                in varchar2
 ,p_clp_attribute25                in varchar2
 ,p_clp_attribute26                in varchar2
 ,p_clp_attribute27                in varchar2
 ,p_clp_attribute28                in varchar2
 ,p_clp_attribute29                in varchar2
 ,p_clp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_seq_o                          in number
 ,p_ler1_id_o                      in number
 ,p_bool1_cd_o                     in varchar2
 ,p_ler2_id_o                      in number
 ,p_bool2_cd_o                     in varchar2
 ,p_ler3_id_o                      in number
 ,p_bool3_cd_o                     in varchar2
 ,p_ler4_id_o                      in number
 ,p_bool4_cd_o                     in varchar2
 ,p_ler5_id_o                      in number
 ,p_bool5_cd_o                     in varchar2
 ,p_ler6_id_o                      in number
 ,p_bool6_cd_o                     in varchar2
 ,p_ler7_id_o                      in number
 ,p_bool7_cd_o                     in varchar2
 ,p_ler8_id_o                      in number
 ,p_bool8_cd_o                     in varchar2
 ,p_ler9_id_o                      in number
 ,p_bool9_cd_o                     in varchar2
 ,p_ler10_id_o                     in number
 ,p_eval_cd_o                      in varchar2
 ,p_eval_rl_o                      in number
 ,p_tlrnc_dys_num_o                in number
 ,p_eval_ler_id_o                  in number
 ,p_eval_ler_det_cd_o              in varchar2
 ,p_eval_ler_det_rl_o              in number
 ,p_clp_attribute_category_o       in varchar2
 ,p_clp_attribute1_o               in varchar2
 ,p_clp_attribute2_o               in varchar2
 ,p_clp_attribute3_o               in varchar2
 ,p_clp_attribute4_o               in varchar2
 ,p_clp_attribute5_o               in varchar2
 ,p_clp_attribute6_o               in varchar2
 ,p_clp_attribute7_o               in varchar2
 ,p_clp_attribute8_o               in varchar2
 ,p_clp_attribute9_o               in varchar2
 ,p_clp_attribute10_o              in varchar2
 ,p_clp_attribute11_o              in varchar2
 ,p_clp_attribute12_o              in varchar2
 ,p_clp_attribute13_o              in varchar2
 ,p_clp_attribute14_o              in varchar2
 ,p_clp_attribute15_o              in varchar2
 ,p_clp_attribute16_o              in varchar2
 ,p_clp_attribute17_o              in varchar2
 ,p_clp_attribute18_o              in varchar2
 ,p_clp_attribute19_o              in varchar2
 ,p_clp_attribute20_o              in varchar2
 ,p_clp_attribute21_o              in varchar2
 ,p_clp_attribute22_o              in varchar2
 ,p_clp_attribute23_o              in varchar2
 ,p_clp_attribute24_o              in varchar2
 ,p_clp_attribute25_o              in varchar2
 ,p_clp_attribute26_o              in varchar2
 ,p_clp_attribute27_o              in varchar2
 ,p_clp_attribute28_o              in varchar2
 ,p_clp_attribute29_o              in varchar2
 ,p_clp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_clp_rku;

 

/
