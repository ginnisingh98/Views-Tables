--------------------------------------------------------
--  DDL for Package PER_ENT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ENT_RKD" AUTHID CURRENT_USER as
/* $Header: peentrhi.pkh 120.0 2005/05/31 08:09:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_calendar_entry_id            in number
  ,p_business_group_id_o          in number
  ,p_name_o                       in varchar2
  ,p_type_o                       in varchar2
  ,p_start_date_o                 in date
  ,p_start_hour_o                 in varchar2
  ,p_start_min_o                  in varchar2
  ,p_end_date_o                   in date
  ,p_end_hour_o                   in varchar2
  ,p_end_min_o                    in varchar2
  ,p_description_o                in varchar2
  ,p_hierarchy_id_o               in number
  ,p_value_set_id_o               in number
  ,p_organization_structure_id_o  in number
  ,p_org_structure_version_id_o   in number
  ,p_object_version_number_o      in number
  );
--
end per_ent_rkd;

 

/
