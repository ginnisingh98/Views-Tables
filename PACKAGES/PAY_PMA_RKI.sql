--------------------------------------------------------
--  DDL for Package PAY_PMA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PMA_RKI" AUTHID CURRENT_USER as
/* $Header: pypmarhi.pkh 120.0 2005/05/29 07:38:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_organization_id                in number
 ,p_source_id                      in number
 ,p_account_number                 in varchar2
 ,p_enabled                        in varchar2
 ,p_description                    in varchar2
 ,p_business_group_id              in number
 ,p_attribute_category             in varchar2
 ,p_attribute1                     in varchar2
 ,p_attribute2                     in varchar2
 ,p_attribute3                     in varchar2
 ,p_attribute4                     in varchar2
 ,p_attribute5                     in varchar2
 ,p_attribute6                     in varchar2
 ,p_attribute7                     in varchar2
 ,p_attribute8                     in varchar2
 ,p_attribute9                     in varchar2
 ,p_attribute10                    in varchar2
 ,p_attribute11                    in varchar2
 ,p_attribute12                    in varchar2
 ,p_attribute13                    in varchar2
 ,p_attribute14                    in varchar2
 ,p_attribute15                    in varchar2
 ,p_attribute16                    in varchar2
 ,p_attribute17                    in varchar2
 ,p_attribute18                    in varchar2
 ,p_attribute19                    in varchar2
 ,p_attribute20                    in varchar2
 ,p_attribute21                    in varchar2
 ,p_attribute22                    in varchar2
 ,p_attribute23                    in varchar2
 ,p_attribute24                    in varchar2
 ,p_attribute25                    in varchar2
 ,p_attribute26                    in varchar2
 ,p_attribute27                    in varchar2
 ,p_attribute28                    in varchar2
 ,p_attribute29                    in varchar2
 ,p_attribute30                    in varchar2
 ,p_object_version_number          in number
  );
end pay_pma_rki;

 

/