--------------------------------------------------------
--  DDL for Package OTA_LP_MEMBER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LP_MEMBER_BK3" AUTHID CURRENT_USER as
/* $Header: otlpmapi.pkh 120.1 2005/10/02 02:07:38 aroussel $ */

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_learning_path_member_b >----------------|
-- ----------------------------------------------------------------------------
procedure delete_learning_path_member_b
  (p_learning_path_member_id       in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_learning_path_member_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_learning_path_member_a
  (p_learning_path_member_id       in     number
  ,p_object_version_number         in     number
  );
--
end ota_lp_member_bk3;

 

/
