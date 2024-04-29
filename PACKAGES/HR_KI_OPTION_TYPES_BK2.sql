--------------------------------------------------------
--  DDL for Package HR_KI_OPTION_TYPES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_OPTION_TYPES_BK2" AUTHID CURRENT_USER as
/* $Header: hrotyapi.pkh 120.1 2005/10/02 02:05:08 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_option_type_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_option_type_b
  (
   p_language_code                 in     varchar2
  ,p_display_type                  in     varchar2
  ,p_option_name                   in     varchar2
  ,p_option_type_id                in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_option_type_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_option_type_a
  (
   p_language_code                 in     varchar2
  ,p_display_type                  in     varchar2
  ,p_option_name                   in     varchar2
  ,p_option_type_id                in     number
  ,p_object_version_number         in     number
  );
--
end hr_ki_option_types_bk2;

 

/
