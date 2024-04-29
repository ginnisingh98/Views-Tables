--------------------------------------------------------
--  DDL for Package JL_ZZ_FA_DEPRN_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_FA_DEPRN_ADJ_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzfdas.pls 115.2 2002/11/21 02:01:32 vsidhart ship $ */

/*+=========================================================================+
  |  PUBLIC PROCEDURE                                                       |
  |    deprn_adj_ret_assets                                                 |
  |         p_book_type_code         Book Type Code                         |
  |                                                                         |
  |  NOTES                                                                  |
  |    Once the asset is retired, journal entries are posted to reverse the |
  |  accumulated depreciation. The inflation adjusted depreciation account  |
  |  remains unchanged until the end of the fiscal year, when it is used to |
  |  calculate the FY's result and then its balance is zeroed.  But that    |
  |  balance is not in constant units of money to the time of the FY's end, |
  |  so we must adjust it for inflation during that FY's periods.           |
  |                                                                         |
  +=========================================================================+*/
  PROCEDURE deprn_adj_ret_assets (errbuf OUT NOCOPY VARCHAR2
                                , retcode OUT NOCOPY VARCHAR2
                                , p_book_type_code IN VARCHAR2);

END jl_zz_fa_deprn_adj_pkg;

 

/
