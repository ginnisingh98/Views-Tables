--------------------------------------------------------
--  DDL for Package PAY_EVG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVG_RKI" AUTHID CURRENT_USER as
/* $Header: pyevgrhi.pkh 120.1 2005/07/08 02:46:26 kkawol noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_event_group_id               in number
  ,p_event_group_name             in varchar2
  ,p_event_group_type             in varchar2
  ,p_proration_type               in varchar2
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_object_version_number        in number
  ,p_time_definition_id           in number
  );
end pay_evg_rki;

 

/
