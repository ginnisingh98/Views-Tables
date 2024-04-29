--------------------------------------------------------
--  DDL for Package PAY_TDU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TDU_RKI" AUTHID CURRENT_USER as
/* $Header: pytdurhi.pkh 120.1 2005/06/14 14:29 tvankayl noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_time_definition_id           in number
  ,p_usage_type                   in varchar2
  ,p_object_version_number        in number
  );
end pay_tdu_rki;

 

/
