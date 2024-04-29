--------------------------------------------------------
--  DDL for Package IEX_TERR_ASSIGNMENT_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_TERR_ASSIGNMENT_CLEANUP" AUTHID CURRENT_USER as
/* $Header: iexttacs.pls 120.1 2005/10/28 04:39:20 lkkumar noship $ */


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

PROCEDURE Cleanup_Duplicate_Resources(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS);

PROCEDURE Cleanup_Terrritory_Accesses(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS);

PROCEDURE Perform_Account_Cleanup(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS);


PROCEDURE Perform_Chgd_Accts_Cleanup(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS);


END IEX_TERR_ASSIGNMENT_CLEANUP;

 

/
