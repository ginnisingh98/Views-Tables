--------------------------------------------------------
--  DDL for Package OTA_RESOURCE_USAGE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_RESOURCE_USAGE_BK3" AUTHID CURRENT_USER as
/* $Header: otrudapi.pkh 120.1 2005/10/02 02:07:53 aroussel $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ota_resource_usage_bk3.';
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_resource_b >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  Before Process User Hook.
--
-- {End Of Comments}
--
procedure Delete_resource_b
  (p_resource_usage_id             in     number
  ,p_object_version_number         in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_resource_a >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  After Process User Hook.
--
-- {End Of Comments}
--
procedure Delete_resource_a
  (p_resource_usage_id             in     number
  ,p_object_version_number         in     number
  );

end ota_resource_usage_bK3;

 

/
