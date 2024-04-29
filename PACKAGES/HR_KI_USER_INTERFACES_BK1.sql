--------------------------------------------------------
--  DDL for Package HR_KI_USER_INTERFACES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_USER_INTERFACES_BK1" AUTHID CURRENT_USER as
/* $Header: hritfapi.pkh 120.1 2005/10/02 02:03:16 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_user_interface_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_user_interface_b
  (
   p_effective_date                in     date
  ,p_type                          in     varchar2
  ,p_form_name                     in     varchar2
  ,p_page_region_code              in     varchar2
  ,p_region_code                   in     varchar2

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_user_interface_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_user_interface_a
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
end hr_ki_user_interfaces_bk1;

 

/
