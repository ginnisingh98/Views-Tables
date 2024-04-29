--------------------------------------------------------
--  DDL for Package BEN_LCC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LCC_RKI" AUTHID CURRENT_USER as
/* $Header: belccrhi.pkh 120.0 2005/05/28 03:17:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_ler_chg_dpnt_cvg_ctfn_id       in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_dpnt_cvg_ctfn_typ_cd           in varchar2
 ,p_rlshp_typ_cd		   in varchar2
 ,p_ctfn_rqd_when_rl		   in number
 ,p_lack_ctfn_sspnd_enrt_flag	   in varchar2
 ,p_rqd_flag			   in varchar2
 ,p_ler_chg_dpnt_cvg_id            in number
 ,p_business_group_id              in number
 ,p_lcc_attribute_category         in varchar2
 ,p_lcc_attribute1                 in varchar2
 ,p_lcc_attribute2                 in varchar2
 ,p_lcc_attribute3                 in varchar2
 ,p_lcc_attribute4                 in varchar2
 ,p_lcc_attribute5                 in varchar2
 ,p_lcc_attribute6                 in varchar2
 ,p_lcc_attribute7                 in varchar2
 ,p_lcc_attribute8                 in varchar2
 ,p_lcc_attribute9                 in varchar2
 ,p_lcc_attribute10                in varchar2
 ,p_lcc_attribute11                in varchar2
 ,p_lcc_attribute12                in varchar2
 ,p_lcc_attribute13                in varchar2
 ,p_lcc_attribute14                in varchar2
 ,p_lcc_attribute15                in varchar2
 ,p_lcc_attribute16                in varchar2
 ,p_lcc_attribute17                in varchar2
 ,p_lcc_attribute18                in varchar2
 ,p_lcc_attribute19                in varchar2
 ,p_lcc_attribute20                in varchar2
 ,p_lcc_attribute21                in varchar2
 ,p_lcc_attribute22                in varchar2
 ,p_lcc_attribute23                in varchar2
 ,p_lcc_attribute24                in varchar2
 ,p_lcc_attribute25                in varchar2
 ,p_lcc_attribute26                in varchar2
 ,p_lcc_attribute27                in varchar2
 ,p_lcc_attribute28                in varchar2
 ,p_lcc_attribute29                in varchar2
 ,p_lcc_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_lcc_rki;

 

/
