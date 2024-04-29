--------------------------------------------------------
--  DDL for Package AME_ATU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ATU_RKD" AUTHID CURRENT_USER as
/* $Header: amaturhi.pkh 120.0 2005/09/02 03:52 mbocutt noship $ */
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
  ,p_attribute_id                 in number
  ,p_application_id               in number
  ,p_start_date                   in date
  ,p_end_date                     in date
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
end ame_atu_rkd;

 

/
