--------------------------------------------------------
--  DDL for Package PQH_TJR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TJR_RKU" AUTHID CURRENT_USER as
/* $Header: pqtjrrhi.pkh 120.0 2005/05/29 02:49:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_txn_job_requirement_id       in number
  ,p_position_transaction_id      in number
  ,p_job_requirement_id           in number
  ,p_business_group_id            in number
  ,p_analysis_criteria_id         in number
  ,p_date_from                    in date
  ,p_date_to                      in date
  ,p_essential                    in varchar2
  ,p_job_id                       in number
  ,p_object_version_number        in number
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
  ,p_comments                     in varchar2
  ,p_position_transaction_id_o    in number
  ,p_job_requirement_id_o         in number
  ,p_business_group_id_o          in number
  ,p_analysis_criteria_id_o       in number
  ,p_date_from_o                  in date
  ,p_date_to_o                    in date
  ,p_essential_o                  in varchar2
  ,p_job_id_o                     in number
  ,p_object_version_number_o      in number
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
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
  ,p_comments_o                   in varchar2
  );
--
end pqh_tjr_rku;

 

/