--------------------------------------------------------
--  DDL for Package EDW_HR_MVMNT_TYP_M_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_HR_MVMNT_TYP_M_SIZING" AUTHID CURRENT_USER AS
/* $Header: hriezmvt.pkh 120.1 2005/06/08 02:46:52 anmajumd noship $ */

PROCEDURE count_source_rows( p_from_date IN  DATE,
                             p_to_date   IN  DATE,
                             p_row_count OUT NOCOPY NUMBER );

PROCEDURE estimate_row_length( p_from_date       IN  DATE,
                               p_to_date         IN  DATE,
                               p_avg_row_length  OUT NOCOPY NUMBER);

END edw_hr_mvmnt_typ_m_sizing;

 

/
