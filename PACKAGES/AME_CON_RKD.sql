--------------------------------------------------------
--  DDL for Package AME_CON_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CON_RKD" AUTHID CURRENT_USER as
/* $Header: amconrhi.pkh 120.0 2005/09/02 03:56 mbocutt noship $ */
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
  ,p_condition_id                 in number
  ,p_start_date                   in date
  ,p_end_date                     in date
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
end ame_con_rkd;

 

/
