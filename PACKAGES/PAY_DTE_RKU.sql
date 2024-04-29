--------------------------------------------------------
--  DDL for Package PAY_DTE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DTE_RKU" AUTHID CURRENT_USER as
/* $Header: pydterhi.pkh 120.0 2005/05/29 04:24:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
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
  ,p_event_group_id_o             in number
  ,p_dated_table_id_o             in number
  ,p_column_name_o                in varchar2
  ,p_update_type_o                in varchar2
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_object_version_number_o      in number
  ,p_proration_style_o            in varchar2
  );
--
end pay_dte_rku;

 

/
