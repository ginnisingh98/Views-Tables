--------------------------------------------------------
--  DDL for Package AME_ATU_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ATU_RKU" AUTHID CURRENT_USER as
/* $Header: amaturhi.pkh 120.0 2005/09/02 03:52 mbocutt noship $ */
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
  ,p_attribute_id                 in number
  ,p_application_id               in number
  ,p_query_string                 in varchar2
  ,p_use_count                    in number
  ,p_user_editable                in varchar2
  ,p_is_static                    in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_security_group_id            in number
  ,p_value_set_id                 in number
  ,p_object_version_number        in number
  ,p_query_string_o               in varchar2
  ,p_use_count_o                  in number
  ,p_user_editable_o              in varchar2
  ,p_is_static_o                  in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_security_group_id_o          in number
  ,p_value_set_id_o               in number
  ,p_object_version_number_o      in number
  );
--
end ame_atu_rku;

 

/
