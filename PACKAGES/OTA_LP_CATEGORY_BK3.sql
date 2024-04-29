--------------------------------------------------------
--  DDL for Package OTA_LP_CATEGORY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LP_CATEGORY_BK3" AUTHID CURRENT_USER as
/* $Header: otlciapi.pkh 120.1 2005/10/02 02:07:34 aroussel $ */

-- ----------------------------------------------------------------------------
-- |---------------------< delete_lp_cat_inclusion_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_lp_cat_inclusion_b
  ( p_learning_path_id                in number,
  p_category_usage_id                    in number,
  p_object_version_number              in number

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_lp_cat_inclusion_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_lp_cat_inclusion_a
  ( p_learning_path_id                in number,
  p_category_usage_id                    in number,
  p_object_version_number              in number
  );
--
end ota_lp_category_bk3;

 

/
