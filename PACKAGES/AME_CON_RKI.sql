--------------------------------------------------------
--  DDL for Package AME_CON_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CON_RKI" AUTHID CURRENT_USER as
/* $Header: amconrhi.pkh 120.0 2005/09/02 03:56 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
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
  );
end ame_con_rki;

 

/
