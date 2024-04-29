--------------------------------------------------------
--  DDL for Package BEN_PUM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PUM_RKU" AUTHID CURRENT_USER as
/* $Header: bepumrhi.pkh 120.0 2005/05/28 11:27:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_pop_up_messages_id             in number
 ,p_pop_name                       in varchar2
 ,p_formula_id                     in number
 ,p_function_name                  in varchar2
 ,p_block_name                     in varchar2
 ,p_field_name                     in varchar2
 ,p_event_name                     in varchar2
 ,p_message                        in varchar2
 ,p_message_type                   in varchar2
 ,p_business_group_id              in number
 ,p_object_version_number          in number
 ,p_start_date                     in date
 ,p_end_date                       in date
 ,p_no_formula_flag                in varchar2
 ,p_effective_date                 in date
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
end ben_pum_rku;

 

/
