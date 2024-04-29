--------------------------------------------------------
--  DDL for Package HXC_TKGQ_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TKGQ_RKI" AUTHID CURRENT_USER as
/* $Header: hxctkgqrhi.pkh 120.0.12010000.1 2008/07/28 11:24:04 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_tk_group_query_id        in number
  ,p_tk_group_id              in number
  ,p_group_query_name         in varchar2
  ,p_include_exclude          in varchar2
  ,p_system_user              in varchar2
  ,p_object_version_number    in number
  );
end hxc_tkgq_rki;

/
