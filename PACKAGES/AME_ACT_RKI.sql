--------------------------------------------------------
--  DDL for Package AME_ACT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACT_RKI" AUTHID CURRENT_USER as
/* $Header: amactrhi.pkh 120.0 2005/09/02 03:48 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_action_id                    in number
  ,p_action_type_id               in number
  ,p_parameter                    in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_description                  in varchar2
  ,p_security_group_id            in number
  ,p_parameter_two                in varchar2
  ,p_object_version_number        in number
  );
end ame_act_rki;

 

/
