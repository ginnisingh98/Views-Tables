--------------------------------------------------------
--  DDL for Package BEN_PAT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PAT_RKI" AUTHID CURRENT_USER as
/* $Header: bepatrhi.pkh 120.1 2007/03/29 07:05:30 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_mandatory                     in varchar2
 ,p_once_or_always                in varchar2
  );
end ben_pat_rki;

/
