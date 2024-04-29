--------------------------------------------------------
--  DDL for Package PAY_ROM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ROM_RKI" AUTHID CURRENT_USER as
/* $Header: pyromrhi.pkh 120.0 2005/05/29 08:24:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_run_type_id                  in number
  ,p_org_payment_method_id        in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_priority                     in number
  ,p_percentage                   in number
  ,p_amount                       in number
  ,p_object_version_number        in number
  ,p_run_type_org_method_id       in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  );
end pay_rom_rki;

 

/
