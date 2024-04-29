--------------------------------------------------------
--  DDL for Package PAY_ESU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ESU_RKI" AUTHID CURRENT_USER as
/* $Header: pyesurhi.pkh 120.0 2005/05/29 04:41:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_element_span_usage_id        in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_time_span_id                 in number
  ,p_retro_component_usage_id     in number
  ,p_adjustment_type              in varchar2
  ,p_retro_element_type_id        in number
  ,p_object_version_number        in number
  );
end pay_esu_rki;

 

/
