--------------------------------------------------------
--  DDL for Package HR_HRC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HRC_RKI" AUTHID CURRENT_USER as
/* $Header: hrhrcrhi.pkh 120.0 2005/05/31 00:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_hierarchy_id                 in number
  ,p_hierarchy_key                in varchar2
  ,p_parent_hierarchy_id          in number
  ,p_object_version_number        in number
  );
end hr_hrc_rki;

 

/
