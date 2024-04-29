--------------------------------------------------------
--  DDL for Package HR_HNM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HNM_RKD" AUTHID CURRENT_USER as
/* $Header: hrhnmrhi.pkh 120.0 2005/05/31 00:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_hierarchy_node_map_id        in number
  ,p_hierarchy_id_o               in number
  ,p_topic_id_o                   in number
  ,p_user_interface_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end hr_hnm_rkd;

 

/
