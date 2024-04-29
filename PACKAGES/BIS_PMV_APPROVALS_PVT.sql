--------------------------------------------------------
--  DDL for Package BIS_PMV_APPROVALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_APPROVALS_PVT" AUTHID CURRENT_USER as
/* $Header: BISAPPVS.pls 120.0.12000000.1 2007/01/19 17:54:39 appldev ship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.1=120.0):~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      BIS_PMV_APPROVALS_PVT
--                                                                        --
--  DESCRIPTION:  Approvals APIs for PMV
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                --
--  10/17/00   nkishore   Initial creation                                --
----------------------------------------------------------------------------

PROCEDURE APPROVALS_SQL (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                         ,x_custom_sql         OUT  NOCOPY VARCHAR2
                         ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE APPROVALS_DETAIL_SQL (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                         ,x_custom_sql         OUT  NOCOPY VARCHAR2
                         ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END BIS_PMV_APPROVALS_PVT;

 

/
