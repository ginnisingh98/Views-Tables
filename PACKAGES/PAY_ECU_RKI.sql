--------------------------------------------------------
--  DDL for Package PAY_ECU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ECU_RKI" AUTHID CURRENT_USER as
/* $Header: pyecurhi.pkh 120.1 2005/12/15 06:40:05 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_element_class_usage_id       in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_run_type_id                  in number
  ,p_classification_id            in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_object_version_number        in number
  );
end pay_ecu_rki;

 

/
