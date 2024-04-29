--------------------------------------------------------
--  DDL for Package BEN_PGC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PGC_RKI" AUTHID CURRENT_USER as
/* $Header: bepgcrhi.pkh 120.0 2005/05/28 10:45:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_pgm_dpnt_cvg_ctfn_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_pgm_id                         in number
 ,p_lack_ctfn_sspnd_enrt_flag      in varchar2
 ,p_ctfn_rqd_when_rl               in number
 ,p_pfd_flag                       in varchar2
 ,p_dpnt_cvg_ctfn_typ_cd           in varchar2
 ,p_rqd_flag                       in varchar2
 ,p_rlshp_typ_cd                   in varchar2
 ,p_pgc_attribute_category         in varchar2
 ,p_pgc_attribute1                 in varchar2
 ,p_pgc_attribute2                 in varchar2
 ,p_pgc_attribute3                 in varchar2
 ,p_pgc_attribute4                 in varchar2
 ,p_pgc_attribute5                 in varchar2
 ,p_pgc_attribute6                 in varchar2
 ,p_pgc_attribute7                 in varchar2
 ,p_pgc_attribute8                 in varchar2
 ,p_pgc_attribute9                 in varchar2
 ,p_pgc_attribute10                in varchar2
 ,p_pgc_attribute11                in varchar2
 ,p_pgc_attribute12                in varchar2
 ,p_pgc_attribute13                in varchar2
 ,p_pgc_attribute14                in varchar2
 ,p_pgc_attribute15                in varchar2
 ,p_pgc_attribute16                in varchar2
 ,p_pgc_attribute17                in varchar2
 ,p_pgc_attribute18                in varchar2
 ,p_pgc_attribute19                in varchar2
 ,p_pgc_attribute20                in varchar2
 ,p_pgc_attribute21                in varchar2
 ,p_pgc_attribute22                in varchar2
 ,p_pgc_attribute23                in varchar2
 ,p_pgc_attribute24                in varchar2
 ,p_pgc_attribute25                in varchar2
 ,p_pgc_attribute26                in varchar2
 ,p_pgc_attribute27                in varchar2
 ,p_pgc_attribute28                in varchar2
 ,p_pgc_attribute29                in varchar2
 ,p_pgc_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_pgc_rki;

 

/
