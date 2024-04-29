--------------------------------------------------------
--  DDL for Package BEN_PEA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PEA_RKD" AUTHID CURRENT_USER as
/* $Header: bepearhi.pkh 120.0 2005/05/28 10:31:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_prtt_enrt_actn_id              in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_cmpltd_dt_o                    in date
 ,p_due_dt_o                       in date
 ,p_rqd_flag_o                     in varchar2
 ,p_prtt_enrt_rslt_id_o            in number
 ,p_per_in_ler_id_o            in number
 ,p_actn_typ_id_o                  in number
 ,p_elig_cvrd_dpnt_id_o            in number
 ,p_pl_bnf_id_o                    in number
 ,p_business_group_id_o            in number
 ,p_pea_attribute_category_o       in varchar2
 ,p_pea_attribute1_o               in varchar2
 ,p_pea_attribute2_o               in varchar2
 ,p_pea_attribute3_o               in varchar2
 ,p_pea_attribute4_o               in varchar2
 ,p_pea_attribute5_o               in varchar2
 ,p_pea_attribute6_o               in varchar2
 ,p_pea_attribute7_o               in varchar2
 ,p_pea_attribute8_o               in varchar2
 ,p_pea_attribute9_o               in varchar2
 ,p_pea_attribute10_o              in varchar2
 ,p_pea_attribute11_o              in varchar2
 ,p_pea_attribute12_o              in varchar2
 ,p_pea_attribute13_o              in varchar2
 ,p_pea_attribute14_o              in varchar2
 ,p_pea_attribute15_o              in varchar2
 ,p_pea_attribute16_o              in varchar2
 ,p_pea_attribute17_o              in varchar2
 ,p_pea_attribute18_o              in varchar2
 ,p_pea_attribute19_o              in varchar2
 ,p_pea_attribute20_o              in varchar2
 ,p_pea_attribute21_o              in varchar2
 ,p_pea_attribute22_o              in varchar2
 ,p_pea_attribute23_o              in varchar2
 ,p_pea_attribute24_o              in varchar2
 ,p_pea_attribute25_o              in varchar2
 ,p_pea_attribute26_o              in varchar2
 ,p_pea_attribute27_o              in varchar2
 ,p_pea_attribute28_o              in varchar2
 ,p_pea_attribute29_o              in varchar2
 ,p_pea_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_pea_rkd;

 

/
