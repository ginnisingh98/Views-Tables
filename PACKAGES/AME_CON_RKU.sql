--------------------------------------------------------
--  DDL for Package AME_CON_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CON_RKU" AUTHID CURRENT_USER as
/* $Header: amconrhi.pkh 120.0 2005/09/02 03:56 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_condition_id                 in number
  ,p_condition_type               in varchar2
  ,p_attribute_id                 in number
  ,p_parameter_one                in varchar2
  ,p_parameter_two                in varchar2
  ,p_parameter_three              in varchar2
  ,p_include_lower_limit          in varchar2
  ,p_include_upper_limit          in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_security_group_id            in number
  ,p_condition_key                in varchar2
  ,p_object_version_number        in number
  ,p_condition_type_o             in varchar2
  ,p_attribute_id_o               in number
  ,p_parameter_one_o              in varchar2
  ,p_parameter_two_o              in varchar2
  ,p_parameter_three_o            in varchar2
  ,p_include_lower_limit_o        in varchar2
  ,p_include_upper_limit_o        in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_security_group_id_o          in number
  ,p_condition_key_o              in varchar2
  ,p_object_version_number_o      in number
  );
--
end ame_con_rku;

 

/
