--------------------------------------------------------
--  DDL for Package OPI_EDW_RES_UTIL_F_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_RES_UTIL_F_SZ" AUTHID CURRENT_USER AS
/* $Header: OPIORUZS.pls 120.2 2005/06/16 03:52:18 appldev  $*/

PROCEDURE cnt_rows(p_from_date DATE, p_to_date DATE, p_num_rows OUT NOCOPY NUMBER)  ;

PROCEDURE est_row_len(p_from_date DATE, p_to_date DATE, p_avg_row_len OUT NOCOPY NUMBER)  ;

END opi_edw_res_util_f_sz;

 

/
