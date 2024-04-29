--------------------------------------------------------
--  DDL for Package AME_RLU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_RLU_RKI" AUTHID CURRENT_USER as
/* $Header: amrlurhi.pkh 120.0 2005/09/02 04:02 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_item_id                      in number
  ,p_usage_type                   in varchar2
  ,p_rule_id                      in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_security_group_id            in number
  ,p_priority                     in number
  ,p_approver_category            in varchar2
  ,p_object_version_number        in number
  );
end ame_rlu_rki;

 

/
