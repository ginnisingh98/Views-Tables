--------------------------------------------------------
--  DDL for Package HXC_TKG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TKG_RKD" AUTHID CURRENT_USER as
/* $Header: hxctkgrhi.pkh 120.0.12010000.1 2008/07/28 11:24:10 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_tk_group_id              in number
  ,p_tk_group_name_o          in varchar2
  ,p_tk_resource_id_o            in number
  ,p_object_version_number_o  in number
  );
--
end hxc_tkg_rkd;

/
