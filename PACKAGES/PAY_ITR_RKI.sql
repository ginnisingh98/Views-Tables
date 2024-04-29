--------------------------------------------------------
--  DDL for Package PAY_ITR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ITR_RKI" AUTHID CURRENT_USER as
/* $Header: pyitrrhi.pkh 120.0 2005/05/29 06:03:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_iterative_rule_id            in number
  ,p_element_type_id              in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_result_name                  in varchar2
  ,p_iterative_rule_type          in varchar2
  ,p_input_value_id               in number
  ,p_severity_level               in varchar2
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_object_version_number        in number
  );
end pay_itr_rki;

 

/
