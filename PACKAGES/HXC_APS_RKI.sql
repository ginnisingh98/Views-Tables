--------------------------------------------------------
--  DDL for Package HXC_APS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APS_RKI" AUTHID CURRENT_USER as
/* $Header: hxcaprpsrhi.pkh 120.0 2005/05/29 06:12:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_approval_period_set_id       in number
  ,p_name                         in varchar2
  ,p_object_version_number        in number
  );
end hxc_aps_rki;

 

/
