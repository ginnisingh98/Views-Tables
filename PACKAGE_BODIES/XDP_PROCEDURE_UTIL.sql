--------------------------------------------------------
--  DDL for Package Body XDP_PROCEDURE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_PROCEDURE_UTIL" AS
/* $Header: XDPPUTLB.pls 120.1 2005/06/16 02:27:41 appldev  $ */

g_new_line CONSTANT VARCHAR2(10) := convert(FND_GLOBAL.LOCAL_CHR(10),
        substr(userenv('LANGUAGE'), instr(userenv('LANGUAGE'),'.') +1),
        'WE8ISO8859P1')  ;


  FUNCTION get_compilation_error(p_proc_name IN VARCHAR2)
    RETURN varchar2;

  Function get_procedure_body (proc_name varchar2)
    RETURN varchar2;

  Procedure CheckIfDuplicate(p_proc_name IN VARCHAR2,
			     p_proc_type IN VARCHAR2,
			     p_duplicate OUT NOCOPY BOOLEAN,
			     p_dup_type OUT NOCOPY VARCHAR2);

  Function CheckIfProcExists(p_proc_name IN VARCHAR2) return BOOLEAN;

  Procedure PreCompileProvProc(p_ProcName in varchar2,
                               p_FAID in number,
                               p_ProcBody in varchar2,
                               p_ErrCode OUT NOCOPY number,
                               p_ProcErrors OUT NOCOPY varchar2);

  Procedure PreCompileConnectProc(p_ProcName in varchar2,
                                  p_FeTypeID in number,
                                  p_ProcBody in varchar2,
                                  p_ErrCode OUT NOCOPY number,
                                  p_ProcErrors OUT NOCOPY varchar2);

FUNCTION get_compilation_error(p_proc_name IN VARCHAR2)
  RETURN varchar2
IS
  lv_err varchar2(2000):= ' ';
  CURSOR lc_text IS
   select text from user_errors
   where name = p_proc_name;
BEGIN

  for lc_text_rec IN lc_text LOOP
    if length(lv_err) < 2000 then
	lv_err := lv_err || substr(lc_text_rec.text, 1, 1998 - length(lv_err)) || ' ';
    end if;
  end loop;

    return lv_err;
END get_compilation_error;

procedure get_package_name(p_proc_name IN VARCHAR2,
	                   p_package_name  OUT NOCOPY varchar2,
	                   return_code  OUT NOCOPY NUMBER,
                           error_string OUT NOCOPY VARCHAR2)
IS
 lv_tmp varchar2(80);
BEGIN
 if length(p_proc_name) > 23 then
    return_code := -1;
    return;
 end if;

 if fnd_profile.defined('XDP_PACKAGE_SUFFIX') then
    fnd_profile.get('XDP_PACKAGE_SUFFIX',lv_tmp);
    lv_tmp := substr(lv_tmp,1,3);
 else
   lv_tmp := '_U';
 end if;

 p_package_name := 'XDP_' || p_proc_name || lv_tmp;

END get_package_name;


Function decode_proc_name(ProcName in varchar2) return varchar2 is
begin
  return (substr(ProcName,(instr(ProcName,'.',1) + 1), length(ProcName)));

end decode_proc_name;





FUNCTION get_procedure_body (proc_name varchar2)
  RETURN VARCHAR2
IS
lv_tmp_string varchar2(32767);
BEGIN
  lv_tmp_string := XDP_Utilities.Get_CLOB_Value(proc_name);
  return lv_tmp_string;

END get_procedure_body;



Procedure PreCompileProvProc(p_ProcName in varchar2,
                             p_FAID in number,
                             p_ProcBody in varchar2,
                             p_ErrCode OUT NOCOPY number,
                             p_ProcErrors OUT NOCOPY varchar2)
is

begin
 p_ErrCode := 0;
 p_ProcErrors := NULL;

 XDP_PROC_CTL.FIND_PARAMETERS(p_FAID, 0, p_ProcBody, p_ErrCode, p_ProcErrors);

 if p_ErrCode <> 0 then
   return;
 end if;

exception
when others then
  p_ErrCode := SQLCODE;
  p_ProcErrors := SUBSTR(SQLERRM,1,255);
end PreCompileProvProc;




Procedure PreCompileConnectProc(p_ProcName in varchar2,
                                p_FeTypeID in number,
                                p_ProcBody in varchar2,
                                p_ErrCode OUT NOCOPY number,
                                p_ProcErrors OUT NOCOPY varchar2)
is
begin

 p_ErrCode := 0;
 p_ProcErrors := NULL;

 XDP_PROC_CTL.FIND_CONNECT_PARAMETERS(p_FeTypeID, p_ProcBody, p_ErrCode, p_ProcErrors);

 if p_ErrCode <> 0 then
   return;
 end if;

exception
when others then
 p_ErrCode := SQLCODE;
 p_ProcErrors := SUBSTR(SQLERRM,1,255);
end PreCompileConnectProc;


Function Get_Package_Spec(
	p_proc_type IN VARCHAR2) return varchar2
is

 l_ProcSpec varchar2(32767);

 e_InvalidProcException exception;
begin

    IF p_proc_type = 'PROVISIONING' THEN

      l_ProcSpec :=
'/*****************************************************************************
This procedure is called by the FA to provision a FE for a particular service.
It has the following input parameters and no output parameters:

order_id         IN  NUMBER   -- order ID
line_item_id     IN NUMBER -- Line Item ID
workitem_instance_id IN  NUMBER   -- workitem instance ID
fa_instance_id IN  NUMBER   -- FA instance ID
db_channel_name  IN  VARCHAR2 -- Channel name used by this procedure
fe_name  IN  VARCHAR2 -- FE name to be provisioned by this procedure
fa_item_type   IN  VARCHAR2 -- FA workflow process item type
fa_item_key    IN  VARCHAR2 -- FA workflow process item key
*****************************************************************************/

-- Enter your procedure below:

BEGIN

-- your code...
null;

END;';


    ELSIF p_proc_type in ('CONNECT', 'DISCONNECT') THEN

      l_ProcSpec :=
'/*****************************************************************************
This procedure is used by the INTERACTIVE adapter to establish a connection
to the FE. This procedure is invoked when SFM is started or through the
Connection Management Utility (CMU).
It has the following input parameters and no output parameters:

fe_name       IN Varchar2 -- name of the FE this procedure will connect to
channel_name    IN Varchar2 -- name of the channel this procedure will use
*****************************************************************************/

-- Enter your procedure below:

BEGIN

-- your code...
null;

END;';

    ELSIF p_proc_type = 'LOCATE_FE' THEN

      l_ProcSpec :=
'/*****************************************************************************
This procedure returns the Fulfillment Element (FE) name of the FE
that is to be provisioned by this Fulfillment Action (FA).
It has the following input and output parameters:

p_order_id       IN  NUMBER   -- order ID
p_wi_instance_id IN  NUMBER   -- workitem instance ID
p_fa_instance_id IN  NUMBER   -- FA instance ID

p_fe_name        OUT VARCHAR2 -- FE to be provisioned
*****************************************************************************/

-- Enter your procedure below:

BEGIN

-- your code...
null;

END;';


    ELSIF p_proc_type = 'WI_PARAM_EVAL_PROC' THEN

      l_ProcSpec :=
'/*****************************************************************************
This procedure calculates a new value for the Workitem parameter.
It has the following input and output parameters:

p_order_id       IN  NUMBER   -- order ID
p_wi_instance_id IN  NUMBER   -- workitem instance ID
p_param_val      IN  VARCHAR2 -- parameter initial value
p_param_ref_val  IN  VARCHAR2 -- reference value (if order amendment)

p_param_eval_val     OUT VARCHAR2 -- parameter new value
p_param_eval_ref_val OUT VARCHAR2 -- new reference value (if order amendment)
*****************************************************************************/

-- Enter your procedure below:

BEGIN

-- your code...
null;

END;';

    ELSIF p_proc_type = 'FA_PARAM_EVAL_PROC' THEN

      l_ProcSpec :=
'/*****************************************************************************
This procedure calculates a new value for the Fulfullment Action parameter.
It has the following input and output parameters:

p_order_id       IN  NUMBER   -- order ID
p_wi_instance_id IN  NUMBER   -- workitem instance ID
p_fa_instance_id IN  NUMBER   -- FA instance ID
p_param_val      IN  VARCHAR2 -- parameter initial value
p_param_ref_val  IN  VARCHAR2 -- reference value (if order amendment)

p_param_eval_val     OUT VARCHAR2 -- parameter new value
p_param_eval_ref_val OUT VARCHAR2 -- new reference value (if order amendment)
*****************************************************************************/

-- Enter your procedure below:

BEGIN

-- your code...
null;

END;';

    ELSIF p_proc_type = 'FA_PARAM_EVAL_ALL_PROC' THEN

      l_ProcSpec :=
'/*****************************************************************************
This procedure evaluates all parameters for the Fulfillment Action (FA).
It has the following input parameters and no output parameters:

p_order_id       IN  NUMBER   -- order ID
p_wi_instance_id IN  NUMBER   -- workitem instance ID
p_fa_instance_id IN  NUMBER   -- FA instance ID

*****************************************************************************/

-- Enter your procedure below:

BEGIN

-- your code...
null;

END;';

    ELSIF p_proc_type = 'DYNAMIC_FA_MAPPING' THEN

      l_ProcSpec :=
'/*****************************************************************************
This procedure determines at runtime (dynamically) which FAs are used
by this workitem.
Use the XDP_ENG_UTIL.Add_FA_toWI() procedure to specify the FAs
that need to be called as part of the execution of this workitem.
the spec of Add_FA_to_WI() is:
procedure Add_FA_to_WI( p_wi_instance_id   IN NUMBER,
                        p_FA_name          IN VARCHAR2,
                        p_FE_name          IN VARCHAR2,
                        p_priority         IN NUMBER,
                        p_provisioning_seq IN NUMBER)

This procedure has the following input parameters and no output parameters:

p_order_id       IN  NUMBER   -- order ID
p_wi_instance_id IN  NUMBER   -- workitem instance ID
*****************************************************************************/

-- Enter your procedure below:

BEGIN

-- your code...
null;

END;';

    ELSIF p_proc_type = 'DYNAMIC_WI_MAPPING' THEN

      l_ProcSpec :=
'/*****************************************************************************
This procedure is used to determine at runtime (dynamically) the workitems
that are to be executed to provision this service.
It has the following input parameters and no output parameters:

p_order_id       IN  NUMBER   -- order ID
p_line_item_id   IN  NUMBER   -- line item ID
*****************************************************************************/

-- Enter your procedure below:

BEGIN

-- your code...
null;

END;';

    ELSIF p_proc_type = 'EXEC_WI_WORKFLOW' THEN

      l_ProcSpec :=
'/*****************************************************************************
This procedure can be used to specify a user defined workflow that should be
used to provision the service. This allows you to decide which workflow to
use at runtime (dynamically).
NOTE: you MUST create the workflow process (WF_ENGINE.createProcess()), BUT
      you can NOT start the process. Starting the process will be performed
      by SFM. You MUST return the itemtype, itemkey and process name in the
      output parameters provided.
It has the following input and output parameters:

p_order_id         IN NUMBER     -- order ID
p_wi_instance_id   IN NUMBER     -- workitem instance ID

p_wf_item_type     OUT VARCHAR2  -- itemtype of user workflow
p_wf_item_key      OUT VARCHAR2  -- itemkey  of user workflow
p_wf_process_name  OUT VARCHAR2  -- process  name of user workflow
*****************************************************************************/

-- Enter your procedure below:

BEGIN

-- your code...
null;

END;';


    ELSE
       raise e_InvalidProcException;

    END IF;

      return l_ProcSpec;

end Get_Package_Spec;


PROCEDURE Create_Package_Spec(
	p_proc_name IN VARCHAR2,
	p_proc_type IN VARCHAR2,
	return_code  OUT NOCOPY NUMBER,
	error_string OUT NOCOPY VARCHAR2)
IS

  lv_return_code NUMBER;
  lv_error_description VARCHAR2(32000);
  lv_out_str VARCHAR2(32600);

  lv_package_name varchar2(80);

  lv_dup_type varchar2(80);
  lv_dup BOOLEAN;

BEGIN
  return_code := 0;

/*
  CheckIfDuplicate(p_proc_name, p_proc_type, lv_dup, lv_dup_type);

  IF lv_dup then
     return_code := -20111;
     error_string := 'Error: A procedure of a different type '||lv_dup_type ||' already exists with the same name.';
     return;
  END IF;


  get_package_name(p_proc_name, lv_package_name, return_code, error_string);
  if return_code <> 0 then
     return;
  end if;
 */
 xdp_procedure_builder.generatepackagename(p_ProcType => p_proc_type,
					   p_ProcName => p_proc_name,
					   p_Validate => true,
					   x_PackageName => lv_package_name,
					   x_ErrorCode => return_code,
					   x_ErrorString => error_string);
 if return_code <> 0 then
	return;
 end if;

 xdp_procedure_builder.generatepackagespec(p_PackageName => lv_package_name,
					   p_ProcType => p_proc_type,
					   p_ProcName => p_proc_name,
					   x_ErrorCode => return_code,
					   x_ErrorString => error_string);

exception
 when OTHERS THEN
  return_code := SQLCODE;
  error_string := SQLERRM;
END Create_Package_Spec;



PROCEDURE Create_Package_Body(
   	p_proc_name IN VARCHAR2,
	p_proc_type IN VARCHAR2,
        p_FaID    in NUMBER,
        p_FeTypeID    in NUMBER,
	p_proc_body IN VARCHAR2,
	return_code  OUT NOCOPY NUMBER,
	error_string OUT NOCOPY VARCHAR2)
IS

  lv_return_code NUMBER;
  lv_error_description VARCHAR2(32000);
  lv_out_str VARCHAR2(32767);


  lv_package_name varchar2(80);

  lv_dup_type varchar2(80);
  lv_dup BOOLEAN;

  lv_Id number;

 e_NotProfileFoundException exception;

BEGIN
  return_code := 0;

  IF p_proc_body IS NULL THEN
     return_code := -20111;
     error_string := 'Error: The procedure body is empty.';
     return;
  END IF;

 xdp_procedure_builder.generatepackagename(p_ProcType => p_proc_type,
					   p_ProcName => p_proc_name,
					   p_Validate => true,
					   x_PackageName => lv_package_name,
					   x_ErrorCode => return_code,
					   x_ErrorString => error_string);
 if return_code <> 0 then
	return;
 end if;

  if p_Proc_type in
	(xdp_procedure_builder.g_ConnectType, xdp_procedure_builder.g_DisconnectType) then
	lv_ID := p_FeTypeID;
  elsif p_Proc_type in (xdp_procedure_builder.g_FPType,
			xdp_procedure_builder.g_LocateFEType,
			xdp_procedure_builder.g_FAParamEvalType) then
	lv_ID := p_FaID;
  else
	lv_ID := null;
  end if;

  return_code := 0;
  xdp_procedure_builder.generatepackagebody(p_PackageName => lv_package_name,
					    p_ProcType => p_proc_type,
					    p_ProcName => p_proc_name,
					    p_ProcBody => p_proc_body,
					    x_ErrorCode => return_code,
					    x_ErrorString => error_string);

  exception
  when OTHERS THEN
	return_code := SQLCODE;
	error_string := SQLERRM;
END Create_Package_Body;


PROCEDURE Load_Proc_Table(
	p_proc_name IN VARCHAR2,
	p_proc_type IN VARCHAR2,
	p_proc_body IN VARCHAR2,
	return_code  OUT NOCOPY NUMBER,
	error_string OUT NOCOPY VARCHAR2)
IS

  lv_exists varchar2(1);
BEGIN
-- No longer supported
-- Obsoleted
  return_code := 0;

END Load_Proc_Table;

PROCEDURE Rollback_Proc(
	p_proc_name IN VARCHAR2,
	p_proc_type IN VARCHAR2,
	p_FaID  IN NUMBER,
	p_FeTypeID  IN NUMBER,
	return_code OUT NOCOPY NUMBER,
	error_string OUT NOCOPY VARCHAR2)
IS

  lv_proc_body varchar2(32600);

BEGIN
  return_code := 0;

  if not CheckIfProcExists(p_proc_name) then
     return_code := -20111;
     error_string := 'Error: Can not rollback.  Procedure not exists.';
     return;
  end if;

  lv_proc_body := get_procedure_body (p_proc_name );
  Create_Package_Body(
	p_proc_name ,
	p_proc_type ,
	p_FaID,
	p_FeTypeID,
        lv_proc_body,
	return_code ,
	error_string );

END Rollback_Proc;


Procedure CheckIfDuplicate(p_proc_name IN VARCHAR2,
			   p_proc_type IN VARCHAR2,
			   p_duplicate OUT NOCOPY BOOLEAN,
			   p_dup_type OUT NOCOPY VARCHAR2)
is

  CURSOR c_CheckDup is
    select proc_type
    from xdp_proc_body
    where proc_name = p_proc_name
      and proc_type <> p_proc_type;
begin

  p_duplicate := FALSE;
  p_dup_type := NULL;

   for v_CheckDup in c_CheckDup loop
	p_duplicate := TRUE;
	p_dup_type := v_CheckDup.proc_type;
	exit;
   end loop;

end CheckIfDuplicate;


Function CheckIfProcExists(p_proc_name IN VARCHAR2) return BOOLEAN
is
lv_exists boolean := FALSE;

  CURSOR c_CheckExists is
    select 1
    from xdp_proc_body
    where proc_name = p_proc_name;
begin

   for v_CheckExists in c_CheckExists loop
        lv_exists := TRUE;
        exit;
   end loop;

   return (lv_exists);

end CheckIfProcExists;

END XDP_PROCEDURE_UTIL;

/
