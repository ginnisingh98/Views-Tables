--------------------------------------------------------
--  DDL for Package PER_RCF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RCF_RKD" AUTHID CURRENT_USER as
/* $Header: percfrhi.pkh 120.0 2005/05/31 16:52:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_rec_activity_for_id          in number
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
end per_rcf_rkd;

 

/
