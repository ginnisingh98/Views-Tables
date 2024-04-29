--------------------------------------------------------
--  DDL for Package HR_KI_OPTION_TYPES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_OPTION_TYPES_BK3" AUTHID CURRENT_USER as
/* $Header: hrotyapi.pkh 120.1 2005/10/02 02:05:08 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_option_type_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_option_type_b
  (
   p_option_type_id                in     number
  ,p_object_version_number         in     number

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_option_type_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_option_type_a
  (
   p_option_type_id                in     number
  ,p_object_version_number         in     number
  );
--
end hr_ki_option_types_bk3;

 

/
