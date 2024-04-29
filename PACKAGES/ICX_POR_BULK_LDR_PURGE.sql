--------------------------------------------------------
--  DDL for Package ICX_POR_BULK_LDR_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_BULK_LDR_PURGE" AUTHID CURRENT_USER AS
/* $Header: ICXBLKPS.pls 115.1 2004/03/31 21:41:35 vkartik ship $*/

/**
 ** Proc : purge_bulk_ldr_tables
 ** Desc : Purges Bulk Loader tables beyond the no of days specified.
 **/
PROCEDURE purge_bulk_ldr_tables(p_no_of_days IN NUMBER DEFAULT 30,
                                p_commit_size IN NUMBER DEFAULT 2500);

END ICX_POR_BULK_LDR_PURGE;

 

/
