--------------------------------------------------------
--  DDL for Package EDW_ITEMS_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_ITEMS_M_SIZE" AUTHID CURRENT_USER AS
/* $Header: ENIITMSS.pls 115.4 2004/01/30 21:50:32 sbag noship $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER);


PROCEDURE est_row_len(p_from_date DATE,
                      p_to_date DATE,
                      p_avg_row_len OUT NOCOPY NUMBER);

END EDW_ITEMS_M_SIZE;

 

/
