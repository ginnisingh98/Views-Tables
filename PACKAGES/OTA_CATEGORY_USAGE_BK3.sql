--------------------------------------------------------
--  DDL for Package OTA_CATEGORY_USAGE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CATEGORY_USAGE_BK3" AUTHID CURRENT_USER as
/* $Header: otctuapi.pkh 120.1.12010000.2 2009/07/24 10:51:35 shwnayak ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ota_category_usage_bk3.';
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_CATEGORY_B >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  Before Process User Hook.
--
-- {End Of Comments}
--
procedure Delete_Category_b
  (p_category_usage_id             in     number
  ,p_object_version_number         in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_CATEGORY_A >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  After Process User Hook.
--
-- {End Of Comments}
--
procedure Delete_Category_a
  (p_category_usage_id             in     number
  ,p_object_version_number         in     number
  );

end ota_category_usage_bk3;

/
