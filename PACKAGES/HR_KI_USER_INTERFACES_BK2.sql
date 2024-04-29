--------------------------------------------------------
--  DDL for Package HR_KI_USER_INTERFACES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_USER_INTERFACES_BK2" AUTHID CURRENT_USER as
/* $Header: hritfapi.pkh 120.1 2005/10/02 02:03:16 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_user_interface_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_user_interface_b
  (
   p_effective_date                in     date
  ,p_type                          in     varchar2
  ,p_form_name                     in     varchar2
  ,p_page_region_code              in     varchar2
  ,p_region_code                   in     varchar2
  ,p_user_interface_id             in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_user_interface_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_user_interface_a
  (
   p_effective_date                in     date
  ,p_type                          in     varchar2
  ,p_form_name                     in     varchar2
  ,p_page_region_code              in     varchar2
  ,p_region_code                   in     varchar2
  ,p_user_interface_id             in     number
  ,p_object_version_number         in     number
  );
--
end hr_ki_user_interfaces_bk2;

 

/
