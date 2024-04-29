--------------------------------------------------------
--  DDL for Package OTA_TFL_API_BUSINESS_RULES2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TFL_API_BUSINESS_RULES2" AUTHID CURRENT_USER as
/* $Header: ottfl03t.pkh 115.3 2002/11/29 09:24:50 arkashya ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< set_all_amounts >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
--    Set the AMOUNTS standard_amount, money_amount and unitary_amount
--    depending on the finance_line type and the booking deal type.
--
Procedure set_all_amounts
  (
   p_finance_line_type        in      varchar2
  ,p_activity_version_id      in      number
  ,p_event_id                 in      number
  ,p_price_basis              in      varchar2 default null
  ,p_booking_id               in      number
  ,p_number_of_places         in      number default 1
  ,p_booking_deal_id          in      number
  ,p_resource_allocation_id   in      number
  ,p_resource_booking_id      in      number
  ,p_currency_code            in      varchar2
  ,p_standard_amount          in out nocopy number
  ,p_money_amount             in out nocopy number
  ,p_unitary_amount           in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< copy_lines_to_new_header >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    A procedure is required to copy all finance lines from one finance
--    header to another. Only those lines with a cancelled_flag = 'N'
--    will be copied.
--
Procedure copy_lines_to_new_header
  (
   p_finance_header_id_from       in   number
  ,p_finance_header_id_to         in   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< set_cancel_flag_for_header>-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    A procedure is required to call the cancellation  or
--    uncalleation procedure for
--    each finance line defined for a given finance header.
--
Procedure set_cancel_flag_for_header
  (
   p_finance_header_id       in   number
  ,p_new_cancelled_flag      in   varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< cancel_finance_line >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    A procedure is required to set the attribute cancelled_flag to 'Y'.
--
Procedure cancel_finance_line
  (
   p_finance_line_id    in      number
  ,p_cancelled_flag     in out  nocopy varchar2
  ,p_transfer_status    in      varchar2
  ,p_finance_header_id  in      number
  ,p_validate           in      boolean
  ,p_commit             in      boolean default FALSE
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< cancel_finance_line >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    A procedure is required to set the attribute cancelled_flag to 'Y'.
--
Procedure cancel_finance_line
  (
   p_finance_line_id    in      number
  ,p_cancelled_flag     in out  nocopy varchar2
  ,p_transfer_status    in      varchar2
  ,p_finance_header_id  in      number
  ,p_object_version_number in out nocopy number
  ,p_validate           in      boolean
  ,p_commit             in      boolean default FALSE
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< recancel_finance_line >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    A procedure is required to set the attribute cancelled_flag to 'N'.
--
Procedure recancel_finance_line
  (
   p_finance_line_id    in      number
  ,p_cancelled_flag     in out  nocopy varchar2
  ,p_transfer_status    in      varchar2
  ,p_finance_header_id  in      number
  ,p_validate           in      boolean
  ,p_commit             in      boolean default FALSE
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< change_line_for_header >------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    A procedure is required to set the attribute transfer_status to the same
--    as the header when the header has been changed
--    This only occurs when the status is th esam eas the old value on the
--    header.
Procedure change_line_for_header
  (
   p_finance_header_id      in      number
  ,p_new_transfer_status    in      varchar2
  ,p_old_transfer_status    in      varchar2
  ,p_include_cancelled      in      varchar2 default 'N'
  );
--
-- ----------------------------------------------------------------------------
--
end ota_tfl_api_business_rules2;

 

/
