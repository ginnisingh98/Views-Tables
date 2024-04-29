--------------------------------------------------------
--  DDL for Package GL_MC_CURRENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_MC_CURRENCY_PKG" AUTHID CURRENT_USER AS
/*$Header: glmccurs.pls 120.7 2003/04/24 01:36:23 djogg ship $*/

    -- Global variable which is used for AR trigger.  This variable is used at
    -- the MRC trigger on RA_CUST_TRX_LINE_GL_DIST_ALL.  The trigger fires
    -- only if the value is set to FALSE.  At the time of running the AR MRC
    -- upgrade utility we set the value to be TRUE.  This ensures that the
    -- trigger does not fire when we insert rounding lines during the upgrade
    -- process.
    g_ar_upgrade_mode BOOLEAN := FALSE;  -- still need this???

    -- The following global variables are defined to ensure that trigger
    -- will know whether the records are inserted/updated due to upgrade
    -- or it is a normal transaction.
    g_ap_upgrade_mode BOOLEAN := FALSE;  -- still need this???
    g_po_upgrade_mode BOOLEAN := FALSE;  -- still need this???
    g_fa_upgrade_mode BOOLEAN := FALSE;
    g_pa_upgrade_mode BOOLEAN := FALSE;

    FUNCTION get_currency_code (
                      p_set_of_books_id IN NUMBER) RETURN VARCHAR2;

    FUNCTION get_mrc_sob_type_code (
                      p_set_of_books_id IN NUMBER) RETURN VARCHAR2;

    PROCEDURE  get_rate(p_primary_set_of_books_id   IN NUMBER,
                        p_reporting_set_of_books_id IN NUMBER,
                        p_trans_date                IN DATE,
                        p_trans_currency_code       IN VARCHAR2,
                        p_trans_conversion_type     IN OUT NOCOPY VARCHAR2,
                        p_trans_conversion_date     IN OUT NOCOPY DATE,
                        p_trans_conversion_rate     IN OUT NOCOPY NUMBER,
                        p_application_id            IN NUMBER,
  	                    p_org_id                    IN NUMBER,
                        p_fa_book_type_code         IN VARCHAR2,
                        p_je_source_name            IN VARCHAR2,
                        p_je_category_name          IN VARCHAR2,
                        p_result_code               IN OUT NOCOPY VARCHAR2,
                        p_denominator_rate          OUT NOCOPY NUMBER,
                        p_numerator_rate            OUT NOCOPY NUMBER );

    PROCEDURE  get_rate(p_primary_set_of_books_id   IN NUMBER,
                        p_reporting_set_of_books_id IN NUMBER,
                        p_trans_date                IN DATE,
                        p_trans_currency_code       IN VARCHAR2,
                        p_trans_conversion_type     IN OUT NOCOPY VARCHAR2,
                        p_trans_conversion_date     IN OUT NOCOPY DATE,
                        p_trans_conversion_rate     IN OUT NOCOPY NUMBER,
                        p_application_id            IN NUMBER,
  	                    p_org_id                    IN NUMBER,
                        p_fa_book_type_code         IN VARCHAR2,
                        p_je_source_name            IN VARCHAR2,
                        p_je_category_name          IN VARCHAR2,
                        p_result_code               IN OUT NOCOPY VARCHAR2);

    FUNCTION get_default_rate (
                p_from_currency         VARCHAR2,
                p_to_currency           VARCHAR2,
                p_conversion_date       DATE,
                p_conversion_type       VARCHAR2 DEFAULT NULL ) RETURN NUMBER;

    PROCEDURE GetCurrencyDetails( p_currency_code IN  VARCHAR2,
                                  p_precision     OUT NOCOPY NUMBER,
                                  p_mau           OUT NOCOPY NUMBER);

    FUNCTION CurrRound(p_amount IN NUMBER, p_currency_code IN VARCHAR2) RETURN NUMBER;

END gl_mc_currency_pkg;

 

/
