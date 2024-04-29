--------------------------------------------------------
--  DDL for Package PER_CNF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CNF_RKD" AUTHID CURRENT_USER as
/* $Header: pecnfrhi.pkh 120.0 2005/05/31 06:47:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_configuration_code           in varchar2
  ,p_configuration_type_o         in varchar2
  ,p_configuration_status_o       in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_cnf_rkd;

 

/
