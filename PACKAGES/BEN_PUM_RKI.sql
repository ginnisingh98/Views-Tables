--------------------------------------------------------
--  DDL for Package BEN_PUM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PUM_RKI" AUTHID CURRENT_USER as
/* $Header: bepumrhi.pkh 120.0 2005/05/28 11:27:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
  );
end ben_pum_rki;

 

/
