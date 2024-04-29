--------------------------------------------------------
--  DDL for Package HR_OPT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_OPT_RKU" AUTHID CURRENT_USER as
/* $Header: hroptrhi.pkh 120.0 2005/05/31 01:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
   p_option_id                    in number
  ,p_value                        in varchar2
  ,p_encrypted                    in varchar2
  ,p_object_version_number        in number
  ,p_option_type_id_o             in number
  ,p_option_level_o               in number
  ,p_option_level_id_o            in varchar2
  ,p_value_o                      in varchar2
  ,p_encrypted_o                  in varchar2
  ,p_integration_id_o             in number
  ,p_object_version_number_o      in number
  );
--
end hr_opt_rku;

 

/
