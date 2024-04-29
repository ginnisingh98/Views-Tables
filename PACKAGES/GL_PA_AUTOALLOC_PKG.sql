--------------------------------------------------------
--  DDL for Package GL_PA_AUTOALLOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_PA_AUTOALLOC_PKG" AUTHID CURRENT_USER AS
/*  $Header: glalprjs.pls 120.2 2002/11/11 23:53:35 djogg ship $  */

  --
  -- Function
  --   get_period_type
  -- Purpose
  --  Given a set id it determines if Project Allocation Rules use GL period or
  --  PA period. If all the rules use PA Period type then return 'P' similarly if
  --  all the rules use GL Period Type then return 'G'- if both types exist return
  --  'B' - if the set does not have any Project Allocation Rules return 'N'
  -- Arguments
  --   allocation_set_id
  -- Example
  --   period_req := GL_PA_AUTOALLOC_PKG.get_period_type(id);


Function 	get_period_type ( p_allocation_set_id In Number	)
Return Varchar2;
PRAGMA RESTRICT_REFERENCES (Get_Period_Type,WNDS,WNPS);

  --
  -- Function
  --   Valid_Run_Period
  -- Purpose
  --  This function calls Get_Period_Type to determine which run period (pa/gl)
  --  value is required. It further checks if that period is not null.
  --  TRUE on success, FALSE on failure.
  -- Arguments
  --   allocation_set_id, pa_period, gl_period
  -- Example
  --  is_period_valid := GL_PA_AUTOALLOC_PKG.Valid_Run_Period(id,pa_period,gl_period);


Function valid_run_period ( p_allocation_set_id	In 	Number,
			    p_pa_period 		In	 Varchar2
							Default  Null,
		            p_gl_period 		In	 Varchar2
							Default  Null)
Return Boolean;

PRAGMA RESTRICT_REFERENCES (Valid_Run_Period,WNDS,WNPS);

  --
  -- Function
  --   submit_alloc_request
  -- Purpose
  --  function does two things
  --  1.Identify which period to be passed as parameter to a process.
  --  2. Submits the Generate Allocation Transactions Request.
  --  Return Value: Request Id of submitted request
  -- Arguments
  --  p_rule_id,p_expnd_item_date,p_pa_period,p_gl_period

Function  submit_alloc_request(
                       p_rule_id          In    Number,
  		       p_expnd_item_date  In	Date,
		       p_pa_period	  In	Varchar2,
		       p_gl_period	  In	Varchar2
				     )
Return Number;

  --
  -- Procedure
  --   get_pa_step_status
  -- Purpose
  --  For a given request_id and step number it returns the step status .
  --  p_mode = 'S' for step-down otherwise its parallel
  --  This is only for a project step in the auto allocation.
  -- Arguments
  --   request_id, step_number, mode
  --  Returns  run status of a project step in the auto allocation

Procedure get_pa_step_status (
                      p_request_Id        In   Number
                     ,p_step_number       In   Number
                     ,p_mode              In   Varchar2
                     ,p_status            Out NOCOPY  Varchar2);


  --
  -- Procedure
  --   upd_gl_auto_alloc_batch_history
  -- Purpose
  --  For a given request_id and step number , it update the PA_ALLOCATION_RUN_ID
  --  with p_pa_allocation_run_id
  --
  -- Arguments
  --   request_id, step_number, pa_allocation_run_id
  --  Returns -1 if record is not found else returns 0

Procedure upd_gl_autoalloc_batch_hist(
                     p_request_Id             In  Number
                    ,p_step_number            In  Number
                    ,p_pa_allocation_run_id   In  Number
                    ,p_return_code            Out NOCOPY Number );

End gl_pa_autoalloc_pkg;

 

/
