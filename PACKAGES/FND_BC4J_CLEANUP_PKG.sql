--------------------------------------------------------
--  DDL for Package FND_BC4J_CLEANUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_BC4J_CLEANUP_PKG" AUTHID CURRENT_USER AS
/* $Header: FNDBCCLS.pls 115.1 2002/08/29 10:05:13 nigoel ship $ */

/*
 * Deletes rows for user transaction state in FND_PS_TXN table.
 * p_older_than_date - Rows that are older than this date will be
 * deleted.
 */
PROCEDURE Delete_Transaction_Rows(p_older_than_date IN DATE);

/*
 * Deletes rows for the control table FND_PCOLL_CONTROL table.
 * p_older_than_date - Rows that are older than this date will be
 * deleted.
 */
PROCEDURE Delete_Control_Rows(p_older_than_date IN DATE);


end FND_BC4J_CLEANUP_PKG;

 

/
