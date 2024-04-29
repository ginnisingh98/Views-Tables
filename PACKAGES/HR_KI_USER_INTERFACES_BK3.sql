--------------------------------------------------------
--  DDL for Package HR_KI_USER_INTERFACES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_USER_INTERFACES_BK3" AUTHID CURRENT_USER as
/* $Header: hritfapi.pkh 120.1 2005/10/02 02:03:16 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_user_interface_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_user_interface_b
  (
   p_user_interface_id             in     number
  ,p_object_version_number         in     number

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_user_interface_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_user_interface_a
  (
   p_user_interface_id             in     number
  ,p_object_version_number         in     number
  );
--
end hr_ki_user_interfaces_bk3;

 

/
