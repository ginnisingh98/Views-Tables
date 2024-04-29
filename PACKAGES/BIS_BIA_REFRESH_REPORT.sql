--------------------------------------------------------
--  DDL for Package BIS_BIA_REFRESH_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_BIA_REFRESH_REPORT" AUTHID CURRENT_USER AS
/* $Header: BISRPTSS.pls 115.0 2003/12/23 05:10:01 sbuenits noship $  */
   version               CONSTANT VARCHAR (80)
            := '$Header: BISRPTSS.pls 115.0 2003/12/23 05:10:01 sbuenits noship $
';

   FUNCTION get_request_set_time_qry (
      p_page_parameter_tbl   IN   bis_pmv_page_parameter_tbl
   )
      RETURN VARCHAR2;

   FUNCTION get_request_stage_time_qry (
      p_page_parameter_tbl   IN   bis_pmv_page_parameter_tbl
   )
      RETURN VARCHAR2;

   FUNCTION get_request_object_time_qry (
      p_page_parameter_tbl   IN   bis_pmv_page_parameter_tbl
   )
      RETURN VARCHAR2;

   FUNCTION time_interval (p_interval IN NUMBER)
      RETURN VARCHAR2;

END BIS_BIA_REFRESH_REPORT;


 

/
