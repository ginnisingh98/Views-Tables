--------------------------------------------------------
--  DDL for Package PER_RCF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RCF_RKI" AUTHID CURRENT_USER as
/* $Header: percfrhi.pkh 120.0 2005/05/31 16:52:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_rec_activity_for_id          in number
  ,p_business_group_id            in number
  ,p_vacancy_id                   in number
  ,p_rec_activity_id               in number
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_object_version_number        in number
  );
end per_rcf_rki;

 

/
