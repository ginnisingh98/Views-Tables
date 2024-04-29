--------------------------------------------------------
--  DDL for Package HXC_TKGQ_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TKGQ_RKU" AUTHID CURRENT_USER as
/* $Header: hxctkgqrhi.pkh 120.0.12010000.1 2008/07/28 11:24:04 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_tk_group_query_id        in number
  ,p_tk_group_id              in number
  ,p_group_query_name         in varchar2
  ,p_include_exclude          in varchar2
  ,p_system_user              in varchar2
  ,p_object_version_number    in number
  ,p_tk_group_id_o            in number
  ,p_group_query_name_o       in varchar2
  ,p_include_exclude_o        in varchar2
  ,p_system_user_o            in varchar2
  ,p_object_version_number_o  in number
  );
--
end hxc_tkgq_rku;

/
