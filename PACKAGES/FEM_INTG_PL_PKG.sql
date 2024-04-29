--------------------------------------------------------
--  DDL for Package FEM_INTG_PL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_INTG_PL_PKG" AUTHID CURRENT_USER as
/* $Header: fem_intg_pl.pls 120.0 2005/06/06 19:47:56 appldev noship $ */
--
-- Package
--   fem_intg_pl_pkg
-- Purpose
--   Process locking wrapper procedures for OGL-FEM integration
-- History
--   27-SEP-04  M Ward          Created
--

  --
  -- Function
  --   obj_def_data_edit_lock_exists
  -- Purpose
  --   Check whether an edit lock exists on an object definition
  -- Arguments
  --   p_object_definition_id	Object definition to check
  -- Return Value
  --   'T' if a lock exists, and 'F' if there is no lock
  -- Example
  --   FEM_INTG_PL_PKG.obj_def_data_edit_lock_exists(
  --     p_object_definition_id => 100)
  -- Notes
  --
  FUNCTION Obj_Def_Data_Edit_Lock_Exists(p_object_definition_id NUMBER)
  RETURN VARCHAR2;

  --
  -- Function
  --   Can_Delete_Object_Def
  -- Purpose
  --   Check whether an object definition can be deleted
  -- Arguments
  --   p_object_definition_id	Object definition to check
  -- Return Value
  --   'T' if it can be deleted, and 'F' if it cannot be deleted
  -- Example
  --   FEM_INTG_PL_PKG.Can_Delete_Object_Def(
  --     p_object_definition_id => 100)
  -- Notes
  --
  FUNCTION Can_Delete_Object_Def(p_object_definition_id NUMBER)
  RETURN VARCHAR2;

  --
  -- Function
  --   Dimension_Rules_Have_Been_Run
  -- Purpose
  --   Check whether all dimension rules for the chart of accounts
  --   have been run successfully
  -- Arguments
  --   p_chart_of_accounts_id	The chart of accounts to check
  -- Return Value
  --   'T' if a the rules have all been run successfully, and 'F' otherwise
  -- Example
  --   FEM_INTG_PL_PKG.Dimension_Rules_Have_Been_Run(
  --     p_chart_of_accounts_id => 101)
  -- Notes
  --
  FUNCTION Dimension_Rules_Have_Been_Run(p_chart_of_accounts_id NUMBER)
  RETURN VARCHAR2;

  --
  -- Function
  --   Effective_Date_Incl_Rslt_Data
  -- Purpose
  --   Check whether the effective dates given cover the range of all
  --   runs by this object definition
  -- Arguments
  --   p_object_definition_id		Object definition to check
  --   p_new_effective_start_date	New start date
  --   p_new_effective_end_date		New end date
  -- Return Value
  --   'T' if all runs are included, and 'F' otherwise
  -- Example
  --   FEM_INTG_PL_PKG.Effective_Date_Incl_Rslt_Data(
  --     p_object_definition_id => 100,
  --     p_new_effective_start_date => sysdate-1,
  --     p_new_effective_end_date => sysdate+1)
  -- Notes
  --
  FUNCTION Effective_Date_Incl_Rslt_Data(
	p_object_definition_id		NUMBER,
	p_new_effective_start_date	DATE,
	p_new_effective_end_date	DATE)
  RETURN VARCHAR2;


  --
  -- Procedure
  --   Register_Process_Execution
  -- Purpose
  --   Registers the concurrent request and all processing parameters into
  ---  the FEM Process Logging architecture
  -- Arguments
  --   p_obj_id		  Object id
  --   p_obj_def_id       Object definition id
  --   p_req_id           Request id
  --   p_user_id          User id
  --   p_login_id         Login id
  --   p_pgm_id           Program id
  --   p_pgm_app_id       Program application id
  --   p_module_name      Module name
  --   p_hierarchy_name   Hierarchy name
  --   x_completion_code  Completion code
  -- Example
  --   Register_Process_Execution(
  --     p_obj_id => 1,
  --     p_obj_def_id => 10,
  --     p_req_id => 100,
  --     p_user_id => 1000,
  --     p_login_id => 200,
  --     p_pgm_id => 120,
  --     p_pgm_app_id => 274
  --     p_module_name => 'abc',
  --     p_hierarchy_name => 'abc',
  --     x_completion_code => v_completion_code
  --  );
  -- Notes
  --
  PROCEDURE Register_Process_Execution(
    p_obj_id IN NUMBER,
    p_obj_def_id IN NUMBER,
    p_req_id IN NUMBER,
    p_user_id IN NUMBER,
    p_login_id IN NUMBER,
    p_pgm_id IN NUMBER,
    p_pgm_app_id IN NUMBER,
    p_module_name IN VARCHAR2,
    p_hierarchy_name IN VARCHAR2 DEFAULT NULL,
    x_completion_code OUT NOCOPY NUMBER
  );


  --
  -- Procedure
  --   Final_Process_Logging
  -- Purpose
  --   Performs all required post-execution process logging operations
  -- Arguments
  --   p_obj_id		  Object id
  --   p_obj_def_id       Object definition id
  --   p_req_id           Request id
  --   p_user_id          User id
  --   p_login_id         Login id
  --   p_exec_status      Execution status
  --   p_row_num_loaded   Number of rows loaded
  --   p_err_num_count    Number of errors encountered
  --   p_final_msg_name   Final message name
  --   p_module_name      Module name
  --   x_completion_code  Completion code
  -- Example
  --   Final_Process_Logging(
  --     p_obj_id => 1,
  --     p_obj_def_id => 10,
  --     p_req_id => 100,
  --     p_user_id => 1000,
  --     p_login_id => 200,
  --     p_exec_status => 'SUCCESS'
  --     p_row_num_loaded => 100000,
  --     p_err_num_count => 0,
  --     p_final_msg_name => 'Final Message',
  --     p_module_name => 'abc',
  --     x_completion_code => v_completion_code
  --  );
  -- Notes
  --
  PROCEDURE Final_Process_Logging(
    p_obj_id IN NUMBER,
    p_obj_def_id IN NUMBER,
    p_req_id IN NUMBER,
    p_user_id IN NUMBER,
    p_login_id IN NUMBER,
    p_exec_status IN VARCHAR2,
    p_row_num_loaded IN NUMBER,
    p_err_num_count IN NUMBER,
    p_final_msg_name IN VARCHAR2,
    p_module_name IN VARCHAR2,
    x_completion_code OUT NOCOPY NUMBER
  );

END FEM_INTG_PL_PKG;

 

/
