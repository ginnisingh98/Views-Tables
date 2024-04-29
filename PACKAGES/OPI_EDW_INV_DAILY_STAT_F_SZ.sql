--------------------------------------------------------
--  DDL for Package OPI_EDW_INV_DAILY_STAT_F_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_INV_DAILY_STAT_F_SZ" AUTHID CURRENT_USER AS
/* $Header: OPIOINZS.pls 120.1 2005/06/07 02:08:55 appldev  $*/

PROCEDURE cnt_rows(p_from_date DATE, p_to_date DATE, p_num_rows OUT NOCOPY NUMBER)  ;

PROCEDURE est_row_len(p_from_date DATE, p_to_date DATE, p_avg_row_len OUT NOCOPY NUMBER)  ;

END OPI_EDW_INV_DAILY_STAT_F_SZ ;

 

/
