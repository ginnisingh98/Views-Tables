--------------------------------------------------------
--  DDL for Package HXC_TKG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TKG_RKI" AUTHID CURRENT_USER as
/* $Header: hxctkgrhi.pkh 120.0.12010000.1 2008/07/28 11:24:10 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_tk_group_id              in number
  ,p_tk_group_name            in varchar2
  ,p_tk_resource_id              in number
  ,p_object_version_number    in number
  ,p_business_group_id        in number
  );
end hxc_tkg_rki;

/
