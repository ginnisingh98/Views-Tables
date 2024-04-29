--------------------------------------------------------
--  DDL for Package AME_CFV_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CFV_RKD" AUTHID CURRENT_USER as
/* $Header: amcfvrhi.pkh 120.0 2005/09/02 03:54 mbocutt noship $ */
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
  ,p_application_id               in number
  ,p_variable_name                in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_variable_value_o             in varchar2
  ,p_description_o                in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_security_group_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end ame_cfv_rkd;

 

/
