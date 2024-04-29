--------------------------------------------------------
--  DDL for Package HXC_MAP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_MAP_RKU" AUTHID CURRENT_USER as
/* $Header: hxcmaprhi.pkh 120.0.12010000.1 2008/07/28 11:15:59 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_mapping_id                   in number
  ,p_name                         in varchar2
  ,p_object_version_number        in number
  ,p_name_o                       in varchar2
  ,p_object_version_number_o      in number
  );
--
end hxc_map_rku;

/
