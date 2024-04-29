--------------------------------------------------------
--  DDL for Package HR_KI_OPTIONS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_OPTIONS_BK1" AUTHID CURRENT_USER as
/* $Header: hroptapi.pkh 120.1 2005/10/02 02:04:45 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_option_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_option_b
  (
   p_effective_date                in     date
  ,p_option_type_id                in     number
  ,p_option_level                  in     number
  ,p_option_level_id               in     varchar2
  ,p_value                         in     varchar2
  ,p_encrypted                     in     varchar2
  ,p_integration_id                in     number

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_option_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_option_a
  (
   p_effective_date                in     date
  ,p_option_type_id                in     number
  ,p_option_level                  in     number
  ,p_option_level_id               in     varchar2
  ,p_value                         in     varchar2
  ,p_encrypted                     in     varchar2
  ,p_integration_id                in     number
  ,p_option_id                     in     number
  ,p_object_version_number         in     number
  );
--
end hr_ki_options_bk1;

 

/
