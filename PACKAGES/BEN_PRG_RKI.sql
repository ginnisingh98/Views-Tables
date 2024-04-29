--------------------------------------------------------
--  DDL for Package BEN_PRG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRG_RKI" AUTHID CURRENT_USER as
/* $Header: beprgrhi.pkh 120.0.12010000.1 2008/07/29 12:54:15 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_pl_regn_id                     in number
 ,p_effective_end_date             in date
 ,p_effective_start_date           in date
 ,p_business_group_id              in number
 ,p_regn_id                        in number
 ,p_pl_id                          in number
 ,p_rptg_grp_id                    in number
 ,p_hghly_compd_det_rl             in number
 ,p_key_ee_det_rl                  in number
 ,p_cntr_nndscrn_rl                in number
 ,p_cvg_nndscrn_rl                 in number
 ,p_five_pct_ownr_rl               in number
 ,p_regy_pl_typ_cd                 in varchar2
 ,p_prg_attribute_category         in varchar2
 ,p_prg_attribute1                 in varchar2
 ,p_prg_attribute2                 in varchar2
 ,p_prg_attribute3                 in varchar2
 ,p_prg_attribute4                 in varchar2
 ,p_prg_attribute5                 in varchar2
 ,p_prg_attribute6                 in varchar2
 ,p_prg_attribute7                 in varchar2
 ,p_prg_attribute8                 in varchar2
 ,p_prg_attribute9                 in varchar2
 ,p_prg_attribute10                in varchar2
 ,p_prg_attribute11                in varchar2
 ,p_prg_attribute12                in varchar2
 ,p_prg_attribute13                in varchar2
 ,p_prg_attribute14                in varchar2
 ,p_prg_attribute15                in varchar2
 ,p_prg_attribute16                in varchar2
 ,p_prg_attribute17                in varchar2
 ,p_prg_attribute18                in varchar2
 ,p_prg_attribute19                in varchar2
 ,p_prg_attribute20                in varchar2
 ,p_prg_attribute21                in varchar2
 ,p_prg_attribute22                in varchar2
 ,p_prg_attribute23                in varchar2
 ,p_prg_attribute24                in varchar2
 ,p_prg_attribute25                in varchar2
 ,p_prg_attribute26                in varchar2
 ,p_prg_attribute27                in varchar2
 ,p_prg_attribute28                in varchar2
 ,p_prg_attribute29                in varchar2
 ,p_prg_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_prg_rki;

/
