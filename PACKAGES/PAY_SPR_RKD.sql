--------------------------------------------------------
--  DDL for Package PAY_SPR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SPR_RKD" AUTHID CURRENT_USER as
/* $Header: pysprrhi.pkh 120.0 2005/05/29 08:54:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_security_profile_id          in number
  ,p_payroll_id                   in number
  ,p_business_group_id_o          in number
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_object_version_number_o      in number
  );
--
end pay_spr_rkd;

 

/
