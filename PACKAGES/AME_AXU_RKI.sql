--------------------------------------------------------
--  DDL for Package AME_AXU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_AXU_RKI" AUTHID CURRENT_USER as
/* $Header: amaxurhi.pkh 120.0 2005/09/02 03:53 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_action_type_id               in number
  ,p_rule_type                    in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_security_group_id            in number
  ,p_object_version_number        in number
  );
end ame_axu_rki;

 

/
