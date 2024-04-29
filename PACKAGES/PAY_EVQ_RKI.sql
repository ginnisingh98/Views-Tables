--------------------------------------------------------
--  DDL for Package PAY_EVQ_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVQ_RKI" AUTHID CURRENT_USER as
/* $Header: pyevqrhi.pkh 120.0 2005/05/29 04:49:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_event_qualifier_id           in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_dated_table_id               in number
  ,p_column_name                  in varchar2
  ,p_qualifier_name               in varchar2
  ,p_legislation_code             in varchar2
  ,p_business_group_id            in number
  ,p_comparison_column            in varchar2
  ,p_qualifier_definition         in varchar2
  ,p_qualifier_where_clause       in varchar2
  ,p_entry_qualification          in varchar2
  ,p_assignment_qualification     in varchar2
  ,p_multi_event_sql              in varchar2
  ,p_object_version_number        in number
  );
end pay_evq_rki;

 

/
