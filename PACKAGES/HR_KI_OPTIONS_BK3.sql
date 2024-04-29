--------------------------------------------------------
--  DDL for Package HR_KI_OPTIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_OPTIONS_BK3" AUTHID CURRENT_USER as
/* $Header: hroptapi.pkh 120.1 2005/10/02 02:04:45 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_option_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_option_b
  (
   p_option_id                     in     number
  ,p_object_version_number         in     number

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_option_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_option_a
  (
   p_option_id                     in     number
  ,p_object_version_number         in     number
  );
--
end hr_ki_options_bk3;

 

/
