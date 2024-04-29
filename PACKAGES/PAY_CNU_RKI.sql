--------------------------------------------------------
--  DDL for Package PAY_CNU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CNU_RKI" AUTHID CURRENT_USER as
/* $Header: pycnurhi.pkh 120.0 2005/05/29 04:05:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_contribution_usage_id        in number
  ,p_date_from                    in date
  ,p_date_to                      in date
  ,p_group_code                   in varchar2
  ,p_process_type                 in varchar2
  ,p_element_name                 in varchar2
  ,p_rate_type                    in varchar2
  ,p_contribution_code            in varchar2
  ,p_retro_contribution_code      in varchar2
  ,p_contribution_type            in varchar2
  ,p_contribution_usage_type      in varchar2
  ,p_rate_category                in varchar2
  ,p_business_group_id            in number
  ,p_object_version_number        in number
  ,p_code_Rate_id                 in number
  );
end pay_cnu_rki;

 

/
