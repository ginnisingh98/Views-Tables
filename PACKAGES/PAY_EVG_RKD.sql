--------------------------------------------------------
--  DDL for Package PAY_EVG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVG_RKD" AUTHID CURRENT_USER as
/* $Header: pyevgrhi.pkh 120.1 2005/07/08 02:46:26 kkawol noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_event_group_id               in number
  ,p_event_group_name_o           in varchar2
  ,p_event_group_type_o           in varchar2
  ,p_proration_type_o             in varchar2
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_object_version_number_o      in number
  ,p_time_definition_id_o         in number
  );
--
end pay_evg_rkd;

 

/
