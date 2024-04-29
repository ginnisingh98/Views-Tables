--------------------------------------------------------
--  DDL for Package PER_CNF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CNF_RKU" AUTHID CURRENT_USER as
/* $Header: pecnfrhi.pkh 120.0 2005/05/31 06:47:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_configuration_code           in varchar2
  ,p_configuration_type           in varchar2
  ,p_configuration_status         in varchar2
  ,p_object_version_number        in number
  ,p_configuration_type_o         in varchar2
  ,p_configuration_status_o       in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_cnf_rku;

 

/
