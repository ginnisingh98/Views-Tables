--------------------------------------------------------
--  DDL for Package HR_EDW_WRK_SPRTN_F_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EDW_WRK_SPRTN_F_SIZING" AUTHID CURRENT_USER AS
/* $Header: hriezwsp.pkh 120.1 2005/06/08 02:52:34 anmajumd noship $ */

/******************************************************************************/
/* Sets p_num_rows to the number of rows which would be collected between the */
/* given dates                                                                */
/******************************************************************************/
PROCEDURE count_source_rows( p_from_date IN  DATE,
                             p_to_date   IN  DATE,
                             p_row_count OUT NOCOPY NUMBER );

PROCEDURE estimate_row_length( p_from_date       IN  DATE,
                               p_to_date         IN  DATE,
                               p_avg_row_length  OUT NOCOPY NUMBER);

END hr_edw_wrk_sprtn_f_sizing;

 

/
