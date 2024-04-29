--------------------------------------------------------
--  DDL for Package HXC_APS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APS_RKD" AUTHID CURRENT_USER as
/* $Header: hxcaprpsrhi.pkh 120.0 2005/05/29 06:12:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_approval_period_set_id       in number
  ,p_name_o                       in varchar2
  ,p_object_version_number_o      in number
  );
--
end hxc_aps_rkd;

 

/
