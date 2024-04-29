--------------------------------------------------------
--  DDL for Package FUN_OPEN_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_OPEN_INTERFACE_PKG" AUTHID CURRENT_USER AS
/* $Header: funximps.pls 120.4.12010000.3 2009/07/30 15:53:32 abhaktha ship $ */


/***********************************************
* Procedure Main :
*                        This Procedure Validates the Interface Table Data and       *
*		on success Inserts into FUN Final Tables			*
*										*
***************************************************/

PROCEDURE MAIN(
    p_errbuff  OUT NOCOPY VARCHAR2,
    p_retcode OUT NOCOPY NUMBER,
    p_source IN VARCHAR2,
    p_group_id IN NUMBER,
    p_import_transaction_as_sent IN VARCHAR2  default null,
   p_rejected_only IN VARCHAR2  default null,
   p_debug IN VARCHAR2
);

/***********************************************
*   Procedure Purge_Interface_Table :					*
	*                        Procedure to Purge Accepted Records from the Interface Tables		*
*										*
***************************************************/

PROCEDURE Purge_Interface_Table
        (
               p_source               IN      VARCHAR2,
               p_group_id	        IN     VARCHAR2
        );

	/*****************************************************
	*Procedure to purge the Rejected Transactions from interface tables.
	*
	********************************************************/
PROCEDURE Import_data_purge
        (
               errbuf             OUT NOCOPY VARCHAR2,
               retcode            OUT NOCOPY NUMBER,
               p_source           IN  VARCHAR2,
               p_group_id         IN  NUMBER DEFAULT NULL,
	       p_review_required  IN  VARCHAR2
        );

END FUN_OPEN_INTERFACE_PKG;

/
