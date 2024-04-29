--------------------------------------------------------
--  DDL for Package BEN_WCN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WCN_RKI" AUTHID CURRENT_USER as
/* $Header: bewcnrhi.pkh 120.0.12010000.1 2008/07/29 13:08:57 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_wv_prtn_rsn_ctfn_pl_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_pfd_flag                       in varchar2
 ,p_lack_ctfn_sspnd_wvr_flag       in varchar2
 ,p_rqd_flag                       in varchar2
 ,p_ctfn_rqd_when_rl               in number
 ,p_wv_prtn_ctfn_typ_cd            in varchar2
 ,p_wv_prtn_rsn_pl_id              in number
 ,p_business_group_id              in number
 ,p_wcn_attribute_category         in varchar2
 ,p_wcn_attribute1                 in varchar2
 ,p_wcn_attribute2                 in varchar2
 ,p_wcn_attribute3                 in varchar2
 ,p_wcn_attribute4                 in varchar2
 ,p_wcn_attribute5                 in varchar2
 ,p_wcn_attribute6                 in varchar2
 ,p_wcn_attribute7                 in varchar2
 ,p_wcn_attribute8                 in varchar2
 ,p_wcn_attribute9                 in varchar2
 ,p_wcn_attribute10                in varchar2
 ,p_wcn_attribute11                in varchar2
 ,p_wcn_attribute12                in varchar2
 ,p_wcn_attribute13                in varchar2
 ,p_wcn_attribute14                in varchar2
 ,p_wcn_attribute15                in varchar2
 ,p_wcn_attribute16                in varchar2
 ,p_wcn_attribute17                in varchar2
 ,p_wcn_attribute18                in varchar2
 ,p_wcn_attribute19                in varchar2
 ,p_wcn_attribute20                in varchar2
 ,p_wcn_attribute21                in varchar2
 ,p_wcn_attribute22                in varchar2
 ,p_wcn_attribute23                in varchar2
 ,p_wcn_attribute24                in varchar2
 ,p_wcn_attribute25                in varchar2
 ,p_wcn_attribute26                in varchar2
 ,p_wcn_attribute27                in varchar2
 ,p_wcn_attribute28                in varchar2
 ,p_wcn_attribute29                in varchar2
 ,p_wcn_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_wcn_rki;

/
