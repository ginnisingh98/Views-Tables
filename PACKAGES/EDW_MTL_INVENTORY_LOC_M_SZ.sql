--------------------------------------------------------
--  DDL for Package EDW_MTL_INVENTORY_LOC_M_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_MTL_INVENTORY_LOC_M_SZ" AUTHID CURRENT_USER AS
/* $Header: OPIINLZS.pls 120.1 2005/06/10 13:33:04 appldev  $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER)  ;


PROCEDURE est_row_len(p_from_date DATE,
                   p_to_date DATE,
                   p_est_row_len OUT NOCOPY NUMBER) ;

END EDW_MTL_INVENTORY_LOC_M_SZ;

 

/
