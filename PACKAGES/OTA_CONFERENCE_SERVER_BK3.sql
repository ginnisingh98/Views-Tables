--------------------------------------------------------
--  DDL for Package OTA_CONFERENCE_SERVER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CONFERENCE_SERVER_BK3" AUTHID CURRENT_USER as
/* $Header: otcfsapi.pkh 120.3 2006/07/13 12:24:25 niarora noship $ */

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_conference_server_b >-------------------|
-- ----------------------------------------------------------------------------
procedure delete_conference_server_b
  (p_conference_server_id       in     number
  ,p_object_version_number      in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_conference_server_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_conference_server_a
  (p_conference_server_id       in     number
  ,p_object_version_number      in     number
  );
--
end ota_conference_server_bk3;

 

/
