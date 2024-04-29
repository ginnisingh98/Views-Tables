--------------------------------------------------------
--  DDL for Package PQH_PTI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PTI_RKU" AUTHID CURRENT_USER as
/* $Header: pqptirhi.pkh 120.1 2005/10/12 20:18:53 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_information_type               in varchar2
 ,p_active_inactive_flag           in varchar2
 ,p_description                    in varchar2
 ,p_multiple_occurences_flag       in varchar2
 ,p_legislation_code               in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_active_inactive_flag_o         in varchar2
 ,p_description_o                  in varchar2
 ,p_multiple_occurences_flag_o     in varchar2
 ,p_legislation_code_o             in varchar2
 ,p_object_version_number_o        in number
  );
--
end pqh_pti_rku;

 

/
