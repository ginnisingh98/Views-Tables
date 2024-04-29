--------------------------------------------------------
--  DDL for Package OTA_TFL_API_BUSINESS_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TFL_API_BUSINESS_RULES" AUTHID CURRENT_USER as
/* $Header: ottfl02t.pkh 115.2 2002/11/29 09:24:36 arkashya ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_update_attributes >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    If the line has been transferred then no attributes may be updated.
--
Procedure check_update_attributes
  (
   p_transfer_status      in   varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_cancelled_flag >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    The attribute CANCELLED_FLAG must be in the doamin 'Yes No'
--
Procedure check_cancelled_flag
  (
   p_cancelled_flag    in   varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_sequence_number >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    The sequence_number for a finance line within a finance_header_id
--    MUST be unique.
--
Procedure check_sequence_number
  (
   p_finance_header_id       in   number
  ,p_sequence_number         in   number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_next_sequence_number >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    The sequence_number for a finance line within a finance_header_id
--    MUST be unique.
--
Procedure get_next_sequence_number
  (
   p_finance_header_id       in      number
  ,p_sequence_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_date_raised >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    Get a valid date_raised for the finance line.
--
Procedure get_date_raised
  (
   p_finance_header_id       in      number
  ,p_date_raised             in out  nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_delete_attempt >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    No finance lines may be delated.
--
Procedure check_delete_attempt
  (
   p_finance_header_id       in   number
  ,p_finance_line_id         in   number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_currency_code >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
Procedure get_currency_code
  (
   p_finance_line_type       in   varchar2
  ,p_booking_id              in   number
  ,p_booking_deal_id         in   number
  ,p_resource_allocation_id  in   number
  ,p_resource_booking_id     in   number
  ,p_currency_code           out nocopy  varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< check_currency_code >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
Procedure check_currency_code
  (
   p_finance_line_type       in   varchar2
  ,p_finance_header_id       in   number
  ,p_booking_id              in   number
  ,p_booking_deal_id         in   number
  ,p_resource_allocation_id  in   number
  ,p_resource_booking_id     in   number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_type_constraints >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
procedure check_type_constraints (
         p_finance_line_type            in varchar2
        ,p_finance_header_id            in number
        ,p_booking_id                   in number
        ,p_booking_deal_id              in number
        ,p_resource_booking_id          in number
        ,p_resource_allocation_id       in number
   );
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_type_and_amounts >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
Procedure check_type_and_amounts
  (
   p_finance_line_type       in   varchar2
  ,p_standard_amount         in   number
  ,p_money_amount            in   number
  ,p_unitary_amount          in   number
  ,p_booking_deal_id         in   number
  ,p_finance_header_id       in   number
   );
-- ---------------------------------------------------------------------------
-- ---------------------------------------------------------------------------
-- |--------------------< check_unique_finance_line >-----------------------|
-- ---------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
procedure check_unique_finance_line
                 (p_finance_line_id        in number
                 ,p_line_type              in varchar2
                 ,p_booking_id             in number
                 ,p_resource_booking_id    in number
                 ,p_resource_allocation_id in number);
-- ---------------------------------------------------------------------------
-- ---------------------------------------------------------------------------
-- |--------------------< get_finance_header >-----------------------------|
-- ---------------------------------------------------------------------------
--
procedure get_finance_header
  (p_finance_header_id          in     number
  ,p_tfh_type                   in out nocopy varchar2
  ,p_customer_id                in out nocopy number
  ,p_vendor_id                  in out nocopy number
  ,p_tfh_receivable_type        in out nocopy varchar2
  ,p_tfh_transfer_status        in out nocopy varchar2
  ,p_tfh_superseded_flag        in out nocopy varchar2
  ,p_tfh_cancelled_flag         in out nocopy varchar2);
--
-- ---------------------------------------------------------------------------
-- |--------------------< check_finance_header >---------------------------|
-- ---------------------------------------------------------------------------
procedure check_finance_header(p_type                      in varchar2
                              ,p_superseded_flag           in varchar2
                              ,p_transfer_status           in varchar2
                              ,p_cancelled_flag            in varchar2
                              ,p_check_cancelled_flag      in boolean
                              ,p_check_successful_transfer in boolean);
end ota_tfl_api_business_rules;

 

/
