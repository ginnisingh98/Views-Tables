--------------------------------------------------------
--  DDL for Package OTA_BKNG_JUSTIFICATION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_BKNG_JUSTIFICATION_BK2" AUTHID CURRENT_USER as
/* $Header: otbjsapi.pkh 120.1 2006/08/30 06:55:10 niarora noship $ */
-- ----------------------------------------------------------------------------
-- |----------------< update_booking_justification_b >----------------------------|
-- ----------------------------------------------------------------------------
procedure update_booking_justification_b
  (p_effective_date               in date,
  p_booking_justification_id             in number,
  p_priority_level                    in varchar2,
  p_justification_text in varchar2,
  p_object_version_number        in number,
  p_start_date_active            in date,
  p_end_date_active              in date,
  p_business_group_id            in number            ,
  p_validate                     in boolean
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_booking_justification_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_booking_justification_a
  (p_effective_date               in date,
  p_booking_justification_id             in number,
  p_priority_level                    in varchar2,
  p_justification_text in varchar2,
  p_object_version_number        in number,
  p_start_date_active            in date,
  p_end_date_active              in date,
  p_business_group_id            in number            ,
  p_validate                     in boolean
  );

end ota_bkng_justification_bk2;

 

/
