--------------------------------------------------------
--  DDL for Package XDP_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: XDPUTILS.pls 120.1 2005/06/16 02:44:42 appldev  $ */


G_MESSAGE_LIST XDP_TYPES.VARCHAR2_32767_TAB;
G_CLOB         CLOB;
g_fp_object_type VARCHAR2(5) := 'FP';
g_fa_object_type VARCHAR2(5) := 'FA';
g_wi_object_type VARCHAR2(5) := 'WI';
g_service_object_type VARCHAR2(10) := 'SERVICE';

g_wait_for_resource VARCHAR2(40) := 'WAIT_FOR_RESOURCE';
g_system_hold VARCHAR2(40) := 'SYSTEM_HOLD';

  pv_DefErrNotifProfile varchar2(30) := 'XDP_SYS_ERR_RECIPIENT';
  pv_DefErrNotifRecipient varchar2(30) := 'FND_RESP535:21704';

  pv_ErrorNotifItemType varchar2(8) 		:= 'XDPWFSTD';

 -- Call any SFM Workitem Parameter evaluation procedure
 --
 -- the user defined WI parameter evaluation procedure should use
 -- the following spec:
 -- procedure <name of the proc>(
 --      p_order_id 	IN NUMBER,
 --      p_line_item_id 	IN NUMBER,
 --      p_wi_instance_id 	IN NUMBER,
 -- 	   p_param_val		IN Varchar2,
 --      p_param_ref_val	IN Varchar2,
 --      p_param_eval_val	OUT NOCOPY VARCHAR2,
 --      p_param_eval_ref_val OUT NOCOPY Varchar2,
 --	   p_return_code	OUT NOCOPY NUMBER,
 --	   p_error_description  OUT NOCOPY VARCHAR2)
 --
  PROCEDURE CallWIParamEvalProc(
	p_procedure_name  IN Varchar2,
	p_order_id		IN NUMBER,
	p_line_item_id		IN NUMBER,
       	p_wi_instance_id 	IN NUMBER,
  	p_param_val		IN Varchar2,
       	p_param_ref_val	IN Varchar2,
       	p_param_eval_val	OUT NOCOPY VARCHAR2,
       	p_param_eval_ref_val OUT NOCOPY Varchar2,
 	p_return_code	OUT NOCOPY NUMBER,
 	p_error_description  OUT NOCOPY VARCHAR2);

 -- Call any SFM FA Parameter evaluation procedure
 --
 -- the user defined FA parameter evaluation procedure should use
 -- the following spec:
 -- procedure <name of the proc>(
 --      p_order_id 		IN NUMBER,
 --      p_line_item_id 	IN NUMBER,
 --      p_wi_instance_id 	IN NUMBER,
 --      p_fa_instance_id 	IN NUMBER,
 -- 	   p_param_val		IN Varchar2,
 --      p_param_ref_val	IN Varchar2,
 --      p_param_eval_val	OUT NOCOPY VARCHAR2,
 --      p_param_eval_ref_val OUT NOCOPY Varchar2,
 --	   p_return_code	OUT NOCOPY NUMBER,
 --	   p_error_description  OUT NOCOPY VARCHAR2)
 --
  PROCEDURE CallFAParamEvalProc(
	p_procedure_name IN Varchar2,
	p_order_id		IN NUMBER,
	p_line_item_id		IN NUMBER,
    p_wi_instance_id 	IN NUMBER,
    p_fa_instance_id 	IN NUMBER,
  	p_param_val		IN Varchar2,
    p_param_ref_val	IN Varchar2,
    p_param_eval_val	OUT NOCOPY VARCHAR2,
    p_param_eval_ref_val OUT NOCOPY Varchar2,
 	p_return_code	OUT NOCOPY NUMBER,
 	p_error_description  OUT NOCOPY VARCHAR2);

 -- Call any SFM FA evaluation procedure
 --
 -- the user defined FA evaluation procedure will
 -- evaluate all the FA parameters when the FA instance
 -- is added to a workitem at runtime. The procedure should use
 -- the following spec:
 -- procedure <name of the proc>(
 --      p_order_id 		IN NUMBER,
 --      p_line_item_id 	IN NUMBER,
 --      p_wi_instance_id 	IN NUMBER,
 --      p_fa_instance_id 	IN NUMBER,
 --	   p_return_code	OUT NOCOPY NUMBER,
 --	   p_error_description  OUT NOCOPY VARCHAR2)
 --
  PROCEDURE CallFAEvalAllProc(
				p_procedure_name IN Varchar2,
				p_order_id		IN NUMBER,
				p_line_item_id		IN NUMBER,
       			p_wi_instance_id 	IN NUMBER,
       			p_fa_instance_id 	IN NUMBER,
 				p_return_code	OUT NOCOPY NUMBER,
 	     		p_error_description  OUT NOCOPY VARCHAR2);

 -- Call any SFM FE routing procedure
 --
 --   the user defined FE routing procedure is used by
 --   SFM to determine which FE to talk to for an FA at runtime
 --   base on the order information.  The procedure should use
 --   the following spec:
 --   procedure <name of the proc>(
 --	     p_order_id		IN NUMBER,
 --      p_line_item_id 	IN NUMBER,
 --        p_wi_instance_id 	IN NUMBER,
 --        p_fa_instance_id 	IN NUMBER,
 --	     p_fe_name 		OUT NOCOPY VARCHAR2,
 --	     p_return_code	OUT NOCOPY NUMBER,
 --	     p_error_description  OUT NOCOPY VARCHAR2)
 --

  PROCEDURE CallFERoutingProc(
			p_procedure_name  IN Varchar2,
 	     		p_order_id		IN NUMBER,
			p_line_item_id		IN NUMBER,
         		p_wi_instance_id 	IN NUMBER,
         		p_fa_instance_id 	IN NUMBER,
 	     		p_fe_name 		OUT NOCOPY VARCHAR2,
 			p_return_code	OUT NOCOPY NUMBER,
 	     		p_error_description  OUT NOCOPY VARCHAR2);

 -- Call any SFM NEM connect/disconnect procedure
 --
 --   the user defined NEM connect/disconnect procedure should use
 --   the following spec:
 --   procedure <name of the proc>(
 --        p_fe_name IN Varchar2,
 --	     p_channel_name	IN Varchar2,
 --	     p_return_code IN OUT NOCOPY NUMBER,
 --        p_error_description IN OUT NOCOPY VARCHAR2)
 --

  PROCEDURE Call_NEConnection_Proc(
				p_procedure_name IN Varchar2,
				p_fe_name IN Varchar2,
 				p_channel_name	IN Varchar2,
 				p_return_code OUT NOCOPY NUMBER,
 				p_error_description OUT NOCOPY VARCHAR2);


 -- Call any SFM FA fulfillment procedure
 --
 --  the user defined fulfillment procedure should use
 --  the following spec:
 --  procedure <name of the proc>(
 --         p_order_id IN NUMBER,
 --		p_line_item_id IN NUMBER,
 --         p_wi_instance_id IN NUMBER,
 --         p_fa_instance_id IN NUMBER,
 --	      p_channel_name	IN Varchar2,
 --		p_fe_name		IN VARCHAR2,
 --		p_fa_item_type IN VARCHAR2,
 --		p_fa_item_key  IN VARCHAR2,
 --         p_return_code OUT NOCOPY NUMBER,
 --         p_error_description OUT NOCOPY VARCHAR2)
 --

  PROCEDURE CallFulfillmentProc(
				p_procedure_name IN Varchar2,
          		p_order_id IN NUMBER,
				p_line_item_id IN NUMBER,
          		p_wi_instance_id IN NUMBER,
          		p_fa_instance_id IN NUMBER,
 	      		p_channel_name	IN Varchar2,
 				p_fe_name		IN VARCHAR2,
 				p_fa_item_type IN VARCHAR2,
 				p_fa_item_key  IN VARCHAR2,
          		p_return_code OUT NOCOPY NUMBER,
          		p_error_description OUT NOCOPY VARCHAR2);


 -- Call any SFM workitem FA dynamic mapping procedure
 --
 --  the user defined FA dynamic mapping procedure should use
 --  the following spec:
 --  procedure <name of the proc>(
 --         p_order_id IN NUMBER,
 --      p_line_item_id 	IN NUMBER,
 --         p_wi_instance_id IN NUMBER,
 --		p_return_code OUT NOCOPY NUMBER,
 --         p_error_description OUT NOCOPY VARCHAR2)
 --

  PROCEDURE CallFAMapProc(
				p_procedure_name IN Varchar2,
          		p_order_id IN NUMBER,
				p_line_item_id		IN NUMBER,
          		p_wi_instance_id IN NUMBER,
          		p_return_code OUT NOCOPY NUMBER,
          		p_error_description OUT NOCOPY VARCHAR2);

 --
 -- Call any SFM service action to workitem dynamic mapping procedure
 --
 --  the user defined WI dynamic mapping procedure should use
 --  the following spec:
 --  procedure <name of the proc>(
 --         p_order_id IN NUMBER,
 --         p_line_item_id IN NUMBER,
 --		p_return_code OUT NOCOPY NUMBER,
 --         p_error_description OUT NOCOPY VARCHAR2)
 --

  PROCEDURE CallWIMapProc(
				p_procedure_name IN Varchar2,
          			p_order_id IN NUMBER,
          			p_line_item_id IN NUMBER,
          			p_return_code OUT NOCOPY NUMBER,
          			p_error_description OUT NOCOPY VARCHAR2);

 --
 -- Call any SFM workitem user workflow start up procedure
 --  WI workflow startup procedure is used when the user wishes
 --  to use their own WI workflow to process the workitem.
 --  This procedure should create the workflow process and
 --  return the itemtype, itemkey, and process name to SFM.
 --  This procedure however, SHOULD NOT start the workflow process as
 --  it will be handled by SFM.
 --  The user defined WI workflow startup procedure should use
 --  the following spec:
 --  procedure <name of the proc>(
 --         p_order_id IN NUMBER,
 --      p_line_item_id 	IN NUMBER,
 --         p_wi_instance_id IN NUMBER,
 --     	p_wf_item_type OUT NOCOPY varchar2,
 --		p_wf_item_key  OUT NOCOPY varchar2,
 --		p_wf_process_name  OUT NOCOPY varchar2,
 --		p_reurn_code OUT NOCOPY NUMBER,
 --         p_error_description OUT NOCOPY VARCHAR2)
 --

  PROCEDURE CallWIWorkflowProc(
				p_procedure_name IN Varchar2,
          		p_order_id IN NUMBER,
				p_line_item_id		IN NUMBER,
          		p_wi_instance_id IN NUMBER,
				p_wf_item_type OUT NOCOPY varchar2,
				p_wf_item_key  OUT NOCOPY varchar2,
				p_wf_process_name  OUT NOCOPY varchar2,
          		p_return_code OUT NOCOPY NUMBER,
          		p_error_description OUT NOCOPY VARCHAR2);


 --
 --  Call any SFM DRC Task Result Procedure.
 --  DRC Task Result Procedure is used to construct the
 --  DRC task result string after SFM has perfromed a DRC
 --  task.  The user will use this procedure to examine
 --  all the workitems which had been executed by SFM for
 --  the given DRC task and return the result string accordingly.
 --  The DRC Task Result Procedure should use
 --  the following spec:
 --  procedure <name of the proc>(
 --         p_sdp_order_id IN NUMBER,
 --		p_task_result OUT NOCOPY varchar2,
 --		p_reurn_code OUT NOCOPY NUMBER,
 --         p_error_description OUT NOCOPY VARCHAR2)
 --

  PROCEDURE CallDRCTaskResultProc(
				p_procedure_name IN Varchar2,
          		p_sdp_order_id IN NUMBER,
				p_task_result OUT NOCOPY varchar2,
          		p_return_code OUT NOCOPY NUMBER,
          		p_error_description OUT NOCOPY VARCHAR2);



 --
 --  This procedure will insert a new row into sdp_proc_body table
 --
   PROCEDURE Create_New_Proc_Body(
				p_proc_name IN VARCHAR2,
				p_proc_type IN VARCHAR2 := 'CONNECT',
				p_proc_spec IN VARCHAR2,
				p_proc_body IN VARCHAR2,
				p_creation_date IN DATE,
				p_created_by IN NUMBER,
				p_last_update_date IN DATE,
				p_last_updated_by IN NUMBER,
				p_last_update_login IN NUMBER,
				return_code OUT NOCOPY NUMBER,
				error_description OUT NOCOPY VARCHAR2);
 --
 --  This procedure will update the sdp_proc_body table
 --
   PROCEDURE Update_Proc_Body(
				p_proc_name IN VARCHAR2,
				p_proc_type IN VARCHAR2 := 'CONNECT',
				p_proc_body IN VARCHAR2,
				p_last_update_date IN DATE,
				p_last_updated_by IN NUMBER,
				p_last_update_login IN NUMBER,
				return_code OUT NOCOPY NUMBER,
				error_description OUT NOCOPY VARCHAR2);

 -- A function to convert a clob to a varchar2 value
  FUNCTION Get_CLOB_Value(	p_proc_name IN VARCHAR2)
		RETURN VARCHAR2;

-- a procedure to execute any Query which returns a list of IDs
   PROCEDURE Execute_GetID_QUERY(
				p_query_block IN VARCHAR2,
          		p_id_list OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
				return_code OUT NOCOPY NUMBER,
				error_description OUT NOCOPY VARCHAR2);

--A procedure to create a package spec dynamically
--Param p_pkg_name:  the name of the package
--Param p_pkg_spec:  the ddl statement which creates the package spec
--Param p_application_short_name:  The short name of our apps,
--      should be XDP for OP
  PROCEDURE Create_PKG_Spec(
			p_pkg_name IN VARCHAR2,
			p_pkg_spec IN VARCHAR2,
			p_application_short_name IN VARCHAR2,
			x_return_code OUT NOCOPY NUMBER,
			x_error_string OUT NOCOPY VARCHAR2);

--A procedure to create or replace a package body dynamically
--Param p_pkg_name:  the name of the package
--Param p_pkg_body:  the ddl statement which creates the package body
--Param p_application_short_name:  The short name of our apps,
--      should be XDP for OP
  PROCEDURE Create_PKG_Body(
			p_pkg_name IN VARCHAR2,
			p_pkg_body IN VARCHAR2,
			p_application_short_name IN VARCHAR2,
			x_return_code OUT NOCOPY NUMBER,
			x_error_string OUT NOCOPY VARCHAR2);

  -- Generic parameter for a stored procedure or function
  TYPE t_Parameter IS RECORD (
    actual_type   VARCHAR2(8),  -- One of 'NUMBER', 'VARCHAR2', 'DATE', 'CHAR'
    actual_length INTEGER,
    name          VARCHAR2(50),
    num_param     NUMBER,
    vchar_param   VARCHAR2(500),
	char_param    CHAR(500),
    date_param    DATE);


  -- Generic parameter list
  TYPE t_ParameterList IS TABLE OF t_Parameter
    INDEX BY BINARY_INTEGER;

  -- Runs an arbitrary procedure.  All of the IN parameters in
  -- p_Parameters must have at least the _param and actual_type fields
  -- filled in, and all OUT parameters must have the actual_type field
  -- populated.  On output, the name field is populated.
  PROCEDURE RunProc(p_NumParams IN NUMBER,
                    p_ProcName IN VARCHAR2,
                    p_Parameters IN OUT NOCOPY t_ParameterList);

  -- Populates the internal data structures with description about the
  -- procedure given by p_ProcName.  If p_Print is TRUE, this information
  -- is output using DBMS_OUTPUT.
  PROCEDURE DescribeProc(p_ProcName IN VARCHAR2,
                         p_Print IN BOOLEAN);

  -- Displays, using DBMS_OUTPUT, the parameters in p_Parameters.
  PROCEDURE Printparams(p_Parameters IN t_ParameterList,
                        p_NumParams IN NUMBER);

 -- Quick workaround for form commit problem
  PROCEDURE DO_COMMIT;

 -- Quick workaround for form rollback problem
  PROCEDURE DO_ROLLBACK;

 -- get line item parameter values which is used by order analyzer
  FUNCTION OA_GetLineParam(
		p_line_item_id IN Number,
		p_line_param_name IN Varchar2)
	return Varchar2;
   pragma RESTRICT_REFERENCES(OA_GetLineParam, WNDS, WNPS);

 -- get workitem name which is used by order analyzer
  FUNCTION OA_GetWIName(
		p_wi_instance_id IN Number)
	return Varchar2;
   pragma RESTRICT_REFERENCES(OA_GetWIName, WNDS, WNPS);

 -- get Workitem parameter values which is used by order analyzer
  FUNCTION OA_GetWIParam(
		p_wi_instance_id IN Number,
		p_wi_param_name IN Varchar2)
	return Varchar2;
   pragma RESTRICT_REFERENCES(OA_GetWIParam, WNDS, WNPS);

 -- Check if the order line is a workitem
  FUNCTION OA_Get_LINE_WI_FLAG(
		p_line_item_id IN Number)
	return Varchar2;
   pragma RESTRICT_REFERENCES(OA_Get_LINE_WI_FLAG, WNDS, WNPS);


 -- These set of routines are used for the Name/Value parser provided by SFM

 type string_list_t is table of varchar2(32767) index by binary_integer;

 procedure split_lines(buffer in varchar2,string_list in OUT NOCOPY string_list_t ,split_str in varchar2);

 function get_key_name(buffer in varchar2,assign_str in varchar2 := '=' ) return varchar2;

 function get_key_value(buffer in varchar2,assign_str in varchar2 := '=' ) return varchar2;

 procedure Parse_String( buffer in varchar2,
                         NameValueList in OUT NOCOPY XDP_TYPES.NAME_VALUE_LIST,
                         assign_str in varchar2 := '=',
                         p_term_str in varchar2 := NULL);
  pragma restrict_references(get_key_name,WNDS);
  pragma restrict_references(get_key_value,WNDS);

 -- End of SFM Name/Value Parser related Functions

-- vrachur : 07/15/1999 - Added function to Validate names.
-- 			  Names should confirm to PL/SQL naming convention.

	FUNCTION IS_VALID_NAME( p_varname IN VARCHAR2 ) RETURN BOOLEAN ;
-- skilaru : 08/15/01  - wrapper for JDBC call.
	FUNCTION ISVALIDNAME( p_varname IN VARCHAR2 ) RETURN VARCHAR2 ;

--
--  This is the function which will mimic the workflow function
--  WF_STANDARD.WaitForFlow and handling the workflow concurrency
--  problem in WaitForFlow.  The caller should pass its current item type,
--  item key, and activity name to the API
--
Procedure WaitForFlow(
	p_item_type varchar2,
      p_item_key  varchar2,
      p_activity_name varchar2);

--
--  This is the function which will mimic the workflow function
--  WF_STANDARD.ContinueFlow and handling the workflow concurrency
--  problem in ContinueFlow.  The caller should pass its current item type
--  and item key to the API
--
Procedure ContinueFlow(
	p_item_type varchar2,
      p_item_key  varchar2);

-- An API to get the wf_role_name for notifications generated by workflow
-- The input parameter is the responsibity_key, i.e., OP_SYSADMIN, NP_SYSADMIN
-- The notification must be sent to the role name returned by this API
-- for FMC to retrieve it
Function Get_WF_NotifRecipient(p_responsibility_key in varchar2)
  return varchar2;

-- The API gets the Recipient of All System Error Notifications
Function GetSystemErrNotifRecipient return varchar2;

Procedure Display (
         p_OutputString in varchar2);

-- This procedure is used for compile pl/sql procedures stored in xdp tables
-- It should be run when instance is migrated to a different instance. After data
-- import/export, run this procedure to validate all the procedures configured in
-- the old instance.

-- This procedure will be the base of a concurrent program.

PROCEDURE RECOMPPKG
(
     ERRBUF	            	OUT NOCOPY	VARCHAR2,
     RETCODE	        	OUT NOCOPY	VARCHAR2
);


-- a procedure to execute a Query which returns a list of Order Ids for the passed parameter set

   PROCEDURE Get_XDP_OrderID_QUERY
   (
    P_ORDER_ID        IN VARCHAR2,
    P_ORDER_NUMBER    IN VARCHAR2,
    P_ORDER_VERSION   IN VARCHAR2,
    P_ORDER_REF_NAME  IN VARCHAR2,
    P_ORDER_REF_VALUE IN VARCHAR2,
    P_CUST_ID         IN VARCHAR2,
    P_CUST_NAME       IN VARCHAR2,
    P_PHONE_NUMBER    IN VARCHAR2,
    P_DUE_DATE        IN VARCHAR2,
    P_ACCOUNT_ID      IN VARCHAR2,
    P_QUERY_BLOCK     IN VARCHAR2,
    P_ID_LIST         OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
    RETURN_CODE       OUT NOCOPY NUMBER,
    ERROR_DESCRIPTION OUT NOCOPY VARCHAR2);


-- added procedure for error handling
-- SXBANERJ 07/05/2001

  -- Procedure to call after raising user defined exception
  PROCEDURE raise_exception(p_object_type IN VARCHAR2);

  -- Procedure to call in WHEN OTHERS
  PROCEDURE generic_error(p_object_type IN VARCHAR2
                         ,p_object_key  IN VARCHAR2
                         ,p_errcode     IN VARCHAR2
                         ,p_errmsg      IN VARCHAR2);

-- Procedure to write data/text to CLOB from table of records


 PROCEDURE WRITE_TABLE_TO_CLOB(p_source_table       IN XDP_TYPES.VARCHAR2_32767_TAB,
                               p_dest_clob      IN OUT NOCOPY CLOB,
                               x_error_code        OUT NOCOPY NUMBER,
                               x_error_description OUT NOCOPY VARCHAR2) ;

 PROCEDURE Initialize_pkg ;


 PROCEDURE Build_pkg(p_text IN VARCHAR2);

 PROCEDURE Create_pkg (p_pkg_name               IN VARCHAR2,
                       p_pkg_type               IN VARCHAR2,
                       p_application_short_name IN VARCHAR2,
                       x_error_code            OUT NOCOPY NUMBER,
                       x_error_message         OUT NOCOPY VARCHAR2) ;

 Procedure SET_TIME_OUT (itemtype        in varchar2,
                         itemkey         in varchar2,
                         actid           in number,
                         funcmode        in varchar2,
                         resultout       OUT NOCOPY varchar2);

Procedure GET_FA_RESPONSE_LOB_CONTENT ( p_FAInstanceID VARCHAR2,
                                        p_FECmdSequence VARCHAR2,
                                        p_clob_content OUT NOCOPY VARCHAR2 );

PROCEDURE SET_FP_RETRY_COUNT (itemtype  IN VARCHAR2,
                              itemkey   IN VARCHAR2,
                              actid     IN NUMBER,
                              funcmode  IN VARCHAR2,
                              resultout OUT NOCOPY VARCHAR2 );

Function GET_ASCII_TEXT( p_raw_string IN VARCHAR2 ) return VARCHAR2;
END XDP_UTILITIES;

 

/
