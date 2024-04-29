--------------------------------------------------------
--  DDL for Package HR_ORU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORU_RKI" AUTHID CURRENT_USER as
/* $Header: hrorurhi.pkh 120.1 2005/07/15 06:03:15 bshukla noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_organization_id              in number
  ,p_business_group_id            in number
  ,p_cost_allocation_keyflex_id   in number
  ,p_location_id                  in number
  ,p_soft_coding_keyflex_id       in number
  ,p_date_from                    in date
  ,p_name                         in varchar2
  ,p_comments                     in varchar2
  ,p_date_to                      in date
  ,p_internal_external_flag       in varchar2
  ,p_internal_address_line        in varchar2
  ,p_type                         in varchar2
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_attribute16                  in varchar2
  ,p_attribute17                  in varchar2
  ,p_attribute18                  in varchar2
  ,p_attribute19                  in varchar2
  ,p_attribute20                  in varchar2
  --Enhancement 4040086
  ,p_attribute21                  in varchar2
  ,p_attribute22                  in varchar2
  ,p_attribute23                  in varchar2
  ,p_attribute24                  in varchar2
  ,p_attribute25                  in varchar2
  ,p_attribute26                  in varchar2
  ,p_attribute27                  in varchar2
  ,p_attribute28                  in varchar2
  ,p_attribute29                  in varchar2
  ,p_attribute30                  in varchar2
  --End Enhancement 4040086
  ,p_object_version_number        in number
  );
end hr_oru_rki;
--

 

/
