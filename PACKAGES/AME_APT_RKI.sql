--------------------------------------------------------
--  DDL for Package AME_APT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APT_RKI" AUTHID CURRENT_USER as
/* $Header: amaptrhi.pkh 120.1 2006/04/21 08:43 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_approver_type_id             in number
  ,p_orig_system                  in varchar2
  ,p_query_variable_1_label       in varchar2
  ,p_query_variable_2_label       in varchar2
  ,p_query_variable_3_label       in varchar2
  ,p_query_variable_4_label       in varchar2
  ,p_query_variable_5_label       in varchar2
  ,p_variable_1_lov_query         in varchar2
  ,p_variable_2_lov_query         in varchar2
  ,p_variable_3_lov_query         in varchar2
  ,p_variable_4_lov_query         in varchar2
  ,p_variable_5_lov_query         in varchar2
  ,p_query_procedure              in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_object_version_number        in number
  );
end ame_apt_rki;

 

/
