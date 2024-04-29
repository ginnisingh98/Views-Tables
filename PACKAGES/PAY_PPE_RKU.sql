--------------------------------------------------------
--  DDL for Package PAY_PPE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPE_RKU" AUTHID CURRENT_USER as
/* $Header: pypperhi.pkh 115.0 2000/06/07 04:40:52 pkm ship        $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_process_event_id             in number
  ,p_assignment_id                in number
  ,p_effective_date               in date
  ,p_change_type                  in varchar2
  ,p_status                       in varchar2
  ,p_description                  in varchar2
  ,p_object_version_number        in number
  ,p_assignment_id_o              in number
  ,p_effective_date_o             in date
  ,p_change_type_o                in varchar2
  ,p_status_o                     in varchar2
  ,p_description_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_ppe_rku;

 

/
