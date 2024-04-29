--------------------------------------------------------
--  DDL for Package FA_DEPRN_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DEPRN_EVENTS_PKG" AUTHID CURRENT_USER as
/* $Header: fadpevns.pls 120.5.12010000.3 2009/07/19 11:03:04 glchen ship $   */

TYPE number_tbl_type   IS TABLE OF number INDEX BY BINARY_INTEGER;
TYPE varchar2_tbl_type IS TABLE OF varchar2(15) INDEX BY BINARY_INTEGER;
TYPE rowid_tbl_type    IS TABLE OF rowid INDEX BY BINARY_INTEGER;

PROCEDURE process_deprn_events
           (p_book_type_code varchar2,
            p_period_counter number,
            p_total_requests NUMBER,
            p_request_number NUMBER,
            x_return_status  OUT NOCOPY number);

END FA_DEPRN_EVENTS_PKG;

/
