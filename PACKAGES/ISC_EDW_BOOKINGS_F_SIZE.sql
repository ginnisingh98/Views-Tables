--------------------------------------------------------
--  DDL for Package ISC_EDW_BOOKINGS_F_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_EDW_BOOKINGS_F_SIZE" AUTHID CURRENT_USER AS
/*$Header: ISCSGF0S.pls 115.2 2002/12/19 01:02:33 scheung ship $ */

   PROCEDURE cnt_rows(p_from_date DATE,
                      p_to_date DATE,
                      p_num_rows OUT NOCOPY NUMBER);

   PROCEDURE est_row_len(p_from_date DATE,
                         p_to_date DATE,
                         p_avg_row_len OUT NOCOPY NUMBER);

End ISC_EDW_BOOKINGS_F_SIZE;

 

/
