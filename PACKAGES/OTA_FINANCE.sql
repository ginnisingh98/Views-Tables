--------------------------------------------------------
--  DDL for Package OTA_FINANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FINANCE" AUTHID CURRENT_USER as
/* $Header: otfin01t.pkh 115.0 99/07/16 00:52:20 porting ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< maintain_finance_line >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure maintain_finance_line
             (p_finance_header_id       in     number   default null,
              p_booking_id              in     number   default null,
              p_currency_code           in     varchar2 default null,
              p_object_version_number   in out number   ,
              p_standard_amount         in     number   default null,
              p_unitary_amount          in     number   default null,
              p_money_amount            in     number   default null,
              p_booking_deal_id         in     number   default null,
              p_booking_deal_type       in     varchar2 default null,
              p_resource_booking_id     in     number   default null,
              p_resource_allocation_id  in     number   default null,
              p_finance_line_id         in out number,
              p_cancel_finance_line     in     boolean  default false);
--
function get_deal_unit_based(p_booking_deal_id in number) return boolean;
--
end ota_finance;

 

/
