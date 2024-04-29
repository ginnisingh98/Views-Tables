--------------------------------------------------------
--  DDL for Package PA_AUTOALLOC_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_AUTOALLOC_WF_PKG" AUTHID CURRENT_USER AS
/*  $Header: PAXWFALS.pls 120.2 2006/05/31 23:00:48 skannoji noship $  */

  --    Public variables
  PA_item_type               Varchar2(10) := 'PASDALOC';
  PA_item_key                Varchar2(40) ;
  G_FILE                     Varchar2(255)     := null;
  G_DIR                      Varchar2(255)  ;
  G_FILE_PTR                 utl_file.file_type;
  G_err_name                 Varchar2(30);
  G_err_msg                  Varchar2(2000);
  G_err_stack                Varchar2(32000);
  G_Err_Stage		     Varchar2(200);
-------------------------------------------------------------------------------
  -- Procedure
  -- Launch_PA_WF
  -- Purpose
  -- Called from GL Workflow
  -- It launches PA workflow.It creates PA Step Down Allocation Process
  -- and starts it.
  -- Arguments
  --   standard work-flow activity arguments.

PROCEDURE Launch_PA_WF ( p_item_type	IN 	VARCHAR2,
                         p_item_key	IN 	VARCHAR2,
                         p_actid	IN 	NUMBER,
                         p_funcmode	IN 	VARCHAR2,
                         p_result	OUT NOCOPY 	VARCHAR2);

-------------------------------------------------------------------------------
  -- Procedure
  -- 	initialize_pa_wf
  -- Arguments
  --  	Nil
  -- Purpose
  --  	Called from Launch_PA_WF
  --  	Initilize all work flow item attributes

PROCEDURE initialize_pa_wf;

-------------------------------------------------------------------------------

  -- Procedure
  --    Initialize_Debug
  -- Arguments
  --    None
  -- Purpose
  --    Called from  Workflow activity
  --    Determines what is the batch type of the step

PROCEDURE initialize_debug;

-------------------------------------------------------------------------------

  -- Procedure
  -- 	WriteDebugMsg
  -- Arguments
  --    debug_message
  -- Purpose
  --  	Called from most of the procedures/functions in this package
  --  	Writes debug Msg to the log file if Debug Flag is on

Procedure WriteDebugMsg(debug_message in Varchar2);

--------------------------------------------------------------------------------

  -- Procedure
  -- 	Get_Status_And_Message
  -- Arguments
  --    conc_prog_code: Code of the Concurrent Program
  --	ptype: context type like PENDING,COMPLETE,ERROR,RUNNING,EXCEPTION etc.
  --	rollback_allowed: Flag indicates rollback is allowed or not
  --	status_code: set status code like ALPC (Allocation Process is complete)
  --			to update GL_AUTO_ALLOC_BATCH_HISTORY
  --	message_name: set message name defined in workflow. This message will
  --			be attached to notification
  -- Purpose
  --  	Called from most of the procedures/functions in this package
  --  	Writes debug Msg to the log file if Debug Flag is on

Procedure Get_Status_and_Message(
          p_conc_prg_code    IN  Varchar2
         ,p_ptype            IN  Varchar2
         ,p_rollback_allowed IN Varchar2
         ,x_status_code      OUT NOCOPY Varchar2
         ,x_message_name     OUT NOCOPY Varchar2 );
-------------------------------------------------------------------------------
/** This function submits a concurrent request and returns the request id **/

Function  Submit_Conc_Process(
         p_prog_code	IN 	VARCHAR2
         ,p_arg1	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg2	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg3	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg4	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg5	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg6	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg7	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg8	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg9	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg10	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg11	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg12	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg13	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg14	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg15	IN 	VARCHAR2 DEFAULT NULL)

Return Number;

-------------------------------------------------------------------------------

/** This function submits Concurrent Process to generate Project Allocation Transactions.This is called from PA Step down Allocation Work Flow **/

PROCEDURE Submit_Alloc_Process(	p_item_type	IN	VARCHAR2,
                         	p_item_key	IN 	VARCHAR2,
                         	p_actid		IN 	NUMBER,
                         	p_funcmode	IN 	VARCHAR2,
                         	p_result	OUT NOCOPY 	VARCHAR2);

--------------------------------------------------------------------------------

/** This function submits Concurrent Process to release Project Allocation Transactions.This is called from PA Step down Allocation Work Flow **/

PROCEDURE Submit_Conc_AllocRls(	p_item_type	IN	VARCHAR2,
                         	p_item_key	IN 	VARCHAR2,
                         	p_actid		IN 	NUMBER,
                         	p_funcmode	IN 	VARCHAR2,
                         	p_result	OUT NOCOPY 	VARCHAR2) ;

-------------------------------------------------------------------------------

/** This function submits Concurrent Process to Distribute Cost.This is called from PA Step down Allocation Work Flow **/

PROCEDURE Submit_Conc_Process_Dist(	p_item_type	IN	VARCHAR2,
                         		p_item_key	IN 	VARCHAR2,
                         		p_actid		IN 	NUMBER,
                         		p_funcmode	IN 	VARCHAR2,
                         		p_result	OUT NOCOPY 	VARCHAR2);

-------------------------------------------------------------------------------

/** This function submits Concurrent Process to Update Project Summary Amounts.This is called from PA Step down Allocation Work Flow **/

PROCEDURE Submit_Conc_Sum(	p_item_type	IN	VARCHAR2,
                         	p_item_key	IN 	VARCHAR2,
                         	p_actid		IN 	NUMBER,
                         	p_funcmode	IN 	VARCHAR2,
                         	p_result	OUT NOCOPY 	VARCHAR2);

-------------------------------------------------------------------------------
/** This function calls an API for Allocation Run Reversal.This is part of Rollback Process. This is called from PA Step down Allocation Work Flow **/

PROCEDURE Submit_Conc_AllocRev(	p_item_type	IN	VARCHAR2,
                         	p_item_key	IN 	VARCHAR2,
                         	p_actid		IN 	NUMBER,
                         	p_funcmode	IN 	VARCHAR2,
                         	p_result	OUT NOCOPY 	VARCHAR2);

-------------------------------------------------------------------------------
/** This proc checks if all the expenditure groups i.e. target and offset expenditure groups have been costed or not **/

PROCEDURE Check_Exp_Groups(		p_item_type	IN	VARCHAR2,
                         		p_item_key	IN 	VARCHAR2,
                         		p_actid		IN 	NUMBER,
                         		p_funcmode	IN 	VARCHAR2,
                         		p_result	OUT NOCOPY 	VARCHAR2);

-------------------------------------------------------------------------------

/** This is the function for checking the completion status of the concurrent process **/
Procedure Check_Process_Status(	p_item_type	IN 	VARCHAR2,
                         	p_item_key	IN 	VARCHAR2,
                         	p_actid		IN 	NUMBER,
                       		p_funcmode	IN 	VARCHAR2,
                         	p_result	OUT NOCOPY 	VARCHAR2);

-------------------------------------------------------------------------------
/** This is the function for checking the exceptions in the allocation run process **/

Procedure Check_Alloc_Run_Status(	p_item_type	IN 	VARCHAR2,
                         		p_item_key	IN 	VARCHAR2,
                         		p_actid		IN 	NUMBER,
                       			p_funcmode	IN 	VARCHAR2,
                         		p_result	OUT NOCOPY 	VARCHAR2);

-------------------------------------------------------------------------------
/** This procedure checks if allocation run is released or not.**/

PROCEDURE Check_Alloc_Release(	p_item_type	IN	VARCHAR2,
                         	p_item_key	IN 	VARCHAR2,
                         	p_actid		IN 	NUMBER,
                         	p_funcmode	IN 	VARCHAR2,
                         	p_result	OUT NOCOPY 	VARCHAR2);

-------------------------------------------------------------------------------

/** This is the function for checking the exceptions in the distribute cost process **/

Procedure Check_Costing_Process(	p_item_type	IN 	VARCHAR2,
                         		p_item_key	IN 	VARCHAR2,
                         		p_actid		IN 	NUMBER,
                       			p_funcmode	IN 	VARCHAR2,
                         		p_result	OUT NOCOPY 	VARCHAR2);

-------------------------------------------------------------------------------

/** This is the function for checking the exceptions in the Summarization process **/

Procedure Check_Summary_Process(	p_item_type	IN 	VARCHAR2,
                         		p_item_key	IN 	VARCHAR2,
                         		p_actid		IN 	NUMBER,
                       			p_funcmode	IN 	VARCHAR2,
                         		p_result	OUT NOCOPY 	VARCHAR2);

-------------------------------------------------------------------------------
/*** This function checks if the request submitted for summarization
     has any exceptions. Returns 'FAIL' if an exception occured,
     'PASS' otherwise ***/

Function Check_Summarization_Status( p_request_id	IN	Number)
Return Varchar2;

-------------------------------------------------------------------------------
/** This procedure deletes an allocation run given a rule_id and run_id**/

Procedure Delete_Alloc_Run(	p_item_type 	IN 	VARCHAR2,
                         	p_item_key	IN 	VARCHAR2,
                         	p_actid		IN 	NUMBER,
                       		p_funcmode	IN 	VARCHAR2,
                         	p_result	OUT NOCOPY 	VARCHAR2);

-------------------------------------------------------------------------------

/**This procedure sets a GL attribute value based on the result of PA Step Down
   Allocation Process and issues a complete activity for the block. **/

PROCEDURE Set_PA_WF_Status(	p_item_type	IN	VARCHAR2,
                         	p_item_key	IN 	VARCHAR2,
                         	p_actid		IN 	NUMBER,
                         	p_funcmode	IN 	VARCHAR2,
                         	p_result	OUT NOCOPY 	VARCHAR2);

-------------------------------------------------------------------------------

/* This procedure initializes WF_STACK with the argument passed
   to it */
Procedure 	Init_PA_WF_STACK (p_item_type	In 	Varchar2,
				  p_item_key	In	Varchar2,
				  p_err_stack	In	Varchar2);

-------------------------------------------------------------------------------

/* This procedure sets WF_STACK attribute with an argument */

Procedure 	Set_PA_WF_STACK (p_item_type	In 	Varchar2,
				 p_item_key	In	Varchar2,
				 p_err_stack	In	Varchar2);

------------------------------------------------------------------------------

/* This procedure resets WF_STACK attribute.It just removes last string from the   stack  */
Procedure 	Reset_PA_WF_STACK (p_item_type	In 	Varchar2,
				   p_item_key	In	Varchar2);

-------------------------------------------------------------------------------

/* Set the WF_STAGE attribute with an argument */
Procedure 	Set_PA_WF_Stage (p_item_type	In 	Varchar2,
				 p_item_key	In	Varchar2,
				 p_err_stage	In	Varchar2);

-------------------------------------------------------------------------------

Function DebugFlag
Return Boolean;
-------------------------------------------------------------------------------

-- Created this function for bug 5218394. This function will reterieve the debug
-- directory location using utl_log_dir
-------------------------------------------------------------------------------

Function GetDebugLogDir
Return Varchar2;
-------------------------------------------------------------------------------
END PA_AUTOALLOC_WF_PKG;

 

/
