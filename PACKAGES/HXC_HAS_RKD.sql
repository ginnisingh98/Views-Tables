--------------------------------------------------------
--  DDL for Package HXC_HAS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HAS_RKD" AUTHID CURRENT_USER as
/* $Header: hxchasrhi.pkh 120.2 2006/06/08 13:22:58 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_approval_style_id            in number
  ,p_object_version_number_o      in number
  ,p_name_o                       in varchar2
  ,p_business_group_id_o	  in number
  ,p_legislation_code_o		  in varchar2
  ,p_description_o                in varchar2
  ,p_run_recipient_extensions_o   in varchar2
  ,p_admin_role_o                 in varchar2
  ,p_error_admin_role_o           in varchar2
  );
--
end hxc_has_rkd;

 

/
