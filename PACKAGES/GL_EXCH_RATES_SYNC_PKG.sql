--------------------------------------------------------
--  DDL for Package GL_EXCH_RATES_SYNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_EXCH_RATES_SYNC_PKG" AUTHID CURRENT_USER AS
/*$Header: glexrass.pls 120.0.12010000.2 2008/09/19 14:11:13 kmotepal noship $*/
/*==================================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                            |
|                       Redwood Shores, CA, USA                                     |
|                         All rights reserved.                                      |
+===================================================================================+
| FILENAME                                                                          |
|     glexrass.pls                                                                  |
|                                                                                   |
| PACKAGE NAME                                                                      |
|     GL_EXCH_RATES_SYNC_PKG                                                        |
|                                                                                   |
| DESCRIPTION                                                                       |
|     This is a GL Daily Rates Synchronization which is used to fetch GL Daily      |
|     Rates with in a gieven date range.                                            |
|     Also this Program used to fetch the Cross Rates for the entered Currencies.   |
|                                                                                   |
|                                                                                   |
|     Package specification for the Exchange Rates Synchronization Program.         |
|                                                                                   |
| SUB PROGRAMS                                                                      |
| ------------                                                                      |
| PROCEDURE get_cur_conv_rates                                                      |
|                                                                                   |
| PARAMETER DESCRIPTION                                                             |
| ---------------------                                                             |
| errbuf                OUT NOCOPY Default out parameter to capture error message   |
| retcode               OUT NOCOPY Default out parameter to capture error code      |
| p_from_currency       IN  from_currency from GL_DAILY_RATES table.                |
| p_to_currency         IN  to_currency from GL_DAILY_RATES table.                  |
| p_from_date           IN  conversion_date from GL_DAILY_RATES table.              |
| p_to_date             IN  conversion_date from GL_DAILY_RATES table.              |
| p_conversion_rate_type IN conversion_type from GL_DAILY_RATES table.              |
| p_cur_conv_rates      OUT NOCOPY GL_CUR_CONV_RATE_OBJ_TBL Object type            |
|                                                                                   |
|                                                                                   |
| HISTORY                                                                           |
|     04-AUG-08    Vamshidhar G    Created                                          |
|                                                                                   |
+===================================================================================*/

PROCEDURE get_cur_conv_rates
     (errbuf OUT NOCOPY VARCHAR2,
      retcode OUT NOCOPY NUMBER,
      p_from_currency IN VARCHAR2 DEFAULT NULL,
      p_to_currency IN VARCHAR2 DEFAULT NULL,
      p_from_date IN DATE,
      p_to_date IN DATE DEFAULT SYSDATE,
      p_conversion_rate_type IN VARCHAR2 DEFAULT NULL,
      p_cur_conv_rates OUT NOCOPY GL_CUR_CONV_RATE_OBJ_TBL);

END GL_EXCH_RATES_SYNC_PKG;

/
