--------------------------------------------------------
--  DDL for Package OTA_BOOKING_STATUS_TYPE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_BOOKING_STATUS_TYPE_BK3" AUTHID CURRENT_USER as
/* $Header: otbstapi.pkh 120.2 2006/08/30 06:58:23 niarora noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_BOOKING_STATUS_TYPE_BK3.';
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_BOOKING_STATUS_TYPE_B >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  Before Process User Hook.
--
-- {End Of Comments}
--
procedure DELETE_BOOKING_STATUS_TYPE_B
  (p_booking_status_type_id                   in     number
  ,p_object_version_number         in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_BOOKING_STATUS_TYPE_A >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  After Process User Hook.
--
-- {End Of Comments}
--
procedure DELETE_BOOKING_STATUS_TYPE_A
  (  p_booking_status_type_id                   in     number
  ,p_object_version_number         in     number
  );

end OTA_BOOKING_STATUS_TYPE_BK3;

 

/
