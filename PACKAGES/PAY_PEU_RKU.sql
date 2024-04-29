--------------------------------------------------------
--  DDL for Package PAY_PEU_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PEU_RKU" AUTHID CURRENT_USER as
/* $Header: pypeurhi.pkh 120.0 2005/05/29 07:29:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_event_update_id              in number
  ,p_table_name                   in varchar2
  ,p_column_name                  in varchar2
  ,p_dated_table_id               in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_change_type                  in varchar2
  ,p_event_type                   in varchar2
  ,p_object_version_number        in number
  ,p_table_name_o                 in varchar2
  ,p_column_name_o                in varchar2
  ,p_dated_table_id_o             in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_change_type_o                in varchar2
  ,p_event_type_o                 in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_peu_rku;

 

/
