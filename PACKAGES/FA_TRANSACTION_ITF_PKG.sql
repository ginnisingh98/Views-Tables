--------------------------------------------------------
--  DDL for Package FA_TRANSACTION_ITF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_TRANSACTION_ITF_PKG" AUTHID CURRENT_USER as
  /* $Header: FATRXITFS.pls 120.2.12010000.2 2009/07/19 12:59:23 glchen ship $ */


  -- Author  : SKCHAWLA
  -- Created : 7/18/2005 1:54:40 PM
  -- Purpose : Package for the Transaction Interface

  -- Public type declarations

  -- Public constant declarations

  -- Public variable declarations

  -- Public function and procedure declarations
  procedure process_transaction_interface(p_book_type_code in varchar2,
                           x_request_id     out NOCOPY number,
                           x_msg_count      OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2,
                           x_return_status  OUT NOCOPY number);

end FA_TRANSACTION_ITF_PKG;

/
