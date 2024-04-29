--------------------------------------------------------
--  DDL for Package HR_KI_OPTIONS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_OPTIONS_BK2" AUTHID CURRENT_USER as
/* $Header: hroptapi.pkh 120.1 2005/10/02 02:04:45 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_option_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_option_b
  (
   p_value                         in     varchar2
  ,p_encrypted                     in     varchar2
  ,p_option_id                     in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_option_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_option_a
  (
   p_value                         in     varchar2
  ,p_encrypted                     in     varchar2
  ,p_option_id                     in     number
  ,p_object_version_number         in     number
  );
--
end hr_ki_options_bk2;

 

/
