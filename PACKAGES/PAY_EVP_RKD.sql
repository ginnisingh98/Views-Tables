--------------------------------------------------------
--  DDL for Package PAY_EVP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVP_RKD" AUTHID CURRENT_USER as
/* $Header: pyevprhi.pkh 120.0 2005/05/29 04:48:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_event_procedure_id           in number
  ,p_dated_table_id_o             in number
  ,p_procedure_name_o             in varchar2
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_column_name_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_evp_rkd;

 

/
