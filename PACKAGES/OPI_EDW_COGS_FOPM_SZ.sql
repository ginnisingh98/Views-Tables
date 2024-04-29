--------------------------------------------------------
--  DDL for Package OPI_EDW_COGS_FOPM_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_COGS_FOPM_SZ" AUTHID CURRENT_USER AS
/* $Header: OPIPCGZS.pls 120.2 2005/06/16 03:53:33 appldev  $*/

PROCEDURE cnt_rows(p_from_date DATE, p_to_date DATE, p_num_rows OUT NOCOPY NUMBER)  ;

PROCEDURE est_row_len(p_from_date DATE, p_to_date DATE, p_avg_row_len OUT NOCOPY NUMBER)  ;

END OPI_EDW_COGS_FOPM_SZ;

 

/
