--------------------------------------------------------
--  DDL for Package Body XDP_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_UTILITIES" AS
/* $Header: XDPUTILB.pls 120.1 2005/06/09 00:17:33 appldev  $ */

-- internal DBMS_DESCRIBE.DESCRIBE_PROCEDURE variables
  v_Overload     DBMS_DESCRIBE.NUMBER_TABLE;
  v_Position     DBMS_DESCRIBE.NUMBER_TABLE;
  v_Level        DBMS_DESCRIBE.NUMBER_TABLE;
  v_ArgumentName DBMS_DESCRIBE.VARCHAR2_TABLE;
  v_Datatype     DBMS_DESCRIBE.NUMBER_TABLE;
  v_DefaultValue DBMS_DESCRIBE.NUMBER_TABLE;
  v_InOut        DBMS_DESCRIBE.NUMBER_TABLE;
  v_Length       DBMS_DESCRIBE.NUMBER_TABLE;
  v_Precision    DBMS_DESCRIBE.NUMBER_TABLE;
  v_Scale        DBMS_DESCRIBE.NUMBER_TABLE;
  v_Radix        DBMS_DESCRIBE.NUMBER_TABLE;
  v_Spare        DBMS_DESCRIBE.NUMBER_TABLE;

 PROCEDURE DO_COMMIT IS
 -- PL/SQL Block
BEGIN
    COMMIT;
 END DO_COMMIT;

 PROCEDURE DO_ROLLBACK IS
 -- PL/SQL Block
BEGIN
    ROLLBACK;
 END DO_ROLLBACK;


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
 		p_error_description  OUT NOCOPY VARCHAR2)
  IS
     lv_plsql_blk varchar2(32000);
     l_message_params  varchar2(2000);
     l_wi_disp_name varchar2(100);
     e_wi_param_eval_failed exception;
  BEGIN

    p_return_code := 0;
    lv_plsql_blk := 'BEGIN  '||
		    p_procedure_name||
		    '( :order_id,
			:line_item_id,
			:wi_instance_id,
	 		:param_val,
			:param_ref_val,
			:param_eval_val,
			:param_eval_ref_val,
			:ret,
			:err_str); end;';
    execute immediate lv_plsql_blk
     USING p_order_id,
	   p_line_item_id,
	   p_wi_instance_id,
	   p_param_val,
	   p_param_ref_val,
	   OUT p_param_eval_val,
	   OUT p_param_eval_ref_val,
	   OUT p_return_code,
	   OUT p_error_description;
   IF p_return_code <> 0 THEN
       xdpcore.context( 'XDP_UTILITIES', 'CallWIParamEvalProc', 'WI', p_wi_instance_id, p_error_description );
   END IF;
  EXCEPTION
  WHEN OTHERS THEN
    xdpcore.context( 'XDP_UTILITIES', 'CallWIParamEvalProc', 'WI', p_wi_instance_id, SQLERRM);

    p_return_code := SQLCODE;
    p_error_description := SQLERRM;
  END CallWIParamEvalProc;

 -- Call any SFM FA Parameter evaluation procedure
 --
 -- the user defined FA parameter evaluation procedure should use
 -- the following spec:
 -- procedure <name of the proc>(
 --      p_order_id 		IN NUMBER,
 --      p_line_item_id		IN NUMBER,
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
  		p_error_description  OUT NOCOPY VARCHAR2)
  IS
     lv_plsql_blk varchar2(32000);
     l_message_params varchar2(2000);
     l_fa_disp_name varchar2(100);
     l_evaluation_failed_exception exception;
  BEGIN

    p_return_code := 0;
    lv_plsql_blk := 'BEGIN  '||
		    p_procedure_name||
		    '( :order_id,
			:line_item_id,
			:wi_instance_id,
			:fa_instance_id,
	 		:param_val,
			:param_ref_val,
			:param_eval_val,
			:param_eval_ref_val,
			:ret,
			:err_str); end;';
    execute immediate lv_plsql_blk
     USING p_order_id,
	   p_line_item_id,
	   p_wi_instance_id,
	   p_fa_instance_id,
	   p_param_val,
	   p_param_ref_val,
	   OUT p_param_eval_val,
	   OUT p_param_eval_ref_val,
	   OUT p_return_code,
	   OUT p_error_description;

   IF p_return_code <> 0 THEN
       xdpcore.context( 'XDP_UTILITIES', 'CallFAParamEvalProc', 'FA', p_fa_instance_id, p_error_description );
   END IF;

  EXCEPTION
  WHEN OTHERS THEN
    xdpcore.context( 'XDP_UTILITIES', 'CallFAParamEvalProc', 'FA', p_fa_instance_id, SQLERRM );
    p_return_code := SQLCODE;
    p_error_description := SQLERRM;
  END CallFAParamEvalProc;

 -- Call any SFM FA evaluation procedure
 --
 -- the user defined FA evaluation procedure will
 -- evaluate all the FA parameters when the FA instance
 -- is added to a workitem at runtime. The procedure should use
 -- the following spec:
 -- procedure <name of the proc>(
 --      p_order_id 		IN NUMBER,
 --      p_line_item_id		IN NUMBER,
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
  		p_error_description  OUT NOCOPY VARCHAR2)
  IS
     lv_plsql_blk varchar2(32000);
  BEGIN

    p_return_code := 0;
    lv_plsql_blk := 'BEGIN  '||
		    p_procedure_name||
		    '( :order_id,
			:line_item_id,
			:wi_instance_id,
			:fa_instance_id,
			:ret,
			:err_str); end;';
    execute immediate lv_plsql_blk
     USING p_order_id,
	   p_line_item_id,
	   p_wi_instance_id,
	   p_fa_instance_id,
	   OUT p_return_code,
	   OUT p_error_description;
   IF p_return_code <> 0 THEN
       xdpcore.context( 'XDP_UTILITIES', 'CallFAEvalAllProc', 'FA', p_fa_instance_id, p_error_description );
   END IF;

  EXCEPTION
  WHEN OTHERS THEN
    xdpcore.context( 'XDP_UTILITIES', 'CallFAEvalAllProc', 'FA', p_fa_instance_id, SQLERRM );
    p_return_code := SQLCODE;
    p_error_description := SQLERRM;
  END CallFAEvalAllProc;

 -- Call any SFM FE routing procedure
 --
 --   the user defined FE routing procedure is used by
 --   SFM to determine which FE to talk to for an FA at runtime
 --   base on the order information.  The procedure should use
 --   the following spec:
 --   procedure <name of the proc>(
 --	     p_order_id		IN NUMBER,
 --	     p_line_item_id		IN NUMBER,
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
  		p_error_description  OUT NOCOPY VARCHAR2)
  IS
     lv_plsql_blk varchar2(32000);
  BEGIN

    p_return_code := 0;
    lv_plsql_blk := 'BEGIN  '||
		    p_procedure_name||
		    '( :order_id,
			:line_item_id,
			:wi_instance_id,
			:fa_instance_id,
			:fe_name,
			:ret,
			:err_str); end;';
    execute immediate lv_plsql_blk
     USING p_order_id,
	   p_line_item_id,
	   p_wi_instance_id,
	   p_fa_instance_id,
	   OUT p_fe_name,
	   OUT p_return_code,
	   OUT p_error_description;
   IF p_return_code <> 0 THEN
       xdpcore.context( 'XDP_UTILITIES', 'CallFERoutingProc', 'FA', p_fa_instance_id, p_error_description );
   END IF;

  EXCEPTION
  WHEN OTHERS THEN
    xdpcore.context( 'XDP_UTILITIES', 'CallFERoutingProc', 'FA', p_fa_instance_id, SQLERRM );
    p_return_code := SQLCODE;
    p_error_description := SQLERRM;
  END CallFERoutingProc;

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
 				p_error_description OUT NOCOPY VARCHAR2)
  IS
     lv_plsql_blk varchar2(32000);
  BEGIN

    p_return_code := 0;
    lv_plsql_blk := 'BEGIN  '||
		    p_procedure_name||
		    '( :fe_name,
			:channel_name,
			:ret,
			:err_str); end;';
    execute immediate lv_plsql_blk
     USING p_fe_name,
	   p_channel_name,
	   OUT p_return_code,
	   OUT p_error_description;

  EXCEPTION
  WHEN OTHERS THEN
    p_return_code := SQLCODE;
    p_error_description := SQLERRM;
  END Call_NEConnection_Proc;


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
          	p_error_description OUT NOCOPY VARCHAR2)
  IS
     lv_plsql_blk varchar2(32000);
  BEGIN

    p_return_code := 0;
    lv_plsql_blk := 'BEGIN  '||
		    p_procedure_name||
		    '( :order_id,
			:line_item_id,
			:wi_instance_id,
			:fa_instance_id,
	 		:channel_name,
			:fe_name,
			:fa_item_type,
			:fa_item_key,
			:ret,
			:err_str); end;';
    execute immediate lv_plsql_blk
     USING p_order_id,
	   p_line_item_id,
	   p_wi_instance_id,
	   p_fa_instance_id,
	   p_channel_name,
	   p_fe_name,
	   p_fa_item_type,
	   p_fa_item_key,
	   OUT p_return_code,
	   OUT p_error_description;
   IF p_return_code <> 0 THEN
       xdpcore.context( 'XDP_UTILITIES', 'CallFulfillmentProc', 'FE', p_fe_name, p_error_description );
   END IF;

  EXCEPTION
  WHEN OTHERS THEN
    xdpcore.context( 'XDP_UTILITIES', 'CallFulfillmentProc', 'FE', p_fe_name, SQLERRM );
    p_return_code := SQLCODE;
    p_error_description := SQLERRM;
  END CallFulfillmentProc;


 -- Call any SFM workitem FA dynamic mapping procedure
 --
 --  the user defined FA dynamic mapping procedure should use
 --  the following spec:
 --  procedure <name of the proc>(
 --         p_order_id IN NUMBER,
 --         p_line_item_id IN NUMBER,
 --         p_wi_instance_id IN NUMBER,
 --		p_return_code OUT NOCOPY NUMBER,
 --         p_error_description OUT NOCOPY VARCHAR2)
 --

  PROCEDURE CallFAMapProc(
		p_procedure_name IN Varchar2,
       	p_order_id IN NUMBER,
       	p_line_item_id IN NUMBER,
       	p_wi_instance_id IN NUMBER,
       	p_return_code OUT NOCOPY NUMBER,
       	p_error_description OUT NOCOPY VARCHAR2)
  IS
     lv_plsql_blk varchar2(32000);
  BEGIN

    p_return_code := 0;
    lv_plsql_blk := 'BEGIN  '||
		    p_procedure_name||
		    '( :order_id,
			:line_item_id,
			:wi_instance_id,
			:ret,
			:err_str); end;';
    execute immediate lv_plsql_blk
     USING p_order_id,
	   p_line_item_id,
	   p_wi_instance_id,
	   OUT p_return_code,
	   OUT p_error_description;

   IF p_return_code <> 0 THEN
       xdpcore.context( 'XDP_UTILITIES', 'CallFAMapProc', 'WI', p_wi_instance_id, p_error_description );
   END IF;
  EXCEPTION
  WHEN OTHERS THEN
    xdpcore.context( 'XDP_UTILITIES', 'CallFAMapProc', 'WI', p_wi_instance_id, SQLERRM );
    p_return_code := SQLCODE;
    p_error_description := SQLERRM;
  END CallFAMapProc;

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
       		p_error_description OUT NOCOPY VARCHAR2)
  IS
     lv_plsql_blk varchar2(32000);
  BEGIN

    p_return_code := 0;
    lv_plsql_blk := 'BEGIN  '||
		    p_procedure_name||
		    '( :order_id,
			:line_item_id,
			:ret,
			:err_str); end;';
    execute immediate lv_plsql_blk
     USING p_order_id,
	   p_line_item_id,
	   OUT p_return_code,
	   OUT p_error_description;

   IF p_return_code <> 0 THEN
       xdpcore.context( 'XDP_UTILITIES', 'CallWIMapProc', 'LINE', p_line_item_id, p_error_description );
   END IF;
  EXCEPTION
  WHEN OTHERS THEN
    xdpcore.context( 'XDP_UTILITIES', 'CallWIMapProc', 'LINE', p_line_item_id, SQLERRM );
    p_return_code := SQLCODE;
    p_error_description := SQLERRM;

  END CallWIMapProc;


 --
 -- Call any SFM workitem user workflow start up procedure
 --
 --  the user defined WI workflow startup procedure should use
 --  the following spec:
 --  procedure <name of the proc>(
 --         p_order_id IN NUMBER,
 --         p_line_item_id IN NUMBER,
 --         p_wi_instance_id IN NUMBER,
 --		p_wf_item_type OUT NOCOPY varchar2,
 --		p_wf_item_key  OUT NOCOPY varchar2,
 --		p_wf_process_name  OUT NOCOPY varchar2,
 --		p_return_code OUT NOCOPY NUMBER,
 --         p_error_description OUT NOCOPY VARCHAR2)
 --

  PROCEDURE CallWIWorkflowProc(
		p_procedure_name IN Varchar2,
       	p_order_id IN NUMBER,
       	p_line_item_id IN NUMBER,
       	p_wi_instance_id IN NUMBER,
		p_wf_item_type OUT NOCOPY varchar2,
		p_wf_item_key  OUT NOCOPY varchar2,
		p_wf_process_name  OUT NOCOPY varchar2,
       	p_return_code OUT NOCOPY NUMBER,
       	p_error_description OUT NOCOPY VARCHAR2)
  IS
     lv_plsql_blk varchar2(32000);
  BEGIN

    p_return_code := 0;
    lv_plsql_blk := 'BEGIN  '||
		    p_procedure_name||
		    '( :order_id,
			:line_item_id,
			:wi_instance_id,
			:wf_item_type,
			:wf_item_key,
			:wf_process_name,
			:ret,
			:err_str); end;';
    execute immediate lv_plsql_blk
     USING p_order_id,
	   p_line_item_id,
	   p_wi_instance_id,
	   OUT p_wf_item_type,
	   OUT p_wf_item_key,
	   OUT p_wf_process_name,
	   OUT p_return_code,
	   OUT p_error_description;
   IF p_return_code <> 0 THEN
       xdpcore.context( 'XDP_UTILITIES', 'CallWIWorkflowProc', 'WI', p_wi_instance_id, p_error_description );
   END IF;

  EXCEPTION
  WHEN OTHERS THEN
    xdpcore.context( 'XDP_UTILITIES', 'CallWIWorkflowProc', 'WI', p_wi_instance_id, SQLERRM );
    p_return_code := SQLCODE;
    p_error_description := SQLERRM;
  END CallWIWorkflowProc;

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
       		p_error_description OUT NOCOPY VARCHAR2)
  IS
     lv_plsql_blk varchar2(32000);
  BEGIN

    p_return_code := 0;
    lv_plsql_blk := 'BEGIN  '||
		    p_procedure_name||
		    '( :sdp_order_id,
			:task_result,
			:ret,
			:err_str); end;';
    execute immediate lv_plsql_blk
     USING p_sdp_order_id,
	   OUT p_task_result,
	   OUT p_return_code,
	   OUT p_error_description;

  EXCEPTION
  WHEN OTHERS THEN
    p_return_code := SQLCODE;
    p_error_description := SQLERRM;
  END CallDRCTaskResultProc;



 --
 --  This procedure will insert a new row into XDP_PROC_BODY table
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
	error_description OUT NOCOPY VARCHAR2) IS
  lv_lob clob;
 BEGIN
   return_code := 0;
   insert into xdp_proc_body
   (proc_name, proc_type, protected_flag, proc_spec, proc_body, creation_date, created_by, last_update_date,
    last_updated_by, last_update_login)
   values
   (p_proc_name, p_proc_type, 'N', p_proc_spec, empty_clob(),
    p_creation_date, p_created_by, p_last_update_date, p_last_updated_by,p_last_update_login)
   returning proc_body into lv_lob;

  dbms_lob.write(lv_lob, length(p_proc_body), 1, p_proc_body);

  EXCEPTION
  WHEN OTHERS THEN
    return_code := SQLCODE;
    error_description := SUBSTR(SQLERRM,1,280);
 END Create_New_Proc_Body;

 --
 --  This procedure will update the XDP_PROC_BODY table
 --
 PROCEDURE Update_Proc_Body(
		p_proc_name IN VARCHAR2,
		p_proc_type IN VARCHAR2 := 'CONNECT',
		p_proc_body IN VARCHAR2,
		p_last_update_date IN DATE,
		p_last_updated_by IN NUMBER,
		p_last_update_login IN NUMBER,
		return_code OUT NOCOPY NUMBER,
		error_description OUT NOCOPY VARCHAR2) IS

   lv_lob clob;
   lv_length number := 32767;
  BEGIN
      return_code := 0;

      update xdp_proc_body
      set
	  last_update_date = p_last_update_date,
	  last_updated_by = p_last_updated_by,
	  last_update_login = p_last_update_login,
	  proc_body = empty_clob()
      where
 	    proc_type = p_proc_type
	and proc_name = p_proc_name
      returning proc_body into lv_lob;

  DBMS_LOB.WRITE(lv_lob,length(p_proc_body),1,p_proc_body);
  commit;


  EXCEPTION
  WHEN OTHERS THEN
    return_code := SQLCODE;
    error_description := SUBSTR(SQLERRM,1,280);
  END Update_Proc_Body;


 --
 -- A function to convert clob to varchar2
 --
 FUNCTION Get_CLOB_Value(p_proc_name in varchar2)
   RETURN VARCHAR2 IS
  lv_str varchar2(32700);
  lv_length number := 32600;
  lv_lob clob;

  CURSOR l_get_clob_value_csr IS
    select proc_body
    from xdp_proc_body
    where proc_name = p_proc_name;

 BEGIN

/***
    --skilaru 03/27/2001
    --modified to use CURSOR
    select proc_body into lv_lob
    from xdp_proc_body
    where proc_name = p_proc_name;
    dbms_lob.read(lv_lob,lv_length,1,lv_str);
***/
    OPEN l_get_clob_value_csr;
    FETCH l_get_clob_value_csr INTO lv_lob;

    IF l_get_clob_value_csr%FOUND THEN
      dbms_lob.read(lv_lob,lv_length,1,lv_str);
    END IF;

    CLOSE l_get_clob_value_csr;
    RETURN lv_str;

 END Get_CLOB_Value;

--
-- a procedure to execute any Query which returns a list of IDs
--

PROCEDURE Execute_GetID_QUERY(
				p_query_block IN VARCHAR2,
          			p_id_list OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
				return_code OUT NOCOPY NUMBER,
				error_description OUT NOCOPY VARCHAR2)
IS
  TYPE v_cursorType IS REF CURSOR;
  v_cursor v_cursorType;
  v_numRows number := 0;
  lv_tmp_id number;
BEGIN

  return_code := 0;
  IF v_cursor%ISOPEN THEN
  	CLOSE v_cursor;
  END IF;
  OPEN v_cursor FOR p_query_block;
  LOOP
   FETCH v_cursor INTO lv_tmp_id;
   EXIT WHEN v_cursor%NOTFOUND OR v_cursor%NOTFOUND IS NULL;
   v_numRows := v_numRows + 1;
   p_id_list(v_numRows) := lv_tmp_id;
  END LOOP;

  CLOSE v_cursor;

EXCEPTION
WHEN OTHERS THEN
    return_code := SQLCODE;
    error_description := SUBSTR(SQLERRM,1,280);
    CLOSE v_cursor;
END Execute_GetID_QUERY;

  -- Local function to convert parameter modes to strings.
  FUNCTION ConvertMode(p_Code IN NUMBER)
    RETURN VARCHAR2 IS
    v_Output VARCHAR2(10);
  BEGIN

--
-- Changed DECODE statement to IF statements to improve performance.
-- skilaru 03/14/2001
--
/*
    SELECT DECODE(p_Code, 0, 'IN',
                          1, 'IN OUT',
                          2, 'OUT')
      INTO v_Output
      FROM dual;
*/
    IF p_Code = 0 THEN
        v_Output :=  'IN';
    ELSIF p_Code = 1 THEN
        v_Output :=  'IN OUT';
    ELSIF p_Code = 2 THEN
        v_Output :=  'OUT';
    END IF;

    RETURN v_Output;
  END ConvertMode;


  --
  -- Describe the procedure
  PROCEDURE DescribeProc(p_ProcName IN VARCHAR2,
                         p_Print IN BOOLEAN) IS
    v_ArgCounter NUMBER := 1;
  BEGIN
    -- First call DESCRIBE_PROCEDURE to populate the internal variables
	-- about the procedure.
    DBMS_DESCRIBE.DESCRIBE_PROCEDURE(
      p_ProcName,
      null,
      null,
      v_Overload,
      v_Position,
      v_Level,
      v_ArgumentName,
      v_Datatype,
      v_DefaultValue,
      v_InOut,
      v_Length,
      v_Precision,
      v_Scale,
      v_Radix,
      v_Spare);

    IF NOT p_Print THEN
      RETURN;
    END IF;

  END DescribeProc;

  PROCEDURE RunProc(p_NumParams IN NUMBER,
                    p_ProcName IN VARCHAR2,
                    p_Parameters IN OUT NOCOPY t_ParameterList) IS

    -- DBMS_SQL variables
    v_Cursor  NUMBER;
    v_NumRows NUMBER;
    lv_InOut        DBMS_DESCRIBE.NUMBER_TABLE;

    v_ProcCall VARCHAR2(32600);
    v_FirstParam BOOLEAN := TRUE;
  BEGIN

    -- First describe the procedure.
    DescribeProc(p_ProcName, FALSE);
    lv_InOut := v_InOut;

    -- Now we need to create the procedure call string.  This consists of
	-- 'BEGIN <procedure_name>(:p1, :p2, ...); END;'
    v_ProcCall := 'BEGIN ' || p_ProcName || '(';

    FOR v_Counter IN 1..p_NumParams LOOP
      IF v_FirstParam THEN
        v_ProcCall := v_ProcCall || ':' || v_ArgumentName(v_Counter);
        v_FirstParam := FALSE;
      ELSE
        v_ProcCall := v_ProcCall || ', :' || v_ArgumentName(v_Counter);
      END IF;
    END LOOP;

    v_ProcCall := v_ProcCall || '); END;';

    -- Open the cursor and parse the statement.
    v_Cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_Cursor, v_ProcCall, DBMS_SQL.V7);

    -- Bind the procedure parameters.
    FOR v_Counter IN 1..p_NumParams LOOP

      -- First set the parameter name.
      p_Parameters(v_Counter).name := v_ArgumentName(v_Counter);

      -- Bind based on the parameter type.
      IF p_Parameters(v_Counter).actual_type = 'NUMBER' THEN
        DBMS_SQL.BIND_VARIABLE(v_Cursor, p_Parameters(v_Counter).name,
                               p_Parameters(v_Counter).num_param);
      ELSIF p_Parameters(v_Counter).actual_type = 'VARCHAR2' THEN
        DBMS_SQL.BIND_VARIABLE(v_Cursor, p_Parameters(v_Counter).name,
                               p_Parameters(v_Counter).vchar_param, 32767);
      ELSIF p_Parameters(v_Counter).actual_type = 'DATE' THEN
        DBMS_SQL.BIND_VARIABLE(v_Cursor, p_Parameters(v_Counter).name,
                               p_Parameters(v_Counter).date_param);
      ELSIF p_Parameters(v_Counter).actual_type = 'CHAR' THEN
        DBMS_SQL.BIND_VARIABLE_CHAR(v_Cursor, p_Parameters(v_Counter).name,
                               p_Parameters(v_Counter).char_param, 500);
      ELSE
        RAISE_APPLICATION_ERROR(-20501, 'Dynamic PL/SQL error: Invalid parameter type');
      END IF;
    END LOOP;

    -- Execute the procedure.
    v_NumRows := DBMS_SQL.EXECUTE(v_Cursor);

    -- Call VARIABLE_VALUE for any OUT or IN OUT parameters.
    FOR v_Counter IN 1..p_NumParams LOOP
      IF lv_InOut(v_Counter) = 1 OR lv_InOut(v_Counter) = 2 THEN
        IF p_Parameters(v_Counter).actual_type = 'NUMBER' THEN
          DBMS_SQL.VARIABLE_VALUE(v_Cursor, ':' || p_Parameters(v_Counter).name,
                                p_Parameters(v_Counter).num_param);
        ELSIF p_Parameters(v_Counter).actual_type = 'VARCHAR2' THEN
          DBMS_SQL.VARIABLE_VALUE(v_Cursor, ':' || p_Parameters(v_Counter).name,
                                p_Parameters(v_Counter).vchar_param);
        ELSIF p_Parameters(v_Counter).actual_type = 'DATE' THEN
          DBMS_SQL.VARIABLE_VALUE(v_Cursor, ':' || p_Parameters(v_Counter).name,
                                p_Parameters(v_Counter).date_param);
        ELSIF p_Parameters(v_Counter).actual_type = 'CHAR' THEN
          DBMS_SQL.VARIABLE_VALUE_CHAR(v_Cursor, ':' || p_Parameters(v_Counter).name,
                                p_Parameters(v_Counter).char_param);
        ELSE
          RAISE_APPLICATION_ERROR(-20501, 'Dynamic PL/SQL error: Invalid parameter type');
        END IF;
      END IF;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(v_Cursor);

  EXCEPTION
  WHEN OTHERS THEN
      DBMS_SQL.CLOSE_CURSOR(v_Cursor);
      raise;
  END RunProc;

  PROCEDURE Printparams(p_Parameters IN t_ParameterList,
                        p_NumParams IN NUMBER) IS
  BEGIN
	null;
  END PrintParams;

 -- get line item parameter values which is used by order analyzer
  FUNCTION OA_GetLineParam(
		p_line_item_id IN Number,
		p_line_param_name IN Varchar2)
	return Varchar2
  IS
    lv_param_value varchar2(4000);

    CURSOR l_oa_getlineparam_csr IS
      select parameter_value
      from XDP_ORDER_LINEITEM_DETS
      where
	 line_item_id = p_line_item_id AND
	 line_parameter_name = p_line_param_name;
  BEGIN

/***
    --skilaru 03/28/2001
    --modified to use CURSOR
    select parameter_value into lv_param_value
    from XDP_ORDER_LINEITEM_DETS
    where
	 line_item_id = p_line_item_id AND
	 line_parameter_name = p_line_param_name;
***/

    OPEN l_oa_getlineparam_csr;
    FETCH l_oa_getlineparam_csr INTO lv_param_value;

    IF l_oa_getlineparam_csr%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;

    CLOSE l_oa_getlineparam_csr;

    return lv_param_value;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    lv_param_value := 'SDP_NO_DATA_FOUND';

    IF l_oa_getlineparam_csr%ISOPEN THEN
      CLOSE l_oa_getlineparam_csr;
    END IF;

    return lv_param_value;
  WHEN OTHERS THEN
    raise;
  END OA_GetLineParam;

 -- get Workitem parameter values which is used by order analyzer
  FUNCTION OA_GetWIParam(
		p_wi_instance_id IN Number,
		p_wi_param_name IN Varchar2)
	return Varchar2
 IS
    lv_param_value varchar2(4000);


    CURSOR l_oa_getwiparam_csr IS
      select parameter_value
      from
	xdp_worklist_details wdl
      where
	 wdl.workitem_instance_id = p_wi_instance_id AND
	 wdl.parameter_name = p_wi_param_name;
  BEGIN
/***
    --skilaru 03/28/2001
    --modified to use CURSOR
    select parameter_value into lv_param_value
    from
	xdp_worklist_details wdl,
	xdp_parameter_pool ppl
    where
	 wdl.workitem_instance_id = p_wi_instance_id AND
	 wdl.wi_parameter_id = ppl.parameter_id AND
	 ppl.parameter_name = p_wi_param_name;
***/
    OPEN l_oa_getwiparam_csr;
    FETCH l_oa_getwiparam_csr INTO lv_param_value;

    IF l_oa_getwiparam_csr%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;

    CLOSE l_oa_getwiparam_csr;

    return lv_param_value;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    lv_param_value := 'SDP_NO_DATA_FOUND';

    IF l_oa_getwiparam_csr%ISOPEN THEN
      CLOSE l_oa_getwiparam_csr;
    END IF;

    return lv_param_value;
  WHEN OTHERS THEN
    raise;

 END OA_GetWIParam;

 -- Check if the order line is a workitem
 FUNCTION OA_Get_LINE_WI_FLAG(
		p_line_item_id IN Number)
  return Varchar2
 IS
	--lv_flag varchar2(1);
	lv_flag varchar2(1) := 'N';
        lv_wi_id NUMBER;

        CURSOR l_oa_get_line_wi_flag_csr IS
	select workitem_id
	from xdp_order_line_items
	where
		line_item_id = p_line_item_id;
 BEGIN
/***
    --skilaru 03/28/2001
    --modified to use CURSOR

	select decode(workitem_id,NULL,'N','Y')
	into lv_flag
	from xdp_order_line_items
	where
		line_item_id = p_line_item_id;
***/
      OPEN l_oa_get_line_wi_flag_csr;
      FETCH l_oa_get_line_wi_flag_csr INTO lv_wi_id;

      IF lv_wi_id IS NOT NULL THEN
        lv_flag := 'Y';
      ELSE
        RAISE NO_DATA_FOUND;
      END IF;

      CLOSE l_oa_get_line_wi_flag_csr;
      return lv_flag;

 EXCEPTION
 WHEN NO_DATA_FOUND THEN
        --skilaru 03/31/2001
        lv_flag := NULL;

        IF l_oa_get_line_wi_flag_csr%ISOPEN THEN
          CLOSE l_oa_get_line_wi_flag_csr;
        END IF;

      return lv_flag;
 END OA_Get_LINE_WI_FLAG;

 -- get workitem name which is used by order analyzer
 FUNCTION OA_GetWIName(
		p_wi_instance_id IN Number)
  return Varchar2
 IS
    lv_wi  varchar2(80);
    CURSOR l_oa_getwiname_csr IS
        select workitem_name
	from xdp_workitems wim,
	     XDP_FULFILL_WORKLIST fwt
	where
		fwt.workitem_instance_id = p_wi_instance_id and
		fwt.workitem_id = wim.workitem_id;
 BEGIN

/***
        --skilaru 03/31/2001
        --modified to use CURSOR

	select workitem_name
	into lv_wi
	from xdp_workitems wim,
	     XDP_FULFILL_WORKLIST fwt
	where
		fwt.workitem_instance_id = p_wi_instance_id and
		fwt.workitem_id = wim.workitem_id;
***/
      OPEN l_oa_getwiname_csr;
      FETCH l_oa_getwiname_csr INTO lv_wi;

      IF l_oa_getwiname_csr%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
      END IF;

      CLOSE l_oa_getwiname_csr;
      return lv_wi;
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
	lv_wi := NULL;

        IF l_oa_getwiname_csr%ISOPEN THEN
          CLOSE l_oa_getwiname_csr;
        END IF;

      return lv_wi;

 END OA_GetWIName;


-- These set of routines are used by the Name/Value parser provided by SFM

 procedure Parse_String( buffer in varchar2,
                         NameValueList IN OUT NOCOPY XDP_TYPES.NAME_VALUE_LIST,
                         assign_str in varchar2 := '=',
                         p_term_str in varchar2 := NULL)

 IS
	assign_str_pos		integer := 0;
	assign_str_len		integer := 0;
	line_count		integer := 0;
	buffer_len		integer := 0;
	done			boolean := FALSE;
	line_buffer		varchar2(32767);
	key_name		varchar2(32767);
	key_value		varchar2(32767);
	term_str		varchar2(6);
	proc_tag varchar2(30) := 'PARSE_RESPONSE-';
	line_list		string_list_t;
	c			integer := 1;
BEGIN
	if buffer is null then
		return;
	end if;
	if p_term_str is null then
		term_str := FND_GLOBAL.LOCAL_CHR(10);
	else
		term_str := p_term_str;
	end if;

  	buffer_len := LENGTH(buffer);
	if buffer_len = 0 then
		return;
	end if;
	split_lines(buffer,line_list,term_str);
	line_count := 1;
	for c in line_list.first .. line_list.last loop
		key_name  := get_key_name(line_list(c),assign_str);
		key_value := get_key_value(line_list(c),assign_str);
		if key_name is not null then
			NameValueList(line_count).NAME := key_name;
			if key_value is not null then
				NameValueList(line_count).VALUE := key_value;
			end if;
			line_count := line_count + 1;
		end if;
	  end loop;
EXCEPTION
	WHEN OTHERS THEN RAISE;
end Parse_String;

function get_key_name(buffer in varchar2,assign_str in varchar2 := '=' ) return varchar2
is
 ret_val varchar2(32767);
 assign_str_pos integer := 0;
 assign_str_len integer := 0;
 minimum_start_pos integer := 0;
 buffer_len integer := 0;
 key_start_pos integer := 1;
 characters_to_read integer := 0;
 minimum_assign_pos integer := 2;
 proc_tag varchar2(30) := 'GET_KEY_NAME-';
begin
	buffer_len := length(buffer);
	if buffer_len = 0 or buffer_len is null then
		return null;
	end if;
	assign_str_len := length(assign_str);
	assign_str_pos := instr(buffer,assign_str);
	if assign_str_pos < minimum_assign_pos or assign_str_pos is null then
		ret_val := null;
	else
		characters_to_read := assign_str_pos - key_start_pos ;
		ret_val := substr(buffer, key_start_pos, characters_to_read);
	end if;
	return ret_val;
EXCEPTION
	WHEN OTHERS THEN
		RAISE;
end get_key_name;

function get_key_value(buffer in varchar2,assign_str in varchar2 := '=' ) return varchar2
is
	ret_val			varchar2(32767);
	assign_str_pos		integer := 0;
	buffer_len		integer := 0;
	assign_str_len		integer := 0;
	value_start_pos		integer := 0;
	characters_to_read	integer := 0;
	proc_tag varchar2(30) := 'GET_KEY_VALUE-';
begin
	buffer_len		:= length(buffer);
	if buffer_len = 0 or buffer_len is null then
		return null;
	end if;
	assign_str_pos		:= instr(buffer,assign_str);
	assign_str_len		:= length(assign_str);
	value_start_pos		:= assign_str_pos + assign_str_len;
	characters_to_read	:= buffer_len - assign_str_pos;
	if assign_str_pos = 0 then
		return null;
	end if;
	IF value_start_pos > buffer_len then
		ret_val := null;
	else
		ret_val := substr(buffer, value_start_pos, characters_to_read );
	end if;
	return ret_val;
EXCEPTION
 WHEN OTHERS THEN RAISE;
end get_key_value;

procedure split_lines(buffer in varchar2,string_list in OUT NOCOPY string_list_t ,split_str in varchar2)
is
 c integer := 1;
 start_pos integer := 1;
 buffer_len integer := 0;
 end_pos integer := 1;
 done boolean := false;
 proc_tag varchar2(30) := 'SPLIT_LINES-';
 line_end_pos integer := 0;
begin
        if buffer is null then
                return;
        end if;
        buffer_len := length(buffer);
        if buffer_len = 0 then
                return;
        end if;
	end_pos := instr(buffer,split_str,start_pos);
	if end_pos = 0 then
		string_list(1) := buffer;
		done := true;
	end if;
	start_pos := 1;
        while (start_pos < buffer_len) and (end_pos > 0 )  loop
                end_pos := instr(buffer,split_str,start_pos,1);
		line_end_pos := end_pos - start_pos ;
                if end_pos = 0 then
                	string_list(c) := substr(buffer,start_pos);
		else
			string_list(c) := substr(buffer,start_pos,line_end_pos );
		end if;
                start_pos := end_pos + 1;
		c := c + 1;
        end loop;
end split_lines;

-- End of SFM Name/Value parser


FUNCTION ISVALIDNAME( p_varname IN VARCHAR2 ) RETURN VARCHAR2 IS

BEGIN
   IF( IS_VALID_NAME( p_varname ) ) THEN
    RETURN 'TRUE';
   ELSE
    RETURN 'FALSE';
   END IF;
END ISVALIDNAME;

/*
	vrachur : 07/15/1999 - Added funtion IS_VALID_NAME

	Function: IS_VALID_NAME( VARCHAR2 )
	Input	: Variable Name

	Purpose	: Checks if a name confirms to PL/SQL naming convention. This
		  does not check for reserved words.

	Returns : TRUE  - Valid Name
		  FALSE - Invalid Name
*/
FUNCTION IS_VALID_NAME( p_varname IN VARCHAR2 ) RETURN BOOLEAN IS
	l_cur_char	CHAR(1) ;
	l_var_length	NUMBER ;
	l_char_ascii	NUMBER ;

BEGIN
	-- Return FALSE if nothing is passed.
	l_var_length := LENGTH( p_varname ) ;

	IF ( p_varname IS NULL ) OR ( l_var_length <= 0 ) THEN
		RETURN FALSE ;

	END IF ;

	-- Check Char by Char. Make sure it adheres to PL/SQL naming Standards.
	FOR i IN 1..l_var_length
	LOOP
		l_cur_char   := SUBSTR( p_varname, i, 1 ) ;
		l_char_ascii := ASCII( l_cur_char ) ;

		-- First Character should always be A-Z or a-z
		IF ( i = 1 ) THEN
			-- First Character
			IF ( l_char_ascii NOT BETWEEN 65 AND 90 ) AND
				( l_char_ascii NOT BETWEEN 97 AND 122 ) THEN
				RETURN FALSE ;
			END IF ;
		ELSE
			-- Rest can be A-Z, a-z, 0-9, $, #, _
			IF ( l_char_ascii NOT BETWEEN 65 AND 90 ) AND
				( l_char_ascii NOT BETWEEN 97 AND 122 ) AND
				( l_char_ascii NOT BETWEEN 48 AND 57 ) AND
				( l_cur_char NOT IN ( '_', '$', '#' ) ) THEN

				RETURN FALSE ;
			END IF ;
		END IF ;
	END LOOP ;

	RETURN TRUE ;

EXCEPTION
	WHEN OTHERS THEN
		RETURN FALSE ;
END	IS_VALID_NAME ;

--
--  This is the function which will mimic the workflow function
--  WF_STANDARD.WaitForFlow and handling the workflow concurrency
--  problem in WaitForFlow.  The caller should pass its current item type,
--  item key, and activity name to the API
--
Procedure WaitForFlow(
	p_item_type varchar2,
      p_item_key  varchar2,
      p_activity_name varchar2)
IS
  lv_child_count number := 0;
  lv_id number;
  cursor lc_child IS
   select item_type, item_key
   from wf_items_v wi
   where
	wi.parent_item_type = p_item_type and
      wi.parent_item_key = p_item_key ;
  lv_attr_defined varchar2(1) := 'N';
  lv_previous_count number;
  lv_error_wf varchar2(1);
BEGIN

   begin
     select 'Y' into lv_attr_defined
     from dual
     where exists(
         select 1
        from WF_ITEM_ATTRIBUTE_values WIA
        where WIA.ITEM_TYPE = p_item_type
	  and WIA.ITEM_KEY = p_item_key
        and WIA.NAME = 'XDP_NUMBER_OF_CHILDREN');
      exception
      when no_data_found then
        wf_engine.AddItemAttr(
		p_item_type,
		p_item_key,
            'XDP_NUMBER_OF_CHILDREN');
    	  wf_engine.SetItemAttrNumber(
		p_item_type,
		p_item_key,
            'XDP_NUMBER_OF_CHILDREN',
		0);

    end;

  lv_previous_count := wf_engine.GetItemAttrNumber(
		p_item_type,
		p_item_key,
            'XDP_NUMBER_OF_CHILDREN');

  select XDP_WF_COORDINATION_ID_S.NextVal
  into lv_id from dual;

  For lv_child_rec in lc_child loop
    begin
     select 'N' into lv_error_wf
     from dual
     where not exists(
         select 1
        from WF_ITEM_ATTRIBUTE_values WIA
        where WIA.ITEM_TYPE = lv_child_rec.item_type
	  and WIA.ITEM_KEY = lv_child_rec.item_key
        and WIA.NAME = 'ERROR_ITEM_KEY'
        and WIA.TEXT_VALUE = p_item_key);
      exception
      when no_data_found then
        lv_error_wf := 'Y';
    end;
    IF lv_error_wf = 'N' THEN
      lv_child_count := lv_child_count + 1;
      begin
       select 'Y' into lv_attr_defined
       from dual
       where exists(
         select 1
        from WF_ITEM_ATTRIBUTE_values WIA
        where WIA.ITEM_TYPE = lv_child_rec.item_type
	  and WIA.ITEM_KEY = lv_child_rec.item_key
        and WIA.NAME = 'XDP_WF_COORDINATION_ID');
       exception
        when no_data_found then
          wf_engine.AddItemAttr(
		lv_child_rec.item_type,
		lv_child_rec.item_key,
            'XDP_WF_COORDINATION_ID');
	    wf_engine.SetItemAttrNumber(
		lv_child_rec.item_type,
		lv_child_rec.item_key,
            'XDP_WF_COORDINATION_ID',
		lv_id);
      end;
    END IF;
  end loop;

  if lv_child_count = 0 then
    raise_application_error(-20111,
         'Call to WaitForFlow failed.  There is no child process');
  end if;

  insert into XDP_WF_PROCESS_COORD
  (wf_coordination_id,
   wf_item_type,
   wf_item_key,
   wf_activity_name,
   child_process_num,
   created_by,
   creation_date,
   last_updated_by,
   last_update_date,
   last_update_login
  )
  values
  (
    lv_id,
    p_item_type,
    p_item_key,
    p_activity_name,
    lv_child_count - lv_previous_count,
	FND_GLOBAL.USER_ID,
	sysdate,
	FND_GLOBAL.USER_ID,
	sysdate,
	FND_GLOBAL.LOGIN_ID
  );

 wf_engine.SetItemAttrNumber(
	p_item_type,
	p_item_key,
      'XDP_NUMBER_OF_CHILDREN',
	lv_child_count);

END WaitForFlow;

--
--  This is the function which will mimic the workflow function
--  WF_STANDARD.ContinueFlow and handling the workflow concurrency
--  problem in ContinueFlow.  The caller should pass its current item type
--  and item key to the API
--
Procedure ContinueFlow(
	p_item_type varchar2,
      p_item_key  varchar2)
IS
  lv_id number;
  lv_child_count number;
  lv_type varchar2(8);
  lv_key varchar2(240);
  lv_act varchar2(240);
BEGIN
  lv_id := wf_engine.GetItemAttrNumber(
		p_item_type,
		p_item_key,
            'XDP_WF_COORDINATION_ID');
  Select child_process_num,wf_item_type,wf_item_key,wf_activity_name
  into lv_child_count,lv_type,lv_key,lv_act
  from XDP_WF_PROCESS_COORD
  where wf_coordination_id = lv_id for update;

  lv_child_count := lv_child_count - 1;

  IF lv_child_count > 0 THEN
	update XDP_WF_PROCESS_COORD
      set child_process_num = lv_child_count
      where wf_coordination_id = lv_id ;
  ELSE
	delete from XDP_WF_PROCESS_COORD
      where wf_coordination_id = lv_id ;
      WF_ENGINE.CompleteActivity(
        lv_type,
        lv_key,
	  lv_act,
        wf_engine.eng_null);
  END IF;

END ContinueFlow;

--
-- A procedure to create a package spec dynamically
--  application_short_name should be either XDP or XNP
--
PROCEDURE Create_PKG_Spec(
			p_pkg_name IN VARCHAR2,
			p_pkg_spec IN VARCHAR2,
			p_application_short_name IN VARCHAR2,
			x_return_code OUT NOCOPY NUMBER,
			x_error_string OUT NOCOPY VARCHAR2)
IS

    lv1 varchar2(80);
    lv2 varchar2(80);
    lv_schema varchar2(80);
    lv_ret BOOLEAN;
	lv_loc1 number := 1;
	lv_loc2 number;
	lv_len number := LENGTH(p_pkg_spec);
	lv_row number := 0;
	lv_status varchar2(40);
	lv_owner varchar2(80);
	lf_owner varchar2(80);
	lv_tmp varchar2(32767);
	lv_tmp_len number;
	lv_lf varchar2(10);
	lv_pkg_name varchar2(80) := UPPER(p_pkg_name);
	CURSOR lc_status IS
	  select status, owner
	  from all_objects
	  where object_name = lv_pkg_name and
		   object_type = 'PACKAGE' and
                   owner = lf_owner and
		   status <> 'VALID';
	CURSOR lc_err(l_owner IN VARCHAR2) IS
	 select text from all_errors
	 where
	   owner = l_owner and
	   name = lv_pkg_name
	   order by line;

BEGIN
        select user into lf_owner from dual;

	x_return_code := 0;
  	lv_ret := FND_INSTALLATION.get_app_info(
       'FND',
		lv1,
		lv2,
		lv_schema);
	lv_lf := '
';
    LOOP
		if lv_loc1 > lv_len then
			exit;
		end if;

		lv_loc2 := INSTR(p_pkg_spec,lv_lf,lv_loc1,1);
		if lv_loc2 = 0 then
			lv_tmp_len := lv_len - lv_loc1 + 1;
			lv_tmp := SUBSTR(p_pkg_spec,lv_loc1,lv_tmp_len);
			if lv_tmp_len <= 255 then
				lv_row := lv_row + 1;
  				ad_ddl.build_package(
					lv_tmp,
					lv_row
					);
				exit;
			else
	  			x_return_code := -20111;
	  			x_error_string :=
					'Error:The following line exceeds 255 character.  '||
					'Please insert a character return to break up the line.'||
					SUBSTR(lv_tmp,1,257);
				return;
			end if;
		else
			lv_tmp_len := lv_loc2 - lv_loc1;
			lv_tmp := SUBSTR(p_pkg_spec,lv_loc1,lv_tmp_len);
			if lv_tmp_len <= 255 then
				lv_row := lv_row + 1;
  				ad_ddl.build_package(
					lv_tmp,
					lv_row
					);
				lv_loc1 := lv_loc1 + lv_tmp_len + 1;
			else
	  			x_return_code := -20111;
	  			x_error_string :=
					'Error:The following line exceeds 255 character.  '||
					'Please insert a character return to break up the line.'||
					SUBSTR(lv_tmp,1,257);
				return;
			end if;
		end if;
	END LOOP;

	IF lv_row = 0 THEN
	  x_return_code := -20111;
	  x_error_string := 'Error:The package spec can not be empty.';
	  return;
	END IF;

	AD_DDL.CREATE_PACKAGE(
		lv_schema  ,
		p_application_short_name  ,
		p_pkg_name,
		'FALSE',
		1,
		lv_row
		);

	lv_status := 'VALID';
	FOR lv_status_rec IN lc_status LOOP
      lv_status := lv_status_rec.status;
	  lv_owner := lv_status_rec.owner;
	  exit;
	END LOOP;
    IF lv_status <> 'VALID' THEN
	   x_return_code := -24344;
	   for lv_err_rec in lc_err(lv_owner) loop
		  x_error_string := x_error_string ||lv_err_rec.text||' ';
	   end loop;
	END IF;


EXCEPTION
	WHEN OTHERS THEN
	x_return_code := SQLCODE;
	x_error_string := SQLERRM;
END Create_PKG_Spec;

-- A procedure to create or replace a package body dynamically
PROCEDURE Create_PKG_Body(
			p_pkg_name IN VARCHAR2,
			p_pkg_body IN VARCHAR2,
			p_application_short_name IN VARCHAR2,
			x_return_code OUT NOCOPY NUMBER,
			x_error_string OUT NOCOPY VARCHAR2)
IS

    lv1 varchar2(80);
    lv2 varchar2(80);
    lv_schema varchar2(80);
    lv_ret BOOLEAN;
	lv_loc1 number := 1;
	lv_loc2 number;
	lv_len number := LENGTH(p_pkg_body);
	lv_row number := 0;
	lv_status varchar2(40);
	lv_owner varchar2(80);
	lf_owner varchar2(80);
	lv_tmp varchar2(32767);
	lv_tmp_len number;
	lv_lf varchar2(10);
	lv_pkg_name varchar2(80) := UPPER(p_pkg_name);
	CURSOR lc_status IS
	  select status, owner
	  from all_objects
	  where object_name = lv_pkg_name and
		   object_type = 'PACKAGE BODY' and
                   owner = lf_owner and
		   status <> 'VALID';
	CURSOR lc_err(l_owner IN VARCHAR2) IS
	 select text from all_errors
	 where
	   owner = l_owner and
	   name = p_pkg_name
	   order by line;
BEGIN

        select user into lf_owner from dual;
	x_return_code := 0;
  	lv_ret := FND_INSTALLATION.get_app_info(
       'FND',
		lv1,
		lv2,
		lv_schema);
	lv_lf := '
';
    LOOP
		if lv_loc1 > lv_len then
			exit;
		end if;
		lv_loc2 := INSTR(p_pkg_body,lv_lf,lv_loc1,1);
		if lv_loc2 = 0 then
			lv_tmp_len := lv_len - lv_loc1 + 1;
			lv_tmp := SUBSTR(p_pkg_body,lv_loc1,lv_tmp_len);
			if lv_tmp_len <= 255 then
				lv_row := lv_row + 1;
  				ad_ddl.build_package(
					lv_tmp,
					lv_row
					);
				exit;
			else
	  			x_return_code := -20111;
	  			x_error_string :=
					'Error:The following line exceeds 255 character.  '||
					'Please insert a character return to break up the line.'||
					SUBSTR(lv_tmp,1,257);
				return;
			end if;
		else
			lv_tmp_len := lv_loc2 - lv_loc1;
			lv_tmp := SUBSTR(p_pkg_body,lv_loc1,lv_tmp_len);
			if lv_tmp_len <= 255 then
				lv_row := lv_row + 1;
  				ad_ddl.build_package(
					lv_tmp,
					lv_row
					);
				lv_loc1 := lv_loc1 + lv_tmp_len + 1;
			else
	  			x_return_code := -20111;
	  			x_error_string :=
					'Error:The following line exceeds 255 character.  '||
					'Please insert a character return to break up the line.'||
					SUBSTR(lv_tmp,1,257);
				return;
			end if;
		end if;
	END LOOP;
	IF lv_row = 0 THEN
	  x_return_code := -20111;
	  x_error_string := 'Error:The package body can not be empty.';
	  return;
	END IF;

	AD_DDL.CREATE_PACKAGE(
		lv_schema  ,
		p_application_short_name  ,
		p_pkg_name,
		'TRUE',
		1,
		lv_row
		);

	lv_status := 'VALID';
	FOR lv_status_rec IN lc_status LOOP
      lv_status := lv_status_rec.status;
	  lv_owner := lv_status_rec.owner;
	  exit;
	END LOOP;
    IF lv_status <> 'VALID' THEN
	   x_return_code := -24344;
	   for lv_err_rec in lc_err(lv_owner) loop
		  x_error_string := x_error_string ||lv_err_rec.text||' ';
	   end loop;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
	x_return_code := SQLCODE;
	x_error_string := SQLERRM;
END Create_PKG_Body;


Procedure DISPLAY (
  p_OutputString in varchar2)
IS
lv_start number;
lv_cnt number;
lv_done number;

BEGIN
 lv_done := 0;
 lv_start := 1;
 lv_cnt := 1;
 IF LENGTH(p_OutputString) > 255 THEN
  WHILE lv_done <> 1 LOOP
    IF (lv_start + 255) > LENGTH(p_OutputString) or (lv_start + 255) > 32767 THEN
     lv_done := 1;
--   DBMS_OUTPUT.PUT_LINE(SUBSTR(p_OutputString,lv_start,(LENGTH(p_OutputString) - lv_start)));
    ELSE
--     DBMS_OUTPUT.PUT_LINE(SUBSTR(p_OutputString,lv_start,255));
     lv_start := lv_cnt * 256;
     lv_cnt := lv_cnt + 1;
    END IF;
  END LOOP;
 ELSE
--   DBMS_OUTPUT.PUT_LINE(p_OutputString);
  null;
 END IF;
exception
when others then
-- DBMS_OUTPUT.PUT_LINE(SUBSTR(SQLERRM,1,255));
  null;
END Display;

-- An API to get the wf_role_name for notifications generated by workflow
-- The input parameter is the responsibity_key, i.e., OP_SYSADMIN, NP_SYSADMIN
-- The notification must be sent to the role name returned by this API
-- for FMC to retrieve it
Function Get_WF_NotifRecipient(p_responsibility_key in varchar2)
  return varchar2
IS

 l_ApplicationID number;
 l_ResponsibilityID number;

 l_NotifRecipient varchar2(80);
 l_DispName varchar2(200);
begin

  select application_id, responsibility_id
    into l_ApplicationID, l_ResponsibilityID
  from fnd_responsibility
    where RESPONSIBILITY_KEY = p_responsibility_key;


  wf_directory.getrolename(P_ORIG_SYSTEM => 'FND_RESP' ||
							to_char(l_ApplicationID),
                           P_ORIG_SYSTEM_ID => to_char(l_ResponsibilityID),
                           P_NAME => l_NotifRecipient,
                           P_DISPLAY_NAME => l_DispName);

 return l_NotifRecipient;


END Get_WF_NotifRecipient;


-- The API gets the Recipient of All System Error Notifications
-- Get the Profile Option Value and if the profile Option Value is null
-- return SFM System Administrator as value

Function GetSystemErrNotifRecipient return varchar2 is
 l_NotifRecipient varchar2(2000);
begin

 if fnd_profile.defined(pv_DefErrNotifProfile) then
   fnd_profile.get(pv_DefErrNotifProfile, l_NotifRecipient);
 else
   l_NotifRecipient := pv_DefErrNotifRecipient;
 end if;

 if l_NotifRecipient is null then
	l_NotifRecipient := pv_DefErrNotifRecipient;
 end if;

 return (l_NotifRecipient);

end GetSystemErrNotifRecipient;


-- This procedure is used for compile pl/sql procedures stored in xdp tables
-- It should be run when instance is migrated to a different instance. After data
-- import/export, run this procedure to validate all the procedures configured in
-- the old instance.

-- This procedure will be the base of a concurrent program.

PROCEDURE RECOMPPKG
(
     ERRBUF	            	OUT NOCOPY	VARCHAR2,
     RETCODE	        	OUT NOCOPY	VARCHAR2
) IS
  lv_lob2 clob;
  lv_str varchar2(2000);
  lv_body varchar2(32767);
  lv_ret number;
  lv_src_length number;
  lv_fa_id number := NULL;
  lv_fetype_id number := NULL;
  lv_proc_name varchar2(80);
  lv_index number;
  lv_sw_gen_id number := NULL;
  lv_ActualID number := NULL;
  lv_adapter_type varchar2(80) := null;

  lv_amount number := 1000;
  lv_offset number := 1;
  lv_buffer varchar2(80);

  CURSOR lc_proc IS
   SELECT PROC_NAME,PROC_TYPE
   FROM XDP_PROC_BODY
   WHERE protected_flag = 'N'
   ORDER BY PROC_TYPE, PROC_NAME;

  CURSOR lc_adapter IS
   SELECT ADAPTER_TYPE
   FROM xdp_fe_sw_gen_lookup
   WHERE FE_SW_GEN_LOOKUP_ID = lv_sw_gen_id;


BEGIN

	FOR lv_rec IN lc_proc LOOP

       fnd_file.put_line(fnd_file.output,'--------------------------------------------------------------');
       fnd_file.put_line(fnd_file.output,' ');
       fnd_file.put_line(fnd_file.output,'Examining Procedure: ' || lv_rec.proc_name);
       fnd_file.put_line(fnd_file.output,'Procedure Type found to be: ' || lv_rec.proc_type);

      lv_body := null;
      lv_amount := 80;
      lv_offset := 1;
      lv_src_length := 0;
      lv_buffer := NULL;

      select proc_body into lv_lob2
      from xdp_proc_body
      where proc_name = lv_rec.proc_name
      and proc_type = lv_rec.proc_type;

      lv_src_length := dbms_lob.GETLENGTH(lv_lob2);
      IF lv_src_length = 0 THEN
        fnd_file.put_line(fnd_file.log, 'Procedure '||
						lv_rec.proc_name||
						' does not contain any body text.');
        fnd_file.put_line(fnd_file.log, 'Ignored...');
        GOTO l_continue;
      ELSE
        null;
      END IF;

   -- Read the CLOB into a varchar2 buffer!!!
      begin
        loop
           dbms_lob.read(lv_lob2, lv_amount, lv_offset, lv_buffer);
           lv_body := lv_body || lv_buffer;

           if lv_offset >= 32767 then
              exit;
           end if;

           lv_offset := lv_offset + lv_amount;

         end loop;
        exception
        when no_data_found then
            null;
        end;

       IF lv_rec.proc_type = 'PROVISIONING' THEN
         BEGIN
           SELECT FULFILLMENT_ACTION_ID, FE_SW_GEN_LOOKUP_ID
           INTO lv_fa_id, lv_sw_gen_id
           FROM
              XDP_FA_FULFILLMENT_PROC fp
           where
             fp.fulfillment_proc = lv_rec.proc_name AND
             rownum = 1;

		for v_adapter in lc_adapter loop
			lv_adapter_type := v_adapter.adapter_type;
		end loop;

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
             lv_fa_id := NULL;
         END;
       ELSIF lv_rec.proc_type = 'CONNECT' THEN
         BEGIN
           SELECT FETYPE_ID
           INTO lv_fetype_id
           FROM
              xdp_fe_sw_gen_lookup fp
           where
              fp.sw_start_proc = lv_rec.proc_name AND
              rownum = 1;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              SELECT fa.FETYPE_ID
              INTO lv_fetype_id
              FROM XDP_FES fa,
               xdp_fe_generic_config fp
              where
               fa.fe_id = fp.fe_id AND
               fp.sw_start_proc = lv_rec.proc_name AND
               rownum = 1;
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 lv_fetype_id := NULL;
            END;
        END;
       ELSIF lv_rec.proc_type = 'DISCONNECT' THEN
         BEGIN
           SELECT FETYPE_ID
           INTO lv_fetype_id
           FROM
              xdp_fe_sw_gen_lookup fp
           where
              fp.sw_exit_proc = lv_rec.proc_name AND
              rownum = 1;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              SELECT fa.FETYPE_ID
              INTO lv_fetype_id
              FROM XDP_FES fa,
               xdp_fe_generic_config fp
              where
               fa.fe_id = fp.fe_id AND
               fp.sw_exit_proc = lv_rec.proc_name AND
               rownum = 1;
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 lv_fetype_id := NULL;
            END;
        END;
      ELSE
          lv_fetype_id := NULL;
 		 lv_fa_id := NULL;
      END IF;

	lv_proc_name := XDP_PROCEDURE_UTIL.decode_proc_name (lv_rec.proc_name) ;

-- The ID for Pre-Compilation depends on the type of the procedure
	if lv_rec.proc_type = 'PROVISIONING' then
		lv_ActualID := lv_fa_id;
	elsif lv_rec.proc_type in ('CONNECT','DISCONNECT') then
		lv_ActualID := lv_fetype_id;
	end if;

	fnd_file.put_line(fnd_file.output,'Pre-Compiling Package...');
	xdp_procedure_builder.PrecompileProcedure(
                        p_ProcType => lv_rec.proc_type,
                        p_ProcBody => lv_body,
                        p_ID => lv_ActualID,
			p_AdapterType => lv_adapter_type,
                        x_ErrorCode => lv_ret,
                        x_ErrorString => lv_str);

	 if lv_ret <> 0 then
                fnd_file.put_line(fnd_file.log,
		'--------------------------------------------------------------');
                fnd_file.put_line(fnd_file.log,'Package Pre-Compilation failed');
		fnd_file.put_line(fnd_file.log,
			'Pre-Compilation failed for procedure: '||lv_rec.proc_name);
		for lv_index in 1..(LENGTH(lv_str)/80 + 1) loop
			fnd_file.put_line(fnd_file.log,
				SUBSTR(lv_str,((lv_index - 1) * 80) + 1, 80));
		end loop;
                lv_ret := 0;
		goto l_continue;
	 else
		fnd_file.put_line(fnd_file.output,
				'Package Pre-Compiled created successfully... ');
	end if;


         fnd_file.put_line(fnd_file.output,'Creating Package Spec... ');
	 XDP_PROCEDURE_UTIL.Create_Package_Spec(
		lv_proc_name,
		lv_rec.proc_type,
		lv_ret,
		lv_str);
	 if lv_ret <> 0 then
                fnd_file.put_line(fnd_file.log,'--------------------------------------------------------------');
                fnd_file.put_line(fnd_file.log,'Package Spec creation failed');
		fnd_file.put_line(fnd_file.log,'Compilation failed for procedure: '||lv_rec.proc_name);
		for lv_index in 1..(LENGTH(lv_str)/80 + 1) loop
			fnd_file.put_line(fnd_file.log,SUBSTR(lv_str,((lv_index - 1) * 80) + 1, 80));
		end loop;
                lv_ret := 0;
		goto l_continue;
	 else
         fnd_file.put_line(fnd_file.output,'Package Spec created successfully... ');
         fnd_file.put_line(fnd_file.output,'Creating Package Body... ');
	 	XDP_PROCEDURE_UTIL.Create_Package_Body(
			lv_proc_name,
			lv_rec.proc_type,
			lv_fa_id,
			lv_fetype_id,
			lv_body,
			lv_ret,
			lv_str);

	 	if lv_ret <> 0 then
                   fnd_file.put_line(fnd_file.log,'--------------------------------------------------------------');
                   fnd_file.put_line(fnd_file.log,'Package Body creation failed');
                   fnd_file.put_line(fnd_file.log,'Compilation failed for procedure: '||lv_rec.proc_name);
			for lv_index in 1..(LENGTH(lv_str)/80 + 1) loop
				fnd_file.put_line(fnd_file.log,SUBSTR(lv_str,((lv_index - 1) * 80) + 1, 80));
			end loop;
	                lv_ret := 0;
			goto l_continue;
		else
			fnd_file.put_line(fnd_file.output,'Compilation succeed for procedure: '||lv_rec.proc_name);
                        lv_ret := 0;
			commit;
		end if;
	 end if;
    <<l_continue>>
    	COMMIT;
 		fnd_file.put_line(fnd_file.output,' ');
		fnd_file.put_line(fnd_file.output,'--------------------------------------------------------------');
  	END LOOP;

	RETCODE := 0;
    ERRBUF := 'Success';
EXCEPTION
	WHEN OTHERS THEN
		RETCODE := 2;
    	ERRBUF := SQLERRM;
END RECOMPPKG;

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
    ERROR_DESCRIPTION OUT NOCOPY VARCHAR2)
IS

  TYPE v_cursorType IS REF CURSOR;
  v_cursor       v_cursorType;
  v_numRows      NUMBER := 0;
  lv_tmp_id      NUMBER;

BEGIN

  return_code := 0;

  IF v_cursor%ISOPEN THEN
     CLOSE v_cursor;
  END IF;

  OPEN v_cursor FOR p_query_block
                            USING P_ORDER_ID       ,
                                  P_ORDER_NUMBER   ,
                                  P_ORDER_VERSION  ,
                                  P_ORDER_REF_NAME ,
                                  P_ORDER_REF_VALUE,
                                  P_CUST_ID        ,
                                  P_CUST_NAME      ,
                                  P_PHONE_NUMBER   ,
                                  P_DUE_DATE       ,
                                  P_ACCOUNT_ID     ;

  LOOP
   FETCH v_cursor INTO lv_tmp_id;

   EXIT WHEN v_cursor%NOTFOUND OR v_cursor%NOTFOUND IS NULL;

   v_numRows := v_numRows + 1;
   p_id_list(v_numRows) := lv_tmp_id;

  END LOOP;

  CLOSE v_cursor;

EXCEPTION
       WHEN others THEN
            return_code := SQLCODE;
            error_description := SUBSTR(SQLERRM,1,280);
            CLOSE v_cursor;

END Get_XDP_OrderID_QUERY ;

-- Modified by SXBANERJ 07/05/2001
-- Procedure to call after raising user defined exception
--
-- Comment out fnd log as app_exception.raise_exception
-- does the logging and it is controlled from a profile option
--
  PROCEDURE raise_exception(p_object_type   IN VARCHAR2) IS
    BEGIN
/*
      fnd_log.message(4
                    ,p_object_type
                    ,FALSE);
*/
      APP_EXCEPTION.RAISE_EXCEPTION;
    END raise_exception;

  -- Procedure to call in WHEN OTHERS
  PROCEDURE generic_error(p_object_type IN VARCHAR2
                         ,p_object_key  IN VARCHAR2
                         ,p_errcode     IN VARCHAR2
                         ,p_errmsg      IN VARCHAR2) IS

    e_dummy_exception EXCEPTION;

  BEGIN
    IF SQLCODE <> -20001 THEN -- i.e. if procedure is NOT invoked
                              -- through APP_EXCEPTION.RAISE_EXCEPTION
      FND_MESSAGE.SET_NAME('XDP','XDP_UNHANDLED_EXCEPTION'); -- New message
      FND_MESSAGE.SET_TOKEN('OBJECT_KEY',p_object_key);
      FND_MESSAGE.SET_TOKEN('ERRCODE',p_errcode);
      FND_MESSAGE.SET_TOKEN('ERRMSG',p_errmsg);
/*
      fnd_log.message(4
                   ,p_object_type
                   ,FALSE);
*/
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
/*
      fnd_log.message(4
                    ,p_object_type
                    ,FALSE);
*/
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END generic_error;

-- Procedure to write data/text to CLOB from table of records

PROCEDURE WRITE_TABLE_TO_CLOB (p_source_table       IN XDP_TYPES.VARCHAR2_32767_TAB,
                               p_dest_clob      IN OUT NOCOPY CLOB,
                               x_error_code        OUT NOCOPY NUMBER,
                               x_error_description OUT NOCOPY VARCHAR2) IS

l_amount    NUMBER;

BEGIN
     DBMS_LOB.CREATETEMPORARY(p_dest_clob,TRUE);

     DBMS_LOB.OPEN(p_dest_clob,DBMS_LOB.LOB_READWRITE);


     FOR i in 1..p_source_table.COUNT
         LOOP
             l_amount := LENGTH(p_source_table(i));

             DBMS_LOB.WRITEAPPEND(p_dest_clob,l_amount,p_source_table(i));
         END LOOP ;

    DBMS_LOB.CLOSE(p_dest_clob);


EXCEPTION
     WHEN others THEN
          x_error_code := SQLCODE;
          x_error_description := SUBSTR(SQLERRM,1,280);

END WRITE_TABLE_TO_CLOB ;


PROCEDURE Initialize_pkg IS

BEGIN

g_message_list.DELETE ;

END Initialize_pkg ;



PROCEDURE Build_pkg(p_text IN VARCHAR2) IS

l_count NUMBER;

BEGIN

 l_count := g_message_list.COUNT;
 g_message_list(l_count+1) := p_text ;

END Build_pkg;


PROCEDURE Create_pkg (p_pkg_name               IN VARCHAR2,
                      p_pkg_type               IN VARCHAR2,
		      p_application_short_name IN VARCHAR2,
		      x_error_code            OUT NOCOPY NUMBER,
		      x_error_message         OUT NOCOPY VARCHAR2) IS

lv1         VARCHAR2(80);
lv2         VARCHAR2(80);
lv_schema   VARCHAR2(80);
lv_ret      BOOLEAN;
lv_loc1     NUMBER := 1;
lv_loc2     NUMBER;
lv_len      NUMBER := 0;
lv_row      NUMBER := 0;
lv_status   VARCHAR2(40);
lv_owner    VARCHAR2(80);
lf_owner    VARCHAR2(80);
lv_tmp      VARCHAR2(32767);
lv_tmp_len  NUMBER;
lv_lf       VARCHAR2(10);
lv_pkg_name VARCHAR2(80) := UPPER(p_pkg_name);
l_text_line VARCHAR2(32767);

CURSOR lc_status IS
       SELECT status, owner
         FROM all_objects
        WHERE object_name = lv_pkg_name
          AND object_type = p_pkg_type
          AND owner = lf_owner
          AND status <> 'VALID';

CURSOR lc_err(l_owner IN VARCHAR2) IS
       SELECT text
         FROM all_errors
        WHERE owner = l_owner
          AND name  = lv_pkg_name
        ORDER BY line;

BEGIN
        select user into lf_owner from dual;

x_error_code := 0;

lv_ret := FND_INSTALLATION.get_app_info(
            'FND',
             lv1,
             lv2,
             lv_schema);
             lv_lf := '
';

FOR i IN 1..g_message_list.COUNT
  LOOP
     lv_loc1 := 1 ;
     lv_len := NVL(LENGTH(g_message_list(i)),0);
     l_text_line := g_message_list(i) ;
     LOOP
	if lv_loc1 > lv_len then
	   exit;
	end if;

	lv_loc2 := INSTR(l_text_line,lv_lf,lv_loc1,1);

	if lv_loc2 = 0 then
 	   lv_tmp_len := lv_len - lv_loc1 + 1;
	   lv_tmp := SUBSTR(l_text_line,lv_loc1,lv_tmp_len);

	   if lv_tmp_len <= 255 then
	      lv_row := lv_row + 1;
  	      ad_ddl.build_package(
	          	lv_tmp,
		        lv_row
		        );
	      exit;
	   else
	      x_error_code    := -20111;
	      x_error_message :=
	             'Error:The following line exceeds 255 character.  '||
	             'Please insert a character return to break up the line.'|| SUBSTR(lv_tmp,1,257);
	      return;
	   end if;
	else
	   lv_tmp_len := lv_loc2 - lv_loc1;
	   lv_tmp := SUBSTR(l_text_line,lv_loc1,lv_tmp_len);

	   if lv_tmp_len <= 255 then
	      lv_row := lv_row + 1;
  	      ad_ddl.build_package(
			lv_tmp,
			lv_row
			);
	      lv_loc1 := lv_loc1 + lv_tmp_len + 1;
	   else
	      x_error_code := -20111;
	      x_error_message :=
			'Error:The following line exceeds 255 character.  '||
			'Please insert a character return to break up the line.'||
			SUBSTR(lv_tmp,1,257);
	      return;
	   end if;
	end if;
     END LOOP;
  END LOOP;

	IF lv_row = 0 THEN
	  x_error_code := -20111;
	  x_error_message := 'Error:The package spec can not be empty.';
	  return;
	END IF;

	AD_DDL.CREATE_PACKAGE(
		lv_schema  ,
		p_application_short_name  ,
		p_pkg_name,
		'FALSE',
		1,
		lv_row
		);

	lv_status := 'VALID';

	FOR lv_status_rec IN lc_status
            LOOP
               lv_status := lv_status_rec.status;
	       lv_owner := lv_status_rec.owner;
	       exit;
	    END LOOP;

    IF lv_status <> 'VALID' THEN
	   x_error_code := -24344;
	   FOR lv_err_rec in lc_err(lv_owner)
               LOOP
		  x_error_message := x_error_message ||lv_err_rec.text||' ';
	       END LOOP;
    END IF;

EXCEPTION
     WHEN others THEN
          x_error_code := SQLCODE;
          x_error_message := SUBSTR(SQLERRM,1,280);
END Create_pkg;

PROCEDURE SET_TIME_OUT (itemtype  IN VARCHAR2,
			              itemkey   IN VARCHAR2,
			              actid     IN NUMBER,
			              funcmode  IN VARCHAR2,
			              resultout OUT NOCOPY VARCHAR2 ) IS

 x_Progress   VARCHAR2(2000);
 l_time_out_str   VARCHAR2(100);
 l_time_out_num   NUMBER;

BEGIN

-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
               if( fnd_profile.defined( 'XDP_TIME_OUT') ) THEN
                 fnd_profile.get( 'XDP_TIME_OUT',  l_time_out_str );
                 l_time_out_num := to_number( l_time_out_str );
                 wf_engine.SetItemAttrNumber(itemtype => SET_TIME_OUT.itemtype,
                                             itemkey  => SET_TIME_OUT.itemkey,
                                             aname    => 'TIME_OUT',
                                             avalue   => l_time_out_num );

               end if;
               resultout := 'COMPLETE';
               return;
        ELSE
               resultout := 'COMPLETE';
               return;
        END IF;


EXCEPTION
     WHEN OTHERS THEN
      wf_core.context('XDP_UTILITIES', 'SET_TIME_OUT', itemtype, itemkey, to_char(actid), funcmode);
      raise;
END SET_TIME_OUT;

PROCEDURE SET_FP_RETRY_COUNT (itemtype  IN VARCHAR2,
			              itemkey   IN VARCHAR2,
			              actid     IN NUMBER,
			              funcmode  IN VARCHAR2,
			              resultout OUT NOCOPY VARCHAR2 ) IS

 x_Progress   VARCHAR2(2000);
 l_fp_retry_count_str   VARCHAR2(100);
 l_fp_retry_count_num   NUMBER;
 l_err_desc   VARCHAR2(2000);
 l_err_code   NUMBER;
 l_fp_current_numb_retries   NUMBER;

BEGIN

-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
               if( fnd_profile.defined( 'XDP_FP_RETRY_COUNT') ) THEN

                 fnd_profile.get( 'XDP_FP_RETRY_COUNT',  l_fp_retry_count_str );
                 l_fp_retry_count_num := to_number( l_fp_retry_count_str );

                 BEGIN
                   l_fp_current_numb_retries := wf_engine.getItemAttrNumber(
                                                  itemtype => SET_FP_RETRY_COUNT.itemtype,
                                                  itemkey  => SET_FP_RETRY_COUNT.itemkey,
                                                  aname    => 'RETRY_COUNT');
                   IF( l_fp_current_numb_retries > l_fp_retry_count_num ) THEN
                     --Clear the time out Item attribute
                     wf_engine.setItemAttrNumber( itemtype => SET_FP_RETRY_COUNT.itemtype,
                                                  itemkey  => SET_FP_RETRY_COUNT.itemkey,
                                                  aname    => 'TIME_OUT',
                                                  avalue   => 0);

                     resultout := 'Y';
                   ELSE
                     resultout := 'N';
                   END IF;

                   l_fp_current_numb_retries := l_fp_current_numb_retries + 1;

                   wf_engine.setItemAttrNumber( itemtype => SET_FP_RETRY_COUNT.itemtype,
                                                itemkey  => SET_FP_RETRY_COUNT.itemkey,
                                                aname    => 'RETRY_COUNT',
                                                avalue   => l_fp_current_numb_retries);

                 EXCEPTION
                   WHEN others THEN
                     --Item attribute doesnt exist; set to retry Zero.
                     xdpcore.checkNAddItemAttrNumber( itemtype => SET_FP_RETRY_COUNT.itemtype,
                                                  itemkey  => SET_FP_RETRY_COUNT.itemkey,
                                                  attrname    => 'RETRY_COUNT',
                                                  attrvalue   => 0,
                                                  errcode  => l_err_code,
                                                  errstr   => l_err_desc);
                   resultout := 'N';
                 END;
               else
                 --If profile option is not defined..
                 resultout := 'N';
               end if;
        ELSE
               resultout := 'COMPLETE';
               return;
        END IF;


EXCEPTION
     WHEN OTHERS THEN
      wf_core.context('XDP_UTILITIES', 'SET_FP_RETRY_COUNT', itemtype, itemkey, to_char(actid), funcmode);
      raise;
END SET_FP_RETRY_COUNT;

PROCEDURE GET_FA_RESPONSE_LOB_CONTENT ( p_FAInstanceID VARCHAR2,p_FECmdSequence VARCHAR2,  p_clob_content OUT NOCOPY VARCHAR2 )
IS
 l_clob CLOB;
 l_length number := 32767;
BEGIN
  SELECT response_long into l_clob
  FROM xdp_fe_cmd_aud_trails
  WHERE fa_instance_id = p_FAInstanceID
  AND fe_command_seq = p_FECmdSequence;
  -- get the content..
  dbms_lob.read(l_clob,l_length,1,p_clob_content);
EXCEPTION
     WHEN OTHERS THEN
      xdpcore.context('XDP_UTILITIES', 'GET_FA_RESPONSE_LOB_CONTENT', 'FA', p_FAInstanceID);
      raise;
end GET_FA_RESPONSE_LOB_CONTENT;



Function GET_ASCII_TEXT( p_raw_string IN VARCHAR2 ) return VARCHAR2
IS
 l_ascii_string VARCHAR2(32767);
 l_cur_char	CHAR(1) ;
 l_str_length	NUMBER ;
 l_char_ascii	NUMBER ;

BEGIN
  l_str_length := LENGTH( p_raw_string ) ;
  IF l_str_length = 0 THEN
    RETURN NULL;
  END IF;

  FOR i IN 1..l_str_length LOOP

    l_cur_char   := SUBSTR( p_raw_string, i, 1 ) ;
    l_char_ascii := ASCII( l_cur_char ) ;

    -- ASCII character range 20 - 126 are displayble characters
    -- To keep the formatting we dont want to replace  ASCII 10(line feed)
    -- and 13(Vertical Tab).

    IF ( l_char_ascii  BETWEEN 20 AND 126 ) THEN
      l_ascii_string := l_ascii_string || l_cur_char;
    ELSE
      l_ascii_string := l_ascii_string || 'CHR('|| l_char_ascii || ')' || l_cur_char;
    END IF;

    IF ( LENGTH( l_ascii_string ) = 32767 ) THEN
      EXIT;
    END IF;
  END LOOP;

  RETURN l_ascii_string;

EXCEPTION
     WHEN OTHERS THEN
      raise;
END GET_ASCII_TEXT;


END XDP_UTILITIES;

/
