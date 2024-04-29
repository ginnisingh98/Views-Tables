--------------------------------------------------------
--  DDL for Package PAY_CNU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CNU_RKD" AUTHID CURRENT_USER as
/* $Header: pycnurhi.pkh 120.0 2005/05/29 04:05:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_contribution_usage_id        in number
  ,p_date_from_o                  in date
  ,p_date_to_o                    in date
  ,p_group_code_o                 in varchar2
  ,p_process_type_o               in varchar2
  ,p_element_name_o               in varchar2
  ,p_rate_type_o                  in varchar2
  ,p_contribution_code_o          in varchar2
  ,p_retro_contribution_code_o    in varchar2
  ,p_contribution_type_o          in varchar2
  ,p_contribution_usage_type_o    in varchar2
  ,p_rate_category_o              in varchar2
  ,p_business_group_id_o          in number
  ,p_object_version_number_o      in number
  ,p_code_Rate_id_o               in number
  );
--
end pay_cnu_rkd;

 

/
