--------------------------------------------------------
--  DDL for Package BIS_BIA_RSG_LOG_MGMNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_BIA_RSG_LOG_MGMNT" AUTHID CURRENT_USER AS
/*$Header: BISBRLMS.pls 120.1 2005/08/17 13:36:59 tiwang noship $*/

PROCEDURE MV_LOG_API (
    ERRBUF  		OUT NOCOPY VARCHAR2,
    RETCODE		    OUT NOCOPY VARCHAR2,
    P_API 	        IN 	VARCHAR2,
    P_OBJ_NAME      IN 	VARCHAR2,
    P_OBJ_TYPE      IN 	VARCHAR2,
    P_MODE          IN 	VARCHAR2
);

PROCEDURE create_mv_log(
    p_base_object_name in varchar2,
    P_base_object_schema in varchar2,
    P_base_object_type in varchar2,
	P_check_profile in varchar2 default 'Y');

PROCEDURE capture_and_drop_log_by_set(
    ERRBUF  		   OUT NOCOPY VARCHAR2,
    RETCODE		       OUT NOCOPY VARCHAR2,
    p_request_set_name in varchar2);


procedure restore_by_set(
   ERRBUF  		   OUT NOCOPY VARCHAR2,
   RETCODE		       OUT NOCOPY VARCHAR2,
   p_request_set_name varchar2
);

PROCEDURE base_sum_mlog_recreate (
    P_OBJ_NAME      IN 	VARCHAR2
);

PROCEDURE base_sum_mlog_capture_and_drop(
    P_OBJ_NAME      IN 	VARCHAR2
);

function get_mv_creation_date_dd (p_base_object_name in varchar2,p_base_object_type in varchar2,p_base_object_schema in varchar2) return date;

END BIS_BIA_RSG_LOG_MGMNT;

 

/
