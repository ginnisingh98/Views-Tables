--------------------------------------------------------
--  DDL for Package OTA_ACTIVITY_VERSION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ACTIVITY_VERSION_BK3" AUTHID CURRENT_USER as
/* $Header: ottavapi.pkh 120.4.12010000.2 2009/08/11 13:01:11 smahanka ship $ */

-- ----------------------------------------------------------------------------
-- |---------------------< delete_activity_version_a >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_activity_version_a
  ( p_activity_version_id           in     number
   ,p_object_version_number         in     number

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_activity_version_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_activity_version_b
  ( p_activity_version_id           in     number
  ,p_object_version_number         in     number
  );
--
end ota_activity_version_bk3;

/
