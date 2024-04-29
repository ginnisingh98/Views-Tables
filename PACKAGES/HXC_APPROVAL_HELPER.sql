--------------------------------------------------------
--  DDL for Package HXC_APPROVAL_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPROVAL_HELPER" AUTHID CURRENT_USER AS
/* $Header: hxcaprhlp.pkh 120.0 2006/03/06 16:43:44 arundell noship $ */

   Function createAdHocUser
              (p_resource_id in hxc_time_building_blocks.resource_id%type,
               p_effective_date in hxc_time_building_blocks.start_time%type)
     Return varchar2;

END hxc_approval_helper;

 

/
