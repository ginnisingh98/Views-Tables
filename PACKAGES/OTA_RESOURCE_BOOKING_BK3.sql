--------------------------------------------------------
--  DDL for Package OTA_RESOURCE_BOOKING_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_RESOURCE_BOOKING_BK3" AUTHID CURRENT_USER as
/* $Header: ottrbapi.pkh 120.4 2006/03/06 02:29:49 rdola noship $ */

-- ----------------------------------------------------------------------------
-- |---------------------< delete_resource_booking_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_resource_booking_b
 (
  p_resource_booking_id                in number,
  p_object_version_number              in number,
  p_validate                           in boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_resource_booking_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_resource_booking_a
 (
  p_resource_booking_id                in number,
  p_object_version_number              in number,
  p_validate                           in boolean
  );
--
end ota_resource_booking_bk3;


 

/
