--------------------------------------------------------
--  DDL for Package PAY_URT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_URT_RKI" AUTHID CURRENT_USER as
/* $Header: pyurtrhi.pkh 120.0 2005/05/29 09:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_user_row_id                  in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_row_low_range_or_name        in varchar2
  );
end pay_urt_rki;

 

/
