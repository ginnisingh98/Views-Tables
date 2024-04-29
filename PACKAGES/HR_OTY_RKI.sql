--------------------------------------------------------
--  DDL for Package HR_OTY_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_OTY_RKI" AUTHID CURRENT_USER as
/* $Header: hrotyrhi.pkh 120.0 2005/05/31 01:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_option_type_id               in number
  ,p_option_type_key              in varchar2
  ,p_display_type                 in varchar2
  ,p_object_version_number        in number
  );
end hr_oty_rki;

 

/
