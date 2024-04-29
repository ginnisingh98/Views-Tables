--------------------------------------------------------
--  DDL for Package OTA_ANNOUNCEMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ANNOUNCEMENT_BK3" AUTHID CURRENT_USER as
/* $Header: otancapi.pkh 120.1 2005/10/02 02:07:19 aroussel $ */

-- ----------------------------------------------------------------------------
-- |---------------------< delete_announcement_b >----------------------------|
-- ----------------------------------------------------------------------------
procedure delete_announcement_b
  ( p_announcement_id                in number,
  p_object_version_number              in number

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_announcement_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_announcement_a
  (  p_announcement_id                in number,
  p_object_version_number              in number
  );
--
end ota_announcement_bk3;

 

/
