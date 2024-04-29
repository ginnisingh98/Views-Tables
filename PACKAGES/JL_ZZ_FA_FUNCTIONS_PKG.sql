--------------------------------------------------------
--  DDL for Package JL_ZZ_FA_FUNCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_FA_FUNCTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzfafs.pls 115.12 2003/09/03 16:38:17 svaze ship $ */

/*+=========================================================================+
  |  PUBLIC FUNCTION                                                        |
  |    middle_month                                                         |
  |        p_add_month_number        Month in which the Addition took place.|
  |        p_ret_month_number        Month in which the Retirement took     |
  |                                  place.                                 |
  |        p_include_dpis            Include DPIS month in the periods of   |
  |                                  use calculation.                       |
  |        p_include_ret             Include retirement month in the periods|
  |                                  of use calculation.                    |
  |                                                                         |
  |  NOTES                                                                  |
  |    Middle Month Function:  Assets added or sold in the current FY are   |
  |  adjusted until the half of the period of use.  The half of the period  |
  |  of use is obtained from the Middle Month Tables.                       |
  |                                                                         |
  |    08-Nov-00   S. Vaze      This procedure is now written due to changes|
  |                             in the requirement # 1561112.               |
  |                             The month number 0 in addition signifies    |
  |                             Addition in the previous year.              |
  |                             The month number 13 in retirement signifies |
  |                             Asset is not retired yet.                   |
  +=========================================================================+*/
  FUNCTION middle_month (p_add_month_number IN NUMBER
                       , p_ret_month_number IN NUMBER
                       , p_include_dpis     IN VARCHAR2
                       , p_include_ret      IN VARCHAR2) RETURN NUMBER;


/*+=========================================================================+
  |  PUBLIC FUNCTION                                                        |
  |    periods_of_use                                                       |
  |        p_add_month_number        Month in which the Addition took place.|
  |        p_ret_month_number        Month in which the Retirement took     |
  |                                  place.                                 |
  |        p_include_dpis            Include DPIS month in the periods of   |
  |                                  use calculation.                       |
  |        p_include_ret             Include retirement month in the periods|
  |                                  of use calculation.                    |
  |        Returns                   Periods of use                         |
  |                                                                         |
  |  NOTES                                                                  |
  |    Period of use Function:  This function calculates periods of use     |
  |    depending on the method chosen by the customer.                      |
  |                                                                         |
  |    30-Nov-00   S. Vaze      Created.                                    |
  |    04-Dec-00   C.Leyva      Function Month of Use Completed.            |
  +=========================================================================+*/
  FUNCTION periods_of_use (p_add_month_number IN NUMBER
                         , p_ret_month_number IN NUMBER
                         , p_include_dpis     IN VARCHAR2
                         , p_include_ret      IN VARCHAR2) RETURN NUMBER;


/*+=========================================================================+
  |  PUBLIC FUNCTION                                                        |
  |    asset_cost                                                           |
  |        p_book_type_code IN  Depreciation Book                           |
  |        p_asset_id       IN  Asset                                       |
  |        p_period_counter IN  Period                                      |
  |        p_asset_cost     OUT Asset cost for this particular period and   |
  |                             depreciation book.                          |
  |      Returns                                                            |
  |        Number           0   Normal completion                           |
  |                         1   Abnormal completion                         |
  |                                                                         |
  |  NOTES                                                                  |
  |      Given an asset, a depreciation book and a depreciation period,     |
  |      returns the asset's cost at the end of the period for that         |
  |      depreciation book.                                                 |
  |                                                                         |
  |                                                                         |
  +=========================================================================+*/
  FUNCTION asset_cost (p_book_type_code IN VARCHAR2
                     , p_asset_id       IN NUMBER
                     , p_period_counter IN NUMBER
                     , p_asset_cost     IN OUT NOCOPY NUMBER
                     , p_mrcsobtype     IN VARCHAR2 DEFAULT 'P') RETURN NUMBER;

/*+=========================================================================+
  |  PUBLIC FUNCTION                                                        |
  |    asset_desc                                                           |
  |        p_asset_number   IN  Asset                                       |
  |                                                                         |
  |      Returns                                                            |
  |        p_asset_desc         Asset Description                           |
  |                                                                         |
  |  NOTES                                                                  |
  |      Given an asset, returns the asset's description.                   |
  |                                                                         |
  |                                                                         |
  +=========================================================================+*/
  FUNCTION asset_desc (p_asset_number   IN VARCHAR2) RETURN VARCHAR2;

/*+=========================================================================+
  |  PUBLIC PROCEDURE                                                       |
  |    populate_FA_Exhibit_Data                                             |
  |        p_tax_book             IN  VARCHAR2                              |
  |        p_corp_book            IN  VARCHAR2                              |
  |        p_conc_request_id      IN  NUMBER                                |
  |        p_period_counter_from  IN  NUMBER                                |
  |        p_period_counter_to    IN  NUMBER                                |
  |                                                                         |
  |      Returns                                                            |
  |                                                                         |
  |                                                                         |
  |  NOTES                                                                  |
  |      This procedure populates data in temporary table                   |
  |      JL_AR_FA_EXHIBIT_REPORT                                            |
  |      which is used to present the information in the Argentine Report.  |
  |                                                                         |
  +=========================================================================+*/
  PROCEDURE populate_FA_Exhibit_Data (p_tax_book      IN VARCHAR2,
                                      p_corp_book     IN VARCHAR2,
                                      p_conc_request_id     IN  NUMBER,
                                      p_period_counter_from IN  NUMBER,
                                      p_period_counter_to   IN  NUMBER,
                                      p_mrcsobtype          IN VARCHAR2 DEFAULT 'P');
END JL_ZZ_FA_FUNCTIONS_PKG;

 

/
