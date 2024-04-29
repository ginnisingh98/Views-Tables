--------------------------------------------------------
--  DDL for Package WMS_CONTROL_BOARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CONTROL_BOARD" AUTHID CURRENT_USER AS
/* $Header: WMSCBCPS.pls 120.1 2005/06/17 05:42:30 appldev  $ */

-- Record Type for the task status distribution data for the performance chart
TYPE cb_chart_status_rec_type is RECORD
  (
      status		VARCHAR2(400) 	:= NULL
    , task_count	NUMBER  	:= NULL
  );

-- Table type definition for an array of cb_chart_status_rec_type records.
TYPE cb_chart_status_tbl_type is TABLE OF cb_chart_status_rec_type
  INDEX BY BINARY_INTEGER;

-- Record Type for the task type distribution data for the performance chart
TYPE cb_chart_type_rec_type is RECORD
  (
      type		VARCHAR2(100) 	:= NULL
    , task_count	NUMBER  	:= NULL
  );

-- Table type definition for an array of cb_chart_type_rec_type records.
TYPE cb_chart_type_tbl_type is TABLE OF cb_chart_type_rec_type
  INDEX BY BINARY_INTEGER;

-- constance for null values
ln_null	 CONSTANT   NUMBER := 0;
lc_null  CONSTANT   VARCHAR2(4) := 'NULL';


-- Procedure definition to get task status distribution
-- Bug # 1800521, added new input parameter to status,task distribution procedure
-- so that sql has same where clause as the control board find window.
-- After making changes in the control board form to split the task and
-- exception views into separate ones, it makes sense to have the
-- performance chart use the same where clause that is set either through
-- the query find window or selecting the nodes in the trees
-- The where clause is now set as a form level parameter

/* --Bug#2483984 Performace Tuning of WMS Control Board
  --  now there are separate FROM and WHERE clauses for active, pending and completed tasks */
PROCEDURE get_status_dist (
	x_status_chart_data OUT NOCOPY /* file.sql.39 change */ cb_chart_status_tbl_type
,	x_status_data_count OUT NOCOPY /* file.sql.39 change */ 	NUMBER
,	x_return_status	        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, 	x_msg_count	        OUT NOCOPY /* file.sql.39 change */ NUMBER
, 	x_msg_data     	        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,  p_cq_type   IN NUMBER
,  p_at_from   IN VARCHAR2
,  p_pt_from   IN VARCHAR2
,  p_ct_from   IN VARCHAR2
,  p_at_where  IN VARCHAR2
,  p_pt_where  IN VARCHAR2
,  p_ct_where  IN VARCHAR2
,  p_acy_from   IN VARCHAR2
,  p_pcy_from   IN VARCHAR2
,  p_ccy_from   IN VARCHAR2
,  p_acy_where  IN VARCHAR2
,  p_pcy_where  IN VARCHAR2
,  p_ccy_where  IN VARCHAR2
);

-- Procedure definition to get task type distribution
/* --Bug#2483984 Performace Tuning of WMS Control Board
  --  now there are separate FROM and WHERE clauses for active, pending and completed tasks */
PROCEDURE get_type_dist(
	x_type_chart_data OUT NOCOPY /* file.sql.39 change */ cb_chart_type_tbl_type
,	x_type_data_count OUT NOCOPY /* file.sql.39 change */ 	NUMBER
,	x_return_status	        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, 	x_msg_count	        OUT NOCOPY /* file.sql.39 change */ NUMBER
, 	x_msg_data     	        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,  p_cq_type   IN NUMBER
,  p_at_from   IN VARCHAR2
,  p_pt_from   IN VARCHAR2
,  p_ct_from   IN VARCHAR2
,  p_at_where  IN VARCHAR2
,  p_pt_where  IN VARCHAR2
,  p_ct_where  IN VARCHAR2
,  p_acy_from   IN VARCHAR2
,  p_pcy_from   IN VARCHAR2
,  p_ccy_from   IN VARCHAR2
,  p_acy_where  IN VARCHAR2
,  p_pcy_where  IN VARCHAR2
,  p_ccy_where  IN VARCHAR2
);

-----------------------------------------------------------
-- Procedure to check whether a change in status is validate
-----------------------------------------------------------
FUNCTION is_status_valid(
	p_from_status		IN NUMBER
,	p_to_status		IN NUMBER ) RETURN VARCHAR2;


/*****kkoothan*** Part of Fix#2163139  *******/
/*** Added one more default null parameter ***/
/*** p_transaction_source_type_id in       ***/
/*** lock_row to handle cycle count Tasks. ***/
PROCEDURE lock_row(
	p_rowid				 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,	p_transaction_temp_id			IN	NUMBER
,	p_task_id				IN	NUMBER
,	p_status				IN 	NUMBER
,	p_priority				IN 	NUMBER
,	p_person_id				IN	NUMBER
,	p_person_resource_id			IN	NUMBER
,   p_transaction_source_type_id IN NUMBER DEFAULT NULL --kkoothan
);

-- Procedure definition to manipulate the warehosue task
-- resource information and priority.
/*****kkoothan***     Part of Fix#2163139    *******/
/*** Added one more default null parameter       ***/
/*** p_transaction_source_type_id in             ***/
/*** task_manipulator to handle cycle count Tasks***/
PROCEDURE task_manipulator(
	 x_return_status		 OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
	,x_msg_count			 OUT NOCOPY /* file.sql.39 change */ 	NUMBER
	,x_msg_data			 OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
	,x_task_id			 OUT NOCOPY /* file.sql.39 change */ 	NUMBER
	,p_updated_by				IN	NUMBER
	,p_task_id				IN	NUMBER DEFAULT NULL
	,p_transaction_temp_id			IN	NUMBER
	,p_organization_id			IN	NUMBER
	,p_person_resource_id			IN	NUMBER
	,p_person_id				IN	NUMBER
	,p_priority				IN	NUMBER
	,p_from_status				IN	NUMBER
	,p_to_status				IN	NUMBER
	,p_user_task_type			IN 	NUMBER DEFAULT NULL
	,p_task_type				IN	NUMBER DEFAULT NULL
        ,p_transaction_source_type_id IN NUMBER DEFAULT NULL -- kkoothan
        ,p_last_update_date                     IN      DATE DEFAULT NULL );  /* Bug 2372652 */
	-- Bug# 1728558, added p_user_task_type parameter

PROCEDURE mydebug(msg in varchar2);

END WMS_CONTROL_BOARD;

 

/
