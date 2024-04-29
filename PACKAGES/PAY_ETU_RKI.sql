--------------------------------------------------------
--  DDL for Package PAY_ETU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ETU_RKI" AUTHID CURRENT_USER as
/* $Header: pyeturhi.pkh 120.0 2005/05/29 04:45:36 appldev noship $ */
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
  ,p_element_type_id              in number
  ,p_inclusion_flag               in varchar2
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_object_version_number        in number
  ,p_element_type_usage_id        in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_usage_type			  in varchar2
  );
end pay_etu_rki;

 

/
