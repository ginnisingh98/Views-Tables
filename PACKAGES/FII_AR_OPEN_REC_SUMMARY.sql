--------------------------------------------------------
--  DDL for Package FII_AR_OPEN_REC_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_OPEN_REC_SUMMARY" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIORSS.pls 120.0.12000000.1 2007/02/23 02:28:22 applrt ship $ */

-- -----------------------------------------------------------------------
-- Name: get_open_rec_sum
-- Desc: This procedure is get the open receivable summary data
-- Output:
-- -----------------------------------------------------------------------

PROCEDURE get_open_rec_sum (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        open_rec_sum_sql        OUT NOCOPY VARCHAR2,
        open_rec_sum_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END fii_ar_open_rec_summary;

 

/
