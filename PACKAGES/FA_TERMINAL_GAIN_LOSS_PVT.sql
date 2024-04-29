--------------------------------------------------------
--  DDL for Package FA_TERMINAL_GAIN_LOSS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_TERMINAL_GAIN_LOSS_PVT" AUTHID CURRENT_USER as
/* $Header: FAVTGLS.pls 120.0.12010000.2 2009/07/19 09:55:14 glchen ship $   */

FUNCTION fadtgl (
   p_asset_id          IN NUMBER,
   p_book_type_code    IN VARCHAR2,
   p_deprn_reserve     IN NUMBER,
   p_mrc_sob_type_code IN VARCHAR2,
   p_set_of_books_id   IN NUMBER
)  RETURN NUMBER;

END FA_TERMINAL_GAIN_LOSS_PVT;

/
