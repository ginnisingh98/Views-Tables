--------------------------------------------------------
--  DDL for Package Body INV_PRJ_CUST_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PRJ_CUST_VAL" AS
/* $Header: INVPRJCB.pls 120.2 2005/06/11 14:01:33 appldev  $ */

procedure validate(
	 V_item_id			IN	number
	,V_revision			IN	varchar2 	DEFAULT NULL
	,V_org_id			IN	number
	,V_sub_code			IN	varchar2
	,V_locator_id			IN	number		DEFAULT NULL
	,V_xfr_org_id			IN	number 		DEFAULT NULL
	,V_xfr_sub_code			IN	varchar2 	DEFAULT NULL
	,V_xfr_locator_id		IN	number 		DEFAULT NULL
	,V_quantity			IN	number
	,V_txn_type_id			IN	number
	,V_txn_action_id		IN	number 		DEFAULT NULL
	,V_txn_source_type_id		IN	number 		DEFAULT NULL
	,V_txn_source_id		IN	number 		DEFAULT NULL
	,V_txn_source_name		IN	varchar2	DEFAULT NULL
	,V_project_id			IN 	number 		DEFAULT NULL
	,V_task_id		 IN OUT NOCOPY /* file.sql.39 change */ number
	,V_source_project_id		IN 	number 		DEFAULT NULL
	,V_source_task_id	 IN OUT NOCOPY /* file.sql.39 change */ number
	,V_to_project_id		IN 	number 		DEFAULT NULL
	,V_to_task_id		 IN OUT NOCOPY /* file.sql.39 change */ number
	,V_txn_date			IN	date
	,V_pa_expenditure_org_id 	IN	number 		DEFAULT NULL
	,V_expenditure_type		IN	varchar2 	DEFAULT NULL
	,V_calling_module		IN	varchar2
	,V_user_id			IN	number
	,V_error_mesg		 OUT NOCOPY /* file.sql.39 change */ varchar2
	,V_warning_mesg		 OUT NOCOPY /* file.sql.39 change */ varchar2
	,V_success_flag		 OUT NOCOPY /* file.sql.39 change */ number
	,V_attribute_category		IN	varchar2
	,V_attribute1			IN	varchar2	DEFAULT NULL
	,V_attribute2			IN	varchar2	DEFAULT NULL
	,V_attribute3			IN	varchar2	DEFAULT NULL
	,V_attribute4			IN	varchar2	DEFAULT NULL
	,V_attribute5			IN	varchar2	DEFAULT NULL
	,V_attribute6			IN	varchar2	DEFAULT NULL
	,V_attribute7			IN	varchar2	DEFAULT NULL
	,V_attribute8			IN	varchar2	DEFAULT NULL
	,V_attribute9			IN	varchar2	DEFAULT NULL
	,V_attribute10			IN	varchar2	DEFAULT NULL
	,V_attribute11			IN	varchar2	DEFAULT NULL
	,V_attribute12			IN	varchar2	DEFAULT NULL
	,V_attribute13			IN	varchar2	DEFAULT NULL
	,V_attribute14			IN	varchar2	DEFAULT NULL
	,V_attribute15			IN	varchar2	DEFAULT NULL )
IS
/*
 Declare your local variables here before the "Begin" section
*/

Begin
v_success_flag := 1 ;
/*
 insert custom pl/sql code here. Make sure you comment the line above.
*/



end validate ;

END inv_prj_cust_val;

/
