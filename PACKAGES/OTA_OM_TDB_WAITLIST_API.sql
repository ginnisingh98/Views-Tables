--------------------------------------------------------
--  DDL for Package OTA_OM_TDB_WAITLIST_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OM_TDB_WAITLIST_API" AUTHID CURRENT_USER as
/* $Header: ottomint.pkh 120.20.12010000.10 2009/08/31 13:49:06 smahanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< AUTO_ENROLL_FROM_WAITLIST >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
-- p_validate
-- p_business_group_id
-- p_event_id
--
-- Out Parameters
-- p_return_status
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure AUTO_ENROLL_FROM_WAITLIST
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_event_id                      in     number   default null
  ,p_return_status           out nocopy    varchar2
  );
--
end OTA_OM_TDB_WAITLIST_API;

/
