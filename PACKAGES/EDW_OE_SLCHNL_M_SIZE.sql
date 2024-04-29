--------------------------------------------------------
--  DDL for Package EDW_OE_SLCHNL_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_OE_SLCHNL_M_SIZE" AUTHID CURRENT_USER AS
/*$Header: ISCSGD3S.pls 115.2 2002/12/19 01:01:53 scheung ship $ */

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER);

PROCEDURE est_row_len(p_from_date DATE,
                      p_to_date DATE,
                      p_avg_row_len OUT NOCOPY NUMBER);

End EDW_OE_SLCHNL_M_SIZE;

 

/
