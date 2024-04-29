--------------------------------------------------------
--  DDL for Package OTA_OFFERING_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OFFERING_BK3" AUTHID CURRENT_USER as
/* $Header: otoffapi.pkh 120.4.12010000.2 2008/08/05 11:45:04 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ota_offering_bk3.';
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_OFFERING_B >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  Before Process User Hook.
--
-- {End Of Comments}
--
procedure Delete_Offering_b
  (p_offering_id                   in     number
  ,p_object_version_number         in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_OFFERING_A >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  After Process User Hook.
--
-- {End Of Comments}
--
procedure Delete_Offering_a
  (  p_offering_id                   in     number
  ,p_object_version_number         in     number
  );

end ota_offering_bk3;

/
