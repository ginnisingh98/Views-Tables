--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_PER_ORGMGR_LOV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_PER_ORGMGR_LOV" AUTHID CURRENT_USER AS
/* $Header: hriopomlov.pkh 120.2 2005/09/26 21:55:29 rlpatil noship $ */


   PROCEDURE GET_SQL(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                     x_custom_sql       OUT NOCOPY VARCHAR2,
                     x_custom_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END HRI_OLTP_PMV_PER_ORGMGR_LOV;


 

/
