--------------------------------------------------------
--  DDL for Package BIS_SETUP_KPI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_SETUP_KPI_PKG" AUTHID CURRENT_USER AS
/* $Header: BISKPISS.pls 120.1 2006/01/17 03:29:28 aguwalan noship $ */
version    CONSTANT VARCHAR2(80) := '$Header: BISKPISS.pls 120.1 2006/01/17 03:29:28 aguwalan noship $';

c_amp      CONSTANT VARCHAR2(1) := '&';
c_eq       CONSTANT VARCHAR2(1) := '=';

FUNCTION getValue(
   p_key        IN VARCHAR2
  ,p_parameters IN VARCHAR2
  ,p_delimiter  IN VARCHAR2 := c_amp ) RETURN VARCHAR2;

FUNCTION getPagesAndImplFlag(
   p_kpi_id   IN NUMBER ) RETURN VARCHAR2;

--FUNCTION getKpis(p_page_name IN VARCHAR2) RETURN t_bis_setup_kpi_tab;
PROCEDURE getKpis(p_page_name IN VARCHAR2);

--FUNCTION getkpisandpages RETURN t_bis_kpi_page_tab;
/* This API is not used with current Administer KPI UI; and the query used is coming up
   in the APPSPERF: R12 bug#4912250. Hence commenting this API
PROCEDURE getkpisandpages;
*/

PROCEDURE invalidateCache;

g_populated CHAR(1) := 'N';
--g_kpis_pages t_bis_kpi_page_tab := t_bis_kpi_page_tab();

END bis_setup_kpi_pkg;


 

/
