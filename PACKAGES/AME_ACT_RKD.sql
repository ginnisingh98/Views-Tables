--------------------------------------------------------
--  DDL for Package AME_ACT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACT_RKD" AUTHID CURRENT_USER as
/* $Header: amactrhi.pkh 120.0 2005/09/02 03:48 mbocutt noship $ */
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
  ,p_action_id                    in number
  ,p_action_type_id               in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_parameter_o                  in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_description_o                in varchar2
  ,p_security_group_id_o          in number
  ,p_parameter_two_o              in varchar2
  ,p_object_version_number_o      in number
  );
--
end ame_act_rkd;

 

/
