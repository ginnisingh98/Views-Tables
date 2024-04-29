--------------------------------------------------------
--  DDL for Package OPI_EDW_JOB_RSRC_FOPM_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_JOB_RSRC_FOPM_SZ" AUTHID CURRENT_USER AS
/* $Header: OPIPJRZS.pls 120.1 2005/06/07 03:42:18 appldev  $*/

PROCEDURE CNT_ROWS(p_from_date DATE, p_to_date DATE, p_num_rows OUT NOCOPY NUMBER)  ;

PROCEDURE EST_ROW_LEN(p_from_date DATE, p_to_date DATE, p_avg_row_len OUT NOCOPY NUMBER)  ;

END OPI_EDW_JOB_RSRC_FOPM_SZ;

 

/
