--------------------------------------------------------
--  DDL for Package BEN_ERC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ERC_RKI" AUTHID CURRENT_USER as
/* $Header: beercrhi.pkh 120.0 2005/05/28 02:50:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_enrt_rt_ctfn_id                in number
 ,p_enrt_ctfn_typ_cd               in varchar2
 ,p_rqd_flag                       in varchar2
 ,p_enrt_rt_id                     in number
 ,p_business_group_id              in number
 ,p_erc_attribute_category         in varchar2
 ,p_erc_attribute1                 in varchar2
 ,p_erc_attribute2                 in varchar2
 ,p_erc_attribute3                 in varchar2
 ,p_erc_attribute4                 in varchar2
 ,p_erc_attribute5                 in varchar2
 ,p_erc_attribute6                 in varchar2
 ,p_erc_attribute7                 in varchar2
 ,p_erc_attribute8                 in varchar2
 ,p_erc_attribute9                 in varchar2
 ,p_erc_attribute10                in varchar2
 ,p_erc_attribute11                in varchar2
 ,p_erc_attribute12                in varchar2
 ,p_erc_attribute13                in varchar2
 ,p_erc_attribute14                in varchar2
 ,p_erc_attribute15                in varchar2
 ,p_erc_attribute16                in varchar2
 ,p_erc_attribute17                in varchar2
 ,p_erc_attribute18                in varchar2
 ,p_erc_attribute19                in varchar2
 ,p_erc_attribute20                in varchar2
 ,p_erc_attribute21                in varchar2
 ,p_erc_attribute22                in varchar2
 ,p_erc_attribute23                in varchar2
 ,p_erc_attribute24                in varchar2
 ,p_erc_attribute25                in varchar2
 ,p_erc_attribute26                in varchar2
 ,p_erc_attribute27                in varchar2
 ,p_erc_attribute28                in varchar2
 ,p_erc_attribute29                in varchar2
 ,p_erc_attribute30                in varchar2
 ,p_request_id                     in number
 ,p_program_application_id         in number
 ,p_program_id                     in number
 ,p_program_update_date            in date
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end ben_erc_rki;

 

/
