--------------------------------------------------------
--  DDL for Package HR_HNM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HNM_RKI" AUTHID CURRENT_USER as
/* $Header: hrhnmrhi.pkh 120.0 2005/05/31 00:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_hierarchy_node_map_id        in number
  ,p_hierarchy_id                 in number
  ,p_topic_id                     in number
  ,p_user_interface_id            in number
  ,p_object_version_number        in number
  );
end hr_hnm_rki;

 

/
