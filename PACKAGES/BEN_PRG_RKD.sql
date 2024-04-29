--------------------------------------------------------
--  DDL for Package BEN_PRG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRG_RKD" AUTHID CURRENT_USER as
/* $Header: beprgrhi.pkh 120.0.12010000.1 2008/07/29 12:54:15 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_pl_regn_id                     in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_end_date_o           in date
 ,p_effective_start_date_o         in date
 ,p_business_group_id_o            in number
 ,p_regn_id_o                      in number
 ,p_pl_id_o                        in number
 ,p_rptg_grp_id_o                  in number
 ,p_hghly_compd_det_rl_o           in number
 ,p_key_ee_det_rl_o                in number
 ,p_cntr_nndscrn_rl_o              in number
 ,p_cvg_nndscrn_rl_o               in number
 ,p_five_pct_ownr_rl_o             in number
 ,p_regy_pl_typ_cd_o               in varchar2
 ,p_prg_attribute_category_o       in varchar2
 ,p_prg_attribute1_o               in varchar2
 ,p_prg_attribute2_o               in varchar2
 ,p_prg_attribute3_o               in varchar2
 ,p_prg_attribute4_o               in varchar2
 ,p_prg_attribute5_o               in varchar2
 ,p_prg_attribute6_o               in varchar2
 ,p_prg_attribute7_o               in varchar2
 ,p_prg_attribute8_o               in varchar2
 ,p_prg_attribute9_o               in varchar2
 ,p_prg_attribute10_o              in varchar2
 ,p_prg_attribute11_o              in varchar2
 ,p_prg_attribute12_o              in varchar2
 ,p_prg_attribute13_o              in varchar2
 ,p_prg_attribute14_o              in varchar2
 ,p_prg_attribute15_o              in varchar2
 ,p_prg_attribute16_o              in varchar2
 ,p_prg_attribute17_o              in varchar2
 ,p_prg_attribute18_o              in varchar2
 ,p_prg_attribute19_o              in varchar2
 ,p_prg_attribute20_o              in varchar2
 ,p_prg_attribute21_o              in varchar2
 ,p_prg_attribute22_o              in varchar2
 ,p_prg_attribute23_o              in varchar2
 ,p_prg_attribute24_o              in varchar2
 ,p_prg_attribute25_o              in varchar2
 ,p_prg_attribute26_o              in varchar2
 ,p_prg_attribute27_o              in varchar2
 ,p_prg_attribute28_o              in varchar2
 ,p_prg_attribute29_o              in varchar2
 ,p_prg_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_prg_rkd;

/
