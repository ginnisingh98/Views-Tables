--------------------------------------------------------
--  DDL for Package PAY_GBE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GBE_RKD" AUTHID CURRENT_USER as
/* $Header: pygberhi.pkh 120.1 2005/06/30 06:58:29 tukumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_grossup_balances_id          in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_source_id_o                  in number
  ,p_source_type_o                in varchar2
  ,p_balance_type_id_o            in number
  ,p_object_version_number_o      in number
  );
--
end pay_gbe_rkd;

 

/
