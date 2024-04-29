--------------------------------------------------------
--  DDL for Package OTA_DELEGATE_BOOKING_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_DELEGATE_BOOKING_BK3" AUTHID CURRENT_USER as
/* $Header: otenrapi.pkh 120.13.12010000.6 2009/08/13 07:22:59 smahanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_DELEGATE_BOOKING_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_delegate_booking_b
(
  p_booking_id                         in number,
  p_object_version_number              in number
);

--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_DELEGATE_BOOKING_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_delegate_booking_a
(
  p_booking_id                         in number,
  p_object_version_number              in number,
  p_person_id                          in number
);
end OTA_DELEGATE_BOOKING_BK3;



/
