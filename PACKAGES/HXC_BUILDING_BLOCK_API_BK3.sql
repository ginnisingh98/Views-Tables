--------------------------------------------------------
--  DDL for Package HXC_BUILDING_BLOCK_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_BUILDING_BLOCK_API_BK3" AUTHID CURRENT_USER as
/* $Header: hxctbbapi.pkh 120.1 2005/07/14 17:18:24 arundell noship $ */

procedure delete_building_block_b
  (p_effective_date           in date
  );

procedure delete_building_block_a
  (p_effective_date           in date
  ,p_time_building_block_id   in number
  ,p_object_version_number    in number
  );

end hxc_building_block_api_bk3;

 

/
