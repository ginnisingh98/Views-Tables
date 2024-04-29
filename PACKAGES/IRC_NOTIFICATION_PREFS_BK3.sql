--------------------------------------------------------
--  DDL for Package IRC_NOTIFICATION_PREFS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_NOTIFICATION_PREFS_BK3" AUTHID CURRENT_USER as
/* $Header: irinpapi.pkh 120.4 2008/02/21 14:16:27 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_notification_prefs_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_notification_prefs_b
  (p_notification_preference_id    in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_notification_prefs_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_notification_prefs_a
  (p_notification_preference_id    in     number
  ,p_object_version_number         in     number
  );
--
end IRC_NOTIFICATION_PREFS_BK3;

/
