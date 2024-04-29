--------------------------------------------------------
--  DDL for Package AME_CFV_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CFV_RKI" AUTHID CURRENT_USER as
/* $Header: amcfvrhi.pkh 120.0 2005/09/02 03:54 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_application_id               in number
  ,p_variable_name                in varchar2
  ,p_variable_value               in varchar2
  ,p_description                  in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_security_group_id            in number
  ,p_object_version_number        in number
  );
end ame_cfv_rki;

 

/
