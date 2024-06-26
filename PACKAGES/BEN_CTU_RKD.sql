--------------------------------------------------------
--  DDL for Package BEN_CTU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CTU_RKD" AUTHID CURRENT_USER as
/* $Header: becturhi.pkh 120.0 2005/05/28 01:28:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
 (p_cm_typ_usg_id                  in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_all_r_any_cd_o                 in varchar2
 ,p_cm_usg_rl_o                    in number
 ,p_descr_text_o                   in varchar2
 ,p_pgm_id_o                       in number
 ,p_pl_id_o                        in number
 ,p_pl_typ_id_o                    in number
 ,p_enrt_perd_id_o                 in number
 ,p_actn_typ_id_o                  in number
 ,p_cm_typ_id_o                    in number
 ,p_ler_id_o                       in number
 ,p_business_group_id_o            in number
 ,p_ctu_attribute_category_o       in varchar2
 ,p_ctu_attribute1_o               in varchar2
 ,p_ctu_attribute2_o               in varchar2
 ,p_ctu_attribute3_o               in varchar2
 ,p_ctu_attribute4_o               in varchar2
 ,p_ctu_attribute5_o               in varchar2
 ,p_ctu_attribute6_o               in varchar2
 ,p_ctu_attribute7_o               in varchar2
 ,p_ctu_attribute8_o               in varchar2
 ,p_ctu_attribute9_o               in varchar2
 ,p_ctu_attribute10_o              in varchar2
 ,p_ctu_attribute11_o              in varchar2
 ,p_ctu_attribute12_o              in varchar2
 ,p_ctu_attribute13_o              in varchar2
 ,p_ctu_attribute14_o              in varchar2
 ,p_ctu_attribute15_o              in varchar2
 ,p_ctu_attribute16_o              in varchar2
 ,p_ctu_attribute17_o              in varchar2
 ,p_ctu_attribute18_o              in varchar2
 ,p_ctu_attribute19_o              in varchar2
 ,p_ctu_attribute20_o              in varchar2
 ,p_ctu_attribute21_o              in varchar2
 ,p_ctu_attribute22_o              in varchar2
 ,p_ctu_attribute23_o              in varchar2
 ,p_ctu_attribute24_o              in varchar2
 ,p_ctu_attribute25_o              in varchar2
 ,p_ctu_attribute26_o              in varchar2
 ,p_ctu_attribute27_o              in varchar2
 ,p_ctu_attribute28_o              in varchar2
 ,p_ctu_attribute29_o              in varchar2
 ,p_ctu_attribute30_o              in varchar2
 ,p_object_version_number_o        in number);
--
end ben_ctu_rkd;

 

/
