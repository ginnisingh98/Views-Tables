--------------------------------------------------------
--  DDL for Package PA_BIS_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BIS_SUMMARY" AUTHID CURRENT_USER AS
/* $Header: PABISUMS.pls 120.1 2005/08/19 16:16:15 mwasowic noship $ */

----------------------------
--  PROCEDURES AND FUNCTIONS
--
--
--  1. Procedure Name:	SUMMARIZE_BIS
--  	Usage:		Populates data in tables : PA_BIS_TOTALS_BY_PERIOD,
--                             			      PA_BIS_TOTALS_TO_DATE,
--						                           PA_BIS_TO_DATE_DRILLDOWNS,
--						                           PA_BIS_PRJ_BY_PERD_DRILLDOWNS,
--						                           PA_BIS_PRJ_TO_DATE_DRILLDOWNS


Procedure SUMMARIZE_BIS(errbuf OUT NOCOPY varchar2,ret_code OUT NOCOPY varchar2); --File.Sql.39 bug 4440895

END PA_BIS_SUMMARY;

 

/
