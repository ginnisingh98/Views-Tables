--------------------------------------------------------
--  DDL for Package IEX_PROCESS_ACCOUNT_WINNERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_PROCESS_ACCOUNT_WINNERS" AUTHID CURRENT_USER as
/* $Header: iextpaws.pls 120.2.12010000.2 2009/07/31 09:48:20 pnaveenk ship $ */


/*-------------------------------------------------------------------------*
 |                             PUBLIC CONSTANTS
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC DATATYPES
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC VARIABLES
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC ROUTINES
 *-------------------------------------------------------------------------*/

PROCEDURE Process_Account_Records(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS,
    p_assignlevel      IN  varchar2);  -- changed for bug 8708291 pnaveenk multi level strategy


END IEX_PROCESS_ACCOUNT_WINNERS;

/
