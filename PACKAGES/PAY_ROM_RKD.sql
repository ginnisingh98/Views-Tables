--------------------------------------------------------
--  DDL for Package PAY_ROM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ROM_RKD" AUTHID CURRENT_USER as
/* $Header: pyromrhi.pkh 120.0 2005/05/29 08:24:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_run_type_org_method_id       in number
  ,p_run_type_id_o                in number
  ,p_org_payment_method_id_o      in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_priority_o                   in number
  ,p_percentage_o                 in number
  ,p_amount_o                     in number
  ,p_object_version_number_o      in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  );
--
end pay_rom_rkd;

 

/
