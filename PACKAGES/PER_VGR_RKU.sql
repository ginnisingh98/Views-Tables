--------------------------------------------------------
--  DDL for Package PER_VGR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_VGR_RKU" AUTHID CURRENT_USER as
/* $Header: pevgrrhi.pkh 120.0 2005/05/31 22:59:42 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_update >----------------------------------|
-- ----------------------------------------------------------------------------
--
--{Start Of Comments}
--
-- This procedure is for the row handler user hook. The package body is generated.
--
Procedure after_update
   (
    p_valid_grade_id               in number
   ,p_date_from                    in date
   ,p_effective_date		   in date   -- Added for Bug# 1760707
   ,p_comments                     in varchar2
   ,p_date_to                      in date
   ,p_request_id                   in number
   ,p_program_application_id       in number
   ,p_program_id                   in number
   ,p_program_update_date          in date
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
   ,p_object_version_number        in number
   ,p_grade_id                     in number
   ,p_business_group_id_o          in number
   ,p_grade_id_o                   in number
   ,p_date_from_o                  in date
   ,p_comments_o                   in varchar2
   ,p_date_to_o                    in date
   ,p_request_id_o                 in number
   ,p_program_application_id_o     in number
   ,p_program_id_o                 in number
   ,p_program_update_date_o        in date
   ,p_job_id_o                     in number
   ,p_position_id_o                in number
   ,p_attribute_category_o         in varchar2
   ,p_attribute1_o                 in varchar2
   ,p_attribute2_o                 in varchar2
   ,p_attribute3_o                 in varchar2
   ,p_attribute4_o                 in varchar2
   ,p_attribute5_o                 in varchar2
   ,p_attribute6_o                 in varchar2
   ,p_attribute7_o                 in varchar2
   ,p_attribute8_o                 in varchar2
   ,p_attribute9_o                 in varchar2
   ,p_attribute10_o                in varchar2
   ,p_attribute11_o                in varchar2
   ,p_attribute12_o                in varchar2
   ,p_attribute13_o                in varchar2
   ,p_attribute14_o                in varchar2
   ,p_attribute15_o                in varchar2
   ,p_attribute16_o                in varchar2
   ,p_attribute17_o                in varchar2
   ,p_attribute18_o                in varchar2
   ,p_attribute19_o                in varchar2
   ,p_attribute20_o                in varchar2
   ,p_object_version_number_o      in number
   );
end per_vgr_rku;

 

/
