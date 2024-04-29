--------------------------------------------------------
--  DDL for Package PON_VALIDATE_PAYMENTS_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_VALIDATE_PAYMENTS_INT" AUTHID CURRENT_USER as
-- $Header: PONVAPIS.pls 120.2 2007/02/01 00:43:27 mxfang ship $
PROCEDURE validate_response (p_spreadsheet_type VARCHAR2, p_batch_Id NUMBER, p_bid_number NUMBER, p_auction_header_id NUMBER, p_request_id NUMBER);

PROCEDURE validate_creation(p_source VARCHAR2,  p_batch_Id NUMBER);

PROCEDURE copy_payments_from_int_to_txn(
      p_batch_id IN pon_bid_item_prices_interface.batch_id%TYPE,
      p_spreadsheet_type   IN VARCHAR2,
      p_bid_number         IN NUMBER,
      p_auction_header_id  IN NUMBER,
      x_result                OUT NOCOPY VARCHAR2, -- S: Success, E: failure
      x_error_code            OUT NOCOPY VARCHAR2,
      x_error_message         OUT NOCOPY VARCHAR2) ;

END pon_validate_payments_int;

/
