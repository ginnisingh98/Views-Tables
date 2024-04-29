--------------------------------------------------------
--  DDL for Package HXC_MPC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_MPC_RKD" AUTHID CURRENT_USER as
/* $Header: hxcmpcrhi.pkh 120.0 2005/05/29 05:48:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_mapping_component_id         in number
  ,p_field_name_o                 in varchar2
  ,p_name_o                       in varchar2
  ,p_bld_blk_info_type_id_o       in number
  ,p_segment_o                    in varchar2
  ,p_object_version_number_o      in number
  );
--
end hxc_mpc_rkd;

 

/
