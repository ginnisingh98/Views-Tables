--------------------------------------------------------
--  DDL for Package OTA_TPC_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPC_API_BK3" AUTHID CURRENT_USER as
/* $Header: ottpcapi.pkh 120.1 2005/10/02 02:08:30 aroussel $ */

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_cost_b >---------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_cost_b
  (p_training_plan_cost_id         in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_cost_a >---------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cost_a
  (p_training_plan_cost_id         in     number
  ,p_object_version_number         in     number
  );
--
end ota_tpc_api_bk3;

 

/
