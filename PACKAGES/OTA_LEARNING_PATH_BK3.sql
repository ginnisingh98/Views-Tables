--------------------------------------------------------
--  DDL for Package OTA_LEARNING_PATH_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LEARNING_PATH_BK3" AUTHID CURRENT_USER as
/* $Header: otlpsapi.pkh 120.3 2005/11/07 03:26:28 rdola noship $ */

-- ----------------------------------------------------------------------------
-- |---------------------< delete_learning_path_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_learning_path_b
  ( p_learning_path_id                in number,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_learning_path_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_learning_path_a
  ( p_learning_path_id                in number,
  p_object_version_number              in number
  );
--
end ota_learning_path_bk3;

 

/
