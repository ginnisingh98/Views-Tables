--------------------------------------------------------
--  DDL for Package PQH_PTI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PTI_RKD" AUTHID CURRENT_USER as
/* $Header: pqptirhi.pkh 120.1 2005/10/12 20:18:53 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_information_type               in varchar2
 ,p_active_inactive_flag_o         in varchar2
 ,p_description_o                  in varchar2
 ,p_multiple_occurences_flag_o     in varchar2
 ,p_legislation_code_o             in varchar2
 ,p_object_version_number_o        in number
  );
--
end pqh_pti_rkd;

 

/
