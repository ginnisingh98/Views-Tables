--------------------------------------------------------
--  DDL for Package MSC_UNDO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_UNDO" AUTHID CURRENT_USER AS
/* $Header: MSCUNDOS.pls 115.4 2002/12/02 18:10:43 eychen ship $ */


  --Action passed from form.
  inserted constant number := 1;
  updated constant number := 2;
  bookmark constant number := 3;
  start_online constant number := 4;
  replan_start constant number := 5;
  replan_stop constant number := 6;
  stop_online constant number := 7;

  TYPE UndoTblType_type IS RECORD
  (
	undo_id NUMBER,
	action NUMBER,
	table_changed NUMBER,
	plan_id NUMBER,
	sr_instance_id NUMBER,
	transaction_id NUMBER,
        last_update_date DATE
  );

  TYPE UndoTblType IS TABLE OF UndoTblType_type INDEX BY BINARY_INTEGER;
  --to contain undo_summary to insert into undo_summary table.


  TYPE ChangeRGType_type IS RECORD
  (
    Column_changed VARCHAR2(30),
    Column_changed_text VARCHAR2(240),
    Old_Value      VARCHAR2(240),
    Column_Type VARCHAR2(10),
    New_Value      VARCHAR2(240)
  );

  TYPE ChangeRGType IS TABLE OF ChangeRgType_type INDEX BY BINARY_INTEGER;
  --to contain undo_details to insert into undo_details table


  TYPE UndoIdTblType_type IS RECORD
  (
	undo_id NUMBER
  );

  TYPE UndoIdTblType IS TABLE OF UndoIdTblType_type INDEX BY BINARY_INTEGER;
  --to contain undo_ids for undo

  procedure UNDO (undoID undoIdTblType,
		x_return_status OUT NOCOPY VARCHAR2,
		x_msg_count OUT NOCOPY NUMBER,
		x_msg_data OUT NOCOPY VARCHAR2);

  procedure STORE_UNDO (table_changed NUMBER,
		action NUMBER,
		transaction_id NUMBER,
		plan_id NUMBER,
		sr_instance_id NUMBER,
		parent_id NUMBER,
		changed_values MSC_UNDO.ChangeRGType,
		x_return_status OUT NOCOPY VARCHAR2,
		x_msg_count OUT NOCOPY NUMBER,
		x_msg_data OUT NOCOPY VARCHAR2,
		undo_id NUMBER DEFAULT NULL);

  procedure ADD_BOOKMARK(bookmark_name VARCHAR2,
		action NUMBER,
		plan_id NUMBER,
		x_return_status OUT NOCOPY VARCHAR2,
		x_msg_count OUT NOCOPY NUMBER,
		x_msg_data OUT NOCOPY VARCHAR2);


--Private procedures

  v_user_id NUMBER ;
  v_last_update_login NUMBER;

  procedure set_Vars;  -- to set the who cols

 function undo_validate(v_undo_id number,
			x_return_status out NOCOPY VARCHAR2,
			x_msg_count OUT NOCOPY NUMBER,
			x_msg_data OUT NOCOPY VARCHAR2) return number;

  PROCEDURE update_table(p_table_changed NUMBER,
			p_column_changed VARCHAR2,
			p_old_value VARCHAR2,
			p_new_value VARCHAR2,
			p_column_type VARCHAR2,
			p_plan_id NUMBER,
			p_sr_instance_id NUMBER,
			p_transaction_id NUMBER,
			x_return_status OUT NOCOPY VARCHAR2,
			x_msg_count OUT NOCOPY NUMBER,
			x_msg_data OUT NOCOPY VARCHAR2,
			p_undo_id NUMBER);
  PROCEDURE insert_table (p_undo_id NUMBER,
			p_table_changed NUMBER,
			p_plan_id NUMBER,
			p_transaction_id NUMBER,
			p_sr_instance_id NUMBER,
			x_return_status OUT NOCOPY VARCHAR2,
			x_msg_count OUT NOCOPY NUMBER,
			x_msg_data OUT NOCOPY VARCHAR2);
END MSC_UNDO;

 

/
