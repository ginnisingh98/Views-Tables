--------------------------------------------------------
--  DDL for Package PON_PRINTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_PRINTING_PKG" AUTHID CURRENT_USER as
/* $Header: PONPRNS.pls 120.9.12010000.3 2009/02/20 03:22:02 jianliu ship $ */
----------------------------------------------------------------
-- Creates a xml file for negotiation emd report              --
-- it as a clob                                               --
----------------------------------------------------------------
  FUNCTION generate_emd_xml(p_auction_header_id          IN NUMBER)
  RETURN CLOB;
----------------------------------------------------------------
-- Creates a xml file for individual supplier report          --
-- it as a clob                                               --
----------------------------------------------------------------
  FUNCTION generate_supplier_xml(p_auction_header_id          IN NUMBER,
                                 p_supplier_sequence         IN NUMBER
                                )
  RETURN CLOB;

----------------------------------------------------------------
-- Creates a  xml file for receipt of individual supplier report          --
-- it as a clob                                               --
----------------------------------------------------------------
  FUNCTION generate_receipt_xml(p_auction_header_id          IN NUMBER,
                                 p_supplier_sequence         IN NUMBER
                                )
  RETURN CLOB;

----------------------------------------------------------------
-- Creates a xml file for the auction id and returns          --
-- it as a clob                                               --
----------------------------------------------------------------
  FUNCTION generate_auction_xml(p_auction_header_id          IN NUMBER,
                                p_client_time_zone           IN VARCHAR2,
                                p_server_time_zone           IN VARCHAR2,
                                p_date_format                IN VARCHAR2,
                                p_trading_partner_id         IN NUMBER,
                                p_trading_partner_name       IN VARCHAR2,
                                p_vendor_site_id             IN NUMBER,
                                p_user_view_type             IN VARCHAR2,
                                p_printing_warning_flag      IN VARCHAR2  DEFAULT 'N',
                                p_neg_printed_with_contracts IN VARCHAR2  DEFAULT 'N',
                                p_requested_supplier_id      IN NUMBER,
                                p_requested_supplier_name    IN VARCHAR2,
				p_trading_partner_contact_id IN NUMBER)
  RETURN CLOB;

-------------------------------------------------------------------------------
-- If p_bid_number > 0 , Creates a xml file for the bid number and returns   --
-- it as a clob. If p_bid_number <= 0, creates a xml file for the auction id --
-------------------------------------------------------------------------------
  FUNCTION generate_auction_xml(p_auction_header_id          IN NUMBER,
                                p_client_time_zone           IN VARCHAR2,
                                p_server_time_zone           IN VARCHAR2,
                                p_date_format                IN VARCHAR2,
                                p_trading_partner_id         IN NUMBER,
                                p_trading_partner_name       IN VARCHAR2,
                                p_vendor_site_id             IN NUMBER,
                                p_user_view_type             IN VARCHAR2,
                                p_printing_warning_flag      IN VARCHAR2  DEFAULT 'N',
                                p_neg_printed_with_contracts IN VARCHAR2  DEFAULT 'N',
                                p_requested_supplier_id      IN NUMBER,
                                p_requested_supplier_name    IN VARCHAR2,
				p_trading_partner_contact_id IN NUMBER,
                                p_bid_number                 IN NUMBER,
                                p_user_id                    IN NUMBER)
  RETURN CLOB;

--  Overloaded version of the above procedure without trading_partner_contact_id
--  Kept here for backward compatibility - can be removed once all the dependent
--  changes are done.

  FUNCTION generate_auction_xml(p_auction_header_id          IN NUMBER,
                                p_client_time_zone           IN VARCHAR2,
                                p_server_time_zone           IN VARCHAR2,
                                p_date_format                IN VARCHAR2,
                                p_trading_partner_id         IN NUMBER,
                                p_trading_partner_name       IN VARCHAR2,
                                p_vendor_site_id             IN NUMBER,
                                p_user_view_type             IN VARCHAR2,
                                p_printing_warning_flag      IN VARCHAR2  DEFAULT 'N',
                                p_neg_printed_with_contracts IN VARCHAR2  DEFAULT 'N',
                                p_requested_supplier_id      IN NUMBER,
                                p_requested_supplier_name    IN VARCHAR2)
  RETURN CLOB;
----------------------------------------------------------------
-- Gets the message after substituting the token values       --
----------------------------------------------------------------
FUNCTION GET_MESSAGES(p_message_name in VARCHAR2,
                      p_token_name in VARCHAR2,
                      p_token_value in VARCHAR2) return VARCHAR2;

----------------------------------------------------------------
-- Returns the corresponding value of the message name after  --
-- substituting it with the the two token                   --
----------------------------------------------------------------
  FUNCTION GET_MESSAGES(p_message_name in VARCHAR2,
                        p_token_name1 in VARCHAR2,
                        p_token_value1 in VARCHAR2,
                        p_token_name2 in VARCHAR2,
                        p_token_value2 in VARCHAR2) return VARCHAR2;

----------------------------------------------------------------
-- Returns the corresponding value of the message name after  --
-- substituting it with the the three token                   --
----------------------------------------------------------------
  FUNCTION GET_MESSAGES(p_message_name in VARCHAR2,
                        p_token_name1 in VARCHAR2,
                        p_token_value1 in VARCHAR2,
                        p_token_name2 in VARCHAR2,
                        p_token_value2 in VARCHAR2,
                        p_token_name3 in VARCHAR2,
                        p_token_value3 in VARCHAR2) return VARCHAR2;

----------------------------------------------------------------
-- Returns the corresponding value of the mesage name after   --
-- substituting it with the token. The message name is formed --
-- by joining the message name and message suffix parameters  --
----------------------------------------------------------------
FUNCTION GET_MESSAGES(p_message_name in VARCHAR2,
                        p_message_suffix in VARCHAR2,
                        p_token_name in VARCHAR2,
                        p_token_value in VARCHAR2) return VARCHAR2;

----------------------------------------------------------------
-- Adds the suffix to the message to generate the  document   --
-- specific messages name                                     --
----------------------------------------------------------------
FUNCTION GET_DOCUMENT_MESSAGE_NAME(p_message_name in VARCHAR2,
                                   p_message_suffix in VARCHAR2) return VARCHAR2;

----------------------------------------------------------------
-- Returns Y if XDO is installed                              --
----------------------------------------------------------------

FUNCTION is_xdo_installed RETURN VARCHAR2;

---------------------------------------------------------------
-- Returns the rate to be displayed                           --
----------------------------------------------------------------
FUNCTION GET_DISPLAY_RATE(p_rate_dsp in NUMBER,
	                        p_rate_type in VARCHAR2,
                          p_rate_date in DATE,
                          p_auction_currency_code in VARCHAR2,
                          p_bid_currency_code in VARCHAR2) return VARCHAR2;

-----------------------------------------------------------------
-- Returns the email of the user. Creating this method instead --
-- of an outer join as in hz contact points table same email   --
-- record with active status of type MAILHTML existed. This was--
-- leading 2 records for all the queries.                      --
-----------------------------------------------------------------
FUNCTION GET_USER_EMAIL(p_user_party_id in NUMBER) return VARCHAR2;

----------------------------------------------------------------
-- Formats the number based passed. If the number does not    --
-- decimal part then the decimal separator will not be        --
-- displayed. If the number is less that 0 then 0 will        --
-- be displayed before the decimal separator                  --
----------------------------------------------------------------
FUNCTION FORMAT_NUMBER(p_number in NUMBER) return VARCHAR2;

 ----------------------------------------------------------------
  -- Formats the number which is a varchar.                 --
  ----------------------------------------------------------------
FUNCTION FORMAT_NUMBER_STRING(p_value in VARCHAR2) return VARCHAR2;
----------------------------------------------------------------
-- Formats the price passed based on the format passed.       --
-- If the price does have a decimal part then the decimal     --
-- separator will not be displayed. If the price is less      --
-- that 0 then 0 will be displayed before the decimal         --
-- separator                                                  --
----------------------------------------------------------------
FUNCTION FORMAT_PRICE(p_price in NUMBER,
                      p_format_mask in VARCHAR2,
                      p_precision IN NUMBER)
                      return VARCHAR2;

  ----------------------------------------------------------------
	-- Formats the response value of the attributes         --
  ----------------------------------------------------------------
  FUNCTION PRINT_ATTRIBUTE_RESPONSE_VALUE(
                                        p_value in VARCHAR2,
                                        p_datatype in VARCHAR2,
                                        p_client_time_zone in VARCHAR2,
                                        p_server_time_zone in VARCHAR2,
                                        p_date_format in VARCHAR2,
                                        p_attribute_sequence_number in NUMBER
                                        )
                                        RETURN VARCHAR2;
----------------------------------------------------------------
-- Formats the target value of the attributes                 --
----------------------------------------------------------------
FUNCTION PRINT_ATTRIBUTE_TARGET_VALUE(p_show_target_value  in VARCHAR2,
                                      p_value in VARCHAR2,
                                      p_datatype in VARCHAR2,
                                      p_sequence_number in VARCHAR2,
                                      p_client_time_zone in VARCHAR2,
                                      p_server_time_zone in VARCHAR2,
                                      p_date_format in VARCHAR2,
                                      p_user_view_type IN VARCHAR2) RETURN VARCHAR2;

  ----------------------------------------------------------------
  -- Retunrs the range / value of a for an attribute along with --
  -- the score. The score will be displayed only if             --
  -- p_show_bidder_scores is 'Y'                                --
  ----------------------------------------------------------------
FUNCTION GET_ACCEPTABLE_VALUE(p_show_bidder_scores  in VARCHAR2,
                              p_attribute_sequence_number NUMBER,
                              p_score_data_type  in VARCHAR2,
                              p_from_range  in VARCHAR2,
                              p_to_range  in VARCHAR2,
                              p_value  in VARCHAR2,
                              p_score  in VARCHAR2,
                              p_client_time_zone in VARCHAR2,
                              p_server_time_zone in VARCHAR2,
                              p_date_format in VARCHAR2,
                              p_user_view_score IN VARCHAR2) RETURN VARCHAR2;

 -----------------------------------------------------------------
 -- For Bug 4373655
 -- Returns the carrier name based on the carrier code and      --
 -- inventory org id corresponding to the org_id passed a       --
 -- parameter                                                   --
 -----------------------------------------------------------------
 FUNCTION GET_CARRIER_DESCRIPTION(p_org_id in NUMBER,
                                  p_carrier_code in VARCHAR2)
                                  return VARCHAR2;

----------------------------------------------------------------
-- Calculate Response Total for supplier view.                --
----------------------------------------------------------------
FUNCTION get_supplier_bid_total
             (p_auction_header_id    IN NUMBER,
              p_bid_number           IN NUMBER,
              p_buyer_bid_total           IN NUMBER,
              p_outcome              IN pon_auction_headers_all.contract_type%TYPE,
              p_doctype_group_name   IN VARCHAR2,
              p_bid_status           IN VARCHAR2
              ) RETURN NUMBER;

----------------------------------------------------------------------
-- Returns whether the buyer has price visibility in scoring team   --
----------------------------------------------------------------------
 FUNCTION is_price_visible( p_auction_header_id          IN NUMBER,
                             p_user_id             IN NUMBER
                           ) RETURN VARCHAR2;
END PON_PRINTING_PKG;


/
