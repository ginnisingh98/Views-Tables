--------------------------------------------------------
--  DDL for Package PAY_PUT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PUT_RKI" AUTHID CURRENT_USER as
/* $Header: pyputrhi.pkh 120.0 2005/05/29 08:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_user_table_id                in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_range_or_match               in varchar2
  ,p_user_key_units               in varchar2
  ,p_user_table_name              in varchar2
  ,p_user_row_title               in varchar2
  ,p_object_version_number        in number
  );
end pay_put_rki;

 

/
