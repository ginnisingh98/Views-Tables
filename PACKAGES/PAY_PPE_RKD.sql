--------------------------------------------------------
--  DDL for Package PAY_PPE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPE_RKD" AUTHID CURRENT_USER as
/* $Header: pypperhi.pkh 115.0 2000/06/07 04:40:52 pkm ship        $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_process_event_id             in number
  ,p_assignment_id_o              in number
  ,p_effective_date_o             in date
  ,p_change_type_o                in varchar2
  ,p_status_o                     in varchar2
  ,p_description_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_ppe_rkd;

 

/
