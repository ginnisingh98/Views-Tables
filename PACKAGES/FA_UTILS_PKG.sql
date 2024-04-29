--------------------------------------------------------
--  DDL for Package FA_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: FAXUTILS.pls 120.2.12010000.2 2009/07/19 11:12:56 glchen ship $ */

TYPE faxcurr_type  IS RECORD(
                        set_of_books_id  number,
                        currency_code    varchar2(15),
                        precision        number);

TYPE faxcurr_tab  IS TABLE OF faxcurr_type
                      index by binary_integer;

TYPE faxlookups_tab IS TABLE OF VARCHAR2(80)
      INDEX BY BINARY_INTEGER;

-- variables for cache
--
faxcurr_record      faxcurr_type;
faxcurr_table       faxcurr_tab;

faxlkpmg_table faxlookups_tab;
faxlkpcd_table faxlookups_tab;

/******************************************************************************
 *
 *  Name :         faxrnd
 *
 *  Description:   Round function to round off amount based on the precision
 *                 of currency and book
 *
 *  Parameters:    X_amount - amount to be rounded off.
 *                 X_book - book_type_code to get associated currency and
 *                          precision
 *
 *  Returns:       True if successful, False otherwise
 *
 * *****************************************************************************/

FUNCTION faxrnd(X_amount   IN OUT NOCOPY NUMBER,
                X_book     IN VARCHAR2,
                X_set_of_books_id IN NUMBER,
                p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)

RETURN BOOLEAN;


/*****************************************************************************
 *
 *  Name :         faxtru
 *
 *  Description:   Truncate function to truncate X_in_num based on the
 *		   precision of currency and book
 *
 *  Parameters:    X_in_num - amount to be truncated
 *                 X_book_type_code - book_type_code to get associated
 *                         currency and precision
 *                 X_out_num - truncated value (OUT)
 *
 *  Returns:       True if successful, False otherwise
 *
 ******************************************************************************/
FUNCTION faxtru (X_num            IN OUT NOCOPY number,
		 X_book_type_code IN VARCHAR2,
                 X_set_of_books_id IN NUMBER,
                 p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
RETURN BOOLEAN;


/******************************************************************************
 *
 *  Name :         faxceil
 *
 *  Description:   Round function to round up amount based on the precision
 *                 of currency and book
 *
 *  Parameters:    X_amount - amount to be rounded up.
 *                 X_book - book_type_code to get associated currency and
 *                          precision
 *
 *  Returns:       True if successful, False otherwise
 *
 * *****************************************************************************/

FUNCTION faxceil(X_amount   IN OUT NOCOPY NUMBER,
                 X_book     IN VARCHAR2,
                 X_set_of_books_id IN NUMBER,
                 p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)

RETURN BOOLEAN;


/******************************************************************************
 *
 *  Name :         faxfloor
 *
 *  Description:   Round function to round off amount based on the precision
 *                 of currency and book
 *
 *  Parameters:    X_amount - amount to be rounded off.
 *                 X_book - book_type_code to get associated currency and
 *                          precision
 *
 *  Returns:       True if successful, False otherwise
 *
 * *****************************************************************************/

FUNCTION faxfloor(X_amount   IN OUT NOCOPY NUMBER,
                  X_book     IN VARCHAR2,
                  X_set_of_books_id IN NUMBER,
                  p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)

RETURN BOOLEAN;

/******************************************************************************
 *
 *  Name :         faxlkp_meaning
 *
 *  Description:   Gets the meaning for given lookup_type and lookup_code
 *
 *  Parameters:    X_lookup_type - Lookup_type to get associated meaning.
 *                 X_lookup_code - Lookup_code to get associated meaning.
 *
 *  Returns:       The Meaning for the given Lookup_type and Lookup_code
 *
 * *****************************************************************************/

FUNCTION faxlkp_meaning(X_lookup_type   IN  VARCHAR2,
                        X_lookup_code   IN  VARCHAR2,
                        p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)

RETURN VARCHAR2;

/******************************************************************************
 *
 *  Name :         faxlkp_code
 *
 *  Description:   Gets the lookup_code for given Lookup_type and meaning
 *
 *
 *  Parameters:    X_lookup_type - Lookup_type to get associated Lookup_code.
 *                 X_meaning     -  Meaning to get associated Lookup_code.
 *
 *  Returns:       The Lookup_code for the give Lookup_type and Meaning.
 *
 * *****************************************************************************/

FUNCTION faxlkp_code(X_lookup_type   IN  VARCHAR2,
                     X_meaning       IN  VARCHAR2,
                     p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)

RETURN VARCHAR2;

END FA_UTILS_PKG;

/
