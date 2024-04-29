--------------------------------------------------------
--  DDL for Package PQH_OPG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_OPG_RKI" AUTHID CURRENT_USER as
/* $Header: pqopgrhi.pkh 120.0 2005/05/29 02:14:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_operation_group_id           in number
  ,p_operation_group_code         in varchar2
  ,p_description                  in varchar2
  ,p_business_group_id            in number
  ,p_object_version_number        in number
  );
end pqh_opg_rki;

 

/
