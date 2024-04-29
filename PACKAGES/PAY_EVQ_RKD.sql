--------------------------------------------------------
--  DDL for Package PAY_EVQ_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVQ_RKD" AUTHID CURRENT_USER as
/* $Header: pyevqrhi.pkh 120.0 2005/05/29 04:49:58 appldev noship $ */
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
  ,p_event_qualifier_id           in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_dated_table_id_o             in number
  ,p_column_name_o                in varchar2
  ,p_qualifier_name_o             in varchar2
  ,p_legislation_code_o           in varchar2
  ,p_business_group_id_o          in number
  ,p_comparison_column_o          in varchar2
  ,p_qualifier_definition_o       in varchar2
  ,p_qualifier_where_clause_o     in varchar2
  ,p_entry_qualification_o        in varchar2
  ,p_assignment_qualification_o   in varchar2
  ,p_multi_event_sql_o            in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_evq_rkd;

 

/
