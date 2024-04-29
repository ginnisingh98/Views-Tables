--------------------------------------------------------
--  DDL for Package HXC_HAD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HAD_RKI" AUTHID CURRENT_USER as
/* $Header: hxchadrhi.pkh 120.0 2005/05/29 05:32:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_alias_definition_id          in number
  ,p_description                  in varchar2
  ,p_alias_definition_name        in varchar2
  ,p_alias_context_code 	  in varchar2
  ,p_business_group_id		  in number
  ,p_legislation_code		  in varchar2
  ,p_timecard_field               in varchar2
  ,p_object_version_number        in number
  ,p_alias_type_id 		  in number
  );
end hxc_had_rki;

 

/
