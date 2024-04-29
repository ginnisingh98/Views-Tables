--------------------------------------------------------
--  DDL for Package OTA_RESOURCE_DEFINITION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_RESOURCE_DEFINITION_BK3" AUTHID CURRENT_USER as
/* $Header: ottsrapi.pkh 120.3 2006/08/04 10:43:59 niarora noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_RESOURCE_DEFINITION_BK3.';
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_RESOURCE_DEFINITION_B >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  Before Process User Hook.
--
-- {End Of Comments}
--
procedure DELETE_RESOURCE_DEFINITION_B
  (p_supplied_resource_id                   in     number
  ,p_object_version_number         in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_RESOURCE_DEFINITION_A >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  After Process User Hook.
--
-- {End Of Comments}
--
procedure DELETE_RESOURCE_DEFINITION_A
  (  p_supplied_resource_id                   in     number
  ,p_object_version_number         in     number
  );

end OTA_RESOURCE_DEFINITION_BK3;

 

/
