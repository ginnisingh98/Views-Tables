--------------------------------------------------------
--  DDL for Package HR_EAP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EAP_RKU" AUTHID CURRENT_USER as
/* $Header: hreaprhi.pkh 120.0 2005/05/30 23:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_ext_application_id           in number
  ,p_external_application_name    in varchar2
  ,p_external_application_name_o  in varchar2
  ,p_external_application_id_o    in varchar2
  );
--
end hr_eap_rku;

 

/
