--------------------------------------------------------
--  DDL for Package HXC_HAS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HAS_RKI" AUTHID CURRENT_USER as
/* $Header: hxchasrhi.pkh 120.2 2006/06/08 13:22:58 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_approval_style_id            in number
  ,p_object_version_number        in number
  ,p_name                         in varchar2
  ,p_business_group_id		  in number
  ,p_legislation_code		  in varchar2
  ,p_description                  in varchar2
  ,p_run_recipient_extensions     in varchar2
  ,p_admin_role                   in varchar2
  ,p_error_admin_role             in varchar2
  );
end hxc_has_rki;

 

/
