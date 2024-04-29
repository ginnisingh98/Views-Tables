--------------------------------------------------------
--  DDL for Package EDW_HR_REC_ACT_M_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_HR_REC_ACT_M_SIZING" AUTHID CURRENT_USER AS
/* $Header: hriezrec.pkh 120.1 2005/06/08 02:49:41 anmajumd noship $ */

PROCEDURE count_source_rows( p_from_date IN  DATE,
                             p_to_date   IN  DATE,
                             p_row_count OUT NOCOPY NUMBER );

PROCEDURE estimate_row_length( p_from_date       IN  DATE,
                               p_to_date         IN  DATE,
                               p_avg_row_length  OUT NOCOPY NUMBER);

END edw_hr_rec_act_m_sizing;

 

/
