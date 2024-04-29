--------------------------------------------------------
--  DDL for Package PAY_DTE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DTE_RKI" AUTHID CURRENT_USER as
/* $Header: pydterhi.pkh 120.0 2005/05/29 04:24:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_datetracked_event_id         in number
  ,p_event_group_id               in number
  ,p_dated_table_id               in number
  ,p_column_name                  in varchar2
  ,p_update_type                  in varchar2
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_object_version_number        in number
  ,p_proration_style              in varchar2
  );
end pay_dte_rki;

 

/
