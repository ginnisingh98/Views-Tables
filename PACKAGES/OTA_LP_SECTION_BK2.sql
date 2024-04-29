--------------------------------------------------------
--  DDL for Package OTA_LP_SECTION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LP_SECTION_BK2" AUTHID CURRENT_USER as
/* $Header: otlpcapi.pkh 120.1 2005/10/02 02:36:59 aroussel $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< update_lp_section_b >---------------------------------|
-- ----------------------------------------------------------------------------
procedure update_lp_section_b
  (p_effective_date                in     date
  ,p_learning_path_section_id      in     number
  ,p_section_name                  in     varchar2
  ,p_description                   in     varchar2
  ,p_object_version_number         in     number
  ,p_section_sequence              in     number
  ,p_completion_type_code          in     varchar2
  ,p_no_of_mandatory_courses       in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_lp_section_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_lp_section_a
  (p_effective_date                in     date
  ,p_learning_path_section_id       in    number
  ,p_section_name                  in     varchar2
  ,p_description                   in     varchar2
  ,p_object_version_number         in     number
  ,p_section_sequence              in     number
  ,p_completion_type_code          in     varchar2
  ,p_no_of_mandatory_courses       in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  );
end ota_lp_section_bk2;

 

/
