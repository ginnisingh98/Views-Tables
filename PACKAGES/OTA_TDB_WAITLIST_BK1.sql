--------------------------------------------------------
--  DDL for Package OTA_TDB_WAITLIST_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TDB_WAITLIST_BK1" AUTHID CURRENT_USER as
/* $Header: ottdb03t.pkh 120.0 2005/05/29 07:38:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< AUTO_ENROLL_FROM_WAITLIST_B >------------------|
-- ----------------------------------------------------------------------------
--
procedure AUTO_ENROLL_FROM_WAITLIST_B
  (p_business_group_id             in     number
  ,p_event_id                      in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< AUTO_ENROLL_FROM_WAITLIST_A >------------------|
-- ----------------------------------------------------------------------------
--
procedure AUTO_ENROLL_FROM_WAITLIST_A
  (p_business_group_id             in     number
  ,p_event_id                      in     number
  );
--
end OTA_TDB_WAITLIST_BK1;

 

/
