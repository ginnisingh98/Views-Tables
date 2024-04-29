--------------------------------------------------------
--  DDL for Package CNDIHY_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CNDIHY_HIERARCHY_PKG" AUTHID CURRENT_USER as
-- $Header: cndihyas.pls 115.1 99/07/16 07:06:20 porting ship $


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE Default_Row 	(X_hierarchy_id 	IN OUT	number);
  PROCEDURE Default_Period_Row  (X_hierarchy_id 	IN OUT	number);


  PROCEDURE Populate_Period_Fields (X_start_period		number,
				    X_start_name   IN OUT	varchar2,
				    X_end_period		number,
				    X_end_name	   IN OUT	varchar2);
  --
  -- Procedure Name
  --   populate_fields
  -- History
  --   12/28/93		Tony Lower		Created
  --
  PROCEDURE Populate_Fields (X_dimension_id		number,
			     X_hierarchy_id		number,
			     X_select_clause	IN OUT	varchar2);


  --
  -- Procedure Name
  --   populate_fields
  -- History
  --   06/01/94		Tony Lower		Created
  --
  PROCEDURE Populate_Value_Fields (X_value_id		number,
				   X_dim_hierarchy_id	number,
 				   X_name	IN OUT	varchar2);

  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE Root_Node ( X_hierarchy_id			number,
			X_value_id		IN OUT	number);


  --
  -- Procedure Name
  --   Synchronize_Node
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE Synchronize_Node (  X_value_id		IN OUT	number,
				X_name				varchar2,
				X_dim_hierarchy_id		number);


  --
  -- Procedure Name
  --   Synchronize_Node
  -- History
  --   06/02/94		Tony Lower		Created
  --
  PROCEDURE Shift_Parent( X_parent_value_id		number,
			  X_dim_hierarchy_id		number,
			  X_central_root_node		number,
			  X_central_value_id	IN OUT	number,
			  X_central_parent_id	IN OUT	number);

  --
  -- Procedure Name
  --   Cascade_Number
  -- History
  --   7/19/93		Tony Lower		Created
  --
  PROCEDURE Cascade_Number(X_value_id		   number,
			   X_dim_hierarchy_id	   number,
			   X_cascade_number IN OUT number);

  --
  -- Procedure Name
  --   Cascade_Delete
  -- History
  --   7/19/93		Tony Lower		Created
  --
  PROCEDURE Cascade_Delete(X_value_id		   number,
			   X_parent_value_id	   number,
			   X_dim_hierarchy_id	   number);

  --
  -- Procedure Name
  --   Insert_Row
  -- History
  --   7/19/93		Tony Lower		Created
  --
  PROCEDURE Insert_Row(X_value_id		   number,
		       X_parent_Value_id	   number,
		       X_dim_hierarchy_id	   number);

  --
  -- Procedure Name
  --   Insert_Root
  -- History
  --   7/25/93		Tony Lower		Created
  --
  PROCEDURE Insert_Root(X_value_id		   number,
		        X_dim_hierarchy_id	   number);

  --
  -- Procedure Name
  --   Fetch_Row_counts
  -- History
  --   7/25/93		Tony Lower		Created
  --
  PROCEDURE Fetch_Row_Counts (X_parent_value_id		number,
			      X_value_id		number,
			      X_dim_hierarchy_id	number,
			      X_parent_rows	 IN OUT number,
			      X_child_rows	 IN OUT number);

  --
  -- Procedure Name
  --   Fetch_Row_counts
  -- History
  --   7/26/93		Tony Lower		Created
  --
  PROCEDURE Create_Dummy_Node (X_value_id	IN OUT number,
			       X_name		       varchar2,
			       X_dim_hierarchy_id      number);

END CNDIHY_Hierarchy_PKG;

 

/
