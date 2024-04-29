--------------------------------------------------------
--  DDL for Package HXC_TKGQC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TKGQC_RKU" AUTHID CURRENT_USER as
/* $Header: hxctkgqcrhi.pkh 120.0 2005/05/29 06:15:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_tk_group_query_criteria_id   in number
  ,p_tk_group_query_id            in number
  ,p_criteria_type                in varchar2
  ,p_criteria_id                  in number
  ,p_object_version_number        in number
  ,p_tk_group_query_id_o          in number
  ,p_criteria_type_o              in varchar2
  ,p_criteria_id_o                in number
  ,p_object_version_number_o      in number
  );
--
end hxc_tkgqc_rku;

 

/
