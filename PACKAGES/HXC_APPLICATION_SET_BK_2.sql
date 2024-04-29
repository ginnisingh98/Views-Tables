--------------------------------------------------------
--  DDL for Package HXC_APPLICATION_SET_BK_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPLICATION_SET_BK_2" AUTHID CURRENT_USER as
/* $Header: hxcapsapi.pkh 120.0 2005/05/29 05:25:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------<update_application_set_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_application_set_b
  (p_application_set_id       in     number
  ,p_object_version_number          in     number
  ,p_name                           in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_application_set_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_application_set_a
  (p_application_set_id       in     number
  ,p_object_version_number          in     number
  ,p_name                           in     varchar2
  );
--
end hxc_application_set_bk_2;

 

/
