--------------------------------------------------------
--  DDL for Package BEN_PAT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PAT_RKU" AUTHID CURRENT_USER as
/* $Header: bepatrhi.pkh 120.1 2007/03/29 07:05:30 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_popl_actn_typ_id               in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_actn_typ_due_dt_cd             in varchar2
 ,p_actn_typ_due_dt_rl             in number
 ,p_actn_typ_id                    in number
 ,p_pgm_id                         in number
 ,p_pl_id                          in number
 ,p_business_group_id              in number
 ,p_pat_attribute_category         in varchar2
 ,p_pat_attribute1                 in varchar2
 ,p_pat_attribute2                 in varchar2
 ,p_pat_attribute3                 in varchar2
 ,p_pat_attribute4                 in varchar2
 ,p_pat_attribute5                 in varchar2
 ,p_pat_attribute6                 in varchar2
 ,p_pat_attribute7                 in varchar2
 ,p_pat_attribute8                 in varchar2
 ,p_pat_attribute9                 in varchar2
 ,p_pat_attribute10                in varchar2
 ,p_pat_attribute11                in varchar2
 ,p_pat_attribute12                in varchar2
 ,p_pat_attribute13                in varchar2
 ,p_pat_attribute14                in varchar2
 ,p_pat_attribute15                in varchar2
 ,p_pat_attribute16                in varchar2
 ,p_pat_attribute17                in varchar2
 ,p_pat_attribute18                in varchar2
 ,p_pat_attribute19                in varchar2
 ,p_pat_attribute20                in varchar2
 ,p_pat_attribute21                in varchar2
 ,p_pat_attribute22                in varchar2
 ,p_pat_attribute23                in varchar2
 ,p_pat_attribute24                in varchar2
 ,p_pat_attribute25                in varchar2
 ,p_pat_attribute26                in varchar2
 ,p_pat_attribute27                in varchar2
 ,p_pat_attribute28                in varchar2
 ,p_pat_attribute29                in varchar2
 ,p_pat_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_mandatory                     in varchar2
 ,p_once_or_always                in varchar2
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_actn_typ_due_dt_cd_o           in varchar2
 ,p_actn_typ_due_dt_rl_o           in number
 ,p_actn_typ_id_o                  in number
 ,p_pgm_id_o                       in number
 ,p_pl_id_o                        in number
 ,p_business_group_id_o            in number
 ,p_pat_attribute_category_o       in varchar2
 ,p_pat_attribute1_o               in varchar2
 ,p_pat_attribute2_o               in varchar2
 ,p_pat_attribute3_o               in varchar2
 ,p_pat_attribute4_o               in varchar2
 ,p_pat_attribute5_o               in varchar2
 ,p_pat_attribute6_o               in varchar2
 ,p_pat_attribute7_o               in varchar2
 ,p_pat_attribute8_o               in varchar2
 ,p_pat_attribute9_o               in varchar2
 ,p_pat_attribute10_o              in varchar2
 ,p_pat_attribute11_o              in varchar2
 ,p_pat_attribute12_o              in varchar2
 ,p_pat_attribute13_o              in varchar2
 ,p_pat_attribute14_o              in varchar2
 ,p_pat_attribute15_o              in varchar2
 ,p_pat_attribute16_o              in varchar2
 ,p_pat_attribute17_o              in varchar2
 ,p_pat_attribute18_o              in varchar2
 ,p_pat_attribute19_o              in varchar2
 ,p_pat_attribute20_o              in varchar2
 ,p_pat_attribute21_o              in varchar2
 ,p_pat_attribute22_o              in varchar2
 ,p_pat_attribute23_o              in varchar2
 ,p_pat_attribute24_o              in varchar2
 ,p_pat_attribute25_o              in varchar2
 ,p_pat_attribute26_o              in varchar2
 ,p_pat_attribute27_o              in varchar2
 ,p_pat_attribute28_o              in varchar2
 ,p_pat_attribute29_o              in varchar2
 ,p_pat_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_mandatory_o                    in varchar2
 ,p_once_or_always_o               in varchar2

  );
--
end ben_pat_rku;

/
