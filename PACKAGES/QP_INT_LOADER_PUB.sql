--------------------------------------------------------
--  DDL for Package QP_INT_LOADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_INT_LOADER_PUB" AUTHID CURRENT_USER AS
/* $Header: QPXILDRS.pls 120.1 2005/06/14 05:36:16 appldev  $ */

G_PROCESS_LST_REQ_TYPE                  VARCHAR2(3);

PROCEDURE Load_Int_List
(	p_process_id		IN	NUMBER,
	x_status		OUT NOCOPY /* file.sql.39 change */	VARCHAR2,
	x_errors		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
);


PROCEDURE Load_Int_List
(	p_process_id		IN	NUMBER,
	p_action_code		IN	VARCHAR2
);

/*

PROCEDURE Insert_Err_Msg
(
		p_job_id		IN	NUMBER,
		p_line_num		IN	NUMBER,
		p_field_name		IN 	VARCHAR2,
		p_creation_date		IN 	DATE,
		p_err_msg		IN 	VARCHAR2,
		p_last_update_date	IN 	DATE
);

PROCEDURE Insert_Job_Status
(
		p_job_id		IN	NUMBER,
		p_lines_processed	IN	NUMBER,
		p_lines_failed		IN 	NUMBER,
		p_lines_submitted	IN 	NUMBER,
		p_total_error_number	IN 	NUMBER,
		p_supplier_id		IN 	NUMBER,
		p_job_status		IN	VARCHAR2,
		p_job_type		IN	VARCHAR2,
		p_file_name		IN	VARCHAR2,
		p_start_date		IN 	DATE,
		p_completion_date	IN	DATE
);

PROCEDURE GetRegionId (
	p_region_str IN VARCHAR2,
	x_region_id OUT NOCOPY NUMBER,
	x_rid_err_msg OUT NOCOPY VARCHAR2
);
*/

PROCEDURE Get_Party_Id (
	p_process_id IN NUMBER,
	x_party_id OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_pid_err_msg OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

PROCEDURE Is_Qualifier_Prclst_Exist (
		p_prclst_name IN VARCHAR2,
		x_prclst_exists OUT NOCOPY /* file.sql.39 change */ BOOLEAN,
		x_prclst_exists_err_msg OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

g_temp_status varchar2(30);
g_temp_errors varchar2(5000);
g_temp_region_id NUMBER;

END QP_INT_LOADER_PUB;

 

/
