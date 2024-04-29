--------------------------------------------------------
--  DDL for Package FII_AR_OPEN_REC_PDUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_OPEN_REC_PDUE" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIPDS.pls 120.0.12000000.1 2007/02/23 02:28:26 applrt ship $ */


PROCEDURE get_rec_pdue (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        open_rec_sql             OUT NOCOPY VARCHAR2,
        open_rec_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END FII_AR_OPEN_REC_PDUE;

-- End of package


 

/
