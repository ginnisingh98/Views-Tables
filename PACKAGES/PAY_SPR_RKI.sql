--------------------------------------------------------
--  DDL for Package PAY_SPR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SPR_RKI" AUTHID CURRENT_USER as
/* $Header: pysprrhi.pkh 120.0 2005/05/29 08:54:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_business_group_id            in number
  ,p_security_profile_id          in number
  ,p_payroll_id                   in number
  ,p_object_version_number        in number
  );
end pay_spr_rki;

 

/
