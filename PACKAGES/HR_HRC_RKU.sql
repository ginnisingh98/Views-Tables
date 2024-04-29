--------------------------------------------------------
--  DDL for Package HR_HRC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HRC_RKU" AUTHID CURRENT_USER as
/* $Header: hrhrcrhi.pkh 120.0 2005/05/31 00:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_hierarchy_id                 in number
  ,p_parent_hierarchy_id          in number
  ,p_object_version_number        in number
  ,p_hierarchy_key_o              in varchar2
  ,p_parent_hierarchy_id_o        in number
  ,p_object_version_number_o      in number
  );
--
end hr_hrc_rku;

 

/
