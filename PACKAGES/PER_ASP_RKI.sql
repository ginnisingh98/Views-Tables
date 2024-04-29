--------------------------------------------------------
--  DDL for Package PER_ASP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASP_RKI" AUTHID CURRENT_USER as
/* $Header: peasprhi.pkh 115.7 99/07/22 06:41:29 porting ship  $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_sec_profile_assignment_id      in number
 ,p_user_id                        in number
 ,p_security_group_id              in number
 ,p_business_group_id              in number
 ,p_security_profile_id            in number
 ,p_responsibility_id              in number
 ,p_responsibility_application_i  in number
 ,p_start_date                     in date
 ,p_end_date                       in date
 ,p_object_version_number          in number
  );
end per_asp_rki;

 

/
