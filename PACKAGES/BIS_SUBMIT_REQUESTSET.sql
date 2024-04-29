--------------------------------------------------------
--  DDL for Package BIS_SUBMIT_REQUESTSET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_SUBMIT_REQUESTSET" AUTHID CURRENT_USER AS
/*$Header: BISSRSUS.pls 120.0.12010000.2 2008/08/12 07:53:39 bijain ship $*/
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(120.0.12000000.2=120.1):~PROD:~PATH:~FILE
TYPE table_sorting_rec_type IS RECORD (
  tbl_index		NUMBER,
  refresh_date	date);

TYPE table_sorting_tbl_type is TABLE of table_sorting_rec_type
  INDEX BY BINARY_INTEGER;

 function get_parameter_flag(p_program_name varchar2, p_app_id number) return varchar2;
 procedure update_default_value(p_program_name varchar2, p_app_id number) ;
 function get_last_refreshtime(p_obj_type varchar2,p_obj_owner varchar2,p_obj_name varchar2) return varchar2;
 function get_last_refreshdate(p_obj_type varchar2,p_obj_owner varchar2,p_obj_name varchar2) return date;
 procedure sort_table(p_sorting_tbl in out NOCOPY table_sorting_tbl_type) ;
 procedure update_last_refresh_date(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR2,
    p_request_id         IN NUMBER
 );


/**
procedure get_last_refreshdate(p_obj_type in varchar2,
                               p_obj_owner in varchar2,
                               p_obj_name in varchar2,
                               x_last_refresh_date out NOCOPY date,
                               x_detail_string out NOCOPY varchar2);
  **/
/** This api has been deprecated. But to be on the safer side,
the api has not been deleted.**/
function get_last_refreshdate_url(p_obj_type in varchar2,
                               p_obj_owner in varchar2,
                               p_obj_name in varchar2,
			       p_url_flag in varchar2 default 'Y') return varchar2;

function get_last_refreshdate_url(p_obj_type in varchar2,
                               p_obj_owner in varchar2,
                               p_obj_name in varchar2,
			       p_url_flag in varchar2 default 'Y',
                               p_RF_Url in varchar2) return varchar2;




END BIS_SUBMIT_REQUESTSET;

/
