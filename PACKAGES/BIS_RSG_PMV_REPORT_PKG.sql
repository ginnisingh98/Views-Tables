--------------------------------------------------------
--  DDL for Package BIS_RSG_PMV_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_RSG_PMV_REPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: BISRSPRS.pls 120.1 2006/03/27 09:31:21 amitgupt noship $ */

 FUNCTION duration_str(
 	p_duration		number) return VARCHAR2;

 FUNCTION duration_HHMM(
 	p_duration		number) return VARCHAR2;

 FUNCTION duration(
	p_duration		number) return NUMBER;

 FUNCTION get_meaning(p_status_code VARCHAR2,
                   p_phase_code VARCHAR2) return VARCHAR2 ;

 PROCEDURE request_set_perf_report (
            p_param 	IN 		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output OUT NOCOPY 	BIS_QUERY_ATTRIBUTES_TBL);
 PROCEDURE request_set_perf_det_rep(
             p_param 	IN 		BIS_PMV_PAGE_PARAMETER_TBL,
 			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output OUT NOCOPY 	BIS_QUERY_ATTRIBUTES_TBL);

 PROCEDURE request_set_sub_req_rep(
             p_param 	IN 		BIS_PMV_PAGE_PARAMETER_TBL,
   			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output OUT NOCOPY 	BIS_QUERY_ATTRIBUTES_TBL);

 PROCEDURE request_set_space_rep(
              p_param 	IN 		BIS_PMV_PAGE_PARAMETER_TBL,
    			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output OUT NOCOPY 	BIS_QUERY_ATTRIBUTES_TBL);

 PROCEDURE tablespace_detail_report(
               p_param 	IN 		BIS_PMV_PAGE_PARAMETER_TBL,
     			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output OUT NOCOPY 	BIS_QUERY_ATTRIBUTES_TBL);

 PROCEDURE request_details_report(
                p_param 	IN 		BIS_PMV_PAGE_PARAMETER_TBL,
      			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output OUT NOCOPY 	BIS_QUERY_ATTRIBUTES_TBL);

 FUNCTION  gtitle(p_param 			BIS_PMV_PAGE_PARAMETER_TBL) return varchar2;

 FUNCTION  get_max_stg(prog_id Number,
                       set_req_id Number,
                       stage_id varchar2) return Number;

 FUNCTION  get_latest_run(req_set_id Number) return Number;

 FUNCTION  Check_rsid(req_set_id Number) return Number;

 FUNCTION  returnLogUrl(req_id Number, fromReport Number) return Varchar2;

 -- added for bug 4486989
 -- function is added for timezone conversion
 -- is also being called from BIS_SUBMIT_REQUESTSET
 FUNCTION date_to_charDTTZ(pServerDate DATE) return varchar2;

END BIS_RSG_PMV_REPORT_PKG;

 

/
