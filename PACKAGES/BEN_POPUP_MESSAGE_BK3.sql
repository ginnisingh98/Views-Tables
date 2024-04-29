--------------------------------------------------------
--  DDL for Package BEN_POPUP_MESSAGE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_POPUP_MESSAGE_BK3" AUTHID CURRENT_USER as
/* $Header: bepumapi.pkh 120.0 2005/05/28 11:26:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_popup_message_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_popup_message_b
  (
   p_pop_up_messages_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_popup_message_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_popup_message_a
  (
   p_pop_up_messages_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_popup_message_bk3;

 

/
