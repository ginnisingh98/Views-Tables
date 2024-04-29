--------------------------------------------------------
--  DDL for Package HXC_HAT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HAT_RKI" AUTHID CURRENT_USER as
/* $Header: hxchatrhi.pkh 120.0 2005/05/29 05:34:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_alias_type_id                in number
  ,p_alias_type                   in varchar2
  ,p_reference_object             in varchar2
  ,p_object_version_number        in number
  );
end hxc_hat_rki;

 

/
