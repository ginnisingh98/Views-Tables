--------------------------------------------------------
--  DDL for Package PAY_TDU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TDU_RKD" AUTHID CURRENT_USER as
/* $Header: pytdurhi.pkh 120.1 2005/06/14 14:29 tvankayl noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_time_definition_id           in number
  ,p_usage_type                   in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_tdu_rkd;

 

/
