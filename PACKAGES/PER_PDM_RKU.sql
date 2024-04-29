--------------------------------------------------------
--  DDL for Package PER_PDM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PDM_RKU" AUTHID CURRENT_USER as
/* $Header: pepdmrhi.pkh 120.0 2005/05/31 13:05:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_delivery_method_id             in number
 ,p_date_start                     in date
 ,p_date_end                       in date
 ,p_comm_dlvry_method              in varchar2
 ,p_preferred_flag                 in varchar2
 ,p_object_version_number          in number
 ,p_request_id                     in number
 ,p_program_update_date            in date
 ,p_program_application_id         in number
 ,p_program_id                     in number
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
 ,p_effective_date                 in date
 ,p_date_start_o                   in date
 ,p_date_end_o                     in date
 ,p_person_id_o                    in varchar2
 ,p_comm_dlvry_method_o            in varchar2
 ,p_preferred_flag_o               in varchar2
 ,p_object_version_number_o        in number
 ,p_request_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_attribute_category_o           in varchar2
 ,p_attribute1_o                   in varchar2
 ,p_attribute2_o                   in varchar2
 ,p_attribute3_o                   in varchar2
 ,p_attribute4_o                   in varchar2
 ,p_attribute5_o                   in varchar2
 ,p_attribute6_o                   in varchar2
 ,p_attribute7_o                   in varchar2
 ,p_attribute8_o                   in varchar2
 ,p_attribute9_o                   in varchar2
 ,p_attribute10_o                  in varchar2
 ,p_attribute11_o                  in varchar2
 ,p_attribute12_o                  in varchar2
 ,p_attribute13_o                  in varchar2
 ,p_attribute14_o                  in varchar2
 ,p_attribute15_o                  in varchar2
 ,p_attribute16_o                  in varchar2
 ,p_attribute17_o                  in varchar2
 ,p_attribute18_o                  in varchar2
 ,p_attribute19_o                  in varchar2
 ,p_attribute20_o                  in varchar2
  );
--
end per_pdm_rku;

 

/
