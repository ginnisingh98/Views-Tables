--------------------------------------------------------
--  DDL for Package OPI_DBI_OPEN_JOB_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_OPEN_JOB_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: OPIDROPNJS.pls 120.0 2005/05/24 19:09:50 appldev noship $ */
  PROCEDURE get_dtl_sql( p_param          IN         BIS_PMV_PAGE_PARAMETER_TBL
                     , x_custom_sql     OUT NOCOPY VARCHAR2
                     , x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
END OPI_DBI_OPEN_JOB_DTL_PKG;

 

/