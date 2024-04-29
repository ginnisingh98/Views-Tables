--------------------------------------------------------
--  DDL for Package AME_RUL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_RUL_RKI" AUTHID CURRENT_USER as
/* $Header: amrulrhi.pkh 120.0 2005/09/02 04:03 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_rule_id                      in number
  ,p_rule_type                    in number
  ,p_action_id                    in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_description                  in varchar2
  ,p_security_group_id            in number
  ,p_rule_key                     in varchar2
  ,p_item_class_id                in number
  ,p_object_version_number        in number
  );
end ame_rul_rki;

 

/
