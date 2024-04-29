--------------------------------------------------------
--  DDL for Package BEN_PBC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PBC_RKD" AUTHID CURRENT_USER as
/* $Header: bepbcrhi.pkh 120.0 2005/05/28 10:04:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_pl_bnf_ctfn_prvdd_id           in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_bnf_ctfn_typ_cd_o              in varchar2
 ,p_bnf_ctfn_recd_dt_o             in date
 ,p_bnf_ctfn_rqd_flag_o            in varchar2
 ,p_pl_bnf_id_o                    in number
 ,p_prtt_enrt_actn_id_o            in number
 ,p_business_group_id_o            in number
 ,p_pbc_attribute_category_o       in varchar2
 ,p_pbc_attribute1_o               in varchar2
 ,p_pbc_attribute2_o               in varchar2
 ,p_pbc_attribute3_o               in varchar2
 ,p_pbc_attribute4_o               in varchar2
 ,p_pbc_attribute5_o               in varchar2
 ,p_pbc_attribute6_o               in varchar2
 ,p_pbc_attribute7_o               in varchar2
 ,p_pbc_attribute8_o               in varchar2
 ,p_pbc_attribute9_o               in varchar2
 ,p_pbc_attribute10_o              in varchar2
 ,p_pbc_attribute11_o              in varchar2
 ,p_pbc_attribute12_o              in varchar2
 ,p_pbc_attribute13_o              in varchar2
 ,p_pbc_attribute14_o              in varchar2
 ,p_pbc_attribute15_o              in varchar2
 ,p_pbc_attribute16_o              in varchar2
 ,p_pbc_attribute17_o              in varchar2
 ,p_pbc_attribute18_o              in varchar2
 ,p_pbc_attribute19_o              in varchar2
 ,p_pbc_attribute20_o              in varchar2
 ,p_pbc_attribute21_o              in varchar2
 ,p_pbc_attribute22_o              in varchar2
 ,p_pbc_attribute23_o              in varchar2
 ,p_pbc_attribute24_o              in varchar2
 ,p_pbc_attribute25_o              in varchar2
 ,p_pbc_attribute26_o              in varchar2
 ,p_pbc_attribute27_o              in varchar2
 ,p_pbc_attribute28_o              in varchar2
 ,p_pbc_attribute29_o              in varchar2
 ,p_pbc_attribute30_o              in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
  );
--
end ben_pbc_rkd;

 

/
