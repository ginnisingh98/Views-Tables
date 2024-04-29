--------------------------------------------------------
--  DDL for Package OTA_TDB_WAITLIST_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TDB_WAITLIST_API" AUTHID CURRENT_USER as
/* $Header: ottdb03t.pkh 120.0 2005/05/29 07:38:38 appldev noship $ */
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
--   Name                           Reqd Type     Description
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
  );
--
end OTA_TDB_WAITLIST_API;

 

/
