--------------------------------------------------------
--  DDL for Package OPI_EDW_RES_UTIL_FOPM_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_RES_UTIL_FOPM_SZ" AUTHID CURRENT_USER AS
/* $Header: OPIPRUZS.pls 120.1 2005/06/09 16:23:15 appldev  $*/

PROCEDURE CNT_ROWS(p_from_date DATE, p_to_date DATE, p_num_rows OUT NOCOPY NUMBER)  ;

PROCEDURE EST_ROW_LEN(p_from_date DATE, p_to_date DATE, p_avg_row_len OUT NOCOPY NUMBER)  ;

END OPI_EDW_RES_UTIL_FOPM_SZ;

 

/
