--------------------------------------------------------
--  DDL for Package HXC_HAT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HAT_RKU" AUTHID CURRENT_USER as
/* $Header: hxchatrhi.pkh 120.0 2005/05/29 05:34:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_alias_type_id                in number
  ,p_alias_type                   in varchar2
  ,p_reference_object             in varchar2
  ,p_object_version_number        in number
  ,p_alias_type_o                 in varchar2
  ,p_reference_object_o           in varchar2
  ,p_object_version_number_o      in number
  );
--
end hxc_hat_rku;

 

/
