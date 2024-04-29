--------------------------------------------------------
--  DDL for Package PAY_DTE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DTE_RKD" AUTHID CURRENT_USER as
/* $Header: pydterhi.pkh 120.0 2005/05/29 04:24:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_datetracked_event_id         in number
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
end pay_dte_rkd;

 

/
