--------------------------------------------------------
--  DDL for Package OTA_BKNG_JUSTIFICATION_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_BKNG_JUSTIFICATION_BK1" AUTHID CURRENT_USER as
/* $Header: otbjsapi.pkh 120.1 2006/08/30 06:55:10 niarora noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_booking_justification_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_booking_justification_b
  (  p_effective_date               in date,
  p_validate                     in boolean,
  p_priority_level                    in varchar2,
  p_justification_text             in varchar2 ,
  p_business_group_id            in number,
  p_start_date_active            in date,
  p_end_date_active              in date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_booking_justification_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_booking_justification_a
  ( p_effective_date               in date,
  p_validate                     in boolean,
  p_priority_level                    in varchar2,
  p_justification_text             in varchar2 ,
  p_business_group_id            in number,
  p_start_date_active            in date,
  p_end_date_active              in date
  );

end ota_bkng_justification_bk1 ;

 

/
