--------------------------------------------------------
--  DDL for Package OTA_TPS_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPS_API_BK3" AUTHID CURRENT_USER as
/* $Header: ottpsapi.pkh 120.1 2005/10/02 02:08:40 aroussel $ */

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_training_plan_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_training_plan_b
  (p_training_plan_id              in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_training_plan_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_training_plan_a
  (p_training_plan_id              in     number
  ,p_object_version_number         in     number
  );
--
end ota_tps_api_bk3;

 

/
