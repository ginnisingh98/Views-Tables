--------------------------------------------------------
--  DDL for Package PAY_PPE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPE_RKI" AUTHID CURRENT_USER as
/* $Header: pypperhi.pkh 115.0 2000/06/07 04:40:52 pkm ship        $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_process_event_id             in number
  ,p_assignment_id                in number
  ,p_effective_date               in date
  ,p_change_type                  in varchar2
  ,p_status                       in varchar2
  ,p_description                  in varchar2
  ,p_object_version_number        in number
  );
end pay_ppe_rki;

 

/
