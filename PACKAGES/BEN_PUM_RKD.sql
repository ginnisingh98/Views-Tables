--------------------------------------------------------
--  DDL for Package BEN_PUM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PUM_RKD" AUTHID CURRENT_USER as
/* $Header: bepumrhi.pkh 120.0 2005/05/28 11:27:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_pop_up_messages_id             in number
 ,p_pop_name_o                     in varchar2
 ,p_formula_id_o                   in number
 ,p_function_name_o                in varchar2
 ,p_block_name_o                   in varchar2
 ,p_field_name_o                   in varchar2
 ,p_event_name_o                   in varchar2
 ,p_message_o                      in varchar2
 ,p_message_type_o                 in varchar2
 ,p_business_group_id_o            in number
 ,p_object_version_number_o        in number
 ,p_start_date_o                   in date
 ,p_end_date_o                     in date
 ,p_no_formula_flag_o              in varchar2
  );
--
end ben_pum_rkd;

 

/
