--------------------------------------------------------
--  DDL for Package FII_AR_REC_ACTIVITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_REC_ACTIVITY_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIRECACTVS.pls 120.1.12000000.1 2007/02/23 02:28:53 applrt ship $ */


PROCEDURE get_rec_activity (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        rec_activity_sql             OUT NOCOPY VARCHAR2,
        rec_activity_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END FII_AR_REC_ACTIVITY_PKG;

 

/
