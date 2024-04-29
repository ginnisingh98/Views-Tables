--------------------------------------------------------
--  DDL for Package HXC_APPLICATION_SET_COMP_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPLICATION_SET_COMP_BK_3" AUTHID CURRENT_USER as
/* $Header: hxcascapi.pkh 120.0 2005/05/29 05:26:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_application_set_comp_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_application_set_comp_b
  (p_application_set_comp_id in  number
  ,p_object_version_number         in  number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_application_set_comp_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_application_set_comp_a
  (p_application_set_comp_id      in  number
  ,p_object_version_number         in  number
  );
--
end hxc_application_set_comp_bk_3;

 

/
