--------------------------------------------------------
--  DDL for Package BIS_COLL_RS_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_COLL_RS_HISTORY" AUTHID CURRENT_USER AS
/*$Header: BISRSHTS.pls 120.1 2006/05/18 12:28:42 aguwalan noship $*/

procedure rsg_history_report (
	errbuf  		   OUT NOCOPY VARCHAR2,
        retcode		           OUT NOCOPY VARCHAR2,
	Root_request_id		   IN    NUMBER);

procedure insert_program_object_data (	x_request_id    IN NUMBER,
					x_stage_req_id  IN NUMBER,
					x_object_name   IN VARCHAR2,
					x_object_type   IN VARCHAR2,
					x_refresh_type  IN VARCHAR2,
					x_set_request_id IN NUMBER);


procedure purgeHistory;

procedure get_space_usage_details( p_object_name	     IN			varchar2,
				    p_Object_type	     IN			varchar2,
				    p_Object_row_count	     OUT  NOCOPY	number,
				    p_Object_space_usage     OUT  NOCOPY	number,
				    p_Tablespace_name        OUT  NOCOPY	varchar2,
				    p_Free_tablespace_size   OUT  NOCOPY	number
				    );
PROCEDURE add_rsg_rs_run_record(p_request_set_id	IN NUMBER,
				p_request_set_appl_id	IN NUMBER,
				p_request_name		IN VARCHAR2,
				p_root_req_id		IN NUMBER);

FUNCTION get_refresh_mode(p_request_set_id	IN NUMBER,
			  p_request_set_appl_id	IN NUMBER) RETURN VARCHAR2;

FUNCTION if_program_already_ran(l_root_request_id NUMBER ) RETURN BOOLEAN;

FUNCTION get_req_set_details(p_request_set_id	   OUT    NOCOPY NUMBER,
			 p_request_set_appl_id	   OUT    NOCOPY NUMBER,
			 p_request_set_name        OUT    NOCOPY VARCHAR2,
			 p_root_request_id	   IN     NUMBER ) RETURN BOOLEAN  ;

function get_lookup_meaning(p_lookup_type varchar2, p_lookup_code varchar2) return varchar2;

PROCEDURE update_warn_compl_txt(p_root_req_id IN NUMBER);

procedure update_terminated_rs;

PROCEDURE update_rs_stage_dates(p_root_req_id IN NUMBER);

PROCEDURE  update_report_date;

PROCEDURE capture_object_info(p_root_request_id IN NUMBER);

END BIS_COLL_RS_HISTORY;

 

/
