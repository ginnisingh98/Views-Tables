--------------------------------------------------------
--  DDL for Package FII_RECONVERSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_RECONVERSION_PKG" AUTHID CURRENT_USER AS
/* $Header: FIICRECS.pls 115.6 2003/10/07 18:16:40 phu noship $ */

--
-- PACKAGE
--   FII_RECONVERSION_PKG
--
-- PURPOSE
--   This package will cache reconversion rates and use them to convert the
--   global amounts of the base tables for AP, AR and/or GL based on the
--   passed in parameters
--   The concurrent manager will call the procedure reconvert_amounts() of
--   this package when processing FII Currency Re-conversion SRS request.
--
-- HISTORY
--   07/22/03          L Poon            Created
--

--
-- PROCEDURE
--   reconvert_amounts()
--
-- PARAMETERS:
--   errbuf                Error message for the concurrent manager
--   retcode               Return code for the concurrent manager
--   p_transaction_type    Specify what transactions are to be reconverted (AP,
--                         AR, GL, or ALL)
--   p_currency_type       Specify which global currency amounts are to be
--                         reconverted (PRIMARY, SECONDARY, or ALL)
--   p_primary_rate_type   The rate type used to reconvert primary global
--                         amounts
--   p_secondary_rate_type The rate type used to reconvert secondary global
--                         amounts
--   p_from_date           The reconversion start date string
--   p_to_date             The reconversion end date string
--   p_log_filename        The log filename used when not running by SRS
--   p_output_filename     The output filename used when not running by SRS
--
-- DESCRIPTION:
--   This is the main function of this currency reconversion package. It will
--   initialize the variables and validate the passed in parameters from the
--   concurrent manager. Then, it will call other procdures to cache rates,
--   reconvert global amounts for different products and print execution report.
--
PROCEDURE reconvert_amounts(
             errbuf                IN OUT NOCOPY VARCHAR2
           , retcode               IN OUT NOCOPY VARCHAR2
           , p_currency_type       IN            VARCHAR2
           , p_primary_rate_type   IN            VARCHAR2
           , p_secondary_rate_type IN            VARCHAR2
           , p_from_date           IN            VARCHAR2
           , p_to_date             IN            VARCHAR2
           , p_transaction_type    IN            VARCHAR2 DEFAULT 'ALL'
           , p_log_filename        IN            VARCHAR2 DEFAULT NULL
           , p_output_filename     IN            VARCHAR2 DEFAULT NULL);


--
-- FUNCTION
--   cache_rates()
--
-- PARAMETERS:
--   p_request_id          The currency reconversion request ID
--   p_gl_name             The product name for GL
--   p_ap_name             The product name for AP
--   p_ar_name             The product name for AR
--   p_primary_currency    The primary global currency code
--   p_primary_rate_type   The rate type used to cache reconversion rates for
--                         primary global currency
--   p_secondary_currency  The secondary global currency code
--   p_secondary_rate_type The rate type used to cache reconversion rates for
--                         secondary global currency
--   p_cache_for_gl_flag   Indicate if it caches rates to reconvert GL
--   p_cache_for_ap_flag   Indicate if it caches rates to reconvert AP
--   p_cache_for_ar_flag   Indicate if it caches rates to reconvert AR
--   p_from_date_id        The start date to cache rates (in Julian format)
--   p_to_date_id          The end date to cache rates (in Julian format)
--
-- DESCRIPTION:
--   It will insert global conversion rates (from set of books currencies to
--   global currencies) into FII_RECONV_RATES_GT for the specified date range.
--
--   The return value can be:
--    'C' - all the required rates are cached
--    'M' - there are missing rates
--    'N' - no rates are cached
--
FUNCTION cache_rates(
            p_request_id          IN NUMBER
          , p_gl_name             IN VARCHAR2
          , p_ap_name             IN VARCHAR2
          , p_ar_name             IN VARCHAR2
          , p_primary_currency    IN VARCHAR2
          , p_primary_rate_type   IN VARCHAR2
          , p_secondary_currency  IN VARCHAR2
          , p_secondary_rate_type IN VARCHAR2
          , p_cache_for_gl_flag   IN VARCHAR2
          , p_cache_for_ap_flag   IN VARCHAR2
          , p_cache_for_ar_flag   IN VARCHAR2
          , p_from_date_id        IN NUMBER
          , p_to_date_id          IN NUMBER) RETURN VARCHAR2;


-- PROCEDURE
--   reconvert_gl()
--
-- PARAMETERS:
--   errbuf               Error message for the concurrent manager
--   retcode              Return code for the concurrent manager
--   p_request_id         The currency reconversion request ID
--   p_user_id            The ID for the user who submit this request
--   p_product_name       The product name for GL
--   p_primary_currency   The primary global currency code
--   p_primary_mau        The minimum accountable unit of primary global
--                        currency
--   p_secondary_currency The secondary global currency code
--   p_primary_mau        The minimum accountable unit of secondary global
--                        currency
--   p_from_date_id       The start date to cache rates (in Julian format)
--   p_to_date_id         The end date to cache rates (in Julian format)
--   p_log_filename       The log filename used when not running by SRS
--   p_output_filename    The output filename used when not running by SRS
--
-- DESCRIPTION:
--   It will reconvert global amounts for the GL base table FII_GL_JE_SUMMARY_B.
--
PROCEDURE reconvert_gl(
             errbuf               IN OUT NOCOPY VARCHAR2
           , retcode              IN OUT NOCOPY VARCHAR2
           , p_request_id         IN NUMBER
           , p_user_id            IN NUMBER
           , p_product_name       IN VARCHAR2
           , p_primary_currency   IN VARCHAR2
           , p_primary_mau        IN NUMBER
           , p_secondary_currency IN VARCHAR2
           , p_secondary_mau      IN NUMBER
           , p_from_date_id       IN NUMBER
           , p_to_date_id         IN NUMBER
           , p_log_filename       IN VARCHAR2
           , p_output_filename    IN VARCHAR2);


-- PROCEDURE
--   reconvert_ap()
--
-- PARAMETERS:
--   errbuf               Error message for the concurrent manager
--   retcode              Return code for the concurrent manager
--   p_request_id         The currency reconversion request ID
--   p_user_id            The ID for the user who submit this request
--   p_product_name       The product name for AP
--   p_primary_currency   The primary global currency code
--   p_primary_mau        The minimum accountable unit of primary global
--                        currency
--   p_secondary_currency The secondary global currency code
--   p_primary_mau        The minimum accountable unit of secondary global
--                        currency
--   p_from_date_id       The start date to cache rates (in Julian format)
--   p_to_date_id         The end date to cache rates (in Julian format)
--   p_log_filename       The log filename used when not running by SRS
--   p_output_filename    The output filename used when not running by SRS
--
-- DESCRIPTION:
--   It will reconvert global amounts for the AP base table FII_AP_INV_B.
--
PROCEDURE reconvert_ap(
             errbuf               IN OUT NOCOPY VARCHAR2
           , retcode              IN OUT NOCOPY VARCHAR2
           , p_request_id         IN NUMBER
           , p_user_id            IN NUMBER
           , p_product_name       IN VARCHAR2
           , p_primary_currency   IN VARCHAR2
           , p_primary_mau        IN NUMBER
           , p_secondary_currency IN VARCHAR2
           , p_secondary_mau      IN NUMBER
           , p_from_date_id       IN NUMBER
           , p_to_date_id         IN NUMBER
           , p_log_filename       IN VARCHAR2
           , p_output_filename    IN VARCHAR2);


-- PROCEDURE
--   reconvert_ar()
--
-- PARAMETERS:
--   errbuf               Error message for the concurrent manager
--   retcode              Return code for the concurrent manager
--   p_request_id         The currency reconversion request ID
--   p_user_id            The ID for the user who submit this request
--   p_product_name       The product name for AR
--   p_primary_currency   The primary global currency code
--   p_primary_mau        The minimum accountable unit of primary global
--                        currency
--   p_secondary_currency The secondary global currency code
--   p_primary_mau        The minimum accountable unit of secondary global
--                        currency
--   p_from_date_id       The start date to cache rates (in Julian format)
--   p_to_date_id         The end date to cache rates (in Julian format)
--   p_debug_mode         Indicate if it is in debug mode (TRUE or FALSE)
--   p_log_filename       The log filename used when not running by SRS
--   p_output_filename    The output filename used when not running by SRS
--
-- DESCRIPTION:
--   It will reconvert global amounts for the AR base table FII_AR_REVENUE_B.
--
PROCEDURE reconvert_ar(
             errbuf               IN OUT NOCOPY VARCHAR2
           , retcode              IN OUT NOCOPY VARCHAR2
           , p_request_id         IN NUMBER
           , p_user_id            IN NUMBER
           , p_product_name       IN VARCHAR2
           , p_primary_currency   IN VARCHAR2
           , p_primary_mau        IN NUMBER
           , p_secondary_currency IN VARCHAR2
           , p_secondary_mau      IN NUMBER
           , p_from_date_id       IN NUMBER
           , p_to_date_id         IN NUMBER
           , p_log_filename       IN VARCHAR2
           , p_output_filename    IN VARCHAR2);


-- PROCEDURE
--   print_report()
--
-- PARAMETERS:
--   p_request_id          The currency reconversion request ID
--   p_transaction_type    The passed parameter, Transaction Type
--   p_currency_type       The passed parameter, Currency Type
--   p_primary_rate_type   The passed parameter, Primary Rate Type
--   p_secondary_rate_type The passed parameter, Secondary Rate Type
--   p_from_date           The passed parameter, From Date
--   p_to_date             The passed parameter, TO Date
--   p_primary_currency    The primary global currency code
--   p_secondary_currency  The secondary global currency code
--   p_cache_rate_status   The status for caching rates
--   p_completion_status   The main request's completion status
--
-- DESCRIPTION:
--   It will print the execution report for different modes. For ERROR mode, it
--   will list all the missing/invalid rates and proper error messages. For
--   SUCCESS mode, it will list all the cached rates and the number of rows
--   updated for each base table.
--
PROCEDURE print_report(
             p_request_id          IN NUMBER
           , p_transaction_type    IN VARCHAR2
           , p_currency_type       IN VARCHAR2
           , p_primary_rate_type   IN VARCHAR2
           , p_secondary_rate_type IN VARCHAR2
           , p_from_date           IN VARCHAR2
           , p_to_date             IN VARCHAR2
           , p_primary_currency    IN VARCHAR2
           , p_secondary_currency  IN VARCHAR2
           , p_cache_rate_status   IN VARCHAR2
           , p_completion_status   IN VARCHAR2);


-- FUNCTION
--   print_report_hdr()
--
-- PARAMETERS:
--   None
--
-- DESCRIPTION:
--   It will print the report header.
--
PROCEDURE print_report_hdr(  p_line_count IN OUT NOCOPY NUMBER
                           , p_page_count IN            NUMBER);


-- PROCEDURE
--   print_mtable_hdr()
--
-- PARAMETERS:
--   None
--
-- DESCRIPTION:
--   It will print the missing conversion rate table header.
--
PROCEDURE print_mtable_hdr(p_line_count IN OUT NOCOPY NUMBER);


-- PROCEDURE
--   print_ctable_hdr()
--
-- PARAMETERS:
--   None
--
-- DESCRIPTION:
--   It will print the cached conversion rate table header.
--
PROCEDURE print_ctable_hdr(p_line_count IN OUT NOCOPY NUMBER);

-- PROCEDURE
--   print_sql()
--
-- PARAMETERS:
--   p_sql_desc     The short description for that SQL to be print
--   p_sql_stmt     The SQL string to be print
--   p_num_of_lines The number of lines for the SQL string to be print
--
-- DESCRIPTION:
--   It will print the passed SQL statement to log file.
--
PROCEDURE print_sql(  p_sql_desc     IN VARCHAR2
                    , p_sql_stmt     IN DBMS_SQL.VARCHAR2S
                    , p_num_of_lines IN NUMBER);


-- PROCEDURE
--   func_enter()
--
-- PARAMETERS:
--   p_func_name The function name
--
-- DESCRIPTION:
--   It will print some customerized output to log and then call
--   FII_MESSAGE.func_enter() to print standard output for entering function
--
PROCEDURE func_enter(p_func_name IN VARCHAR2);


-- PROCEDURE
--   func_succ()
--
-- PARAMETERS:
--   p_func_name The function name
--
-- DESCRIPTION:
--   It will print some customerized output to log and then call
--   FII_MESSAGE.func_succ() to print standard output for exiting function
--   successfully
--
PROCEDURE func_succ(p_func_name IN VARCHAR2);


-- PROCEDURE
--   func_fail()
--
-- PARAMETERS:
--   p_func_name  The function name
--   p_debug_step The debug step code
--   p_err_msg    The additional error message to be print to log
--
-- DESCRIPTION:
--   It will print some additional output/error message to log and then call
--   FII_MESSAGE.func_fail() to print standard output for exiting function with
--   error
--
PROCEDURE func_fail(  p_func_name  IN VARCHAR2
                    , p_debug_step IN VARCHAR2 DEFAULT NULL
                    , p_err_msg    IN VARCHAR2 DEFAULT NULL
                   );

END FII_RECONVERSION_PKG;

 

/
