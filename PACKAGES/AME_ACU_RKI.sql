--------------------------------------------------------
--  DDL for Package AME_ACU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACU_RKI" AUTHID CURRENT_USER as
/* $Header: amacurhi.pkh 120.1 2005/10/11 04:21 tkolla noship $ */
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
  ,p_action_id                    in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_object_version_number        in number
  );
end ame_acu_rki;

 

/
