--------------------------------------------------------
--  DDL for Package PQH_DEF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DEF_RKI" AUTHID CURRENT_USER as
/* $Header: pqdefrhi.pkh 120.0 2005/05/29 01:46:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_wrkplc_vldtn_id              in number
  ,p_validation_name              in varchar2
  ,p_business_group_id            in number
  ,p_employment_type              in varchar2
  ,p_remuneration_regulation      in varchar2
  ,p_object_version_number        in number
  );
end pqh_def_rki;

 

/
