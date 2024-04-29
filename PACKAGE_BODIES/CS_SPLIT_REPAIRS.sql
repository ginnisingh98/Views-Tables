--------------------------------------------------------
--  DDL for Package Body CS_SPLIT_REPAIRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SPLIT_REPAIRS" as
/* $Header: csxdsplb.pls 115.0 99/07/16 09:07:59 porting ship $ */

/*
This procedure is called from the Repairs form, Split window. It allows users
to split one repiar line into 2 user-defined quantities or multiple quantities
of 1 each. A history record indicating a split is written for all repair lines

Paramaters:

	x_user_id		user who performed the split
	x_repair_line_id	repair line that is being split
	x_first_quantity	user-defined quantity. Null if the user
				has indicated split into quantities of 1 each
	x_total_quantity	quantity_received in CS_REPAIRS table.

How it works:
  If we have to split into multiple quantites of 1 each (x_first_quantity
  is NULL).

	1. The repair record is updated with quantity_received = 1 and
	a history is written with a status of SPLIT.
	2. LOOP from 1 to (x_total_quantity - 1)
		Get the next repair_line_id from cs_repairs_s
		Insert into cs_repairs (quantity_received=1) by setting all
		other columns the same as in the original repair line
		Insert repair history records.

  If we have to split into 2 lines with user_defined quantities
	1. The original repair record is updated with quantity_received =
	x_first_quantity and history is written indicating the split.
	2. Get the next repair_line_id from cs_repairs_s
	3. Insert into cs_repairs (quantity_received = x_total_quantity -
	x_first_quantity)
	4. Insert history records.
*/

procedure CS_SPLIT_REPAIRS(X_user_id		IN NUMBER,
			   X_repair_line_id  	IN NUMBER,
			   X_first_quantity  	IN NUMBER,
			   X_total_quantity	IN NUMBER) IS
  Split_lines NUMBER;
  new_line_id NUMBER;
  new_repair_number varchar2(30) ;
  dummy_date  DATE;
  BEGIN

/* Split into multiple lines of quantity 1 each  	 */
/* First update the quantity in the existing record to 1 */
/* Insert a history record to indicate the split	 */

   IF (X_first_quantity IS NULL) THEN

      UPDATE cs_repairs
	 SET quantity_received = 1
	     where repair_line_id = X_repair_line_id;

      INSERT INTO cs_repair_history
		(
		 REPAIR_LINE_ID,
		 LAST_UPDATE_DATE,
		 LAST_UPDATED_BY,
		 CREATION_DATE,
		 CREATED_BY,
		 LAST_UPDATE_LOGIN,
		 REQUEST_ID,
		 TRANSACTION_DATE,
		 STATUS,
		 ATTRIBUTE1,
		 ATTRIBUTE2,
		 ATTRIBUTE3,
		 ATTRIBUTE4,
		 ATTRIBUTE5,
		 ATTRIBUTE6,
		 ATTRIBUTE7,
		 ATTRIBUTE8,
		 ATTRIBUTE9,
		 ATTRIBUTE10,
		 ATTRIBUTE11,
		 ATTRIBUTE12,
		 ATTRIBUTE13,
		 ATTRIBUTE14,
		 ATTRIBUTE15,
		 CONTEXT,
		 PROGRAM_ID,
		 PROGRAM_APPLICATION_ID,
		 PROGRAM_UPDATE_DATE,
		 REPAIR_HISTORY_ID
		)
      VALUES
		(
		x_repair_line_id
		,sysdate
		,x_user_id
 		,sysdate
 		,x_user_id
	 	,x_user_id
		,NULL
		,sysdate
 		,'SPLIT'
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
		,cs_repair_history_s.nextval
	     	);

/* Insert the remaining (quantity - 1) lines using values from the */
/* original repair line.					   */

      FOR split_lines in 1..(X_total_quantity - 1) LOOP

	SELECT cs_repairs_s.nextval
	  INTO new_line_id
	  FROM dual;

	SELECT to_number(cs_repair_number_s.nextval)
	  INTO new_repair_number
	  FROM dual;
	INSERT INTO cs_repairs
		(
		repair_line_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
	 	request_id,
		program_id,
		program_application_id,
		program_update_date,
		rma_header_id,
		rma_line_id,
		estimate_id,
		wip_entity_id,
		repair_header_id,
		replace_header_id,
		loaner_header_id,
		customer_product_id,
		inventory_item_id,
		serial_number,
		quantity_received,
		quantity_scrapped,
		quantity_replaced,
		repair_unit_of_measure_code,
		status,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15,
		context,
		group_id,
		quantity_complete,
		org_id,
		organization_id,
		original_system_reference,
		original_system_line_reference,
		repair_order_line_id,
		repair_duration,
		received_date,
		shipped_date,
		rma_customer_id,
 		rma_number,
 		rma_type_id,
 		rma_date,
 		rma_line_number,
		recvd_organization_id,
		repair_number,
		mtl_transaction_id,
		allow_job,
		incident_id,
		estimate_business_group_id,
		diagnosis_id,
		diagnosed_by_id,
		job_completion_date,
		promised_delivery_date
		)
	SELECT	new_line_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
	 	request_id,
		program_id,
		program_application_id,
		program_update_date,
		rma_header_id,
		rma_line_id,
		estimate_id,
		wip_entity_id,
		repair_header_id,
		replace_header_id,
		loaner_header_id,
		customer_product_id,
		inventory_item_id,
		serial_number,
		1,
		quantity_scrapped,
		quantity_replaced,
		repair_unit_of_measure_code,
		status,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15,
		context,
		group_id,
		quantity_complete,
		org_id,
		organization_id,
		original_system_reference,
		original_system_line_reference,
		repair_order_line_id,
		repair_duration,
		received_date,
		shipped_date,
		rma_customer_id,
 		rma_number,
 		rma_type_id,
 		rma_date,
 		rma_line_number,
		recvd_organization_id,
		new_repair_number,
		mtl_transaction_id,
		allow_job,
		incident_id,
		estimate_business_group_id,
		diagnosis_id,
		diagnosed_by_id,
		job_completion_date,
		promised_delivery_date
	 FROM	cs_repairs
	WHERE	repair_line_id = X_repair_line_id;

/* Insert history records for the new lines */

      INSERT INTO cs_repair_history
		(
		 REPAIR_LINE_ID,
		 LAST_UPDATE_DATE,
		 LAST_UPDATED_BY,
		 CREATION_DATE,
		 CREATED_BY,
		 LAST_UPDATE_LOGIN,
		 REQUEST_ID,
		 TRANSACTION_DATE,
		 STATUS,
		 ATTRIBUTE1,
		 ATTRIBUTE2,
		 ATTRIBUTE3,
		 ATTRIBUTE4,
		 ATTRIBUTE5,
		 ATTRIBUTE6,
		 ATTRIBUTE7,
		 ATTRIBUTE8,
		 ATTRIBUTE9,
		 ATTRIBUTE10,
		 ATTRIBUTE11,
		 ATTRIBUTE12,
		 ATTRIBUTE13,
		 ATTRIBUTE14,
		 ATTRIBUTE15,
		 CONTEXT,
		 PROGRAM_ID,
		 PROGRAM_APPLICATION_ID,
		 PROGRAM_UPDATE_DATE,
		 REPAIR_HISTORY_ID
		)
      SELECT  	new_line_id
		,last_update_date
		,last_updated_by
 		,creation_date
 		,created_by
	 	,last_update_login
		,request_id
		,transaction_date
 		,status
 		,attribute1
 		,attribute2
 		,attribute3
 		,attribute4
 		,attribute5
 		,attribute6
 		,attribute7
 		,attribute8
 		,attribute9
 		,attribute10
 		,attribute11
 		,attribute12
 		,attribute13
 		,attribute14
 		,attribute15
 		,context
	        ,program_id
 		,program_application_id
 		,program_update_date
		,cs_repair_history_s.nextval
	FROM  cs_repair_history
       WHERE  repair_line_id = x_repair_line_id;

      END LOOP;

   ELSE

/*
Means split into 2 lines with user-defined quantities
First update the quantity in the existing record to first quantity
Insert a history record to indicate the split
*/

      UPDATE cs_repairs
	 SET quantity_received = x_first_quantity
	     where repair_line_id = X_repair_line_id;

      INSERT INTO cs_repair_history
		(
		 REPAIR_LINE_ID,
		 LAST_UPDATE_DATE,
		 LAST_UPDATED_BY,
		 CREATION_DATE,
		 CREATED_BY,
		 LAST_UPDATE_LOGIN,
		 REQUEST_ID,
		 TRANSACTION_DATE,
		 STATUS,
		 ATTRIBUTE1,
		 ATTRIBUTE2,
		 ATTRIBUTE3,
		 ATTRIBUTE4,
		 ATTRIBUTE5,
		 ATTRIBUTE6,
		 ATTRIBUTE7,
		 ATTRIBUTE8,
		 ATTRIBUTE9,
		 ATTRIBUTE10,
		 ATTRIBUTE11,
		 ATTRIBUTE12,
		 ATTRIBUTE13,
		 ATTRIBUTE14,
		 ATTRIBUTE15,
		 CONTEXT,
		 PROGRAM_ID,
		 PROGRAM_APPLICATION_ID,
		 PROGRAM_UPDATE_DATE,
		 REPAIR_HISTORY_ID
		)
      VALUES
		(
		x_repair_line_id
		,sysdate
		,x_user_id
 		,sysdate
 		,x_user_id
	 	,x_user_id
		,NULL
		,sysdate
 		,'SPLIT'
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
 		,NULL
		,cs_repair_history_s.nextval
	     	);

/* Insert a repair line with the total_quantity - first_quantity */

/*      dbms_output.put_line('New repair record'); */

	SELECT cs_repairs_s.nextval
	  INTO new_line_id
	  FROM dual;

	SELECT to_number(cs_repair_number_s.nextval)
	  INTO new_repair_number
	  FROM dual;

	INSERT INTO cs_repairs
		(
		repair_line_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
	 	request_id,
		program_id,
		program_application_id,
		program_update_date,
		rma_header_id,
		rma_line_id,
		estimate_id,
		wip_entity_id,
		repair_header_id,
		replace_header_id,
		loaner_header_id,
		customer_product_id,
		inventory_item_id,
		serial_number,
		quantity_received,
		quantity_scrapped,
		quantity_replaced,
		repair_unit_of_measure_code,
		status,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15,
		context,
		group_id,
		quantity_complete,
		org_id,
		organization_id,
		original_system_reference,
		original_system_line_reference,
		repair_order_line_id,
		repair_duration,
		received_date,
		shipped_date,
		rma_customer_id,
 		rma_number,
 		rma_type_id,
 		rma_date,
 		rma_line_number,
		recvd_organization_id,
		repair_number,
		mtl_transaction_id,
		allow_job,
		incident_id,
		estimate_business_group_id,
		diagnosis_id,
		diagnosed_by_id,
		job_completion_date,
		promised_delivery_date
		)
	SELECT	new_line_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
	 	request_id,
		program_id,
		program_application_id,
		program_update_date,
		rma_header_id,
		rma_line_id,
		estimate_id,
		wip_entity_id,
		repair_header_id,
		replace_header_id,
		loaner_header_id,
		customer_product_id,
		inventory_item_id,
		serial_number,
		(x_total_quantity - x_first_quantity),
		quantity_scrapped,
		quantity_replaced,
		repair_unit_of_measure_code,
		status,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15,
		context,
		group_id,
		quantity_complete,
		org_id,
		organization_id,
		original_system_reference,
		original_system_line_reference,
		repair_order_line_id,
		repair_duration,
		received_date,
		shipped_date,
		rma_customer_id,
 		rma_number,
 		rma_type_id,
 		rma_date,
 		rma_line_number,
		recvd_organization_id,
		new_repair_number,
		mtl_transaction_id,
		allow_job,
		incident_id,
		estimate_business_group_id,
		diagnosis_id,
		diagnosed_by_id,
		job_completion_date,
		promised_delivery_date
	 FROM	cs_repairs
	WHERE	repair_line_id = X_repair_line_id;

/* Insert history records for the new line */

      INSERT INTO cs_repair_history
		(
		 REPAIR_LINE_ID,
		 LAST_UPDATE_DATE,
		 LAST_UPDATED_BY,
		 CREATION_DATE,
		 CREATED_BY,
		 LAST_UPDATE_LOGIN,
		 REQUEST_ID,
		 TRANSACTION_DATE,
		 STATUS,
		 ATTRIBUTE1,
		 ATTRIBUTE2,
		 ATTRIBUTE3,
		 ATTRIBUTE4,
		 ATTRIBUTE5,
		 ATTRIBUTE6,
		 ATTRIBUTE7,
		 ATTRIBUTE8,
		 ATTRIBUTE9,
		 ATTRIBUTE10,
		 ATTRIBUTE11,
		 ATTRIBUTE12,
		 ATTRIBUTE13,
		 ATTRIBUTE14,
		 ATTRIBUTE15,
		 CONTEXT,
		 PROGRAM_ID,
		 PROGRAM_APPLICATION_ID,
		 PROGRAM_UPDATE_DATE,
		 REPAIR_HISTORY_ID
		)
      SELECT  	new_line_id
		,last_update_date
		,last_updated_by
 		,creation_date
 		,created_by
	 	,last_update_login
		,request_id
		,transaction_date
 		,status
 		,attribute1
 		,attribute2
 		,attribute3
 		,attribute4
 		,attribute5
 		,attribute6
 		,attribute7
 		,attribute8
 		,attribute9
 		,attribute10
 		,attribute11
 		,attribute12
 		,attribute13
 		,attribute14
 		,attribute15
 		,context
	        ,program_id
 		,program_application_id
 		,program_update_date
		,cs_repair_history_s.nextval
	FROM  cs_repair_history
       WHERE  repair_line_id = x_repair_line_id;

  END IF;

  commit;

  END;

END CS_SPLIT_REPAIRS;

/
