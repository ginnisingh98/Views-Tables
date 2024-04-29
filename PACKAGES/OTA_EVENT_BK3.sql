--------------------------------------------------------
--  DDL for Package OTA_EVENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_EVENT_BK3" AUTHID CURRENT_USER as
/* $Header: otevtapi.pkh 120.2.12010000.3 2009/05/27 13:24:01 pekasi ship $ */

-- ----------------------------------------------------------------------------
-- |----------------------------< delete_class_a >----------------------------|
-- ----------------------------------------------------------------------------
procedure delete_class_a
  ( p_event_id                      in     number,
    p_object_version_number         in     number

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_class_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_class_b
  ( p_event_id                     in     number,
    p_object_version_number        in     number
  );
--
end ota_event_bk3;

/
