--------------------------------------------------------
--  DDL for Package AME_ACU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACU_RKD" AUTHID CURRENT_USER as
/* $Header: amacurhi.pkh 120.1 2005/10/11 04:21 tkolla noship $ */
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
  ,p_rule_id                      in number
  ,p_action_id                    in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_object_version_number_o      in number
  );
--
end ame_acu_rkd;

 

/
