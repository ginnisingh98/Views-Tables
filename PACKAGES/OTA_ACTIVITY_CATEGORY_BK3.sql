--------------------------------------------------------
--  DDL for Package OTA_ACTIVITY_CATEGORY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ACTIVITY_CATEGORY_BK3" AUTHID CURRENT_USER as
/* $Header: otaciapi.pkh 120.1 2005/10/02 02:07:13 aroussel $ */

-- ----------------------------------------------------------------------------
-- |---------------------< delete_act_cat_inclusion_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_act_cat_inclusion_b
  ( p_activity_version_id                in number,
  p_category_usage_id                    in number,
  p_object_version_number              in number

  );
--
-- ----------------------------------------------------------------------------
-- |---------------< delete_act_cat_inclusion_a >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_act_cat_inclusion_a
  ( p_activity_version_id                in number,
  p_category_usage_id                    in number,
  p_object_version_number              in number
  );
--
end ota_activity_category_bk3;

 

/
