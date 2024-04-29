--------------------------------------------------------
--  DDL for Package HR_FORM_TEMPLATES_API_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_TEMPLATES_API_BK1" AUTHID CURRENT_USER as
/* $Header: hrtmpapi.pkh 120.0 2005/05/31 03:20:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< copy_template_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_template_b
  (p_effective_date               in date
  ,p_form_template_id_from        in number
  ,p_language_code                in varchar2
  ,p_template_name                in varchar2
  ,p_user_template_name           in varchar2
  ,p_description                  in varchar2
  ,p_enabled_flag                 in varchar2
  ,p_legislation_code             in varchar2
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< copy_template_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_template_a
  (p_effective_date               in date
  ,p_form_template_id_from        in number
  ,p_language_code                in varchar2
  ,p_template_name                in varchar2
  ,p_user_template_name           in varchar2
  ,p_description                  in varchar2
  ,p_enabled_flag                 in varchar2
  ,p_legislation_code             in varchar2
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
  ,p_form_template_id_to          in number
  ,p_object_version_number        in number
  );
--
end hr_form_templates_api_bk1;

 

/
