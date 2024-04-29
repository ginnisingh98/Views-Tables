--------------------------------------------------------
--  DDL for Package AME_CNU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CNU_RKI" AUTHID CURRENT_USER as
/* $Header: amcnurhi.pkh 120.0 2005/09/02 03:55 mbocutt noship $ */
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
  ,p_condition_id                 in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_security_group_id            in number
  ,p_object_version_number        in number
  );
end ame_cnu_rki;

 

/
