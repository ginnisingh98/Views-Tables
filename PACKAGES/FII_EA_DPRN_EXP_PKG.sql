--------------------------------------------------------
--  DDL for Package FII_EA_DPRN_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_EA_DPRN_EXP_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIEAMAJS.pls 120.1 2005/10/30 05:12:56 appldev noship $ */

-- ----------------------------------------------------------------------
--
-- GET_DPRN_EXP_MAJ: This procedure is called from Depreciation Expense
--                   by Major Category report. It is the main procedure
--                   that reads the report parameter values, builds the
--                   PMV sql and passes back to the calling PMV report.
--
-- ----------------------------------------------------------------------

PROCEDURE GET_DPRN_EXP_MAJ( p_page_parameter_tbl    IN            BIS_PMV_PAGE_PARAMETER_TBL,
                            get_dprn_exp_maj_sql       OUT NOCOPY VARCHAR2,
                            get_dprn_exp_maj_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


-- ----------------------------------------------------------------------
--
-- GET_DPRN_EXP_MIN: This procedure is called from Depreciation Expense
--                   by Minor Category report. It is the main procedure
--                   that reads the report parameter values, builds the
--                   PMV sql and passes back to the calling PMV report.
--
-- ----------------------------------------------------------------------

PROCEDURE GET_DPRN_EXP_MIN( p_page_parameter_tbl    IN            BIS_PMV_PAGE_PARAMETER_TBL,
                            get_dprn_exp_min_sql       OUT NOCOPY VARCHAR2,
                            get_dprn_exp_min_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- ----------------------------------------------------------------------
--
-- GET_DPRN_EXP_LIST: This procedure is called from Depreciation Expense
--                   by Asset Listing report. It is the main procedure
--                   that reads the report parameter values, builds the
--                   PMV sql and passes back to the calling PMV report.
--
-- ----------------------------------------------------------------------

PROCEDURE GET_DPRN_EXP_LIST( p_page_parameter_tbl    IN              BIS_PMV_PAGE_PARAMETER_TBL,
                             get_dprn_exp_list_sql       OUT NOCOPY  VARCHAR2,
                             get_dprn_exp_list_output    OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);
END FII_EA_DPRN_EXP_PKG;

 

/
