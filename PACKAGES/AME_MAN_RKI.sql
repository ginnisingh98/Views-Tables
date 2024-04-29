--------------------------------------------------------
--  DDL for Package AME_MAN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_MAN_RKI" AUTHID CURRENT_USER as
/* $Header: ammanrhi.pkh 120.0 2005/09/02 04:01 mbocutt noship $ */
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
  ,p_action_type_id               in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_security_group_id            in number
  ,p_object_version_number        in number
  );
end ame_man_rki;

 

/
