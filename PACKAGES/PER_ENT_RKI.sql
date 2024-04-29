--------------------------------------------------------
--  DDL for Package PER_ENT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ENT_RKI" AUTHID CURRENT_USER as
/* $Header: peentrhi.pkh 120.0 2005/05/31 08:09:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_calendar_entry_id            in number
  ,p_business_group_id            in number
  ,p_name                         in varchar2
  ,p_type                         in varchar2
  ,p_start_date                   in date
  ,p_start_hour                   in varchar2
  ,p_start_min                    in varchar2
  ,p_end_date                     in date
  ,p_end_hour                     in varchar2
  ,p_end_min                      in varchar2
  ,p_description                  in varchar2
  ,p_hierarchy_id                 in number
  ,p_value_set_id                 in number
  ,p_organization_structure_id    in number
  ,p_org_structure_version_id     in number
  ,p_object_version_number        in number
  );
end per_ent_rki;

 

/
