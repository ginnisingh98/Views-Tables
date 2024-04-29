--------------------------------------------------------
--  DDL for Package AME_ATU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ATU_RKI" AUTHID CURRENT_USER as
/* $Header: amaturhi.pkh 120.0 2005/09/02 03:52 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
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
  );
end ame_atu_rki;

 

/
