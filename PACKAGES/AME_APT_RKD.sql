--------------------------------------------------------
--  DDL for Package AME_APT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APT_RKD" AUTHID CURRENT_USER as
/* $Header: amaptrhi.pkh 120.1 2006/04/21 08:43 avarri noship $ */
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
  ,p_approver_type_id             in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_orig_system_o                in varchar2
  ,p_query_variable_1_label_o     in varchar2
  ,p_query_variable_2_label_o     in varchar2
  ,p_query_variable_3_label_o     in varchar2
  ,p_query_variable_4_label_o     in varchar2
  ,p_query_variable_5_label_o     in varchar2
  ,p_variable_1_lov_query_o       in varchar2
  ,p_variable_2_lov_query_o       in varchar2
  ,p_variable_3_lov_query_o       in varchar2
  ,p_variable_4_lov_query_o       in varchar2
  ,p_variable_5_lov_query_o       in varchar2
  ,p_query_procedure_o            in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_object_version_number_o      in number
  );
--
end ame_apt_rkd;

 

/
