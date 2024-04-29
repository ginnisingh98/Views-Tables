--------------------------------------------------------
--  DDL for Package AS_PERIOD_RATES_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_PERIOD_RATES_REFRESH" AUTHID CURRENT_USER as
/* $Header: asxrates.pls 120.1 2005/06/05 22:52:44 appldev  $ */

--
-- HISTORY
-- 03/20/2001       SOLIN       Created
--

INVALID_FORECAST_CALENDAR          Exception;
INVALID_PERIOD                     Exception;

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC CONSTANTS
 |
 *-------------------------------------------------------------------------*/
G_PKG_NAME               Constant VARCHAR2(30):='AS_PERIOD_RATES_REFRESH';
G_FILE_NAME              Constant VARCHAR2(12):='asxrates.pls';


/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC DATATYPES
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC VARIABLES
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC ROUTINES
 |
 *-------------------------------------------------------------------------*/
PROCEDURE Refresh_AS_PERIOD_RATES(
    ERRBUF             OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    RETCODE            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    p_debug_mode       IN  VARCHAR2,
    p_trace_mode       IN  VARCHAR2);

END AS_PERIOD_RATES_REFRESH;


 

/
