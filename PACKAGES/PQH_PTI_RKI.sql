--------------------------------------------------------
--  DDL for Package PQH_PTI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PTI_RKI" AUTHID CURRENT_USER as
/* $Header: pqptirhi.pkh 120.1 2005/10/12 20:18:53 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_information_type               in varchar2
 ,p_active_inactive_flag           in varchar2
 ,p_description                    in varchar2
 ,p_multiple_occurences_flag       in varchar2
 ,p_legislation_code               in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end pqh_pti_rki;

 

/
