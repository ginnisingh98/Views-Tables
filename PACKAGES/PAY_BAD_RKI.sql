--------------------------------------------------------
--  DDL for Package PAY_BAD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BAD_RKI" AUTHID CURRENT_USER as
/* $Header: pybadrhi.pkh 120.0 2005/05/29 03:14:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_attribute_id                 in number
  ,p_attribute_name               in varchar2
  ,p_alterable                    in varchar2
  ,p_legislation_code             in varchar2
  ,p_business_group_id            in number
  ,p_user_attribute_name          in varchar2
  );
end pay_bad_rki;

 

/
