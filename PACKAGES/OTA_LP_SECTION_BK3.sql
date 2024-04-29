--------------------------------------------------------
--  DDL for Package OTA_LP_SECTION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LP_SECTION_BK3" AUTHID CURRENT_USER as
/* $Header: otlpcapi.pkh 120.1 2005/10/02 02:36:59 aroussel $ */

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_lp_section_b >----------------|
-- ----------------------------------------------------------------------------
procedure delete_lp_section_b
  (p_learning_path_section_id       in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_lp_section_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_lp_section_a
  (p_learning_path_section_id       in     number
  ,p_object_version_number         in     number
  );
--
end ota_lp_section_bk3;

 

/
