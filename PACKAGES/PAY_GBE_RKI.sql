--------------------------------------------------------
--  DDL for Package PAY_GBE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GBE_RKI" AUTHID CURRENT_USER as
/* $Header: pygberhi.pkh 120.1 2005/06/30 06:58:29 tukumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_grossup_balances_id          in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_source_id                    in number
  ,p_source_type                  in varchar2
  ,p_balance_type_id              in number
  ,p_object_version_number        in number
  );
end pay_gbe_rki;

 

/
