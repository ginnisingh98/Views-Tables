--------------------------------------------------------
--  DDL for Package ENI_DBI_UCO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_UCO_PKG" AUTHID CURRENT_USER AS
/* $Header: ENIUCOPS.pls 120.0 2005/05/26 19:35:28 appldev noship $ */

-- Returns query for Total Cost report/portlet
PROCEDURE get_sql ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                            , x_custom_sql OUT NOCOPY VARCHAR2
                            , x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END ENI_DBI_UCO_PKG;

 

/
