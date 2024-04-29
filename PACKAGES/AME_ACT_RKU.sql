--------------------------------------------------------
--  DDL for Package AME_ACT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACT_RKU" AUTHID CURRENT_USER as
/* $Header: amactrhi.pkh 120.0 2005/09/02 03:48 mbocutt noship $ */
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
  ,p_action_id                    in number
  ,p_action_type_id               in number
  ,p_parameter                    in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_description                  in varchar2
  ,p_security_group_id            in number
  ,p_parameter_two                in varchar2
  ,p_object_version_number        in number
  ,p_parameter_o                  in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_description_o                in varchar2
  ,p_security_group_id_o          in number
  ,p_parameter_two_o              in varchar2
  ,p_object_version_number_o      in number
  );
--
end ame_act_rku;

 

/
