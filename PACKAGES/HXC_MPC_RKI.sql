--------------------------------------------------------
--  DDL for Package HXC_MPC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_MPC_RKI" AUTHID CURRENT_USER as
/* $Header: hxcmpcrhi.pkh 120.0 2005/05/29 05:48:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_mapping_component_id         in number
  ,p_field_name                   in varchar2
  ,p_name                         in varchar2
  ,p_bld_blk_info_type_id         in number
  ,p_segment                      in varchar2
  ,p_object_version_number        in number
  );
end hxc_mpc_rki;

 

/
