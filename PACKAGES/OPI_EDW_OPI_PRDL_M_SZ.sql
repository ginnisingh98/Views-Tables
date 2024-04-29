--------------------------------------------------------
--  DDL for Package OPI_EDW_OPI_PRDL_M_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_OPI_PRDL_M_SZ" AUTHID CURRENT_USER as
/* $Header: OPIOPLZS.pls 120.2 2005/06/14 12:49:39 appldev  $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER)  ;


PROCEDURE est_row_len(p_from_date DATE,
                   p_to_date DATE,
                   p_est_row_len OUT NOCOPY NUMBER) ;

END opi_edw_opi_prdl_m_sz;

 

/
