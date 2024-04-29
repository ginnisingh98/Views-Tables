--------------------------------------------------------
--  DDL for Package PER_PSO_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PSO_RKD" AUTHID CURRENT_USER as
/* $Header: pepsorhi.pkh 120.0 2005/05/31 15:23:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_security_organization_id     in number
  ,p_organization_id_o            in number
  ,p_security_profile_id_o        in number
  ,p_entry_type_o                 in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_pso_rkd;

 

/
