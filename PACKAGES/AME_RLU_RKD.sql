--------------------------------------------------------
--  DDL for Package AME_RLU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_RLU_RKD" AUTHID CURRENT_USER as
/* $Header: amrlurhi.pkh 120.0 2005/09/02 04:02 mbocutt noship $ */
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
  ,p_item_id                      in number
  ,p_rule_id                      in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_usage_type_o                 in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_security_group_id_o          in number
  ,p_priority_o                   in number
  ,p_approver_category_o          in varchar2
  ,p_object_version_number_o      in number
  );
--
end ame_rlu_rkd;

 

/
