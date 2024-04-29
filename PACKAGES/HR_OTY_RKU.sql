--------------------------------------------------------
--  DDL for Package HR_OTY_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_OTY_RKU" AUTHID CURRENT_USER as
/* $Header: hrotyrhi.pkh 120.0 2005/05/31 01:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_option_type_id               in number
  ,p_display_type                 in varchar2
  ,p_object_version_number        in number
  ,p_option_type_key_o            in varchar2
  ,p_display_type_o               in varchar2
  ,p_object_version_number_o      in number
  );
--
end hr_oty_rku;

 

/
