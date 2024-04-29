--------------------------------------------------------
--  DDL for Package BEN_BNG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BNG_RKI" AUTHID CURRENT_USER as
/* $Header: bebngrhi.pkh 120.0 2005/05/28 00:45:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_benfts_grp_id                  in number
 ,p_business_group_id              in number
 ,p_name                           in varchar2
 ,p_bng_desc                       in varchar2
 ,p_bng_attribute_category         in varchar2
 ,p_bng_attribute1                 in varchar2
 ,p_bng_attribute2                 in varchar2
 ,p_bng_attribute3                 in varchar2
 ,p_bng_attribute4                 in varchar2
 ,p_bng_attribute5                 in varchar2
 ,p_bng_attribute6                 in varchar2
 ,p_bng_attribute7                 in varchar2
 ,p_bng_attribute8                 in varchar2
 ,p_bng_attribute9                 in varchar2
 ,p_bng_attribute10                in varchar2
 ,p_bng_attribute11                in varchar2
 ,p_bng_attribute12                in varchar2
 ,p_bng_attribute13                in varchar2
 ,p_bng_attribute14                in varchar2
 ,p_bng_attribute15                in varchar2
 ,p_bng_attribute16                in varchar2
 ,p_bng_attribute17                in varchar2
 ,p_bng_attribute18                in varchar2
 ,p_bng_attribute19                in varchar2
 ,p_bng_attribute20                in varchar2
 ,p_bng_attribute21                in varchar2
 ,p_bng_attribute22                in varchar2
 ,p_bng_attribute23                in varchar2
 ,p_bng_attribute24                in varchar2
 ,p_bng_attribute25                in varchar2
 ,p_bng_attribute26                in varchar2
 ,p_bng_attribute27                in varchar2
 ,p_bng_attribute28                in varchar2
 ,p_bng_attribute29                in varchar2
 ,p_bng_attribute30                in varchar2
 ,p_object_version_number          in number
  );
end ben_bng_rki;

 

/
