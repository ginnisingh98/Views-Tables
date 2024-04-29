--------------------------------------------------------
--  DDL for Package BEN_POPUP_MESSAGE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_POPUP_MESSAGE_BK1" AUTHID CURRENT_USER as
/* $Header: bepumapi.pkh 120.0 2005/05/28 11:26:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_popup_message_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_popup_message_b
  (
   p_pop_name                       in  varchar2
  ,p_formula_id                     in  number
  ,p_function_name                  in  varchar2
  ,p_block_name                     in  varchar2
  ,p_field_name                     in  varchar2
  ,p_event_name                     in  varchar2
  ,p_message                        in  varchar2
  ,p_message_type                   in  varchar2
  ,p_business_group_id              in  number
  ,p_start_date                     in  date
  ,p_end_date                       in  date
  ,p_no_formula_flag                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_popup_message_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_popup_message_a
  (
   p_pop_up_messages_id             in  number
  ,p_pop_name                       in  varchar2
  ,p_formula_id                     in  number
  ,p_function_name                  in  varchar2
  ,p_block_name                     in  varchar2
  ,p_field_name                     in  varchar2
  ,p_event_name                     in  varchar2
  ,p_message                        in  varchar2
  ,p_message_type                   in  varchar2
  ,p_business_group_id              in  number
  ,p_object_version_number          in  number
  ,p_start_date                     in  date
  ,p_end_date                       in  date
  ,p_no_formula_flag                in  varchar2
  ,p_effective_date                 in  date
  );
--
end ben_popup_message_bk1;

 

/
