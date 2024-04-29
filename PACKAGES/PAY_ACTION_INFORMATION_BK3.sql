--------------------------------------------------------
--  DDL for Package PAY_ACTION_INFORMATION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ACTION_INFORMATION_BK3" AUTHID CURRENT_USER as
/* $Header: pyaifapi.pkh 120.1 2005/10/02 02:29:11 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_action_information_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_action_information_b
  (
   p_action_information_id          in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_action_information_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_action_information_a
  (
   p_action_information_id          in  number
  ,p_object_version_number          in  number
  );
--
end pay_action_information_bk3;

 

/
