--------------------------------------------------------
--  DDL for Package OTA_BKNG_JUSTIFICATION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_BKNG_JUSTIFICATION_BK3" AUTHID CURRENT_USER as
/* $Header: otbjsapi.pkh 120.1 2006/08/30 06:55:10 niarora noship $ */

-- ----------------------------------------------------------------------------
-- |---------------------< delete_booking_justification_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_booking_justification_b
  ( p_booking_justification_id                in number,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_booking_justification_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_booking_justification_a
  ( p_booking_justification_id                in number,
  p_object_version_number              in number
  );
--
end ota_bkng_justification_bk3;

 

/
