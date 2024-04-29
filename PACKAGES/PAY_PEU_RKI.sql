--------------------------------------------------------
--  DDL for Package PAY_PEU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PEU_RKI" AUTHID CURRENT_USER as
/* $Header: pypeurhi.pkh 120.0 2005/05/29 07:29:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
  );
end pay_peu_rki;

 

/
