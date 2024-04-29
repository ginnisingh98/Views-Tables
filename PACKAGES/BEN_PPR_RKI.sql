--------------------------------------------------------
--  DDL for Package BEN_PPR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PPR_RKI" AUTHID CURRENT_USER as
/* $Header: bepprrhi.pkh 120.0.12010000.1 2008/07/29 12:52:27 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_prmry_care_prvdr_id            in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_prmry_care_prvdr_typ_cd        in varchar2
 ,p_name                           in varchar2
 ,p_ext_ident                      in varchar2
 ,p_prtt_enrt_rslt_id              in number
 ,p_elig_cvrd_dpnt_id              in number
 ,p_business_group_id              in number
 ,p_ppr_attribute_category         in varchar2
 ,p_ppr_attribute1                 in varchar2
 ,p_ppr_attribute2                 in varchar2
 ,p_ppr_attribute3                 in varchar2
 ,p_ppr_attribute4                 in varchar2
 ,p_ppr_attribute5                 in varchar2
 ,p_ppr_attribute6                 in varchar2
 ,p_ppr_attribute7                 in varchar2
 ,p_ppr_attribute8                 in varchar2
 ,p_ppr_attribute9                 in varchar2
 ,p_ppr_attribute10                in varchar2
 ,p_ppr_attribute11                in varchar2
 ,p_ppr_attribute12                in varchar2
 ,p_ppr_attribute13                in varchar2
 ,p_ppr_attribute14                in varchar2
 ,p_ppr_attribute15                in varchar2
 ,p_ppr_attribute16                in varchar2
 ,p_ppr_attribute17                in varchar2
 ,p_ppr_attribute18                in varchar2
 ,p_ppr_attribute19                in varchar2
 ,p_ppr_attribute20                in varchar2
 ,p_ppr_attribute21                in varchar2
 ,p_ppr_attribute22                in varchar2
 ,p_ppr_attribute23                in varchar2
 ,p_ppr_attribute24                in varchar2
 ,p_ppr_attribute25                in varchar2
 ,p_ppr_attribute26                in varchar2
 ,p_ppr_attribute27                in varchar2
 ,p_ppr_attribute28                in varchar2
 ,p_ppr_attribute29                in varchar2
 ,p_ppr_attribute30                in varchar2
 ,p_request_id                     in number
 ,p_program_application_id         in number
 ,p_program_id                     in number
 ,p_program_update_date            in date
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_ppr_rki;

/
