--------------------------------------------------------
--  DDL for Package Body AZW_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZW_UTIL" as
/* $Header: AZWUTILB.pls 115.12 2003/04/08 08:50:27 sbandi ship $: */

-- UpdateDocUrl
--   Called by AIWStart
--   Update the urls in the specific implementation workflow to reflect
-- site specific information.
--   Used by the new UI.
--
procedure UpdateDocUrl(
  p_itemtype in varchar2,
  p_workflow in varchar2) IS
  proc_version   wf_process_activities.process_version%TYPE;
  act_itemtype   wf_activities.item_type%TYPE;
  act_name       wf_activities.name%TYPE;
  act_type       wf_activities.type%TYPE;
  mesg_name      wf_activities.message%TYPE;
  app_short_name varchar2(30);
  target         varchar2(255);
  url            varchar2(255);

  CURSOR c_act_c IS
    select activity_item_type, activity_name
    from wf_process_activities
    start with (process_item_type = p_itemtype
                and   process_version = proc_version
                and   process_name = p_workflow)
    connect by (prior  activity_name = process_name
                and prior activity_item_type = process_item_type);

  CURSOR c_apps_c IS
            select text_default
            from wf_message_attributes_vl
            where message_type = act_itemtype
            and   message_name = mesg_name
            and   name         = 'AZW_IA_APPSNAME';

  CURSOR c_target_c IS
            select text_default
            from wf_message_attributes_vl
            where message_type = act_itemtype
            and   message_name = mesg_name
            and   name         = 'AZW_IA_TARGET';
BEGIN
    BEGIN
	  select max(process_version) into proc_version
	  from wf_process_activities
	  where process_item_type = p_itemtype
	  and   process_name      = p_workflow;
    EXCEPTION
    	WHEN app_exception.application_exception THEN
          RAISE ;
	WHEN OTHERS THEN
	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_util.UpdateDocUrl');
	     fnd_message.set_token('AZW_ERROR_STMT','select process_version from wf_process_activities');
	     APP_EXCEPTION.RAISE_EXCEPTION;
    END;

  OPEN c_act_c;
  FETCH c_act_c into act_itemtype, act_name;
  while(c_act_c%FOUND) loop
        BEGIN
	    select type into act_type
	    from wf_activities
	    where item_type = act_itemtype
	    and   name      = act_name
	    and   end_date is NULL;
        EXCEPTION
    	    WHEN app_exception.application_exception THEN
              RAISE ;
	    WHEN OTHERS THEN
	         fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	         fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	         fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	         fnd_message.set_token('AZW_ERROR_PROC','azw_util.UpdateDocUrl');
	         fnd_message.set_token('AZW_ERROR_STMT','select type from wf_activities');
	         APP_EXCEPTION.RAISE_EXCEPTION;
    	END;

    if (act_type = 'NOTICE') then
        BEGIN
	      select message into mesg_name
	      from wf_activities
	      where item_type = act_itemtype
	      and   name      = act_name
	      and   end_date is NULL;
        EXCEPTION
    	    WHEN app_exception.application_exception THEN
              RAISE ;
	    WHEN OTHERS THEN
	         fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	         fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	         fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	         fnd_message.set_token('AZW_ERROR_PROC','azw_util.UpdateDocUrl');
	         fnd_message.set_token('AZW_ERROR_STMT','select message from wf_activities');
	         APP_EXCEPTION.RAISE_EXCEPTION;
    	END;

        BEGIN
	      OPEN c_apps_c;
	      FETCH c_apps_c into app_short_name;
	      CLOSE c_apps_c;
        EXCEPTION
    	    WHEN app_exception.application_exception THEN
              RAISE ;
	    WHEN OTHERS THEN
	         fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	         fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	         fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	         fnd_message.set_token('AZW_ERROR_PROC','azw_util.UpdateDocUrl');
	         fnd_message.set_token('AZW_ERROR_STMT','cursor c_apps_c');
	         APP_EXCEPTION.RAISE_EXCEPTION;
    	END;

        BEGIN
	      OPEN c_target_c;
	      FETCH c_target_c into target;
	      CLOSE c_target_c;
        EXCEPTION
    	    WHEN app_exception.application_exception THEN
              RAISE ;
	    WHEN OTHERS THEN
	         fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	         fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	         fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	         fnd_message.set_token('AZW_ERROR_PROC','azw_util.UpdateDocUrl');
	         fnd_message.set_token('AZW_ERROR_STMT','cursor c_target_c');
	         APP_EXCEPTION.RAISE_EXCEPTION;
    	END;

	      url := fnd_help.get_url(app_short_name, target);

        BEGIN
	      update wf_message_attributes
	      set text_default = url
	      where message_type = act_itemtype
	      and   message_name = mesg_name
	      and   name         = 'AZW_IA_DOC';
        EXCEPTION
    	    WHEN app_exception.application_exception THEN
              RAISE ;
	    WHEN OTHERS THEN
	         fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	         fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	         fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	         fnd_message.set_token('AZW_ERROR_PROC','azw_util.UpdateDocUrl');
	         fnd_message.set_token('AZW_ERROR_STMT','update wf_message_attribute');
	         APP_EXCEPTION.RAISE_EXCEPTION;
    	END;
    end if;

    FETCH c_act_c into act_itemtype, act_name;
  end loop;
  CLOSE c_act_c;

EXCEPTION
    WHEN app_exception.application_exception THEN
      RAISE ;
    WHEN OTHERS THEN
	 fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	 fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	 fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	 fnd_message.set_token('AZW_ERROR_PROC','azw_util.UpdateDocUrl');
	 fnd_message.set_token('AZW_ERROR_STMT','cursor c_act_c');
	 APP_EXCEPTION.RAISE_EXCEPTION;
End UpdateDocUrl;

-- IsProductInstalled
--   Called by workflow engine in branching functions activities.
--   Check whether the product associated with the workflow is installed
-- or not.
--
procedure IsProductInstalled(
  itemtype    in  varchar2,
  itemkey     in  varchar2,
  actid       in  number,
  funcmode    in  varchar2,
  result      out NOCOPY varchar2 ) is

  prod_name     varchar2(2000);
  prod_id       number;
  --c_char      VARCHAR(1);
  --c_count     NUMBER(15);
  --c_word      VARCHAR(240);
  yes_result  VARCHAR2(240);
  no_result   VARCHAR2(240);
  tmp_result  VARCHAR2(240);
begin
        yes_result := 'COMPLETE:Y';
        no_result  := 'COMPLETE:N';

        prod_name := wf_engine.GetActivityAttrText(itemtype, itemkey,actid, 'AZW_IA_WFPROD');
	   tmp_result := CheckProduct(prod_name);
        if (tmp_result = 'TRUE') then
		result := yes_result;
        else
		result := no_result;
        end if;
EXCEPTION
    WHEN app_exception.application_exception THEN
      RAISE ;
    WHEN OTHERS THEN
	 fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	 fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	 fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	 fnd_message.set_token('AZW_ERROR_PROC','azw_util.IsProductInstalled');
	 fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
	 APP_EXCEPTION.RAISE_EXCEPTION;
END IsProductInstalled;

-- CheckProduct
--   Called by IsProcessRunnable
--   Check whether a product is installed
--
function CheckProduct(
  prod_name in varchar2)
  return varchar2
IS
  prod_id       number;
  is_number   BOOLEAN;
  l_status    VARCHAR2(1);
  l_industry  VARCHAR2(1);
  l_oracle_schema VARCHAR2(30);
  l_appl_short_name fnd_application_vl.application_short_name%TYPE;
  c_char      VARCHAR(1);
  c_count     NUMBER(15);
  c_word      VARCHAR(240);
  yes_result  VARCHAR2(240);
  no_result   VARCHAR2(240);
  result   VARCHAR2(240);
  v_count_installed  NUMBER(15);

  CURSOR c_prod_c IS
  	select application_id
  	from fnd_product_installations
  	where to_char(application_id) = LTRIM(RTRIM(c_word))
  	and (status = 'I' or status ='S');

BEGIN
  yes_result := 'TRUE';
  no_result  := 'FALSE';

  result := no_result;
  if(prod_name is null) then
    result := yes_result;
    return result;
  end if;

  if(prod_name like '%ALL%'
	OR prod_name like '%All%'
	OR prod_name like '%all%') then
    result := yes_result;
    return result;
  end if;

  c_char  := ' ';
  c_count := 0;
  while (NOT (c_char is null)) loop
    c_char  := ' ';
    c_word  := ' ';
    while (not (c_char is null)) and nvl(c_char, 'x') <> ',' loop
      c_word := c_word || c_char;
      c_count := c_count +1;
      c_char := substr(prod_name, c_count, 1);
    end loop;

    --check the product status
    is_number := TRUE;
    BEGIN
	 prod_id := to_number(c_word);
    EXCEPTION
	 WHEN OTHERS THEN
	   is_number := FALSE;
    END;
    IF( is_number = TRUE) THEN
    	--BEGIN
	SELECT COUNT(*)
        INTO v_count_installed
        FROM fnd_product_installations
        WHERE application_id = prod_id
        AND   status = 'I' OR status = 'S';
        IF (v_count_installed > 0 ) THEN
           result := yes_result;
        END IF;
    END IF;
  end loop;

  --result := yes_result;
  RETURN result;
END CheckProduct;


-- validate_opm_context
-- Private procedure. Called by CheckContext.
-- Executes dynamic sql and returns the name and id of opmcontexts

  PROCEDURE validate_opm_context(ctx_type    		IN  varchar2,
				current_ctx_name 	OUT NOCOPY VARCHAR2,
				current_ctx_id 	     	OUT NOCOPY NUMBER) IS

    curs         integer;
    rows         integer;
    sqlstatement az_contexts_sql.SQL_STATEMENT%TYPE;
    opm_id       varchar2(30);

  BEGIN

    fnd_profile.get('GEMMS_DEFAULT_ORGN', opm_id);

    --select organization_id, orgn_name
    --from   sy_orgn_mst
    --where  orgn_code = opm_id;

     SELECT sql_statement
     INTO   sqlstatement
     FROM   az_contexts_sql
     WHERE  context = ctx_type
     AND    purpose = 'VALIDATE';

     curs := DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.PARSE(curs, sqlstatement, DBMS_SQL.NATIVE);

     DBMS_SQL.DEFINE_COLUMN(curs, 1, current_ctx_id);
     DBMS_SQL.DEFINE_COLUMN(curs, 2, current_ctx_name, 80);
     DBMS_SQL.BIND_VARIABLE(curs, ':opm_id', opm_id);

     rows := DBMS_SQL.EXECUTE(curs);
     rows := DBMS_SQL.FETCH_ROWS(curs);

     DBMS_SQL.COLUMN_VALUE(curs, 1, current_ctx_id);
     DBMS_SQL.COLUMN_VALUE(curs, 2, current_ctx_name);
     DBMS_SQL.CLOSE_CURSOR(curs);

    EXCEPTION
    	WHEN OTHERS THEN
	    IF DBMS_SQL.IS_OPEN(curs) then
		  DBMS_SQL.CLOSE_CURSOR(curs);
	     END IF;

	     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
	     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
	     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
	     fnd_message.set_token('AZW_ERROR_PROC','azw_util.validate_opm_context');
	     fnd_message.set_token('AZW_ERROR_STMT','UNKNOWN');
	     APP_EXCEPTION.RAISE_EXCEPTION;

  END validate_opm_context;



-- CheckContext
--   Called by Callback
--   Do the context checking
--
procedure CheckContext(
  itemtype    in  varchar2,
  itemkey     in  varchar2,
  result      out NOCOPY varchar2) IS
  context_type    varchar2(30);
  context_name    varchar2(2000);
  context         varchar2(2000);
  task_ctxt_id number;
  task_ctxt_id_txt varchar2(2000);
  resp_ctxt_id    number;

  act_name        WF_ITEMS.ROOT_ACTIVITY%TYPE;
  bg_id           per_business_groups.BUSINESS_GROUP_ID%TYPE;
  ou_id           HR_OPERATING_UNITS.ORGANIZATION_ID%TYPE;
  io_id           ORG_ORGANIZATION_DEFINITIONS.ORGANIZATION_ID%TYPE;
BEGIN
  result := 'TRUE';

    BEGIN
      task_ctxt_id_txt := wf_engine.GetItemAttrText(itemtype, itemkey,
                            'AZW_IA_CTXT_ID');
      task_ctxt_id := to_number(task_ctxt_id_txt);
    EXCEPTION
      WHEN OTHERS THEN
        task_ctxt_id := null;
    END;

  --Get the context type and context name from workflow process
  context_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'AZW_IA_CTXTNAME');
  --context_type := wf_engine.GetItemAttrText(itemtype, itemkey, 'AZW_IA_CTXTYP');

  select root_activity into act_name
  from wf_items
  where item_type = itemtype
  and   item_key  = itemkey;

  select waav.TEXT_DEFAULT into context_type
  from wf_activity_attributes_vl waav
  where waav.activity_item_type = itemtype
    AND act_name = waav.activity_name
    AND waav.NAME = 'AZW_IA_CTXTYP'
    AND waav.activity_version =
	 (select max(waav.activity_version)
	  from wf_activity_attributes_vl waav
	  where waav.activity_item_type = itemtype
	  AND act_name = waav.activity_name
	  AND waav.NAME = 'AZW_IA_CTXTYP'
	  );

  --Get the current context value
  if(context_type = 'BG') then
    fnd_profile.get('PER_BUSINESS_GROUP_ID', context);
    bg_id := to_number(context);
    resp_ctxt_id := bg_id;
    select name into context
    from per_business_groups
    where BUSINESS_GROUP_ID = bg_id;
  elsif (context_type = 'OU') then
    fnd_profile.get('ORG_ID', context);
    ou_id := to_number(context);
    resp_ctxt_id := ou_id;
    select name into context
    from HR_OPERATING_UNITS
    where ORGANIZATION_ID = ou_id;
  elsif (context_type = 'SOB') then
    fnd_profile.get('GL_SET_OF_BKS_ID', context);
    resp_ctxt_id := to_number(context);
    fnd_profile.get('GL_SET_OF_BKS_NAME', context);

  elsif (context_type = 'OPMCOM' OR context_type = 'OPMORG') then
    validate_opm_context(context_type, context, resp_ctxt_id);

  elsif (context_type = 'IO') then
    --update wf_notification_attributes
    --set text_value = 'INVIDITM'
    --where notification_id = 822
    --and name = 'AZW_IA_FORM';
    --fnd_org.choose_org;
    return;
  else
    return;
  end if;

  context_name := NVL(context_name, ' ');
  context := NVL(context, ' ');

  if(task_ctxt_id is not null) then
    if(task_ctxt_id = resp_ctxt_id) then
      result := 'TRUE';
    else
      result := 'FALSE';
    end if;
  else
    if( context_name = context) then
      result := 'TRUE';
    else
      result := 'FALSE';
    end if;
  end if;
  if( result = 'TRUE') then
    return;
  end if;

    if (context_type = 'SOB') then
      fnd_message.set_name('AZ', 'AZW_INCORRECT_CONTEXT_SOB');
    elsif (context_type = 'OU') then
      fnd_message.set_name('AZ', 'AZW_INCORRECT_CONTEXT_OU');
    elsif (context_type = 'BG') then
      fnd_message.set_name('AZ', 'AZW_INCORRECT_CONTEXT_BG');
    elsif (context_type = 'IO') then
      fnd_message.set_name('AZ', 'AZW_INCORRECT_CONTEXT_INV');
     elsif (context_type = 'OPMCOM') then
      fnd_message.set_name('AZ', 'AZW_INCORRECT_CONTEXT_OPMCOM');
     elsif (context_type = 'OPMORG') then
      fnd_message.set_name('AZ', 'AZW_INCORRECT_CONTEXT_OPMORG');
    end if;
    fnd_message.set_token('AZWCURTYPE', context_type);
    fnd_message.set_token('AZWCURCTXT', context);
    fnd_message.set_token('AZWDESTYPE', context_type);
    fnd_message.set_token('AZWDESCTXT', context_name);
    APP_EXCEPTION.RAISE_EXCEPTION;

END CheckContext;

-- Callback
--   Called by notification form to do context checking
--
procedure Callback(
  itemtype    in  varchar2,
  itemkey     in  varchar2,
  actid       in  number,
  command     in  varchar2,
  result      in out NOCOPY varchar2 ) IS
  task_ctxt_id number;
  task_ctxt_id_txt varchar2(2000);

BEGIN
  if (command = 'TEST_CTX') then
    CheckContext(itemtype, itemkey, result);
  end if;

EXCEPTION
  WHEN app_exception.application_exception THEN
     RAISE ;
  WHEN OTHERS THEN
     fnd_message.set_name('AZ','AZW_PLSQL_EXCEPTION');
     fnd_message.set_token('AZW_ERROR_CODE',SQLCODE);
     fnd_message.set_token('AZW_ERROR_MESG',SQLERRM);
     fnd_message.set_token('AZW_ERROR_PROC','azw_util.Callback');
     fnd_message.set_token('AZW_ERROR_STMT','Call to CheckContext');
     APP_EXCEPTION.RAISE_EXCEPTION;
END Callback;

-- PreviousStep
--   Called by notification form
--   Go back to the previous notification.
--
procedure PreviousStep(
  itemtype    in  varchar2,
  itemkey     in  varchar2,
  result      out NOCOPY varchar2) IS

  CURSOR wf_act_c IS
    select wpa.instance_label, wpa.process_name, wias.notification_id
    from wf_item_activity_statuses wias,
         wf_process_activities wpa
    where wias.item_type = itemtype
    and wias.item_key = itemkey
    and wias.notification_id is not null
    and wias.process_activity = wpa.instance_id
    order by wias.begin_date desc;


  pre_act_label      wf_process_activities.instance_label%TYPE;
  pre_process_name   wf_process_activities.process_name%TYPE;
  pre_notification_id wf_item_activity_statuses_v.notification_id%TYPE;

  cur_act_label      wf_process_activities.instance_label%TYPE;
  cur_process_name   wf_process_activities.process_name%TYPE;
  cur_notification_id wf_item_activity_statuses_v.notification_id%TYPE;
  comment          wf_notifications.user_comment%TYPE;

BEGIN

  result := 'FALSE';
  open wf_act_c;
  FETCH wf_act_c INTO cur_act_label, cur_process_name, cur_notification_id;
  FETCH wf_act_c INTO pre_act_label, pre_process_name, pre_notification_id;
  if wf_act_c%FOUND then
    --Get the previous comment
    select wn.user_comment into comment
    from wf_notifications wn
    where wn.notification_id = pre_notification_id;

	 --Cancel the current message
	 --Deliver the previous message
    wf_engine.handleerror(itemtype, itemkey,pre_process_name||':'|| pre_act_label, 'RETRY');

    --Store the comment into the new notification
    close wf_act_c;
    open wf_act_c;
    FETCH wf_act_c INTO cur_act_label, cur_process_name, cur_notification_id;
    update wf_notifications
    set user_comment = comment
    where notification_id = cur_notification_id;

    result := 'TRUE';
  end if;
  close wf_act_c;
  commit;

EXCEPTION
  WHEN OTHERS THEN
    result := SQLERRM;

END PreviousStep;

end AZW_UTIL;


/
