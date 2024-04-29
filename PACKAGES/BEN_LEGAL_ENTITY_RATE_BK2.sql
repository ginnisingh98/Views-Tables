--------------------------------------------------------
--  DDL for Package BEN_LEGAL_ENTITY_RATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LEGAL_ENTITY_RATE_BK2" AUTHID CURRENT_USER as
/* $Header: belglapi.pkh 120.0 2005/05/28 03:23:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_LEGAL_ENTITY_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_LEGAL_ENTITY_RATE_b
  (
   p_lgl_enty_rt_id                 in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_organization_id                in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_business_group_id              in  number
  ,p_ler1_attribute_category        in  varchar2
  ,p_ler1_attribute1                in  varchar2
  ,p_ler1_attribute2                in  varchar2
  ,p_ler1_attribute3                in  varchar2
  ,p_ler1_attribute4                in  varchar2
  ,p_ler1_attribute5                in  varchar2
  ,p_ler1_attribute6                in  varchar2
  ,p_ler1_attribute7                in  varchar2
  ,p_ler1_attribute8                in  varchar2
  ,p_ler1_attribute9                in  varchar2
  ,p_ler1_attribute10               in  varchar2
  ,p_ler1_attribute11               in  varchar2
  ,p_ler1_attribute12               in  varchar2
  ,p_ler1_attribute13               in  varchar2
  ,p_ler1_attribute14               in  varchar2
  ,p_ler1_attribute15               in  varchar2
  ,p_ler1_attribute16               in  varchar2
  ,p_ler1_attribute17               in  varchar2
  ,p_ler1_attribute18               in  varchar2
  ,p_ler1_attribute19               in  varchar2
  ,p_ler1_attribute20               in  varchar2
  ,p_ler1_attribute21               in  varchar2
  ,p_ler1_attribute22               in  varchar2
  ,p_ler1_attribute23               in  varchar2
  ,p_ler1_attribute24               in  varchar2
  ,p_ler1_attribute25               in  varchar2
  ,p_ler1_attribute26               in  varchar2
  ,p_ler1_attribute27               in  varchar2
  ,p_ler1_attribute28               in  varchar2
  ,p_ler1_attribute29               in  varchar2
  ,p_ler1_attribute30               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_LEGAL_ENTITY_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_LEGAL_ENTITY_RATE_a
  (
   p_lgl_enty_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_vrbl_rt_prfl_id                in  number
  ,p_organization_id                in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_business_group_id              in  number
  ,p_ler1_attribute_category        in  varchar2
  ,p_ler1_attribute1                in  varchar2
  ,p_ler1_attribute2                in  varchar2
  ,p_ler1_attribute3                in  varchar2
  ,p_ler1_attribute4                in  varchar2
  ,p_ler1_attribute5                in  varchar2
  ,p_ler1_attribute6                in  varchar2
  ,p_ler1_attribute7                in  varchar2
  ,p_ler1_attribute8                in  varchar2
  ,p_ler1_attribute9                in  varchar2
  ,p_ler1_attribute10               in  varchar2
  ,p_ler1_attribute11               in  varchar2
  ,p_ler1_attribute12               in  varchar2
  ,p_ler1_attribute13               in  varchar2
  ,p_ler1_attribute14               in  varchar2
  ,p_ler1_attribute15               in  varchar2
  ,p_ler1_attribute16               in  varchar2
  ,p_ler1_attribute17               in  varchar2
  ,p_ler1_attribute18               in  varchar2
  ,p_ler1_attribute19               in  varchar2
  ,p_ler1_attribute20               in  varchar2
  ,p_ler1_attribute21               in  varchar2
  ,p_ler1_attribute22               in  varchar2
  ,p_ler1_attribute23               in  varchar2
  ,p_ler1_attribute24               in  varchar2
  ,p_ler1_attribute25               in  varchar2
  ,p_ler1_attribute26               in  varchar2
  ,p_ler1_attribute27               in  varchar2
  ,p_ler1_attribute28               in  varchar2
  ,p_ler1_attribute29               in  varchar2
  ,p_ler1_attribute30               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_LEGAL_ENTITY_RATE_bk2;

 

/
