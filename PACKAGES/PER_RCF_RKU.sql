--------------------------------------------------------
--  DDL for Package PER_RCF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RCF_RKU" AUTHID CURRENT_USER as
/* $Header: percfrhi.pkh 120.0 2005/05/31 16:52:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_rec_activity_for_id          in number
  ,p_business_group_id            in number
  ,p_vacancy_id                   in number
  ,p_rec_activity_id              in number
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_object_version_number        in number
  ,p_business_group_id_o          in number
  ,p_vacancy_id_o                 in number
  ,p_rec_activity_id_o            in number
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_object_version_number_o      in number
  );
--
end per_rcf_rku;

 

/
