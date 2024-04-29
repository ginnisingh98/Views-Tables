--------------------------------------------------------
--  DDL for Package BEN_PYD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PYD_RKI" AUTHID CURRENT_USER as
/* $Header: bepydrhi.pkh 120.0.12010000.1 2008/07/29 12:59:01 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_ptip_dpnt_cvg_ctfn_id          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_ptip_id                        in number
 ,p_pfd_flag                       in varchar2
 ,p_lack_ctfn_sspnd_enrt_flag      in varchar2
 ,p_ctfn_rqd_when_rl               in number
 ,p_dpnt_cvg_ctfn_typ_cd           in varchar2
 ,p_rlshp_typ_cd                   in varchar2
 ,p_rqd_flag                       in varchar2
 ,p_pyd_attribute_category         in varchar2
 ,p_pyd_attribute1                 in varchar2
 ,p_pyd_attribute2                 in varchar2
 ,p_pyd_attribute3                 in varchar2
 ,p_pyd_attribute4                 in varchar2
 ,p_pyd_attribute5                 in varchar2
 ,p_pyd_attribute6                 in varchar2
 ,p_pyd_attribute7                 in varchar2
 ,p_pyd_attribute8                 in varchar2
 ,p_pyd_attribute9                 in varchar2
 ,p_pyd_attribute10                in varchar2
 ,p_pyd_attribute11                in varchar2
 ,p_pyd_attribute12                in varchar2
 ,p_pyd_attribute13                in varchar2
 ,p_pyd_attribute14                in varchar2
 ,p_pyd_attribute15                in varchar2
 ,p_pyd_attribute16                in varchar2
 ,p_pyd_attribute17                in varchar2
 ,p_pyd_attribute18                in varchar2
 ,p_pyd_attribute19                in varchar2
 ,p_pyd_attribute20                in varchar2
 ,p_pyd_attribute21                in varchar2
 ,p_pyd_attribute22                in varchar2
 ,p_pyd_attribute23                in varchar2
 ,p_pyd_attribute24                in varchar2
 ,p_pyd_attribute25                in varchar2
 ,p_pyd_attribute26                in varchar2
 ,p_pyd_attribute27                in varchar2
 ,p_pyd_attribute28                in varchar2
 ,p_pyd_attribute29                in varchar2
 ,p_pyd_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_pyd_rki;

/
